#Install the Nuget Package Provider to work with the PSGallery.
Install-PackageProvider Nuget -ForceBootstrap -Force

#Ensure the Repository is trusted.
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

#Install Any modules we need for our DSC Configuration and/or testing.
Install-Module Pester, PsScriptAnalyzer, xPSDesiredStateConfiguration, xActiveDirectory, xTimeZone, xNetworking, xComputerManagement -Force

#Copy the Installed Modules into the Output path for later on when we zip the contents
Copy-Item 'C:\Program Files\WindowsPowerShell\Modules\xActiveDirectory', 'C:\Program Files\WindowsPowerShell\Modules\xPSDesiredStateConfiguration', 'C:\Program Files\WindowsPowerShell\Modules\xTimeZone', 'C:\Program Files\WindowsPowerShell\Modules\xNetworking', 'C:\Program Files\WindowsPowerShell\Modules\xComputerManagement' -Recurse -Destination $ProjectRoot
