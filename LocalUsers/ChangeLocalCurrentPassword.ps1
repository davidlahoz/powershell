# Get current username
$currentUserName = $env:USERNAME

# New password
$newPassword = ConvertTo-SecureString "the-new-password" -AsPlainText -Force

# Set password for the current user
Set-LocalUser -Name $currentUserName -Password $newPassword