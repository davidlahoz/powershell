# Needed Modules:
# AzureAD - https://www.powershellgallery.com/packages/AzureAD/

# Email domain variable - edit to your desired naming convention for externals.
$ExternalEmailPattern = "_ext@yourdomain.com"

# Connect to AzureAD - prompts user-interactive login
$null = Connect-AzureAD

# Function to get all Azure AD users and store them in memory
function Get-AzureADUsers {
    Write-Host "Fetching all Azure AD users. Depending on your tenant size might take long..." -BackgroundColor White -ForegroundColor Black
    $global:AllUsers = Get-AzureADUser -All $true | Select-Object DisplayName, UserPrincipalName, UserType
    Write-Host "All Azure AD users fetched and stored in memory." -BackgroundColor DarkGreen -ForegroundColor Black
}

# Function to export filtered Azure AD users to CSV
function Export-AzureADUsers {
    param (
        [string]$UserType
    )

    try {
        $users = @()

        if ($UserType -eq "Internal") {
            # Filter internal users (excluding those with "_ext" in email)
            $users = $global:AllUsers | Where-Object { $_.UserType -eq 'Member' -and $_.UserPrincipalName -notlike "*$ExternalEmailPattern" }
        }
        elseif ($UserType -eq "External") {
            # Filter external users (with specified email domain)
            $users = $global:AllUsers | Where-Object { $_.UserPrincipalName -like "*$ExternalEmailPattern" }
        }
        elseif ($UserType -eq "Guest") {
            # Filter guest users
            $users = $global:AllUsers | Where-Object { $_.UserType -eq 'Guest' }
        }
        elseif ($UserType -eq "All") {
            # Get all users
            $users = $global:AllUsers
        }

        # Export filtered users to CSV
        $users | Export-Csv -Path "C:\temp\AzureADUsers_$UserType.csv" -NoTypeInformation
        Write-Host "Exported Azure AD  '$UserType' users to C:\temp\AzureADUsers_$UserType.csv" -BackgroundColor Green -ForegroundColor DarkGreen
        
        # Prompt user if they want to export another group
        $exportAnother = Read-Host "Do you want to export another user type? (Y/N)"
        if ($exportAnother -eq "Y" -or $exportAnother -eq "y") {
            return $true
            
        }
        else {
            return $false
        }
    }
    catch {
        Write-Host "Error occurred while exporting Azure AD users: $_" -BackgroundColor DarkRed
        return $false
    }
}

# Start by fetching all Azure AD users
Get-AzureADUsers

# Main menu
$options = @("Internal", "External", "Guest", "All")
do {
    Write-Host "Select UserType to export:"
    for ($i = 0; $i -lt $options.Count; $i++) {
        Write-Host "$($i+1). $($options[$i])"
    }

    # Prompt user to choose UserType
    try {
        $choice = Read-Host "Enter the number corresponding to user type you want to export (1-$($options.Count))"
        if ($choice -ge 1 -and $choice -le $options.Count) {
            $selectedOption = $options[$choice - 1]
            $exportAnother = Export-AzureADUsers -UserType $selectedOption
        }
        else {
            Write-Host "Invalid choice. Please choose a valid option." -BackgroundColor DarkRed
            $exportAnother = $true  # Continue loop to prompt user again
        }
    }
    catch {
        Write-Host "An error occurred: $_" -BackgroundColor Red
        $exportAnother = $true  # Continue loop to prompt user again
    }
} while ($exportAnother)

# Clear data from memory and exit the script
Remove-Variable -Name AllUsers -Scope Global
Exit