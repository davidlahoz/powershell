# Check if AzureAD module is installed, if not, prompt the user to install it
if (-not (Get-Module -Name AzureAD -ListAvailable)) {
    Write-Host "AzureAD module is not installed. Please install the AzureAD module before running this script."
    exit
}

# Import the AzureAD module
Import-Module AzureAD

# Connect to Azure AD
Connect-AzureAD

# Specify the user email addresses
$userEmails = @("user1@acme.com", "user2@acme.com", "user3@acme.com")

# Initialize an array to store the results
$results = @()

foreach ($userEmail in $userEmails) {
    # Get the user object from Azure AD
    $user = Get-AzureADUser -Filter "UserPrincipalName eq '$userEmail'"
    
    if ($user) {
        # Get all applications where the user is an owner
        $userApplications = Get-AzureADUserOwnedApplication -ObjectId $user.ObjectId | Select-Object -ExpandProperty DisplayName

        # Create an object to store user email and associated applications where they are owners
        $userResult = [PSCustomObject]@{
            UserEmail = $user.UserPrincipalName
            OwnedApplications = $userApplications -join ","
        }

        # Add the user result to the results array
        $results += $userResult
    } else {
        Write-Host "User with email address $userEmail not found."
    }
}

# Display the results
$results | Format-Table -AutoSize

# Export the results to a CSV file
$results | Export-Csv -Path "C:\temp\UserOwnedApplications.csv" -NoTypeInformation
