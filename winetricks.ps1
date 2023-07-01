$cachedir = ("$env:WINEHOMEDIR" + "\.cache\winetrickxs").substring(4)

if (!(Test-Path -Path "$env:ProgramW6432\7-Zip\7z.exe" -PathType Leaf)) { choco install 7zip -y }

function validate_param
{
[CmdletBinding()]
 Param(
        [Parameter(Mandatory=$false)]
        [ValidateSet('msxml3', 'msxml6','gdiplus', 'mfc42', 'riched20', 'msado15', 'expand', 'wmp', 'ucrtbase', 'vcrun2019', 'mshtml', 'd2d1',`
                     'dxvk1103', 'dxvk20', 'hnetcfg', 'msi', 'wintrust', 'sapi', 'ps51', 'ps51_ise', 'crypt32', 'oleaut32', 'msvbvm60', 'xmllite', 'windows.ui.xaml', 'windowscodecs', 'uxtheme', 'comctl32', 'wsh57',`
                     'nocrashdialog', 'renderer=vulkan', 'renderer=gl', 'app_paths', 'vs19','sharpdx', 'dotnet35', 'dotnet481' ,'cef', 'd3dx','sspicli', 'dshow', 'findstr', 'affinity_requirements', 'winmetadata', 'wintypes', 'dxcore', 'install_dll_from_msu', 'wpf_xaml', 'wpf_msgbox', 'wpf_routedevents', 'embed-exe-in-psscript', 'vulkansamples', 'ps2exe')]
        [string[]]$verb
      )
}

try {validate_param $args}
catch [System.Management.Automation.ParameterBindingException] {Write-Host "Error: [$_.Exception.Message]" -ForegroundColor Red; exit}

$custom_array = @() # Creating an empty array to populate data in

[array]$Qenu = "gdiplus","GDI+, todo: check if this version works",`
               "msxml3","msxml3 + msxml3r",`
               "msxml6","msxml6 + msxml6r",`
               "mfc42","mfc42(u)",`
               "riched20","riched20",`
               "msado15","some minimal mdac dlls",`
               "expand", "native expand.exe, it's renamed to expnd_.exe to not interfere with wine's expand",`
               "wmp", "some wmp (windows media player) dlls, makes e-Sword start",`
               "ucrtbase", "ucrtbase from vcrun2015",`
               "vcrun2019", "vcredist2019",`
               "mshtml", "experimental, dangerzone, might break things, only use on a per app base",`
               "hnetcfg", "hnetcfg with fix for https://bugs.winehq.org/show_bug.cgi?id=45432",`
               "msi", "if an msi installer fails, might wanna try this msi, just faking success for a few actions... Might also result in broken installation ;)",`
               "wintrust", "wine wintrust faking success for WinVerifyTrust",`
               "dxvk1103", "dxvk 1.10.3, latest compatible with Kepler (Nvidia GT 470) ??? )",`
               "dxvk20", "dxvk 2.0",`
               "crypt32", "experimental, dangerzone, might break things, only use on a per app base",`
               "oleaut32", "experimental, dangerzone, will likely break things (!), only use on a per app base",`
               "sapi", "Speech api, experimental, makes Balabolka work",`
               "ps51", "rudimentary PowerShell 5.1 (downloads yet another huge amount of Mb`s!)",`
               "ps51_ise", "PowerShell 5.1 Integrated Scripting Environment",`
               "msvbvm60", "msvbvm60",`
               "xmllite", "xmllite",`
               "windowscodecs", "windowscodecs",`
               "uxtheme", "uxtheme",`
               "wsh57", "MS Windows Script Host",`
               "comctl32", "dangerzone, only for testing, might break things, only use on a per app base",`
               "d2d1", "dangerzone, only for testing, might break things, only use on a per app base",`
               "windows.ui.xaml", "windows.ui.xaml, experimental...",`
               "nocrashdialog", "Disable graphical crash dialog",`
               "renderer=vulkan", "renderer=vulkan",`
               "renderer=gl", "renderer=gl",`
               "app_paths", "start new shell with app paths added to the path (permanently), invoke from powershell console!",
               "vs19", "Visual Studio 2019, only install, devenv doesn't work ",
               "d3dx", "d3x9*, d3dx10*, d3dx11*, xactengine*, xapofx* x3daudio*, xinput* and d3dcompiler",
               "sspicli", "dangerzone, only for testing, might break things, only use on a per app base",
               "dshow", "directshow dlls: qdvd qcap etc.",
               "findstr", "findstr.exe",
               "affinity_requirements", "install and configure stuff to get affinity v2 started",
               "winmetadata", "various *.winmd files",
               "wintypes", "wine wintypes patched (from ElementalWarrior) for Affinity, https://forum.affinity.serif.com/index.php?/topic/182758-affinity-suite-v204-on-linux-wine/page/1/",
               "dxcore", "wine dxcore, patch (from ElementalWarrior) for Affinity, https://forum.affinity.serif.com/index.php?/topic/182758-affinity-suite-v204-on-linux-wine/page/1/",
               "dotnet35", "dotnet35",
               "dotnet481", "dotnet481",
               "install_dll_from_msu","extract and install a dll/file from an msu file (installation in right place might or might not work ;) )",
               "sharpdx", "directX with powershell (spinning cube), test if your d3d11 works, further rather useless verb for now ;)",
               "vulkansamples", "51 vulkan samples to test if your vulkan works, do shift-ctrl^c if you wanna leave earlier ;)",
               "wpf_xaml", "codesnippets from around the internet: how to use wpf+xaml in powershell",
               "wpf_msgbox", "codesnippets from around the internet: some fancy messageboxes (via wpf) in powershell",
               "wpf_routedevents", "codesnippets from around the internet: how to use wpf+xaml+routedevents in powershell",
               "cef", "codesnippets from around the internet: how to use cef / test cef",
               "embed-exe-in-psscript", "codesnippets from around the internet: samplescript howto embed and run an exe into a powershell-scripts (vkcube.exe)",
               "ps2exe", "convert a ps1-script into an executable; requires powershell 5.1, so 1st time usage may take very long time!!!"


for ( $j = 0; $j -lt $Qenu.count; $j+=2 ) { 
    $custom_array += New-Object PSObject -Property @{ # Setting up custom array utilizing a PSObject
        name = $Qenu[$j]  
        Description = $Qenu[$j+1]
    }
}

function quit?([string] $process)  <# wait for a process to quit #>
{
    Get-Process $process -ErrorAction:SilentlyContinue | Foreach-Object { $_.WaitForExit() }
}

function w_download_to
{
    Param ($dldir, $w_url, $w_file)
    $path = "$env:WINEHOMEDIR" + "\\.cache\\winetrickxs\\$dldir"

    if (![System.IO.Directory]::Exists($path.substring(4))){ [System.IO.Directory]::CreateDirectory($path.substring(4))}

    $f = $path.substring(4) + "\\$w_file"
    if (-not(Test-Path $f -PathType Leaf)){
        Add-Type -AssemblyName PresentationCore,PresentationFramework; [System.Windows.MessageBox]::Show('First time usage of this custom `
        winetricks takes VERY long time and eats up gigs of disk space,due to huge download and decompressing things. Loads of gigabytes `
        will be squashed into directory ~/.cache/winetrickxs ','Warning','ok','exclamation')

        (New-Object System.Net.WebClient).DownloadFile($w_url, $f)}
}

function check_msu_sanity <# some sanity checks before extracting from msu, like if cached files are present etc. #>
{
    Param ($url, $cab)

    $msu = $url.split('/')[-1]; <# -1 is last array element... #> $dldir = $($url.split('/')[-1]) -replace '.msu',''
    <# fragile test #>
    if (![System.IO.File]::Exists(  [IO.Path]::Combine($env:systemroot, "system32", "dpx.dll")  ))
       {Write-Host 'Extracting some files needed for expansion' ; func_expand;}

    if (![System.IO.File]::Exists( [IO.Path]::Combine($cachedir,  $dldir,  $cab) ) )
       {Write-Host file seems missing, re-extracting;  w_download_to $dldir $url $msu; 7z e $cachedir\\$dldir\\$msu "-o$cachedir\\$dldir" $cab -y; quit?('7z')}
}

function check_aik_sanity <# some sanity checks to see if cached files from windows kits 7 are present #>
{
    $cab = "KB3AIK_EN.iso"
    $dldir = "aik70"
    $url = "https://download.microsoft.com/download/8/E/9/8E9BBC64-E6F8-457C-9B8D-F6C9A16E6D6A/$cab"

    foreach($i in 'F_WINPEOC_AMD64__WINPE_WINPE_SCRIPTING.CAB', 'F_WINPEOC_AMD64__WINPE_WINPE_MDAC.CAB', 'F_WINPEOC_AMD64__WINPE_WINPE_HTA.CAB', 'F1_WINPE.WIM', `
                  'F_WINPEOC_X86__WINPE_WINPE_SCRIPTING.CAB', 'F_WINPEOC_X86__WINPE_WINPE_MDAC.CAB', 'F_WINPEOC_X86__WINPE_WINPE_HTA.CAB', 'F3_WINPE.WIM' ) {
        if(![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $dldir,  $i) ) ) { #assuming all cached files are gone, re-extract everything
            w_download_to $dldir $url $cab
            7z x $cachedir\\$dldir\\$cab 7z x Neutral.cab WinPE.cab "-o$cachedir\\$dldir" -y; quit?('7z')
            7z x $cachedir\\$dldir\\WinPE.cab F1_WINPE.WIM F3_WINPE.WIM "-o$cachedir\\$dldir" -y; quit?('7z')
            7z x $cachedir\\$dldir\\Neutral.cab F_WINPEOC_AMD64__WINPE_WINPE_SCRIPTING.CAB F_WINPEOC_AMD64__WINPE_WINPE_MDAC.CAB `
            F_WINPEOC_AMD64__WINPE_WINPE_HTA.CAB F_WINPEOC_X86__WINPE_WINPE_SCRIPTING.CAB F_WINPEOC_X86__WINPE_WINPE_MDAC.CAB `
            F_WINPEOC_X86__WINPE_WINPE_HTA.CAB "-o$cachedir\\$dldir" -y; quit?('7z')
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

    $regfile = $((Get-PSCallStack)[1].FunctionName).replace('func', 'reg') + '.reg'
    $regvalues | Out-File -FilePath $env:TEMP\\$regfile
    reg.exe IMPORT $env:TEMP\\$regfile /reg:64;
    reg.exe IMPORT $env:TEMP\\$regfile /reg:32;
}

function func_msxml3
{
    $dlls = @('msxml3.dll','msxml3r.dll'); check_aik_sanity; $dldir = "aik70"

    foreach ($i in $dlls) {
        7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/System32/$i -y | Select-String 'ok' ; Write-Host processed 64-bit $($i.split('/')[-1])
        7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\\syswow64" Windows/System32/$i -y| Select-String 'ok' ; Write-Host processed 32-bit $($i.split('/')[-1])} quit?('7z')
    foreach($i in 'msxml3') { dlloverride 'native' $i }
} <# end msxml3 #>

function func_msxml6
{
    $dlls = @('msxml6.dll', 'msxml6r.dll'); check_aik_sanity; $dldir = "aik70"

    foreach ($i in $dlls) {
        7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/System32/$i -y | Select-String 'ok' ; Write-Host processed 64-bit $($i.split('/')[-1])
        7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\\syswow64" Windows/System32/$i -y| Select-String 'ok' ; Write-Host processed 32-bit $($i.split('/')[-1])} quit?('7z')
    foreach($i in 'msxml6') { dlloverride 'native' $i }
} <# end msxml6 #>

function func_mfc42
{
    $dlls = @('mfc42.dll', 'mfc42u.dll'); check_aik_sanity; $dldir = "aik70"

    foreach ($i in $dlls) {
        7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/System32/$i -y | Select-String 'ok' ; Write-Host processed 64-bit $($i.split('/')[-1])
        7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\\syswow64" Windows/System32/$i -y| Select-String 'ok' ; Write-Host processed 32-bit $($i.split('/')[-1])} quit?('7z')
} <# end mfc42 #>

function func_riched20
{
    $dlls = @('riched20.dll','msls31.dll'); check_aik_sanity; $dldir = "aik70"

    foreach ($i in $dlls) {
        7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/System32/$i -y | Select-String 'ok' ; Write-Host processed 64-bit $($i.split('/')[-1])
        7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\\syswow64" Windows/System32/$i -y| Select-String 'ok' ; Write-Host processed 32-bit $($i.split('/')[-1])} quit?('7z')
    foreach($i in 'riched20') { dlloverride 'native' $i }
} <# end riched20 #>

function func_crypt32
{
    $dlls = @('crypt32.dll','msasn1.dll'); check_aik_sanity; $dldir = "aik70"

    foreach ($i in $dlls) {
        7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/System32/$i -y | Select-String 'ok' ; Write-Host processed 64-bit $($i.split('/')[-1])
        7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\\syswow64" Windows/System32/$i -y| Select-String 'ok' ; Write-Host processed 32-bit $($i.split('/')[-1])} quit?('7z')
    foreach($i in 'crypt32') { dlloverride 'native' $i }
}  <# end crypt32 #>

function func_oleaut32
{
    $dlls = @('oleaut32.dll'); check_aik_sanity; $dldir = "aik70"

    foreach ($i in $dlls) {
        7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/System32/$i -y | Select-String 'ok' ; Write-Host processed 64-bit $($i.split('/')[-1])
        7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\\syswow64" Windows/System32/$i -y| Select-String 'ok' ; Write-Host processed 32-bit $($i.split('/')[-1])} quit?('7z')
    #foreach($i in 'oleaut32') { dlloverride 'native' $i }
}  <# end oleaut32 #>

function func_windowscodecs
{
    $dlls = @('windowscodecs.dll'); check_aik_sanity; $dldir = "aik70"

    foreach ($i in $dlls) {
        7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/System32/$i -aoa; 
        7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\\syswow64" Windows/System32/$i -aoa } quit?('7z')
    foreach($i in 'windowscodecs') { dlloverride 'native' $i }
}  <# end windowscodecs #>

function func_uxtheme
{
    $dlls = @('uxtheme.dll'); check_aik_sanity; $dldir = "aik70"

    foreach ($i in $dlls) {
        7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/System32/$i -aoa; 
        7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\\syswow64" Windows/System32/$i -aoa } quit?('7z')
    foreach($i in 'uxtheme') { dlloverride 'native' $i }
}  <# end uxtheme #>

function func_sspicli
{
    $dlls = @('sspicli.dll'); check_aik_sanity; $dldir = "aik70"

    foreach ($i in $dlls) {
        7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/System32/$i -aoa; 
        7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\\syswow64" Windows/System32/$i -aoa } quit?('7z')
    foreach($i in 'sspicli') { dlloverride 'native' $i }
}  <# end sspicli #>

function func_gdiplus
{
    $url = "https://download.microsoft.com/download/3/5/C/35C470D8-802B-457A-9890-F1AFC277C907/Windows6.1-KB2834886-x64.msu"
    $cab = "Windows6.1-KB2834886-x64.cab"
    $sourcefile = @(`
    'amd64_microsoft.windows.gdiplus_6595b64144ccf1df_1.1.7601.22290_none_145f0c928b8d0397/gdiplus.dll',`
    'x86_microsoft.windows.gdiplus_6595b64144ccf1df_1.1.7601.22290_none_5c0c4369a0092c9d/gdiplus.dll'`
   )

    check_msu_sanity $url $cab; $dldir = $($url.split('/')[-1]) -replace '.msu',''

    foreach ($i in $sourcefile) {
        if( $i.SubString(0,3) -eq 'amd' ) {expnd_.exe $([IO.Path]::Combine($cachedir,  $dldir,  $cab)) -f:$($i.split('/')[-1]) $env:TEMP }
        if( $i.SubString(0,3) -eq 'x86' ) {<# Nothing to do #>}                                                                          } 

    foreach ($i in $sourcefile) {
        if( $i.SubString(0,3) -eq 'amd' ) {Copy-Item -force -verbose "$env:TEMP\\$i" -destination $env:systemroot\\system32\\$($i.split('/')[-1]) }
        if( $i.SubString(0,3) -eq 'x86' ) {Copy-Item -force -verbose "$env:TEMP\\$i" $env:systemroot\\syswow64\\$($i.split('/')[-1]) } } 
		  
    foreach($i in 'gdiplus') { dlloverride 'native' $i }  
} <# end gdiplus #>

function func_d2d1
{
    $url = "http://download.windowsupdate.com/d/msdownload/update/software/updt/2016/05/windows6.1-kb3125574-v4-x64_2dafb1d203c8964239af3048b5dd4b1264cd93b9.msu"
    $cab = "Windows6.1-KB3125574-v4-x64.cab"
    $sourcefile = @(`
    'amd64_microsoft-windows-d2d_31bf3856ad364e35_7.1.7601.23403_none_f7c6a38a168dcfb8/d2d1.dll',`
    'x86_microsoft-windows-d2d_31bf3856ad364e35_7.1.7601.23403_none_9ba808065e305e82/d2d1.dll'`
   )

    check_msu_sanity $url $cab; $dldir = $($url.split('/')[-1]) -replace '.msu',''

    foreach ($i in $sourcefile) {
        if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $dldir,  $i) ) ){
                    if( $i.SubString(0,3) -eq 'amd' ) {expnd_.exe $([IO.Path]::Combine($cachedir,  $dldir,  $cab)) -f:$($i.split('/')[-1]) $(Join-Path $cachedir  $dldir) }
                    if( $i.SubString(0,3) -eq 'x86' ) {<# Nothing to do #>}  }  }

    foreach ($i in $sourcefile) {
        if( $i.SubString(0,3) -eq 'amd' ) {Copy-Item -force -verbose "$(Join-Path $cachedir $dldir)\\$i" -destination $env:systemroot\\system32\\$($i.split('/')[-1]) }
        if( $i.SubString(0,3) -eq 'x86' ) {Copy-Item -force -verbose "$(Join-Path $cachedir $dldir)\\$i" $env:systemroot\\syswow64\\$($i.split('/')[-1]) } } 

    foreach($i in 'd2d1') { dlloverride 'native' $i }  
} <# end d2d1 #>

function func_windows.ui.xaml <# experimental... #>
{
    $url = "http://download.windowsupdate.com/c/msdownload/update/software/updt/2016/11/windows10.0-kb3205436-x64_45c915e7a85a7cc7fc211022ecd38255297049c3.msu"
    $cab = "Windows10.0-KB3205436-x64.cab"
    $sourcefile = @(`
        'wow64_microsoft-onecore-coremessaging_31bf3856ad364e35_10.0.10240.17146_none_59cb7df4b29f7881/coremessaging.dll', `
        'amd64_microsoft-onecore-coremessaging_31bf3856ad364e35_10.0.10240.17146_none_4f76d3a27e3eb686/coremessaging.dll', `
        'amd64_microsoft-windows-directui_31bf3856ad364e35_10.0.10240.17184_none_bee994db894d335a/windows.ui.xaml.dll', `
        'wow64_microsoft-windows-directui_31bf3856ad364e35_10.0.10240.17184_none_c93e3f2dbdadf555/windows.ui.xaml.dll', `
        'amd64_microsoft-windows-bcp47languages_31bf3856ad364e35_10.0.10240.17113_none_a25e8c81718a36ce/bcp47langs.dll', `
        'wow64_microsoft-windows-bcp47languages_31bf3856ad364e35_10.0.10240.17113_none_acb336d3a5eaf8c9/bcp47langs.dll' `
    )

    check_msu_sanity $url $cab; $dldir = $($url.split('/')[-1]) -replace '.msu',''    

    foreach ($i in $sourcefile) {
        if( $i.SubString(0,3) -eq 'amd' ) {expnd_.exe $([IO.Path]::Combine($cachedir,  $dldir,  $cab)) -f:$($i.split('/')[-1]) $env:TEMP }
        if( $i.SubString(0,3) -eq 'wow' ) {<# Nothing to do #>}                                                                          } 

    foreach ($i in $sourcefile) {
        if( $i.SubString(0,3) -eq 'amd' ) {Copy-Item -force -verbose "$env:TEMP\\$i" $env:systemroot\\system32\\$($i.split('/')[-1]) }
        if( $i.SubString(0,3) -eq 'wow' ) {Copy-Item -force -verbose "$env:TEMP\\$i" $env:systemroot\\syswow64\\$($i.split('/')[-1]) } } 
	
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

function func_ucrtbase
{
    $dldir = "vcredist2015"
    w_download_to "$dldir\\64" "https://aka.ms/vs/15/release/vc_redist.x64.exe" "VC_redist.x64.exe"
    w_download_to "$dldir\\32" "https://aka.ms/vs/15/release/vc_redist.x86.exe" VC__redist.x86.exe
    7z -t# x $cachedir\\$dldir\\64\\VC_redist.x64.exe "-o$env:TEMP\\$dldir\\64" 4.cab -y | Select-String 'ok' ; quit?('7z')
    7z -t# x $cachedir\\$dldir\\32\\VC__redist.x86.exe "-o$env:TEMP\\$dldir\\32" 4.cab -y | Select-String 'ok' ; quit?('7z')
    7z e $env:TEMP\\$dldir\\64\\4.cab "-o$env:TEMP\\$dldir\\64" a10 -y | Select-String 'ok' ; quit?('7z')
    7z e $env:TEMP\\$dldir\\32\\4.cab "-o$env:TEMP\\$dldir\\32" a10 -y | Select-String 'ok' ; quit?('7z')

    foreach ($i in 'ucrtbase.dll'){
        7z e $env:TEMP\\$dldir\\64\\a10 "-o$env:systemroot\system32" $i -aoa | Select-String 'ok'; quit?('7z')
        7z e $env:TEMP\\$dldir\\32\\a10 "-o$env:systemroot\syswow64" $i -aoa | Select-String 'ok'; quit?('7z') }
    foreach($i in 'ucrtbase') { dlloverride 'native' $i }
} <# end ucrtbase #>

function func_dshow
{
    $dldir = "win7sp1"
    w_download_to "$dldir" "http://download.windowsupdate.com/msdownload/update/software/svpk/2011/02/windows6.1-kb976932-x64_74865ef2562006e51d7f9333b4a8d45b7a749dab.exe" "windows6.1-kb976932-x64_74865ef2562006e51d7f9333b4a8d45b7a749dab.exe"
    if ( ![System.IO.File]::Exists( [IO.Path]::Combine($cachedir,  $dldir, "191.cab" ) ) ) {
        7z -t# x $cachedir\\$dldir\\windows6.1-kb976932-x64_74865ef2562006e51d7f9333b4a8d45b7a749dab.exe "-o$cachedir\\$dldir" 191.cab -y  ; quit?('7z') }

    foreach ($i in 
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
        'amd64_microsoft-windows-directshow-core_31bf3856ad364e35_6.1.7601.17514_none_04963d500485b5cd/quartz.dll') {
        if( $i.SubString(0,3) -eq 'amd' ) {7z e $cachedir\\$dldir\\191.cab "-o$env:systemroot\system32" $i -aoa ; quit?('7z') }
        if( $i.SubString(0,3) -eq 'x86' ) {7z e $cachedir\\$dldir\\191.cab "-o$env:systemroot\syswow64" $i -aoa ; quit?('7z') }
        if( $i.SubString(0,3) -eq 'wow' ) {7z e $cachedir\\$dldir\\191.cab "-o$env:systemroot\syswow64" $i -aoa ; quit?('7z') } }

    foreach($i in 'amstream', 'qasf', 'qcap', 'qdvd', 'qedit' , 'quartz') { dlloverride 'native' $i }

    foreach($i in  'amstream.dll', 'qasf.dll', 'qcap.dll', 'qdvd.dll', 'qedit.dll' , 'quartz.dll') {
        & "$env:systemroot\\syswow64\\regsvr32"  "$env:systemroot\\syswow64\\$i"
        & "$env:systemroot\\system32\\regsvr32"  "$env:systemroot\\system32\\$i" }
} <# end dshow #>

function func_findstr
{
    $dldir = "win7sp1"
    w_download_to "$dldir" "http://download.windowsupdate.com/msdownload/update/software/svpk/2011/02/windows6.1-kb976932-x64_74865ef2562006e51d7f9333b4a8d45b7a749dab.exe" "windows6.1-kb976932-x64_74865ef2562006e51d7f9333b4a8d45b7a749dab.exe"
    if ( ![System.IO.File]::Exists( [IO.Path]::Combine($cachedir,  $dldir, "191.cab" ) ) ) {
        7z -t# x $cachedir\\$dldir\\windows6.1-kb976932-x64_74865ef2562006e51d7f9333b4a8d45b7a749dab.exe "-o$cachedir\\$dldir" 191.cab -y  ; quit?('7z') }

    foreach ($i in 
        'x86_microsoft-windows-findstr_31bf3856ad364e35_6.1.7601.17514_none_2936f54db7f6c08f/findstr.exe',
        'amd64_microsoft-windows-findstr_31bf3856ad364e35_6.1.7601.17514_none_855590d1705431c5/findstr.exe') {
        if( $i.SubString(0,3) -eq 'amd' ) {7z e $cachedir\\$dldir\\191.cab "-o$env:systemroot\system32" $i -aoa ; quit?('7z') }
        if( $i.SubString(0,3) -eq 'x86' ) {7z e $cachedir\\$dldir\\191.cab "-o$env:systemroot\syswow64" $i -aoa ; quit?('7z') }
        if( $i.SubString(0,3) -eq 'wow' ) {7z e $cachedir\\$dldir\\191.cab "-o$env:systemroot\syswow64" $i -aoa ; quit?('7z') } }

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
    func_ucrtbase
    $dldir = "vcredist140"

    if ( ![System.IO.File]::Exists( [IO.Path]::Combine($cachedir,  $dldir,  "64", "VC_redist.x64.exe" ) ) -or 
         ![System.IO.File]::Exists( [IO.Path]::Combine($cachedir,  $dldir,  "32", "VC__redist.x86.exe") ) ) {
        choco install vcredist140 -n
        . $env:ProgramData\\chocolatey\\lib\\vcredist140\\tools\\data.ps1  #source the file via dot operator
        w_download_to "vcredist140\\64" $installData64.url64 "VC_redist.x64.exe"
        w_download_to "vcredist140\\32" $installData32.url VC__redist.x86.exe }
    
    7z -t# x $cachedir\\$dldir\\64\\VC_redist.x64.exe "-o$env:TEMP\\$dldir\\64" 4.cab -y | Select-String 'ok'; quit?('7z')
    7z -t# x $cachedir\\$dldir\\32\\VC__redist.x86.exe "-o$env:TEMP\\$dldir\\32" 4.cab -y | Select-String 'ok'; quit?('7z')
    7z e $env:TEMP\\$dldir\\64\\4.cab "-o$env:TEMP\\$dldir\\64" a12 -y | Select-String 'ok' ;quit?('7z')
    7z e $env:TEMP\\$dldir\\64\\4.cab "-o$env:TEMP\\$dldir\\64" a13 -y | Select-String 'ok'; quit?('7z')
    7z e $env:TEMP\\$dldir\\32\\4.cab "-o$env:TEMP\\$dldir\\32" a10 -y | Select-String 'ok'; quit?('7z')
    7z e $env:TEMP\\$dldir\\32\\4.cab "-o$env:TEMP\\$dldir\\32" a11 -y | Select-String 'ok'; quit?('7z')
    7z e $env:TEMP\\$dldir\\64\\a12 "-o$env:systemroot\\system32" -y | Select-String 'ok';
    7z e $env:TEMP\\$dldir\\64\\a13 "-o$env:systemroot\\system32" -y | Select-String 'ok';
    7z e $env:TEMP\\$dldir\\32\\a10 "-o$env:systemroot\\syswow64" -y | Select-String 'ok';
    7z e $env:TEMP\\$dldir\\32\\a11 "-o$env:systemroot\\syswow64" -y | Select-String 'ok'; quit?('7z')
    foreach($i in 'concrt140', 'msvcp140', 'msvcp140_1', 'msvcp140_2', 'vcruntime140', 'vcruntime140_1') { dlloverride 'native' $i }
} <# end vcrun2019 #>

function func_hnetcfg <# fix for https://bugs.winehq.org/show_bug.cgi?id=45432 #>
{
    $dldir = "hnetcfg"
    w_download_to "$dldir" "https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/EXTRAS/wine_hnetcfg.7z" "wine_hnetcfg.7z"

    foreach ($i in 'hnetcfg.dll'){
        7z e $cachedir\\$dldir\\wine_hnetcfg.7z "-o$env:systemroot\system32" 64/$i -aoa | Select-String 'ok' ; Write-Host processed 64-bit $($i.split('/')[-1]);quit?('7z')
        7z e $cachedir\\\\$dldir\\wine_hnetcfg.7z "-o$env:systemroot\syswow64" 32/$i -aoa | Select-String 'ok' ; Write-Host processed 64-bit $($i.split('/')[-1]); quit?('7z') }
    foreach($i in 'hnetcfg') { dlloverride 'native' $i }
} <# end hnetcfg #>

function func_msi <# wine msi with some hacks faking success #>
{
    $dldir = "msi"
    w_download_to "$dldir" "https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/EXTRAS/wine_msi.7z" "wine_msi.7z"

    foreach ($i in 'msi.dll'){
        7z e $cachedir\\$dldir\\wine_msi.7z "-o$env:systemroot\system32" 64/$i -aoa | Select-String 'ok' ; Write-Host processed 64-bit $($i.split('/')[-1]);quit?('7z')
        7z e $cachedir\\\\$dldir\\wine_msi.7z "-o$env:systemroot\syswow64" 32/$i -aoa | Select-String 'ok' ; Write-Host processed 32-bit $($i.split('/')[-1]); quit?('7z') }
    foreach($i in 'msi') { dlloverride 'native' $i }
} <# end msi #>

function func_wintrust <# wine wintrust with some hacks faking success #>
{
    $dldir = "wintrust"
    w_download_to "$dldir" "https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/EXTRAS/wine_wintrust.7z" "wine_wintrust.7z"

    foreach ($i in 'wintrust.dll'){
        7z e $cachedir\\$dldir\\wine_wintrust.7z "-o$env:systemroot\system32" 64/$i -aoa | Select-String 'ok' ; Write-Host processed 64-bit $($i.split('/')[-1]);quit?('7z')
        7z e $cachedir\\\\$dldir\\wine_wintrust.7z "-o$env:systemroot\syswow64" 32/$i -aoa | Select-String 'ok' ; Write-Host processed 32-bit $($i.split('/')[-1]); quit?('7z') }
    foreach($i in 'wintrust') { dlloverride 'native' $i }
} <# end wintrust #>

function func_advapi32 <# wine advapi32 with some hacks #>
{
    $dldir = "advapi32"
    w_download_to "$dldir" "https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/EXTRAS/wine_advapi32.7z" "wine_advapi32.7z"

    foreach ($i in 'advapi32.dll'){
        7z e $cachedir\\$dldir\\wine_advapi32.7z "-o$env:systemroot\system32" 64/$i -aoa | Select-String 'ok' ; Write-Host processed 64-bit $($i.split('/')[-1]);quit?('7z')
        7z e $cachedir\\\\$dldir\\wine_advapi32.7z "-o$env:systemroot\syswow64" 32/$i -aoa | Select-String 'ok' ; Write-Host processed 32-bit $($i.split('/')[-1]); quit?('7z') }
} <# end advapi32 #>

function func_ole32 <# wine ole32 with some hacks  #>
{
    $dldir = "ole32"
    w_download_to "$dldir" "https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/EXTRAS/wine_ole32.7z" "wine_ole32.7z"

    foreach ($i in 'ole32.dll'){
        7z e $cachedir\\$dldir\\wine_ole32.7z "-o$env:systemroot\system32" 64/$i -aoa | Select-String 'ok' ; Write-Host processed 64-bit $($i.split('/')[-1]);quit?('7z')
        7z e $cachedir\\\\$dldir\\wine_ole32.7z "-o$env:systemroot\syswow64" 32/$i -aoa | Select-String 'ok' ; Write-Host processed 32-bit $($i.split('/')[-1]); quit?('7z') }
} <# end ole32 #>

function func_combase <# wine combase with some hacks #>
{
    $dldir = "combase"
    w_download_to "$dldir" "https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/EXTRAS/wine_combase.7z" "wine_combase.7z"

    foreach ($i in 'combase.dll'){
        7z e $cachedir\\$dldir\\wine_combase.7z "-o$env:systemroot\system32" 64/$i -aoa | Select-String 'ok' ; Write-Host processed 64-bit $($i.split('/')[-1]);quit?('7z')
        7z e $cachedir\\\\$dldir\\wine_combase.7z "-o$env:systemroot\syswow64" 32/$i -aoa | Select-String 'ok' ; Write-Host processed 32-bit $($i.split('/')[-1]); quit?('7z') }
} <# end combase #>

function func_wintypes <# wintypes #>
{
    $dldir = "wintypes"
    w_download_to "$dldir" "https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/EXTRAS/wine_wintypes.7z" "wine_wintypes.7z"

    foreach ($i in 'wintypes.dll'){
        7z e $cachedir\\$dldir\\wine_wintypes.7z "-o$env:systemroot\system32" 64/$i -aoa | Select-String 'ok' ; Write-Host processed 64-bit $($i.split('/')[-1]);quit?('7z')
        7z e $cachedir\\\\$dldir\\wine_wintypes.7z "-o$env:systemroot\syswow64" 32/$i -aoa | Select-String 'ok' ; Write-Host processed 32-bit $($i.split('/')[-1]); quit?('7z') }
    foreach($i in 'wintypes') { dlloverride 'native' $i }
} <# end wintypes #>

function func_dxcore <# dxcore #>
{
    $dldir = "dxcore"
    w_download_to "$dldir" "https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/EXTRAS/wine_dxcore.7z" "wine_dxcore.7z"
    w_download_to "$dldir" "https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/EXTRAS/wine_ext-ms-win-dxcore-l1-1-0.7z" "wine_ext-ms-win-dxcore-l1-1-0.7z"

    foreach ($i in 'dxcore.dll', 'ext-ms-win-dxcore-l1-1-0.dll'){
        7z e $cachedir\\$dldir\\wine_$($i.split('.')[0]).7z "-o$env:systemroot\system32" 64/$i -aoa | Select-String 'ok' ; Write-Host processed 64-bit $($i.split('/')[-1]);quit?('7z')
        7z e $cachedir\\\\$dldir\\wine_$($i.split('.')[0]).7z "-o$env:systemroot\syswow64" 32/$i -aoa | Select-String 'ok' ; Write-Host processed 32-bit $($i.split('/')[-1]); quit?('7z') }
} <# end dxcore #>

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

function func_wsh57
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
        & "$env:systemroot\\syswow64\\regsvr32"  "$env:systemroot\\syswow64\\$i"
        & "$env:systemroot\\system32\\regsvr32"  "$env:systemroot\\system32\\$i" }

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

    & "$env:systemroot\\system32\\regsvr32"  "$env:CommonProgramFiles\\System\\ADO\\msado15.dll"
    & "$env:systemroot\\syswow64\\regsvr32"  "${env:CommonProgramFiles`(x86`)}\\System\\ADO\\msado15.dll"
    & "$env:systemroot\\system32\\regsvr32"  "$env:CommonProgramFiles\\System\\ADO\\msadox.dll"
    & "$env:systemroot\\syswow64\\regsvr32"  "${env:CommonProgramFiles`(x86`)}\\System\\ADO\\msadox.dll"
    & "$env:systemroot\\system32\\regsvr32"  "$env:CommonProgramFiles\\System\\ADO\\msadrh15.dll"
    & "$env:systemroot\\syswow64\\regsvr32"  "${env:CommonProgramFiles`(x86`)}\\System\\ADO\\msadrh15.dll"
    & "$env:systemroot\\system32\\regsvr32"  "$env:CommonProgramFiles\\System\\OLE DB\\oledb32.dll"
    & "$env:systemroot\\syswow64\\regsvr32"  "${env:CommonProgramFiles`(x86`)}\\System\\OLE DB\\oledb32.dll"
    & "$env:systemroot\\system32\\regsvr32"  "$env:CommonProgramFiles\\System\\MSADC\\msadce.dll"
    & "$env:systemroot\\syswow64\\regsvr32"  "${env:CommonProgramFiles`(x86`)}\\System\\MSADC\\msadce.dll"
    foreach($i in 'msjet40.dll', 'msjetoledb40.dll', 'msrd2x40.dll', 'msrd3x40.dll', 'msexch40.dll', 'msexcl40.dll', 'msltus40.dll', 'mspbde40.dll', 'mstext40.dll', 'msxbde40.dll', 'msjtes40.dll') {
        & "$env:systemroot\\syswow64\\regsvr32"  "$env:systemroot\\syswow64\\$i" }
#    & "$env:systemroot\\syswow64\\regsvr32"  "$env:systemroot\\syswow64\\msjet40.dll"
#    & "$env:systemroot\\syswow64\\regsvr32"  "$env:systemroot\\syswow64\\msrd2x40.dll"
#    & "$env:systemroot\\syswow64\\regsvr32"  "$env:systemroot\\syswow64\\msrd3x40.dll"
#    & "$env:systemroot\\syswow64\\regsvr32"  "$env:systemroot\\syswow64\\msjetoledb40.dll"
    & "$env:systemroot\\syswow64\\regsvr32"  "${env:CommonProgramFiles`(x86`)}\\Microsoft Shared\\DAO\\dao360.dll"

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
    check_aik_sanity; $dldir = "aik70"
    $exp     = @( 'amd64_microsoft-windows-basic-misc-tools_31bf3856ad364e35_6.1.7600.16385_none_7351a917d91c961e/expand.exe')
                  
    $dlls =    @( 'amd64_microsoft-windows-deltapackageexpander_31bf3856ad364e35_6.1.7600.16385_none_c5d387d64eb8e1f2/dpx.dll',
                  'amd64_microsoft-windows-cabinet_31bf3856ad364e35_6.1.7600.16385_none_933442c3fb9cbaed/cabinet.dll',
                  'amd64_microsoft-windows-deltacompressionengine_31bf3856ad364e35_6.1.7600.16385_none_9c2159bf9f702069/msdelta.dll' )

        if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $dldir,  $exp) ) ) {
            7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$([IO.Path]::Combine($cachedir,  $dldir,  $exp.Split('/')[0]))" Windows/winsxs/$exp -y | Select-String 'ok' ; Write-Host processed 64-bit $($i.split('/')[-1])
        }
    #Rename expand.exe to expnd_.exe to not interfere with wine`s expand; also rename it inside the binary
    #https://stackoverflow.com/questions/73790902/replace-string-in-a-binary-clipboard-dump-from-onenote
    # Read the file *as a byte array*.
    $data = Get-Content -AsByteStream -ReadCount 0  $([IO.Path]::Combine($cachedir,  $dldir,  $exp))
    # Convert the array to a "hex string" in the form "nn-nn-nn-...",  where nn represents a two-digit hex representation of each byte,
    # e.g. '41-42' for 0x41, 0x42, which, if interpreted as a single-byte encoding (ASCII), is 'AB'.
    $dataAsHexString = [BitConverter]::ToString($data)
    # Define the search and replace strings, and convert them into "hex strings" too, using their UTF-8 byte representation.
    $search = 'Expand.'
    $replacement = 'expnd_.'
    $searchAsHexString = [BitConverter]::ToString([Text.Encoding]::UTF8.GetBytes($search))
    $replaceAsHexString = [BitConverter]::ToString([Text.Encoding]::UTF8.GetBytes($replacement))
    # Perform the replacement.
    $dataAsHexString = $dataAsHexString.Replace($searchAsHexString, $replaceAsHexString)
    # Convert he modified "hex string" back to a byte[] array.
    $modifiedData = [byte[]] ($dataAsHexString -split '-' -replace '^', '0x')
    # Save the byte array back to the file.
    Set-Content -AsByteStream "$env:SystemRoot\\system32\\expnd_.exe" -Value $modifiedData -verbose

    foreach ($i in $dlls) {
        if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $dldir,  $i) ) ) {
            7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$([IO.Path]::Combine($cachedir,  $dldir,  $i.Split('/')[0]))" Windows/winsxs/$i -y | Select-String 'ok' ; Write-Host processed 64-bit $($i.split('/')[-1])
        }
    }

    foreach ($i in $dlls) {
       Copy-Item -force -verbose "$([IO.Path]::Combine($cachedir,  $dldir,  $i))" -destination $env:systemroot\\system32\\$($i.split('/')[-1])
    }
  
  if(!(Test-Path 'HKCU:\\Software\\Wine\\AppDefaults\\expnd_.exe')) {New-Item  -Path 'HKCU:\\Software\\Wine\\AppDefaults\\expnd_.exe'}
  if(!(Test-Path 'HKCU:\\Software\\Wine\\AppDefaults\\expnd_.exe\\DllOverrides')) {New-Item  -Path 'HKCU:\\Software\\Wine\\AppDefaults\\expnd_.exe\\DllOverrides'}
  New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\expnd_.exe\\DllOverrides' -Name 'cabinet' -Value 'native' -PropertyType 'String' -force
} <# end expand #>

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

function func_comctl32
{
    check_aik_sanity; $dldir = "aik70" <# There`s also other version 5.8 ?? #>
    $60dlls = @( 'amd64_microsoft.windows.common-controls_6595b64144ccf1df_6.0.7600.16385_none_fa645303170382f6/comctl32.dll', `
                 'x86_microsoft.windows.common-controls_6595b64144ccf1df_6.0.7600.16385_none_421189da2b7fabfc/comctl32.dll') ` 

    foreach ($i in $60dlls) {
        if( $i.SubString(0,3) -eq 'amd' ) {7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/winsxs/$i -y | Select-String 'ok' ; Write-Host processed 64-bit $($i.split('/')[-1])}
        if( $i.SubString(0,3) -eq 'x86' ) {7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\\syswow64" Windows/winsxs/$i -y | Select-String 'ok' ; Write-Host processed 32-bit $($i.split('/')[-1])}} quit?('7z')

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

    foreach($i in 'comctl32') { dlloverride 'native' $i }
} <# end comctl32 #>

function func_wmp
{
    $url = "https://download.microsoft.com/download/7/A/D/7AD12930-3AA6-4040-81CF-350BF1E99076/Windows6.2-KB2703761-x64.msu"
    $cab = "Windows6.2-KB2703761-x64.cab"
    $sourcefile = @(`
    'x86_microsoft-windows-mediaplayer-wmasf_31bf3856ad364e35_6.2.9200.16384_none_a460fc8111ced20d/wmasf.dll',`
    'amd64_microsoft-windows-mediaplayer-wmasf_31bf3856ad364e35_6.2.9200.16384_none_007f9804ca2c4343/wmasf.dll',`
    'x86_microsoft-windows-mediaplayer-wmvcore_31bf3856ad364e35_6.2.9200.16384_none_03dd8faea73e4600/wmvcore.dll',`
    'amd64_microsoft-windows-mediaplayer-wmvcore_31bf3856ad364e35_6.2.9200.16384_none_5ffc2b325f9bb736/wmvcore.dll',`
    'amd64_microsoft-windows-mediaplayer-wmnetmgr_31bf3856ad364e35_6.2.9200.16384_none_a00f9d7b48661606/wmnetmgr.dll',`
    'wow64_microsoft-windows-mediaplayer-wmnetmgr_31bf3856ad364e35_6.2.9200.16384_none_aa6447cd7cc6d801/wmnetmgr.dll',`
    'amd64_microsoft-windows-mfplat_31bf3856ad364e35_6.2.9200.16384_none_4f744011dd398719/mfplat.dll',`
    'x86_microsoft-windows-mfplat_31bf3856ad364e35_6.2.9200.16384_none_f355a48e24dc15e3/mfplat.dll',`
    'wow64_microsoft-windows-mediaplayer-wmpdxm_31bf3856ad364e35_6.2.9200.16384_none_07567510e5f08109/wmpdxm.dll',`
    'amd64_microsoft-windows-mediaplayer-wmpdxm_31bf3856ad364e35_6.2.9200.16384_none_fd01cabeb18fbf0e/wmpdxm.dll',`
    'wow64_microsoft-windows-mediaplayer-core_31bf3856ad364e35_6.2.9200.16384_none_6e8814d60d3eb187/wmp.dll',`
    'amd64_microsoft-windows-mediaplayer-core_31bf3856ad364e35_6.2.9200.16384_none_64336a83d8ddef8c/wmp.dll',`
    'wow64_microsoft-windows-mediaplayer-core_31bf3856ad364e35_6.2.9200.16384_none_6e8814d60d3eb187/wmploc.dll',`
    'amd64_microsoft-windows-mediaplayer-core_31bf3856ad364e35_6.2.9200.16384_none_64336a83d8ddef8c/wmploc.dll'`
    )

    check_msu_sanity $url $cab; $dldir = $($url.split('/')[-1]) -replace '.msu',''

    foreach ($i in $sourcefile) {
        if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $dldir,  $i) ) ){
                    if( $i.SubString(0,3) -eq 'amd' ) {expnd_.exe $([IO.Path]::Combine($cachedir,  $dldir,  $cab)) -f:$($i.split('/')[-1]) $(Join-Path $cachedir  $dldir) }
                    if( $i.SubString(0,3) -eq 'x86' ) {<# Nothing to do #>}
                    if( $i.SubString(0,3) -eq 'wow' ) {<# Nothing to do #>}  }  }

    foreach ($i in $sourcefile) {
        if( $i.SubString(0,3) -eq 'amd' ) {Copy-Item -force -verbose "$(Join-Path $cachedir $dldir)\\$i" -destination $env:systemroot\\system32\\$($i.split('/')[-1]) }
        if( $i.SubString(0,3) -eq 'x86' ) {Copy-Item -force -verbose "$(Join-Path $cachedir $dldir)\\$i" $env:systemroot\\syswow64\\$($i.split('/')[-1]) }
        if( $i.SubString(0,3) -eq 'wow' ) {Copy-Item -force -verbose "$(Join-Path $cachedir $dldir)\\$i" $env:systemroot\\syswow64\\$($i.split('/')[-1]) } } 
	  
    foreach($i in 'wmp') { dlloverride 'native' $i }

    foreach($i in 'wmp', 'wmpdxm') {
        & "$env:systemroot\\syswow64\\regsvr32"  "$env:systemroot\\syswow64\\$i"
        & "$env:systemroot\\system32\\regsvr32"  "$env:systemroot\\system32\\$i" }
} <# end wmp #>
 
function func_mshtml
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

    foreach($i in 'mshtml', 'ieframe', 'urlmon', 'jscript', 'wininet', 'shlwapi') { dlloverride 'native' $i }
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

function func_sapi <# Speech api #>
{   
    $url = "http://download.windowsupdate.com/c/msdownload/update/software/updt/2016/11/windows10.0-kb3205436-x64_45c915e7a85a7cc7fc211022ecd38255297049c3.msu"
    $cab = "Windows10.0-KB3205436-x64.cab"
    $sourcefile = @(`
        'amd64_microsoft-windows-speechcommon_31bf3856ad364e35_10.0.10240.17184_none_ddf5e9c56d621922/sapi.dll',
        'x86_microsoft-windows-speechcommon_31bf3856ad364e35_10.0.10240.17184_none_81d74e41b504a7ec/sapi.dll' `
    )

    check_msu_sanity $url $cab; $dldir = $($url.split('/')[-1]) -replace '.msu',''    

    foreach ($i in $sourcefile) {
        if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $dldir,  $i) ) ){
                    if( $i.SubString(0,3) -eq 'amd' ) {expnd_.exe $([IO.Path]::Combine($cachedir,  $dldir,  $cab)) -f:$($i.split('/')[-1]) $(Join-Path $cachedir  $dldir) }
                    if( $i.SubString(0,3) -eq 'x86' ) {<# Nothing to do #>}  }  }

    foreach ($i in $sourcefile) {
        if( $i.SubString(0,3) -eq 'amd' ) {Copy-Item -force -verbose "$(Join-Path $cachedir $dldir)\\$i" -destination $env:systemroot\\system32\\Speech\\Common\\$($i.split('/')[-1]) }
        if( $i.SubString(0,3) -eq 'x86' ) {Copy-Item -force -verbose "$(Join-Path $cachedir $dldir)\\$i" $env:systemroot\\syswow64\\Speech\\Common\\$($i.split('/')[-1]) } } 

    reg.exe DELETE "HKLM\SOFTWARE\Microsoft\Speech\Voices\Tokens\Wine Default Voice" /f /reg:64
    reg.exe DELETE "HKLM\SOFTWARE\Microsoft\Speech\Voices\Tokens\Wine Default Voice" /f /reg:32

    $dldir = "SpeechRuntime"
    w_download_to "$dldir\\32" "https://download.microsoft.com/download/A/6/4/A64012D6-D56F-4E58-85E3-531E56ABC0E6/x86_SpeechPlatformRuntime/SpeechPlatformRuntime.msi" "SpeechPlatformRuntime.msi"
    w_download_to "$dldir\\64" "https://download.microsoft.com/download/A/6/4/A64012D6-D56F-4E58-85E3-531E56ABC0E6/x64_SpeechPlatformRuntime/SpeechPlatformRuntime.msi" "SpeechPlatformRuntime.msi"

    iex "msiexec /i $cachedir\\$dldir\\64\\SpeechPlatformRuntime.msi INSTALLDIR='$env:SystemRoot\\system32\\Speech\\Engines' /q "
    iex "msiexec /i $cachedir\\$dldir\\32\\SpeechPlatformRuntime.msi INSTALLDIR='$env:SystemRoot\\syswow64\\Speech\\Engines' /q "

    foreach ($i in 'sapi') { dlloverride 'native' $i } 

    foreach($i in 'sapi.dll') {
        & "$env:systemroot\\syswow64\\regsvr32"  "$env:systemroot\\syswow64\\Speech\\Common\\$i"
        & "$env:systemroot\\system32\\regsvr32"  "$env:systemroot\\system32\\Speech\\Common\\$i" }

    w_download_to "$dldir" "https://download.microsoft.com/download/4/0/D/40D6347A-AFA5-417D-A9BB-173D937BEED4/MSSpeech_TTS_en-US_ZiraPro.msi" "MSSpeech_TTS_en-US_ZiraPro.msi"

    iex "msiexec /i $cachedir\\$dldir\\MSSpeech_TTS_en-US_ZiraPro.msi <# INSTALLDIR='$env:SystemRoot\\Speech\\Engines\\TTS\\en-US' #> "

    quit?('msiexec')

    reg.exe COPY "HKLM\Software\MicroSoft\Speech Server\v11.0" "HKLM\Software\MicroSoft\Speech" /s /f /reg:64
    reg.exe COPY "HKLM\Software\MicroSoft\Speech Server\v11.0" "HKLM\Software\MicroSoft\Speech" /s /f /reg:32

    $voice = new-object -com SAPI.SpVoice
    $voice.Speak("This is mostly a bunch of crap. Please improve me", 2)
} <# end sapi #>

function func_ps51 <# powershell 5.1; do 'ps51 -h' for help #>
{   
    $dldir = "ps51"
    if ( ![System.IO.File]::Exists( [IO.Path]::Combine($cachedir,  $dldir, "Windows6.1-KB3191566-x64.cab" ) ) ) {
        w_download_to $dldir "https://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/Win7AndW2K8R2-KB3191566-x64.zip" Win7AndW2K8R2-KB3191566-x64.zip
        7z e $cachedir\\$dldir\\Win7AndW2K8R2-KB3191566-x64.zip "-o$cachedir\\$dldir" Win7AndW2K8R2-KB3191566-x64.msu -y | Select-String 'ok'; quit?('7z')
        7z e $cachedir\\$dldir\\Win7AndW2K8R2-KB3191566-x64.msu "-o$cachedir\\$dldir" Windows6.1-KB3191566-x64.cab -y | Select-String 'ok'; quit?('7z')}

    $cab = "Windows6.1-KB3191566-x64.cab"
    $sourcefile = @(`
    'msil_system.management.automation_31bf3856ad364e35_7.3.7601.16384_none_85266a48f56bfafc/system.management.automation.dll',`
    'msil_microsoft.powershel..ommands.diagnostics_31bf3856ad364e35_7.3.7601.16384_none_3cbfce2c3881d318/microsoft.powershell.commands.diagnostics.dll',`
    'msil_microsoft.powershell.commands.utility_31bf3856ad364e35_7.3.7601.16384_none_d96091fd5568ce18/microsoft.powershell.commands.utility.dll',`
    'msil_microsoft.powershell.consolehost_31bf3856ad364e35_7.3.7601.16384_none_8634e813855724c9/microsoft.powershell.consolehost.dll',`
    'msil_microsoft.powershell.commands.management_31bf3856ad364e35_7.3.7601.16384_none_c1a0335546714b23/microsoft.powershell.commands.management.dll',`
    'msil_microsoft.management.infrastructure_31bf3856ad364e35_7.3.7601.16384_none_8310156aa31a52f1/microsoft.management.infrastructure.dll',`
    'msil_microsoft.powershell.security_31bf3856ad364e35_7.3.7601.16384_none_64c18e3e0eafee92/microsoft.powershell.security.dll',`
    'msil_microsoft.wsman.runtime_31bf3856ad364e35_7.3.7601.16384_none_a19b148df40272fb/microsoft.wsman.runtime.dll',`
    'msil_microsoft.wsman.management_31bf3856ad364e35_7.3.7601.16384_none_60964e40b40fafee/microsoft.wsman.management.dll',`
    'msil_microsoft.powershell.graphicalhost_31bf3856ad364e35_7.3.7601.16384_none_c32121af2a1808d4/microsoft.powershell.graphicalhost.dll'`
    )

    <# Following files have to go into $env:systemroot\\system32\\WindowsPowerShell\v1.0\\ #>
    $psrootfiles = @(` <# sourcefile #>                                                                                                                        <# destination file #>
    @('wow64_microsoft-windows-powershell-exe_31bf3856ad364e35_7.3.7601.16384_none_531328cc15e8fa79/powershell.exe',                                           'ps51.exe'),`
    @('amd64_microsoft-windows-powershell-exe_31bf3856ad364e35_7.3.7601.16384_none_48be7e79e188387e/powershell.exe',                                           'ps51.exe'),`
    @('x86_microsoft.managemen..frastructure.native_31bf3856ad364e35_7.3.7601.16384_none_d262ac3e9809d109/microsoft.management.infrastructure.native.dll',     'microsoft.management.infrastructure.native.dll'),`
    @('amd64_microsoft.managemen..frastructure.native_31bf3856ad364e35_7.3.7601.16384_none_8ab57567838da803/microsoft.management.infrastructure.native.dll',   'microsoft.management.infrastructure.native.dll')`
    )

    <# Following files have to go into their right directories like on Windows (like e.g. $env:systemroot\\system32\\WindowsPowerShell\v1.0\\Modules\\microsoft.powershell.management etc.) #>
    $modfiles = @(` <# sourcefile #>                                                                                                             <# destination directory #>
    @('amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/microsoft.powershell.management.psd1', 'Modules\\microsoft.powershell.management'),`
    @('wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/microsoft.powershell.management.psd1', 'Modules\\microsoft.powershell.management'),`
    @('amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/microsoft.powershell.utility.psd1',    'Modules\\microsoft.powershell.utility'),`
    @('wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/microsoft.powershell.utility.psd1',    'Modules\\microsoft.powershell.utility'),`
    @('amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/microsoft.powershell.utility.psm1',    'Modules\\microsoft.powershell.utility'),`
    @('wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/microsoft.powershell.utility.psm1',    'Modules\\microsoft.powershell.utility'),`
#    
    @('amd64_microsoft.powershell.archive_31bf3856ad364e35_7.3.7601.16384_none_f7ab4242f320bef0/microsoft.powershell.archive.psm1',                  'Modules\\microsoft.powershell.archive'),`
    @('amd64_microsoft.powershell.archive_31bf3856ad364e35_7.3.7601.16384_none_f7ab4242f320bef0/microsoft.powershell.archive.psd1',                  'Modules\\microsoft.powershell.archive'),`
    @('wow64_microsoft.powershell.archive_31bf3856ad364e35_7.3.7601.16384_none_01ffec95278180eb/microsoft.powershell.archive.psm1',                  'Modules\\microsoft.powershell.archive'),`
    @('wow64_microsoft.powershell.archive_31bf3856ad364e35_7.3.7601.16384_none_01ffec95278180eb/microsoft.powershell.archive.psd1',                  'Modules\\microsoft.powershell.archive'),`
#
    @('amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/microsoft.powershell.diagnostics.psd1',    'Modules\\microsoft.powershell.diagnostics'),`
    @('wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/microsoft.powershell.diagnostics.psd1',    'Modules\\microsoft.powershell.diagnostics'),`
#    
    @('amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/microsoft.powershell.security.psd1',       'Modules\\microsoft.powershell.security'),`
    @('wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/microsoft.powershell.security.psd1',       'Modules\\microsoft.powershell.security')`
    )
    <# fragile test... #>
    if (![System.IO.File]::Exists(  [IO.Path]::Combine($env:systemroot, "system32", "dpx.dll")  ) ) { func_expand }

    foreach ($i in $sourcefile) {
        if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $dldir,  $i) ) ){
            expnd_.exe $([IO.Path]::Combine($cachedir,  $dldir,  $cab)) -f:$($i.split('/')[-1]) $(Join-Path $cachedir  $dldir) } 
        Copy-Item -force "$(Join-Path $cachedir $dldir)\\$i" $env:systemroot\\system32\\WindowsPowerShell\v1.0\\$($i.split('/')[-1])}

    foreach ($i in $psrootfiles) {
        if (![System.IO.File]::Exists(  $(Join-Path $cachedir  $dldir  $i[0]) ) ){  
            if( $i[0].SubString(0,3) -eq 'amd' ) {expnd_.exe $([IO.Path]::Combine($cachedir,  $dldir,  $cab)) -f:$($i[0].split('/')[-1]) $(Join-Path $cachedir $dldir) }
            if( $i[0].SubString(0,3) -eq 'x86' ) {<# Nothing to do #>}     
            if( $i[0].SubString(0,3) -eq 'wow' ) {<# Nothing to do #>}  }  }  

    foreach ($i in $psrootfiles) {
        if( $i[0].SubString(0,3) -eq 'amd' ) {Copy-Item -force -verbose $(Join-Path $cachedir $dldir $i[0]) -destination  $(Join-Path $env:systemroot\\system32\\WindowsPowerShell\\v1.0 $i[1] ) }
        if( $i[0].SubString(0,3) -eq 'x86' ) {Copy-Item -force -verbose $(Join-Path $cachedir $dldir $i[0]) -destination  $(Join-Path $env:systemroot\\syswow64\\WindowsPowerShell\\v1.0 $i[1] ) }
        if( $i[0].SubString(0,3) -eq 'wow' ) {Copy-Item -force -verbose $(Join-Path $cachedir $dldir $i[0]) -destination  $(Join-Path $env:systemroot\\syswow64\\WindowsPowerShell\\v1.0 $i[1] ) } }

    foreach ($i in $modfiles) {
        if (![System.IO.File]::Exists(  $(Join-Path $cachedir  $dldir  $i[0]) ) ){  
            if( $i[0].SubString(0,3) -eq 'amd' ) {expnd_.exe $([IO.Path]::Combine($cachedir,  $dldir,  $cab)) -f:$($i[0].split('/')[-1]) $(Join-Path $cachedir $dldir) }
            if( $i[0].SubString(0,3) -eq 'wow' ) {<# Nothing to do #>}  }  }  

    foreach ($i in $modfiles) {
        if( $i[0].SubString(0,3) -eq 'amd' ) {Copy-Item -force -verbose $(Join-Path $cachedir $dldir $i[0]) -destination (New-Item -Path $(Join-Path $env:systemroot\\system32\\WindowsPowerShell\\v1.0 $i[1] ) -Type Directory -force) }
        if( $i[0].SubString(0,3) -eq 'wow' ) {Copy-Item -force -verbose $(Join-Path $cachedir $dldir $i[0]) -destination (New-Item -Path $(Join-Path $env:systemroot\\syswow64\\WindowsPowerShell\\v1.0 $i[1] ) -Type Directory -force) } } 

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

Import-Module `$env:SystemRoot\system32\WindowsPowerShell\v1.0\Modules\microsoft.powershell.utility\microsoft.powershell.utility.psm1

`$env:PS51 = 1

function Get-CIMInstance ( [parameter(position=0)] [string]`$classname, [string[]]`$property="*")
{
     Get-WMIObject `$classname -property `$property
}

Set-Alias -Name gcim -Value Get-CIMInstance

if (!(Get-process -Name powershell_ise -erroraction silentlycontinue)) {
    (Get-Host).ui.RawUI.WindowTitle='This is Powershell 5.1!'
 
    Set-ExecutionPolicy ByPass
 
#    Import-Module PSReadLine

    function prompt  
    {  
        `$ESC = [char]27
         "`$ESC[93mPS 51! `$(`$executionContext.SessionState.Path.CurrentLocation)`$(' `$' * (`$nestedPromptLevel + 1)) `$ESC[0m"  
    }
}

. "`$env:ProgramData\Chocolatey-for-wine\profile_winetricks_caller.ps1"

"@
    $profile51 | Out-File $env:SystemRoot\\system32\\WindowsPowerShell\v1.0\\profile.ps1
    $profile51 | Out-File $env:SystemRoot\\syswow64\\WindowsPowerShell\v1.0\\profile.ps1

#    Copy-Item -Path "$env:systemroot\system32\WindowsPowershell\v1.0\system.management.automation.dll" -Destination (New-item -Name "System.Management.Automation\v4.0_3.0.0.0__31bf3856ad364e35" -Type directory -Path "$env:systemroot\Microsoft.NET/assembly/GAC_MSIL" -Force) -Force -Verbose
    Move-Item -Path "$env:systemroot\system32\WindowsPowershell\v1.0\system.management.automation.dll" -Destination (New-item -Name "System.Management.Automation\v4.0_3.0.0.0__31bf3856ad364e35" -Type directory -Path "$env:systemroot\Microsoft.NET/assembly/GAC_MSIL" -Force) -Force -Verbose
    Move-Item -Path "$env:systemroot\system32\WindowsPowershell\v1.0\microsoft.wsman.runtime.dll" -Destination (New-item -Name "Microsoft.WSMan.Runtime\v4.0_3.0.0.0__31bf3856ad364e35" -Type directory -Path "$env:systemroot\Microsoft.NET/assembly/GAC_MSIL" -Force) -Force -Verbose
    Move-Item -Path "$env:systemroot\system32\WindowsPowershell\v1.0\microsoft.wsman.management.dll" -Destination (New-item -Name "Microsoft.WSMan.Management\v4.0_3.0.0.0__31bf3856ad364e35" -Type directory -Path "$env:systemroot\Microsoft.NET/assembly/GAC_MSIL" -Force) -Force -Verbose
    Move-Item -Path "$env:systemroot\system32\WindowsPowershell\v1.0\microsoft.powershell.security.dll" -Destination (New-item -Name "Microsoft.PowerShell.Security\v4.0_3.0.0.0__31bf3856ad364e35" -Type directory -Path "$env:systemroot\Microsoft.NET/assembly/GAC_MSIL" -Force) -Force -Verbose
    Copy-Item -Path "$env:systemroot\system32\WindowsPowershell\v1.0\microsoft.management.infrastructure.native.dll" -Destination (New-item -Name "Microsoft.Management.Infrastructure\v4.0_1.0.0.0__31bf3856ad364e35" -Type directory -Path "$env:systemroot\Microsoft.NET/assembly/GAC_64" -Force) -Force -Verbose
    Copy-Item -Path "$env:systemroot\syswow64\WindowsPowershell\v1.0\microsoft.management.infrastructure.native.dll" -Destination (New-item -Name "Microsoft.Management.Infrastructure\v4.0_1.0.0.0__31bf3856ad364e35" -Type directory -Path "$env:systemroot\Microsoft.NET/assembly/GAC_32" -Force) -Force -Verbose
    Move-Item -Path "$env:systemroot\system32\WindowsPowershell\v1.0\microsoft.management.infrastructure.dll" -Destination (New-item -Name "Microsoft.Management.Infrastructure\v4.0_1.0.0.0__31bf3856ad364e35" -Type directory -Path "$env:systemroot\Microsoft.NET/assembly/GAC_MSIL" -Force) -Force -Verbose
    Move-Item -Path "$env:systemroot\system32\WindowsPowershell\v1.0\microsoft.powershell.commands.management.dll" -Destination (New-item -Name "Microsoft.PowerShell.Commands.Management\v4.0_3.0.0.0__31bf3856ad364e35" -Type directory -Path "$env:systemroot\Microsoft.NET/assembly/GAC_MSIL" -Force) -Force -Verbose
    Move-Item -Path "$env:systemroot\system32\WindowsPowershell\v1.0\microsoft.powershell.commands.utility.dll" -Destination (New-item -Name "Microsoft.PowerShell.Commands.Utility\v4.0_3.0.0.0__31bf3856ad364e35" -Type directory -Path "$env:systemroot\Microsoft.NET/assembly/GAC_MSIL" -Force) -Force -Verbose
    Move-Item -Path "$env:systemroot\system32\WindowsPowershell\v1.0\microsoft.powershell.consolehost.dll" -Destination (New-item -Name "Microsoft.PowerShell.ConsoleHost\v4.0_3.0.0.0__31bf3856ad364e35" -Type directory -Path "$env:systemroot\Microsoft.NET/assembly/GAC_MSIL" -Force) -Force -Verbose
    Move-Item -Path "$env:systemroot\system32\WindowsPowershell\v1.0\microsoft.powershell.commands.diagnostics.dll" -Destination (New-item -Name "Microsoft.PowerShell.Commands.Diagnostics\v4.0_3.0.0.0__31bf3856ad364e35" -Type directory -Path "$env:systemroot\Microsoft.NET/assembly/GAC_MSIL" -Force) -Force -Verbose
} <# end ps51 #>

function func_ps51_ise <# Powershell 5.1 Integrated Scripting Environment #>
{   
    $cab = "Windows6.1-KB3191566-x64.cab"
    $sourcefile = @(`
    'msil_microsoft.powershell.isecommon_31bf3856ad364e35_7.3.7601.16384_none_a33e3db6b35267f1/microsoft.powershell.isecommon.dll',`
    'msil_microsoft.powershell.gpowershell_31bf3856ad364e35_7.3.7601.16384_none_4ae744e0977d3ba7/microsoft.powershell.gpowershell.dll',`
    'msil_microsoft.powershell.editor_31bf3856ad364e35_7.3.7601.16384_none_63323f1238aa80de/microsoft.powershell.editor.dll'`
    )
    <# Following files have to go into their right directories like on Windows (like e.g. $env:systemroot\\system32\\WindowsPowerShell\v1.0\\Modules\\ISE etc.) #>
    $modfiles = @(` <# sourcefile #>                                                                                                             <# destination #>
    @('wow64_microsoft-windows-gpowershell-exe_31bf3856ad364e35_7.3.7601.16384_none_228e49bab56b74ea/powershell_ise.exe',                        ''),`
    @('amd64_microsoft-windows-gpowershell-exe_31bf3856ad364e35_7.3.7601.16384_none_18399f68810ab2ef/powershell_ise.exe',                        ''),`
    @('amd64_microsoft-windows-gpowershell-exe_31bf3856ad364e35_7.3.7601.16384_none_18399f68810ab2ef/ise.psd1',                                  'Modules\\ISE'),`
    @('amd64_microsoft-windows-gpowershell-exe_31bf3856ad364e35_7.3.7601.16384_none_18399f68810ab2ef/ise.psm1',                                  'Modules\\ISE'),`
    @('wow64_microsoft-windows-gpowershell-exe_31bf3856ad364e35_7.3.7601.16384_none_228e49bab56b74ea/ise.psd1',                                  'Modules\\ISE'),`
    @('wow64_microsoft-windows-gpowershell-exe_31bf3856ad364e35_7.3.7601.16384_none_228e49bab56b74ea/ise.psm1',                                  'Modules\\ISE')`
)

    func_ps51

    $dldir = "ps51"

    <# fragile test... #>
    if (![System.IO.File]::Exists(  [IO.Path]::Combine($env:systemroot, "system32", "dpx.dll")  ) ) { func_expand }

    foreach ($i in $sourcefile) {
        if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $dldir,  $i) ) ){
            expnd_.exe $([IO.Path]::Combine($cachedir,  $dldir,  $cab)) -f:$($i.split('/')[-1]) $(Join-Path $cachedir  $dldir) } 
        Copy-Item -force $(Join-Path $cachedir $dldir $i) $env:systemroot\\system32\\WindowsPowerShell\v1.0\\$($i.split('/')[-1])}

    foreach ($i in $modfiles) {
        if (![System.IO.File]::Exists(  $(Join-Path $cachedir  $dldir  $i[0]) ) ){  
                    if( $i[0].SubString(0,3) -eq 'amd' ) {expnd_.exe $([IO.Path]::Combine($cachedir,  $dldir,  $cab)) -f:$($i[0].split('/')[-1]) $(Join-Path $cachedir $dldir) }
                    if( $i[0].SubString(0,3) -eq 'wow' ) {<# Nothing to do #>}  }  }  

    foreach ($i in $modfiles) {
        if( $i[0].SubString(0,3) -eq 'amd' ) {Copy-Item -force -verbose $(Join-Path $cachedir $dldir $i[0]) -destination (New-Item -Path $(Join-Path $env:systemroot\\system32\\WindowsPowerShell\\v1.0 $i[1] ) -Type Directory -force) }
        if( $i[0].SubString(0,3) -eq 'wow' ) {Copy-Item -force -verbose $(Join-Path $cachedir $dldir $i[0]) -destination (New-Item -Path $(Join-Path $env:systemroot\\syswow64\\WindowsPowerShell\\v1.0 $i[1] ) -Type Directory -force) } } 

$regkey_ise = @"
REGEDIT4
[HKEY_CURRENT_USER\Software\Wine\Fonts\Replacements]
"Lucida Console"="Arial"
"@
    reg_edit $regkey_ise

    powershell_ise.exe     
} <# end ps51_ise #>

function func_msvbvm60 <# msvbvm60 #>
{   
    $url = "http://download.windowsupdate.com/d/msdownload/update/software/updt/2016/05/windows6.1-kb3125574-v4-x64_2dafb1d203c8964239af3048b5dd4b1264cd93b9.msu"
    $cab = "Windows6.1-KB3125574-v4-x64.cab"
    $sourcefile = @(`
    'x86_microsoft-windows-msvbvm60_31bf3856ad364e35_6.1.7601.23403_none_c51e69cfc91299fe/msvbvm60.dll'
    )

    check_msu_sanity $url $cab; $dldir = $($url.split('/')[-1]) -replace '.msu',''

    foreach ($i in $sourcefile) {
        if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $dldir,  $i) ) ){
            expnd_.exe $([IO.Path]::Combine($cachedir,  $dldir,  $cab)) -f:$($i.split('/')[-1]) $(Join-Path $cachedir  $dldir) } 
        Copy-Item -force "$(Join-Path $cachedir $dldir)\\$i" $env:systemroot\\syswow64\\$($i.split('/')[-1])}
} <# end msvbvm60 #>

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
func_msxml6
#func_wintrust
#func_msxml3
#func_vcrun2019
#func_xmllite

winecfg /v win7

(New-Object System.Net.WebClient).DownloadFile('https://aka.ms/vs/16/release/installer', "$env:TMP\\installer")

7z x $env:TMP\\installer "-o$env:TMP\\opc" -y ;quit?('7z')

set-executionpolicy bypass

Start-Process  "$env:TMP\\opc\\Contents\\vs_installer.exe" -Verb RunAs -ArgumentList "install --channelId VisualStudio.16.Release --channelUri `"https://aka.ms/vs/16/release/channel`" --productId Microsoft.VisualStudio.Product.Community --add Microsoft.VisualStudio.Workload.VCTools --add `"Microsoft.VisualStudio.Component.VC.Tools.x86.x64`" --add `"Microsoft.VisualStudio.Component.VC.CoreIde`"             --includeRecommended --quiet" 
# Start-Process  "$env:TMP\\opc\\Contents\\vs_installer.exe" -Verb RunAs -ArgumentList "install --channelId VisualStudio.16.Release --channelUri `"https://aka.ms/vs/16/release/channel`" --productId Microsoft.VisualStudio.Product.Community --add Microsoft.VisualStudio.Workload.VCTools --add `"Microsoft.VisualStudio.Component.VC.Tools.x86.x64`" --add `"Microsoft.VisualStudio.Component.VC.CoreIde`"  --add `"Microsoft.VisualStudio.Component.Windows10SDK.16299`"           --includeRecommended --quiet"

#cl.exe -I"c:\Program Files (x86)/Windows Kits/10/Include/10.0.16299.0/um/"     -I"c:\Program Files (x86)/Windows Kits/10/Include/10.0.16299.0/Shared/"   -I"c:\Program Files (x86)/Windows Kits/10/Include/10.0.16299.0/ucrt/"   -I"c:\Program Files (x86)/Microsoft Visual Studio/2019/Community/VC/Tools/MSVC/14.29.30133/include/" .\mainv1.c /link /LIBPATH:"c:/Program Files (x86)/Windows Kits/10/Lib/10.0.16299.0/um/x64/" /LIBPATH:"c:/Program Files (x86)/Microsoft Visual Studio/2019/Community/VC/Tools/MSVC/14.29.30133/lib/x64/" /LIBPATH:"c:/Program Files (x86)/Windows Kits/10/Lib/10.0.16299.0/ucrt/x64/"  "c:/Program Files (x86)/Windows Kits/10/Lib/10.0.16299.0/um/x64/urlmon.lib"  "c:/Program Files (x86)/Windows Kits/10/Lib/10.0.16299.0/um/x64/shlwapi.lib"


  func_advapi32
  func_ole32
  func_combase
  

  if(!(Test-Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe')) {New-Item  -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe'}
  if(!(Test-Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe\\DllOverrides')) {New-Item  -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe\\DllOverrides'}
  New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe\\DllOverrides' -Name 'advapi32' -Value 'native' -PropertyType 'String' -force
  New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe\\DllOverrides' -Name 'ole32' -Value 'native' -PropertyType 'String' -force
  New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe\\DllOverrides' -Name 'combase' -Value 'native' -PropertyType 'String' -force

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
    . "$env:ProgramData\Chocolatey-for-wine\powershell_collected_codesnippets_examples.ps1"
    func_embed-exe-in-psscript2
}

function func_ps2exe
{
    . "$env:ProgramData\Chocolatey-for-wine\powershell_collected_codesnippets_examples.ps1"
    func_ps2exe2
}

function func_vulkansamples
{   <# https://www.saschawillems.de/blog/2017/03/25/updated-vulkan-example-binaries/ #>
    $dldir = "vulkansamples"
    w_download_to $dldir "http://vulkan.gpuinfo.org/downloads/examples/vulkan_examples_windows_x64.7z" "vulkan_examples_windows_x64.7z" 
    w_download_to $dldir "http://vulkan.gpuinfo.org/downloads/examples/vulkan_examples_mediapack.7z" "vulkan_examples_mediapack.7z" 
    7z x $cachedir\\$dldir\\vulkan_examples_windows_x64.7z "-o$cachedir\\$dldir\\" -y; quit?(7z)
    7z x $cachedir\\$dldir\\vulkan_examples_mediapack.7z "-o$cachedir\\$dldir\\vulkan_examples_windows_x64" -y; quit?(7z)
    Push-Location
    cd $cachedir\\$dldir\\vulkan_examples_windows_x64\\bin
    foreach($i in $( ls $cachedir\\$dldir\\vulkan_examples_windows_x64\\bin\\*.exe).Name) { Write-Host 'Press Shift-Ctrl^C to exit earlier...'; Start-process -Wait "$cachedir\\$dldir\\vulkan_examples_windows_x64\\bin\\$i"}
    Pop-Location
}

function func_dotnet35
{
    $dldir = "dotnet35"
    w_download_to $dldir "https://download.microsoft.com/download/6/0/f/60fc5854-3cb8-4892-b6db-bd4f42510f28/dotnetfx35.exe" "dotnetfx35.exe"
    7z x $cachedir\\$dldir\\dotnetfx35.exe "-o$env:TEMP\\$dldir\\" -y; quit?(7z)

    Remove-Item -Force  $env:TEMP\\$dldir\\wcu\\dotNetFramework\\dotNetFX20\\PCW_CAB_NetFX*
    foreach($i in $( ls $env:TEMP\\$dldir\\wcu\\dotNetFramework\\dotNetFX20\\*.msp) )
        {7z x $i "-o$env:TEMP\\$dldir\\wcu\\dotNetFramework\\dotNetFX20" "PCW_CAB_NetFX" -aou -y;}
    quit?(7z)
    foreach($i in $( ls $env:TEMP\\$dldir\\wcu\\dotNetFramework\\dotNetFX20\\PCW_CAB_NetFX*) )
        { 7z x $i "-o$env:TEMP\\$dldir\\wcu\\dotNetFramework\\dotNetFX20\\extr" -y; } 
    quit?(7z)

    #https://4sysops.com/archives/find-and-remove-duplicate-files-with-powershell/
    #Document mainly for myself how I built list of where the extracted files should go:
    #A. First ged rid of extracted duplicates 
    #$srcDir = "$env:Temp\dotnet35\wcu\dotNetFramework\dotNetFX20\extr"
    #$targetDir = "$env:Temp\dotnet35\wcu\dotNetFramework\dotNetFX20"
    # Move duplicate (extracted)files from srcdir to a different location targetdir
    #Get-ChildItem -Path $srcDir -File -Recurse | group -Property Length | where { $_.Count -gt 1 } `
    #    | select -ExpandProperty Group | Get-FileHash  | group -Property Hash `
    #    | where { $_.Count -gt 1 }| foreach { $_.Group | select -Skip 1 } `
    #    | Move-Item -Destination $targetDir -Force -Verbose

  
    #B. Copy c:\windows from a regular 'winetricks dotnet35' install to the same directory ('extr')and 
    # get a list of all duplicate files, in an (almost ready) array ('choco install sed' first): 
    #$srcDir = "$env:Temp\dotnet35\wcu\dotNetFramework\dotNetFX20\extr"
    #Get-ChildItem -Path $srcDir -File -Recurse | Group -Property Length `
    # | where { $_.Count -gt 1 } | select -ExpandProperty Group | Get-FileHash `
    # | Group -Property Hash | where { $_.count -gt 1 }| foreach { $_.Group | select Path, Hash } |fl `
    # |sed '/^$/d' | sed 'N;s/\n/,/' |sed 's/Path : /(\"/g' |sed 's/,Hash : /\",\"/g' | sed  's/$/\"),`/g' >c:\list

    #C. List should look like below (some minor further manual edit); the list still contains many duplicates only present in the copied 'windows'-directory
    #so we have to filter them away: perform the code below to find the copy-operations that really should be performed,
    # and save verbose output (4>log.txt)    
    # $Qenu = @(`
    #("C:\users\louis\Temp\dotnet35\wcu\dotNetFramework\dotNetFX20\extr\windows\Microsoft.NET\assembly\GAC_MSIL\System.Web.DynamicData.Design\v4.0_4.0.0.0__31bf3856ad364e35\System.Web.DynamicData.Design.dll","002FE23572625BB228D1F4F34B6F599A8AE0A16C0EE8065D03EAC542C06378B1"),`
    #("C:\users\louis\Temp\dotnet35\wcu\dotNetFramework\dotNetFX20\extr\windows\Microsoft.NET\Framework\v4.0.30319\System.Web.DynamicData.Design.dll","002FE23572625BB228D1F4F34B6F599A8AE0A16C0EE8065D03EAC542C06378B1"),`
    #.
    #.
    #("C:\users\louis\Temp\dotnet35\wcu\dotNetFramework\dotNetFX20\extr\windows\Microsoft.NET\Framework64\v4.0.30319\System.Threading.dll","FFCBBC3F80176FD79780CB713D57C61C518DEA465B4F787139AF081BA97BF554")`
    #)

    #for ( $j = 0; $j -lt $Qenu.count; $j+=1 ) { 

    #    while ( -not ($Qenu[$j][0] -match '\\windows\\')) {
    #        $src = $Qenu[$j][0]; $src_hash = $Qenu[$j][1]
    #        while($Qenu[$j+1][1] -eq $src_hash) {copy-item -verbose -force $src $Qenu[$j+1][0]; $j++ }
    #    }
    #}
    #D. Use that verbose output to create (leafpad is your friend) the long dotnet20 list below...

    $srcpath="$env:TEMP\dotnet35\wcu\dotNetFramework\dotNetFX20\extr"

[array]$dotnet20 = `
"$srcpath\FL_EditAppSetting_aspx_resx_103113_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\AppConfig\App_LocalResources\EditAppSetting.aspx.resx",`
"$srcpath\FL_EditAppSetting_aspx_resx_103113_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\AppConfig\App_LocalResources\EditAppSetting.aspx.resx",`
"$srcpath\FL_EditAppSetting_aspx_resx_103113_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\AppConfig\App_LocalResources\EditAppSetting.aspx.resx",`
"$srcpath\FL_System_EnterpriseServices_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_32\System.EnterpriseServices\2.0.0.0__b03f5f7f11d50a3a\System.EnterpriseServices.dll",`
"$srcpath\FL_System_EnterpriseServices_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\System.EnterpriseServices.dll",`
"$srcpath\FL_System_ServiceProcess_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.ServiceProcess\2.0.0.0__b03f5f7f11d50a3a\System.ServiceProcess.dll",`
"$srcpath\FL_System_ServiceProcess_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\System.ServiceProcess.dll",`
"$srcpath\FL_System_ServiceProcess_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\System.ServiceProcess.dll",`
"$srcpath\FL_aspnet_perf2_ini_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\aspnet_perf2.ini",`
"$srcpath\FL_web_mediumtrust_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CONFIG\web_mediumtrust.config.default",`
"$srcpath\FL_web_mediumtrust_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CONFIG\web_mediumtrust.config.default",`
"$srcpath\FL_WebAdminHelp_aspx_resx_122112_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\App_LocalResources\WebAdminHelp.aspx.resx",`
"$srcpath\FL_WebAdminHelp_aspx_resx_122112_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_LocalResources\WebAdminHelp.aspx.resx",`
"$srcpath\FL_WebAdminHelp_aspx_resx_122112_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\App_LocalResources\WebAdminHelp.aspx.resx",`
"$srcpath\FL_alink_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\alink.dll",`
"$srcpath\FL_headerGRADIENT_Tall_gif_102057_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Images\headerGRADIENT_Tall.gif",`
"$srcpath\FL_headerGRADIENT_Tall_gif_102057_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\headerGRADIENT_Tall.gif",`
"$srcpath\FL_headerGRADIENT_Tall_gif_102057_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Images\headerGRADIENT_Tall.gif",`
"$srcpath\FL_dfdll_dll_75023_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\dfdll.dll",`
"$srcpath\FL_mscorsvw_exe_93402_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\mscorsvw.exe",`
"$srcpath\FL_jphone_browser_76157_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\jphone.browser",`
"$srcpath\FL_jphone_browser_76157_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\jphone.browser",`
"$srcpath\msvcp80.dll.8.0.50727.1433.844EFBA7_1C24_93B2_FF1F_C8B3B9A1E18E" , "$env:SystemRoot\winsxs\amd64_Microsoft.VC80.CRT_1fc8b3b9a1e18e3b_8.0.50727.1433_x-ww_8f022ab2\msvcp80.dll",`
"$srcpath\FL_corperfmonsymbols_ini_1_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\corperfmonsymbols.ini",`
"$srcpath\FL_corperfmonsymbols_ini_1_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\corperfmonsymbols.ini",`
"$srcpath\FL_IEExec_exe_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\IEExec.exe",`
"$srcpath\FL_home0_aspx_resx_103505_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\App_LocalResources\home0.aspx.resx",`
"$srcpath\FL_home0_aspx_resx_103505_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_LocalResources\home0.aspx.resx",`
"$srcpath\FL_home0_aspx_resx_103505_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\App_LocalResources\home0.aspx.resx",`
"$srcpath\FL_UninstallSqlStateTemplate_sql_116232_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\UninstallSqlStateTemplate.sql",`
"$srcpath\FL_UninstallSqlStateTemplate_sql_116232_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\UninstallSqlStateTemplate.sql",`
"$srcpath\FL_UninstallSqlStateTemplate_sql_116232_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\UninstallSqlStateTemplate.sql",`
"$srcpath\FL_UninstallSqlStateTemplate_sql_116232_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\UninstallSqlStateTemplate.sql",`
"$srcpath\FL_CLR_mof_uninstall_126479_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CLR.mof.uninstall",`
"$srcpath\FL_CLR_mof_uninstall_126479_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CLR.mof.uninstall",`
"$srcpath\catalog.8.0.50727.1433.63E949F6_03BC_5C40_FF1F_C8B3B9A1E18E" , "$env:SystemRoot\winsxs\Policies\x86_policy.8.0.Microsoft.VC80.CRT_1fc8b3b9a1e18e3b_x-ww_77c24773\8.0.50727.1433.cat",`
"$srcpath\Microsoft_VisualBasic_dll_2_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\Microsoft.VisualBasic\8.0.0.0__b03f5f7f11d50a3a\Microsoft.VisualBasic.dll",`
"$srcpath\Microsoft_VisualBasic_dll_2_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\Microsoft.VisualBasic.dll",`
"$srcpath\Microsoft_VisualBasic_dll_2_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\Microsoft.VisualBasic.dll",`
"$srcpath\FL_System_Configuration_Install_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.Configuration.Install\2.0.0.0__b03f5f7f11d50a3a\System.Configuration.Install.dll",`
"$srcpath\FL_System_Configuration_Install_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\System.Configuration.Install.dll",`
"$srcpath\FL_System_Configuration_Install_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\System.Configuration.Install.dll",`
"$srcpath\FL_Microsoft_Vsa_Vb_CodeDOMProcessor_tlb_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\Microsoft.Vsa.Vb.CodeDOMProcessor.tlb",`
"$srcpath\FL_webtv_browser_76167_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\webtv.browser",`
"$srcpath\FL_webtv_browser_76167_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\webtv.browser",`
"$srcpath\FL_SOS_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\SOS.dll",`
"$srcpath\FL_CLR_mof_126478_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CLR.mof",`
"$srcpath\FL_CLR_mof_126478_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CLR.mof",`
"$srcpath\FL_wizardAddUser_ascx_resx_103392_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Security\Wizard\App_LocalResources\wizardAddUser.ascx.resx",`
"$srcpath\FL_wizardAddUser_ascx_resx_103392_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Wizard\App_LocalResources\wizardAddUser.ascx.resx",`
"$srcpath\FL_wizardAddUser_ascx_resx_103392_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Security\Wizard\App_LocalResources\wizardAddUser.ascx.resx",`
"$srcpath\FL_Microsoft_Vsa_Vb_CodeDOMProcessor_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\Microsoft.Vsa.Vb.CodeDOMProcessor\8.0.0.0__b03f5f7f11d50a3a\Microsoft.Vsa.Vb.CodeDOMProcessor.dll",`
"$srcpath\FL_Microsoft_Vsa_Vb_CodeDOMProcessor_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\Microsoft.Vsa.Vb.CodeDOMProcessor.dll",`
"$srcpath\FL_xjis_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_32\mscorlib\2.0.0.0__b77a5c561934e089\xjis.nlp",`
"$srcpath\FL_xjis_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_64\mscorlib\2.0.0.0__b77a5c561934e089\xjis.nlp",`
"$srcpath\FL_xjis_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\xjis.nlp",`
"$srcpath\FL_xjis_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\xjis.nlp",`
"$srcpath\FL_NETFXSBS10_exe_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\NETFXSBS10.exe",`
"$srcpath\FL_PerfCounter_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\PerfCounter.dll",`
"$srcpath\FL_System_configuration_dll_116773_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.Configuration\2.0.0.0__b03f5f7f11d50a3a\System.configuration.dll",`
"$srcpath\FL_System_configuration_dll_116773_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\System.configuration.dll",`
"$srcpath\FL_System_configuration_dll_116773_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\System.configuration.dll",`
"$srcpath\dw20.adm_0001_1036_1036.F0DF3458_A845_11D3_8D0A_0050046416B9" , "$env:SystemRoot\inf\AER_1036.ADM",`
"$srcpath\FL_System_Windows_Forms_tlb_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\System.Windows.Forms.tlb",`
"$srcpath\FL_editUser_aspx_resx_103466_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Security\Users\App_LocalResources\editUser.aspx.resx",`
"$srcpath\FL_editUser_aspx_resx_103466_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Users\App_LocalResources\editUser.aspx.resx",`
"$srcpath\FL_editUser_aspx_resx_103466_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Security\Users\App_LocalResources\editUser.aspx.resx",`
"$srcpath\FL_cscmsgs_dll_ENU_X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\1033\cscompui.dll",`
"$srcpath\FL_chooseProviderManagement_aspx_resx_103382_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Providers\App_LocalResources\chooseProviderManagement.aspx.resx",`
"$srcpath\FL_chooseProviderManagement_aspx_resx_103382_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Providers\App_LocalResources\chooseProviderManagement.aspx.resx",`
"$srcpath\FL_chooseProviderManagement_aspx_resx_103382_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Providers\App_LocalResources\chooseProviderManagement.aspx.resx",`
"$srcpath\FL_addUser_aspx_74814_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Users\addUser.aspx",`
"$srcpath\dw20.adm_0001_1041_1041.F0DF3458_A845_11D3_8D0A_0050046416B9" , "$env:SystemRoot\inf\AER_1041.ADM",`
"$srcpath\FL_Microsoft_Build_Core_xsd_117587_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\MSBuild\Microsoft.Build.Core.xsd",`
"$srcpath\FL_Microsoft_Build_Core_xsd_117587_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\MSBuild\Microsoft.Build.Core.xsd",`
"$srcpath\FL_sbs_mscordbi_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\sbs_mscordbi.dll",`
"$srcpath\FL_aspnet_regbrowsers_exe_76177_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\aspnet_regbrowsers.exe",`
"$srcpath\FL_PasswordValueTextBox_cs_102036_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_Code\PasswordValueTextBox.cs",`
"$srcpath\FL_sbs_system_configuration_install_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\sbs_system.configuration.install.dll",`
"$srcpath\FL_Ldr64_exe_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\Ldr64.exe",`
"$srcpath\FL_ericsson_browser_76173_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\ericsson.browser",`
"$srcpath\FL_ericsson_browser_76173_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\ericsson.browser",`
"$srcpath\FL_ASPdotNET_logo_jpg_74765_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Images\ASPdotNET_logo.jpg",`
"$srcpath\FL_ASPdotNET_logo_jpg_74765_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\ASPdotNET_logo.jpg",`
"$srcpath\FL_ASPdotNET_logo_jpg_74765_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Images\ASPdotNET_logo.jpg",`
"$srcpath\FL_palm_browser_76164_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\palm.browser",`
"$srcpath\FL_palm_browser_76164_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\palm.browser",`
"$srcpath\FL_wizardCreateRoles_ascx_74818_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Wizard\wizardCreateRoles.ascx",`
"$srcpath\FL_ksc_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_32\mscorlib\2.0.0.0__b77a5c561934e089\ksc.nlp",`
"$srcpath\FL_ksc_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_64\mscorlib\2.0.0.0__b77a5c561934e089\ksc.nlp",`
"$srcpath\FL_ksc_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\ksc.nlp",`
"$srcpath\FL_ksc_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ksc.nlp",`
"$srcpath\FL_csc_exe_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\csc.exe",`
"$srcpath\FL_wizardFinish_ascx_resx_103396_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Security\Wizard\App_LocalResources\wizardFinish.ascx.resx",`
"$srcpath\FL_wizardFinish_ascx_resx_103396_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Wizard\App_LocalResources\wizardFinish.ascx.resx",`
"$srcpath\FL_wizardFinish_ascx_resx_103396_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Security\Wizard\App_LocalResources\wizardFinish.ascx.resx",`
"$srcpath\FL_ManageAppSettings_aspx_102021_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\AppConfig\ManageAppSettings.aspx",`
"$srcpath\FL_ManageAppSettings_aspx_102021_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\AppConfig\ManageAppSettings.aspx",`
"$srcpath\FL_ManageAppSettings_aspx_102021_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\AppConfig\ManageAppSettings.aspx",`
"$srcpath\FL_AssemblyList_xml_113047_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\RedistList\FrameworkList.xml",`
"$srcpath\FL_MSBuild_exe_67853_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\MSBuild.exe",`
"$srcpath\FL_security0_aspx_74806_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Security\security0.aspx",`
"$srcpath\FL_security0_aspx_74806_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\security0.aspx",`
"$srcpath\FL_security0_aspx_74806_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Security\security0.aspx",`
"$srcpath\FL_wizard_aspx_resx_103393_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Security\Wizard\App_LocalResources\wizard.aspx.resx",`
"$srcpath\FL_wizard_aspx_resx_103393_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Wizard\App_LocalResources\wizard.aspx.resx",`
"$srcpath\FL_wizard_aspx_resx_103393_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Security\Wizard\App_LocalResources\wizard.aspx.resx",`
"$srcpath\FL_InstallMembership_sql_67218_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\InstallMembership.sql",`
"$srcpath\FL_InstallMembership_sql_67218_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\InstallMembership.sql",`
"$srcpath\FL_Microsoft_VisualBasic_Vsa_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\Microsoft.VisualBasic.Vsa\8.0.0.0__b03f5f7f11d50a3a\Microsoft.VisualBasic.Vsa.dll",`
"$srcpath\FL_Microsoft_VisualBasic_Vsa_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\Microsoft.VisualBasic.Vsa.dll",`
"$srcpath\FL_normidna_nlp_93185_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_32\mscorlib\2.0.0.0__b77a5c561934e089\normidna.nlp",`
"$srcpath\FL_normidna_nlp_93185_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_64\mscorlib\2.0.0.0__b77a5c561934e089\normidna.nlp",`
"$srcpath\FL_normidna_nlp_93185_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\assembly\GAC_32\mscorlib\v4.0_4.0.0.0__b77a5c561934e089\normidna.nlp",`
"$srcpath\FL_normidna_nlp_93185_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\assembly\GAC_64\mscorlib\v4.0_4.0.0.0__b77a5c561934e089\normidna.nlp",`
"$srcpath\FL_normidna_nlp_93185_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\normidna.nlp",`
"$srcpath\FL_normidna_nlp_93185_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\normidna.nlp",`
"$srcpath\FL_normidna_nlp_93185_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\normidna.nlp",`
"$srcpath\FL_normidna_nlp_93185_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\normidna.nlp",`
"$srcpath\FL_ilasm_exe_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\ilasm.exe",`
"$srcpath\FL_System_Windows_Forms_tlb_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\System.Windows.Forms.tlb",`
"$srcpath\FL_mscorld_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\mscorld.dll",`
"$srcpath\FL_ApplicationConfigurationPage_cs_102046_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_Code\ApplicationConfigurationPage.cs",`
"$srcpath\FL_CustomMarshalers_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_32\CustomMarshalers\2.0.0.0__b03f5f7f11d50a3a\CustomMarshalers.dll",`
"$srcpath\FL_CustomMarshalers_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CustomMarshalers.dll",`
"$srcpath\FL_Accessibility_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\Accessibility\2.0.0.0__b03f5f7f11d50a3a\Accessibility.dll",`
"$srcpath\FL_Accessibility_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\Accessibility.dll",`
"$srcpath\FL_Accessibility_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\Accessibility.dll",`
"$srcpath\FL__DataPerfCounters_ini_108892_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\_DataPerfCounters.ini",`
"$srcpath\FL__DataPerfCounters_ini_108892_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\_DataPerfCounters.ini",`
"$srcpath\FL_peverify_dll_97810_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\peverify.dll",`
"$srcpath\FL_mscorld_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\mscorld.dll",`
"$srcpath\FL_Microsoft_Build_Commontypes_xsd_117588_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\MSBuild\Microsoft.Build.Commontypes.xsd",`
"$srcpath\FL_Microsoft_Build_Commontypes_xsd_117588_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\MSBuild\Microsoft.Build.Commontypes.xsd",`
"$srcpath\FL_alert_sml_gif_93379_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Images\security_watermark.jpg",`
"$srcpath\FL_alert_sml_gif_93379_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Images\selectedTab_1x1.gif",`
"$srcpath\FL_alert_sml_gif_93379_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\alert_sml.gif",`
"$srcpath\FL_alert_sml_gif_93379_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\security_watermark.jpg",`
"$srcpath\FL_alert_sml_gif_93379_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\selectedTab_1x1.gif",`
"$srcpath\FL_alert_sml_gif_93379_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Images\security_watermark.jpg",`
"$srcpath\FL_alert_sml_gif_93379_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Images\selectedTab_1x1.gif",`
"$srcpath\FL_mscorlib_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_64\mscorlib\2.0.0.0__b77a5c561934e089\mscorlib.dll",`
"$srcpath\FL_mscorlib_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\mscorlib.dll",`
"$srcpath\FL_wizardCreateRoles_ascx_resx_103397_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Security\Wizard\App_LocalResources\wizardCreateRoles.ascx.resx",`
"$srcpath\FL_wizardCreateRoles_ascx_resx_103397_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Wizard\App_LocalResources\wizardCreateRoles.ascx.resx",`
"$srcpath\FL_wizardCreateRoles_ascx_resx_103397_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Security\Wizard\App_LocalResources\wizardCreateRoles.ascx.resx",`
"$srcpath\FL_WebAdminHelp_Security_aspx_resx_122115_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\App_LocalResources\WebAdminHelp_Security.aspx.resx",`
"$srcpath\FL_WebAdminHelp_Security_aspx_resx_122115_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_LocalResources\WebAdminHelp_Security.aspx.resx",`
"$srcpath\FL_WebAdminHelp_Security_aspx_resx_122115_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\App_LocalResources\WebAdminHelp_Security.aspx.resx",`
"$srcpath\FL_webengine_dll_135889_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\webengine.dll",`
"$srcpath\FL_normnfkc_nlp_66376_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_32\mscorlib\2.0.0.0__b77a5c561934e089\normnfkc.nlp",`
"$srcpath\FL_normnfkc_nlp_66376_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_64\mscorlib\2.0.0.0__b77a5c561934e089\normnfkc.nlp",`
"$srcpath\FL_normnfkc_nlp_66376_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\normnfkc.nlp",`
"$srcpath\FL_normnfkc_nlp_66376_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\normnfkc.nlp",`
"$srcpath\FL_PerfCounter_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\PerfCounter.dll",`
"$srcpath\FL_ISymWrapper_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_64\ISymWrapper\2.0.0.0__b03f5f7f11d50a3a\ISymWrapper.dll",`
"$srcpath\FL_ISymWrapper_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ISymWrapper.dll",`
"$srcpath\FL_aspnet_compiler_exe_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\aspnet_compiler.exe",`
"$srcpath\FL_Culture_dll_102451_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\Culture.dll",`
"$srcpath\FL_wizardPermission_ascx_resx_103399_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Security\Wizard\App_LocalResources\wizardPermission.ascx.resx",`
"$srcpath\FL_wizardPermission_ascx_resx_103399_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Wizard\App_LocalResources\wizardPermission.ascx.resx",`
"$srcpath\FL_wizardPermission_ascx_resx_103399_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Security\Wizard\App_LocalResources\wizardPermission.ascx.resx",`
"$srcpath\FL_ManageConsolidatedProviders_aspx_102159_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Providers\ManageConsolidatedProviders.aspx",`
"$srcpath\FL_ManageConsolidatedProviders_aspx_102159_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Providers\ManageConsolidatedProviders.aspx",`
"$srcpath\FL_ManageConsolidatedProviders_aspx_102159_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Providers\ManageConsolidatedProviders.aspx",`
"$srcpath\mscorwks_dll_4_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\mscorwks.dll",`
"$srcpath\FL_sbs_wminet_utils_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\sbs_wminet_utils.dll",`
"$srcpath\Microsoft_Vsa_dll_2_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\Microsoft.Vsa\8.0.0.0__b03f5f7f11d50a3a\Microsoft.Vsa.dll",`
"$srcpath\Microsoft_Vsa_dll_2_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\Microsoft.Vsa.dll",`
"$srcpath\Microsoft_Vsa_dll_2_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\Microsoft.Vsa.dll",`
"$srcpath\FL__dataperfcounters_ini_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\_dataperfcounters_shared12_neutral.ini",`
"$srcpath\FL__dataperfcounters_ini_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\_dataperfcounters_shared12_neutral.ini",`
"$srcpath\FL_pie_browser_76166_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\pie.browser",`
"$srcpath\FL_pie_browser_76166_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\pie.browser",`
"$srcpath\cvtres_exe_1_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\cvtres.exe",`
"$srcpath\FL_vbc_exe_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\vbc.exe",`
"$srcpath\FL_aspnet_mof_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\aspnet.mof",`
"$srcpath\FL_aspnet_mof_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\aspnet.mof",`
"$srcpath\FL_topGradRepeat_jpg_74759_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Images\topGradRepeat.jpg",`
"$srcpath\FL_topGradRepeat_jpg_74759_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\topGradRepeat.jpg",`
"$srcpath\FL_topGradRepeat_jpg_74759_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Images\topGradRepeat.jpg",`
"$srcpath\FL_vbc7ui_dll_ENU_X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\1033\vbc7ui.dll",`
"$srcpath\FL_mscordacwks_dll_66373_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\mscordacwks.dll",`
"$srcpath\FL_wizard_aspx_74823_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Wizard\wizard.aspx",`
"$srcpath\FL_WebAdminPage_cs_74747_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_Code\WebAdminPage.cs",`
"$srcpath\FL_mscortim_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\mscortim.dll",`
"$srcpath\FL_Microsoft_Build_xsd_117586_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\Microsoft.Build.xsd",`
"$srcpath\FL_Microsoft_Build_xsd_117586_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\Microsoft.Build.xsd",`
"$srcpath\FL_XPThemes_manifest_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\XPThemes.manifest",`
"$srcpath\FL_XPThemes_manifest_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\XPThemes.manifest",`
"$srcpath\FL_XPThemes_manifest_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\XPThemes.manifest",`
"$srcpath\FL_XPThemes_manifest_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\XPThemes.manifest",`
"$srcpath\FL_System_Web_RegularExpressions_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.Web.RegularExpressions\2.0.0.0__b03f5f7f11d50a3a\System.Web.RegularExpressions.dll",`
"$srcpath\FL_System_Web_RegularExpressions_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\System.Web.RegularExpressions.dll",`
"$srcpath\FL_System_Web_RegularExpressions_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\System.Web.RegularExpressions.dll",`
"$srcpath\FL_nokia_browser_76161_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\nokia.browser",`
"$srcpath\FL_nokia_browser_76161_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\nokia.browser",`
"$srcpath\FL_managePermissions_aspx_resx_103212_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Security\Permissions\App_LocalResources\managePermissions.aspx.resx",`
"$srcpath\FL_managePermissions_aspx_resx_103212_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Permissions\App_LocalResources\managePermissions.aspx.resx",`
"$srcpath\FL_managePermissions_aspx_resx_103212_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Security\Permissions\App_LocalResources\managePermissions.aspx.resx",`
"$srcpath\FL_Microsoft_VisualC_Dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\Microsoft.VisualC\8.0.0.0__b03f5f7f11d50a3a\Microsoft.VisualC.Dll",`
"$srcpath\FL_Microsoft_VisualC_Dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\Microsoft.VisualC.Dll",`
"$srcpath\FL_Microsoft_VisualC_Dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\Microsoft.VisualC.Dll",`
"$srcpath\FL_Aspnet_perf_dll_113116_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\Aspnet_perf.dll",`
"$srcpath\FL_csc_urt_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\csc.exe.config",`
"$srcpath\FL_csc_urt_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\jsc.exe.config",`
"$srcpath\FL_csc_urt_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\vbc.exe.config",`
"$srcpath\FL_csc_urt_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\csc.exe.config",`
"$srcpath\FL_csc_urt_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\vbc.exe.config",`
"$srcpath\FL_csc_urt_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\csc.exe.config",`
"$srcpath\FL_csc_urt_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\jsc.exe.config",`
"$srcpath\FL_csc_urt_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\vbc.exe.config",`
"$srcpath\FL_csc_urt_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\csc.exe.config",`
"$srcpath\FL_csc_urt_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\vbc.exe.config",`
"$srcpath\FL_IEHost_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\IEHost\2.0.0.0__b03f5f7f11d50a3a\IEHost.dll",`
"$srcpath\FL_IEHost_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\IEHost.dll",`
"$srcpath\FL_IEHost_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\IEHost.dll",`
"$srcpath\FL_manageSingleRole_aspx_74810_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Roles\manageSingleRole.aspx",`
"$srcpath\FL_mscordacwks_dll_66373_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\mscordacwks.dll",`
"$srcpath\System.Web_dll_5_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_64\System.Web\2.0.0.0__b03f5f7f11d50a3a\System.Web.dll",`
"$srcpath\System.Web_dll_5_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\System.Web.dll",`
"$srcpath\FL_manageconsolidatedProviders_aspx_resx_103380_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Providers\App_LocalResources\manageconsolidatedProviders.aspx.resx",`
"$srcpath\FL_manageconsolidatedProviders_aspx_resx_103380_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Providers\App_LocalResources\manageconsolidatedProviders.aspx.resx",`
"$srcpath\FL_manageconsolidatedProviders_aspx_resx_103380_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Providers\App_LocalResources\manageconsolidatedProviders.aspx.resx",`
"$srcpath\FL_WebAdminStyles_css_74739_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\WebAdminStyles.css",`
"$srcpath\FL_image1_gif_74784_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Images\image1.gif",`
"$srcpath\FL_image1_gif_74784_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\image1.gif",`
"$srcpath\FL_image1_gif_74784_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Images\image1.gif",`
"$srcpath\FL_legend_browser_109072_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\legend.browser",`
"$srcpath\FL_legend_browser_109072_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\legend.browser",`
"$srcpath\FL_WebAdminHelp_Application_aspx_119290_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\ASP.NETWebAdminFiles\WebAdminHelp_Application.aspx",`
"$srcpath\FL_WebAdminHelp_Application_aspx_119290_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\WebAdminHelp_Application.aspx",`
"$srcpath\FL_WebAdminHelp_Application_aspx_119290_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\WebAdminHelp_Application.aspx",`
"$srcpath\FL_WebAdminHelp_Application_aspx_119290_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\WebAdminHelp_Application.aspx",`
"$srcpath\FL_InstallUtil_exe_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\InstallUtil.exe",`
"$srcpath\FL_System_Security_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.Security\2.0.0.0__b03f5f7f11d50a3a\System.Security.dll",`
"$srcpath\FL_System_Security_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\System.Security.dll",`
"$srcpath\FL_System_Security_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\System.Security.dll",`
"$srcpath\FL_System_EnterpriseServices_tlb_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\System.EnterpriseServices.tlb",`
"$srcpath\FL_wizardInit_ascx_resx_103398_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Security\Wizard\App_LocalResources\wizardInit.ascx.resx",`
"$srcpath\FL_wizardInit_ascx_resx_103398_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Wizard\App_LocalResources\wizardInit.ascx.resx",`
"$srcpath\FL_wizardInit_ascx_resx_103398_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Security\Wizard\App_LocalResources\wizardInit.ascx.resx",`
"$srcpath\FL_alert_lrg_gif_92834_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Images\alert_lrg.gif",`
"$srcpath\FL_alert_lrg_gif_92834_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\alert_lrg.gif",`
"$srcpath\FL_alert_lrg_gif_92834_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Images\alert_lrg.gif",`
"$srcpath\FL_aspnet_wp_exe_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\aspnet_wp.exe",`
"$srcpath\FL_fusion_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\fusion.dll",`
"$srcpath\FL_dfdll_dll_75023_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\dfdll.dll",`
"$srcpath\FL_caspol_exe_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\caspol.exe.config",`
"$srcpath\FL_caspol_exe_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\ieexec.exe.config",`
"$srcpath\FL_caspol_exe_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\ilasm.exe.config",`
"$srcpath\FL_caspol_exe_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\regasm.exe.config",`
"$srcpath\FL_caspol_exe_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\regsvcs.exe.config",`
"$srcpath\FL_caspol_exe_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\caspol.exe.config",`
"$srcpath\FL_caspol_exe_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ieexec.exe.config",`
"$srcpath\FL_caspol_exe_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ilasm.exe.config",`
"$srcpath\FL_caspol_exe_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\regasm.exe.config",`
"$srcpath\FL_caspol_exe_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\regsvcs.exe.config",`
"$srcpath\FL_aspnet_isapi_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\aspnet_isapi.dll",`
"$srcpath\dw20.adm_0001_2052_2052.F0DF3458_A845_11D3_8D0A_0050046416B9" , "$env:SystemRoot\inf\AER_2052.ADM",`
"$srcpath\FL_mscorlib_tlb_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\mscorlib.tlb",`
"$srcpath\dw20.adm_0001_1031_1031.F0DF3458_A845_11D3_8D0A_0050046416B9" , "$env:SystemRoot\inf\AER_1031.ADM",`
"$srcpath\Microsoft_VisualBasic_Compatibility_dll_2_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\Microsoft.VisualBasic.Compatibility\8.0.0.0__b03f5f7f11d50a3a\Microsoft.VisualBasic.Compatibility.dll",`
"$srcpath\Microsoft_VisualBasic_Compatibility_dll_2_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\Microsoft.VisualBasic.Compatibility.dll",`
"$srcpath\Vsavb7rtUI_dll_2_ENU_X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\1033\Vsavb7rtUI.dll",`
"$srcpath\FL_mscorie_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\mscorie.dll",`
"$srcpath\FL_webAdmin_master_74735_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\webAdmin.master",`
"$srcpath\FL_Microsoft_Common_targets_106593_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\Microsoft.Common.targets",`
"$srcpath\FL_Microsoft_Common_targets_106593_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\Microsoft.Common.targets",`
"$srcpath\vsavb7_tlb_1_____x86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\vsavb7.olb",`
"$srcpath\FL_home1_aspx_resx_103507_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\App_LocalResources\home1.aspx.resx",`
"$srcpath\FL_home1_aspx_resx_103507_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_LocalResources\home1.aspx.resx",`
"$srcpath\FL_home1_aspx_resx_103507_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\App_LocalResources\home1.aspx.resx",`
"$srcpath\msvcr80.dll.8.0.50727.1433.844EFBA7_1C24_93B2_FF1F_C8B3B9A1E18E" , "$env:SystemRoot\winsxs\amd64_Microsoft.VC80.CRT_1fc8b3b9a1e18e3b_8.0.50727.1433_x-ww_8f022ab2\msvcr80.dll",`
"$srcpath\FL_wizardProviderInfo_ascx_102277_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Security\Wizard\wizardProviderInfo.ascx",`
"$srcpath\FL_wizardProviderInfo_ascx_102277_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Wizard\wizardProviderInfo.ascx",`
"$srcpath\FL_wizardProviderInfo_ascx_102277_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Security\Wizard\wizardProviderInfo.ascx",`
"$srcpath\System.Web_dll_5_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_32\System.Web\2.0.0.0__b03f5f7f11d50a3a\System.Web.dll",`
"$srcpath\System.Web_dll_5_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\System.Web.dll",`
"$srcpath\FL_IEExec_exe_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\IEExec.exe",`
"$srcpath\FL_AppConfigHome_aspx_102015_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\AppConfig\AppConfigHome.aspx",`
"$srcpath\FL_default_aspx_74742_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\default.aspx",`
"$srcpath\FL_default_aspx_74742_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\default.aspx",`
"$srcpath\FL_default_aspx_74742_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\default.aspx",`
"$srcpath\FL_msbuild_urt_config_135103_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\msbuild.exe.config",`
"$srcpath\FL_msbuild_urt_config_135103_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\msbuild.exe.config",`
"$srcpath\FL_System_Drawing_Design_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.Drawing.Design\2.0.0.0__b03f5f7f11d50a3a\System.Drawing.Design.dll",`
"$srcpath\FL_System_Drawing_Design_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\System.Drawing.Design.dll",`
"$srcpath\FL_System_Drawing_Design_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\System.Drawing.Design.dll",`
"$srcpath\FL_System_EnterpriseServices_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_64\System.EnterpriseServices\2.0.0.0__b03f5f7f11d50a3a\System.EnterpriseServices.dll",`
"$srcpath\FL_System_EnterpriseServices_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\System.EnterpriseServices.dll",`
"$srcpath\FL_EZWap_browser_93275_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\EZWap.browser",`
"$srcpath\FL_EZWap_browser_93275_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\EZWap.browser",`
"$srcpath\FL_System_Web_tbl_105182_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\System.Web.tlb",`
"$srcpath\FL_root_web_config_comments_118268_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CONFIG\web.config.comments",`
"$srcpath\FL_root_web_config_comments_118268_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CONFIG\web.config.comments",`
"$srcpath\FL_sbs_system_data_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\sbs_system.data.dll",`
"$srcpath\FL_sysglobl_dll_92791_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\sysglobl\2.0.0.0__b03f5f7f11d50a3a\sysglobl.dll",`
"$srcpath\FL_sysglobl_dll_92791_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\sysglobl.dll",`
"$srcpath\FL_sysglobl_dll_92791_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\sysglobl.dll",`
"$srcpath\FL_web_minimaltrust_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CONFIG\web_minimaltrust.config",`
"$srcpath\FL_web_minimaltrust_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CONFIG\web_minimaltrust.config.default",`
"$srcpath\FL_web_minimaltrust_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CONFIG\web_minimaltrust.config",`
"$srcpath\FL_web_minimaltrust_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CONFIG\web_minimaltrust.config.default",`
"$srcpath\FL_netfxsbs12_hkf_76082_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\netfxsbs12.hkf",`
"$srcpath\FL_csc_exe_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\csc.exe",`
"$srcpath\FL_mscorsec_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\mscorsec.dll",`
"$srcpath\FL_mscorpe_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\mscorpe.dll",`
"$srcpath\FL_setUpAuthentication_aspx_74802_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Security\setUpAuthentication.aspx",`
"$srcpath\FL_setUpAuthentication_aspx_74802_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\setUpAuthentication.aspx",`
"$srcpath\FL_setUpAuthentication_aspx_74802_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Security\setUpAuthentication.aspx",`
"$srcpath\FL_InstallCommon_sql_74696_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\InstallCommon.sql",`
"$srcpath\FL_InstallCommon_sql_74696_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\InstallCommon.sql",`
"$srcpath\FL_InstallCommon_sql_74696_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\InstallCommon.sql",`
"$srcpath\FL_InstallCommon_sql_74696_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\InstallCommon.sql",`
"$srcpath\FL_sbs_VsaVb7rt_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\sbs_VsaVb7rt.dll",`
"$srcpath\FL_wizardAddUser_ascx_74816_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Wizard\wizardAddUser.ascx",`
"$srcpath\FL_vbc7ui_dll_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\1033\vbc7ui.dll",`
"$srcpath\FL_mscordbi_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\mscordbi.dll",`
"$srcpath\dw20.adm_0001_3082_3082.F0DF3458_A845_11D3_8D0A_0050046416B9" , "$env:SystemRoot\inf\AER_3082.ADM",`
"$srcpath\FL_DebugAndTrace_aspx_resx_103116_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\AppConfig\App_LocalResources\DebugAndTrace.aspx.resx",`
"$srcpath\FL_DebugAndTrace_aspx_resx_103116_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\AppConfig\App_LocalResources\DebugAndTrace.aspx.resx",`
"$srcpath\FL_DebugAndTrace_aspx_resx_103116_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\AppConfig\App_LocalResources\DebugAndTrace.aspx.resx",`
"$srcpath\FL_bopomofo_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_32\mscorlib\2.0.0.0__b77a5c561934e089\bopomofo.nlp",`
"$srcpath\FL_bopomofo_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_64\mscorlib\2.0.0.0__b77a5c561934e089\bopomofo.nlp",`
"$srcpath\FL_bopomofo_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\bopomofo.nlp",`
"$srcpath\FL_bopomofo_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\bopomofo.nlp",`
"$srcpath\FL_root_web_config_default_118269_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CONFIG\web.config.default",`
"$srcpath\FL_root_web_config_default_118269_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CONFIG\web.config.default",`
"$srcpath\msvcm80.dll.8.0.50727.1433.844EFBA7_1C24_93B2_FF1F_C8B3B9A1E18E" , "$env:SystemRoot\winsxs\amd64_Microsoft.VC80.CRT_1fc8b3b9a1e18e3b_8.0.50727.1433_x-ww_8f022ab2\msvcm80.dll",`
"$srcpath\FL_mscorjit_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\mscorjit.dll",`
"$srcpath\FL_diasymreader_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\diasymreader.dll",`
"$srcpath\FL_InstallRoles_sql_67224_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\InstallRoles.sql",`
"$srcpath\FL_InstallRoles_sql_67224_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\InstallRoles.sql",`
"$srcpath\FL_InstallRoles_sql_67224_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\InstallRoles.sql",`
"$srcpath\FL_InstallRoles_sql_67224_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\InstallRoles.sql",`
"$srcpath\FL_System_Web_Mobile_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.Web.Mobile\2.0.0.0__b03f5f7f11d50a3a\System.Web.Mobile.dll",`
"$srcpath\FL_System_Web_Mobile_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\System.Web.Mobile.dll",`
"$srcpath\FL_System_Web_Mobile_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\System.Web.Mobile.dll",`
"$srcpath\FL_editUser_aspx_102270_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Users\editUser.aspx",`
"$srcpath\FL_mscorsecr_dll_ENU_X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\MUI\0409\mscorsecr.dll",`
"$srcpath\FL_gradient_onWhite_gif_74776_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Images\gradient_onWhite.gif",`
"$srcpath\FL_gradient_onWhite_gif_74776_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\gradient_onWhite.gif",`
"$srcpath\FL_gradient_onWhite_gif_74776_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Images\gradient_onWhite.gif",`
"$srcpath\FL_DefineErrorPage_aspx_resx_103112_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\AppConfig\App_LocalResources\DefineErrorPage.aspx.resx",`
"$srcpath\FL_DefineErrorPage_aspx_resx_103112_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\AppConfig\App_LocalResources\DefineErrorPage.aspx.resx",`
"$srcpath\FL_DefineErrorPage_aspx_resx_103112_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\AppConfig\App_LocalResources\DefineErrorPage.aspx.resx",`
"$srcpath\FL_MmcAspExt_dll_95862_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\MmcAspExt.dll",`
"$srcpath\FL_Aspnet_regsql_exe_config_116177_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\Aspnet_regsql.exe.config",`
"$srcpath\FL_Aspnet_regsql_exe_config_116177_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\Aspnet_regsql.exe.config",`
"$srcpath\FL_UninstallWebEventSqlProvider_sql_93277_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\UninstallWebEventSqlProvider.sql",`
"$srcpath\FL_UninstallWebEventSqlProvider_sql_93277_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\UninstallWebEventSqlProvider.sql",`
"$srcpath\FL_UninstallWebEventSqlProvider_sql_93277_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\UninstallWebEventSqlProvider.sql",`
"$srcpath\FL_UninstallWebEventSqlProvider_sql_93277_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\UninstallWebEventSqlProvider.sql",`
"$srcpath\FL_AppSetting_ascx_102014_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\AppConfig\AppSetting.ascx",`
"$srcpath\FL_AppConfigCommon_resx_103538_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\App_GlobalResources\AppConfigCommon.resx",`
"$srcpath\FL_AppConfigCommon_resx_103538_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_GlobalResources\AppConfigCommon.resx",`
"$srcpath\FL_AppConfigCommon_resx_103538_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\App_GlobalResources\AppConfigCommon.resx",`
"$srcpath\FL_cscomp_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\cscomp.dll",`
"$srcpath\FL_GlobalResources_resx_103539_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_GlobalResources\GlobalResources.resx",`
"$srcpath\FL_security0_aspx_resx_103484_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Security\App_LocalResources\security0.aspx.resx",`
"$srcpath\FL_security0_aspx_resx_103484_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\App_LocalResources\security0.aspx.resx",`
"$srcpath\FL_security0_aspx_resx_103484_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Security\App_LocalResources\security0.aspx.resx",`
"$srcpath\FL_System_tlb_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\System.tlb",`
"$srcpath\FL_sbs_system_enterpriseservices_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\sbs_system.enterpriseservices.dll",`
"$srcpath\FL_adonetdiag_mof_106906_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\adonetdiag.mof",`
"$srcpath\FL_adonetdiag_mof_106906_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\adonetdiag.mof",`
"$srcpath\FL_mscorsn_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\mscorsn.dll",`
"$srcpath\FL_normnfkd_nlp_66377_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_32\mscorlib\2.0.0.0__b77a5c561934e089\normnfkd.nlp",`
"$srcpath\FL_normnfkd_nlp_66377_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_64\mscorlib\2.0.0.0__b77a5c561934e089\normnfkd.nlp",`
"$srcpath\FL_normnfkd_nlp_66377_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\normnfkd.nlp",`
"$srcpath\FL_normnfkd_nlp_66377_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\normnfkd.nlp",`
"$srcpath\FL_ISymWrapper_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_32\ISymWrapper\2.0.0.0__b03f5f7f11d50a3a\ISymWrapper.dll",`
"$srcpath\FL_ISymWrapper_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\ISymWrapper.dll",`
"$srcpath\FL_navigationBar_ascx_74730_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\navigationBar.ascx",`
"$srcpath\FL_EventLogMessages_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\EventLogMessages.dll",`
"$srcpath\FL_cscomp_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\cscomp.dll",`
"$srcpath\FL_docomo_browser_76172_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\docomo.browser",`
"$srcpath\FL_docomo_browser_76172_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\docomo.browser",`
"$srcpath\FL_MSBuildFramework_dll_70716_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\Microsoft.Build.Framework\2.0.0.0__b03f5f7f11d50a3a\Microsoft.Build.Framework.dll",`
"$srcpath\FL_MSBuildFramework_dll_70716_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\Microsoft.Build.Framework.dll",`
"$srcpath\FL_MSBuildFramework_dll_70716_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\Microsoft.Build.Framework.dll",`
"$srcpath\FL_InstallPersonalization_sql_67221_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\InstallPersonalization.sql",`
"$srcpath\FL_InstallPersonalization_sql_67221_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\InstallPersonalization.sql",`
"$srcpath\FL_InstallPersonalization_sql_67221_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\InstallPersonalization.sql",`
"$srcpath\FL_InstallPersonalization_sql_67221_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\InstallPersonalization.sql",`
"$srcpath\FL_CORPerfMonExt_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CORPerfMonExt.dll",`
"$srcpath\FL_ilasm_exe_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ilasm.exe",`
"$srcpath\FL_web_config_74734_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\web.config",`
"$srcpath\FL_WebAdminHelp_Security_aspx_119294_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\ASP.NETWebAdminFiles\WebAdminHelp_Security.aspx",`
"$srcpath\FL_WebAdminHelp_Security_aspx_119294_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\WebAdminHelp_Security.aspx",`
"$srcpath\FL_WebAdminHelp_Security_aspx_119294_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\WebAdminHelp_Security.aspx",`
"$srcpath\FL_WebAdminHelp_Security_aspx_119294_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\WebAdminHelp_Security.aspx",`
"$srcpath\FL_CvtResUI_dll_109387_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\1033\CvtResUI.dll",`
"$srcpath\FL_aspnet_perf_ini_ENU_X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\aspnet_perf.ini",`
"$srcpath\FL_System_Data_OracleClient_dll_2_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_64\System.Data.OracleClient\2.0.0.0__b77a5c561934e089\System.Data.OracleClient.dll",`
"$srcpath\FL_System_Data_OracleClient_dll_2_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\System.Data.OracleClient.dll",`
"$srcpath\FL_TLBREF_DLL_97713_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\TLBREF.DLL",`
"$srcpath\FL_mscorlib_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_32\mscorlib\2.0.0.0__b77a5c561934e089\mscorlib.dll",`
"$srcpath\FL_mscorlib_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\mscorlib.dll",`
"$srcpath\FL_aspnet_wp_exe_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\aspnet_wp.exe",`
"$srcpath\FL_shfusion_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\shfusion.dll",`
"$srcpath\FL_normalization_dll_66379_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\normalization.dll",`
"$srcpath\FL_sbs_microsoft_vsa_vb_codedomprocessor_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\sbs_microsoft.vsa.vb.codedomprocessor.dll",`
"$srcpath\FL_Jataayu_browser_93274_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\Jataayu.browser",`
"$srcpath\FL_Jataayu_browser_93274_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\Jataayu.browser",`
"$srcpath\FL_yellowCORNER_gif_74760_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Images\yellowCORNER.gif",`
"$srcpath\FL_yellowCORNER_gif_74760_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\yellowCORNER.gif",`
"$srcpath\FL_yellowCORNER_gif_74760_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Images\yellowCORNER.gif",`
"$srcpath\FL_System_Data_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_32\System.Data\2.0.0.0__b77a5c561934e089\System.Data.dll",`
"$srcpath\FL_System_Data_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\System.Data.dll",`
"$srcpath\FL_createPermission_aspx_resx_103211_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Security\Permissions\App_LocalResources\createPermission.aspx.resx",`
"$srcpath\FL_createPermission_aspx_resx_103211_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Permissions\App_LocalResources\createPermission.aspx.resx",`
"$srcpath\FL_createPermission_aspx_resx_103211_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Security\Permissions\App_LocalResources\createPermission.aspx.resx",`
"$srcpath\dw20.adm_1025_1025.D0DF3458_A845_11D3_8D0A_0050046416B9" , "$env:SystemRoot\inf\AER_1025.ADM",`
"$srcpath\FL_System_Data_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_64\System.Data\2.0.0.0__b77a5c561934e089\System.Data.dll",`
"$srcpath\FL_System_Data_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\System.Data.dll",`
"$srcpath\manifest.8.0.50727.1433.4F6D20F0_CCE5_1492_FF1F_C8B3B9A1E18E" , "$env:SystemRoot\winsxs\Policies\amd64_policy.8.0.Microsoft.VC80.CRT_1fc8b3b9a1e18e3b_x-ww_d780e993\8.0.50727.1433.policy",`
"$srcpath\FL_aspnet_compiler_exe_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\aspnet_compiler.exe",`
"$srcpath\FL_WebAdminHelp_Internals_aspx_resx_122113_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\App_LocalResources\WebAdminHelp_Internals.aspx.resx",`
"$srcpath\FL_WebAdminHelp_Internals_aspx_resx_122113_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_LocalResources\WebAdminHelp_Internals.aspx.resx",`
"$srcpath\FL_WebAdminHelp_Internals_aspx_resx_122113_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\App_LocalResources\WebAdminHelp_Internals.aspx.resx",`
"$srcpath\FL_normalization_dll_66379_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\normalization.dll",`
"$srcpath\FL_fusion_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\fusion.dll",`
"$srcpath\FL_aspnet_state_exe_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\aspnet_state.exe",`
"$srcpath\FL_webAdminNoButtonRow_master_74738_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\webAdminNoButtonRow.master",`
"$srcpath\FL_webAdminNoButtonRow_master_74738_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\webAdminNoButtonRow.master",`
"$srcpath\FL_webAdminNoButtonRow_master_74738_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\webAdminNoButtonRow.master",`
"$srcpath\FL_MmcAspExt_dll_95862_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\MmcAspExt.dll",`
"$srcpath\FL_requiredBang_gif_74755_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Images\requiredBang.gif",`
"$srcpath\FL_requiredBang_gif_74755_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\requiredBang.gif",`
"$srcpath\FL_requiredBang_gif_74755_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Images\requiredBang.gif",`
"$srcpath\FL_aspnet_rc_dll_1_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\aspnet_rc.dll",`
"$srcpath\FL_aspnet_filter_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\aspnet_filter.dll",`
"$srcpath\FL_System_Web_tbl_105182_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\System.Web.tlb",`
"$srcpath\FL_default_aspx_resx_103509_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\App_LocalResources\default.aspx.resx",`
"$srcpath\FL_default_aspx_resx_103509_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_LocalResources\default.aspx.resx",`
"$srcpath\FL_default_aspx_resx_103509_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\App_LocalResources\default.aspx.resx",`
"$srcpath\FL_folder_gif_74774_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Images\folder.gif",`
"$srcpath\FL_folder_gif_74774_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\folder.gif",`
"$srcpath\FL_folder_gif_74774_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Images\folder.gif",`
"$srcpath\FL_avantgo_browser_76169_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\avantgo.browser",`
"$srcpath\FL_avantgo_browser_76169_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\avantgo.browser",`
"$srcpath\Microsoft_VisualBasic_Compatibility_Data_dll_2_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\Microsoft.VisualBasic.Compatibility.Data\8.0.0.0__b03f5f7f11d50a3a\Microsoft.VisualBasic.Compatibility.Data.dll",`
"$srcpath\Microsoft_VisualBasic_Compatibility_Data_dll_2_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\Microsoft.VisualBasic.Compatibility.Data.dll",`
"$srcpath\FL_UninstallPersonalization_sql_67220_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\UninstallPersonalization.sql",`
"$srcpath\FL_UninstallPersonalization_sql_67220_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\UninstallPersonalization.sql",`
"$srcpath\FL_UninstallPersonalization_sql_67220_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\UninstallPersonalization.sql",`
"$srcpath\FL_UninstallPersonalization_sql_67220_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\UninstallPersonalization.sql",`
"$srcpath\FL_aspnet_isapi_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\aspnet_isapi.dll",`
"$srcpath\FL_regtlib_exe_1_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\regtlibv12.exe",`
"$srcpath\catalog.8.0.50727.1433.844EFBA7_1C24_93B2_FF1F_C8B3B9A1E18E" , "$env:SystemRoot\winsxs\manifests\amd64_Microsoft.VC80.CRT_1fc8b3b9a1e18e3b_8.0.50727.1433_x-ww_8f022ab2.cat",`
"$srcpath\FL_vbc_rsp_76080_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\vbc.rsp",`
"$srcpath\FL_vbc_rsp_76080_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\vbc.rsp",`
"$srcpath\FL_findUsers_aspx_resx_103468_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Security\Users\App_LocalResources\findUsers.aspx.resx",`
"$srcpath\FL_findUsers_aspx_resx_103468_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Users\App_LocalResources\findUsers.aspx.resx",`
"$srcpath\FL_findUsers_aspx_resx_103468_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Security\Users\App_LocalResources\findUsers.aspx.resx",`
"$srcpath\FL_generic_browser_76175_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\generic.browser",`
"$srcpath\FL_generic_browser_76175_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\generic.browser",`
"$srcpath\FL_ProviderList_ascx_92846_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Providers\ProviderList.ascx",`
"$srcpath\FL_navigationBar_ascx_resx_103510_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\App_LocalResources\navigationBar.ascx.resx",`
"$srcpath\FL_navigationBar_ascx_resx_103510_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_LocalResources\navigationBar.ascx.resx",`
"$srcpath\FL_navigationBar_ascx_resx_103510_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\App_LocalResources\navigationBar.ascx.resx",`
"$srcpath\FL_AppSetting_ascx_resx_103115_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\AppConfig\App_LocalResources\AppSetting.ascx.resx",`
"$srcpath\FL_AppSetting_ascx_resx_103115_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\AppConfig\App_LocalResources\AppSetting.ascx.resx",`
"$srcpath\FL_AppSetting_ascx_resx_103115_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\AppConfig\App_LocalResources\AppSetting.ascx.resx",`
"$srcpath\FL_wizardAuthentication_ascx_74817_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Security\Wizard\wizardAuthentication.ascx",`
"$srcpath\FL_wizardAuthentication_ascx_74817_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Wizard\wizardAuthentication.ascx",`
"$srcpath\FL_wizardAuthentication_ascx_74817_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Security\Wizard\wizardAuthentication.ascx",`
"$srcpath\FL_System_Transactions_dll_75016_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_32\System.Transactions\2.0.0.0__b77a5c561934e089\System.Transactions.dll",`
"$srcpath\FL_System_Transactions_dll_75016_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\System.Transactions.dll",`
"$srcpath\FL_goAmerica_browser_76155_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\goAmerica.browser",`
"$srcpath\FL_goAmerica_browser_76155_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\goAmerica.browser",`
"$srcpath\FL_aspnet_state_perf_ini_76106_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\aspnet_state_perf.ini",`
"$srcpath\FL_aspnet_state_perf_ini_76106_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\aspnet_state_perf.ini",`
"$srcpath\VsaVb7rt_dll_2_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\VsaVb7rt.dll",`
"$srcpath\dw20.adm_0001_1042_1042.F0DF3458_A845_11D3_8D0A_0050046416B9" , "$env:SystemRoot\inf\AER_1042.ADM",`
"$srcpath\jsc_exe_1_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\jsc.exe",`
"$srcpath\FL_big5_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_32\mscorlib\2.0.0.0__b77a5c561934e089\big5.nlp",`
"$srcpath\FL_big5_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_64\mscorlib\2.0.0.0__b77a5c561934e089\big5.nlp",`
"$srcpath\FL_big5_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\big5.nlp",`
"$srcpath\FL_big5_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\big5.nlp",`
"$srcpath\FL_cassio_browser_76170_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\cassio.browser",`
"$srcpath\FL_cassio_browser_76170_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\cassio.browser",`
"$srcpath\dw20.adm_0001_1040_1040.F0DF3458_A845_11D3_8D0A_0050046416B9" , "$env:SystemRoot\inf\AER_1040.ADM",`
"$srcpath\FL_mscorsvc_dll_93043_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\mscorsvc.dll",`
"$srcpath\FL_UninstallPersistSqlState_sql_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\UninstallPersistSqlState.sql",`
"$srcpath\FL_UninstallPersistSqlState_sql_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\UninstallPersistSqlState.sql",`
"$srcpath\FL_UninstallPersistSqlState_sql_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\UninstallPersistSqlState.sql",`
"$srcpath\FL_UninstallPersistSqlState_sql_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\UninstallPersistSqlState.sql",`
"$srcpath\FL_aspx_file_gif_102053_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Images\aspx_file.gif",`
"$srcpath\FL_aspx_file_gif_102053_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\aspx_file.gif",`
"$srcpath\FL_aspx_file_gif_102053_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Images\aspx_file.gif",`
"$srcpath\FL_sbs_microsoft_jscript_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\sbs_microsoft.jscript.dll",`
"$srcpath\FL_AspNetMMCExt_dll_66806_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\AspNetMMCExt\2.0.0.0__b03f5f7f11d50a3a\AspNetMMCExt.dll",`
"$srcpath\FL_AspNetMMCExt_dll_66806_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\AspNetMMCExt.dll",`
"$srcpath\FL_AdoNetDiag_dll_106905_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\AdoNetDiag.dll",`
"$srcpath\FL_machine_config_comments_105748_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CONFIG\machine.config.comments",`
"$srcpath\FL_machine_config_comments_105748_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CONFIG\machine.config.comments",`
"$srcpath\FL_chooseProviderManagement_aspx_102160_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Providers\chooseProviderManagement.aspx",`
"$srcpath\FL_chooseProviderManagement_aspx_102160_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Providers\chooseProviderManagement.aspx",`
"$srcpath\FL_chooseProviderManagement_aspx_102160_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Providers\chooseProviderManagement.aspx",`
"$srcpath\mscorwks_dll_4_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\mscorwks.dll",`
"$srcpath\FL_mscordbc_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\mscordbc.dll",`
"$srcpath\FL_Culture_dll_102451_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\Culture.dll",`
"$srcpath\FL_Microsoft_BuildTasks_67856_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\Microsoft.Common.Tasks",`
"$srcpath\FL_Microsoft_BuildTasks_67856_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\Microsoft.Common.Tasks",`
"$srcpath\FL_mscorjit_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\mscorjit.dll",`
"$srcpath\FL_regsvcs_exe_config_79704_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v1.1.4322\regsvcs.exe.config",`
"$srcpath\FL_vbc_exe_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\vbc.exe",`
"$srcpath\FL_error_aspx_resx_103504_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\App_LocalResources\error.aspx.resx",`
"$srcpath\FL_error_aspx_resx_103504_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_LocalResources\error.aspx.resx",`
"$srcpath\FL_error_aspx_resx_103504_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\App_LocalResources\error.aspx.resx",`
"$srcpath\FL_GroupedProviders_xml_117816_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\App_Data\GroupedProviders.xml",`
"$srcpath\FL_GroupedProviders_xml_117816_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_Data\GroupedProviders.xml",`
"$srcpath\FL_GroupedProviders_xml_117816_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\App_Data\GroupedProviders.xml",`
"$srcpath\FL_aspnet_regbrowsers_exe_76177_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\aspnet_regbrowsers.exe",`
"$srcpath\FL_Aspnet_perf_dll_113116_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\Aspnet_perf.dll",`
"$srcpath\FL_mscories_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\syswow64\mscories.dll",`
"$srcpath\FL_manageAllRoles_aspx_resx_103495_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Security\Roles\App_LocalResources\manageAllRoles.aspx.resx",`
"$srcpath\FL_manageAllRoles_aspx_resx_103495_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Roles\App_LocalResources\manageAllRoles.aspx.resx",`
"$srcpath\FL_manageAllRoles_aspx_resx_103495_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Security\Roles\App_LocalResources\manageAllRoles.aspx.resx",`
"$srcpath\FL_error_aspx_74743_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\error.aspx",`
"$srcpath\FL_error_aspx_74743_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\error.aspx",`
"$srcpath\FL_error_aspx_74743_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\error.aspx",`
"$srcpath\FL__DataPerfCounters_h_108891_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\_DataPerfCounters.h",`
"$srcpath\FL__DataPerfCounters_h_108891_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\_DataPerfCounters.h",`
"$srcpath\FL__DataPerfCounters_h_108891_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\_DataPerfCounters.h",`
"$srcpath\FL__DataPerfCounters_h_108891_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\_DataPerfCounters.h",`
"$srcpath\manifest.8.0.50727.1433.63E949F6_03BC_5C40_FF1F_C8B3B9A1E18E" , "$env:SystemRoot\winsxs\Policies\x86_policy.8.0.Microsoft.VC80.CRT_1fc8b3b9a1e18e3b_x-ww_77c24773\8.0.50727.1433.policy",`
"$srcpath\FL_webhightrust_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CONFIG\web_hightrust.config.default",`
"$srcpath\FL_webhightrust_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CONFIG\web_hightrust.config.default",`
"$srcpath\FL_System_DeploymentFramework_dll_66796_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.Deployment\2.0.0.0__b03f5f7f11d50a3a\System.Deployment.dll",`
"$srcpath\FL_System_DeploymentFramework_dll_66796_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\System.Deployment.dll",`
"$srcpath\FL_System_DeploymentFramework_dll_66796_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\System.Deployment.dll",`
"$srcpath\FL_UninstallSqlState_sql_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\UninstallSqlState.sql",`
"$srcpath\FL_UninstallSqlState_sql_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\UninstallSqlState.sql",`
"$srcpath\FL_UninstallSqlState_sql_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\UninstallSqlState.sql",`
"$srcpath\FL_UninstallSqlState_sql_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\UninstallSqlState.sql",`
"$srcpath\FL_ngen_exe_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\ngen.exe",`
"$srcpath\FL_aspnet_rc_dll_1_ENU_X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\aspnet_rc.dll",`
"$srcpath\FL_System_Data_SqlXml_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.Data.SqlXml\2.0.0.0__b77a5c561934e089\System.Data.SqlXml.dll",`
"$srcpath\FL_System_Data_SqlXml_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\System.Data.SqlXml.dll",`
"$srcpath\FL_System_Data_SqlXml_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\System.Data.SqlXml.dll",`
"$srcpath\FL_darkBlue_GRAD_jpg_74769_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Images\darkBlue_GRAD.jpg",`
"$srcpath\FL_darkBlue_GRAD_jpg_74769_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\darkBlue_GRAD.jpg",`
"$srcpath\FL_darkBlue_GRAD_jpg_74769_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Images\darkBlue_GRAD.jpg",`
"$srcpath\FL_UnInstallProfile_SQL_104242_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\UnInstallProfile.SQL",`
"$srcpath\FL_UnInstallProfile_SQL_104242_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\UnInstallProfile.SQL",`
"$srcpath\FL_UnInstallProfile_SQL_104242_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\UnInstallProfile.SQL",`
"$srcpath\FL_UnInstallProfile_SQL_104242_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\UnInstallProfile.SQL",`
"$srcpath\FL_wizardFinish_ascx_74819_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Security\Wizard\wizardFinish.ascx",`
"$srcpath\FL_wizardFinish_ascx_74819_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Wizard\wizardFinish.ascx",`
"$srcpath\FL_wizardFinish_ascx_74819_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Security\Wizard\wizardFinish.ascx",`
"$srcpath\msvcm80.dll.8.0.50727.1433.98CB24AD_52FB_DB5F_FF1F_C8B3B9A1E18E" , "$env:SystemRoot\winsxs\x86_Microsoft.VC80.CRT_1fc8b3b9a1e18e3b_8.0.50727.1433_x-ww_5cf844d2\msvcm80.dll",`
"$srcpath\FL_InstallPersistSqlState_sql_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\InstallPersistSqlState.sql",`
"$srcpath\FL_InstallPersistSqlState_sql_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\InstallPersistSqlState.sql",`
"$srcpath\FL_manageUsers_aspx_74815_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Users\manageUsers.aspx",`
"$srcpath\FL__Networkingperfcounters_ini_1_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\_Networkingperfcounters.ini",`
"$srcpath\FL__Networkingperfcounters_ini_1_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\_Networkingperfcounters.ini",`
"$srcpath\FL_mscorpe_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\mscorpe.dll",`
"$srcpath\FL_MSBuildTasks_dll_67855_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\Microsoft.Build.Tasks\2.0.0.0__b03f5f7f11d50a3a\Microsoft.Build.Tasks.dll",`
"$srcpath\FL_MSBuildTasks_dll_67855_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\Microsoft.Build.Tasks.dll",`
"$srcpath\FL_MSBuildTasks_dll_67855_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\Microsoft.Build.Tasks.dll",`
"$srcpath\FL__DataOracleClientPerfCounters_shared12__106790_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\_DataOracleClientPerfCounters_shared12_neutral.h",`
"$srcpath\FL__DataOracleClientPerfCounters_shared12__106790_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\_dataperfcounters_shared12_neutral.h",`
"$srcpath\FL__DataOracleClientPerfCounters_shared12__106790_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\_DataOracleClientPerfCounters_shared12_neutral.h",`
"$srcpath\FL__DataOracleClientPerfCounters_shared12__106790_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\_dataperfcounters_shared12_neutral.h",`
"$srcpath\FL__DataOracleClientPerfCounters_shared12__106790_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\_DataOracleClientPerfCounters_shared12_neutral.h",`
"$srcpath\FL__DataOracleClientPerfCounters_shared12__106790_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\_dataperfcounters_shared12_neutral.h",`
"$srcpath\FL__DataOracleClientPerfCounters_shared12__106790_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\_DataOracleClientPerfCounters_shared12_neutral.h",`
"$srcpath\FL__DataOracleClientPerfCounters_shared12__106790_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\_dataperfcounters_shared12_neutral.h",`
"$srcpath\FL_InstallUtilLib_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\InstallUtilLib.dll",`
"$srcpath\FL_Microsoft_VisualBasic_targets_106592_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\Microsoft.VisualBasic.targets",`
"$srcpath\FL_Microsoft_VisualBasic_targets_106592_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\Microsoft.VisualBasic.targets",`
"$srcpath\Microsoft_Vsa_tlb_1_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\Microsoft.Vsa.tlb",`
"$srcpath\FL_System_EnterpriseServices_Thunk_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\System.EnterpriseServices.Thunk.dll",`
"$srcpath\FL_almsgs_dll_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\1033\alinkui.dll",`
"$srcpath\ShFusRes_dll_1_ENU_X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\ShFusRes.dll",`
"$srcpath\FL_System_DirectoryServices_Protocols_dll_101362_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.DirectoryServices.Protocols\2.0.0.0__b03f5f7f11d50a3a\System.DirectoryServices.Protocols.dll",`
"$srcpath\FL_System_DirectoryServices_Protocols_dll_101362_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\System.DirectoryServices.Protocols.dll",`
"$srcpath\FL_System_DirectoryServices_Protocols_dll_101362_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\System.DirectoryServices.Protocols.dll",`
"$srcpath\FL_home2_aspx_74746_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\home2.aspx",`
"$srcpath\FL_home2_aspx_74746_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\home2.aspx",`
"$srcpath\FL_home2_aspx_74746_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\home2.aspx",`
"$srcpath\manifest.8.0.50727.1433.844EFBA7_1C24_93B2_FF1F_C8B3B9A1E18E" , "$env:SystemRoot\winsxs\manifests\amd64_Microsoft.VC80.CRT_1fc8b3b9a1e18e3b_8.0.50727.1433_x-ww_8f022ab2.manifest",`
"$srcpath\FL_System_Management_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.Management\2.0.0.0__b03f5f7f11d50a3a\System.Management.dll",`
"$srcpath\FL_System_Management_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\System.Management.dll",`
"$srcpath\FL_System_Management_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\System.Management.dll",`
"$srcpath\FL_SmtpSettings_aspx_resx_103109_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\AppConfig\App_LocalResources\SmtpSettings.aspx.resx",`
"$srcpath\FL_SmtpSettings_aspx_resx_103109_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\AppConfig\App_LocalResources\SmtpSettings.aspx.resx",`
"$srcpath\FL_SmtpSettings_aspx_resx_103109_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\AppConfig\App_LocalResources\SmtpSettings.aspx.resx",`
"$srcpath\FL_EditAppSetting_aspx_102020_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\AppConfig\EditAppSetting.aspx",`
"$srcpath\FL_EditAppSetting_aspx_102020_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\AppConfig\EditAppSetting.aspx",`
"$srcpath\FL_EditAppSetting_aspx_102020_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\AppConfig\EditAppSetting.aspx",`
"$srcpath\FL_WebAdminHelp_Provider_aspx_119293_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\ASP.NETWebAdminFiles\WebAdminHelp_Provider.aspx",`
"$srcpath\FL_WebAdminHelp_Provider_aspx_119293_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\WebAdminHelp_Provider.aspx",`
"$srcpath\FL_WebAdminHelp_Provider_aspx_119293_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\WebAdminHelp_Provider.aspx",`
"$srcpath\FL_WebAdminHelp_Provider_aspx_119293_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\WebAdminHelp_Provider.aspx",`
"$srcpath\FL_AdoNetDiag_dll_106905_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\AdoNetDiag.dll",`
"$srcpath\FL_managePermissions_aspx_74808_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Permissions\managePermissions.aspx",`
"$srcpath\FL_InstallUtilLib_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\InstallUtilLib.dll",`
"$srcpath\FL_WebAdminHelp_aspx_119289_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\ASP.NETWebAdminFiles\WebAdminHelp.aspx",`
"$srcpath\FL_WebAdminHelp_aspx_119289_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\WebAdminHelp.aspx",`
"$srcpath\FL_WebAdminHelp_aspx_119289_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\WebAdminHelp.aspx",`
"$srcpath\FL_WebAdminHelp_aspx_119289_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\WebAdminHelp.aspx",`
"$srcpath\cvtres_exe_1_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\cvtres.exe",`
"$srcpath\FL_branding_Full2_gif_102054_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Images\branding_Full2.gif",`
"$srcpath\FL_branding_Full2_gif_102054_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\branding_Full2.gif",`
"$srcpath\FL_branding_Full2_gif_102054_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Images\branding_Full2.gif",`
"$srcpath\FL_selectedTab_leftCorner_gif_102049_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Images\selectedTab_leftCorner.gif",`
"$srcpath\FL_selectedTab_leftCorner_gif_102049_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Images\unSelectedTab_leftCorner.gif",`
"$srcpath\FL_selectedTab_leftCorner_gif_102049_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\selectedTab_leftCorner.gif",`
"$srcpath\FL_selectedTab_leftCorner_gif_102049_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\unSelectedTab_leftCorner.gif",`
"$srcpath\FL_selectedTab_leftCorner_gif_102049_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Images\selectedTab_leftCorner.gif",`
"$srcpath\FL_selectedTab_leftCorner_gif_102049_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Images\unSelectedTab_leftCorner.gif",`
"$srcpath\FL_RegSvcs_exe_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\RegSvcs.exe",`
"$srcpath\FL_RegSvcs_exe_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\RegSvcs.exe",`
"$srcpath\FL_IEExecRemote_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\IEExecRemote\2.0.0.0__b03f5f7f11d50a3a\IEExecRemote.dll",`
"$srcpath\FL_IEExecRemote_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\IEExecRemote.dll",`
"$srcpath\FL_IEExecRemote_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\IEExecRemote.dll",`
"$srcpath\FL_InstallProfile_SQL_104241_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\InstallProfile.SQL",`
"$srcpath\FL_InstallProfile_SQL_104241_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\InstallProfile.SQL",`
"$srcpath\FL_InstallProfile_SQL_104241_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\InstallProfile.SQL",`
"$srcpath\FL_InstallProfile_SQL_104241_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\InstallProfile.SQL",`
"$srcpath\FL_webAdminButtonRow_master_74737_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\webAdminButtonRow.master",`
"$srcpath\FL_webAdminButtonRow_master_74737_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\webAdminButtonRow.master",`
"$srcpath\FL_webAdminButtonRow_master_74737_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\webAdminButtonRow.master",`
"$srcpath\FL_manageSingleRole_aspx_resx_103494_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Security\Roles\App_LocalResources\manageSingleRole.aspx.resx",`
"$srcpath\FL_manageSingleRole_aspx_resx_103494_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Roles\App_LocalResources\manageSingleRole.aspx.resx",`
"$srcpath\FL_manageSingleRole_aspx_resx_103494_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Security\Roles\App_LocalResources\manageSingleRole.aspx.resx",`
"$srcpath\FL_System_EnterpriseServices_Wrapper_dll_76457_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_32\System.EnterpriseServices\2.0.0.0__b03f5f7f11d50a3a\System.EnterpriseServices.Wrapper.dll",`
"$srcpath\FL_System_EnterpriseServices_Wrapper_dll_76457_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\System.EnterpriseServices.Wrapper.dll",`
"$srcpath\mscoree_tlb_1_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\mscoree.tlb",`
"$srcpath\FL_mscories_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\system32\mscories.dll",`
"$srcpath\FL_InstallSqlStateTemplate_sql_116231_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\InstallSqlStateTemplate.sql",`
"$srcpath\FL_InstallSqlStateTemplate_sql_116231_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\InstallSqlStateTemplate.sql",`
"$srcpath\FL_AppConfigHome_aspx_resx_103114_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\AppConfig\App_LocalResources\AppConfigHome.aspx.resx",`
"$srcpath\FL_AppConfigHome_aspx_resx_103114_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\AppConfig\App_LocalResources\AppConfigHome.aspx.resx",`
"$srcpath\FL_AppConfigHome_aspx_resx_103114_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\AppConfig\App_LocalResources\AppConfigHome.aspx.resx",`
"$srcpath\FL_security_aspx_74800_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\security.aspx",`
"$srcpath\FL_WizardPage_cs_102042_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_Code\WizardPage.cs",`
"$srcpath\FL_manageUsers_aspx_resx_103467_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Security\Users\App_LocalResources\manageUsers.aspx.resx",`
"$srcpath\FL_manageUsers_aspx_resx_103467_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Users\App_LocalResources\manageUsers.aspx.resx",`
"$srcpath\FL_manageUsers_aspx_resx_103467_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Security\Users\App_LocalResources\manageUsers.aspx.resx",`
"$srcpath\FL_System_tlb_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\System.tlb",`
"$srcpath\FL_wizardPermission_ascx_74822_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Wizard\wizardPermission.ascx",`
"$srcpath\FL_xiino_browser_76168_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\xiino.browser",`
"$srcpath\FL_xiino_browser_76168_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\xiino.browser",`
"$srcpath\FL_AppLaunch_exe_111659_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\AppLaunch.exe",`
"$srcpath\FL_webAdminNoNavBar_master_102339_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\webAdminNoNavBar.master",`
"$srcpath\FL_webAdminNoNavBar_master_102339_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\webAdminNoNavBar.master",`
"$srcpath\FL_webAdminNoNavBar_master_102339_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\webAdminNoNavBar.master",`
"$srcpath\FL_almsgs_dll_ENU_X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\1033\alinkui.dll",`
"$srcpath\FL_aspnet_regiis_exe_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\aspnet_regiis.exe",`
"$srcpath\FL__DataOracleClientPerfCounters_shared12__106788_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\_DataOracleClientPerfCounters_shared12_neutral.ini",`
"$srcpath\FL__DataOracleClientPerfCounters_shared12__106788_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\_DataOracleClientPerfCounters_shared12_neutral.ini",`
"$srcpath\FL_cscompmgd_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\cscompmgd\8.0.0.0__b03f5f7f11d50a3a\cscompmgd.dll",`
"$srcpath\FL_cscompmgd_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\cscompmgd.dll",`
"$srcpath\FL_cscompmgd_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\cscompmgd.dll",`
"$srcpath\FL_confirmation_ascx_resx_110690_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Security\Wizard\App_LocalResources\confirmation.ascx.resx",`
"$srcpath\FL_confirmation_ascx_resx_110690_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Wizard\App_LocalResources\confirmation.ascx.resx",`
"$srcpath\FL_confirmation_ascx_resx_110690_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Security\Wizard\App_LocalResources\confirmation.ascx.resx",`
"$srcpath\jsc_exe_1_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\jsc.exe",`
"$srcpath\FL_TLBREF_DLL_97713_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\TLBREF.DLL",`
"$srcpath\FL_findUsers_aspx_102268_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Users\findUsers.aspx",`
"$srcpath\FL_UninstallMembership_sql_67219_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\UninstallMembership.sql",`
"$srcpath\FL_UninstallMembership_sql_67219_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\UninstallMembership.sql",`
"$srcpath\FL_UninstallMembership_sql_67219_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\UninstallMembership.sql",`
"$srcpath\FL_UninstallMembership_sql_67219_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\UninstallMembership.sql",`
"$srcpath\FL_peverify_dll_97810_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\peverify.dll",`
"$srcpath\FL_webengine_dll_135889_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\webengine.dll",`
"$srcpath\FL_csc_rsp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\csc.rsp",`
"$srcpath\FL_csc_rsp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\csc.rsp",`
"$srcpath\FL_WebAdminHelp_Provider_aspx_resx_122114_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\App_LocalResources\WebAdminHelp_Provider.aspx.resx",`
"$srcpath\FL_WebAdminHelp_Provider_aspx_resx_122114_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_LocalResources\WebAdminHelp_Provider.aspx.resx",`
"$srcpath\FL_WebAdminHelp_Provider_aspx_resx_122114_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\App_LocalResources\WebAdminHelp_Provider.aspx.resx",`
"$srcpath\FL_home0_aspx_74744_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\home0.aspx",`
"$srcpath\FL_home0_aspx_74744_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\home0.aspx",`
"$srcpath\FL_home0_aspx_74744_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\home0.aspx",`
"$srcpath\FL_InstallSqlState_sql_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\InstallSqlState.sql",`
"$srcpath\FL_InstallSqlState_sql_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\InstallSqlState.sql",`
"$srcpath\FL_weblowtrust_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CONFIG\web_lowtrust.config",`
"$srcpath\FL_weblowtrust_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CONFIG\web_lowtrust.config.default",`
"$srcpath\FL_weblowtrust_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CONFIG\web_lowtrust.config",`
"$srcpath\FL_weblowtrust_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CONFIG\web_lowtrust.config.default",`
"$srcpath\FL_System_Messaging_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.Messaging\2.0.0.0__b03f5f7f11d50a3a\System.Messaging.dll",`
"$srcpath\FL_System_Messaging_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\System.Messaging.dll",`
"$srcpath\FL_System_Messaging_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\System.Messaging.dll",`
"$srcpath\Microsoft_VsaVb_dll_3_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\Microsoft_VsaVb\8.0.0.0__b03f5f7f11d50a3a\Microsoft_VsaVb.dll",`
"$srcpath\Microsoft_VsaVb_dll_3_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\Microsoft_VsaVb.dll",`
"$srcpath\FL_shfusion_chm_121725_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\shfusion.chm",`
"$srcpath\FL_shfusion_chm_121725_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\shfusion.chm",`
"$srcpath\FL_ProvidersPage_cs_102040_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_Code\ProvidersPage.cs",`
"$srcpath\FL_sbs_mscorrc_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\sbs_mscorrc.dll",`
"$srcpath\FL_ManageProviders_aspx_92850_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Providers\ManageProviders.aspx",`
"$srcpath\FL_ManageProviders_aspx_92850_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Providers\ManageProviders.aspx",`
"$srcpath\FL_ManageProviders_aspx_92850_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Providers\ManageProviders.aspx",`
"$srcpath\FL_Aspnet_config_117583_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\Aspnet.config",`
"$srcpath\FL_Aspnet_config_117583_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\Aspnet.config",`
"$srcpath\FL_CasPol_exe_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CasPol.exe",`
"$srcpath\FL_confirmation_ascx_102278_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Wizard\confirmation.ascx",`
"$srcpath\FL_WebAdminHelp_Internals_aspx_119291_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\ASP.NETWebAdminFiles\WebAdminHelp_Internals.aspx",`
"$srcpath\FL_WebAdminHelp_Internals_aspx_119291_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\WebAdminHelp_Internals.aspx",`
"$srcpath\FL_WebAdminHelp_Internals_aspx_119291_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\WebAdminHelp_Internals.aspx",`
"$srcpath\FL_WebAdminHelp_Internals_aspx_119291_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\WebAdminHelp_Internals.aspx",`
"$srcpath\FL_System_Runtime_Serialization_Formatters_Soap_dl_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.Runtime.Serialization.Formatters.Soap\2.0.0.0__b03f5f7f11d50a3a\System.Runtime.Serialization.Formatters.Soap.dll",`
"$srcpath\FL_System_Runtime_Serialization_Formatters_Soap_dl_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\System.Runtime.Serialization.Formatters.Soap.dll",`
"$srcpath\FL_System_Runtime_Serialization_Formatters_Soap_dl_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\System.Runtime.Serialization.Formatters.Soap.dll",`
"$srcpath\FL_DefineErrorPage_aspx_102019_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\AppConfig\DefineErrorPage.aspx",`
"$srcpath\prcp_nlp_1_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_32\mscorlib\2.0.0.0__b77a5c561934e089\prcp.nlp",`
"$srcpath\prcp_nlp_1_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_64\mscorlib\2.0.0.0__b77a5c561934e089\prcp.nlp",`
"$srcpath\prcp_nlp_1_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\prcp.nlp",`
"$srcpath\prcp_nlp_1_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\prcp.nlp",`
"$srcpath\FL_System_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System\2.0.0.0__b77a5c561934e089\System.dll",`
"$srcpath\FL_System_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\System.dll",`
"$srcpath\FL_System_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\System.dll",`
"$srcpath\FL_aspnet_perf2_ini_ENU_X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\aspnet_perf2.ini",`
"$srcpath\FL_WebAdminWithConfirmationNoButtonRow_mas_102343_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\WebAdminWithConfirmationNoButtonRow.master",`
"$srcpath\FL_System_XML_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.Xml\2.0.0.0__b77a5c561934e089\System.XML.dll",`
"$srcpath\FL_System_XML_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\System.XML.dll",`
"$srcpath\FL_System_XML_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\System.XML.dll",`
"$srcpath\FL_mscorsec_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\mscorsec.dll",`
"$srcpath\FL_sbs_iehost_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\sbs_iehost.dll",`
"$srcpath\FL_CreateAppSetting_aspx_resx_103117_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\AppConfig\App_LocalResources\CreateAppSetting.aspx.resx",`
"$srcpath\FL_CreateAppSetting_aspx_resx_103117_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\AppConfig\App_LocalResources\CreateAppSetting.aspx.resx",`
"$srcpath\FL_CreateAppSetting_aspx_resx_103117_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\AppConfig\App_LocalResources\CreateAppSetting.aspx.resx",`
"$srcpath\FL_wizardInit_ascx_74820_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Security\Wizard\wizardInit.ascx",`
"$srcpath\FL_wizardInit_ascx_74820_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Wizard\wizardInit.ascx",`
"$srcpath\FL_wizardInit_ascx_74820_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Security\Wizard\wizardInit.ascx",`
"$srcpath\FL_mscorlib_tlb_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\mscorlib.tlb",`
"$srcpath\FL_aspnet_filter_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\aspnet_filter.dll",`
"$srcpath\FL_System_DeploymentFramework_Service_exe_66797_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\dfsvc.exe",`
"$srcpath\FL_System_EnterpriseServices_tlb_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\System.EnterpriseServices.tlb",`
"$srcpath\FL_machine_config_105746_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CONFIG\machine.config.default",`
"$srcpath\FL_machine_config_105746_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CONFIG\machine.config.default",`
"$srcpath\FL_NavigationBar_cs_102045_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_Code\NavigationBar.cs",`
"$srcpath\FL_manageProviders_aspx_resx_103379_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Providers\App_LocalResources\manageProviders.aspx.resx",`
"$srcpath\FL_manageProviders_aspx_resx_103379_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Providers\App_LocalResources\manageProviders.aspx.resx",`
"$srcpath\FL_manageProviders_aspx_resx_103379_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Providers\App_LocalResources\manageProviders.aspx.resx",`
"$srcpath\FL_sorttbls_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_32\mscorlib\2.0.0.0__b77a5c561934e089\sorttbls.nlp",`
"$srcpath\FL_sorttbls_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_64\mscorlib\2.0.0.0__b77a5c561934e089\sorttbls.nlp",`
"$srcpath\FL_sorttbls_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\sorttbls.nlp",`
"$srcpath\FL_sorttbls_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\sorttbls.nlp",`
"$srcpath\catalog.8.0.50727.1433.4F6D20F0_CCE5_1492_FF1F_C8B3B9A1E18E" , "$env:SystemRoot\winsxs\Policies\amd64_policy.8.0.Microsoft.VC80.CRT_1fc8b3b9a1e18e3b_x-ww_d780e993\8.0.50727.1433.cat",`
"$srcpath\FL_aspnet_perf_ini_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\aspnet_perf.ini",`
"$srcpath\FL_CvtResUI_dll_109387_ENU_X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\1033\CvtResUI.dll",`
"$srcpath\FL_WebAdminHelp_Application_aspx_resx_122111_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\App_LocalResources\WebAdminHelp_Application.aspx.resx",`
"$srcpath\FL_WebAdminHelp_Application_aspx_resx_122111_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_LocalResources\WebAdminHelp_Application.aspx.resx",`
"$srcpath\FL_WebAdminHelp_Application_aspx_resx_122111_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\App_LocalResources\WebAdminHelp_Application.aspx.resx",`
"$srcpath\FL_Default_browser_76171_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\Default.browser",`
"$srcpath\FL_Default_browser_76171_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\Default.browser",`
"$srcpath\FL_CustomMarshalers_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_64\CustomMarshalers\2.0.0.0__b03f5f7f11d50a3a\CustomMarshalers.dll",`
"$srcpath\FL_CustomMarshalers_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CustomMarshalers.dll",`
"$srcpath\Microsoft.JScript_tlb_2_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\Microsoft.JScript.tlb",`
"$srcpath\FL_gateway_browser_76174_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\gateway.browser",`
"$srcpath\FL_gateway_browser_76174_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\gateway.browser",`
"$srcpath\FL_createPermission_aspx_74809_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Permissions\createPermission.aspx",`
"$srcpath\CORPerfMonSymbols_h_1_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CORPerfMonSymbols.h",`
"$srcpath\CORPerfMonSymbols_h_1_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\CORPerfMonSymbols.h",`
"$srcpath\CORPerfMonSymbols_h_1_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CORPerfMonSymbols.h",`
"$srcpath\CORPerfMonSymbols_h_1_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\CORPerfMonSymbols.h",`
"$srcpath\FL_SecurityPage_cs_102041_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_Code\SecurityPage.cs",`
"$srcpath\mscoree_tlb_1_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\mscoree.tlb",`
"$srcpath\FL_MME_browser_76158_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\MME.browser",`
"$srcpath\FL_MME_browser_76158_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\MME.browser",`
"$srcpath\FL_wizardAuthentication_ascx_resx_103395_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Security\Wizard\App_LocalResources\wizardAuthentication.ascx.resx",`
"$srcpath\FL_wizardAuthentication_ascx_resx_103395_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Wizard\App_LocalResources\wizardAuthentication.ascx.resx",`
"$srcpath\FL_wizardAuthentication_ascx_resx_103395_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Security\Wizard\App_LocalResources\wizardAuthentication.ascx.resx",`
"$srcpath\FL_aspnet_mof_uninstall_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\aspnet.mof.uninstall",`
"$srcpath\FL_aspnet_mof_uninstall_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\aspnet.mof.uninstall",`
"$srcpath\FL_aspnet_mof_uninstall_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\aspnet.mof.uninstall",`
"$srcpath\FL_aspnet_mof_uninstall_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\aspnet.mof.uninstall",`
"$srcpath\catalog.8.0.50727.1433.98CB24AD_52FB_DB5F_FF1F_C8B3B9A1E18E" , "$env:SystemRoot\winsxs\manifests\x86_Microsoft.VC80.CRT_1fc8b3b9a1e18e3b_8.0.50727.1433_x-ww_5cf844d2.cat",`
"$srcpath\FL_ie_browser_76156_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\ie.browser",`
"$srcpath\FL_ie_browser_76156_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\ie.browser",`
"$srcpath\FL_SOS_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\SOS.dll",`
"$srcpath\FL_SmtpSettings_aspx_102013_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\AppConfig\SmtpSettings.aspx",`
"$srcpath\FL_AppLaunch_exe_111659_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\AppLaunch.exe",`
"$srcpath\FL_setUpAuthentication_aspx_resx_103482_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Security\App_LocalResources\setUpAuthentication.aspx.resx",`
"$srcpath\FL_setUpAuthentication_aspx_resx_103482_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\App_LocalResources\setUpAuthentication.aspx.resx",`
"$srcpath\FL_setUpAuthentication_aspx_resx_103482_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Security\App_LocalResources\setUpAuthentication.aspx.resx",`
"$srcpath\FL_providerList_ascx_resx_103378_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Providers\App_LocalResources\providerList.ascx.resx",`
"$srcpath\FL_providerList_ascx_resx_103378_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Providers\App_LocalResources\providerList.ascx.resx",`
"$srcpath\FL_providerList_ascx_resx_103378_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Providers\App_LocalResources\providerList.ascx.resx",`
"$srcpath\FL_image2_gif_74785_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Images\image2.gif",`
"$srcpath\FL_image2_gif_74785_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\image2.gif",`
"$srcpath\FL_image2_gif_74785_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Images\image2.gif",`
"$srcpath\FL_CasPol_exe_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CasPol.exe",`
"$srcpath\FL_ManageAppSettings_aspx_resx_103111_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\AppConfig\App_LocalResources\ManageAppSettings.aspx.resx",`
"$srcpath\FL_ManageAppSettings_aspx_resx_103111_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\AppConfig\App_LocalResources\ManageAppSettings.aspx.resx",`
"$srcpath\FL_ManageAppSettings_aspx_resx_103111_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\AppConfig\App_LocalResources\ManageAppSettings.aspx.resx",`
"$srcpath\FL_winwap_browser_109069_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\winwap.browser",`
"$srcpath\FL_winwap_browser_109069_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\winwap.browser",`
"$srcpath\FL__NetworkingPerfCounters_h_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\_NetworkingPerfCounters.h",`
"$srcpath\FL__NetworkingPerfCounters_h_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\_NetworkingPerfCounters_v2.h",`
"$srcpath\FL__NetworkingPerfCounters_h_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\_NetworkingPerfCounters.h",`
"$srcpath\FL__NetworkingPerfCounters_h_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\_NetworkingPerfCounters_v2.h",`
"$srcpath\FL_mscorsecr_dll_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\MUI\0409\mscorsecr.dll",`
"$srcpath\FL_InstallUtil_exe_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\InstallUtil.exe",`
"$srcpath\FL_regtlib_exe_1_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\regtlibv12.exe",`
"$srcpath\FL_HelpIcon_solid_gif_102058_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Images\HelpIcon_solid.gif",`
"$srcpath\FL_HelpIcon_solid_gif_102058_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\HelpIcon_solid.gif",`
"$srcpath\FL_HelpIcon_solid_gif_102058_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Images\HelpIcon_solid.gif",`
"$srcpath\FL_selectedTab_rightCorner_gif_102050_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Images\selectedTab_rightCorner.gif",`
"$srcpath\FL_selectedTab_rightCorner_gif_102050_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Images\unSelectedTab_rightCorner.gif",`
"$srcpath\FL_selectedTab_rightCorner_gif_102050_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\selectedTab_rightCorner.gif",`
"$srcpath\FL_selectedTab_rightCorner_gif_102050_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\unSelectedTab_rightCorner.gif",`
"$srcpath\FL_selectedTab_rightCorner_gif_102050_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Images\selectedTab_rightCorner.gif",`
"$srcpath\FL_selectedTab_rightCorner_gif_102050_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Images\unSelectedTab_rightCorner.gif",`
"$srcpath\FL_System_Drawing_tlb_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\System.Drawing.tlb",`
"$srcpath\FL_MSBuildEngine_dll_67852_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\Microsoft.Build.Engine\2.0.0.0__b03f5f7f11d50a3a\Microsoft.Build.Engine.dll",`
"$srcpath\FL_MSBuildEngine_dll_67852_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\Microsoft.Build.Engine.dll",`
"$srcpath\FL_MSBuildEngine_dll_67852_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\Microsoft.Build.Engine.dll",`
"$srcpath\FL_wizardProviderInfo_ascx_resx_103394_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Security\Wizard\App_LocalResources\wizardProviderInfo.ascx.resx",`
"$srcpath\FL_wizardProviderInfo_ascx_resx_103394_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Wizard\App_LocalResources\wizardProviderInfo.ascx.resx",`
"$srcpath\FL_wizardProviderInfo_ascx_resx_103394_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Security\Wizard\App_LocalResources\wizardProviderInfo.ascx.resx",`
"$srcpath\dw20.adm_0001_1033.F0DF3458_A845_11D3_8D0A_0050046416B9" , "$env:SystemRoot\inf\AER_1033.ADM",`
"$srcpath\FL_MSBuild_rsp_113422_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\MSBuild.rsp",`
"$srcpath\FL_MSBuild_rsp_113422_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\MSBuild.rsp",`
"$srcpath\FL_MSBuild_rsp_113422_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\MSBuild.rsp",`
"$srcpath\FL_MSBuild_rsp_113422_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\MSBuild.rsp",`
"$srcpath\FL_MSBuild_rsp_113422_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\MSBuild.rsp",`
"$srcpath\FL_MSBuild_rsp_113422_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\MSBuild.rsp",`
"$srcpath\FL_mscorsn_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\mscorsn.dll",`
"$srcpath\Microsoft.JScript_dll_2_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\Microsoft.JScript\8.0.0.0__b03f5f7f11d50a3a\Microsoft.JScript.dll",`
"$srcpath\Microsoft.JScript_dll_2_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\Microsoft.JScript.dll",`
"$srcpath\Microsoft.JScript_dll_2_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\Microsoft.JScript.dll",`
"$srcpath\FL_diasymreader_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\diasymreader.dll",`
"$srcpath\FL_sbs_mscorsec_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\sbs_mscorsec.dll",`
"$srcpath\FL_MSBuildUtilities_dll_70717_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\Microsoft.Build.Utilities\2.0.0.0__b03f5f7f11d50a3a\Microsoft.Build.Utilities.dll",`
"$srcpath\FL_MSBuildUtilities_dll_70717_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\Microsoft.Build.Utilities.dll",`
"$srcpath\FL_MSBuildUtilities_dll_70717_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\Microsoft.Build.Utilities.dll",`
"$srcpath\FL_mscortim_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\mscortim.dll",`
"$srcpath\FL_aspnet_regsql_exe_73568_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\aspnet_regsql.exe",`
"$srcpath\msvcr80.dll.8.0.50727.1433.98CB24AD_52FB_DB5F_FF1F_C8B3B9A1E18E" , "$env:SystemRoot\winsxs\x86_Microsoft.VC80.CRT_1fc8b3b9a1e18e3b_8.0.50727.1433_x-ww_5cf844d2\msvcr80.dll",`
"$srcpath\FL_cscmsgs_dll_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\1033\cscompui.dll",`
"$srcpath\FL_aspnet_regsql_exe_73568_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\aspnet_regsql.exe",`
"$srcpath\FL_mozilla_browser_76159_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\mozilla.browser",`
"$srcpath\FL_mozilla_browser_76159_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\mozilla.browser",`
"$srcpath\FL_home2_aspx_resx_103508_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\App_LocalResources\home2.aspx.resx",`
"$srcpath\FL_home2_aspx_resx_103508_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_LocalResources\home2.aspx.resx",`
"$srcpath\FL_home2_aspx_resx_103508_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\App_LocalResources\home2.aspx.resx",`
"$srcpath\FL_WebAdminWithConfirmation_master_92851_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\WebAdminWithConfirmation.master",`
"$srcpath\FL_home1_aspx_74745_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\home1.aspx",`
"$srcpath\FL_home1_aspx_74745_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\home1.aspx",`
"$srcpath\FL_home1_aspx_74745_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\home1.aspx",`
"$srcpath\FL_WMINet_Utils_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\WMINet_Utils.dll",`
"$srcpath\FL_System_Drawing_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.Drawing\2.0.0.0__b03f5f7f11d50a3a\System.Drawing.dll",`
"$srcpath\FL_System_Drawing_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\System.Drawing.dll",`
"$srcpath\FL_System_Drawing_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\System.Drawing.dll",`
"$srcpath\FL_RegAsm_exe_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\RegAsm.exe",`
"$srcpath\FL_netscape_browser_76160_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\netscape.browser",`
"$srcpath\FL_netscape_browser_76160_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\netscape.browser",`
"$srcpath\Microsoft.JScript_tlb_2_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\Microsoft.JScript.tlb",`
"$srcpath\msvcp80.dll.8.0.50727.1433.98CB24AD_52FB_DB5F_FF1F_C8B3B9A1E18E" , "$env:SystemRoot\winsxs\x86_Microsoft.VC80.CRT_1fc8b3b9a1e18e3b_8.0.50727.1433_x-ww_5cf844d2\msvcp80.dll",`
"$srcpath\FL_EventLogMessages_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\EventLogMessages.dll",`
"$srcpath\dw20.adm_0001_1028_1028.F0DF3458_A845_11D3_8D0A_0050046416B9" , "$env:SystemRoot\inf\AER_1028.ADM",`
"$srcpath\mscorrc_dll_2_ENU_X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\mscorrc.dll",`
"$srcpath\FL_alink_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\alink.dll",`
"$srcpath\FL_MSBuild_exe_67853_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\MSBuild.exe",`
"$srcpath\FL_CORPerfMonExt_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CORPerfMonExt.dll",`
"$srcpath\FL_IIEHost_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\IIEHost\2.0.0.0__b03f5f7f11d50a3a\IIEHost.dll",`
"$srcpath\FL_IIEHost_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\IIEHost.dll",`
"$srcpath\FL_IIEHost_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\IIEHost.dll",`
"$srcpath\FL_aspnet_state_perf_h_76107_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\aspnet_state_perf.h",`
"$srcpath\FL_aspnet_state_perf_h_76107_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\aspnet_state_perf.h",`
"$srcpath\FL_ngen_exe_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ngen.exe",`
"$srcpath\filler" , "$env:SystemRoot\dotnet48.installed.workaround",`
"$srcpath\filler" , "$env:SystemRoot\assembly\NativeImages_v2.0.50727_32\index24.dat",`
"$srcpath\filler" , "$env:SystemRoot\assembly\NativeImages_v2.0.50727_32\index25.dat",`
"$srcpath\filler" , "$env:SystemRoot\assembly\NativeImages_v2.0.50727_64\index31.dat",`
"$srcpath\filler" , "$env:SystemRoot\Installer\wix{F5B09CFD-F0B2-36AF-8DF4-1DF6B63FC7B4}.SchedServiceConfig.rmi",`
"$srcpath\manifest.8.0.50727.1433.98CB24AD_52FB_DB5F_FF1F_C8B3B9A1E18E" , "$env:SystemRoot\winsxs\manifests\x86_Microsoft.VC80.CRT_1fc8b3b9a1e18e3b_8.0.50727.1433_x-ww_5cf844d2.manifest",`
"$srcpath\FL_opera_browser_76163_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\opera.browser",`
"$srcpath\FL_opera_browser_76163_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\opera.browser",`
"$srcpath\FL_normnfc_nlp_66374_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_32\mscorlib\2.0.0.0__b77a5c561934e089\normnfc.nlp",`
"$srcpath\FL_normnfc_nlp_66374_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_64\mscorlib\2.0.0.0__b77a5c561934e089\normnfc.nlp",`
"$srcpath\FL_normnfc_nlp_66374_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\normnfc.nlp",`
"$srcpath\FL_normnfc_nlp_66374_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\normnfc.nlp",`
"$srcpath\FL_sbs_diasymreader_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\sbs_diasymreader.dll",`
"$srcpath\FL_System_Web_Services_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.Web.Services\2.0.0.0__b03f5f7f11d50a3a\System.Web.Services.dll",`
"$srcpath\FL_System_Web_Services_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\System.Web.Services.dll",`
"$srcpath\FL_System_Web_Services_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\System.Web.Services.dll",`
"$srcpath\FL_System_Runtime_Remoting_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.Runtime.Remoting\2.0.0.0__b77a5c561934e089\System.Runtime.Remoting.dll",`
"$srcpath\FL_System_Runtime_Remoting_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\System.Runtime.Remoting.dll",`
"$srcpath\FL_System_Runtime_Remoting_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\System.Runtime.Remoting.dll",`
"$srcpath\FL_aspnet_perf_h_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\aspnet_perf.h",`
"$srcpath\FL_aspnet_perf_h_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\aspnet_perf.h",`
"$srcpath\FL_gacutil_exe_config_79703_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v1.1.4322\gacutil.exe.config",`
"$srcpath\FL_aspnet_regiis_exe_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\aspnet_regiis.exe",`
"$srcpath\FL_mscorsvc_dll_93043_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\mscorsvc.dll",`
"$srcpath\FL_UninstallRoles_sql_67222_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\UninstallRoles.sql",`
"$srcpath\FL_UninstallRoles_sql_67222_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\UninstallRoles.sql",`
"$srcpath\FL_UninstallRoles_sql_67222_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\UninstallRoles.sql",`
"$srcpath\FL_UninstallRoles_sql_67222_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\UninstallRoles.sql",`
"$srcpath\FL_help_jpg_74778_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Images\help.jpg",`
"$srcpath\FL_help_jpg_74778_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\help.jpg",`
"$srcpath\FL_help_jpg_74778_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Images\help.jpg",`
"$srcpath\FL_gradient_onBlue_gif_74775_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Images\gradient_onBlue.gif",`
"$srcpath\FL_gradient_onBlue_gif_74775_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\gradient_onBlue.gif",`
"$srcpath\FL_gradient_onBlue_gif_74775_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Images\gradient_onBlue.gif",`
"$srcpath\FL_System_Design_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.Design\2.0.0.0__b03f5f7f11d50a3a\System.Design.dll",`
"$srcpath\FL_System_Design_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\System.Design.dll",`
"$srcpath\FL_System_Design_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\System.Design.dll",`
"$srcpath\FL_Microsoft_CSharp_targets_106591_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\Microsoft.CSharp.targets",`
"$srcpath\FL_Microsoft_CSharp_targets_106591_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\Microsoft.CSharp.targets",`
"$srcpath\FL_System_Transactions_dll_75016_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_64\System.Transactions\2.0.0.0__b77a5c561934e089\System.Transactions.dll",`
"$srcpath\FL_System_Transactions_dll_75016_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\System.Transactions.dll",`
"$srcpath\FL_mscorpjt_dll_93058_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\mscorpjt.dll",`
"$srcpath\FL_System_EnterpriseServices_Thunk_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\System.EnterpriseServices.Thunk.dll",`
"$srcpath\FL_mscordbc_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\mscordbc.dll",`
"$srcpath\FL_prc_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_32\mscorlib\2.0.0.0__b77a5c561934e089\prc.nlp",`
"$srcpath\FL_prc_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_64\mscorlib\2.0.0.0__b77a5c561934e089\prc.nlp",`
"$srcpath\FL_prc_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\prc.nlp",`
"$srcpath\FL_prc_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\prc.nlp",`
"$srcpath\FL_DefaultWsdlHelpGenerator_aspx_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CONFIG\DefaultWsdlHelpGenerator.aspx",`
"$srcpath\FL_DefaultWsdlHelpGenerator_aspx_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CONFIG\DefaultWsdlHelpGenerator.aspx",`
"$srcpath\FL_System_EnterpriseServices_Wrapper_dll_76457_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_64\System.EnterpriseServices\2.0.0.0__b03f5f7f11d50a3a\System.EnterpriseServices.Wrapper.dll",`
"$srcpath\FL_System_EnterpriseServices_Wrapper_dll_76457_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\System.EnterpriseServices.Wrapper.dll",`
"$srcpath\FL_mscorie_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\mscorie.dll",`
"$srcpath\FL_DebugAndTrace_aspx_102018_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\AppConfig\DebugAndTrace.aspx",`
"$srcpath\FL_shfusion_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\shfusion.dll",`
"$srcpath\FL_addUser_aspx_resx_103469_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Security\Users\App_LocalResources\addUser.aspx.resx",`
"$srcpath\FL_addUser_aspx_resx_103469_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Users\App_LocalResources\addUser.aspx.resx",`
"$srcpath\FL_addUser_aspx_resx_103469_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Security\Users\App_LocalResources\addUser.aspx.resx",`
"$srcpath\FL_System_DeploymentFramework_Service_exe_66797_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\dfsvc.exe",`
"$srcpath\FL_mscorsvw_exe_93402_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\mscorsvw.exe",`
"$srcpath\FL_System_Data_OracleClient_dll_2_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_32\System.Data.OracleClient\2.0.0.0__b77a5c561934e089\System.Data.OracleClient.dll",`
"$srcpath\FL_System_Data_OracleClient_dll_2_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\System.Data.OracleClient.dll",`
"$srcpath\FL_UninstallCommon_sql_74697_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\UninstallCommon.sql",`
"$srcpath\FL_UninstallCommon_sql_74697_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\UninstallCommon.sql",`
"$srcpath\FL_UninstallCommon_sql_74697_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\UninstallCommon.sql",`
"$srcpath\FL_UninstallCommon_sql_74697_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\UninstallCommon.sql",`
"$srcpath\ShFusRes_dll_1_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ShFusRes.dll",`
"$srcpath\FL_SYSTEM_WINDOWS_FORMS_DLL_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.Windows.Forms\2.0.0.0__b77a5c561934e089\System.Windows.Forms.dll",`
"$srcpath\FL_SYSTEM_WINDOWS_FORMS_DLL_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\System.Windows.Forms.dll",`
"$srcpath\FL_SYSTEM_WINDOWS_FORMS_DLL_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\System.Windows.Forms.dll",`
"$srcpath\Microsoft_Vsa_tlb_1_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\Microsoft.Vsa.tlb",`
"$srcpath\FL_manageAllRoles_aspx_74812_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Roles\manageAllRoles.aspx",`
"$srcpath\FL_AssemblyList_xml_113047_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\RedistList\FrameworkList.xml",`
"$srcpath\FL_openwave_browser_76162_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\openwave.browser",`
"$srcpath\FL_openwave_browser_76162_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\openwave.browser",`
"$srcpath\FL_mscordbi_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\mscordbi.dll",`
"$srcpath\FL_dv_aspnetmmc_chm_121991_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\dv_aspnetmmc.chm",`
"$srcpath\FL_dv_aspnetmmc_chm_121991_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\dv_aspnetmmc.chm",`
"$srcpath\FL_dv_aspnetmmc_chm_121991_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\dv_aspnetmmc.chm",`
"$srcpath\FL_dv_aspnetmmc_chm_121991_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\dv_aspnetmmc.chm",`
"$srcpath\FL_panasonic_browser_76165_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\panasonic.browser",`
"$srcpath\FL_panasonic_browser_76165_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\panasonic.browser",`
"$srcpath\FL_System_Drawing_tlb_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\System.Drawing.tlb",`
"$srcpath\FL_WMINet_Utils_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\WMINet_Utils.dll",`
"$srcpath\FL_CreateAppSetting_aspx_102017_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\AppConfig\CreateAppSetting.aspx",`
"$srcpath\FL_CreateAppSetting_aspx_102017_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\AppConfig\CreateAppSetting.aspx",`
"$srcpath\FL_CreateAppSetting_aspx_102017_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\AppConfig\CreateAppSetting.aspx",`
"$srcpath\FL_System_DirectoryServices_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.DirectoryServices\2.0.0.0__b03f5f7f11d50a3a\System.DirectoryServices.dll",`
"$srcpath\FL_System_DirectoryServices_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\System.DirectoryServices.dll",`
"$srcpath\FL_System_DirectoryServices_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\System.DirectoryServices.dll",`
"$srcpath\FL_sbscmp10_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\sbscmp20_mscorlib.dll",`
"$srcpath\FL_InstallWebEventSqlProvider_sql_93276_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\InstallWebEventSqlProvider.sql",`
"$srcpath\FL_InstallWebEventSqlProvider_sql_93276_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\InstallWebEventSqlProvider.sql",`
"$srcpath\FL_InstallWebEventSqlProvider_sql_93276_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\InstallWebEventSqlProvider.sql",`
"$srcpath\FL_InstallWebEventSqlProvider_sql_93276_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\InstallWebEventSqlProvider.sql",`
"$srcpath\FL_deselectedTab_1x1_gif_102056_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Images\deselectedTab_1x1.gif",`
"$srcpath\FL_deselectedTab_1x1_gif_102056_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\deselectedTab_1x1.gif",`
"$srcpath\FL_deselectedTab_1x1_gif_102056_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Images\deselectedTab_1x1.gif",`
"$srcpath\mscorrc_dll_2_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\mscorrc.dll",`
"$srcpath\FL_normnfd_nlp_66375_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_32\mscorlib\2.0.0.0__b77a5c561934e089\normnfd.nlp",`
"$srcpath\FL_normnfd_nlp_66375_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_64\mscorlib\2.0.0.0__b77a5c561934e089\normnfd.nlp",`
"$srcpath\FL_normnfd_nlp_66375_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\normnfd.nlp",`
"$srcpath\FL_normnfd_nlp_66375_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\normnfd.nlp",`
"$srcpath\FL_security_aspx_resx_103483_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Security\App_LocalResources\security.aspx.resx",`
"$srcpath\FL_security_aspx_resx_103483_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\App_LocalResources\security.aspx.resx",`
"$srcpath\FL_security_aspx_resx_103483_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\ASP.NETWebAdminFiles\Security\App_LocalResources\security.aspx.resx",`
"$srcpath\FL_sortkey_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_32\mscorlib\2.0.0.0__b77a5c561934e089\sortkey.nlp",`
"$srcpath\FL_sortkey_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_64\mscorlib\2.0.0.0__b77a5c561934e089\sortkey.nlp",`
"$srcpath\FL_sortkey_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\sortkey.nlp",`
"$srcpath\FL_sortkey_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\sortkey.nlp"

for ( $j = 0; $j -lt $dotnet20.count; $j+=2 ) {
    Copy-Item -recurse -Path $dotnet20[$j] -Destination ( Join-Path (New-item -Type Directory -Force $(Split-Path -Path $dotnet20[$j+1]))   $(Split-Path -Leaf $dotnet20[$j+1])   ) -Force  -Verbose }


7z x $env:TEMP\\$dldir\\wcu\\dotNetFramework\\dotNetFX35\\x64\\netfx35_x64.exe "-o$env:TEMP\\$dldir\\wcu\\dotNetFramework\\dotNetFX35\\x64" -y;
7z x $env:TEMP\\$dldir\\wcu\\dotNetFramework\\dotNetFX35\\x64\\vs_setup.cab "-o$env:TEMP\\$dldir\\wcu\\dotNetFramework\\dotNetFX35\\extr" -y;

    $srcpath="$env:TEMP\dotnet35\wcu\dotNetFramework\dotNetFX35\extr"

[array]$dotnet35 = `
"$srcpath\System.Net_dll_x86_gc.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.Net\3.5.0.0__b03f5f7f11d50a3a\System.Net.dll",`
"$srcpath\WapRes_dll_amd64_heb.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1037.dll",`
"$srcpath\FL_npwpf_dll_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\Windows Presentation Foundation\NPWPF.dll",`
"$srcpath\FL_eula_exp_txt_amd64_chs.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.2052.rtf",`
"$srcpath\FL_DirectoryServices_AccountManagement_dll_Gac_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.DirectoryServices.AccountManagement\3.5.0.0__b77a5c561934e089\System.DirectoryServices.AccountManagement.dll",`
"$srcpath\FL_setupres_dll_amd64_cht.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1028.dll",`
"$srcpath\FL_logo_bmp_97496_97496_cn_enu.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\logo.bmp",`
"$srcpath\policy.21022.08.policy_9_0_Microsoft_VC90_CRT_x86.RTM" , "$env:SystemRoot\winsxs\Policies\x86_policy.9.0.Microsoft.VC90.CRT_1fc8b3b9a1e18e3b_x-ww_b7353f75\9.0.21022.8.policy",`
"$srcpath\FL_setupres_dll_amd64_dan.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1030.dll",`
"$srcpath\msvcp90.dll.21022.08.Microsoft_VC90_CRT_x64.RTM" , "$env:SystemRoot\winsxs\amd64_Microsoft.VC90.CRT_1fc8b3b9a1e18e3b_9.0.21022.8_x-ww_0296e955\msvcp90.dll",`
"$srcpath\SQLServer_Targets_v35_x86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\SqlServer.targets",`
"$srcpath\catalog.21022.08.policy_9_0_Microsoft_VC90_CRT_x86.RTM" , "$env:SystemRoot\winsxs\Policies\x86_policy.9.0.Microsoft.VC90.CRT_1fc8b3b9a1e18e3b_x-ww_b7353f75\9.0.21022.8.cat",`
"$srcpath\CSD_SYSTEM_WORKFLOWSERVICES_DLL_3500amd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.WorkflowServices\3.5.0.0__31bf3856ad364e35\System.WorkflowServices.dll",`
"$srcpath\FL_Microsoft_Build_xsd_v35_amd64_enu.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\Microsoft.Build.xsd",`
"$srcpath\FL_Microsoft_Build_xsd_v35_amd64_enu.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\Microsoft.Build.xsd",`
"$srcpath\FL_Microsoft_Build_xsd_v35_amd64_enu.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft.Build.xsd",`
"$srcpath\FL_Microsoft_Build_xsd_v35_amd64_enu.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\Microsoft.Build.xsd",`
"$srcpath\FL_setupres_dll_amd64_jpn.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1041.dll",`
"$srcpath\FL_eula_exp_txt_amd64_nld.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1043.rtf",`
"$srcpath\FL_vbc_exe_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\vbc.exe",`
"$srcpath\WapRes_dll_amd64_nld.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1043.dll",`
"$srcpath\FL_vbc7ui_dll_20030_x86_enu.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\1033\vbc7ui.dll",`
"$srcpath\FL_eula_exp_txt_amd64_sve.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1053.rtf",`
"$srcpath\FL_eula_exp_txt_amd64_fra.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1036.rtf",`
"$srcpath\FL_setupres_dll_amd64_nor.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1044.dll",`
"$srcpath\FL_setupres_dll_amd64_trk.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1055.dll",`
"$srcpath\FL_System_AddIn_Con_dll_Gac_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.AddIn.Contract\2.0.0.0__b03f5f7f11d50a3a\System.AddIn.Contract.dll",`
"$srcpath\Microsoft_WinFX_Targets_v35_amd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\Microsoft.WinFx.targets",`
"$srcpath\Microsoft_WinFX_Targets_v35_amd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft.WinFx.targets",`
"$srcpath\FL_MSITOSIT_dll_96104_96104_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\vs_setup.dll",`
"$srcpath\csc_exe_amd64.config" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\csc.exe.config",`
"$srcpath\csc_exe_amd64.config" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\jsc.exe.config",`
"$srcpath\csc_exe_amd64.config" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\vbc.exe.config",`
"$srcpath\csc_exe_amd64.config" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\csc.exe.config",`
"$srcpath\csc_exe_amd64.config" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\vbc.exe.config",`
"$srcpath\csc_exe_amd64.config" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\csc.exe.config",`
"$srcpath\csc_exe_amd64.config" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\jsc.exe.config",`
"$srcpath\csc_exe_amd64.config" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\vbc.exe.config",`
"$srcpath\csc_exe_amd64.config" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\csc.exe.config",`
"$srcpath\csc_exe_amd64.config" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\vbc.exe.config",`
"$srcpath\FL_DeleteTemp_exe_96108_96108_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\DeleteTemp.exe",`
"$srcpath\FL_netfx35_setup_pdi_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\vs_setup.pdi",`
"$srcpath\CSD_CDF_INSTALLER_EXEamd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\WFServicesReg.exe",`
"$srcpath\FL_eula_exp_txt_amd64_jpn.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1041.rtf",`
"$srcpath\WapRes_dll_amd64_jpn.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1041.dll",`
"$srcpath\CFX_SERVICEMODEL35_MOF_UNINSTALLamd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\MOF\ServiceModel35.mof.uninstall",`
"$srcpath\CFX_SERVICEMODEL35_MOF_UNINSTALLamd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\MOF\ServiceModel35.mof.uninstall",`
"$srcpath\CFX_SERVICEMODEL35_MOF_UNINSTALLamd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\MOF\ServiceModel35.mof.uninstall",`
"$srcpath\CFX_SERVICEMODEL35_MOF_UNINSTALLamd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\MOF\ServiceModel35.mof.uninstall",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1025.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1028.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1029.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1030.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1031.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1032.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1035.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1036.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1037.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1038.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1040.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1041.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1042.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1043.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1044.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1045.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1046.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1049.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1053.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1055.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.2052.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.2070.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.3082.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.ini",`
"$srcpath\FL_AddInUtil_exe_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\AddInUtil.exe",`
"$srcpath\FL_setupres_dll_amd64_kor.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1042.dll",`
"$srcpath\WapRes_dll_amd64_cht.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1028.dll",`
"$srcpath\FL_setupres_dll_amd64_deu.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1031.dll",`
"$srcpath\FL_AddInProcess_exe_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\AddInProcess.exe",`
"$srcpath\FL_AddInProcess32_exe_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\AddInProcess32.exe",`
"$srcpath\FL_setupres_dll_amd64_nld.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1043.dll",`
"$srcpath\FL_setupres_dll_amd64_fin.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1035.dll",`
"$srcpath\msvcm90.dll.21022.08.Microsoft_VC90_CRT_x64.RTM" , "$env:SystemRoot\winsxs\amd64_Microsoft.VC90.CRT_1fc8b3b9a1e18e3b_9.0.21022.8_x-ww_0296e955\msvcm90.dll",`
"$srcpath\FL_gencomp_dll_98507_98507_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\gencomp.dll",`
"$srcpath\WapRes_dll_amd64_deu.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1031.dll",`
"$srcpath\CFX_SERVICEMODEL35_MOFamd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\MOF\ServiceModel35.mof",`
"$srcpath\CFX_SERVICEMODEL35_MOFamd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\MOF\ServiceModel35.mof",`
"$srcpath\FL_MSBuildTasks_dll_GAC_v35_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft.Build.Tasks.v3.5.dll",`
"$srcpath\FL_AddInUtil_exe_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\AddInUtil.exe",`
"$srcpath\FL_AddInProcess32_exe_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\AddInProcess32.exe",`
"$srcpath\FL_Microsoft_BuildTasks_v35_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\Microsoft.Common.Tasks",`
"$srcpath\FL_Microsoft_BuildTasks_v35_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft.Common.Tasks",`
"$srcpath\FL_eula_exp_txt_amd64_trk.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1055.rtf",`
"$srcpath\FL_Microsoft_CSharp_targets_v35_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\Microsoft.CSharp.targets",`
"$srcpath\FL_Microsoft_CSharp_targets_v35_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft.CSharp.targets",`
"$srcpath\FL_System_Management_Instrumentation_dll_GAC_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.Management.Instrumentation\3.5.0.0__b77a5c561934e089\System.Management.Instrumentation.dll",`
"$srcpath\msvcp90.dll.21022.08.Microsoft_VC90_CRT_x86.RTM" , "$env:SystemRoot\winsxs\x86_Microsoft.VC90.CRT_1fc8b3b9a1e18e3b_9.0.21022.8_x-ww_d08d0375\msvcp90.dll",`
"$srcpath\WapRes_dll_amd64_nor.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1044.dll",`
"$srcpath\CFX_SQL_FILE_LOGIC_DROPamd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\SQL\EN\DropSqlPersistenceProviderLogic.sql",`
"$srcpath\CFX_SQL_FILE_LOGIC_DROPamd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\SQL\EN\DropSqlPersistenceProviderLogic.sql",`
"$srcpath\catalog.21022.08.Microsoft_VC90_CRT_x86.RTM" , "$env:SystemRoot\winsxs\manifests\x86_Microsoft.VC90.CRT_1fc8b3b9a1e18e3b_9.0.21022.8_x-ww_d08d0375.cat",`
"$srcpath\csc_amd64.exe" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\csc.exe",`
"$srcpath\WapRes_dll_amd64_fin.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1035.dll",`
"$srcpath\CSD_CDF_INSTALLER_EXEx86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\WFServicesReg.exe",`
"$srcpath\WapRes_dll_amd64_chs.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.2052.dll",`
"$srcpath\FL_MSBuildFramework_dll_GAC_v35_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\Microsoft.Build.Framework\3.5.0.0__b03f5f7f11d50a3a\Microsoft.Build.Framework.dll",`
"$srcpath\CFX_SQL_FILE_LOGICamd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\SQL\EN\SqlPersistenceProviderLogic.sql",`
"$srcpath\CFX_SQL_FILE_LOGICamd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\SQL\EN\SqlPersistenceProviderLogic.sql",`
"$srcpath\FL_eula_exp_txt_amd64_hun.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1038.rtf",`
"$srcpath\FL_Microsoft_VisualC_STLCLR_dll_1_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft.VisualC.STLCLR.dll",`
"$srcpath\WapRes_dll_amd64_ita.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1040.dll",`
"$srcpath\FL_eula_exp_txt_amd64_ara.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1025.rtf",`
"$srcpath\policy.21022.08.policy_9_0_Microsoft_VC90_CRT_x64.RTM" , "$env:SystemRoot\winsxs\Policies\amd64_policy.9.0.Microsoft.VC90.CRT_1fc8b3b9a1e18e3b_x-ww_16f3e195\9.0.21022.8.policy",`
"$srcpath\FL_SITSetup_dll_96093_96093_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\SITSetup.dll",`
"$srcpath\csc_x86.exe" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\csc.exe",`
"$srcpath\FL_DLinq_dll_24763_GAC_x86_ln.B588F0AF_A1DC_445b_ABE8_B3EDA2EA2F31" , "$env:SystemRoot\assembly\GAC_MSIL\System.Data.Linq\3.5.0.0__b77a5c561934e089\System.Data.Linq.dll",`
"$srcpath\FL_setupres_dll_amd64_rus.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1049.dll",`
"$srcpath\FL_eula_exp_txt_amd64_ptg.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.2070.rtf",`
"$srcpath\FL_setupres_dll_amd64_heb.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1037.dll",`
"$srcpath\FL_setupres_dll_amd64_csy.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1029.dll",`
"$srcpath\FL_eula_exp_txt_amd64_nor.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1044.rtf",`
"$srcpath\FL_Microsoft_VisualC_STLCLR_dll_1_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\Microsoft.VisualC.STLCLR\1.0.0.0__b03f5f7f11d50a3a\Microsoft.VisualC.STLCLR.dll",`
"$srcpath\FL_Microsoft_VisualC_STLCLR_dll_1_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\Microsoft.VisualC.STLCLR.dll",`
"$srcpath\FL_AddInProcess_exe_config_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\AddInProcess.exe.config",`
"$srcpath\FL_AddInProcess_exe_config_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\AddInProcess32.exe.config",`
"$srcpath\FL_AddInProcess_exe_config_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\AddInUtil.exe.config",`
"$srcpath\FL_AddInProcess_exe_config_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\AddInProcess.exe.config",`
"$srcpath\FL_AddInProcess_exe_config_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\AddInProcess32.exe.config",`
"$srcpath\FL_AddInProcess_exe_config_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\AddInUtil.exe.config",`
"$srcpath\FL_setupres_dll_amd64_esn.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.3082.dll",`
"$srcpath\FL_setupres_dll_amd64_enu.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.dll",`
"$srcpath\FL_eula_exp_txt_amd64_ptb.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1046.rtf",`
"$srcpath\CFX_SQL_FILE_SCHEMAamd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\SQL\EN\SqlPersistenceProviderSchema.sql",`
"$srcpath\CFX_SQL_FILE_SCHEMAamd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\SQL\en\SqlPersistenceProviderSchema.sql",`
"$srcpath\CFX_SQL_FILE_SCHEMAamd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\SQL\EN\SqlPersistenceProviderSchema.sql",`
"$srcpath\CFX_SQL_FILE_SCHEMAamd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\SQL\en\SqlPersistenceProviderSchema.sql",`
"$srcpath\cscrsp_amd64.rsp" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\csc.rsp",`
"$srcpath\cscrsp_amd64.rsp" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\csc.rsp",`
"$srcpath\FL_Microsoft_Build_Conversion_dll_GAC_v35_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\Microsoft.Build.Conversion.v3.5\3.5.0.0__b03f5f7f11d50a3a\Microsoft.Build.Conversion.v3.5.dll",`
"$srcpath\FL_eula_exp_txt_amd64_esn.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.3082.rtf",`
"$srcpath\WapRes_dll_amd64_ara.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1025.dll",`
"$srcpath\FL_MSBuildEngine_dll_GAC_v35_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\Microsoft.Build.Engine\3.5.0.0__b03f5f7f11d50a3a\Microsoft.Build.Engine.dll",`
"$srcpath\catalog.21022.08.Microsoft_VC90_CRT_x64.RTM" , "$env:SystemRoot\winsxs\manifests\amd64_Microsoft.VC90.CRT_1fc8b3b9a1e18e3b_9.0.21022.8_x-ww_0296e955.cat",`
"$srcpath\FL_setupres_dll_amd64_ptb.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1046.dll",`
"$srcpath\FL_AddInProcess_exe_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\AddInProcess.exe",`
"$srcpath\FL_eula_exp_txt_amd64_ita.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1040.rtf",`
"$srcpath\FL_eula_exp_txt_amd64_ell.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1032.rtf",`
"$srcpath\FL_dlmgr_dll_100069_100069_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\dlmgr.dll",`
"$srcpath\FL_deffactory_dat_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\deffactory.dat",`
"$srcpath\FL_Microsoft_Build_Core_xsd_v35_amd64_enu.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\MSBuild\Microsoft.Build.Core.xsd",`
"$srcpath\FL_Microsoft_Build_Core_xsd_v35_amd64_enu.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\MSBuild\Microsoft.Build.Core.xsd",`
"$srcpath\CFX_SQL_FILE_SCHEMA_DROPamd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\SQL\EN\DropSqlPersistenceProviderSchema.sql",`
"$srcpath\CFX_SQL_FILE_SCHEMA_DROPamd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\SQL\en\DropSqlPersistenceProviderSchema.sql",`
"$srcpath\CFX_SQL_FILE_SCHEMA_DROPamd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\SQL\EN\DropSqlPersistenceProviderSchema.sql",`
"$srcpath\CFX_SQL_FILE_SCHEMA_DROPamd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\SQL\en\DropSqlPersistenceProviderSchema.sql",`
"$srcpath\FL_System_Core_dll_24763_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.Core\3.5.0.0__b77a5c561934e089\System.Core.dll",`
"$srcpath\CSD_SYSTEM_SERVICEMODEL_WEB_DLL_3500amd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.ServiceModel.Web\3.5.0.0__31bf3856ad364e35\System.ServiceModel.Web.dll",`
"$srcpath\FL_setup_sdb_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setup.sdb",`
"$srcpath\WapRes_dll_amd64_hun.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1038.dll",`
"$srcpath\FL_Microsoft_Common_targets_v35_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\Microsoft.Common.targets",`
"$srcpath\FL_Microsoft_Common_targets_v35_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft.Common.targets",`
"$srcpath\FL_System_Data_DataSetExtensions_dll_Gac_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.Data.DataSetExtensions\3.5.0.0__b77a5c561934e089\System.Data.DataSetExtensions.dll",`
"$srcpath\WapRes_dll_amd64_csy.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1029.dll",`
"$srcpath\FL_System_Windows_Presentation_dll_gac_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.Windows.Presentation\3.5.0.0__b77a5c561934e089\System.Windows.Presentation.dll",`
"$srcpath\WapRes_dll_amd64_dan.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1030.dll",`
"$srcpath\WapRes_dll_amd64_rus.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1049.dll",`
"$srcpath\FL_vbc_rsp_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\vbc.rsp",`
"$srcpath\FL_vbc_rsp_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\vbc.rsp",`
"$srcpath\FL_setupres_dll_amd64_ell.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1032.dll",`
"$srcpath\FL_HtmlLite_dll_96198_96198_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\HtmlLite.dll",`
"$srcpath\FL_MSBuild_exe_v35_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\MSBuild.exe",`
"$srcpath\WapRes_dll_amd64_plk.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1045.dll",`
"$srcpath\msvcm90.dll.21022.08.Microsoft_VC90_CRT_x86.RTM" , "$env:SystemRoot\winsxs\x86_Microsoft.VC90.CRT_1fc8b3b9a1e18e3b_9.0.21022.8_x-ww_d08d0375\msvcm90.dll",`
"$srcpath\FL_vbc7ui_dll_20030_amd64_enu.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\1033\vbc7ui.dll",`
"$srcpath\FL_MSBuildUtilities_DLL_GAC_v35_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\Microsoft.Build.Utilities.v3.5\3.5.0.0__b03f5f7f11d50a3a\Microsoft.Build.Utilities.v3.5.dll",`
"$srcpath\FL_Microsoft_VisualBasic_targets_v35_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\Microsoft.VisualBasic.targets",`
"$srcpath\FL_Microsoft_VisualBasic_targets_v35_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft.VisualBasic.targets",`
"$srcpath\FL_setupres_dll_amd64_ara.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1025.dll",`
"$srcpath\FL_eula_exp_txt_amd64_fin.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1035.rtf",`
"$srcpath\FL_MSBuildTasks_dll_GAC_v35_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\Microsoft.Build.Tasks.v3.5\3.5.0.0__b03f5f7f11d50a3a\Microsoft.Build.Tasks.v3.5.dll",`
"$srcpath\FL_MSBuildTasks_dll_GAC_v35_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\Microsoft.Build.Tasks.v3.5.dll",`
"$srcpath\default_win32manifest_amd64" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\default.win32manifest",`
"$srcpath\default_win32manifest_amd64" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\default.win32manifest",`
"$srcpath\default_win32manifest_amd64" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\default.win32manifest",`
"$srcpath\default_win32manifest_amd64" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\default.win32manifest",`
"$srcpath\FL_setupres_dll_amd64_plk.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1045.dll",`
"$srcpath\FL_eula_exp_txt_amd64_heb.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1037.rtf",`
"$srcpath\FL_setupres_dll_amd64_ita.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1040.dll",`
"$srcpath\WapRes_dll_amd64_kor.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1042.dll",`
"$srcpath\FL_vs70uimgr_dll_96106_96106_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\vs70uimgr.dll",`
"$srcpath\cscompui_x86.dll" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\1033\cscompui.dll",`
"$srcpath\FL_XLinq_dll_Gac_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.Xml.Linq\3.5.0.0__b77a5c561934e089\System.Xml.Linq.dll",`
"$srcpath\FL_eula_exp_txt_amd64_rus.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1049.rtf",`
"$srcpath\WapRes_dll_amd64_esn.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.3082.dll",`
"$srcpath\FL_Microsoft_Build_Commontypes_xsd_v35_amd64_enu.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\MSBuild\Microsoft.Build.Commontypes.xsd",`
"$srcpath\FL_Microsoft_Build_Commontypes_xsd_v35_amd64_enu.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\MSBuild\Microsoft.Build.Commontypes.xsd",`
"$srcpath\FL_eula_exp_txt_amd64_cht.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1028.rtf",`
"$srcpath\FL_MSBuild_rsp_v35_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\MSBuild.rsp",`
"$srcpath\FL_MSBuild_rsp_v35_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\MSBuild.rsp",`
"$srcpath\FL_MSBuild_rsp_v35_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\MSBuild.rsp",`
"$srcpath\FL_MSBuild_rsp_v35_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\MSBuild.rsp",`
"$srcpath\FL_MSBuild_rsp_v35_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\MSBuild.rsp",`
"$srcpath\FL_MSBuild_rsp_v35_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\MSBuild.rsp",`
"$srcpath\FL_eula_exp_txt_amd64_kor.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1042.rtf",`
"$srcpath\WapRes_dll_amd64_ell.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1032.dll",`
"$srcpath\WapRes_dll_amd64_sve.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1053.dll",`
"$srcpath\WapRes_dll_amd64_ptg.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.2070.dll",`
"$srcpath\FL_eula_exp_txt_amd64_dan.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1030.rtf",`
"$srcpath\catalog.21022.08.policy_9_0_Microsoft_VC90_CRT_x64.RTM" , "$env:SystemRoot\winsxs\Policies\amd64_policy.9.0.Microsoft.VC90.CRT_1fc8b3b9a1e18e3b_x-ww_16f3e195\9.0.21022.8.cat",`
"$srcpath\FL_WapUI_dll_amd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapUI.dll",`
"$srcpath\FL_MSBuild_exe_v35_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\MSBuild.exe",`
"$srcpath\FL_setupres_dll_amd64_ptg.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.2070.dll",`
"$srcpath\FL_eula_exp_txt_amd64_csy.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1029.rtf",`
"$srcpath\msvcr90.dll.21022.08.Microsoft_VC90_CRT_x64.RTM" , "$env:SystemRoot\winsxs\amd64_Microsoft.VC90.CRT_1fc8b3b9a1e18e3b_9.0.21022.8_x-ww_0296e955\msvcr90.dll",`
"$srcpath\FL_System_AddIn_dll_Gac_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.AddIn\3.5.0.0__b77a5c561934e089\System.AddIn.dll",`
"$srcpath\FL_baseline_dat_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\baseline.dat",`
"$srcpath\WapRes_dll_amd64_ptb.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1046.dll",`
"$srcpath\FL_vbc_exe_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\vbc.exe",`
"$srcpath\FL_setupres_dll_amd64_hun.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1038.dll",`
"$srcpath\FL_setupres_dll_amd64_fra.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1036.dll",`
"$srcpath\FL_setupres_dll_amd64_sve.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1053.dll",`
"$srcpath\System.Web.Extensions_dll_x86_gc.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.Web.Extensions\3.5.0.0__31bf3856ad364e35\System.Web.Extensions.dll",`
"$srcpath\msvcr90.dll.21022.08.Microsoft_VC90_CRT_x86.RTM" , "$env:SystemRoot\winsxs\x86_Microsoft.VC90.CRT_1fc8b3b9a1e18e3b_9.0.21022.8_x-ww_d08d0375\msvcr90.dll",`
"$srcpath\FL_vsscenario_dll_98517_98517_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\vsscenario.dll",`
"$srcpath\manifest.21022.08.Microsoft_VC90_CRT_x64.RTM" , "$env:SystemRoot\winsxs\manifests\amd64_Microsoft.VC90.CRT_1fc8b3b9a1e18e3b_9.0.21022.8_x-ww_0296e955.manifest",`
"$srcpath\FL_eula_exp_txt_amd64_plk.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1045.rtf",`
"$srcpath\FL_setupres_dll_amd64_chs.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.2052.dll",`
"$srcpath\FL_eula_exp_txt_amd64_deu.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1031.rtf",`
"$srcpath\WapRes_dll_amd64_enu.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.dll",`
"$srcpath\System.Web.Extensions.Design_dll_x86_gc.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.Web.Extensions.Design\3.5.0.0__31bf3856ad364e35\System.Web.Extensions.Design.dll",`
"$srcpath\WapRes_dll_amd64_fra.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1036.dll",`
"$srcpath\FL_eula_exp_txt_amd64_enu.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1033.rtf",`
"$srcpath\FL_msbuild_urt_config_v35_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.5\msbuild.exe.config",`
"$srcpath\FL_msbuild_urt_config_v35_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\msbuild.exe.config",`
"$srcpath\FL_vsbasereqs_dll_98508_98508_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\vsbasereqs.dll",`
"$srcpath\cscompui_amd64.dll" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\1033\cscompui.dll",`
"$srcpath\WapRes_dll_amd64_trk.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1055.dll",`
"$srcpath\FL_setup_exe_96103_96103_amd64_enu.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setup.exe",`
"$srcpath\manifest.21022.08.Microsoft_VC90_CRT_x86.RTM" , "$env:SystemRoot\winsxs\manifests\x86_Microsoft.VC90.CRT_1fc8b3b9a1e18e3b_9.0.21022.8_x-ww_d08d0375.manifest"

for ( $j = 0; $j -lt $dotnet35.count; $j+=2 ) {
    Copy-Item -recurse -Path $dotnet35[$j] -Destination ( Join-Path (New-item -Type Directory -Force $(Split-Path -Path $dotnet35[$j+1]))   $(Split-Path -Leaf $dotnet35[$j+1])   ) -Force  -Verbose }


    Remove-Item -Force  $env:TEMP\\$dldir\\wcu\\dotNetFramework\\dotNetFX30\\PCW_CAB_NetFX*
    foreach($i in $( ls $env:TEMP\\$dldir\\wcu\\dotNetFramework\\dotNetFX30\\*.msp) )
        {7z x $i "-o$env:TEMP\\$dldir\\wcu\\dotNetFramework\\dotNetFX30" "PCW_CAB_NetFX" -aou -y;}
    quit?(7z) ;
    foreach($i in $( ls $env:TEMP\\$dldir\\wcu\\dotNetFramework\\dotNetFX30\\PCW_CAB_NetFX*) )
        {7z x $i "-o$env:TEMP\\$dldir\\wcu\\dotNetFramework\\dotNetFX30\\extr" -y; } 
    quit?(7z)

    $srcpath="$env:TEMP\dotnet35\wcu\dotNetFramework\dotNetFX30\extr"

[array]$dotnet30 = `
"$srcpath\XamlViewer_X86.xbap" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\WPF\XamlViewer\XamlViewer_v0300.xbap",`
"$srcpath\PresentationHostDLL_X86.dll.mui" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\WPF\en-us\PresentationHostDLL.dll.mui",`
"$srcpath\PresentationHost_X86.exe.mui" , "$env:SystemRoot\syswow64\en-us\PresentationHost.exe.mui",`
"$srcpath\NlsData0009_A64.dll" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\WPF\NlsData0009.dll",`
"$srcpath\FL_infocardcpl_cpl_134629_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\syswow64\infocardcpl.cpl",`
"$srcpath\UIAutomationClient_A64.dll" , "$env:SystemRoot\assembly\GAC_MSIL\UIAutomationClient\3.0.0.0__31bf3856ad364e35\UIAutomationClient.dll",`
"$srcpath\PenIMC_X86.dll" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\WPF\PenIMC.dll",`
"$srcpath\FL__ServiceModelEndpointPerfCounters_ini_134737_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_ServiceModelEndpointPerfCounters.ini",`
"$srcpath\FL__ServiceModelEndpointPerfCounters_ini_134737_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_ServiceModelEndpointPerfCounters.ini",`
"$srcpath\WindowsBase_A64.dll" , "$env:SystemRoot\assembly\GAC_MSIL\WindowsBase\3.0.0.0__31bf3856ad364e35\WindowsBase.dll",`
"$srcpath\XamlViewer_X86.exe.manifest" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\WPF\XamlViewer\XamlViewer_v0300.exe.manifest",`
"$srcpath\ReachFramework_A64.dll" , "$env:SystemRoot\assembly\GAC_MSIL\ReachFramework\3.0.0.0__31bf3856ad364e35\ReachFramework.dll",`
"$srcpath\PresentationNative_X86.dll" , "$env:SystemRoot\syswow64\PresentationNative_v0300.dll",`
"$srcpath\UIAutomationCore_X86.dll" , "$env:SystemRoot\syswow64\uiautomationcore.dll",`
"$srcpath\XamlViewer_X86.exe" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\WPF\XamlViewer\XamlViewer_v0300.exe",`
"$srcpath\FL__TransactionBridgePerfCounters_h_133787_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_TransactionBridgePerfCounters.h",`
"$srcpath\FL__TransactionBridgePerfCounters_h_133787_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\_TransactionBridgePerfCounters.h",`
"$srcpath\FL__TransactionBridgePerfCounters_h_133787_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_TransactionBridgePerfCounters.h",`
"$srcpath\FL__TransactionBridgePerfCounters_h_133787_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\_TransactionBridgePerfCounters.h",`
"$srcpath\PenIMC_A64.dll" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\WPF\PenIMC.dll",`
"$srcpath\cPerfCnt.ini.246A212A_8E55_48AF_B8DC_0E9A4E0AD039" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Workflow Foundation\PerfCounters.ini",`
"$srcpath\GlobalMonospace.CompositeFont" , "$env:SystemRoot\Fonts\GlobalMonospace.CompositeFont",`
"$srcpath\GlobalMonospace.CompositeFont" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\WPF\GlobalMonospace.CompositeFont",`
"$srcpath\GlobalMonospace.CompositeFont" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\WPF\Fonts\GlobalMonospace.CompositeFont",`
"$srcpath\GlobalMonospace.CompositeFont" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\WPF\GlobalMonospace.CompositeFont",`
"$srcpath\GlobalMonospace.CompositeFont" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\WPF\Fonts\GlobalMonospace.CompositeFont",`
"$srcpath\FL_WsatConfig_exe_148103_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\WsatConfig.exe",`
"$srcpath\FL_WsatConfig_exe_148103_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\WsatConfig.exe",`
"$srcpath\cPerfCnt.reg.246A212A_8E55_48AF_B8DC_0E9A4E0AD039" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Workflow Foundation\PerfCounters.reg",`
"$srcpath\FL__ServiceModelEndpointPerfCounters_h_134738_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_ServiceModelEndpointPerfCounters.h",`
"$srcpath\FL__ServiceModelEndpointPerfCounters_h_134738_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\_ServiceModelEndpointPerfCounters.h",`
"$srcpath\FL__ServiceModelEndpointPerfCounters_h_134738_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_ServiceModelEndpointPerfCounters.h",`
"$srcpath\FL__ServiceModelEndpointPerfCounters_h_134738_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\_ServiceModelEndpointPerfCounters.h",`
"$srcpath\XPSViewer_X86.exe.mui" , "$env:SystemRoot\syswow64\XPSViewer\en-us\XPSViewer.exe.mui",`
"$srcpath\PresentationUI_A64.dll" , "$env:SystemRoot\assembly\GAC_MSIL\PresentationUI\3.0.0.0__31bf3856ad364e35\PresentationUI.dll",`
"$srcpath\PresentationUI_A64.dll" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\WPF\PresentationUI.dll",`
"$srcpath\FL_System_ServiceModel_dll_133679_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.ServiceModel\3.0.0.0__b77a5c561934e089\System.ServiceModel.dll",`
"$srcpath\FL_System_ServiceModel_dll_133679_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\System.ServiceModel.dll",`
"$srcpath\FL_System_ServiceModel_dll_133679_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\System.ServiceModel.dll",`
"$srcpath\milcore_X86.dll" , "$env:SystemRoot\syswow64\milcore.dll",`
"$srcpath\UIAutomationClientsideProviders_A64.dll" , "$env:SystemRoot\assembly\GAC_MSIL\UIAutomationClientsideProviders\3.0.0.0__31bf3856ad364e35\UIAutomationClientsideProviders.dll",`
"$srcpath\FL__TransactionBridgePerfCounters_reg_133789_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_TransactionBridgePerfCounters.reg",`
"$srcpath\FL__TransactionBridgePerfCounters_reg_133789_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_TransactionBridgePerfCounters.reg",`
"$srcpath\FL_icardagt_exe_134628_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\syswow64\icardagt.exe",`
"$srcpath\fTrackSchema_EN.246A212B_8E55_48AF_B8DC_0E9A4E0AD039" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Workflow Foundation\SQL\EN\Tracking_Schema.sql",`
"$srcpath\cPerfCnt.vrg.246A212A_8E55_48AF_B8DC_0E9A4E0AD039" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Workflow Foundation\PerfCounters.vrg",`
"$srcpath\FL_ServiceModelEvents_dll_mui_148753_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\ServiceModelEvents.dll.mui",`
"$srcpath\FL_ServiceModelEvents_dll_mui_148753_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\MUI\0409\ServiceModelEvents.dll.mui",`
"$srcpath\FL_System_ServiceModel_WasHosting_dll_134736_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.ServiceModel.WasHosting\3.0.0.0__b77a5c561934e089\System.ServiceModel.WasHosting.dll",`
"$srcpath\FL_System_ServiceModel_WasHosting_dll_134736_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\System.ServiceModel.WasHosting.dll",`
"$srcpath\FL_System_ServiceModel_WasHosting_dll_134736_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\System.ServiceModel.WasHosting.dll",`
"$srcpath\fWEAct.dll.I_IL.2C0646A5_257B_44EA_803B_3C8E81C4F428" , "$env:SystemRoot\assembly\GAC_MSIL\System.Workflow.Activities\3.0.0.0__31bf3856ad364e35\System.Workflow.Activities.dll",`
"$srcpath\FL_icardagt_exe_134628_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\system32\icardagt.exe",`
"$srcpath\UIAutomationTypes_A64.dll" , "$env:SystemRoot\assembly\GAC_MSIL\UIAutomationTypes\3.0.0.0__31bf3856ad364e35\UIAutomationTypes.dll",`
"$srcpath\FL__ServiceModelOperationPerfCounters_ini_134194_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_ServiceModelOperationPerfCounters.ini",`
"$srcpath\FL__ServiceModelOperationPerfCounters_ini_134194_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_ServiceModelOperationPerfCounters.ini",`
"$srcpath\XamlViewer_A64.exe.manifest" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\WPF\XamlViewer\XamlViewer_v0300.exe.manifest",`
"$srcpath\GlobalSansSerif.CompositeFont" , "$env:SystemRoot\Fonts\GlobalSansSerif.CompositeFont",`
"$srcpath\GlobalSansSerif.CompositeFont" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\WPF\GlobalSansSerif.CompositeFont",`
"$srcpath\GlobalSansSerif.CompositeFont" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\WPF\Fonts\GlobalSansSerif.CompositeFont",`
"$srcpath\GlobalSansSerif.CompositeFont" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\WPF\GlobalSansSerif.CompositeFont",`
"$srcpath\GlobalSansSerif.CompositeFont" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\WPF\Fonts\GlobalSansSerif.CompositeFont",`
"$srcpath\FL__ServiceModelOperationPerfCounters_vrg_134196_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_ServiceModelOperationPerfCounters.vrg",`
"$srcpath\FL__ServiceModelOperationPerfCounters_vrg_134196_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_ServiceModelOperationPerfCounters.vrg",`
"$srcpath\System.Printing_GAC_X86.dll" , "$env:SystemRoot\assembly\GAC_32\System.Printing\3.0.0.0__31bf3856ad364e35\System.Printing.dll",`
"$srcpath\PresentationHostDLL_A64.dll" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\WPF\PresentationHostDLL.dll",`
"$srcpath\FL__SMSvcHostPerfCounters_ini_143455_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_SMSvcHostPerfCounters.ini",`
"$srcpath\FL__SMSvcHostPerfCounters_ini_143455_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_SMSvcHostPerfCounters.ini",`
"$srcpath\fSqlSrvcSch_EN.246A212B_8E55_48AF_B8DC_0E9A4E0AD039" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Workflow Foundation\SQL\EN\SqlPersistenceService_Schema.sql",`
"$srcpath\fSqlSrvcSch_EN.246A212B_8E55_48AF_B8DC_0E9A4E0AD039" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\SQL\en\SqlPersistenceService_Schema.sql",`
"$srcpath\fSqlSrvcSch_EN.246A212B_8E55_48AF_B8DC_0E9A4E0AD039" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\SQL\en\SqlPersistenceService_Schema.sql",`
"$srcpath\Speech_A64.dll" , "$env:SystemRoot\assembly\GAC_MSIL\System.Speech\3.0.0.0__31bf3856ad364e35\System.Speech.dll",`
"$srcpath\PresentationCFFRasterizerNative_A64.dll" , "$env:SystemRoot\system32\PresentationCFFRasterizerNative_v0300.dll",`
"$srcpath\WFSet.ico.246A212A_8E55_48AF_B8DC_0E9A4E0AD039" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Workflow Foundation\Setup.ico",`
"$srcpath\FL_ServiceMonikerSupport_dll_133768_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\ServiceMonikerSupport.dll",`
"$srcpath\FL__ServiceModelServicePerfCounters_ini_134741_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_ServiceModelServicePerfCounters.ini",`
"$srcpath\FL__ServiceModelServicePerfCounters_ini_134741_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_ServiceModelServicePerfCounters.ini",`
"$srcpath\FL__ServiceModelOperationPerfCounters_reg_134195_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_ServiceModelOperationPerfCounters.reg",`
"$srcpath\FL__ServiceModelOperationPerfCounters_reg_134195_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_ServiceModelOperationPerfCounters.reg",`
"$srcpath\FL__SMSvcHostPerfCounters_vrg_143458_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_SMSvcHostPerfCounters.vrg",`
"$srcpath\FL__SMSvcHostPerfCounters_vrg_143458_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_SMSvcHostPerfCounters.vrg",`
"$srcpath\FL_ServiceModelEvents_dll_mui_148753_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\ServiceModelEvents.dll.mui",`
"$srcpath\FL_ServiceModelEvents_dll_mui_148753_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\MUI\0409\ServiceModelEvents.dll.mui",`
"$srcpath\PresentationCFFRasterizerNative_X86.dll" , "$env:SystemRoot\syswow64\PresentationCFFRasterizerNative_v0300.dll",`
"$srcpath\UIAutomationCore_A64.dll.mui" , "$env:SystemRoot\system32\en-us\UIAutomationCore.dll.mui",`
"$srcpath\fTracLogic_EN.246A212B_8E55_48AF_B8DC_0E9A4E0AD039" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Workflow Foundation\SQL\EN\Tracking_Logic.sql",`
"$srcpath\fTracLogic_EN.246A212B_8E55_48AF_B8DC_0E9A4E0AD039" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\SQL\en\Tracking_Logic.sql",`
"$srcpath\fTracLogic_EN.246A212B_8E55_48AF_B8DC_0E9A4E0AD039" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\SQL\en\Tracking_Logic.sql",`
"$srcpath\FL__ServiceModelEndpointPerfCounters_vrg_134740_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_ServiceModelEndpointPerfCounters.vrg",`
"$srcpath\FL__ServiceModelEndpointPerfCounters_vrg_134740_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_ServiceModelEndpointPerfCounters.vrg",`
"$srcpath\PresentationFontCache_A64.cat" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\WPF\PresentationFontCache.cat",`
"$srcpath\PresentationFontCache_A64.cat" , "$env:SystemRoot\system32\catroot\{f750e6c3-38ee-11d1-85e5-00c04fc295ee}\PresentationFontCache.cat",`
"$srcpath\FL_servicemodel_mof_uninstall_143451_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\ServiceModel.mof.uninstall",`
"$srcpath\FL_servicemodel_mof_uninstall_143451_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\MOF\ServiceModel.mof.uninstall",`
"$srcpath\FL_servicemodel_mof_uninstall_143451_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\ServiceModel.mof.uninstall",`
"$srcpath\FL_servicemodel_mof_uninstall_143451_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\MOF\ServiceModel.mof.uninstall",`
"$srcpath\NlsData0009_X86.dll" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\WPF\NlsData0009.dll",`
"$srcpath\PresentationCFFRasterizer_GAC_X86.dll" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\WPF\PresentationCFFRasterizer.dll",`
"$srcpath\FL__TransactionBridgePerfCounters_vrg_133790_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_TransactionBridgePerfCounters.vrg",`
"$srcpath\FL__TransactionBridgePerfCounters_vrg_133790_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_TransactionBridgePerfCounters.vrg",`
"$srcpath\TSWPFWrp_X86.exe" , "$env:SystemRoot\syswow64\tswpfwrp.exe",`
"$srcpath\FL_inforcardapi_dll_134627_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\syswow64\infocardapi.dll",`
"$srcpath\GlobalUserInterface.CompositeFont" , "$env:SystemRoot\Fonts\GlobalUserInterface.CompositeFont",`
"$srcpath\PresentationUI_GAC_X86.dll" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\WPF\PresentationUI.dll",`
"$srcpath\PresentationCore_A64.dll" , "$env:SystemRoot\assembly\GAC_64\PresentationCore\3.0.0.0__31bf3856ad364e35\PresentationCore.dll",`
"$srcpath\XPSViewerManifest_X86.xml" , "$env:SystemRoot\syswow64\XPSViewer\XPSViewerManifest.xml",`
"$srcpath\milcore_A64.dll" , "$env:SystemRoot\system32\milcore.dll",`
"$srcpath\PresentationFontCache_A64.exe" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\WPF\PresentationFontCache.exe",`
"$srcpath\PresentationFramework.Classic_A64.dll" , "$env:SystemRoot\assembly\GAC_MSIL\PresentationFramework.Classic\3.0.0.0__31bf3856ad364e35\PresentationFramework.Classic.dll",`
"$srcpath\FL_ServiceMonikerSupport_dll_133768_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\ServiceMonikerSupport.dll",`
"$srcpath\UIAutomationCore_X86.dll.mui" , "$env:SystemRoot\syswow64\en-us\UIAutomationCore.dll.mui",`
"$srcpath\FL_SMSvcHost_exe_config_143453_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\SMSvcHost.exe.config",`
"$srcpath\FL_SMSvcHost_exe_config_143453_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\SMSvcHost.exe.config",`
"$srcpath\FL_icardres_dll_mui_149310_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\system32\icardres.dll.mui",`
"$srcpath\FL_icardres_dll_mui_149310_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\system32\mui\0409\icardres.dll.mui",`
"$srcpath\FL__ServiceModelServicePerfCounters_reg_134744_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_ServiceModelServicePerfCounters.reg",`
"$srcpath\FL__ServiceModelServicePerfCounters_reg_134744_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_ServiceModelServicePerfCounters.reg",`
"$srcpath\NaturalLanguage6_A64.dll" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\WPF\NaturalLanguage6.dll",`
"$srcpath\FL_ServiceModelEvents_dll_143449_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\ServiceModelEvents.dll",`
"$srcpath\PresentationFramework.Luna_A64.dll" , "$env:SystemRoot\assembly\GAC_MSIL\PresentationFramework.Luna\3.0.0.0__31bf3856ad364e35\PresentationFramework.Luna.dll",`
"$srcpath\System.Printing_A64.dll" , "$env:SystemRoot\assembly\GAC_64\System.Printing\3.0.0.0__31bf3856ad364e35\System.Printing.dll",`
"$srcpath\NaturalLanguage6_X86.dll" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\WPF\NaturalLanguage6.dll",`
"$srcpath\FL_infocard_exe_134626_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\infocard.exe",`
"$srcpath\PresentationCFFRasterizer_A64.dll" , "$env:SystemRoot\assembly\GAC_MSIL\PresentationCFFRasterizer\3.0.0.0__31bf3856ad364e35\PresentationCFFRasterizer.dll",`
"$srcpath\PresentationCFFRasterizer_A64.dll" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\WPF\PresentationCFFRasterizer.dll",`
"$srcpath\FL_System_ServiceModel_Install_dll_133794_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.ServiceModel.Install\3.0.0.0__b77a5c561934e089\System.ServiceModel.Install.dll",`
"$srcpath\FL_System_ServiceModel_Install_dll_133794_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\System.ServiceModel.Install.dll",`
"$srcpath\FL_System_ServiceModel_Install_dll_133794_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\System.ServiceModel.Install.dll",`
"$srcpath\FL__ServiceModelEndpointPerfCounters_reg_134739_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_ServiceModelEndpointPerfCounters.reg",`
"$srcpath\FL__ServiceModelEndpointPerfCounters_reg_134739_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_ServiceModelEndpointPerfCounters.reg",`
"$srcpath\FL_system_identitymodel_selectors_dll_147068_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.IdentityModel.Selectors\3.0.0.0__b77a5c561934e089\System.IdentityModel.Selectors.dll",`
"$srcpath\cPerfCnt.exe.246A212A_8E55_48AF_B8DC_0E9A4E0AD039" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Workflow Foundation\PerformanceCounterInstaller.exe",`
"$srcpath\PresentationCore_GAC_X86.dll" , "$env:SystemRoot\assembly\GAC_32\PresentationCore\3.0.0.0__31bf3856ad364e35\PresentationCore.dll",`
"$srcpath\FL__ServiceModelOperationPerfCounters_h_134193_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_ServiceModelOperationPerfCounters.h",`
"$srcpath\FL__ServiceModelOperationPerfCounters_h_134193_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\_ServiceModelOperationPerfCounters.h",`
"$srcpath\FL__ServiceModelOperationPerfCounters_h_134193_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_ServiceModelOperationPerfCounters.h",`
"$srcpath\FL__ServiceModelOperationPerfCounters_h_134193_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\_ServiceModelOperationPerfCounters.h",`
"$srcpath\fCompdll.I_IL.2C0646A5_257B_44EA_803B_3C8E81C4F428" , "$env:SystemRoot\assembly\GAC_MSIL\System.Workflow.ComponentModel\3.0.0.0__31bf3856ad364e35\System.Workflow.ComponentModel.dll",`
"$srcpath\XamlViewer_A64.exe" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\WPF\XamlViewer\XamlViewer_v0300.exe",`
"$srcpath\FL_ServiceModelReg_exe_143454_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\ServiceModelReg.exe",`
"$srcpath\FL_ServiceModelReg_exe_143454_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\ServiceModelReg.exe",`
"$srcpath\PresentationFramework.Aero_A64.dll" , "$env:SystemRoot\assembly\GAC_MSIL\PresentationFramework.Aero\3.0.0.0__31bf3856ad364e35\PresentationFramework.Aero.dll",`
"$srcpath\NlsLexicons0009_X86.dll" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\WPF\NlsLexicons0009.dll",`
"$srcpath\fWEExec.dll.I_IL.2C0646A5_257B_44EA_803B_3C8E81C4F428" , "$env:SystemRoot\assembly\GAC_MSIL\System.Workflow.Runtime\3.0.0.0__31bf3856ad364e35\System.Workflow.Runtime.dll",`
"$srcpath\XamlViewer_A64.xbap" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\WPF\XamlViewer\XamlViewer_v0300.xbap",`
"$srcpath\PresentationBuildTasks_A64.dll" , "$env:SystemRoot\assembly\GAC_MSIL\PresentationBuildTasks\3.0.0.0__31bf3856ad364e35\PresentationBuildTasks.dll",`
"$srcpath\FL__TransactionBridgePerfCounters_ini_133788_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_TransactionBridgePerfCounters.ini",`
"$srcpath\FL__TransactionBridgePerfCounters_ini_133788_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_TransactionBridgePerfCounters.ini",`
"$srcpath\FL_SMSvcHost_exe_143452_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\SMSvcHost.exe",`
"$srcpath\FL_SMSvcHost_exe_143452_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\SMSvcHost.exe",`
"$srcpath\FL_SMDiagnostics_dll_147054_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\SMDiagnostics\3.0.0.0__b77a5c561934e089\SMdiagnostics.dll",`
"$srcpath\FL_SMDiagnostics_dll_147054_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\SMDiagnostics.dll",`
"$srcpath\FL_SMDiagnostics_dll_147054_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\SMDiagnostics.dll",`
"$srcpath\FL_ComSvcConfig_exe_133774_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\ComSvcConfig.exe",`
"$srcpath\FL_ComSvcConfig_exe_133774_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\ComSvcConfig.exe",`
"$srcpath\FL__ServiceModelServicePerfCounters_vrg_134743_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_ServiceModelServicePerfCounters.vrg",`
"$srcpath\FL__ServiceModelServicePerfCounters_vrg_134743_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_ServiceModelServicePerfCounters.vrg",`
"$srcpath\FL_icardres_dll_142943_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\system32\icardres.dll",`
"$srcpath\FL_infocard_exe_134626_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\infocard.exe",`
"$srcpath\PresentationFramework_A64.dll" , "$env:SystemRoot\assembly\GAC_MSIL\PresentationFramework\3.0.0.0__31bf3856ad364e35\PresentationFramework.dll",`
"$srcpath\PresentationHostDLL_X86.dll" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\WPF\PresentationHostDLL.dll",`
"$srcpath\WindowsFormsIntegration_A64.dll" , "$env:SystemRoot\assembly\GAC_MSIL\WindowsFormsIntegration\3.0.0.0__31bf3856ad364e35\WindowsFormsIntegration.dll",`
"$srcpath\GlobalSerif.CompositeFont" , "$env:SystemRoot\Fonts\GlobalSerif.CompositeFont",`
"$srcpath\GlobalSerif.CompositeFont" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\WPF\GlobalSerif.CompositeFont",`
"$srcpath\GlobalSerif.CompositeFont" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\WPF\Fonts\GlobalSerif.CompositeFont",`
"$srcpath\GlobalSerif.CompositeFont" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\WPF\GlobalSerif.CompositeFont",`
"$srcpath\GlobalSerif.CompositeFont" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\WPF\Fonts\GlobalSerif.CompositeFont",`
"$srcpath\PresentationFramework.Royale_A64.dll" , "$env:SystemRoot\assembly\GAC_MSIL\PresentationFramework.Royale\3.0.0.0__31bf3856ad364e35\PresentationFramework.Royale.dll",`
"$srcpath\FL_inforcardapi_dll_134627_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\system32\infocardapi.dll",`
"$srcpath\FL_System_IO_Log_dll_133671_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.IO.Log\3.0.0.0__b03f5f7f11d50a3a\System.IO.Log.dll",`
"$srcpath\FL__SMSvcHostPerfCounters_h_143456_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_SMSvcHostPerfCounters.h",`
"$srcpath\FL__SMSvcHostPerfCounters_h_143456_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\_SMSvcHostPerfCounters.h",`
"$srcpath\FL__SMSvcHostPerfCounters_h_143456_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_SMSvcHostPerfCounters.h",`
"$srcpath\FL__SMSvcHostPerfCounters_h_143456_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\_SMSvcHostPerfCounters.h",`
"$srcpath\NlsLexicons0009_A64.dll" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\WPF\NlsLexicons0009.dll",`
"$srcpath\FL__SMSvcHostPerfCounters_reg_143457_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_SMSvcHostPerfCounters.reg",`
"$srcpath\FL__SMSvcHostPerfCounters_reg_143457_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_SMSvcHostPerfCounters.reg",`
"$srcpath\fSqlPersSLgic_EN.246A212B_8E55_48AF_B8DC_0E9A4E0AD039" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Workflow Foundation\SQL\EN\SqlPersistenceService_Logic.sql",`
"$srcpath\FL_icardres_dll_mui_149310_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\syswow64\icardres.dll.mui",`
"$srcpath\FL_icardres_dll_mui_149310_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\syswow64\mui\0409\icardres.dll.mui",`
"$srcpath\FL_infocardcpl_cpl_134629_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\system32\infocardcpl.cpl",`
"$srcpath\FL_system_identitymodel_dll_147070_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.IdentityModel\3.0.0.0__b77a5c561934e089\System.IdentityModel.dll",`
"$srcpath\FL_Microsoft_Transactions_Bridge_dll_133653_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\Microsoft.Transactions.Bridge\3.0.0.0__b03f5f7f11d50a3a\Microsoft.Transactions.Bridge.dll",`
"$srcpath\FL_Microsoft_Transactions_Bridge_dll_133653_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\Microsoft.Transactions.Bridge.dll",`
"$srcpath\FL_Microsoft_Transactions_Bridge_dll_133653_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\Microsoft.Transactions.Bridge.dll",`
"$srcpath\FL_Microsoft_Transactions_Bridge_DTC_dll_133669_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_32\Microsoft.Transactions.Bridge.Dtc\3.0.0.0__b03f5f7f11d50a3a\Microsoft.Transactions.Bridge.Dtc.dll",`
"$srcpath\FL_Microsoft_Transactions_Bridge_DTC_dll_133669_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\Microsoft.Transactions.Bridge.Dtc.dll",`
"$srcpath\UIAutomationProvider_A64.dll" , "$env:SystemRoot\assembly\GAC_MSIL\UIAutomationProvider\3.0.0.0__31bf3856ad364e35\UIAutomationProvider.dll",`
"$srcpath\Microsoft.WinFX_A64.targets" , "$env:SystemRoot\Microsoft.NET\Framework\v2.0.50727\Microsoft.WinFX.targets",`
"$srcpath\Microsoft.WinFX_A64.targets" , "$env:SystemRoot\Microsoft.NET\Framework64\v2.0.50727\Microsoft.WinFX.targets",`
"$srcpath\TSWPFWrp_A64.exe" , "$env:SystemRoot\system32\tswpfwrp.exe",`
"$srcpath\UIAutomationCore_A64.dll" , "$env:SystemRoot\system32\uiautomationcore.dll",`
"$srcpath\cPerfCnt.h.246A212A_8E55_48AF_B8DC_0E9A4E0AD039" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Workflow Foundation\PerfCounters.h",`
"$srcpath\cPerfCnt.h.246A212A_8E55_48AF_B8DC_0E9A4E0AD039" , "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\PerfCounters.h",`
"$srcpath\cPerfCnt.h.246A212A_8E55_48AF_B8DC_0E9A4E0AD039" , "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\PerfCounters.h",`
"$srcpath\XPSViewer_X86.exe" , "$env:SystemRoot\syswow64\XPSViewer\XPSViewer.exe",`
"$srcpath\filler" , "$env:SystemRoot\dotnet48.installed.workaround",`
"$srcpath\filler" , "$env:SystemRoot\assembly\NativeImages_v2.0.50727_32\index24.dat",`
"$srcpath\filler" , "$env:SystemRoot\assembly\NativeImages_v2.0.50727_32\index25.dat",`
"$srcpath\filler" , "$env:SystemRoot\assembly\NativeImages_v2.0.50727_64\index31.dat",`
"$srcpath\filler" , "$env:SystemRoot\Installer\wix{F5B09CFD-F0B2-36AF-8DF4-1DF6B63FC7B4}.SchedServiceConfig.rmi",`
"$srcpath\FL_servicemodel_mof_143450_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\ServiceModel.mof",`
"$srcpath\FL_servicemodel_mof_143450_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\ServiceModel.mof",`
"$srcpath\FL_ServiceModelEvents_dll_143449_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\ServiceModelEvents.dll",`
"$srcpath\FL_System_Runtime_Serialization_dll_133675_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_MSIL\System.Runtime.Serialization\3.0.0.0__b77a5c561934e089\System.Runtime.Serialization.dll",`
"$srcpath\FL_System_Runtime_Serialization_dll_133675_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\System.Runtime.Serialization.dll",`
"$srcpath\FL_System_Runtime_Serialization_dll_133675_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\System.Runtime.Serialization.dll",`
"$srcpath\PresentationHostDLL_A64.dll.mui" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\WPF\en-us\PresentationHostDLL.dll.mui",`
"$srcpath\FL_Microsoft_Transactions_Bridge_DTC_dll_133669_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\assembly\GAC_64\Microsoft.Transactions.Bridge.Dtc\3.0.0.0__b03f5f7f11d50a3a\Microsoft.Transactions.Bridge.Dtc.dll",`
"$srcpath\FL_Microsoft_Transactions_Bridge_DTC_dll_133669_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\Microsoft.Transactions.Bridge.Dtc.dll",`
"$srcpath\PresentationNative_A64.dll" , "$env:SystemRoot\system32\PresentationNative_v0300.dll",`
"$srcpath\FL__ServiceModelServicePerfCounters_h_134742_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_ServiceModelServicePerfCounters.h",`
"$srcpath\FL__ServiceModelServicePerfCounters_h_134742_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_ServiceModelServicePerfCounters.h",`
"$srcpath\FL_icardres_dll_142943_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:SystemRoot\syswow64\icardres.dll"

for ( $j = 0; $j -lt $dotnet30.count; $j+=2 ) {
    Copy-Item -recurse -Path $dotnet30[$j] -Destination ( Join-Path (New-item -Type Directory -Force $(Split-Path -Path $dotnet30[$j+1]))   $(Split-Path -Leaf $dotnet30[$j+1])   ) -Force  -Verbose }

$regkey = @"
REGEDIT4
[HKEY_LOCAL_MACHINE\Software\Microsoft\.NETFramework]
"OnlyUseLatestCLR"=dword:00000000
"@

    reg_edit $regkey

    foreach ($i in 'mscorwks') { dlloverride 'native' $i }
}

function write_keys_from_manifest{
    param ($manifest)
    
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

                   $null = New-ItemProperty -Path $path -Name $Regname -Value $value.Value -PropertyType $propertyType -Force -ErrorAction SilentlyContinue   #-Verbose
                }
            }
        }
        }
} <# end write_keys_from_manifest #>

<# FIXME, very fragile!!! / bogus parts!!! / bugs!!! #>
function install_from_manifest ( [parameter(position=0)] [string] $manifestfile, [parameter(position=1)] [string] $file ) { <# installs files to systemdirs using info from manifestfile #>

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

                if (-not (Test-Path -Path ([system.io.fileinfo]$finalpath).DirectoryName )) { New-Item -Path ([system.io.fileinfo]$finalpath).DirectoryName -ItemType directory -Force }

                Copy-Item -Path $($manifestfile.Replace('.manifest','\') + ([system.io.fileinfo]$finalpath).Name<#$Xml.assembly.file.name?'*'#>) -Destination $finalpath -Force -verbose

            }
    ############  End copy links #########################
        }
    }
        elseif ( $Xml.assembly.assemblyIdentity.processorArchitecture -eq 'msil' -and -not $file_names.destinationpath) {
                 $finalpath = "$env:systemroot\Microsoft.NET\assembly\GAC_MSIL\" + "$($Xml.assembly.assemblyIdentity.name)\" + "v4.0_" + "$([System.Reflection.AssemblyName]::GetAssemblyName($file).Version.ToString())" + "__" + "$($Xml.assembly.assemblyIdentity.publicKeyToken)\"

            if (-not (Test-Path -Path $finalpath )) { New-Item -Path $finalpath -ItemType directory -Force }
            Copy-Item -Path $file -Destination $finalpath -Force  -verbose # -ErrorAction SilentlyContinue 
        }
        else { if($file) { Write-Host -foregroundcolor yellow "***  No way found to install the file, copy it manually from location $file  ***" } else {Write-Host $null}<#FIXME#>}
} <# end function install_from_manifest #>

function func_dotnet481
{
    $dldir = "dotnet481"
    w_download_to $dldir "https://download.visualstudio.microsoft.com/download/pr/6f083c7e-bd40-44d4-9e3f-ffba71ec8b09/3951fd5af6098f2c7e8ff5c331a0679c/ndp481-x86-x64-allos-enu.exe" "ndp481-x86-x64-allos-enu.exe" 
    7z x $cachedir\\$dldir\\ndp481-x86-x64-allos-enu.exe "-o$env:TEMP\\$dldir\\" -y; quit?(7z)
    7z x $env:TEMP\\$dldir\\x64-Windows10.0-KB5011048-x64.cab "-o$env:TEMP\\$dldir\\" -y; quit?(7z)

    Stop-Process -Name mscorsvw -ErrorAction SilentlyContinue <# otherwise some dlls fail to be replaced as they are in use by mscorvw; only mscoreei.dll has to be copied manually afaict as it is in use by pwsh #>


    Write-Host -foregroundColor yellow 'Starting copying files , this takes a while (> 3 minutes), patience...'    
    foreach ($i in $(Get-ChildItem $env:TEMP\\dotnet481\\*.manifest).FullName) { install_from_manifest($i) }

    foreach ($i in $(Get-ChildItem $env:TEMP\\dotnet481\\*.manifest).FullName ) { write_keys_from_manifest($i) }
    Write-Host -foregroundColor yellow 'Done , hopefully nothing''s screwed up ;)' 

    <# FIXME:  mscoreei.dll is not installed as it is in use by pwsh.exe #>
    #Start-Process -FilePath $env:SystemRoot\\Microsoft.NET\\Framework64\\v4.0.3031\\ngen.exe -NoNewWindow -ArgumentList "eqi"
    #Start-Process -FilePath $env:SystemRoot\\Microsoft.NET\\Framework\\v4.0.3031\\ngen.exe -NoNewWindow -ArgumentList "eqi"
} <# end dotnet481 #>

function func_install_dll_from_msu
{
    func_expand
    <# Unfortunately we need another huge download as we need newer version of dpx.dll and msdelta.dll, otherwise several msu files fail to extract #>
    $url = "https://catalog.s.download.windowsupdate.com/c/msdownload/update/software/updt/2018/08/windows10.0-kb4343893-x64_bdae9c9c28d4102a673a24d37c371ed73d053338.msu"
    $cab = "Windows10.0-KB4343893-x64.cab"
    $sourcefile = @(`
    'amd64_microsoft-windows-i..p-media-legacy-base_31bf3856ad364e35_10.0.16299.547_none_7f0fdb243374c0d2/msdelta.dll',`
    'amd64_microsoft-windows-i..p-media-legacy-base_31bf3856ad364e35_10.0.16299.547_none_7f0fdb243374c0d2/dpx.dll'`
    )

    check_msu_sanity $url $cab; $dldir = $($url.split('/')[-1]) -replace '.msu',''    

    foreach ($i in $sourcefile) {
        if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $dldir,  $i) ) ){
                    if( $i.SubString(0,3) -eq 'amd' ) {& "$env:systemroot\system32\expnd_" $([IO.Path]::Combine($cachedir,  $dldir,  $cab)) -f:$($i.split('/')[-1]) $(Join-Path $cachedir  $dldir) }  }  }

    foreach ($i in $sourcefile) {
        if( $i.SubString(0,3) -eq 'amd' ) {Copy-Item -force -verbose "$(Join-Path $cachedir $dldir)\\$i" -destination $env:systemroot\\system32\\$($i.split('/')[-1]) } } 

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
        if( $( expnd_.exe -d $i ) |select-string 'cabinet.cablist.ini') {# newer msu's apparently contain several cabs, so need another trip around for extraction  
            7z x $i "-x!WSUSSCAN.cab" "-o$env:TEMP\\$dest" -aoa 
            Move-Item $i $i.Replace('.cab','.1cab')
        }

    }
    quit?(7z)
    
    Write-Host -ForegroundColor green '****************************************************************'
    Write-Host -ForegroundColor green '*   Patience please! Getting list of files takes a while!      *'
    Write-Host -ForegroundColor green '****************************************************************'

     $out = $( expnd_.exe -d $env:TEMP\\$dest\\*.cab )
     foreach ( $j in ($out |select-string -notMatch '.manifest', '.cat', '.mum').Line  |Sort-Object  -Unique ) { 
         $custom_array.Add(@{ name = $j }) > $null 
     }
   
    <# create the selection dialog #>
    $result = ($custom_array  | select name | Out-GridView  -PassThru  -Title 'Make a  selection')

    foreach ($i in $result) { #https://stackoverflow.com/questions/8097354/how-do-i-capture-the-output-into-a-variable-from-an-external-process-in-powershe/35980675
        [array]$verboseoutput = $( expnd_.exe $i.Name.Split(': ')[0] -F:$i.Name.Split(': ')[1] "$env:TEMP\\$dest") 
        foreach($n in $verboseoutput) { if($n -match 'Queue') {[array]$output += $n + " from $($i.Name.Split(': ')[0])" } } 
    }
    $output

    foreach($j in $output  ) {
        $file = [System.IO.FileInfo]$j.Split(' ')[1]
        $manifestfile = $file.DirectoryName.Split('\')[-1] + '.manifest'
        [array]$verbosemanifestoutput += $(expnd_ $j.Split('from ')[-1] -F:$manifestfile "$env:TEMP\\$dest") 
    }

    foreach($n in $verbosemanifestoutput ) { if($n -match 'Queue') {[array]$verbose += $n}} 
    $verbose

    for($n=0 ; $n -lt $output.count; $n++) {
        install_from_manifest $($([System.IO.FileInfo]$verbose[$n].Split(' ')[1]).FullName) $([System.IO.FileInfo]$output[$n].Split(' ')[1]).FullName
    }
    
    Remove-Item -force  $env:TEMP\\$dest\\*.cab; Remove-Item -force  $env:TEMP\\$dest\\*.1cab
}

function func_affinity_requirements
{
winecfg /v win11
func_renderer=vulkan
func_winmetadata
func_dxcore
func_wintypes
}

function func_winmetadata <# winmetadata #>
{   
    $url = "https://catalog.s.download.windowsupdate.com/c/msdownload/update/software/updt/2018/08/windows10.0-kb4343893-x64_bdae9c9c28d4102a673a24d37c371ed73d053338.msu"
    $cab = "Windows10.0-KB4343893-x64.cab"
    $sourcefile = @(`
'wow64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_5e12b0fead7757f6/windows.web.winmd',
'wow64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_5e12b0fead7757f6/windows.foundation.winmd',
'wow64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_5e12b0fead7757f6/windows.graphics.winmd',
'wow64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_5e12b0fead7757f6/windows.services.winmd',
'wow64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_5e12b0fead7757f6/windows.data.winmd',
'wow64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_5e12b0fead7757f6/windows.media.winmd',
'wow64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_5e12b0fead7757f6/windows.system.winmd',
'wow64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_5e12b0fead7757f6/windows.ui.winmd',
'wow64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_5e12b0fead7757f6/windows.security.winmd',
'wow64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_5e12b0fead7757f6/windows.globalization.winmd',
'wow64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_5e12b0fead7757f6/windows.management.winmd',
'wow64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_5e12b0fead7757f6/windows.devices.winmd',
'wow64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_5e12b0fead7757f6/windows.perception.winmd',
'wow64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_5e12b0fead7757f6/windows.storage.winmd',
'wow64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_5e12b0fead7757f6/windows.ui.xaml.winmd',
'wow64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_5e12b0fead7757f6/windows.gaming.winmd',
'wow64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_5e12b0fead7757f6/windows.applicationmodel.winmd',
'wow64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_5e12b0fead7757f6/windows.networking.winmd',
'amd64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_53be06ac791695fb/windows.web.winmd',
'amd64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_53be06ac791695fb/windows.foundation.winmd',
'amd64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_53be06ac791695fb/windows.graphics.winmd',
'amd64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_53be06ac791695fb/windows.services.winmd',
'amd64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_53be06ac791695fb/windows.data.winmd',
'amd64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_53be06ac791695fb/windows.media.winmd',
'amd64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_53be06ac791695fb/windows.system.winmd',
'amd64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_53be06ac791695fb/windows.ui.winmd',
'amd64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_53be06ac791695fb/windows.security.winmd',
'amd64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_53be06ac791695fb/windows.globalization.winmd',
'amd64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_53be06ac791695fb/windows.management.winmd',
'amd64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_53be06ac791695fb/windows.devices.winmd',
'amd64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_53be06ac791695fb/windows.perception.winmd',
'amd64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_53be06ac791695fb/windows.storage.winmd',
'amd64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_53be06ac791695fb/windows.ui.xaml.winmd',
'amd64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_53be06ac791695fb/windows.gaming.winmd',
'amd64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_53be06ac791695fb/windows.applicationmodel.winmd',
'amd64_microsoft-windows-runtime-metadata_31bf3856ad364e35_10.0.16299.98_none_53be06ac791695fb/windows.networking.winmd'`
    )

    New-Item -Path $env:systemroot\\system32\\winmetadata -Type Directory -force -erroraction silentlycontinue
    New-Item -Path $env:systemroot\\syswow64\\winmetadata -Type Directory -force -erroraction silentlycontinue

    check_msu_sanity $url $cab; $dldir = $($url.split('/')[-1]) -replace '.msu',''    

    foreach ($i in $sourcefile) {
        if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $dldir,  $i) ) ){
                    if( $i.SubString(0,3) -eq 'amd' ) {expnd_.exe $([IO.Path]::Combine($cachedir,  $dldir,  $cab)) -f:$($i.split('/')[-1]) $(Join-Path $cachedir  $dldir) }
                    if( $i.SubString(0,3) -eq 'wow' ) {<# Nothing to do #>}  }  }

    foreach ($i in $sourcefile) {
        if( $i.SubString(0,3) -eq 'amd' ) {Copy-Item -force -verbose "$(Join-Path $cachedir $dldir)\\$i" -destination $env:systemroot\\system32\\winmetadata\\$($i.split('/')[-1]) }
        if( $i.SubString(0,3) -eq 'wow' ) {Copy-Item -force -verbose "$(Join-Path $cachedir $dldir)\\$i" $env:systemroot\\syswow64\\winmetadata\\$($i.split('/')[-1]) } } 
} <# end winmetadata #>

<# Main function #>
    if ( $args.count ) { $result =  $args } else { $result = $custom_array  | select name,description | Out-GridView  -PassThru  -Title 'Make a  selection'}
    foreach ($i in $result) { if ( $args.count ) { $call = $i } else { $call = $i.Name }; & $('func_' + $call); }
