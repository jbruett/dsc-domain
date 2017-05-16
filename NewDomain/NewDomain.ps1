configuration NewDomain {
    param
    (
        # PSCredential for Safe Mode Administrator Password (password only)
        [parameter(Mandatory)]
        [pscredential]$SafeModeAdministratorCred,
        # PSCredential for the domain administrator (password only)
        [Parameter(Mandatory)]
        [pscredential]$DomainCred,
        # IP Address of a dns server in the domain, not needed for primary domain controller.
        [Parameter()]
        [string[]]$DomainDnsAddress
    )

    Import-DscResource -ModuleName xActiveDirectory, xTimeZone, PSDesiredStateConfiguration, xNetworking, xComputerManagement

    Node $AllNodes.NodeName 
    {
        LocalConfigurationManager {
            ActionAfterReboot  = 'ContinueConfiguration'
            ConfigurationMode  = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }
        
        File ADFiles {
            DestinationPath = 'C:\NTDS'
            Type            = 'Directory'
            Ensure          = 'Present'
        }
        
        WindowsFeature ADDSInstall {
            Ensure = "Present"
            Name   = "AD-Domain-Services"
        }
        
        xTimezone East {
            isSingleinstance = 'yes'
            TimeZone         = 'Eastern Standard Time'
        }
    }

    Node $AllNodes.Where{$_.Role -eq 'PrimaryDC'}.NodeName
    {
        # No slash at end of folder paths
        xADDomain FirstDS {
            DomainName                    = $Node.DomainName
            DomainAdministratorCredential = $domainCred
            SafemodeAdministratorPassword = $SafemodeAdministratorCred
            DatabasePath                  = 'C:\NTDS'
            LogPath                       = 'C:\NTDS'
            DependsOn                     = "[WindowsFeature]ADDSInstall", "[File]ADFiles"
        }
    }
    
    Node $AllNodes.Where{$_.Role -ne 'PrimaryDC'}.NodeName {
        xDNSServerAddress dnsoverride {
            InterfaceAlias = 'Ethernet 2'
            AddressFamily  = 'IPV4'
            Address        = $DomainDnsAddress
            Validate       = $true
        }
        
        xComputer DomainJoin {
            Name       = $node.NodeName
            DomainName = $Node.DomainName
            Credential = $domainCred
        }
                
        xWaitForADDomain Wait {
            DomainName           = $Node.DomainName
            DomainUserCredential = $domainCred
        }
        
        xADDomainController DC {
            DomainName                    = $Node.DomainName
            DomainAdministratorCredential = $domainCred
            SafemodeAdministratorPassword = $SafemodeAdministratorCred
            DatabasePath                  = 'C:\NTDS'
            LogPath                       = 'C:\NTDS'
            DependsOn                     = '[xWaitForADDomain]Wait', '[WindowsFeature]ADDSInstall', '[File]ADFiles'
        }
    }
}

# Configuration Data for AD

$SafemodeCred = New-Object -TypeName pscredential -argumentlist "null", (Convertto-securestring -String $env:safemode_password -AsPlainText -Force)
$DomainCred = New-Object -TypeName pscredential -ArgumentList "contoso\administrator", (ConvertTo-SecureString -String $env:domain_password -AsPlainText -Force)

NewDomain -ConfigurationData $ConfigData -SafemodeAdministratorCred $SafemodeCred -domainCred $DomainCred -DomainDnsAddress '10.0.8.5', '8.8.4.4'

# Make sure that LCM is set to continue configuration after reboot
Set-DSCLocalConfigurationManager -Path .\NewDomain -Verbose

# Build the domain
Start-DscConfiguration -Wait -Force -Path .\NewDomain -Verbose