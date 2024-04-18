# Needed Modules:
# ExchangeOnlineManagement - https://www.powershellgallery.com/packages/ExchangeOnlineManagement/

# Connect to Exchange Online - prompts user-interactive login
$null = Connect-ExchangeOnline

# CSV file path
$csvPath = "C:\temp\EmailToSharedMailbox.csv"

# Function to transform regular account to shared mailbox
function TransformToSharedMailbox {
    param (
        [string]$EmailAddress
    )

    try {
        # Set the mailbox type to Shared
        Set-Mailbox -Identity $EmailAddress -Type Shared
        Write-Host "Successfully transformed $EmailAddress to a shared mailbox." -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to transform $EmailAddress to a shared mailbox. Error: $_" -ForegroundColor Red
    }
}

# Display warning message with red background and white foreground color
Write-Host "Please check documentation before using the script - visit :" -BackgroundColor Red -ForegroundColor White
Write-Host "https://learn.microsoft.com/en-us/exchange/recipients-in-exchange-online/manage-user-mailboxes/convert-a-mailbox#what-do-you-need-to-know-before-you-begin" -BackgroundColor Yellow -ForegroundColor Red
$warningAccepted = Read-Host "Type 'yes' to acknowledge and continue"

if ($warningAccepted -ne "yes") {
    Write-Host "You must accept the warning to continue" -ForegroundColor Red
    exit
}

# Prompt user to choose between single email address or CSV file
do {
    Write-Host "Choose an option:"
    $options = @("Single Email Address", "CSV File")
    for ($i = 0; $i -lt $options.Count; $i++) {
        Write-Host "$($i + 1). $($options[$i])"
    }

    $choice = Read-Host -Prompt "Enter the option number (1-$($options.Count))"

    if ($choice -eq 1) {
        # Prompt user to enter the email address
        $email = Read-Host "Enter the email address of the regular account you want to transform to a shared mailbox: "
        TransformToSharedMailbox -EmailAddress $email
    }
    elseif ($choice -eq 2) {
        # Check if the CSV file exists
        if (Test-Path $csvPath) {
            # Import CSV file
            $csvData = Import-Csv $csvPath

            # Iterate through each row in the CSV file and transform regular accounts to shared mailboxes
            foreach ($row in $csvData) {
                TransformToSharedMailbox -EmailAddress $row.Identity
            }
        }
        else {
            Write-Host "CSV file not found at the specified path." -BackgroundColor Yellow
        }
    }
    else {
        Write-Host "Invalid choice. Please choose a valid option." -BackgroundColor DarkRed
    }
} until ($choice -eq 1 -or $choice -eq 2)