// appServicePlan.bicep
@description('Name of the App Service Plan')
param name string

@description('Location for the App Service Plan')
param location string

@description('SKU for the App Service Plan')
param sku object

@description('Kind of the App Service Plan')
param kind string

@description('Reserved flag for the App Service Plan')
param reserved bool

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: name
  location: location
  sku: sku
  kind: kind
  properties: {
    reserved: reserved
  }
}

output resourceId string = appServicePlan.id
