// key-vault.bicep
@description('Name of the Key Vault')
param name string

@description('Location for the Key Vault')
param location string

@description('Enable Key Vault for deployment')
param enableVaultForDeployment bool = true

@description('Array of role assignments')
param roleAssignments array

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: name
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    accessPolicies: [] // Managed via role assignments
    enabledForTemplateDeployment: enableVaultForDeployment
    publicNetworkAccess: 'Enabled'
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for assignment in roleAssignments: {
  name: guid(keyVault.id, assignment.principalId, assignment.roleDefinitionIdOrName)
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', getRoleDefinitionId(assignment.roleDefinitionIdOrName))
    principalId: assignment.principalId
    principalType: 'ServicePrincipal'
  }
}]

output keyVaultName string = keyVault.name
output keyVaultId string = keyVault.id

