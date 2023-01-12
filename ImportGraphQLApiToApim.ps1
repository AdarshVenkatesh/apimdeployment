param(
	[string]$ApimResourceGroupName = $(throw "-ApimResourceGroupName is required."),
    [string]$ApimInstanceName = $(throw "-ApimInstanceName is required."),
    [string]$GraphQLSuffix = $(throw "-GraphQLSuffix is required."),
    [string]$ServiceUrl = $(throw "-ServiceUrl is required."),
    [string]$ApiName = $(throw "-ApiName is required.")
)

Write-Host "Reading API Name"
Write-Host "API Name: $ApiName"
$schemaUrl = "https://fd-csp-sit-h7f5bmcpfahwfwfr.z01.azurefd.net/csp-api/graphql/sdl"
$schemaFileName = "schema.graphql"
$apiContext = New-AzApiManagementContext -ResourceGroupName $ApimResourceGroupName -ServiceName $ApimInstanceName
$apiObj = Get-AzApiManagementApi -Context $apiContext -Name "$ApiName"

if ( -Not $apiObj)
{
        # Api Doesnot exist. Generate a new ApiId
        $ApiId = [guid]::NewGuid()
        Write-Host "Generated ApiId is $ApiId"
        Write-Host "ResourceGroupName $ApimResourceGroupName"
        Write-Host "API mgmt context $ApimInstanceName"
}
else
{
    $ApiId = $apiObj.ApiId
    Write-Host "Existing APIId of APIM endpoint is $ApiId" 
}

Write-Host "Downloading schema to schema.graphql file"
Invoke-RestMethod -Uri $schemaUrl -OutFile $schemaFileName
ls

Write-Host "Import GraphQL Api endpoint to apim instance"
Import-AzApiManagementApi -ServiceUrl $ServiceUrl -ApiType GraphQL -Path $GraphQLSuffix -ApiId $ApiId -Context $apiContext -SpecificationUrl $schemaUrl -SpecificationFormat GraphQL
Write-Host "GraphQL APi successfully imported to apim instance.." -ForegroundColor "Green"
