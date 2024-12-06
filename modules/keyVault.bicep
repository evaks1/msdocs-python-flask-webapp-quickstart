// modules/key-vault.bicep

@description('Name of the Key Vault')
param name string

@description('Location for the Key Vault')
param location string

@description('Enable Key Vault for deployment')
param enableVaultForDeployment bool = true

@description('Array of role assignments')
param roleAssignments array

// Function to resolve role definition IDs by name or GUID
function getRoleDefinitionId(roleDefinitionIdOrName string) string {
  if (length(roleDefinitionIdOrName) == 36 && contains(roleDefinitionIdOrName, '-')) {
    return roleDefinitionIdOrName
  } else {
    // Predefined role names can be mapped to their IDs here
    switch (roleDefinitionIdOrName) {
      'Key Vault Secrets User' => '4633458b-17de-408a-b874-0445c86b69e6'
      default => throw 'Unsupported role definition name.'
    }
  }
}

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
