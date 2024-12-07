// modules/acr.bicep

@description('Name of the Azure Container Registry')
param name string

@description('Location for the Azure Container Registry')
param location string

@description('Enable admin user for the Azure Container Registry')
param acrAdminUserEnabled bool

@description('Resource ID of the Key Vault for storing credentials')
param keyVaultId string

@description('Secret name for ACR username')
@secure()
param adminCredentialsKeyVaultSecretUserName string

@description('Secret name for ACR password 1')
@secure()
param adminCredentialsKeyVaultSecretUserPassword1 string

@description('Secret name for ACR password 2')
@secure()
param adminCredentialsKeyVaultSecretUserPassword2 string

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = if (!empty(keyVaultId)) {
  name: last(split((!empty(keyVaultId) ? keyVaultId : 'dummyVault'), '/'))!
}

// Deploy Azure Container Registry
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

// Store ACR username in Key Vault
resource secretUsername 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: adminCredentialsKeyVaultSecretUserName
  parent: keyVault
  properties: {
    value: acr.listCredentials().username
  }
}

// Store ACR password1 in Key Vault
resource secretPassword1 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: adminCredentialsKeyVaultSecretUserPassword1
  parent: keyVault
  properties: {
    value: acr.listCredentials().passwords[0].value
  }
}

// Store ACR password2 in Key Vault
resource secretPassword2 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: adminCredentialsKeyVaultSecretUserPassword2
  parent: keyVault
  properties: {
    value: acr.listCredentials().passwords[1].value
  }
}

output acrLoginServer string = acr.properties.loginServer
