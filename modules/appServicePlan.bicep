@description('Name of the App Service Plan')
param appServicePlanName string

@description('Location for the App Service Plan')
param location string


resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    capacity: 1
    family: 'B'
    name: 'B1'
    size: 'B1'
    tier: 'Basic'
  }
  kind: 'Linux'
  properties: {
    reserved: true
  }
}

output appServicePlanId string = appServicePlan.id
