################################################################################################################### 
#                                                                                                                 #
#  Miscellaneous registry keys                                                                                    #
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

'@
################################################################################################################### 
#                                                                                                                 #
#  profile.ps1: Put workarounds/hacks here. It goes into Program Files\\Powershell\\7\\profile.ps1                #
#                                                                                                                 #
###################################################################################################################
$profile_ps1 = @'
#Put workarounds/hacks here.../Adjust to your own needs. It goes into c:\\Program Files\\Powershell\\7\\profile.ps1

#Remove ~/Documents/Powershell/Modules from modulepath; it becomes a mess because it`s not removed when one deletes the wineprefix... 
$path = $env:PSModulePath -split ';'
$env:PSModulePath  = ( $path | Select-Object -Skip 1 | Sort-Object -Unique) -join ';'

$profile = '$env:ProgramFiles\PowerShell\7\profile.ps1'

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
Function Get-WmiObject([parameter(mandatory)] [string]$class, [string[]]$property="*", `
                       [string]$computername = "localhost", [string]$namespace = "root\cimv2", `
                       [string]$filter)
{   <# Do not remove or change, it will break Chocolatey #>
    $ConnectionOptions = new-object System.Management.ConnectionOptions
    $assembledpath = "\\" + $computername + "\" + $namespace
    
    $Scope = new-object System.Management.ManagementScope $assembledpath, $ConnectionOptions
    $Scope.Connect() 
    
    $querystring = "SELECT " +  $property + " FROM " + $class
    $query = new-object System.Management.ObjectQuery $querystring
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

Function Get-CIMInstance ( [parameter(position=0)] [string]$classname, [string[]]$property="*")
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
     if (!([System.IO.File]::Exists("$env:systemdrive\\winetricks.ps1"))){
         (New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/winetricks.ps1', "$env:systemdrive\\winetricks.ps1")
     }
     pwsh -f  $( Join-Path ${env:\\systemdrive} "winetricks.ps1")   $args
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
    $spl = $args.Split(" ")
    if ($args | Select-string '/CREATE') { <# Just execute this stuff instantly #>
        Start-Process $spl[$spl.IndexOf("/TR") + 1] } <# hack for Spotify #>
    else {
        Start-Process -Wait -NoNewWindow QPR.schtasks.exe $args }
}

Set-Alias "QPR.$env:systemroot\system32\wbem\wmic.exe" QPR_wmic; Set-Alias QPR.wmic.exe QPR_wmic; Set-Alias QPR.wmic QPR_wmic
function QPR_wmic { <# wmic replacement #>
    [CmdletBinding()]
        Param([parameter(Position=0)][string]$alias,
        [parameter(Position=1)][string]$option, <# only 'get' supported, param not used at all a.t.m. #>
        [parameter(Position=2)][string[]]$property="*")

    $hash = @{
        'os' = "win32_operatingsystem"
        'bios' = "win32_bios"
        'logicaldisk' = "win32_logicaldisk"
        'process' = "win32_process" } <# etc. etc. #>

    foreach ($key in $hash.keys) {
         if($alias -eq $key) {$class = $hash[$key];} }
    <# Syntax example from NopowerShell: "gwmi "Select ProcessId,Name,CommandLine From Win32_Process" #>
    $query = 'Select' + ' ' + ($property -join ',') + ' ' + 'From' + ' ' + $class
    #get-wmiobject win32_logicaldisk |where @"deviceid"='c:'" |select-object freespace
    NoPowerShell.exe Get-WMIObject "$query" 
} 
#Easy access to the C# compiler
Set-Alias csc c:\windows\Microsoft.NET\Framework\v4.0.30319\csc.exe

function apply_conemu_hack { New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\ConEmu64.exe\\DllOverrides' -force -Name 'user32' -Value 'native' -PropertyType 'String' && Stop-Process -name conemu64 && Stop-Process -name conemuC64 && Start-Process "powershell" -NoNewWindow }
function handy_apps { choco install explorersuite reactos-paint}
'@
################################################################################################################### 
#                                                                                                                 #
#  Install ConEmu, Chocolatey, dotnet48, arial, d3dcompiler_47 and a few extras (nopowershell and wine robocopy)  #
#                                                                                                                 #
###################################################################################################################

    (New-Object System.Net.WebClient).DownloadFile('https://conemu.github.io/install2.ps1', $(Join-Path "$env:TEMP" 'install2.ps1') )
    Invoke-Expression  $(cat $(Join-Path "$env:TEMP" 'install2.ps1') | Select-string 'url_7za =')  <# Get the 7za.exe downloadlink from install2.ps1 file #>
    (New-Object System.Net.WebClient).DownloadFile($url_7za, $(Join-Path "$env:TEMP" '7za.exe') )

    <# fragile test... If install files already present skip downloads. Run choc_installer once with 'SAVEINSTALLFILES=1' to cache downloads #>
    if (!(Test-Path -Path "$env:WINEHOMEDIR\.cache\choc_install_files\netfx_Full_x64.msi".substring(4) -PathType Leaf)) { <# First download/extract/install dotnet48 as job, this takes most time #>
        (New-Object System.Net.WebClient).DownloadFile('https://download.visualstudio.microsoft.com/download/pr/7afca223-55d2-470a-8edc-6a1739ae3252/abd170b4b0ec15ad0222a809b761a036/ndp48-x86-x64-allos-enu.exe', $(Join-Path "$env:TEMP" 'ndp48-x86-x64-allos-enu.exe') )
        start-threadjob -throttle 2 -ScriptBlock {[System.Threading.Thread]::CurrentThread.Priority = 'Highest'; Start-Process -FilePath $env:TEMP\\7za.exe -NoNewWindow -ArgumentList  "x -x!*.cab -ms190M $env:TEMP\\ndp48-x86-x64-allos-enu.exe -o$env:TEMP"}
        start-threadjob -throttle 2 -ScriptBlock {  while(!(Test-Path -Path "$env:TEMP\1025") ) {Sleep 0.25} ;[System.Threading.Thread]::CurrentThread.Priority = 'Highest'; &{ c:\\windows\\system32\\msiexec.exe  /i $env:TEMP\\netfx_Full_x64.msi EXTUI=1 /sfxlang:1033 /q /norestart} }

       $url = @('http://download.windowsupdate.com/msdownload/update/software/crup/2010/06/windows6.1-kb958488-v6001-x64_a137e4f328f01146dfa75d7b5a576090dee948dc.msu', `
                 'https://mirrors.kernel.org/gentoo/distfiles/arial32.exe', `
                 'https://mirrors.kernel.org/gentoo/distfiles/arialb32.exe', `
                 'https://github.com/mozilla/fxc2/raw/master/dll/d3dcompiler_47.dll', `
                 'https://github.com/mozilla/fxc2/raw/master/dll/d3dcompiler_47_32.dll' `
                 ) `
       <# Download stuff #>
       $url | ForEach-Object { Write-Host -ForeGroundColor Yellow "Downloading $PSItem" && (New-Object System.Net.WebClient).DownloadFile($PSItem, $(Join-Path "$env:TEMP" ($PSItem  -split '/' | Select-Object -Last 1)))}; `
       <# Extract stuff we need for quick dotnet40 install, only mscoree (probably)#>
       Start-Process -FilePath $env:TEMP\\7za.exe -NoNewWindow -Wait -ArgumentList  "x $env:TEMP\\windows6.1-kb958488-v6001-x64_a137e4f328f01146dfa75d7b5a576090dee948dc.msu -o$env:TEMP\\dotnet40 Windows6.1-KB958488-x64.cab"; `
       Start-Process -FilePath $env:TEMP\\7za.exe -NoNewWindow -Wait -ArgumentList  "x $env:TEMP\\dotnet40\\Windows6.1-KB958488-x64.cab -o$env:TEMP\\dotnet40 x86_netfx-mscoree_dll_31bf3856ad364e35_6.2.7600.16513_none_7daed23956119a9f/mscoree.dll"; `
       Start-Process -FilePath $env:TEMP\\7za.exe -NoNewWindow -Wait -ArgumentList  "x $env:TEMP\\dotnet40\\Windows6.1-KB958488-x64.cab -o$env:TEMP\\dotnet40 amd64_netfx-mscoree_dll_31bf3856ad364e35_6.2.7600.16513_none_d9cd6dbd0e6f0bd5/mscoree.dll";`
       Start-Process -FilePath $env:TEMP\\7za.exe -NoNewWindow -Wait -ArgumentList  "x $(Join-Path $args[0] 'EXTRAS\wine_robocopy.7z') -o$env:TEMP"; `
       Start-Process -FilePath $env:TEMP\\7za.exe -NoNewWindow -Wait -ArgumentList  "x $(Join-Path $args[0] 'EXTRAS\wine_user32_for_conemu_hack_for_wine7_9.7z') -o$env:TEMP" `


       & $env:TEMP\\install2.ps1  <# ConEmu install #>
       $C_TMP = $env:TEMP
    }
    else {
        $C_TMP = "$env:WINEHOMEDIR\.cache\choc_install_files\".substring(4)
        & $env:TEMP\\install2.ps1   <# ConEmu install #>
        &{c:\\windows\\system32\\msiexec.exe  /i $C_TMP\\netfx_Full_x64.msi EXTUI=1 /sfxlang:1033 /q /norestart} ;Get-Process 'msiexec' -ErrorAction:SilentlyContinue | Foreach-Object { $_.WaitForExit()}
    }
    
    $misc_reg | Out-File $env:TEMP\\misc.reg
    $profile_ps1 | Out-File $env:TEMP\\profile.ps1
    $profile_ps1 | Out-File $(Join-Path $(Split-Path -Path (Get-Process -Id $pid).Path) "profile.ps1") <# Write profile.ps1 to Powershell directory #>

    <# Install Chocolatey #>
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    <# This makes Astro Photography Tool happy #>
    foreach($i in 'regasm.exe') { 
        Copy-Item -Path $env:systemroot\\Microsoft.NET\\Framework\\v4.0.30319\\$i -Destination $env:systemroot\\Microsoft.NET\\Framework\\v2.0.50727\\$i
        Copy-Item -Path $env:systemroot\\Microsoft.NET\\Framework64\\v4.0.30319\\$i -Destination $env:systemroot\\Microsoft.NET\\Framework\\v2.0.50727\\$i}
      <# Many programs need arial and native d3dcompiler_47, so install it #>
    start-threadjob -throttle 2 -ScriptBlock {Start-Process -FilePath "$C_TMP\\arial32.exe" -Wait -ArgumentList  "-q" }
    start-threadjob -throttle 2 -ScriptBlock {Start-Process -FilePath "$C_TMP\\arialb32.exe" -Wait -ArgumentList  "-q" }

    <# dotnet40: we (probably) only need mscoree.dll from winetricks dotnet40 recipe, so just copy it and write registry values from it`s manifest file. This saves quite some time!#>
    Copy-Item -Path "$C_TMP\\dotnet40\\x86_netfx-mscoree_dll_31bf3856ad364e35_6.2.7600.16513_none_7daed23956119a9f/mscoree.dll" -Destination "$env:systemroot\\syswow64\\" -Force
    Copy-Item -Path "$C_TMP\\dotnet40\\amd64_netfx-mscoree_dll_31bf3856ad364e35_6.2.7600.16513_none_d9cd6dbd0e6f0bd5/mscoree.dll" -Destination "$env:systemroot\\system32\\" -Force
    <# Import reg keys: keys from mscoree manifest files, tweaks to advertise compability with lower .Net versions, and set some native dlls #>
    Get-job |wait-job;        Get-Process '7za' -ErrorAction:SilentlyContinue | Foreach-Object { $_.WaitForExit() } 
    reg.exe  IMPORT  $C_TMP\\misc.reg /reg:64
    reg.exe  IMPORT  $C_TMP\\misc.reg /reg:32      

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

    <# fragile test...; Download and 'install' NoPowerShell.exe which has some extra Powershell cmdlets #>
    if (!(Test-Path -Path "$env:WINEHOMEDIR\.cache\choc_install_files\netfx_Full_x64.msi".substring(4) -PathType Leaf)) {
        (New-Object System.Net.WebClient).DownloadFile('https://github.com/bitsadmin/nopowershell/releases/download/1.23/NoPowerShell_trunk.zip', $(Join-Path "$env:TEMP" 'NoPowerShell_trunk.zip') )
        Start-Process -FilePath $env:TEMP\\7za.exe -NoNewWindow -Wait -ArgumentList  "x $env:TEMP\\NoPowerShell_trunk.zip Dotnet45/* -o$env:TEMP"}
    Copy-Item "$C_TMP\\DOTNET45\\*.*" "$env:SystemRoot\\system32\\WindowsPowershell\\v1.0\\"
    <# Backup files if wanted #>
    if (Test-Path 'env:SAVEINSTALLFILES') { 
        New-Item -Path "$env:WINEHOMEDIR\.cache\".substring(4) -Name "choc_install_files" -ItemType "directory" -ErrorAction SilentlyContinue
        Copy-Item -Recurse -Path $env:TEMP\\* -Destination "$env:WINEHOMEDIR\.cache\choc_install_files\".substring(4)  -force
    }
    <# wine robocopy and hack for ConEmu #>
    Copy-Item -Path "$C_TMP\\robocopy64.exe" -Destination "$env:SystemRoot\\System32\\robocopy.exe" -Force
    Copy-Item -Path "$C_TMP\\robocopy32.exe" -Destination "$env:SystemRoot\\syswow64\\robocopy.exe" -Force
    Copy-Item -Path "$C_TMP\\user32_32.dll" -Destination "$env:SystemDrive\\ConEmu\\user32.dll" -Force

    Copy-Item -Path "$C_TMP\\d3dcompiler_47_32.dll" -Destination "$env:SystemRoot\\SysWOW64\\d3dcompiler_47.dll" -Force
    Copy-Item -Path "$C_TMP\\d3dcompiler_47_32.dll" -Destination "$env:SystemRoot\\SysWOW64\\d3dcompiler_43.dll" -Force
    Copy-Item -Path "$C_TMP\\d3dcompiler_47.dll" -Destination "$env:SystemRoot\\System32\\d3dcompiler_47.dll" -Force
    Copy-Item -Path "$C_TMP\\d3dcompiler_47.dll" -Destination "$env:SystemRoot\\System32\\d3dcompiler_43.dll" -Force
    <# Replace some system programs by functions (in profile.ps1); This also makes wusa a dummy program: we don`t want windows updates and it doesn`t work anyway #>
    ForEach ($file in "schtasks.exe") {
        Copy-Item -Path "$env:windir\\SysWOW64\\$file" -Destination "$env:windir\\SysWOW64\\QPR.$file" -Force
        Copy-Item -Path "$env:winsysdir\\$file" -Destination "$env:winsysdir\\QPR.$file" -Force}
    ForEach ($file in "wusa.exe","tasklist.exe","schtasks.exe","systeminfo.exe","wbem\\wmic.exe") {
        Copy-Item -Path "$env:windir\\SysWOW64\\WindowsPowerShell\\v1.0\\powershell.exe" -Destination "$env:windir\\SysWOW64\\$file" -Force
        Copy-Item -Path "$env:winsysdir\\WindowsPowerShell\\v1.0\\powershell.exe" -Destination "$env:winsysdir\\$file" -Force}
    <# It seems some programs need this dir?? #>
    New-Item -Path "$env:LOCALAPPDATA" -Name "Temp" -ItemType "directory" -ErrorAction SilentlyContinue
