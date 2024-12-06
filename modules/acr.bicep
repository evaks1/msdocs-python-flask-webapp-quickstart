param name string
param location string
param acrAdminUserEnabled bool

// Key Vault params
param adminCredentialsKeyVaultResourceId string
param adminCredentialsKeyVaultSecretUserName string
param adminCredentialsKeyVaultSecretUserPassword string

resource registry 'Microsoft.ContainerRegistry/registries@2021-08-01-preview' = {
  name: name
  location: location
  sku: {
    name: 'Basic'
  }
  adminUserEnabled: acrAdminUserEnabled
}

resource adminCredentialsKeyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: last(split(adminCredentialsKeyVaultResourceId, '/'))
}

resource secretAdminUserName 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: adminCredentialsKeyVaultSecretUserName
  parent: adminCredentialsKeyVault
  properties: {
    value: registry.listCredentials().username
  }
}

resource secretAdminPassword 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: adminCredentialsKeyVaultSecretUserPassword
  parent: adminCredentialsKeyVault
  properties: {
    value: registry.listCredentials().passwords[0].value
  }
}

output registryName string = registry.name
output registryLoginServer string = registry.loginServer
