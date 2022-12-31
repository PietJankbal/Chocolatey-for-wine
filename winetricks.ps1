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
               "embed-exe-in-psscript", "codesnippets from around the internet: samplescript howto embed and run an exe into a powershell-scripts (vkcube.exe)"


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

(New-Object System.Net.WebClient).DownloadFile('https://aka.ms/vs/16/release/installer', "$env:TMP\\installer")

7z x $env:TMP\\installer "-o$env:TMP\\opc" -y ;quit?('7z')

set-executionpolicy bypass
 
 Start-Process  "$env:TMP\\opc\\Contents\\vs_installer.exe" -Verb RunAs -ArgumentList "install --channelId VisualStudio.16.Release --channelUri `"https://aka.ms/vs/16/release/channel`" --productId Microsoft.VisualStudio.Product.Community --add Microsoft.VisualStudio.Workload.VCTools --add `"Microsoft.VisualStudio.Component.VC.Tools.x86.x64`" --add `"Microsoft.VisualStudio.Component.VC.CoreIde`"  --add `"Microsoft.VisualStudio.Component.Windows10SDK.16299`"           --includeRecommended --quiet"

#cl.exe -I"c:\Program Files (x86)/Windows Kits/10/Include/10.0.16299.0/um/"     -I"c:\Program Files (x86)/Windows Kits/10/Include/10.0.16299.0/Shared/"   -I"c:\Program Files (x86)/Windows Kits/10/Include/10.0.16299.0/ucrt/"   -I"c:\Program Files (x86)/Microsoft Visual Studio/2019/Community/VC/Tools/MSVC/14.29.30133/include/" .\mainv1.c /link /LIBPATH:"c:/Program Files (x86)/Windows Kits/10/Lib/10.0.16299.0/um/x64/" /LIBPATH:"c:/Program Files (x86)/Microsoft Visual Studio/2019/Community/VC/Tools/MSVC/14.29.30133/lib/x64/" /LIBPATH:"c:/Program Files (x86)/Windows Kits/10/Lib/10.0.16299.0/ucrt/x64/"  "c:/Program Files (x86)/Windows Kits/10/Lib/10.0.16299.0/um/x64/urlmon.lib"  "c:/Program Files (x86)/Windows Kits/10/Lib/10.0.16299.0/um/x64/shlwapi.lib"

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
    . "$env:ProgramData\powershell_collected_codesnippets_examples.ps1"
    func_wpf_xaml2
}


function func_wpf_msgbox
{
    . "$env:ProgramData\powershell_collected_codesnippets_examples.ps1"
    func_wpf_msgbox2
}

function func_wpf_routedevents
{
    . "$env:ProgramData\powershell_collected_codesnippets_examples.ps1"
    func_wpf_routedevents2
}

function func_embed-exe-in-psscript
{
    . "$env:ProgramData\powershell_collected_codesnippets_examples.ps1"
    func_embed-exe-in-psscript2
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
