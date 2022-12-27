$cachedir = ("$env:WINEHOMEDIR" + "\.cache\winetrickxs").substring(4)

if (!(Test-Path -Path "$env:ProgramW6432\7-Zip\7z.exe" -PathType Leaf)) { choco install 7zip -y }

function validate_param
{
[CmdletBinding()]
 Param(
        [Parameter(Mandatory=$false)]
        [ValidateSet('msxml3', 'msxml6','gdiplus', 'mfc42', 'riched20', 'msado15', 'expand', 'wmp', 'ucrtbase', 'vcrun2019', 'mshtml', 'd2d1',`
                     'dxvk1103', 'hnetcfg', 'msi', 'sapi', 'ps51', 'ps51_ise', 'crypt32', 'oleaut32', 'msvbvm60', 'xmllite', 'windows.ui.xaml', 'windowscodecs', 'uxtheme', 'comctl32', 'wsh57',`
                     'nocrashdialog', 'renderer=vulkan', 'renderer=gl', 'app_paths', 'vs19','sharpdx', 'cef', 'd3dx','sspicli', 'dshow', 'findstr', 'wpf_xaml', 'wpf_msgbox', 'wpf_routedevents', 'embed-exe-in-psscript', 'vulkansamples')]
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
	       "expand", "native expand.exe",`
               "wmp", "some wmp (windows media player) dlls, makes e-Sword start",`
	       "ucrtbase", "ucrtbase from vcrun2015",`
	       "vcrun2019", "vcredist2019",`
	       "mshtml", "experimental, dangerzone, might break things, only use on a per app base",`
               "hnetcfg", "hnetcfg with fix for https://bugs.winehq.org/show_bug.cgi?id=45432",`
               "msi", "if an msi installer fails, might wanna try this msi, just faking success for a few actions... Might also result in broken installation ;)",`
               "dxvk1103", "dxvk 1.10.3, latest compatible with Kepler (Nvidia GT 470) ??? )",`
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
               "sharpdx", "directX with powershell (spinning cube), test if your d3d11 works, further rather useless verb for now ;)",
               "vulkansamples", "51 vulkan samples to test if your vulkan works, do shift-ctrl^c if you wanna leave earlier ;)",
               "wpf_xaml", "codesnippets from around the internet: how to use wpf+xaml in powershell",
               "wpf_msgbox", "codesnippets from around the internet: some fancy messageboxes (via wpf) in powershell",
               "wpf_routedevents", "codesnippets from around the internet: how to use wpf+xaml+routedevents in powershell",
               "cef", "codesnippets from around the internet: how to use cef / test cef",
               "embed-exe-in-psscript", "codesnippets from around the internet: downloads and runs samplescript howto embed an exe into powershell-scripts (vkcube.exe)"


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

    w_download_to $dldir $url $msu

    if (![System.IO.File]::Exists( [IO.Path]::Combine($cachedir,  $dldir,  $cab) ) )
       {Write-Host file seems missing, re-extracting; 7z e $cachedir\\$dldir\\$msu "-o$cachedir\\$dldir" -y; quit?('7z')}

    foreach ($i in 'cabinet', 'expand.exe') { dlloverride 'native' $i } 
}

function check_aik_sanity <# some sanity checks to see if cached files from windows kits 7 are present #>
{
    $cab = "KB3AIK_EN.iso"
    $dldir = "aik70"
    $url = "https://download.microsoft.com/download/8/E/9/8E9BBC64-E6F8-457C-9B8D-F6C9A16E6D6A/$cab"
    w_download_to $dldir $url $cab

    if ( -not(Test-Path $cachedir\\$dldir\\WinPE.cab -PathType Leaf) -or -not(Test-Path $cachedir\\$dldir\\Neutral.cab -PathType Leaf)){
        7z x $cachedir\\$dldir\\$cab "-o$cachedir\\$dldir" -y; quit?('7z')} 

    if ( -not(Test-Path $cachedir\\$dldir\\F1_WINPE.WIM -PathType Leaf) ){ #fragile test...
        7z x $cachedir\\$dldir\\WinPE.cab "-o$cachedir\\$dldir" -y; quit?('7z')}

    if ( -not(Test-Path $cachedir\\$dldir\\F_WINPEOC_AMD64__WINPE_WINPE_MDAC.CAB -PathType Leaf) ){ #fragile test...
        7z x $cachedir\\$dldir\\Neutral.cab "-o$cachedir\\$dldir\\" -y; quit?('7z')}
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
        7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/System32/$i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])
        7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\\syswow64" Windows/System32/$i -y| Select-String 'ok' && Write-Host processed 32-bit $($i.split('/')[-1])} quit?('7z')
    foreach($i in 'msxml3') { dlloverride 'native' $i }
} <# end msxml3 #>

function func_msxml6
{
    $dlls = @('msxml6.dll', 'msxml6r.dll'); check_aik_sanity; $dldir = "aik70"

    foreach ($i in $dlls) {
        7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/System32/$i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])
        7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\\syswow64" Windows/System32/$i -y| Select-String 'ok' && Write-Host processed 32-bit $($i.split('/')[-1])} quit?('7z')
    foreach($i in 'msxml6') { dlloverride 'native' $i }
} <# end msxml6 #>

function func_mfc42
{
    $dlls = @('mfc42.dll', 'mfc42u.dll'); check_aik_sanity; $dldir = "aik70"

    foreach ($i in $dlls) {
        7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/System32/$i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])
        7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\\syswow64" Windows/System32/$i -y| Select-String 'ok' && Write-Host processed 32-bit $($i.split('/')[-1])} quit?('7z')
} <# end mfc42 #>

function func_riched20
{
    $dlls = @('riched20.dll','msls31.dll'); check_aik_sanity; $dldir = "aik70"

    foreach ($i in $dlls) {
        7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/System32/$i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])
        7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\\syswow64" Windows/System32/$i -y| Select-String 'ok' && Write-Host processed 32-bit $($i.split('/')[-1])} quit?('7z')
    foreach($i in 'riched20') { dlloverride 'native' $i }
} <# end riched20 #>

function func_crypt32
{
    $dlls = @('crypt32.dll','msasn1.dll'); check_aik_sanity; $dldir = "aik70"

    foreach ($i in $dlls) {
        7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/System32/$i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])
        7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\\syswow64" Windows/System32/$i -y| Select-String 'ok' && Write-Host processed 32-bit $($i.split('/')[-1])} quit?('7z')
    foreach($i in 'crypt32') { dlloverride 'native' $i }
}  <# end crypt32 #>

function func_oleaut32
{
    $dlls = @('oleaut32.dll'); check_aik_sanity; $dldir = "aik70"

    foreach ($i in $dlls) {
        7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/System32/$i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])
        7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\\syswow64" Windows/System32/$i -y| Select-String 'ok' && Write-Host processed 32-bit $($i.split('/')[-1])} quit?('7z')
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
        if( $i.SubString(0,3) -eq 'amd' ) {expand.exe $([IO.Path]::Combine($cachedir,  $dldir,  $cab)) -f:$($i.split('/')[-1]) $env:TEMP }
        if( $i.SubString(0,3) -eq 'x86' ) {<# Nothing to do #>}                                                                          } 

    foreach ($i in $sourcefile) {
        if( $i.SubString(0,3) -eq 'amd' ) {Copy-Item -force -verbose "$env:TEMP\\$i" -destination $env:systemroot\\system32\\$($i.split('/')[-1]) }
        if( $i.SubString(0,3) -eq 'x86' ) {Copy-Item -force -verbose "$env:TEMP\\$i" $env:systemroot\\syswow64\\$($i.split('/')[-1]) } } 
		  
    foreach($i in 'cabinet', 'expand.exe') { dlloverride 'builtin' $i }
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
                    if( $i.SubString(0,3) -eq 'amd' ) {expand.exe $([IO.Path]::Combine($cachedir,  $dldir,  $cab)) -f:$($i.split('/')[-1]) $(Join-Path $cachedir  $dldir) }
                    if( $i.SubString(0,3) -eq 'x86' ) {<# Nothing to do #>}  }  }

    foreach ($i in $sourcefile) {
        if( $i.SubString(0,3) -eq 'amd' ) {Copy-Item -force -verbose "$(Join-Path $cachedir $dldir)\\$i" -destination $env:systemroot\\system32\\$($i.split('/')[-1]) }
        if( $i.SubString(0,3) -eq 'x86' ) {Copy-Item -force -verbose "$(Join-Path $cachedir $dldir)\\$i" $env:systemroot\\syswow64\\$($i.split('/')[-1]) } } 

    foreach($i in 'cabinet', 'expand.exe') { dlloverride 'builtin' $i }
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
        if( $i.SubString(0,3) -eq 'amd' ) {expand.exe $([IO.Path]::Combine($cachedir,  $dldir,  $cab)) -f:$($i.split('/')[-1]) $env:TEMP }
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
	  
    foreach($i in 'cabinet', 'expand.exe') { dlloverride 'builtin' $i } 
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
        7z e $cachedir\\$dldir\\wine_hnetcfg.7z "-o$env:systemroot\system32" 64/$i -aoa | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1]);quit?('7z')
        7z e $cachedir\\\\$dldir\\wine_hnetcfg.7z "-o$env:systemroot\syswow64" 32/$i -aoa | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1]); quit?('7z') }
    foreach($i in 'hnetcfg') { dlloverride 'native' $i }
} <# end hnetcfg #>

function func_msi <# wine msi with some hacks faking success #>
{
    $dldir = "msi"
    w_download_to "$dldir" "https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/EXTRAS/wine_msi.7z" "wine_msi.7z"

    foreach ($i in 'msi.dll'){
        7z e $cachedir\\$dldir\\wine_msi.7z "-o$env:systemroot\system32" 64/$i -aoa | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1]);quit?('7z')
        7z e $cachedir\\\\$dldir\\wine_msi.7z "-o$env:systemroot\syswow64" 32/$i -aoa | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1]); quit?('7z') }
    foreach($i in 'msi') { dlloverride 'native' $i }
} <# end msi #>

function func_dxvk1103
{
    $dldir = "dxvk1103"
    w_download_to "dxvk1103" "https://github.com/doitsujin/dxvk/releases/download/v1.10.3/dxvk-1.10.3.tar.gz" "dxvk-1.10.3.tar.gz"

    7z x -y $cachedir\\$dldir\\dxvk-1.10.3.tar.gz "-o$env:TEMP";quit?('7z') 
    7z e $env:TEMP\\dxvk-1.10.3.tar "-o$env:systemroot\\system32" dxvk-1.10.3/x64 -y;
    7z e $env:TEMP\\dxvk-1.10.3.tar "-o$env:systemroot\\syswow64" dxvk-1.10.3/x32 -y;
    foreach($i in 'dxgi', 'd3d9', 'd3d10_1', 'd3d10core', 'd3d10', 'd3d11') { dlloverride 'native' $i }
} <# end dxvk1101 #>

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
            if( $i.SubString(0,3) -eq 'amd' ) {7z e $cachedir\\$dldir\\F_WINPEOC_AMD64__WINPE_WINPE_MDAC.CAB "-o$env:CommonProgramFiles\\System\\ADO" $i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])}
            if( $i.SubString(0,3) -eq 'x86' ) {7z e $cachedir\\$dldir\\F_WINPEOC_X86__WINPE_WINPE_MDAC.CAB "-o${env:CommonProgramFiles`(x86`)}\\System\\ADO" $i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])}} quit?('7z')

    $oledlls = @( 'amd64_microsoft-windows-m..ents-mdac-oledb-dll_31bf3856ad364e35_6.1.7600.16385_none_4e1fa9e216eb782f/oledb32.dll', `
                  'x86_microsoft-windows-m..ents-mdac-oledb-dll_31bf3856ad364e35_6.1.7600.16385_none_f2010e5e5e8e06f9/oledb32.dll', `
                  'amd64_microsoft-windows-m..ents-mdac-oledb-rll_31bf3856ad364e35_6.1.7600.16385_none_54550e6612edb791/oledb32r.dll', `
                  'x86_microsoft-windows-m..ents-mdac-oledb-rll_31bf3856ad364e35_6.1.7600.16385_none_f83672e25a90465b/oledb32r.dll' )

    foreach ($i in $oledlls) {
            if( $i.SubString(0,3) -eq 'amd' ) {7z e $cachedir\\$dldir\\F_WINPEOC_AMD64__WINPE_WINPE_MDAC.CAB "-o$env:CommonProgramFiles\\System\\OLE DB" $i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])}
            if( $i.SubString(0,3) -eq 'x86' ) {7z e $cachedir\\$dldir\\F_WINPEOC_X86__WINPE_WINPE_MDAC.CAB "-o${env:CommonProgramFiles`(x86`)}\\System\\OLE DB" $i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])}} quit?('7z')

    $adcdlls = @( 'amd64_microsoft-windows-m..nts-mdac-rds-ce-rll_31bf3856ad364e35_6.1.7600.16385_none_bd4e87525be1bd8b/msadcer.dll', `
                  'x86_microsoft-windows-m..nts-mdac-rds-ce-rll_31bf3856ad364e35_6.1.7600.16385_none_612febcea3844c55/msadcer.dll', `
                  'amd64_microsoft-windows-m..nts-mdac-rds-ce-dll_31bf3856ad364e35_6.1.7600.16385_none_bde5e63a5b70365d/msadce.dll', `
                  'x86_microsoft-windows-m..nts-mdac-rds-ce-dll_31bf3856ad364e35_6.1.7600.16385_none_61c74ab6a312c527/msadce.dll' )

    foreach ($i in $adcdlls) {
            if( $i.SubString(0,3) -eq 'amd' ) {7z e $cachedir\\$dldir\\F_WINPEOC_AMD64__WINPE_WINPE_MDAC.CAB "-o$env:CommonProgramFiles\\System\\MSADC" $i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])}
            if( $i.SubString(0,3) -eq 'x86' ) {7z e $cachedir\\$dldir\\F_WINPEOC_X86__WINPE_WINPE_MDAC.CAB "-o${env:CommonProgramFiles`(x86`)}\\System\\MSADC" $i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])}} quit?('7z')


    $dlls = @( 'amd64_microsoft-windows-m..ponents-mdac-msdart_31bf3856ad364e35_6.1.7600.16385_none_42074b3f2553d5bd/msdart.dll', `
               'x86_microsoft-windows-m..ponents-mdac-msdart_31bf3856ad364e35_6.1.7600.16385_none_e5e8afbb6cf66487/msdart.dll')
#              'x86_microsoft-windows-m..mponents-jetintlerr_31bf3856ad364e35_6.1.7600.16385_none_0f472a3521bdcfd4/msjint40.dll', `
#              'x86_microsoft-windows-m..-components-jetcore_31bf3856ad364e35_6.1.7600.16385_none_046511bf090691ab/msjet40.dll', `
#              'x86_microsoft-windows-m..mponents-jetintlerr_31bf3856ad364e35_6.1.7600.16385_none_0f472a3521bdcfd4/msjter40.dll' )
		 
    foreach ($i in $dlls) {
            if( $i.SubString(0,3) -eq 'amd' ) {7z e $cachedir\\$dldir\\F_WINPEOC_AMD64__WINPE_WINPE_MDAC.CAB "-o$env:systemroot\\system32" $i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])}
            if( $i.SubString(0,3) -eq 'x86' ) {7z e $cachedir\\$dldir\\F_WINPEOC_X86__WINPE_WINPE_MDAC.CAB "-o$env:systemroot\\syswow64" $i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])}} quit?('7z')

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
    $expdlls = @( 'amd64_microsoft-windows-basic-misc-tools_31bf3856ad364e35_6.1.7600.16385_none_7351a917d91c961e/expand.exe', `
                  'x86_microsoft-windows-basic-misc-tools_31bf3856ad364e35_6.1.7600.16385_none_17330d9420bf24e8/expand.exe',
                  'amd64_microsoft-windows-deltapackageexpander_31bf3856ad364e35_6.1.7600.16385_none_c5d387d64eb8e1f2/dpx.dll',
                  'x86_microsoft-windows-deltapackageexpander_31bf3856ad364e35_6.1.7600.16385_none_69b4ec52965b70bc/dpx.dll',
                  'amd64_microsoft-windows-cabinet_31bf3856ad364e35_6.1.7600.16385_none_933442c3fb9cbaed/cabinet.dll',
                  'x86_microsoft-windows-cabinet_31bf3856ad364e35_6.1.7600.16385_none_3715a740433f49b7/cabinet.dll',
                  'amd64_microsoft-windows-deltacompressionengine_31bf3856ad364e35_6.1.7600.16385_none_9c2159bf9f702069/msdelta.dll',
                  'x86_microsoft-windows-deltacompressionengine_31bf3856ad364e35_6.1.7600.16385_none_4002be3be712af33/msdelta.dll' )
		  
    foreach ($i in $expdlls) {
            if( $i.SubString(0,3) -eq 'amd' ) {7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/winsxs/$i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])}
            if( $i.SubString(0,3) -eq 'x86' ) {7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\\syswow64" Windows/winsxs/$i -y | Select-String 'ok' && Write-Host processed 32-bit $($i.split('/')[-1])}} quit?('7z')
} <# end expand #>

function func_xmllite
{
    check_aik_sanity; $dldir = "aik70"
    $expdlls = @( 'amd64_microsoft-windows-servicingstack_31bf3856ad364e35_6.1.7600.16385_none_655452efe0fb810b/xmllite.dll', `
                  'x86_microsoft-windows-servicingstack_31bf3856ad364e35_6.1.7600.16385_none_0935b76c289e0fd5/xmllite.dll' )
		  
    foreach ($i in $expdlls) {
        if( $i.SubString(0,3) -eq 'amd' ) {7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/winsxs/$i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])}
        if( $i.SubString(0,3) -eq 'x86' ) {7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\\syswow64" Windows/winsxs/$i -y | Select-String 'ok' && Write-Host processed 32-bit $($i.split('/')[-1])}} quit?('7z')

    foreach($i in 'xmllite') { dlloverride 'native' $i }
} <# end xmllite #>

function func_comctl32
{
    check_aik_sanity; $dldir = "aik70" <# There`s also other version 5.8 ?? #>
    $60dlls = @( 'amd64_microsoft.windows.common-controls_6595b64144ccf1df_6.0.7600.16385_none_fa645303170382f6/comctl32.dll', `
                 'x86_microsoft.windows.common-controls_6595b64144ccf1df_6.0.7600.16385_none_421189da2b7fabfc/comctl32.dll') ` 

    foreach ($i in $60dlls) {
        if( $i.SubString(0,3) -eq 'amd' ) {7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/winsxs/$i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])}
        if( $i.SubString(0,3) -eq 'x86' ) {7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\\syswow64" Windows/winsxs/$i -y | Select-String 'ok' && Write-Host processed 32-bit $($i.split('/')[-1])}} quit?('7z')

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
                    if( $i.SubString(0,3) -eq 'amd' ) {expand.exe $([IO.Path]::Combine($cachedir,  $dldir,  $cab)) -f:$($i.split('/')[-1]) $(Join-Path $cachedir  $dldir) }
                    if( $i.SubString(0,3) -eq 'x86' ) {<# Nothing to do #>}
                    if( $i.SubString(0,3) -eq 'wow' ) {<# Nothing to do #>}  }  }

    foreach ($i in $sourcefile) {
        if( $i.SubString(0,3) -eq 'amd' ) {Copy-Item -force -verbose "$(Join-Path $cachedir $dldir)\\$i" -destination $env:systemroot\\system32\\$($i.split('/')[-1]) }
        if( $i.SubString(0,3) -eq 'x86' ) {Copy-Item -force -verbose "$(Join-Path $cachedir $dldir)\\$i" $env:systemroot\\syswow64\\$($i.split('/')[-1]) }
        if( $i.SubString(0,3) -eq 'wow' ) {Copy-Item -force -verbose "$(Join-Path $cachedir $dldir)\\$i" $env:systemroot\\syswow64\\$($i.split('/')[-1]) } } 
	  
    foreach($i in 'cabinet', 'expand.exe') { dlloverride 'builtin' $i }
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
            if( $i.SubString(0,3) -eq 'amd' ) {7z e $cachedir\\$dldir\\F_WINPEOC_AMD64__WINPE_WINPE_HTA.CAB "-o$env:systemroot\\system32" $i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])}
            if( $i.SubString(0,3) -eq 'x86' ) {7z e $cachedir\\$dldir\\F_WINPEOC_X86__WINPE_WINPE_HTA.CAB "-o$env:systemroot\\syswow64" $i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])}} quit?('7z')

    $sxsdlls = @( 'amd64_microsoft-windows-msls31_31bf3856ad364e35_6.1.7600.16385_none_27f4c55dbc24c492/msls31.dll', `
                  'x86_microsoft-windows-msls31_31bf3856ad364e35_6.1.7600.16385_none_cbd629da03c7535c/msls31.dll', `
		  'amd64_microsoft-windows-i..tocolimplementation_31bf3856ad364e35_8.0.7600.16385_none_78982c5c3286110a/wininet.dll', `
	          'x86_microsoft-windows-i..tocolimplementation_31bf3856ad364e35_8.0.7600.16385_none_1c7990d87a289fd4/wininet.dll', `
	          'amd64_microsoft-windows-ie-runtimeutilities_31bf3856ad364e35_8.0.7600.16385_none_be52e3381d372f67/iertutil.dll', `
		  'x86_microsoft-windows-ie-runtimeutilities_31bf3856ad364e35_8.0.7600.16385_none_623447b464d9be31/iertutil.dll', `
                  'amd64_microsoft-windows-shlwapi_31bf3856ad364e35_6.1.7600.16385_none_55cea3abbe5ff1f1/shlwapi.dll', `
                  'x86_microsoft-windows-shlwapi_31bf3856ad364e35_6.1.7600.16385_none_f9b00828060280bb/shlwapi.dll')

    foreach ($i in $sxsdlls) {
            if( $i.SubString(0,3) -eq 'amd' ) {7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/winsxs/$i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])}
            if( $i.SubString(0,3) -eq 'x86' ) {7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\\syswow64" Windows/winsxs/$i -y | Select-String 'ok' && Write-Host processed 32-bit $($i.split('/')[-1])}} quit?('7z')

    $scrdlls = @( 'amd64_microsoft-windows-scripting-jscript_31bf3856ad364e35_8.0.7600.16385_none_f98f217587d75631/jscript.dll',`
                  'x86_microsoft-windows-scripting-jscript_31bf3856ad364e35_8.0.7600.16385_none_9d7085f1cf79e4fb/jscript.dll')

    foreach ($i in $scrdlls) {
            if( $i.SubString(0,3) -eq 'amd' ) {7z e $cachedir\\$dldir\\F_WINPEOC_AMD64__WINPE_WINPE_SCRIPTING.CAB "-o$env:systemroot\\system32" $i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])}
            if( $i.SubString(0,3) -eq 'x86' ) {7z e $cachedir\\$dldir\\F_WINPEOC_X86__WINPE_WINPE_SCRIPTING.CAB "-o$env:systemroot\\syswow64" $i -y | Select-String 'ok' && Write-Host processed 32-bit $($i.split('/')[-1])}} quit?('7z')

    $dlls = @('urlmon.dll' <# ,'iertutil.dll' #>)

    foreach ($i in $dlls) {
        7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/System32/$i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])
        7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\syswow64" Windows/System32/$i -y | Select-String 'ok' && Write-Host processed 32-bit $($i.split('/')[-1])} quit?('7z')

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
                    if( $i.SubString(0,3) -eq 'amd' ) {expand.exe $([IO.Path]::Combine($cachedir,  $dldir,  $cab)) -f:$($i.split('/')[-1]) $(Join-Path $cachedir  $dldir) }
                    if( $i.SubString(0,3) -eq 'x86' ) {<# Nothing to do #>}  }  }

    foreach ($i in $sourcefile) {
        if( $i.SubString(0,3) -eq 'amd' ) {Copy-Item -force -verbose "$(Join-Path $cachedir $dldir)\\$i" -destination $env:systemroot\\system32\\Speech\\Common\\$($i.split('/')[-1]) }
        if( $i.SubString(0,3) -eq 'x86' ) {Copy-Item -force -verbose "$(Join-Path $cachedir $dldir)\\$i" $env:systemroot\\syswow64\\Speech\\Common\\$($i.split('/')[-1]) } } 

    foreach($i in 'cabinet', 'expand.exe') { dlloverride 'builtin' $i }  

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

$test = @"
CreateObject("SAPI.SpVoice").Speak" This is mostly a bunch of crap. Please improve me"
"@

    $test | Out-File $env:SystemRoot\\test.vbs
    iex "cscript.exe $env:SystemRoot\\test.vbs"      
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
    @('wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/microsoft.powershell.management.psd1', 'Modules\\microsoft.powershell.management')`
    )
    <# fragile test... #>
    if (![System.IO.File]::Exists(  [IO.Path]::Combine($env:systemroot, "system32", "dpx.dll")  ) ) { func_expand }
    foreach ($i in 'cabinet', 'expand.exe') { dlloverride 'native' $i } 

    foreach ($i in $sourcefile) {
        if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $dldir,  $i) ) ){
            expand.exe $([IO.Path]::Combine($cachedir,  $dldir,  $cab)) -f:$($i.split('/')[-1]) $(Join-Path $cachedir  $dldir) } 
        Copy-Item -force "$(Join-Path $cachedir $dldir)\\$i" $env:systemroot\\system32\\WindowsPowerShell\v1.0\\$($i.split('/')[-1])}

    foreach ($i in $psrootfiles) {
        if (![System.IO.File]::Exists(  $(Join-Path $cachedir  $dldir  $i[0]) ) ){  
            if( $i[0].SubString(0,3) -eq 'amd' ) {expand.exe $([IO.Path]::Combine($cachedir,  $dldir,  $cab)) -f:$($i[0].split('/')[-1]) $(Join-Path $cachedir $dldir) }
            if( $i[0].SubString(0,3) -eq 'x86' ) {<# Nothing to do #>}     
            if( $i[0].SubString(0,3) -eq 'wow' ) {<# Nothing to do #>}  }  }  

    foreach ($i in $psrootfiles) {
        if( $i[0].SubString(0,3) -eq 'amd' ) {Copy-Item -force -verbose $(Join-Path $cachedir $dldir $i[0]) -destination  $(Join-Path $env:systemroot\\system32\\WindowsPowerShell\\v1.0 $i[1] ) }
        if( $i[0].SubString(0,3) -eq 'x86' ) {Copy-Item -force -verbose $(Join-Path $cachedir $dldir $i[0]) -destination  $(Join-Path $env:systemroot\\syswow64\\WindowsPowerShell\\v1.0 $i[1] ) }
        if( $i[0].SubString(0,3) -eq 'wow' ) {Copy-Item -force -verbose $(Join-Path $cachedir $dldir $i[0]) -destination  $(Join-Path $env:systemroot\\syswow64\\WindowsPowerShell\\v1.0 $i[1] ) } }

    foreach ($i in $modfiles) {
        if (![System.IO.File]::Exists(  $(Join-Path $cachedir  $dldir  $i[0]) ) ){  
            if( $i[0].SubString(0,3) -eq 'amd' ) {expand.exe $([IO.Path]::Combine($cachedir,  $dldir,  $cab)) -f:$($i[0].split('/')[-1]) $(Join-Path $cachedir $dldir) }
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
`$env:PSModulepath += ';c:\windows\system32\WindowsPowershell\v1.0\Modules'

function Get-CIMInstance ( [parameter(position=0)] [string]`$classname, [string[]]`$property="*")
{
     Get-WMIObject `$classname -property `$property
}

Set-Alias -Name gcim -Value Get-CIMInstance

if (!(Get-process -Name powershell_ise -erroraction silentlycontinue)) {
    (Get-Host).ui.RawUI.WindowTitle='This is Powershell 5.1!'
 
    Set-ExecutionPolicy ByPass
 
    Import-Module PSReadLine

    function prompt  
    {  
        `$ESC = [char]27
         "`$ESC[93mPS 51! `$(`$executionContext.SessionState.Path.CurrentLocation)`$(' `$' * (`$nestedPromptLevel + 1)) `$ESC[0m"  
    }

    function winetricks
    {
         if (!([System.IO.File]::Exists("`$env:ProgramData\\winetricks.ps1"))){
             Add-Type -AssemblyName PresentationCore,PresentationFramework;
             [System.Windows.MessageBox]::Show("winetricks script is missing`nplease reinstall it in c:\\ProgramData",'Congrats','ok','exclamation')
         }
         pwsh -f `$( Join-Path `${env:\\ProgramData} "winetricks.ps1") `$args
    }
}
"@
    $profile51 | Out-File $env:SystemRoot\\system32\\WindowsPowerShell\v1.0\\profile.ps1

    Copy-Item -Path "$env:systemroot\system32\WindowsPowershell\v1.0\system.management.automation.dll" -Destination (New-item -Name "System.Management.Automation\v4.0_3.0.0.0__31bf3856ad364e35" -Type directory -Path "$env:systemroot\Microsoft.NET/assembly/GAC_MSIL" -Force) -Force -Verbose

    foreach($i in 'cabinet', 'expand.exe') { dlloverride 'builtin' $i }      
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
    @('wow64_microsoft-windows-gpowershell-exe_31bf3856ad364e35_7.3.7601.16384_none_228e49bab56b74ea/ise.psm1',                                  'Modules\\ISE'),`
    @('amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/microsoft.powershell.utility.psd1',    'Modules\\microsoft.powershell.utility'),`
    @('wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/microsoft.powershell.utility.psd1',    'Modules\\microsoft.powershell.utility'),`
    @('amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/microsoft.powershell.utility.psm1',    'Modules\\microsoft.powershell.utility'),`
    @('wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/microsoft.powershell.utility.psm1',    'Modules\\microsoft.powershell.utility')`
    )

    func_ps51

    $dldir = "ps51"

    <# fragile test... #>
    if (![System.IO.File]::Exists(  [IO.Path]::Combine($env:systemroot, "system32", "dpx.dll")  ) ) { func_expand }
    foreach ($i in 'cabinet', 'expand.exe') { dlloverride 'native' $i } 

    foreach ($i in $sourcefile) {
        if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $dldir,  $i) ) ){
            expand.exe $([IO.Path]::Combine($cachedir,  $dldir,  $cab)) -f:$($i.split('/')[-1]) $(Join-Path $cachedir  $dldir) } 
        Copy-Item -force $(Join-Path $cachedir $dldir $i) $env:systemroot\\system32\\WindowsPowerShell\v1.0\\$($i.split('/')[-1])}

    foreach ($i in $modfiles) {
        if (![System.IO.File]::Exists(  $(Join-Path $cachedir  $dldir  $i[0]) ) ){  
                    if( $i[0].SubString(0,3) -eq 'amd' ) {expand.exe $([IO.Path]::Combine($cachedir,  $dldir,  $cab)) -f:$($i[0].split('/')[-1]) $(Join-Path $cachedir $dldir) }
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

    foreach($i in 'cabinet', 'expand.exe') { dlloverride 'builtin' $i } 

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
            expand.exe $([IO.Path]::Combine($cachedir,  $dldir,  $cab)) -f:$($i.split('/')[-1]) $(Join-Path $cachedir  $dldir) } 
        Copy-Item -force "$(Join-Path $cachedir $dldir)\\$i" $env:systemroot\\syswow64\\$($i.split('/')[-1])}

    foreach($i in 'cabinet', 'expand.exe') { dlloverride 'builtin' $i }      
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
func_msxml3
func_vcrun2019
func_xmllite

winecfg /v win7

(New-Object System.Net.WebClient).DownloadFile('https://aka.ms/vs/15/release/installer', "$env:TMP\\installer")

7z x $env:TMP\\installer "-o$env:TMP\\opc" -y ;quit?('7z')

set-executionpolicy bypass
 
 Start-Process  "$env:TMP\\opc\\Contents\\vs_installer.exe" -Verb RunAs -ArgumentList "install --channelId VisualStudio.15.Release --channelUri `"https://aka.ms/vs/15/release/channel`" --productId Microsoft.VisualStudio.Product.Professional --add `"Microsoft.VisualStudio.Workload.VCTools`" --includeRecommended --quiet"
}

function func_sharpdx
{
    $dldir = "sharpdx"

    foreach( $i in '.direct3d11', '.dxgi', '.d3dcompiler', '.mathematics', '.direct3d9', '.desktop', '' <# =sharpdx core #> )
    {
        w_download_to $dldir "https://globalcdn.nuget.org/packages/sharpdx$i.4.2.0.nupkg" "sharpdx$i.4.2.0.nupkg"
        if (![System.IO.File]::Exists(  [IO.Path]::Combine($env:systemroot, "system32", "WindowsPowerShell", "v1.0", "SharpDX$i.dll")  )){
           7z e $cachedir\\$dldir\\sharpdx$i.4.2.0.nupkg "-o$env:systemroot\\system32\\WindowsPowerShell\\v1.0" lib/net45/SharpDX$i.dll -y 
        }
    }

$MiniCube=  @"
    struct VS_IN 
    {
	    float4 pos : POSITION;
	    float4 col : COLOR;
    };

    struct PS_IN
    {
	    float4 pos : SV_POSITION;
	    float4 col : COLOR;
    };

    float4x4 worldViewProj;

    PS_IN VS( VS_IN input )
    {
	    PS_IN output = (PS_IN)0;
	
	    output.pos = mul(input.pos, worldViewProj);
	    output.col = input.col;
	
	    return output;
    }

    float4 PS( PS_IN input ) : SV_Target
    {
	    return input.col;
    }
"@
    $MiniCube | Out-File $env:SystemRoot\\system32\\WindowsPowerShell\v1.0\\MiniCube.fx

Add-Type -path "$env:systemroot\\system32\\WindowsPowerShell\\v1.0\\SharpDX.dll"
Add-Type -path "$env:systemroot\\system32\\WindowsPowerShell\\v1.0\\SharpDX.Direct3D11.dll"
Add-Type -path "$env:systemroot\\system32\\WindowsPowerShell\\v1.0\\SharpDX.Mathematics.dll"
Add-Type -path "$env:systemroot\\system32\\WindowsPowerShell\\v1.0\\SharpDX.D3DCompiler.dll"
Add-Type -path "$env:systemroot\\system32\\WindowsPowerShell\\v1.0\\SharpDX.Dxgi.dll"
Add-Type -path "$env:systemroot\\system32\\WindowsPowerShell\\v1.0\\SharpDX.Desktop.dll"

Add-Type @'

// Copyright (c) 2010-2013 SharpDX - Alexandre Mutel
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
using System;
using System.Diagnostics;
using System.Windows.Forms;

using SharpDX;
using SharpDX.D3DCompiler;
using SharpDX.Direct3D;
using SharpDX.Direct3D11;
using SharpDX.DXGI;
using SharpDX.Windows;
using Buffer = SharpDX.Direct3D11.Buffer;
using Device = SharpDX.Direct3D11.Device;

namespace MiniCube5
{
    /// <summary>
    /// SharpDX MiniCube Direct3D 11 Sample
    /// </summary>
    public class Program
    {
  //      [STAThread]
        public void Main()
        {
            var form = new RenderForm("SharpDX - MiniCube Direct3D11 Sample");

            // SwapChain description
            var desc = new SwapChainDescription()
            {
                BufferCount = 1,
                ModeDescription =
                    new ModeDescription(form.ClientSize.Width, form.ClientSize.Height,
                                        new Rational(60, 1), Format.R8G8B8A8_UNorm),
                IsWindowed = true,
                OutputHandle = form.Handle,
                SampleDescription = new SampleDescription(1, 0),
                SwapEffect = SwapEffect.Discard,
                Usage = Usage.RenderTargetOutput
            };

            // Used for debugging dispose object references
            // Configuration.EnableObjectTracking = true;

            // Disable throws on shader compilation errors
            //Configuration.ThrowOnShaderCompileError = false;

            // Create Device and SwapChain
            Device device;
            SwapChain swapChain;
            Device.CreateWithSwapChain(DriverType.Hardware, DeviceCreationFlags.None, desc, out device, out swapChain);
            var context = device.ImmediateContext;

            // Ignore all windows events
            var factory = swapChain.GetParent<Factory>();
            factory.MakeWindowAssociation(form.Handle, WindowAssociationFlags.IgnoreAll);

            // Compile Vertex and Pixel shaders
            var vertexShaderByteCode = ShaderBytecode.CompileFromFile(Environment.SystemDirectory + "\\WindowsPowerShell\\v1.0\\MiniCube.fx", "VS", "vs_4_0");
            var vertexShader = new VertexShader(device, vertexShaderByteCode);

            var pixelShaderByteCode = ShaderBytecode.CompileFromFile(Environment.SystemDirectory + "\\WindowsPowerShell\\v1.0\\MiniCube.fx", "PS", "ps_4_0");
            var pixelShader = new PixelShader(device, pixelShaderByteCode);

            var signature = ShaderSignature.GetInputSignature(vertexShaderByteCode);
            // Layout from VertexShader input signature
            var layout = new InputLayout(device, signature, new[]
                    {
                        new InputElement("POSITION", 0, Format.R32G32B32A32_Float, 0, 0),
                        new InputElement("COLOR", 0, Format.R32G32B32A32_Float, 16, 0)
                    });

            // Instantiate Vertex buiffer from vertex data
            var vertices = Buffer.Create(device, BindFlags.VertexBuffer, new[]
                                  {
                                      new Vector4(-1.0f, -1.0f, -1.0f, 1.0f), new Vector4(1.0f, 0.0f, 0.0f, 1.0f), // Front
                                      new Vector4(-1.0f,  1.0f, -1.0f, 1.0f), new Vector4(1.0f, 0.0f, 0.0f, 1.0f),
                                      new Vector4( 1.0f,  1.0f, -1.0f, 1.0f), new Vector4(1.0f, 0.0f, 0.0f, 1.0f),
                                      new Vector4(-1.0f, -1.0f, -1.0f, 1.0f), new Vector4(1.0f, 0.0f, 0.0f, 1.0f),
                                      new Vector4( 1.0f,  1.0f, -1.0f, 1.0f), new Vector4(1.0f, 0.0f, 0.0f, 1.0f),
                                      new Vector4( 1.0f, -1.0f, -1.0f, 1.0f), new Vector4(1.0f, 0.0f, 0.0f, 1.0f),

                                      new Vector4(-1.0f, -1.0f,  1.0f, 1.0f), new Vector4(0.0f, 1.0f, 0.0f, 1.0f), // BACK
                                      new Vector4( 1.0f,  1.0f,  1.0f, 1.0f), new Vector4(0.0f, 1.0f, 0.0f, 1.0f),
                                      new Vector4(-1.0f,  1.0f,  1.0f, 1.0f), new Vector4(0.0f, 1.0f, 0.0f, 1.0f),
                                      new Vector4(-1.0f, -1.0f,  1.0f, 1.0f), new Vector4(0.0f, 1.0f, 0.0f, 1.0f),
                                      new Vector4( 1.0f, -1.0f,  1.0f, 1.0f), new Vector4(0.0f, 1.0f, 0.0f, 1.0f),
                                      new Vector4( 1.0f,  1.0f,  1.0f, 1.0f), new Vector4(0.0f, 1.0f, 0.0f, 1.0f),

                                      new Vector4(-1.0f, 1.0f, -1.0f,  1.0f), new Vector4(0.0f, 0.0f, 1.0f, 1.0f), // Top
                                      new Vector4(-1.0f, 1.0f,  1.0f,  1.0f), new Vector4(0.0f, 0.0f, 1.0f, 1.0f),
                                      new Vector4( 1.0f, 1.0f,  1.0f,  1.0f), new Vector4(0.0f, 0.0f, 1.0f, 1.0f),
                                      new Vector4(-1.0f, 1.0f, -1.0f,  1.0f), new Vector4(0.0f, 0.0f, 1.0f, 1.0f),
                                      new Vector4( 1.0f, 1.0f,  1.0f,  1.0f), new Vector4(0.0f, 0.0f, 1.0f, 1.0f),
                                      new Vector4( 1.0f, 1.0f, -1.0f,  1.0f), new Vector4(0.0f, 0.0f, 1.0f, 1.0f),

                                      new Vector4(-1.0f,-1.0f, -1.0f,  1.0f), new Vector4(1.0f, 1.0f, 0.0f, 1.0f), // Bottom
                                      new Vector4( 1.0f,-1.0f,  1.0f,  1.0f), new Vector4(1.0f, 1.0f, 0.0f, 1.0f),
                                      new Vector4(-1.0f,-1.0f,  1.0f,  1.0f), new Vector4(1.0f, 1.0f, 0.0f, 1.0f),
                                      new Vector4(-1.0f,-1.0f, -1.0f,  1.0f), new Vector4(1.0f, 1.0f, 0.0f, 1.0f),
                                      new Vector4( 1.0f,-1.0f, -1.0f,  1.0f), new Vector4(1.0f, 1.0f, 0.0f, 1.0f),
                                      new Vector4( 1.0f,-1.0f,  1.0f,  1.0f), new Vector4(1.0f, 1.0f, 0.0f, 1.0f),

                                      new Vector4(-1.0f, -1.0f, -1.0f, 1.0f), new Vector4(1.0f, 0.0f, 1.0f, 1.0f), // Left
                                      new Vector4(-1.0f, -1.0f,  1.0f, 1.0f), new Vector4(1.0f, 0.0f, 1.0f, 1.0f),
                                      new Vector4(-1.0f,  1.0f,  1.0f, 1.0f), new Vector4(1.0f, 0.0f, 1.0f, 1.0f),
                                      new Vector4(-1.0f, -1.0f, -1.0f, 1.0f), new Vector4(1.0f, 0.0f, 1.0f, 1.0f),
                                      new Vector4(-1.0f,  1.0f,  1.0f, 1.0f), new Vector4(1.0f, 0.0f, 1.0f, 1.0f),
                                      new Vector4(-1.0f,  1.0f, -1.0f, 1.0f), new Vector4(1.0f, 0.0f, 1.0f, 1.0f),

                                      new Vector4( 1.0f, -1.0f, -1.0f, 1.0f), new Vector4(0.0f, 1.0f, 1.0f, 1.0f), // Right
                                      new Vector4( 1.0f,  1.0f,  1.0f, 1.0f), new Vector4(0.0f, 1.0f, 1.0f, 1.0f),
                                      new Vector4( 1.0f, -1.0f,  1.0f, 1.0f), new Vector4(0.0f, 1.0f, 1.0f, 1.0f),
                                      new Vector4( 1.0f, -1.0f, -1.0f, 1.0f), new Vector4(0.0f, 1.0f, 1.0f, 1.0f),
                                      new Vector4( 1.0f,  1.0f, -1.0f, 1.0f), new Vector4(0.0f, 1.0f, 1.0f, 1.0f),
                                      new Vector4( 1.0f,  1.0f,  1.0f, 1.0f), new Vector4(0.0f, 1.0f, 1.0f, 1.0f),
                            });

            // Create Constant Buffer
            var contantBuffer = new Buffer(device, Utilities.SizeOf<Matrix>(), ResourceUsage.Default, BindFlags.ConstantBuffer, CpuAccessFlags.None, ResourceOptionFlags.None, 0);

            // Prepare All the stages
            context.InputAssembler.InputLayout = layout;
            context.InputAssembler.PrimitiveTopology = PrimitiveTopology.TriangleList;
            context.InputAssembler.SetVertexBuffers(0, new VertexBufferBinding(vertices, Utilities.SizeOf<Vector4>() * 2, 0));
            context.VertexShader.SetConstantBuffer(0, contantBuffer);
            context.VertexShader.Set(vertexShader);
            context.PixelShader.Set(pixelShader);

            // Prepare matrices
            var view = Matrix.LookAtLH(new Vector3(0, 0, -5), new Vector3(0, 0, 0), Vector3.UnitY);
            Matrix proj = Matrix.Identity;

            // Use clock
            var clock = new Stopwatch();
            clock.Start();

            // Declare texture for rendering
            bool userResized = true;
            Texture2D backBuffer = null;
            RenderTargetView renderView = null;
            Texture2D depthBuffer = null;
            DepthStencilView depthView = null;

            // Setup handler on resize form
            form.UserResized += (sender, args) => userResized = true;

            // Setup full screen mode change F5 (Full) F4 (Window)
            form.KeyUp += (sender, args) =>
                {
                    if (args.KeyCode == Keys.F5)
                        swapChain.SetFullscreenState(true, null);
                    else if (args.KeyCode == Keys.F4)
                        swapChain.SetFullscreenState(false, null);
                    else if (args.KeyCode == Keys.Escape)
                        form.Close();
                };

            // Main loop
            RenderLoop.Run(form, () =>
            {
                // If Form resized
                if (userResized)
                {
                    // Dispose all previous allocated resources
                    Utilities.Dispose(ref backBuffer);
                    Utilities.Dispose(ref renderView);
                    Utilities.Dispose(ref depthBuffer);
                    Utilities.Dispose(ref depthView);

                    // Resize the backbuffer
                    swapChain.ResizeBuffers(desc.BufferCount, form.ClientSize.Width, form.ClientSize.Height, Format.Unknown, SwapChainFlags.None);

                    // Get the backbuffer from the swapchain
                    backBuffer = Texture2D.FromSwapChain<Texture2D>(swapChain, 0);

                    // Renderview on the backbuffer
                    renderView = new RenderTargetView(device, backBuffer);

                    // Create the depth buffer
                    depthBuffer = new Texture2D(device, new Texture2DDescription()
                    {
                        Format = Format.D32_Float_S8X24_UInt,
                        ArraySize = 1,
                        MipLevels = 1,
                        Width = form.ClientSize.Width,
                        Height = form.ClientSize.Height,
                        SampleDescription = new SampleDescription(1, 0),
                        Usage = ResourceUsage.Default,
                        BindFlags = BindFlags.DepthStencil,
                        CpuAccessFlags = CpuAccessFlags.None,
                        OptionFlags = ResourceOptionFlags.None
                    });

                    // Create the depth buffer view
                    depthView = new DepthStencilView(device, depthBuffer);

                    // Setup targets and viewport for rendering
                    context.Rasterizer.SetViewport(new Viewport(0, 0, form.ClientSize.Width, form.ClientSize.Height, 0.0f, 1.0f));
                    context.OutputMerger.SetTargets(depthView, renderView);

                    // Setup new projection matrix with correct aspect ratio
                    proj = Matrix.PerspectiveFovLH((float)Math.PI / 4.0f, form.ClientSize.Width / (float)form.ClientSize.Height, 0.1f, 100.0f);

                    // We are done resizing
                    userResized = false;
                }

                var time = clock.ElapsedMilliseconds / 400.0f;

                var viewProj = Matrix.Multiply(view, proj);

                // Clear views
                context.ClearDepthStencilView(depthView, DepthStencilClearFlags.Depth, 1.0f, 0);
                context.ClearRenderTargetView(renderView, Color.Black);

                // Update WorldViewProj Matrix
                var worldViewProj = Matrix.RotationX(time) * Matrix.RotationY(time * 2) * Matrix.RotationZ(time * .7f) * viewProj;
                worldViewProj.Transpose();
                context.UpdateSubresource(ref worldViewProj, contantBuffer);

                // Draw the cube
                context.Draw(36, 0);

                // Present!
                swapChain.Present(0, PresentFlags.None);
            });

            // Release all resources
            signature.Dispose();
            vertexShaderByteCode.Dispose();
            vertexShader.Dispose();
            pixelShaderByteCode.Dispose();
            pixelShader.Dispose();
            vertices.Dispose();
            layout.Dispose();
            contantBuffer.Dispose();
            depthBuffer.Dispose();
            depthView.Dispose();
            renderView.Dispose();
            backBuffer.Dispose();
            context.ClearState();
            context.Flush();
            device.Dispose();
            context.Dispose();
            swapChain.Dispose();
            factory.Dispose();
        }
    }
}
'@ -ReferencedAssemblies System.Runtime.Extensions,System,SharpDX,SharpDX.Direct3D11,SharpDX.D3DCompiler,SharpDX.DXGI,SharpDX.Mathematics,SharpDX.Desktop,System.Windows.Forms,System.Diagnostics.Tools,System.ComponentModel.Primitives,mscorlib,System.Drawing.Primitives,System.Threading.Thread

    $env:DXVK_HUD="fps,memory"

    [MiniCube5.Program]::new().Main()
}

function func_cef
{
$dldir = "cef"

New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\pwsh.exe\\DllOverrides' -force -Name 'dwmapi' -Value 'builtin' -PropertyType 'String'

w_download_to $dldir "https://www.nuget.org/api/v2/package/CefSharp.Common/102.0.90" "CefSharp.Common_102.0.90.nupkg"

w_download_to $dldir "https://www.nuget.org/api/v2/package/CefSharp.Wpf/102.0.90" "CefSharp.Wpf_102.0.90.nupkg"

w_download_to $dldir "https://www.nuget.org/api/v2/package/CefSharp.WinForms/102.0.90" "CefSharp.WinForms_102.0.90.nupkg"

w_download_to $dldir "https://www.nuget.org/api/v2/package/cef.redist.x64/102.0.9" "cef.redist.x64_102.0.9.nupkg"





7z e $cachedir\\$dldir\\cef.redist.x64_102.0.9.nupkg "-o$env:systemroot\\system32\\WindowsPowerShell\\v1.0" -y


7z e $cachedir\\$dldir\\CefSharp.Common_102.0.90.nupkg "-o$env:systemroot\\system32\\WindowsPowerShell\\v1.0" lib/net452/*.dll -y 


7z e $cachedir\\$dldir\\CefSharp.Common_102.0.90.nupkg "-o$env:systemroot\\system32\\WindowsPowerShell\\v1.0" CefSharp/x64/*.dll -y 

7z e $cachedir\\$dldir\\CefSharp.Common_102.0.90.nupkg "-o$env:systemroot\\system32\\WindowsPowerShell\\v1.0" CefSharp/x64/*.exe -y 

7z e $cachedir\\$dldir\\CefSharp.Wpf_102.0.90.nupkg "-o$env:systemroot\\system32\\WindowsPowerShell\\v1.0" lib/net452/*.dll -y 


7z e $cachedir\\$dldir\\CefSharp.WinForms_102.0.90.nupkg "-o$env:systemroot\\system32\\WindowsPowerShell\\v1.0" lib/net452/*.dll -y 





#https://www.nuget.org/api/v2/package/CefSharp.Common/102.0.90

#https://www.nuget.org/api/v2/package/CefSharp.Wpf/102.0.90

#https://www.nuget.org/api/v2/package/CefSharp.WinForms/102.0.90


#https://www.nuget.org/api/v2/package/cef.redist.x64/102.0.9

Add-Type -Path $env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\System.ServiceModel.dll



Add-Type -Path "$env:SystemRoot\system32\WindowsPowerShell\v1.0\CefSharp.Core.dll"
Add-Type -Path "$env:SystemRoot\system32\WindowsPowerShell\v1.0\\CefSharp.WinForms.dll"
Add-Type -Path "$env:SystemRoot\system32\WindowsPowerShell\v1.0\\CefSharp.dll"

Add-Type -AssemblyName System.Windows.Forms

# WinForm Setup
$mainForm = New-Object System.Windows.Forms.Form
#$mainForm.Font = "Comic Sans MS,9"
$mainForm.ForeColor = [System.Drawing.Color]::White
$mainForm.BackColor = [System.Drawing.Color]::DarkSlateBlue
$mainForm.Text = "CefSharp"
$mainForm.Width = 960
$mainForm.Height = 700

[CefSharp.WinForms.ChromiumWebBrowser] $browser = New-Object CefSharp.WinForms.ChromiumWebBrowser "www.google.com"
$mainForm.Controls.Add($browser)

[void] $mainForm.ShowDialog()


if(1) {

    Add-Type -Path "$env:SystemRoot\system32\WindowsPowerShell\v1.0\\CefSharp.Wpf.dll"

    #Add-Type -AssemblyName System.Windows.Forms

    Add-Type -AssemblyName PresentationFramework

    [xml]$xaml = @'
    <Window
            xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
            xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
            xmlns:local="clr-namespace:WebBrowserTest"
            xmlns:cef="clr-namespace:CefSharp.Wpf;assembly=CefSharp.Wpf"
            Title="test" Height="480" Width="640">
        <Grid>
            <cef:ChromiumWebBrowser Address="https://www.google.co.jp" />
        </Grid>
    </Window>
'@

    $reader = New-Object System.Xml.XmlNodeReader $xaml
    $frame = [System.Windows.Markup.XamlReader]::Load($reader)

    $frame.ShowDialog()
    }

}

function func_wpf_xaml
{
<# Author      : Jim Moyle @jimmoyle   GitHub      : https://github.com/JimMoyle/GUIDemo #>

<# syntax which Visual Studio 2015 creates #>
$inputXML = @'
<Window x:Name="MyWindow" x:Class="GUIDemo.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:GUIDemo"
        mc:Ignorable="d"
        Title="MainWindow" Height="350" Width="525">
    <Grid Background="#FF1187A8" RenderTransformOrigin="0.216,0.276">
        <Button x:Name="MyButton" Content="Run Program" HorizontalAlignment="Left" Margin="295,224,0,0" VerticalAlignment="Top" Width="75" RenderTransformOrigin="3.948,-3.193"/>
        <Image x:Name="Myimage" HorizontalAlignment="Left" Height="100" Margin="104,72,0,0" VerticalAlignment="Top" Width="100"/>
        <TextBox x:Name="MyTextBox" HorizontalAlignment="Left" Height="23" Margin="86,222,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="157"/>
        <TextBlock HorizontalAlignment="Left" Margin="295,72,0,0" TextWrapping="Wrap" Text="@jimmoyle" VerticalAlignment="Top" FontSize="24"/>
    </Grid>
</Window>
'@


#========================================================
#code from previous script
#========================================================

#Add in the frameworks so that we can create the WPF GUI
Add-Type -AssemblyName presentationframework, presentationcore
#Create empty hashtable into which we will place the GUI objects
$wpf = @{ }
#Grab the content of the Visual Studio xaml file as a string
#$inputXML = Get-Content -Path ".\WPFGUIinTenLines\MainWindow.xaml"
#clean up xml there is syntax which Visual Studio 2015 creates which PoSH can't understand
$inputXMLClean = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace 'x:Class=".*?"','' -replace 'd:DesignHeight="\d*?"','' -replace 'd:DesignWidth="\d*?"',''
#change string variable into xml
[xml]$xaml = $inputXMLClean
$reader = New-Object System.Xml.XmlNodeReader $xaml
#read xml data into xaml node reader object
$tempform = [Windows.Markup.XamlReader]::Load($reader)
#select each named node using an Xpath expression.
$namedNodes = $xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]")
#add all the named nodes as members to the $wpf variable, this also adds in the correct type for the objects.
$namedNodes | ForEach-Object {$wpf.Add($_.Name, $tempform.FindName($_.Name))}

#========================================================
#Your Code goes here
#========================================================


#This code runs when the button is clicked
$wpf.MyButton.add_Click({

$programname = $wpf.MytextBox.text

Start-Process $programname

	})

#=======================================================
#End of Your Code
#=======================================================


$wpf.MyWindow.ShowDialog() | Out-Null
}

function func_wpf_msgbox {

    Function New-WPFMessageBox {

    # For examples for use, see my blog:
    # https://smsagent.wordpress.com/2017/08/24/a-customisable-wpf-messagebox-for-powershell/
    
    # Define Parameters
    [CmdletBinding()]
    Param
    (
        # The popup Content
        [Parameter(Mandatory=$True,Position=0)]
        [Object]$Content,

        # The window title
        [Parameter(Mandatory=$false,Position=1)]
        [string]$Title,

        # The buttons to add
        [Parameter(Mandatory=$false,Position=2)]
        [ValidateSet('OK','OK-Cancel','Abort-Retry-Ignore','Yes-No-Cancel','Yes-No','Retry-Cancel','Cancel-TryAgain-Continue','None')]
        [array]$ButtonType = 'OK',

        # The buttons to add
        [Parameter(Mandatory=$false,Position=3)]
        [array]$CustomButtons,

        # Content font size
        [Parameter(Mandatory=$false,Position=4)]
        [int]$ContentFontSize = 14,

        # Title font size
        [Parameter(Mandatory=$false,Position=5)]
        [int]$TitleFontSize = 14,

        # BorderThickness
        [Parameter(Mandatory=$false,Position=6)]
        [int]$BorderThickness = 0,

        # CornerRadius
        [Parameter(Mandatory=$false,Position=7)]
        [int]$CornerRadius = 8,

        # ShadowDepth
        [Parameter(Mandatory=$false,Position=8)]
        [int]$ShadowDepth = 3,

        # BlurRadius
        [Parameter(Mandatory=$false,Position=9)]
        [int]$BlurRadius = 20,

        # WindowHost
        [Parameter(Mandatory=$false,Position=10)]
        [object]$WindowHost,

        # Timeout in seconds,
        [Parameter(Mandatory=$false,Position=11)]
        [int]$Timeout,

        # Code for Window Loaded event,
        [Parameter(Mandatory=$false,Position=12)]
        [scriptblock]$OnLoaded,

        # Code for Window Closed event,
        [Parameter(Mandatory=$false,Position=13)]
        [scriptblock]$OnClosed

    )

    # Dynamically Populated parameters
    DynamicParam {
        
        # ContentBackground
        $ContentBackground = 'ContentBackground'
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $False
        $AttributeCollection.Add($ParameterAttribute) 
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $arrSet = [System.Drawing.Brushes] | Get-Member -Static -MemberType Property | Select -ExpandProperty Name 
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)    
        $AttributeCollection.Add($ValidateSetAttribute)
        $PSBoundParameters.ContentBackground = "White"
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ContentBackground, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ContentBackground, $RuntimeParameter)
        

        # FontFamily
        $FontFamily = 'FontFamily'
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $False
        $AttributeCollection.Add($ParameterAttribute)  
        $arrSet = [System.Drawing.FontFamily]::Families | Select -ExpandProperty Name 
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
        $AttributeCollection.Add($ValidateSetAttribute)
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($FontFamily, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($FontFamily, $RuntimeParameter)
        $PSBoundParameters.FontFamily = "Segui"

        # TitleFontWeight
        $TitleFontWeight = 'TitleFontWeight'
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $False
        $AttributeCollection.Add($ParameterAttribute) 
        $arrSet = [System.Windows.FontWeights] | Get-Member -Static -MemberType Property | Select -ExpandProperty Name 
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)    
        $AttributeCollection.Add($ValidateSetAttribute)
        $PSBoundParameters.TitleFontWeight = "Normal"
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($TitleFontWeight, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($TitleFontWeight, $RuntimeParameter)

        # ContentFontWeight
        $ContentFontWeight = 'ContentFontWeight'
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $False
        $AttributeCollection.Add($ParameterAttribute) 
        $arrSet = [System.Windows.FontWeights] | Get-Member -Static -MemberType Property | Select -ExpandProperty Name 
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)    
        $AttributeCollection.Add($ValidateSetAttribute)
        $PSBoundParameters.ContentFontWeight = "Normal"
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ContentFontWeight, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ContentFontWeight, $RuntimeParameter)
        

        # ContentTextForeground
        $ContentTextForeground = 'ContentTextForeground'
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $False
        $AttributeCollection.Add($ParameterAttribute) 
        $arrSet = [System.Drawing.Brushes] | Get-Member -Static -MemberType Property | Select -ExpandProperty Name 
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)    
        $AttributeCollection.Add($ValidateSetAttribute)
        $PSBoundParameters.ContentTextForeground = "Black"
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ContentTextForeground, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ContentTextForeground, $RuntimeParameter)

        # TitleTextForeground
        $TitleTextForeground = 'TitleTextForeground'
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $False
        $AttributeCollection.Add($ParameterAttribute) 
        $arrSet = [System.Drawing.Brushes] | Get-Member -Static -MemberType Property | Select -ExpandProperty Name 
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)    
        $AttributeCollection.Add($ValidateSetAttribute)
        $PSBoundParameters.TitleTextForeground = "Black"
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($TitleTextForeground, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($TitleTextForeground, $RuntimeParameter)

        # BorderBrush
        $BorderBrush = 'BorderBrush'
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $False
        $AttributeCollection.Add($ParameterAttribute) 
        $arrSet = [System.Drawing.Brushes] | Get-Member -Static -MemberType Property | Select -ExpandProperty Name 
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)    
        $AttributeCollection.Add($ValidateSetAttribute)
        $PSBoundParameters.BorderBrush = "Black"
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($BorderBrush, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($BorderBrush, $RuntimeParameter)


        # TitleBackground
        $TitleBackground = 'TitleBackground'
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $False
        $AttributeCollection.Add($ParameterAttribute) 
        $arrSet = [System.Drawing.Brushes] | Get-Member -Static -MemberType Property | Select -ExpandProperty Name 
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)    
        $AttributeCollection.Add($ValidateSetAttribute)
        $PSBoundParameters.TitleBackground = "White"
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($TitleBackground, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($TitleBackground, $RuntimeParameter)

        # ButtonTextForeground
        $ButtonTextForeground = 'ButtonTextForeground'
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $False
        $AttributeCollection.Add($ParameterAttribute) 
        $arrSet = [System.Drawing.Brushes] | Get-Member -Static -MemberType Property | Select -ExpandProperty Name 
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)    
        $AttributeCollection.Add($ValidateSetAttribute)
        $PSBoundParameters.ButtonTextForeground = "Black"
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ButtonTextForeground, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ButtonTextForeground, $RuntimeParameter)

        # Sound
        #$Sound = 'Sound'
        #$AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        #$ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        #$ParameterAttribute.Mandatory = $False
        #$ParameterAttribute.Position = 14
        #$AttributeCollection.Add($ParameterAttribute) 
        #$arrSet = (Get-ChildItem "$env:SystemDrive\Windows\Media" -Filter Windows* | Select -ExpandProperty Name).Replace('.wav','')
        #$ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)    
        #$AttributeCollection.Add($ValidateSetAttribute)
        #$RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($Sound, [string], $AttributeCollection)
        #$RuntimeParameterDictionary.Add($Sound, $RuntimeParameter)

        return $RuntimeParameterDictionary
    }

    Begin {
        Add-Type -AssemblyName PresentationFramework
    }
    
    Process {

# Define the XAML markup
[XML]$Xaml = @"
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        x:Name="Window" Title="" SizeToContent="WidthAndHeight" WindowStartupLocation="CenterScreen" WindowStyle="None" ResizeMode="NoResize" AllowsTransparency="True" Background="Transparent" Opacity="1">
    <Window.Resources>
        <Style TargetType="{x:Type Button}">
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border>
                            <Grid Background="{TemplateBinding Background}">
                                <ContentPresenter />
                            </Grid>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>
    <Border x:Name="MainBorder" Margin="10" CornerRadius="$CornerRadius" BorderThickness="$BorderThickness" BorderBrush="$($PSBoundParameters.BorderBrush)" Padding="0" >
        <Border.Effect>
            <DropShadowEffect x:Name="DSE" Color="Black" Direction="270" BlurRadius="$BlurRadius" ShadowDepth="$ShadowDepth" Opacity="0.6" />
        </Border.Effect>
        <Border.Triggers>
            <EventTrigger RoutedEvent="Window.Loaded">
                <BeginStoryboard>
                    <Storyboard>
                        <DoubleAnimation Storyboard.TargetName="DSE" Storyboard.TargetProperty="ShadowDepth" From="0" To="$ShadowDepth" Duration="0:0:1" AutoReverse="False" />
                        <DoubleAnimation Storyboard.TargetName="DSE" Storyboard.TargetProperty="BlurRadius" From="0" To="$BlurRadius" Duration="0:0:1" AutoReverse="False" />
                    </Storyboard>
                </BeginStoryboard>
            </EventTrigger>
        </Border.Triggers>
        <Grid >
            <Border Name="Mask" CornerRadius="$CornerRadius" Background="$($PSBoundParameters.ContentBackground)" />
            <Grid x:Name="Grid" Background="$($PSBoundParameters.ContentBackground)">
                <Grid.OpacityMask>
                    <VisualBrush Visual="{Binding ElementName=Mask}"/>
                </Grid.OpacityMask>
                <StackPanel Name="StackPanel" >                   
                    <TextBox Name="TitleBar" IsReadOnly="True" IsHitTestVisible="False" Text="$Title" Padding="10" FontFamily="$($PSBoundParameters.FontFamily)" FontSize="$TitleFontSize" Foreground="$($PSBoundParameters.TitleTextForeground)" FontWeight="$($PSBoundParameters.TitleFontWeight)" Background="$($PSBoundParameters.TitleBackground)" HorizontalAlignment="Stretch" VerticalAlignment="Center" Width="Auto" HorizontalContentAlignment="Center" BorderThickness="0"/>
                    <DockPanel Name="ContentHost" Margin="0,10,0,10"  >
                    </DockPanel>
                    <DockPanel Name="ButtonHost" LastChildFill="False" HorizontalAlignment="Center" >
                    </DockPanel>
                </StackPanel>
            </Grid>
        </Grid>
    </Border>
</Window>
"@

[XML]$ButtonXaml = @"
<Button xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Width="Auto" Height="30" FontFamily="Segui" FontSize="16" Background="Transparent" Foreground="White" BorderThickness="1" Margin="10" Padding="20,0,20,0" HorizontalAlignment="Right" Cursor="Hand"/>
"@

[XML]$ButtonTextXaml = @"
<TextBlock xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" FontFamily="$($PSBoundParameters.FontFamily)" FontSize="16" Background="Transparent" Foreground="$($PSBoundParameters.ButtonTextForeground)" Padding="20,5,20,5" HorizontalAlignment="Center" VerticalAlignment="Center"/>
"@

[XML]$ContentTextXaml = @"
<TextBlock xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Text="$Content" Foreground="$($PSBoundParameters.ContentTextForeground)" DockPanel.Dock="Right" HorizontalAlignment="Center" VerticalAlignment="Center" FontFamily="$($PSBoundParameters.FontFamily)" FontSize="$ContentFontSize" FontWeight="$($PSBoundParameters.ContentFontWeight)" TextWrapping="Wrap" Height="Auto" MaxWidth="500" MinWidth="50" Padding="10"/>
"@

    # Load the window from XAML
    $Window = [Windows.Markup.XamlReader]::Load((New-Object -TypeName System.Xml.XmlNodeReader -ArgumentList $xaml))

    # Custom function to add a button
    Function Add-Button {
        Param($Content)
        $Button = [Windows.Markup.XamlReader]::Load((New-Object -TypeName System.Xml.XmlNodeReader -ArgumentList $ButtonXaml))
        $ButtonText = [Windows.Markup.XamlReader]::Load((New-Object -TypeName System.Xml.XmlNodeReader -ArgumentList $ButtonTextXaml))
        $ButtonText.Text = "$Content"
        $Button.Content = $ButtonText
        $Button.Add_MouseEnter({
            $This.Content.FontSize = "17"
        })
        $Button.Add_MouseLeave({
            $This.Content.FontSize = "16"
        })
        $Button.Add_Click({
            $Window.Close()
            Write-host $This.Content.Text
        })
        $Window.FindName('ButtonHost').AddChild($Button)
    }

    # Add buttons
    If ($ButtonType -eq "OK")
    {
        Add-Button -Content "OK"
    }

    If ($ButtonType -eq "OK-Cancel")
    {
        Add-Button -Content "OK"
        Add-Button -Content "Cancel"
    }

    If ($ButtonType -eq "Abort-Retry-Ignore")
    {
        Add-Button -Content "Abort"
        Add-Button -Content "Retry"
        Add-Button -Content "Ignore"
    }

    If ($ButtonType -eq "Yes-No-Cancel")
    {
        Add-Button -Content "Yes"
        Add-Button -Content "No"
        Add-Button -Content "Cancel"
    }

    If ($ButtonType -eq "Yes-No")
    {
        Add-Button -Content "Yes"
        Add-Button -Content "No"
    }

    If ($ButtonType -eq "Retry-Cancel")
    {
        Add-Button -Content "Retry"
        Add-Button -Content "Cancel"
    }

    If ($ButtonType -eq "Cancel-TryAgain-Continue")
    {
        Add-Button -Content "Cancel"
        Add-Button -Content "TryAgain"
        Add-Button -Content "Continue"
    }

    If ($ButtonType -eq "None" -and $CustomButtons)
    {
        Foreach ($CustomButton in $CustomButtons)
        {
            Add-Button -Content "$CustomButton"
        }
    }

    # Remove the title bar if no title is provided
    If ($Title -eq "")
    {
        $TitleBar = $Window.FindName('TitleBar')
        $Window.FindName('StackPanel').Children.Remove($TitleBar)
    }

    # Add the Content
    If ($Content -is [String])
    {
        # Replace double quotes with single to avoid quote issues in strings
        If ($Content -match '"')
        {
            $Content = $Content.Replace('"',"'")
        }
        
        # Use a text box for a string value...
        $ContentTextBox = [Windows.Markup.XamlReader]::Load((New-Object -TypeName System.Xml.XmlNodeReader -ArgumentList $ContentTextXaml))
        $Window.FindName('ContentHost').AddChild($ContentTextBox)
    }
    Else
    {
        # ...or add a WPF element as a child
        Try
        {
            $Window.FindName('ContentHost').AddChild($Content) 
        }
        Catch
        {
            $_
        }        
    }

    # Enable window to move when dragged
    $Window.FindName('Grid').Add_MouseLeftButtonDown({
        $Window.DragMove()
    })

    # Activate the window on loading
    If ($OnLoaded)
    {
        $Window.Add_Loaded({
            $This.Activate()
            Invoke-Command $OnLoaded
        })
    }
    Else
    {
        $Window.Add_Loaded({
            $This.Activate()
        })
    }
    

    # Stop the dispatcher timer if exists
    If ($OnClosed)
    {
        $Window.Add_Closed({
            If ($DispatcherTimer)
            {
                $DispatcherTimer.Stop()
            }
            Invoke-Command $OnClosed
        })
    }
    Else
    {
        $Window.Add_Closed({
            If ($DispatcherTimer)
            {
                $DispatcherTimer.Stop()
            }
        })
    }
    

    # If a window host is provided assign it as the owner
    If ($WindowHost)
    {
        $Window.Owner = $WindowHost
        $Window.WindowStartupLocation = "CenterOwner"
    }

    # If a timeout value is provided, use a dispatcher timer to close the window when timeout is reached
    If ($Timeout)
    {
        $Stopwatch = New-object System.Diagnostics.Stopwatch
        $TimerCode = {
            If ($Stopwatch.Elapsed.TotalSeconds -ge $Timeout)
            {
                $Stopwatch.Stop()
                $Window.Close()
            }
        }
        $DispatcherTimer = New-Object -TypeName System.Windows.Threading.DispatcherTimer
        $DispatcherTimer.Interval = [TimeSpan]::FromSeconds(1)
        $DispatcherTimer.Add_Tick($TimerCode)
        $Stopwatch.Start()
        $DispatcherTimer.Start()
    }

    # Play a sound
    If ($($PSBoundParameters.Sound))
    {
        $SoundFile = "$env:SystemDrive\Windows\Media\$($PSBoundParameters.Sound).wav"
        $SoundPlayer = New-Object System.Media.SoundPlayer -ArgumentList $SoundFile
        $SoundPlayer.Add_LoadCompleted({
            $This.Play()
            $This.Dispose()
        })
        $SoundPlayer.LoadAsync()
    }

    # Display the window
    $null = $window.Dispatcher.InvokeAsync{$window.ShowDialog()}.Wait()

    }
}

# Load required assemblies
Add-Type -AssemblyName PresentationFramework, PresentationCore , System.Windows.Forms

#https://smsagent.blog/2018/02/01/create-a-custom-toast-notification-with-wpf-and-powershell/
# Code to create a base64 string from an image file, so that you can include it in the script as a string
#$File = "C:\somepicturefile.png"
#$Image = [System.Drawing.Image]::FromFile($File)
#$MemoryStream = New-Object System.IO.MemoryStream
#$Image.Save($MemoryStream, $Image.RawFormat)
#[System.Byte[]]$Bytes = $MemoryStream.ToArray()
#$Base64 = [System.Convert]::ToBase64String($Bytes)
#$Image.Dispose()
#$MemoryStream.Dispose()
#$Base64 > c:\base64.txt

# Create the custom logo from Base64 string
$Base64 = "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"
$CustomImage = New-Object System.Windows.Media.Imaging.BitmapImage
$CustomImage.BeginInit()
$CustomImage.StreamSource = [System.IO.MemoryStream][System.Convert]::FromBase64String($Base64)
$CustomImage.EndInit()

$Image = New-Object System.Windows.Controls.Image
$Image.Source = $CustomImage
$Image.Height = 512 #[System.Drawing.Image]::FromFile($CustomImage).Height / 2
$Image.Width = 512 #[System.Drawing.Image]::FromFile($CustomImage).Width / 2
 
$TextBlock = New-Object System.Windows.Controls.TextBlock
$TextBlock.Text = "My Logo"
$TextBlock.FontSize = "28"
$TextBlock.HorizontalAlignment = "Center"
 
$StackPanel = New-Object System.Windows.Controls.StackPanel
$StackPanel.AddChild($Image)
$StackPanel.AddChild($TextBlock)
 
New-WPFMessageBox -Content $StackPanel -Title "Messagebox with some logo" -TitleBackground LightSeaGreen -TitleTextForeground Black -ContentBackground LightSeaGreen

$ComputerName = "RandomPC"
Try
{
    New-PSSession -ComputerName $ComputerName -ErrorAction Stop
}
Catch
{
 
    # Create a text box
    $TextBox = New-Object System.Windows.Controls.TextBox
    $TextBox.Text = "Could not create a remote session to '$ComputerName'!"
    $TextBox.Padding = 5
    $TextBox.Margin = 5
    $TextBox.BorderThickness = 0
    $TextBox.FontSize = 16
    $TextBox.Width = "NaN"
    $TextBox.IsReadOnly = $True
 
    # Create an exander
    $Expander = New-Object System.Windows.Controls.Expander
    $Expander.Header = "Error details"
    $Expander.FontSize = 14
    $Expander.Padding = 5
    $Expander.Margin = "5,5,5,0"
 
    # Bind the expander width to the text box width, so the message box width does not change when expanded
    $Binding = New-Object System.Windows.Data.Binding
    $Binding.Path = [System.Windows.Controls.TextBox]::ActualWidthProperty
    $Binding.Mode = [System.Windows.Data.BindingMode]::OneWay
    $Binding.Source = $TextBox
    [void]$Expander.SetBinding([System.Windows.Controls.Expander]::WidthProperty,$Binding)
 
    # Create a textbox for the expander
    $ExpanderTextBox = New-Object System.Windows.Controls.TextBox
    $ExpanderTextBox.Text = "$_"
    $ExpanderTextBox.Padding = 5
    $ExpanderTextBox.BorderThickness = 0
    $ExpanderTextBox.FontSize = 16
    $ExpanderTextBox.TextWrapping = "Wrap"
    $ExpanderTextBox.IsReadOnly = $True
    $Expander.Content = $ExpanderTextBox
 
    # Assemble controls into a stackpanel
    $StackPanel = New-Object System.Windows.Controls.StackPanel
    $StackPanel.AddChild($TextBox)
    $StackPanel.AddChild($Expander)
 
    # Using no rounded corners as they do not stay true when the window resizes
    New-WPFMessageBox -Content $StackPanel -Title "PSSession Error" -TitleBackground Red -TitleFontSize 20 <# -Sound 'Windows Unlock' #> -CornerRadius 0



$Params = @{
    FontFamily = 'Arial'
    Title = ":("
    TitleFontSize = 80
    TitleTextForeground = 'White'
    TitleBackground = 'SteelBlue'
    ButtonType = 'OK'
    ContentFontSize = 16
    ContentTextForeground = 'White'
    ContentBackground = 'SteelBlue'
    ButtonTextForeground = 'White'
    BorderThickness = 0
}
New-WPFMessageBox @Params -Content "The script ran into a problem that it couldn't handle, and now it needs to exit. 
 
0x80050002

 See https://smsagent.wordpress.com/2017/08/24/a-customisable-wpf-messagebox-for-powershell/ for more exmaples"


}

}

function func_wpf_routedevents
{
#https://learn-powershell.net/2014/08/10/powershell-and-wpf-radio-button/

#https://gist.githubusercontent.com/SMSAgentSoftware/8331a70fac978e4c998bbc8fe34094bb/raw/88c2e4e7850cfd5177f76751f9b13cfc21db840e/New-CustomToastNotification.ps1

#Build the GUI
[xml]$xaml = @"
<Window 
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    x:Name="Window" Title="Initial Window" WindowStartupLocation = "CenterScreen"
    SizeToContent = "WidthAndHeight" ShowInTaskbar = "True" Background = "red"> 
    <StackPanel x:Name='StackPanel'> 
        <RadioButton x:Name="Item1" Content = 'Item1'/>
        <RadioButton x:Name="Item2" Content = 'Item2'/>
        <RadioButton x:Name="Item3" Content = 'Item3'/>  
        <Separator/>
        <TextBox x:Name='textbox'/>      
    </StackPanel>
</Window>
"@
 
$reader=(New-Object System.Xml.XmlNodeReader $xaml)
$Window=[Windows.Markup.XamlReader]::Load( $reader )

$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]") | ForEach {
    Set-Variable -Name ($_.Name) -Value $Window.FindName($_.Name) -Scope Script
}

#Bubble up event handler
[System.Windows.RoutedEventHandler]$Script:CheckedEventHandler = {
    $TextBox.Text = $_.source.name
}
$StackPanel.AddHandler([System.Windows.Controls.RadioButton]::CheckedEvent, $CheckedEventHandler)

$Window.Showdialog() | Out-Null
}

function func_embed-exe-in-psscript
{
    if (-not(Test-Path "$env:ProgramData\embedding-exe-files-into-powershell-scripts-example_vkcube.exe.ps1" -PathType Leaf)) {
        (New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/EXTRAS/embedding-exe-files-into-powershell-scripts-example_vkcube.exe.ps1", "$env:ProgramData\embedding-exe-files-into-powershell-scripts-example_vkcube.exe.ps1") }

    . "$env:ProgramData\embedding-exe-files-into-powershell-scripts-example_vkcube.exe.ps1"
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

<# Main function #>
    $result = ($args.count) ? ($args) : ($custom_array  | select name,description | Out-GridView  -PassThru  -Title 'Make a  selection')
    foreach ($i in $result) { $call = ($args.count) ? ($i) : ($i.Name); & $('func_' + $call); }
