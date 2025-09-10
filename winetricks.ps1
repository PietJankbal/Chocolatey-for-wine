if("$env:WINETRICKXHOME") {$cachedir = "$env:WINETRICKXHOME"}
else                      {$cachedir = ("$env:WINEHOMEDIR" + "\.cache\winetrickxs").substring(4)}

<#   winetricks verb list: insert new verbs in list below #>

<#  marker line: do not change this marker line!!!
    "apps","git.portable","Access to several unix-commands like tar, file, sed etc. etc.",
#   "apps","itunes","itunes, with fixed black GUI",
#   "apps","mspaint","mspaint, inserting text does not work :(",
#   "apps","nodejs","install node.js (a workaround for failing installer)",
    "apps","office365","Microsoft Office365HomePremium (registering does not work, many glitches...)",
    "apps","use_chromium_as_browser", "replace winebrowser with chrome to open webpages",
    "apps","vs19", "Visual Studio 2019",
    "apps","vs22", "Visual Studio 2022",
    "apps","vs19_interactive_installer", "Visual Studio 2019 interactive installer",
    "apps","vs22_interactive_installer", "Visual Studio 2022 interactive installer",
    "apps","vulkansamples", "51 vulkan samples to test if your vulkan works, do shift-ctrl^c if you wanna leave earlier ;)",
    "apps","webview2", "Microsoft Edge WebView2",
    "dlls","bitstransfer", "Add Bitstransfer cmdlets to Powershell 5.1",     
    "dlls","cmd","cmd.exe",
    "dlls","comctl32", "dangerzone, might break things, can only be set on a per app base",
    "dlls","crypt32", "experimental, dangerzone, will likely break things, only use on a per app base (crypt32.dll, msasn1.dll)",
    "dlls","d2d1", "dangerzone, only for testing, might break things, only use on a per app base (d2d1.dll)",
    "dlls","d3dx", "d3x9*, d3dx10*, d3dx11*, xactengine*, xapofx* x3daudio*, xinput* and d3dcompiler*",
    "dlls","dbghelp", "dbghelp.dll",
    "dlls","dinput8", "dinput8.dll",
    "dlls","directmusic", "directmusic ddls: dmusic.dll, dmband.dll, dmime.dll, dmloader.dll, dmscript.dll, dmstyle.dll, dmsynth.dll, dsound.dll, dswave.dll",
    "dlls","dotnet2030", "dotnet20 + dotnet30",
    "dlls","dotnet35", "dotnet35",
    "dlls","dotnet481", "experimental dotnet481 install (includes System.Runtime.WindowsRuntime.dll)",
    "dlls","dshow", "directshow dlls: amstream.dll,qasf.dll,qcap.dll,qdvd.dll,qedit.dll,quartz.dll",
    "dlls","dxvk1103", "dxvk 1.10.3, latest compatible with Kepler (Nvidia GT 470) ??? )",
    "dlls","dxvk20", "dxvk 2.0",
    "dlls","expand", "native expand.exe, it's renamed to expnd_.exe to not interfere with wine's expand",
    "dlls","findstr", "findstr.exe",
    "dlls","gdiplus","GDI+ (gdiplus.dll)",
    "dlls","ie8","ie8 dlls",
    "dlls","iertutil","iertutil.dll",
    "dlls","mfc42","mfc42.dll, mfc43u.dll",
    "dlls","mdac28","mdac28 SP1",
    "dlls","mdac_win7","mdac dlls from win 7",
    "dlls","msado15","MDAC and Jet40: some minimal mdac dlls (msado15.dll, oledb32.dll, dao360.dll)",
    "dlls","msdelta", "msdelta.dll",
    "dlls","mshtml", "experimental, dangerzone, might break things, only use on a per app base;ie8 dlls: mshtml.dll, ieframe.dll, urlmon.dll, jscript.dll, wininet.dll, shlwapi.dll, iertutil.dll",
#   "dlls","mshtml_win7","experimental, dangerzone, might break things, only use on a per app base;ie8 dlls: mshtml.dll, ieframe.dll, urlmon.dll, jscript.dll, wininet.dll, shlwapi.dll, iertutil.dll",
    "dlls","mspatcha", "mspatcha.dll",
    "dlls","msvbvm60", "msvbvm60.dll",
    "dlls","msxml3","msxml3.dll",
#   "dlls","msxml3_win10","msxml3.dll from win10", 
    "dlls","msxml6","(experimental) msxml6.dll",
    "dlls","oleaut32","native oleaut32, (dangerzone) can only be set on a per app base",
    "dlls","ps51_ise", "PowerShell 5.1 Integrated Scripting Environment",
    "dlls","ps51", "rudimentary PowerShell 5.1 (downloads yet another huge amount of Mb`s!)",
    "dlls","riched20","riched20.dll, msls31.dll, msftedit.dll",
    "dlls","sapi", "Speech api (sapi.dll), experimental, makes Balabolka work",
    "dlls","sspicli", "dangerzone, only for testing, might break things, only use on a per app base (sspicli.dll)",
    "dlls","uianimation", "uianimation.dll",
    "dlls","uiautomationcore", "uiautomationcore.dll",
    "dlls","uiribbon", "uiribbon.dll",
    "dlls","urlmon", "urlmon.dll",
    "dlls","uxtheme", "uxtheme.dll",
    "dlls","vcrun2019", "vcredist2019 (concrt140.dll, msvcp140.dll, msvcp140_1.dll, msvcp140_2.dll, vcruntime140.dll, vcruntime140_1.dll, ucrtbase.dll)",
    "dlls","vcrun2022", "vcredist2022 (concrt140.dll, msvcp140.dll, msvcp140_1.dll, msvcp140_2.dll, vcruntime140.dll, vcruntime140_1.dll, ucrtbase.dll)",
    "dlls","windowscodecs", "windowscodecs.dll",
    "dlls","wbemdisp", "wbemdisp.dll",
    "dlls","windows.ui.xaml", "windows.ui.xaml, experimental...",
    "dlls","winmetadata", "alternative for winmetadata, requires much less downloadtime",
    "dlls","wmf", "some media foundation dlls",
    "dlls","wmiutils","wmiutils.dll",
    "dlls","wmp", "some wmp (windows media player) dlls, makes e-Sword start",
    "dlls","wsh57", "MS Windows Script Host (vbscript.dll scrrun.dll msscript.ocx jscript.dll scrobj.dll wshom.ocx)",
#   "dlls","wsh_win7", "MS Windows Script Host (vbscript.dll scrrun.dll msscript.ocx jscript.dll scrobj.dll wshom.ocx)",
    "dlls","xmllite", "xmllite.dll",
    "font","win7_fonts", "Segoeui fonts, Lucida Console font, Tahoma font, MS Sans Serif",
    "font","vista_fonts","Arial,Calibri,Cambria,Comic Sans,Consolas,Courier,Georgia,Impact,Lucida Sans Unicode,Symbol,Times New Roman,Trebuchet ,Verdana ,Webdings,Wingdings font",
    "misc","access_winrt_from_powershell", "codesnippets from around the internet: howto use Windows Runtime classes in powershell; requires powershell 5.1, so 1st time usage may take very long time!!!",
    "misc","cef", "codesnippets from around the internet: how to use cef / test cef",
    "misc","chocolatey_upgrade","upgrade chocolatey to the latest (>v2.2), requires Powershell 5.1 so on first usage might take >15 minutes!",
    "misc","embed-exe-in-psscript", "codesnippets from around the internet: samplescript howto embed and run an exe into a powershell-scripts (vkcube.exe); might trigger a viruswarning (!) but is really harmless",
#   "misc","GE-Proton","Install bunch of dlls from GE-Proton",
    "misc","Get-PEHeader", "codesnippets from around the internet: add Get-PEHeader to cmdlets, handy to explore dlls imports/exports",
    "misc","Get-MsiDatabaseProperties", "This function retrieves properties from a Windows Installer MSI database",
    "misc","Get-MsiDatabaseRegistryKeys", "This function retrieves Registry Keys from a Windows Installer MSI database",
    "misc","glxgears", "test if your opengl in wine is working",
    "misc","install_dll_from_msu","extract and install a dll/file from an msu file (installation in right place might or might not work ;) )",
    "misc","net_cmdlets", "some cmdlets to test net connection",
    "misc","ps2exe", "codesnippets from around the internet: convert a ps1-script into an executable; requires powershell 5.1, so 1st time usage may take very long time!!!",
#   "misc","sharpdx", "directX with powershell (spinning cube), test if your d3d11 works, further rather useless verb for now ;)",
    "misc","vanara","vanara https://github.com/dahall/Vanara",
    "misc","winrt_hacks","WIP, enable all included wine hacks for (hopefully) bit more winrt ",
    "misc","wpf_msgbox", "codesnippets from around the internet: some fancy messageboxes (via wpf) in powershell",
    "misc","wpf_routedevents", "codesnippets from around the internet: how to use wpf+xaml+routedevents in powershell",
    "misc","wpf_xaml", "codesnippets from around the internet: how to use wpf+xaml in powershell",
    "sets","app_paths", "start new shell with app paths added to the path (permanently), invoke from powershell console!",
    "sets","nocrashdialog", "Disable graphical crash dialog",
    "sets","renderer=gl", "renderer=gl",
    "sets","renderer=vulkan", "renderer=vulkan",
    "wine","ping","semi-fake ping.exe (tcp isntead of ICMP) as the last requires special permissions",
    "wine","wine_advapi32", "wine advapi32 with a few hacks",
    "wine","wine_combase", "wine combase with a few hacks",
    "wine","wine_d2d1", "wine d2d1 with a few hacks",
    "wine","wine_hnetcfg", "wine hnetcfg.dll with fix for https://bugs.winehq.org/show_bug.cgi?id=45432",
    "wine","wine_kernel32","rudimentary mui resource support (makes windows 7 games work)",
    "wine","wine_msi", "if an msi installer fails, might wanna try this wine msi, just faking success for a few actions... Might also result in broken installation ;)",
    "wine","wine_msxml3", "wine msxml3 with a few hacks",
    "wine","wine_wbemprox","hacky wmispoofer, spoof wmi values/add new classes, see c:\ProgramData\Chocolatey-for-wine\wmispoofer.ini for details",
    "wine","wine_shell32", "wine shell32 with a few hacks",
    "wine","wine_wintrust", "wine wintrust faking success for WinVerifyTrust",
    "wine","wine_wintypes", "wine wintypes.dll for for example Affinity"
    marker line!!!: do not change this marker line #>

$expand_exe = "$env:systemroot\system32\expnd\expand.exe"

function quit?([string] $process)  <# wait for a process to quit #>
{
    Get-Process $process -ErrorAction:SilentlyContinue | Foreach-Object { $_.WaitForExit() }
}

if (![System.IO.File]::Exists("$env:ProgramData\chocolatey\bin\wget2.exe")){
    (New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/refs/heads/main/EXTRAS/wget2/wget2.exe", "$env:ProgramData\chocolatey\bin\wget2.exe")
    #iex "$env:ProgramData\\chocolatey\\tools\\shimgen.exe --output=`"$env:ProgramData`"\\chocolatey\\bin\\wget2.exe --path=`"$env:ProgramData`"\Chocolatey-for-wine\wget2.exe"
}

function w_download_to
{
    Param ($dldir, $w_url, $w_file)

    if (![System.IO.Directory]::Exists("$cachedir\\$dldir")){ [System.IO.Directory]::CreateDirectory("$cachedir\\$dldir")}

    if (![System.IO.File]::Exists("$cachedir\\$dldir\\$w_file")){
        Write-Host -foregroundcolor yellow "**********************************************************"
        Write-Host -foregroundcolor yellow "*                                                        *"
        Write-Host -foregroundcolor yellow "*        Downloading file(s) and extracting might        *"
        Write-Host -foregroundcolor yellow "*        take several minutes!                           *"
        Write-Host -foregroundcolor yellow "*        Patience please!                                *"
        Write-Host -foregroundcolor yellow "*                                                        *"
        Write-Host -foregroundcolor yellow "**********************************************************"
        
         wget2 --restrict-file-names=nocontrol <# do not escape any character #> "$w_url" -P "$cachedir\\$dldir"; quit?('wget2')
        }
}

function check_msu_sanity <# some sanity checks before extracting from msu, like if dlls needed for expansion and the msu are present etc. #>
{
    Param ($url, $cab)

    $msu = $url.split('/')[-1]; <# -1 is last array element... #> $dldir = $((Get-PSCallStack)[1].Command).replace('func_', '')
    <# fragile test #>
    if (![System.IO.File]::Exists(  [IO.Path]::Combine($env:systemroot, "system32", "dpx.dll")  ))
       {Write-Host 'Downloading and extracting some files needed for expansion' ; func_expand;
    }

    if (![System.IO.File]::Exists( [IO.Path]::Combine($cachedir,  $dldir,  $msu) ) ) {
        w_download_to $dldir $url $msu; quit?('7z');
    }
    7z e "$cachedir\$dldir\$msu" "-o$cachedir\$dldir" "$cab" -y; 
    Remove-Item "$cachedir\$dldir\$msu" 
}

function check_aik_sanity <# some sanity checks to see if cached files from windows kits 7 are present #>
{
    $url = "https://download.microsoft.com/download/8/E/9/8E9BBC64-E6F8-457C-9B8D-F6C9A16E6D6A/KB3AIK_EN.iso"

    foreach($i in 'F_WINPEOC_AMD64__WINPE_WINPE_SCRIPTING.CAB', 'F_WINPEOC_AMD64__WINPE_WINPE_MDAC.CAB', 'F_WINPEOC_AMD64__WINPE_WINPE_HTA.CAB', 'F1_WINPE.WIM', `
                  'F_WINPEOC_X86__WINPE_WINPE_SCRIPTING.CAB', 'F_WINPEOC_X86__WINPE_WINPE_MDAC.CAB', 'F_WINPEOC_X86__WINPE_WINPE_HTA.CAB', 'F3_WINPE.WIM' ) {
        if(![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  "aik70",  $i) ) ) { #assuming all cached files are gone, re-extract everything
            #w_download_to "aik70" "$url" "KB3AIK_EN.iso"
            if (![System.IO.Directory]::Exists("$cachedir\\aik70")){ [System.IO.Directory]::CreateDirectory("$cachedir\\aik70")}

        if (![System.IO.File]::Exists("$cachedir\\aik70\\KB3AIK_EN.iso")){
            Write-Host -foregroundcolor yellow "**********************************************************"
            Write-Host -foregroundcolor yellow "*                                                        *"
            Write-Host -foregroundcolor yellow "*        Downloading file(s) and extracting might        *"
            Write-Host -foregroundcolor yellow "*        take several minutes!                           *"
            Write-Host -foregroundcolor yellow "*        Patience please!                                *"
            Write-Host -foregroundcolor yellow "*                                                        *"
            Write-Host -foregroundcolor yellow "**********************************************************"
        
            wget2 --restrict-file-names=nocontrol <# do not escape any character #> --header "Range: bytes=0-1099999999"  "$url" -P "$cachedir\\aik70";
        }
                     
            7z x "$cachedir\aik70\KB3AIK_EN.iso" "Neutral.cab" "WinPE.cab" "-o$cachedir\aik70" -y; quit?('7z')
            Remove-Item -Force "$cachedir\aik70\KB3AIK_EN.iso" 
            7z x "$cachedir\aik70\WinPE.cab" "F1_WINPE.WIM" "F3_WINPE.WIM" "-o$cachedir\aik70" -y; quit?('7z')
            Remove-Item -Force "$cachedir\aik70\WinPE.cab" 
            7z x "$cachedir\aik70\Neutral.cab" "F_WINPEOC_AMD64__WINPE_WINPE_SCRIPTING.CAB" "F_WINPEOC_AMD64__WINPE_WINPE_MDAC.CAB" `
            "F_WINPEOC_AMD64__WINPE_WINPE_HTA.CAB" "F_WINPEOC_X86__WINPE_WINPE_SCRIPTING.CAB" "F_WINPEOC_X86__WINPE_WINPE_MDAC.CAB" `
            "F_WINPEOC_X86__WINPE_WINPE_HTA.CAB" "-o$cachedir\aik70" -y; quit?('7z')
            Remove-Item -Force "$cachedir\aik70\Neutral.cab" 
            break;
        }
    }
}

function dlloverride
{
     Param ($value, $dll)
     New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name $dll -Value $value -PropertyType 'String' | Select $dll
}

function reg_edit
{
    param ($regvalues)

    $regfile = $((Get-PSCallStack)[1].Command).replace('func', 'reg') + '.reg'
    $regvalues | Out-File -FilePath $env:TEMP\\$regfile
    reg.exe IMPORT $env:TEMP\\$regfile /reg:64;
    reg.exe IMPORT $env:TEMP\\$regfile /reg:32;
}

function verb { return $((Get-PSCallStack)[1].Command).replace('func_', '') }

function system_install <# install dlls in the systemdirectories #>
{
    Param ($7z_archive, $hash, $verb_might_need_restart) <# hash only for wine dlls  7z_archive = name of archive in winetrickx cache #>

    $path=[IO.Path]::Combine($cachedir, $7z_archive, "$7z_archive.7z" )
    
    if($hash) {
        if( [System.IO.File]::Exists($path) -and ( (Get-FileHash $path).Hash -ne $hash) )  {
            Remove-Item -Force $path 
        }
        w_download_to "$7z_archive" "https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/EXTRAS/$7z_archive.7z" "$7z_archive.7z"
    }

    if($verb_might_need_restart) {
        if([Microsoft.Win32.RegistryKey]::OpenBaseKey('LocalMachine',0).OpenSubKey('System\ControlSet001\Control\Session Manager\KnownDLLs')) {
            $KnownDLLs = [Microsoft.Win32.RegistryKey]::OpenBaseKey('LocalMachine',0).OpenSubKey('System\ControlSet001\Control\Session Manager', $true)
            $KnownDLLs.DeleteSubKey('KnownDLLs')
            Add-Type -AssemblyName PresentationCore,PresentationFramework;    
            [System.Windows.MessageBox]::Show("!!!This verb first needs a restart of wine, so the current session will be terminated!!!`r`n Do 'wine powershell' after this session is has ended, and retry your command",'Message','ok','exclamation');
            Get-Process -name "pwsh" | Stop-Process
        }
    }

    $out = & "$env:ProgramFiles\7-Zip\7z.exe" e -ba -bb3 "$path" "amd64*\*" "64\*"  "-o$env:systemroot\system32\WindowsPowerShell" -aoa
    & "$env:ProgramFiles\7-Zip\7z.exe" e -ba -bb3 "$path" "wow64*\*" "32\*" "x86*\*" "-o$env:systemroot\syswow64\WindowsPowerShell" -aoa; quit?('7z')

   foreach($i in $($out.IndexOf('Type = 7z') + 7)..$($out.IndexOf('Everything is Ok')-1) ){ <# use 7z output to get names of dlls in archive #>
       if( ( ($out[$i]).Substring(2,2) -eq 'am') -or ( ($out[$i]).Substring(2,2) -eq '64')  ) {
           [string[]]$dlls += $out[$i].split('\')[-1] }
   }

    foreach($j in 'system32','syswow64') {
        foreach($i in $dlls) {
            Rename-Item  "$env:systemroot\$j\$i" $("__" + "$i") -Force -Verbose -erroraction silentlycontinue
            Move-Item    "$env:systemroot\$j\WindowsPowerShell\$i" "$env:systemroot\$j\$i" -Force -Verbose -erroraction silentlycontinue
            #Remove-Item  $env:systemroot\$j\$("$i" + "_*") -Force -Verbose -erroraction silentlycontinue
         }
    }
     
    if($hash) { dlloverride 'native,builtin' $dlls.Replace('.dll','') }
}

$MethodDefinition = @" 
[DllImport("ntdll.dll", CharSet = CharSet.Ansi)] public static extern string wine_get_version();
[DllImport("ntdll.dll", CharSet = CharSet.Ansi)] public static extern string wine_get_build_id();
"@
$ntdll = Add-Type -MemberDefinition $MethodDefinition -Name 'ntdll' -PassThru

function func_msxml3
{
    $dlls = @('msxml3.dll','msxml3r.dll'); check_aik_sanity;

    foreach ($i in $dlls) {
        7z e "$cachedir\aik70\F3_WINPE.WIM" "-o$env:systemroot\system32" "Windows/System32/$i" -y | Select-String 'ok'
        7z e "$cachedir\aik70\F1_WINPE.WIM" "-o$env:systemroot\syswow64" "Windows/System32/$i" -y| Select-String 'ok' } ; quit?('7z') 
    foreach($i in 'msxml3') { dlloverride 'native' $i }
} <# end msxml3 #>

function func_mfc42
{
    $dlls = @('mfc42.dll', 'mfc42u.dll'); check_aik_sanity;

    foreach ($i in $dlls) {
        7z e "$cachedir\aik70\F3_WINPE.WIM" "-o$env:systemroot\system32" "Windows/System32/$i" -y | Select-String 'ok'
        7z e "$cachedir\aik70\F1_WINPE.WIM" "-o$env:systemroot\syswow64" "Windows/System32/$i" -y| Select-String 'ok' } ; quit?('7z')
} <# end mfc42 #>

function func_riched20
{
    $dlls = @('riched20.dll','msls31.dll','msftedit.dll'); check_aik_sanity;

    foreach ($i in $dlls) {
        7z e "$cachedir\aik70\F3_WINPE.WIM" "-o$env:systemroot\system32" "Windows/System32/$i" -y | Select-String 'ok'
        7z e "$cachedir\aik70\F1_WINPE.WIM" "-o$env:systemroot\syswow64" "Windows/System32/$i" -y| Select-String 'ok' } ; quit?('7z') 
    foreach($i in 'riched20','msftedit') { dlloverride 'native' $i }
} <# end riched20 #>

function func_windowscodecs
{
    $dlls = @('windowscodecs.dll'); check_aik_sanity;

    foreach ($i in $dlls) {
        7z e "$cachedir\aik70\F3_WINPE.WIM" "-o$env:systemroot\system32" "Windows/System32/$i" -y | Select-String 'ok'
        7z e "$cachedir\aik70\F1_WINPE.WIM" "-o$env:systemroot\syswow64" "Windows/System32/$i" -y| Select-String 'ok' } ; quit?('7z') 
    foreach($i in 'windowscodecs') { dlloverride 'native' $i }
}  <# end windowscodecs #>

function func_uxtheme
{
    $dlls = @('uxtheme.dll'); check_aik_sanity;

    foreach ($i in $dlls) {
        7z e "$cachedir\aik70\F3_WINPE.WIM" "-o$env:systemroot\system32" "Windows/System32/$i" -y | Select-String 'ok'
        7z e "$cachedir\aik70\F1_WINPE.WIM" "-o$env:systemroot\syswow64" "Windows/System32/$i" -y| Select-String 'ok' } ; quit?('7z') 
    foreach($i in 'uxtheme') { dlloverride 'native' $i }
}  <# end uxtheme #>

function func_dbghelp
{
    $dlls = @('dbghelp.dll'); check_aik_sanity;

    foreach ($i in $dlls) {
        7z e "$cachedir\aik70\F3_WINPE.WIM" "-o$env:systemroot\system32" "Windows/System32/$i" -y | Select-String 'ok'
        7z e "$cachedir\aik70\F1_WINPE.WIM" "-o$env:systemroot\syswow64" "Windows/System32/$i" -y| Select-String 'ok' } ; quit?('7z') 
    foreach($i in 'dbghelp') { dlloverride 'native' $i }
}  <# end dbghelp #>

function func_sspicli
{
    $dlls = @('sspicli.dll'); check_aik_sanity;

    foreach ($i in $dlls) {
        7z e "$cachedir\aik70\F3_WINPE.WIM" "-o$env:systemroot\system32" "Windows/System32/$i" -y | Select-String 'ok'
        7z e "$cachedir\aik70\F1_WINPE.WIM" "-o$env:systemroot\syswow64" "Windows/System32/$i" -y| Select-String 'ok' } ; quit?('7z') 
    foreach($i in 'sspicli') { dlloverride 'native' $i }
}  <# end sspicli #>

function func_uiautomationcore
{
    $dlls = @('uiautomationcore.dll'); check_aik_sanity;

    foreach ($i in $dlls) {
        7z e "$cachedir\aik70\F3_WINPE.WIM" "-o$env:systemroot\system32" "Windows/System32/$i" -y | Select-String 'ok'
        7z e "$cachedir\aik70\F1_WINPE.WIM" "-o$env:systemroot\syswow64" "Windows/System32/$i" -y| Select-String 'ok' } ; quit?('7z') 
    foreach($i in 'uiautomationcore') { dlloverride 'native' $i }
}  <# end uiautomationcore #>

function func_mspatcha
{
    $dlls = @('mspatcha.dll'); check_aik_sanity;

    foreach ($i in $dlls) {
        7z e "$cachedir\aik70\F3_WINPE.WIM" "-o$env:systemroot\system32" "Windows/System32/$i" -y | Select-String 'ok'
        7z e "$cachedir\aik70\F1_WINPE.WIM" "-o$env:systemroot\syswow64" "Windows/System32/$i" -y| Select-String 'ok' } ; quit?('7z') 
    foreach($i in 'mspatcha') { dlloverride 'native' $i }
}  <# end mspatcha #>

function func_urlmon
{
    $dlls = @('urlmon.dll'); check_aik_sanity;

    foreach ($i in $dlls) {
        7z e "$cachedir\aik70\F3_WINPE.WIM" "-o$env:systemroot\system32" "Windows/System32/$i" -y | Select-String 'ok'
        7z e "$cachedir\aik70\F1_WINPE.WIM" "-o$env:systemroot\syswow64" "Windows/System32/$i" -y| Select-String 'ok' } ; quit?('7z') 
    foreach($i in 'urlmon') { dlloverride 'native' $i }
}  <# end urlmon #>

function func_xmllite
{
    check_aik_sanity; $dldir = "aik70"
    $expdlls = @( 'amd64_microsoft-windows-servicingstack_31bf3856ad364e35_6.1.7600.16385_none_655452efe0fb810b/xmllite.dll', `
                  'x86_microsoft-windows-servicingstack_31bf3856ad364e35_6.1.7600.16385_none_0935b76c289e0fd5/xmllite.dll' )
		  
    foreach ($i in $expdlls) {
        if( $i.SubString(0,3) -eq 'amd' ) {7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/winsxs/$i -y | Select-String 'ok' ; Write-Host processed 64-bit $($i.split('/')[-1])}
        if( $i.SubString(0,3) -eq 'x86' ) {7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\\syswow64" Windows/winsxs/$i -y | Select-String 'ok' ; Write-Host processed 32-bit $($i.split('/')[-1])}} quit?('7z')

    foreach($i in 'xmllite') { dlloverride 'native' $i }
} <# end xmllite #>

function func_iertutil
{
    check_aik_sanity; $dldir = "aik70"
    $expdlls = @( 'amd64_microsoft-windows-ie-runtimeutilities_31bf3856ad364e35_8.0.7600.16385_none_be52e3381d372f67/iertutil.dll', `
                  'x86_microsoft-windows-ie-runtimeutilities_31bf3856ad364e35_8.0.7600.16385_none_623447b464d9be31/iertutil.dll' )
		  
    foreach ($i in $expdlls) {
        if( $i.SubString(0,3) -eq 'amd' ) {7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/winsxs/$i -y | Select-String 'ok' ; Write-Host processed 64-bit $($i.split('/')[-1])}
        if( $i.SubString(0,3) -eq 'x86' ) {7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\\syswow64" Windows/winsxs/$i -y | Select-String 'ok' ; Write-Host processed 32-bit $($i.split('/')[-1])}} quit?('7z')

    foreach($i in 'iertutil') { dlloverride 'native' $i }
} <# end iertutil #>

function func_comctl32 <# comctl32 #>
{
    #https://4sysops.com/archives/how-to-create-an-open-file-folder-dialog-box-with-powershell/
    try{ $null=[System.Reflection.Assembly]::GetAssembly([System.Windows.Forms]) }
    catch { [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null }
    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
    InitialDirectory =  [System.IO.Directory]::GetCurrentDirectory() 
    Filter = 'exe files (*.exe)|*.exe'
    Title = "Select the exe for which you want to add the 'native' $(verb) override" }
    if ( $FileBrowser.ShowDialog() -eq 'Cancel' ) {exit}

    $file = ([System.IO.FileInfo]($FileBrowser.FileName)).name
    $filepath = ([System.IO.FileInfo]($FileBrowser.FileName)).Fullname
    $destdir =([System.IO.FileInfo]($FileBrowser.FileName)).Directory

    $dlls = @("$(verb).dll"); check_aik_sanity;

    foreach ($i in $dlls) {
        7z e "$cachedir\aik70\F3_WINPE.WIM" "-o$env:systemroot\system32" "Windows/winsxs/amd64_microsoft.windows.common-controls_6595b64144ccf1df_6.0.7600.16385_none_fa645303170382f6/$i" -y 
        7z e "$cachedir\aik70\F1_WINPE.WIM" "-o$env:systemroot\syswow64" "Windows/winsxs/x86_microsoft.windows.common-controls_6595b64144ccf1df_6.0.7600.16385_none_421189da2b7fabfc/$i" -y } ; quit?('7z') 

    if(!(Test-Path "HKCU:\\Software\\Wine\\AppDefaults\\$file")) {New-Item  -Path "HKCU:\\Software\\Wine\\AppDefaults\\$file"}
    if(!(Test-Path "HKCU:\\Software\\Wine\\AppDefaults\\$file\\DllOverrides")) {New-Item  -Path "HKCU:\\Software\\Wine\\AppDefaults\\$file\\DllOverrides"}
    New-ItemProperty -Path "HKCU:\\Software\\Wine\\AppDefaults\\$file\\DllOverrides" -Name "$(verb)" -Value 'native,builtin' -PropertyType 'String' -force

$regkey = @"
REGEDIT4
[HKEY_CURRENT_USER\Software\Wine\AppDefaults\explorer.exe\DllOverrides]
"comctl32"="builtin"
[HKEY_CURRENT_USER\Software\Wine\AppDefaults\winecfg.exe\DllOverrides]
"comctl32"="builtin"
[HKEY_CURRENT_USER\Software\Wine\AppDefaults\regedit.exe\DllOverrides]
"comctl32"="builtin"
"@
    reg_edit $regkey

    Remove-Item -Force $env:systemroot\winsxs\manifests\amd64_microsoft.windows.common-controls_6595b64144ccf1df_6.0.2600.2982_none_deadbeef.manifest -ErrorAction SilentlyContinue
    Remove-Item -Force $env:systemroot\winsxs\manifests\x86_microsoft.windows.common-controls_6595b64144ccf1df_6.0.2600.2982_none_deadbeef.manifest -ErrorAction SilentlyContinue
} <# end comctl32 #>

function func_oleaut32 <# oleaut32  #>
{
    #https://4sysops.com/archives/how-to-create-an-open-file-folder-dialog-box-with-powershell/
    try{ $null=[System.Reflection.Assembly]::GetAssembly([System.Windows.Forms]) }
    catch { [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null }
    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
    InitialDirectory =  [System.IO.Directory]::GetCurrentDirectory() 
    Filter = 'exe files (*.exe)|*.exe'
    Title = "Select the exe for which you want to add the 'native' $(verb) override" }
    if ( $FileBrowser.ShowDialog() -eq 'Cancel' ) {exit}

    $file = ([System.IO.FileInfo]($FileBrowser.FileName)).name
    $filepath = ([System.IO.FileInfo]($FileBrowser.FileName)).Fullname
    $destdir =([System.IO.FileInfo]($FileBrowser.FileName)).Directory

    if ( $(7z l $filepath | findstr 'CPU' |select-string x64) )       {$arch = 'F3' }
    elseif ( $(7z l $filepath | findstr 'CPU' |select-string x86) )   {$arch = 'F1' }
    else {Write-Host 'Something went wrong...'; exit}
    
    $dlls = @("$(verb).dll"); check_aik_sanity;
    
    foreach ($i in $dlls ) {
        7z e "$cachedir\aik70\$($arch)_WINPE.WIM" "-o$destdir" "Windows/System32/$i" -y| Select-String 'ok' } ; quit?('7z') 
     
    if(!(Test-Path "HKCU:\\Software\\Wine\\AppDefaults\\$file")) {New-Item  -Path "HKCU:\\Software\\Wine\\AppDefaults\\$file"}
    if(!(Test-Path "HKCU:\\Software\\Wine\\AppDefaults\\$file\\DllOverrides")) {New-Item  -Path "HKCU:\\Software\\Wine\\AppDefaults\\$file\\DllOverrides"}
    New-ItemProperty -Path "HKCU:\\Software\\Wine\\AppDefaults\\$file\\DllOverrides" -Name "$(verb)" -Value 'native,builtin' -PropertyType 'String' -force
} <# end oleaut32 #>

function func_msxml6 <# experimental... #>
{
    $url = "https://catalog.s.download.windowsupdate.com/c/msdownload/update/software/updt/2018/08/windows10.0-kb4343893-x64_bdae9c9c28d4102a673a24d37c371ed73d053338.msu"
    $cab = "Windows10.0-KB4343893-x64.cab"
    $sourcefile = @('msxml6.dll', 'msxml6r.dll')


    if ([System.IO.File]::Exists(  [IO.Path]::Combine("$env:SystemRoot", "system32", "msxml6_installed.txt") ) ) {
        Write-host "msxml6 already seems to be installed.`r`nJust skipping installation of msxml6 now."; return;
    }

    if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $(verb),  "$(verb).7z") ) ) {
        check_msu_sanity $url $cab;
        foreach ($i in $sourcefile) { & $expand_exe $([IO.Path]::Combine($cachedir,  $(verb),  $cab)) -f:$i $([IO.Path]::Combine($cachedir,  $(verb) ) ) }
        7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on "$cachedir\$(verb)\$(verb).7z" "$cachedir\$(verb)\amd64*" "$cachedir\$(verb)\wow*" ; quit?('7z')

        foreach($i in 'amd64', 'x86', 'wow64') { Remove-Item -Force -Recurse "$cachedir\$(verb)\$i*" }
        
        Remove-Item -Force "$cachedir\$(verb)\$cab" -ErrorAction SilentlyContinue
    }

    system_install wine_rpcrt4 'c82422a0bf6cc4045c142a91f250e557f841755aa1f8b169e1765a9ed3b6258c' $true
    system_install $(verb) $null $false
      
    [system.console]::ForegroundColor='white'
    
    foreach($i in 'msxml6', 'rpcrt4') { dlloverride 'native,builtin' $i }
    
#    echo $null >> $env:SystemRoot\\system32\\msxml6_installed.txt

#    Add-Type -AssemblyName PresentationCore,PresentationFramework;    
#    [System.Windows.MessageBox]::Show("This verb needs a restart of powershell, so the current session will be terminated!!!`r`n Do 'wine powershell' after this session is has ended.",'Message','ok','exclamation');
#    Get-Process -name "pwsh" | Stop-Process

} <# end msxml6 #>

function func_msxml3_win10 <# experimental... #>
{
    $url = "https://catalog.s.download.windowsupdate.com/c/msdownload/update/software/updt/2018/08/windows10.0-kb4343893-x64_bdae9c9c28d4102a673a24d37c371ed73d053338.msu"
    $cab = "Windows10.0-KB4343893-x64.cab"
    $sourcefile = @('msxml3.dll', 'msxml3r.dll')

    if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $(verb),  "$(verb).7z") ) ) {
        check_msu_sanity $url $cab;
        foreach ($i in $sourcefile) { & $expand_exe $([IO.Path]::Combine($cachedir,  $(verb),  $cab)) -f:$i $([IO.Path]::Combine($cachedir,  $(verb) ) ) }
        7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on "$cachedir\$(verb)\$(verb).7z" "$cachedir\$(verb)\amd64*" "$cachedir\$(verb)\wow*" ; quit?('7z')

        foreach($i in 'amd64', 'x86', 'wow64') { Remove-Item -Force -Recurse "$cachedir\$(verb)\$i*" }
        
        Remove-Item -Force "$cachedir\$(verb)\$cab" -ErrorAction SilentlyContinue
    }

    Rename-Item  "$env:systemroot\system32\msxml6.dll" "$env:systemroot\system32\msxml3_old.dll" -Force -Verbose -erroraction silentlycontinue
    Rename-Item  "$env:systemroot\system32\msxml6r.dll" "$env:systemroot\system32\msxml3r_old.dll" -Force -Verbose -erroraction silentlycontinue

    & "$env:ProgramFiles\7-Zip\7z.exe" e "$cachedir\$(verb)\$(verb).7z" "amd64*\*" "-o$env:systemroot\system32" -aoa
    & "$env:ProgramFiles\7-Zip\7z.exe" e "$cachedir\$(verb)\$(verb).7z" "wow64*\*" "-o$env:systemroot\syswow64" -aoa

    remove-item "$env:systemroot\system32\msxml3_old.dll" -force -erroraction silentlycontinue -verbose
    remove-item "$env:systemroot\system32\msxml3r_old.dll" -force -erroraction silentlycontinue -verbose
        
    if( [System.IO.File]::Exists( $([IO.Path]::Combine($cachedir,  'wine_rpcrt4', "wine_rpcrt4.7z") )) -and ( (Get-FileHash  "$cachedir\wine_rpcrt4\wine_rpcrt4.7z").Hash -ne 'c82422a0bf6cc4045c142a91f250e557f841755aa1f8b169e1765a9ed3b6258c') )  {
        Remove-Item -Force  "$cachedir\wine_rpcrt4\wine_rpcrt4.7z" 
    }
    w_download_to "wine_rpcrt4" "https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/EXTRAS/wine_rpcrt4.7z" "wine_rpcrt4.7z"

    7z e "$cachedir\\wine_rpcrt4\\wine_rpcrt4.7z" "-o$env:systemroot\system32" "64/rpcrt4_64.dll" -aoa | Select-String 'ok' 
    7z e "$cachedir\\wine_rpcrt4\\wine_rpcrt4.7z" "-o$env:systemroot\syswow64" "32/rpcrt4.dll" -aoa | Select-String 'ok'

    remove-item "$env:systemroot\system32\rpcrt4_old.dll" -force -erroraction silentlycontinue -verbose
    Rename-Item  "$env:systemroot\system32\rpcrt4.dll" "$env:systemroot\system32\rpcrt4_old.dll" -Force -Verbose -erroraction silentlycontinue
    Rename-Item  "$env:systemroot\system32\rpcrt4_64.dll" "$env:systemroot\system32\rpcrt4.dll" -Force -Verbose -erroraction silentlycontinue
    [system.console]::ForegroundColor='white'
    
    foreach($i in 'msxml3', 'rpcrt4') { dlloverride 'native,builtin' $i }
} <# end msxml3 #>

function func_wsh57_deprecated
{
    check_aik_sanity; $dldir = "aik70"
    $dlls = @( 'amd64_microsoft-windows-scripting_31bf3856ad364e35_6.1.7600.16385_none_a45d44bd1a0af822/wshom.ocx',`
               'amd64_microsoft-windows-scripting_31bf3856ad364e35_6.1.7600.16385_none_a45d44bd1a0af822/wscript.exe',`
               'amd64_microsoft-windows-scripting_31bf3856ad364e35_6.1.7600.16385_none_a45d44bd1a0af822/cscript.exe',`
               'amd64_microsoft-windows-scripting_31bf3856ad364e35_6.1.7600.16385_none_a45d44bd1a0af822/wshcon.dll',`
               'amd64_microsoft-windows-scripting_31bf3856ad364e35_6.1.7600.16385_none_a45d44bd1a0af822/scrrun.dll',`
               'amd64_microsoft-windows-scripting_31bf3856ad364e35_6.1.7600.16385_none_a45d44bd1a0af822/scrobj.dll',`
               'amd64_microsoft-windows-scripting_31bf3856ad364e35_6.1.7600.16385_none_a45d44bd1a0af822/dispex.dll',`
               'amd64_microsoft-windows-scripting-vbscript_31bf3856ad364e35_6.1.7600.16385_none_a44ef4f6479809f0/vbscript.dll',`
               'amd64_microsoft-windows-scripting-jscript_31bf3856ad364e35_8.0.7600.16385_none_f98f217587d75631/jscript.dll',`
               'x86_microsoft-windows-scripting_31bf3856ad364e35_6.1.7600.16385_none_483ea93961ad86ec/wshom.ocx',`
               'x86_microsoft-windows-scripting_31bf3856ad364e35_6.1.7600.16385_none_483ea93961ad86ec/wscript.exe',`
               'x86_microsoft-windows-scripting_31bf3856ad364e35_6.1.7600.16385_none_483ea93961ad86ec/cscript.exe',`
               'x86_microsoft-windows-scripting_31bf3856ad364e35_6.1.7600.16385_none_483ea93961ad86ec/wshcon.dll',`
               'x86_microsoft-windows-scripting_31bf3856ad364e35_6.1.7600.16385_none_483ea93961ad86ec/scrrun.dll',`
               'x86_microsoft-windows-scripting_31bf3856ad364e35_6.1.7600.16385_none_483ea93961ad86ec/scrobj.dll',`
               'x86_microsoft-windows-scripting_31bf3856ad364e35_6.1.7600.16385_none_483ea93961ad86ec/dispex.dll',`
               'x86_microsoft-windows-scripting-vbscript_31bf3856ad364e35_6.1.7600.16385_none_483059728f3a98ba/vbscript.dll',`
               'x86_microsoft-windows-scripting-msscript_31bf3856ad364e35_6.1.7600.16385_none_90381958050e76f8/msscript.ocx',`
               'x86_microsoft-windows-scripting-jscript_31bf3856ad364e35_8.0.7600.16385_none_9d7085f1cf79e4fb/jscript.dll')
		  
    foreach ($i in $dlls) {
        if( $i.SubString(0,3) -eq 'amd' ) {7z e $cachedir\\$dldir\\F_WINPEOC_AMD64__WINPE_WINPE_SCRIPTING.CAB "-o$env:systemroot\\system32" $i -y | Select-String 'ok' }
        if( $i.SubString(0,3) -eq 'x86' ) {7z e $cachedir\\$dldir\\F_WINPEOC_X86__WINPE_WINPE_SCRIPTING.CAB "-o$env:systemroot\\syswow64" $i -y | Select-String 'ok' }} quit?('7z')

    foreach($i in 'dispex.dll', 'jscript.dll', 'scrobj.dll', 'scrrun.dll', 'vbscript.dll', 'msscript.ocx', 'wshom.ocx', 'wscript.exe', 'cscript.exe') { dlloverride 'native' $i }

    foreach($i in 'msscript.ocx', 'jscript.dll', 'scrobj.dll', 'scrrun.dll', 'vbscript.dll', 'wshcon.dll', 'wshom.ocx', 'dispex.dll') {
        & "$env:systemroot\\syswow64\\regsvr32" /s "$env:systemroot\\syswow64\\$i"
        & "$env:systemroot\\system32\\regsvr32" /s "$env:systemroot\\system32\\$i" }

} <# end wsh57 #>

function func_msado15
{
    check_aik_sanity;
    $dldir = "jet40"

    w_download_to "$dldir" "https://web.archive.org/web/20210225171713if_/http://download.microsoft.com/download/4/3/9/4393c9ac-e69e-458d-9f6d-2fe191c51469/Jet40SP8_9xNT.exe" "Jet40SP8_9xNT.exe"

    7z e $cachedir\\$dldir\\Jet40SP8_9xNT.exe "-o$env:TEMP\\$dldir" jetsetup.exe -y ;quit?('7z')
    7z e $env:TEMP\\$dldir\\jetsetup.exe "-o$env:TEMP\\$dldir" jetsetup.cab -y ;quit?('7z')
    7z e $env:TEMP\\$dldir\\jetsetup.cab "-o$env:systemroot\\syswow64" -aoa; Move-Item "$env:systemroot\\syswow64\\msjetol1.dll" "$env:systemroot\\syswow64\\msjetoledb40.dll" -force; quit?('7z')
#    7z e $env:TEMP\\$dldir\\jetsetup.cab "-o$env:systemroot\\syswow64" msrd2x40.dll -aoa; quit?('7z')
#    7z e $env:TEMP\\$dldir\\jetsetup.cab "-o$env:systemroot\\syswow64" msrd3x40.dll -aoa; quit?('7z')
#    7z e $env:TEMP\\$dldir\\jetsetup.cab "-o$env:systemroot\\syswow64" msjet40.dll -aoa; quit?('7z')
#    7z e $env:TEMP\\$dldir\\jetsetup.cab "-o$env:TEMP\\$dldir" dao360.dll -aoa;
    mkdir "${env:CommonProgramFiles`(x86`)}\\Microsoft Shared\\DAO" -erroraction silentlycontinue ;Move-Item "$env:systemroot\\syswow64\\dao360.dll" "${env:CommonProgramFiles`(x86`)}\\Microsoft Shared\\DAO\\dao360.dll" -force

#    $dldir = "mdac28"

#    w_download_to "$dldir" "https://web.archive.org/web/20070127061938if_/http://download.microsoft.com:80/download/4/a/a/4aafff19-9d21-4d35-ae81-02c48dcbbbff/MDAC_TYP.EXE" "MDAC_TYP.EXE"

#   7z e $cachedir\\$dldir\\MDAC_TYP.EXE "-o$env:TEMP\\$dldir" jetfiles.cab -y ;quit?('7z')
#    foreach ($i in 'expsrv.dll', 'msjtes40.dll', 'mswdat10.dll', 'mswstr10.dll', 'vbajet32.dll'){
#        7z e $env:TEMP\\$dldir\\jetfiles.cab "-o$env:systemroot\\syswow64" -y ;quit?('7z')}

    $dldir = "aik70"

    $adodlls = @( 'amd64_microsoft-windows-m..ents-mdac-ado15-dll_31bf3856ad364e35_6.1.7600.16385_none_6825d42d8a57b77d/msado15.dll', `
                  'x86_microsoft-windows-m..ents-mdac-ado15-dll_31bf3856ad364e35_6.1.7600.16385_none_0c0738a9d1fa4647/msado15.dll', `
                  'amd64_microsoft-windows-m..ac-ado-ddl-security_31bf3856ad364e35_6.1.7600.16385_none_0e2388835a138ae2/msadox.dll', `
                  'x86_microsoft-windows-m..ac-ado-ddl-security_31bf3856ad364e35_6.1.7600.16385_none_b204ecffa1b619ac/msadox.dll',
                  'amd64_microsoft-windows-m..nents-mdac-ado15-rh_31bf3856ad364e35_6.1.7600.16385_none_8fcb05776848745b/msadrh15.dll',
                  'x86_microsoft-windows-m..nents-mdac-ado15-rh_31bf3856ad364e35_6.1.7600.16385_none_33ac69f3afeb0325/msadrh15.dll')

    foreach ($i in $adodlls) {
            if( $i.SubString(0,3) -eq 'amd' ) {7z e $cachedir\\$dldir\\F_WINPEOC_AMD64__WINPE_WINPE_MDAC.CAB "-o$env:CommonProgramFiles\\System\\ADO" $i -y | Select-String 'ok' ; Write-Host processed 64-bit $($i.split('/')[-1])}
            if( $i.SubString(0,3) -eq 'x86' ) {7z e $cachedir\\$dldir\\F_WINPEOC_X86__WINPE_WINPE_MDAC.CAB "-o${env:CommonProgramFiles`(x86`)}\\System\\ADO" $i -y | Select-String 'ok' ; Write-Host processed 64-bit $($i.split('/')[-1])}} quit?('7z')

    $oledlls = @( 'amd64_microsoft-windows-m..ents-mdac-oledb-dll_31bf3856ad364e35_6.1.7600.16385_none_4e1fa9e216eb782f/oledb32.dll', `
                  'x86_microsoft-windows-m..ents-mdac-oledb-dll_31bf3856ad364e35_6.1.7600.16385_none_f2010e5e5e8e06f9/oledb32.dll', `
                  'amd64_microsoft-windows-m..ents-mdac-oledb-rll_31bf3856ad364e35_6.1.7600.16385_none_54550e6612edb791/oledb32r.dll', `
                  'x86_microsoft-windows-m..ents-mdac-oledb-rll_31bf3856ad364e35_6.1.7600.16385_none_f83672e25a90465b/oledb32r.dll' )

    foreach ($i in $oledlls) {
            if( $i.SubString(0,3) -eq 'amd' ) {7z e $cachedir\\$dldir\\F_WINPEOC_AMD64__WINPE_WINPE_MDAC.CAB "-o$env:CommonProgramFiles\\System\\OLE DB" $i -y | Select-String 'ok' ; Write-Host processed 64-bit $($i.split('/')[-1])}
            if( $i.SubString(0,3) -eq 'x86' ) {7z e $cachedir\\$dldir\\F_WINPEOC_X86__WINPE_WINPE_MDAC.CAB "-o${env:CommonProgramFiles`(x86`)}\\System\\OLE DB" $i -y | Select-String 'ok' ; Write-Host processed 64-bit $($i.split('/')[-1])}} quit?('7z')

    $adcdlls = @( 'amd64_microsoft-windows-m..nts-mdac-rds-ce-rll_31bf3856ad364e35_6.1.7600.16385_none_bd4e87525be1bd8b/msadcer.dll', `
                  'x86_microsoft-windows-m..nts-mdac-rds-ce-rll_31bf3856ad364e35_6.1.7600.16385_none_612febcea3844c55/msadcer.dll', `
                  'amd64_microsoft-windows-m..nts-mdac-rds-ce-dll_31bf3856ad364e35_6.1.7600.16385_none_bde5e63a5b70365d/msadce.dll', `
                  'x86_microsoft-windows-m..nts-mdac-rds-ce-dll_31bf3856ad364e35_6.1.7600.16385_none_61c74ab6a312c527/msadce.dll' )

    foreach ($i in $adcdlls) {
            if( $i.SubString(0,3) -eq 'amd' ) {7z e $cachedir\\$dldir\\F_WINPEOC_AMD64__WINPE_WINPE_MDAC.CAB "-o$env:CommonProgramFiles\\System\\MSADC" $i -y | Select-String 'ok' ; Write-Host processed 64-bit $($i.split('/')[-1])}
            if( $i.SubString(0,3) -eq 'x86' ) {7z e $cachedir\\$dldir\\F_WINPEOC_X86__WINPE_WINPE_MDAC.CAB "-o${env:CommonProgramFiles`(x86`)}\\System\\MSADC" $i -y | Select-String 'ok' ; Write-Host processed 64-bit $($i.split('/')[-1])}} quit?('7z')


    $dlls = @( 'amd64_microsoft-windows-m..ponents-mdac-msdart_31bf3856ad364e35_6.1.7600.16385_none_42074b3f2553d5bd/msdart.dll', `
               'x86_microsoft-windows-m..ponents-mdac-msdart_31bf3856ad364e35_6.1.7600.16385_none_e5e8afbb6cf66487/msdart.dll')
#              'x86_microsoft-windows-m..mponents-jetintlerr_31bf3856ad364e35_6.1.7600.16385_none_0f472a3521bdcfd4/msjint40.dll', `
#              'x86_microsoft-windows-m..-components-jetcore_31bf3856ad364e35_6.1.7600.16385_none_046511bf090691ab/msjet40.dll', `
#              'x86_microsoft-windows-m..mponents-jetintlerr_31bf3856ad364e35_6.1.7600.16385_none_0f472a3521bdcfd4/msjter40.dll' )
		 
    foreach ($i in $dlls) {
            if( $i.SubString(0,3) -eq 'amd' ) {7z e $cachedir\\$dldir\\F_WINPEOC_AMD64__WINPE_WINPE_MDAC.CAB "-o$env:systemroot\\system32" $i -y | Select-String 'ok' ; Write-Host processed 64-bit $($i.split('/')[-1])}
            if( $i.SubString(0,3) -eq 'x86' ) {7z e $cachedir\\$dldir\\F_WINPEOC_X86__WINPE_WINPE_MDAC.CAB "-o$env:systemroot\\syswow64" $i -y | Select-String 'ok' ; Write-Host processed 64-bit $($i.split('/')[-1])}} quit?('7z')

    foreach($i in 'msado15', 'oledb32') { dlloverride 'native' $i }

    & "$env:systemroot\\system32\\regsvr32" /s "$env:CommonProgramFiles\\System\\ADO\\msado15.dll"
    & "$env:systemroot\\syswow64\\regsvr32" /s "${env:CommonProgramFiles`(x86`)}\\System\\ADO\\msado15.dll"
    & "$env:systemroot\\system32\\regsvr32" /s "$env:CommonProgramFiles\\System\\ADO\\msadox.dll"
    & "$env:systemroot\\syswow64\\regsvr32" /s "${env:CommonProgramFiles`(x86`)}\\System\\ADO\\msadox.dll"
    & "$env:systemroot\\system32\\regsvr32" /s "$env:CommonProgramFiles\\System\\ADO\\msadrh15.dll"
    & "$env:systemroot\\syswow64\\regsvr32" /s "${env:CommonProgramFiles`(x86`)}\\System\\ADO\\msadrh15.dll"
    & "$env:systemroot\\system32\\regsvr32" /s "$env:CommonProgramFiles\\System\\OLE DB\\oledb32.dll"
    & "$env:systemroot\\syswow64\\regsvr32" /s "${env:CommonProgramFiles`(x86`)}\\System\\OLE DB\\oledb32.dll"
    & "$env:systemroot\\system32\\regsvr32" /s "$env:CommonProgramFiles\\System\\MSADC\\msadce.dll"
    & "$env:systemroot\\syswow64\\regsvr32" /s "${env:CommonProgramFiles`(x86`)}\\System\\MSADC\\msadce.dll"
    foreach($i in 'msjet40.dll', 'msjetoledb40.dll', 'msrd2x40.dll', 'msrd3x40.dll', 'msexch40.dll', 'msexcl40.dll', 'msltus40.dll', 'mspbde40.dll', 'mstext40.dll', 'msxbde40.dll', 'msjtes40.dll') {
        & "$env:systemroot\\syswow64\\regsvr32" /s "$env:systemroot\\syswow64\\$i" }
#    & "$env:systemroot\\syswow64\\regsvr32"  "$env:systemroot\\syswow64\\msjet40.dll"
#    & "$env:systemroot\\syswow64\\regsvr32"  "$env:systemroot\\syswow64\\msrd2x40.dll"
#    & "$env:systemroot\\syswow64\\regsvr32"  "$env:systemroot\\syswow64\\msrd3x40.dll"
#    & "$env:systemroot\\syswow64\\regsvr32"  "$env:systemroot\\syswow64\\msjetoledb40.dll"
    & "$env:systemroot\\syswow64\\regsvr32" /s "${env:CommonProgramFiles`(x86`)}\\Microsoft Shared\\DAO\\dao360.dll"

$regkey = @"
REGEDIT4
[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{00000602-0000-0010-8000-00AA006D2EA4}]
@="ADOX.Catalog.6.0"

[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{00000602-0000-0010-8000-00AA006D2EA4}\InprocServer32]
@=hex(2):25,43,6f,6d,6d,6f,6e,50,72,6f,67,72,61,6d,46,69,6c,65,73,25,5c,53,79,\
  73,74,65,6d,5c,61,64,6f,5c,6d,73,61,64,6f,78,2e,64,6c,6c,00
"ThreadingModel"="Apartment"

[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{00000602-0000-0010-8000-00AA006D2EA4}\ProgID]
@="ADOX.Catalog.6.0"

[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{00000602-0000-0010-8000-00AA006D2EA4}\VersionIndependentProgID]
@="ADOX.Catalog.6.0"
[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{92396AD0-68F5-11d0-A57E-00A0C9138C66}]
@="RowsetHelper"

[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{92396AD0-68F5-11d0-A57E-00A0C9138C66}\ExtendedErrors]
@="Extended Error Service"

[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{92396AD0-68F5-11d0-A57E-00A0C9138C66}\ExtendedErrors\{92396AD0-68F5-11d0-A57E-00A0C9138C66}]
@="Rowset Helper Error Lookup Service"

[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{92396AD0-68F5-11d0-A57E-00A0C9138C66}\InprocServer32]
@=hex(2):25,43,6f,6d,6d,6f,6e,50,72,6f,67,72,61,6d,46,69,6c,65,73,25,5c,53,79,\
  73,74,65,6d,5c,61,64,6f,5c,6d,73,61,64,72,68,31,35,2e,64,6c,6c,00
"ThreadingModel"="Both"

[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{92396AD0-68F5-11d0-A57E-00A0C9138C66}\ProgID]
@="RowsetHelper"

[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{92396AD0-68F5-11d0-A57E-00A0C9138C66}\VersionIndependentProgID]
@="RowsetHelper"

[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{3FF292B6-B204-11CF-8D23-00AA005FFE58}]
@="FoxOLEDB 1.0 Object"

[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{3FF292B6-B204-11CF-8D23-00AA005FFE58}\InprocServer32]
@=hex(2):25,43,6f,6d,6d,6f,6e,50,72,6f,67,72,61,6d,46,69,6c,65,73,25,5c,53,79,\
  73,74,65,6d,5c,6d,73,61,64,63,5c,6d,73,61,64,63,65,2e,64,6c,6c,00
"ThreadingModel"="both"

[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{3FF292B6-B204-11CF-8D23-00AA005FFE58}\ProgID]
@="FX.Rowset.1"

[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{3FF292B6-B204-11CF-8D23-00AA005FFE58}\VersionIndependentProgID]
@="FX.Rowset"

"@
    reg_edit $regkey

} <# end msado15 #>

function func_expand
{
    check_aik_sanity;
                  
    $dlls =    @( 'amd64_microsoft-windows-deltapackageexpander_31bf3856ad364e35_6.1.7600.16385_none_c5d387d64eb8e1f2/dpx.dll',
                  'amd64_microsoft-windows-cabinet_31bf3856ad364e35_6.1.7600.16385_none_933442c3fb9cbaed/cabinet.dll',
                  'amd64_microsoft-windows-deltacompressionengine_31bf3856ad364e35_6.1.7600.16385_none_9c2159bf9f702069/msdelta.dll',
                  'amd64_microsoft-windows-basic-misc-tools_31bf3856ad364e35_6.1.7600.16385_none_7351a917d91c961e/expand.exe' )

    if (![System.IO.File]::Exists( $expand_exe ) ) { <# fragile test #>
        foreach ($i in $dlls) {
            7z e "$cachedir\aik70\F3_WINPE.WIM" "-o$env:systemroot\system32\expnd" Windows/winsxs/$i -y 
        }

        func_msdelta
        iex "$env:ProgramData\\chocolatey\\tools\\shimgen.exe --output=`"$env:ProgramData`"\\chocolatey\\bin\\expnd.exe --path=`"$env:SystemRoot`"\\system32\\expnd\\expand.exe"
    }

    if(!(Test-Path 'HKCU:\\Software\\Wine\\AppDefaults\\expand.exe')) {New-Item  -Path 'HKCU:\\Software\\Wine\\AppDefaults\\expand.exe'}
    if(!(Test-Path 'HKCU:\\Software\\Wine\\AppDefaults\\expand.exe\\DllOverrides')) {New-Item  -Path 'HKCU:\\Software\\Wine\\AppDefaults\\expand.exe\\DllOverrides'}
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\expand.exe\\DllOverrides' -Name 'cabinet' -Value 'native,builtin' -PropertyType 'String' -force
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\expand.exe\\DllOverrides' -Name 'msdelta' -Value 'native,builtin' -PropertyType 'String' -force

} <# end expand #>

function func_mshtml_deprecated
{
    check_aik_sanity; $dldir = "aik70"

    $iedlls = @( 'amd64_microsoft-windows-ie-htmlrendering_31bf3856ad364e35_8.0.7600.16385_none_89f24b7ab2dc7a40/mshtml.dll', `
                 'x86_microsoft-windows-ie-htmlrendering_31bf3856ad364e35_8.0.7600.16385_none_2dd3aff6fa7f090a/mshtml.dll', ` 
		 'x86_microsoft-windows-ieframe_31bf3856ad364e35_8.0.7600.16385_none_7f3309fa86749737/ieframe.dll', `
                 'amd64_microsoft-windows-ieframe_31bf3856ad364e35_8.0.7600.16385_none_db51a57e3ed2086d/ieframe.dll', `
		 'amd64_microsoft-windows-i..ablenetworkgraphics_31bf3856ad364e35_8.0.7600.16385_none_6475a807a41c7313/pngfilt.dll', `
		 'x86_microsoft-windows-i..ablenetworkgraphics_31bf3856ad364e35_8.0.7600.16385_none_08570c83ebbf01dd/pngfilt.dll', `
                 'x86_microsoft-windows-ie-imagesupport_31bf3856ad364e35_8.0.7600.16385_none_5885662ecb64099b/imgutil.dll', ` 
                 'amd64_microsoft-windows-ie-imagesupport_31bf3856ad364e35_8.0.7600.16385_none_b4a401b283c17ad1/imgutil.dll' `
                )

    foreach ($i in $iedlls) {
            if( $i.SubString(0,3) -eq 'amd' ) {7z e $cachedir\\$dldir\\F_WINPEOC_AMD64__WINPE_WINPE_HTA.CAB "-o$env:systemroot\\system32" $i -y | Select-String 'ok' ; Write-Host processed 64-bit $($i.split('/')[-1])}
            if( $i.SubString(0,3) -eq 'x86' ) {7z e $cachedir\\$dldir\\F_WINPEOC_X86__WINPE_WINPE_HTA.CAB "-o$env:systemroot\\syswow64" $i -y | Select-String 'ok' ; Write-Host processed 64-bit $($i.split('/')[-1])}} quit?('7z')

    $sxsdlls = @( 'amd64_microsoft-windows-msls31_31bf3856ad364e35_6.1.7600.16385_none_27f4c55dbc24c492/msls31.dll', `
                  'x86_microsoft-windows-msls31_31bf3856ad364e35_6.1.7600.16385_none_cbd629da03c7535c/msls31.dll', `
		  'amd64_microsoft-windows-i..tocolimplementation_31bf3856ad364e35_8.0.7600.16385_none_78982c5c3286110a/wininet.dll', `
	          'x86_microsoft-windows-i..tocolimplementation_31bf3856ad364e35_8.0.7600.16385_none_1c7990d87a289fd4/wininet.dll', `
	          'amd64_microsoft-windows-ie-runtimeutilities_31bf3856ad364e35_8.0.7600.16385_none_be52e3381d372f67/iertutil.dll', `
		  'x86_microsoft-windows-ie-runtimeutilities_31bf3856ad364e35_8.0.7600.16385_none_623447b464d9be31/iertutil.dll', `
                  'amd64_microsoft-windows-shlwapi_31bf3856ad364e35_6.1.7600.16385_none_55cea3abbe5ff1f1/shlwapi.dll', `
                  'x86_microsoft-windows-shlwapi_31bf3856ad364e35_6.1.7600.16385_none_f9b00828060280bb/shlwapi.dll')

    foreach ($i in $sxsdlls) {
            if( $i.SubString(0,3) -eq 'amd' ) {7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/winsxs/$i -y | Select-String 'ok' ; Write-Host processed 64-bit $($i.split('/')[-1])}
            if( $i.SubString(0,3) -eq 'x86' ) {7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\\syswow64" Windows/winsxs/$i -y | Select-String 'ok' ; Write-Host processed 32-bit $($i.split('/')[-1])}} quit?('7z')

    $scrdlls = @( 'amd64_microsoft-windows-scripting-jscript_31bf3856ad364e35_8.0.7600.16385_none_f98f217587d75631/jscript.dll',`
                  'x86_microsoft-windows-scripting-jscript_31bf3856ad364e35_8.0.7600.16385_none_9d7085f1cf79e4fb/jscript.dll')

    foreach ($i in $scrdlls) {
            if( $i.SubString(0,3) -eq 'amd' ) {7z e $cachedir\\$dldir\\F_WINPEOC_AMD64__WINPE_WINPE_SCRIPTING.CAB "-o$env:systemroot\\system32" $i -y | Select-String 'ok' ; Write-Host processed 64-bit $($i.split('/')[-1])}
            if( $i.SubString(0,3) -eq 'x86' ) {7z e $cachedir\\$dldir\\F_WINPEOC_X86__WINPE_WINPE_SCRIPTING.CAB "-o$env:systemroot\\syswow64" $i -y | Select-String 'ok' ; Write-Host processed 32-bit $($i.split('/')[-1])}} quit?('7z')

    $dlls = @('urlmon.dll' <# ,'iertutil.dll' #>)

    foreach ($i in $dlls) {
        7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/System32/$i -y | Select-String 'ok' ; Write-Host processed 64-bit $($i.split('/')[-1])
        7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\syswow64" Windows/System32/$i -y | Select-String 'ok' ; Write-Host processed 32-bit $($i.split('/')[-1])} quit?('7z')

    foreach($i in 'mshtml', 'ieframe', 'urlmon', 'jscript', 'iertutil', 'shlwapi') { dlloverride 'native' $i }
    foreach($i in 'msimtf') { dlloverride 'builtin' $i }

<# Note: the 'back-tick+n's below is line-break when we write below stuff to file, saves space  #>
$regkey = @"
REGEDIT4
[HKEY_LOCAL_MACHINE\Software\Classes\CLSID\{30C3B080-30FB-11d0-B724-00AA006C1A01}]
@="CoMapMIMEToCLSID Class"
[HKEY_LOCAL_MACHINE\Software\Classes\CLSID\{30C3B080-30FB-11d0-B724-00AA006C1A01}\InProcServer32]
@="C:\\windows\\system32\\imgutil.dll"
"ThreadingModel"="Both"
[HKEY_LOCAL_MACHINE\Software\Classes\CLSID\{30C3B080-30FB-11d0-B724-00AA006C1A01}\ProgID]
@="ImgUtil.CoMapMIMEToCLSID.1"
[HKEY_LOCAL_MACHINE\Software\Classes\CLSID\{6A01FDA0-30DF-11d0-B724-00AA006C1A01}]
@="CoSniffStream Class"
[HKEY_LOCAL_MACHINE\Software\Classes\CLSID\{6A01FDA0-30DF-11d0-B724-00AA006C1A01}\InProcServer32]
@="C:\\windows\\system32\\imgutil.dll"
"ThreadingModel"="Both"
[HKEY_LOCAL_MACHINE\Software\Classes\CLSID\{6A01FDA0-30DF-11d0-B724-00AA006C1A01}\ProgID]
@="ImgUtil.CoSniffStream.1"
[HKEY_LOCAL_MACHINE\Software\Classes\CLSID\{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}]
@="CoPNGFilter Class"
[HKEY_LOCAL_MACHINE\Software\Classes\CLSID\{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}\InProcServer32]
@="C:\\windows\\system32\\pngfilt.dll"
"ThreadingModel"="Both"
[HKEY_LOCAL_MACHINE\Software\Classes\CLSID\{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}\ProgID]
@="PNGFilter.CoPNGFilter.1"
[HKEY_LOCAL_MACHINE\Software\Classes\MIME\Database\Content Type\image/png]
"Extension"=".png"
"Image Filter CLSID"="{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}"
[HKEY_LOCAL_MACHINE\Software\Classes\MIME\Database\Content Type\image/png\Bits]
"0"=hex:08,00,00,00,ff,ff,ff,ff,ff,ff,ff,ff,89,50,4e,47,0d,0a,1a,0a
[HKEY_LOCAL_MACHINE\Software\Classes\MIME\Database\Content Type\image/x-png]
"Extension"=".png"
"Image Filter CLSID"="{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}"
[HKEY_LOCAL_MACHINE\Software\Classes\MIME\Database\Content Type\image/x-png\Bits]
"0"=hex:08,00,00,00,ff,ff,ff,ff,ff,ff,ff,ff,89,50,4e,47,0d,0a,1a,0a
[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Lockdown_Zones]
[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Lockdown_Zones\0]
[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3]
@=""
"1206"=dword:00000003`n"1207"=dword:00000003`n"1208"=dword:00000003`n"1209"=dword:00000003`n"120A"=dword:00000003`n"120B"=dword:00000003
"1408"=dword:00000003`n"1409"=dword:00000000`n"160A"=dword:00000003`n"1806"=dword:00000001`n"1807"=dword:00000001`n"1808"=dword:00000000
"1809"=dword:00000000`n"180A"=dword:00000003`n"180C"=dword:00000003`n"180D"=dword:00000001`n"2000"=dword:00000000`n"2005"=dword:00000003
"2100"=dword:00000000`n"2101"=dword:00000000`n"2102"=dword:00000003`n"2103"=dword:00000003`n"2104"=dword:00000003`n"2105"=dword:00000003
"2106"=dword:00000000`n"2200"=dword:00000003`n"2201"=dword:00000003`n"2300"=dword:00000001`n"2301"=dword:00000000`n"2400"=dword:00000000
"2401"=dword:00000000`n"2402"=dword:00000000`n"2500"=dword:00000000`n"2600"=dword:00000000`n"2700"=dword:00000000
"Icon"="inetcpl.cpl#001313"`n"LowIcon"="inetcpl.cpl#005425"`n"PMDisplayName"="Internet [Protected Mode]"`n"RecommendedLevel"=dword:00011500
"@
    reg_edit $regkey
} <# end mshtml #>

function func_gdiplus
{
    $url = "https://download.microsoft.com/download/3/5/C/35C470D8-802B-457A-9890-F1AFC277C907/Windows6.1-KB2834886-x64.msu"
    $cab = "Windows6.1-KB2834886-x64.cab"
    $sourcefile = @('gdiplus.dll')

    if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $(verb),  "$(verb).7z") ) ) {
        check_msu_sanity $url $cab;
        foreach ($i in $sourcefile) { &$expand_exe $([IO.Path]::Combine($cachedir,  $(verb),  $cab)) -f:$i $([IO.Path]::Combine($cachedir,  $(verb) ) ) }
        7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on "$cachedir\$(verb)\$(verb).7z" "$cachedir\$(verb)\amd64_microsoft.windows.gdiplus_6595b64144ccf1df_1.1.7601.22290_none_145f0c928b8d0397" "$cachedir\$(verb)\x86_microsoft.windows.gdiplus_6595b64144ccf1df_1.1.7601.22290_none_5c0c4369a0092c9d" ; quit?('7z')
    }

    foreach($i in "$cab", "amd64", "x86", "wow64") { Remove-Item -Force -Recurse "$cachedir\$(verb)\$i*" -Erroraction SilentlyContinue }

    system_install $(verb) $null $true
#    7z e "$cachedir\$(verb)\$(verb).7z" "amd64*\*" -o"$env:systemroot\\system32" -aoa
#    7z e "$cachedir\$(verb)\$(verb).7z" "x86*\*" -o"$env:systemroot\\syswow64" -aoa
		  
    foreach($i in 'gdiplus') { dlloverride 'native' $i }  
} <# end gdiplus #>

function func_d2d1
{
    $url = "http://download.windowsupdate.com/d/msdownload/update/software/updt/2016/05/windows6.1-kb3125574-v4-x64_2dafb1d203c8964239af3048b5dd4b1264cd93b9.msu"
    $cab = "Windows6.1-KB3125574-v4-x64.cab"
    $sourcefile = @('d2d1.dll')
    if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $(verb),  "$(verb).7z") ) ) {
        check_msu_sanity $url $cab;
        foreach ($i in $sourcefile) { & $expand_exe $([IO.Path]::Combine($cachedir,  $(verb),  $cab)) -f:$i $([IO.Path]::Combine($cachedir,  $(verb) ) ) }
        7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on "$cachedir\$(verb)\$(verb).7z" "$cachedir\$(verb)\amd64_microsoft-windows-d2d_31bf3856ad364e35_7.1.7601.23403_none_f7c6a38a168dcfb8" "$cachedir\$(verb)\x86_microsoft-windows-d2d_31bf3856ad364e35_7.1.7601.23403_none_9ba808065e305e82" ; quit?('7z')
    }

    foreach($i in "$cab", "amd64", "x86", "wow64") { Remove-Item -Force -Recurse "$cachedir\$(verb)\$i*" -Erroraction SilentlyContinue }

    #https://4sysops.com/archives/how-to-create-an-open-file-folder-dialog-box-with-powershell/
    try{ $null=[System.Reflection.Assembly]::GetAssembly([System.Windows.Forms]) }
    catch { [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null }
    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
    InitialDirectory =  [System.IO.Directory]::GetCurrentDirectory() 
    Filter = 'exe files (*.exe)|*.exe'
    Title = "Select the exe for which you want to add the 'native' $(verb) override" }
    if ( $FileBrowser.ShowDialog() -eq 'Cancel' ) {exit}

    $file = ([System.IO.FileInfo]($FileBrowser.FileName)).name
    $filepath = ([System.IO.FileInfo]($FileBrowser.FileName)).Fullname
    $destdir =([System.IO.FileInfo]($FileBrowser.FileName)).Directory

    if ( $(7z l $filepath | findstr 'CPU' |select-string x64) )       {$arch = 'amd64'}
    elseif ( $(7z l $filepath | findstr 'CPU' |select-string x86) )   {$arch = 'x86'}
    else {Write-Host 'Something went wrong...'; exit}
    
    check_aik_sanity;
  
    7z e "$cachedir\$(verb)\$(verb).7z" "$($arch)*\*" "-o$destdir" -y| Select-String 'ok' ; quit?('7z') 
     
    if(!(Test-Path "HKCU:\\Software\\Wine\\AppDefaults\\$file")) {New-Item  -Path "HKCU:\\Software\\Wine\\AppDefaults\\$file"}
    if(!(Test-Path "HKCU:\\Software\\Wine\\AppDefaults\\$file\\DllOverrides")) {New-Item  -Path "HKCU:\\Software\\Wine\\AppDefaults\\$file\\DllOverrides"}
    New-ItemProperty -Path "HKCU:\\Software\\Wine\\AppDefaults\\$file\\DllOverrides" -Name "$(verb)" -Value 'native,builtin' -PropertyType 'String' -force 
} <# end d2d1 #>

function func_dinput8
{
    $url = "https://catalog.s.download.windowsupdate.com/c/msdownload/update/software/updt/2018/08/windows10.0-kb4343893-x64_bdae9c9c28d4102a673a24d37c371ed73d053338.msu"
    $cab = "Windows10.0-KB4343893-x64.cab"
    $sourcefile = @('dinput8.dll')

    if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $(verb),  "$(verb).7z") ) ) {
        check_msu_sanity $url $cab;
        foreach ($i in $sourcefile) { & $expand_exe $([IO.Path]::Combine($cachedir,  $(verb),  $cab)) -f:$i $([IO.Path]::Combine($cachedir,  $(verb) ) ) }
        7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on "$cachedir\$(verb)\$(verb).7z" "$cachedir\$(verb)\amd64*" "$cachedir\$(verb)\x86*" ; quit?('7z')

        foreach($i in 'amd64', 'x86', 'wow64') { Remove-Item -Force -Recurse "$cachedir\$(verb)\$i*" }
    }

    Remove-Item -Force "$cachedir\$(verb)\$cab" -ErrorAction SilentlyContinue

    7z e "$cachedir\$(verb)\$(verb).7z" "amd64*\*" -o"$env:systemroot\\system32" -aoa
    7z e "$cachedir\$(verb)\$(verb).7z" "x86*\*" -o"$env:systemroot\\syswow64" -aoa

    foreach($i in 'dinput8') { dlloverride 'native' $i }  
} <# end dinput8 #>

function func_wmp
{
    $url = "https://download.microsoft.com/download/7/A/D/7AD12930-3AA6-4040-81CF-350BF1E99076/Windows6.2-KB2703761-x64.msu"
    $cab = "Windows6.2-KB2703761-x64.cab"
    $sourcefile = @('wmasf.dll', 'wmvcore.dll', 'wmnetmgr.dll', 'mfplat.dll', 'wmpdxm.dll', 'wmp.dll', 'wmploc.dll')

    if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $(verb),  "$(verb).7z") ) ) {
        check_msu_sanity $url $cab;
        foreach ($i in $sourcefile) { & $expand_exe $([IO.Path]::Combine($cachedir,  $(verb),  $cab)) -f:$i $([IO.Path]::Combine($cachedir,  $(verb) ) ) }
        7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on "$cachedir\$(verb)\$(verb).7z" "$cachedir\$(verb)\amd64*" "$cachedir\$(verb)\x86*" "$cachedir\$(verb)\wow64*"; quit?('7z')

        foreach($i in 'amd64', 'x86', 'wow64') { Remove-Item -Force -Recurse "$cachedir\$(verb)\$i*" }
    }

    Remove-Item -Force "$cachedir\$(verb)\$cab" -ErrorAction SilentlyContinue

    7z e "$cachedir\$(verb)\$(verb).7z" amd64_*\* -o"$env:systemroot\\system32" -aoa
    7z e "$cachedir\$(verb)\$(verb).7z" x86_*\* -o"$env:systemroot\\syswow64" -aoa
    7z e "$cachedir\$(verb)\$(verb).7z" wow64_*\* -o"$env:systemroot\\syswow64" -aoa ; quit?('7z')
  
    foreach($i in 'wmp') { dlloverride 'native' $i }

    foreach($i in 'wmp', 'wmpdxm') {
        & "$env:systemroot\\syswow64\\regsvr32" /s "$env:systemroot\\syswow64\\$i.dll"
        & "$env:systemroot\\system32\\regsvr32" /s "$env:systemroot\\system32\\$i.dll" }
} <# end wmp #>

function func_wmf
{
    $url = "http://download.windowsupdate.com/d/msdownload/update/software/updt/2016/05/windows6.1-kb3125574-v4-x64_2dafb1d203c8964239af3048b5dd4b1264cd93b9.msu"
    $cab = "Windows6.1-KB3125574-v4-x64.cab"
    $sourcefile = @('colorcnv.dll', 'mf.dll', 'mfps.dll', 'mferror.dll', 'mfplat.dll', 'mfplay.dll', 'mfreadwrite.dll', 'msmpeg2adec.dll', 'msmpeg2vdec.dll', 'sqmapi.dll', 'wmadmod.dll', 'wmvdecod.dll', 'wow64_microsoft-windows-mediafoundation_31bf3856ad364e35_6.1.7601.23403_none_056d1a0e70d89a35.manifest', 'amd64_microsoft-windows-mediafoundation_31bf3856ad364e35_6.1.7601.23403_none_fb186fbc3c77d83a.manifest')
    if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $(verb),  "$(verb).7z") ) ) {
        check_msu_sanity $url $cab;
        foreach ($i in $sourcefile) { & $expand_exe $([IO.Path]::Combine($cachedir,  $(verb),  $cab)) -f:$i $([IO.Path]::Combine($cachedir,  $(verb) ) ) }
        7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on "$cachedir\$(verb)\$(verb).7z" "$cachedir\$(verb)\amd64_*" "$cachedir\$(verb)\x86_*" "$cachedir\$(verb)\wow64_*"; quit?('7z')
    }

    foreach($i in "$cab", "amd64", "x86", "wow64") { Remove-Item -Force -Recurse "$cachedir\$(verb)\$i*" -Erroraction SilentlyContinue }

    check_aik_sanity;
  
    7z e "$cachedir\$(verb)\$(verb).7z" amd64_*\* -o"$env:systemroot\\system32" -aoa
    7z e "$cachedir\$(verb)\$(verb).7z" x86_*\* -o"$env:systemroot\\syswow64" -aoa
    7z e "$cachedir\$(verb)\$(verb).7z" wow64_*\* -o"$env:systemroot\\syswow64" -aoa ; quit?('7z')
    
    foreach($i in 'mf', 'mferror', 'mfplat', <# 'mfplay',#> 'mfreadwrite', 'msmpeg2adec', 'msmpeg2vdec') { dlloverride 'native' $i }
     
    foreach($i in 'colorcnv', 'msmpeg2adec', 'msmpeg2vdec', 'wmadmod', 'wmvdecod', 'mfps' <#, 'mf'#>) {
        & "$env:systemroot\\syswow64\\regsvr32" /s "$env:systemroot\\syswow64\\$i.dll"
        & "$env:systemroot\\system32\\regsvr32" /s "$env:systemroot\\system32\\$i.dll" }
        
        $mfregkey = @"
REGEDIT4
[HKEY_LOCAL_MACHINE\Software\Wine\LicenseInformation]
"msmpeg2adec-AACDecoderV2AddInEnable"=dword:00000001
"msmpeg2adec-AACDecoderV2InSKU"=dword:00000001
"msmpeg2adec-DolbyDigitalDecoderV2AddInEnable"=dword:00000001
"msmpeg2adec-DolbyDigitalDecoderV2InSKU"=dword:00000001
"msmpeg2vdec-H264VideoDecoderV2AddInEnable"=dword:00000001
"msmpeg2vdec-H264VideoDecoderV2InSKU"=dword:00000001
"msmpeg2vdec-MPEG2VideoDecoderV2AddInEnable"=dword:00000001
"msmpeg2vdec-MPEG2VideoDecoderV2InSKU"=dword:00000001

[HKEY_CLASSES_ROOT\CLSID\{271C3902-6095-4c45-A22F-20091816EE9E}]
@="MPEG4 Byte Stream Handler"

[HKEY_CLASSES_ROOT\CLSID\{271C3902-6095-4c45-A22F-20091816EE9E}\InprocServer32]
@="mf.dll"
"ThreadingModel"="Both"

[HKEY_CLASSES_ROOT\CLSID\{477EC299-1421-4bdd-971F-7CCB933F21AD}]
@="File Scheme Handler"

[HKEY_CLASSES_ROOT\CLSID\{477EC299-1421-4bdd-971F-7CCB933F21AD}\InprocServer32]
@="mf.dll"
"ThreadingModel"="Both"

[HKEY_CLASSES_ROOT\CLSID\{48e2ed0f-98c2-4a37-bed5-166312ddd83f}]
@="MFReadWrite Class Factory"

[HKEY_CLASSES_ROOT\CLSID\{48e2ed0f-98c2-4a37-bed5-166312ddd83f}\InprocServer32]
@="mfreadwrite.dll"
"ThreadingModel"="Both"
"@

    reg_edit $mfregkey
    
        $wmfregkey = @"
REGEDIT4

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation]

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers]

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\.3g2]
"{271C3902-6095-4c45-A22F-20091816EE9E}"="MPEG4 Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\.3gp]
"{271C3902-6095-4c45-A22F-20091816EE9E}"="MPEG4 Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\.3gp2]
"{271C3902-6095-4c45-A22F-20091816EE9E}"="MPEG4 Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\.3gpp]
"{271C3902-6095-4c45-A22F-20091816EE9E}"="MPEG4 Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\.aac]
"{926f41f7-003e-4382-9e84-9e953be10562}"="ADTS Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\.adt]
"{926f41f7-003e-4382-9e84-9e953be10562}"="ADTS Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\.adts]
"{926f41f7-003e-4382-9e84-9e953be10562}"="ADTS Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\.asf]
"{41457294-644C-4298-A28A-BD69F2C0CF3B}"="ASF Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\.avi]
"{7AFA253E-F823-42f6-A5D9-714BDE467412}"="AVI Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\.dvr-ms]
"{a8721937-e2fb-4d7a-a9ee-4eb08c890b6e}"="MF SBE Source ByteStreamHandler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\.m4a]
"{271C3902-6095-4c45-A22F-20091816EE9E}"="MPEG4 Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\.m4v]
"{271C3902-6095-4c45-A22F-20091816EE9E}"="MPEG4 Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\.mov]
"{271C3902-6095-4c45-A22F-20091816EE9E}"="MPEG4 Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\.mp3]
"{A82E50BA-8E92-41eb-9DF2-433F50EC2993}"="MP3 Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\.mp4]
"{271C3902-6095-4c45-A22F-20091816EE9E}"="MPEG4 Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\.mp4v]
"{271C3902-6095-4c45-A22F-20091816EE9E}"="MPEG4 Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\.nsc]
"{B084785C-DDE0-4d30-8CA8-05A373E185BE}"="NSC Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\.sami]
"{7A56C4CB-D678-4188-85A8-BA2EF68FA10D}"="SAMI Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\.smi]
"{7A56C4CB-D678-4188-85A8-BA2EF68FA10D}"="SAMI Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\.wav]
"{42C9B9F5-16FC-47ef-AF22-DA05F7C842E3}"="WAV Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\.wm]
"{41457294-644C-4298-A28A-BD69F2C0CF3B}"="ASF Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\.wma]
"{41457294-644C-4298-A28A-BD69F2C0CF3B}"="ASF Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\.wmv]
"{41457294-644C-4298-A28A-BD69F2C0CF3B}"="ASF Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\audio/3gpp]
"{271C3902-6095-4c45-A22F-20091816EE9E}"="MPEG4 Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\audio/3gpp2]
"{271C3902-6095-4c45-A22F-20091816EE9E}"="MPEG4 Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\audio/aac]
"{926f41f7-003e-4382-9e84-9e953be10562}"="ADTS Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\audio/aacp]
"{926f41f7-003e-4382-9e84-9e953be10562}"="ADTS Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\audio/L16]
"{3FFB3B8C-EB99-472b-8902-E1C1B05F07CF}"="LPCM Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\audio/mp4]
"{271C3902-6095-4c45-A22F-20091816EE9E}"="MPEG4 Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\audio/mpeg]
"{A82E50BA-8E92-41eb-9DF2-433F50EC2993}"="MP3 Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\audio/vnd.dlna.adts]
"{926f41f7-003e-4382-9e84-9e953be10562}"="ADTS Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\audio/wav]
"{42C9B9F5-16FC-47ef-AF22-DA05F7C842E3}"="WAV Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\audio/x-aac]
"{926f41f7-003e-4382-9e84-9e953be10562}"="ADTS Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\audio/x-mp3]
"{A82E50BA-8E92-41eb-9DF2-433F50EC2993}"="MP3 Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\audio/x-mpeg]
"{A82E50BA-8E92-41eb-9DF2-433F50EC2993}"="MP3 Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\audio/x-ms-wma]
"{41457294-644C-4298-A28A-BD69F2C0CF3B}"="ASF Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\audio/x-wav]
"{42C9B9F5-16FC-47ef-AF22-DA05F7C842E3}"="WAV Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\video/3gpp]
"{271C3902-6095-4c45-A22F-20091816EE9E}"="MPEG4 Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\video/3gpp2]
"{271C3902-6095-4c45-A22F-20091816EE9E}"="MPEG4 Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\video/avi]
"{7AFA253E-F823-42f6-A5D9-714BDE467412}"="AVI Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\video/mp4]
"{271C3902-6095-4c45-A22F-20091816EE9E}"="MPEG4 Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\video/msvideo]
"{7AFA253E-F823-42f6-A5D9-714BDE467412}"="AVI Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\video/x-ms-asf]
"{41457294-644C-4298-A28A-BD69F2C0CF3B}"="ASF Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\video/x-ms-wm]
"{41457294-644C-4298-A28A-BD69F2C0CF3B}"="ASF Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\video/x-ms-wmv]
"{41457294-644C-4298-A28A-BD69F2C0CF3B}"="ASF Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\ByteStreamHandlers\video/x-msvideo]
"{7AFA253E-F823-42f6-A5D9-714BDE467412}"="AVI Byte Stream Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\HardwareMFT]
"EnableDecoders"=dword:00000000
"EnableEncoders"=dword:00000001
"EnableVideoProcessors"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\Platform]

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\Platform\EVR]

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\Platform\EVR\{16260968-C914-4aa1-8736-B7A6F3C5AE9B}]
"SWVideoDecodePowerLevel"=dword:00000000
"OptimizationFlags"=dword:00000590

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\Platform\EVR\{5C67A112-A4C9-483f-B4A7-1D473BECAFDC}]
"SWVideoDecodePowerLevel"=dword:00000064
"OptimizationFlags"=dword:00000a10

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\Platform\EVR\{651288E5-A7ED-4076-A96B-6CC62D848FE1}]
"SWVideoDecodePowerLevel"=dword:00000032
"OptimizationFlags"=dword:00000590

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\RemoteDesktop]
"PluginCLSID"="{636c15cf-df63-4790-866a-117163d10a46}"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\SchemeHandlers]

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\SchemeHandlers\file:]
"{477EC299-1421-4bdd-971F-7CCB933F21AD}"="File Scheme Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\SchemeHandlers\http:]
"{9EC4B4F9-3029-45ad-947B-344DE2A249E2}"="Urlmon Scheme Handler"
"{E9F4EBAB-D97B-463e-A2B1-C54EE3F9414D}"="Net Scheme Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\SchemeHandlers\httpd:]
"{44CB442B-9DA9-49df-B3FD-023777B16E50}"="Http Scheme Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\SchemeHandlers\httpnd:]
"{2EEEED04-0908-4cdb-AF8F-AC5B768A34C9}"="Drm Scheme Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\SchemeHandlers\https:]
"{37A61C8B-7F8E-4d08-B12B-248D73E9AB4F}"="Secure Http Scheme Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\SchemeHandlers\httpsd:]
"{37A61C8B-7F8E-4d08-B12B-248D73E9AB4F}"="Secure Http Scheme Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\SchemeHandlers\httpt:]
"{E9F4EBAB-D97B-463e-A2B1-C54EE3F9414D}"="Net Scheme Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\SchemeHandlers\httpu:]
"{E9F4EBAB-D97B-463e-A2B1-C54EE3F9414D}"="Net Scheme Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\SchemeHandlers\mcast:]
"{E9F4EBAB-D97B-463e-A2B1-C54EE3F9414D}"="Net Scheme Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\SchemeHandlers\mms:]
"{E9F4EBAB-D97B-463e-A2B1-C54EE3F9414D}"="Net Scheme Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\SchemeHandlers\rtsp:]
"{E9F4EBAB-D97B-463e-A2B1-C54EE3F9414D}"="Net Scheme Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\SchemeHandlers\rtspt:]
"{E9F4EBAB-D97B-463e-A2B1-C54EE3F9414D}"="Net Scheme Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\SchemeHandlers\rtspu:]
"{E9F4EBAB-D97B-463e-A2B1-C54EE3F9414D}"="Net Scheme Handler"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\SchemeHandlers\sdp:]
"{E9F4EBAB-D97B-463e-A2B1-C54EE3F9414D}"="Net Scheme Handler"

"@
   # reg_edit $wmfregkey
   
   7z e "$cachedir\$(verb)\$(verb).7z" amd64_microsoft-windows-mediafoundation_31bf3856ad364e35_6.1.7601.23403_none_fb186fbc3c77d83a.manifest -o"$env:systemroot\\system32" -aoa
   7z e "$cachedir\$(verb)\$(verb).7z" wow64_microsoft-windows-mediafoundation_31bf3856ad364e35_6.1.7601.23403_none_056d1a0e70d89a35.manifest -o"$env:systemroot\\syswow64" -aoa

   write_keys_from_manifest "$env:systemroot\\system32\\amd64_microsoft-windows-mediafoundation_31bf3856ad364e35_6.1.7601.23403_none_fb186fbc3c77d83a.manifest"
   write_keys_from_manifest "$env:systemroot\\syswow64\\wow64_microsoft-windows-mediafoundation_31bf3856ad364e35_6.1.7601.23403_none_056d1a0e70d89a35.manifest"

} <# end wmf #>

function func_msdelta <#  msdelta and dpx from windows 10 #>
{
    $url = "https://catalog.s.download.windowsupdate.com/c/msdownload/update/software/updt/2018/08/windows10.0-kb4343893-x64_bdae9c9c28d4102a673a24d37c371ed73d053338.msu"
    $cab = "Windows10.0-KB4343893-x64.cab"
    $sourcefile = @('msdelta.dll','dpx.dll')
 
    if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $(verb),  "$(verb).7z" ) ) ){
        check_msu_sanity $url $cab;
        foreach ($i in $sourcefile) { & $expand_exe $([IO.Path]::Combine($cachedir,  $(verb),  $cab)) -f:$i $([IO.Path]::Combine($cachedir,  $(verb) ) ) }
        7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on "$cachedir\$(verb)\$(verb).7z" "$cachedir\$(verb)\amd64_microsoft-windows-i..p-media-legacy-base_31bf3856ad364e35_10.0.16299.547_none_7f0fdb243374c0d2"  ; quit?('7z')

        foreach($i in 'amd64', 'x86', 'wow64') { Remove-Item -Force -Recurse "$cachedir\$(verb)\$i*" }
    }

    Remove-Item -Force "$cachedir\$(verb)\$cab" -Erroraction SilentlyContinue
    
    if ((Get-PSCallStack)[1].Command -eq 'func_expand') {
        7z e "$cachedir\$(verb)\$(verb).7z" amd64_microsoft-windows-i..p-media-legacy-base_31bf3856ad364e35_10.0.16299.547_none_7f0fdb243374c0d2\* -o"$env:systemroot\\system32\\expnd" -aoa ; quit?('7z')
    }
    else {
        7z e "$cachedir\$(verb)\$(verb).7z" amd64_microsoft-windows-i..p-media-legacy-base_31bf3856ad364e35_10.0.16299.547_none_7f0fdb243374c0d2\* -o"$env:systemroot\\system32" -aoa ; quit?('7z')
    }
} <# end msdelta #>

function func_sapi <# Speech api #>
{   
    $url = "http://download.windowsupdate.com/c/msdownload/update/software/updt/2016/11/windows10.0-kb3205436-x64_45c915e7a85a7cc7fc211022ecd38255297049c3.msu"
    $cab = "Windows10.0-KB3205436-x64.cab"
    $sourcefile = @( 'sapi.dll' )

    if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $(verb), "$(verb).7z") ) ) {
        check_msu_sanity $url $cab;
        foreach ($i in $sourcefile) { & $expand_exe $([IO.Path]::Combine($cachedir,  $(verb),  $cab)) -f:$i $([IO.Path]::Combine($cachedir,  $(verb) ) ) }
        7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on "$cachedir\$(verb)\$(verb).7z" "$cachedir\$(verb)\amd64*" "$cachedir\$(verb)\x86*" ; quit?('7z')

        foreach($i in 'amd64', 'x86', 'wow64') { Remove-Item -Force -Recurse "$cachedir\$(verb)\$i*)" }
    }

    Remove-Item -Force "$cachedir\$(verb)\$cab" -ErrorAction SilentlyContinue

    7z e "$cachedir\$(verb)\$(verb).7z" "amd64*\*" -o"$env:systemroot\\system32\\Speech\\Common" -aoa
    7z e "$cachedir\$(verb)\$(verb).7z" "x86*\*" -o"$env:systemroot\\syswow64\\Speech\\Common" -aoa; quit?('7z')

    reg.exe DELETE "HKLM\SOFTWARE\Microsoft\Speech\Voices\Tokens\Wine Default Voice" /f /reg:64
    reg.exe DELETE "HKLM\SOFTWARE\Microsoft\Speech\Voices\Tokens\Wine Default Voice" /f /reg:32

    $dldir = "SpeechRuntime"
    w_download_to "$dldir\\32" "https://download.microsoft.com/download/A/6/4/A64012D6-D56F-4E58-85E3-531E56ABC0E6/x86_SpeechPlatformRuntime/SpeechPlatformRuntime.msi" "SpeechPlatformRuntime.msi"
    w_download_to "$dldir\\64" "https://download.microsoft.com/download/A/6/4/A64012D6-D56F-4E58-85E3-531E56ABC0E6/x64_SpeechPlatformRuntime/SpeechPlatformRuntime.msi" "SpeechPlatformRuntime.msi"

    iex "msiexec /i $cachedir\\$dldir\\64\\SpeechPlatformRuntime.msi INSTALLDIR='$env:SystemRoot\\system32\\Speech\\Engines' /q "
    iex "msiexec /i $cachedir\\$dldir\\32\\SpeechPlatformRuntime.msi INSTALLDIR='$env:SystemRoot\\syswow64\\Speech\\Engines' /q "

    foreach ($i in 'sapi', 'msttsengine') { dlloverride 'native' $i } 

    foreach($i in 'sapi.dll') {
        & "$env:systemroot\\syswow64\\regsvr32" /s "$env:systemroot\\syswow64\\Speech\\Common\\$i"
        & "$env:systemroot\\system32\\regsvr32" /s "$env:systemroot\\system32\\Speech\\Common\\$i" }

    w_download_to "$dldir" "https://download.microsoft.com/download/4/0/D/40D6347A-AFA5-417D-A9BB-173D937BEED4/MSSpeech_TTS_en-US_ZiraPro.msi" "MSSpeech_TTS_en-US_ZiraPro.msi"

    iex "msiexec /i $cachedir\\$dldir\\MSSpeech_TTS_en-US_ZiraPro.msi <# INSTALLDIR='$env:SystemRoot\\Speech\\Engines\\TTS\\en-US' #> "

    quit?('msiexec')

    reg.exe COPY "HKLM\Software\MicroSoft\Speech Server\v11.0" "HKLM\Software\MicroSoft\Speech" /s /f /reg:64
    reg.exe COPY "HKLM\Software\MicroSoft\Speech Server\v11.0" "HKLM\Software\MicroSoft\Speech" /s /f /reg:32

    pwsh -c {
        $voice = new-object -com SAPI.SpVoice
        $voice.Speak("This is mostly a bunch of crap. Please improve me", 2)
    }
} <# end sapi #>

function deprecated_func_winmetadata <# winmetadata #>
{   
    $url = "https://catalog.s.download.windowsupdate.com/c/msdownload/update/software/updt/2018/08/windows10.0-kb4343893-x64_bdae9c9c28d4102a673a24d37c371ed73d053338.msu"
    $cab = "Windows10.0-KB4343893-x64.cab"
    $sourcefile = @(`
    'windows.web.winmd', 'windows.foundation.winmd', 'windows.graphics.winmd', 'windows.services.winmd', 'windows.data.winmd', 'windows.media.winmd',
    'windows.system.winmd', 'windows.ui.winmd', 'windows.security.winmd', 'windows.globalization.winmd', 'windows.management.winmd', 'windows.devices.winmd',
    'windows.perception.winmd', 'windows.storage.winmd', 'windows.ui.xaml.winmd', 'windows.gaming.winmd', 'windows.applicationmodel.winmd', 'windows.networking.winmd'`
    )

    New-Item -Path $env:systemroot\\system32\\winmetadata -Type Directory -force -erroraction silentlycontinue
    New-Item -Path $env:systemroot\\syswow64\\winmetadata -Type Directory -force -erroraction silentlycontinue

    if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $(verb),  "$(verb).7z") ) ) {
        check_msu_sanity $url $cab;
        foreach ($i in $sourcefile) { & $expand_exe $([IO.Path]::Combine($cachedir,  $(verb),  $cab)) -f:$i $([IO.Path]::Combine($cachedir,  $(verb) ) ) }
        7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on "$cachedir\$(verb)\$(verb).7z" "$cachedir\$(verb)\amd64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_53be06ac791695fb" "$cachedir\$(verb)\wow64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_5e12b0fead7757f6" ; quit?('7z')
        foreach($i in 'amd64', 'x86', 'wow64') { Remove-Item -Force -Recurse "$cachedir\$(verb)\$i*" }
    }

    Remove-Item -Force "$cachedir\$(verb)\$cab" -Erroraction SilentlyContinue

    7z e "$cachedir\$(verb)\$(verb).7z" "amd64*\*" -o"$env:systemroot\\system32\\winmetadata" -aoa
    7z e "$cachedir\$(verb)\$(verb).7z" "wow64*\*" -o"$env:systemroot\\syswow64\\winmetadata" -aoa

} <# end winmetadata #>

function func_winmetadata <# winmetadata alternative#>
{   
    New-Item -Path $env:systemroot\\system32\\winmetadata -Type Directory -force -erroraction silentlycontinue
    New-Item -Path $env:systemroot\\syswow64\\winmetadata -Type Directory -force -erroraction silentlycontinue

    $url='https://raw.githubusercontent.com/microsoft/windows-rs/master/crates/libs/bindgen/default/Windows.winmd'

    w_download_to $(verb) 'https://raw.githubusercontent.com/microsoft/windows-rs/master/crates/libs/bindgen/default/Windows.winmd' "Windows.winmd"

    if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $(verb),  "$(verb).7z") ) ) {
        7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on "$cachedir\$(verb)\$(verb).7z" "$cachedir\$(verb)\Windows.winmd" ; quit?('7z')
        foreach($i in 'Windows.winmd') { Remove-Item -Force "$cachedir\$(verb)\$i*" }
    }

    7z e "$cachedir\$(verb)\$(verb).7z" "Windows.winmd" -o"$env:systemroot\\system32\\winmetadata" -aoa
    7z e "$cachedir\$(verb)\$(verb).7z" "Windows.winmd" -o"$env:systemroot\\syswow64\\winmetadata" -aoa

    func_wine_wintypes

#    Move-Item "$env:Systemroot\system32\wintypes2.dll" "$env:Systemroot\system32\wintypes.dll" -force -erroraction silentlycontinue
#    Move-Item "$env:Systemroot\syswow64\wintypes2.dll" "$env:Systemroot\syswow64\wintypes.dll" -force -erroraction silentlycontinue

    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -Name 'wintypes' -Value 'native' -PropertyType 'String' -force
#    Remove-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -Name 'wintypes2' -erroraction silentlycontinue -force 
} <# end winmetadata #>

function func_ie8 <# ie8 #>
{
    w_download_to $(verb) "http://download.microsoft.com/download/7/5/4/754D6601-662D-4E39-9788-6F90D8E5C097/IE8-WindowsServer2003-x64-ENU.exe" "IE8-WindowsServer2003-x64-ENU.exe"

  #  if(!(Test-Path "HKCU:\\Software\\Wine\\AppDefaults\\IE8-WindowsServer2003-x64-ENU.exe")) {New-Item  -Path "HKCU:\\Software\\Wine\\AppDefaults\\IE8-WindowsServer2003-x64-ENU.exe"}
  #  New-ItemProperty -Path "HKCU:\\Software\\Wine\\AppDefaults\\IE8-WindowsServer2003-x64-ENU.exe" -Name 'Version' -Value 'win2003' -PropertyType 'String' -force
  #  if(!(Test-Path "HKCU:\\Software\\Wine\\AppDefaults\\iesetup.exe")) {New-Item  -Path "HKCU:\\Software\\Wine\\AppDefaults\\iesetup.exe"}
  #  New-ItemProperty -Path "HKCU:\\Software\\Wine\\AppDefaults\\iesetup.exe" -Name 'Version' -Value 'win2003' -PropertyType 'String' -force
  #  if(!(Test-Path "HKCU:\\Software\\Wine\\AppDefaults\\iexplore.exe")) {New-Item  -Path "HKCU:\\Software\\Wine\\AppDefaults\\iexplore.exe"}
  # New-ItemProperty -Path "HKCU:\\Software\\Wine\\AppDefaults\\iexplore.exe" -Name 'Version' -Value 'win2003' -PropertyType 'String' -force

    winecfg /v win2003
    
    iexplore -unregserver 
    
    #for version check
    foreach($i in 'iexplore.exe') { dlloverride 'native' $i }
        foreach($i in 'updspapi') { dlloverride 'builtin' $i }
        
    # iexplore -unregserver needded???
    # w_override_dlls builtin updspapi needded???

 
#        foreach($i in "$env:SystemRoot\syswow64\iexplore.exe", "$env:SystemRoot\system32\iexplore.exe", "$env:ProgramFiles\Internet Explorer\iexplore.exe", "${env:ProgramFiles`(x86`)}\\Internet Explorer\\iexplore.exe")
        foreach($i in  "$env:ProgramFiles\Internet Explorer\iexplore.exe")
{
        #https://stackoverflow.com/questions/73790902/replace-string-in-a-binary-clipboard-dump-from-onenote
        # Read the file *as a byte array*.
        $data = Get-Content -AsByteStream -ReadCount 0  "$i"
        # Convert the array to a "hex string" in the form "nn-nn-nn-...",  where nn represents a two-digit hex representation of each byte,
        # e.g. '41-42' for 0x41, 0x42, which, if interpreted as a single-byte encoding (ASCII), is 'AB'.
        $dataAsHexString = [BitConverter]::ToString($data)
        
        # The installer seems to check FileVersionRaw which seems te be just before version strings in the binary; replace major version 9 with 7 -->
        $searchAsHexString =   '09-00-25-40-B0-1F-00-00-09-00-25-40-B0-1F'
        $replaceAsHexString =  '07-00-25-40-B0-1F-00-00-07-00-25-40-B0-1F'

        # Perform the replacement.
        $dataAsHexString = $dataAsHexString.Replace($searchAsHexString, $replaceAsHexString)
        # Convert he modified "hex string" back to a byte[] array.
        $modifiedData = [byte[]] ($dataAsHexString -split '-' -replace '^', '0x')
        # Save the byte array back to the file.
        Set-Content -AsByteStream "$i" -Value $modifiedData -verbose
 }
 
    # foreach($i in 'iexplore.exe') { dlloverride 'builtin' $i }
        iex "$cachedir\$(verb)\IE8-WindowsServer2003-x64-ENU.exe /no-default /norestart  /passive /log:`"c:\\`"" # /forcerestart   /update-no #/quiet "

        quit?('IE8-WindowsServer2003-x64-ENU'); quit?('iesetup');


   Copy-Item "${env:ProgramFiles`(x86`)}\\Internet Explorer\\ieproxy.dll" "$env:SystemRoot\\syswow64\\ieproxy.dll" -force 
   Copy-Item "$env:ProgramFiles\\Internet Explorer\\ieproxy.dll" "$env:systemroot\\system32\\ieproxy.dll" -force


<#
                  cat > "$W_TMP"/set-tabprocgrowth.reg <<_EOF_
REGEDIT4

[HKEY_CURRENT_USER\\Software\\Microsoft\\Internet Explorer\\Main]
"TabProcGrowth"=dword:00000000

_EOF_
        w_try_regedit "$W_TMP_WIN"\\set-tabprocgrowth.reg
    fi

#>
             
    winecfg /v win10
    
  <#      for i in browseui.dll corpol.dll dxtmsft.dll dxtrans.dll ieaksie.dll ieapfltr.dll \
             iedkcs32.dll iepeers.dll ieproxy.dll jscript.dll licmgr10.dll \
             msdbg2.dll mshtmled.dll mstime.dll shdocvw.dll tdc.ocx urlmon.dll vbscript.dll #>
    
    
    foreach($i in 'mshtml', 'ieframe',  'iertutil', 'jscript', 'urlmon', 'ieproxy', 'dxtrans') { dlloverride 'native' $i }

    foreach($i in 'msimtf') { dlloverride 'builtin' $i }
    
       # conemu64 && wineboot.exe -k


<#
01b8:err:environ:init_peb starting L"C:\\windows\\syswow64\\regsvr32.exe" in experimental wow64 mode
regsvr32: Successfully registered DLL 'C:\Program Files (x86)\Internet Explorer\ieproxy.dll'
01c4:err:environ:init_peb starting L"C:\\windows\\syswow64\\regsvr32.exe" in experimental wow64 mode
regsvr32: 'DllInstall' not implemented in DLL 'C:\windows\SysWOW64\ieframe.dll'
01d4:err:environ:init_peb starting L"C:\\windows\\syswow64\\regsvr32.exe" in experimental wow64 mode
regsvr32: Successfully registered DLL 'C:\windows\SysWOW64\actxprxy.dll'
regsvr32: Successfully registered DLL 'C:\Program Files\Internet Explorer\ieproxy.dll'
regsvr32: 'DllInstall' not implemented in DLL 'C:\windows\system32\ieframe.dll'
regsvr32: Successfully registered DLL 'C:\windows\system32\actxprxy.dll'
#>

    foreach($i in   'ieframe.dll', 'browseui.dll', 'corpol.dll', 'dxtmsft.dll', 'dxtrans.dll', 'jscript.dll', 'urlmon.dll', 'mshtmled.dll', 'shdocvw.dll', 'vbscript.dll') {
        & "$env:systemroot\\syswow64\\regsvr32" /s "$env:systemroot\\syswow64\\$i"
        & "$env:systemroot\\system32\\regsvr32" /s "$env:systemroot\\system32\\$i" }

    foreach($i in  'ieproxy.dll') {
        & "$env:systemroot\\syswow64\\regsvr32" /s "${env:ProgramFiles`(x86`)}\\Internet Explorer\\$i"
        & "$env:systemroot\\system32\\regsvr32" /s "$env:ProgramFiles\\Internet Explorer\\$i" }

<#
00e8:err:environ:init_peb starting L"C:\\windows\\syswow64\\reg.exe" in experimental wow64 mode
00e8:fixme:reg:wmain stub: L"C:\\windows\\SysWOW64\\reg.exe" L"ADD" L"HKLM\\Software\\Clients\\StartMenuInternet\\IEXPLORE.EXE\\DefaultIcon" L"/ve" L"/d" L"C:\\Program Files\\Internet Explorer\\iexplore.exe,-7" L"/f"
012c:fixme:reg:wmain stub: L"C:\\windows\\system32\\reg.exe" L"DELETE" L"HKLM\\SOFTWARE\\Microsoft\\Active Setup\\Installed Components" L"/v" L"NoIE4StubProcessing" L"/f"
0158:err:environ:init_peb starting L"C:\\windows\\syswow64\\reg.exe" in experimental wow64 mode
0158:fixme:reg:wmain stub: L"C:\\windows\\SysWOW64\\reg.exe" L"DELETE" L"HKLM\\SOFTWARE\\Microsoft\\Active Setup\\Installed Components" L"/v" L"NoIE4StubProcessing" L"/f"
0178:err:environ:init_peb starting L"C:\\windows\\syswow64\\reg.exe" in experimental wow64 mode
0178:fixme:reg:wmain stub: L"C:\\windows\\SysWOW64\\reg.exe" L"DELETE" L"HKLM\\SOFTWARE\\Microsoft\\Internet Explorer\\Setup" L"/v" L"IEPendingReboot" L"/f"
0188:err:environ:init_peb starting L"C:\\windows\\syswow64\\reg.exe" in experimental wow64 mode
0188:fixme:reg:wmain stub: L"C:\\windows\\SysWOW64\\reg.exe" L"DELETE" L"HKLM\\SOFTWARE\\Microsoft\\Internet Explorer\\Setup" L"/v" L"InstallStarted" L"/f"
01f0:fixme:reg:wmain stub: L"C:\\windows\\system32\\reg.exe" L"ADD" L"HKLM\\Software\\Clients\\StartMenuInternet\\IEXPLORE.EXE\\DefaultIcon" L"/ve" L"/d" L"C:\\Program Files\\Internet Explorer\\iexplore.exe,-7" L"/f"
0224:fixme:reg:wmain stub: L"C:\\windows\\system32\\reg.exe" L"DELETE" L"HKLM\\SOFTWARE\\Microsoft\\Active Setup\\Installed Components" L"/v" L"NoIE4StubProcessing" L"/f"
0234:fixme:reg:wmain stub: L"C:\\windows\\system32\\reg.exe" L"DELETE" L"HKLM\\SOFTWARE\\Microsoft\\Internet Explorer\\Setup" L"/v" L"IEPendingReboot" L"/f"
0244:fixme:reg:wmain stub: L"C:\\windows\\system32\\reg.exe" L"DELETE" L"HKLM\\SOFTWARE\\Microsoft\\Internet Explorer\\Setup" L"/v" L"InstallStarted" L"/f"

#>
}

function func_ps51 <# powershell 5.1; do 'ps51 -h' for help #>
{
    $url = "/Win7AndW2K8R2-KB3191566-x64.msu" <# download is zip file, so no download url of the msu #>
    $cab = "Windows6.1-KB3191566-x64.cab"

    $sourcefile = @('wow64_microsoft.powershell.packagemanagement_31bf3856ad364e35_7.3.7601.16384_none_be98c8f8cfb32e06.manifest',
    'amd64_microsoft.powershell.packagemanagement_31bf3856ad364e35_7.3.7601.16384_none_b4441ea69b526c0b.manifest',
    'msil_microsoft.powershell.consolehost_31bf3856ad364e35_7.3.7601.16384_none_8634e813855724c9.manifest',
    'amd64_microsoft.managemen..frastructure.native_31bf3856ad364e35_7.3.7601.16384_none_8ab57567838da803.manifest',
    'x86_microsoft.managemen..frastructure.native_31bf3856ad364e35_7.3.7601.16384_none_d262ac3e9809d109.manifest'
    'amd64_microsoft.powershell.archive_31bf3856ad364e35_7.3.7601.16384_none_f7ab4242f320bef0.manifest',
    'msil_microsoft.powershell.security_31bf3856ad364e35_7.3.7601.16384_none_64c18e3e0eafee92.manifest',
    'amd64_microsoft.packagemanagement.common_31bf3856ad364e35_7.3.7601.16384_none_ee66270965c165ab.manifest',
    'wow64_microsoft.packagemanagement.common_31bf3856ad364e35_7.3.7601.16384_none_f8bad15b9a2227a6.manifest',
    'amd64_microsoft.packagemanagement_31bf3856ad364e35_7.3.7601.16384_none_f23f0a687ff51c88.manifest',
                    'wow64_microsoft.packagemanagement_31bf3856ad364e35_7.3.7601.16384_none_fc93b4bab455de83.manifest',
                    'msil_system.management.automation_31bf3856ad364e35_7.3.7601.16384_none_85266a48f56bfafc.manifest',
                    'msil_microsoft.powershel..ommands.diagnostics_31bf3856ad364e35_7.3.7601.16384_none_3cbfce2c3881d318.manifest',
                    'msil_microsoft.wsman.management_31bf3856ad364e35_7.3.7601.16384_none_60964e40b40fafee.manifest',
                    'msil_microsoft.powershell.commands.management_31bf3856ad364e35_7.3.7601.16384_none_c1a0335546714b23.manifest',
                    'msil_microsoft.powershell.commands.utility_31bf3856ad364e35_7.3.7601.16384_none_d96091fd5568ce18.manifest',
                    'msil_microsoft.management.infrastructure_31bf3856ad364e35_7.3.7601.16384_none_8310156aa31a52f1.manifest',
                    'msil_microsoft.wsman.runtime_31bf3856ad364e35_7.3.7601.16384_none_a19b148df40272fb.manifest',
                    'msil_microsoft.powershell.graphicalhost_31bf3856ad364e35_7.3.7601.16384_none_c32121af2a1808d4.manifest',
                    'amd64_microsoft.powershell.psget_31bf3856ad364e35_7.3.7601.16384_none_c9db05c823f10f09.manifest',
                    'wow64_microsoft.powershell.psget_31bf3856ad364e35_7.3.7601.16384_none_d42fb01a5851d104.manifest',
                    'msil_policy.1.0.system.management.automation_31bf3856ad364e35_7.3.7601.16384_none_79a60ff187b4c325.manifest',
                    'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea.manifest',
                    'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef.manifest',
                    'wow64_microsoft.packagema..provider.powershell_31bf3856ad364e35_7.3.7601.16384_none_f50f549afdaf3c10.manifest',
                    'amd64_microsoft.packagema..provider.powershell_31bf3856ad364e35_7.3.7601.16384_none_eabaaa48c94e7a15.manifest',
                    'wow64_microsoft.packagema..ement.coreproviders_31bf3856ad364e35_7.3.7601.16384_none_f05cb06fdbbd6e3c.manifest',
'amd64_microsoft.packagema..ement.coreproviders_31bf3856ad364e35_7.3.7601.16384_none_e608061da75cac41.manifest',


'amd64_microsoft.packagema..t.archiverproviders_31bf3856ad364e35_7.3.7601.16384_none_a98e3ebb18648eb6.manifest',

'wow64_microsoft.packagema..t.archiverproviders_31bf3856ad364e35_7.3.7601.16384_none_b3e2e90d4cc550b1.manifest',


'amd64_microsoft.packagemanagement.msiprovider_31bf3856ad364e35_7.3.7601.16384_none_ae42a045a84e072e.manifest',
'wow64_microsoft.packagemanagement.msiprovider_31bf3856ad364e35_7.3.7601.16384_none_b8974a97dcaec929.manifest'
    )


    

 
    
     #Temporary workaround: In staging running ps51.exe frequently hangs in recent versions (e.g. 8.15)
    if("$($ntdll::wine_get_build_id())".Contains('(Staging)')) { 
        func_wine_shell32
        if(!(Test-Path 'HKCU:\\Software\\Wine\\AppDefaults\\ps51.exe')) {New-Item  -Path 'HKCU:\\Software\\Wine\\AppDefaults\\ps51.exe'}
        if(!(Test-Path 'HKCU:\\Software\\Wine\\AppDefaults\\ps51.exe\\DllOverrides')) {New-Item  -Path 'HKCU:\\Software\\Wine\\AppDefaults\\ps51.exe\\DllOverrides'}
        New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\ps51.exe\\DllOverrides' -Name 'shell32' -Value 'native' -PropertyType 'String' -force
    }
    else {
        if(!(Test-Path 'HKCU:\\Software\\Wine\\AppDefaults\\ps51.exe')) {New-Item  -Path 'HKCU:\\Software\\Wine\\AppDefaults\\ps51.exe'}
        if(!(Test-Path 'HKCU:\\Software\\Wine\\AppDefaults\\ps51.exe\\DllOverrides')) {New-Item  -Path 'HKCU:\\Software\\Wine\\AppDefaults\\ps51.exe\\DllOverrides'}
        New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\ps51.exe\\DllOverrides' -Name 'shell32' -Value 'builtin' -PropertyType 'String' -force
    }
    
    if( [System.IO.File]::Exists( $([IO.Path]::Combine($cachedir,  $(verb), "$(verb).7z") )) -and !($( & 7z l $([IO.Path]::Combine($cachedir,  $(verb), "$(verb).7z") ) |findstr /C:' 171 files'))  ) {
        Remove-Item -Force  "$cachedir\$(verb)\$(verb).7z" 
    }
    
    if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $(verb), "$(verb).7z") ) ) {

        if ( ![System.IO.File]::Exists( [IO.Path]::Combine($cachedir,  $(verb), "Win7AndW2K8R2-KB3191566-x64.zip" ) ) ) {
            w_download_to $(verb) "https://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/Win7AndW2K8R2-KB3191566-x64.zip" "Win7AndW2K8R2-KB3191566-x64.zip"
            7z e "$cachedir\$(verb)\Win7AndW2K8R2-KB3191566-x64.zip" "-o$cachedir\$(verb)" "Win7AndW2K8R2-KB3191566-x64.msu" -y | Select-String 'ok'; quit?('7z')
            Remove-Item -Force $([IO.Path]::Combine($cachedir,  $(verb), "Win7AndW2K8R2-KB3191566-x64.zip") ) -ErrorAction SilentlyContinue
            7z e "$cachedir\$(verb)\Win7AndW2K8R2-KB3191566-x64.msu" "-o$cachedir\$(verb)" "$cab" -y | Select-String 'ok'; quit?('7z')
            Remove-Item -Force $([IO.Path]::Combine($cachedir,  $(verb), "Win7AndW2K8R2-KB3191566-x64.msu") ) -ErrorAction SilentlyContinue

            foreach ($i in $sourcefile) {7z e "$cachedir\$(verb)\$cab" "-o$cachedir\$(verb)" $i -y} 
            
        }
        
       if (![System.IO.File]::Exists(  [IO.Path]::Combine($env:systemroot, "system32", "dpx.dll")  ))
       {Write-Host 'Downloading and extracting some files needed for expansion' ; func_expand;
        }
        

        #foreach ($i in (gci "$cachedir\$(verb)\*.manifest").Name) { & $expand_exe $([IO.Path]::Combine($cachedir,  $(verb),  $cab)) -f:$i $([IO.Path]::Combine($cachedir,  $(verb) ) ) }

        mkdir "$env:TEMP\$(verb)"
        
        foreach ($i in (gci "$cachedir\$(verb)\*.manifest")) {
            $Xml = [xml](Get-Content -Path $i.FullName )
        
            $file_names= $Xml.assembly.file | Where-Object -Property name
            
            foreach ($name in $file_names.name ) { & $expand_exe $([IO.Path]::Combine($cachedir,  $(verb),  $cab)) -f:$name $([IO.Path]::Combine($cachedir,  $(verb) ) ) 
            install_from_manifest $i.FullName  $([IO.Path]::Combine($cachedir,  $(verb), $i.BaseName, $name ) )  "$env:TEMP\$(verb)"}
        }
        
        & $expand_exe $([IO.Path]::Combine($cachedir,  $(verb),  $cab)) -f:"powershell.exe" $([IO.Path]::Combine($cachedir,  $(verb) ) )
Copy-Item -Path  $([IO.Path]::Combine($cachedir,  $(verb), "amd64_microsoft-windows-powershell-exe_31bf3856ad364e35_7.3.7601.16384_none_48be7e79e188387e", "powershell.exe" ) ) -destination  "$env:TEMP\$(verb)\c:\windows\system32\WindowsPowershell\v1.0\ps51.exe" -verbose
Copy-Item -Path  $([IO.Path]::Combine($cachedir,  $(verb), "wow64_microsoft-windows-powershell-exe_31bf3856ad364e35_7.3.7601.16384_none_531328cc15e8fa79", "powershell.exe" ) ) -destination  "$env:TEMP\$(verb)\c:\windows\syswow64\WindowsPowershell\v1.0\ps51.exe" -verbose

        Remove-Item -Force "$cachedir\$(verb)\$cab" -ErrorAction SilentlyContinue
        foreach($i in 'amd64', 'x86', 'wow64', 'msil') { Remove-Item -Force -Recurse "$cachedir\$(verb)\$i*" }
       Remove-Item -Force "$cachedir\$(verb)\*.manifest" -ErrorAction SilentlyContinue


       Push-Location ; Set-Location "$env:TEMP\$(verb)"
       7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on  "$cachedir\$(verb)\$(verb).7z" ".\c:\" ; quit?(7z)
       Pop-Location 
       
       Remove-Item -recurse -force "$env:TEMP\$(verb)"
 }       
        7z x -spf "$cachedir\$(verb)\$(verb).7z" -aoa
         
            
$regkey51 = @"
REGEDIT4

[HKEY_LOCAL_MACHINE\Software\Microsoft\PowerShell]
[HKEY_LOCAL_MACHINE\Software\Microsoft\PowerShell\1]
"Install"=dword:00000001
[HKEY_LOCAL_MACHINE\Software\Microsoft\PowerShell\1\PowerShellEngine]
"ApplicationBase"="C:\\Windows\\System32\\WindowsPowerShell\\v1.0"
[HKEY_LOCAL_MACHINE\Software\Microsoft\PowerShell\3]
"Install"=dword:00000001
[HKEY_LOCAL_MACHINE\Software\Microsoft\PowerShell\3\PowerShellEngine]
"ApplicationBase"="c:\\windows\\system32\\WindowsPowerShell\\v1.0"
"ConsoleHostAssemblyName"="Microsoft.PowerShell.ConsoleHost, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35, ProcessorArchitecture=msil"
"ConsoleHostModuleName"="C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\Microsoft.PowerShell.ConsoleHost.dll"
"PowerShellVersion"="5.1.19041.1"
"PSCompatibleVersion"="1.0, 2.0, 3.0, 4.0, 5.0, 5.1"
"PSPluginWkrModuleName"="C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\system.management.automation.dll"
"RuntimeVersion"="v4.0.30319"
"@
    reg_edit $regkey51

<# add a custom profile file for powershell 5.1 ; escape dollarsign with back-tick here to write it correctly to profile file! #>
$profile51 = @"
<# PowerShell 5.1 profile #>
#FIXME: following causes a hang when running pwsh from ps51 console:
#`$env:PSModulepath = 'c:\windows\system32\WindowsPowershell\v1.0\Modules' + `$env:PSModulepath

`$profile = "`$env:SystemRoot\system32\WindowsPowerShell\v1.0\profile.ps1"
`$env:PSMOdulePath="`$env:SystemRoot\system32\WindowsPowershell\v1.0\Modules;`$env:ProgramFiles(x86)\WindowsPowerShell\Modules;`$env:ProgramFiles\WindowsPowerShell\Modules"

Import-Module "`$env:ProgramFiles\PowerShell\7\Modules\PSReadLine\PSReadLine.psm1"

`$env:PS51 = 1

Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord

function Get-CIMInstance ( [parameter(position=0)] [string]`$classname, [string[]]`$property="*")
{
     Get-WMIObject `$classname -property `$property
}

del alias:gwmi -Force
Set-Alias -Name gcim -Value Get-CIMInstance

<# To support auto-tabcompletion only a comma seperated is supported from now on when calling winetricks with multiple arguments, e.g. 'winetricks gdiplus,riched20' #>

   `$found=0;`$v=@()
   `$lines= [IO.File]::ReadLines("`$env:ProgramData\\Chocolatey-for-wine\\winetricks.ps1")
   foreach(`$line in `$lines) {if(`$line -match 'marker line!!!') {`$found+=1} else{ if((`$found -eq 1) -and !(`$line.StartsWith('#'))) {`$v+= `$line }; if(`$found -eq 2) {break;}}} 
   
   #https://stackoverflow.com/questions/50368246/splitting-a-string-on-spaces-but-ignore-section-between-double-quotes
   `$Qenu=([regex]::Split( `$v, ',(?=(?:[^"]|"[^"]*")*`$)' )).Trim(' ').Trim('"') 
               
#https://stackoverflow.com/questions/67356762/couldnt-use-predefined-array-inside-validateset-powershell`$verblist =0
for ( `$j = 0; `$j -lt `$Qenu.count; `$j+=3) { [string[]]`$verblist += `$Qenu[`$j+1] }

function winetricks {
  [CmdletBinding()]
  param(
    #[Parameter(Mandatory)]
    # Tab-complete based on array `$verblist
    [ArgumentCompleter({
      param(`$cmd, `$param, `$wordToComplete) `$verblist -like "`$wordToComplete*"
    })]
    # Validate based on array `$verblist.
    # NOTE: If validation fails, the (default) error message is unhelpful.
    #       You can work around that in *Windows PowerShell* with `throw`, and in
    #       PowerShell (Core) 7+, you can add an `ErrorMessage` property:
    #         [ValidateScript({ `$_ -in `$verblist }, ErrorMessage = 'Unknown value: {0}')]
    [ValidateScript({
      if (`$_ -in `$verblist) { return `$true }
      throw "'`$_' is not in the set of the supported values: `$(`$verblist -join ', ')"
    })]
    `$Arg
  )

  if (!([System.IO.File]::Exists("`$env:ProgramData\\Chocolatey-for-wine\\winetricks.ps1"))){
      Add-Type -AssemblyName PresentationCore,PresentationFramework;
      [System.Windows.MessageBox]::Show("winetricks script is missing`nplease reinstall it in c:\\ProgramData\\Chocolatey-for-wine",'Congrats','ok','exclamation')
  }
  .   `$([System.IO.Path]::Combine("`$env:ProgramData","Chocolatey-for-wine", "winetricks.ps1")) `$(`$arg -join ',')
}
  
Set-ExecutionPolicy ByPass

if (!(Get-process -Name powershell_ise -erroraction silentlycontinue)) {
    (Get-Host).ui.RawUI.WindowTitle='This is Powershell 5.1!'
 
#    Import-Module PSReadLine

    function prompt  
    {  
        `$ESC = [char]27
         "`$ESC[93mPS 51! `$(`$executionContext.SessionState.Path.CurrentLocation)`$(' `$' * (`$nestedPromptLevel + 1)) `$ESC[0m"  
    }
}


#https://blog.ironmansoftware.com/using-powershell-7-in-the-windows-powershell-ise/

if ((Get-process -Name powershell_ise -erroraction silentlycontinue)) {
#`$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Clear()
`$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("Switch to PowerShell 7", { 
        function New-OutOfProcRunspace {
            param(`$ProcessId)

            `$ci = New-Object -TypeName System.Management.Automation.Runspaces.NamedPipeConnectionInfo -ArgumentList @(`$ProcessId)
            `$tt = [System.Management.Automation.Runspaces.TypeTable]::LoadDefaultTypeFiles()

            `$Runspace = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace(`$ci, `$Host, `$tt)

            `$Runspace.Open()
            `$Runspace
        }



        `$PowerShell = Start-Process PWSH -ArgumentList @("-NoExit") -PassThru -WindowStyle Hidden 
        `$Runspace = New-OutOfProcRunspace -ProcessId `$PowerShell.Id 
        `$Host.PushRunspace(`$Runspace) 
        

        
}, "ALT+F5") | Out-Null 

`$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("Switch to Windows PowerShell", { 
       `$Host.PopRunspace()
       
        `$searcher = [wmisearcher]"Select * From Win32_Process where ParentProcessID=`$PID"
`       `$searcher.scope.path = "\\.\root\cimv2"

         `$child = `$searcher.get()

   # `$Child =  Get-WmiObject -Class win32_process | where {`$_.ParentProcessId -eq `$Pid}
   # $child
    `$Child | ForEach-Object { Stop-Process -Id `$_.ProcessId } 
 }, "ALT+F6") | Out-Null


}

"@
    $profile51 | Out-File $env:SystemRoot\\system32\\WindowsPowerShell\v1.0\\profile.ps1
    $profile51 | Out-File $env:SystemRoot\\syswow64\\WindowsPowerShell\v1.0\\profile.ps1

        


} <# end ps51 #>

function func_ps51_ise <# Powershell 5.1 Integrated Scripting Environment #>
{   
    $url = "/Win7AndW2K8R2-KB3191566-x64.msu" <# download is zip file, so no download url of the msu #>
    $cab = "Windows6.1-KB3191566-x64.cab"

    $sourcefile = @('microsoft.powershell.isecommon.dll', 'microsoft.powershell.gpowershell.dll', 'microsoft.powershell.editor.dll',`
                    'powershell_ise.exe', 'ise.psd1', 'ise.psm1')
   
    func_ps51
   
    if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $(verb), "$(verb).7z") ) ) {

        if ( ![System.IO.File]::Exists( [IO.Path]::Combine($cachedir,  $(verb), "Win7AndW2K8R2-KB3191566-x64.zip" ) ) ) {
            w_download_to $(verb) "https://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/Win7AndW2K8R2-KB3191566-x64.zip" "Win7AndW2K8R2-KB3191566-x64.zip"
            7z e "$cachedir\$(verb)\Win7AndW2K8R2-KB3191566-x64.zip" "-o$cachedir\$(verb)" "Win7AndW2K8R2-KB3191566-x64.msu" -y | Select-String 'ok'; quit?('7z')
            check_msu_sanity $url $cab;
        }

        Remove-Item -Force $([IO.Path]::Combine($cachedir,  $(verb), "Win7AndW2K8R2-KB3191566-x64.zip") ) -ErrorAction SilentlyContinue

        foreach ($i in $sourcefile) { & $expand_exe $([IO.Path]::Combine($cachedir,  $(verb),  $cab)) -f:$i $([IO.Path]::Combine($cachedir,  $(verb) ) ) }

        Remove-Item -Force "$cachedir\$(verb)\$cab" -ErrorAction SilentlyContinue

        foreach ($i in (gci "$cachedir\$(verb)\msil_*\*").FullName ) {
         
            $assembly=[System.Reflection.AssemblyName]::GetAssemblyName($i)
            $publickeytoken = ($assembly.GetPublicKeyToken() |ForEach-Object ToString x2) -join '' 
      
            $destdir = "$env:SystemRoot" + "\" + "Microsoft.NET\assembly\GAC_MSIL\" + $assembly.Name + '\' + 'v4.0_' + $assembly.Version.ToString() + '__' + $publickeytoken
        
            7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on "$cachedir\$(verb)\$(verb).7z" $i; quit?('7z')
            7z rn "$cachedir\$(verb)\$(verb).7z" "$(([System.IO.FileInfo]$i).Name)" "$destdir\$(([System.IO.FileInfo]$i).Name)" ; quit?('7z')
        }

        foreach ($i in 'powershell_ise.exe') {
 
            foreach ($j in (gci "$cachedir\$(verb)\*\$i" ).FullName) {
                if( $(([System.IO.FileInfo]$j).Directory).Name.SubString(0,3) -eq 'amd' ) {$arch = 'system32'} else {$arch = 'syswow64'}

                7z a -spf -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on "$cachedir\$(verb)\$(verb).7z" $j; quit?('7z')
                7z rn "$cachedir\$(verb)\$(verb).7z" "$j" "$env:SystemRoot\$arch\WindowsPowershell\v1.0\$(([System.IO.FileInfo]$j).Name)" ; quit?('7z')
            } 
         }

         foreach ($i in 'ise.psm1', 'ise.psd1') {
 
             foreach ($j in (gci "$cachedir\$(verb)\*\$i" ).FullName) {
                  7z a -spf -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on "$cachedir\$(verb)\$(verb).7z" $j; quit?('7z')

                  if( $(([System.IO.FileInfo]$j).Directory).Name.SubString(0,3) -eq 'amd' ) {$arch = 'system32'} else {$arch = 'syswow64'}
                  7z rn "$cachedir\$(verb)\$(verb).7z" "$j" "$env:SystemRoot\$arch\WindowsPowershell\v1.0\Modules\$(([System.IO.FileInfo]$j).BaseName)\$(([System.IO.FileInfo]$j).Name)" ; quit?('7z')
             }
         }
    }

    foreach($i in 'amd64', 'x86', 'wow64', 'msil') { Remove-Item -Force -Recurse "$cachedir\$(verb)\$($i + '*')" }

    7z x -spf "$cachedir\$(verb)\$(verb).7z" -aoa
    
#$regkey_ise = @"
#REGEDIT4
#[HKEY_CURRENT_USER\Software\Wine\Fonts\Replacements]
#"Lucida Console"="Arial"
#"@
#    reg_edit $regkey_ise

    func_win7_fonts

    powershell_ise.exe     
} <# end ps51_ise #>

function func_msvbvm60 <# msvbvm60 #>
{   
    $url = "http://download.windowsupdate.com/d/msdownload/update/software/updt/2016/05/windows6.1-kb3125574-v4-x64_2dafb1d203c8964239af3048b5dd4b1264cd93b9.msu"
    $cab = "Windows6.1-KB3125574-v4-x64.cab"
    $sourcefile = @('msvbvm60.dll')

    if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $(verb),  "$(verb).7z") ) ) {
        check_msu_sanity $url $cab;
        foreach ($i in $sourcefile) { & $expand_exe $([IO.Path]::Combine($cachedir,  $(verb),  $cab)) -f:$i $([IO.Path]::Combine($cachedir,  $(verb) ) ) }
        7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on "$cachedir\$(verb)\$(verb).7z" "$cachedir\$(verb)\x86*" ; quit?('7z')

        foreach($i in 'amd64', 'x86', 'wow64') { Remove-Item -Force -Recurse "$cachedir\$(verb)\$i*" }
    }

    Remove-Item -Force "$cachedir\$(verb)\$cab" -ErrorAction SilentlyContinue

    7z e "$cachedir\$(verb)\$(verb).7z" "x86*\*" -o"$env:systemroot\\syswow64" -aoa
} <# end msvbvm60 #>

function func_windows.ui.xaml <# experimental... #>
{
    $url = "http://download.windowsupdate.com/c/msdownload/update/software/updt/2016/11/windows10.0-kb3205436-x64_45c915e7a85a7cc7fc211022ecd38255297049c3.msu"
    $cab = "Windows10.0-KB3205436-x64.cab"
    $sourcefile = @('coremessaging.dll', 'windows.ui.xaml.dll', 'bcp47langs.dll', 'windows.storage.dll', 'windows.ui.dll', 'windows.ui.immersive.dll', 'twinapi.appcore.dll')

    if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $(verb),  "$(verb).7z") ) ) {
        check_msu_sanity $url $cab;
        foreach ($i in $sourcefile) { & $expand_exe $([IO.Path]::Combine($cachedir,  $(verb),  $cab)) -f:$i $([IO.Path]::Combine($cachedir,  $(verb) ) ) }
        7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on "$cachedir\$(verb)\$(verb).7z" "$cachedir\$(verb)\amd64*" "$cachedir\$(verb)\wow*" ; quit?('7z')

        foreach($i in 'amd64', 'x86', 'wow64') { Remove-Item -Force -Recurse "$cachedir\$(verb)\$i*" }
    }

    Remove-Item -Force "$cachedir\$(verb)\$cab" -ErrorAction SilentlyContinue

    7z e "$cachedir\$(verb)\$(verb).7z" "amd64*\*" -o"$env:systemroot\\system32" -aoa
    7z e "$cachedir\$(verb)\$(verb).7z" "wow64*\*" -o"$env:systemroot\\syswow64" -aoa
	
$regkey = @"
REGEDIT4
[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion]
"CurrentBuild"="17134"
"CurrentBuildNumber"="17134"
[HKEY_LOCAL_MACHINE\Software\Microsoft\WindowsRuntime\ActivatableClassId\Windows.UI.Xaml.Application]
"DllPath"="c:\\\\windows\\\\system32\\\\Windows.UI.Xaml.dll"
"@
    reg_edit $regkey
	  
} <# end windows.ui.xaml #>

function func_bitstransfer <# bitstransfer cmdlets for ps51 #>
{
    $url = "http://download.windowsupdate.com/c/msdownload/update/software/updt/2016/11/windows10.0-kb3205436-x64_45c915e7a85a7cc7fc211022ecd38255297049c3.msu"
    $cab = "Windows10.0-KB3205436-x64.cab"
    $sourcefile = @('BitsTransfer.psd1', 'BitsTransfer.Format.ps1xml', 'Microsoft.BackgroundIntelligentTransfer.Management.Interop.dll', 'Microsoft.BackgroundIntelligentTransfer.Management.dll')

    if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $(verb),  "$(verb).7z") ) ) {

        Write-Host -foregroundcolor yellow "**********************************************************"
        Write-Host -foregroundcolor yellow "*                                                        *"
        Write-Host -foregroundcolor yellow "*        Downloading file(s) and extracting might        *"
        Write-Host -foregroundcolor yellow "*        take several minutes!                           *"
        Write-Host -foregroundcolor yellow "*        Patience please!                                *"
        Write-Host -foregroundcolor yellow "*                                                        *"
        Write-Host -foregroundcolor yellow "**********************************************************"
        
        $httpClient = New-Object System.Net.Http.HttpClient
        $httpClient.Timeout = 9000000000 <# 15 min. #>
        $response = $httpClient.GetAsync($url)  <# or $response.Wait() ??? #>
        $response.GetAwaiter().GetResult()
        #$sevenZipStream = [System.IO.MemoryStream]::new(($response.Result.Content.ReadAsByteArrayAsync().Result))
        Add-Type -path $env:systemroot\system32\WindowsPowerShell\v1.0\SevenZipExtractor.dll
        $szExtractor = New-Object -TypeName SevenZipExtractor.ArchiveFile -ArgumentList @([System.IO.MemoryStream]::new(($response.Result.Content.ReadAsByteArrayAsync().Result)))

        ($szextractor.Entries[1]).Extract($([IO.Path]::Combine($cachedir,  $(verb),  $cab)))

        <# See below example howto extract to a new stream, from which yet another extraction has to done (e.g. extract msu from zip, then extract msu)   
        $memStream = [System.IO.MemoryStream]::new()
        ($szextractor.Entries[1]).Extract($memstream)
        $newExtractor = New-Object -TypeName SevenZipExtractor.ArchiveFile -ArgumentList @([System.IO.MemoryStream]::new($memStream.ToArray()))
        $newExtractor.Entries[7].Extract()  #>

        foreach ($i in $sourcefile) { & $expand_exe $([IO.Path]::Combine($cachedir,  $(verb),  $cab)) -f:$i $([IO.Path]::Combine($cachedir,  $(verb) ) ) }
        7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on "$cachedir\$(verb)\$(verb).7z" "$cachedir\$(verb)\amd64*" "$cachedir\$(verb)\wow*" "$cachedir\$(verb)\msil*"; quit?('7z')

        foreach($i in 'amd64', 'x86', 'wow64', 'msil') { Remove-Item -Force -Recurse "$cachedir\$(verb)\$i*" }
    }

    Remove-Item -Force "$cachedir\$(verb)\$cab" -Recurse -ErrorAction SilentlyContinue

    7z e "$cachedir\$(verb)\$(verb).7z" "amd64*\*" -o"$env:systemroot\\system32\\WindowsPowerShell\\v1.0\\Modules\\bitstransfer" -aoa
    7z e "$cachedir\$(verb)\$(verb).7z" "wow64*\*" -o"$env:systemroot\\syswow64\\WindowsPowerShell\\v1.0\\Modules\\bitstransfer" -aoa
 
    7z e "$cachedir\$(verb)\$(verb).7z" "msil*\*" -o"$env:TEMP\\msil" -aoa
    
    foreach ($i in (gci "$env:TEMP\\msil").FullName ) {
         
        $assembly=[System.Reflection.AssemblyName]::GetAssemblyName($i)
        $publickeytoken = ($assembly.GetPublicKeyToken() |ForEach-Object ToString x2) -join '' 
      
        $destdir = "$env:SystemRoot" + "\" + "Microsoft.NET\assembly\GAC_MSIL\" + $assembly.Name + '\' + 'v4.0_' + $assembly.Version.ToString() + '__' + $publickeytoken

	    7z e "$cachedir\$(verb)\$(verb).7z" "msil*\$(([System.IO.FileInfo]$i).name)" -o"$destdir" -aoa
	}
	        
	Remove-Item -Force -Recurse "$env:TEMP\\msil" -ErrorAction SilentlyContinue
	
	func_wine_combase
} <# end bitstransfer #>

function func_uianimation <# experimental... #>
{
    $url = "http://download.windowsupdate.com/c/msdownload/update/software/updt/2016/11/windows10.0-kb3205436-x64_45c915e7a85a7cc7fc211022ecd38255297049c3.msu"
    $cab = "Windows10.0-KB3205436-x64.cab"
    $sourcefile = @('uianimation.dll')

    if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $(verb),  "$(verb).7z") ) ) {
        check_msu_sanity $url $cab;
        foreach ($i in $sourcefile) { & $expand_exe $([IO.Path]::Combine($cachedir,  $(verb),  $cab)) -f:$i $([IO.Path]::Combine($cachedir,  $(verb) ) ) }
        7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on "$cachedir\$(verb)\$(verb).7z" "$cachedir\$(verb)\amd64*" "$cachedir\$(verb)\wow*" ; quit?('7z')

        foreach($i in 'amd64', 'x86', 'wow64') { Remove-Item -Force -Recurse "$cachedir\$(verb)\$i*" }
    }

    Remove-Item -Force "$cachedir\$(verb)\$cab" -ErrorAction SilentlyContinue

    7z e "$cachedir\$(verb)\$(verb).7z" "amd64*\*" -o"$env:systemroot\\system32" -aoa
    7z e "$cachedir\$(verb)\$(verb).7z" "wow64*\*" -o"$env:systemroot\\syswow64" -aoa

    foreach($i in 'uianimation') { dlloverride 'native' $i }
} <# end uianimation #>

function func_dcomp <# experimental... #>
{
    $url = "http://download.windowsupdate.com/c/msdownload/update/software/updt/2016/11/windows10.0-kb3205436-x64_45c915e7a85a7cc7fc211022ecd38255297049c3.msu"
    $cab = "Windows10.0-KB3205436-x64.cab"
    $sourcefile = @('dcomp.dll')

    if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $(verb),  "$(verb).7z") ) ) {
        check_msu_sanity $url $cab;
        foreach ($i in $sourcefile) { & $expand_exe $([IO.Path]::Combine($cachedir,  $(verb),  $cab)) -f:$i $([IO.Path]::Combine($cachedir,  $(verb) ) ) }
        7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on "$cachedir\$(verb)\$(verb).7z" "$cachedir\$(verb)\amd64*" "$cachedir\$(verb)\wow*" ; quit?('7z')

        foreach($i in 'amd64', 'x86', 'wow64') { Remove-Item -Force -Recurse "$cachedir\$(verb)\$i*" }
    }

    Remove-Item -Force "$cachedir\$(verb)\$cab" -ErrorAction SilentlyContinue

    7z e "$cachedir\$(verb)\$(verb).7z" "amd64*\*" -o"$env:systemroot\\system32" -aoa
    7z e "$cachedir\$(verb)\$(verb).7z" "wow64*\*" -o"$env:systemroot\\syswow64" -aoa

    foreach($i in 'dcomp') { dlloverride 'native' $i }
} <# end dcomp #>

function func_dshow
{
    $url = "http://download.windowsupdate.com/msdownload/update/software/svpk/2011/02/windows6.1-kb976932-x64_74865ef2562006e51d7f9333b4a8d45b7a749dab.exe"
    $cab = "191.cab"
    $sourcefile = @(`
        'amd64_microsoft-windows-directshow-other_31bf3856ad364e35_6.1.7601.17514_none_6b778d68f75a1a54/amstream.dll',
        'x86_microsoft-windows-directshow-other_31bf3856ad364e35_6.1.7601.17514_none_0f58f1e53efca91e/amstream.dll',
        'wow64_microsoft-windows-directshow-asf_31bf3856ad364e35_6.1.7601.17514_none_83382f97498abe19/qasf.dll',
        'amd64_microsoft-windows-directshow-asf_31bf3856ad364e35_6.1.7601.17514_none_78e385451529fc1e/qasf.dll',
        'x86_microsoft-windows-directshow-capture_31bf3856ad364e35_6.1.7601.17514_none_bae08d1e7dcccf2a/qcap.dll',
        'amd64_microsoft-windows-directshow-capture_31bf3856ad364e35_6.1.7601.17514_none_16ff28a2362a4060/qcap.dll',
        'x86_microsoft-windows-directshow-dvdsupport_31bf3856ad364e35_6.1.7601.17514_none_562994bd321aac67/qdvd.dll',
        'amd64_microsoft-windows-directshow-dvdsupport_31bf3856ad364e35_6.1.7601.17514_none_b2483040ea781d9d/qdvd.dll',
        'wow64_microsoft-windows-qedit_31bf3856ad364e35_6.1.7601.17514_none_c3168c6e9267a403/qedit.dll',
        'amd64_microsoft-windows-qedit_31bf3856ad364e35_6.1.7601.17514_none_b8c1e21c5e06e208/qedit.dll',
        'wow64_microsoft-windows-directshow-core_31bf3856ad364e35_6.1.7601.17514_none_0eeae7a238e677c8/quartz.dll',
        'amd64_microsoft-windows-directshow-core_31bf3856ad364e35_6.1.7601.17514_none_04963d500485b5cd/quartz.dll')

    if (![System.IO.File]::Exists([IO.Path]::Combine("$cachedir", "$(verb)", "$(verb).7z") ) ) {
        w_download_to "$(verb)" "$url" "$($url.split('/')[-1])"
            if ( ![System.IO.File]::Exists( [IO.Path]::Combine("$cachedir" , "$(verb)", "$cab") ) ) {
                7z -t# x "$cachedir\$(verb)\$($url.split('/')[-1])" -o"$cachedir\$(verb)" "$cab" -y  ; quit?('7z')
            }
        foreach ($i in $sourcefile) {7z x "$cachedir\$(verb)\$cab" -o"$cachedir\$(verb)" "$i" ; quit?('7z') }
        foreach ($dir in 'amd64*', 'wow64*', 'x86*') {7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on "$cachedir\$(verb)\$(verb).7z" "$cachedir\$(verb)\$dir" ; quit?('7z')}
        foreach ($i in "$cab", "$($url.split('/')[-1])", "$cachedir\$(verb)\amd64*", "$cachedir/$(verb)/wow64*",  "$cachedir/$(verb)/x86*" ) {Remove-Item -Force -Recurse "$([IO.Path]::Combine($cachedir, $(verb), $i) )"}
    }
    
    7z e "$cachedir\$(verb)\$(verb).7z" "-o$env:systemroot\system32" "amd64*/*" -aoa
    7z e "$cachedir\$(verb)\$(verb).7z" "-o$env:systemroot\syswow64" "wow64*/*" -aoa ; quit?('7z')

    foreach($i in 'amstream', 'qasf', 'qcap', 'qdvd', 'qedit' , 'quartz') { dlloverride 'native' $i }

    foreach($i in  'amstream.dll', 'qasf.dll', 'qcap.dll', 'qdvd.dll', 'qedit.dll' , 'quartz.dll') {
        & "$env:systemroot\\syswow64\\regsvr32" /s "$env:systemroot\\syswow64\\$i"
        & "$env:systemroot\\system32\\regsvr32" /s "$env:systemroot\\system32\\$i" }
} <# end dshow #>

function func_uiribbon
{
    $url = "http://download.windowsupdate.com/msdownload/update/software/svpk/2011/02/windows6.1-kb976932-x64_74865ef2562006e51d7f9333b4a8d45b7a749dab.exe"
    $cab = "191.cab"
    $sourcefile = @(`
        'amd64_microsoft-windows-uiribbon_31bf3856ad364e35_6.1.7601.17514_none_d102e18929d497cb/uiribbonres.dll',
        'wow64_microsoft-windows-uiribbon_31bf3856ad364e35_6.1.7601.17514_none_db578bdb5e3559c6/uiribbon.dll',
        'wow64_microsoft-windows-uiribbon_31bf3856ad364e35_6.1.7601.17514_none_db578bdb5e3559c6/uiribbonres.dll',
        'amd64_microsoft-windows-uiribbon_31bf3856ad364e35_6.1.7601.17514_none_d102e18929d497cb/uiribbon.dll'`
        )

    if (![System.IO.File]::Exists([IO.Path]::Combine("$cachedir", "$(verb)", "$(verb).7z") ) ) {
        w_download_to "$(verb)" "$url" "$($url.split('/')[-1])"
            if ( ![System.IO.File]::Exists( [IO.Path]::Combine("$cachedir" , "$(verb)", "$cab") ) ) {
                7z -t# x "$cachedir\$(verb)\$($url.split('/')[-1])" -o"$cachedir\$(verb)" "$cab" -y  ; quit?('7z')
            }
        foreach ($i in $sourcefile) {7z x "$cachedir\$(verb)\$cab" -o"$cachedir\$(verb)" "$i" ; quit?('7z')}
        7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on "$cachedir\$(verb)\$(verb).7z" "$cachedir\$(verb)\amd64*" "$cachedir/$(verb)/wow64*" ; quit?('7z')
        foreach ($i in "$cab", "$($url.split('/')[-1])", "$cachedir\$(verb)\amd64*", "$cachedir/$(verb)/wow64*" ) {Remove-Item -Force -Recurse "$([IO.Path]::Combine($cachedir, $(verb), $i) )"}
    }
    

    7z e "$cachedir\$(verb)\$(verb).7z" "-o$env:systemroot\system32" "amd64*/*" -aoa
    7z e "$cachedir\$(verb)\$(verb).7z" "-o$env:systemroot\syswow64" "wow64*/*" -aoa ; quit?('7z')

    foreach($i in 'uiribbon') { dlloverride 'native' $i }

    foreach($i in  'uiribbon.dll') {
        & "$env:systemroot\\syswow64\\regsvr32" /s "$env:systemroot\\syswow64\\$i"
        & "$env:systemroot\\system32\\regsvr32" /s "$env:systemroot\\system32\\$i" }
} <# end uiribbon #>

function func_findstr
{
    $url = "http://download.windowsupdate.com/msdownload/update/software/svpk/2011/02/windows6.1-kb976932-x64_74865ef2562006e51d7f9333b4a8d45b7a749dab.exe"
    $cab = "191.cab"
    $sourcefile = @(`
        'x86_microsoft-windows-findstr_31bf3856ad364e35_6.1.7601.17514_none_2936f54db7f6c08f/findstr.exe',
        'amd64_microsoft-windows-findstr_31bf3856ad364e35_6.1.7601.17514_none_855590d1705431c5/findstr.exe')

    if (![System.IO.File]::Exists([IO.Path]::Combine("$cachedir", "$(verb)", "$(verb).7z") ) ) {
        w_download_to "$(verb)" "$url" "$($url.split('/')[-1])"
            if ( ![System.IO.File]::Exists( [IO.Path]::Combine("$cachedir" , "$(verb)", "$cab") ) ) {
                7z -t# x "$cachedir\$(verb)\$($url.split('/')[-1])" -o"$cachedir\$(verb)" "$cab" -y  ; quit?('7z')
            }
        foreach ($i in $sourcefile) {7z x "$cachedir\$(verb)\$cab" -o"$cachedir\$(verb)" "$i" ; quit?('7z') }
        foreach ($dir in 'amd64*', 'wow64*', 'x86*') {7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on "$cachedir\$(verb)\$(verb).7z" "$cachedir\$(verb)\$dir" ; quit?('7z')}
        foreach ($i in "$cab", "$($url.split('/')[-1])", "$cachedir\$(verb)\amd64*", "$cachedir/$(verb)/wow64*",  "$cachedir/$(verb)/x86*" ) {Remove-Item -Force -Recurse "$([IO.Path]::Combine($cachedir, $(verb), $i) )" -ErrorAction SilentlyContinue}
    }
    
    7z e "$cachedir\$(verb)\$(verb).7z" "-o$env:systemroot\system32" "amd64*/*" -aoa
    7z e "$cachedir\$(verb)\$(verb).7z" "-o$env:systemroot\syswow64" "x86*/*" -aoa ; quit?('7z')

    foreach($i in 'findstr.exe') { dlloverride 'native' $i }
} <# end findstr #>

function func_d3dx
{
    $dldir = "d3dx"
     #w_download_to "$dldir" "https://globalcdn.nuget.org/packages/microsoft.dxsdk.d3dx.9.29.952.8.nupkg" "microsoft.dxsdk.d3dx.9.29.952.8.nupkg" 
     w_download_to "$dldir" "https://download.microsoft.com/download/c/c/2/cc291a37-2ebd-4ac2-ba5f-4c9124733bf1/UAPSignedBinary_Microsoft.DirectX.x64.appx" "UAPSignedBinary_Microsoft.DirectX.x64.appx"
     #7z x $cachedir\\$dldir\\microsoft.dxsdk.d3dx.9.29.952.8.nupkg "-o$env:TEMP\\$dldir\\d3dx" -y #this one has 'D3DCompiler_43.dll', 'd3dx10_43.dll', 'd3dx11_43.dll', 'D3DX9_43.dll'
     7z x $cachedir\\$dldir\\UAPSignedBinary_Microsoft.DirectX.x64.appx "-o$env:SystemRoot\\system32" -y

     w_download_to "$dldir" "https://download.microsoft.com/download/c/c/2/cc291a37-2ebd-4ac2-ba5f-4c9124733bf1/UAPSignedBinary_Microsoft.DirectX.x86.appx" "UAPSignedBinary_Microsoft.DirectX.x86.appx" 
     7z x $cachedir\\$dldir\\UAPSignedBinary_Microsoft.DirectX.x86.appx "-o$env:SystemRoot\\syswow64" -y
} <# end d3dx #>
 
 function func_vcrun2019
{
    func_expand
    
<#    if ( ![System.IO.File]::Exists( [IO.Path]::Combine("$cachedir",  "$(verb)",  "64", "VC_redist.x64.exe" ) ) -or 
         ![System.IO.File]::Exists( [IO.Path]::Combine("$cachedir",  "$(verb)",  "32", "VC__redist.x86.exe") ) ) {
        choco install vcredist140 -n -force
        . $env:ProgramData\\chocolatey\\lib\\vcredist140\\tools\\data.ps1 
        w_download_to "$(verb)\\64" $installData64.url64 "VC_redist.x64.exe"
        w_download_to "$(verb)\\32" $installData32.url "VC__redist.x86.exe" 
    }
#>
    if ( ![System.IO.File]::Exists( [IO.Path]::Combine("$cachedir",  "$(verb)",  "64", "VC_redist.x64.exe" ) ) -or 
         ![System.IO.File]::Exists( [IO.Path]::Combine("$cachedir",  "$(verb)",  "32", "VC__redist.x86.exe") ) ) {

        w_download_to "$(verb)\\64" "https://aka.ms/vs/16/release/vc_redist.x64.exe" "VC_redist.x64.exe"
        w_download_to "$(verb)\\32" "https://aka.ms/vs/16/release/vc_redist.x86.exe" "VC__redist.x86.exe" 
    }
         
    7z -t# x $cachedir\\$(verb)\\64\\VC_redist.x64.exe "-o$env:TEMP\\$(verb)\\64" 4.cab -y | Select-String 'ok'; quit?('7z')
    7z e $env:TEMP\\$(verb)\\64\\4.cab "-o$env:TEMP\\$(verb)\\64" a2 a12 a13 -y | Select-String 'ok' ;quit?('7z')

    & $expand_exe "$env:TEMP\$(verb)\64\a2" -f:"Windows8.1-KB2999226-x64.cab" "$env:TEMP\\$(verb)\\64" 
    & $expand_exe  "$env:TEMP\$(verb)\64\Windows8.1-KB2999226-x64.cab" -f:"ucrtbase.dll" "$env:TEMP\\$(verb)\\64"

    Remove-Item   "$env:systemroot\\SysWOW64\\ucrtbase_weg.dll" -Force -Verbose -erroraction SilentlyContinue
    Remove-Item   "$env:systemroot\\System32\\ucrtbase_weg.dll" -Force -Verbose -erroraction SilentlyContinue

    Rename-Item  "$env:systemroot\\SysWOW64\\ucrtbase.dll" "$env:systemroot\\SysWOW64\\ucrtbase_weg.dll" -Force -Verbose
    Rename-Item  "$env:systemroot\\System32\\ucrtbase.dll" "$env:systemroot\\System32\\ucrtbase_weg.dll" -Force -Verbose

    Copy-Item -Path "$env:TEMP\$(verb)\64\amd*\ucrtbase.dll" -Destination "$env:SystemRoot\\system32" -Force -Verbose
    Copy-Item -Path "$env:TEMP\$(verb)\64\x86*\ucrtbase.dll" -Destination "$env:windir\\SysWOW64" -Force -Verbose

    7z x $env:TEMP\\$(verb)\\64\\a12  "-o$env:TEMP\\$(verb)\\64"
    7z x $env:TEMP\\$(verb)\\64\\a13    mfc140.dll mfc140u.dll mfcm140.dll mfcm140u.dll "-o$env:TEMP\\$(verb)\\64"
    foreach ($i in (get-item "$env:TEMP\\vcrun2019\\64\\*.dll").name) {Move-Item $env:TEMP\\$(verb)\\64\\$i $env:systemroot\\system32\\$i -force -verbose}  

    7z -t# x $cachedir\\$(verb)\\32\\VC__redist.x86.exe "-o$env:TEMP\\$(verb)\\32" 4.cab -y | Select-String 'ok'; quit?('7z')
    7z e $env:TEMP\\$(verb)\\32\\4.cab "-o$env:TEMP\\$(verb)\\32" a10 a11 -y | Select-String 'ok' ;quit?('7z')

    7z x $env:TEMP\\$(verb)\\32\\a10   "-o$env:TEMP\\$(verb)\\32"
    7z x $env:TEMP\\$(verb)\\32\\a11  mfc140.dll mfc140u.dll  mfcm140.dll mfcm140u.dll  "-o$env:TEMP\\$(verb)\\32"
    foreach ($i in (get-item "$env:TEMP\\vcrun2019\\32\\*.dll").name) {Move-Item $env:TEMP\\$(verb)\\32\\$i $env:systemroot\\syswow64\\$i -force -verbose}  

    Remove-Item -Force -Recurse "$env:TEMP\$(verb)"
        
    foreach($i in 'concrt140', 'msvcp140', 'msvcp140_1', 'msvcp140_2', 'vcruntime140', 'vcruntime140_1', 'ucrtbase') { dlloverride 'native' $i }
} <# end vcrun2019 #>

function func_vcrun2022
{
    func_expand
    
    if ( ![System.IO.File]::Exists( [IO.Path]::Combine("$cachedir",  "$(verb)",  "64", "VC_redist.x64.exe" ) ) -or 
         ![System.IO.File]::Exists( [IO.Path]::Combine("$cachedir",  "$(verb)",  "32", "VC__redist.x86.exe") ) ) {

        w_download_to "$(verb)\\64" "https://aka.ms/vs/17/release/vc_redist.x64.exe" "VC_redist.x64.exe"
        w_download_to "$(verb)\\32" "https://aka.ms/vs/17/release/vc_redist.x86.exe" "VC__redist.x86.exe" 
    }
     
    7z -t# x $cachedir\\$(verb)\\64\\VC_redist.x64.exe "-o$env:TEMP\\$(verb)\\64" 4.cab -y | Select-String 'ok'; quit?('7z')
    7z e $env:TEMP\\$(verb)\\64\\4.cab "-o$env:TEMP\\$(verb)\\64" a2 a12 a13 -y | Select-String 'ok' ;quit?('7z')

    & $expand_exe "$env:TEMP\$(verb)\64\a2" -f:"Windows8.1-KB2999226-x64.cab" "$env:TEMP\\$(verb)\\64" 
    & $expand_exe  "$env:TEMP\$(verb)\64\Windows8.1-KB2999226-x64.cab" -f:"ucrtbase.dll" "$env:TEMP\\$(verb)\\64"

    Remove-Item   "$env:systemroot\\SysWOW64\\ucrtbase_weg.dll" -Force -Verbose -erroraction SilentlyContinue
    Remove-Item   "$env:systemroot\\System32\\ucrtbase_weg.dll" -Force -Verbose -erroraction SilentlyContinue

    Rename-Item  "$env:systemroot\\SysWOW64\\ucrtbase.dll" "$env:systemroot\\SysWOW64\\ucrtbase_weg.dll" -Force -Verbose
    Rename-Item  "$env:systemroot\\System32\\ucrtbase.dll" "$env:systemroot\\System32\\ucrtbase_weg.dll" -Force -Verbose

    Copy-Item -Path "$env:TEMP\$(verb)\64\amd*\ucrtbase.dll" -Destination "$env:SystemRoot\\system32" -Force -Verbose
    Copy-Item -Path "$env:TEMP\$(verb)\64\x86*\ucrtbase.dll" -Destination "$env:windir\\SysWOW64" -Force -Verbose
 
    7z x $env:TEMP\\$(verb)\\64\\a12  "-o$env:TEMP\\$(verb)\\64"
    7z x $env:TEMP\\$(verb)\\64\\a13    mfc140.dll_amd64 mfc140u.dll_amd64 mfcm140.dll_amd64 mfcm140u.dll_amd64 "-o$env:TEMP\\$(verb)\\64"
    foreach ($i in (get-item "$env:TEMP\\$(verb)\\64\\*.dll_amd64").name) {Move-Item $env:TEMP\\$(verb)\\64\\$i $env:systemroot\\system32\\$($i -replace '_amd64','' ) -force -verbose}  

    7z -t# x $cachedir\\$(verb)\\32\\VC__redist.x86.exe "-o$env:TEMP\\$(verb)\\32" 4.cab -y | Select-String 'ok'; quit?('7z')
    7z e $env:TEMP\\$(verb)\\32\\4.cab "-o$env:TEMP\\$(verb)\\32" a10 a11 -y | Select-String 'ok' ;quit?('7z')

    7z x $env:TEMP\\$(verb)\\32\\a10   "-o$env:TEMP\\$(verb)\\32"
    7z x $env:TEMP\\$(verb)\\32\\a11  mfc140.dll_x86 mfc140u.dll_x86  mfcm140.dll_x86 mfcm140u.dll_x86  "-o$env:TEMP\\$(verb)\\32"
    foreach ($i in (get-item "$env:TEMP\\$(verb)\\32\\*.dll_x86").name) {Move-Item $env:TEMP\\$(verb)\\32\\$i $env:systemroot\\syswow64\\$($i -replace '_x86','') -force -verbose}  
    
    Remove-Item -Force -Recurse "$env:TEMP\$(verb)"
        
    foreach($i in 'concrt140', 'msvcp140', 'msvcp140_1', 'msvcp140_2', 'vcruntime140', 'vcruntime140_1', 'ucrtbase') { dlloverride 'native' $i }
} <# end vcrun2022 #>

function func_cmd <# native cmd #>
{
    if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $(verb),  "$(verb).7z" ) ) ){
    
        w_download_to "$(verb)" "https://catalog.s.download.windowsupdate.com/msdownload/update/v3-19990518/cabpool/windowsserver2003.windowsxp-kb914961-sp2-x64-enu_7f8e909c52d23ac8b5dbfd73f1f12d3ee0fe794c.exe" "windowsserver2003.windowsxp-kb914961-sp2-x64-enu_7f8e909c52d23ac8b5dbfd73f1f12d3ee0fe794c.exe"

        7z x "$cachedir\$(verb)\windowsserver2003.windowsxp-kb914961-sp2-x64-enu_7f8e909c52d23ac8b5dbfd73f1f12d3ee0fe794c.exe" "-o$env:Temp\$(verb)" "amd64/cmd.ex_" -aoa; quit?('7z')
        7z e "$env:Temp\$(verb)\amd64\cmd.ex_" "-o$env:Temp\$(verb)\$(verb)\64" "cmd.exe"-aoa | Select-String 'ok' ; quit?('7z');
        Remove-Item -Force "$cachedir\$(verb)\windowsserver2003.windowsxp-kb914961-sp2-x64-enu_7f8e909c52d23ac8b5dbfd73f1f12d3ee0fe794c.exe"

        w_download_to "$(verb)" "https://catalog.s.download.windowsupdate.com/msdownload/update/software/dflt/2008/02/windowsserver2003-kb914961-sp2-x86-enu_51e1759a1fda6cd588660324abaed59dd3bbe86b.exe" "windowsserver2003-kb914961-sp2-x86-enu_51e1759a1fda6cd588660324abaed59dd3bbe86b.exe"

        7z x "$cachedir\$(verb)\windowsserver2003-kb914961-sp2-x86-enu_51e1759a1fda6cd588660324abaed59dd3bbe86b.exe" "-o$env:Temp\$(verb)" "i386/cmd.ex_" -aoa; quit?('7z')
        7z e "$env:Temp\$(verb)\i386\cmd.ex_" "-o$env:Temp\$(verb)\$(verb)\32" "cmd.exe" -aoa | Select-String 'ok' ; quit?('7z'); 
        Remove-Item -Force "$cachedir\$(verb)\windowsserver2003-kb914961-sp2-x86-enu_51e1759a1fda6cd588660324abaed59dd3bbe86b.exe"
    
        7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on "$cachedir\$(verb)\$(verb).7z" "$env:Temp\$(verb)\$(verb)\64" "$env:Temp\$(verb)\$(verb)\32" ;quit?(7z)
        Remove-Item -Force "$env:Temp\$(verb)" -recurse
    }
    7z e "$cachedir\$(verb)\$(verb).7z" "-o$env:systemroot\system32" "64\cmd.exe" -y 
    7z e "$cachedir\$(verb)\$(verb).7z" "-o$env:systemroot\syswow64" "32\cmd.exe"  -y
    
    foreach($i in 'cmd.exe') { dlloverride 'native' $i }
} <# end cmd #>

function func_wmiutils <# native wmiutils #>
{
    if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $(verb),  "$(verb).7z" ) ) ){
    
        w_download_to "$(verb)" "https://catalog.s.download.windowsupdate.com/msdownload/update/v3-19990518/cabpool/windowsserver2003.windowsxp-kb914961-sp2-x64-enu_7f8e909c52d23ac8b5dbfd73f1f12d3ee0fe794c.exe" "windowsserver2003.windowsxp-kb914961-sp2-x64-enu_7f8e909c52d23ac8b5dbfd73f1f12d3ee0fe794c.exe"

        7z x "$cachedir\$(verb)\windowsserver2003.windowsxp-kb914961-sp2-x64-enu_7f8e909c52d23ac8b5dbfd73f1f12d3ee0fe794c.exe" "-o$env:Temp\$(verb)" "amd64/wmiutils.dl_" -aoa; quit?('7z')
        7z e "$env:Temp\$(verb)\amd64\wmiutils.dl_" "-o$env:Temp\$(verb)\$(verb)\64" "wmiutils.dll"-aoa | Select-String 'ok' ; quit?('7z');

        7z x "$cachedir\$(verb)\windowsserver2003.windowsxp-kb914961-sp2-x64-enu_7f8e909c52d23ac8b5dbfd73f1f12d3ee0fe794c.exe" "-o$env:Temp\$(verb)" "amd64/wow/wwmiutils.dl_" -aoa; quit?('7z')
        7z e "$env:Temp\$(verb)\amd64\wow\wwmiutils.dl_" "-o$env:Temp\$(verb)\$(verb)\32" "wwmiutils.dll" -aoa | Select-String 'ok' ; quit?('7z');
        Move-Item "$env:Temp\$(verb)\$(verb)\32\wwmiutils.dll" "$env:Temp\$(verb)\$(verb)\32\wmiutils.dll"

        Remove-Item -Force "$cachedir\$(verb)\windowsserver2003.windowsxp-kb914961-sp2-x64-enu_7f8e909c52d23ac8b5dbfd73f1f12d3ee0fe794c.exe"
 
        7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on "$cachedir\$(verb)\$(verb).7z" "$env:Temp\$(verb)\$(verb)\64" "$env:Temp\$(verb)\$(verb)\32" ;quit?(7z)
        Remove-Item -Force "$env:Temp\$(verb)" -recurse
    }
    7z e "$cachedir\$(verb)\$(verb).7z" "-o$env:systemroot\system32\wbem" "64\wmiutils.dll" -y 
    7z e "$cachedir\$(verb)\$(verb).7z" "-o$env:systemroot\syswow64\wbem" "32\wmiutils.dll"  -y
    
    foreach($i in 'wmiutils') { dlloverride 'native' $i }
} <# end wmiutils #>

function func_wbemdisp <# native wbemdisp #>
{
    if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $(verb),  "$(verb).7z" ) ) ){
    
        w_download_to "$(verb)" "https://catalog.s.download.windowsupdate.com/msdownload/update/v3-19990518/cabpool/windowsserver2003.windowsxp-kb914961-sp2-x64-enu_7f8e909c52d23ac8b5dbfd73f1f12d3ee0fe794c.exe" "windowsserver2003.windowsxp-kb914961-sp2-x64-enu_7f8e909c52d23ac8b5dbfd73f1f12d3ee0fe794c.exe"

        7z x "$cachedir\$(verb)\windowsserver2003.windowsxp-kb914961-sp2-x64-enu_7f8e909c52d23ac8b5dbfd73f1f12d3ee0fe794c.exe" "-o$env:Temp\$(verb)" "amd64/wbemdisp.dl_" -aoa; quit?('7z')
        7z e "$env:Temp\$(verb)\amd64\wbemdisp.dl_" "-o$env:Temp\$(verb)\$(verb)\64" "wbemdisp.dll"-aoa | Select-String 'ok' ; quit?('7z');

        7z x "$cachedir\$(verb)\windowsserver2003.windowsxp-kb914961-sp2-x64-enu_7f8e909c52d23ac8b5dbfd73f1f12d3ee0fe794c.exe" "-o$env:Temp\$(verb)" "amd64/wow/wwbemdisp.dl_" -aoa; quit?('7z')
        7z e "$env:Temp\$(verb)\amd64\wow\wwbemdisp.dl_" "-o$env:Temp\$(verb)\$(verb)\32" "wwbemdisp.dll" -aoa | Select-String 'ok' ; quit?('7z');
        Move-Item "$env:Temp\$(verb)\$(verb)\32\wwbemdisp.dll" "$env:Temp\$(verb)\$(verb)\32\wbemdisp.dll"

        Remove-Item -Force "$cachedir\$(verb)\windowsserver2003.windowsxp-kb914961-sp2-x64-enu_7f8e909c52d23ac8b5dbfd73f1f12d3ee0fe794c.exe"
 
        7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on "$cachedir\$(verb)\$(verb).7z" "$env:Temp\$(verb)\$(verb)\64" "$env:Temp\$(verb)\$(verb)\32" ;quit?(7z)
        Remove-Item -Force "$env:Temp\$(verb)" -recurse
    }
    7z e "$cachedir\$(verb)\$(verb).7z" "-o$env:systemroot\system32\wbem" "64\wbemdisp.dll" -y 
    7z e "$cachedir\$(verb)\$(verb).7z" "-o$env:systemroot\syswow64\wbem" "32\wbemdisp.dll"  -y
    
    foreach($i in 'wbemdisp') { dlloverride 'native' $i }
    
    foreach($i in 'wbemdisp.dll') {
        & "$env:systemroot\\syswow64\\regsvr32" /s "$env:systemroot\\syswow64\\wbem\\$i"
        & "$env:systemroot\\system32\\regsvr32" /s "$env:systemroot\\system32\\wbem\\$i" }
} <# end wbemdisp #>

function func_wine_wbemprox
{
    w_download_to "$(verb)" "https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/EXTRAS/$(verb).7z" "$(verb).7z"

    foreach ($i in $(verb).substring(5) ){
        7z e "$cachedir\\$(verb)\\$(verb).7z" "-o$env:systemroot\system32\wbem" "64/$i.dll" -aoa | Select-String 'ok' 
        7z e "$cachedir\\\\$(verb)\\$(verb).7z" "-o$env:systemroot\syswow64\wbem" "32/$i.dll" -aoa | Select-String 'ok'  }

@'
[win32_bios]        ;replace value, might not always work. If not, just replace whole class like in last example
Manufacturer=Mercedes Benz

[win32_videocontroller]
Caption=3Dfx Voodoo 3 3000 AGP VGA Card

[Win32_NetworkAdapter]
Speed=5

[Win32_Operatingsystem]
Caption=MSDOS 1.0

[Win32_spoofclassA]     ;  add new class, number of keys and types is hardcoded, make sure to add right type and don not change number of keys  
ClassName=Win32_example
string1=somestring1
string2=somestring2
string3=somestring3
string4=somestring4
string5=somestring5
uint8=26
uint16_1=27
uint16_2=28
uint16_3=29
uint32_1=30
uint32_2=31
uint32_3=32
uint64_1=33
uint64_2=34
bool1=1
bool2=1
sint32=0x21
real32=3.3f
datetime=20140101000000.000000+000

[Win32_spoofclassB]     ;  add new class, number of keys and types is hardcoded, make sure to add right type and don not change number of keys
ClassName=Win32_example1
string1=somestring1
string2=somestring2
string3=somestring3
string4=somestring4
string5=somestring5
uint8=26
uint16_1=27
uint16_2=28
uint16_3=29
uint32_1=30
uint32_2=31
uint32_3=32
uint64_1=33
uint64_2=34
bool1=1
bool2=1
sint32=0x21
real32=3.3f
datetime=20140101000000.000000+000

[Win32_spoofclassC]   ;  add new class, number of keys and types is hardcoded, make sure to add right type and don not change number of keys
ClassName=Win32_example2
string1=somestring1
string2=somestring2
string3=somestring3
string4=somestring4
string5=somestring5
uint8=26
uint16_1=27
uint16_2=28
uint16_3=29
uint32_1=30
uint32_2=31
uint32_3=32
uint64_1=33
uint64_2=34
bool1=1
bool2=1
sint32=0x21
real32=3.3f
datetime=20140101000000.000000+000

[Win32_spoofclassD]         ;  add new class, number of keys and types is hardcoded, make sure to add right type and don not change number of keys          
ClassName=Win32_example3
string1=somestring1
string2=somestring2
string3=somestring3
string4=somestring4
string5=somestring5
uint8=26
uint16_1=27
uint16_2=28
uint16_3=29
uint32_1=30
uint32_2=31
uint32_3=32
uint64_1=33
uint64_2=34
bool1=1
bool2=1
sint32=0x21
real32=3.3f
datetime=20140101000000.000000+000

[Win32_QuickFixEngineering]	 ; replace existing class, make sure to add right type and don not change number of keys 
ClassName=fake_entry1
[Win32_spoofclassE]                
ClassName=fake_entry1
Caption=Updates
Description=Installed Updates
Status=OK
HotFixID=KB5555 KB77777
InstalledBy=Me
uint8=
uint16_1=
uint16_2=
uint16_3=
uint32_1=
uint32_2=
uint32_3=
uint64_1=
uint64_2=
bool1=
bool2=
sint32=
real32=
InstallDate=
'@ |Out-File "$env:ProgramData\Chocolatey-for-wine\wmispoofer.ini"

foreach($i in 'wbemprox') { dlloverride 'native' $i }

pwsh -nologo
}

function func_crypt32 <# native crypt32 #>
{
    if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $(verb),  "$(verb).7z" ) ) ){
    
       try{ w_download_to "$(verb)" "https://catalog.s.download.windowsupdate.com/msdownload/update/v3-19990518/cabpool/windowsserver2003.windowsxp-kb914961-sp2-x64-enu_7f8e909c52d23ac8b5dbfd73f1f12d3ee0fe794c.exe" "windowsserver2003.windowsxp-kb914961-sp2-x64-enu_7f8e909c52d23ac8b5dbfd73f1f12d3ee0fe794c.exe"}
       catch{"$($Error[0].Exception.InnerException.message): $computername"} ;$PSItem.Exception.InnerExceptionMessage
        7z x "$cachedir\$(verb)\windowsserver2003.windowsxp-kb914961-sp2-x64-enu_7f8e909c52d23ac8b5dbfd73f1f12d3ee0fe794c.exe" "-o$env:Temp\$(verb)" "amd64/crypt32.dl_" "amd64/msasn1.dl_" -aoa; quit?('7z')
        7z e "$env:Temp\$(verb)\amd64\*.dl_" "-o$env:Temp\$(verb)\$(verb)\64" -aoa | Select-String 'ok' ; quit?('7z');

        7z x "$cachedir\$(verb)\windowsserver2003.windowsxp-kb914961-sp2-x64-enu_7f8e909c52d23ac8b5dbfd73f1f12d3ee0fe794c.exe" "-o$env:Temp\$(verb)" "amd64/wow/wcrypt32.dl_" "amd64/wow/wmsasn1.dl_" -aoa; quit?('7z')
        7z e "$env:Temp\$(verb)\amd64\wow\*.dl_" "-o$env:Temp\$(verb)\$(verb)\32"  -aoa | Select-String 'ok' ; quit?('7z');
        Move-Item "$env:Temp\$(verb)\$(verb)\32\wcrypt32.dll" "$env:Temp\$(verb)\$(verb)\32\crypt32.dll"
        Move-Item "$env:Temp\$(verb)\$(verb)\32\wmsasn1.dll" "$env:Temp\$(verb)\$(verb)\32\msasn1.dll"
        
        Remove-Item -Force "$cachedir\$(verb)\windowsserver2003.windowsxp-kb914961-sp2-x64-enu_7f8e909c52d23ac8b5dbfd73f1f12d3ee0fe794c.exe"
 
        7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on "$cachedir\$(verb)\$(verb).7z" "$env:Temp\$(verb)\$(verb)\64" "$env:Temp\$(verb)\$(verb)\32" ;quit?(7z)
       # Remove-Item -Force "$env:Temp\$(verb)" -recurse
    }

    #https://4sysops.com/archives/how-to-create-an-open-file-folder-dialog-box-with-powershell/
    try{ $null=[System.Reflection.Assembly]::GetAssembly([System.Windows.Forms]) }
    catch { [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null }
    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
    InitialDirectory =  [System.IO.Directory]::GetCurrentDirectory() 
    Filter = 'exe files (*.exe)|*.exe'
    Title = "Select the exe for which you want to add the 'native' $($(verb))  override" }
    if ( $FileBrowser.ShowDialog() -eq 'Cancel' ) {exit}

    $file = ([System.IO.FileInfo]($FileBrowser.FileName)).name
    $filepath = ([System.IO.FileInfo]($FileBrowser.FileName)).Fullname
    $destdir =([System.IO.FileInfo]($FileBrowser.FileName)).Directory

    if ( $(7z l $filepath | findstr 'CPU' |select-string x64) )       {$arch = '64' }
    elseif ( $(7z l $filepath | findstr 'CPU' |select-string x86) )   {$arch = '32' }
    else {Write-Host 'Something went wrong...'; exit}
    
    7z e "$cachedir\\$(verb)\\$(verb).7z" "-o$destdir" "$arch/*" -aoa 
        
    if(!(Test-Path "HKCU:\\Software\\Wine\\AppDefaults\\$file")) {New-Item  -Path "HKCU:\\Software\\Wine\\AppDefaults\\$file"}
    if(!(Test-Path "HKCU:\\Software\\Wine\\AppDefaults\\$file\\DllOverrides")) {New-Item  -Path "HKCU:\\Software\\Wine\\AppDefaults\\$file\\DllOverrides"}
    New-ItemProperty -Path "HKCU:\\Software\\Wine\\AppDefaults\\$file\\DllOverrides" -Name "$(verb)" -Value 'native,builtin' -PropertyType 'String' -force
} <# end crypt32 #>

function func_directmusic <# native dmusic #>
{
    if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $(verb),  "$(verb).7z" ) ) ){
    
        w_download_to "$(verb)" "https://catalog.s.download.windowsupdate.com/msdownload/update/software/dflt/2008/04/windowsxp-kb936929-sp3-x86-enu_c81472f7eeea2eca421e116cd4c03e2300ebfde4.exe" "windowsxp-kb936929-sp3-x86-enu_c81472f7eeea2eca421e116cd4c03e2300ebfde4.exe"

    foreach ($i in 'dmusic.dll', 'dmband.dll', 'dmime.dll', 'dmloader.dll', 'dmscript.dll', 'dmstyle.dll', 'dmsynth.dll', 'dsound.dll', 'dswave.dll' <#, 'dcompos.dll', 'dmusic32.dll' #>) {
            7z x "$cachedir\$(verb)\windowsxp-kb936929-sp3-x86-enu_c81472f7eeea2eca421e116cd4c03e2300ebfde4.exe" "-o$env:Temp\$(verb)" "i386/$($i.replace('dll','dl_'))" -aoa; quit?('7z')
            7z e "$env:Temp\$(verb)\i386\$($i.replace('dll','dl_'))" "-o$env:Temp\$(verb)\$(verb)\32" "$i" -aoa | Select-String 'ok' ; quit?('7z');
            
        }
        Remove-Item -Force "$cachedir\$(verb)\windowsxp-kb936929-sp3-x86-enu_c81472f7eeea2eca421e116cd4c03e2300ebfde4.exe"
    
        7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on "$cachedir\$(verb)\$(verb).7z" "$env:Temp\$(verb)\$(verb)\32" ;quit?(7z)
        Remove-Item -Force "$env:Temp\$(verb)" -recurse
    }
    7z e "$cachedir\$(verb)\$(verb).7z" "-o$env:systemroot\syswow64" "32\*"  -y
    
    foreach ($i in 'dmusic.dll', 'dmband.dll', 'dmime.dll', 'dmloader.dll', 'dmscript.dll', 'dmstyle.dll', 'dmsynth.dll', 'dsound.dll', 'dswave.dll' <#, 'dcompos.dll', 'dmusic32.dll' #>) {
        dlloverride 'native' $i.Split('.')[0]
        & "$env:systemroot\\syswow64\\regsvr32" /s "$env:systemroot\\syswow64\\$i" /s
    }
} <# end directmusic #>

function func_wine_wintrust <# wine wintrust with some hack faking success #>
{
    w_download_to "$(verb)" "https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/EXTRAS/$(verb).7z" "$(verb).7z"

    foreach ($i in $(verb).substring(5) ){
        7z e "$cachedir\\$(verb)\\$(verb).7z" "-o$env:systemroot\system32" "64/$i.dll" -aoa | Select-String 'ok' 
        7z e "$cachedir\\\\$(verb)\\$(verb).7z" "-o$env:systemroot\syswow64" "32/$i.dll" -aoa | Select-String 'ok'  }
    foreach($i in $(verb).substring(5) ) { dlloverride 'native' $i }
} <# end wintrust #>

function func_wine_advapi32 { system_install wine_advapi32 '27b8ffd4abec1aa26936d769f0c6bcc74f5bfb2c6526acdd37223f2f199ccdfd' $true}

function func_wine_shell32  { system_install wine_shell32  '21ed91f32180b4927239a5e02d557b9aa00731b8bf1af185a21a53c87f2a235c' $true}

function func_wine_combase  { system_install wine_combase  'ab66f282f7feab67be6ddb8b3700a04126ba8f6808d193f4b5f0581b697781e8' $true}

function func_wine_d2d1     { system_install wine_d2d1     'd93559790176ca68b8c5a35f99f9bd1d64231991b167110d64033ebae1ee65b0' $false}

function func_wine_msxml3   { system_install wine_msxml3   '4a96a865a47d090eab3c1485fa923ca639b5d38fcff03c1b7b62785aa5921151' $false}

function func_wine_cfgmgr32 { system_install wine_cfgmgr32 'f1975926672e216206a16fca848a647ea86d1367867426accffa4ef4039c61bc' $false}

function func_wine_sxs      { system_install wine_sxs      '9ac670ae3105611a5211649aab25973b327dcd8ea932f1a8569e78adca6fedcb' $false}

function func_wine_wintypes { system_install wine_wintypes '7c99767ebecaba810b474eafe8b39056d354676950ed23e633e38e0bda57e4c4' $false}

function func_wine_msi      { system_install wine_msi      'fc2e00c3265c2cc98b81fc0aa582bb9e4c1543a21c97ed6dd8e7e323a5e6ed27' $false}

function func_wine_kernel32 { system_install wine_kernel32 'adc588a5fb250009858fceadf78cd715725d4b322ab0373d624330b4247a1b7c' $true}

function func_wine_sppc     { system_install wine_sppc     'fc2e00c3265c2cc98b81fc0aa582bb9e4c1543a21c97ed6dd8e7e323a5e6ed27' $false}

function func_wine_hnetcfg  { system_install wine_hnetcfg  'fc2e00c3265c2cc98b81fc0aa582bb9e4c1543a21c97ed6dd8e7e323a5e6ed27' $false}

function func_wine_api-ms-win-appmodel-state-l1-2-0 <# wine api-ms-win-appmodel-state-l1-2-0 #>
{
    w_download_to "wine_kernelbase" "https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/EXTRAS/wine_kernelbase.7z" "wine_kernelbase.7z"

    7z e "$cachedir\\wine_kernelbase\\wine_kernelbase.7z" "-o$env:systemroot\system32\WindowsPowerShell" "64/kernelbase.dll" -aoa | Select-String 'ok' 
    7z e "$cachedir\\\\wine_kernelbase\\wine_kernelbase.7z" "-o$env:systemroot\syswow64\WindowsPowerShell" "32/kernelbase.dll" -aoa | Select-String 'ok'
    Move-Item "$env:systemroot\syswow64\WindowsPowerShell\kernelbase.dll" "$env:systemroot\syswow64\api-ms-win-appmodel-state-l1-2-0.dll" -force -erroraction SilentlyContinue
    Move-Item "$env:systemroot\system32\WindowsPowerShell\kernelbase.dll" "$env:systemroot\system32\api-ms-win-appmodel-state-l1-2-0.dll" -force -erroraction SilentlyContinue
} <# end api-ms-win-appmodel-state-l1-2-0 #>

#function func_wine_wintypes2 { install_winedll wine_wintypes2 'ead327788f98b617017a483e9a0500cf2bd627e9c5d23ae7e175cb8035dc0a9e'}

function func_wine_kernelbase <# wine kernelbase with rudimentary MUI support + bunch of other hacks #>
{
    if( [System.IO.File]::Exists( $([IO.Path]::Combine($cachedir,  $(verb), "$(verb).7z") )) -and ( (Get-FileHash  "$cachedir\$(verb)\$(verb).7z").Hash -ne '6056679D21DE6D8CAF2080E15673D388F4D8686054EA5BD9B0EC93F1019ABEF1') )  {
        Remove-Item -Force  "$cachedir\$(verb)\$(verb).7z" 
    }

    w_download_to "$(verb)" "https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/EXTRAS/$(verb).7z" "$(verb).7z"

    #https://4sysops.com/archives/how-to-create-an-open-file-folder-dialog-box-with-powershell/
    try{ $null=[System.Reflection.Assembly]::GetAssembly([System.Windows.Forms]) }
    catch { [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null }
    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
    InitialDirectory =  [System.IO.Directory]::GetCurrentDirectory() 
    Filter = 'exe files (*.exe)|*.exe'
    Title = "Select the exe for which you want to add the 'native' $($(verb).substring(5))  override" }
    if ( $FileBrowser.ShowDialog() -eq 'Cancel' ) {exit}

    $file = ([System.IO.FileInfo]($FileBrowser.FileName)).name
    $filepath = ([System.IO.FileInfo]($FileBrowser.FileName)).Fullname
    $destdir =([System.IO.FileInfo]($FileBrowser.FileName)).Directory

    if ( $(7z l $filepath | findstr 'CPU' |select-string x64) )       {$arch = '64' }
    elseif ( $(7z l $filepath | findstr 'CPU' |select-string x86) )   {$arch = '32' }
    else {Write-Host 'Something went wrong...'; exit}
    
    foreach ($i in $(verb).substring(5) ){
        7z e "$cachedir\\$(verb)\\$(verb).7z" "-o$destdir" "$arch/$($(verb).substring(5)).dll" -aoa  }
        
    if(!(Test-Path "HKCU:\\Software\\Wine\\AppDefaults\\$file")) {New-Item  -Path "HKCU:\\Software\\Wine\\AppDefaults\\$file"}
    if(!(Test-Path "HKCU:\\Software\\Wine\\AppDefaults\\$file\\DllOverrides")) {New-Item  -Path "HKCU:\\Software\\Wine\\AppDefaults\\$file\\DllOverrides"}
    New-ItemProperty -Path "HKCU:\\Software\\Wine\\AppDefaults\\$file\\DllOverrides" -Name "$($(verb).substring(5))" -Value 'native,builtin' -PropertyType 'String' -force

    #replace commandlines; Note: Conemu apparently doesn't like this :
@'
;Append something to a commandline like 'msedge' --> 'msedge -no-sandbox'
;[msedge.exe]
;append="-no-sandbox"

;Replace a commandline like 'where.exe comctl32.dll' --> 'where.exe ntdll.dll'
;[where.exe]
;replace_from=comctl32.dll
;replace_to=ntdll.dll
'@ | Out-File $env:ProgramData\Chocolatey-for-wine\kernel32.ini -Force


} <# end kernelbase #>

function func_win7_fonts
{
    $fonts = @('segoeui.ttf', 'segoeuib.ttf', 'segoeuii.ttf', 'segoeuil.ttf', 'segoeuiz.ttf', 'tahomabd.ttf', 'tahoma.ttf', 'lucon.ttf', 'micross.ttf'); check_aik_sanity;
    
    foreach ($i in $fonts) { 7z e "$cachedir\aik70\F3_WINPE.WIM" "-o$env:systemroot\Fonts" "Windows/Fonts/$i" -y | Select-String 'ok'; quit?('7z') }
    
$regkey = @'
REGEDIT4
[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Fonts]
"Segoe UI (TrueType)"="segoeui.ttf"
"Segoe UI Light (TrueType)"="segoeuil.ttf"
"Segoe UI Bold (TrueType)"="segoeuib.ttf"
"Segoe UI Bold Italic (TrueType)"="segoeuiz.ttf"
"Segoe UI Italic (TrueType)"="segoeuii.ttf"
"Tahoma (TrueType)"="tahoma.ttf"
"Tahoma Bold (TrueType)"="tahomabd.ttf"
"Lucida Console (True Type)"="lucon.ttf"
'@
    reg_edit $regkey
}

function func_vista_fonts
{
    $url = "https://catalog.s.download.windowsupdate.com/msdownload/update/software/updt/2010/04/windows6.0-kb980248-x86_c3accb4e416d6ef6d6fcbe27da9fc7da1fc22eb6.msu"
    $cab = "Windows6.0-KB980248-x86.cab"
    $sourcefile = @('arial.ttf','arialbd.ttf','arialbi.ttf','ariali.ttf','ariblk.ttf','calibrib.ttf','calibrii.ttf','calibri.ttf','calibriz.ttf','cambriab.ttf',`
    'cambriai.ttf','cambriaz.ttf','comicbd.ttf','comic.ttf','consolab.ttf','consolai.ttf','consola.ttf','consolaz.ttf','courbd.ttf','courbi.ttf',`
    'couri.ttf','cour.ttf','georgiab.ttf','georgiai.ttf','georgia.ttf','georgiaz.ttf','impact.ttf','l_10646.ttf','symbol.ttf','timesbd.ttf','timesbi.ttf',`
    'timesi.ttf','times.ttf','trebucbd.ttf','trebucbi.ttf','trebucit.ttf','trebuc.ttf','verdanab.ttf','verdanai.ttf','verdana.ttf','verdanaz.ttf','webdings.ttf','wingding.ttf')
    

    if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $(verb),  "$(verb).7z") ) ) {
        check_msu_sanity $url $cab;
        foreach ($i in $sourcefile) { &$expand_exe $([IO.Path]::Combine($cachedir,  $(verb),  $cab)) -f:$i $([IO.Path]::Combine($cachedir,  $(verb) ) ) }
        7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on "$cachedir\$(verb)\$(verb).7z" "$cachedir\$(verb)\x86*_6.0.6001.22635*" ; quit?('7z') #x86_microsoft-windows-font-truetype-webdings_31bf3856ad364e35_6.0.6001.22635_none_af74feceda033349
    }

    foreach($i in "$cab", "amd64", "x86", "wow64") { Remove-Item -Force -Recurse "$cachedir\$(verb)\$i*" -Erroraction SilentlyContinue }

    7z e "$cachedir\$(verb)\$(verb).7z" "x86*\*" -o"$env:systemroot\\Fonts" -aoa
    
    $regkey = @'
REGEDIT4
[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Fonts]
"Arial Black (TrueType)"="ariblk.ttf"
"Arial Bold (TrueType)"="arialbd.ttf"
"Arial Bold Italic (TrueType)"="arialbi.ttf"
"Arial Italic (TrueType)"="ariali.ttf"
"Calibri (TrueType)"="calibri.ttf"
"Calibri Bold (TrueType)"="calibrib.ttf"
"Calibri Bold Italic (TrueType)"="calibriz.ttf"
"Calibri Italic (TrueType)"="calibrii.ttf"
"Cambria Bold (TrueType)"="cambriab.ttf"
"Cambria Bold Italic (TrueType)"="cambriaz.ttf"
"Cambria Italic (TrueType)"="cambriai.ttf"
"Comic Sans MS (TrueType)"="comic.ttf"
"Comic Sans MS Bold (TrueType)"="comicbd.ttf"
"Consolas (TrueType)"="consola.ttf"
"Consolas Bold (TrueType)"="consolab.ttf"
"Consolas Bold Italic (TrueType)"="consolaz.ttf"
"Consolas Italic (TrueType)"="consolai.ttf"
"Courier New (TrueType)"="cour.ttf"
"Courier New Bold (TrueType)"="courbd.ttf"
"Courier New Bold Italic (TrueType)"="courbi.ttf"
"Courier New Italic (TrueType)"="couri.ttf"
"Georgia (TrueType)"="georgia.ttf"
"Georgia Bold (TrueType)"="georgiab.ttf"
"Georgia Bold Italic (TrueType)"="georgiaz.ttf"
"Georgia Italic (TrueType)"="georgiai.ttf"
"Impact (TrueType)"="impact.ttf"
"Lucida Sans Unicode (TrueType)"="l_10646.ttf"
"Symbol (TrueType)"="symbol.ttf"
"Tahoma (TrueType)"="tahoma.ttf"
"Tahoma Bold (TrueType)"="tahomabd.ttf"
"Times New Roman (TrueType)"="times.ttf"
"Times New Roman Bold (TrueType)"="timesbd.ttf"
"Times New Roman Bold Italic (TrueType)"="timesbi.ttf"
"Times New Roman Italic (TrueType)"="timesi.ttf"
"Trebuchet MS (TrueType)"="trebuc.ttf"
"Trebuchet MS Bold (TrueType)"="trebucbd.ttf"
"Trebuchet MS Bold Italic (TrueType)"="trebucbi.ttf"
"Trebuchet MS Italic (TrueType)"="trebucit.ttf"
"Verdana (TrueType)"="verdana.ttf"
"Verdana Bold (TrueType)"="verdanab.ttf"
"Verdana Bold Italic (TrueType)"="verdanaz.ttf"
"Verdana Italic (TrueType)"="verdanai.ttf"
"Webdings (TrueType)"="webdings.ttf"
"Wingdings (TrueType)"="wingding.ttf"
'@
    reg_edit $regkey
} <# end gdiplus #>

function func_dxvk1103
{
    $dldir = "dxvk1103"
    w_download_to "dxvk1103" "https://github.com/doitsujin/dxvk/releases/download/v1.10.3/dxvk-1.10.3.tar.gz" "dxvk-1.10.3.tar.gz"

    7z x -y $cachedir\\$dldir\\dxvk-1.10.3.tar.gz "-o$env:TEMP";quit?('7z') 
    7z e $env:TEMP\\dxvk-1.10.3.tar "-o$env:systemroot\\system32" dxvk-1.10.3/x64 -y;
    7z e $env:TEMP\\dxvk-1.10.3.tar "-o$env:systemroot\\syswow64" dxvk-1.10.3/x32 -y;
    foreach($i in 'dxgi', 'd3d9', 'd3d10_1', 'd3d10core', 'd3d10', 'd3d11') { dlloverride 'native' $i }
} <# end dxvk1101 #>

function func_dxvk20
{
    $dldir = "dxvk20"
    w_download_to "dxvk20" "https://github.com/doitsujin/dxvk/releases/download/v2.0/dxvk-2.0.tar.gz" "dxvk-2.0.tar.gz"

    7z x -y $cachedir\\$dldir\\dxvk-2.0.tar.gz "-o$env:TEMP";quit?('7z') 
    7z e $env:TEMP\\dxvk-2.0.tar "-o$env:systemroot\\system32" dxvk-2.0/x64 -y;
    7z e $env:TEMP\\dxvk-2.0.tar "-o$env:systemroot\\syswow64" dxvk-2.0/x32 -y;
    foreach($i in 'dxgi', 'd3d9', 'd3d10_1', 'd3d10core', 'd3d10', 'd3d11') { dlloverride 'native' $i }
} <# end dxvk20 #>

function func_net_cmdlets
{
@'
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
'@ | Out-File ( New-Item -Path $env:ProgramFiles\Powershell\7\Modules\Test-NetConnection\Test-NetConnection.psm1 -Force )

@'
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
'@ | Out-File ( New-Item -Path $env:ProgramFiles\Powershell\7\Modules\Get-NetIPAddress\Get-NetIPAddress.psm1 -Force )

@'
function Get-NetRoute {
      Get-WmiObject -query 'Select  Destination, NextHop From Win32_IP4RouteTable' |select Destination,NextHop |ft }
'@ | Out-File ( New-Item -Path $env:ProgramFiles\Powershell\7\Modules\Get-NetRoute\Get-NetRoute.psm1 -Force )

@'
function Resolve-DnsName([string]$name) { <# https://askme4tech.com/how-resolve-hostname-ip-address-and-vice-versa-powershell #>
    $type = [Uri]::CheckHostname($name)
    if( $type -eq 'Dns')                            { [System.Net.Dns]::GetHostaddresses($name) |select IPAddressToString}
    if( ($type -eq 'IPv4') || ($type -eq 'IPv6'))   { [System.Net.Dns]::GetHostentry($name).hostname}
}
'@ | Out-File ( New-Item -Path $env:ProgramFiles\Powershell\7\Modules\Resolve-DnsName\Resolve-DnsName.psm1 -Force )

<#
#Register-WMIEvent not available in PS Core, so for now just change into noop
function Register-WMIEvent {
    exit 0
}
  
#Example (works on windows,requires admin rights): Set-WmiInstance -class win32_operatingsystem -arguments @{"description" = "MyDescription"}
#Based on https://devblogs.microsoft.com/scripting/use-the-set-wmiinstance-powershell-cmdlet-to-ease-configuration/
Function Set-WmiInstance( [string]$class, [hashtable]$arguments, [string]$computername = "localhost", `
                          [string]$namespace = "root\cimv2" )
{
    $assembledpath = "\\" + $computername + "\" + $namespace + ":" + $class
    $obj = ([wmiclass]"$assembledpath").CreateInstance()

    foreach ($h in $arguments.GetEnumerator()) {
        $obj.$($h.Name) = $($h.Value)
    }
    $result = $obj.put()

    return $result.Path
}
#>


}

function func_ping <# fake ping for when wine's ping fails due to permission issues  #>
{
@'
function QPR.ping
{
    $cmdline = $($([kernel32]::GetCommandLineW()).Split(" ",4)[3])
    iex  -Command ('QPR_ping ' + $cmdline)
}

#https://stackoverflow.com/questions/53522016/how-to-measure-tcp-and-icmp-connection-time-on-remote-machine-like-ping
function QPR_ping { <# ping.exe replacement #>
    <#
        .SYNOPSIS
            Implementation PS du ping + tcp-Ping
        .DESCRIPTION
            retourne les temps de reponce ICMP (port 0) et TCP (port 1-65535)
        .PARAMETER HostAddress
            HostName ou IP a tester,
            pour le HostName une resolution DNS est faite a chaque boucle
        .PARAMETER ports
            Liste des ports TCP-IP a tester, le port 0 pour l'ICMP
        .PARAMETER timeout
            TimeOut des test individuel
        .PARAMETER loop
            nombre de boucle a effectuer, par defaut Infini
        .PARAMETER Intervale
            intervale entre chaque series de test
        .PARAMETER ComputerName
            permet de faire ce Ping en total remote,
            si ComputerName est fournis, joignable et different de localhost alors c'est lui qui executera ce code et retourne le resultat
            Requiere "Enable-PSRemoting -force"
        .EXAMPLE
            Ping sur ICMP + TCP:53,80,666 timeout 80ms (par test)
            Ping 8.8.8.8 -ports 0,53,80,666 -timeout 80 | ft
        .EXAMPLE
            3 ping en remote depuis le serveur vdiv05 sur ICMP,3389,6516 le tous dans une jolie fenetre
            ping 10.48.50.27 0,3389,6516 -ComputerName vdiv05 -count 3 | Out-GridView
        .NOTES
            Alban LOPEZ 2018
            alban.lopez @t gmail.com
        #>
    Param(
        [string]$HostAddress = 'vps.opt2', 
        [ValidateRange(0, 65535)]
        [int[]]$ports =  @(80),                                         # @(0, 22, 135), 
        [ValidateRange(0, 2000)]
        [int]$timeout = 200,
        [int32]$n = 4,                                  # [int32]::MaxValue,  68 annees !
        [ValidateSet(250, 500, 1000, 2000, 4000, 10000)]
        [int]$Intervale = 2000,
        $l = 32,                                                        # 1Kb,
        $ComputerName = $null
    )
    
    
    
    begin {     
        if ($computerName -and $computerName -notmatch "^(\.|localhost|127.0.0.1)$|^$($env:computername)" -and (Test-TcpPort -DestNodes $computerName -ConfirmIfDown)) {
            $pingScriptBlock = Include-ToScriptblock -functions 'write-logStep', 'write-color', 'Write-Host', 'ping', 'Test-TcpPort', 'Include-ToScriptblock'
        } else {
            $ComputerName = $null
            $ObjPing = [pscustomobject]@{
                DateTime   = $null
                IP         = $null
                Status     = $null
                hasChanged = $null
            }
            $ObjPings = $test = @()
            if (!$ports) {$ports = @(0)}
            $Ports | ForEach-Object {
                if ($_) {
                    # TCP
                    $ObjPing | Add-Member -MemberType NoteProperty -Name "Tcp-$_" -Value $null
                    $test += "Tcp-$_"
                }
                else {
                    # ICMP
                    $ping = new-object System.Net.NetworkInformation.Ping
                    $ObjPing | Add-Member -MemberType NoteProperty -Name ICMP -Value $null

                    $ObjPing | Add-Member -MemberType NoteProperty -Name 'ICMP-Ttl' -Value $null
                    # $ObjPing | Add-Member -MemberType NoteProperty -Name 'ICMP-Size' -Value $l
                    $buffer = [byte[]](1..$l | ForEach-Object {get-random -Minimum 20 -Maximum 255})
                    $test += "ICMP ($l Octs)"
                }
            }
            # Write-LogStep -prefixe 'L.%Line% Ping' "Ping [$DestNode] ", ($test -join(' + ')) ok
        }
        
    #statistics calculations
    $averageTime = -1;
    $minimumTime = $timeout;
    $maximumTime = 0
    $count = $n;
        
    }
    process {
        if(!$ComputerName){

           if (!($HostAddress -as [System.Net.IPAddress])){
           
             try { $entry = [System.Net.Dns]::GetHostEntry($HostAddress) }
             catch { Write-Host "Ping request could not find host $HostAddress. Please check the name and try again."; return}
              $DestNode = $entry.AddressList | Where-Object -Property AddressFamily -eq -Value "InternetWork" |Get-random
              $HostName = $entry.HostName
           if(!$HostAddress){break}
           } else {
               $DestNode = [System.Net.IPAddress]$HostAddress
                $HostName = $HostAddress
           }

            Write-Host ""
            Write-Host "pinging $HostAddress [$DestNode] with $l bytes of data:"

                        $ObjPing.DateTime = (get-date)
                        $ObjPing.status = $ObjPing.haschanged = $null
                        $ObjPing.IP = [string][System.Net.Dns]::GetHostAddresses($DestNode).IPAddressToString
                                While ($n--) {
                $ms = (Measure-Command {
                    try {
                        #$ObjPing.DateTime = (get-date)
                       # $ObjPing.status = $ObjPing.haschanged = $null
                       # $ObjPing.IP = [string][System.Net.Dns]::GetHostAddresses($DestNode).IPAddressToString
                        #Write-LogStep -prefixe 'L.%Line% Ping' "Ping $DestNode", $ObjPing.IP wait
                            foreach ($port in $ports) {
                                if ($port) {
                                    # TCP
                                    $ObjPing."Tcp-$port" = $iar = $null
                                    try {
                                        $tcpclient = new-Object system.Net.Sockets.TcpClient # Create TCP Client
                                        $iar = $tcpclient.BeginConnect($ObjPing.IP, $port, $null, $null) # Tell TCP Client to connect to machine on Port
                                        $timeMs = (Measure-Command {
                                                $wait = $iar.AsyncWaitHandle.WaitOne($timeout, $false) # Set the wait time
                                            }).TotalMilliseconds
                                    }
                                    catch {
                                        # Write-verbose $_
                                    }
                                    # Write-LogStep -prefixe 'L.%Line% Ping' "Tcp-$port", $x.status, $timeMs ok
                                    # Check to see if the connection is done
                                    if (!$wait) {
                                        # Close the connection and report timeout
                                        $ObjPing."Tcp-$port" = 'TimeOut'
                                        $tcpclient.Close()
                                    }
                                    else {
                                        try {
                                            $ObjPing."Tcp-$port" = [int]$timeMs
                                            $ObjPing.status ++
                                            # Write-LogStep -prefixe 'L.%Line% Ping' 'TCP ', "$($ObjPing."Tcp-$port") ms" ok
                                            $tcpclient.EndConnect($iar) | out-Null
                                            $tcpclient.Close()
                                        }
                                        catch {
                                            # $ObjPing."Tcp-$port" = 'Unknow Host'
                                        }
                                    }
                                    if ($tcpclient) {
                                        $tcpclient.Dispose()
                                        $tcpclient.Close()
                                    }
                                }
                                else {
                                    # ICMP
                                    $ObjPing.ICMP = $ObjPing."ICMP-Ttl"  = $null # $ObjPing."ICMP-Size"
                                    try {
                                        $x = $ping.send($ObjPing.IP, $timeOut, $Buffer)
                                        if ($x.status -like 'Success') {
                                            $ObjPing."ICMP" = [int]$x.RoundtripTime
                                            $ObjPing."ICMP-Ttl" = $x.Options.Ttl
                                            # $ObjPing."ICMP-Size" = $x.Buffer.Length
                                            $ObjPing.status ++
                                            # Write-LogStep -prefixe 'L.%Line% Ping' 'ICMP ', "$($x.RoundtripTime) ms", $x.Options.Ttl, $x.Buffer.Length ok
                                        }
                                        else {
                                            # Write-LogStep -prefixe 'L.%Line% Ping' 'ICMP ', "$($x.RoundtripTime) ms", $x.Options.Ttl, $x.Buffer.Length Warn
                                            $ObjPing."ICMP" = $x.status
                                            $ObjPing."ICMP-Ttl" = $ObjPing."ICMP-Size" = '-'
                                        }
                                    }
                                    catch {
                                        # $ObjPing.ICMP =  'Unknow Host'
                                    }
                                }
                            }
                        }
                        catch {
                            # Write-LogStep -prefixe 'L.%Line% Ping' '', 'Inpossible de determiner le noeud de destination !' error
                            $ObjPing.Status = 0
                        }
                        #$ObjPing.status = "$([int]([Math]::Round($ObjPing.status / $ports.count,2) * 100))%"
                        #$ObjPing.hasChanged = !($ObjPing.Status -eq $last -and $ObjPing.IP -eq $IP )
                        $last = $ObjPing.Status
                        $IP = $ObjPing.IP
                        ipconfig /flushdns
                    }).TotalMilliseconds

                $ObjPings += $ObjPing

                
                if($timeMs  -lt 200) { Write-Host Reply from "$IP": bytes=$l time="$timeMs"ms TTL=123
                
                            if ($timeMs -gt $maximumTime)
            {
                $maximumTime = $timeMs;
            }
            if ($timeMs -lt $minimumTime)
            {
                $minimumTime = $timeMs;
            }
   
        $averageTime += $timeMs;
               
                }
                else    { Write-Host "Request timed out" }

                if ($n -and $Intervale - $ms -gt 0) {
                    start-sleep -m ($Intervale - $ms)
                }
            }    
            
            
           Write-Host ""
           Write-Host  "Ping statistics for ${IP}:"
           Write-Host "	Packets: Sent = $count, Received = $count, Lost = 0 <0% loss>,"
           Write-Host "Approximate round trip times in milli-seconds:" 
           Write-Host "	Minimum = ${minimumTime}ms, Maximum = ${maximumTime}ms, Average = $($averageTime/$count)ms" 
                        
                         
        }
    }
    end {
        if ($computerName) {
            $pingScriptBlock = $pingScriptBlock | Include-ToScriptblock -StringBlocks "Ping -DestNode $DestNode -ports $($ports -join(',')) -timeout $timeout -loop $n -Intervale $Intervale"
            Invoke-Command -ComputerName $ComputerName -ScriptBlock $pingScriptBlock | Select-Object -Property * -ExcludeProperty RunspaceID
        }
     exit 0
    }
}
'@ | Out-File ( New-Item -Path $env:ProgramFiles\Powershell\7\Modules\QPR.ping\QPR.ping.psm1 -Force )

	Copy-Item -Path "$env:windir\\SysWOW64\\WindowsPowerShell\\v1.0\\powershell.exe" -Destination "$env:windir\\SysWOW64\\ping.exe" -Force
    Copy-Item -Path "$env:winsysdir\\WindowsPowerShell\\v1.0\\powershell.exe" -Destination "$env:winsysdir\\ping.exe" -Force
		  
    foreach($i in 'ping.exe') { dlloverride 'native' $i }

} <# end ping #>
 
function func_nocrashdialog <# nocrashdialog #>
{
$regkey = @"
REGEDIT4
[HKEY_CURRENT_USER\Software\Wine\WineDbg]
"ShowCrashDialog"=dword:00000000
"BreakOnFirstChance"=dword:00000000
"@
    reg_edit $regkey
} <# end nocrashdialog #>

function func_renderer=vulkan <# renderer=vulkan #>
{   
$regkey = @"
REGEDIT4
[HKEY_CURRENT_USER\Software\Wine\Direct3D]
"renderer"="vulkan"
"@
    reg_edit $regkey
} <# end renderer=vulkan #>

function func_renderer=gl <# renderer=gl #>
{   
$regkey = @"
REGEDIT4
[HKEY_CURRENT_USER\Software\Wine\Direct3D]
"renderer"="gl"
"@
    reg_edit $regkey
} <# end renderer=vulkan #>

function func_app_paths
{
    Push-Location ;
    Set-Location 'HKLM:' 
    $r=(Get-ItemProperty (dir 'HKLM:\Software\Microsoft\Windows\CurrentVersion\App Paths')).path -join ';'
    $env:PATH += ";$r" 
    [Environment]::SetEnvironmentVariable("PATH", $env:PATH, "MACHINE")  
    Pop-Location
    pwsh -nologo
}

function func_vs19
{
    func_wine_msxml3
    #func_msxml3
    #func_vcrun2019
    #func_xmllite
    #func_cmd
    func_wine_advapi32
    #func_wine_combase
    func_wine_shell32
    #func_wine_wintypes
    func_winmetadata
    
    winecfg /v win7

    (New-Object System.Net.WebClient).DownloadFile('https://aka.ms/vs/16/release/vs_community.exe', "$env:TMP\\vs_Community.exe") <#  https://download.visualstudio.microsoft.com/download/pr/1d66edfe-3c83-476b-bf05-e8901c62ba7f/ef3e389f222335676581eddbe7ddec01147969c1d42e19b9dade815c3c0f04b1/vs_Community.exe #>

  #  7z x $env:TMP\\installer "-o$env:TMP\\opc" -y ;quit?('7z')

    <# hack to workaround hanging sh.exe (when cloning repository) , fixed in wine-9.21#>
    if( [System.Convert]::ToDecimal( ($ntdll::wine_get_version() -replace '-rc','' ) ) -lt 9.21 ) {

        choco install busybox
    
        start-threadjob -ScriptBlock {
          $sh = "$env:ProgramFiles\Microsoft Visual Studio\2019\Community\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\Git\usr\bin\sh.exe";
          while(!(Test-Path -Path "$sh" -PathType Leaf) ) {Sleep 2.0} ;
          Copy-Item "$sh" "$($sh+'.back')" -force
          Copy-Item "$env:Systemroot\system32\setx.exe" "$sh" -force
        }
@'
    function QPR.sh { <# sh.exe replacement #>
    $argv = CommandLineToArgvW $('sh.exe' + ' ' + $($([kernel32]::GetCommandLineW()).Split(" ",4)[3])) 
    busybox sh $argv
}
'@ | Out-File ( New-Item -Path $env:ProgramFiles\Powershell\7\Modules\QPR.sh\QPR.sh.psm1 -Force )

    }  <# end hack sh.exe  #>

    set-executionpolicy bypass

    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = "$env:Temp\vs_community.exe"
    $startInfo.Arguments = "--downloadThenInstall --quiet --productId Microsoft.VisualStudio.Product.Community  --channelId VisualStudio.16.Release  --channelUri `"https://aka.ms/vs/16/release/channel`" --add Microsoft.VisualStudio.Workload.NativeDesktop --includeRecommended --wait"
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo
    $process.Start()

    Write-Host -foregroundcolor yellow "**********************************************************"
    Write-Host -foregroundcolor yellow "*                                                        *"
    Write-Host -foregroundcolor yellow "*        Downloading  and installing Visual Studio       *"
    Write-Host -foregroundcolor yellow "*        might takes > 15 minutes!                       *"
    Write-Host -foregroundcolor yellow "*        Patience please!                                *"
    Write-Host -foregroundcolor yellow "*                                                        *"
    Write-Host -foregroundcolor yellow "**********************************************************"

    $process.WaitForExit()

    # Start-Process  "$env:TMP\\opc\\Contents\\vs_installer.exe" -Verb RunAs -ArgumentList "install --channelId VisualStudio.16.Release --channelUri `"https://aka.ms/vs/16/release/channel`" --productId Microsoft.VisualStudio.Product.Community --add Microsoft.VisualStudio.Workload.VCTools --add `"Microsoft.VisualStudio.Component.VC.Tools.x86.x64`" --add `"Microsoft.VisualStudio.Component.VC.CoreIde`"  --add `"Microsoft.VisualStudio.Component.Windows10SDK.16299`"           --includeRecommended --quiet"
    #& 'C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x64\cl.exe'  -I"c:\Program Files (x86)/Windows Kits/10/Include/10.0.19041.0/um/"     -I"c:\Program Files (x86)/Windows Kits/10/Include/10.0.19041.0/Shared/"   -I"c:\Program Files (x86)/Microsoft Visual Studio/2019/Community/VC/Tools/MSVC/14.29.30133/include/"  -I"c:\Program Files (x86)/Windows Kits/10/Include/10.0.19041.0/ucrt/" .\code.cpp /link /LIBPATH:"c:/Program Files (x86)/Windows Kits/10/Lib/10.0.19041.0/um/x64/" /LIBPATH:"c:\Program Files (x86)/Microsoft Visual Studio/2019/Community/VC/Tools/MSVC/14.29.30133/lib/x64/" /LIBPATH:"c:/Program Files (x86)/Windows Kits/10/Lib/10.0.19041.0/ucrt/x64/"

    quit?('setup');quit?('vs_installer'); quit?('VSFinalizer'); quit?('devenv')

    if(!(Test-Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe')) {New-Item  -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe'}
    if(!(Test-Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe\\DllOverrides')) {New-Item  -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe\\DllOverrides'}
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe\\DllOverrides' -Name 'advapi32' -Value 'native' -PropertyType 'String' -force
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe\\DllOverrides' -Name 'shell32' -Value 'native' -PropertyType 'String' -force
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe\\DllOverrides' -Name 'concrt140' -Value 'native' -PropertyType 'String' -force

    New-Item  -Path "HKLM:\\Software\\Classes\\CLSID\\{4E14FBA2-2E22-11D1-9964-00C04FBBB345}"
    New-Item  -Path "HKLM:\\Software\\Classes\\CLSID\\{4E14FBA2-2E22-11D1-9964-00C04FBBB345}\\InprocServer32"
    New-ItemProperty -Path "HKLM:\\Software\\Classes\\CLSID\\{4E14FBA2-2E22-11D1-9964-00C04FBBB345}\\InprocServer32" -Name "(Default)" -Value 'c:\windows\system32\es.dll' -PropertyType 'String' -force

#    if( [System.Convert]::ToDecimal( ($ntdll::wine_get_version() -replace '-rc','' ) ) -lt 8.13 ) {
#        New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe\\DllOverrides' -Name 'combase' -Value 'native' -PropertyType 'String' -force }

    <# FIXME: frequently mpc are not written to registry (wine bug?), do it manually #>
    & "${env:ProgramFiles`(x86`)}\Microsoft` Visual` Studio\2019\Community\Common7\IDE\DDConfigCA.exe" | & "${env:ProgramFiles`(x86`)}\Microsoft` Visual` Studio\2019\Community\Common7\IDE\StorePID.exe" 09299
}

function func_vs22
{
    func_wine_msxml3
#   func_vcrun2019
    func_xmllite
    func_uiautomationcore
    func_wine_sxs  <# FIXME: now very sad hack, probably disabling functionality (?), needs more work to figure out what goes wrong#>
    func_wine_advapi32
    func_wine_combase
    func_wine_shell32
    func_wine_wintypes
    func_winmetadata
    if( [System.Convert]::ToDecimal( ($ntdll::wine_get_version() -replace '-rc','' ) ) -lt 10.4 ) { func_wine_cfgmgr32 }

    winecfg /v win10

    # Fall back to builtin powershell to fake success for failing command:
    # "c:\windows\syswow64\\windowspowershell\v1.0\powershell.exe" -NoLogo -NoProfile -Noninteractive -ExecutionPolicy Unrestricted -InputFormat None -Command "& """C:\ProgramData\Microsoft\VisualStudio\Packages\Microsoft.VisualCpp.Redist.14,version=14.40.33810,chip=x64\VCRedistInstall.ps1""" -PayloadDirectory """C:\ProgramData\Microsoft\VisualStudio\Packages\Microsoft.VisualCpp.Redist.14,version=14.40.33810,chip=x64""" -Architecture x64 -Logfile """C:\users\MYNAME\AppData\Local\Temp\dd_setup_20240728084731_003_Microsoft.VisualCpp.Redist.14.log"""; exit $LastExitCode"
#   foreach($i in 'powershell.exe') { dlloverride 'builtin' $i }
    
    (New-Object System.Net.WebClient).DownloadFile('https://aka.ms/vs/17/release/vs_community.exe', "$env:TMP\\vs_Community.exe") 

  #  7z x $env:TMP\\installer "-o$env:TMP\\opc" -y ;quit?('7z')

    if( [System.Convert]::ToDecimal( ($ntdll::wine_get_version() -replace '-rc','' ) ) -lt 9.21 ) {
    <# hack to workaround hanging sh.exe (when cloning repository) , fixed in wine-9.21#>
        choco install busybox
    
        start-threadjob -ScriptBlock {
          $sh = "$env:ProgramFiles\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\Git\usr\bin\sh.exe";
          while(!(Test-Path -Path "$sh" -PathType Leaf) ) {Sleep 2.0} ;
          Copy-Item "$sh" "$($sh+'.back')" -force
          Copy-Item "$env:Systemroot\system32\setx.exe" "$sh" -force
        }
@'
    function QPR.sh { <# sh.exe replacement #>
    $argv = CommandLineToArgvW $('sh.exe' + ' ' + $($([kernel32]::GetCommandLineW()).Split(" ",4)[3])) 
    busybox sh $argv
}
'@ | Out-File ( New-Item -Path $env:ProgramFiles\Powershell\7\Modules\QPR.sh\QPR.sh.psm1 -Force )

    }  <# end hack sh.exe  #>
    
    set-executionpolicy bypass

    New-ItemProperty -Path 'HKCU:\\Software\\Microsoft\\Avalon.Graphics' -Name 'DisableHWAcceleration' -Value 1 -PropertyType 'Dword' -force

    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = "$env:Temp\vs_community.exe"
    $startInfo.Arguments = "--downloadThenInstall --quiet --productId Microsoft.VisualStudio.Product.Community  --channelId VisualStudio.17.Release  --channelUri `"https://aka.ms/vs/17/release/channel`" --add Microsoft.VisualStudio.Workload.NativeDesktop --includeRecommended --wait" 
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo
    $process.Start()

    Write-Host -foregroundcolor yellow "**********************************************************"
    Write-Host -foregroundcolor yellow "*                                                        *"
    Write-Host -foregroundcolor yellow "*        Downloading  and installing Visual Studio       *"
    Write-Host -foregroundcolor yellow "*        might takes > 25 minutes!                       *"
    Write-Host -foregroundcolor yellow "*        Patience please!                                *"
    Write-Host -foregroundcolor yellow "*                                                        *"
    Write-Host -foregroundcolor yellow "**********************************************************"

    $process.WaitForExit()

    # Start-Process  "$env:TMP\\opc\\Contents\\vs_installer.exe" -Verb RunAs -ArgumentList "install --channelId VisualStudio.17.Release --channelUri `"https://aka.ms/vs/17/release/channel`" --productId Microsoft.VisualStudio.Product.Community --add Microsoft.VisualStudio.Workload.VCTools --add `"Microsoft.VisualStudio.Component.VC.Tools.x86.x64`" --add `"Microsoft.VisualStudio.Component.VC.CoreIde`"  --add `"Microsoft.VisualStudio.Component.Windows10SDK.16299`"           --includeRecommended --quiet"
    #& 'C:\Program Files (x86)\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x64\cl.exe'  -I"c:\Program Files (x86)/Windows Kits/10/Include/10.0.19041.0/um/"     -I"c:\Program Files (x86)/Windows Kits/10/Include/10.0.19041.0/Shared/"   -I"c:\Program Files (x86)/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.29.30133/include/"  -I"c:\Program Files (x86)/Windows Kits/10/Include/10.0.19041.0/ucrt/" .\code.cpp /link /LIBPATH:"c:/Program Files (x86)/Windows Kits/10/Lib/10.0.19041.0/um/x64/" /LIBPATH:"c:\Program Files (x86)/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.29.30133/lib/x64/" /LIBPATH:"c:/Program Files (x86)/Windows Kits/10/Lib/10.0.19041.0/ucrt/x64/"

    #if(!(Test-Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe')) {New-Item  -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe'}
    #if(!(Test-Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe\\DllOverrides')) {New-Item  -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe\\DllOverrides'}
    #New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe\\DllOverrides' -Name 'advapi32' -Value 'native' -PropertyType 'String' -force
    #New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe\\DllOverrides' -Name 'shell32' -Value 'native' -PropertyType 'String' -force

    quit?('setup');quit?('vs_installer'); quit?('VSFinalizer'); quit?('devenv')

    <# FIXME: frequently mpc are not written to registry (wine bug?), do it manually #>
    & "${env:ProgramFiles}\Microsoft` Visual` Studio\2022\Community\Common7\IDE\DDConfigCA.exe" | & "${env:ProgramFiles}\Microsoft` Visual` Studio\2022\Community\Common7\IDE\StorePID.exe" 09299

    if(!(Test-Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe')) {New-Item  -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe'}
    if(!(Test-Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe\\X11 Driver')) {New-Item  -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe\\X11 Driver'}
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe\\X11 Driver' -Name 'Decorated' -Value 'N' -PropertyType 'String' -force

    if(!(Test-Path 'HKCU:\\Software\\Wine\\AppDefaults\\DesignToolsServer.exe')) {New-Item  -Path 'HKCU:\\Software\\Wine\\AppDefaults\\DesignToolsServer.exe'}
    if(!(Test-Path 'HKCU:\\Software\\Wine\\AppDefaults\\DesignToolsServer.exe\\DllOverrides')) {New-Item  -Path 'HKCU:\\Software\\Wine\\AppDefaults\\DesignToolsServer.exe\\DllOverrides'}
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\DesignToolsServer.exe\\DllOverrides' -Name 'kernel32' -Value '' -PropertyType 'String' -force

    New-Item  -Path "HKLM:\\Software\\Classes\\CLSID\\{4E14FBA2-2E22-11D1-9964-00C04FBBB345}"
    New-Item  -Path "HKLM:\\Software\\Classes\\CLSID\\{4E14FBA2-2E22-11D1-9964-00C04FBBB345}\\InprocServer32"
    New-ItemProperty -Path "HKLM:\\Software\\Classes\\CLSID\\{4E14FBA2-2E22-11D1-9964-00C04FBBB345}\\InprocServer32" -Name "(Default)" -Value 'c:\windows\system32\es.dll' -PropertyType 'String' -force

    #New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe\\DllOverrides' -Name 'sxs' -Value '' -PropertyType 'String' -force
    #New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe' -Name 'Version' -Value 'win7' -PropertyType 'String' -force
    winecfg /v win7  <# FIXME win10 does not work#>
    
    foreach($i in 'concrt140') { dlloverride 'native,builtin' $i }
}

function func_vs22_interactive_installer
{
    func_wine_msxml3
    #func_ps51
#   func_vcrun2019
    #func_xmllite
    #func_cmd
#    func_wine_sxs  <# FIXME: now very sad hack, probably disabling functionality (?), needs more work to figure out what goes wrong #>
    func_wine_advapi32
    func_wine_combase
    func_wine_shell32
    #func_wine_wintypes
    func_winmetadata
    if( [System.Convert]::ToDecimal( ($ntdll::wine_get_version() -replace '-rc','' ) ) -lt 10.4 ) { func_wine_cfgmgr32 }

    winecfg /v win10

    # Fall back to builtin powershell to fake success for failing command:
    # "c:\windows\syswow64\\windowspowershell\v1.0\powershell.exe" -NoLogo -NoProfile -Noninteractive -ExecutionPolicy Unrestricted -InputFormat None -Command "& """C:\ProgramData\Microsoft\VisualStudio\Packages\Microsoft.VisualCpp.Redist.14,version=14.40.33810,chip=x64\VCRedistInstall.ps1""" -PayloadDirectory """C:\ProgramData\Microsoft\VisualStudio\Packages\Microsoft.VisualCpp.Redist.14,version=14.40.33810,chip=x64""" -Architecture x64 -Logfile """C:\users\MYNAME\AppData\Local\Temp\dd_setup_20240728084731_003_Microsoft.VisualCpp.Redist.14.log"""; exit $LastExitCode"
    # foreach($i in 'powershell.exe') { dlloverride 'builtin' $i }
    
    if(!(Test-Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe')) {New-Item  -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe'}
    if(!(Test-Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe\\X11 Driver')) {New-Item  -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe\\X11 Driver'}
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe\\X11 Driver' -Name 'Decorated' -Value 'N' -PropertyType 'String' -force
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe' -Name 'Version' -Value 'win7' -PropertyType 'String' -force

    New-ItemProperty -Path 'HKCU:\\Software\\Microsoft\\Avalon.Graphics' -Name 'DisableHWAcceleration' -Value 1 -PropertyType 'Dword' -force

    foreach($i in 'concrt140') { dlloverride 'native,builtin' $i }

    <# FIXME: some of these too crash in win10 mode, too lazy to figure out which one's. And why they crash... Set version to win7 for now#>
    foreach($i in
	'Microsoft.ServiceHub.Controller.exe', 'ServiceHub.Host.Node.x86.exe',
	'ServiceHub.Host.dotnet.x64.exe',
	'ServiceHub.RoslynCodeAnalysisServiceS.exe',
	'ServiceHub.ThreadedWaitDialog.exe',
	'ServiceHub.VSDetouredHost.exe',
	'ServiceHub.IdentityHost.exe',
	'ServiceHub.LiveUnitTesting.RemoteSyncManager.exe',
	'ServiceHub.DataWarehouseHost.exe',
	'ServiceHub.RoslynCodeAnalysisService.exe',
	'ServiceHub.IndexingService.exe',
	'ServiceHub.IdentityHost.exe',
	'ServiceHub.DataWarehouseHost.exe',
	'ServiceHub.Host.netfx.x86.exe',
	'ServiceHub.Host.netfx.x64.exe',
	'ServiceHub.DataWarehouseHost.exe',
	'ServiceHub.IntellicodeModelService.exe',
	'ServiceHub.Host.Extensibility.exe',
	'ServiceHub.TestWindowStoreHost.exe',
	'ServiceHub.RoslynCodeAnalysisServiceS.exe',
	'ServiceHub.LiveUnitTesting.exe',
	'ServiceHub.ThreadedWaitDialog.exe',
	'ServiceHub.VSDetouredHost.exe',
	'ServiceHub.Host.AnyCPU.exe',
	'ServiceHub.RoslynCodeAnalysisService.exe',
	'ServiceHub.SettingsHost.exe') {
    if(!(Test-Path "HKCU:\\Software\\Wine\\AppDefaults\\$i")) {New-Item  -Path "HKCU:\\Software\\Wine\\AppDefaults\\$i"}
    New-ItemProperty -Path "HKCU:\\Software\\Wine\\AppDefaults\\$i" -Name 'Version' -Value 'win7' -PropertyType 'String' -force
 }
 
    if(!(Test-Path 'HKCU:\\Software\\Wine\\AppDefaults\\DesignToolsServer.exe')) {New-Item  -Path 'HKCU:\\Software\\Wine\\AppDefaults\\DesignToolsServer.exe'}
    if(!(Test-Path 'HKCU:\\Software\\Wine\\AppDefaults\\DesignToolsServer.exe\\DllOverrides')) {New-Item  -Path 'HKCU:\\Software\\Wine\\AppDefaults\\DesignToolsServer.exe\\DllOverrides'}
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\DesignToolsServer.exe\\DllOverrides' -Name 'kernel32' -Value '' -PropertyType 'String' -force

    (New-Object System.Net.WebClient).DownloadFile('https://aka.ms/vs/17/release/vs_community.exe', "$env:TMP\\vs_Community.exe") 

    New-Item  -Path "HKLM:\\Software\\Classes\\CLSID\\{4E14FBA2-2E22-11D1-9964-00C04FBBB345}"
    New-Item  -Path "HKLM:\\Software\\Classes\\CLSID\\{4E14FBA2-2E22-11D1-9964-00C04FBBB345}\\InprocServer32"
    New-ItemProperty -Path "HKLM:\\Software\\Classes\\CLSID\\{4E14FBA2-2E22-11D1-9964-00C04FBBB345}\\InprocServer32" -Name "(Default)" -Value 'c:\windows\system32\es.dll' -PropertyType 'String' -force

    if( [System.Convert]::ToDecimal( ($ntdll::wine_get_version() -replace '-rc','' ) ) -lt 9.21 ) {
    <# hack to workaround hanging sh.exe (when cloning repository), fixed in wine-9.21 #>
        choco install busybox
    
        start-threadjob -ScriptBlock {
          $sh = "$env:ProgramFiles\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\Git\usr\bin\sh.exe";
          while(!(Test-Path -Path "$sh" -PathType Leaf) ) {Sleep 2.0} ;
          Copy-Item "$sh" "$($sh+'.back')" -force
          Copy-Item "$env:Systemroot\system32\setx.exe" "$sh" -force
        }
@'
    function QPR.sh { <# sh.exe replacement #>
    $argv = CommandLineToArgvW $('sh.exe' + ' ' + $($([kernel32]::GetCommandLineW()).Split(" ",4)[3])) 
    busybox sh $argv
}
'@ | Out-File ( New-Item -Path $env:ProgramFiles\Powershell\7\Modules\QPR.sh\QPR.sh.psm1 -Force )

   }  <# end hack sh.exe  #>

    & "$env:TMP\\vs_Community.exe" --wait
    
    quit?('vs_Community')
    
#    <# FIXME: frequently mpc are not written to registry (wine bug?), do it manually #>
#    & "${env:ProgramFiles}\Microsoft` Visual` Studio\2022\Community\Common7\IDE\DDConfigCA.exe" | & "${env:ProgramFiles}\Microsoft` Visual` Studio\2022\Community\Common7\IDE\StorePID.exe" 09299
}

function func_vs19_interactive_installer
{
    func_wine_msxml3
    #func_ps51
#   func_vcrun2019
    #func_xmllite
    #func_cmd
    func_wine_advapi32
    func_wine_combase
    func_wine_shell32
    #func_wine_wintypes
    func_winmetadata

    winecfg /v win10
    
    if(!(Test-Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe')) {New-Item  -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe'}
    if(!(Test-Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe\\X11 Driver')) {New-Item  -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe\\X11 Driver'}
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe\\X11 Driver' -Name 'Decorated' -Value 'N' -PropertyType 'String' -force
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe' -Name 'Version' -Value 'win7' -PropertyType 'String' -force

    New-ItemProperty -Path 'HKCU:\\Software\\Microsoft\\Avalon.Graphics' -Name 'DisableHWAcceleration' -Value 1 -PropertyType 'Dword' -force

    foreach($i in 'concrt140') { dlloverride 'native,builtin' $i }

  
#    if(!(Test-Path 'HKCU:\\Software\\Wine\\AppDefaults\\DesignToolsServer.exe')) {New-Item  -Path 'HKCU:\\Software\\Wine\\AppDefaults\\DesignToolsServer.exe'}
#    if(!(Test-Path 'HKCU:\\Software\\Wine\\AppDefaults\\DesignToolsServer.exe\\DllOverrides')) {New-Item  -Path 'HKCU:\\Software\\Wine\\AppDefaults\\DesignToolsServer.exe\\DllOverrides'}
#    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\DesignToolsServer.exe\\DllOverrides' -Name 'kernel32' -Value '' -PropertyType 'String' -force

    (New-Object System.Net.WebClient).DownloadFile('https://aka.ms/vs/16/release/vs_community.exe', "$env:TMP\\vs_Community.exe") 

    & "$env:TMP\\vs_Community.exe" --wait
    
    quit?('vs_Community')
    
}

function func_office365
{


winecfg /v win10

func_msxml6
func_riched20
func_wine_sppc

foreach($i in 'sppc') { dlloverride 'native' $i }
        
choco install Office365HomePremium

#  if(!(Test-Path 'HKCU:\\Software\\Wine\\Direct3D')) {New-Item  -Path 'HKCU:\\Software\\Wine\\Direct3D'}
#  New-ItemProperty -Path 'HKCU:\\Software\\Wine\\Direct3D' -Name 'MaxVersionGL' -Value '0x30002' -PropertyType 'DWORD' -force


(New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/EXTRAS/wine_wbemprox.7z', "$env:ProgramFiles\Microsoft Office 15\root\office15\wine_wbemprox.7z")
7z e "$env:ProgramFiles\Microsoft Office 15\root\office15\wine_wbemprox.7z" "-o$env:SystemRoot\syswow64\wbem" "32/wbemprox.dll"-y
7z e "$env:ProgramFiles\Microsoft Office 15\root\office15\wine_wbemprox.7z" "-o$env:SystemRoot\system32\wbem" "64/wbemprox.dll"-y


  if(!(Test-Path 'HKCU:\\Software\\Wine\\AppDefaults\\onenote.exe')) {New-Item  -Path 'HKCU:\\Software\\Wine\\AppDefaults\\onenote.exe'}
  if(!(Test-Path 'HKCU:\\Software\\Wine\\AppDefaults\\onenote.exe\\DllOverrides')) {New-Item  -Path 'HKCU:\\Software\\Wine\\AppDefaults\\onenote.exe\\DllOverrides'}
  New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\onenote.exe\\DllOverrides' -Name 'wbemprox' -Value 'native' -PropertyType 'String' -force

#  if(!(Test-Path 'HKCU:\\Software\\Wine\\AppDefaults\\powerpnt.exe')) {New-Item  -Path 'HKCU:\\Software\\Wine\\AppDefaults\\powerpnt.exe'}
#  if(!(Test-Path 'HKCU:\\Software\\Wine\\AppDefaults\\powerpnt.exe\\DllOverrides')) {New-Item  -Path 'HKCU:\\Software\\Wine\\AppDefaults\\powerpnt.exe\\DllOverrides'}
#  New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\powerpnt.exe\\DllOverrides' -Name 'kernel32' -Value 'native' -PropertyType 'String' -force
}

function func_git.portable
{
    if (![System.IO.File]::Exists(  [IO.Path]::Combine($env:systemdrive,'tools','git','usr','bin','msys-2.0.dll') ) ) {
        choco install git.portable

        Write-Host 'Performing some tweaks; Patience please...'
        
        #Get rid of the warning 'Cygwin WARNING:  Couldn't compute FAST_CWD pointer'

        #https://stackoverflow.com/questions/73790902/replace-string-in-a-binary-clipboard-dump-from-onenote
        # Read the file *as a byte array*.
        $data = Get-Content -AsByteStream -ReadCount 0  "$env:SystemDrive\tools\git\usr\bin\msys-2.0.dll"
        # Convert the array to a "hex string" in the form "nn-nn-nn-...",  where nn represents a two-digit hex representation of each byte,
        # e.g. '41-42' for 0x41, 0x42, which, if interpreted as a single-byte encoding (ASCII), is 'AB'.
        $dataAsHexString = [BitConverter]::ToString($data)
        # Define the search and replace strings, and convert them into "hex strings" too, using their UTF-8 byte representation.
        $search =      "Cygwin WARNING:`n  Couldn't compute FAST_CWD pointer.  This typically occurs if you're using`n  an older Cygwin version on a newer Windows.  Please update to the latest`n  available Cygwin version from https://cygwin.com/.  If the problem persists,`n  please see https://cygwin.com/problems.html`n`n"
        $replacement = "`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0`0"

        $searchAsHexString = [BitConverter]::ToString([Text.Encoding]::UTF8.GetBytes($search))
        $replaceAsHexString = [BitConverter]::ToString([Text.Encoding]::UTF8.GetBytes($replacement))
        # Perform the replacement.
        $dataAsHexString = $dataAsHexString.Replace($searchAsHexString, $replaceAsHexString)
        # Convert he modified "hex string" back to a byte[] array.
        $modifiedData = [byte[]] ($dataAsHexString -split '-' -replace '^', '0x')
        # Save the byte array back to the file.
        Set-Content -AsByteStream "$env:SystemDrive\tools\git\usr\bin\msys-2.0.dll" -Value $modifiedData -verbose
 
        $pathvar=[System.Environment]::GetEnvironmentVariable('PATH')

        [System.Environment]::SetEnvironmentVariable("PATH", $pathvar + ';C:\tools\git\usr\bin' + ';C:\tools\git\mingw64\bin','Machine')
                
 	Write-Host -foregroundcolor yellow 'Do "refreshenv" to add several unix commands to current session!'
    }
}

function func_itunes
{
   func_wine_d2d1
   func_wine_msi
   choco install itunes #--version 12.12.4.1 --ignore-checksums
}

function func_nodejs
{
   func_wine_msi
   choco install nodejs
}

function func_cef
{
    . "$env:ProgramData\Chocolatey-for-wine\powershell_collected_codesnippets_examples.ps1"
    func_cef2
}

function func_sharpdx
{
    . "$env:ProgramData\Chocolatey-for-wine\powershell_collected_codesnippets_examples.ps1"
    func_sharpdx2
}

function func_glxgears
{
    . "$env:ProgramData\Chocolatey-for-wine\powershell_collected_codesnippets_examples.ps1"
    func_glxgears2
}

function func_wpf_xaml
{
    . "$env:ProgramData\Chocolatey-for-wine\powershell_collected_codesnippets_examples.ps1"
    func_wpf_xaml2
}

function func_wpf_msgbox
{
    . "$env:ProgramData\Chocolatey-for-wine\powershell_collected_codesnippets_examples.ps1"
    func_wpf_msgbox2
}

function func_wpf_routedevents
{
    . "$env:ProgramData\Chocolatey-for-wine\powershell_collected_codesnippets_examples.ps1"
    func_wpf_routedevents2
}

function func_embed-exe-in-psscript
{
    if (![System.IO.File]::Exists(  "$env:ProgramData\Chocolatey-for-wine\embed-exe-in-psscript.ps1"  )) {
        Add-Type -AssemblyName System.Windows.Forms
        $result = [System.Windows.Forms.MessageBox]::Show("Using this verb might likely trigger a viruswarning, but this script is actually really harmless. Download the script now? " , "Info" , 4)
        if ($result -eq 'Yes') {
            (New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/EXTRAS/embed-exe-in-psscript.ps1', "$env:ProgramData\Chocolatey-for-wine\embed-exe-in-psscript.ps1" )
        . "$env:ProgramData\Chocolatey-for-wine\embed-exe-in-psscript.ps1"
        func_embed-exe-in-psscript2
        }
        elseif ($result -eq 'No') { return } 
    }
    else {
        . "$env:ProgramData\Chocolatey-for-wine\embed-exe-in-psscript.ps1"
        func_embed-exe-in-psscript2
    }
}

function func_Get-PEHeader
{
    . "$env:ProgramData\Chocolatey-for-wine\powershell_collected_codesnippets_examples.ps1"
    func_Get-PEHeader2
}

function func_Get-MsiDatabaseProperties
{
    . "$env:ProgramData\Chocolatey-for-wine\powershell_collected_codesnippets_examples.ps1"
    func_Get-MsiDatabaseProperties2
}

function func_Get-MsiDatabaseRegistryKeys
{
    . "$env:ProgramData\Chocolatey-for-wine\powershell_collected_codesnippets_examples.ps1"
    func_Get-MsiDatabaseRegistryKeys2
}

function func_access_winrt_from_powershell
{
    . "$env:ProgramData\Chocolatey-for-wine\powershell_collected_codesnippets_examples.ps1"
    func_access_winrt_from_powershell2
}

function func_ps2exe
{
    . "$env:ProgramData\Chocolatey-for-wine\powershell_collected_codesnippets_examples.ps1"
    func_ps2exe2
}

function func_vanara
{
    . "$env:ProgramData\Chocolatey-for-wine\powershell_collected_codesnippets_examples.ps1"
    func_vanara2
}

function func_vulkansamples  <# force a full software rendering for Vulkan and OpenGL:  LIBGL_ALWAYS_SOFTWARE=1 __GLX_VENDOR_LIBRARY_NAME=mesa VK_DRIVER_FILES=/usr/share/vulkan/icd.d/lvp_icd.i686.json:/usr/share/vulkan/icd.d/lvp_icd.x86_64.json #>
{   <# https://www.saschawillems.de/blog/2017/03/25/updated-vulkan-example-binaries/ #>
    w_download_to $(verb) "http://vulkan.gpuinfo.org/downloads/examples/vulkan_examples_windows_x64.7z" "vulkan_examples_windows_x64.7z" 
    w_download_to $(verb) "http://vulkan.gpuinfo.org/downloads/examples/vulkan_examples_mediapack.7z" "vulkan_examples_mediapack.7z" 
    7z x "$cachedir\$(verb)\vulkan_examples_windows_x64.7z" "-o$env:Temp\$(verb)" -y; quit?(7z)
    7z x "$cachedir\$(verb)\vulkan_examples_mediapack.7z" "-o$env:Temp\$(verb)\vulkan_examples_windows_x64" -y; quit?(7z)
    Push-Location
    cd "$env:Temp\$(verb)\vulkan_examples_windows_x64\bin"
    foreach($i in (ls ("$env:Temp\$(verb)\vulkan_examples_windows_x64\bin\*.exe")).Name )  { Write-Host 'Press Shift-Ctrl^C to exit earlier...'; Start-process -Wait "$env:Temp\$(verb)\vulkan_examples_windows_x64\bin\$i" }
    Pop-Location
}

function func_dotnet2030
{
    w_download_to $(verb) "https://download.microsoft.com/download/2/0/e/20e90413-712f-438c-988e-fdaa79a8ac3d/dotnetfx35.exe" "dotnetfx35.exe"

    7z x "$cachedir\$(verb)\dotnetfx35.exe" -o"$env:TEMP\$(verb)\"  "wcu/./././././dotNetFramework/dotNetFX20/*"   "-x!wcu/./././././dotNetFramework/dotNetFX20/Netfx20a_x86.msi" "-x!wcu/./././././dotNetFramework/dotNetFX20/prexp.msp"  -aoa; quit?(7z)
    7z x "$cachedir\$(verb)\dotnetfx35.exe" -o"$env:TEMP\$(verb)\"  "wcu/./././././dotNetFramework/dotNetFX30/*" -aoa; quit?(7z)

    winecfg /v winxp #2003

    func_wine_msi

    <# dotnet20 #>
    $zne = 'msiexec.exe /i "$env:TEMP\$(verb)\wcu\dotNetFramework\dotNetFX20\Netfx20a_x64.msi" PATCH="'

    foreach($i in  'clr', <#'crt',#> 'dw','NetFX_Core', 'NetFX_Other', 'winforms', 'ASPNET' ) {
        $zne += "$env:TEMP\\$(verb)\\wcu\\dotNetFramework\\dotNetFX20\\$i" +'.msp;' + "$env:TEMP\\$(verb)\\wcu\\dotNetFramework\\dotNetFX20\\$i" + '_64' +'.msp;'
    }
    $zne += '" /q'
    
    iex $zne ; quit?('msiexec')
  
    <# dotnet30
    Netfx30a_x64.msi  WCS.msp          WPF1.msp          x64
    Netfx30a_x86.msi  WF_32.msp        WPF2_32.msp       x86
    RGB9RAST_x64.msi  WF_64.msp        WPF2_64.msp       XPSEPSC-amd64-en-US.exe
    RGB9RAST_x86.msi  WF.msp           WPF2.msp          XPSEPSC-x86-en-US.exe
    WCF_64.msp        WIC_x64_enu.exe  WPF_Other_32.msp  XPS.msp
    WCF.msp           WIC_x86_enu.exe  WPF_Other_64.msp
    WCS_64.msp        WPF1_64.msp      WPF_Other.msp
    #>

    $ze = 'msiexec.exe /i "$env:TEMP\$(verb)\wcu\dotNetFramework\dotNetFX30\Netfx30a_x64.msi" PATCH="'

    foreach($i in 'WF', 'WPF1', 'WPF2', 'WPF_Other', 'WCS', 'WCF', 'XPS') {
        $ze += "$env:TEMP\\$(verb)\\wcu\\dotNetFramework\\dotNetFX30\\$i" +'.msp;' + "$env:TEMP\\$(verb)\\wcu\\dotNetFramework\\dotNetFX30\\$i" + '_64' +'.msp;'

    }
    $ze += '" /q'

    iex $ze ; quit?('msiexec')
        
    dlloverride 'builtin' 'msi'
    winecfg /v win10
   
    $regkey = @"
REGEDIT4
[HKEY_LOCAL_MACHINE\Software\Microsoft\.NETFramework]
"OnlyUseLatestCLR"=dword:00000000
"@

    reg_edit $regkey

    foreach ($i in 'mscorwks') { dlloverride 'native' $i }

    Remove-Item -Force -Recurse  "$env:TEMP\dotnet35"
}

function func_dotnet35
{
    w_download_to $(verb) "https://download.microsoft.com/download/2/0/e/20e90413-712f-438c-988e-fdaa79a8ac3d/dotnetfx35.exe" "dotnetfx35.exe"

    7z x "$cachedir\$(verb)\dotnetfx35.exe" -o"$env:TEMP\$(verb)\"  "wcu/./././././dotNetFramework/dotNetFX35/x64/netfx35_x64.exe" -aoa; quit?(7z)
    7z x "$env:TEMP\$(verb)\wcu\dotNetFramework/dotNetFX35/x64/netfx35_x64.exe"  -o"$env:TEMP\$(verb)\"  -aoa; quit?(7z)

    winecfg /v winxp #2003

    func_wine_msi

    <# dotnet35 #>
    msiexec /i "$env:TEMP\$(verb)\vs_setup.msi" /q ; quit?('msiexec')
        
    dlloverride 'builtin' 'msi'
    winecfg /v win10
   
    $regkey = @"
REGEDIT4
[HKEY_LOCAL_MACHINE\Software\Microsoft\.NETFramework]
"OnlyUseLatestCLR"=dword:00000000
"@

    reg_edit $regkey

    foreach ($i in 'mscorwks') { dlloverride 'native' $i }

    Remove-Item -Force -Recurse  "$env:TEMP\dotnet35"
}

function write_keys_from_manifest([parameter(position=0)] [string] $manifest, [switch] $to_file){

    
    $Xml = [xml](Get-Content -Path "$manifest")

    if( $Xml.assembly.registryKeys ) { #try write regkeys from manifest file, thanks some guy from freenode webchat channel powershell who wrote skeleton of this in 4 minutes...
 
        foreach ($key in $Xml.assembly.registryKeys.registryKey) {
            $path = 'Registry::{0}' -f $key.keyName
    
            if ( ($Xml.assembly.assemblyIdentity.processorArchitecture -eq 'wow64') -or  ($Xml.assembly.assemblyIdentity.processorArchitecture -eq 'x86') ) { $path = $path -replace 'HKEY_LOCAL_MACHINE\\SOFTWARE','HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node' -replace 'HKEY_CLASSES_ROOT','HKEY_CLASSES_ROOT\Wow6432Node' }
	 
            if (-not (Test-Path -Path $path)) { New-Item -Path $path -ItemType Key -Force }

            #Write-Host Processing manifest $manifest
            foreach ($value in $key.registryValue) {
                $propertyType = switch ($value.valueType) {
                    'REG_SZ'         { 'String' }
                    'REG_BINARY'     { 'Binary' }
                    'REG_DWORD'      { 'DWORD'  }
	            'REG_EXPAND_SZ'  { 'ExpandString' } 
	            'REG_MULTI_SZ'   { 'MultiString'  } 
	            'REG_QWORD'      { 'QWord' }
                    'REG_NONE'       { '' } 
                }

                $Regname = switch ($value.Name) {
                    '' { ‘(Default)’ }
                    'registryValue' { ‘(Default)’ } <#FIXME Bugs in script...#>
                    default { $value.Name }
                }
                #If ($propertyType -eq "Binary") { $value.Value = [System.Text.Encoding]::Unicode.GetBytes($value.Value + "000") ; $value.Value.Replace(" ",",")}
                #https://stackoverflow.com/questions/54543075/how-to-convert-a-hash-string-to-byte-array-in-powershell
                if ( ($propertyType -eq "Binary") ) {$hashByteArray = [byte[]] ($value.Value -replace '..', '0x$&,' -split ',' -ne '');New-ItemProperty -Path $path -Name $Regname -Value $hashByteArray  -PropertyType $propertyType -Force}
                else{
                    if ( $Xml.assembly.assemblyIdentity.processorArchitecture -eq 'amd64' -and $value.Value) {
                        $value.Value = $value.Value -replace ([Regex]::Escape('$(runtime.system32)')),"$env:systemroot\\system32" -replace ([Regex]::Escape('$(runtime.programFiles)')),"$env:ProgramFiles" `
	                -replace ([Regex]::Escape('$(runtime.commonFiles)')),"$env:CommonProgramFiles" -replace ([Regex]::Escape('$(runtime.wbem)')),"$env:systemroot\\system32\\wbem" 
                    }
                    if ( ($Xml.assembly.assemblyIdentity.processorArchitecture -eq 'wow64' -and $value.Value ) -or  ($Xml.assembly.assemblyIdentity.processorArchitecture -eq 'x86' -and $value.Value ) ) {            
                        $value.Value = $value.Value -replace ([Regex]::Escape('$(runtime.system32)')),"$env:systemroot\\syswow64" -replace ([Regex]::Escape('$(runtime.programFiles)')),"${env:ProgramFiles`(x86`)}" `
	                -replace ([Regex]::Escape('$(runtime.commonFiles)')),"${env:CommonProgramFiles`(x86`)}" -replace ([Regex]::Escape('$(runtime.wbem)')),"$env:systemroot\\syswow64\\wbem"
                    }	   

                   if( $value.Value ) { $value.Value = $value.Value -replace ([Regex]::Escape('$(runtime.windows)')),"$env:systemroot" -replace ([Regex]::Escape('$(runtime.inf)')),"$env:systemroot\\inf" }

                   if(!$to_file) { $null = New-ItemProperty -Path $path -Name $Regname -Value $value.Value -PropertyType $propertyType -Force -ErrorAction SilentlyContinue }  #-Verbose
                   else { '$v=''' + $path +''';if(!(Test-Path $v )) {New-Item -Path $v -Force}; New-ItemProperty -Path $v -Name ''' + $Regname + ''' -Value ''' + $value.Value +''' -PropertyType '''+ $propertyType + ''' -Force' |out-file "$env:TEMP\reg_keys.ps1" -append } #-Verbose
                } 
            }
        }
        }
} <# end write_keys_from_manifest #>

<# FIXME, very fragile!!! / bogus parts!!! / bugs!!! #>
function install_from_manifest ( [parameter(position=0)] [string] $manifestfile, [parameter(position=1)] [string] $file , [parameter(position=2)] [string] $prefix) { <# installs files to systemdirs using info from manifestfile #>



    $Xml = [xml](Get-Content -Path $manifestfile )
    if($file) { $file_names= $Xml.assembly.file | Where-Object -Property name -eq -Value $(([System.IO.FileInfo]$file).Name) }
    else      { $file_names= $Xml.assembly.file | Where-Object -Property name }

    if ($file_names.destinationpath) {
        foreach ($destpath in $file_names.destinationpath ) { 
            if ($destpath) { <# FIXME what to do with "msil" which has a destinationpath? Below might not be correct #>
                if ( ($Xml.assembly.assemblyIdentity.processorArchitecture -eq 'amd64') -or ($Xml.assembly.assemblyIdentity.processorArchitecture -eq 'msil') ) {
                    $finalpath = $destpath -replace ([Regex]::Escape('$(runtime.system32)')),"$env:systemroot\\system32" -replace ([Regex]::Escape('$(runtime.programFiles)')),"$env:ProgramFiles" `
	            -replace ([Regex]::Escape('$(runtime.wbem)')),"$env:systemroot\\system32\\wbem" -replace ([Regex]::Escape('$(runtime.commonFiles)')),"$env:CommonProgramFiles"
                }

                if ( ($Xml.assembly.assemblyIdentity.processorArchitecture -eq 'wow64') -or  ($Xml.assembly.assemblyIdentity.processorArchitecture -eq 'x86') ) {
                    $finalpath = $destpath -replace ([Regex]::Escape('$(runtime.system32)')),"$env:systemroot\\syswow64" -replace ([Regex]::Escape('$(runtime.programFiles)')),"${env:ProgramFiles`(x86`)}" `
                    -replace ([Regex]::Escape('$(runtime.wbem)')),"$env:systemroot\\syswow64\\wbem" -replace ([Regex]::Escape('$(runtime.commonFiles)')),"${env:CommonProgramFiles`(x86`)}"
                }

                $finalpath = $finalpath -replace ([Regex]::Escape('$(runtime.windows)')),"$env:systemroot" -replace ([Regex]::Escape('$(runtime.inf)')),"$env:systemroot\\inf"

                if($prefix) {$finalpath = join-path $prefix $finalpath}######

                if (-not (Test-Path -Path $finalpath )) { New-Item -Path $finalpath -ItemType directory -Force }
                if($file) {
                    Copy-Item -Path $($manifestfile.Replace('.manifest','\') +  $(([System.IO.FileInfo]$file).Name) ) -Destination $finalpath -Force -verbose #-ErrorAction SilentlyContinue  
                }
                else {
                    Copy-Item -Path $($manifestfile.Replace('.manifest','\') + '*' ) -Destination $finalpath -Force -verbose #-ErrorAction SilentlyContinue  
                }
            } 
        }
    ############  Also copy 'links' #########################

        if ($Xml.assembly.file.link) {
            foreach ($destpath in $Xml.assembly.file.link.destination){

                if ( ($Xml.assembly.assemblyIdentity.processorArchitecture -eq 'amd64') -or ($Xml.assembly.assemblyIdentity.processorArchitecture -eq 'msil') ) {
                    $finalpath = $destpath -replace ([Regex]::Escape('$(runtime.system32)')),"$env:systemroot\\system32" -replace ([Regex]::Escape('$(runtime.programFiles)')),"$env:ProgramFiles" `
                    -replace ([Regex]::Escape('$(runtime.wbem)')),"$env:systemroot\\system32\\wbem" -replace ([Regex]::Escape('$(runtime.commonFiles)')),"$env:CommonProgramFiles"
                }

                if ( ($Xml.assembly.assemblyIdentity.processorArchitecture -eq 'wow64') -or  ($Xml.assembly.assemblyIdentity.processorArchitecture -eq 'x86') ) {
                    $finalpath = $destpath -replace ([Regex]::Escape('$(runtime.system32)')),"$env:systemroot\\syswow64" -replace ([Regex]::Escape('$(runtime.programFiles)')),"${env:ProgramFiles`(x86`)}" `
		                           -replace ([Regex]::Escape('$(runtime.wbem)')),"$env:systemroot\\syswow64\\wbem" -replace ([Regex]::Escape('$(runtime.commonFiles)')),"${env:CommonProgramFiles`(x86`)}" `
                }

                $finalpath = $finalpath -replace ([Regex]::Escape('$(runtime.windows)')),"$env:systemroot" -replace ([Regex]::Escape('$(runtime.inf)')),"$env:systemroot\\inf"

                if($prefix) {$finalpath = join-path $prefix $finalpath}######

                if (-not (Test-Path -Path ([system.io.fileinfo]$finalpath).DirectoryName )) { New-Item -Path ([system.io.fileinfo]$finalpath).DirectoryName -ItemType directory -Force }

                Copy-Item -Path $($manifestfile.Replace('.manifest','\') + ([system.io.fileinfo]$finalpath).Name<#$Xml.assembly.file.name?'*'#>) -Destination $finalpath -Force -verbose

            }
    ############  End copy links #########################
        }
    }
        elseif ( $Xml.assembly.assemblyIdentity.processorArchitecture -eq 'msil' -and -not $file_names.destinationpath) {
                if( ([system.io.fileinfo]$file).Extension -eq '.config' ) { $dummy = $($file -replace '.config' , '.dll') } else {$dummy = $file}
                 $finalpath = "$env:systemroot\Microsoft.NET\assembly\GAC_MSIL\" + "$($Xml.assembly.assemblyIdentity.name)\" + "v4.0_" + "$([System.Reflection.AssemblyName]::GetAssemblyName($dummy).Version.ToString())" + "__" + "$($Xml.assembly.assemblyIdentity.publicKeyToken)\"
                 if($prefix) {$finalpath = join-path $prefix $finalpath}######
                 
                if (-not (Test-Path -Path $finalpath )) { New-Item -Path $finalpath -ItemType directory -Force }
                Copy-Item -Path $file -Destination $finalpath -Force  -verbose # -ErrorAction SilentlyContinue 
        }        
        elseif ( $Xml.assembly.assemblyIdentity.processorArchitecture -eq 'amd64' -and -not $file_names.destinationpath) { # no destinationpath, put it in GAC_64
        if($file) {
        if( ([system.io.fileinfo]$file).Extension -eq '.config' ) { $dummy = $($file -replace '.config' , '.dll') } else {$dummy = $file}
            $finalpath = "$env:systemroot\Microsoft.NET\assembly\GAC_64\" + "$($Xml.assembly.assemblyIdentity.name)\" + "v4.0_" + "$([System.Reflection.AssemblyName]::GetAssemblyName($dummy).Version.ToString())" + "__" + "$($Xml.assembly.assemblyIdentity.publicKeyToken)\"
            if($prefix) {$finalpath = join-path $prefix $finalpath};                if (-not (Test-Path -Path $finalpath )) { New-Item -Path $finalpath -ItemType directory -Force }######
            Copy-Item -Path $file -Destination $finalpath -Force  -verbose} # -ErrorAction SilentlyContinue 
        }
        elseif ( $Xml.assembly.assemblyIdentity.processorArchitecture -eq 'x86' -and -not $file_names.destinationpath) { # no destinationpath, put it in GAC_64
       if($file) {
       if( ([system.io.fileinfo]$file).Extension -eq '.config' ) { $dummy = $($file -replace '.config' , '.dll') } else {$dummy = $file}
            $finalpath = "$env:systemroot\Microsoft.NET\assembly\GAC_32\" + "$($Xml.assembly.assemblyIdentity.name)\" + "v4.0_" + "$([System.Reflection.AssemblyName]::GetAssemblyName($dummy).Version.ToString())" + "__" + "$($Xml.assembly.assemblyIdentity.publicKeyToken)\"
            if($prefix) {$finalpath = join-path $prefix $finalpath};                if (-not (Test-Path -Path $finalpath )) { New-Item -Path $finalpath -ItemType directory -Force }
######
            Copy-Item -Path $file -Destination $finalpath -Force  -verbose } #-ErrorAction SilentlyContinue 
        }
        else { if($file) { Write-Host -foregroundcolor yellow "***  No way found to install the file, copy it manually from location $file  ***" } else {Write-Host $null}<#FIXME#>}
} <# end function install_from_manifest #>

function func_dotnet481_deprecated
{
    if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $(verb),  "$(verb).7z" ) ) ){

    w_download_to $(verb) "https://download.visualstudio.microsoft.com/download/pr/6f083c7e-bd40-44d4-9e3f-ffba71ec8b09/3951fd5af6098f2c7e8ff5c331a0679c/ndp481-x86-x64-allos-enu.exe" "ndp481-x86-x64-allos-enu.exe" 
    7z x $cachedir\\$(verb)\\ndp481-x86-x64-allos-enu.exe "-o$env:TEMP\\$(verb)\\" "x64-Windows10.0-KB5011048-x64.cab" -y; quit?(7z)
    7z x $env:TEMP\\$(verb)\\x64-Windows10.0-KB5011048-x64.cab "-o$env:TEMP\\$(verb)\\" "amd64*/*" "x86*/*" "wow64*/*" "*.manifest" -y; quit?(7z)

    Stop-Process -Name mscorsvw -ErrorAction SilentlyContinue <# otherwise some dlls fail to be replaced as they are in use by mscorvw; only mscoreei.dll has to be copied manually afaict as it is in use by pwsh #>

    Remove-Item -force   "$env:TEMP\reg_keys.ps1" -erroraction silentlycontinue 

    Write-Host -foregroundColor yellow 'Starting copying files , this takes a while (> 3 minutes), patience...'    
    foreach ($i in $(Get-ChildItem $env:TEMP\\dotnet481\\*.manifest).FullName) { install_from_manifest -manifestfile $i -prefix "$env:TEMP\$(verb)"  }

    foreach ($i in $(Get-ChildItem $env:TEMP\\dotnet481\\*.manifest).FullName ) { write_keys_from_manifest $i -to_file }
   
    #find out compression flags: 7z l -slt ~/.cache/winetrickxs/dotnet481/dotnet481.7z | grep -e '^---' -e '^Path =' -e '^Method ='^C
   
    Push-Location ; Set-Location "$env:TEMP\$(verb)"
    7z a -m0=BCJ2   -m1=LZMA:29:lc8:pb1 -m2=LZMA:24 -m3=LZMA:24 -mx=9  -ms=on  "$cachedir\$(verb)\$(verb).7z" ".\c:\"; quit?(7z)
    Pop-Location

    (Get-Content "$env:TEMP\reg_keys.ps1") | Foreach-Object {$_ -replace 'HKEY_', 'HKEY_LOCAL_MACHINE\HKEY_'} | Set-Content "$env:TEMP\reg_keys_tmp.ps1"
    Write-Host -foregroundColor yellow 'Writing registry keys to temporary file, patience please...' 
    $null =  . "$env:TEMP\reg_keys_tmp.ps1"
    reg.exe EXPORT 'HKEY_LOCAL_MACHINE\HKEY_LOCAL_MACHINE' "$env:TEMP\reg_keys_hklm.ps1" /y
    reg.exe EXPORT 'HKEY_LOCAL_MACHINE\HKEY_CLASSES_ROOT' "$env:TEMP\reg_keys_hkcr.ps1" /y  
    (Get-Content "$env:TEMP\reg_keys_hklm.ps1") | Foreach-Object {$_ -replace ([Regex]::Escape('[HKEY_LOCAL_MACHINE\HKEY')) ,'[HKEY'} | Set-Content "$env:TEMP\reg_keys_hklm_def.ps1"
    (Get-Content "$env:TEMP\reg_keys_hkcr.ps1") | Foreach-Object {$_ -replace ([Regex]::Escape('[HKEY_LOCAL_MACHINE\HKEY')) ,'[HKEY'} | Set-Content "$env:TEMP\reg_keys_hkcr_def.ps1"

    Push-Location ; Set-Location "$env:TEMP\$(verb)"    
    7z a -spf -m0=BCJ2   -m1=LZMA:29:lc8:pb1 -m2=LZMA:24 -m3=LZMA:24 -mx=9  -ms=on  "$cachedir\$(verb)\$(verb).7z" "$env:TEMP\reg_keys_hklm_def.ps1"  "$env:TEMP\reg_keys_hkcr_def.ps1" ; quit?(7z)
    Pop-Location

    reg.exe DELETE 'HKEY_LOCAL_MACHINE\HKEY_LOCAL_MACHINE' /f
    reg.exe DELETE 'HKEY_LOCAL_MACHINE\HKEY_CLASSES_ROOT' /f
     
    Remove-Item -Force -Recurse "$env:TEMP\$(verb)"
    Remove-Item -Force "$cachedir\\$(verb)\\ndp481-x86-x64-allos-enu.exe"
    }  
        $sourcefile = @(
   'C:\windows\Microsoft.NET\assembly\GAC_MSIL\System\v4.0_4.0.0.0__b77a5c561934e089\System.dll',
 'C:\windows\Microsoft.NET\assembly\GAC_MSIL\System.Core\v4.0_4.0.0.0__b77a5c561934e089\System.Core.dll',
 'C:\windows\Microsoft.NET\Framework64\v4.0.30319\clr.dll',
 'C:\windows\Microsoft.NET\Framework64\v4.0.30319\clrjit.dll',
'C:\windows\Microsoft.NET\Framework64\v4.0.30319\mscoreei.dll',
'C:\windows\system32\ucrtbase_clr0400.dll',
 'C:\windows\system32\vcruntime140_clr0400.dll'
)
    foreach($i in $sourcefile){
   # Remove-Item $i -force -erroraction silentlycontinue
    #    7z e "$cachedir\$(verb)\$(verb).7z" -o"$env:TEMP" $i -aoa
        #Move-Item "$env:TEMP\$(([System.IO.FileInfo]$i).Name)" $i -force -verbose
     }
    
  
    & "$env:ProgramFiles\7-Zip\7z.exe" x -spf "$cachedir\$(verb)\$(verb).7z" -aoa 
    Write-Host -foregroundColor yellow 'Writing registry keys , patience please...' 
    #$null =  . "$env:TEMP\reg_keys.ps1"

    reg.exe IMPORT "$env:TEMP\reg_keys_hklm_def.ps1"
    reg.exe IMPORT "$env:TEMP\reg_keys_hkcr_def.ps1"

    Write-Host -foregroundColor yellow 'Done , hopefully nothing''s screwed up ;)' 
    
    <# FIXME:  mscoreei.dll is not installed as it is in use by pwsh.exe #>
    #Start-Process -FilePath $env:SystemRoot\\Microsoft.NET\\Framework64\\v4.0.3031\\ngen.exe -NoNewWindow -ArgumentList "eqi"
    #Start-Process -FilePath $env:SystemRoot\\Microsoft.NET\\Framework\\v4.0.3031\\ngen.exe -NoNewWindow -ArgumentList "eqi"
} <# end dotnet481 #>

function func_dotnet481
{   
    if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $(verb),  "$(verb).7z" ) ) ){

    w_download_to $(verb) "https://download.visualstudio.microsoft.com/download/pr/6f083c7e-bd40-44d4-9e3f-ffba71ec8b09/3951fd5af6098f2c7e8ff5c331a0679c/ndp481-x86-x64-allos-enu.exe" "ndp481-x86-x64-allos-enu.exe" 
    7z x $cachedir\\$(verb)\\ndp481-x86-x64-allos-enu.exe "-o$env:TEMP\\$(verb)\\" "x64-Windows10.0-KB5011048-x64.cab" -y; quit?(7z)
    7z x $env:TEMP\\$(verb)\\x64-Windows10.0-KB5011048-x64.cab "-o$env:TEMP\\$(verb)\\" "amd64*/*" "x86*/*" "wow64*/*" "*.manifest" -y; quit?(7z)

    Stop-Process -Name mscorsvw -ErrorAction SilentlyContinue <# otherwise some dlls fail to be replaced as they are in use by mscorvw; only mscoreei.dll has to be copied manually afaict as it is in use by pwsh #>

    Write-Host -foregroundColor yellow 'Starting copying files , this takes a while (> 3 minutes), patience...'    
    foreach ($i in $(Get-ChildItem $env:TEMP\\$(verb)\\*.manifest).FullName) { install_from_manifest -manifestfile $i -prefix "$env:TEMP\$(verb)"  }

    foreach ($i in $(Get-ChildItem $env:TEMP\\$(verb)\\*.manifest).FullName ) { write_keys_from_manifest_tofile $i -todir "$env:TEMP\$(verb)\c:\windows\temp"}

    Push-Location ; Set-Location "$env:TEMP\$(verb)"
    & "$env:ProgramFiles\7-Zip\7z.exe" a -m0=BCJ2   -m1=LZMA:29:lc8:pb1 -m2=LZMA:24 -m3=LZMA:24 -mx=9  -ms=on  "$cachedir\$(verb)\$(verb).7z" ".\c:\"; quit?(7z)

    7z a "$cachedir\$(verb)\$(verb).7z" "C:\users\louis\AppData\Local\Temp\dotnet481\C:\windows\Microsoft.NET\Framework64\v4.0.30319\mscoreei.dll"
    Pop-Location

    Remove-Item -Force -Recurse "$env:TEMP\$(verb)"
    }   
    
    & "$env:ProgramFiles\7-Zip\7z.exe"  x -spf "$cachedir\$(verb)\$(verb).7z" -aoa <# do not use shimmed 7z here, then overwriting several dlls wil fail #> 

    Write-Host -foregroundColor yellow 'Replacing mscoreei...'

    remove-item "C:\windows\Microsoft.NET\Framework64\v4.0.30319\mscoreei_old.dll" -force -erroraction silentlycontinue -verbose

    Rename-Item  "C:\windows\Microsoft.NET\Framework64\v4.0.30319\mscoreei.dll" "C:\windows\Microsoft.NET\Framework64\v4.0.30319\mscoreei_old.dll" -Force -Verbose

    Move-Item "$env:systemdrive\mscoreei.dll" "$env:systemroot\Microsoft.NET\Framework64\v4.0.30319\mscoreei.dll" -verbose -force

    Write-Host -foregroundColor yellow 'Writing registry keys , patience please...' 

    reg.exe IMPORT "c:\windows\temp\reg_keys64.ps1" /reg:64 ; Remove-Item -Force "c:\windows\temp\reg_keys64.ps1"
    reg.exe IMPORT "c:\windows\temp\reg_keys32.ps1" /reg:32 ; Remove-Item -Force "c:\windows\temp\reg_keys32.ps1"
    
    Write-Host -foregroundColor yellow 'Done , hopefully nothing''s screwed up ;)'     <# FIXME:  mscoreei.dll is not installed as it is in use by pwsh.exe #>
    #Start-Process -FilePath $env:SystemRoot\\Microsoft.NET\\Framework64\\v4.0.3031\\ngen.exe -NoNewWindow -ArgumentList "eqi"
    #Start-Process -FilePath $env:SystemRoot\\Microsoft.NET\\Framework\\v4.0.3031\\ngen.exe -NoNewWindow -ArgumentList "eqi"
} <# end dotnet481 #>


function func_install_dll_from_msu
{
    func_expand
    <# Unfortunately we need another huge download as we need newer version of dpx.dll and msdelta.dll, otherwise several msu files fail to extract #>
     
    #https://4sysops.com/archives/how-to-create-an-open-file-folder-dialog-box-with-powershell/
    try{ $null=[System.Reflection.Assembly]::GetAssembly([System.Windows.Forms]) }
    catch { [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null }
    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
    InitialDirectory = [Environment]::GetFolderPath('Desktop')
    Filter = 'msu files (*.msu)|*.msu'
    Title = 'Select an msu file' }
    if ( $FileBrowser.ShowDialog() -eq 'Cancel' ) {exit}
    $dest = $(ls $FileBrowser.FileName).BaseName

    7z x "-x!WSUSSCAN.cab" $FileBrowser.FileName "-o$env:TEMP\\$dest"-aoa; quit?(7z)

    $custom_array = New-Object System.Collections.ArrayList

    foreach($i in "$(ls $env:TEMP\\$dest\\*.cab)") {
        if( $( & $expand_exe -d $i ) |select-string 'cabinet.cablist.ini') {# newer msu's apparently contain several cabs, so need another trip around for extraction  
            7z x $i "-x!WSUSSCAN.cab" "-o$env:TEMP\\$dest" -aoa 
            Move-Item $i $i.Replace('.cab','.1cab')
        }
    }
    quit?(7z)
    
    Write-Host -ForegroundColor green '****************************************************************'
    Write-Host -ForegroundColor green '*   Patience please! Getting list of files takes a while!      *'
    Write-Host -ForegroundColor green '****************************************************************'

     $out = $( & $expand_exe -d $env:TEMP\\$dest\\*.cab )
     foreach ( $j in ($out |select-string -notMatch '.manifest', '.cat', '.mum').Line  |Sort-Object  -Unique ) { 
         $custom_array.Add(@{ name = $j }) > $null 
     }
   
    <# create the selection dialog #>
    $result = ($custom_array  | select name | Out-GridView  -PassThru  -Title 'Make a  selection')

    foreach ($i in $result) { #https://stackoverflow.com/questions/8097354/how-do-i-capture-the-output-into-a-variable-from-an-external-process-in-powershe/35980675
        [array]$verboseoutput = $( & $expand_exe $i.Name.Split(': ')[0] -F:$i.Name.Split(': ')[1] "$env:TEMP\\$dest") 
        foreach($n in $verboseoutput) { if($n -match 'Queue') {[array]$output += $n + " from $($i.Name.Split(': ')[0])" } } 
    }
    $output

    foreach($j in $output  ) {
        $file = [System.IO.FileInfo]$j.Split(' ')[1]
        $manifestfile = $file.DirectoryName.Split('\')[-1] + '.manifest'
        [array]$verbosemanifestoutput += $(& $expand_exe $j.Split('from ')[-1] -F:$manifestfile "$env:TEMP\\$dest") 
    }

    foreach($n in $verbosemanifestoutput ) { if($n -match 'Queue') {[array]$verbose += $n}} 
    $verbose

    for($n=0 ; $n -lt $output.count; $n++) {
        install_from_manifest $($([System.IO.FileInfo]$verbose[$n].Split(' ')[1]).FullName) $([System.IO.FileInfo]$output[$n].Split(' ')[1]).FullName
        write_keys_from_manifest $($([System.IO.FileInfo]$verbose[$n].Split(' ')[1]).FullName)
    }
    
    Remove-Item -force  $env:TEMP\\$dest\\*.cab; Remove-Item -force  $env:TEMP\\$dest\\*.1cab
}

function func_affinity_requirements
{
if( [System.Convert]::ToDecimal( ($ntdll::wine_get_version() -replace '-rc','' ) ) -lt 8.15 ) { 
    Add-Type -AssemblyName System.Windows.Forms
    $result = [System.Windows.Forms.MessageBox]::Show("Use latest wine release (>8.15), this verb is not compatible with older wine-versions" , "Info" , 'OK',48)
    return
}

winecfg /v win11
func_renderer=vulkan
func_winmetadata
func_wine_wintypes
}

function func_webview2
{
#foreach($i in 'wldp') { dlloverride 'disabled' $i }
#winecfg /v win7
choco install webview2-runtime  --ignore-checksums
#foreach($i in 'wldp') { dlloverride 'builtin' $i }
}

function func_use_chromium_as_browser { <# replace winebrowser with chrome to open webpages #>
if (!([System.IO.File]::Exists("$env:ProgramFiles\Chromium\Application\Chrome.exe"))){ choco install chromium}

@"
REGEDIT4
[HKEY_CLASSES_ROOT\https\shell\open\command]
@="\"%ProgramFiles%\\Chromium\\Application\\chrome.exe\"  \"%1\""
[HKEY_CLASSES_ROOT\http\shell\open\command]
@="\"%ProgramFiles%\\Chromium\\Application\\chrome.exe\"  \"%1\""
"@ | Out-File -FilePath $env:TEMP\\regkey.reg
    reg.exe  IMPORT  $env:TEMP\\regkey.reg /reg:64;
    reg.exe  IMPORT  $env:TEMP\\regkey.reg /reg:32;
}

function func_GE-proton{

w_download_to "$cachedir\\$(verb)" "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton9-13/GE-Proton9-13.tar.gz" "GE-Proton9-13.tar.gz"
7z x "$cachedir\\$(verb)\\GE-Proton9-13.tar.gz" -so |7z x -aoa -si -ttar -o"$env:TMP" "GE-Proton9-13/files/lib/wine" "GE-Proton9-13/files/lib64/wine"  "GE-Proton9-13/files/lib/vkd3d" "GE-Proton9-13/files/lib64/vkd3d"  

#foreach($i in 'd3d12','' )

Copy-item "$env:TMP\\GE-Proton9-13/files/lib64/vkd3d/*" "$env:systemroot/system32/" -force
Copy-item "$env:TMP\\GE-Proton9-13/files/lib/vkd3d/*" "$env:systemroot/syswow64/" -force


Copy-item "$env:TMP\\GE-Proton9-13/files/lib64/wine/vkd3d-proton/*" "$env:systemroot/system32/" -force
Copy-item "$env:TMP\\GE-Proton9-13/files/lib/wine/vkd3d-proton/*" "$env:systemroot/syswow64/" -force

Copy-item "$env:TMP\\GE-Proton9-13/files/lib64/wine/dxvk/*" "$env:systemroot/system32/" -force
Copy-item "$env:TMP\\GE-Proton9-13/files/lib/wine/dxvk/*" "$env:systemroot/syswow64/" -force

Copy-item "$env:TMP\\GE-Proton9-13/files/lib64/wine/nvapi/*" "$env:systemroot/system32/" -force
Copy-item "$env:TMP\\GE-Proton9-13/files/lib/wine/nvapi/*" "$env:systemroot/syswow64/" -force
}

function func_mspaint
{

wget2.exe -P "$env:TEMP\"  --referer 'https://win7games.com/' 'https://win7games.com/download/ClassicPaint.zip'

7z x "$env:TEMP\ClassicPaint.zip" "-o$env:TEMP"

quit?('7z')

& "$env:TEMP\ClassicPaint-1.1-setup.exe" /silent

func_mfc42
func_uiribbon
func_msxml3

7z e "$cachedir\aik70\F1_WINPE.WIM" "-o$env:ProgramFiles\Classic Paint" "Windows/winsxs/x86_microsoft-windows-shlwapi_31bf3856ad364e35_6.1.7600.16385_none_f9b00828060280bb/shlwapi.dll" -y 

w_download_to "wine_kernelbase" "https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/EXTRAS/wine_kernelbase.7z" "wine_kernelbase.7z"
7z e "$cachedir\\wine_kernelbase\\wine_kernelbase.7z" "-o$env:ProgramFiles\Classic Paint" "32/kernelbase.dll" -aoa 
        
if(!(Test-Path "HKCU:\\Software\\Wine\\AppDefaults\\mspaint1.exe")) {New-Item  -Path "HKCU:\\Software\\Wine\\AppDefaults\\mspaint1.exe"}
if(!(Test-Path "HKCU:\\Software\\Wine\\AppDefaults\\mspaint1.exe\\DllOverrides")) {New-Item  -Path "HKCU:\\Software\\Wine\\AppDefaults\\mspaint1.exe\\DllOverrides"}
New-ItemProperty -Path "HKCU:\\Software\\Wine\\AppDefaults\\mspaint1.exe\\DllOverrides" -Name "kernelbase" -Value 'native,builtin' -PropertyType 'String' -force
New-ItemProperty -Path "HKCU:\\Software\\Wine\\AppDefaults\\mspaint1.exe\\DllOverrides" -Name "shlwapi" -Value 'native,builtin' -PropertyType 'String' -force
}

function func_winrt_hacks
{func_wine_api-ms-win-appmodel-state-l1-2-0;return
    func_wine_combase
    func_wine_wintypes
    func_winmetadata
    func_dotnet481
    func_xmllite
    func_windows.ui.xaml
    func_wine_api-ms-win-appmodel-state-l1-2-0    
}

function func_chocolatey_upgrade
{
    func_ps51
    choco pin remove -n chocolatey
    choco.exe feature enable --name=powershellHost
    choco upgrade chocolatey    
}

function func_mdac28
{
if (![System.IO.File]::Exists("$cachedir\\$(verb)\\MDAC_TYP.EXE")) {

choco install wget

wget2.exe -P "$cachedir\\$(verb)" "https://web.archive.org/web/20070127061938/https://download.microsoft.com/download/4/a/a/4aafff19-9d21-4d35-ae81-02c48dcbbbff/MDAC_TYP.EXE"

}
winecfg /v win2k

start-process "$cachedir\\$(verb)\\MDAC_TYP.EXE" -argumentlist '/q /C:"setup /q"'

quit?('mdac_typ'); quit?('setup');quit?('dasetup'); quit?('odbcconf');
winecfg /v win10

foreach ($i in 'mtxdm' ,'odbc32', 'oledb32', 'msdasql', 'odbccp32', 'msado15') { dlloverride 'native,builtin' $i }    
}

function func_mdac_deprecated_win7
{
    check_aik_sanity;
    
    if (![System.IO.File]::Exists("$cachedir\\$(verb)\\$(verb).7z")) {
    
    7z x $cachedir\\aik70\\F_WINPEOC_AMD64__WINPE_WINPE_MDAC.CAB "-o$env:TEMP\\$(verb)\\"  -y; 
    7z x $cachedir\\aik70\\F_WINPEOC_X86__WINPE_WINPE_MDAC.CAB "-o$env:TEMP\\$(verb)\\"  -y; quit?(7z)
    
    Remove-Item -force   "$env:TEMP\reg_keys.ps1" -erroraction silentlycontinue 

    Write-Host -foregroundColor yellow 'Starting copying files , this takes a while (> 3 minutes), patience...'    
    foreach ($i in $(Get-ChildItem $env:TEMP\\$(verb)\\*.manifest).FullName) { install_from_manifest -manifestfile $i -prefix "$env:TEMP\$(verb)"  }

    foreach ($i in $(Get-ChildItem $env:TEMP\\$(verb)\\*.manifest).FullName ) { write_keys_from_manifest $i -to_file }
   
    Push-Location ; Set-Location "$env:TEMP\$(verb)"
    7z a -m0=BCJ2   -m1=LZMA:29:lc8:pb1 -m2=LZMA:24 -m3=LZMA:24 -mx=9  -ms=on  "$cachedir\$(verb)\$(verb).7z" ".\c:\"; quit?(7z)
    Pop-Location

    (Get-Content "$env:TEMP\reg_keys.ps1") | Foreach-Object {$_ -replace 'HKEY_', 'HKEY_LOCAL_MACHINE\HKEY_'} | Set-Content "$env:TEMP\reg_keys_tmp.ps1"
    Write-Host -foregroundColor yellow 'Writing registry keys to temporary file, patience please...' 
    $null =  . "$env:TEMP\reg_keys_tmp.ps1" 
    reg.exe EXPORT 'HKEY_LOCAL_MACHINE\HKEY_LOCAL_MACHINE' "$env:TEMP\reg_keys_hklm.ps1" /y
    reg.exe EXPORT 'HKEY_LOCAL_MACHINE\HKEY_CLASSES_ROOT' "$env:TEMP\reg_keys_hkcr.ps1" /y  
    (Get-Content "$env:TEMP\reg_keys_hklm.ps1") | Foreach-Object {$_ -replace ([Regex]::Escape('[HKEY_LOCAL_MACHINE\HKEY')) ,'[HKEY'} | Set-Content "$env:TEMP\reg_keys_hklm_def.ps1"
    (Get-Content "$env:TEMP\reg_keys_hkcr.ps1") | Foreach-Object {$_ -replace ([Regex]::Escape('[HKEY_LOCAL_MACHINE\HKEY')) ,'[HKEY'} | Set-Content "$env:TEMP\reg_keys_hkcr_def.ps1"

    Push-Location ; Set-Location "$env:TEMP\$(verb)"    
    7z a -spf -m0=BCJ2   -m1=LZMA:29:lc8:pb1 -m2=LZMA:24 -m3=LZMA:24 -mx=9  -ms=on  "$cachedir\$(verb)\$(verb).7z" "$env:TEMP\reg_keys_hklm_def.ps1"  "$env:TEMP\reg_keys_hkcr_def.ps1" ; quit?(7z)
    Pop-Location

    reg.exe DELETE 'HKEY_LOCAL_MACHINE\HKEY_LOCAL_MACHINE' /f
    reg.exe DELETE 'HKEY_LOCAL_MACHINE\HKEY_CLASSES_ROOT' /f
     
    Remove-Item -Force -Recurse "$env:TEMP\$(verb)"

    }   
    
    & "$env:ProgramFiles\7-Zip\7z.exe" x -spf "$cachedir\$(verb)\$(verb).7z" -aoa 
    Write-Host -foregroundColor yellow 'Writing registry keys , patience please...' 
    #$null =  . "$env:TEMP\reg_keys.ps1"

    reg.exe IMPORT "$env:TEMP\reg_keys_hklm_def.ps1"
    reg.exe IMPORT "$env:TEMP\reg_keys_hkcr_def.ps1"

    foreach ($i in 'mtxdm' ,'odbc32', 'oledb32', 'msdasql', 'odbccp32', 'msado15') { dlloverride 'native,builtin' $i }  

    Write-Host -foregroundColor yellow 'Done , hopefully nothing''s screwed up ;)' 
}

function func_mdac_win7
{
    check_aik_sanity;
    
    if (![System.IO.File]::Exists("$cachedir\\$(verb)\\$(verb).7z")) {
    
    7z x $cachedir\\aik70\\F_WINPEOC_AMD64__WINPE_WINPE_MDAC.CAB "-o$env:TEMP\\$(verb)\\"  -y; 
    7z x $cachedir\\aik70\\F_WINPEOC_X86__WINPE_WINPE_MDAC.CAB "-o$env:TEMP\\$(verb)\\"  -y; quit?(7z)

    Write-Host -foregroundColor yellow 'Starting copying files , this takes a while (> 3 minutes), patience...'    
    foreach ($i in $(Get-ChildItem $env:TEMP\\$(verb)\\*.manifest).FullName) { install_from_manifest -manifestfile $i -prefix "$env:TEMP\$(verb)"  }

    foreach ($i in $(Get-ChildItem $env:TEMP\\$(verb)\\*.manifest).FullName ) { write_keys_from_manifest_tofile $i -todir "$env:TEMP\$(verb)\c:\windows\temp"}
   
    Push-Location ; Set-Location "$env:TEMP\$(verb)"
    7z a -m0=BCJ2   -m1=LZMA:29:lc8:pb1 -m2=LZMA:24 -m3=LZMA:24 -mx=9  -ms=on  "$cachedir\$(verb)\$(verb).7z" ".\c:\"; quit?(7z)
    Pop-Location

    Remove-Item -Force -Recurse "$env:TEMP\$(verb)"
    }   
    
    & "$env:ProgramFiles\7-Zip\7z.exe" x -spf "$cachedir\$(verb)\$(verb).7z" -aoa 
    Write-Host -foregroundColor yellow 'Writing registry keys , patience please...' 

    reg.exe IMPORT "c:\windows\temp\reg_keys64.ps1" /reg:64 ; Remove-Item -Force "c:\windows\temp\reg_keys64.ps1"
    reg.exe IMPORT "c:\windows\temp\reg_keys32.ps1" /reg:32 ; Remove-Item -Force "c:\windows\temp\reg_keys32.ps1"

    foreach ($i in 'mtxdm' ,'odbc32', 'oledb32', 'msdasql', 'odbccp32', 'msado15') { dlloverride 'native,builtin' $i }  
    
    Write-Host -foregroundColor yellow 'Done , hopefully nothing''s screwed up ;)' 
}

function func_wsh57
{
    check_aik_sanity;
    
    if (![System.IO.File]::Exists("$cachedir\\$(verb)\\$(verb).7z")) {
    
    7z x $cachedir\\aik70\\F_WINPEOC_AMD64__WINPE_WINPE_SCRIPTING.CAB "-o$env:TEMP\\$(verb)\\"  -y; 
    7z x $cachedir\\aik70\\F_WINPEOC_X86__WINPE_WINPE_SCRIPTING.CAB "-o$env:TEMP\\$(verb)\\"  -y; quit?(7z)

    Write-Host -foregroundColor yellow 'Starting copying files , this takes a while (> 3 minutes), patience...'    
    foreach ($i in $(Get-ChildItem $env:TEMP\\$(verb)\\*.manifest).FullName) { install_from_manifest -manifestfile $i -prefix "$env:TEMP\$(verb)"  }

    foreach ($i in $(Get-ChildItem $env:TEMP\\$(verb)\\*.manifest).FullName ) { write_keys_from_manifest_tofile $i -todir "$env:TEMP\$(verb)\c:\windows\temp"}
   
    Push-Location ; Set-Location "$env:TEMP\$(verb)"
    7z a -m0=BCJ2   -m1=LZMA:29:lc8:pb1 -m2=LZMA:24 -m3=LZMA:24 -mx=9  -ms=on  "$cachedir\$(verb)\$(verb).7z" ".\c:\"; quit?(7z)
    Pop-Location

    Remove-Item -Force -Recurse "$env:TEMP\$(verb)"
    }   
    
    & "$env:ProgramFiles\7-Zip\7z.exe" x -spf "$cachedir\$(verb)\$(verb).7z" -aoa 
    Write-Host -foregroundColor yellow 'Writing registry keys , patience please...' 

    reg.exe IMPORT "c:\windows\temp\reg_keys64.ps1" /reg:64 ; Remove-Item -Force "c:\windows\temp\reg_keys64.ps1"
    reg.exe IMPORT "c:\windows\temp\reg_keys32.ps1" /reg:32 ; Remove-Item -Force "c:\windows\temp\reg_keys32.ps1"

    foreach($i in 'dispex', 'jscript', 'scrobj', 'scrrun', 'vbscript', 'msscript.ocx', 'wshom.ocx', 'wscript.exe', 'cscript.exe') { dlloverride 'native' $i }
    
    Write-Host -foregroundColor yellow 'Done , hopefully nothing''s screwed up ;)' 
}

function write_keys_from_manifest_tofile([parameter(position=0)] [string] $manifest, [string] $todir){

    if (![System.IO.File]::Exists("$todir\reg_keys64.ps1")) { 
        New-Item -Path "$todir\reg_keys64.ps1" -Force; "Windows Registry Editor Version 5.00" | out-file "$todir\reg_keys64.ps1"}
    if (![System.IO.File]::Exists("$todir\reg_keys32.ps1")) {
        New-Item -Path "$todir\reg_keys32.ps1" -Force; "Windows Registry Editor Version 5.00" | out-file "$todir\reg_keys32.ps1"}

    $Xml = [xml](Get-Content -Path "$manifest")

    if( $Xml.assembly.registryKeys ) { #try write regkeys from manifest file, thanks some guy from freenode webchat channel powershell who wrote skeleton of this in 4 minutes...
 
        foreach ($key in $Xml.assembly.registryKeys.registryKey) {
            $path = '[{0}]' -f $key.keyName
    
            if ( ($Xml.assembly.assemblyIdentity.processorArchitecture -eq 'wow64') -or  ($Xml.assembly.assemblyIdentity.processorArchitecture -eq 'x86') ) { $arch = '32' }
	        else {$arch = '64'}
	
	        "`n"+$path  | out-file "$todir\reg_keys$arch.ps1" -append;
	        
            foreach ($value in $key.registryValue) {
                $propertyType = switch ($value.valueType) {
                    'REG_SZ'         { '' }
                    'REG_BINARY'     { 'hex:' }
                    'REG_DWORD'      { 'dword:'  }
	            'REG_EXPAND_SZ'  { 'hex(2):' } 
	            'REG_MULTI_SZ'   { '\MultiString'  } <# FIXME todo #>
	            'REG_QWORD'      { 'hex(b):' }
                    'REG_NONE'       { '' } 
                }

                $Regname = switch ($value.Name) {
                    '' { ‘@’ }
                    'registryValue' { ‘@’ } <#FIXME Bugs in script...#>
                    default { '"' + $value.Name + '"' }
                }
                
                    if ( $Xml.assembly.assemblyIdentity.processorArchitecture -eq 'amd64' -and $value.Value) {
                        $value.Value = $value.Value -replace ([Regex]::Escape('$(runtime.system32)')),"$env:systemroot\system32" -replace ([Regex]::Escape('$(runtime.programFiles)')),"$env:ProgramFiles" `
	                -replace ([Regex]::Escape('$(runtime.commonFiles)')),"$env:CommonProgramFiles" -replace ([Regex]::Escape('$(runtime.wbem)')),"$env:systemroot\system32\wbem" -replace ([Regex]::Escape('$(runtime.windows)')),"$env:systemroot" -replace ([Regex]::Escape('$(runtime.inf)')),"$env:systemroot\\inf" -replace '\\','\\'
                    }
                    if ( ($Xml.assembly.assemblyIdentity.processorArchitecture -eq 'wow64' -and $value.Value ) -or  ($Xml.assembly.assemblyIdentity.processorArchitecture -eq 'x86' -and $value.Value ) ) {            
                        $value.Value = $value.Value -replace ([Regex]::Escape('$(runtime.system32)')),"$env:systemroot\syswow64" -replace ([Regex]::Escape('$(runtime.programFiles)')),"${env:ProgramFiles`(x86`)}" `
	                -replace ([Regex]::Escape('$(runtime.commonFiles)')),"${env:CommonProgramFiles`(x86`)}" -replace ([Regex]::Escape('$(runtime.wbem)')),"$env:systemroot\syswow64\wbem" -replace ([Regex]::Escape('$(runtime.windows)')),"$env:systemroot" -replace ([Regex]::Escape('$(runtime.inf)')),"$env:systemroot\\inf" -replace '\\','\\'
                    }	   

                   $Regname = $Regname -replace ([Regex]::Escape('$(runtime.windows)')),"$env:systemroot" -replace '\\','\\' <# dotnet481 has regnames with $(runtime.windows)...#>

                   if(($value.valueType -eq 'REG_SZ') <#-or ($value.valueType -eq 'REG_EXPAND_SZ')#>) { $quote='"' } else { $quote='' }
                   if($value.valueType -eq 'REG_BINARY') { $value.value = ($value.value -split '(..)').Where({$_}) -join ',' }
                   if($value.valueType -eq 'REG_EXPAND_SZ') { $value.value = ([System.Text.Encoding]::ASCII.GetBytes($value.value +"`0")  -replace '\\','\\' |Format-Hex).HexBytes -replace ' ',',' }
                   if($value.valueType -eq 'REG_QWORD') { $value.value = ([int64]$value.value | Format-Hex).HexBytes -replace ' ',',' }

                   $Regname + '=' + $quote + $propertyType + $value.Value + $quote |out-file "$todir\reg_keys$arch.ps1" -append -Verbose
            }
        }
        }
} <# end write_keys_from_manifest #>

function func_mshtml
{
    check_aik_sanity;
    
    func_urlmon
    func_iertutil
    func_riched20 #for msls31/dll
    func_wsh_win7
    
    if (![System.IO.File]::Exists("$cachedir\\$(verb)\\$(verb).7z")) {
    
    7z x $cachedir\\aik70\\F_WINPEOC_AMD64__WINPE_WINPE_HTA.CAB "-o$env:TEMP\\$(verb)\\"  -y; 
    7z x $cachedir\\aik70\\F_WINPEOC_X86__WINPE_WINPE_HTA.CAB "-o$env:TEMP\\$(verb)\\"  -y; quit?(7z)

    Write-Host -foregroundColor yellow 'Starting copying files , this takes a while (> 3 minutes), patience...'    
    foreach ($i in $(Get-ChildItem $env:TEMP\\$(verb)\\*.manifest).FullName) { install_from_manifest -manifestfile $i -prefix "$env:TEMP\$(verb)"  }

    foreach ($i in $(Get-ChildItem $env:TEMP\\$(verb)\\*.manifest).FullName ) { write_keys_from_manifest_tofile $i -todir "$env:TEMP\$(verb)\c:\windows\temp"}
   
    Push-Location ; Set-Location "$env:TEMP\$(verb)"
    7z a -m0=BCJ2   -m1=LZMA:29:lc8:pb1 -m2=LZMA:24 -m3=LZMA:24 -mx=9  -ms=on  "$cachedir\$(verb)\$(verb).7z" ".\c:\"; quit?(7z)
    Pop-Location

    Remove-Item -Force -Recurse "$env:TEMP\$(verb)"
    }   
    
    7z x -spf "$cachedir\$(verb)\$(verb).7z" -aoa 
    Write-Host -foregroundColor yellow 'Writing registry keys , patience please...' 

    reg.exe IMPORT "c:\windows\temp\reg_keys64.ps1" /reg:64 ; Remove-Item -Force "c:\windows\temp\reg_keys64.ps1"
    reg.exe IMPORT "c:\windows\temp\reg_keys32.ps1" /reg:32 ; Remove-Item -Force "c:\windows\temp\reg_keys32.ps1"

    foreach($i in 'mshtml', 'ieframe', 'urlmon', 'iertutil') { dlloverride 'native' $i }
    foreach($i in 'msimtf') { dlloverride 'builtin' $i }
    
    Write-Host -foregroundColor yellow 'Done , hopefully nothing''s screwed up ;)' 
}

<# Main function #> 
if ( !$args) {
    $custom_array = @(); 
    for ( $j = 0; $j -lt $Qenu.count; $j+=3 ) { $custom_array += [PSCustomObject]@{ category = $Qenu[$j] ;name = $Qenu[$j+1]; Description = $Qenu[$j+2] } } 
    $args =  ($custom_array  | select category,name,description |Out-GridView  -PassThru  -Title 'Make a  selection').name
    }
if($args) {foreach ($i in $args -split ',') { & $('func_' + $i);  }
}
