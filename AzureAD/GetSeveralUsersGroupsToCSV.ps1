# Needed Modules:
# AzureAD - https://www.powershellgallery.com/packages/AzureAD/

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
$userEmails = @("john@acme.com", "jane@acme.com", "tim@acme.com")

# Initialize an array to store the results
$results = @()

foreach ($userEmail in $userEmails) {
    # Get the user object from Azure AD
    $user = Get-AzureADUser -Filter "UserPrincipalName eq '$userEmail'"
    
    if ($user) {
        # Get all groups that the user is a member of
        $userGroups = Get-AzureADUserMembership -ObjectId $user.ObjectId | Select-Object -ExpandProperty DisplayName

        # Create an object to store user email and associated groups
        $userResult = [PSCustomObject]@{
            UserEmail = $user.UserPrincipalName
            Groups = $userGroups -join ","
        }

        # Add the user result to the results array
        $results += $userResult
    } else {
        Write-Host "User with email address $userEmail not found."
    }
}

# Export the results to a CSV file in C:\temp\
$results | Export-Csv -Path "C:\temp\UserGroups.csv" -NoTypeInformation
