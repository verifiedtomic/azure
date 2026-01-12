// Sender must have "Monitoring Metrics Publisher" role on the DCR!

targetScope = 'resourceGroup'

var logName string = ''
var dcrRegion string = ''
@description('Max length is 30 characters.')
var dcrName string = ''
var dcrDescription string = ''
var customTableName string = ''
@description('Max length is 32 characters.')
var dcrStreamName string = 'Custom-${customTableName}'

resource log 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing =  {
  name: logName
}

resource dcr 'Microsoft.Insights/dataCollectionRules@2023-03-11' = {
  kind: 'Direct'
  location: dcrRegion
  name: dcrName
  properties: {
    dataFlows: [
      {
        streams: [dcrStreamName]
        destinations: ['la-${substring(guid(log.id),0,9)}']
        transformKql: 'source | project TimeGenerated = TimeStamp, Computer, Level, Message'
        outputStream: dcrStreamName
      }
    ]
    description: dcrDescription
    destinations: {
      logAnalytics: [
          {
            workspaceResourceId: log.id
            name: 'la-${substring(guid(log.id),0,9)}'
          }
      ]
    }
    streamDeclarations: {
    '${dcrStreamName}': {
        columns: [
          {
            name: 'TimeStamp'
            type: 'datetime'
          }
          {
            name: 'Computer'
            type: 'string'
          }
          {
            name: 'Level'
            type: 'string'
          }
          {
            name: 'Message'
            type: 'string'
          }
        ]
      }
    }
  }
}

output ingestionUri string = dcr.properties.endpoints.logsIngestion
output immutableId string = dcr.properties.immutableId
