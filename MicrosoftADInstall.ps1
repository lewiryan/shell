<#
.SYNOPSIS
    Automates creation of a new Active Directory forest with DNS on Windows Server 2025.

.DESCRIPTION
    - Installs AD DS and DNS roles
    - Promotes server as domain controller
    - Creates forest and sets domain/forest mode to Windows Server 2025
    - Requires Administrator privileges
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
    -DomainMode Windows2025Domain `
    -ForestMode Windows2025Forest `
    -DatabasePath $DatabasePath `
    -LogPath $LogPath `
    -SysvolPath $SysvolPath `
    -InstallDns:$true `
    -SafeModeAdministratorPassword $SafeModePwd `
    -Force:$true
