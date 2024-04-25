Try {
    $Ask_Creds = Connect-AzureAD
    Write-Host "Connection with tenant successful"
}
Catch {
    Write-Host "Connection with tenant failed"
    exit
}

$Get_All_Users = Get-AzureADUser -All $true
$Users_report = @()

ForEach ($User in $Get_All_Users) {
    $User_ObjectID = $User.ObjectID
    $User_DisplayName = $User.DisplayName
    $User_Mail = $User.UserPrincipalName
    $User_Mobile = $User.Mobile
    $User_OU = $User.extensionproperty.onPremisesDistinguishedName
    $User_Account_Status = $User.AccountEnabled

    $Get_User_Devices = Get-AzureADUserRegisteredDevice -ObjectId $User_ObjectID

    foreach ($Device in $Get_User_Devices) {
        $DeviceObj = New-Object PSObject
        $DeviceObj | Add-Member NoteProperty -Name "User Name" -Value $User_DisplayName
        $DeviceObj | Add-Member NoteProperty -Name "User Mail" -Value $User_Mail
        $DeviceObj | Add-Member NoteProperty -Name "User OU" -Value $User_OU
        $DeviceObj | Add-Member NoteProperty -Name "Account enabled ?" -Value $User_Account_Status
        $DeviceObj | Add-Member NoteProperty -Name "Device Name" -Value $Device.DisplayName
        $DeviceObj | Add-Member NoteProperty -Name "Device Last Logon" -Value $Device.ApproximateLastLogonTimeStamp
        $DeviceObj | Add-Member NoteProperty -Name "Device OS Type" -Value $Device.DeviceOSType
        $DeviceObj | Add-Member NoteProperty -Name "Device OS Version" -Value $Device.DeviceOSVersion

        $Users_report += $DeviceObj
    }
}

$Users_report | Out-GridView
$Users_report | Export-Csv "C:\temp\list_Users_Devices.csv" -NoTypeInformation -Delimiter ";"