param location string
param sqlServerName string
param sqlAdminUserName string
@secure()
param sqlAdminPassword string
param databaseName string

@secure()
param adminCredentialsKeyVaultSecretDbUserName string
@secure()
param adminCredentialsKeyVaultSecretDbPassword string

// Key Vault Resource ID
param adminCredentialsKeyVaultResourceId string

resource sqlServer 'Microsoft.Sql/servers@2021-02-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdminUserName
    administratorLoginPassword: sqlAdminPassword
  }
  tags: {}
}

resource sqlDb 'Microsoft.Sql/servers/databases@2021-02-01-preview' = {
  name: databaseName
  parent: sqlServer
  location: location
  sku: {
    name: 'S0'
    tier: 'Standard'
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: last(split(adminCredentialsKeyVaultResourceId, '/'))
}

resource secretDbUserName 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  name: adminCredentialsKeyVaultSecretDbUserName
  parent: keyVault
  properties: {
    value: sqlAdminUserName
  }
}

resource secretDbPassword 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  name: adminCredentialsKeyVaultSecretDbPassword
  parent: keyVault
  properties: {
    value: sqlAdminPassword
  }
}

output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName
