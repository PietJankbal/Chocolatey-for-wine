$cachedir = ("$env:WINEHOMEDIR" + "\.cache\winetrickxs").substring(4)

if (!(Test-Path -Path "$env:ProgramW6432\7-Zip\7z.exe" -PathType Leaf)) {
    choco install 7zip -y }

function validate_param
{
[CmdletBinding()]
 Param(
        [Parameter(Mandatory=$false)]
        [ValidateSet('msxml3', 'msxml6','gdiplus', 'robocopy', 'msado15', 'expand', 'wmp', 'ucrtbase', 'vcrun2019', 'mshtml')]
        [string[]]$verb
      )
}

try {validate_param $args}
catch [System.Management.Automation.ParameterBindingException] {Write-Host "Error: [$_.Exception.Message]" -ForegroundColor Red; exit}

$custom_array = @() # Creating an empty array to populate data in

[array]$Qenu = "gdiplus","GDI+, todo: check if this version works",`
               "msxml3","msxml3+msxml3r",`
	       "msxml6","msxml6+msxml6r",`
               "robocopy","robocopy.exe + mfc42(u)",`
	       "msado15","some minimal mdac dlls",`
	       "expand", "native expand.exe",`
               "wmp", "some wmp (windows media player) dlls",`
	       "ucrtbase", "ucrtbase from vcrun2015",`
	       "vcrun2019", "vcredist2019",`
	       "mshtml", "native mshtml, experimental"

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

function func_msxml3
{
    validate_cab_existence
    $dlls = @('msxml3.dll','msxml3r.dll'); $dldir = "aik70"

    foreach ($i in $dlls) {
        7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/System32/$i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])
        7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\\syswow64" Windows/System32/$i -y| Select-String 'ok' && Write-Host processed 32-bit $($i.split('/')[-1])} quit?('7z')
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'msxml3' -Value 'native' -PropertyType 'String'
}

function func_msxml6
{
    validate_cab_existence
    $dlls = @('msxml6.dll', 'msxml6r.dll'); $dldir = "aik70"

    foreach ($i in $dlls) {
        7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/System32/$i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])
        7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\\syswow64" Windows/System32/$i -y| Select-String 'ok' && Write-Host processed 32-bit $($i.split('/')[-1])} quit?('7z')
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'msxml6' -Value 'native' -PropertyType 'String'
}

function func_robocopy
{
    validate_cab_existence
    $dlls = @('robocopy.exe', 'mfc42.dll', 'mfc42u.dll'); $dldir = "aik70"

    foreach ($i in $dlls) {
        7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/System32/$i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])
        7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\\syswow64" Windows/System32/$i -y| Select-String 'ok' && Write-Host processed 32-bit $($i.split('/')[-1])} quit?('7z')
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'robocopy.exe' -Value 'native' -PropertyType 'String'
}

function func_gdiplus
{
    validate_cab_existence; $dldir = "aik70"
    $sxsdlls = @( 'amd64_microsoft.windows.gdiplus_6595b64144ccf1df_1.0.7600.16385_none_3bfdd703d890231d/gdiplus.dll', `
                  'x86_microsoft.windows.gdiplus_6595b64144ccf1df_1.0.7600.16385_none_83ab0ddaed0c4c23/gdiplus.dll' )
		  
    foreach ($i in $sxsdlls) {
        switch ( $i.SubString(0,3) ) {
            'amd' {7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/winsxs/$i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])}
            'x86' {7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\\syswow64" Windows/winsxs/$i -y | Select-String 'ok' && Write-Host processed 32-bit $($i.split('/')[-1])}}} quit?('7z')
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'gdiplus' -Value 'native' -PropertyType 'String'
}

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
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'ucrtbase' -Value 'native' -PropertyType 'String'
}

function func_vcrun2019
{
    func_ucrtbase
    
    choco install vcredist140 -n
    .   $env:ProgramData\\chocolatey\\lib\\vcredist140\\tools\\data.ps1  #source the file via dot operator
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
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'msxml3' -Value 'native' -PropertyType 'String'
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'concrt140' -Value 'native' -PropertyType 'String'
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'msvcp140' -Value 'native' -PropertyType 'String'
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'msvcp140_1' -Value 'native' -PropertyType 'String'
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'msvcp140_2' -Value 'native' -PropertyType 'String'
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'vcruntime140' -Value 'native' -PropertyType 'String'
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'vcruntime140_1' -Value 'native' -PropertyType 'String'
}

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

    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'msado15' -Value 'native' -PropertyType 'String'

    & "$env:systemroot\\system32\\regsvr32" "$env:CommonProgramFiles\\System\\ADO\\msado15.dll"
    & "$env:systemroot\\syswow64\\regsvr32"  "${env:CommonProgramFiles`(x86`)}\\System\\ADO\\msado15.dll"
}

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
}

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

    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'mshtml' -Value 'native' -PropertyType 'String'
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'ieframe' -Value 'native' -PropertyType 'String'

    $sxsdlls = @( 'amd64_microsoft-windows-msls31_31bf3856ad364e35_6.1.7600.16385_none_27f4c55dbc24c492/msls31.dll', `
                  'x86_microsoft-windows-msls31_31bf3856ad364e35_6.1.7600.16385_none_cbd629da03c7535c/msls31.dll' )
		  
    foreach ($i in $sxsdlls) {
        switch ( $i.SubString(0,3) ) {
            'amd' {7z e $cachedir\\$dldir\\F3_WINPE.WIM "-o$env:systemroot\\system32" Windows/winsxs/$i -y | Select-String 'ok' && Write-Host processed 64-bit $($i.split('/')[-1])}
            'x86' {7z e $cachedir\\$dldir\\F1_WINPE.WIM "-o$env:systemroot\\syswow64" Windows/winsxs/$i -y | Select-String 'ok' && Write-Host processed 32-bit $($i.split('/')[-1])}}} quit?('7z')
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'ieframe' -Value 'native' -PropertyType 'String'
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'msimtf' -Value 'builtin' -PropertyType 'String'

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
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'urlmon' -Value 'native' -PropertyType 'String'
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'jscript' -Value 'native' -PropertyType 'String'

$regkey = @"
REGEDIT4

[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Lockdown_Zones]

[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Lockdown_Zones\0]

[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3]
@=""
"1206"=dword:00000003
"1207"=dword:00000003
"1208"=dword:00000003
"1209"=dword:00000003
"120A"=dword:00000003
"120B"=dword:00000003
"1408"=dword:00000003
"1409"=dword:00000000
"160A"=dword:00000003
"1806"=dword:00000001
"1807"=dword:00000001
"1808"=dword:00000000
"1809"=dword:00000000
"180A"=dword:00000003
"180C"=dword:00000003
"180D"=dword:00000001
"2000"=dword:00000000
"2005"=dword:00000003
"2100"=dword:00000000
"2101"=dword:00000000
"2102"=dword:00000003
"2103"=dword:00000003
"2104"=dword:00000003
"2105"=dword:00000003
"2106"=dword:00000000
"2200"=dword:00000003
"2201"=dword:00000003
"2300"=dword:00000001
"2301"=dword:00000000
"2400"=dword:00000000
"2401"=dword:00000000
"2402"=dword:00000000
"2500"=dword:00000000
"2600"=dword:00000000
"2700"=dword:00000000
"Icon"="inetcpl.cpl#001313"
"LowIcon"="inetcpl.cpl#005425"
"PMDisplayName"="Internet [Protected Mode]"
"RecommendedLevel"=dword:00011500
"@

     $regkey | Out-File -FilePath $env:TEMP\\regkey.reg
     reg.exe  IMPORT  $env:TEMP\\regkey.reg /reg:64; quit?('reg')
     reg.exe  IMPORT  $env:TEMP\\regkey.reg /reg:32; quit?('reg')
}

function func_wmp <# This makes e-Sword start #>
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
    'wow64_microsoft-windows-mediaplayer-core_31bf3856ad364e35_6.2.9200.16384_none_6e8814d60d3eb187/wmp.dll',`
    'amd64_microsoft-windows-mediaplayer-core_31bf3856ad364e35_6.2.9200.16384_none_64336a83d8ddef8c/wmp.dll',`
    'wow64_microsoft-windows-mediaplayer-core_31bf3856ad364e35_6.2.9200.16384_none_6e8814d60d3eb187/wmploc.dll',`
    'amd64_microsoft-windows-mediaplayer-core_31bf3856ad364e35_6.2.9200.16384_none_64336a83d8ddef8c/wmploc.dll',`
    'wow64_microsoft-windows-mediafoundation_31bf3856ad364e35_6.2.9200.16384_none_ff7d80f2cae6a275/mf.dll',`
    'amd64_microsoft-windows-mediafoundation_31bf3856ad364e35_6.2.9200.16384_none_f528d6a09685e07a/mf.dll',`
    'wow64_microsoft-windows-mfreadwrite_31bf3856ad364e35_6.2.9200.16384_none_1c7439bad6296610/mfreadwrite.dll',`
    'amd64_microsoft-windows-mfreadwrite_31bf3856ad364e35_6.2.9200.16384_none_121f8f68a1c8a415/mfreadwrite.dll',`
    'amd64_microsoft-windows-enhancedvideorenderer_31bf3856ad364e35_6.2.9200.16384_none_e86c2510564ab50b/evr.dll',`
    'x86_microsoft-windows-enhancedvideorenderer_31bf3856ad364e35_6.2.9200.16384_none_8c4d898c9ded43d5/evr.dll',`
    'x86_microsoft-windows-msmpeg2adec_31bf3856ad364e35_6.2.9200.16384_none_8e855f0288be81c1/msmpeg2adec.dll',`
    'amd64_microsoft-windows-msmpeg2adec_31bf3856ad364e35_6.2.9200.16384_none_eaa3fa86411bf2f7/msmpeg2adec.dll',`
    'x86_microsoft-windows-msmpeg2vdec_31bf3856ad364e35_6.2.9200.16384_none_8da250a68968cc86/msmpeg2vdec.dll',`
    'amd64_microsoft-windows-msmpeg2vdec_31bf3856ad364e35_6.2.9200.16384_none_e9c0ec2a41c63dbc/msmpeg2vdec.dll',`
    'wow64_microsoft-windows-mfnetcore_31bf3856ad364e35_6.2.9200.16384_none_f1f2450aab394253/mfnetcore.dll',`
    'amd64_microsoft-windows-mfnetcore_31bf3856ad364e35_6.2.9200.16384_none_e79d9ab876d88058/mfnetcore.dll',`
    'wow64_microsoft-windows-mfcore_31bf3856ad364e35_6.2.9200.16384_none_53f6f7ec15569064/mfcore.dll',`
    'amd64_microsoft-windows-mfcore_31bf3856ad364e35_6.2.9200.16384_none_49a24d99e0f5ce69/mfcore.dll'`
    )

    $msu = $url.split('/')[-1]; <# -1 is last array element... #> $dldir = $($url.split('/')[-1]) -replace '.msu',''

    if (![System.IO.File]::Exists(  [IO.Path]::Combine($env:systemroot, "system32", "dpx.dll")  ))
       {Write-Host 'Extracting some files needed for expansion' ;func_expand;}

    w_download_to $dldir $url $msu

    if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $dldir,  $cab) ) )
       {Write-Host file seems missing, re-extracting;7z e $cachedir\\$dldir\\$msu "-o$cachedir\\$dldir" -y; quit?('7z')}
       
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'cabinet' -Value 'native' -PropertyType 'String' | Out-Null
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'expand.exe' -Value 'native' -PropertyType 'String' | Out-Null

    foreach ($i in $sourcefile) {
              switch ( $i.SubString(0,3) ) {
                  'amd'                    {expand.exe $([IO.Path]::Combine($cachedir,  $dldir,  $cab)) -f:$($i.split('/')[-1]) $env:TEMP }
                  {$_ -in 'wow', 'x86'}    {<# Nothing to do #>}                                                                          } }

    foreach ($i in $sourcefile) {
              switch ( $i.SubString(0,3) ) {
                  'amd'                    {Copy-Item -force $env:TEMP\\$i $env:systemroot\\system32\\$($i.split('/')[-1])}
                  {$_ -in 'wow', 'x86'}    {Copy-Item -force $env:TEMP\\$i $env:systemroot\\syswow64\\$($i.split('/')[-1])} } }
		  
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'cabinet' -Value 'builtin' -PropertyType 'String' | Out-Null
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'expand.exe' -Value 'builtin' -PropertyType 'String' | Out-Null
}

# Main function
if(!$args.count){
    $Result = $custom_array  | select name,description | Out-GridView  -PassThru  -Title 'Make a  selection' 

    Foreach ($i in $Result){
        $call = 'func_' +  $i.Name; & $call;
    }
}
else {
    for ( $i = 0; $i -lt $args.count; $i++ ) {
        $call = 'func_' +  $args[$i]; & $call;
    }
}
