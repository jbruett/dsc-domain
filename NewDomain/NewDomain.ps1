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
        [string]$DomainDnsAddress
    )

    Import-DscResource -ModuleName xActiveDirectory, xTimeZone, PSDesiredStateConfiguration, xNetworking, xComputerManagement

    Node $AllNodes.NodeName 
 {
        LocalConfigurationManager {
            ActionAfterReboot = 'ContinueConfiguration'
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }
        
        File ADFiles {
            DestinationPath = 'C:\NTDS'
            Type = 'Directory'
            Ensure = 'Present'
        }
        
        WindowsFeature ADDSInstall {
            Ensure = "Present"
            Name = "AD-Domain-Services"
        }
        
        xTimezone East {
            isSingleinstance = 'yes'
            TimeZone = 'Eastern Standard Time'
        }
    }

    Node $AllNodes.Where{$_.Role -eq 'PrimaryDC'}.NodeName
 {
        # No slash at end of folder paths
        xADDomain FirstDS {
            DomainName = $Node.DomainName
            DomainAdministratorCredential = $domainCred
            SafemodeAdministratorPassword = $safemodeAdministratorCred
            DatabasePath = 'C:\NTDS'
            LogPath = 'C:\NTDS'
            DependsOn = "[WindowsFeature]ADDSInstall", "[File]ADFiles"
        }
    }
    
    Node $AllNodes.Where{$_.Role -ne 'PrimaryDC'}.NodeName {
        xDNSServerAddress dnsoverride {
            InterfaceAlias = 'Ethernet 2'
            AddressFamily = 'IPV4'
            Address = $DomainDnsAddress
            Validate = $true
        }
        
        xComputer DomainJoin {
            Name = $node.NodeName
            DomainName = $Node.DomainName
            Credential = $domainCred
        }
                
        xWaitForADDomain Wait {
            DomainName = $Node.DomainName
            DomainUserCredential = $domainCred
        }
        
        xADDomainController DC {
            DomainName = $Node.DomainName
            DomainAdministratorCredential = $domainCred
            SafemodeAdministratorPassword = $safemodeAdministratorCred
            DatabasePath = 'C:\NTDS'
            LogPath = 'C:\NTDS'
            DependsOn = '[xWaitForADDomain]Wait', '[WindowsFeature]ADDSInstall', '[File]ADFiles'
        }
    }
}

# Configuration Data for AD


NewDomain -ConfigurationData $ConfigData -safemodeAdministratorCred (Get-Credential -UserName '(Password Only)' -Message "New Domain Safe Mode Administrator Password") -domainCred (Get-Credential -UserName contoso\administrator -Message "New Domain Admin Credential") -DomainDnsAddress '10.0.8.5'

# Make sure that LCM is set to continue configuration after reboot
Set-DSCLocalConfigurationManager -Path .\NewDomain –Verbose
            
# Build the domain            
Start-DscConfiguration -Wait -Force -Path .\NewDomain -Verbose