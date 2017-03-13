#Invoke-Command -ComputerName ARDA.fareast.corp.microsoft.com -ScriptBlock {

[xml]$config = Get-Content C:\Users\arda\Desktop\Configuration.xml
$logdir = $config.Config.LogDirectory
$Script_Logfile = $config.Config.ScriptLogFilePath
$days = $config.Config.UnzipDays 


if (-not (Test-Path -Path "$env:ProgramFiles\7-Zip\7z.exe"))  #update path to point to the location of 7-zip

{

    throw "$env:ProgramFiles\7-Zip\7z.exe needed"

}

Set-Alias -Name sz -Value "$env:ProgramFiles\7-Zip\7z.exe"



$logs = Get-ChildItem -Recurse -Path $logdir -Attributes !Directory -Filter *.txt

foreach ($log in $logs)

{

$name = $log.name #gets the filename

$directory = $log.DirectoryName #gets the directory name

$LastWriteTime = $log.LastWriteTime #gets the lastwritetime of the file

$zipfile = $name.Replace('.log','.7z') #creates the zipped filename

sz a -t7z "$directory\$zipfile" "$directory\$name" #runs 7-zip with the provided parameters – name and location of the zip file and the file to zip

if($LastExitCode -eq 0) #verifies the zip process was successful

{

Get-ChildItem $directory -Filter $zipfile | % {$_.LastWriteTime = $LastWriteTime} #sets the LastWriteTime of the zip file to match the original log file

Remove-Item -Path $directory\$name #deletes the original log file

echo $logtime + ': Created zip ' + $directory + '\' + $zipfile + '. Deleted original logfile: ' + $name | Out-File $Script_Logfile -Encoding UTF8 -Append #writes logfile entry

}

}

#}

