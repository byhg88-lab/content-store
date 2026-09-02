# Register the weekly Task Scheduler job (run once, in an ADMIN PowerShell).
#   powershell -NoProfile -ExecutionPolicy Bypass -File "c:\Users\hahahoho\Desktop\content\scripts\register-task.ps1"
#
# Schedule: every Monday 10:00 AM.
# If the PC was off at that time, it runs after the next boot + sign-in (StartWhenAvailable).

$TaskName = "Heerim Weekly Pipeline"
$Runner   = "c:\Users\hahahoho\Desktop\content\scripts\run-weekly.ps1"

$action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument ('-NoProfile -ExecutionPolicy Bypass -File "' + $Runner + '"')

$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At 10:00am

$settings = New-ScheduledTaskSettingsSet `
    -StartWhenAvailable `
    -MultipleInstances IgnoreNew `
    -ExecutionTimeLimit (New-TimeSpan -Hours 2) `
    -DontStopIfGoingOnBatteries `
    -AllowStartIfOnBatteries

Register-ScheduledTask -TaskName $TaskName `
    -Action $action -Trigger $trigger -Settings $settings `
    -Description "Weekly Heerim content pipeline: scan -> notion log -> topic selection. Missed runs catch up after boot/sign-in." `
    -Force

Write-Host ""
Write-Host ("Registered: " + $TaskName) -ForegroundColor Green
Write-Host "Next run time:"
(Get-ScheduledTask -TaskName $TaskName | Get-ScheduledTaskInfo).NextRunTime
