# Specify the path to the input directory
$inputDirectory = ".\input\"

# Specify the path to the output directory
$outputDirectory = ".\output\"

# Get all input files in the input directory
$inputFiles = Get-ChildItem -Path $inputDirectory -Filter *.txt

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

    # Output a message indicating the creation of the output file for the current input file
    Write-Host "Output file '$outputFileName' created."
}