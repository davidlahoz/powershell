# Check if 1Password CLI is installed
$1PasswordCLIInstalled = Test-Path "C:\Program Files\1Password CLI\op.exe"

if ($1PasswordCLIInstalled) {
    Write-Host "1Password CLI detected. Continuing with the script..." -ForegroundColor Green
} else {
    Write-Host "1Password CLI is not installed. Please install it before running this script." -ForegroundColor DarkRed
    return
}

# Sign in to 1Password CLI
Write-Host "Signing in to 1Password CLI..."
op signin

# List all the .txt files in the folder
$files = Get-ChildItem -Path "..\1Password CLI\output\" -Filter "*.txt" | Select-Object -ExpandProperty Name

# Prompt the user to choose a file
Write-Host "Select a file to use:"
for ($i = 0; $i -lt $files.Count; $i++) {
    Write-Host "$($i + 1). $($files[$i])"
}
$selectedFileIndex = Read-Host "Enter the number corresponding to the file:"

# Validate user input
if ($selectedFileIndex -gt 0 -and $selectedFileIndex -le $files.Count) {
    $selectedFileName = $files[$selectedFileIndex - 1]
    $filePath = "..\1Password CLI\output\$selectedFileName"
} else {
    Write-Host "Invalid selection. Exiting script." -ForegroundColor DarkRed
    return
}

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
