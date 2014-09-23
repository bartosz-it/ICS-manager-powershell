# Check if script is running with elevated rights

$isElevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-NOT ($isElevated))
    {
        Write-Host " `
        ! You do NOT have Administrator rights !`n`n `
        ! Trying to re-run this script as an Administrator !`n`n `
        ! If it won't work try to run it again as Administrator manually or use different credentials !
        " -ForegroundColor Red
        
        #$arguments = "& '" + $myinvocation.mycommand.definition + "'"
        #Start-Process "$psHome\powershell.exe" -Verb runAs -ArgumentList $arguments
        Start-Process -FilePath PowerShell.exe -Verb runAs -ArgumentList $myinvocation.mycommand.definition
        #Start-Process -FilePath PowerShell.exe -Credential $admincheck -ArgumentList $myinvocation.mycommand.definition
        exit
    }

Write-Host "You HAVE Administrator rights!" -ForegroundColor Green

# Register the HNetCfg library (once)
regsvr32 /s hnetcfg.dll

# Create a NetSharingManager object
$m = New-Object -ComObject HNetCfg.HNetShare

# List connections
$m.EnumEveryConnection |% { $m.NetConnectionProps.Invoke($_) }

# Find connection
$conn_1 = $m.EnumEveryConnection |? { $m.NetConnectionProps.Invoke($_).Name -eq "Ethernet_1" }
$conn_2 = $m.EnumEveryConnection |? { $m.NetConnectionProps.Invoke($_).Name -eq "Ethernet_2" }

# Get sharing configuration
$config_1 = $m.INetSharingConfigurationForINetConnection.Invoke($conn_1)
$config_2 = $m.INetSharingConfigurationForINetConnection.Invoke($conn_2)


# See if sharing is enabled
Write-Output $config_1.SharingEnabled
Write-Output $config_2.SharingEnabled

# See the role of connection in sharing
# 0 - public, 1 - private
# Only meaningful if SharingEnabled is True
Write-Output $config_1.SharingType
Write-Output $config_2.SharingType

# Enable sharing (0 - public, 1 - private)

# Enable sharing public on Network_1
$config_1.EnableSharing(0)

# Enable sharing private on Network_2
$config_2.EnableSharing(1)

# Disable sharing
$config_1.DisableSharing()
$config_2.DisableSharing()


Read-Host 'Press Enter to continue...' | Out-Null