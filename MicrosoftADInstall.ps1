<#
.SYNOPSIS
    Automates creation of a new Active Directory forest with DNS on Windows Server 2025.

.DESCRIPTION
    - Installs AD DS and DNS roles
    - Promotes server as domain controller
    - Creates forest and sets domain/forest mode to Windows Server 2025
    - Requires Administrator privileges

    Windows Server Domain and Forest Functional Levels (excluding Win2025):

Windows Server 2003:
  - Numeric: 2
  - String: Win2003

Windows Server 2008:
  - Numeric: 3
  - String: Win2008

Windows Server 2008 R2:
  - Numeric: 4
  - String: Win2008R2

Windows Server 2012:
  - Numeric: 5
  - String: Win2012

Windows Server 2012 R2:
  - Numeric: 6
  - String: Win2012R2

Windows Server 2016:
  - Numeric: 7
  - String: WinThreshold

Windows Server 2025:
  - Numeric: 10
  - String: Win2025

#>



#---------------------#
# Configuration Block #
#---------------------#
$DomainName = "corp.example.com"         # FQDN of the new domain
$NetBIOSName = "CORP"                    # NetBIOS name of the domain
$DatabasePath = "C:\Windows\NTDS"
$LogPath = "C:\Windows\NTDS"
$SysvolPath = "C:\Windows\SYSVOL"

#---------------------------#
# Prompt for Safe Mode Pass #
#---------------------------#
$SafeModePwd = Read-Host -Prompt "Enter DSRM (Directory Services Restore Mode) password" -AsSecureString

#-------------------------#
# Install Required Roles  #
#-------------------------#
Write-Host "`n[+] Installing AD DS and DNS roles..." -ForegroundColor Cyan
Install-WindowsFeature AD-Domain-Services, DNS -IncludeManagementTools

#-----------------------------#
# Promote Server to DC       #
#-----------------------------#
Write-Host "`n[+] Promoting server to domain controller for '$DomainName'..." -ForegroundColor Cyan
Install-ADDSForest `
    -DomainName $DomainName `
    -DomainNetbiosName $NetBIOSName `
    -DomainMode Win2025 `
    -ForestMode Win2025 `
    -DatabasePath $DatabasePath `
    -LogPath $LogPath `
    -SysvolPath $SysvolPath `
    -InstallDns:$true `
    -SafeModeAdministratorPassword $SafeModePwd `
    -Force:$true
