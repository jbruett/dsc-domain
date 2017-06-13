$Timestamp = Get-date -f yyyy_MM_dd-hh-mm-ss
Start-Transcript -Path C:\Userdata_$Timestamp.txt

#Move required modules into PSModulePath
Move-Item 'C:\Windows\Temp\xActiveDirectory', 'C:\Windows\Temp\xPSDesiredStateConfiguration', 'C:\Windows\Temp\xTimeZone', 'C:\Windows\Temp\xNetworking', 'C:\Windows\Temp\xComputerManagement' -Destination 'C:\Program Files\WindowsPowerShell\Modules\'

$instanceId = (Invoke-WebRequest "http://169.254.169.254/latest/meta-data/instance-id" -UseBasicParsing).content
$tags = get-ec2tag -Filter @{name = 'resource-id'; value = $instanceId} | select-object key, value

#Get servername from name tag
$servername = [string]::empty
for ($i = 0; $i -lt $tags.length; $i++) {
    if ($tags[$i].key -eq 'Name') {
        $i; $servername = $tags[$i].value
    }
}

invoke-command -scriptblock {winrm set winrm/config/client @{TrustedHosts = "$env:computername;$servername"}}

#Apply DSC Configuration
Start-DscConfiguration -path C:\windows\temp\ -Verbose -wait -force

#Stop all transcription
Stop-Transcript

#Write transcription to S3
Write-S3Object -BucketName jb2w-powershell-dsc-mofs -File C:\Userdata_$Timestamp.txt