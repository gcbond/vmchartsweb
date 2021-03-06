$vmhosts = "localhost"

foreach($vmhost in $vmhosts) {
	echo "Running Get-VMSummary on $vmhost"
	$vmsummary = Get-VMSummary -server $vmhost
	$vmscsv = "VM Name,State,Cores,RAM,Snapshots,Created`n"
	$totalMachines = 0
	$totalRunning = 0
	$totalPaused = 0
	$totalStopped = 0
	$totalMemory = 0
	$totalCores = 0
	$totalSnapshots = 0
	$totalcsv = "Machines,Running,Paused,Stopped,Memory,Cores,Snapshots`n"
	foreach($vm in $vmsummary)  {
		$vmName = $vm.VMElementName
		$vmState = $vm.EnabledState
		$vmCpu = $vm.CPUCount
		$vmMemory = $vm.MemoryUsage
		$vmSnapshots = $vm.Snapshots
		$vmBorn = $vm.CreationTime
		$tYear = $vmBorn.Substring(0,4)
		$tMonth = $vmBorn.Substring(4,2)
		$tDay = $vmBorn.Substring(6,2)
		$tHour = $vmBorn.Substring(8,2)
		$tMin = $vmBorn.Substring(10,2)
		$vmBorn = "$tMonth/$tDay/$tYear $tHour.$tMin"
		$vmscsv = $vmscsv + "$vmName,$vmState,$vmCpu,$vmMemory,$vmSnapshots,$vmBorn`n"
		$totalMachines++
		if($vmState -eq "Running") { $totalRunning++ }
		ElseIf($vmState -eq "Paused") { $totalPaused++ }
		ElseIf($vmState -eq "Stopped") { $totalStopped++ }
		$totalMemory += $vmMemory
		$totalCores += $vmCpu
		$totalSnapshots += $vmSnapshots
	}
	$totalcsv = $totalcsv + "$totalMachines,$totalRunning,$totalMemory,$totalCores,$totalSnapshots`n"
	$vmscsv | Out-File C:\$vmhost.csv -Encoding UTF8
	$totalcsv | Out-File C:\$vmhost-total.csv -Encoding UTF8
}

foreach($vmhost in $vmhosts) {
	echo "Getting perfomance stats for $vmhost"
	$memoryFree = Invoke-Command -ComputerName $vmhost -ScriptBlock { typeperf -sc 1 "\Memory\Available MBytes" }
	$cpuGuest = Invoke-Command -ComputerName $vmhost -ScriptBlock { typeperf -sc 1 "\Hyper-V Hypervisor Virtual Processor(_Total)\% Guest Run Time" }
	$cpuHyperV = Invoke-Command -ComputerName $vmhost -ScriptBlock { typeperf -sc 1 "\Hyper-V Hypervisor Virtual Processor(_Total)\% Hypervisor Run Time" }
	$cpuTotal = Invoke-Command -ComputerName $vmhost -ScriptBlock { typeperf -sc 1 "\Hyper-V Hypervisor Virtual Processor(_Total)\% Total Run Time" }
	#$sysInfo = Invoke-Command -ComputerName $vmhost -ScriptBlock { systeminfo }
}
