param name string
param location string
param kind string
param serverFarmResourceId string
param siteConfig object
param appSettingsKeyValuePairs object

@secure()
param dockerRegistryServerUrl string
@secure()
param dockerRegistryServerUserName string
@secure()
param dockerRegistryServerPassword string

var dockerAppSettings = {
  DOCKER_REGISTRY_SERVER_URL: dockerRegistryServerUrl
  DOCKER_REGISTRY_SERVER_USERNAME: dockerRegistryServerUserName
  DOCKER_REGISTRY_SERVER_PASSWORD: dockerRegistryServerPassword
}

resource app 'Microsoft.Web/sites@2022-03-01' = {
  name: name
  location: location
  kind: kind
  properties: {
    serverFarmId: serverFarmResourceId
    siteConfig: siteConfig
  }
}

module app_appsettings 'config--appsettings/main.bicep' = if (!empty(appSettingsKeyValuePairs)) {
  name: '${uniqueString(deployment().name, location)}-Site-Config-AppSettings'
  params: {
    appName: app.name
    kind: kind
    storageAccountResourceId: ''
    appInsightResourceId: ''
    setAzureWebJobsDashboard: false
    appSettingsKeyValuePairs: union(appSettingsKeyValuePairs, dockerAppSettings)
    enableDefaultTelemetry: false
  }
}

output webAppName string = app.name
