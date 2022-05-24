$cachedir = ("$env:WINEHOMEDIR" + "\.cache\winetrickxs").substring(4)

if (!(Test-Path -Path "$env:ProgramW6432\7-Zip\7z.exe" -PathType Leaf)) { choco install 7zip -y }

function validate_param
{
[CmdletBinding()]
 Param(
        [Parameter(Mandatory=$false)]
        [ValidateSet('msxml3', 'msxml6','gdiplus', 'mfc42', 'riched20', 'msado15', 'expand', 'wmp', 'ucrtbase', 'vcrun2019', 'mshtml', 'dxvk1101', 'pwsh40', 'crypt32', 'msvbvm60')]
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
               "wmp", "TODO, some wmp (windows media player) dlls",`
	       "ucrtbase", "ucrtbase from vcrun2015",`
	       "vcrun2019", "vcredist2019",`
	       "mshtml", "native mshtml, experimental, dangerzone",`
               "dxvk1101", "dxvk",`
               "crypt32", "crypt32 (and msasn1)",`
               "pwsh40", "rudimentary PowerShell 4.0 (downloads yet another huge amount of Mb`s!)",`
               "msvbvm60", "msvbvm60"

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

function validate_cab_existence
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
     New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name $dll -Value $value -PropertyType 'String'
}

function func_msxml3
{
    validate_cab_existence
    $dlls = @('msxml3.dll','msxml3r.dll'); $dldir = "aik70"

    foreach ($i in $dlls) {
        7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/System32/$i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])
        7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\\syswow64" Windows/System32/$i -y| Select-String 'ok' && Write-Host processed 32-bit $($i.split('/')[-1])} quit?('7z')
    foreach($i in 'msxml3') { dlloverride 'native' $i }
} <# end msxml3 #>

function func_msxml6
{
    validate_cab_existence
    $dlls = @('msxml6.dll', 'msxml6r.dll'); $dldir = "aik70"

    foreach ($i in $dlls) {
        7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/System32/$i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])
        7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\\syswow64" Windows/System32/$i -y| Select-String 'ok' && Write-Host processed 32-bit $($i.split('/')[-1])} quit?('7z')
    foreach($i in 'msxml6') { dlloverride 'native' $i }
} <# end msxml6 #>

function func_mfc42
{
    validate_cab_existence
    $dlls = @('mfc42.dll', 'mfc42u.dll'); $dldir = "aik70"

    foreach ($i in $dlls) {
        7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/System32/$i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])
        7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\\syswow64" Windows/System32/$i -y| Select-String 'ok' && Write-Host processed 32-bit $($i.split('/')[-1])} quit?('7z')
} <# end mfc42 #>

function func_riched20
{
    validate_cab_existence
    $dlls = @('riched20.dll','msls31.dll'); $dldir = "aik70"

    foreach ($i in $dlls) {
        7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/System32/$i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])
        7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\\syswow64" Windows/System32/$i -y| Select-String 'ok' && Write-Host processed 32-bit $($i.split('/')[-1])} quit?('7z')
    foreach($i in 'riched20') { dlloverride 'native' $i }
} <# end riched20 #>

function func_crypt32
{
    validate_cab_existence
    $dlls = @('crypt32.dll','msasn1.dll'); $dldir = "aik70"

    foreach ($i in $dlls) {
        7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/System32/$i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])
        7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\\syswow64" Windows/System32/$i -y| Select-String 'ok' && Write-Host processed 32-bit $($i.split('/')[-1])} quit?('7z')
        foreach($i in 'crypt32') { dlloverride 'native' $i }
}

function func_gdiplus
{
    $url = "https://download.microsoft.com/download/3/5/C/35C470D8-802B-457A-9890-F1AFC277C907/Windows6.1-KB2834886-x64.msu"
    $cab = "Windows6.1-KB2834886-x64.cab"
    $sourcefile = @(`
    'amd64_microsoft.windows.gdiplus_6595b64144ccf1df_1.1.7601.22290_none_145f0c928b8d0397/gdiplus.dll',`
    'x86_microsoft.windows.gdiplus_6595b64144ccf1df_1.1.7601.22290_none_5c0c4369a0092c9d/gdiplus.dll'`
   )

    $msu = $url.split('/')[-1]; <# -1 is last array element... #> $dldir = $($url.split('/')[-1]) -replace '.msu',''

    if (![System.IO.File]::Exists(  [IO.Path]::Combine($env:systemroot, "system32", "dpx.dll")  ))
       {Write-Host 'Extracting some files needed for expansion' ;func_expand;}

    w_download_to $dldir $url $msu

    if (![System.IO.File]::Exists( [IO.Path]::Combine($cachedir,  $dldir,  $cab) ) )
       {Write-Host file seems missing, re-extracting;7z e $cachedir\\$dldir\\$msu "-o$cachedir\\$dldir" -y; quit?('7z')}

    foreach($i in 'cabinet', 'expand.exe') { dlloverride 'native' $i }      

    foreach ($i in $sourcefile) {
              switch ( $i.SubString(0,3) ) {
                  {'amd'              }    {expand.exe $([IO.Path]::Combine($cachedir,  $dldir,  $cab)) -f:$($i.split('/')[-1]) $env:TEMP }
                  {$_ -in 'wow', 'x86'}    {<# Nothing to do #>}                                                                          } }

    foreach ($i in $sourcefile) {
              switch ( $i.SubString(0,3) ) {
                  {'amd'              }    {Copy-Item -force $env:TEMP\\$i $env:systemroot\\system32\\$($i.split('/')[-1])}
                  {$_ -in 'wow', 'x86'}    {Copy-Item -force $env:TEMP\\$i $env:systemroot\\syswow64\\$($i.split('/')[-1])} } }
		  
   foreach($i in 'cabinet', 'expand.exe') { dlloverride 'builtin' $i }
   foreach($i in 'gdiplus') { dlloverride 'native' $i }  
} <# end gdiplus #>

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
        7z e $env:TEMP\\$dldir\\64\\a10 "-o$env:systemroot\system32" $i -aoa | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1]);quit?('7z')
        7z e $env:TEMP\\$dldir\\32\\a10 "-o$env:systemroot\syswow64" $i -aoa | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1]); quit?('7z') }
    foreach($i in 'ucrtbase') { dlloverride 'native' $i }
} <# end ucrtbase #>

function func_vcrun2019
{
    func_ucrtbase
    
    choco install vcredist140 -n
    . $env:ProgramData\\chocolatey\\lib\\vcredist140\\tools\\data.ps1  #source the file via dot operator
    w_download_to "vcredist140\\64" $installData64.url64 "VC_redist.x64.exe"
    w_download_to "vcredist140\\32" $installData32.url VC__redist.x86.exe
    $dldir = "vcredist140"
        
    7z -t# x $cachedir\\$dldir\\64\\VC_redist.x64.exe "-o$env:TEMP\\$dldir\\64" 4.cab -y; quit?('7z')
    7z -t# x $cachedir\\$dldir\\32\\VC__redist.x86.exe "-o$env:TEMP\\$dldir\\32" 4.cab -y; quit?('7z')
    7z e $env:TEMP\\$dldir\\64\\4.cab "-o$env:TEMP\\$dldir\\64" a12 -y ;quit?('7z')
    7z e $env:TEMP\\$dldir\\64\\4.cab "-o$env:TEMP\\$dldir\\64" a13 -y ;quit?('7z')
    7z e $env:TEMP\\$dldir\\32\\4.cab "-o$env:TEMP\\$dldir\\32" a10 -y; quit?('7z')
    7z e $env:TEMP\\$dldir\\32\\4.cab "-o$env:TEMP\\$dldir\\32" a11 -y; quit?('7z')
    7z e $env:TEMP\\$dldir\\64\\a12 "-o$env:systemroot\\system32" -y; quit?('7z')
    7z e $env:TEMP\\$dldir\\64\\a13 "-o$env:systemroot\\system32" -y; quit?('7z')
    7z e $env:TEMP\\$dldir\\32\\a10 "-o$env:systemroot\\syswow64" -y; quit?('7z')
    7z e $env:TEMP\\$dldir\\32\\a11 "-o$env:systemroot\\syswow64" -y; quit?('7z')
    foreach($i in 'concrt140', 'msvcp140', 'msvcp140_1', 'msvcp140_2', 'vcruntime140', 'vcruntime140_1') { dlloverride 'native' $i }
} <# end vcrun2019 #>

function func_dxvk1101
{
    $dldir = "dxvk1101"
    w_download_to "dxvk1101" "https://github.com/doitsujin/dxvk/releases/download/v1.10.1/dxvk-1.10.1.tar.gz" "dxvk-1.10.1.tar.gz"

    7z x -y $cachedir\\$dldir\\dxvk-1.10.1.tar.gz "-o$env:TEMP";quit?('7z') 
    7z e $env:TEMP\\dxvk-1.10.1.tar "-o$env:systemroot\\system32" dxvk-1.10.1/x64 -y;
    7z e $env:TEMP\\dxvk-1.10.1.tar "-o$env:systemroot\\syswow64" dxvk-1.10.1/x32 -y;
    foreach($i in 'dxgi', 'd3d9', 'd3d10_1', 'd3d10core', 'd3d10', 'd3d11') { dlloverride 'native' $i }
} <# end dxvk1101 #>

function func_msado15
{
    validate_cab_existence; $dldir = "aik70"

    $adodlls = @( 'amd64_microsoft-windows-m..ents-mdac-ado15-dll_31bf3856ad364e35_6.1.7600.16385_none_6825d42d8a57b77d/msado15.dll', `
                  'x86_microsoft-windows-m..ents-mdac-ado15-dll_31bf3856ad364e35_6.1.7600.16385_none_0c0738a9d1fa4647/msado15.dll', `
		  'x86_microsoft-windows-m..-components-jetcore_31bf3856ad364e35_6.1.7600.16385_none_046511bf090691ab/msjet40.dll', `
                  'amd64_microsoft-windows-m..ac-ado-ddl-security_31bf3856ad364e35_6.1.7600.16385_none_0e2388835a138ae2/msadox.dll', `
                  'x86_microsoft-windows-m..ac-ado-ddl-security_31bf3856ad364e35_6.1.7600.16385_none_b204ecffa1b619ac/msadox.dll' )

    foreach ($i in $adodlls) {
        switch ( $i.SubString(0,3) ) { 
            'amd'    {7z e $cachedir\\$dldir\\F_WINPEOC_AMD64__WINPE_WINPE_MDAC.CAB "-o$env:CommonProgramFiles\\System\\ADO" $i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])}
            'x86'    {7z e $cachedir\\$dldir\\F_WINPEOC_X86__WINPE_WINPE_MDAC.CAB "-o${env:CommonProgramFiles`(x86`)}\\System\\ADO" $i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])}}} quit?('7z')

    $dlls = @( 'amd64_microsoft-windows-m..ponents-mdac-msdart_31bf3856ad364e35_6.1.7600.16385_none_42074b3f2553d5bd/msdart.dll', `
               'x86_microsoft-windows-m..ponents-mdac-msdart_31bf3856ad364e35_6.1.7600.16385_none_e5e8afbb6cf66487/msdart.dll' )
		 
    foreach ($i in $dlls) {
        switch ( $i.SubString(0,3) ) {
            'amd'    {7z e $cachedir\\$dldir\\F_WINPEOC_AMD64__WINPE_WINPE_MDAC.CAB "-o$env:systemroot\\system32" $i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])}
            'x86'    {7z e $cachedir\\$dldir\\F_WINPEOC_X86__WINPE_WINPE_MDAC.CAB "-o$env:systemroot\\syswow64" $i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])}}} quit?('7z')

    foreach($i in 'msado15') { dlloverride 'native' $i }

    & "$env:systemroot\\system32\\regsvr32" "$env:CommonProgramFiles\\System\\ADO\\msado15.dll"
    & "$env:systemroot\\syswow64\\regsvr32"  "${env:CommonProgramFiles`(x86`)}\\System\\ADO\\msado15.dll"
} <# end msado15 #>

function func_expand
{
    validate_cab_existence; $dldir = "aik70"
    $expdlls = @( 'amd64_microsoft-windows-basic-misc-tools_31bf3856ad364e35_6.1.7600.16385_none_7351a917d91c961e/expand.exe', `
                  'x86_microsoft-windows-basic-misc-tools_31bf3856ad364e35_6.1.7600.16385_none_17330d9420bf24e8/expand.exe',
                  'amd64_microsoft-windows-deltapackageexpander_31bf3856ad364e35_6.1.7600.16385_none_c5d387d64eb8e1f2/dpx.dll',
                  'x86_microsoft-windows-deltapackageexpander_31bf3856ad364e35_6.1.7600.16385_none_69b4ec52965b70bc/dpx.dll',
                  'amd64_microsoft-windows-cabinet_31bf3856ad364e35_6.1.7600.16385_none_933442c3fb9cbaed/cabinet.dll',
                  'x86_microsoft-windows-cabinet_31bf3856ad364e35_6.1.7600.16385_none_3715a740433f49b7/cabinet.dll',
                  'amd64_microsoft-windows-deltacompressionengine_31bf3856ad364e35_6.1.7600.16385_none_9c2159bf9f702069/msdelta.dll',
                  'x86_microsoft-windows-deltacompressionengine_31bf3856ad364e35_6.1.7600.16385_none_4002be3be712af33/msdelta.dll' )
		  
    foreach ($i in $expdlls) {
        switch ( $i.SubString(0,3) ) {
            'amd' {7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/winsxs/$i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])}
            'x86' {7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\\syswow64" Windows/winsxs/$i -y | Select-String 'ok' && Write-Host processed 32-bit $($i.split('/')[-1])}}} quit?('7z')
} <# end expand #>

function func_wmp{ Write-Host TODO, Nothing here yet ...}

function func_mshtml
{
    validate_cab_existence; $dldir = "aik70"

    $iedlls = @( 'amd64_microsoft-windows-ie-htmlrendering_31bf3856ad364e35_8.0.7600.16385_none_89f24b7ab2dc7a40/mshtml.dll', `
                 'x86_microsoft-windows-ie-htmlrendering_31bf3856ad364e35_8.0.7600.16385_none_2dd3aff6fa7f090a/mshtml.dll', ` 
		 'x86_microsoft-windows-ieframe_31bf3856ad364e35_8.0.7600.16385_none_7f3309fa86749737/ieframe.dll', `
                 'amd64_microsoft-windows-ieframe_31bf3856ad364e35_8.0.7600.16385_none_db51a57e3ed2086d/ieframe.dll')

    foreach ($i in $iedlls) {
        switch ( $i.SubString(0,3) ) {
            'amd'    {7z e $cachedir\\$dldir\\F_WINPEOC_AMD64__WINPE_WINPE_HTA.CAB "-o$env:systemroot\\system32" $i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])}
            'x86'    {7z e $cachedir\\$dldir\\F_WINPEOC_X86__WINPE_WINPE_HTA.CAB "-o$env:systemroot\\syswow64" $i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])}}} quit?('7z')

    $sxsdlls = @( 'amd64_microsoft-windows-msls31_31bf3856ad364e35_6.1.7600.16385_none_27f4c55dbc24c492/msls31.dll', `
                  'x86_microsoft-windows-msls31_31bf3856ad364e35_6.1.7600.16385_none_cbd629da03c7535c/msls31.dll' )
		  
    foreach ($i in $sxsdlls) {
        switch ( $i.SubString(0,3) ) {
            'amd' {7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/winsxs/$i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])}
            'x86' {7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\\syswow64" Windows/winsxs/$i -y | Select-String 'ok' && Write-Host processed 32-bit $($i.split('/')[-1])}}} quit?('7z')

    $scrdlls = @( 'amd64_microsoft-windows-scripting-jscript_31bf3856ad364e35_8.0.7600.16385_none_f98f217587d75631/jscript.dll',`
                  'x86_microsoft-windows-scripting-jscript_31bf3856ad364e35_8.0.7600.16385_none_9d7085f1cf79e4fb/jscript.dll')

    foreach ($i in $scrdlls) {
        switch ( $i.SubString(0,3) ) {
            'amd'    {7z e $cachedir\\$dldir\\F_WINPEOC_AMD64__WINPE_WINPE_SCRIPTING.CAB "-o$env:systemroot\\system32" $i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])}
            'x86'    {7z e $cachedir\\$dldir\\F_WINPEOC_X86__WINPE_WINPE_SCRIPTING.CAB "-o$env:systemroot\\syswow64" $i -y | Select-String 'ok' && Write-Host processed 32-bit $($i.split('/')[-1])}}} quit?('7z')

    $dlls = @('urlmon.dll','iertutil.dll')

    foreach ($i in $dlls) {
        7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/System32/$i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])
        7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\syswow64" Windows/System32/$i -y | Select-String 'ok' && Write-Host processed 32-bit $($i.split('/')[-1])} quit?('7z')

    foreach($i in 'mshtml', 'ieframe', 'urlmon', 'jscript') { dlloverride 'native' $i }
    foreach($i in 'msimtf') { dlloverride 'builtin' $i }

<# Note: the 'back-tick+n's below is line-break when we write below stuff to file, saves space  #>
$regkey = @"
REGEDIT4
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

     $regkey | Out-File -FilePath $env:TEMP\\regkey.reg
     reg.exe  IMPORT  $env:TEMP\\regkey.reg /reg:64;
     reg.exe  IMPORT  $env:TEMP\\regkey.reg /reg:32;
} <# end mshtml #>

function func_pwsh40 <# rudimentary powershell 4.0; do 'ps40 -h' for help #>
{   
    $url = "http://download.windowsupdate.com/d/msdownload/update/software/updt/2016/05/windows6.1-kb3125574-v4-x64_2dafb1d203c8964239af3048b5dd4b1264cd93b9.msu"
    $cab = "Windows6.1-KB3125574-v4-x64.cab"
    $sourcefile = @(`
    'msil_system.management.automation_31bf3856ad364e35_7.2.7601.23403_none_7eff6ece76149477/system.management.automation.dll',`
    'msil_microsoft.powershel..ommands.diagnostics_31bf3856ad364e35_7.2.7601.23403_none_3698d2b1b92a6c93/microsoft.powershell.commands.diagnostics.dll',`
    'msil_microsoft.powershell.commands.utility_31bf3856ad364e35_7.2.7601.23403_none_d3399682d6116793/microsoft.powershell.commands.utility.dll',`
    'msil_microsoft.powershell.consolehost_31bf3856ad364e35_7.2.7601.23403_none_800dec9905ffbe44/microsoft.powershell.consolehost.dll',`
    'msil_microsoft.powershell.commands.management_31bf3856ad364e35_7.2.7601.23403_none_bb7937dac719e49e/microsoft.powershell.commands.management.dll',`
    'msil_microsoft.management.infrastructure_31bf3856ad364e35_7.2.7601.23403_none_7ce919f023c2ec6c/microsoft.management.infrastructure.dll',`
    'msil_microsoft.powershell.security_31bf3856ad364e35_7.2.7601.23403_none_5e9a92c38f58880d/microsoft.powershell.security.dll',`
    'msil_microsoft.wsman.runtime_31bf3856ad364e35_7.2.7601.23403_none_9b74191374ab0c76/microsoft.wsman.runtime.dll',`
    'msil_microsoft.wsman.management_31bf3856ad364e35_7.2.7601.23403_none_5a6f52c634b84969/microsoft.wsman.management.dll'`
    )

    $msu = $url.split('/')[-1]; <# -1 is last array element... #> $dldir = $($url.split('/')[-1]) -replace '.msu',''

    if (![System.IO.File]::Exists(  [IO.Path]::Combine($env:systemroot, "system32", "dpx.dll")  ))
       {Write-Host 'Extracting some files needed for expansion' ;func_expand;}

    w_download_to $dldir $url $msu

    if (![System.IO.File]::Exists( [IO.Path]::Combine($cachedir,  $dldir,  $cab) ) )
       {Write-Host file seems missing, re-extracting;7z e $cachedir\\$dldir\\$msu "-o$cachedir\\$dldir" -y; quit?('7z')}

    foreach($i in 'cabinet', 'expand.exe') { dlloverride 'native' $i }      

    foreach ($i in $sourcefile) {
        if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $dldir,  $i) ) ){
            expand.exe $([IO.Path]::Combine($cachedir,  $dldir,  $cab)) -f:$($i.split('/')[-1]) $(Join-Path $cachedir  $dldir) } 
        Copy-Item -force "$(Join-Path $cachedir $dldir)\\$i" $env:systemroot\\system32\\WindowsPowerShell\v1.0\\$($i.split('/')[-1])}

$regkey40 = @"
REGEDIT4

[HKEY_LOCAL_MACHINE\Software\Microsoft\PowerShell]

[HKEY_LOCAL_MACHINE\Software\Microsoft\PowerShell\1]

[HKEY_LOCAL_MACHINE\Software\Microsoft\PowerShell\1\PowerShellEngine]
"ApplicationBase"="C:\\Windows\\System32\\WindowsPowerShell\\v1.0"

[HKEY_LOCAL_MACHINE\Software\Microsoft\PowerShell\3]

[HKEY_LOCAL_MACHINE\Software\Microsoft\PowerShell\3\PowerShellEngine]
"ApplicationBase"="c:\\windows\\system32\\WindowsPowerShell\\v1.0"
"@

    $regkey40 | Out-File -FilePath $env:TEMP\\regkey40.reg
    reg.exe  IMPORT  $env:TEMP\\regkey40.reg /reg:64; quit?('reg')
    reg.exe  IMPORT  $env:TEMP\\regkey40.reg /reg:32; quit?('reg')
		  
<# Included license hereafter: code below is 99 % copy/paste from https://github.com/p3nt4/PowerShdll ( Program.cs and Common.cs ) #>
$ps40script = @"
//MIT License
//Copyright (c) 2017 p3nt4

//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

using System;
using System.Text;
using System.Collections.ObjectModel;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using System.IO;
//https://blogs.msdn.microsoft.com/kebab/2014/04/28/executing-powershell-scripts-from-c/

namespace Powershdll
{  

    static class Program
    {
        static void Main(string[] args)
        {
            PowerShdll psdl = new PowerShdll();
            psdl.start(args);
        }
    }

    class PowerShdll
    {
        PS ps;
        public PowerShdll()
        {
            ps = new PS();
        }
        public void interact()
        {
            Console.ForegroundColor = ConsoleColor.Yellow; Console.WriteLine("Entering PowerShell 4.0 console. Do 'exit' to exit.\n");
            string cmd = "";
            while (cmd.ToLower() != "exit")
            {
                Console.Write("PS 4.0!\\" + ps.exe("`$(get-location).Path").Replace(System.Environment.NewLine, String.Empty) + ">");
                cmd = Console.ReadLine();
                Console.WriteLine(ps.exe(cmd));
            } Console.ForegroundColor = ConsoleColor.White;
        }
        public static string LoadScript(string filename)
        {
            try
            {
                using (StreamReader sr = new StreamReader(filename))
                {
                    StringBuilder fileContents = new StringBuilder();
                    string curLine;
                    while ((curLine = sr.ReadLine()) != null)
                    {
                        fileContents.Append(curLine + "\n");
                    }
                    return fileContents.ToString();
                }
            }
            catch (Exception e)
            {
                string errorText = e.Message + "\n";
                Console.WriteLine(errorText);
                return ("error");
            }

        }
        public void usage()
        {
            Console.WriteLine("Usage:");
            Console.WriteLine("ps40 <script>");
            Console.WriteLine("ps40 -h\t Display this messages");
            Console.WriteLine("ps40 -f <path>\t Run the script passed as argument");
            Console.WriteLine("ps40 -i\t Start an interactive console (Default)");
        }
        public void start(string[] args)
        {
            // Place payload here for embeded payload:
            string payload = "";
            if (payload.Length != 0) {
                Console.Write(ps.exe(payload));
                ps.close(); 
                return; 
            }
            if (args.Length==0) { this.interact(); return; }
            else if (args[0] == "-h")
            {
                usage();
            }
            else if (args[0] == "-w")
            {
                this.interact();
            }
            else if (args[0] == "-i")
            {
                Console.Title = "PowerShdll";
                this.interact();
                ps.close();
            }
            else if (args[0] == "-f")
            {
                if (args.Length < 2) { usage(); return; }
                string script = PowerShdll.LoadScript(args[1]);
                if (script != "error")
                {
                    Console.Write(ps.exe(script));
                }
            }
            else
            {
                string script = string.Join(" ", args);
                Console.Write(ps.exe(script));
                ps.close();
            }
            return;
        }
    }

    public class PS
    {
        Runspace runspace;

        public PS()
        {
            this.runspace = RunspaceFactory.CreateRunspace();
            // open it
            this.runspace.Open();

        }
        public string exe(string cmd)
        {
            try
            {
                Pipeline pipeline = runspace.CreatePipeline();
                pipeline.Commands.AddScript(cmd);
                pipeline.Commands.Add("Out-String");
                Collection<PSObject> results = pipeline.Invoke();
                StringBuilder stringBuilder = new StringBuilder();
                foreach (PSObject obj in results)
                {
                    foreach (string line in obj.ToString().Split(new[] { "\r\n", "\r", "\n" }, StringSplitOptions.None))
                    {
                        stringBuilder.AppendLine(line.TrimEnd());
                    }
                }
                return stringBuilder.ToString();
            }
            catch (Exception e)
            {
                // Let the user know what went wrong.

                string errorText = e.Message + "\n";
                return (errorText);
            }
        }
        public void close()
        {
            this.runspace.Close();
        }
    }
}
"@
    $ps40script | Out-File $env:SystemRoot\\system32\\WindowsPowerShell\v1.0\\ps40.cs
    &$env:systemroot\\Microsoft.NET\\Framework64\\v4.0.30319\\csc.exe /r:$env:SystemRoot\\system32\\WindowsPowerShell\v1.0\\system.management.automation.dll `
        /out:$env:SystemRoot\\system32\\WindowsPowerShell\v1.0\\ps40.exe "$env:SystemRoot\\system32\\WindowsPowerShell\v1.0\\ps40.cs"

    foreach($i in 'cabinet', 'expand.exe') { dlloverride 'builtin' $i }      
} <# end pwsh40 #>


function func_msvbvm60 <# msvbvm60 #>
{   
    $url = "http://download.windowsupdate.com/d/msdownload/update/software/updt/2016/05/windows6.1-kb3125574-v4-x64_2dafb1d203c8964239af3048b5dd4b1264cd93b9.msu"
    $cab = "Windows6.1-KB3125574-v4-x64.cab"
    $sourcefile = @(`
    'x86_microsoft-windows-msvbvm60_31bf3856ad364e35_6.1.7601.23403_none_c51e69cfc91299fe/msvbvm60.dll'
    )

    $msu = $url.split('/')[-1]; <# -1 is last array element... #> $dldir = $($url.split('/')[-1]) -replace '.msu',''

    if (![System.IO.File]::Exists(  [IO.Path]::Combine($env:systemroot, "system32", "dpx.dll")  ))
       {Write-Host 'Extracting some files needed for expansion' ;func_expand;}

    w_download_to $dldir $url $msu

    if (![System.IO.File]::Exists( [IO.Path]::Combine($cachedir,  $dldir,  $cab) ) )
       {Write-Host file seems missing, re-extracting;7z e $cachedir\\$dldir\\$msu "-o$cachedir\\$dldir" -y; quit?('7z')}

    foreach($i in 'cabinet', 'expand.exe') { dlloverride 'native' $i }      

    foreach ($i in $sourcefile) {
        if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $dldir,  $i) ) ){
            expand.exe $([IO.Path]::Combine($cachedir,  $dldir,  $cab)) -f:$($i.split('/')[-1]) $(Join-Path $cachedir  $dldir) } 
        Copy-Item -force "$(Join-Path $cachedir $dldir)\\$i" $env:systemroot\\syswow64\\$($i.split('/')[-1])}

    foreach($i in 'cabinet', 'expand.exe') { dlloverride 'builtin' $i }      
} <# end msvbvm60 #>

<# Main function #>
if(!$args.count){
    $Result = $custom_array  | select name,description | Out-GridView  -PassThru  -Title 'Make a  selection'
    Foreach ($i in $Result){ $call = 'func_' +  $i.Name; & $call; } }
else { for ( $i = 0; $i -lt $args.count; $i++ ) { $call = 'func_' +  $args[$i]; & $call; } }
