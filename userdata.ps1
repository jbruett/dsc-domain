$Timestamp = Get-date -f yyyy_MM_dd-hh-mm-ss
Start-Transcript -Path C:\Userdata_$Timestamp.txt

#Move required modules into PSModulePath
Move-Item C:\windows\temp\cChoco\, C:\windows\temp\xPSDesiredStateConfiguration\ -Destination 'C:\Program Files\WindowsPowerShell\Modules\'

Function Get-CurrentInstanceTag() {

    #Gets all instance tags for the current instance
    $instanceId = Invoke-WebRequest "http://169.254.169.254/latest/meta-data/instance-id" -UseBasicParsing
    $versionTag = Get-EC2Tag | Where-Object {$Psitem.ResourceId -eq $instanceId} | Select-Object Key, Value
    return $versiontag
}

$CurrentTags = Get-CurrentInstanceTag

#Temp <== remove this line later and change it with getting own tag etc
Rename-Item C:\windows\temp\NewDomain.mof -NewName localhost.mof

#Apply DSC Configuration
Start-DscConfiguration -path C:\windows\temp\ -Verbose -wait -force -ComputerName localhost

#Stop all transcription
Stop-Transcript

#Write transcription to S3
Write-S3Object -BucketName jb2w-powershell-dsc-mofs -File C:\Userdata_$Timestamp.txt