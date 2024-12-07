@description('Name of the Azure Container Registry')
param name string

@description('Location for the Azure Container Registry')
param location string

@description('Enable admin user for the Azure Container Registry')
param acrAdminUserEnabled bool

resource acr 'Microsoft.ContainerRegistry/registries@2022-12-01'= {
  name: name
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: acrAdminUserEnabled
  }
}

output acrLoginServer string = acr.properties.loginServer
output acrUsername string = acr.listCredentials().username
output acrPassword string = acr.listCredentials().passwords[0].value
