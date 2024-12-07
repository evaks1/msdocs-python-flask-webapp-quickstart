@description('Parameters for deploying infrastructure')
param containerRegistryName string
param appServicePlanName string
param webAppName string
param location string
param containerRegistryImageName string
param containerRegistryImageVersion string

module acrModule './modules/acr.bicep' = {
  name: 'containerRegistryDeployment'
  params: {
    name: containerRegistryName
    location: location
    acrAdminUserEnabled: true
  }
}

module appServicePlanModule './modules/appServicePlan.bicep' = {
  name: 'appServicePlanDeployment'
  params: {
    name: appServicePlanName
    location: location
    sku: {
      capacity: 1
      family: 'B'
      name: 'B1'
      size: 'B1'
      tier: 'Basic'
      kind: 'Linux'
      reserved: true
    }
  }
}

module webAppModule './modules/webApp.bicep' = {
  name: 'webAppDeployment'
  params: {
    name: webAppName
    location: location
    serverFarmResourceId: appServicePlanModule.outputs.appServicePlanId
    containerRegistryUrl: acrModule.outputs.acrLoginServer
    containerImageName: containerRegistryImageName
    containerImageVersion: containerRegistryImageVersion
    dockerRegistryUsername: acrModule.outputs.acrUsername
    dockerRegistryPassword: acrModule.outputs.acrPassword
  }
}

output webAppUrl string = 'https://${webAppModule.outputs.webAppDefaultHostName}'
