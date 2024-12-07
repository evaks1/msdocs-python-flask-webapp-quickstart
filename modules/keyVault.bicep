// key-vault.bicep

@description('Name of the Azure Key Vault')
param name string

@description('Location for the Azure Key Vault')
param location string

@description('Enable Key Vault for deployment')
param enableVaultForDeployment bool

@description('Role assignments for the Key Vault')
param roleAssignments array

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: name
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: [
      for assignment in roleAssignments: {
        tenantId: subscription().tenantId
        objectId: assignment.principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
      }
    ]
  }
}

output keyVaultId string = keyVault.id
output keyVaultName string = keyVault.name
