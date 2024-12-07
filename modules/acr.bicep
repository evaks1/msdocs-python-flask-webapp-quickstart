param containerRegistryName string
param location string = resourceGroup().location
param keyVaultResourceId string
#disable-next-line secure-secrets-in-params
param keyVaultSecretNameAdminUsername string
#disable-next-line secure-secrets-in-params
param keyVaultSecretNameAdminPassword string

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name:  containerRegistryName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

output id string = containerRegistry.id
output loginServer string = containerRegistry.properties.loginServer

resource adminCredentialsKeyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = if (!empty(keyVaultResourceId)) {
  name: last(split((!empty(keyVaultResourceId) ? keyVaultResourceId : 'dummyVault'), '/'))!
}

// create a secret to store the container registry admin username
resource secretAdminUserName 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = if (!empty(keyVaultSecretNameAdminUsername)) {
  name: !empty(keyVaultSecretNameAdminUsername) ? keyVaultSecretNameAdminUsername : 'dummySecret'
  parent: adminCredentialsKeyVault
  properties: {
    value: containerRegistry.listCredentials().username
}
}
// create a secret to store the container registry admin password 0
resource secretAdminUserPassword0 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = if (!empty(keyVaultSecretNameAdminPassword)) {
  name: !empty(keyVaultSecretNameAdminPassword) ? keyVaultSecretNameAdminPassword : 'dummySecret'
  parent: adminCredentialsKeyVault
  properties: {
    value: containerRegistry.listCredentials().passwords[0].value
}
}
