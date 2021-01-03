Param(

    [parameter(Mandatory=$true)][string]$Location
    
)

[cmdletbinding]

#############################################################
# Variables
#############################################################
# Gets User Principal for Key Vault Access Policy
$UserObjectId = (Get-AzADUser | Where-Object {$_.UserPrincipalName -like "$((Get-AzContext).Account.Id.Split('@')[0])*"}).Id

# Sets user details for deployment name
$Context = Get-AzContext
$Username = $Context.Account.Id.Split('@')[0]
$TimeStamp = Get-Date -F 'yyyyMMddhhmmss'
$Name =  $Username + '_' + $TimeStamp


#############################################################
# Template Parameter Object
#############################################################
$Params = @{
    UserObjectId = $UserObjectId
    Username = $Username
}


#############################################################
# Deployment
#############################################################
try 
{
    New-AzSubscriptionDeployment `
        -Name $Name `
        -Location $Location `
        -TemplateFile '.\subscription.json' `
        -TemplateParameterObject $Params `
        -ErrorAction Stop `
        -Verbose
}
catch 
{
    Write-Host "Deployment Failed: $Name"
    $_ | Select-Object *
}