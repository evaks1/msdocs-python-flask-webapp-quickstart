param name string
param location string
param acrAdminUserEnabled bool

@secure()
param adminCredentialsKeyVaultSecretUserName string
@secure()
param adminCredentialsKeyVaultSecretUserPassword string

// Key Vault Resource ID
param adminCredentialsKeyVaultResourceId string

resource registry 'Microsoft.ContainerRegistry/registries@2021-08-01-preview' = {
  name: name
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: acrAdminUserEnabled
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: last(split(adminCredentialsKeyVaultResourceId, '/'))
}

resource secretAdminUserName 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  name: adminCredentialsKeyVaultSecretUserName
  parent: keyVault
  properties: {
    value: registry.listCredentials().username
  }
}

resource secretAdminPassword 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  name: adminCredentialsKeyVaultSecretUserPassword
  parent: keyVault
  properties: {
    value: registry.listCredentials().passwords[0].value
  }
}

output registryName string = registry.name
output registryLoginServer string = registry.loginServer
