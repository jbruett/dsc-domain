$Timestamp = Get-date -f yyyy_MM_dd-hh-mm-ss
Start-Transcript -Path C:\Userdata_$Timestamp.txt

#Move required modules into PSModulePath
Move-Item 'C:\Windows\Temp\xActiveDirectory', 'C:\Windows\Temp\xPSDesiredStateConfiguration', 'C:\Windows\Temp\xTimeZone', 'C:\Windows\Temp\xNetworking', 'C:\Windows\Temp\xComputerManagement' -Destination 'C:\Program Files\WindowsPowerShell\Modules\'

$instanceId = (Invoke-WebRequest "http://169.254.169.254/latest/meta-data/instance-id" -UseBasicParsing).content
#$ipaddress = get-netadapter | where-object -Property status -eq -value 'up' | select -first 1  | get-netipaddress -AddressFamily IPv4 | Select-Object -ExpandProperty ipaddress

$tags = get-ec2tag -Filter @{name = 'resource-id'; value = $instanceId} | select-object key, value

#Get servername and role from name tag
$servername = [string]::empty
$role_name = [string]::empty

for ($i = 0; $i -lt $tags.length; $i++) {
    if ($tags[$i].key -eq 'Name') {
        $servername = $tags[$i].value
    }
    if ($tags[$i].key -eq 'role') {
        $role_name = $tags[$i].value
    }
}

#Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value "$env:computername,$servername" -force
#add-content -path 'c:\windows\system32\drivers\etc\hosts' -value "$ipaddress $env:computername $servername"

if ($role_name -ne [string]::empty) {
    Rename-Item C:\windows\temp\$($role_name).mof -NewName localhost.mof
    Rename-Item C:\windows\temp\$($role_name).meta.mof -NewName localhost.meta.mof
}

#Apply DSC Configuration
Start-DscConfiguration -path C:\windows\temp\ -Verbose -wait -force -computername localhost

#Stop all transcription
Stop-Transcript

#Write transcription to S3
Write-S3Object -BucketName jb2w-powershell-dsc-mofs -File C:\Userdata_$Timestamp.txt