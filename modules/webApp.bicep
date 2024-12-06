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

resource app 'Microsoft.Web/sites@2021-02-01' = {
  name: name
  location: location
  kind: kind
  properties: {
    serverFarmId: serverFarmResourceId
    siteConfig: {
      linuxFxVersion: siteConfig.linuxFxVersion
      appCommandLine: siteConfig.appCommandLine
    }
    appSettings: [
      for (key, value) in appSettingsKeyValuePairs: {
        name: key
        value: value
      }
      {
        name: 'DOCKER_REGISTRY_SERVER_URL'
        value: dockerRegistryServerUrl
      }
      {
        name: 'DOCKER_REGISTRY_SERVER_USERNAME'
        value: dockerRegistryServerUserName
      }
      {
        name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
        value: dockerRegistryServerPassword
      }
    ]
  }
}

output webAppName string = app.name
