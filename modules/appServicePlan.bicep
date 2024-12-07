@description('Name of the App Service Plan')
param name string

@description('Location for the App Service Plan')
param location string

@description('SKU details for the App Service Plan')
param sku object

resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: name
  location: location
  sku: {
    name: sku.name
    tier: sku.tier
    capacity: sku.capacity
    size: sku.size
    family: sku.family
  }
  kind: sku.kind
  properties: {
    reserved: sku.reserved
  }
}

output appServicePlanId string = appServicePlan.id
