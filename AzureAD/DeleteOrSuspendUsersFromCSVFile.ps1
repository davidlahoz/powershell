# Needed Modules:
# AzureAD - https://www.powershellgallery.com/packages/AzureAD/

# Connect to AzureAD - prompts user-interactive login
$null = Connect-AzureAD

# Define the path to the CSV file
# CSV column names must be "ObjectId" and "status"
# Status: "delete" or "suspend"
$csvPath = "C:\temp\UsersToDeleteOrSuspend.csv"

# Check if the CSV file exists
if (-not (Test-Path $csvPath)) {
    Write-Host "CSV file not found at $csvPath" -BackgroundColor DarkRed
    Write-Host "Please make sure the file exists." -BackgroundColor DarkRed
    Exit
}

# Read the CSV file recursively
$users = Import-Csv -Path $csvPath

# Iterate through each row in the CSV
foreach ($user in $users) {
    # Check if the 'ObjectId' and 'Status' columns exist
    if ($user.PSObject.Properties.Name -contains 'ObjectId' -and $user.PSObject.Properties.Name -contains 'Status') {
        # Get the object id and status of the user
        $objectId = $user.ObjectId
        $status = $user.Status
        
        # Try to remove or suspend the user based on the status
        $errorActionPreference = "Stop"
        try {
            if ($status -eq "delete") {
                Remove-AzureADUser -ObjectId $objectId -Force -ErrorAction Stop
                Write-Host "Account '$objectId' deleted successfully." -BackgroundColor DarkGreen
            } elseif ($status -eq "suspend") {
                Set-AzureADUser -ObjectId $objectId -AccountEnabled $false -ErrorAction Stop
                Write-Host "Account '$objectId' suspended successfully." -BackgroundColor DarkGreen
            } else {
                Write-Host "Invalid status '$status' for user with the account '$objectId'." -BackgroundColor DarkRed
            }
        } catch {
            Write-Host "Failed to process user with ObjectId '$objectId': $_" -BackgroundColor DarkRed
        } finally {
            $errorActionPreference = "Continue"
        }
    } else {
        Write-Host "CSV FORMAT ERROR! 'ObjectId' or 'Status' column not found in the CSV file." -BackgroundColor DarkRed
        Exit
    }
}
