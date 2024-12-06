// webApp.bicep
@description('Name of the Web App')
param name string

@description('Location for the Web App')
param location string

@description('Kind of the Web App')
param kind string

@description('Resource ID of the App Service Plan')
param serverFarmResourceId string

@description('Site configuration for the Web App')
param siteConfig object

@description('Additional app settings key-value pairs')
param appSettingsKeyValuePairs object

@description('Docker registry server URL')
param dockerRegistryServerUrl string

@description('Docker registry server username (retrieved from Key Vault)')
param dockerRegistryServerUserName string

@description('Docker registry server password (retrieved from Key Vault)')
param dockerRegistryServerPassword string

var dockerAppSettings = {
  DOCKER_REGISTRY_SERVER_URL: dockerRegistryServerUrl
  DOCKER_REGISTRY_SERVER_USERNAME: dockerRegistryServerUserName
  DOCKER_REGISTRY_SERVER_PASSWORD: dockerRegistryServerPassword
}

resource webApp 'Microsoft.Web/sites@2021-02-01' = {
  name: name
  location: location
  kind: kind
  properties: {
    serverFarmId: serverFarmResourceId
    siteConfig: siteConfig
    appSettings: union(appSettingsKeyValuePairs, dockerAppSettings)
  }
}

output webAppId string = webApp.id

