Function Get-FailOverHistory([string]$server, [string]$start, [string]$end) {
    
	if ($start.length -eq 0){$end = "14"}
	if ($end.length -eq 0){$end = "0"}
	
	#Mod-OSVersion
	#. $env:My_dir\mod-osversion.ps1
	$OS = Mod-OSVersion $server
	if ($OS -ne "Server 2008"){
		Write-Host "This function will only return results for Server 2008. $server is $OS."
		Return 
	}	
	
	#Check to see if $server is a cluster node
	if(!(Get-Process -ComputerName $server -ProcessName clussvc -ErrorAction SilentlyContinue)){
	#Keep for debugging purposes
		Write-Host "Clussvc process not found on $server"
		Return 
	}
	
	#Get all cluster node names
	$clusternode = $null
	$clusternode = Get-WmiObject -Class mscluster_node -Authentication PacketPrivacy -Impersonation Impersonate -namespace root\mscluster -ComputerName $server | Select-Object Name
    
    # Remove duplicates and sort alphabetically
    	$uniquenode = $null
	$uniquenode = $clusternode | Select-Object Name -Unique
	
	# Change $uniquenode type to string
	$uniquenodeSTR = $null
	$uniquenodeSTR = @()
    	foreach ($nodeA in $uniquenode) {
    		[string]$string = $nodeA
    		$uniquenodeSTR += [regex]::matches($string, "[Pp][Rr][BXVbxv][\w]{6}[\d]{3}[A-Ea-e]?") | foreach {$_.value }
	}
	
	foreach ($nodeB in $uniquenodeSTR) {
		Get-WinEvent -ComputerName $nodeB -FilterHashTable @{ ProviderName = "Microsoft-Windows-FailoverClustering"; StartTime = ((Get-Date).AddDays(-$start)); EndTime = ((Get-Date).AddDays(-$end)); ID = 1200,1201,1203,1204} | 
		Select-Object ID,TimeCreated,MachineName,Message | 
		Format-List *
	}
}

Set-Alias -Name fohist -Value Get-FailOverHistory
