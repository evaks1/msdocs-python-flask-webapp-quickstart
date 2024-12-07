// main.bicep

param location string = 'westeurope'
param containerRegistryName string
param appServicePlanName string
param webAppName string
param containerRegistryImageName string
param containerRegistryImageVersion string


// Deploy Key Vault
module keyVaultModule 'modules/keyVault.bicep' = {
  name: 'keyVaultDeployment'
  params: {
    name: 'ELSKeyvault20'
    location: location
    roleAssignments: [
      {
        principalId: '7200f83e-ec45-4915-8c52-fb94147cfe5a'
        roleDefinitionIdOrName: 'Key Vault Secrets User'
        principalType: 'ServicePrincipal'
      }
    ]
  }
}

// Deploy Container Registry
module containerRegistryModule 'modules/acr.bicep' = {
  name: 'containerRegistryDeployment'
  params: {
    name: containerRegistryName
    location: location
    acrAdminUserEnabled: true
    keyVaultId: keyVaultModule.outputs.keyVaultId
    adminCredentialsKeyVaultSecretUserName: 'ACR-Username'
    adminCredentialsKeyVaultSecretUserPassword1: 'ACR-Password1'
    adminCredentialsKeyVaultSecretUserPassword2: 'ACR-Password2'
  }
}

// Deploy App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
  properties: {}
}

// Deploy Web App
module webAppModule 'modules/webApp.bicep' = {
  name: 'webAppDeployment'
  params: {
    name: webAppName
    location: location
    serverFarmResourceId: appServicePlan.id
    dockerRegistryServerUrl: containerRegistryModule.outputs.acrLoginServer
    dockerRegistryServerUserName: 'ACR-Username' // Secret will be fetched from Key Vault in GitHub Actions
    dockerRegistryServerPassword: 'ACR-Password1' // Secret will be fetched from Key Vault in GitHub Actions
    containerRegistryImageName: containerRegistryImageName
    containerRegistryImageVersion: containerRegistryImageVersion
  }
}

output webAppUrl string = webAppModule.outputs.webAppDefaultHostName
