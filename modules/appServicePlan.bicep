param name string
param location string
param sku object

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: name
  location: location
  sku: {
    name: sku.name
    tier: sku.tier
    capacity: sku.capacity
  }
  kind: sku.kind
  properties: {
    reserved: sku.reserved
  }
}

output appServicePlanId string = appServicePlan.id
