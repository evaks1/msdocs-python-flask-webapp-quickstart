// modules/keyVault.bicep

@description('Name of the Azure Key Vault')
param name string

@description('Location for the Azure Key Vault')
param location string

@description('Role assignments for the Key Vault')
param roleAssignments array
param servicePrincipalObjectId string = '1736344c-8095-440c-876e-bda11cdb224f' // Replace with your Service Principal Object ID

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
        objectId: servicePrincipalObjectId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
          keys: [
            'get'
            'list'
          ]
          certificates: [
            'get'
            'list'
          ]
          storage: [
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
