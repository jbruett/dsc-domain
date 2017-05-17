#Import the Configuration Script
Import-Module '.\NewDomain\NewDomain.ps1'

#Call The Configuration Script passing in our Configuration Data
Main -OutputPath $ProjectRoot -ConfigurationData '.\NewDomain\ConfigurationData.psd1'

#Create a Zip from the Mof output (Include Modules)
Get-Item -Path "$ProjectRoot\userdata.ps1",
"$ProjectRoot\NewDomain\*.mof",
"$ProjectRoot\xActiveDirectory",
"$ProjectRoot\xTimeZone",
"$ProjectRoot\xNetworking",
"$ProjectRoot\xComputerManagement",
"$ProjectRoot\xPSDesiredStateConfiguration",
"$ProjectRoot\xPSDSCs" | Compress-Archive -DestinationPath $ProjectRoot\DomainMof.zip

#Publish zip as artifact
Push-AppveyorArtifact $ProjectRoot\DomainMof.zip -Verbose

#update