# Needed Modules:
# ExchangeOnlineManagement - https://www.powershellgallery.com/packages/ExchangeOnlineManagement/

# Connect to Exchange Online - prompts user-interactive login
$null = Connect-ExchangeOnline

# CSV file path
$CsvPath = "C:\temp\AddBulkMailBoxPermission.csv"

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

# Function to grant permissions to a single person
function Grant-SinglePermission {
    param (
        [string]$EmailAddress
    )

    try {
        # Add-MailboxPermission command goes here
        Write-Host "Permission granted to $EmailAddress"
    }
    catch {
        Write-Host "Error: $_"
    }
}

# Function to grant permissions from a CSV file
function Grant-BulkPermissions {
    param (
        [string]$CsvPath
    )

    try {
        # Read CSV and loop through each entry to grant permissions
        $csvData = Import-Csv $CsvPath
        foreach ($entry in $csvData) {
            # Add-MailboxPermission command goes here for each entry
        }
        Write-Host "Permissions removed successfully using the file from $CsvPath"
    }
    catch {
        Write-Host "Error: $_"
    }
}

# Main script starts here
$EmailAddress = Read-Host "Enter the email address to add permissions to:"
$response = Confirm-Action "Is $EmailAddress correct?"

if ($response -eq "Y") {
    $options = @"
Select an option:
1. Grant permissions to one single account
2. Grant permissions from  several accounts at once (CSV file - bulk)
"@
    Write-Host $options

    $choice = Read-Host "Enter your choice (1/2):"
    switch ($choice) {
        1 { Grant-SinglePermission -EmailAddress $EmailAddress }
        2 { Grant-BulkPermissions -CsvPath $CsvPath }
        default { Write-Host "Invalid choice" }
    }
}
else {
    Clear-Host
    & ".\Add-MailboxPermission_FromCSV.ps1" # Run the script again recursively
}