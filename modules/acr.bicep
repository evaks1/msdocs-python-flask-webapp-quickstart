// containerRegistry.bicep

@description('Name of the Azure Container Registry')
param name string

@description('Location for the Azure Container Registry')
param location string

@description('Enable admin user for the Azure Container Registry')
param acrAdminUserEnabled bool

@description('Resource ID of the Key Vault for storing credentials')
param adminCredentialsKeyVaultResourceId string

@description('Secret name for ACR username')
param adminCredentialsKeyVaultSecretUserName string

@description('Secret name for ACR password')
param adminCredentialsKeyVaultSecretUserPassword1 string

@description('Secret name for ACR password 2')
param adminCredentialsKeyVaultSecretUserPassword2 string

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: last(split(adminCredentialsKeyVaultResourceId, '/'))
}

resource acr 'Microsoft.ContainerRegistry/registries@2022-12-01' = {
  name: name
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: acrAdminUserEnabled
  }
}

resource secretUsername 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: '${keyVault.name}/${adminCredentialsKeyVaultSecretUserName}'
  properties: {
    value: acr.listCredentials().username
  }
}

resource secretPassword1 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: '${keyVault.name}/${adminCredentialsKeyVaultSecretUserPassword1}'
  properties: {
    value: acr.listCredentials().passwords[0].value
  }
}

resource secretPassword2 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: '${keyVault.name}/${adminCredentialsKeyVaultSecretUserPassword2}'
  properties: {
    value: acr.listCredentials().passwords[1].value
  }
}

output acrLoginServer string = acr.properties.loginServer
