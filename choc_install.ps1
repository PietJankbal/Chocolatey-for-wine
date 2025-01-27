################################################################################################################### 
#                                                                                                                 #
#  Miscellaneous registry keys, a few from mscoree manifest so we can skip dotnet40 install                       #
#                                                                                                                 #
###################################################################################################################
@'
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
"wmic.exe"="native"
"ngen.exe"="native"
"version"="native,builtin" ;Bug 29678
"shdocvw"="native,builtin" ;Bug 20777
"riched20"="native,builtin" ;Bug 14980
"winhttp"="native,builtin" ;Bug 47053
"packager"="native,builtin" ;Bug 43472
"d3d8"="native,builtin" ;Bug 47120

[HKEY_CURRENT_USER\Software\Wine\AppDefaults\conemu64.exe]
"Version"="win81"

[HKEY_CURRENT_USER\Software\Wine\AppDefaults\conemu64.exe\DllOverrides]
"dwmapi"=""
"user32"="native, builtin"

[HKEY_CURRENT_USER\Software\Wine\AppDefaults\pwsh.exe]

[HKEY_CURRENT_USER\Software\Wine\AppDefaults\pwsh.exe\DllOverrides]
"amsi"=""
"dwmapi"=""

[HKEY_CURRENT_USER\Software\ConEmu\.Vanilla]
"CmdLine"="%ProgramFiles%\\Powershell\\7\\pwsh.exe"
"ColorTable00"=dword:00562401
"ColorTable14"=dword:0000ffff

[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\{DE293FDE-C181-46C0-8DCC-1F75EA35833D}]
"DisplayName"="ConEmu 230724.x64"
"DisplayVersion"="11.230.7240"
"Publisher"="ConEmu-Maximus5"
 

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

[HKEY_CURRENT_USER\Software\Wine\Debug]
"RelayExclude"="user32.CharNextA;KERNEL32.GetProcessHeap;KERNEL32.GetCurrentThreadId;KERNEL32.TlsGetValue;KERNEL32.GetCurrentThreadId;KERNEL32.TlsSetValue;ntdll.RtlEncodePointer;ntdll.RtlDecodePointer;ntdll.RtlEnterCriticalSection;ntdll.RtlLeaveCriticalSection;kernel32.94;kernel32.95;kernel32.96;kernel32.97;kernel32.98;KERNEL32.TlsGetValue;KERNEL32.FlsGetValue;ntdll.RtlFreeHeap;ntdll.RtlAllocateHeap;KERNEL32.InterlockedDecrement;KERNEL32.InterlockedCompareExchange;ntdll.RtlTryEnterCriticalSection;KERNEL32.InitializeCriticalSection;ntdll.RtlDeleteCriticalSection;KERNEL32.InterlockedExchange;KERNEL32.InterlockedIncrement;KERNEL32.LocalFree;Kernel32.LocalAlloc;ntdll.RtlReAllocateHeap;KERNEL32.VirtualAlloc;Kernel32.VirtualFree;Kernel32.HeapFree;KERNEL32.QueryPerformanceCounter;KERNEL32.QueryThreadCycleTime;ntdll.RtlFreeHeap;ntdll.memmove;ntdll.memcmp;KERNEL32.GetTickCount;kernelbase.InitializeCriticalSectionEx;ntdll.RtlInitializeCriticalSectionEx;ntdll.RtlInitializeCriticalSection;kernelbase.FlsGetValue"
"RelayFromExclude"="winex11.drv;user32;gdi32;advapi32;kernel32"
'@ | Out-File $env:TEMP\\misc.reg
<# FIXME these keys are different from regular winetricks dotnet48 install????
[HKEY_CLASSES_ROOT\CLSID\{E5CB7A31-7512-11D2-89CE-0080C792E5D8}]
"MasterVersion"=dword:0x00000002
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Eventlog\Application\.NET Runtime]
"TypesSupported"=dword:0x00000007 #>
################################################################################################################### 
#                                                                                                                 #
#  profile.ps1: Put workarounds/hacks here. It goes into c:\\Program Files\\Powershell\\7\\profile.ps1            #
#                                                                                                                 #
###################################################################################################################
@'
#Put workarounds/hacks here.../Adjust to your own needs. It goes into c:\\Program Files\\Powershell\\7\\profile.ps1

$host.ui.RawUI.WindowTitle = 'This is Powershell Core (pwsh.exe), not (!) powershell.exe'

$profile = "$env:ProgramFiles\PowerShell\7\profile.ps1"

. "$env:ProgramData\\Chocolatey-for-wine\\profile_essentials.ps1"

'@ | Out-File ( New-Item -Path $(Join-Path $(Split-Path -Path (Get-Process -Id $pid).Path) "profile.ps1") -Force)<# Write profile.ps1 to Powershell directory #>
################################################################################################################################ 
#                                                                                                                              #
#  profile_essentials_ps1: essential functions/settings for Chocolatey-for-wine to work properly                               #
#                                                                                                                              #
################################################################################################################################   
@'
<# This contains essential functions/settings for Chocolatey-for-wine to work properly, do not remove or change #>
cd c:\; 

$env:DXVK_CONFIG_FILE=("$env:WINECONFIGDIR" + "\" + "drive_c" + "\" + ($env:ProgramData |split-path -leaf) + "\" + "dxvk.conf").substring(6) -replace "\\","/"

# Enable Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

<# if powershell is started without args let's start conemu, but not if redirected or from pipe ( like 'powershell < a.ps1'  or '"echo hello" | powershell') #>
$MethodDefinition = @"
    public enum  FSINFOCLASS
        {
            FileFsDeviceInformation = 4,
        }

    //https://stackoverflow.com/questions/69192954/how-to-add-and-use-a-c-sharp-struct-in-powershell
    [StructLayout(LayoutKind.Sequential, Pack = 0)]
     public struct FILE_FS_DEVICE_INFORMATION {
         public uint DeviceType;
         public ulong Characteristics;
         // construct ahead 
         public FILE_FS_DEVICE_INFORMATION(uint dev, ulong chr) {
             this.DeviceType = dev;
             this.Characteristics = chr; 
        }
    }       

     [StructLayout(LayoutKind.Sequential, Pack = 0)]
     public struct IO_STATUS_BLOCK {
         public uint status;
         public IntPtr information;
         // construct ahead
         public IO_STATUS_BLOCK(uint stat, IntPtr inf) {
             this.status = stat;
             this.information = inf;
         }
     }

    [DllImport("ntdll.dll",  SetLastError=true)] public static extern long NtQueryVolumeInformationFile(IntPtr FileHandle,  ref IO_STATUS_BLOCK IoStatusBlock,ref FILE_FS_DEVICE_INFORMATION FsInformation, UInt32 Length, FSINFOCLASS FsInformationClass);
    [DllImport("ntdll.dll", CharSet = CharSet.Ansi)] public static extern string wine_get_version();
    [DllImport("ntdll.dll", CharSet = CharSet.Ansi)] public static extern string wine_get_build_id();
"@

$ntdll = Add-Type -MemberDefinition $MethodDefinition -Namespace '' -name 'ntdll' -PassThru

$MethodDefinition2 = @" 
    [DllImport("kernel32.dll", CharSet = CharSet.Unicode)] public static extern string GetCommandLineW();
    [DllImport("kernel32.dll", SetLastError = true)] public static extern IntPtr GetStdHandle(int nStdHandle);
"@

$kernel32 = Add-Type -MemberDefinition $MethodDefinition2 -Namespace '' -Name 'kernel32' -PassThru    

$h=[kernel32]::GetStdHandle(-10) <# (DWORD)-10 is STD_INPUT_HANDLE #>

$io = [ntdll+IO_STATUS_BLOCK]::new(0,0)
$info =[ntdll+FILE_FS_DEVICE_INFORMATION]::new(0,0)

$null=[ntdll]::NtQueryVolumeInformationFile($h,[ref]$io,[ref]$info,[System.Runtime.InteropServices.Marshal]::SizeOf($info),[ntdll+FSINFOCLASS]::FileFsDeviceInformation.value__ )

$parent = [System.Diagnostics.Process]::GetCurrentProcess().Parent

if(($parent.processname -eq 'powershell') -and  ( $kernel32::GetCommandLineW() -eq """$env:ProgramFiles\Powershell\7\pwsh.exe""") -and  ($info.DeviceType -eq 80) ) {
    Start-Process c:\\ConEmu\\conemu64 |Out-Null
    #Stop-process -id $parent.Id
    Stop-process -id  ([System.Diagnostics.Process]::GetCurrentProcess()).Id
}  <# end start ConEmu #>

if($([System.Diagnostics.Process]::GetCurrentProcess().Parent.processname) -eq 'ConEmuC64' ) {Write-Host "";Write-Host -Foregroundcolor yellow Running Power Shell Core $PSVersionTable.PSVersion.ToString() on ([ntdll]::wine_get_build_id()); Write-Host "";[system.console]::ForegroundColor='white'}

<# if wineprefix is updated by running another wine version we have to update the hack for ConEmu bug https://bugs.winehq.org/show_bug.cgi?id=48761 #>
if( !( (Get-FileHash C:\windows\system32\user32.dll).Hash -eq (Get-FileHash C:\windows\system32\user32dummy.dll).Hash) ) {
    Copy-Item $env:SystemRoot\\system32\\user32.dll $env:SystemRoot\\system32\\user32dummy.dll -force -erroraction silentlycontinue
}

#Easy access to the C# compiler
Set-Alias csc c:\windows\Microsoft.NET\Framework\v4.0.30319\csc.exe

Set-Alias gwmi Get-WmiObject
Set-Alias Get-CIMInstance Get-CIMInstance_replacement

<# winetricks: to support auto-tabcompletion only a comma seperated is supported when calling winetricks with multiple arguments, e.g. 'winetricks gdiplus,riched20' #>
[array]$Qenu = iex "$([IO.File]::Readalltext("$env:ProgramData\\Chocolatey-for-wine\\winetricks.ps1").Split('marker line!!!',3)[1])"
               
<# https://stackoverflow.com/questions/67356762/couldnt-use-predefined-array-inside-validateset-powershell #>
for ( $j = 0; $j -lt $Qenu.count; $j+=3) { [string[]]$verblist += $Qenu[$j+1] }

function winetricks {
  [CmdletBinding()]
  param(
    #[Parameter(Mandatory)]
    # Tab-complete based on array $verblist
    [ArgumentCompleter({
      param($cmd, $param, $wordToComplete) $verblist -like "$wordToComplete*"
    })]
    # Validate based on array $verblist.
    # NOTE: If validation fails, the (default) error message is unhelpful.
    #       You can work around that in *Windows PowerShell* with `throw`, and in
    #       PowerShell (Core) 7+, you can add an `ErrorMessage` property:
    #         [ValidateScript({ $_ -in $verblist }, ErrorMessage = 'Unknown value: {0}')]
    [ValidateScript({
      if ($_ -in $verblist) { return $true }
      throw "'$_' is not in the set of the supported values: $($verblist -join ', ')"
    })]
    $Arg
  )

  if (!([System.IO.File]::Exists("$env:ProgramData\\Chocolatey-for-wine\\winetricks.ps1"))){
      Add-Type -AssemblyName PresentationCore,PresentationFramework;
      [System.Windows.MessageBox]::Show("winetricks script is missing`nplease reinstall it in c:\\ProgramData\\Chocolatey-for-wine",'Congrats','ok','exclamation')
  }
  
  .   $([System.IO.Path]::Combine("$env:ProgramData","Chocolatey-for-wine", "winetricks.ps1")) $($arg -join ',')
  
#Remove ~/Documents/Powershell/Modules from modulepath; it becomes a mess because it`s not removed when one deletes the wineprefix... 
$path = $env:PSModulePath -split ';'
$env:PSModulePath  = ( $path | Select-Object -Skip 1 | Sort-Object -Unique) -join ';'
}
'@ | Out-File ( New-Item -Path $env:ProgramData\\Chocolatey-for-wine\\profile_essentials.ps1 -Force)
################################################################################################################################ 
#                                                                                                                              #
#  Install dotnet48, ConEmu, Chocolatey, 7z, d3dcompiler_47 and a few extras (wine robocopy + wine taskschd)                   #
#                                                                                                                              #
################################################################################################################################   
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
    $cachedir = "$env:WINEHOMEDIR\.cache\choc_install_files".substring(4)
    $setupcache = "$env:SystemRoot\\Microsoft.NET\\Framework64\\v4.0.30319\\SetupCache"

    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

    if ((Test-Path -Path "$cachedir\v4.8.03761\netfx_Full.mzz" -PathType Leaf)) {  $is_cached = 1} 

    if (!(Test-Path -Path "$cachedir\7z2407-x64.exe".substring(4) -PathType Leaf)) { 
        (New-Object System.Net.WebClient).DownloadFile('https://d3.7-zip.org/a/7z2407-x64.exe', $(Join-Path $setupcache '7z2407-x64.exe') ); $cachedir = $setupcache
    }

    iex "$(Join-Path "$cachedir" '7z2407-x64.exe') /S"; while(!(Test-Path -Path "$env:ProgramW6432\\7-zip\\7z.exe") ) {Sleep 0.25}
    $cachedir = "$env:WINEHOMEDIR\.cache\choc_install_files".substring(4);
    
    if (!$is_cached) { <# First download/extract/install dotnet48 as job, this takes most time #>
        (New-Object System.Net.WebClient).DownloadFile('https://download.visualstudio.microsoft.com/download/pr/7afca223-55d2-470a-8edc-6a1739ae3252/abd170b4b0ec15ad0222a809b761a036/ndp48-x86-x64-allos-enu.exe', $(Join-Path $setupcache 'ndp48-x86-x64-allos-enu.exe') )
         Start-Process -FilePath $env:ProgramW6432\\7-zip\\7z.exe -NoNewWindow -ArgumentList  "x -x!*.cab -x!netfx_c* -x!netfx_e* -x!NetFx4* -ms190M $env:SystemRoot\\Microsoft.NET\\Framework64\\v4.0.30319\\SetupCache\\ndp48-x86-x64-allos-enu.exe -o$env:SystemRoot\\Microsoft.NET\\Framework64\\v4.0.30319\\SetupCache\\v4.8.03761"
        while(!(Test-Path -Path "c:\\windows\\Microsoft.NET\\Framework64\\v4.0.30319\\SetupCache\\v4.8.03761\\1025") ) {Start-Sleep 0.25} ; &{ c:\\windows\\system32\\msiexec.exe /i c:\\windows\\Microsoft.NET\\Framework64\\v4.0.30319\\SetupCache\\v4.8.03761\\netfx_Full_x64.msi EXTUI=1  /sfxlang:1033 /q /norestart}
    }
    $url = @('http://download.windowsupdate.com/msdownload/update/software/crup/2010/06/windows6.1-kb958488-v6001-x64_a137e4f328f01146dfa75d7b5a576090dee948dc.msu', `
             'https://github.com/mozilla/fxc2/raw/master/dll/d3dcompiler_47.dll', `
             'https://github.com/mozilla/fxc2/raw/master/dll/d3dcompiler_47_32.dll', `
             'https://github.com/Maximus5/ConEmu/releases/download/v23.07.24/ConEmuPack.230724.7z', `
             'https://globalcdn.nuget.org/packages/sevenzipextractor.1.0.17.nupkg',
             'https://catalog.s.download.windowsupdate.com/msdownload/update/software/updt/2009/11/windowsserver2003-kb968930-x64-eng_8ba702aa016e4c5aed581814647f4d55635eff5c.exe'
             )
    <# Download stuff #>
    foreach($i in $url) {          `
         if (!(Test-Path -Path "$cachedir\$i.split('/')[-1]".substring(4) -PathType Leaf)) { 
              (New-Object System.Net.WebClient).DownloadFile($i, $(Join-Path "$setupcache" $i.split('/')[-1]) ); $cachedir = "$setupcache" 
         }
    }

    <# we probably only need this from regular dotnet40 install (???) #>
    iex "& ""wusa.exe""   ""$cachedir\\windows6.1-kb958488-v6001-x64_a137e4f328f01146dfa75d7b5a576090dee948dc.msu"""
    iex "& ""$env:ProgramW6432\\7-zip\\7z.exe"" x  ""$cachedir\ConEmuPack.230724.7z"" ""-o$env:SystemDrive\ConEmu""";
            
    foreach($i in $(Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*)) {
        if($i.DisplayName -match 'Mono') { Remove-Item -force  $i.PSPath -recurse  }
    }
    
    <# Import reg keys: keys from mscoree manifest files, tweaks to advertise compability with lower .Net versions, and set some native dlls #>
    reg.exe  IMPORT  $env:TMP\\misc.reg /reg:64
    reg.exe  IMPORT  $env:TMP\\misc.reg /reg:32 
    <# fix up the 'highlight selection'-hack for ConEmu #>
    Copy-Item $env:SystemRoot\\system32\\user32.dll $env:SystemRoot\\system32\\user32dummy.dll -force
    
    <# Install Chocolatey #>
#   $env:chocolateyVersion = '1.4.0'
#   iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    while(!(Test-path "$env:ProgramData\chocolatey") ) {start-Sleep 0.25};
    iex  "& ""$env:ProgramW6432\\7-zip\\7z.exe"" x  -x!""*resources.dll"" ""$cachedir\\windowsserver2003-kb968930-x64-eng_8ba702aa016e4c5aed581814647f4d55635eff5c.exe""  ""Microsoft.Powershell*.dll""   ""Microsoft.WSman*.dll"" ""system.management.automation.dll"" ""-o$env:ProgramData\chocolatey"""
    #Get-Process 'msiexec' -ErrorAction:SilentlyContinue | Foreach-Object { $_.WaitForExit() }
    New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{DE293FDE-C181-46C0-8DCC-1F75EA35833D}" -Name "InstallDate" -Value "$(Get-Date -Format FileDate)" -PropertyType 'String' -force
#   choco pin add -n chocolatey
    <# end install Chocolatey #>
    
    [System.Environment]::SetEnvironmentVariable("POWERSHELL_UPDATECHECK", 'Off','Machine')
    Remove-Item "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{92FB6C44-E685-45AD-9B20-CADF4CABA132} - 1033" -recurse -force

    # Add-Type -AssemblyName PresentationCore,PresentationFramework; [System.Windows.MessageBox]::Show('Chocolatey installed','Congrats','ok','exclamation')
    iex  "& ""$env:ProgramW6432\\7-zip\\7z.exe"" x  -spf ""$(Join-Path $args[0] 'c_drive.7z')"" -aoa";

    Start-Process "c:\conemu\conemu64" -ArgumentList " -NoUpdate -LoadRegistry -run %ProgramFiles%\\Powershell\\7\\pwsh.exe -noe -c Write-Host Installed Software: ; Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |? DisplayName| Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table ;"
################################################################################################################### 
#  All code below is only for sending a single keystroke (ENTER) to ConEmu's annoying                             #
#  fast configuration window to dismiss it...............                                                         #
#  Based on https://github.com/nylyst/PowerShell/blob/master/Send-KeyPress.ps1 -> so credits to that author       #
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
    
    while(!$p) {$p = Get-Process | Where-Object { $_.MainWindowTitle -Match "Conemu" }; Start-Sleep -Milliseconds 200}
    $h = $p[0].MainWindowHandle
    [void] [StartActivateProgramClass]::SetForegroundWindow($h)
    [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")  <# Dismiss ConEmu's fast configuration window by hitting enter #>
################################################################################################################### 
#                                                                                                                 #
#  Finish installation and some app specific tweaks                                                               #
#                                                                                                                 #
###################################################################################################################
    <# do not use chocolatey's builtin powershell host #>
    while(!(Test-path "$env:systemroot\\system32\\ucrtbase_clr0400.dll") ) {start-Sleep 0.50}
    cd c:\; c:\\ProgramData\\chocolatey\\choco.exe feature disable --name=powershellHost; winecfg /v win10
    c:\\ProgramData\\chocolatey\\choco.exe feature enable -n allowGlobalConfirmation <# to confirm automatically (no -y needed) #>
    <# easy access to 7z #>
    iex "$env:ProgramData\\chocolatey\\tools\\shimgen.exe --output=`"$env:ProgramData`"\\chocolatey\\bin\\7z.exe --path=`"$env:ProgramW6432`"\\7-zip\\7z.exe"
    Remove-Item -force -recurse "$env:systemroot\mono";
    <# This makes Astro Photography Tool happy #>
    foreach($i in 'regasm.exe') { 
        Copy-Item -Path $env:systemroot\\Microsoft.NET\\Framework\\v4.0.30319\\$i -Destination $env:systemroot\\Microsoft.NET\\Framework\\v2.0.50727\\$i
        Copy-Item -Path $env:systemroot\\Microsoft.NET\\Framework64\\v4.0.30319\\$i -Destination $env:systemroot\\Microsoft.NET\\Framework\\v2.0.50727\\$i
    }

    Start-Process $env:ProgramW6432\\7-zip\\7z.exe -NoNewWindow -Wait -ArgumentList "e $cachedir\\sevenzipextractor.1.0.17.nupkg -o$env:systemroot\\system32\\WindowsPowerShell\\v1.0  lib/netstandard2.0/SevenZipExtractor.dll -aoa"
    Copy-Item -Path "$cachedir\\d3dcompiler_47_32.dll" -Destination "$env:SystemRoot\\SysWOW64\\d3dcompiler_47.dll" -Force
    Copy-Item -Path "$cachedir\\d3dcompiler_47_32.dll" -Destination "$env:SystemRoot\\SysWOW64\\d3dcompiler_43.dll" -Force
    Copy-Item -Path "$cachedir\\d3dcompiler_47.dll" -Destination "$env:SystemRoot\\System32\\d3dcompiler_47.dll" -Force
    Copy-Item -Path "$cachedir\\d3dcompiler_47.dll" -Destination "$env:SystemRoot\\System32\\d3dcompiler_43.dll" -Force
    <# Backup files if wanted #>
    if (Test-Path 'env:SAVEINSTALLFILES') { 
        New-Item -Path "$env:WINEHOMEDIR\.cache\".substring(4) -Name "choc_install_files" -ItemType "directory" -ErrorAction SilentlyContinue
        foreach($i in 'PowerShell-7.4.5-win-x64.msi', 'd3dcompiler_47.dll', 'd3dcompiler_47_32.dll', 'windows6.1-kb958488-v6001-x64_a137e4f328f01146dfa75d7b5a576090dee948dc.msu', '7z2407-x64.exe', 'sevenzipextractor.1.0.17.nupkg', 'ConEmuPack.230724.7z', 'windowsserver2003-kb968930-x64-eng_8ba702aa016e4c5aed581814647f4d55635eff5c.exe') {
            Move-Item -Path "$setupcache\\$i" -Destination "$env:WINEHOMEDIR\.cache\choc_install_files\".substring(4) -force }
        #Copy-Item -Path "$env:TEMP\choc_inst_files\v4.8.03761" -Destination "$env:WINEHOMEDIR\.cache\choc_install_files\".substring(4) -recurse -force
        Move-Item -path  "$setupcache\\v4.8.03761" -destination "$env:WINEHOMEDIR\.cache\choc_install_files".substring(4);
    }
    <# Replace some system programs by functions; This also makes wusa a dummy program: we don`t want windows updates and it doesn`t work anyway #>
    ForEach ($file in "wusa","schtasks","getmac","setx","wbem\\wmic", "ie4uinit", "openfiles") {
        Move-Item -Path "$env:windir\\SysWOW64\\$($file + '.exe')" -Destination "$env:windir\\SysWOW64\\$($file + '.back.exe')" -Force -ErrorAction SilentlyContinue
        Move-Item -Path "$env:winsysdir\\$($file + '.exe')" -Destination "$env:winsysdir\\$($file + '.back.exe')" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$env:windir\\SysWOW64\\WindowsPowerShell\\v1.0\\powershell.exe" -Destination "$env:windir\\SysWOW64\\$($file + '.exe')" -Force
        Copy-Item -Path "$env:winsysdir\\WindowsPowerShell\\v1.0\\powershell.exe" -Destination "$env:winsysdir\\$($file + '.exe')" -Force}
    <# Native Access needs this dir #>
    New-Item -Path "$env:Public" -Name "Downloads" -ItemType "directory" -ErrorAction SilentlyContinue
    <# clean up #>
    Remove-Item $setupcache -force -recurse
    <# dxvk (if installed) doesn't work well with WPF, add workaround from dxvk site  #>
$dxvkconf = @"
[pwsh.exe]
d3d9.shaderModel = 1

[ps51.exe]
d3d9.shaderModel = 1
"@ | Out-File -FilePath $env:ProgramData\\dxvk.conf

@'
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
'@ | Out-File ( New-Item -Path $env:ProgramFiles\Powershell\7\Modules\Get-WmiObject\Get-WmiObject.psm1 -Force )

@'
Function Get-CIMInstance_replacement ( [parameter(mandatory)] [string]$classname, [string[]]$property="*", [string]$filter)
{
     Get-WMIObject $classname -property $property -filter $filter
}
'@ | Out-File ( New-Item -Path $env:ProgramFiles\Powershell\7\Modules\Get-CIMInstance_replacement\Get-CIMInstance_replacement.psm1 -Force )

@'
function QPR.wusa { <# wusa.exe replacement, Query program replacement for wusa.exe; Do not remove or change, it will break Chocolatey #>
     Write-Host "This is wusa dummy doing nothing..."
     exit 0;
}
'@ | Out-File ( New-Item -Path $env:ProgramFiles\Powershell\7\Modules\QPR.wusa\QPR.wusa.psm1 -Force )

@'
function QPR.schtasks { <# schtasks.exe replacement #>
    $cmdline = $($([kernel32]::GetCommandLineW()).Split(" ",3)[2]) #.SubString($env:QPRCMDLINE.IndexOf(" "), $env:QPRCMDLINE.Length - $env:QPRCMDLINE.IndexOf(" "))

    $cmdline = $cmdline -replace '/create', '-create' -replace '/tn', '-tn' -replace "/tr", "-tr" <#-replace "'", "'`"'"#>  <# escape quotes (??) #> `
                        -replace "/sc", "-sc" -replace "/run", "-run" -replace "/delete", "-delete"
    $cmdline
    iex  -Command ('QPR_schtasks ' + $cmdline)
} 

function QPR_schtasks { <# schtasks replacement #>
   # [CmdletBinding()]
    Param([switch]$create, [string]$tn, [string]$tr, [string]$sc, [switch]$run, [switch]$delete,
    [parameter(ValueFromRemainingArguments=$true)]$vargs)

   if($create) {$tr -replace "'" -replace "/silent"
   iex -command $($tr -replace "'" -replace "/silent") } <# hack for spotify #>
   else {
       $cmdline = $cmdline -replace "^[^ ]+" <# remove everything up yo 1st space #> -replace "-","/"
       $cmdline
       Start-Process -NoNewWindow schtasks.back.exe -argumentlist "$cmdline" }
}

'@ | Out-File ( New-Item -Path $env:ProgramFiles\Powershell\7\Modules\QPR.schtasks\QPR.schtasks.psm1 -Force )

@'
 <# hack for installing adobereader #>
function  Unregister-ScheduledTask { Write-Host 'cmdlet Unregister-ScheduledTask not available in PS 7, doing nothing...'; return}
<# needed for Amazon Music #>
function QPR.ie4uinit { <# ie4uinit.exe replacement #>
     Write-Host "This is ie4uinit dummy doing nothing..."
     exit 0;
}
'@ | Out-File ( New-Item -Path $env:ProgramFiles\Powershell\7\Modules\QPR.ie4uinit\QPR.ie4uinit.psm1 -Force )

@'
function QPR.openfiles { <# openfiles.exe replacement for install of mpv  #>
     Write-Host "This is openfiles dummy doing nothing..."
     exit 0;
}
'@ | Out-File ( New-Item -Path $env:ProgramFiles\Powershell\7\Modules\QPR.openfiles\QPR.openfiles.psm1 -Force )

@'
# Note: Visual Studio calls this, not sure if this is really needed by it...
function QPR.getmac { <# getmac.exe replacement #>
    Get-WmiObject win32_networkadapterconfiguration | Format-Table @{L=’Physical address’;E={$_.macaddress}}
}
'@ | Out-File ( New-Item -Path $env:ProgramFiles\Powershell\7\Modules\QPR.getmac\QPR.getmac.psm1 -Force )

@'
function QPR.setx { <# setx.exe replacement #>
    <# FIXME, only setting env. variable handled atm. #>
    <# https://stackoverflow.com/questions/50368246/splitting-a-string-on-spaces-but-ignore-section-between-double-quotes #>
    #$argv = ($env:QPRCMDLINE| select-string '("[^"]*"|\S)+' -AllMatches | % matches | % value) -replace '"'

    $argv = CommandLineToArgvW $($([kernel32]::GetCommandLineW()).Split(" ",3)[2])

    New-ItemProperty -Path 'HKLM:\\System\\CurrentControlSet\\Control\\Session Manager\\Environment' -force -Name $argv[1] -Value $argv[2] -PropertyType 'String' 
    New-ItemProperty -Path 'HKCU:\\Environment' -force -Name $argv[1] -Value $argv[2] -PropertyType 'String' 
    exit 0
}
'@ | Out-File ( New-Item -Path $env:ProgramFiles\Powershell\7\Modules\QPR.setx\QPR.setx.psm1 -Force )

@'
<#
.Synopsis
	Parse command-line arguments using Win32 API CommandLineToArgvW function.

.Link
	http://edgylogic.com/blog/powershell-and-external-commands-done-right/

.Description
	This is the Cmdlet version of the code from the article http://edgylogic.com/blog/powershell-and-external-commands-done-right.
	It can parse command-line arguments using Win32 API function CommandLineToArgvW . 
#>
function CommandLineToArgvW
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$CommandLine
    )

    Begin
    {
        $Kernel32Definition =  @"
            [DllImport("kernel32")]
            public static extern IntPtr GetCommandLineW();
            [DllImport("kernel32")]
            public static extern IntPtr LocalFree(IntPtr hMem);
"@
        $Kernel32 = Add-Type -MemberDefinition $Kernel32Definition -Name 'Kernel32' -Namespace 'Win32' -PassThru

        $Shell32Definition = @"
            [DllImport("shell32.dll", SetLastError = true)]
            public static extern IntPtr CommandLineToArgvW(
                [MarshalAs(UnmanagedType.LPWStr)] string lpCmdLine,
                out int pNumArgs);
"@
        $Shell32 = Add-Type -MemberDefinition $Shell32Definition -Name 'Shell32' -Namespace 'Win32' -PassThru

        if(!$CommandLine)
        {
            $CommandLine = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($Kernel32::GetCommandLineW())
        }
    }

    Process
    {
        $ParsedArgCount = 0
        $ParsedArgsPtr = $Shell32::CommandLineToArgvW($CommandLine, [ref]$ParsedArgCount)

        Try
        {
            $ParsedArgs = @();

            0..$ParsedArgCount | ForEach-Object {
                $ParsedArgs += [System.Runtime.InteropServices.Marshal]::PtrToStringUni(
                    [System.Runtime.InteropServices.Marshal]::ReadIntPtr($ParsedArgsPtr, $_ * [IntPtr]::Size)
                )
            }
        }
        Finally
        {
            $Kernel32::LocalFree($ParsedArgsPtr) | Out-Null
        }

        $ret = @()

        # -lt to skip the last item, which is a NULL ptr
        for ($i = 0; $i -lt $ParsedArgCount; $i += 1) {
            $ret += $ParsedArgs[$i]
        }

        return $ret
    }
}
'@ | Out-File ( New-Item -Path $env:ProgramFiles\Powershell\7\Modules\CommandLineToArgvW\CommandLineToArgvW.psm1 -Force )

@'
function QPR.wmic { <# wmic replacement, this part only rebuilds the arguments #>
    if ( $(Get-Process wmic).Parent.name -eq 'pwsh') { <# check whether cmd is ran from PS-console #>
        $cmd = $(cat (Get-PSReadlineOption).HistorySavePath -tail 1).Trim(' ')
        $cmdline = $cmd.Substring($cmd.IndexOf(' ')+1).Trim(' ') + ' ' }
    else {
        $cmdline = $($([kernel32]::GetCommandLineW()).Split(" ",4)[3]) }
     
    $hash = @{
        "path" = "-class "
        'os' = "-class win32_operatingsystem"
         'memorychip' = "-class Win32_PhysicalMemory"
        'cpu' = "-class win32_processor"
        'nic' = "-class win32_NetworkAdapter"     
        'csproduct' = "-class Win32_ComputerSystemProduct"} <# etc. etc. #>

    $class= $cmdline.SubString(0, $cmdline.IndexOf(" "))
    $remainder= $cmdline.SubString( $cmdline.IndexOf(" ")) -replace '\bget\b', '-property'  -replace '\bwhere\b', ' -where '' WHERE '' -filter '

    foreach ($key in $hash.keys) {
        if( $class -eq $key ) { $class = $hash[$key]; $found = 1;  break }  }
    if(-not $found) {$class = $('win32_' + $class)}

    iex  -Command ('QPR_wmic ' + $class + $remainder)
}

function QPR_wmic { <# wmic replacement #>
    [CmdletBinding()]
    Param([parameter(Position=0)][string]$class, [string[]]$property="*",[string]$where, [string]$filter, [parameter(ValueFromRemainingArguments=$true)]$vargs)

    if($property -eq '*'){ <# 'get-wmiobject $class | select *' does not work because of wine-bug, so need a workaround:  #>
        Get-WmiObject $class ($($(Get-WmiObject $class |Get-Member) |where {$_.membertype -eq 'property'}).name -join ',') }
    else { #handle e.g. wmic logicaldisk where "deviceid='C:'" get freespace or  wmic logicaldisk get size, freespace, caption
                                                           
        ([wmisearcher]$("SELECT " +  ($property -join ",") + " FROM " + $class + $where + $filter)).get() |ft ($property |sort) -autosize |Out-string -Stream | Select -skipindex (2)| ?{$_.trim() -ne ""}}
}
'@ | Out-File ( New-Item -Path $env:ProgramFiles\Powershell\7\Modules\QPR.wmic\QPR.wmic.psm1 -Force )
#    Start-Process $env:systemroot\Microsoft.NET\Framework64\v4.0.30319\ngen.exe -NoNewWindow -Wait -ArgumentList  "eqi"
#    Start-Process $env:systemroot\Microsoft.NET\Framework\v4.0.30319\ngen.exe -NoNewWindow -Wait -ArgumentList "eqi"
