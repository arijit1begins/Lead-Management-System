[xml]$config = Get-Content C:\Users\arda\Desktop\finalLogManagement\Configuration.xml
$logdir = $config.Config.LogDirectory
$Script_Logfile = $config.Config.ScriptLogFilePath
$days = $config.Config.UnzipDays 
$logs = Get-ChildItem -Recurse -Path $logdir -Attributes !Directory -Filter *.txt

Add-Type -AssemblyName "system.io.compression.filesystem"

foreach ($log in $logs)

{

    $name = $log.name #gets the filename
    $directory = $log.DirectoryName #gets the directory name
    $LastWriteTime = $log.LastWriteTime #gets the lastwritetime of the file
    $zipfile = $name.Replace('.log','.zip') #creates the zipped filename
    $source = $directory + "\" + $name
    $destination = $directory + "\" + $zipfile  

    [io.compression.zipfile]::CreateFromDirectory($source,$destination) #zip

    if($LastExitCode -eq 0) #verifies the zip process was successful

    {

        Remove-Item -Path $directory\$name #deletes the original log file
        
        $logtime = Get-Date
        $logtime.ToString() + ': Created zip ' + $directory + '\' + $zipfile + '. Deleted original logfile: ' + $name | Out-File $Script_Logfile -Encoding UTF8 -Append #writes logfile entry

    }

}




