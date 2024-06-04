# Needed Modules:
# ExchangeOnlineManagement - https://www.powershellgallery.com/packages/ExchangeOnlineManagement/
#
# The CSV (UserlistEnableLitigationHold.csv) file should follow this format:
# username
# user1@example.com
# user2@example.com

# Define path to the CSV file
$csvPath = "C:\temp\UserlistEnableLitigationHold.csv"

# Importing the session module
Import-Module ExchangeOnlineManagement

# Connect to Exchange Online
Connect-ExchangeOnline -ShowProgress $true

# Reading from CSV and updating each mailbox
Import-Csv -Path $csvPath | ForEach-Object {
    $username = $_.username
    Write-Host "Setting Litigation Hold for $username"
    
    try {
        Set-Mailbox -Identity $username -LitigationHoldEnabled $true
        Write-Host "Litigation hold set successfully for $username"
    } catch {
        Write-Host "Failed to set litigation hold for $username. Error: $_"
    }
}

# Disconnect the session
Disconnect-ExchangeOnline -Confirm:$false
