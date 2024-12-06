// main.bicep

@description('The location for the resources')
param location string = resourceGroup().location

@description('Name of the Azure Container Registry')
param containerRegistryName string

@description('Name of the container image')
param containerRegistryImageName string

@description('Version of the container image')
param containerRegistryImageVersion string

@description('Name of the App Service Plan')
param appServicePlanName string

@description('Name of the Web App')
param webAppName string

@description('Name of the Key Vault')
param keyVaultName string

@description('Principal ID for role assignments')
param principalId string = '7200f83e-ec45-4915-8c52-fb94147cfe5a' // Replace with your Service Principal ID

module keyVaultModule './modules/keyVault.bicep' = {
  name: 'keyVaultModule'
  params: {
    name: keyVaultName
    location: location
    enableVaultForDeployment: true
    roleAssignments: [
      {
        principalId: principalId
        roleDefinitionIdOrName: 'Key Vault Secrets User'
      }
    ]
  }
}

module acrModule './modules/acr.bicep' = {
  name: 'acrModule'
  params: {
    name: containerRegistryName
    location: location
    acrAdminUserEnabled: true
    adminCredentialsKeyVaultResourceId: keyVaultModule.outputs.keyVaultId
    adminCredentialsKeyVaultSecretUserName: 'ElsACRUsername'
    adminCredentialsKeyVaultSecretUserPassword1: 'ElsACRPassword1'
    adminCredentialsKeyVaultSecretUserPassword2: 'ElsACRPassword2'
  }
}

module appServicePlanModule './modules/appServicePlan.bicep' = {
  name: 'appServicePlanModule'
  params: {
    name: appServicePlanName
    location: location
    sku: {
      capacity: 1
      family: 'B'
      name: 'B1'
      size: 'B1'
      tier: 'Basic'
    }
    kind: 'Linux'
    reserved: true
  }
}

module webAppModule './modules/webApp.bicep' = {
  name: 'webAppModule'
  params: {
    name: webAppName
    location: location
    kind: 'app'
    serverFarmResourceId: appServicePlanModule.outputs.resourceId
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryName}.azurecr.io/${containerRegistryImageName}:${containerRegistryImageVersion}'
      appCommandLine: ''
    }
    appSettingsKeyValuePairs: {}
    dockerRegistryServerUrl: 'https://${containerRegistryName}.azurecr.io'
    dockerRegistryServerUserName: acrModule.outputs.acrAdminUsernameSecretId
    dockerRegistryServerPassword: acrModule.outputs.acrAdminPassword1SecretId
  }
}

output keyVaultName string = keyVaultModule.outputs.keyVaultName
output keyVaultId string = keyVaultModule.outputs.keyVaultId
output acrName string = acrModule.outputs.acrName
output acrId string = acrModule.outputs.acrId
output webAppId string = webAppModule.outputs.webAppId
