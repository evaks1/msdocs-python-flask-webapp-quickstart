param location string
param sqlServerName string
param sqlAdminUserName string
@secure()
param sqlAdminPassword string
param databaseName string

param adminCredentialsKeyVaultResourceId string
param adminCredentialsKeyVaultSecretDbUserName string
param adminCredentialsKeyVaultSecretDbPassword string

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdminUserName
    administratorLoginPassword: sqlAdminPassword
  }
  tags: {}
}

resource sqlDb 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  name: '${sqlServerName}/${databaseName}'
  location: location
  sku: {
    name: 'S0'
    tier: 'Standard'
  }
}

resource adminCredentialsKeyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: last(split(adminCredentialsKeyVaultResourceId, '/'))
}

resource secretDbUserName 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: adminCredentialsKeyVaultSecretDbUserName
  parent: adminCredentialsKeyVault
  properties: {
    value: sqlAdminUserName
  }
}

resource secretDbPassword 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: adminCredentialsKeyVaultSecretDbPassword
  parent: adminCredentialsKeyVault
  properties: {
    value: sqlAdminPassword
  }
}

output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName
