$a = 0

$timespan = New-Object System.TimeSpan(0, 0, 1)
$scope = New-Object System.Management.ManagementScope("\\.\root\cimV2")
$query = New-Object System.Management.WQLEventQuery `
    ("__InstanceDeletionEvent",$timespan, "TargetInstance ISA 'Win32_Process'" )
$watcher = New-Object System.Management.ManagementEventWatcher($scope,$query)

do
    {
        $b = $watcher.WaitForNextEvent()
        $b.TargetInstance.Name
    }
while ($a -ne 1)