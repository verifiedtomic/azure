targetScope = 'resourceGroup'

var logName string = ''
var tableName string = ''
var tableDescription string = ''


resource log 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  name: logName
}

resource customTable 'Microsoft.OperationalInsights/workspaces/tables@2025-02-01' = {
  parent: log
  name: '${tableName}_CL'
  properties: {
    plan: 'Analytics'
    retentionInDays: -1
    schema: {
      columns: [
        {
          name: 'TimeGenerated'
          type: 'datetime'
          description: 'The time at which the data was ingested.'
        }
        {
          name: 'Computer'
          type: 'string'
          description: 'Machine name'
        }
        {
          name: 'Level'
          type: 'string'
          description: 'Message Level'
        }
        {
          name: 'Message'
          type: 'string'
          description: 'Log Message'
        }
      ]
      description: tableDescription
      name: '${tableName}_CL'
    }
    totalRetentionInDays: -1
  }
}
