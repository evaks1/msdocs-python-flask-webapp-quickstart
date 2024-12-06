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
param acrUserNameSecretName string = 'ElsACRUsername'
param acrPasswordSecretName string = 'ElsACRPassword'
param dbUserNameSecretName string = 'ElsDBUsername'
param dbPasswordSecretName string = 'ElsDBPassword'

// The principalId for the SP that deploys resources (from instructions)
param principalId string = '7200f83e-ec45-4915-8c52-fb94147cfe5a'
param roleDefinitionIdOrName string = 'Key Vault Secrets User'

// Reference modules using the 'module' keyword and correct paths
module keyVaultDeploy './modules/keyVault.bicep' = {
  name: 'kv-deploy'
  params: {
    name: keyVaultName
    location: location
    principalId: principalId
    roleDefinitionIdOrName: roleDefinitionIdOrName
  }
}

module acrDeploy './modules/acr.bicep' = {
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

module sqlDeploy './modules/sqlDatabase.bicep' = {
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

module appServicePlanDeploy './modules/appServicePlan.bicep' = {
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

// Reference the Key Vault resource deployed by the keyVaultDeploy module
resource keyvault 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: keyVaultDeploy.outputs.keyVaultName
}

// Directly pass getSecret results to module parameters marked with @secure()
module webAppDeploy './modules/webApp.bicep' = {
  name: 'webApp-deploy'
  dependsOn: [
    acrDeploy
    appServicePlanDeploy
    sqlDeploy
  ]
  params: {
    name: webAppName
    location: location
    kind: 'app'
    serverFarmResourceId: appServicePlanDeploy.outputs.appServicePlanId
    siteConfig: {
      linuxFxVersion: 'DOCKER|${acrDeploy.outputs.registryName}.azurecr.io/${containerRegistryImageName}:${containerRegistryImageVersion}'
      appCommandLine: ''
    }
    appSettingsKeyValuePairs: {
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: false
      DB_CONNECTION_STRING: 'Server=tcp:${sqlDeploy.outputs.sqlServerFqdn},1433;Database=${databaseName};User ID=${dbUserNameSecretName};Password=${dbPasswordSecretName};'
    }
    dockerRegistryServerUrl: 'https://${acrDeploy.outputs.registryLoginServer}'
    dockerRegistryServerUserName: keyvault.getSecret(acrUserNameSecretName)
    dockerRegistryServerPassword: keyvault.getSecret(acrPasswordSecretName)
  }
}
