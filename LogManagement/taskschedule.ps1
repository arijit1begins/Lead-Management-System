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
}

Function ConfigureScheduledTaskSettings ($TASKNAME, $TASKPATH)
{
    $SETTINGS = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Hidden -RestartCount 3
    Set-ScheduledTask -TaskName $TASKNAME -Settings $SETTINGS -TaskPath $TASKPATH 
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