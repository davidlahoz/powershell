# Check if the script is running with administrative privileges
if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    [System.Windows.Forms.MessageBox]::Show("This script needs to be run as an administrator. Please restart the script with elevated privileges.", "Administrative Privileges Required", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    exit
}

# Inform the user about the required options
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
[System.Windows.Forms.MessageBox]::Show("Sysprep will now be run. It will select 'OOBE and Reboot'. The system will reboot after sysprep completes.", "Sysprep Notification", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)

# Run sysprep with the required options
$sysprepPath = "C:\Windows\System32\Sysprep\sysprep.exe"
Start-Process -FilePath $sysprepPath -ArgumentList "/oobe /reboot" -Wait
