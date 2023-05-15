################################################################################################################### 
#                                                                                                                 #
#  Miscellaneous registry keys, a few from mscoree manifest so we can skip dotnet40 install                       #
#                                                                                                                 #
###################################################################################################################
$misc_reg = @'
REGEDIT4

[HKEY_CURRENT_USER\Software\Wine\DllOverrides]
"mscoree"="native"
"d3dcompiler_47"="native"
"d3dcompiler_43"="native"
"wusa.exe"="native"
"mscorsvw.exe"=""
"schtasks.exe"="native"
"setx.exe"="native"
"taskschd"="native"
"robocopy.exe"="native"
"systeminfo.exe"="native"
"wmic.exe"="native"
"ngen.exe"="native"

[HKEY_CURRENT_USER\Software\Wine\AppDefaults\conemu64.exe]
"Version"="win81"

[HKEY_CURRENT_USER\Software\Wine\AppDefaults\conemu64.exe\DllOverrides]
"dwmapi"=""
"user32"="native"

[HKEY_CURRENT_USER\Software\Wine\AppDefaults\pwsh.exe]

[HKEY_CURRENT_USER\Software\Wine\AppDefaults\pwsh.exe\DllOverrides]
"amsi"=""
"dwmapi"=""

[HKEY_CURRENT_USER\Software\ConEmu\.Vanilla]
"ColorTable00"=dword:00562401
"ColorTable14"=dword:0000ffff

[HKEY_LOCAL_MACHINE\Software\Microsoft\.NETFramework]
"OnlyUseLatestCLR"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework\Policy\v2.0]
"50727"="50727-50727"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.0]
"Install"=dword:0x00000001
"SP"=dword:0x00000002
"Version"="3.2.30729"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.0\Setup]
"InstallSuccess"=dword:0x00000001
"Version"="3.2.30729"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5]
"Install"=dword:0x00000001
"SP"=dword:0x00000001
"Version"="3.5.30729.4926"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5\1033]
"Install"=dword:0x00000001

[HKEY_CURRENT_USER\Software\Microsoft\Avalon.Graphics]
"DisableHWAcceleration"=dword:00000000

[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{0A29FF9E-7F9C-4437-8B11-F424491E3931}\InprocServer32]
@="C:\\Windows\\System32\\mscoree.dll"
"ThreadingModel"="Both"

[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{0A29FF9E-7F9C-4437-8B11-F424491E3931}]
@="NDP SymBinder"

[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{0A29FF9E-7F9C-4437-8B11-F424491E3931}\ProgID]
@="CorSymBinder_SxS"

[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{0A29FF9E-7F9C-4437-8B11-F424491E3931}\Server]
@="diasymreader.dll"

[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Fonts]
"Arial (TrueType)"="arial.ttf"
"Arial Bold (TrueType)"="arialbd.ttf"
"Arial Bold Italic (TrueType)"="arialbi.ttf"
"Arial Italic (TrueType)"="ariali.ttf"

[HKEY_CURRENT_USER\Software\Wine\Debug]
"RelayExclude"="user32.CharNextA;KERNEL32.GetProcessHeap;KERNEL32.GetCurrentThreadId;KERNEL32.TlsGetValue;KERNEL32.GetCurrentThreadId;KERNEL32.TlsSetValue;ntdll.RtlEncodePointer;ntdll.RtlDecodePointer;ntdll.RtlEnterCriticalSection;ntdll.RtlLeaveCriticalSection;kernel32.94;kernel32.95;kernel32.96;kernel32.97;kernel32.98;KERNEL32.TlsGetValue;KERNEL32.FlsGetValue;ntdll.RtlFreeHeap;ntdll.RtlAllocateHeap;KERNEL32.InterlockedDecrement;KERNEL32.InterlockedCompareExchange;ntdll.RtlTryEnterCriticalSection;KERNEL32.InitializeCriticalSection;ntdll.RtlDeleteCriticalSection;KERNEL32.InterlockedExchange;KERNEL32.InterlockedIncrement;KERNEL32.LocalFree;Kernel32.LocalAlloc;ntdll.RtlReAllocateHeap;KERNEL32.VirtualAlloc;Kernel32.VirtualFree;Kernel32.HeapFree;KERNEL32.QueryPerformanceCounter;KERNEL32.QueryThreadCycleTime;ntdll.RtlFreeHeap;ntdll.memmove;ntdll.memcmp;KERNEL32.GetTickCount;kernelbase.InitializeCriticalSectionEx;ntdll.RtlInitializeCriticalSectionEx;ntdll.RtlInitializeCriticalSection;kernelbase.FlsGetValue"
"RelayFromExclude"="winex11.drv;user32;gdi32;advapi32;kernel32"

'@

<# FIXME these keys are different from regular winetricks dotnet48 install????
[HKEY_CLASSES_ROOT\CLSID\{E5CB7A31-7512-11D2-89CE-0080C792E5D8}]
"MasterVersion"=dword:0x00000002

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Eventlog\Application\.NET Runtime]
"TypesSupported"=dword:0x00000007
#>
################################################################################################################### 
#                                                                                                                 #
#  profile.ps1: Put workarounds/hacks here. It goes into c:\\Program Files\\Powershell\\7\\profile.ps1            #
#                                                                                                                 #
###################################################################################################################
$profile_ps1 = @'
#Put workarounds/hacks here.../Adjust to your own needs. It goes into c:\\Program Files\\Powershell\\7\\profile.ps1

$host.ui.RawUI.WindowTitle = 'This is Powershell Core (pwsh.exe), not (!) powershell.exe'

$profile = '$env:ProgramFiles\PowerShell\7\profile.ps1'

. "$env:ProgramData\\Chocolatey-for-wine\\profile_essentials.ps1"
. "$env:ProgramData\\Chocolatey-for-wine\\profile_winetricks_caller.ps1"
. "$env:ProgramData\\Chocolatey-for-wine\\profile_miscellaneous.ps1"
'@
################################################################################################################################ 
#                                                                                                                              #
#  profile_essentials_ps1.ps1                   #
#                                                                                                                              #
################################################################################################################################   
$profile_essentials_ps1 = @'
<# This contains essential functions/settings for Chocolatey-for-wine to work properly, do not remove or change #>

$env:DXVK_CONFIG_FILE=("$env:WINECONFIGDIR" + "\" + "drive_c" + "\" + ($env:ProgramData |split-path -leaf) + "\" + "dxvk.conf").substring(6) -replace "\\","/"

# Enable Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

if($env:FirstRun -eq '2') {
    Write-Host Installed Software besides ConEmu: ; Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table ; [Environment]::SetEnvironmentVariable("FirstRun",$null)}

if($env:FirstRun -eq '1') { $env:FirstRun=2 }

<# if wineprefix is updated by running another wine version we have to update the hack for ConEmu bug https://bugs.winehq.org/show_bug.cgi?id=48761 #>
if( !( (Get-FileHash C:\windows\system32\user32.dll).Hash -eq (Get-FileHash C:\windows\system32\user32dummy.dll).Hash) ) {
    Copy-Item $env:SystemRoot\\system32\\user32.dll $env:SystemRoot\\system32\\user32dummy.dll -force -erroraction silentlycontinue
}
<# check wine-version, hack is only compatible with recent wine versions #>
$MethodDefinition = @" 
[DllImport("ntdll.dll", CharSet = CharSet.Ansi)] public static extern string wine_get_version();
"@
$ntdll = Add-Type -MemberDefinition $MethodDefinition -Name 'ntdll' -PassThru

if( [System.Convert]::ToDecimal( ($ntdll::wine_get_version() -replace '-rc','' ) ) -lt 7.16 ) { <# hack incompatible for older wine versions #>
    $null = New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\ConEmu64.exe\\DllOverrides' -force -Name 'user32' -Value 'builtin' -PropertyType 'String'}
else {
     $null = New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\ConEmu64.exe\\DllOverrides' -force -Name 'user32' -Value 'native' -PropertyType 'String'}
<# end update ConEmu hack #>

#Examples of usage: Get-WmiObject win32_operatingsystem version or $(Get-WmiObject win32_videocontroller).name etc.
Function Get-WmiObject([parameter(mandatory=$true, position = 0, parametersetname = 'class')] [string]$class, `
                       [parameter( position = 1, parametersetname = 'class')][string[]]$property="*", `
                       [string]$computername = "localhost", [string]$namespace = "root\cimv2", `
                       [string]$filter, [parameter(parametersetname = 'query')] [string]$query)
{   <# Do not remove or change, it will break Chocolatey #>
    if(!$query) {    
        $query = "SELECT " +  $($property | Join-String -Separator ",") + " FROM " + $class + (($filter) ? (' where ' + $filter ) : ('')) }

    $searcher = [wmisearcher]$query

    $searcher.scope.path = "\\" + $computername + "\" + $namespace

    return [System.Management.ManagementObjectCollection]$searcher.get()
}

Set-Alias gwmi Get-WmiObject

Function Get-CIMInstance ( [parameter(mandatory)] [string]$classname, [string[]]$property="*", [string]$filter)
{
     Get-WMIObject $classname -property $property -filter $filter
}

# Query program replacement for wusa.exe; Do not remove or change, it will break Chocolatey
Set-Alias "QPR.wusa" "QPR.wusa.exe";
function QPR.wusa.exe { <# wusa.exe replacement #>
     Write-Host "This is wusa dummy doing nothing..."
     exit 0;
}
'@
################################################################################################################################ 
#                                                                                                                              #
#  profile_winetricks_caller.ps1                   #
#                                                                                                                              #
################################################################################################################################   
$profile_winetricks_caller_ps1 = @'
<# Because this function might be updated/changed more frequently, it has been put in a seperate file #>

<# To support auto-tabcompletion only a comma seperated is supported from now on when calling winetricks with multiple arguments, e.g. 'winetricks gdiplus,riched20' #>
function winetricks {
[CmdletBinding()]
 Param(
        [Parameter(Mandatory=$false)]
        [ArgumentCompletions('msxml3', 'msxml6','gdiplus', 'mfc42', 'riched20', 'msado15', 'expand', 'wmp', 'ucrtbase', 'vcrun2019', 'mshtml', 'd2d1',`
                     'dxvk1103', 'dxvk20', 'hnetcfg', 'msi', 'wintrust', 'sapi', 'ps51', 'ps51_ise', 'crypt32', 'oleaut32', 'msvbvm60', 'xmllite', 'windows.ui.xaml', 'windowscodecs', 'uxtheme', 'comctl32', 'wsh57',`
                     'nocrashdialog', 'renderer=vulkan', 'renderer=gl', 'app_paths', 'vs19','sharpdx', 'dotnet35', 'dotnet481' ,'cef', 'd3dx','sspicli', 'dshow', 'findstr', 'affinity_requirements',`
                     'winmetadata', 'wintypes', 'dxcore', 'install_dll_from_msu', 'wpf_xaml', 'wpf_msgbox', 'wpf_routedevents', 'embed-exe-in-psscript', 'vulkansamples', 'ps2exe')]
        [string[]]$verb
      )

     if (!([System.IO.File]::Exists("$env:ProgramData\\Chocolatey-for-wine\\winetricks.ps1"))){
         Add-Type -AssemblyName PresentationCore,PresentationFramework;
         [System.Windows.MessageBox]::Show("winetricks script is missing`nplease reinstall it in c:\\ProgramData\\Chocolatey-for-wine",'Congrats','ok','exclamation')
     }

     pwsh -f  $( Join-Path $("$env:ProgramData\\Chocolatey-for-wine") "winetricks.ps1")   $verb
}
'@
################################################################################################################################ 
#                                                                                                                              #
#  profile_miscellaneous.ps1                   #
#                                                                                                                              #
################################################################################################################################   
$profile_miscellaneous_ps1 = @'
<# Stuff you might want to throw away / change ... #>

#Remove ~/Documents/Powershell/Modules from modulepath; it becomes a mess because it`s not removed when one deletes the wineprefix... 
$path = $env:PSModulePath -split ';'
$env:PSModulePath  = ( $path | Select-Object -Skip 1 | Sort-Object -Unique) -join ';'

#Register-WMIEvent not available in PS Core, so for now just change into noop
function Register-WMIEvent {
    exit 0
}
  
#Example (works on windows,requires admin rights): Set-WmiInstance -class win32_operatingsystem -arguments @{"description" = "MyDescription"}
#Based on https://devblogs.microsoft.com/scripting/use-the-set-wmiinstance-powershell-cmdlet-to-ease-configuration/
Function Set-WmiInstance( [string]$class, [hashtable]$arguments, [string]$computername = "localhost", `
                          [string]$namespace = "root\cimv2" <#, [string]$path #>)
{
    $assembledpath = "\\" + $computername + "\" + $namespace + ":" + $class
    $obj = ([wmiclass]"$assembledpath").CreateInstance()

    foreach ($h in $arguments.GetEnumerator()) {
        $obj.$($h.Name) = $($h.Value)
    }
    $result = $obj.put()

    return $result.Path
}

function Test-NetConnection { <# stolen from https://copdips.com/2019/09/fast-tcp-port-check-in-powershell.html #>
    [CmdletBinding()]
    param ([Parameter(ValueFromPipeline = $true)][String[]]$ComputerName='internetbeacon.msedge.net', [Int]$Port = 80, [Int]$Timeout = 1000)

    begin { $result = [System.Collections.ArrayList]::new() }

    process {
        foreach ($originalComputerName in $ComputerName) {
            $remoteInfo = $originalComputerName.Split(":")
            if ($remoteInfo.count -eq 1) { $remoteHostname = $originalComputerName; $remotePort = $Port } <# 'host' #>
            elseif ($remoteInfo.count -eq 2) { $remoteHostname = $remoteInfo[0]; $remotePort = $remoteInfo[1] }
            else { $msg = "Got unknown format "; Write-Error $msg;  return }

            $tcpClient = New-Object System.Net.Sockets.TcpClient
            $portOpened = $tcpClient.ConnectAsync($remoteHostname, $remotePort).Wait($Timeout)
            if($portOpened) {
            $ra = $tcpClient.Client.RemoteEndPoint.Address.ToString() }
            $sa = $tcpClient.Client.LocalEndPoint.Address.ToString()

            $null = $result.Add([PSCustomObject]@{
                RemoteHostname = $remoteHostname   ; RemoteAddress = $ra         ; RemotePort = $remotePort
                SourceAddress  = $sa               ; PortOpened    = $portOpened ; TimeoutInMillisecond = $Timeout
                SourceHostname = $env:COMPUTERNAME ; OriginalComputerName = $originalComputerName })
        }
    }
    end { return $result }
}

function Get-NetIPAddress( [string]$AddressFamily='*', [string]$InterfaceIndex='*', [string]$IPAddress='*' ) 
{
    $netcfg = (Get-WmiObject  -Class Win32_NetworkAdapterConfiguration ) ; $ip = $netcfg.ipaddress; $ip += '127.0.0.1'
    $result = @() ; $idx=0

    foreach($i in $ip) { if($i) {
        $result += New-Object PSObject -Property @{
             IPAddress        = $i
             InterfaceIndex   = $netcfg.Index[$idx] ? $netcfg.Index[$idx] : '1' 
             InterfaceAlias   = ($i -eq '127.0.0.1') ? 'Loopback Pseudo-Interface 1' : 'Ethernet'
             AddressFamily    = ( ([IPAddress]$i).AddressFamily -eq 'InterNetwork' ) ? 'IPv4' : 'IPv6'}
             | where-object  {($_.AddressFamily -like $AddressFamily) -and ($_.InterfaceIndex -like $InterfaceIndex) -and ($_.IPAddress -like $IPAddress) } }
        $idx++
    }
    $result |  Select ipaddress,interfaceindex,interfacealias,addressfamily  |fl
}

function Get-NetRoute {
      Get-WmiObject -query 'Select  Destination, NextHop From Win32_IP4RouteTable' |select Destination,NextHop |ft }

function Resolve-DnsName([string]$name) { <# https://askme4tech.com/how-resolve-hostname-ip-address-and-vice-versa-powershell #>
    $type = [Uri]::CheckHostname($name)
    if( $type -eq 'Dns')                            { [System.Net.Dns]::GetHostaddresses($name) |select IPAddressToString}
    if( ($type -eq 'IPv4') || ($type -eq 'IPv6'))   { [System.Net.Dns]::GetHostentry($name).hostname}
}
 <# hack for installing adobereader #>
function  Unregister-ScheduledTask { Write-Host 'cmdlet Unregister-ScheduledTask not available in PS 7, doing nothing...'; return}
<# needed for Amazon Music #>
Set-Alias "QPR.ie4uinit" "QPR.ie4uinit.exe";
function QPR.ie4uinit.exe { <# ie4uinit.exe replacement #>
     Write-Host "This is ie4uinit dummy doing nothing..."
     exit 0;
}

function check_busybox {
    if (!([System.IO.File]::Exists("$env:systemdrive\\ProgramData\\chocolatey\\bin\\busybox64.exe "))){ choco install Busybox -y }
}

<# A few Unix commands I find handy, just remove stuff below if you don`t want it #>
function du   { check_busybox; Busybox64.exe du $args}
function df   { check_busybox; Busybox64.exe df $args}
function wget { check_busybox; Busybox64.exe wget $args}
function grep { check_busybox; Busybox64.exe grep $args}
function bash { check_busybox; Busybox64.exe bash $args}

# Note: Visual Studio calls this, not sure if this is really needed by it...
Set-Alias "QPR.getmac" "QPR.getmac.exe";
function QPR.getmac.exe { <# getmac.exe replacement #>
    Get-WmiObject win32_networkadapterconfiguration | Format-Table @{L=’Physical address’;E={$_.macaddress}}
}

Set-Alias "QPR.setx" "QPR.setx.exe";
function QPR.setx.exe { <# setx.exe replacement #>
    <# FIXME, only setting env. variable handled atm. #>
    <# https://stackoverflow.com/questions/50368246/splitting-a-string-on-spaces-but-ignore-section-between-double-quotes #>
    $argv = ($env:QPRCMDLINE| select-string '("[^"]*"|\S)+' -AllMatches | % matches | % value) -replace '"'

    New-ItemProperty -Path 'HKLM:\\System\\CurrentControlSet\\Control\\Session Manager\\Environment' -force -Name $argv[1] -Value $argv[2] -PropertyType 'String' 
    New-ItemProperty -Path 'HKCU:\\Environment' -force -Name $argv[1] -Value $argv[2] -PropertyType 'String' 
    exit 0
}

#Set-Alias "QPR.findstr" "QPR.findstr.exe"; Set-Alias "findstr.exe" "QPR.findstr.exe"; Set-Alias "findstr" "QPR.findstr.exe"
#function QPR.findstr.exe { <# findstr.exe replacement #>
#
#begin { $count = 0 
#        $new = $env:QPRPIPE 
#
#        if($args[1]) {
#            foreach($i in (cat $args[1])) {
#                $found = Select-String -Inputobject $i -Pattern $args[0]; if ($found) {Write-Host $found; $count++}}
#         }
#
#        foreach($i in $new -split "`n") {
#            $found = Select-String -Inputobject $i  -Pattern $args[0].Replace(" ","") <#.Split("|").Trim("'").Trim(" ")#>; if ($found) {Write-Host $found; $count++}
#        }       
#
#        if ($count) {  if($env:QPRCMDLINE)  {exit 0} }  
#        else        {  if($env:QPRCMDLINE)  {exit 1} }
#}
#process	{
#        if(-not $args[1]){
#            $found = Select-String -Inputobject $_ -Pattern $args[0].Replace(" ","") <#.Split("|").Trim("'").Trim(" ")#>; if ($found) {Write-Host $found; $count++}}
#        else {
#            foreach($i in (cat $args[1])) {
#                $found = Select-String -Inputobject $i -Pattern $args[0]; if ($found) {Write-Host $found; $count++}}}
#}
#
#end {
#      if ($count) {  if($env:QPRCMDLINE)  {exit 0} }  
#      else        {  if($env:QPRCMDLINE)  {exit 1} }
#}
#}

Set-Alias "QPR.systeminfo" "QPR.systeminfo.exe";
function QPR.systeminfo.exe { <# systeminfo replacement #>
    $result = [System.Collections.ArrayList]::new() ;  $p=[System.Collections.ArrayList]::new() 

    foreach ($i in 'operatingsystem', 'computersystem', 'processor', 'bios', 'QuickFixEngineering', 'PageFileUsage', 'videocontroller') {
        $null = $p.Add( [PSCustomObject]@{ v = Get-WmiObject ('win32_' + $i)} ) } 

        $null = $result.Add([PSCustomObject]@{
    "Host Name"=$p[0].v.csname ; "OS Name"=$p[0].v.caption ; "OS Version"=$p[0].v.version + ' Build ' + $p[0].v.buildnumber         
    "OS Manufacturer"=$p[0].v.manufacturer ; "OS Build Type"=$p[0].v.buildtype ; "Registered Owner"=$p[0].v.registereduser          
    "Registered Organization"=$p[0].v.organization ; "Product ID"=$p[0].v.SerialNumber                
    "Original Install Date"=[Management.ManagementDateTimeConverter]::ToDateTime($p[0].v.InstallDate) 
    "System Boot Time"=[Management.ManagementDateTimeConverter]::ToDateTime($p[0].v.LastBootUpTime)    
    "System Manufacturer"=$p[1].v.manufacturer ; "System Model"=$p[1].v.model ; "System Type"=$p[1].v.systemtype            
    "Processor(s)"=$p[2].v.Description + ' ~' + $p[2].v.CurrentClockSpeed + 'Mhz'            
    "BIOS Version"=$p[3].v.Manufacturer + ' ' + $p[3].v.SMBIOSBIOSVersion + ' ' + [Management.ManagementDateTimeConverter]::ToDateTime($p[3].v.ReleaseDate)            
    "Windows Directory"=$p[0].v.windowsdirectory ; "System Directory"=$p[0].v.systemdirectory ; "Boot Device"=$p[0].v.bootdevice          
    "System Locale"=$p[0].v.oslanguage ; "Input Locale"=$p[0].v.oslanguage
    "Time Zone"='UTC' + (( ($p[0].v.CurrentTimeZone/60) -gt 0) ? ('+') : ('-')) + $p[0].v.currenttimezone/60 
    "Total Physical Memory"=$p[0].v.TotalVisibleMemorySize ; "Available Physical Memory"=$p[0].v.FreePhysicalMemory
    "Virtual Memory: Max Size"=$p[0].v.TotalVirtualMemorySize ; "Virtual Memory: Available"=$p[0].v.FreeVirtualMemory
    "Virtual Memory: In Use"='[not implemented]' ; "Page File Location(s)"=$p[5].v.name ; "Domain"=$p[1].v.domain ; "Logon Server"=$env:LOGONSERVER ;
    "Hotfix(s)"=$p[4].v.hotfixid ; "Network Card(s)"='[not implemented]' ; "Hyper-V Requirements"='[not implemented]' ; "GPU"=$p[6].v.videoprocessor })
   
    return $result 
}

Set-Alias Get-ComputerInfo QPR.systeminfo.exe

#If passing back (manipulated) arguments back to the same program, make sure to backup a copy (here QPR.schtasks.exe, copied during installation)
Set-Alias "QPR.schtasks" "QPR.schtasks.exe";
function QPR.schtasks.exe { <# schtasks.exe replacement #>
    $cmdline = $env:QPRCMDLINE

    $cmdline = $cmdline -replace '/create', '-create' -replace '/tn', '-tn' -replace "/tr", "-tr" <#-replace "'", "'`"'"#>  <# escape quotes (??) #> `
                        -replace "/sc", "-sc" -replace "/run", "-run" -replace "/delete", "-delete"
    $cmdline
    iex  -Command ('QPR_schtasks ' + $cmdline)
}

function QPR_schtasks { <# schtasks replacement #>
   # [CmdletBinding()]
    Param([switch]$create, [string]$tn, [string]$tr, [string]$sc, [switch]$run, [switch]$delete,
    [parameter(ValueFromRemainingArguments=$true)]$vargs)

   if($create) {$tr -replace "'" 
    start-process ($tr -replace "'" -replace "/silent") } <# hack for spotify #>
   else {
       $cmdline = $cmdline -replace "^[^ ]+" <# remove everything up yo 1st space #> -replace "-","/"
       Start-Process -NoNewWindow QPR.schtasks.exe -argumentlist "$cmdline" }
}

Set-Alias "QPR.wmic" "QPR.wmic.exe";
function QPR.wmic.exe { <# wmic replacement, this part only rebuilds the arguments #>
    $cmdline = $env:QPRCMDLINE 
    $hash = @{
        'os' = "-class win32_operatingsystem"
        'bios' = "-class win32_bios"
        'logicaldisk' = "-class win32_logicaldisk"
        'process' = "-class win32_process" } <# etc. etc. #>

    foreach ($key in $hash.keys) {
        if( $cmdline |select-string "\b$key\b" ) { $cmdline = $cmdline -replace $key, $hash[$key]; break }    }
   
    $cmdline = $cmdline -replace 'get', '-property' -replace 'where', '-where' -replace "/path", "-class"

    <# Hack: if command like  'wmic logicaldisk where 'deviceid="c:"' get freespace' is ran from PS-console, somehow (double) quotes get lost so escape them #>
    if ( $(Get-Process wmic).Parent.name -eq 'pwsh') <# check whether cmd is ran from PS-console #>
        { $cmdline = $cmdline -replace "`'", "```'"   -replace "`"", "```""}

    iex  -Command ('QPR_wmic ' + $cmdline)
}

function QPR_wmic { <# wmic replacement #>
    [CmdletBinding()]
    Param([parameter(Position=0)][string]$class, [string[]]$property="*",
    [string]$where, [parameter(ValueFromRemainingArguments=$true)]$vargs)

    if($property -eq '*'){ <# 'get-wmiobject $class | select *' does not work because of wine-bug, so need a workaround:  #>
        Get-WmiObject $class ($($(Get-WmiObject $class |Get-Member) |where {$_.membertype -eq 'property'}).name |Join-String -Separator ',') }
    else { #handle e.g. wmic logicaldisk where "deviceid='C:'" get freespace or  wmic logicaldisk get size, freespace, caption
    $query = 'Select' + ' ' + $($property -join ',' ) + ' ' + 'From' + ' ' + $class + (($where) ? (' where ' + $where ) : ('')) #+ $vargs
    <#                                                                              -Stream: break up in lines  skip seperatorline(---) remove blank lines #>
    (Get-WMIObject -query $query |ft ($property |sort-object) -autosize |Out-string -Stream | Select-Object    -skipindex (2)|          ?{$_.trim() -ne ""}) } 
}

function use_google_as_browser { <# replace winebrowser with google chrome to open webpages #>
    if (!([System.IO.File]::Exists("$env:ProgramFiles\Google\Chrome\Application\Chrome.exe"))){ choco install googlechrome}

$regkey = @"
REGEDIT4
[HKEY_CLASSES_ROOT\https\shell\open\command]
@="\"%ProgramFiles%\\Google\\Chrome\\Application\\chrome.exe\" \"--no-sandbox\" \"%1\""
[HKEY_CLASSES_ROOT\http\shell\open\command]
@="\"%ProgramFiles%\\Google\\Chrome\\Application\\chrome.exe\" \"--no-sandbox\" \"%1\""
"@
    $regkey | Out-File -FilePath $env:TEMP\\regkey.reg
    reg.exe  IMPORT  $env:TEMP\\regkey.reg /reg:64;
    reg.exe  IMPORT  $env:TEMP\\regkey.reg /reg:32;
}

#Easy access to the C# compiler
Set-Alias csc c:\windows\Microsoft.NET\Framework\v4.0.30319\csc.exe

function handy_apps { choco install explorersuite reactos-paint}
'@
################################################################################################################################ 
#                                                                                                                              #
#  Install dotnet48, ConEmu, Chocolatey, 7z, arial, d3dcompiler_47 and a few extras (wine robocopy + wine taskschd)                   #
#                                                                                                                              #
################################################################################################################################   
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
#   Invoke-Expression  $(cat $(Join-Path "$env:TEMP" 'install2.ps1') | Select-string 'url_7za =')  <# Get the 7za.exe downloadlink from install2.ps1 file #>
#   (New-Object System.Net.WebClient).DownloadFile($url_7za, $(Join-Path "$env:TEMP" '7za.exe') )
    if (!(Test-Path -Path "$env:WINEHOMEDIR\.cache\choc_install_files\7z2201-x64.exe".substring(4) -PathType Leaf)) { 
        (New-Object System.Net.WebClient).DownloadFile('https://d3.7-zip.org/a/7z2201-x64.exe', $(Join-Path "$env:TEMP" '7z2201-x64.exe') ) }
    else {
        Copy-Item -Path "$env:WINEHOMEDIR\.cache\choc_install_files\7z2201-x64.exe".substring(4) -Destination "$env:TEMP" -Force }

    iex "$(Join-Path "$env:TEMP" '7z2201-x64.exe') /S"; while(!(Test-Path -Path "$env:ProgramW6432\\7-zip\\7z.exe") ) {Sleep 0.25}
    New-Item -Path "$env:ProgramData" -Name "Chocolatey-for-wine" -ItemType "directory" -ErrorAction SilentlyContinue

    <# fragile test... If install files already present skip downloads. Run choc_installer once with 'SAVEINSTALLFILES=1' to cache downloads #>
    if (!(Test-Path -Path "$env:WINEHOMEDIR\.cache\choc_install_files\ndp48-x86-x64-allos-enu.exe".substring(4) -PathType Leaf)) { <# First download/extract/install dotnet48 as job, this takes most time #>
        (New-Object System.Net.WebClient).DownloadFile('https://download.visualstudio.microsoft.com/download/pr/7afca223-55d2-470a-8edc-6a1739ae3252/abd170b4b0ec15ad0222a809b761a036/ndp48-x86-x64-allos-enu.exe', $(Join-Path "$env:TEMP" 'ndp48-x86-x64-allos-enu.exe') ) }
    else {
        Copy-Item -Path "$env:WINEHOMEDIR\.cache\choc_install_files\ndp48-x86-x64-allos-enu.exe".substring(4) -Destination "$env:TEMP" -Force }
    start-threadjob -throttle 2 -ScriptBlock {[System.Threading.Thread]::CurrentThread.Priority = 'Highest'; Start-Process -FilePath $env:ProgramW6432\\7-zip\\7z.exe -NoNewWindow -ArgumentList  "x -x!*.cab -ms190M $env:TEMP\\ndp48-x86-x64-allos-enu.exe -o$env:TEMP"}
    start-threadjob -throttle 2 -ScriptBlock {  while(!(Test-Path -Path "$env:TEMP\1025") ) {Sleep 0.25} ;[System.Threading.Thread]::CurrentThread.Priority = 'Highest'; &{ c:\\windows\\system32\\msiexec.exe  /i $env:TEMP\\netfx_Full_x64.msi EXTUI=1 /sfxlang:1033 /q /norestart} }

    $url = @('http://download.windowsupdate.com/msdownload/update/software/crup/2010/06/windows6.1-kb958488-v6001-x64_a137e4f328f01146dfa75d7b5a576090dee948dc.msu', `
             'https://mirrors.kernel.org/gentoo/distfiles/arial32.exe', `
#            'https://mirrors.kernel.org/gentoo/distfiles/arialb32.exe', `
             'https://github.com/mozilla/fxc2/raw/master/dll/d3dcompiler_47.dll', `
             'https://github.com/mozilla/fxc2/raw/master/dll/d3dcompiler_47_32.dll', `
             'https://globalcdn.nuget.org/packages/sevenzipextractor.1.0.17.nupkg' )
    <# Download stuff #>
    foreach($i in $url) {          `
         if (!(Test-Path -Path "$env:WINEHOMEDIR\.cache\choc_install_files\$i.split('/')[-1]".substring(4) -PathType Leaf)) { 
              (New-Object System.Net.WebClient).DownloadFile($i, $(Join-Path "$env:TEMP" $i.split('/')[-1]) ) }
         else {
             Copy-Item -Path "$env:WINEHOMEDIR\.cache\choc_install_files\$i.split('/')[-1]".substring(4) -Destination "$env:TEMP" -Force } }
    <# Download ConEmu #>
    (New-Object System.Net.WebClient).DownloadFile('https://conemu.github.io/install2.ps1', $(Join-Path "$env:TEMP" 'install2.ps1') )
    <# we probably only need this from regular dotnet40 install (???) #>
    Start-Process wusa.exe -NoNewWindow -Wait -ArgumentList  "$env:TEMP\\windows6.1-kb958488-v6001-x64_a137e4f328f01146dfa75d7b5a576090dee948dc.msu"
     
    Start-Process -FilePath $env:ProgramW6432\\7-zip\\7z.exe -NoNewWindow -Wait -ArgumentList  "x $(Join-Path $args[0] 'EXTRAS\wine_robocopy.7z') -o$env:TEMP";
    Start-Process -FilePath $env:ProgramW6432\\7-zip\\7z.exe -NoNewWindow -Wait -ArgumentList  "x $(Join-Path $args[0] 'EXTRAS\wine_taskschd.7z') -o$env:TEMP";
    Start-Process -FilePath $env:ProgramW6432\\7-zip\\7z.exe -NoNewWindow -Wait -ArgumentList  "x $(Join-Path $args[0] 'EXTRAS\wine_user32_for_conemu_hack_for_wine7_16.7z') -o$env:TEMP" `

    & $env:TEMP\\install2.ps1  <# ConEmu install #>
    
    $misc_reg | Out-File $env:TEMP\\misc.reg
    $profile_ps1 | Out-File $env:TEMP\\profile.ps1
    $profile_ps1 | Out-File $(Join-Path $(Split-Path -Path (Get-Process -Id $pid).Path) "profile.ps1") <# Write profile.ps1 to Powershell directory #>
    $profile_winetricks_caller_ps1 | Out-File $env:ProgramData\\Chocolatey-for-wine\\profile_winetricks_caller.ps1
    $profile_essentials_ps1 | Out-File $env:ProgramData\\Chocolatey-for-wine\\profile_essentials.ps1
    $profile_miscellaneous_ps1 | Out-File $env:ProgramData\\Chocolatey-for-wine\\profile_miscellaneous.ps1

    <# Install Chocolatey #>
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    <# Import reg keys: keys from mscoree manifest files, tweaks to advertise compability with lower .Net versions, and set some native dlls #>
    Get-job |wait-job; 
    Get-Process '7z' -ErrorAction:SilentlyContinue | Foreach-Object { $_.WaitForExit() } 
    reg.exe  IMPORT  $env:TMP\\misc.reg /reg:64
    reg.exe  IMPORT  $env:TMP\\misc.reg /reg:32 
    <# fix up the 'highlight selection'-hack for ConEmu #>
    Copy-Item -Path "$env:TMP\\user32.dll" -Destination "$env:SystemDrive\\ConEmu\\user32.dll" -Force
    Copy-Item $env:SystemRoot\\system32\\user32.dll $env:SystemRoot\\system32\\user32dummy.dll -force

    <# do not use chocolatey's builtin powershell host #>
    cd c:\; c:\\ProgramData\\chocolatey\\choco.exe feature disable --name=powershellHost; winecfg /v win10
    c:\\ProgramData\\chocolatey\\choco.exe feature enable -n allowGlobalConfirmation <# to confirm automatically (no -y needed) #>
    # Add-Type -AssemblyName PresentationCore,PresentationFramework; [System.Windows.MessageBox]::Show('Chocolatey installed','Congrats','ok','exclamation')
    # choco install tccle -y; & "$env:ProgramFiles\\JPSoft\\TCCLE14x64\\tcc.exe" "$env:ProgramFiles\\JPSoft\\TCCLE14x64\\tccbatch.btm"; <># cmd.exe replacement #
    $env:FirstRun=1
    Start-Process "powershell" -NoNewWindow
################################################################################################################### 
#  All code below is only for sending a single keystroke (ENTER) to ConEmu's annoying                             #
#  fast configuration window to dismiss it...............                                                         #
#  Based on https://github.com/nylyst/PowerShell/blob/master/Send-KeyPress.ps1 -> so credits to that author       #
#  Could be replaced with [System.Windows.Forms.SendKeys]::SendWait("{ENTER}") if that one day works in wine...   #
###################################################################################################################
    <# add a C# class to access the WIN32 API SetForegroundWindow #>
    Add-Type @"
    using System;
    using System.Runtime.InteropServices;

    public class StartActivateProgramClass {
    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
    }
"@
    <# get the application and window handle and set it to foreground #>
    while(!$p) {$p = Get-Process | Where-Object { $_.MainWindowTitle -Match "Conemu" }; Start-Sleep -Milliseconds 200}
    $h = $p[0].MainWindowHandle
    [void] [StartActivateProgramClass]::SetForegroundWindow($h)
    <# add a C# class to access the WIN32 API SendInput #>
    Add-Type @"
    using System;
    using System.Collections.Generic;
    using System.Runtime.InteropServices;

    public static class Synthesize_Keystrokes {    
        public enum InputType : uint {
            INPUT_MOUSE = 0,
            INPUT_KEYBOARD = 1,
            INPUT_HARDWARE = 3
        }

        [Flags]
        internal enum KEYEVENTF : uint
        {
            KEYDOWN = 0x0,
            EXTENDEDKEY = 0x0001,
            KEYUP = 0x0002,
            SCANCODE = 0x0008,
            UNICODE = 0x0004
        }

        [Flags]
        internal enum MOUSEEVENTF : uint
        {
            ABSOLUTE = 0x8000,
            HWHEEL = 0x01000,
            MOVE = 0x0001,
            MOVE_NOCOALESCE = 0x2000,
            LEFTDOWN = 0x0002,
            LEFTUP = 0x0004,
            RIGHTDOWN = 0x0008,
            RIGHTUP = 0x0010,
            MIDDLEDOWN = 0x0020,
            MIDDLEUP = 0x0040,
            VIRTUALDESK = 0x4000,
            WHEEL = 0x0800,
            XDOWN = 0x0080,
            XUP = 0x0100
        }

        [StructLayout(LayoutKind.Sequential)] /* Master Input structure */
        public struct lpInput {
            internal InputType type;
            internal InputUnion Data;
            internal static int Size { get { return Marshal.SizeOf(typeof(lpInput)); } }            
        }
        [StructLayout(LayoutKind.Explicit)] /* Union structure */
        internal struct InputUnion {
            [FieldOffset(0)]
            internal MOUSEINPUT mi;
            [FieldOffset(0)]
            internal KEYBDINPUT ki;
            [FieldOffset(0)]
            internal HARDWAREINPUT hi;
        }

        [StructLayout(LayoutKind.Sequential)] /* Input Types */
        internal struct MOUSEINPUT
        {
            internal int dx;
            internal int dy;
            internal int mouseData;
            internal MOUSEEVENTF dwFlags;
            internal uint time;
            internal UIntPtr dwExtraInfo;
        }

        [StructLayout(LayoutKind.Sequential)]
        internal struct KEYBDINPUT
        {
            internal short wVk;
            internal short wScan;
            internal KEYEVENTF dwFlags;
            internal int time;
            internal UIntPtr dwExtraInfo;
        }

        [StructLayout(LayoutKind.Sequential)]
        internal struct HARDWAREINPUT
        {
            internal int uMsg;
            internal short wParamL;
            internal short wParamH;
        }

        private class unmanaged {
            [DllImport("user32.dll", SetLastError = true)]
            internal static extern uint SendInput (
                uint cInputs, 
                [MarshalAs(UnmanagedType.LPArray)]
                lpInput[] inputs,
                int cbSize
            );

            [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
            public static extern short VkKeyScan(char ch);
        }

        internal static uint SendInput(uint cInputs, lpInput[] inputs, int cbSize) {
            return unmanaged.SendInput(cInputs, inputs, cbSize);
        }

        public static void SendKeyStroke() {
            lpInput[] KeyInputs = new lpInput[2];
            lpInput KeyInput = new lpInput();
            /* Generic Keyboard Event */
            KeyInput.type = InputType.INPUT_KEYBOARD;
            KeyInput.Data.ki.wScan = 0;
            KeyInput.Data.ki.time = 0;
            KeyInput.Data.ki.dwExtraInfo = UIntPtr.Zero;
            /* Emulate keypress */
            KeyInput.Data.ki.wVk = 13; /* VK_RETURN */
            KeyInput.Data.ki.dwFlags = KEYEVENTF.KEYDOWN;
            KeyInputs[0] = KeyInput;
            KeyInput.Data.ki.wVk = 13; /* VK_RETURN */
            KeyInput.Data.ki.dwFlags = KEYEVENTF.KEYUP;
            KeyInputs[1] = KeyInput;
            
            SendInput(2, KeyInputs, lpInput.Size);
            return;
            }
    }
"@

    [Synthesize_Keystrokes]::SendKeyStroke() <# Dismiss ConEmu's fast configuration window by hitting enter #>
################################################################################################################### 
#                                                                                                                 #
#  Finish installation and some app specific tweaks                                                               #
#                                                                                                                 #
###################################################################################################################
    <# easy access to 7z #>
    iex "$env:ProgramData\\chocolatey\\tools\\shimgen.exe --output=`"$env:ProgramData`"\\chocolatey\\bin\\7z.exe --path=`"$env:ProgramW6432`"\\7-zip\\7z.exe"
    <# put winetricks.ps1 and codesnippets in ProgramData\\Chocolatey-for-wine #>
    Copy-Item -Path "$(Join-Path $args[0] 'winetricks.ps1')" "$env:ProgramData\\Chocolatey-for-wine"
    Copy-Item -Path "$(Join-Path $args[0] 'EXTRAS' 'powershell_collected_codesnippets_examples.ps1')" "$env:ProgramData\\Chocolatey-for-wine"
    <# This makes Astro Photography Tool happy #>
    foreach($i in 'regasm.exe') { 
        Copy-Item -Path $env:systemroot\\Microsoft.NET\\Framework\\v4.0.30319\\$i -Destination $env:systemroot\\Microsoft.NET\\Framework\\v2.0.50727\\$i
        Copy-Item -Path $env:systemroot\\Microsoft.NET\\Framework64\\v4.0.30319\\$i -Destination $env:systemroot\\Microsoft.NET\\Framework\\v2.0.50727\\$i}
    <# Many programs need arial and native d3dcompiler_47, so install it #>
    foreach($i in 'arial.ttf', 'ariali.ttf', 'arialbi.ttf', 'arialbd.ttf') { <# fixme?: also install arial32b.exe (ariblk.ttf "Arial Black)??? #>
        Start-Process $env:ProgramW6432\\7-zip\\7z.exe -NoNewWindow -Wait -ArgumentList "e $env:TEMP\\arial32.exe -o$env:systemroot\Fonts $i -aoa" } 
        Start-Process $env:ProgramW6432\\7-zip\\7z.exe -NoNewWindow -Wait -ArgumentList "e $env:TEMP\\sevenzipextractor.1.0.17.nupkg -o$env:systemroot\\system32\\WindowsPowerShell\\v1.0  lib/netstandard2.0/SevenZipExtractor.dll -aoa"
    Copy-Item -Path "$env:TMP\\d3dcompiler_47_32.dll" -Destination "$env:SystemRoot\\SysWOW64\\d3dcompiler_47.dll" -Force
    Copy-Item -Path "$env:TMP\\d3dcompiler_47_32.dll" -Destination "$env:SystemRoot\\SysWOW64\\d3dcompiler_43.dll" -Force
    Copy-Item -Path "$env:TMP\\d3dcompiler_47.dll" -Destination "$env:SystemRoot\\System32\\d3dcompiler_47.dll" -Force
    Copy-Item -Path "$env:TMP\\d3dcompiler_47.dll" -Destination "$env:SystemRoot\\System32\\d3dcompiler_43.dll" -Force
    <# Backup files if wanted #>
    if (Test-Path 'env:SAVEINSTALLFILES') { 
        New-Item -Path "$env:WINEHOMEDIR\.cache\".substring(4) -Name "choc_install_files" -ItemType "directory" -ErrorAction SilentlyContinue
        foreach($i in 'ndp48-x86-x64-allos-enu.exe', 'PowerShell-7.1.5-win-x64.msi', 'arial32.exe', 'd3dcompiler_47.dll', 'd3dcompiler_47_32.dll', 'windows6.1-kb958488-v6001-x64_a137e4f328f01146dfa75d7b5a576090dee948dc.msu', '7z2201-x64.exe', 'sevenzipextractor.1.0.17.nupkg') {
            Copy-Item -Path $env:TEMP\\$i -Destination "$env:WINEHOMEDIR\.cache\choc_install_files\".substring(4)  -force }
    }
    <# install wine robocopy and (custom) wine tasksch.dll #>
    Copy-Item -Path "$env:TMP\\robocopy64.exe" -Destination "$env:SystemRoot\\System32\\robocopy.exe" -Force
    Copy-Item -Path "$env:TMP\\robocopy32.exe" -Destination "$env:SystemRoot\\syswow64\\robocopy.exe" -Force
    Copy-Item -Path "$env:TMP\\taskschd64.dll" -Destination "$env:SystemRoot\\System32\\taskschd.dll" -Force
    Copy-Item -Path "$env:TMP\\taskschd32.dll" -Destination "$env:SystemRoot\\syswow64\\taskschd.dll" -Force

    <# Replace some system programs by functions (in profile.ps1); This also makes wusa a dummy program: we don`t want windows updates and it doesn`t work anyway #>
    ForEach ($file in "schtasks.exe") {
        Copy-Item -Path "$env:windir\\SysWOW64\\$file" -Destination "$env:windir\\SysWOW64\\QPR.$file" -Force
        Copy-Item -Path "$env:winsysdir\\$file" -Destination "$env:winsysdir\\QPR.$file" -Force}
    ForEach ($file in "wusa.exe","schtasks.exe","systeminfo.exe","getmac.exe","setx.exe","wbem\\wmic.exe", "ie4uinit.exe") {
        Copy-Item -Path "$env:windir\\SysWOW64\\WindowsPowerShell\\v1.0\\powershell.exe" -Destination "$env:windir\\SysWOW64\\$file" -Force
        Copy-Item -Path "$env:winsysdir\\WindowsPowerShell\\v1.0\\powershell.exe" -Destination "$env:winsysdir\\$file" -Force}
    <# It seems some programs need this dir?? #>
    New-Item -Path "$env:LOCALAPPDATA" -Name "Temp" -ItemType "directory" -ErrorAction SilentlyContinue
    <# Native Access needs this dir #>
    New-Item -Path "$env:Public" -Name "Downloads" -ItemType "directory" -ErrorAction SilentlyContinue
    <# a game launcher tried to open this key, i think it should be present (?) #>
    reg.exe COPY "HKLM\SYSTEM\CurrentControlSet" "HKLM\SYSTEM\ControlSet001" /s /f
    <# dxvk (if installed) doesn't work well with WPF, add workaround from dxvk site  #>
    
$dxvkconf = @"
[pwsh.exe]
d3d9.shaderModel = 1

[ps51.exe]
d3d9.shaderModel = 1
"@
    $dxvkconf | Out-File -FilePath $env:ProgramData\\dxvk.conf

#    Start-Process $env:systemroot\Microsoft.NET\Framework64\v4.0.30319\ngen.exe -NoNewWindow -Wait -ArgumentList  "eqi"
#    Start-Process $env:systemroot\Microsoft.NET\Framework\v4.0.30319\ngen.exe -NoNewWindow -Wait -ArgumentList "eqi"
