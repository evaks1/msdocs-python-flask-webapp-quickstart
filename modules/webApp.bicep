@description('Name of the Web App')
param name string

@description('Location for the Web App')
param location string

@description('Resource ID of the App Service Plan')
param serverFarmResourceId string

@description('Container Registry URL')
param containerRegistryUrl string

@description('Container Image Name')
param containerImageName string

@description('Container Image Version')
param containerImageVersion string

@description('Docker Registry Username')
param dockerRegistryUsername string

@description('Docker Registry Password')
param dockerRegistryPassword string

resource webApp 'Microsoft.Web/sites@2021-03-01' = {
  name: name
  location: location
  kind: 'app'
  properties: {
    serverFarmId: serverFarmResourceId
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryUrl}/${containerImageName}:${containerImageVersion}'
      appCommandLine: ''
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: containerRegistryUrl
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: dockerRegistryUsername
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: dockerRegistryPassword
        }
      ]
    }
  }
}

output webAppDefaultHostName string = webApp.properties.defaultHostName
