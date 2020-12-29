Param(

    [parameter(Mandatory=$true)]
    [string]$Blueprint,
    
    [parameter(Mandatory=$true)]
    [ValidateSet("UserAssigned","SystemAssigned")]
    [string]$IdentityType,

    [parameter(Mandatory=$true)]
    [ValidateScript({(Get-AzLocation).Location -contains $_})]
    [string]$Location,

    [parameter(Mandatory=$true)]
    [ValidateSet("AllResourcesDoNotDelete","AllResourcesReadOnly","None")]
    [string]$LockAssignment,
    
    [parameter(Mandatory=$true)]
    [string]$ManagementGroup,

    [parameter(Mandatory=$true)]
    [string]$Subscription

)

[cmdletbinding]

Set-AzContext -Subscription $Subscription -ErrorAction Stop

$Context = Get-AzContext

if($IdentityType -eq 'UserAssigned')
{
    $IdentityName = Read-Host -Prompt 'User Assigned Identity Name'
    $IdentityId = (Get-AzResource -ResourceType 'Microsoft.ManagedIdentity/userAssignedIdentities' -Name $IdentityName).ResourceId
}

$Profile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile

$Client = New-Object -TypeName Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient -ArgumentList ($Profile)

$Token = $Client.AcquireAccessToken($Context.Subscription.TenantId)

$Header = @{
    'Content-Type'='application/json'
    'Authorization'='Bearer ' + $Token.AccessToken
}

$URI = "https://management.azure.com/providers/Microsoft.Management/managementGroups/" + $ManagementGroup + "/providers/Microsoft.Blueprint/blueprintAssignments/" + $Blueprint + "?api-version=2018-11-01-preview"

$Body = @{
    
    identity = switch($IdentityType){
        
        SystemAssigned {@{ type = $IdentityType }}
        UserAssigned {@{ type = $IdentityType; userAssignedIdentities = @{ $IdentityId = @{} } }}

    }
    properties = @{
    
        blueprintId = (Get-AzBlueprint | Where-Object {$_.Name -eq $Blueprint}).Id
        resourceGroups = @{}
        scope = '/subscriptions/' + $Context.Subscription.Id
        locks = @{ mode = $LockAssignment }
        parameters = @{}
    }
    location = $Location

}

$BodyJson = ConvertTo-Json -InputObject $Body -Depth 100

Invoke-RestMethod `
    -Headers $Header `
    -Method Put `
    -Uri $URI `
    -Body $BodyJson `
    -Verbose