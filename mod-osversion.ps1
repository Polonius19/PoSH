function Mod-OSVersion ([string]$server) {
	$srv = $server.toupper()
		
	$OSVer = (Get-WmiObject Win32_OperatingSystem -ComputerName $srv).Version
	if ($OSVer -match "5.2.[\d]{4}") {
		$OS_return = "Server 2003" 
		return $OS_return }
	elseif ($OSVer -match "6.[\d].[\d]{4}") {
		$OS_return = "Server 2008" 
		return $OS_return }
}

