# Example Usage of Invoke-Fabric-Approval Script

# 1. First, get your Logic App's HTTP trigger URL from the Azure Portal:
# - Go to your Logic App
# - Click on the "Logic app designer"
# - The HTTP POST URL will be shown in the "When a HTTP request is received" trigger

# 2. Example command (replace with your values):
.\invoke-fabric-approval.ps1 `
    -LogicAppUrl "https://prod-35.eastus.logic.azure.com:443/workflows/2451886856834928895b63d4387e3119/triggers/manual/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=NVyigD8YdLmWzwK5T49Z4KuTqu5UOdji5n7HqCOGrUI" `
    -CapacityName "fabcap101" `
    -Location "eastus" `
    -ResourceGroup "fabricRG" `
    -SubscriptionId "95ad0027-ffa7-4f15-8a92-76112d0073d9" `
    -PolicyAssignmentId "/subscriptions/95ad0027-ffa7-4f15-8a92-76112d0073d9/providers/Microsoft.Authorization/policyAssignments/35c97326601c43479b3e7abd" `
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