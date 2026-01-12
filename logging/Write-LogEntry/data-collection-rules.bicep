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

resource dcrWindows 'Microsoft.Insights/dataCollectionRules@2023-03-11' = {
  kind: 'Windows'
  location: dcrRegion
  name: dcrName
  properties: {
      dataFlows: [
        {
          streams: [
              dcrStreamName
          ]
          destinations: [
              'la-${substring(guid(log.id),0,9)}'
          ]
          transformKql: '''
            source
            | parse RawData with timestamp:datetime"|"Level:string"|"Message:string
            | extend TimeGenerated = timestamp
            | project TimeGenerated, Computer, Level, Message
          '''
          outputStream: dcrStreamName
        }
      ]
      dataSources: {
        logFiles: [
          {
            streams: [
              dcrStreamName
            ]
            filePatterns: [
              '<path-to-log-file>\\*.log'
            ]
            format: 'text'
            name: dcrStreamName
            settings: {
              text: {
                recordStartTimestampFormat: 'ISO 8601'
              }
            }
          }
        ]
      }
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
            name: 'TimeGenerated'
            type: 'datetime'
          }
          {
            name: 'Computer'
            type: 'string'
          }
          {
            name: 'RawData'
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

output ingestionUriWindows string = dcrWindows.properties.endpoints.logsIngestion
output immutableIdWindows string = dcrWindows.properties.immutableId



resource dcrLinux 'Microsoft.Insights/dataCollectionRules@2023-03-11' = {
  kind: 'Linux'
  location: dcrRegion
  name: dcrName
  properties: {
      dataFlows: [
        {
          streams: [
              dcrStreamName
          ]
          destinations: [
              'la-${substring(guid(log.id),0,9)}'
          ]
          transformKql: '''
            source
            | parse RawData with timestamp:datetime"|"Level:string"|"Message:string
            | extend TimeGenerated = timestamp
            | project TimeGenerated, Computer, Level, Message
          '''
          outputStream: dcrStreamName
        }
      ]
      dataSources: {
        logFiles: [
          {
            streams: [
              dcrStreamName
            ]
            filePatterns: [
              '<path-to-log-file>/*.log'
            ]
            format: 'text'
            name: dcrStreamName
            settings: {
              text: {
                recordStartTimestampFormat: 'ISO 8601'
              }
            }
          }
        ]
      }
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
            name: 'TimeGenerated'
            type: 'datetime'
          }
          {
            name: 'Computer'
            type: 'string'
          }
          {
            name: 'RawData'
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

output ingestionUriLinux string = dcrLinux.properties.endpoints.logsIngestion
output immutableIdLinux string = dcrLinux.properties.immutableId
