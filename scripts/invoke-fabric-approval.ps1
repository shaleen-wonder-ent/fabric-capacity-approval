# Parameters for invoking Fabric Capacity Approval Logic App
param(
    [Parameter(Mandatory = $true)]
    [string]$LogicAppUrl,  # Get this from Logic App's trigger URL

    [Parameter(Mandatory = $true)]
    [string]$CapacityName,

    [Parameter(Mandatory = $true)]
    [string]$Location,

    [Parameter(Mandatory = $true)]
    [string]$ResourceGroup,

    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $true)]
    [string]$PolicyAssignmentId,  # ID of the deny policy assignment that blocks Fabric capacity creation (from policy-deny-fabric-capacity.json)

    [Parameter(Mandatory = $true)]
    [ValidateSet('F2', 'F4', 'F8', 'F16', 'F32')]
    [string]$SkuName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$AdminMembers  # Comma-separated list of admin UPNs or SP objectIds
)

# Construct the request body
$body = @{
    capacityName = $CapacityName
    location = $Location
    resourceGroup = $ResourceGroup
    subscriptionId = $SubscriptionId
    policyAssignmentId = $PolicyAssignmentId
    skuName = $SkuName
    adminMembers = $AdminMembers
} | ConvertTo-Json

# Invoke the Logic App
$response = Invoke-RestMethod `
    -Uri $LogicAppUrl `
    -Method Post `
    -Body $body `
    -ContentType "application/json"

# Output the response
Write-Host "Logic App triggered successfully!"
Write-Host "Response:"
$response | ConvertTo-Json
