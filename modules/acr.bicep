// acr.bicep
@description('Name of the Azure Container Registry')
param name string

@description('Location for the ACR')
param location string

@description('Enable admin user for ACR')
param acrAdminUserEnabled bool = false

@description('Resource ID of the Key Vault to store credentials')
param adminCredentialsKeyVaultResourceId string

@description('Name for the Key Vault secret storing ACR username')
param adminCredentialsKeyVaultSecretUserName string

@description('Name for the Key Vault secret storing ACR password1')
param adminCredentialsKeyVaultSecretUserPassword1 string

@description('Name for the Key Vault secret storing ACR password2')
param adminCredentialsKeyVaultSecretUserPassword2 string

resource acr 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
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
  scope: resourceGroup()
  name: last(split(adminCredentialsKeyVaultResourceId, '/'))
}

resource secretUserName 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: '${keyVault.name}/${adminCredentialsKeyVaultSecretUserName}'
  properties: {
    value: acr.listCredentials().username
  }
}

resource secretUserPassword1 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: '${keyVault.name}/${adminCredentialsKeyVaultSecretUserPassword1}'
  properties: {
    value: acr.listCredentials().passwords[0].value
  }
}

resource secretUserPassword2 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: '${keyVault.name}/${adminCredentialsKeyVaultSecretUserPassword2}'
  properties: {
    value: acr.listCredentials().passwords[1].value
  }
}

output acrName string = acr.name
output acrId string = acr.id
output acrAdminUsernameSecretId string = secretUserName.id
output acrAdminPassword1SecretId string = secretUserPassword1.id
output acrAdminPassword2SecretId string = secretUserPassword2.id
