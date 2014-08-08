USE [MSN_Dev]
GO
/****** Object:  StoredProcedure [dbo].[uspEnterpriseServiceBusDataProcess]    Script Date: 05/12/2010 08:32:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Created By:		John Starr
Company:		Stanley
Date:			06/03/2009
Description:	Activation stored procedure used to process data from the Coast
				Guard Enterprise Service Bus for MISLE.

Modified By: Lucas Truax 	
Company:	QSS	
Date:		09/10/2009	
Description: Changed the join on DeptId to filter out inactive units. Added SET XACT_ABORT ON. 

Modified By:	
Company:	
Date:		
Description:
*/

ALTER PROCEDURE [dbo].[uspEnterpriseServiceBusDataProcess]
AS

SET NOCOUNT ON;
SET XACT_ABORT ON;
DECLARE @idoc	int;
DECLARE @conversation_handle uniqueidentifier;
DECLARE @message_body xml;
DECLARE @message_type varchar(max);
DECLARE @inserted_records bigint;
DECLARE @updated_records bigint;

WHILE (1=1)
BEGIN
	SET @inserted_records = 0;
	SET @updated_records = 0;

	--Pop the top message off of the queue.
	RECEIVE TOP(1)
			@conversation_handle = conversation_handle,
			@message_type = message_type_name,
			@message_body = message_body
	FROM	dbo.EnterpriseServiceBusInboundQueue

	--If no rows were returned, break out of the loop.
	IF (@@ROWCOUNT = 0)
	BEGIN
		RETURN;
	END	

	--Process any messages from ALMIS that are data initialization messages.
	IF @message_type = '//MISLE/EnterpriseServiceBusData/MessageType/ALMIS/Inbound/Subscriber/Initialize'
	BEGIN
		--Try to process the message.  If an error occurs, catch it, rollback the transaction,
		--and log and audit failure message.
		BEGIN TRY
			EXEC sp_xml_preparedocument @idoc OUTPUT, @message_body,
			'<root	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
					xmlns:ns2="http://almis.uscg.dhs.gov/1.0" 
					xmlns:n ="http://uscg/C21/InitialResourceList"/>';

			--Retrieve the pertinent data to the store in the database from the XML message.
			SELECT	ALMISResourceId,
					Aircraft_HTN,
					Aircraft_Type,
					Aircraft_Status,
					DepartmentId,
					ResourceConcealedInd,
					Last_AMMIS_Update
			INTO	#ALMIS_Data
			FROM	OPENXML(@idoc,'/n:InitialResourceListResponse/n:Response/ns2:ResourceList/ns2:Resource',2)
			WITH	(
						ALMISResourceId			int			'ns2:ID',
						Aircraft_HTN			varchar(20)	'./ns2:ResourceIdentification/ns2:SerialNumber',
						Aircraft_Type			varchar(20)	'./ns2:ResourceVersion/ns2:Version',
						Aircraft_Status			varchar(10)	'./ns2:ResourceStatus/ns2:StatusCode',
						DepartmentID			varchar(10)	'./ns2:ResourceOwner/ns2:DepartmentID',
						ResourceConcealedInd	bit			'./ns2:ResourceConcealment/ns2:Concealed',
						Last_AMMIS_Update		datetime	'./ns2:ResourceStatus/ns2:EffectiveDate'
					);

			EXEC sp_xml_removedocument @idoc;

			BEGIN TRANSACTION
				--Insert any new Resource Types from ALMIS
				INSERT INTO	dbo.AOPS_Resource_Type
				(
					Resource_Type_Cd,
					[Description],
					Resource_Class_Cd,
					Active_Ind,
					Status_Cd,
					Last_Mod_Individual,
					Last_Mod_DtTm,
					Last_Mod_Unit_Id
				)
				SELECT			DISTINCT Aircraft_Type,
								'No description provided.',
								'AIR',
								1,
								'B2',
								'ALMIS Import',
								GETDATE(),
								98
				FROM			#ALMIS_Data ad
				LEFT OUTER JOIN	dbo.AOPS_Resource_Type art
							ON	ad.Aircraft_Type = art.Resource_Type_Cd
				WHERE			art.Resource_Type_Id IS NULL
							AND	NOT(ad.Aircraft_Type = '')
							AND ad.Aircraft_Type IS NOT NULL;
				
				--Insert new rows
				INSERT INTO dbo.AMMIS_Resource
				(
					Aircraft_HTN,
					Aircraft_Type,
					Aircraft_Status,
					OPFAC,
					Task,
					Lat,
					Long,
					Remarks,
					Last_Mod_Individual,
					Last_Mod_Dttm,
					Last_Mod_Unit_Id,
					Last_Ammis_Update,
					Active_Ind,
					ALMISResourceId,
					DepartmentId,
					ResourceConcealedInd
				)
				SELECT			ad.Aircraft_HTN,
								ad.Aircraft_Type,
								ad.Aircraft_Status,
								u.OPFAC,
								NULL,
								NULL,
								NULL,
								NULL,
								'ALMIS Import',
								GETDATE(),
								98,
								ad.Last_AMMIS_Update,
								1,
								ad.ALMISResourceId,
								ad.DepartmentId,
								ad.ResourceConcealedInd
				FROM			#ALMIS_Data ad
				LEFT OUTER JOIN	dbo.Unit u
							ON	ad.DepartmentId = u.DEPTID
							AND	U.Active_Ind = 1
				LEFT OUTER JOIN	dbo.AMMIS_Resource ar
							ON	ad.ALMISResourceId = ar.ALMISResourceId
				WHERE			ar.ALMISResourceId IS NULL;

				--Retrieve the number of rows inserted.
				SET @inserted_records = @@ROWCOUNT;

				--Update existing rows in MISLE
				--Aircraft_Type
				UPDATE		dbo.AMMIS_Resource
				SET			Aircraft_Type = ad.Aircraft_Type,
							Last_AMMIS_Update =	CASE
													WHEN ad.Last_AMMIS_Update IS NOT NULL
														THEN ad.Last_AMMIS_Update
													ELSE ar.Last_AMMIS_Update
												END,
							Last_Mod_Individual = 'ALMIS Import',
							Last_Mod_DtTm = GETDATE(),
							Last_Mod_Unit_Id = 98 
				FROM		dbo.AMMIS_Resource ar
				INNER JOIN	#ALMIS_Data ad
						ON	ar.ALMISResourceId = ad.ALMISResourceId
				WHERE		NOT(ad.Aircraft_Type = ar.Aircraft_Type);

				--Retrieve the number of rows updated and add to total.
				SET @updated_records = @updated_records + @@ROWCOUNT;

				--Aircraft_Status
				UPDATE		dbo.AMMIS_Resource
				SET			Aircraft_Status = ad.Aircraft_Status,
							Last_AMMIS_Update =	CASE
													WHEN ad.Last_AMMIS_Update IS NOT NULL
														THEN ad.Last_AMMIS_Update
													ELSE ar.Last_AMMIS_Update
												END,
							Last_Mod_Individual = 'ALMIS Import',
							Last_Mod_DtTm = GETDATE(),
							Last_Mod_Unit_Id = 98   
				FROM		dbo.AMMIS_Resource ar
				INNER JOIN	#ALMIS_Data ad
						ON	ar.ALMISResourceId = ad.ALMISResourceId
				WHERE		NOT(ad.Aircraft_Status = ar.Aircraft_Status);

				--Retrieve the number of rows updated and add to total.
				SET @updated_records = @updated_records + @@ROWCOUNT;

				--DepartmentId/OPFAC fields.
				UPDATE			dbo.AMMIS_Resource
				SET				DepartmentId = ad.DepartmentId,
								Last_AMMIS_Update =	CASE
														WHEN ad.Last_AMMIS_Update IS NOT NULL
															THEN ad.Last_AMMIS_Update
														ELSE ar.Last_AMMIS_Update
													END,
								OPFAC = u.OPFAC,
								Last_Mod_Individual = 'ALMIS Import',
								Last_Mod_DtTm = GETDATE(),
								Last_Mod_Unit_Id = 98   
				FROM			dbo.AMMIS_Resource ar
				INNER JOIN		#ALMIS_Data ad
							ON	ar.ALMISResourceId = ad.ALMISResourceId
				LEFT OUTER JOIN	dbo.Unit u
							ON	ad.DepartmentId = u.DEPTID
							AND	U.Active_ind = 1
				WHERE			NOT(ad.DepartmentId = ar.DepartmentId);

				--Retrieve the number of rows updated and add to total.
				SET @updated_records = @updated_records + @@ROWCOUNT;

				--ResourceConcealedInd fields.
				UPDATE			dbo.AMMIS_Resource
				SET				ResourceConcealedInd = ad.ResourceConcealedInd,
								Last_AMMIS_Update =	CASE
														WHEN ad.Last_AMMIS_Update IS NOT NULL
															THEN ad.Last_AMMIS_Update
														ELSE ar.Last_AMMIS_Update
													END,
								Last_Mod_Individual = 'ALMIS Import',
								Last_Mod_DtTm = GETDATE(),
								Last_Mod_Unit_Id = 98   
				FROM			dbo.AMMIS_Resource ar
				INNER JOIN		#ALMIS_Data ad
							ON	ar.ALMISResourceId = ad.ALMISResourceId
				WHERE			NOT(ad.ResourceConcealedInd = ar.ResourceConcealedInd);

				--Retrieve the number of rows updated and add to total.
				SET @updated_records = @updated_records + @@ROWCOUNT;

				--Log audit information to the database.
				INSERT INTO dbo.EnterpriseServiceBusMessageAudit
				(
					XML_Message,
					Message_Type,
					Rows_Inserted,
					Rows_Updated,
					Rows_Selected,
					Rows_Deleted,
					Error_Occurred_Ind,
					Error_Msg,
					Audit_DtTm
				)
				VALUES
				(
					@message_body,
					@message_type,
					@inserted_records,
					@updated_records,
					0,
					0,
					0,
					NULL,
					GETDATE()
				);
			COMMIT TRANSACTION

			DROP TABLE #ALMIS_Data;
		END TRY
		BEGIN CATCH
			--If the transaction is uncommittable, rollback the transaction.
			IF		XACT_STATE() = -1
				OR	XACT_STATE() = 1
			BEGIN
				ROLLBACK TRANSACTION
			END


			IF OBJECT_ID('tempdb..#ALMIS_Data') IS NOT NULL
			BEGIN
				DROP TABLE #ALMIS_Data
			END

			--Log information about the failure to the audit table.
			INSERT INTO dbo.EnterpriseServiceBusMessageAudit
			(
				XML_Message,
				Message_Type,
				Rows_Inserted,
				Rows_Updated,
				Rows_Selected,
				Rows_Deleted,
				Error_Occurred_Ind,
				Error_Msg
			)
			VALUES
			(
				@message_body,
				@message_type,
				0,
				0,
				0,
				0,
				1,
				ERROR_MESSAGE()
			);
		END CATCH
	END
	ELSE
	BEGIN
		--Process messages from ALMIS that are data delta messages.
		--If any errors occur, catch the error message, log it to an audit table.
		BEGIN TRY
			EXEC sp_xml_preparedocument	@iDoc OUTPUT, @message_body,
				'<root	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
				xmlns:ns2="http://almis.uscg.dhs.gov/1.0"/>';

			BEGIN TRANSACTION
				--If there is a Resource element in the message with an attribute name operation
				--equal to add, it is an insertion record.  Insert the data.
				IF	(@message_body.exist	(	'declare namespace ns2="http://almis.uscg.dhs.gov/1.0";
												//ns2:Resource[@operation = "add"]'
											)
					) = 1
				BEGIN
					WITH Resource (ALMISResourceId, ActionTaken) AS
					(
						SELECT		ALMISResourceId,
									ActionTaken
						FROM		OPENXML(@iDoc, '/ns2:ResourceList/ns2:Resource')
						WITH		(
										ALMISResourceId		int			'./ns2:ID',
										ActionTaken			varchar(10)	'./@operation'
									)
					)

					INSERT INTO dbo.AMMIS_Resource
					(
						ALMISResourceId,
						Last_Mod_Individual,
						Last_Mod_DtTm,
						Last_Mod_Unit_Id,
						Active_Ind
					)
					SELECT		ALMISResourceId,
								'ALMIS Import', 
								GETDATE(),
								98,
								1 As Active_Ind
					FROM		Resource r
					WHERE		r.ActionTaken = 'add'
							AND	NOT EXISTS	(
												SELECT	*
												FROM	dbo.AMMIS_Resource ar
												WHERE	ALMISResourceId = r.ALMISResourceId
											);
					
					--Retrieve the number of records inserted.
					SELECT @inserted_records = @@ROWCOUNT;
				END
			
				--If there is a ResourceStatus element in the message, update Status information about
				--the Resource.  The possibility exists for multiple updates to a single Resource to exist
				--in a single message, so the Effective_DtTm must be used as a tiebreaker as to what should be imported.
				IF	(@message_body.exist	(	'declare namespace ns2="http://almis.uscg.dhs.gov/1.0";
												//ns2:ResourceStatus'
											)
					) = 1
				BEGIN
					WITH ResourceStatus(ALMISResourceId, Aircraft_Status, Effective_DtTm) AS
					(
						SELECT		ALMISResourceId,
									Aircraft_Status,
									Effective_DtTm
						FROM		OPENXML(@iDoc, '/ns2:ResourceList/ns2:Resource/ns2:ResourceStatus')
						WITH		(
										ALMISResourceId		int			'../ns2:ID',
										Aircraft_Status		varchar(10)	'./ns2:StatusCode',
										Effective_DtTm		datetime	'./ns2:EffectiveDate'
									)
					)
					UPDATE		dbo.AMMIS_Resource
					SET			Aircraft_Status = rs.Aircraft_Status,
								Last_AMMIS_Update = rs.Effective_DtTm,
								Last_Mod_DtTm = GETDATE(),
								Last_Mod_Individual = 'ALMIS Import',
								Last_Mod_Unit_Id = 98
					FROM		dbo.AMMIS_Resource ar
					INNER JOIN	ResourceStatus rs
							ON	ar.ALMISResourceId = rs.ALMISResourceId
					WHERE		Effective_DtTm =	(
														SELECT	MAX(Effective_DtTm)
														FROM	ResourceStatus rsm
														WHERE	rs.ALMISResourceId = rsm.ALMISResourceId
													);

					--Retrieve the number of records updated and add it to the running total.
					SELECT @updated_records = @updated_records + @@ROWCOUNT;
				END

				--If there is a ResourceLocation element in the message, update Location information about
				--the Resource.  The possibility exists for multiple updates to a single Resource to exist
				--in a single message, so the Effective_DtTm must be used as a tiebreaker as to what should be imported.
				IF	(@message_body.exist	(	'declare namespace ns2="http://almis.uscg.dhs.gov/1.0";
												//ns2:ResourceOwner'
											)
					) = 1
				BEGIN
					WITH ResourceOwner(ALMISResourceId, Effective_DtTm, DepartmentID) AS
					(
						SELECT		ALMISResourceId,
									Effective_DtTm,
									DepartmentID
						FROM		OPENXML(@iDoc, '/ns2:ResourceList/ns2:Resource/ns2:ResourceOwner')
						WITH		(
										ALMISResourceId		int			'../ns2:ID',
										Effective_DtTm		datetime	'./ns2:EffectiveDate',
										DepartmentID		varchar(10)	'./ns2:DepartmentID'
									)
					)
					--Because MISLE still utilizes the OPFAC for assignment of Resources, capture the
					--OPFAC from the Unit table based on the Department Id.
					UPDATE			dbo.AMMIS_Resource
					SET				DepartmentId = ro.DepartmentId,
									OPFAC = u.OPFAC,
									Last_Mod_DtTm = GETDATE(),
									Last_Mod_Individual = 'ALMIS Import',
									Last_Mod_Unit_Id = 98									
					FROM			dbo.AMMIS_Resource ar
					INNER JOIN		ResourceOwner ro
								ON	ar.ALMISResourceId = ro.ALMISResourceId
					LEFT OUTER JOIN	dbo.Unit u
								ON	ro.DepartmentID = u.DEPTID
								AND	U.Active_Ind = 1
					WHERE			Effective_DtTm =	(
															SELECT	MAX(Effective_DtTm)
															FROM	ResourceOwner rom
															WHERE	ro.ALMISResourceId = rom.ALMISResourceId
														);


					--Retrieve the number of records updated and add it to the running total.
					SELECT @updated_records = @updated_records + @@ROWCOUNT;
				END

				--If there is a ResourceVersion element in the message, update Classification information about
				--the Resource.  The possibility exists for multiple updates to a single Resource to exist
				--in a single message, so the Effective_DtTm must be used as a tiebreaker as to what should be imported.
				IF	(@message_body.exist	(	'declare namespace ns2="http://almis.uscg.dhs.gov/1.0";
												//ns2:ResourceVersion'
											)
					) = 1
				BEGIN
					WITH ResourceVersion(ALMISResourceId, Effective_DtTm, Aircraft_Type) AS
					(
						SELECT		ALMISResourceId,
									Effective_DtTm,
									Aircraft_Type
						FROM		OPENXML(@iDoc, '/ns2:ResourceList/ns2:Resource/ns2:ResourceVersion')
						WITH		(
										ALMISResourceId		int			'../ns2:ID',
										Effective_DtTm		datetime	'./ns2:EffectiveDate',
										Aircraft_Type		varchar(20)	'./ns2:Version'
									)
					)
					INSERT INTO	dbo.AOPS_Resource_Type
					(
						Resource_Type_Cd,
						[Description],
						Resource_Class_Cd,
						Active_Ind,
						Status_Cd,
						Last_Mod_Individual,
						Last_Mod_DtTm,
						Last_Mod_Unit_Id
					)
					SELECT			DISTINCT Aircraft_Type,
									'No description provided.',
									'AIR',
									1,
									'B2',
									'ALMIS Import',
									GETDATE(),
									98
					FROM			ResourceVersion rv
					LEFT OUTER JOIN	dbo.AOPS_Resource_Type art
								ON	rv.Aircraft_Type = art.Resource_Type_Cd
					WHERE			art.Resource_Type_Id IS NULL
								AND	NOT(rv.Aircraft_Type = '')
								AND rv.Aircraft_Type IS NOT NULL;

					WITH ResourceVersion(ALMISResourceId, Effective_DtTm, Aircraft_Type) AS
					(
						SELECT		ALMISResourceId,
									Effective_DtTm,
									Aircraft_Type
						FROM		OPENXML(@iDoc, '/ns2:ResourceList/ns2:Resource/ns2:ResourceVersion')
						WITH		(
										ALMISResourceId		int			'../ns2:ID',
										Effective_DtTm		datetime	'./ns2:EffectiveDate',
										Aircraft_Type		varchar(20)	'./ns2:Version'
									)
					)
					UPDATE		dbo.AMMIS_Resource
					SET			Aircraft_Type = rv.Aircraft_Type,
								Last_Mod_DtTm = GETDATE(),
								Last_Mod_Individual = 'ALMIS Import',
								Last_Mod_Unit_Id = 98
					FROM		dbo.AMMIS_Resource ar
					INNER JOIN	ResourceVersion rv
							ON	ar.ALMISResourceId = rv.ALMISResourceId
					WHERE		Effective_DtTm =	(
														SELECT	MAX(Effective_DtTm)
														FROM	ResourceVersion rvm
														WHERE	rv.ALMISResourceId = rvm.ALMISResourceId
													);

					--Retrieve the number of records updated and add it to the running total.
					SELECT @updated_records = @updated_records + @@ROWCOUNT;
				END

				--If there is a ResourceIdentification element in the message, update Identification information about
				--the Resource.  The possibility exists for multiple updates to a single Resource to exist
				--in a single message, so the Effective_DtTm must be used as a tiebreaker as to what should be imported.
				IF	(@message_body.exist	(	'declare namespace ns2="http://almis.uscg.dhs.gov/1.0";
												//ns2:ResourceIdentification'
											)
					) = 1
				BEGIN
					WITH ResourceIdentification(ALMISResourceId, Effective_DtTm, Aircraft_HTN) AS
					(
						SELECT		ALMISResourceId,
									Effective_DtTm,
									Aircraft_HTN
						FROM		OPENXML(@iDoc, '/ns2:ResourceList/ns2:Resource/ns2:ResourceIdentification')
						WITH		(
										ALMISResourceId		int			'../ns2:ID',
										Effective_DtTm		datetime	'./ns2:EffectiveDate',
										Aircraft_HTN		varchar(20)	'./ns2:SerialNumber'
									)
					)
					UPDATE		dbo.AMMIS_Resource
					SET			Aircraft_HTN = ri.Aircraft_HTN,
								Last_Mod_DtTm = GETDATE(),
								Last_Mod_Individual = 'ALMIS Import',
								Last_Mod_Unit_Id = 98
					FROM		dbo.AMMIS_Resource ar
					INNER JOIN	ResourceIdentification ri
							ON	ar.ALMISResourceId = ri.ALMISResourceId
					WHERE		Effective_DtTm =	(
														SELECT	MAX(Effective_DtTm)
														FROM	ResourceIdentification rim
														WHERE	ri.ALMISResourceId = rim.ALMISResourceId
													);

					--Retrieve the number of records updated and add it to the running total.
					SELECT @updated_records = @updated_records + @@ROWCOUNT;
				END

				--If there is a ResourceConcealment element in the message, update Concealment information about
				--the Resource.  The possibility exists for multiple updates to a single Resource to exist
				--in a single message, so the Effective_DtTm must be used as a tiebreaker as to what should be imported.
				IF	(@message_body.exist	(	'declare namespace ns2="http://almis.uscg.dhs.gov/1.0";
												//ns2:ResourceConcealment'
											)
					) = 1
				BEGIN
					WITH ResourceConcealment(ALMISResourceId, Effective_DtTm, ResourceConcealedInd) AS
					(
						SELECT		ALMISResourceId,
									Effective_DtTm,
									ResourceConcealedInd
						FROM		OPENXML(@iDoc, '/ns2:ResourceList/ns2:Resource/ns2:ResourceConcealment')
						WITH		(
										ALMISResourceId			int			'../ns2:ID',
										Effective_DtTm			datetime	'./ns2:EffectiveDate',
										ResourceConcealedInd	bit			'./ns2:Concealed'
									)	
					)
					UPDATE		dbo.AMMIS_Resource
					SET			ResourceConcealedInd = rc.ResourceConcealedInd,
								Last_Mod_DtTm = GETDATE(),
								Last_Mod_Individual = 'ALMIS Import',
								Last_Mod_Unit_Id = 98
					FROM		dbo.AMMIS_Resource ar
					INNER JOIN	ResourceConcealment rc
							ON	ar.ALMISResourceId = rc.ALMISResourceId
					WHERE		Effective_DtTm =	(
														SELECT	MAX(Effective_DtTm)
														FROM	ResourceConcealment rcm
														WHERE	rc.ALMISResourceId = rcm.ALMISResourceId
													);

					--Retrieve the number of records updated and add it to the running total.
					SELECT @updated_records = @updated_records + @@ROWCOUNT;
				END

				--Log audit information about the message processed.
				INSERT INTO dbo.EnterpriseServiceBusMessageAudit
				(
					XML_Message,
					Message_Type,
					Rows_Inserted,
					Rows_Updated,
					Rows_Selected,
					Rows_Deleted,
					Error_Occurred_Ind,
					Error_Msg,
					Audit_DtTm
				)
				VALUES
				(
					@message_body,
					@message_type,
					@inserted_records,
					@updated_records,
					0,
					0,
					0,
					NULL,
					GETDATE()
				);

				EXEC sp_xml_removedocument @iDoc;

			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			--If the transaction is uncommittable, roll it back.
			IF		XACT_STATE() = -1
				OR	XACT_STATE() = 1
			BEGIN
				ROLLBACK TRANSACTION
			END

			--Log audit information about the failure to the database.
			INSERT INTO dbo.EnterpriseServiceBusMessageAudit
			(
				XML_Message,
				Message_Type,
				Rows_Inserted,
				Rows_Updated,
				Rows_Selected,
				Rows_Deleted,
				Error_Occurred_Ind,
				Error_Msg,
				Audit_DtTm
			)
			VALUES
			(
				@message_body,
				@message_type,
				0,
				0,
				0,
				0,
				1,
				ERROR_MESSAGE(),
				GETDATE()
			);
		END CATCH
	END
END



