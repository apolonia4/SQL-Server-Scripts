select 'Grant Execute on ' + '[' + name + ']' + ' ' + 'TO' + ' ' + '[VHAMASTER\VACO-SDI-CCB-APP]'
from sysobjects where xtype in ('P') and name not like 'sp%'

