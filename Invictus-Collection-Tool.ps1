#Microsoft Graph Auhentication Script
Connect-AzAccount

$tenantId = (Get-AzContext).Tenant.Id

if (-not $tenantId) {
    Write-Host "Error: Unable to retrieve Tenant ID." -ForegroundColor Red
    exit 1
}
Write-Host "Using Tenant ID: $tenantId"

$appName = "MyCustomApp"
$app = Get-AzADApplication -DisplayName $appName  
if (-not $app) {
    Write-Host "Error: Unable to retrieve App for '$appName'." -ForegroundColor Red
    exit 1
}

$appId = $app.AppId
Write-Host "Found App ID: $appId for application '$appName'"

Connect-AzureAD -TenantId $tenantId

Start-Sleep -Seconds 10

# Create a new password credential
$pwdCred = New-AzureADApplicationPasswordCredential -ObjectId $app.Id
$clientSecret = $pwdCred.Value

if (-not $clientSecret) {
    Write-Host "Error: Failed to reset client secret." -ForegroundColor Red
    exit 1
}

Write-Host "Client secret reset successfully. This is necessary for reauthentication."
Write-Host "New Client Secret: $clientSecret"

Start-Sleep -Seconds 20

$ApplicationClientId     = $appId
$ApplicationClientSecret = $clientSecret
$SecureClientSecret      = ConvertTo-SecureString -String $clientSecret -AsPlainText -Force
$ClientSecretCredential  = New-Object -TypeName System.Management.Automation.PSCredential `
    -ArgumentList $ApplicationClientId, $SecureClientSecret

Start-Sleep -Seconds 5

Connect-MgGraph -TenantId $tenantId -ClientSecretCredential $ClientSecretCredential





########################################################################################################

# Ask for the mounted shared folder drive
$SharedDrive = Read-Host -Prompt "Enter the drive letter for the mounted shared folder (e.g., Z:)"
Write-Host "Shared drive set to: $SharedDrive" -ForegroundColor Green

# Define the Evidence folder path
$EvidencePath = "$SharedDrive\Evidence"
Write-Host "Evidence folder path: $EvidencePath" -ForegroundColor Green

# Create a new folder for the output
$OutputFolder = "$EvidencePath\$(Get-Date -Format 'yyyyMMdd_HHmmss')"
New-Item -ItemType Directory -Path $OutputFolder | Out-Null
Write-Host "Created output folder: $OutputFolder" -ForegroundColor Green

# Authenticate to Microsoft services
Write-Host "Authenticating to Microsoft services..." -ForegroundColor Yellow|

# Unblock all files in the directory
Get-ChildItem -Path "$PWD" -Recurse | ForEach-Object {
    if ($_.Attributes -match 'ReadOnly') { $_.Attributes = 'Normal' }
    Unblock-File -Path $_.FullName
}

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

Import-Module .\Microsoft-Extractor-Suite.psd1

Start-Sleep -Seconds 3
Connect-M365
Start-Sleep -Seconds 3
Connect-Azure
Start-Sleep -Seconds 3


Write-Host "Authentication complete." -ForegroundColor Green



Do {
    # Ask the user for the collection type
    Do {
        $CollectionTypeInput = Read-Host -Prompt "Enter collection type:`n1 for Triage Package`n2 for Comprehensive Log Collection Less Than 5000 Users`n3 for Comprehensive Log Collection Greater Than 5000 Users`n4 for Individual User Log Collection`n5 for IOC Search`nSelection"
        if ($CollectionTypeInput -eq "1") {
            $CollectionType = "triage"
        } elseif ($CollectionTypeInput -eq "4") {
            $CollectionType = "individual_log"
        } elseif ($CollectionTypeInput -eq "5") {
            $CollectionType = "ioc_search"
        } elseif ($CollectionTypeInput -eq "2") {
            $CollectionType = "Comprehensive_Log_Collection_LessThan5000_Users"
        } elseif ($CollectionTypeInput -eq "3") {
            $CollectionType = "Comprehensive_Log_Collection_GreaterThan5000_Users"
        } else {
            Write-Host "Invalid input. Please enter a value 1-5." -ForegroundColor Red
        }
    } while ($null -eq $CollectionType)


    # Perform actions based on collection type

##############################################################################################

if ($CollectionType -eq "triage") {
    Write-Host "Starting triage collection..." -ForegroundColor Yellow
    
    # Basic tenant information collection for Triage
    Write-Host "Collecting tenant user information..." -ForegroundColor Blue
    Get-Users -OutputDir $OutputFolder

    Write-Host "Collecting tenant admin user information..." -ForegroundColor Blue
    Get-AdminUsers -OutputDir $OutputFolder

    Write-Host "Collecting Multi-Factor Authentication (MFA) configurations..." -ForegroundColor Blue
    Get-MFA -OutputDir $OutputFolder

    Write-Host "Collecting conditional access policies..." -ForegroundColor Blue
    Get-ConditionalAccessPolicies -OutputDir $OutputFolder

    Write-Host "Collecting mailbox client configurations..." -ForegroundColor Blue
    Get-CasMailbox -ResultSize Unlimited |
        Select-Object PrimarySmtpAddress, ActiveSyncEnabled, OWAEnabled, OWAForDevicesEnabled, PopEnabled, ImapEnabled, MAPIEnabled |
        Export-Csv -Path "$OutputFolder\MailClients.csv" -NoTypeInformation

    # Triage-specific collections
    Write-Host "Collecting risky user data..." -ForegroundColor Blue
    Get-RiskyUsers -OutputDir $OutputFolder

    Write-Host "Collecting risky sign-in detections..." -ForegroundColor Blue
    Get-RiskyDetections -OutputDir $OutputFolder

    Write-Host "Collecting mailbox rules..." -ForegroundColor Blue
    Get-MailboxRules -OutputDir $OutputFolder

    Write-Host "Collecting transport rules..." -ForegroundColor Blue
    Get-TransportRules -OutputDir $OutputFolder

    Write-Host "Triage collection complete." -ForegroundColor Green

##############################################################################################

    }  elseif ($CollectionType -eq "Comprehensive_Log_Collection_LessThan5000_Users") {
    Write-Host "Starting comprehensive log collection for less than 5000 users..." -ForegroundColor Yellow

    # Basic tenant information collection for Triage
    Write-Host "Collecting tenant user information..." -ForegroundColor Blue
    Get-Users -OutputDir $OutputFolder

    Write-Host "Collecting tenant admin user information..." -ForegroundColor Blue
    Get-AdminUsers -OutputDir $OutputFolder

    Write-Host "Collecting Multi-Factor Authentication (MFA) configurations..." -ForegroundColor Blue
    Get-MFA -OutputDir $OutputFolder

    Write-Host "Collecting conditional access policies..." -ForegroundColor Blue
    Get-ConditionalAccessPolicies -OutputDir $OutputFolder

    Write-Host "Collecting mailbox client configurations..." -ForegroundColor Blue
    Get-CasMailbox -ResultSize Unlimited |
        Select-Object PrimarySmtpAddress, ActiveSyncEnabled, OWAEnabled, OWAForDevicesEnabled, PopEnabled, ImapEnabled, MAPIEnabled |
        Export-Csv -Path "$OutputFolder\MailClients.csv" -NoTypeInformation

    # Triage-specific collections
    Write-Host "Collecting risky user data..." -ForegroundColor Blue
    Get-RiskyUsers -OutputDir $OutputFolder

    Write-Host "Collecting risky sign-in detections..." -ForegroundColor Blue
    Get-RiskyDetections -OutputDir $OutputFolder

    Write-Host "Collecting mailbox rules..." -ForegroundColor Blue
    Get-MailboxRules -OutputDir $OutputFolder

    Write-Host "Collecting transport rules..." -ForegroundColor Blue
    Get-TransportRules -OutputDir $OutputFolder

    # Additional Logging Not in Triage Collection
    Write-Host "Collecting Unified Audit Logs (UAL)..." -ForegroundColor Blue
    Get-UALAll -OutputDir $OutputFolder

    Write-Host "Collecting admin audit logs..." -ForegroundColor Blue
    Get-AdminAuditLog -OutputDir $OutputFolder

    Write-Host "Collecting general activity logs..." -ForegroundColor Blue
    Get-ActivityLogs -OutputDir $OutputFolder

    Write-Host "Collecting Active Directory (AD) audit logs..." -ForegroundColor Blue
    Get-ADAuditLogs -MergeOutput -OutputDir $OutputFolder

    Write-Host "Collecting Active Directory (AD) sign-in logs..." -ForegroundColor Blue
    Get-ADSignInLogs -MergeOutput -OutputDir $OutputFolder

    Write-Host "Comprehensive log collection for less than 5000 users complete." -ForegroundColor Green


##############################################################################################

        
    }  elseif ($CollectionType -eq "Comprehensive_Log_Collection_GreaterThan5000_Users") {
    Write-Host "Starting comprehensive log collection for greater than 5000 users..." -ForegroundColor Yellow

    # Basic tenant information collection for Triage
    Write-Host "Collecting tenant user information..." -ForegroundColor Blue
    Get-Users -OutputDir $OutputFolder

    Write-Host "Collecting tenant admin user information..." -ForegroundColor Blue
    Get-AdminUsers -OutputDir $OutputFolder

    Write-Host "Collecting Multi-Factor Authentication (MFA) configurations..." -ForegroundColor Blue
    Get-MFA -OutputDir $OutputFolder

    Write-Host "Collecting conditional access policies..." -ForegroundColor Blue
    Get-ConditionalAccessPolicies -OutputDir $OutputFolder

    Write-Host "Collecting mailbox client configurations..." -ForegroundColor Blue
    Get-CasMailbox -ResultSize Unlimited |
        Select-Object PrimarySmtpAddress, ActiveSyncEnabled, OWAEnabled, OWAForDevicesEnabled, PopEnabled, ImapEnabled, MAPIEnabled |
        Export-Csv -Path "$OutputFolder\MailClients.csv" -NoTypeInformation

    # Triage-specific collections
    Write-Host "Collecting risky user data..." -ForegroundColor Blue
    Get-RiskyUsers -OutputDir $OutputFolder

    Write-Host "Collecting risky sign-in detections..." -ForegroundColor Blue
    Get-RiskyDetections -OutputDir $OutputFolder

    Write-Host "Collecting mailbox rules..." -ForegroundColor Blue
    Get-MailboxRules -OutputDir $OutputFolder

    Write-Host "Collecting transport rules..." -ForegroundColor Blue
    Get-TransportRules -OutputDir $OutputFolder

    # Additional Logging Not in Triage Collection
    Write-Host "Collecting admin audit logs..." -ForegroundColor Blue
    Get-AdminAuditLog -OutputDir $OutputFolder

    Write-Host "Collecting general activity logs..." -ForegroundColor Blue
    Get-ActivityLogs -OutputDir $OutputFolder

    Write-Host "Collecting Active Directory (AD) audit logs..." -ForegroundColor Blue
    Get-ADAuditLogs -MergeOutput -OutputDir $OutputFolder

    Write-Host "Collecting Active Directory (AD) sign-in logs..." -ForegroundColor Blue
    Get-ADSignInLogs -MergeOutput -OutputDir $OutputFolder

    # Limited UAL Logging
    Write-Host "Collecting limited Unified Audit Logs (UAL) based on activity types..."
    $ActivityTypes = @(
        "UserLoggedIn",
        "MailboxLogin",
        "New-InboxRule",
        "Set-InboxRule",
        "Change user password.",
        "Reset user password.",
        "Add application.",
        "Update user.",
        "CreatedFlow",
        "EditedFlow"
    )

    foreach ($ActivityType in $ActivityTypes) {
        Write-Host "Collecting UAL data for activity type: $ActivityType..." -ForegroundColor Blue
        Get-UALSpecificActivity -MergeOutput -ActivityType $ActivityType -OutputDir $OutputFolder
    }

    Write-Host "Comprehensive log collection for greater than 5000 users complete." -ForegroundColor Green


                                                    
##############################################################################################


    } elseif ($CollectionType -eq "individual_log") {
    Write-Host "Starting individual user log collection..." -ForegroundColor Yellow
    Write-Host "The script will read a list of emails from a file called users.txt in the current working directory."


    while ($true) {
        $UserListPath = Join-Path (Get-Location) "users.txt"
    
        if (Test-Path $UserListPath) {
            Write-Host "`nFound users.txt at: $UserListPath"
            break  
                                      }
        else {
            Write-Host "`nError: users.txt not found in the current directory." -ForegroundColor Red
            $userChoice = Read-Host "Press Enter after placing 'users.txt' here, or type 'Q' to quit"
        
            if ($userChoice -eq 'Q') {
             Write-Host "Exiting script..."
             exit
                                    }
               }
                     }

    $Users = Get-Content -Path $UserListPath
    foreach ($User in $Users) {
        Write-Host "Processing logs for user: $User" -ForegroundColor Cyan

        # Collect mailbox audit logs
        Write-Host "Collecting mailbox audit logs for $User..." -ForegroundColor Blue
        Get-MailboxAuditLog -UserIds $User -OutputDir $OutputFolder

        # Collect mailbox rules
        Write-Host "Collecting mailbox rules for $User..." -ForegroundColor Blue
        Get-MailboxRules -UserIds $User -OutputDir $OutputFolder

        # Collect AD sign-in logs
        Write-Host "Collecting Active Directory (AD) sign-in logs for $User..." -ForegroundColor Blue
        Get-ADSignInLogs -UserIds $User -OutputDir $OutputFolder

        # Collect AD audit logs
        Write-Host "Collecting Active Directory (AD) audit logs for $User..." -ForegroundColor Blue
        Get-ADAuditLogs -UserIds $User -OutputDir $OutputFolder

        # Export mailbox permissions
        Write-Host "Exporting mailbox permissions for $User..." -ForegroundColor Blue
        Get-Mailbox -ResultSize Unlimited | Get-MailboxPermission -User $User |
            Select-Object Identity, User, AccessRights |
            Export-Csv "$OutputFolder\${User}_MailboxAccess.csv" -NoTypeInformation
        Write-Host "Exporting access permissions for $User..."
        Get-MailboxPermission -Identity $User |
            Select-Object Identity, User, AccessRights |
            Export-Csv "$OutputFolder\${User}_AccessToUserAccount.csv" -NoTypeInformation

        # Prompt for and validate Start/End Dates for Historical Search
        Write-Host "Prompting for start and end dates for historical search for $User..."
        do {
            $StartDateInput = Read-Host "Enter start date (e.g., 2023-01-01)"
            $EndDateInput = Read-Host "Enter end date (e.g., 2023-03-01)"

            try {
                $StartDate = [datetime]::ParseExact($StartDateInput, 'yyyy-MM-dd', $null)
                $EndDate = [datetime]::ParseExact($EndDateInput, 'yyyy-MM-dd', $null)
            } catch {
                Write-Host "Invalid date format. Please enter dates in YYYY-MM-DD format." -ForegroundColor Red
                $StartDate = $null
                $EndDate = $null
                continue
            }

            $CurrentDate = Get-Date

            if ($EndDate -lt $StartDate) {
                Write-Host "Error: End date cannot be earlier than start date." -ForegroundColor Red
                $StartDate = $null
                $EndDate = $null
            } elseif (($CurrentDate - $StartDate).Days -gt 90 -or ($CurrentDate - $EndDate).Days -gt 90) {
                Write-Host "Error: Start and end dates must be within the last 90 days." -ForegroundColor Red
                $StartDate = $null
                $EndDate = $null
            }
        } while (-not $StartDate -or -not $EndDate)

        # Run Historical Search
        Write-Host "Running historical search for outgoing messages for $User..." -ForegroundColor Blue
        Start-HistoricalSearch -ReportTitle "${User}_Outgoing" -ReportType MessageTrace -SenderAddress $User -StartDate $StartDate -EndDate $EndDate

        Write-Host "Running historical search for incoming messages for $User..." -ForegroundColor Blue
        Start-HistoricalSearch -ReportTitle "${User}_Incoming" -ReportType MessageTrace -RecipientAddress $User -StartDate $StartDate -EndDate $EndDate
    }

    Write-Host "Individual user log collection complete." -ForegroundColor Green


##############################################################################################
        
    } elseif ($CollectionType -eq "ioc_search") {
    Write-Host "Starting IOC (Indicator of Compromise) search..." -ForegroundColor Yellow

    # Prompt user for IP or User Search
    $IOCType = Read-Host -Prompt "Enter 1 for IP Search or 2 for User Search"
    if ($IOCType -eq "1") {
        # IP Search
        Write-Host "You selected IP Search." -ForegroundColor Cyan
        $SearchName = Read-Host -Prompt "Enter the search name"
        $IPAddress = Read-Host -Prompt "Enter the IP address to search"
        Write-Host "Performing IOC search for IP address: $IPAddress with search name: $SearchName..." -ForegroundColor Yellow
        Get-UALGraph -SearchName $SearchName -IPAddress $IPAddress -OutputDir $OutputFolder
        Write-Host "IP search completed. Results saved to: $OutputFolder" -ForegroundColor Green

    } elseif ($IOCType -eq "2") {
        # User Search
        Write-Host "You selected User Search." -ForegroundColor Cyan
        $SearchName = Read-Host -Prompt "Enter the search name"
        $UserEmail = Read-Host -Prompt "Enter the user email to search"
        Write-Host "Performing IOC search for user email: $UserEmail with search name: $SearchName..." -ForegroundColor Yellow
        Get-UALGraph -SearchName $SearchName -UserIds $UserEmail -OutputDir $OutputFolder
        Write-Host "User search completed. Results saved to: $OutputFolder" -ForegroundColor Green

    } else {
        Write-Host "Invalid input. Please enter 1 for IP Search or 2 for User Search." -ForegroundColor Red
    }

    Write-Host "IOC search process complete." -ForegroundColor Green
}


    # Prompt to do another collection
do {
        $DoAnother = Read-Host -Prompt "Do you want to perform another collection? (yes/no)"
            
        if ($DoAnother.ToLower() -ne "yes" -and $DoAnother.ToLower() -ne "no") {
            Write-Host "Invalid input. Please enter 'yes' or 'no'." -ForegroundColor Red
                                                                                }
    } while ($DoAnother.ToLower() -ne "yes" -and $DoAnother.ToLower() -ne "no")

    Write-Host "User selected to perform another collection: $DoAnother" -ForegroundColor Cyan
} while ($DoAnother -eq "yes")
