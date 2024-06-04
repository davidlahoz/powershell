# Check if the script is running with administrative privileges
if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    [System.Windows.Forms.MessageBox]::Show("This script needs to be run as an administrator. Please restart the script with elevated privileges.", "Administrative Privileges Required", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    exit
}

# Create destination folder for the ID
New-Item -Path "C:\DeviceID" -ItemType Directory -Force

# Get the current execution policy
#$currentPolicy = Get-ExecutionPolicy


# Check if the current policy is not "Unrestricted"
#if ($currentPolicy -ne "Unrestricted") {
    # Set the execution policy to "Unrestricted"
#    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force
#}

# Output the current policy for confirmation
#Write-Output "Current Execution Policy: $(Get-ExecutionPolicy)"

# Get the current execution policy
$currentPolicy = Get-ExecutionPolicy

# Check if the current policy is not "Unrestricted"
if ($currentPolicy -ne "Unrestricted") {
    try {
        # Attempt to set the execution policy to "Unrestricted"
        Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force
    } catch {
        Write-Warning "Unable to set execution policy due to Group Policy settings."
    }
}

# Output the current policy for confirmation
$currentPolicy = Get-ExecutionPolicy
Write-Output "Current Execution Policy: $currentPolicy"


# Install NuGet and Autopilot script
Install-Module -Name NuGet -Confirm:$false
Install-Script -Name Get-WindowsAutoPilotInfo -Confirm:$false

# Run Get-WindowsAutoPilotInfo and save the ID
Get-WindowsAutoPilotInfo.ps1 -OutputFile c:\DeviceID\deviceid.csv

# Inform user
Write-Host "DeviceID generated succesfully in c:\DeviceID\"
Write-Host "Import it to Intune before proceeding with any next step!"
pause