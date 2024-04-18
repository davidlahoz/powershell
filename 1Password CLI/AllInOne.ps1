# Menu function to display options and get user choice
function Show-Menu {
    Clear-Host
    Write-Host "1. Create commands from txt files (Group.txt)"
    Write-Host "2. Create in bulk users and add them to a group in 1Password"
    Write-Host "3. Exit"
    return (Read-Host "Please select an option")
}

# Function to execute Script 1
function New-Script1Execution {
    # Specify the path to the input directory
    $inputDirectory = ".\input\"

    # Specify the path to the output directory
    $outputDirectory = ".\output\"

    # Get all input files in the input directory
    $inputFiles = Get-ChildItem -Path $inputDirectory -Filter *.txt

    # Initialize an array to store the names of the created output files
    $createdFiles = @()

    # Loop through each input file
    foreach ($inputFile in $inputFiles) {
        # Read the content of the current input file
        $emails = Get-Content $inputFile.FullName

        # Get the group name from the input file name (without extension)
        $groupName = $inputFile.BaseName

        # Initialize an empty array to store the output content for the current input file
        $outputContent = @()

        # Loop through each email address in the current input file
        foreach ($email in $emails) {
            # Split the email address by "."
            $parts = $email.Split('.')

            # Extract the name and last name and capitalize the first letter
            $name = $parts[0].Substring(0,1).ToUpper() + $parts[0].Substring(1).ToLower()
            $lastName = $parts[1].Split('@')[0].Substring(0,1).ToUpper() + $parts[1].Split('@')[0].Substring(1).ToLower()

            # Create the output content for the current email
            $userProvisionCommand = "op user provision --name ""$name $lastName"" --email ""$email"""

            # Add the user provision command to the output content array for the current input file
            $outputContent += $userProvisionCommand
        }

        # Add the "op user confirm --all" command to the output content array for the current input file
        $outputContent += "op user confirm --all"

        # Add the group provision command for each user
        foreach ($email in $emails) {
            $outputContent += "op group provision --name ""$groupName"" --user ""$email"""
        }

        # Specify the output file name based on the input file name
        $outputFileName = Join-Path -Path $outputDirectory -ChildPath ($inputFile.BaseName + ".txt")

        # Write the output content to the output file
        Set-Content -Path $outputFileName -Value $outputContent

        # Add the created file name to the array
        $createdFiles += $outputFileName
    }

    # Prompt confirming successful creation of output files
    Write-Host "Output files have been successfully created:"
    foreach ($file in $createdFiles) {
        Write-Host $file
    }

    # Pause the script until the user presses any key
    Pause
}



# Function to execute Script 2
function New-Script2Execution {
    # Check if 1Password CLI is installed
    $1PasswordCLIInstalled = Test-Path "C:\Program Files\1Password CLI\op.exe"

    if ($1PasswordCLIInstalled) {
        Write-Host "1Password CLI detected. Continuing with the script..." -ForegroundColor Green
    } else {
        Write-Host "1Password CLI is not installed. Please install it before running this script." -ForegroundColor DarkRed
        return
    }

    # Get a list of .txt files in the output directory
    $txtFiles = Get-ChildItem -Path ".\output\" -Filter "*.txt" | Select-Object -ExpandProperty Name

    # Display the list of .txt files with a choosing menu
    Write-Host "Select the .txt file you want to use:"
    for ($i = 0; $i -lt $txtFiles.Count; $i++) {
        Write-Host "$($i+1). $($txtFiles[$i])"
    }

    # Prompt the user to choose a file
    $fileIndex = Read-Host "Enter the number corresponding to the file you want to use"

    # Check if the input is a valid number
    if ($fileIndex -match '^\d+$' -and $fileIndex -ge 1 -and $fileIndex -le $txtFiles.Count) {
        # Get the selected file name
        $selectedFile = $txtFiles[$fileIndex - 1]
        $filePath = "..\output\$selectedFile"

        # Function to execute commands from a text file
        function ExecuteCommandsFromFile {
            param (
                [string]$filePath
            )

            # Check if file exists
            if (-not (Test-Path -Path $filePath -PathType Leaf)) {
                Write-Host "File '$filePath' not found."
                return
            }

            # Read file contents line by line
            $commands = Get-Content -Path $filePath

            # Loop through each command and execute
            foreach ($command in $commands) {
                Write-Host "Executing command: $command"
                Invoke-Expression -Command $command
            }
        }

        # Main script
        ExecuteCommandsFromFile -filePath $filePath
    } else {
        Write-Host "Invalid input. Please enter a valid number corresponding to the file you want to use."
    }
}

# Main script
while ($true) {
    $choice = Show-Menu
    switch ($choice) {
        '1' {
            New-Script1Execution
            break
        }
        '2' {
            New-Script2Execution
            break
        }
        '3' {
            exit
        }
        default {
            Write-Host "Invalid choice. Please try again."
            break
        }
    }
}
