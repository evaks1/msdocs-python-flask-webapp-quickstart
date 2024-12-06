param location string
param keyVaultName string
param acrName string
param appServicePlanName string
param webAppName string
param containerRegistryImageName string
param containerRegistryImageVersion string

param sqlServerName string
param sqlAdminUserName string
@secure()
param sqlAdminPassword string
param databaseName string

// Key Vault secrets names
param acrUserNameSecretName string = 'acr-username'
param acrPasswordSecretName string = 'acr-password'
param dbUserNameSecretName string = 'db-username'
param dbPasswordSecretName string = 'db-password'

// The principalId for the SP that deploys resources (from instructions)
param principalId string = '7200f83e-ec45-4915-8c52-fb94147cfe5a'
param roleDefinitionIdOrName string = 'Key Vault Secrets User'

resource keyVaultDeploy 'modules/keyVault.bicep' = {
  name: 'kv-deploy'
  params: {
    name: keyVaultName
    location: location
    principalId: principalId
    roleDefinitionIdOrName: roleDefinitionIdOrName
  }
}

resource acrDeploy 'modules/acr.bicep' = {
  name: 'acr-deploy'
  dependsOn: [
    keyVaultDeploy
  ]
  params: {
    name: acrName
    location: location
    acrAdminUserEnabled: true
    adminCredentialsKeyVaultResourceId: keyVaultDeploy.outputs.keyVaultId
    adminCredentialsKeyVaultSecretUserName: acrUserNameSecretName
    adminCredentialsKeyVaultSecretUserPassword: acrPasswordSecretName
  }
}

resource sqlDeploy 'modules/sqlDatabase.bicep' = {
  name: 'sqldb-deploy'
  dependsOn: [
    keyVaultDeploy
  ]
  params: {
    location: location
    sqlServerName: sqlServerName
    sqlAdminUserName: sqlAdminUserName
    sqlAdminPassword: sqlAdminPassword
    databaseName: databaseName
    adminCredentialsKeyVaultResourceId: keyVaultDeploy.outputs.keyVaultId
    adminCredentialsKeyVaultSecretDbUserName: dbUserNameSecretName
    adminCredentialsKeyVaultSecretDbPassword: dbPasswordSecretName
  }
}

resource appServicePlan 'modules/appServicePlan.bicep' = {
  name: 'asp-deploy'
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

resource keyvault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyVaultDeploy.outputs.keyVaultName
}

var containerRegistryUsername = keyvault.getSecret(acrUserNameSecretName)
var containerRegistryPassword = keyvault.getSecret(acrPasswordSecretName)

var dbUsername = keyvault.getSecret(dbUserNameSecretName)
var dbPassword = keyvault.getSecret(dbPasswordSecretName)

// Example: add DB connection string as well
var dbConnectionString = 'Server=tcp:${sqlDeploy.outputs.sqlServerFqdn},1433;Database=${databaseName};User ID=${dbUsername};Password=${dbPassword};'

resource webApp 'modules/webApp.bicep' = {
  name: 'webApp-deploy'
  dependsOn: [
    acrDeploy
    appServicePlan
    sqlDeploy
  ]
  params: {
    name: webAppName
    location: location
    kind: 'app'
    serverFarmResourceId: appServicePlan.outputs.appServicePlanId
    siteConfig: {
      linuxFxVersion: 'DOCKER|${acrDeploy.outputs.registryName}.azurecr.io/${containerRegistryImageName}:${containerRegistryImageVersion}'
      appCommandLine: ''
    }
    appSettingsKeyValuePairs: {
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: false
      DB_CONNECTION_STRING: dbConnectionString
    }
    dockerRegistryServerUrl: 'https://${acrDeploy.outputs.registryLoginServer}'
    dockerRegistryServerUserName: containerRegistryUsername
    dockerRegistryServerPassword: containerRegistryPassword
  }
}
