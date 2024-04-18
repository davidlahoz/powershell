# Needed Modules:
# ExchangeOnlineManagement - https://www.powershellgallery.com/packages/ExchangeOnlineManagement/

# Connect to Exchange Online - prompts user-interactive login
$null = Connect-ExchangeOnline

# CSV file path
$CsvPath = "C:\temp\RemoveBulkMailBoxPermission.csv"

# Function to prompt the user for confirmation with background color
function Confirm-Action {
    param (
        [string]$Message
    )
    
    do {
        Write-Host -BackgroundColor Yellow -NoNewline "$Message (Y/N)"
        $response = Read-Host ""
    } until ($response -eq "Y" -or $response -eq "N")

    return $response
}

# Function to prompt the user for an email address
function Get-EmailAddress {
    $EmailAddress = Read-Host "Enter the email address to modify permissions for:"
    return $EmailAddress
}

# Function to remove permissions from a single account
function Remove-SinglePermission {
    param (
        [string]$EmailAddress
    )

    try {
        # Remove-MailboxPermission command goes here
        Write-Host "Permission removed from $EmailAddress"
    }
    catch {
        Write-Host "Error: $_"
    }
}

# Function to remove permissions from a CSV file
function Remove-BulkPermissions {
    param (
        [string]$CsvPath
    )

    try {
        # Read CSV and loop through each entry to remove permissions
        $csvData = Import-Csv $CsvPath
        foreach ($entry in $csvData) {
            # Remove-MailboxPermission command goes here for each entry
        }
        Write-Host "Permissions removed successfully using the file from $CsvPath"
    }
    catch {
        Write-Host "Error: $_"
    }
}

# Main script starts here
$EmailAddress = Get-EmailAddress
$response = Confirm-Action "Is $EmailAddress correct?"

if ($response -eq "Y") {
    $options = @"
Select an option:
1. Remove permissions from one single account
2. Remove permissions from  several accounts at once (CSV file - bulk)
"@
    Write-Host $options

    $choice = Read-Host "Enter your choice (1/2):"
    switch ($choice) {
        1 { Remove-SinglePermission -EmailAddress $EmailAddress }
        2 { Remove-BulkPermissions -CsvPath $CsvPath }
        default { Write-Host "Invalid choice" }
    }
}
else {
    Clear-Host
    & ".\Remove-MailboxPermission_FromCSV.ps1" # Run the script again recursively
}
