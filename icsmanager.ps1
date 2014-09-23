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