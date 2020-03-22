param(
  [String] $resourceGroup,
  [String] $storageAccountName,
  [String] $storageQueueName,
  [String] $appServicePlan,
  [String] $webAppName
)

Write-Host "Parameters:"
Write-Host "==========="
Write-Host "resourceGroupName: $resourceGroup"
Write-Host "storageAccountName: $storageAccountName"
Write-Host "appServicePlan: $appServicePlan"
Write-Host "webAppName: $webAppName"
Write-Host ""

Write-Host "* Install Azure CLI app insights extension."
az extension add --name application-insights

$resourceGroupCheck = az group exists -n $resourceGroup
if ($resourceGroupCheck -eq 'true') {
    Write-Host "* Resource group exists."
} else {
    Write-Host "* Create resource group."
    az group create -l australiaeast -n $resourceGroup
}

$storageAccountCheck = az storage account check-name -n $storageAccountName | ConvertFrom-Json
if ($storageAccountCheck.nameAvailable) {
    Write-Host "* Create storage account."
    az storage account create -g $resourceGroup -n $storageAccountName --sku Standard_LRS
} else {
    Write-Host "* Storage account exists."
}
$storageAccountConnectionStrings = az storage account show-connection-string -g $resourceGroup -n $storageAccountName | ConvertFrom-Json
$storageAccountConnectionString = $storageAccountConnectionStrings[0].connectionString

$storageQueueCheck = az storage queue exists -n $storageQueueName --connection-string $storageAccountConnectionString | ConvertFrom-Json
if ($storageQueueCheck.exists) {
    Write-Host "* Storage queue exists."
} else {
    Write-Host "* Create a storage queue."
    az storage queue create -n $storageQueueName --connection-string $storageAccountConnectionString
}

$planCheck = az appservice plan list --query "[?name=='$appServicePlan']" | ConvertFrom-Json
$planExists = $planCheck.Length -gt 0
if ($planExists) {
    Write-Host "* App service plan exists."
} else {
    Write-Host "* Create app service plan."
    az appservice plan create -g $resourceGroup -n $appServicePlan --sku B1
}

$webAppCheck = az webapp list --query "[?name=='$webAppName']" | ConvertFrom-Json
$webAppExists = $webAppCheck.Length -gt 0
if ($webAppExists) {
    Write-Host "* Web app exists."
} else {
    Write-Host "* Create app insights."
    $appInsights = az monitor app-insights component create -g $resourceGroup -a $webAppName -l australiaeast | ConvertFrom-Json
    $appInsightsKey = $appInsights.instrumentationKey
    
    Write-Host "* Create web app."
    az webapp create -g $resourceGroup -p $appServicePlan -n $webAppName 
    Write-Host "* Enable always-on."
    az webapp config set -g $resourceGroup -n $webAppName --always-on true
    
    Write-Host "* App settings - turn on App Insights extension, also set the App Insights key."
    az webapp config appsettings set -g $resourceGroup -n $webappName --settings `
        APPINSIGHTS_INSTRUMENTATIONKEY=$appInsightsKey `
        ApplicationInsightsAgent_EXTENSION_VERSION=~2

    Write-Host "* Connection strings - set up storage account connection from Web Jobs."
    az webapp config connection-string set -g $resourceGroup -n $webappName -t custom --settings `
        AzureWebJobsStorage=$storageAccountConnectionString
}