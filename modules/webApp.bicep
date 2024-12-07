// webApp.bicep

@description('Name of the Azure Web App')
param name string

@description('Location for the Azure Web App')
param location string

@description('Resource ID of the App Service Plan')
param serverFarmResourceId string

@description('Docker Registry Server URL')
param dockerRegistryServerUrl string

@description('Docker Registry Server Username')
@secure()
param dockerRegistryServerUserName string

@description('Docker Registry Server Password')
@secure()
param dockerRegistryServerPassword string

@description('Name of the container image')
param containerRegistryImageName string

@description('Version of the container image')
param containerRegistryImageVersion string


resource webApp 'Microsoft.Web/sites@2021-03-01' = {
  name: name
  location: location
  kind: 'app'
  properties: {
    serverFarmId: serverFarmResourceId
    siteConfig: {
      linuxFxVersion: 'DOCKER|${replace(dockerRegistryServerUrl, 'https://', '')}/${containerRegistryImageName}:${containerRegistryImageVersion}'
      appCommandLine: ''
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
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
}

output webAppDefaultHostName string = webApp.properties.defaultHostName
