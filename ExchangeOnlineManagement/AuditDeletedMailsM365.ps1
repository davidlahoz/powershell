<#
Script Highlights: 
1. The script uses modern authentication to retrieve audit logs. 
2. The script can be executed with MFA enabled account too.   
3. Exports report results to CSV file.   
4. Allows you to track all the deleted emails. 
5. Helps to find out who deleted email from a shared mailbox. 
6. Allows you to generate an email deletion audit report for a custom period.   
7. Automatically installs the EXO V2 module (if not installed already) upon your confirmation.  
8. The script is scheduler-friendly. I.e., Credential can be passed as a parameter instead of saving inside the script.
9. By default, the reports results are for the past 90 days.

Detailed Script execution:
    Track All the Deleted Emails – Who Deleted What Message and When: 
    Users might delete or move critical business emails to deleted items unknowingly. So, admins need to identify the Exchange emails that were deleted or moved to deleted items in their organization.
    Argument: .\AuditDeletedMailsM365.ps1

How to Find out Who Deleted Emails from Shared mailbox: 
    Since the shared mailboxes can be accessed by multiple users (I.e., shared mailbox delegates), it’s necessary to identify the user who has deleted an email from a shared mailbox. To view who have permission on shared mailboxes, you can refer our blog post on get shared mailbox delegates.
    Argument: .\AuditDeletedMailsM365.ps1 -Mailbox sharedmailbox@domain.com

Audit Who Deleted Emails from a Specific Mailbox: 
    An organization may have requirements to allow some users to access another user’s mailbox. So, the emails can be deleted by mailbox delegates and owners. You can generate a mailbox permission report to know the mailbox delegates.
    Argument: .\AuditDeletedMailsM365.ps1 -Mailbox johndoe@domain.com

Find Deleted Emails by Subject: 
    If you want to find an important email from the pool of deleted emails, you can filter out the emails by subject (a word or phrase that the subject contains).
    Argument: .\AuditDeletedMailsM365.ps1 -Subject “Super Important Email”

Audit Email Deletion for a Custom Period: 
    If you want to generate an email audit report for a specific time range, you can run the script with –StartDate and –EndDate params.
    DATE MUST BE IN US FORMAT (MM/DD/YY)
    Argument: .\AuditDeletedMailsM365.ps1 -StartDate 12/01/24 -EndDate 01/28/26
    This can be mixed with auditing a certain mailbox
    Argument: .\AuditDeletedMailsM365.ps1 -StartDate 12/01/24 -EndDate 01/28/26 -Mailbox santaclaus@domain.com

---------------------

Technically you can also Schedule or even get a monthly report by email.

Schedule ‘Deleted Emails Audit Report’: 
    Since the ‘Search-UnifiedAuditLog‘ can keep an audit log for 90 days, you may require old data for analysis.
    In that case, scheduling will help you to keep the audit log for a longer period.
    To run this script as PowerShell scheduled task, you can use the below format in the Windows Task Scheduler.
    Argument: .\AuditDeletedMailsM365.ps1 -UserName admin@domain.com -Password Letmein123

Get a Monthly Report on Email Deletion:
    Argument: .\AuditDeletedMailsM365.ps1 -StartDate ((Get-Date).AddDays(-30)) -EndDate (Get-Date) -UserName admin@domain.com -Password Letmein123


============================================================================================
#>

Param(
    [Parameter(Mandatory = $false)]
    [System.Nullable[System.DateTime]] $StartDate,
    [System.Nullable[System.DateTime]] $EndDate,
    [string] $Mailbox,
    [string] $Subject,
    [string] $UserName,
    [string] $Password
)

Function Connect_Exo {
    # Check if EXO V2 module is installed
    $Module = Get-Module -Name ExchangeOnlineManagement -ListAvailable
    if (-not $Module) {
        Write-Host "EXO V2 module is not installed." -ForegroundColor Yellow
        $Confirm = Read-Host "Do you want to install the EXO V2 module? [Y/N]"
        if ($Confirm -eq 'Y') {
            Write-Host "Installing Exchange Online PowerShell V2 module..."
            Install-Module -Name ExchangeOnlineManagement -Repository PSGallery -AllowClobber -Force
        } else {
            Write-Host "The EXO V2 module is required. Please install it manually." -ForegroundColor Red
            exit
        }
    }
    Write-Host "Connecting to Exchange Online..."
    if ($UserName -and $Password) {
        $SecuredPassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
        $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserName, $SecuredPassword
        Connect-ExchangeOnline -Credential $Credential
    } else {
        Connect-ExchangeOnline
    }
}

Function Validate_Date {
    param(
        [Parameter(Mandatory = $true)]
        [string] $DateType
    )
    $dateInput = $null
    while ($true) {
        $dateInput = Read-Host "Enter $DateType date (MM/DD/YYYY)"
        try {
            $date = [DateTime]::ParseExact($dateInput, 'MM/dd/yyyy', $null)
            return $date
        } catch {
            Write-Host "Invalid date format. Please use MM/DD/YYYY." -ForegroundColor Red
        }
    }
}

# Validate Start and End Dates
$MaxStartDate = (Get-Date).AddDays(-89).Date
if (-not $StartDate) {
    $StartDate = Validate_Date -DateType "start"
}
if (-not $EndDate) {
    $EndDate = Validate_Date -DateType "end"
}

# Ensure Start Date is not too far in the past
if ($StartDate -lt $MaxStartDate) {
    Write-Host "Start date must be within the last 90 days." -ForegroundColor Red
    exit
}

# Ensure End Date is not before Start Date
if ($EndDate -lt $StartDate) {
    Write-Host "End date must be after start date." -ForegroundColor Red
    exit
}

Connect_Exo

# Setup for the audit query
$OutputCSV = "C:\temp\DeletedEmailsAuditReport_$((Get-Date -Format 'yyyy-MMM-dd-ddd hh-mm tt').ToString()).csv"
if (-not (Test-Path -Path $OutputCSV)) {
    "" | Select-Object 'Activity Time', 'Activity', 'Target Mailbox', 'Performed By', 'No. of Emails Deleted', 'Email Subjects', 'Folder', 'Result Status', 'More Info' |
    Export-Csv -Path $OutputCSV -NoTypeInformation
}

$RetriveOperation = "SoftDelete,HardDelete,MoveToDeletedItems"
$SearchFilter = @{
    StartDate     = $StartDate
    EndDate       = $EndDate
    Operations    = $RetriveOperation
    ResultSize    = 5000
    SessionId     = "Session"
    SessionCommand= "ReturnLargeSet"
}

if ($Mailbox) {
    $SearchFilter["MailboxIds"] = $Mailbox
}

# Retrieve the audit log data
$AuditData = Search-UnifiedAuditLog @SearchFilter
$AuditData | ForEach-Object {
    $AuditDetail = $_.AuditData | ConvertFrom-Json
    $ExportResult = @{
        'Activity Time'        = (Get-Date $_.CreationTime)
        'Activity'             = $_.Operations
        'Target Mailbox'       = $AuditDetail.MailboxOwnerUPN
        'Performed By'         = $AuditDetail.UserId
        'No. of Emails Deleted'= $AuditDetail.AffectedItems.Count
        'Email Subjects'       = $AuditDetail.AffectedItems.Subject -join ", "
        'Folder'               = $AuditDetail.FolderPath
        'Result Status'        = $AuditDetail.ResultStatus
        'More Info'            = $_.AuditData
    }
    $ExportResult | Export-Csv -Path $OutputCSV -Append -NoTypeInformation
}

Write-Host "Audit data has been exported to $OutputCSV" -ForegroundColor Green

# Disconnect from Exchange Online
Disconnect-ExchangeOnline -Confirm:$false -InformationAction Ignore -ErrorAction SilentlyContinue
