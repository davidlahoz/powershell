# Needed Modules:
# PowershellGet - https://www.powershellgallery.com/packages/PowerShellGet/
# ExchangeOnlineManagement - https://www.powershellgallery.com/packages/ExchangeOnlineManagement/

# Connect to Exchange Online - prompts user-interactive login
$null = Connect-ExchangeOnline


# Define the path to the CSV file - CSV column name must be "Identity" (email address)
$csvPath = "C:\temp\DistributionGroupsToDelete.csv"

# Check if the CSV file exists
if (-not (Test-Path $csvPath)) {
    Write-Host "CSV file not found at $csvPath" -BackgroundColor DarkRed
    Write-Host "Please make sure the file exists." -BackgroundColor DarkRed
    Exit
}

# Read the CSV file recursively
$groups = Import-Csv -Path $csvPath

# Iterate through each row in the CSV
foreach ($group in $groups) {
    # Check if the 'Identity' column exists
    if ($group.PSObject.Properties.Name -contains 'Identity') {
        # Get the identity of the distribution group
        $identity = $group.Identity
        
        # Try to remove the distribution group
        $errorActionPreference = "Stop"
        try {
            Remove-DistributionGroup -Identity $identity -ErrorAction Stop
            Write-Host "Distribution group '$identity' removed successfully." -BackgroundColor DarkGreen
        } catch {
            $errorMessage = $_.Exception.Message
            if ($errorMessage -match "couldn't be found on") {
                Write-Host "The group $identity was not deleted since it does not exist in your Directory." -BackgroundColor Yellow -ForegroundColor Black
            } else {
                Write-Host "Failed to remove distribution group '$identity': $_" -BackgroundColor DarkRed
            }
        } finally {
            $errorActionPreference = "Continue"
        }
    } else {
        Write-Host "CSV FORMAT ERROR! Identity column not found in the CSV file." -BackgroundColor DarkRed
        Exit
    }
}
