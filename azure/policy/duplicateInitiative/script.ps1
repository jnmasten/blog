Param(
    [parameter(Mandatory=$true)][string]$Initiative,
    [parameter(Mandatory=$true)][string]$NewName,
    [parameter(Mandatory=$true)][string]$NewDisplayName
)

# Get subscription ID
$Id = (Get-AzContext).Subscription.Id 

# Get the initiative's properties using the name
$Initiative = Get-AzPolicySetDefinition | Where-Object {$_.Properties.DisplayName -eq $Name}

# Create a custom initiative
New-AzPolicySetDefinition `
    -Name $NewName `
    -DisplayName $NewDisplayName `
    -Description $Initiative.Properties.Description `
    -PolicyDefinition $([System.Text.RegularExpressions.Regex]::Unescape($($Initiative.Properties.PolicyDefinitions | ConvertTo-Json -Depth 100))) `
    -Metadata $($Initiative.Properties.Metadata | ConvertTo-Json  -Depth 100)  `
    -Parameter $($Initiative.Properties.Parameters | ConvertTo-Json  -Depth 100)  `
    -SubscriptionId $Id `
    -GroupDefinition $($Initiative.Properties.PolicyDefinitionGroups | ConvertTo-Json  -Depth 100)