$Timestamp = Get-date -f yyyy_MM_dd-hh-mm-ss
Start-Transcript -Path C:\Userdata_$Timestamp.txt

#Move required modules into PSModulePath
Move-Item 'C:\Windows\Temp\xActiveDirectory', 'C:\Windows\Temp\xPSDesiredStateConfiguration', 'C:\Windows\Temp\xTimeZone', 'C:\Windows\Temp\xNetworking', 'C:\Windows\Temp\xComputerManagement' -Destination 'C:\Program Files\WindowsPowerShell\Modules\'

Function Get-CurrentInstanceTag() {

    #Gets all instance tags for the current instance
    $instanceId = Invoke-WebRequest "http://169.254.169.254/latest/meta-data/instance-id" -UseBasicParsing
    $versionTag = Get-EC2Tag | Where-Object {$Psitem.ResourceId -eq $instanceId} | Select-Object Key, Value
    return $versiontag
}

$CurrentTags = Get-CurrentInstanceTag

#Apply DSC Configuration
Start-DscConfiguration -path C:\windows\temp\ -Verbose -wait -force

#Stop all transcription
Stop-Transcript

#Write transcription to S3
Write-S3Object -BucketName jb2w-powershell-dsc-mofs -File C:\Userdata_$Timestamp.txt