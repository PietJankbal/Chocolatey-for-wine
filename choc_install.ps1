################################################################################################################### 
#                                                                                                                 #
#  Miscellaneous registry keys, mainly from mscoree manifest so we can skip dotnet40 install                      #
#                                                                                                                 #
###################################################################################################################
$misc_reg = @'
REGEDIT4

[HKEY_CURRENT_USER\Software\Wine\DllOverrides]
"mscorwks"="native"
"mscoree"="native"
"d3dcompiler_47"="native"
"d3dcompiler_43"="native"
"wusa.exe"="native"
"tasklist.exe"="native"
"schtasks.exe"="native"
"taskschd"="native"
"robocopy.exe"="native"
"systeminfo.exe"="native"
"wmic.exe"="native"

[HKEY_CURRENT_USER\Software\Wine\AppDefaults\conemu64.exe]

[HKEY_CURRENT_USER\Software\Wine\AppDefaults\conemu64.exe\DllOverrides]
"dwmapi"=""
"user32"="builtin"

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

[HKEY_CLASSES_ROOT\CCWU.ComCallWrapper.1\CLSID]
@="{3F281000-E95A-11d2-886B-00C04F869F04}"

[HKEY_CLASSES_ROOT\CCWU.ComCallWrapper.1]
@="Com Call Wrapper Unmarshal Class"

[HKEY_CLASSES_ROOT\CCWU.ComCallWrapper\CLSID]
@="{3F281000-E95A-11d2-886B-00C04F869F04}"

[HKEY_CLASSES_ROOT\CCWU.ComCallWrapper]
@="Com Call Wrapper Unmarshal Class"

[HKEY_CLASSES_ROOT\CCWU.ComCallWrapper\CurVer]
@="CCWU.ComCallWrapper.1"

[HKEY_CLASSES_ROOT\CLSID\{1D2680C9-0E2A-469d-B787-065558BC7D43}\Implemented Categories\{62C8FE65-4EBB-45E7-B440-6E39B2CDBF29}]

[HKEY_CLASSES_ROOT\CLSID\{1D2680C9-0E2A-469d-B787-065558BC7D43}]
"InfoTip"=".NET Framework Assemblies"
@="Fusion Cache"

[HKEY_CLASSES_ROOT\CLSID\{1D2680C9-0E2A-469d-B787-065558BC7D43}\InprocServer32]
@="c:\\windows\\system32\\mscoree.dll"
"ThreadingModel"="Apartment"

[HKEY_CLASSES_ROOT\CLSID\{1D2680C9-0E2A-469d-B787-065558BC7D43}\Server]
@="Shfusion.dll"

[HKEY_CLASSES_ROOT\CLSID\{1D2680C9-0E2A-469d-B787-065558BC7D43}\shellex\ContextMenuHandlers\{1D2680C9-0E2A-469d-B787-065558BC7D43}]

[HKEY_CLASSES_ROOT\CLSID\{1D2680C9-0E2A-469d-B787-065558BC7D43}\ShellFolder]
"Attributes"=hex:00,01,10,F0

[HKEY_CLASSES_ROOT\CLSID\{1EC2DE53-75CC-11d2-9775-00A0C9B4D50C}\Implemented Categories\{62C8FE65-4EBB-45E7-B440-6E39B2CDBF29}]

[HKEY_CLASSES_ROOT\CLSID\{1EC2DE53-75CC-11d2-9775-00A0C9B4D50C}\NotInsertable]

[HKEY_CLASSES_ROOT\CLSID\{3F281000-E95A-11d2-886B-00C04F869F04}]
@="Com Call Wrapper Unmarshal Class"

[HKEY_CLASSES_ROOT\CLSID\{3F281000-E95A-11d2-886B-00C04F869F04}\Implemented Categories\{62C8FE65-4EBB-45E7-B440-6E39B2CDBF29}]

[HKEY_CLASSES_ROOT\CLSID\{3F281000-E95A-11d2-886B-00C04F869F04}\InprocServer32]
"ThreadingModel"="Both"
@="c:\\windows\\system32\\mscoree.dll"

[HKEY_CLASSES_ROOT\CLSID\{3F281000-E95A-11d2-886B-00C04F869F04}\NotInsertable]

[HKEY_CLASSES_ROOT\CLSID\{3F281000-E95A-11d2-886B-00C04F869F04}\ProgID]
@="CCWU.ComCallWrapper.1"

[HKEY_CLASSES_ROOT\CLSID\{3F281000-E95A-11d2-886B-00C04F869F04}\VersionIndependentProgID]
@="CCWU.ComCallWrapper"

[HKEY_CLASSES_ROOT\CLSID\{CB2F6723-AB3A-11d2-9C40-00C04FA30A3E}\Implemented Categories\{62C8FE65-4EBB-45E7-B440-6E39B2CDBF29}]

[HKEY_CLASSES_ROOT\CLSID\{CB2F6723-AB3A-11d2-9C40-00C04FA30A3E}]
@="Microsoft Common Language Runtime Meta Data"

[HKEY_CLASSES_ROOT\CLSID\{CB2F6723-AB3A-11d2-9C40-00C04FA30A3E}\NotInsertable]

[HKEY_CLASSES_ROOT\CLSID\{E5CB7A31-7512-11D2-89CE-0080C792E5D8}\Implemented Categories\{62C8FE65-4EBB-45E7-B440-6E39B2CDBF29}]

[HKEY_CLASSES_ROOT\CLSID\{E5CB7A31-7512-11D2-89CE-0080C792E5D8}]
"MasterVersion"=dword:0x00000002

[HKEY_CLASSES_ROOT\CLSID\{E5CB7A31-7512-11D2-89CE-0080C792E5D8}\NotInsertable]

[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{0A29FF9E-7F9C-4437-8B11-F424491E3931}\InprocServer32]
@="C:\\Windows\\System32\\mscoree.dll"
"ThreadingModel"="Both"

[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{0A29FF9E-7F9C-4437-8B11-F424491E3931}]
@="NDP SymBinder"

[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{0A29FF9E-7F9C-4437-8B11-F424491E3931}\ProgID]
@="CorSymBinder_SxS"

[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{0A29FF9E-7F9C-4437-8B11-F424491E3931}\Server]
@="diasymreader.dll"

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Eventlog\Application\.NET Runtime]
"TypesSupported"=dword:0x00000007

[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Fonts]
"Arial (TrueType)"="arial.ttf"
"Arial Bold (TrueType)"="arialbd.ttf"
"Arial Bold Italic (TrueType)"="arialbi.ttf"
"Arial Italic (TrueType)"="ariali.ttf"

[HKEY_CURRENT_USER\Software\Wine\Debug]
"RelayExclude"="user32.CharNextA;KERNEL32.GetProcessHeap;KERNEL32.GetCurrentThreadId;KERNEL32.TlsGetValue;KERNEL32.GetCurrentThreadId;KERNEL32.TlsSetValue;ntdll.RtlEncodePointer;ntdll.RtlDecodePointer;ntdll.RtlEnterCriticalSection;ntdll.RtlLeaveCriticalSection;kernel32.94;kernel32.95;kernel32.96;kernel32.97;kernel32.98;KERNEL32.TlsGetValue;KERNEL32.FlsGetValue;ntdll.RtlFreeHeap;ntdll.RtlAllocateHeap;KERNEL32.InterlockedDecrement;KERNEL32.InterlockedCompareExchange;ntdll.RtlTryEnterCriticalSection;KERNEL32.InitializeCriticalSection;ntdll.RtlDeleteCriticalSection;KERNEL32.InterlockedExchange;KERNEL32.InterlockedIncrement;KERNEL32.LocalFree;Kernel32.LocalAlloc;ntdll.RtlReAllocateHeap;KERNEL32.VirtualAlloc;Kernel32.VirtualFree;Kernel32.HeapFree;KERNEL32.QueryPerformanceCounter;KERNEL32.QueryThreadCycleTime;ntdll.RtlFreeHeap;ntdll.memmove;ntdll.memcmp;KERNEL32.GetTickCount"
"RelayFromExclude"="winex11.drv;user32;gdi32;advapi32;kernel32"

'@
################################################################################################################### 
#                                                                                                                 #
#  profile.ps1: Put workarounds/hacks here. It goes into c:\\Program Files\\Powershell\\7\\profile.ps1            #
#                                                                                                                 #
###################################################################################################################
$profile_ps1 = @'
#Put workarounds/hacks here.../Adjust to your own needs. It goes into c:\\Program Files\\Powershell\\7\\profile.ps1

#Remove ~/Documents/Powershell/Modules from modulepath; it becomes a mess because it`s not removed when one deletes the wineprefix... 
$path = $env:PSModulePath -split ';'
$env:PSModulePath  = ( $path | Select-Object -Skip 1 | Sort-Object -Unique) -join ';'

$profile = '$env:ProgramFiles\PowerShell\7\profile.ps1'

$host.ui.RawUI.WindowTitle = 'This is Powershell Core (pwsh.exe), not (!) powershell.exe'

#Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

# Enable Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

#Register-WMIEvent not available in PS Core, so for now just change into noop
function Register-WMIEvent {
    exit 0
}

#Based on Get-WmiCustom by Daniele Muscetta, so credits to aforementioned author (https://www.powershellgallery.com/packages/Traverse/0.6/Content/Private%5CGet-WMICustom.ps1)
#Only works as of wine-6.20 ( https://bugs.winehq.org/show_bug.cgi?id=51871) e.g. (new-object System.Management.ManagementObjectSearcher("SELECT * FROM Win32_Bios")).Get().manufacturer failed before
#Examples of usage: Get-WmiObject win32_operatingsystem version or $(Get-WmiObject win32_videocontroller).name etc.
#TODO: very short: ([wmiclass]"\\.\root\cimv2:win32_bios").GetInstances()
Function Get-WmiObject([parameter(mandatory=$true, position = 0, parametersetname = 'class')] [string]$class, `
                       [parameter( position = 1, parametersetname = 'class')][string[]]$property="*", `
                       [string]$computername = "localhost", [string]$namespace = "root\cimv2", `
                       [string]$filter, [parameter(parametersetname = 'query')] [string]$query)
{   <# Do not remove or change, it will break Chocolatey #>
    $ConnectionOptions = new-object System.Management.ConnectionOptions
    $assembledpath = "\\" + $computername + "\" + $namespace
    
    $Scope = new-object System.Management.ManagementScope $assembledpath, $ConnectionOptions
    $Scope.Connect() 

    if(!$query) {    
        $querystring = "SELECT " +  $($property | Join-String -Separator ",") + " FROM " + $class }
    else {
        $querystring = $query}

    $queryobj = new-object System.Management.ObjectQuery $querystring
    $searcher = new-object System.Management.ManagementObjectSearcher
    $searcher.Query = $querystring
    $searcher.Scope = $Scope 

    [System.Management.ManagementObjectCollection]$result = $searcher.get()

    if (!$filter) {
        return $result 
    }
    else {
        $hashtable = ConvertFrom-StringData -StringData $filter
        return $result | where $hashtable.Keys -eq $hashtable.Values
    }
}

Function Get-CIMInstance ( [parameter(mandatory)] [string]$classname, [string[]]$property="*")
{
     Get-WMIObject $classname -property $property
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
 <# hack for installing adobereader #>
function  Unregister-ScheduledTask { Write-Host 'cmdlet Unregister-ScheduledTask not available in PS 7, doing nothing...'; return}

function check_busybox {
    if (!([System.IO.File]::Exists("$env:systemdrive\\ProgramData\\chocolatey\\bin\\busybox64.exe "))){ choco install Busybox -y }
}

<# A few Unix commands I find handy, just remove stuff below if you don`t want it #>
function du   { check_busybox; Busybox64.exe du $args}
function df   { check_busybox; Busybox64.exe df $args}
function wget { check_busybox; Busybox64.exe wget $args}
function grep { check_busybox; Busybox64.exe grep $args}
function bash { check_busybox; Busybox64.exe bash $args}
<# A few from NoPowerShell, Powershell Core does't have these #>
function Resolve-DnsName    { NoPowerShell.exe Resolve-DnsName $args    }
function Invoke-WmiMethod   { NoPowerShell.exe Invoke-WmiMethod $args   }
function Get-NetIPAddress   { NoPowerShell.exe Get-NetIPAddress $args   }
function Get-NetRoute       { NoPowerShell.exe Get-NetRoute $args       }
function Test-NetConnection { NoPowerShell.exe Test-NetConnection $args }
function Get-Computerinfo   { NoPowerShell.exe Get-Computerinfo $args   }

function winetricks {
     if (!([System.IO.File]::Exists("$env:ProgramData\\winetricks.ps1"))){
         Add-Type -AssemblyName PresentationCore,PresentationFramework;
         [System.Windows.MessageBox]::Show("winetricks script is missing`nplease reinstall it in c:\\ProgramData",'Congrats','ok','exclamation')
     }
     pwsh -f  $( Join-Path ${env:\\ProgramData} "winetricks.ps1")   $args
}

# Query program replacement for wusa.exe; Do not remove or change, it will break Chocolatey
Set-Alias "QPR.$env:systemroot\system32\wusa.exe" QPR_wusa; Set-Alias QPR.wusa.exe QPR_wusa; Set-Alias QPR.wusa QPR_wusa
function QPR_wusa { <# wusa.exe replacement #>
     Write-Host "This is wusa dummy doing nothing..."
     exit 0;
}

# Note: Following overrides wine(-staging)`s tasklist so remove stuff below if you don`t want that, and remove native override in winecfg 
Set-Alias "QPR.$env:systemroot\system32\tasklist.exe" QPR_tl; Set-Alias QPR.tasklist.exe QPR_tl; Set-Alias QPR.tasklist QPR_tl
function QPR_tl { <# tasklist.exe replacement #>
    Get-WmiObject win32_process "processid,name" | Format-Table -Property Name, processid -autosize
}

# Note: Visual Studio calls this, not sure if this is really needed by it... 
Set-Alias "QPR.$env:systemroot\system32\getmac.exe" QPR_gm; Set-Alias QPR.getmac.exe QPR_gm; Set-Alias QPR.getmac QPR_gm
function QPR_gm { <# getmac.exe replacement #>
    Get-WmiObject win32_networkadapterconfiguration | Format-Table @{L=’Physical address’;E={$_.macaddress}}
}

Set-Alias "QPR.$env:systemroot\system32\setx.exe" QPR_stx; Set-Alias QPR.setx.exe QPR_stx; Set-Alias QPR.setx QPR_stx
function QPR_stx { <# setx.exe replacement #>
    <# FIXME, only setting env. variable handled atm. #>
    New-ItemProperty -Path 'HKLM:\\System\\CurrentControlSet\\Control\\Session Manager\\Environment' -force -Name $args[0] -Value $args[1] -PropertyType 'String' 
    New-ItemProperty -Path 'HKCU:\\Environment' -force -Name $args[0] -Value $args[1] -PropertyType 'String' 
    $env:QPREXITCODE=0;
}

function use_google_as_browser { <# replace winebrowser with google chrome to open webpages #>
    if (!([System.IO.File]::Exists("$env:ProgramFiles\Google\Chrome\Application\Chrome.exe"))){ choco install googlechrome}

$regkey = @"
REGEDIT4
[HKEY_CLASSES_ROOT\https\shell\open\command]
@="\"%ProgramFiles%\\Google\\Chrome\\Application\\chrome.exe\" \"%1\""
[HKEY_CLASSES_ROOT\http\shell\open\command]
@="\"%ProgramFiles%\\Google\\Chrome\\Application\\chrome.exe\" \"%1\""
"@
    $regkey | Out-File -FilePath $env:TEMP\\regkey.reg
    reg.exe  IMPORT  $env:TEMP\\regkey.reg /reg:64;
    reg.exe  IMPORT  $env:TEMP\\regkey.reg /reg:32;
}

Set-Alias "QPR.$env:systemroot\system32\systeminfo.exe" QPR_si; Set-Alias QPR.systeminfo.exe QPR_si; Set-Alias QPR.systeminfo QPR_si
function QPR_si { <# systeminfo replacement #>
    NoPowerShell.exe systeminfo
}

#If passing back (manipulated) arguments back to the same program, make sure to backup a copy (here QPR.schtasks.exe, copied during installation)
Set-Alias "QPR.$env:systemroot\system32\schtasks.exe" QPR_stsk; Set-Alias QPR.schtasks.exe QPR_stsk; Set-Alias QPR.schtasks QPR_stsk
function QPR_stsk { <# schtasks.exe replacement #>
    $spl = $($env:QPRCMDLINE.Split('"'' ''"').Trim('"')).replace('/silent','') <# hack for Spotify #>

    if ($env:QPRCMDLINE | Select-string '"/CREATE"') {Write-Host <# Just execute this stuff instantly #>
        Start-Process  $spl[$spl.IndexOf('/TR') + 1].replace('''','') } <# hack for Spotify #>
    else { $env:QPRCMDLINE.Split('"'' ''"').Trim().Trim('"') 
        Start-Process -Wait -NoNewWindow QPR.schtasks.exe $env:QPRCMDLINE.Split('" "').Trim().Trim('"') }
}

Set-Alias "QPR.$env:systemroot\system32\wbem\wmic.exe" QPR_wmic; Set-Alias QPR.wmic.exe QPR_wmic
function QPR_wmic { <# wmic replacement, this part only rebuilds the arguments #>

    $hash = @{
        'os' = "win32_operatingsystem"
        'bios' = "win32_bios"
        'logicaldisk' = "win32_logicaldisk"
        'process' = "win32_process" } <# etc. etc. #>

    for($i = 0; $i -lt $args.count; $i++) {
        if ($args[$i][0] -ne '/') {
            if ($args[$i-1] -and $args[$i-1] -eq '/PATH') {$class = $args[$i];}
            else { $alias = $args[$i];  }
        $idx = $i;
        break;
        }
        $idx
    }
 
    foreach ($key in $hash.keys) {
        if($alias -eq $key) {$class = $hash[$key];}
    }

    $cmdline = '-class ' + $class + ' '

    for($i = 0; $i -lt $args.count; $i++) {
        if ($args[$i][0] -eq '/') { $cmdline += ($args[$i] -creplace '/','-' -creplace ':',' '''); if( $args[$i].Contains(':') ) {$cmdline += ''' ' } else  {$cmdline += ' '}}
        elseif ($args[$i] -eq 'get') { $cmdline += '-property' + ' ' }
        elseif ($i -eq $idx) {}
        #elseif ($i -eq 'where') { $cmdline += '-where' + ' ' + 'where'} <# FIXME #>
        else {$cmdline += $args[$i] + ' '} }

    iex  -Command ('_wmic ' + $cmdline)
} 

function _wmic { <# wmic replacement #>
    [CmdletBinding()]
    Param([parameter(Position=0)][string]$class,
    [string[]]$property="*",
    #[string]$where,
    [string[]]$node,
    [string[]]$failfast,
    [switch]$path<#dummy #>,
    [parameter(ValueFromRemainingArguments=$true)]$vars)

    $query = 'Select' + ' ' + ($property -join ',') + ' ' + 'From' + ' ' + $class + ' ' + $vars
    #get-wmiobject win32_logicaldisk |where @"deviceid"='c:'" |select-object freespace
    if($property -eq '*'){ <# 'get-wmiobject $class | select *' does not work because of wine-bug, so need a workaround:  #>
        Get-WmiObject $class ($($(Get-WmiObject $class |Get-Member) |where {$_.membertype -eq 'property'}).name |Join-String -Separator ',') }
    else {
        Get-WMIObject -query $query }
} 
#Easy access to the C# compiler
Set-Alias csc c:\windows\Microsoft.NET\Framework\v4.0.30319\csc.exe

function apply_conemu_hack {
    Copy-Item $env:SystemRoot\\system32\\user32.dll $env:SystemRoot\\system32\\user32dummy.dll -force
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\ConEmu64.exe\\DllOverrides' -force -Name 'user32' -Value 'native' -PropertyType 'String' 
    Stop-Process -name conemu64 -erroraction silentlycontinue ; Stop-Process -name conemuC64 -erroraction silentlycontinue 
    Start-Process "powershell" -NoNewWindow
}

function handy_apps { choco install explorersuite reactos-paint}
'@
################################################################################################################################ 
#                                                                                                                              #
#  Install dotnet48, ConEmu, Chocolatey, 7z, arial, d3dcompiler_47 and a few extras (nopowershell and wine robocopy+taskschd)  #
#                                                                                                                              #
################################################################################################################################   
#   Invoke-Expression  $(cat $(Join-Path "$env:TEMP" 'install2.ps1') | Select-string 'url_7za =')  <# Get the 7za.exe downloadlink from install2.ps1 file #>
#   (New-Object System.Net.WebClient).DownloadFile($url_7za, $(Join-Path "$env:TEMP" '7za.exe') )
    (New-Object System.Net.WebClient).DownloadFile('https://d3.7-zip.org/a/7z2201-x64.exe', $(Join-Path "$env:TEMP" '7z2201-x64.exe') )
    iex "$(Join-Path "$env:TEMP" '7z2201-x64.exe') /S"; while(!(Test-Path -Path "$env:ProgramW6432\\7-zip\\7z.exe") ) {Sleep 0.25}

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
             'https://conemu.github.io/install2.ps1' `
                 ) `

    <# Download stuff #>
    $url | ForEach-Object { Write-Host -ForeGroundColor Yellow "Downloading $PSItem" && (New-Object System.Net.WebClient).DownloadFile($PSItem, $(Join-Path "$env:TEMP" ($PSItem  -split '/' | Select-Object -Last 1)))}; `
    <# Extract stuff we need for quick dotnet40 install, only mscoree (probably)#>
    Start-Process -FilePath $env:ProgramW6432\\7-zip\\7z.exe -NoNewWindow -Wait -ArgumentList  "x $env:TEMP\\windows6.1-kb958488-v6001-x64_a137e4f328f01146dfa75d7b5a576090dee948dc.msu -o$env:TEMP\\dotnet40 Windows6.1-KB958488-x64.cab"; `
    Start-Process -FilePath $env:ProgramW6432\\7-zip\\7z.exe -NoNewWindow -Wait -ArgumentList  "x $env:TEMP\\dotnet40\\Windows6.1-KB958488-x64.cab -o$env:TEMP\\dotnet40 x86_netfx-mscoree_dll_31bf3856ad364e35_6.2.7600.16513_none_7daed23956119a9f/mscoree.dll"; `
    Start-Process -FilePath $env:ProgramW6432\\7-zip\\7z.exe -NoNewWindow -Wait -ArgumentList  "x $env:TEMP\\dotnet40\\Windows6.1-KB958488-x64.cab -o$env:TEMP\\dotnet40 amd64_netfx-mscoree_dll_31bf3856ad364e35_6.2.7600.16513_none_d9cd6dbd0e6f0bd5/mscoree.dll";`
    Start-Process -FilePath $env:ProgramW6432\\7-zip\\7z.exe -NoNewWindow -Wait -ArgumentList  "x $(Join-Path $args[0] 'EXTRAS\wine_robocopy.7z') -o$env:TEMP";
    Start-Process -FilePath $env:ProgramW6432\\7-zip\\7z.exe -NoNewWindow -Wait -ArgumentList  "x $(Join-Path $args[0] 'EXTRAS\wine_taskschd.7z') -o$env:TEMP";
    Start-Process -FilePath $env:ProgramW6432\\7-zip\\7z.exe -NoNewWindow -Wait -ArgumentList  "x $(Join-Path $args[0] 'EXTRAS\wine_user32_for_conemu_hack_for_wine7_16.7z') -o$env:TEMP" `

    <# dotnet40: we (probably) only need mscoree.dll from winetricks dotnet40 recipe, so just copy it and write registry values from it`s manifest file. This saves quite some time!#>
    Copy-Item -Path "$env:TMP\\dotnet40\\x86_netfx-mscoree_dll_31bf3856ad364e35_6.2.7600.16513_none_7daed23956119a9f/mscoree.dll" -Destination "$env:systemroot\\syswow64\\" -Force
    Copy-Item -Path "$env:TMP\\dotnet40\\amd64_netfx-mscoree_dll_31bf3856ad364e35_6.2.7600.16513_none_d9cd6dbd0e6f0bd5/mscoree.dll" -Destination "$env:systemroot\\system32\\" -Force

    & $env:TEMP\\install2.ps1  <# ConEmu install #>
    
    $misc_reg | Out-File $env:TEMP\\misc.reg
    $profile_ps1 | Out-File $env:TEMP\\profile.ps1
    $profile_ps1 | Out-File $(Join-Path $(Split-Path -Path (Get-Process -Id $pid).Path) "profile.ps1") <# Write profile.ps1 to Powershell directory #>

    <# Install Chocolatey #>
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    <# Import reg keys: keys from mscoree manifest files, tweaks to advertise compability with lower .Net versions, and set some native dlls #>
    Get-job |wait-job; 
    Get-Process '7z' -ErrorAction:SilentlyContinue | Foreach-Object { $_.WaitForExit() } 
    reg.exe  IMPORT  $env:TMP\\misc.reg /reg:64
    reg.exe  IMPORT  $env:TMP\\misc.reg /reg:32      

    <# do not use chocolatey's builtin powershell host #>
    cd c:\; c:\\ProgramData\\chocolatey\\choco.exe feature disable --name=powershellHost; winecfg /v win10
    c:\\ProgramData\\chocolatey\\choco.exe feature enable -n allowGlobalConfirmation <# to confirm automatically (no -y needed) #>
    # Add-Type -AssemblyName PresentationCore,PresentationFramework; [System.Windows.MessageBox]::Show('Chocolatey installed','Congrats','ok','exclamation')
    # choco install tccle -y; & "$env:ProgramFiles\\JPSoft\\TCCLE14x64\\tcc.exe" "$env:ProgramFiles\\JPSoft\\TCCLE14x64\\tccbatch.btm"; <># cmd.exe replacement #
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

    <# Dismiss ConEmu's fast configuration window by hitting enter #>
    [Synthesize_Keystrokes]::SendKeyStroke()

    iex "$env:ProgramData\\chocolatey\\tools\\shimgen.exe --output=`"$env:ProgramData`"\\chocolatey\\bin\\7z.exe --path=`"$env:ProgramW6432`"\\7-zip\\7z.exe"

    Copy-Item -Path "$(Join-Path $args[0] 'winetricks.ps1')" "$env:ProgramData"
    <# This makes Astro Photography Tool happy #>
    foreach($i in 'regasm.exe') { 
        Copy-Item -Path $env:systemroot\\Microsoft.NET\\Framework\\v4.0.30319\\$i -Destination $env:systemroot\\Microsoft.NET\\Framework\\v2.0.50727\\$i
        Copy-Item -Path $env:systemroot\\Microsoft.NET\\Framework64\\v4.0.30319\\$i -Destination $env:systemroot\\Microsoft.NET\\Framework\\v2.0.50727\\$i}
    <# Many programs need arial and native d3dcompiler_47, so install it #>
    foreach($i in 'arial.ttf', 'ariali.ttf', 'arialbi.ttf', 'arialbd.ttf') { <# fixme?: also install arial32b.exe (ariblk.ttf "Arial Black)??? #>
        Start-Process $env:ProgramW6432\\7-zip\\7z.exe -NoNewWindow -Wait -ArgumentList "e $env:TEMP\\arial32.exe -o$env:systemroot\Fonts $i -aoa" } 
    Copy-Item -Path "$env:TMP\\d3dcompiler_47_32.dll" -Destination "$env:SystemRoot\\SysWOW64\\d3dcompiler_47.dll" -Force
    Copy-Item -Path "$env:TMP\\d3dcompiler_47_32.dll" -Destination "$env:SystemRoot\\SysWOW64\\d3dcompiler_43.dll" -Force
    Copy-Item -Path "$env:TMP\\d3dcompiler_47.dll" -Destination "$env:SystemRoot\\System32\\d3dcompiler_47.dll" -Force
    Copy-Item -Path "$env:TMP\\d3dcompiler_47.dll" -Destination "$env:SystemRoot\\System32\\d3dcompiler_43.dll" -Force

    <# fragile test...; Download and 'install' NoPowerShell.exe which has some extra Powershell cmdlets #>
    if (!(Test-Path -Path "$env:WINEHOMEDIR\.cache\choc_install_files\netfx_Full_x64.msi".substring(4) -PathType Leaf)) {
        (New-Object System.Net.WebClient).DownloadFile('https://github.com/bitsadmin/nopowershell/releases/download/1.23/NoPowerShell_trunk.zip', $(Join-Path "$env:TEMP" 'NoPowerShell_trunk.zip') )
        Start-Process -FilePath $env:ProgramW6432\\7-zip\\7z.exe -NoNewWindow -Wait -ArgumentList  "x $env:TEMP\\NoPowerShell_trunk.zip Dotnet45/* -o$env:TEMP"}
    Copy-Item "$env:TMP\\DOTNET45\\*.*" "$env:SystemRoot\\system32\\WindowsPowershell\\v1.0\\"
    <# Backup files if wanted #>
    if (Test-Path 'env:SAVEINSTALLFILES') { 
        New-Item -Path "$env:WINEHOMEDIR\.cache\".substring(4) -Name "choc_install_files" -ItemType "directory" -ErrorAction SilentlyContinue
        Copy-Item -Recurse -Path $env:TEMP\\ndp48-x86-x64-allos-enu.exe -Destination "$env:WINEHOMEDIR\.cache\choc_install_files\".substring(4)  -force
        Copy-Item -Recurse -Path $env:TEMP\\PowerShell-7.0.3-win-x64.msi -Destination "$env:WINEHOMEDIR\.cache\choc_install_files\".substring(4)  -force
    }
    <# wine robocopy and hack for ConEmu #>
    Copy-Item -Path "$env:TMP\\robocopy64.exe" -Destination "$env:SystemRoot\\System32\\robocopy.exe" -Force
    Copy-Item -Path "$env:TMP\\robocopy32.exe" -Destination "$env:SystemRoot\\syswow64\\robocopy.exe" -Force
    Copy-Item -Path "$env:TMP\\taskschd64.dll" -Destination "$env:SystemRoot\\System32\\taskschd.dll" -Force
    Copy-Item -Path "$env:TMP\\taskschd32.dll" -Destination "$env:SystemRoot\\syswow64\\taskschd.dll" -Force
    Copy-Item -Path "$env:TMP\\user32.dll" -Destination "$env:SystemDrive\\ConEmu\\user32.dll" -Force

    <# Replace some system programs by functions (in profile.ps1); This also makes wusa a dummy program: we don`t want windows updates and it doesn`t work anyway #>
    ForEach ($file in "schtasks.exe") {
        Copy-Item -Path "$env:windir\\SysWOW64\\$file" -Destination "$env:windir\\SysWOW64\\QPR.$file" -Force
        Copy-Item -Path "$env:winsysdir\\$file" -Destination "$env:winsysdir\\QPR.$file" -Force}
    ForEach ($file in "wusa.exe","tasklist.exe","schtasks.exe","systeminfo.exe","getmac.exe","setx.exe","wbem\\wmic.exe") {
        Copy-Item -Path "$env:windir\\SysWOW64\\WindowsPowerShell\\v1.0\\powershell.exe" -Destination "$env:windir\\SysWOW64\\$file" -Force
        Copy-Item -Path "$env:winsysdir\\WindowsPowerShell\\v1.0\\powershell.exe" -Destination "$env:winsysdir\\$file" -Force}
    <# It seems some programs need this dir?? #>
    New-Item -Path "$env:LOCALAPPDATA" -Name "Temp" -ItemType "directory" -ErrorAction SilentlyContinue
    <# Native Access needs this dir #>
    New-Item -Path "$env:Public" -Name "Downloads" -ItemType "directory" -ErrorAction SilentlyContinue
