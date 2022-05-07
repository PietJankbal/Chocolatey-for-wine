#Put workarounds/hacks here.../Adjust to your own needs. It goes into c:\\Program Files\\Powershell\\7\\profile.ps1

#Remove ~/Documents/Powershell/Modules from modulepath; it becomes a mess because it`s not removed when one deletes the wineprefix... 
$path = $env:PSModulePath -split ';'
$env:PSModulePath  = ( $path | Select-Object -Skip 1 | Sort-Object -Unique) -join ';'

$profile = '$env:ProgramFiles\PowerShell\7\profile.ps1'

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

 Set-Alias Get-CIMInstance Get-WMIObject
 
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
function Get-NetIPAddress   { NoPowerShell.exe Get-NetIPAddress $args  }
function Get-NetRoute       { NoPowerShell.exe Get-NetRoute $args       }
function Test-NetConnection { NoPowerShell.exe Test-NetConnection $args }
function Get-Computerinfo   { NoPowerShell.exe Get-Computerinfo $args }

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

Set-Alias "QPR.$env:systemroot\system32\winebrowser.exe" QPR_iex; Set-Alias QPR.winebrowser.exe QPR_iex; Set-Alias QPR.winebrowser QPR_iex
function QPR_iex { <# winebrowser replacement #>
    if (!([System.IO.File]::Exists("$env:ProgramFiles\Google\Chrome\Application\Chrome.exe"))){ choco install googlechrome}
    $newargs =  $args # +'--no-sandbox', not needed anymore as of wine-7.8 
    Start-Process -NoNewWindow -Wait $env:ProgramFiles\Google\Chrome\Application\Chrome.exe $newargs
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

Set-Alias "QPR.$env:systemroot\system32\wmic.exe" QPR_wmic; Set-Alias QPR.wmic.exe QPR_wmic; Set-Alias QPR.wmic QPR_wmic
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

    NoPowerShell.exe Get-WMIObject "$query" 
} 
#Easy access to the C# compiler
Set-Alias csc c:\windows\Microsoft.NET\Framework\v4.0.30319\csc.exe

function apply_conemu_hack { New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\ConEmu.exe\\DllOverrides' -force -Name 'user32' -Value 'native' -PropertyType 'String' && Stop-Process -name conemu && Stop-Process -name conemuC64 && Start-Process "powershell" -NoNewWindow }
function handy_apps { choco install explorersuite reactos-paint}
