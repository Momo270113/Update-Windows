#Create a directory to put powershell script 
mkdir C:\ScheduledTask -Force 

#Copy the file from source to Description 
Copy-Item -Path "C:\autoupdate\1.ps1" -Destination "C:\ScheduledTask\update.ps1" -Force 

#Create the action 
$action = New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument "powershell.exe -executionpolicy bypass -file C:\ScheduledTask\update.ps1" 

#Create a trigger 
$trigger = New-ScheduledTaskTrigger -AtStartup -RandomDelay 00:00:30 

[string]$Username = $($env:UserName) 
[string]$Password = $(Read-Host "Enter the password for user "$Username": ") 

#the parameters to the Register-ScheduledTask cmdlet 
$Params =@{ 
    "TaskName" = "AutoUpdate" 
    "Action" = $action 
    "Trigger" = $trigger 
    "User" = $Username 
    "Password" = $Password 
    "RunLevel" = "Highest" 
    "Description" = "AutoUpdate Win10 1607 to 1803" 
} 

Register-ScheduledTask @Params