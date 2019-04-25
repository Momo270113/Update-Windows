#Start logging 
Start-Transcript -path C:\log.txt -append 
    
    #Change ExecutionPolicy 
    Write-Host "`n>>>Change ExecutionPolicy to Bypass" 
    Set-ExecutionPolicy Bypass -Force 
    Write-Host "`n>>>OK" 

    #Install, import and licensing module PSWindowsUpdate 
    $PathPSWU = "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\PSWindowsUpdate" 
    [string]$IfPathPSWU = $(Test-Path $PathPSWU) 

    if ($IfPathPSWU -eq "True") { 
        Write-Host "`n>>>The module has already been installed" 
    } 
    else { 
        $Username = $($env:UserName)

        Write-Host "`n>>>Unzip PSWindowsUpdate" 
        Expand-Archive C:\Users\$Username\Downloads\PSWindowsUpdate.zip -DestinationPath C:\Windows\System32\WindowsPowerShell\v1.0\Modules\ -Force 
        Write-Host "`n>>>OK"  
        Write-Host "`n>>>Import module PSWindowsUpdate" 
        Import-Module PSWindowsUpdate -Verbose 
        Get-Command -Module PSWindowsUpdate 
        Write-Host "`n>>>OK"    
    } 

    Write-Host "`n>>>Add WUServiceManager" 
    Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d -Confirm:$false 
    Sleep 5 
    Write-Host "`n>>>OK"


    Write-Host "`n>>>Get update list"
    $_listKB = $( Get-WUInstall -MicrosoftUpdate -ListOnly -Verbose | Select KB -ExpandProperty KB )
    Write-Host "`n>>>OK"

    foreach ( $kb in $_listKB ) {
        $CurrentBuildNumber = $((Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentBuildNumber)
        
        if ($CurrentBuildNumber -eq 17134) { 
            Write-Host "`n>>>The update is completed successfully`n>>>The scheduler task is Disabled"
            Disable-ScheduledTask -TaskName "AutoUpdate" 
            Write-Host "`n>>>OK"
            Write-Host "`n>>>The Windows update is Disabled"
            Stop-Service wuauserv
            Set-Service wuauserv -Startup Disabled
            Write-Host "`n>>>OK"
            Write-Host "`n>>>Exit from the script"     
        }
        else { 
            Write-Host "`n>>>Download and install the update $kb" 
            Get-WUInstall -MicrosoftUpdate -KBArticleID $kb -AcceptAll -Verbose -AutoReboot
            Write-Host "`n>>>The Update $kb was installed`n>>>Check reboot status"
            $CheckReboot = $(Get-WURebootStatus -Silent)
            
            if ($CheckReboot -eq "True") {
                Write-Host "`n>>>Need a reboot`n>>>Reboot..."
                Write-Host "`n>>>OK"
                Restart-Computer -Force
            }
            else {
                Write-Host "`n>>>Next update"
            }
        }   
    }
Stop-Transcript


