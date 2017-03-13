[xml]$deployinfo = Get-Content C:\Users\arda\Desktop\finalLogManagement\DeployConfig.xml
$list_webbox = $deployinfo.DeployConfig.Webboxes.Webbox
$source_code_path = $deployinfo.DeployConfig.sourcecodepath

foreach($webbox in $list_webbox) {
    echo hi!!
    
    if(Test-Connection -Cn $webbox.Name -Quiet) {
        $webbox_name = $webbox.Name
        $dest_path = $webbox.Destination
        if (Test-Path -Path "\\$webbox_name\$dest_path\finalLogManagement") #update path to point to the location of 7-zip

        {

            echo "\\$webbox_name\$dest_path Already exists"
            continue

        }
        Try {
            Copy-Item $source_code_path -Destination \\$webbox_name\$dest_path -Recurse
            $date = Get-Date
            $date.ToString() + " Item: " + $source_code_path + " copied to " + $webbox_name + " at location : " + $dest_path | Out-File -FilePath "C:\Users\arda\Desktop\finalLogManagement\DeployLog.txt" -Encoding utf8 -Append
            }
        Catch {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            
            $date = Get-Date
            $date.ToString() + $ErrorMessage + $FailedItem | Out-File -FilePath "C:\Users\arda\Desktop\finalLogManagement\DeployLog.txt" -Encoding utf8 -Append
            }
            
     }else {
            $webbox.Name + ": Not online" | Out-File -FilePath "C:\Users\arda\Desktop\finalLogManagement\DeployLog.txt" -Encoding utf8 -Append
     }
}

###Powershell Task Scheduler##-------------""--------->>>>>>>>>>>>>>
#                                         ----**********######

Function CreateScheduledTaskFolder ($TASKPATH)
{
    $ERRORACTIONPREFERENCE = "stop"
    $SCHEDULE_OBJECT = New-Object -ComObject schedule.service
    $SCHEDULE_OBJECT.connect()
    $ROOT = $SCHEDULE_OBJECT.GetFolder("\")
    Try {$null = $SCHEDULE_OBJECT.GetFolder($TASKPATH)}
    Catch { $null = $ROOT.CreateFolder($TASKPATH) }
    Finally { $ERRORACTIONPREFERENCE = "continue" }
 
}

Function CreateScheduledTask ($TASKNAME, $TASKPATH, $TASKDESCRIPTION, $SCRIPT)
{
    $ACTION = New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument "-File $SCRIPT"
    $TRIGGER =  New-ScheduledTaskTrigger -Daily -At 9:30am
    Register-ScheduledTask -Action $ACTION -Trigger $TRIGGER -TaskName $TASKNAME -Description "$TASKDESCRIPTION" -TaskPath $TASKPATH -RunLevel Highest

    $logtime = Get-Date
    $logtime.ToString() + "Created Scehduled Task: " + $TASKNAME | Out-File -FilePath "C:\Users\arda\Desktop\finalLogManagement\DeployLog.txt" -Encoding utf8 -Append
}

Function ConfigureScheduledTaskSettings ($TASKNAME, $TASKPATH)
{
    $SETTINGS = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Hidden -RestartCount 3
    Set-ScheduledTask -TaskName $TASKNAME -Settings $SETTINGS -TaskPath $TASKPATH 
    $logtime.ToString() + "Configured Scehduled Task settings: " + $TASKNAME | Out-File -FilePath "C:\Users\arda\Desktop\finalLogManagement\DeployLog.txt" -Encoding utf8 -Append
}



#Schedule task path
$scheduleTaskPath = "LogManagement"
CreateScheduledTaskFolder $scheduleTaskName $scheduleTaskPath

###############Zipping Logs###########################

#Schedule task name
$scheduleTaskName = "ZippingLogs"
#Script to schedule
$Script = "C:\Users\arda\Desktop\finalLogManagement\Filezip.ps1"
CreateScheduledTask $scheduleTaskName $scheduleTaskPath "Zipping Log Files---Refer. Configuration.xml for details" $Script | Out-Null
ConfigureScheduledTaskSettings $scheduleTaskName $scheduleTaskPath | Out-Null

##############Archiving Zipped Logs####################
#Schedule task name
$scheduleTaskName = "ArchivedZippedLogs"
#Script to schedule
$Script = "C:\Users\arda\Desktop\finalLogManagement\ziplogarchive.ps1"
CreateScheduledTask $scheduleTaskName $scheduleTaskPath "Moving old zipped files to archive---Refer. Configuration.xml for details" $Script | Out-Null
ConfigureScheduledTaskSettings $scheduleTaskName $scheduleTaskPath | Out-Null

##############Removing Old Archived Zips################
#Schedule task name
$scheduleTaskName = "RemoveOldArchivedZippedLogs"
#Script to schedule
$Script = "C:\Users\arda\Desktop\finalLogManagement\samplescript.ps1"
CreateScheduledTask $scheduleTaskName $scheduleTaskPath "Removes old archived and zipped files permanently---Refer. Configuration.xml for details" $Script | Out-Null
ConfigureScheduledTaskSettings $scheduleTaskName $scheduleTaskPath | Out-Null