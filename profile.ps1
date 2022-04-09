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
    
    if (!$filter) {
        return $searcher.get() 
    }
    else {
        $hashtable = ConvertFrom-StringData -StringData $filter
        return $searcher.get() | where $hashtable.Keys -eq $hashtable.Values
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
    if (!([System.IO.File]::Exists("$env:systemdrive\\ProgramData\\chocolatey\\bin\\busybox64.exe "))){ choco install Busybox -y}
}

<# A few Unix commands I find handy, just remove stuff below if you don`t want it #>
function du   { check_busybox; Busybox64.exe du $args}
function df   { check_busybox; Busybox64.exe df $args}
function wget { check_busybox; Busybox64.exe wget $args}
function grep { check_busybox; Busybox64.exe grep $args}
function bash { check_busybox; Busybox64.exe bash $args}

function winetricks {
     if (!([System.IO.File]::Exists("$env:systemdrive\\winetricks.ps1"))){
         (New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/winetricks.ps1', "$env:systemdrive\\winetricks.ps1")
     }
     pwsh -f  $( Join-Path ${env:\\systemdrive} "winetricks.ps1")   $args
}

# Query program replacement for wusa.exe; Do not remove or change, it will break Chocolatey
Set-Alias wusa.exe.QPR c:\windows\system32\wusa.exe.QPR; Set-Alias wusa.QPR c:\windows\system32\wusa.exe.QPR
function c:\windows\system32\wusa.exe.QPR {
     Write-Host "This is wusa dummy doing nothing..."
     exit 0;
}
# Note: Following overrides wine(-staging)`s tasklist so remove stuff below if you don`t want that, and remove native override in winecfg 
Set-Alias tasklist.exe.QPR c:\windows\system32\tasklist.exe.QPR; Set-Alias tasklist.QPR c:\windows\system32\tasklist.exe.QPR
function c:\windows\system32\tasklist.exe.QPR {    
    Get-WmiObject win32_process "processid,name" | Format-Table -Property Name, processid -autosize
}

Set-Alias "$env:systemroot\system32\iexplore.exe.QPR" iex_path; Set-Alias iexplore.exe.QPR iex_path; Set-Alias iexplore.QPR iex_path
Set-Alias "$env:systemroot\system32\winebrowser.exe.QPR" iex_path; Set-Alias winebrowser.exe.QPR iex_path; Set-Alias winebrowser.QPR iex_path
function iex_path {    
    if (!([System.IO.File]::Exists("$env:ProgramFiles\Google\Chrome\Application\Chrome.exe"))){ choco install googlechrome}
    $newargs =  $args +'--no-sandbox' 
    Start-Process -NoNewWindow -Wait $env:ProgramFiles\Google\Chrome\Application\Chrome.exe $newargs
}
# This is how to intercept any non-wine executable (here csc.exe), at least if the exe is not smart enough to detect it
# For csc.exe it would go like this:  cd ~/.wine/drive_c/windows/Microsoft.NET/Framework/v4.0.30319/
# 1. Backup the real exe with right suffix:
#     cp -rf ./csc.exe ./csc.exe.QPR
# 2. Copy dummy over the real exe (take care whether it`s 64 or 32-bit, here 32-bit exe is replaced):
#     cp -rf ~/.wine/drive_c/windows/syswow64/WindowsPowerShell/v1.0/powershell.exe ./csc.exe 
# Now we can intercept the program like below (for convenience the copying of fake csc.exe is already done during installation;)
Set-Alias csc.exe c:\windows\Microsoft.NET\Framework\v4.0.30319\csc.exe.QPR; Set-Alias csc c:\windows\Microsoft.NET\Framework\v4.0.30319\csc.exe.QPR
function c:\windows\Microsoft.NET\Framework\v4.0.30319\csc.exe.QPR {    
    Add-Type -AssemblyName PresentationCore,PresentationFramework; [System.Windows.MessageBox]::Show('Intercepted call!','Congrats','ok','exclamation')
    # Might manipulate commandline arguments here, or return whatever hack you want. For now just continue.
    Start-Process -NoNewWindow -Wait c:\windows\Microsoft.NET\Framework\v4.0.30319\csc.exe.QPR $args
} <# try 'wine csc.exe' or just 'csc' from powershell console to test #>
