# Example Usage of Invoke-Fabric-Approval Script

# 1. First, get your Logic App's HTTP trigger URL from the Azure Portal:
# - Go to your Logic App
# - Click on the "Logic app designer"
# - The HTTP POST URL will be shown in the "When a HTTP request is received" trigger

# 2. Example command (replace with your values):
.\invoke-fabric-approval.ps1 `
    -LogicAppUrl "https://<addURL>" `
    -CapacityName "fabcap101" `
    -Location "eastus" `
    -ResourceGroup "fabricRG" `
    -SubscriptionId "<Subscription ID>" `
    -PolicyAssignmentId "/subscriptions/<Subscription ID>/providers/Microsoft.Authorization/policyAssignments/<Policy Assignment ID>" `
    -SkuName "F2" `
    -AdminMembers "shaleenthapa@hotmail.com"

# Notes:
# 1. CapacityName must be 3-63 characters, lowercase letters & numbers
# 2. Location must be a valid Azure region (e.g., eastus, westeurope)
# 3. SkuName must be one of: F2, F4, F8, F16, F32
# 4. AdminMembers should be comma-separated list without spaces
# 5. To get PolicyAssignmentId, run the helper script:
#    .\get-policy-assignment.ps1 -SubscriptionId "your-subscription-id"
#    This will show all relevant policy assignments. Copy the Policy Assignment ID that restricts Fabric capacity creation