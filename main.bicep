// ========================================
// General Parameters
// ========================================
@description('Location for all resources')
param location string = resourceGroup().location

// ========================================
// Step 1: Deploy Key Vault
// ========================================
@description('The name of the Key Vault')
param keyVaultName string

@description('Enable RBAC authorization for Key Vault')
param enableRbacAuthorization bool = true

@description('Enable Key Vault\'s soft delete feature')
param enableSoftDelete bool = true

@description('Role assignments for Key Vault')
param keyVaultRoleAssignments array = []

module keyVault 'modules/keyVault.bicep' = {
  name: 'keyVaultDeployment'
  params: {
    name: keyVaultName
    location: location
    enableRbacAuthorization: enableRbacAuthorization
    enableSoftDelete: enableSoftDelete
    roleAssignments: keyVaultRoleAssignments
  }
}

output keyVaultId string = keyVault.outputs.keyVaultId

// ========================================
// Step 2: Deploy Azure Container Registry
// ========================================
@description('The name of the Azure Container Registry')
param acrName string

@description('Name of the Key Vault secret for the ACR admin username')
param acrAdminUsernameSecretName string = 'ACRAdminUsername'

@description('Name of the Key Vault secret for the ACR admin password')
param acrAdminPasswordSecretName string = 'ACRAdminPassword'

module acr 'modules/acr.bicep' = {
  name: 'acrDeployment'
  params: {
    name: acrName
    location: location
    acrAdminUserEnabled: true
    keyVaultResourceId: keyVault.outputs.keyVaultId
    adminCredentialsKeyVaultSecretUserName: acrAdminUsernameSecretName
    adminCredentialsKeyVaultSecretUserPassword: acrAdminPasswordSecretName
  }
  dependsOn: [
    keyVault
  ]
}

output acrLoginServer string = acr.outputs.registryLoginServer

// ========================================
// Step 3: Deploy App Service Plan
// ========================================
@description('The name of the App Service Plan')
param appServicePlanName string

@description('The SKU for the App Service Plan (e.g., B1, F1)')
@allowed([
  'B1'
  'F1'
])
param appServicePlanSku string = 'B1'

module appServicePlan 'modules/appServicePlan.bicep' = {
  name: 'appServicePlanDeployment'
  params: {
    name: appServicePlanName
    location: location
    sku: appServicePlanSku
  }
}

output appServicePlanId string = appServicePlan.outputs.appServicePlanId

// ========================================
// Step 4: Deploy SQL Database
// ========================================
@description('The name of the SQL Server')
param sqlServerName string

@description('The admin username for the SQL Server')
param sqlAdminUserName string

@description('The admin password for the SQL Server')
@secure()
param sqlAdminPassword string

@description('The name of the SQL Database')
param sqlDatabaseName string

module sqlDatabase 'modules/sqlDatabase.bicep' = {
  name: 'sqlDatabaseDeployment'
  params: {
    serverName: sqlServerName
    adminUserName: sqlAdminUserName
    adminPassword: sqlAdminPassword
    databaseName: sqlDatabaseName
    location: location
  }
}

output sqlConnectionString string = sqlDatabase.outputs.connectionString

// ========================================
// Step 5: Deploy Web App
// ========================================
@description('The name of the Web App')
param webAppName string

@description('The Docker image name for the Web App')
param dockerImageName string

@description('The Docker image version for the Web App')
param dockerImageVersion string

@description('App settings for the Web App')
param webAppSettings object = {}

@secure()
@description('Admin username for the Web App')
param adminUsername string = '' // To be overridden by workflow

@secure()
@description('Admin password for the Web App')
param adminPassword string = '' // To be overridden by workflow

// Reference to Key Vault to retrieve secrets
resource keyVaultReference 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

module webApp 'modules/webApp.bicep' = {
  name: 'webAppDeployment'
  params: {
    name: webAppName
    location: location
    appServicePlanId: appServicePlan.outputs.appServicePlanId
    dockerRegistryServerUrl: 'https://${acr.outputs.registryLoginServer}'
    dockerRegistryServerUserName: keyVaultReference.getSecret(acrAdminUsernameSecretName)
    dockerRegistryServerPassword: keyVaultReference.getSecret(acrAdminPasswordSecretName)
    dockerImageName: dockerImageName
    dockerImageVersion: dockerImageVersion
    appSettingsKeyValuePairs: webAppSettings
  }
  dependsOn: [
    acr
    appServicePlan
    sqlDatabase
  ]
}

output webAppUrl string = webApp.outputs.webAppUrl
