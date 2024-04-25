$PASSWORD= ConvertTo-SecureString -AsPlainText -Force -String h>8z[w$o%/fhfSBmo0]:
New-LocalUser -Name "LocalAdmin" -Description "Local Administrator" -Password $PASSWORD
Add-LocalGroupMember -Group "Administrators" -Member "LocalAdmin"