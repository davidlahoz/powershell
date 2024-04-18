# Needed Modules:
# AzureAD - https://www.powershellgallery.com/packages/AzureAD/

# Define the path to save the CSV file
$csvPath = "C:\temp\$($selectedGroup.DisplayName)_Members.csv"

# Connect to AzureAD - prompts user-interactive login
$null = Connect-AzureAD

do {
    # Prompt user to enter the search string
    $searchString = Read-Host "Enter the search string to find AzureAD user groups (or type 'q' to quit)"

    if ($searchString -eq "q") {
        Exit
    }

    # Search for the user groups containing the search string
    $userGroups = Get-AzureADGroup | Where-Object { $_.DisplayName.ToLower().Contains($searchString.ToLower()) } | Select-Object -Property @{Name="Option";Expression={$_.TableIndex+1}}, ObjectId, DisplayName

    # Check if any user groups are found
    if ($userGroups) {
        # Display the found user groups
        Write-Host "Found user groups matching '$searchString':`n" -BackgroundColor DarkGreen
        $userGroups | Format-Table -AutoSize -Property Option, DisplayName

        do {
            # Prompt user to choose a user group from the list
            $selectedGroupIndex = Read-Host "Enter the option number of the user group to export its members (or type 'q' to quit)"
            
            if ($selectedGroupIndex -eq "q") {
                Exit
            }

            $selectedGroup = $userGroups | Where-Object { $_.Option -eq $selectedGroupIndex }

            if ($selectedGroup) {
                # Confirm the selection
                $confirm = Read-Host "You selected $($selectedGroup.DisplayName). Proceed to export its members to a CSV file? (Y/N)"
                if ($confirm -eq "Y" -or $confirm -eq "y") {
                    # Get the members of the selected group
                    $groupMembers = Get-AzureADGroupMember -ObjectId $selectedGroup.ObjectId

                    # Export the group members to a CSV file
                    $groupMembers | Export-Csv -Path $csvPath -NoTypeInformation

                    Write-Host "Group members exported to '$csvPath' successfully." -BackgroundColor DarkGreen
                } elseif ($confirm -eq "N" -or $confirm -eq "n") {
                    Write-Host "Operation canceled." -BackgroundColor DarkRed
                } else {
                    Write-Host "Invalid input. Please enter 'Y' or 'N'." -BackgroundColor DarkRed
                }
            } else {
                Write-Host "Invalid selection. Please choose an option from the list or type 'q' to quit." -BackgroundColor DarkRed
            }
        } while (-not $selectedGroup)
    } else {
        $retry = Read-Host "No user groups found matching '$searchString'. Would you like to search again? (Y/N)" -BackgroundColor Yellow -ForegroundColor Black
        if ($retry -eq "N" -or $retry -eq "n") {
            Exit
        }
    }
} while ($true)