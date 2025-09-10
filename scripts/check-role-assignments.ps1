# Check Role Assignments for Both Identities
param(
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory = $true)]
    [string]$LogicAppName,

    [Parameter(Mandatory = $true)]
    [string]$GithubSpClientId
)

# Connect to Azure if not already connected
try {
    $context = Get-AzContext
    if (-not $context) {
        Connect-AzAccount
    }
} catch {
    Connect-AzAccount
}

# Set the correct subscription
Set-AzContext -SubscriptionId $SubscriptionId

Write-Host "`n=== Checking Logic App Managed Identity Roles ===" -ForegroundColor Cyan
# Get Logic App's managed identity
$logicApp = Get-AzLogicApp -ResourceGroupName $ResourceGroupName -Name $LogicAppName
if ($logicApp -and $logicApp.Identity) {
    $logicAppId = $logicApp.Identity.PrincipalId
    Write-Host "Logic App Managed Identity Principal ID: $logicAppId"
    
    Write-Host "`nRole Assignments for Logic App:" -ForegroundColor Yellow
    Get-AzRoleAssignment -ObjectId $logicAppId | Format-Table RoleDefinitionName, Scope -AutoSize
} else {
    Write-Host "Logic App not found or managed identity not enabled!" -ForegroundColor Red
}

Write-Host "`n=== Checking GitHub Actions Service Principal Roles ===" -ForegroundColor Cyan
Write-Host "GitHub Actions Client ID: $GithubSpClientId"
Write-Host "`nRole Assignments for GitHub Actions SP:" -ForegroundColor Yellow
Get-AzRoleAssignment -ObjectId $GithubSpClientId | Format-Table RoleDefinitionName, Scope -AutoSize