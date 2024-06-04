# Check if the script is running with administrative privileges
if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    [System.Windows.Forms.MessageBox]::Show("This script needs to be run as an administrator. Please restart the script with elevated privileges.", "Administrative Privileges Required", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    exit
}

# Create destination folder for the ID
New-Item -Path "C:\DeviceID" -ItemType Directory -Force

# Get current ExecutionPolicy
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
Write-Host "DeviceID generated succesfully. Saved in c:\DeviceID\" -ForegroundColor Green

# Force user to confirm Intune upload - https://learn.microsoft.com/en-us/autopilot/add-devices#add-devices
do {
    Write-Host "Import the CSV file to Intune before proceeding with the next step!" -ForegroundColor Red -BackgroundColor Yellow
    Write-Host "How to import DeviceID guide:"
    Write-Host "https://learn.microsoft.com/en-us/autopilot/add-devices#add-devices" -ForegroundColor White -BackgroundColor Blue
    Write-Host " "
    $userInput = Read-Host "Type YES once the DeviceID was succesfully imported to Intune" -ForegroundColor Red
} while ($userInput -ne 'YES')


# Inform the user about the sysprep OOBE restart
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
[System.Windows.Forms.MessageBox]::Show("Sysprep will now be run. It will select 'OOBE and Reboot'. The system will reboot after sysprep completes.", "Sysprep Notification", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)

# Run sysprep with the required options
$sysprepPath = "C:\Windows\System32\Sysprep\sysprep.exe"
Start-Process -FilePath $sysprepPath -ArgumentList "/oobe /reboot" -Wait