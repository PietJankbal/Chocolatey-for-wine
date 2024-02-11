$cachedir = ("$env:WINEHOMEDIR" + "\.cache\winetrickxs").substring(4)

$expand_exe = "$env:systemroot\system32\expnd\expand.exe"

if (!(Test-Path -Path "$env:ProgramW6432\7-Zip\7z.exe" -PathType Leaf)) { choco install 7zip -y }

function quit?([string] $process)  <# wait for a process to quit #>
{
    Get-Process $process -ErrorAction:SilentlyContinue | Foreach-Object { $_.WaitForExit() }
}

function w_download_to
{
    Param ($dldir, $w_url, $w_file)

    if (![System.IO.Directory]::Exists("$env:WINEHOMEDIR\\.cache\\winetrickxs\\$dldir".substring(4))){ [System.IO.Directory]::CreateDirectory("$env:WINEHOMEDIR\\.cache\\winetrickxs\\$dldir".substring(4))}

    if (![System.IO.File]::Exists("$env:WINEHOMEDIR\\.cache\\winetrickxs\\$dldir\\$w_file".substring(4))){
        Write-Host -foregroundcolor yellow "**********************************************************"
        Write-Host -foregroundcolor yellow "*                                                        *"
        Write-Host -foregroundcolor yellow "*        Downloading file(s) and extracting might        *"
        Write-Host -foregroundcolor yellow "*        take several minutes!                           *"
        Write-Host -foregroundcolor yellow "*        Patience please!                                *"
        Write-Host -foregroundcolor yellow "*                                                        *"
        Write-Host -foregroundcolor yellow "**********************************************************"

        (New-Object System.Net.WebClient).DownloadFile($w_url, "$env:WINEHOMEDIR\\.cache\\winetrickxs\\$dldir\\$w_file".substring(4))}
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
            w_download_to "aik70" "$url" "KB3AIK_EN.iso"
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

function func_msxml6
{
    $dlls = @('msxml6.dll', 'msxml6r.dll'); check_aik_sanity;

    foreach ($i in $dlls) {
        7z e "$cachedir\aik70\F3_WINPE.WIM" "-o$env:systemroot\system32" "Windows/System32/$i" -y | Select-String 'ok'
        7z e "$cachedir\aik70\F1_WINPE.WIM" "-o$env:systemroot\syswow64" "Windows/System32/$i" -y| Select-String 'ok' } ; quit?('7z')
    foreach($i in 'msxml6') { dlloverride 'native' $i }
} <# end msxml6 #>

function func_mfc42
{
    $dlls = @('mfc42.dll', 'mfc42u.dll'); check_aik_sanity;

    foreach ($i in $dlls) {
        7z e "$cachedir\aik70\F3_WINPE.WIM" "-o$env:systemroot\system32" "Windows/System32/$i" -y | Select-String 'ok'
        7z e "$cachedir\aik70\F1_WINPE.WIM" "-o$env:systemroot\syswow64" "Windows/System32/$i" -y| Select-String 'ok' } ; quit?('7z')
} <# end mfc42 #>

function func_riched20
{
    $dlls = @('riched20.dll','msls31.dll'); check_aik_sanity;

    foreach ($i in $dlls) {
        7z e "$cachedir\aik70\F3_WINPE.WIM" "-o$env:systemroot\system32" "Windows/System32/$i" -y | Select-String 'ok'
        7z e "$cachedir\aik70\F1_WINPE.WIM" "-o$env:systemroot\syswow64" "Windows/System32/$i" -y| Select-String 'ok' } ; quit?('7z') 
    foreach($i in 'riched20') { dlloverride 'native' $i }
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

function func_sspicli
{
    $dlls = @('sspicli.dll'); check_aik_sanity;

    foreach ($i in $dlls) {
        7z e "$cachedir\aik70\F3_WINPE.WIM" "-o$env:systemroot\system32" "Windows/System32/$i" -y | Select-String 'ok'
        7z e "$cachedir\aik70\F1_WINPE.WIM" "-o$env:systemroot\syswow64" "Windows/System32/$i" -y| Select-String 'ok' } ; quit?('7z') 
    foreach($i in 'sspicli') { dlloverride 'native' $i }
}  <# end sspicli #>

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

    7z e "$cachedir\$(verb)\$(verb).7z" "amd64*\*" -o"$env:systemroot\\system32" -aoa
    7z e "$cachedir\$(verb)\$(verb).7z" "x86*\*" -o"$env:systemroot\\syswow64" -aoa
		  
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

    $voice = new-object -com SAPI.SpVoice
    $voice.Speak("This is mostly a bunch of crap. Please improve me", 2)
} <# end sapi #>

function func_winmetadata <# winmetadata #>
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
    
    #https://devblogs.microsoft.com/powershell/when-powershellget-v1-fails-to-install-the-nuget-provider/
        <#$sourcefile = @(,, 
    NEED SPECIAL TREATMENT!!!!!!!!!!!!!!!!!!!!!!!                 ,
    
                    'powershell.exe', --->> done 'microsoft.management.infrastructure.native.dll',
                     , 'Policy.1.0.System.Management.Automation.config', 'Policy.1.0.System.Management.Automation.dll') #>
    

    

 
    
    <# #Temporary workaround: In staging running ps51.exe frequently hangs in recent versions (e.g. 8.15)
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
    #>
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


        
        foreach ($i in (gci "$cachedir\$(verb)\*.manifest")) {
            $Xml = [xml](Get-Content -Path $i.FullName )
        
            $file_names= $Xml.assembly.file | Where-Object -Property name
            
            foreach ($name in $file_names.name ) { & $expand_exe $([IO.Path]::Combine($cachedir,  $(verb),  $cab)) -f:$name $([IO.Path]::Combine($cachedir,  $(verb) ) ) 
            install_from_manifest $i.FullName  $([IO.Path]::Combine($cachedir,  $(verb), $i.BaseName, $name ) )  "$env:TEMP"}
        }
        
        & $expand_exe $([IO.Path]::Combine($cachedir,  $(verb),  $cab)) -f:"powershell.exe" $([IO.Path]::Combine($cachedir,  $(verb) ) )
Copy-Item -Path  $([IO.Path]::Combine($cachedir,  $(verb), "amd64_microsoft-windows-powershell-exe_31bf3856ad364e35_7.3.7601.16384_none_48be7e79e188387e", "powershell.exe" ) ) -destination  "$env:TEMP\c:\windows\system32\WindowsPowershell\v1.0\ps51.exe" -verbose
Copy-Item -Path  $([IO.Path]::Combine($cachedir,  $(verb), "wow64_microsoft-windows-powershell-exe_31bf3856ad364e35_7.3.7601.16384_none_531328cc15e8fa79", "powershell.exe" ) ) -destination  "$env:TEMP\c:\windows\syswow64\WindowsPowershell\v1.0\ps51.exe" -verbose

        Remove-Item -Force "$cachedir\$(verb)\$cab" -ErrorAction SilentlyContinue
        foreach($i in 'amd64', 'x86', 'wow64', 'msil') { Remove-Item -Force -Recurse "$cachedir\$(verb)\$i*" }
       Remove-Item -Force "$cachedir\$(verb)\*.manifest" -ErrorAction SilentlyContinue
        
#amd64_microsoft-windows-powershell-exe_31bf3856ad364e35_7.3.7601.16384_none_48be7e79e188387e.manifest
#wow64_microsoft-windows-powershell-exe_31bf3856ad364e35_7.3.7601.16384_none_531328cc15e8fa79.manifest

       # Write-Host -foregroundColor yellow 'Starting copying files , this takes a while (> 3 minutes), patience...'    
       # foreach ($i in $(Get-ChildItem "$cachedir\$(verb)\*.manifest").FullName) { install_from_manifest($i, $i.Replace('manifest','\\') + $name) }

       Push-Location ; Set-Location $env:TEMP 
       7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on  "$cachedir\$(verb)\$(verb).7z" ".\c:\"
       Pop-Location 
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

`$env:PSMOdulePath="`$env:SystemRoot\system32\WindowsPowershell\v1.0\Modules;`$env:ProgramFiles(x86)\WindowsPowerShell\Modules;`$env:ProgramFiles\WindowsPowerShell\Modules"

#Import-Module `$env:SystemRoot\system32\WindowsPowerShell\v1.0\Modules\microsoft.powershell.utility\microsoft.powershell.utility.psm1

`$env:PS51 = 1

Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord

function Get-CIMInstance ( [parameter(position=0)] [string]`$classname, [string[]]`$property="*")
{
     Get-WMIObject `$classname -property `$property
}

Set-Alias -Name gcim -Value Get-CIMInstance

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

. "`$env:ProgramData\Chocolatey-for-wine\profile_winetricks_caller.ps1"

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

        
        
        exit
        foreach ($i in (gci "$cachedir\$(verb)\msil_*\*").FullName ) {
         
            
            if("$(([System.IO.FileInfo]$i).Extension)" -eq '.config') {
                $assembly=[System.Reflection.AssemblyName]::GetAssemblyName($($i -replace '.config' , '.dll'))
            }
            else {
                $assembly=[System.Reflection.AssemblyName]::GetAssemblyName($i)
            }
            
            $publickeytoken = ($assembly.GetPublicKeyToken() |ForEach-Object ToString x2) -join '' 
      
            $destdir = "$env:SystemRoot" + "\" + "Microsoft.NET\assembly\GAC_MSIL\" + $assembly.Name + '\' + 'v4.0_' + $assembly.Version.ToString() + '__' + $publickeytoken
        
            7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on "$cachedir\$(verb)\$(verb).7z" $i; quit?('7z')
            7z rn "$cachedir\$(verb)\$(verb).7z" "$(([System.IO.FileInfo]$i).Name)" "$destdir\$(([System.IO.FileInfo]$i).Name)" ; quit?('7z')
        }

        foreach ($i in 'powershell.exe', 'microsoft.management.infrastructure.native.dll' ) {
 
            foreach ($j in (gci "$cachedir\$(verb)\*\$i" ).FullName) {
                if( $(([System.IO.FileInfo]$j).Directory).Name.SubString(0,3) -eq 'amd' ) {$arch = 'system32'} else {$arch = 'syswow64'}
                if( $(([System.IO.FileInfo]$j).Name) -eq 'powershell.exe') {$destfile = 'ps51.exe'} else {$destfile = $(([System.IO.FileInfo]$j).Name)}

                7z a -spf -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on "$cachedir\$(verb)\$(verb).7z" $j; quit?('7z')
                7z rn "$cachedir\$(verb)\$(verb).7z" "$j" "$env:SystemRoot\$arch\WindowsPowershell\v1.0\$destfile" ; quit?('7z')
            } 
         }

         foreach ($i in 'microsoft.powershell.management.psd1', 'microsoft.powershell.utility.psd1', 'microsoft.powershell.utility.psm1',`
                 'microsoft.powershell.archive.psm1', 'microsoft.powershell.archive.psd1', 'microsoft.powershell.diagnostics.psd1', 'microsoft.powershell.security.psd1' ) {
 
             foreach ($j in (gci "$cachedir\$(verb)\*\$i" ).FullName) {
                  7z a -spf -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on "$cachedir\$(verb)\$(verb).7z" $j; quit?('7z')

                  if( $(([System.IO.FileInfo]$j).Directory).Name.SubString(0,3) -eq 'amd' ) {$arch = 'system32'} else {$arch = 'syswow64'}
                  7z rn "$cachedir\$(verb)\$(verb).7z" "$j" "$env:SystemRoot\$arch\WindowsPowershell\v1.0\Modules\$(([System.IO.FileInfo]$j).BaseName)\$(([System.IO.FileInfo]$j).Name)" ; quit?('7z')
             }
         }
    #}

    foreach($i in 'amd64', 'x86', 'wow64', 'msil') { Remove-Item -Force -Recurse "$cachedir\$(verb)\$i*" }

    7z x -spf "$cachedir\$(verb)\$(verb).7z" -aoa

    Copy-Item -Path "$env:systemroot\system32\WindowsPowershell\v1.0\microsoft.management.infrastructure.native.dll" -Destination (New-item -Name "Microsoft.Management.Infrastructure\v4.0_1.0.0.0__31bf3856ad364e35" -Type directory -Path "$env:systemroot\Microsoft.NET/assembly/GAC_64" -Force) -Force 
    Copy-Item -Path "$env:systemroot\syswow64\WindowsPowershell\v1.0\microsoft.management.infrastructure.native.dll" -Destination (New-item -Name "Microsoft.Management.Infrastructure\v4.0_1.0.0.0__31bf3856ad364e35" -Type directory -Path "$env:systemroot\Microsoft.NET/assembly/GAC_32" -Force) -Force 

    #if ( ( (Get-PSCallStack)[1].Command -ne 'func_ps51_ise') -and ( (Get-PSCallStack)[1].Command -ne 'func_access_winrt_from_powershell2')  ) { ps51 }

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

    func_font_lucida

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
    $sourcefile = @('coremessaging.dll', 'windows.ui.xaml.dll', 'bcp47langs.dll')

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
    
    if ( ![System.IO.File]::Exists( [IO.Path]::Combine("$cachedir",  "$(verb)",  "64", "VC_redist.x64.exe" ) ) -or 
         ![System.IO.File]::Exists( [IO.Path]::Combine("$cachedir",  "$(verb)",  "32", "VC__redist.x86.exe") ) ) {
        choco install vcredist140 -n -force
        . $env:ProgramData\\chocolatey\\lib\\vcredist140\\tools\\data.ps1 
        w_download_to "$(verb)\\64" $installData64.url64 "VC_redist.x64.exe"
        w_download_to "$(verb)\\32" $installData32.url "VC__redist.x86.exe" 
    }
    
    iex "$cachedir\$(verb)\64\VC_redist.x64.exe /q"
    iex "$cachedir\$(verb)\32\VC__redist.x86.exe /q"
     
    7z -t# x $cachedir\\$(verb)\\64\\VC_redist.x64.exe "-o$env:TEMP\\$(verb)\\64" 4.cab -y | Select-String 'ok'; quit?('7z')
    7z e $env:TEMP\\$(verb)\\64\\4.cab "-o$env:TEMP\\$(verb)\\64" a2 -y | Select-String 'ok' ;quit?('7z')

    & $expand_exe "$env:TEMP\$(verb)\64\a2" -f:"Windows8.1-KB2999226-x64.cab" "$env:TEMP\\$(verb)\\64" 
    & $expand_exe  "$env:TEMP\$(verb)\64\Windows8.1-KB2999226-x64.cab" -f:"ucrtbase.dll" "$env:TEMP\\$(verb)\\64"

    Copy-Item -Path "$env:TEMP\$(verb)\64\amd*\*" -Destination "$env:SystemRoot\\system32" -Force -Verbose
    Copy-Item -Path "$env:TEMP\$(verb)\64\x86*\*" -Destination "$env:windir\\SysWOW64" -Force -Verbose
    
    Remove-Item -Force -Recurse "$env:TEMP\$(verb)"
        
    foreach($i in 'concrt140', 'msvcp140', 'msvcp140_1', 'msvcp140_2', 'vcruntime140', 'vcruntime140_1', 'ucrtbase') { dlloverride 'native' $i }
} <# end vcrun2019 #>

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

function func_wine_advapi32 <# wine advapi32 with some hacks  #>
{
    w_download_to "$(verb)" "https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/EXTRAS/$(verb).7z" "$(verb).7z"

    foreach ($i in $(verb).substring(5) ){
        7z e "$cachedir\\$(verb)\\$(verb).7z" "-o$env:systemroot\system32" "64/$i.dll" -aoa | Select-String 'ok' 
        7z e "$cachedir\\\\$(verb)\\$(verb).7z" "-o$env:systemroot\syswow64" "32/$i.dll" -aoa | Select-String 'ok'  }
} <# end advapi32 #>

function func_wine_shell32 <# wine shell32 with some hack  #>
{
    w_download_to "$(verb)" "https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/EXTRAS/$(verb).7z" "$(verb).7z"

    foreach ($i in $(verb).substring(5) ){
        7z e "$cachedir\\$(verb)\\$(verb).7z" "-o$env:systemroot\system32" "64/$i.dll" -aoa | Select-String 'ok' 
        7z e "$cachedir\\\\$(verb)\\$(verb).7z" "-o$env:systemroot\syswow64" "32/$i.dll" -aoa | Select-String 'ok'  }
    foreach($i in $(verb).substring(5) ) { dlloverride 'native' $i }
} <# end shell32 #>

function func_wine_combase <# wine combase with some hacks  #>
{
    if( [System.IO.File]::Exists( $([IO.Path]::Combine($cachedir,  $(verb), "$(verb).7z") )) -and ( (Get-FileHash  "$cachedir\$(verb)\$(verb).7z").Hash -ne '2DA34A53C4F1C6932BA0B55293CB6EBEFA6169CE8AD536836C48799A4169EFF3') )  {
        Remove-Item -Force  "$cachedir\$(verb)\$(verb).7z" 
    }
    w_download_to "$(verb)" "https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/EXTRAS/$(verb).7z" "$(verb).7z"

    foreach ($i in $(verb).substring(5) ){
        7z e "$cachedir\\$(verb)\\$(verb).7z" "-o$env:systemroot\system32" "64/$i.dll" -aoa | Select-String 'ok' 
        7z e "$cachedir\\\\$(verb)\\$(verb).7z" "-o$env:systemroot\syswow64" "32/$i.dll" -aoa | Select-String 'ok'  }
    foreach($i in $(verb).substring(5) ) { dlloverride 'native' $i }
} <# end combase #>

function func_wine_shell32 <# wine shell32 with some hacks  #>
{
    w_download_to "$(verb)" "https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/EXTRAS/$(verb).7z" "$(verb).7z"

    foreach ($i in $(verb).substring(5) ){
        7z e "$cachedir\\$(verb)\\$(verb).7z" "-o$env:systemroot\system32" "64/$i.dll" -aoa | Select-String 'ok' 
        7z e "$cachedir\\\\$(verb)\\$(verb).7z" "-o$env:systemroot\syswow64" "32/$i.dll" -aoa | Select-String 'ok'  }
} <# end shell32 #>

function func_wine_sppc <# wine sppc with some hacks #>
{
    w_download_to "$(verb)" "https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/EXTRAS/$(verb).7z" "$(verb).7z"

    foreach ($i in $(verb).substring(5) ){
        7z e "$cachedir\\$(verb)\\$(verb).7z" "-o$env:systemroot\system32" "64/$i.dll" -aoa | Select-String 'ok' 
        7z e "$cachedir\\\\$(verb)\\$(verb).7z" "-o$env:systemroot\syswow64" "32/$i.dll" -aoa | Select-String 'ok'  }
} <# end sppc #>

function func_wine_wintypes <# wine wintypes #>
{
    
    if( [System.IO.File]::Exists( $([IO.Path]::Combine($cachedir,  $(verb), "$(verb).7z") )) -and ( (Get-FileHash  "$cachedir\$(verb)\$(verb).7z").Hash -ne 'DEE94F7B8C4BD325AEAE4F155339D83088B698823A35D7E63C5C9FFFEEBF3CDD') )  {
        Remove-Item -Force  "$cachedir\$(verb)\$(verb).7z" 
    }
    w_download_to "$(verb)" "https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/EXTRAS/$(verb).7z" "$(verb).7z"

    foreach ($i in $(verb).substring(5) ){
        7z e "$cachedir\\$(verb)\\$(verb).7z" "-o$env:systemroot\system32" "64/$i.dll" -aoa | Select-String 'ok' 
        7z e "$cachedir\\\\$(verb)\\$(verb).7z" "-o$env:systemroot\syswow64" "32/$i.dll" -aoa | Select-String 'ok'  }
    foreach($i in $(verb).substring(5) ) { dlloverride 'native' $i }
} <# end wintypes #>

function func_wine_windows.ui <# wine windows.ui #>
{
    if( [System.IO.File]::Exists( $([IO.Path]::Combine($cachedir,  $(verb), "$(verb).7z") )) -and ( (Get-FileHash  "$cachedir\$(verb)\$(verb).7z").Hash -ne '896A301B19F1FBED85C23D0A2DDD55B0457E35C22B5725598F895A0C8E4C0FA6') )  {
        Remove-Item -Force  "$cachedir\$(verb)\$(verb).7z" 
    }
    w_download_to "$(verb)" "https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/EXTRAS/$(verb).7z" "$(verb).7z"


    foreach ($i in $(verb).substring(5) ){
        7z e "$cachedir\\$(verb)\\$(verb).7z" "-o$env:systemroot\system32" "64/$i.dll" -aoa | Select-String 'ok' 
        7z e "$cachedir\\\\$(verb)\\$(verb).7z" "-o$env:systemroot\syswow64" "32/$i.dll" -aoa | Select-String 'ok'  }
    foreach($i in $(verb).substring(5) ) { dlloverride 'native' $i }
} <# end windows.ui #>

function func_wine_hnetcfg <# fix for https://bugs.winehq.org/show_bug.cgi?id=45432 #>
{
    w_download_to "$(verb)" "https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/EXTRAS/$(verb).7z" "$(verb).7z"

    foreach ($i in $(verb).substring(5) ){
        7z e "$cachedir\\$(verb)\\$(verb).7z" "-o$env:systemroot\system32" "64/$i.dll" -aoa | Select-String 'ok' 
        7z e "$cachedir\\\\$(verb)\\$(verb).7z" "-o$env:systemroot\syswow64" "32/$i.dll" -aoa | Select-String 'ok'  }
    foreach($i in $(verb).substring(5) ) { dlloverride 'native' $i }
} <# end hnetcfg #>

function func_wine_msi <# wine msi with some hacks faking success #>
{
    w_download_to "$(verb)" "https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/EXTRAS/$(verb).7z" "$(verb).7z"

    foreach ($i in $(verb).substring(5) ){
        7z e "$cachedir\\$(verb)\\$(verb).7z" "-o$env:systemroot\system32" "64/$i.dll" -aoa | Select-String 'ok' 
        7z e "$cachedir\\\\$(verb)\\$(verb).7z" "-o$env:systemroot\syswow64" "32/$i.dll" -aoa | Select-String 'ok'  }
    foreach($i in $(verb).substring(5) ) { dlloverride 'native' $i }
} <# end msi #>


function func_wine_kernelbase <# wine kernelbase with rudimentary MUI support  #>
{
    if( [System.IO.File]::Exists( $([IO.Path]::Combine($cachedir,  $(verb), "$(verb).7z") )) -and ( (Get-FileHash  "$cachedir\$(verb)\$(verb).7z").Hash -ne '4D79D6137E1273D8BAA128787C37B40F9DB9A217FDDEF96BBECEA3B072386E16') )  {
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
} <# end kernelbase #>

function func_font_lucida
{
    $fonts = @('lucon.ttf'); check_aik_sanity;
    
    foreach ($i in $fonts) { 7z e "$cachedir\aik70\F3_WINPE.WIM" "-o$env:systemroot\Fonts" "Windows/Fonts/$i" -y | Select-String 'ok'; quit?('7z') }
    
$regkey = @'
REGEDIT4
[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Fonts]
"Lucida Console (True Type)"="lucon.ttf"
'@
    reg_edit $regkey
}

function func_font_segoeui
{
    $fonts = @('segoeui.ttf', 'segoeuib.ttf', 'segoeuii.ttf', 'segoeuil.ttf', 'segoeuiz.ttf'); check_aik_sanity;
    
    foreach ($i in $fonts) { 7z e "$cachedir\aik70\F3_WINPE.WIM" "-o$env:systemroot\Fonts" "Windows/Fonts/$i" -y | Select-String 'ok'; quit?('7z') }
    
$regkey = @'
REGEDIT4
[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Fonts]
"Segoe UI (TrueType)"="segoeui.ttf"
"Segoe UI Light (TrueType)"="segoeuil.ttf"
"Segoe UI Bold (TrueType)"="segoeuib.ttf"
"Segoe UI Bold Italic (TrueType)"="segoeuiz.ttf"
"Segoe UI Italic (TrueType)"="segoeuii.ttf"
'@
    reg_edit $regkey
}

function func_font_tahoma
{
    $fonts = @('tahomabd.ttf', 'tahoma.ttf'); check_aik_sanity;
    
    foreach ($i in $fonts) { 7z e "$cachedir\aik70\F3_WINPE.WIM" "-o$env:systemroot\Fonts" "Windows/Fonts/$i" -y | Select-String 'ok'; quit?('7z') }
    
$regkey = @'
REGEDIT4
[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Fonts]
"Tahoma (TrueType)"="tahoma.ttf"
"Tahoma Bold (TrueType)"="tahomabd.ttf"
'@
    reg_edit $regkey
}

function func_font_vista
{
    $url = "https://catalog.s.download.windowsupdate.com/msdownload/update/software/updt/2010/04/windows6.0-kb980248-x86_c3accb4e416d6ef6d6fcbe27da9fc7da1fc22eb6.msu"
    $cab = "Windows6.0-KB980248-x86.cab"
    $sourcefile = @('arialbd.ttf','arialbi.ttf','ariali.ttf','ariblk.ttf','calibrib.ttf','calibrii.ttf','calibri.ttf','calibriz.ttf','cambriab.ttf',`
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

function func_ping <# fake ping for when wine's ping fails due to permission issues  #>
{
@'
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
'@ | Out-File ( New-Item -Path $env:ProgramFiles\Powershell\7\Modules\QPR_ping\QPR_ping.psm1 -Force )

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
    func_msxml6
    #func_msxml3
    func_vcrun2019
    #func_xmllite
    #func_cmd
    func_wine_advapi32
    if( [System.Convert]::ToDecimal( ($ntdll::wine_get_version() -replace '-rc','' ) ) -lt 8.16 ) {
        func_wine_ole32 }
    if( [System.Convert]::ToDecimal( ($ntdll::wine_get_version() -replace '-rc','' ) ) -lt 8.13 ) {
      func_wine_combase }
    func_wine_shell32

    winecfg /v win7

    (New-Object System.Net.WebClient).DownloadFile('https://aka.ms/vs/16/release/vs_community.exe', "$env:TMP\\vs_Community.exe") <#  https://download.visualstudio.microsoft.com/download/pr/1d66edfe-3c83-476b-bf05-e8901c62ba7f/ef3e389f222335676581eddbe7ddec01147969c1d42e19b9dade815c3c0f04b1/vs_Community.exe #>

  #  7z x $env:TMP\\installer "-o$env:TMP\\opc" -y ;quit?('7z')

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
    if( [System.Convert]::ToDecimal( ($ntdll::wine_get_version() -replace '-rc','' ) ) -lt 8.16 ) {
        New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe\\DllOverrides' -Name 'ole32' -Value 'native' -PropertyType 'String' -force }
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe\\DllOverrides' -Name 'shell32' -Value 'native' -PropertyType 'String' -force
    if( [System.Convert]::ToDecimal( ($ntdll::wine_get_version() -replace '-rc','' ) ) -lt 8.13 ) {
        New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe\\DllOverrides' -Name 'combase' -Value 'native' -PropertyType 'String' -force }

    <# FIXME: frequently mpc are not written to registry (wine bug?), do it manually #>
    & "${env:ProgramFiles`(x86`)}\Microsoft` Visual` Studio\2019\Community\Common7\IDE\DDConfigCA.exe" | & "${env:ProgramFiles`(x86`)}\Microsoft` Visual` Studio\2019\Community\Common7\IDE\StorePID.exe" 09299
}

function func_vs22
{
    func_msxml6
    #func_msxml3
    func_vcrun2019
    #func_xmllite
    #func_cmd
    func_wine_advapi32
    if( [System.Convert]::ToDecimal( ($ntdll::wine_get_version() -replace '-rc','' ) ) -lt 8.16 ) {
        func_wine_ole32 }
    #if( [System.Convert]::ToDecimal( ($ntdll::wine_get_version() -replace '-rc','' ) ) -lt 8.13 ) {
      func_wine_combase #}
    func_wine_shell32
    func_wine_wintypes
    func_winmetadata

    winecfg /v win10

    
    (New-Object System.Net.WebClient).DownloadFile('https://aka.ms/vs/17/release/vs_community.exe', "$env:TMP\\vs_Community.exe") 

  #  7z x $env:TMP\\installer "-o$env:TMP\\opc" -y ;quit?('7z')

    set-executionpolicy bypass

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

if(!(Test-Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe')) {New-Item  -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe'}
    if(!(Test-Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe\\DllOverrides')) {New-Item  -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe\\DllOverrides'}
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe\\DllOverrides' -Name 'advapi32' -Value 'native' -PropertyType 'String' -force
    if( [System.Convert]::ToDecimal( ($ntdll::wine_get_version() -replace '-rc','' ) ) -lt 8.16 ) {
        New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe\\DllOverrides' -Name 'ole32' -Value 'native' -PropertyType 'String' -force }
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe\\DllOverrides' -Name 'shell32' -Value 'native' -PropertyType 'String' -force
    if( [System.Convert]::ToDecimal( ($ntdll::wine_get_version() -replace '-rc','' ) ) -lt 8.13 ) {
        New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe\\DllOverrides' -Name 'combase' -Value 'native' -PropertyType 'String' -force }

    quit?('setup');quit?('vs_installer'); quit?('VSFinalizer'); quit?('devenv')

    <# FIXME: frequently mpc are not written to registry (wine bug?), do it manually #>
    & "${env:ProgramFiles}\Microsoft` Visual` Studio\2022\Community\Common7\IDE\DDConfigCA.exe" | & "${env:ProgramFiles}\Microsoft` Visual` Studio\2022\Community\Common7\IDE\StorePID.exe" 09299

    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe\\DllOverrides' -Name 'sxs' -Value '' -PropertyType 'String' -force
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\devenv.exe' -Name 'Version' -Value 'win7' -PropertyType 'String' -force
    winecfg /v win7
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

function func_dotnet35
{
    if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $(verb),  "$(verb).7z" ) ) ){
    
    (New-Object System.Net.WebClient).DownloadFile('https://download.microsoft.com/download/6/0/f/60fc5854-3cb8-4892-b6db-bd4f42510f28/dotnetfx35.exe', "$env:TMP\dotnetfx35.exe")
    #w_download_to "$env:TEMP" "https://download.microsoft.com/download/6/0/f/60fc5854-3cb8-4892-b6db-bd4f42510f28/dotnetfx35.exe" "dotnetfx35.exe"
    7z x "$env:TEMP\dotnetfx35.exe" "-o$env:TEMP\$(verb)\" -y; quit?(7z)

    Remove-Item -Force  $env:TEMP\\$(verb)\\wcu\\dotNetFramework\\dotNetFX20\\PCW_CAB_NetFX*
    foreach($i in $( ls $env:TEMP\\$(verb)\\wcu\\dotNetFramework\\dotNetFX20\\*.msp) )
        {7z x $i "-o$env:TEMP\\$(verb)\\wcu\\dotNetFramework\\dotNetFX20" "PCW_CAB_NetFX" -aou -y;}
    quit?(7z)
    foreach($i in $( ls $env:TEMP\\$(verb)\\wcu\\dotNetFramework\\dotNetFX20\\PCW_CAB_NetFX*) )
        { 7z x $i "-o$env:TEMP\\$(verb)\\wcu\\dotNetFramework\\dotNetFX20\\extr" -y; } 
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
    #("C:\users\silly\Temp\dotnet35\wcu\dotNetFramework\dotNetFX20\extr\windows\Microsoft.NET\assembly\GAC_MSIL\System.Web.DynamicData.Design\v4.0_4.0.0.0__31bf3856ad364e35\System.Web.DynamicData.Design.dll","002FE23572625BB228D1F4F34B6F599A8AE0A16C0EE8065D03EAC542C06378B1"),`
    #("C:\users\silly\Temp\dotnet35\wcu\dotNetFramework\dotNetFX20\extr\windows\Microsoft.NET\Framework\v4.0.30319\System.Web.DynamicData.Design.dll","002FE23572625BB228D1F4F34B6F599A8AE0A16C0EE8065D03EAC542C06378B1"),`
    #.
    #.
    #("C:\users\silly\Temp\dotnet35\wcu\dotNetFramework\dotNetFX20\extr\windows\Microsoft.NET\Framework64\v4.0.30319\System.Threading.dll","FFCBBC3F80176FD79780CB713D57C61C518DEA465B4F787139AF081BA97BF554")`
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
"$srcpath\FL_EditAppSetting_aspx_resx_103113_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\AppConfig\App_LocalResources\EditAppSetting.aspx.resx",`
"$srcpath\FL_System_EnterpriseServices_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_32\System.EnterpriseServices\2.0.0.0__b03f5f7f11d50a3a\System.EnterpriseServices.dll",`
"$srcpath\FL_System_EnterpriseServices_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\System.EnterpriseServices.dll",`
"$srcpath\FL_System_ServiceProcess_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.ServiceProcess\2.0.0.0__b03f5f7f11d50a3a\System.ServiceProcess.dll",`
"$srcpath\FL_System_ServiceProcess_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\System.ServiceProcess.dll",`
"$srcpath\FL_System_ServiceProcess_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\System.ServiceProcess.dll",`
"$srcpath\FL_aspnet_perf2_ini_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\aspnet_perf2.ini",`
"$srcpath\FL_web_mediumtrust_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\web_mediumtrust.config.default",`
"$srcpath\FL_web_mediumtrust_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\web_mediumtrust.config.default",`
"$srcpath\FL_WebAdminHelp_aspx_resx_122112_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_LocalResources\WebAdminHelp.aspx.resx",`
"$srcpath\FL_alink_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\alink.dll",`
"$srcpath\FL_headerGRADIENT_Tall_gif_102057_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\headerGRADIENT_Tall.gif",`
"$srcpath\FL_dfdll_dll_75023_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\dfdll.dll",`
"$srcpath\FL_mscorsvw_exe_93402_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\mscorsvw.exe",`
"$srcpath\FL_jphone_browser_76157_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\jphone.browser",`
"$srcpath\FL_jphone_browser_76157_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\jphone.browser",`
"$srcpath\msvcp80.dll.8.0.50727.1433.844EFBA7_1C24_93B2_FF1F_C8B3B9A1E18E" , "$env:Temp\windows\winsxs\amd64_Microsoft.VC80.CRT_1fc8b3b9a1e18e3b_8.0.50727.1433_x-ww_8f022ab2\msvcp80.dll",`
"$srcpath\FL_corperfmonsymbols_ini_1_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\corperfmonsymbols.ini",`
"$srcpath\FL_corperfmonsymbols_ini_1_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\corperfmonsymbols.ini",`
"$srcpath\FL_IEExec_exe_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\IEExec.exe",`
"$srcpath\FL_home0_aspx_resx_103505_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_LocalResources\home0.aspx.resx",`
"$srcpath\FL_UninstallSqlStateTemplate_sql_116232_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\UninstallSqlStateTemplate.sql",`
"$srcpath\FL_UninstallSqlStateTemplate_sql_116232_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\UninstallSqlStateTemplate.sql",`
"$srcpath\FL_CLR_mof_uninstall_126479_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CLR.mof.uninstall",`
"$srcpath\FL_CLR_mof_uninstall_126479_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CLR.mof.uninstall",`
"$srcpath\catalog.8.0.50727.1433.63E949F6_03BC_5C40_FF1F_C8B3B9A1E18E" , "$env:Temp\windows\winsxs\Policies\x86_policy.8.0.Microsoft.VC80.CRT_1fc8b3b9a1e18e3b_x-ww_77c24773\8.0.50727.1433.cat",`
"$srcpath\Microsoft_VisualBasic_dll_2_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\Microsoft.VisualBasic\8.0.0.0__b03f5f7f11d50a3a\Microsoft.VisualBasic.dll",`
"$srcpath\Microsoft_VisualBasic_dll_2_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\Microsoft.VisualBasic.dll",`
"$srcpath\Microsoft_VisualBasic_dll_2_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\Microsoft.VisualBasic.dll",`
"$srcpath\FL_System_Configuration_Install_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.Configuration.Install\2.0.0.0__b03f5f7f11d50a3a\System.Configuration.Install.dll",`
"$srcpath\FL_System_Configuration_Install_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\System.Configuration.Install.dll",`
"$srcpath\FL_System_Configuration_Install_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\System.Configuration.Install.dll",`
"$srcpath\FL_Microsoft_Vsa_Vb_CodeDOMProcessor_tlb_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\Microsoft.Vsa.Vb.CodeDOMProcessor.tlb",`
"$srcpath\FL_webtv_browser_76167_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\webtv.browser",`
"$srcpath\FL_webtv_browser_76167_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\webtv.browser",`
"$srcpath\FL_SOS_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\SOS.dll",`
"$srcpath\FL_CLR_mof_126478_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CLR.mof",`
"$srcpath\FL_CLR_mof_126478_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CLR.mof",`
"$srcpath\FL_wizardAddUser_ascx_resx_103392_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Wizard\App_LocalResources\wizardAddUser.ascx.resx",`
"$srcpath\FL_Microsoft_Vsa_Vb_CodeDOMProcessor_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\Microsoft.Vsa.Vb.CodeDOMProcessor\8.0.0.0__b03f5f7f11d50a3a\Microsoft.Vsa.Vb.CodeDOMProcessor.dll",`
"$srcpath\FL_Microsoft_Vsa_Vb_CodeDOMProcessor_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\Microsoft.Vsa.Vb.CodeDOMProcessor.dll",`
"$srcpath\FL_xjis_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_32\mscorlib\2.0.0.0__b77a5c561934e089\xjis.nlp",`
"$srcpath\FL_xjis_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_64\mscorlib\2.0.0.0__b77a5c561934e089\xjis.nlp",`
"$srcpath\FL_xjis_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\xjis.nlp",`
"$srcpath\FL_xjis_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\xjis.nlp",`
"$srcpath\FL_NETFXSBS10_exe_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\NETFXSBS10.exe",`
"$srcpath\FL_PerfCounter_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\PerfCounter.dll",`
"$srcpath\FL_System_configuration_dll_116773_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.Configuration\2.0.0.0__b03f5f7f11d50a3a\System.configuration.dll",`
"$srcpath\FL_System_configuration_dll_116773_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\System.configuration.dll",`
"$srcpath\FL_System_configuration_dll_116773_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\System.configuration.dll",`
"$srcpath\dw20.adm_0001_1036_1036.F0DF3458_A845_11D3_8D0A_0050046416B9" , "$env:Temp\windows\inf\AER_1036.ADM",`
"$srcpath\FL_System_Windows_Forms_tlb_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\System.Windows.Forms.tlb",`
"$srcpath\FL_editUser_aspx_resx_103466_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Users\App_LocalResources\editUser.aspx.resx",`
"$srcpath\FL_cscmsgs_dll_ENU_X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\1033\cscompui.dll",`
"$srcpath\FL_chooseProviderManagement_aspx_resx_103382_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Providers\App_LocalResources\chooseProviderManagement.aspx.resx",`
"$srcpath\FL_addUser_aspx_74814_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Users\addUser.aspx",`
"$srcpath\dw20.adm_0001_1041_1041.F0DF3458_A845_11D3_8D0A_0050046416B9" , "$env:Temp\windows\inf\AER_1041.ADM",`
"$srcpath\FL_Microsoft_Build_Core_xsd_117587_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\MSBuild\Microsoft.Build.Core.xsd",`
"$srcpath\FL_Microsoft_Build_Core_xsd_117587_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\MSBuild\Microsoft.Build.Core.xsd",`
"$srcpath\FL_sbs_mscordbi_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\sbs_mscordbi.dll",`
"$srcpath\FL_aspnet_regbrowsers_exe_76177_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\aspnet_regbrowsers.exe",`
"$srcpath\FL_PasswordValueTextBox_cs_102036_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_Code\PasswordValueTextBox.cs",`
"$srcpath\FL_sbs_system_configuration_install_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\sbs_system.configuration.install.dll",`
"$srcpath\FL_Ldr64_exe_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\Ldr64.exe",`
"$srcpath\FL_ericsson_browser_76173_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\ericsson.browser",`
"$srcpath\FL_ericsson_browser_76173_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\ericsson.browser",`
"$srcpath\FL_ASPdotNET_logo_jpg_74765_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\ASPdotNET_logo.jpg",`
"$srcpath\FL_palm_browser_76164_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\palm.browser",`
"$srcpath\FL_palm_browser_76164_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\palm.browser",`
"$srcpath\FL_wizardCreateRoles_ascx_74818_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Wizard\wizardCreateRoles.ascx",`
"$srcpath\FL_ksc_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_32\mscorlib\2.0.0.0__b77a5c561934e089\ksc.nlp",`
"$srcpath\FL_ksc_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_64\mscorlib\2.0.0.0__b77a5c561934e089\ksc.nlp",`
"$srcpath\FL_ksc_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\ksc.nlp",`
"$srcpath\FL_ksc_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ksc.nlp",`
"$srcpath\FL_csc_exe_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\csc.exe",`
"$srcpath\FL_wizardFinish_ascx_resx_103396_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Wizard\App_LocalResources\wizardFinish.ascx.resx",`
"$srcpath\FL_ManageAppSettings_aspx_102021_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\AppConfig\ManageAppSettings.aspx",`
"$srcpath\FL_AssemblyList_xml_113047_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\RedistList\FrameworkList.xml",`
"$srcpath\FL_MSBuild_exe_67853_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\MSBuild.exe",`
"$srcpath\FL_security0_aspx_74806_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\security0.aspx",`
"$srcpath\FL_wizard_aspx_resx_103393_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Wizard\App_LocalResources\wizard.aspx.resx",`
"$srcpath\FL_InstallMembership_sql_67218_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\InstallMembership.sql",`
"$srcpath\FL_InstallMembership_sql_67218_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\InstallMembership.sql",`
"$srcpath\FL_Microsoft_VisualBasic_Vsa_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\Microsoft.VisualBasic.Vsa\8.0.0.0__b03f5f7f11d50a3a\Microsoft.VisualBasic.Vsa.dll",`
"$srcpath\FL_Microsoft_VisualBasic_Vsa_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\Microsoft.VisualBasic.Vsa.dll",`
"$srcpath\FL_normidna_nlp_93185_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_32\mscorlib\2.0.0.0__b77a5c561934e089\normidna.nlp",`
"$srcpath\FL_normidna_nlp_93185_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_64\mscorlib\2.0.0.0__b77a5c561934e089\normidna.nlp",`
"$srcpath\FL_normidna_nlp_93185_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\normidna.nlp",`
"$srcpath\FL_normidna_nlp_93185_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\normidna.nlp",`
"$srcpath\FL_ilasm_exe_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\ilasm.exe",`
"$srcpath\FL_System_Windows_Forms_tlb_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\System.Windows.Forms.tlb",`
"$srcpath\FL_mscorld_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\mscorld.dll",`
"$srcpath\FL_ApplicationConfigurationPage_cs_102046_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_Code\ApplicationConfigurationPage.cs",`
"$srcpath\FL_CustomMarshalers_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_32\CustomMarshalers\2.0.0.0__b03f5f7f11d50a3a\CustomMarshalers.dll",`
"$srcpath\FL_CustomMarshalers_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CustomMarshalers.dll",`
"$srcpath\FL_Accessibility_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\Accessibility\2.0.0.0__b03f5f7f11d50a3a\Accessibility.dll",`
"$srcpath\FL_Accessibility_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\Accessibility.dll",`
"$srcpath\FL_Accessibility_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\Accessibility.dll",`
"$srcpath\FL__DataPerfCounters_ini_108892_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\_DataPerfCounters.ini",`
"$srcpath\FL__DataPerfCounters_ini_108892_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\_DataPerfCounters.ini",`
"$srcpath\FL_peverify_dll_97810_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\peverify.dll",`
"$srcpath\FL_mscorld_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\mscorld.dll",`
"$srcpath\FL_Microsoft_Build_Commontypes_xsd_117588_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\MSBuild\Microsoft.Build.Commontypes.xsd",`
"$srcpath\FL_Microsoft_Build_Commontypes_xsd_117588_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\MSBuild\Microsoft.Build.Commontypes.xsd",`
"$srcpath\FL_alert_sml_gif_93379_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\alert_sml.gif",`
"$srcpath\FL_alert_sml_gif_93379_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\security_watermark.jpg",`
"$srcpath\FL_alert_sml_gif_93379_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\selectedTab_1x1.gif",`
"$srcpath\FL_mscorlib_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_64\mscorlib\2.0.0.0__b77a5c561934e089\mscorlib.dll",`
"$srcpath\FL_mscorlib_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\mscorlib.dll",`
"$srcpath\FL_wizardCreateRoles_ascx_resx_103397_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Wizard\App_LocalResources\wizardCreateRoles.ascx.resx",`
"$srcpath\FL_WebAdminHelp_Security_aspx_resx_122115_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_LocalResources\WebAdminHelp_Security.aspx.resx",`
"$srcpath\FL_webengine_dll_135889_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\webengine.dll",`
"$srcpath\FL_normnfkc_nlp_66376_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_32\mscorlib\2.0.0.0__b77a5c561934e089\normnfkc.nlp",`
"$srcpath\FL_normnfkc_nlp_66376_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_64\mscorlib\2.0.0.0__b77a5c561934e089\normnfkc.nlp",`
"$srcpath\FL_normnfkc_nlp_66376_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\normnfkc.nlp",`
"$srcpath\FL_normnfkc_nlp_66376_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\normnfkc.nlp",`
"$srcpath\FL_PerfCounter_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\PerfCounter.dll",`
"$srcpath\FL_ISymWrapper_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_64\ISymWrapper\2.0.0.0__b03f5f7f11d50a3a\ISymWrapper.dll",`
"$srcpath\FL_ISymWrapper_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ISymWrapper.dll",`
"$srcpath\FL_aspnet_compiler_exe_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\aspnet_compiler.exe",`
"$srcpath\FL_Culture_dll_102451_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\Culture.dll",`
"$srcpath\FL_wizardPermission_ascx_resx_103399_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Wizard\App_LocalResources\wizardPermission.ascx.resx",`
"$srcpath\FL_ManageConsolidatedProviders_aspx_102159_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Providers\ManageConsolidatedProviders.aspx",`
"$srcpath\mscorwks_dll_4_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\mscorwks.dll",`
"$srcpath\FL_sbs_wminet_utils_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\sbs_wminet_utils.dll",`
"$srcpath\Microsoft_Vsa_dll_2_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\Microsoft.Vsa\8.0.0.0__b03f5f7f11d50a3a\Microsoft.Vsa.dll",`
"$srcpath\Microsoft_Vsa_dll_2_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\Microsoft.Vsa.dll",`
"$srcpath\Microsoft_Vsa_dll_2_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\Microsoft.Vsa.dll",`
"$srcpath\FL__dataperfcounters_ini_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\_dataperfcounters_shared12_neutral.ini",`
"$srcpath\FL__dataperfcounters_ini_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\_dataperfcounters_shared12_neutral.ini",`
"$srcpath\FL_pie_browser_76166_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\pie.browser",`
"$srcpath\FL_pie_browser_76166_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\pie.browser",`
"$srcpath\cvtres_exe_1_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\cvtres.exe",`
"$srcpath\FL_vbc_exe_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\vbc.exe",`
"$srcpath\FL_aspnet_mof_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\aspnet.mof",`
"$srcpath\FL_aspnet_mof_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\aspnet.mof",`
"$srcpath\FL_topGradRepeat_jpg_74759_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\topGradRepeat.jpg",`
"$srcpath\FL_vbc7ui_dll_ENU_X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\1033\vbc7ui.dll",`
"$srcpath\FL_mscordacwks_dll_66373_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\mscordacwks.dll",`
"$srcpath\FL_wizard_aspx_74823_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Wizard\wizard.aspx",`
"$srcpath\FL_WebAdminPage_cs_74747_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_Code\WebAdminPage.cs",`
"$srcpath\FL_mscortim_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\mscortim.dll",`
"$srcpath\FL_Microsoft_Build_xsd_117586_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\Microsoft.Build.xsd",`
"$srcpath\FL_Microsoft_Build_xsd_117586_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\Microsoft.Build.xsd",`
"$srcpath\FL_XPThemes_manifest_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\XPThemes.manifest",`
"$srcpath\FL_XPThemes_manifest_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\XPThemes.manifest",`
"$srcpath\FL_System_Web_RegularExpressions_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.Web.RegularExpressions\2.0.0.0__b03f5f7f11d50a3a\System.Web.RegularExpressions.dll",`
"$srcpath\FL_System_Web_RegularExpressions_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\System.Web.RegularExpressions.dll",`
"$srcpath\FL_System_Web_RegularExpressions_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\System.Web.RegularExpressions.dll",`
"$srcpath\FL_nokia_browser_76161_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\nokia.browser",`
"$srcpath\FL_nokia_browser_76161_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\nokia.browser",`
"$srcpath\FL_managePermissions_aspx_resx_103212_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Permissions\App_LocalResources\managePermissions.aspx.resx",`
"$srcpath\FL_Microsoft_VisualC_Dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\Microsoft.VisualC\8.0.0.0__b03f5f7f11d50a3a\Microsoft.VisualC.Dll",`
"$srcpath\FL_Microsoft_VisualC_Dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\Microsoft.VisualC.Dll",`
"$srcpath\FL_Microsoft_VisualC_Dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\Microsoft.VisualC.Dll",`
"$srcpath\FL_Aspnet_perf_dll_113116_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\Aspnet_perf.dll",`
"$srcpath\FL_csc_urt_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\csc.exe.config",`
"$srcpath\FL_csc_urt_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\jsc.exe.config",`
"$srcpath\FL_csc_urt_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\vbc.exe.config",`
"$srcpath\FL_csc_urt_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\csc.exe.config",`
"$srcpath\FL_csc_urt_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\vbc.exe.config",`
"$srcpath\FL_csc_urt_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\csc.exe.config",`
"$srcpath\FL_csc_urt_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\jsc.exe.config",`
"$srcpath\FL_csc_urt_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\vbc.exe.config",`
"$srcpath\FL_csc_urt_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\csc.exe.config",`
"$srcpath\FL_csc_urt_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\vbc.exe.config",`
"$srcpath\FL_IEHost_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\IEHost\2.0.0.0__b03f5f7f11d50a3a\IEHost.dll",`
"$srcpath\FL_IEHost_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\IEHost.dll",`
"$srcpath\FL_IEHost_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\IEHost.dll",`
"$srcpath\FL_manageSingleRole_aspx_74810_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Roles\manageSingleRole.aspx",`
"$srcpath\FL_mscordacwks_dll_66373_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\mscordacwks.dll",`
"$srcpath\System.Web_dll_5_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_64\System.Web\2.0.0.0__b03f5f7f11d50a3a\System.Web.dll",`
"$srcpath\System.Web_dll_5_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\System.Web.dll",`
"$srcpath\FL_manageconsolidatedProviders_aspx_resx_103380_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Providers\App_LocalResources\manageconsolidatedProviders.aspx.resx",`
"$srcpath\FL_WebAdminStyles_css_74739_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\WebAdminStyles.css",`
"$srcpath\FL_image1_gif_74784_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\image1.gif",`
"$srcpath\FL_legend_browser_109072_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\legend.browser",`
"$srcpath\FL_legend_browser_109072_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\legend.browser",`
"$srcpath\FL_WebAdminHelp_Application_aspx_119290_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\ASP.NETWebAdminFiles\WebAdminHelp_Application.aspx",`
"$srcpath\FL_WebAdminHelp_Application_aspx_119290_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\WebAdminHelp_Application.aspx",`
"$srcpath\FL_InstallUtil_exe_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\InstallUtil.exe",`
"$srcpath\FL_System_Security_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.Security\2.0.0.0__b03f5f7f11d50a3a\System.Security.dll",`
"$srcpath\FL_System_Security_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\System.Security.dll",`
"$srcpath\FL_System_Security_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\System.Security.dll",`
"$srcpath\FL_System_EnterpriseServices_tlb_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\System.EnterpriseServices.tlb",`
"$srcpath\FL_wizardInit_ascx_resx_103398_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Wizard\App_LocalResources\wizardInit.ascx.resx",`
"$srcpath\FL_alert_lrg_gif_92834_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\alert_lrg.gif",`
"$srcpath\FL_aspnet_wp_exe_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\aspnet_wp.exe",`
"$srcpath\FL_fusion_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\fusion.dll",`
"$srcpath\FL_dfdll_dll_75023_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\dfdll.dll",`
"$srcpath\FL_caspol_exe_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\caspol.exe.config",`
"$srcpath\FL_caspol_exe_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\ieexec.exe.config",`
"$srcpath\FL_caspol_exe_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\ilasm.exe.config",`
"$srcpath\FL_caspol_exe_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\regasm.exe.config",`
"$srcpath\FL_caspol_exe_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\regsvcs.exe.config",`
"$srcpath\FL_caspol_exe_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\caspol.exe.config",`
"$srcpath\FL_caspol_exe_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ieexec.exe.config",`
"$srcpath\FL_caspol_exe_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ilasm.exe.config",`
"$srcpath\FL_caspol_exe_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\regasm.exe.config",`
"$srcpath\FL_caspol_exe_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\regsvcs.exe.config",`
"$srcpath\FL_aspnet_isapi_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\aspnet_isapi.dll",`
"$srcpath\dw20.adm_0001_2052_2052.F0DF3458_A845_11D3_8D0A_0050046416B9" , "$env:Temp\windows\inf\AER_2052.ADM",`
"$srcpath\FL_mscorlib_tlb_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\mscorlib.tlb",`
"$srcpath\dw20.adm_0001_1031_1031.F0DF3458_A845_11D3_8D0A_0050046416B9" , "$env:Temp\windows\inf\AER_1031.ADM",`
"$srcpath\Microsoft_VisualBasic_Compatibility_dll_2_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\Microsoft.VisualBasic.Compatibility\8.0.0.0__b03f5f7f11d50a3a\Microsoft.VisualBasic.Compatibility.dll",`
"$srcpath\Microsoft_VisualBasic_Compatibility_dll_2_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\Microsoft.VisualBasic.Compatibility.dll",`
"$srcpath\Vsavb7rtUI_dll_2_ENU_X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\1033\Vsavb7rtUI.dll",`
"$srcpath\FL_mscorie_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\mscorie.dll",`
"$srcpath\FL_webAdmin_master_74735_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\webAdmin.master",`
"$srcpath\FL_Microsoft_Common_targets_106593_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\Microsoft.Common.targets",`
"$srcpath\FL_Microsoft_Common_targets_106593_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\Microsoft.Common.targets",`
"$srcpath\vsavb7_tlb_1_____x86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\vsavb7.olb",`
"$srcpath\FL_home1_aspx_resx_103507_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_LocalResources\home1.aspx.resx",`
"$srcpath\msvcr80.dll.8.0.50727.1433.844EFBA7_1C24_93B2_FF1F_C8B3B9A1E18E" , "$env:Temp\windows\winsxs\amd64_Microsoft.VC80.CRT_1fc8b3b9a1e18e3b_8.0.50727.1433_x-ww_8f022ab2\msvcr80.dll",`
"$srcpath\FL_wizardProviderInfo_ascx_102277_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Wizard\wizardProviderInfo.ascx",`
"$srcpath\System.Web_dll_5_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_32\System.Web\2.0.0.0__b03f5f7f11d50a3a\System.Web.dll",`
"$srcpath\System.Web_dll_5_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\System.Web.dll",`
"$srcpath\FL_IEExec_exe_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\IEExec.exe",`
"$srcpath\FL_AppConfigHome_aspx_102015_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\AppConfig\AppConfigHome.aspx",`
"$srcpath\FL_default_aspx_74742_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\default.aspx",`
"$srcpath\FL_msbuild_urt_config_135103_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\msbuild.exe.config",`
"$srcpath\FL_msbuild_urt_config_135103_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\msbuild.exe.config",`
"$srcpath\FL_System_Drawing_Design_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.Drawing.Design\2.0.0.0__b03f5f7f11d50a3a\System.Drawing.Design.dll",`
"$srcpath\FL_System_Drawing_Design_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\System.Drawing.Design.dll",`
"$srcpath\FL_System_Drawing_Design_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\System.Drawing.Design.dll",`
"$srcpath\FL_System_EnterpriseServices_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_64\System.EnterpriseServices\2.0.0.0__b03f5f7f11d50a3a\System.EnterpriseServices.dll",`
"$srcpath\FL_System_EnterpriseServices_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\System.EnterpriseServices.dll",`
"$srcpath\FL_EZWap_browser_93275_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\EZWap.browser",`
"$srcpath\FL_EZWap_browser_93275_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\EZWap.browser",`
"$srcpath\FL_System_Web_tbl_105182_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\System.Web.tlb",`
"$srcpath\FL_root_web_config_comments_118268_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\web.config.comments",`
"$srcpath\FL_root_web_config_comments_118268_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\web.config.comments",`
"$srcpath\FL_sbs_system_data_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\sbs_system.data.dll",`
"$srcpath\FL_sysglobl_dll_92791_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\sysglobl\2.0.0.0__b03f5f7f11d50a3a\sysglobl.dll",`
"$srcpath\FL_sysglobl_dll_92791_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\sysglobl.dll",`
"$srcpath\FL_sysglobl_dll_92791_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\sysglobl.dll",`
"$srcpath\FL_web_minimaltrust_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\web_minimaltrust.config",`
"$srcpath\FL_web_minimaltrust_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\web_minimaltrust.config.default",`
"$srcpath\FL_web_minimaltrust_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\web_minimaltrust.config",`
"$srcpath\FL_web_minimaltrust_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\web_minimaltrust.config.default",`
"$srcpath\FL_netfxsbs12_hkf_76082_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\netfxsbs12.hkf",`
"$srcpath\FL_csc_exe_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\csc.exe",`
"$srcpath\FL_mscorsec_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\mscorsec.dll",`
"$srcpath\FL_mscorpe_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\mscorpe.dll",`
"$srcpath\FL_setUpAuthentication_aspx_74802_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\setUpAuthentication.aspx",`
"$srcpath\FL_InstallCommon_sql_74696_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\InstallCommon.sql",`
"$srcpath\FL_InstallCommon_sql_74696_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\InstallCommon.sql",`
"$srcpath\FL_sbs_VsaVb7rt_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\sbs_VsaVb7rt.dll",`
"$srcpath\FL_wizardAddUser_ascx_74816_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Wizard\wizardAddUser.ascx",`
"$srcpath\FL_vbc7ui_dll_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\1033\vbc7ui.dll",`
"$srcpath\FL_mscordbi_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\mscordbi.dll",`
"$srcpath\dw20.adm_0001_3082_3082.F0DF3458_A845_11D3_8D0A_0050046416B9" , "$env:Temp\windows\inf\AER_3082.ADM",`
"$srcpath\FL_DebugAndTrace_aspx_resx_103116_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\AppConfig\App_LocalResources\DebugAndTrace.aspx.resx",`
"$srcpath\FL_bopomofo_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_32\mscorlib\2.0.0.0__b77a5c561934e089\bopomofo.nlp",`
"$srcpath\FL_bopomofo_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_64\mscorlib\2.0.0.0__b77a5c561934e089\bopomofo.nlp",`
"$srcpath\FL_bopomofo_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\bopomofo.nlp",`
"$srcpath\FL_bopomofo_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\bopomofo.nlp",`
"$srcpath\FL_root_web_config_default_118269_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\web.config.default",`
"$srcpath\FL_root_web_config_default_118269_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\web.config.default",`
"$srcpath\msvcm80.dll.8.0.50727.1433.844EFBA7_1C24_93B2_FF1F_C8B3B9A1E18E" , "$env:Temp\windows\winsxs\amd64_Microsoft.VC80.CRT_1fc8b3b9a1e18e3b_8.0.50727.1433_x-ww_8f022ab2\msvcm80.dll",`
"$srcpath\FL_mscorjit_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\mscorjit.dll",`
"$srcpath\FL_diasymreader_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\diasymreader.dll",`
"$srcpath\FL_InstallRoles_sql_67224_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\InstallRoles.sql",`
"$srcpath\FL_InstallRoles_sql_67224_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\InstallRoles.sql",`
"$srcpath\FL_System_Web_Mobile_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.Web.Mobile\2.0.0.0__b03f5f7f11d50a3a\System.Web.Mobile.dll",`
"$srcpath\FL_System_Web_Mobile_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\System.Web.Mobile.dll",`
"$srcpath\FL_System_Web_Mobile_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\System.Web.Mobile.dll",`
"$srcpath\FL_editUser_aspx_102270_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Users\editUser.aspx",`
"$srcpath\FL_mscorsecr_dll_ENU_X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\MUI\0409\mscorsecr.dll",`
"$srcpath\FL_gradient_onWhite_gif_74776_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\gradient_onWhite.gif",`
"$srcpath\FL_DefineErrorPage_aspx_resx_103112_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\AppConfig\App_LocalResources\DefineErrorPage.aspx.resx",`
"$srcpath\FL_MmcAspExt_dll_95862_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\MmcAspExt.dll",`
"$srcpath\FL_Aspnet_regsql_exe_config_116177_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\Aspnet_regsql.exe.config",`
"$srcpath\FL_Aspnet_regsql_exe_config_116177_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\Aspnet_regsql.exe.config",`
"$srcpath\FL_UninstallWebEventSqlProvider_sql_93277_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\UninstallWebEventSqlProvider.sql",`
"$srcpath\FL_UninstallWebEventSqlProvider_sql_93277_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\UninstallWebEventSqlProvider.sql",`
"$srcpath\FL_AppSetting_ascx_102014_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\AppConfig\AppSetting.ascx",`
"$srcpath\FL_AppConfigCommon_resx_103538_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_GlobalResources\AppConfigCommon.resx",`
"$srcpath\FL_cscomp_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\cscomp.dll",`
"$srcpath\FL_GlobalResources_resx_103539_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_GlobalResources\GlobalResources.resx",`
"$srcpath\FL_security0_aspx_resx_103484_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\App_LocalResources\security0.aspx.resx",`
"$srcpath\FL_System_tlb_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\System.tlb",`
"$srcpath\FL_sbs_system_enterpriseservices_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\sbs_system.enterpriseservices.dll",`
"$srcpath\FL_adonetdiag_mof_106906_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\adonetdiag.mof",`
"$srcpath\FL_adonetdiag_mof_106906_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\adonetdiag.mof",`
"$srcpath\FL_mscorsn_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\mscorsn.dll",`
"$srcpath\FL_normnfkd_nlp_66377_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_32\mscorlib\2.0.0.0__b77a5c561934e089\normnfkd.nlp",`
"$srcpath\FL_normnfkd_nlp_66377_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_64\mscorlib\2.0.0.0__b77a5c561934e089\normnfkd.nlp",`
"$srcpath\FL_normnfkd_nlp_66377_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\normnfkd.nlp",`
"$srcpath\FL_normnfkd_nlp_66377_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\normnfkd.nlp",`
"$srcpath\FL_ISymWrapper_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_32\ISymWrapper\2.0.0.0__b03f5f7f11d50a3a\ISymWrapper.dll",`
"$srcpath\FL_ISymWrapper_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\ISymWrapper.dll",`
"$srcpath\FL_navigationBar_ascx_74730_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\navigationBar.ascx",`
"$srcpath\FL_EventLogMessages_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\EventLogMessages.dll",`
"$srcpath\FL_cscomp_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\cscomp.dll",`
"$srcpath\FL_docomo_browser_76172_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\docomo.browser",`
"$srcpath\FL_docomo_browser_76172_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\docomo.browser",`
"$srcpath\FL_MSBuildFramework_dll_70716_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\Microsoft.Build.Framework\2.0.0.0__b03f5f7f11d50a3a\Microsoft.Build.Framework.dll",`
"$srcpath\FL_MSBuildFramework_dll_70716_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\Microsoft.Build.Framework.dll",`
"$srcpath\FL_MSBuildFramework_dll_70716_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\Microsoft.Build.Framework.dll",`
"$srcpath\FL_InstallPersonalization_sql_67221_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\InstallPersonalization.sql",`
"$srcpath\FL_InstallPersonalization_sql_67221_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\InstallPersonalization.sql",`
"$srcpath\FL_CORPerfMonExt_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CORPerfMonExt.dll",`
"$srcpath\FL_ilasm_exe_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ilasm.exe",`
"$srcpath\FL_web_config_74734_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\web.config",`
"$srcpath\FL_WebAdminHelp_Security_aspx_119294_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\ASP.NETWebAdminFiles\WebAdminHelp_Security.aspx",`
"$srcpath\FL_WebAdminHelp_Security_aspx_119294_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\WebAdminHelp_Security.aspx",`
"$srcpath\FL_CvtResUI_dll_109387_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\1033\CvtResUI.dll",`
"$srcpath\FL_aspnet_perf_ini_ENU_X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\aspnet_perf.ini",`
"$srcpath\FL_System_Data_OracleClient_dll_2_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_64\System.Data.OracleClient\2.0.0.0__b77a5c561934e089\System.Data.OracleClient.dll",`
"$srcpath\FL_System_Data_OracleClient_dll_2_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\System.Data.OracleClient.dll",`
"$srcpath\FL_TLBREF_DLL_97713_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\TLBREF.DLL",`
"$srcpath\FL_mscorlib_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_32\mscorlib\2.0.0.0__b77a5c561934e089\mscorlib.dll",`
"$srcpath\FL_mscorlib_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\mscorlib.dll",`
"$srcpath\FL_aspnet_wp_exe_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\aspnet_wp.exe",`
"$srcpath\FL_shfusion_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\shfusion.dll",`
"$srcpath\FL_normalization_dll_66379_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\normalization.dll",`
"$srcpath\FL_sbs_microsoft_vsa_vb_codedomprocessor_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\sbs_microsoft.vsa.vb.codedomprocessor.dll",`
"$srcpath\FL_Jataayu_browser_93274_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\Jataayu.browser",`
"$srcpath\FL_Jataayu_browser_93274_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\Jataayu.browser",`
"$srcpath\FL_yellowCORNER_gif_74760_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\yellowCORNER.gif",`
"$srcpath\FL_System_Data_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_32\System.Data\2.0.0.0__b77a5c561934e089\System.Data.dll",`
"$srcpath\FL_System_Data_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\System.Data.dll",`
"$srcpath\FL_createPermission_aspx_resx_103211_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Permissions\App_LocalResources\createPermission.aspx.resx",`
"$srcpath\dw20.adm_1025_1025.D0DF3458_A845_11D3_8D0A_0050046416B9" , "$env:Temp\windows\inf\AER_1025.ADM",`
"$srcpath\FL_System_Data_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_64\System.Data\2.0.0.0__b77a5c561934e089\System.Data.dll",`
"$srcpath\FL_System_Data_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\System.Data.dll",`
"$srcpath\manifest.8.0.50727.1433.4F6D20F0_CCE5_1492_FF1F_C8B3B9A1E18E" , "$env:Temp\windows\winsxs\Policies\amd64_policy.8.0.Microsoft.VC80.CRT_1fc8b3b9a1e18e3b_x-ww_d780e993\8.0.50727.1433.policy",`
"$srcpath\FL_aspnet_compiler_exe_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\aspnet_compiler.exe",`
"$srcpath\FL_WebAdminHelp_Internals_aspx_resx_122113_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_LocalResources\WebAdminHelp_Internals.aspx.resx",`
"$srcpath\FL_normalization_dll_66379_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\normalization.dll",`
"$srcpath\FL_fusion_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\fusion.dll",`
"$srcpath\FL_aspnet_state_exe_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\aspnet_state.exe",`
"$srcpath\FL_webAdminNoButtonRow_master_74738_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\webAdminNoButtonRow.master",`
"$srcpath\FL_MmcAspExt_dll_95862_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\MmcAspExt.dll",`
"$srcpath\FL_requiredBang_gif_74755_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\requiredBang.gif",`
"$srcpath\FL_aspnet_rc_dll_1_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\aspnet_rc.dll",`
"$srcpath\FL_aspnet_filter_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\aspnet_filter.dll",`
"$srcpath\FL_System_Web_tbl_105182_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\System.Web.tlb",`
"$srcpath\FL_default_aspx_resx_103509_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_LocalResources\default.aspx.resx",`
"$srcpath\FL_folder_gif_74774_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\folder.gif",`
"$srcpath\FL_avantgo_browser_76169_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\avantgo.browser",`
"$srcpath\FL_avantgo_browser_76169_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\avantgo.browser",`
"$srcpath\Microsoft_VisualBasic_Compatibility_Data_dll_2_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\Microsoft.VisualBasic.Compatibility.Data\8.0.0.0__b03f5f7f11d50a3a\Microsoft.VisualBasic.Compatibility.Data.dll",`
"$srcpath\Microsoft_VisualBasic_Compatibility_Data_dll_2_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\Microsoft.VisualBasic.Compatibility.Data.dll",`
"$srcpath\FL_UninstallPersonalization_sql_67220_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\UninstallPersonalization.sql",`
"$srcpath\FL_UninstallPersonalization_sql_67220_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\UninstallPersonalization.sql",`
"$srcpath\FL_aspnet_isapi_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\aspnet_isapi.dll",`
"$srcpath\FL_regtlib_exe_1_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\regtlibv12.exe",`
"$srcpath\catalog.8.0.50727.1433.844EFBA7_1C24_93B2_FF1F_C8B3B9A1E18E" , "$env:Temp\windows\winsxs\manifests\amd64_Microsoft.VC80.CRT_1fc8b3b9a1e18e3b_8.0.50727.1433_x-ww_8f022ab2.cat",`
"$srcpath\FL_vbc_rsp_76080_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\vbc.rsp",`
"$srcpath\FL_vbc_rsp_76080_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\vbc.rsp",`
"$srcpath\FL_findUsers_aspx_resx_103468_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Users\App_LocalResources\findUsers.aspx.resx",`
"$srcpath\FL_generic_browser_76175_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\generic.browser",`
"$srcpath\FL_generic_browser_76175_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\generic.browser",`
"$srcpath\FL_ProviderList_ascx_92846_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Providers\ProviderList.ascx",`
"$srcpath\FL_navigationBar_ascx_resx_103510_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_LocalResources\navigationBar.ascx.resx",`
"$srcpath\FL_AppSetting_ascx_resx_103115_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\AppConfig\App_LocalResources\AppSetting.ascx.resx",`
"$srcpath\FL_wizardAuthentication_ascx_74817_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Wizard\wizardAuthentication.ascx",`
"$srcpath\FL_System_Transactions_dll_75016_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_32\System.Transactions\2.0.0.0__b77a5c561934e089\System.Transactions.dll",`
"$srcpath\FL_System_Transactions_dll_75016_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\System.Transactions.dll",`
"$srcpath\FL_goAmerica_browser_76155_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\goAmerica.browser",`
"$srcpath\FL_goAmerica_browser_76155_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\goAmerica.browser",`
"$srcpath\FL_aspnet_state_perf_ini_76106_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\aspnet_state_perf.ini",`
"$srcpath\FL_aspnet_state_perf_ini_76106_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\aspnet_state_perf.ini",`
"$srcpath\VsaVb7rt_dll_2_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\VsaVb7rt.dll",`
"$srcpath\dw20.adm_0001_1042_1042.F0DF3458_A845_11D3_8D0A_0050046416B9" , "$env:Temp\windows\inf\AER_1042.ADM",`
"$srcpath\jsc_exe_1_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\jsc.exe",`
"$srcpath\FL_big5_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_32\mscorlib\2.0.0.0__b77a5c561934e089\big5.nlp",`
"$srcpath\FL_big5_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_64\mscorlib\2.0.0.0__b77a5c561934e089\big5.nlp",`
"$srcpath\FL_big5_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\big5.nlp",`
"$srcpath\FL_big5_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\big5.nlp",`
"$srcpath\FL_cassio_browser_76170_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\cassio.browser",`
"$srcpath\FL_cassio_browser_76170_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\cassio.browser",`
"$srcpath\dw20.adm_0001_1040_1040.F0DF3458_A845_11D3_8D0A_0050046416B9" , "$env:Temp\windows\inf\AER_1040.ADM",`
"$srcpath\FL_mscorsvc_dll_93043_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\mscorsvc.dll",`
"$srcpath\FL_UninstallPersistSqlState_sql_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\UninstallPersistSqlState.sql",`
"$srcpath\FL_UninstallPersistSqlState_sql_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\UninstallPersistSqlState.sql",`
"$srcpath\FL_aspx_file_gif_102053_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\aspx_file.gif",`
"$srcpath\FL_sbs_microsoft_jscript_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\sbs_microsoft.jscript.dll",`
"$srcpath\FL_AspNetMMCExt_dll_66806_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\AspNetMMCExt\2.0.0.0__b03f5f7f11d50a3a\AspNetMMCExt.dll",`
"$srcpath\FL_AspNetMMCExt_dll_66806_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\AspNetMMCExt.dll",`
"$srcpath\FL_AdoNetDiag_dll_106905_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\AdoNetDiag.dll",`
"$srcpath\FL_machine_config_comments_105748_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\machine.config.comments",`
"$srcpath\FL_machine_config_comments_105748_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\machine.config.comments",`
"$srcpath\FL_chooseProviderManagement_aspx_102160_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Providers\chooseProviderManagement.aspx",`
"$srcpath\mscorwks_dll_4_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\mscorwks.dll",`
"$srcpath\FL_mscordbc_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\mscordbc.dll",`
"$srcpath\FL_Culture_dll_102451_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\Culture.dll",`
"$srcpath\FL_Microsoft_BuildTasks_67856_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\Microsoft.Common.Tasks",`
"$srcpath\FL_Microsoft_BuildTasks_67856_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\Microsoft.Common.Tasks",`
"$srcpath\FL_mscorjit_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\mscorjit.dll",`
"$srcpath\FL_regsvcs_exe_config_79704_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v1.1.4322\regsvcs.exe.config",`
"$srcpath\FL_vbc_exe_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\vbc.exe",`
"$srcpath\FL_error_aspx_resx_103504_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_LocalResources\error.aspx.resx",`
"$srcpath\FL_GroupedProviders_xml_117816_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_Data\GroupedProviders.xml",`
"$srcpath\FL_aspnet_regbrowsers_exe_76177_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\aspnet_regbrowsers.exe",`
"$srcpath\FL_Aspnet_perf_dll_113116_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\Aspnet_perf.dll",`
"$srcpath\FL_mscories_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\syswow64\mscories.dll",`
"$srcpath\FL_manageAllRoles_aspx_resx_103495_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Roles\App_LocalResources\manageAllRoles.aspx.resx",`
"$srcpath\FL_error_aspx_74743_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\error.aspx",`
"$srcpath\FL__DataPerfCounters_h_108891_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\_DataPerfCounters.h",`
"$srcpath\FL__DataPerfCounters_h_108891_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\_DataPerfCounters.h",`
"$srcpath\manifest.8.0.50727.1433.63E949F6_03BC_5C40_FF1F_C8B3B9A1E18E" , "$env:Temp\windows\winsxs\Policies\x86_policy.8.0.Microsoft.VC80.CRT_1fc8b3b9a1e18e3b_x-ww_77c24773\8.0.50727.1433.policy",`
"$srcpath\FL_webhightrust_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\web_hightrust.config.default",`
"$srcpath\FL_webhightrust_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\web_hightrust.config.default",`
"$srcpath\FL_System_DeploymentFramework_dll_66796_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.Deployment\2.0.0.0__b03f5f7f11d50a3a\System.Deployment.dll",`
"$srcpath\FL_System_DeploymentFramework_dll_66796_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\System.Deployment.dll",`
"$srcpath\FL_System_DeploymentFramework_dll_66796_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\System.Deployment.dll",`
"$srcpath\FL_UninstallSqlState_sql_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\UninstallSqlState.sql",`
"$srcpath\FL_UninstallSqlState_sql_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\UninstallSqlState.sql",`
"$srcpath\FL_ngen_exe_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\ngen.exe",`
"$srcpath\FL_aspnet_rc_dll_1_ENU_X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\aspnet_rc.dll",`
"$srcpath\FL_System_Data_SqlXml_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.Data.SqlXml\2.0.0.0__b77a5c561934e089\System.Data.SqlXml.dll",`
"$srcpath\FL_System_Data_SqlXml_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\System.Data.SqlXml.dll",`
"$srcpath\FL_System_Data_SqlXml_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\System.Data.SqlXml.dll",`
"$srcpath\FL_darkBlue_GRAD_jpg_74769_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\darkBlue_GRAD.jpg",`
"$srcpath\FL_UnInstallProfile_SQL_104242_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\UnInstallProfile.SQL",`
"$srcpath\FL_UnInstallProfile_SQL_104242_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\UnInstallProfile.SQL",`
"$srcpath\FL_wizardFinish_ascx_74819_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Wizard\wizardFinish.ascx",`
"$srcpath\msvcm80.dll.8.0.50727.1433.98CB24AD_52FB_DB5F_FF1F_C8B3B9A1E18E" , "$env:Temp\windows\winsxs\x86_Microsoft.VC80.CRT_1fc8b3b9a1e18e3b_8.0.50727.1433_x-ww_5cf844d2\msvcm80.dll",`
"$srcpath\FL_InstallPersistSqlState_sql_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\InstallPersistSqlState.sql",`
"$srcpath\FL_InstallPersistSqlState_sql_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\InstallPersistSqlState.sql",`
"$srcpath\FL_manageUsers_aspx_74815_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Users\manageUsers.aspx",`
"$srcpath\FL__Networkingperfcounters_ini_1_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\_Networkingperfcounters.ini",`
"$srcpath\FL__Networkingperfcounters_ini_1_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\_Networkingperfcounters.ini",`
"$srcpath\FL_mscorpe_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\mscorpe.dll",`
"$srcpath\FL_MSBuildTasks_dll_67855_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\Microsoft.Build.Tasks\2.0.0.0__b03f5f7f11d50a3a\Microsoft.Build.Tasks.dll",`
"$srcpath\FL_MSBuildTasks_dll_67855_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\Microsoft.Build.Tasks.dll",`
"$srcpath\FL_MSBuildTasks_dll_67855_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\Microsoft.Build.Tasks.dll",`
"$srcpath\FL__DataOracleClientPerfCounters_shared12__106790_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\_DataOracleClientPerfCounters_shared12_neutral.h",`
"$srcpath\FL__DataOracleClientPerfCounters_shared12__106790_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\_dataperfcounters_shared12_neutral.h",`
"$srcpath\FL__DataOracleClientPerfCounters_shared12__106790_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\_DataOracleClientPerfCounters_shared12_neutral.h",`
"$srcpath\FL__DataOracleClientPerfCounters_shared12__106790_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\_dataperfcounters_shared12_neutral.h",`
"$srcpath\FL_InstallUtilLib_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\InstallUtilLib.dll",`
"$srcpath\FL_Microsoft_VisualBasic_targets_106592_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\Microsoft.VisualBasic.targets",`
"$srcpath\FL_Microsoft_VisualBasic_targets_106592_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\Microsoft.VisualBasic.targets",`
"$srcpath\Microsoft_Vsa_tlb_1_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\Microsoft.Vsa.tlb",`
"$srcpath\FL_System_EnterpriseServices_Thunk_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\System.EnterpriseServices.Thunk.dll",`
"$srcpath\FL_almsgs_dll_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\1033\alinkui.dll",`
"$srcpath\ShFusRes_dll_1_ENU_X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\ShFusRes.dll",`
"$srcpath\FL_System_DirectoryServices_Protocols_dll_101362_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.DirectoryServices.Protocols\2.0.0.0__b03f5f7f11d50a3a\System.DirectoryServices.Protocols.dll",`
"$srcpath\FL_System_DirectoryServices_Protocols_dll_101362_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\System.DirectoryServices.Protocols.dll",`
"$srcpath\FL_System_DirectoryServices_Protocols_dll_101362_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\System.DirectoryServices.Protocols.dll",`
"$srcpath\FL_home2_aspx_74746_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\home2.aspx",`
"$srcpath\manifest.8.0.50727.1433.844EFBA7_1C24_93B2_FF1F_C8B3B9A1E18E" , "$env:Temp\windows\winsxs\manifests\amd64_Microsoft.VC80.CRT_1fc8b3b9a1e18e3b_8.0.50727.1433_x-ww_8f022ab2.manifest",`
"$srcpath\FL_System_Management_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.Management\2.0.0.0__b03f5f7f11d50a3a\System.Management.dll",`
"$srcpath\FL_System_Management_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\System.Management.dll",`
"$srcpath\FL_System_Management_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\System.Management.dll",`
"$srcpath\FL_SmtpSettings_aspx_resx_103109_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\AppConfig\App_LocalResources\SmtpSettings.aspx.resx",`
"$srcpath\FL_EditAppSetting_aspx_102020_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\AppConfig\EditAppSetting.aspx",`
"$srcpath\FL_WebAdminHelp_Provider_aspx_119293_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\ASP.NETWebAdminFiles\WebAdminHelp_Provider.aspx",`
"$srcpath\FL_WebAdminHelp_Provider_aspx_119293_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\WebAdminHelp_Provider.aspx",`
"$srcpath\FL_AdoNetDiag_dll_106905_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\AdoNetDiag.dll",`
"$srcpath\FL_managePermissions_aspx_74808_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Permissions\managePermissions.aspx",`
"$srcpath\FL_InstallUtilLib_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\InstallUtilLib.dll",`
"$srcpath\FL_WebAdminHelp_aspx_119289_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\ASP.NETWebAdminFiles\WebAdminHelp.aspx",`
"$srcpath\FL_WebAdminHelp_aspx_119289_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\WebAdminHelp.aspx",`
"$srcpath\cvtres_exe_1_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\cvtres.exe",`
"$srcpath\FL_branding_Full2_gif_102054_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\branding_Full2.gif",`
"$srcpath\FL_selectedTab_leftCorner_gif_102049_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\selectedTab_leftCorner.gif",`
"$srcpath\FL_selectedTab_leftCorner_gif_102049_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\unSelectedTab_leftCorner.gif",`
"$srcpath\FL_RegSvcs_exe_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\RegSvcs.exe",`
"$srcpath\FL_RegSvcs_exe_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\RegSvcs.exe",`
"$srcpath\FL_IEExecRemote_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\IEExecRemote\2.0.0.0__b03f5f7f11d50a3a\IEExecRemote.dll",`
"$srcpath\FL_IEExecRemote_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\IEExecRemote.dll",`
"$srcpath\FL_IEExecRemote_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\IEExecRemote.dll",`
"$srcpath\FL_InstallProfile_SQL_104241_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\InstallProfile.SQL",`
"$srcpath\FL_InstallProfile_SQL_104241_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\InstallProfile.SQL",`
"$srcpath\FL_webAdminButtonRow_master_74737_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\webAdminButtonRow.master",`
"$srcpath\FL_manageSingleRole_aspx_resx_103494_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Roles\App_LocalResources\manageSingleRole.aspx.resx",`
"$srcpath\FL_System_EnterpriseServices_Wrapper_dll_76457_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_32\System.EnterpriseServices\2.0.0.0__b03f5f7f11d50a3a\System.EnterpriseServices.Wrapper.dll",`
"$srcpath\FL_System_EnterpriseServices_Wrapper_dll_76457_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\System.EnterpriseServices.Wrapper.dll",`
"$srcpath\mscoree_tlb_1_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\mscoree.tlb",`
"$srcpath\FL_mscories_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\system32\mscories.dll",`
"$srcpath\FL_InstallSqlStateTemplate_sql_116231_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\InstallSqlStateTemplate.sql",`
"$srcpath\FL_InstallSqlStateTemplate_sql_116231_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\InstallSqlStateTemplate.sql",`
"$srcpath\FL_AppConfigHome_aspx_resx_103114_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\AppConfig\App_LocalResources\AppConfigHome.aspx.resx",`
"$srcpath\FL_security_aspx_74800_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\security.aspx",`
"$srcpath\FL_WizardPage_cs_102042_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_Code\WizardPage.cs",`
"$srcpath\FL_manageUsers_aspx_resx_103467_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Users\App_LocalResources\manageUsers.aspx.resx",`
"$srcpath\FL_System_tlb_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\System.tlb",`
"$srcpath\FL_wizardPermission_ascx_74822_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Wizard\wizardPermission.ascx",`
"$srcpath\FL_xiino_browser_76168_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\xiino.browser",`
"$srcpath\FL_xiino_browser_76168_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\xiino.browser",`
"$srcpath\FL_AppLaunch_exe_111659_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\AppLaunch.exe",`
"$srcpath\FL_webAdminNoNavBar_master_102339_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\webAdminNoNavBar.master",`
"$srcpath\FL_almsgs_dll_ENU_X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\1033\alinkui.dll",`
"$srcpath\FL_aspnet_regiis_exe_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\aspnet_regiis.exe",`
"$srcpath\FL__DataOracleClientPerfCounters_shared12__106788_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\_DataOracleClientPerfCounters_shared12_neutral.ini",`
"$srcpath\FL__DataOracleClientPerfCounters_shared12__106788_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\_DataOracleClientPerfCounters_shared12_neutral.ini",`
"$srcpath\FL_cscompmgd_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\cscompmgd\8.0.0.0__b03f5f7f11d50a3a\cscompmgd.dll",`
"$srcpath\FL_cscompmgd_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\cscompmgd.dll",`
"$srcpath\FL_cscompmgd_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\cscompmgd.dll",`
"$srcpath\FL_confirmation_ascx_resx_110690_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Wizard\App_LocalResources\confirmation.ascx.resx",`
"$srcpath\jsc_exe_1_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\jsc.exe",`
"$srcpath\FL_TLBREF_DLL_97713_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\TLBREF.DLL",`
"$srcpath\FL_findUsers_aspx_102268_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Users\findUsers.aspx",`
"$srcpath\FL_UninstallMembership_sql_67219_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\UninstallMembership.sql",`
"$srcpath\FL_UninstallMembership_sql_67219_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\UninstallMembership.sql",`
"$srcpath\FL_peverify_dll_97810_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\peverify.dll",`
"$srcpath\FL_webengine_dll_135889_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\webengine.dll",`
"$srcpath\FL_csc_rsp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\csc.rsp",`
"$srcpath\FL_csc_rsp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\csc.rsp",`
"$srcpath\FL_WebAdminHelp_Provider_aspx_resx_122114_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_LocalResources\WebAdminHelp_Provider.aspx.resx",`
"$srcpath\FL_home0_aspx_74744_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\home0.aspx",`
"$srcpath\FL_InstallSqlState_sql_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\InstallSqlState.sql",`
"$srcpath\FL_InstallSqlState_sql_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\InstallSqlState.sql",`
"$srcpath\FL_weblowtrust_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\web_lowtrust.config",`
"$srcpath\FL_weblowtrust_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\web_lowtrust.config.default",`
"$srcpath\FL_weblowtrust_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\web_lowtrust.config",`
"$srcpath\FL_weblowtrust_config_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\web_lowtrust.config.default",`
"$srcpath\FL_System_Messaging_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.Messaging\2.0.0.0__b03f5f7f11d50a3a\System.Messaging.dll",`
"$srcpath\FL_System_Messaging_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\System.Messaging.dll",`
"$srcpath\FL_System_Messaging_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\System.Messaging.dll",`
"$srcpath\Microsoft_VsaVb_dll_3_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\Microsoft_VsaVb\8.0.0.0__b03f5f7f11d50a3a\Microsoft_VsaVb.dll",`
"$srcpath\Microsoft_VsaVb_dll_3_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\Microsoft_VsaVb.dll",`
"$srcpath\FL_shfusion_chm_121725_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\shfusion.chm",`
"$srcpath\FL_shfusion_chm_121725_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\shfusion.chm",`
"$srcpath\FL_ProvidersPage_cs_102040_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_Code\ProvidersPage.cs",`
"$srcpath\FL_sbs_mscorrc_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\sbs_mscorrc.dll",`
"$srcpath\FL_ManageProviders_aspx_92850_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Providers\ManageProviders.aspx",`
"$srcpath\FL_Aspnet_config_117583_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\Aspnet.config",`
"$srcpath\FL_Aspnet_config_117583_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\Aspnet.config",`
"$srcpath\FL_CasPol_exe_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CasPol.exe",`
"$srcpath\FL_confirmation_ascx_102278_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Wizard\confirmation.ascx",`
"$srcpath\FL_WebAdminHelp_Internals_aspx_119291_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\ASP.NETWebAdminFiles\WebAdminHelp_Internals.aspx",`
"$srcpath\FL_WebAdminHelp_Internals_aspx_119291_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\WebAdminHelp_Internals.aspx",`
"$srcpath\FL_System_Runtime_Serialization_Formatters_Soap_dl_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.Runtime.Serialization.Formatters.Soap\2.0.0.0__b03f5f7f11d50a3a\System.Runtime.Serialization.Formatters.Soap.dll",`
"$srcpath\FL_System_Runtime_Serialization_Formatters_Soap_dl_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\System.Runtime.Serialization.Formatters.Soap.dll",`
"$srcpath\FL_System_Runtime_Serialization_Formatters_Soap_dl_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\System.Runtime.Serialization.Formatters.Soap.dll",`
"$srcpath\FL_DefineErrorPage_aspx_102019_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\AppConfig\DefineErrorPage.aspx",`
"$srcpath\prcp_nlp_1_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_32\mscorlib\2.0.0.0__b77a5c561934e089\prcp.nlp",`
"$srcpath\prcp_nlp_1_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_64\mscorlib\2.0.0.0__b77a5c561934e089\prcp.nlp",`
"$srcpath\prcp_nlp_1_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\prcp.nlp",`
"$srcpath\prcp_nlp_1_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\prcp.nlp",`
"$srcpath\FL_System_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System\2.0.0.0__b77a5c561934e089\System.dll",`
"$srcpath\FL_System_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\System.dll",`
"$srcpath\FL_System_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\System.dll",`
"$srcpath\FL_aspnet_perf2_ini_ENU_X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\aspnet_perf2.ini",`
"$srcpath\FL_WebAdminWithConfirmationNoButtonRow_mas_102343_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\WebAdminWithConfirmationNoButtonRow.master",`
"$srcpath\FL_System_XML_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.Xml\2.0.0.0__b77a5c561934e089\System.XML.dll",`
"$srcpath\FL_System_XML_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\System.XML.dll",`
"$srcpath\FL_System_XML_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\System.XML.dll",`
"$srcpath\FL_mscorsec_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\mscorsec.dll",`
"$srcpath\FL_sbs_iehost_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\sbs_iehost.dll",`
"$srcpath\FL_CreateAppSetting_aspx_resx_103117_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\AppConfig\App_LocalResources\CreateAppSetting.aspx.resx",`
"$srcpath\FL_wizardInit_ascx_74820_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Wizard\wizardInit.ascx",`
"$srcpath\FL_mscorlib_tlb_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\mscorlib.tlb",`
"$srcpath\FL_aspnet_filter_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\aspnet_filter.dll",`
"$srcpath\FL_System_DeploymentFramework_Service_exe_66797_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\dfsvc.exe",`
"$srcpath\FL_System_EnterpriseServices_tlb_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\System.EnterpriseServices.tlb",`
"$srcpath\FL_machine_config_105746_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\machine.config.default",`
"$srcpath\FL_machine_config_105746_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\machine.config.default",`
"$srcpath\FL_NavigationBar_cs_102045_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_Code\NavigationBar.cs",`
"$srcpath\FL_manageProviders_aspx_resx_103379_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Providers\App_LocalResources\manageProviders.aspx.resx",`
"$srcpath\FL_sorttbls_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_32\mscorlib\2.0.0.0__b77a5c561934e089\sorttbls.nlp",`
"$srcpath\FL_sorttbls_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_64\mscorlib\2.0.0.0__b77a5c561934e089\sorttbls.nlp",`
"$srcpath\FL_sorttbls_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\sorttbls.nlp",`
"$srcpath\FL_sorttbls_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\sorttbls.nlp",`
"$srcpath\catalog.8.0.50727.1433.4F6D20F0_CCE5_1492_FF1F_C8B3B9A1E18E" , "$env:Temp\windows\winsxs\Policies\amd64_policy.8.0.Microsoft.VC80.CRT_1fc8b3b9a1e18e3b_x-ww_d780e993\8.0.50727.1433.cat",`
"$srcpath\FL_aspnet_perf_ini_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\aspnet_perf.ini",`
"$srcpath\FL_CvtResUI_dll_109387_ENU_X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\1033\CvtResUI.dll",`
"$srcpath\FL_WebAdminHelp_Application_aspx_resx_122111_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_LocalResources\WebAdminHelp_Application.aspx.resx",`
"$srcpath\FL_Default_browser_76171_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\Default.browser",`
"$srcpath\FL_Default_browser_76171_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\Default.browser",`
"$srcpath\FL_CustomMarshalers_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_64\CustomMarshalers\2.0.0.0__b03f5f7f11d50a3a\CustomMarshalers.dll",`
"$srcpath\FL_CustomMarshalers_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CustomMarshalers.dll",`
"$srcpath\Microsoft.JScript_tlb_2_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\Microsoft.JScript.tlb",`
"$srcpath\FL_gateway_browser_76174_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\gateway.browser",`
"$srcpath\FL_gateway_browser_76174_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\gateway.browser",`
"$srcpath\FL_createPermission_aspx_74809_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Permissions\createPermission.aspx",`
"$srcpath\CORPerfMonSymbols_h_1_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CORPerfMonSymbols.h",`
"$srcpath\CORPerfMonSymbols_h_1_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CORPerfMonSymbols.h",`
"$srcpath\FL_SecurityPage_cs_102041_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_Code\SecurityPage.cs",`
"$srcpath\mscoree_tlb_1_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\mscoree.tlb",`
"$srcpath\FL_MME_browser_76158_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\MME.browser",`
"$srcpath\FL_MME_browser_76158_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\MME.browser",`
"$srcpath\FL_wizardAuthentication_ascx_resx_103395_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Wizard\App_LocalResources\wizardAuthentication.ascx.resx",`
"$srcpath\FL_aspnet_mof_uninstall_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\aspnet.mof.uninstall",`
"$srcpath\FL_aspnet_mof_uninstall_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\aspnet.mof.uninstall",`
"$srcpath\catalog.8.0.50727.1433.98CB24AD_52FB_DB5F_FF1F_C8B3B9A1E18E" , "$env:Temp\windows\winsxs\manifests\x86_Microsoft.VC80.CRT_1fc8b3b9a1e18e3b_8.0.50727.1433_x-ww_5cf844d2.cat",`
"$srcpath\FL_ie_browser_76156_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\ie.browser",`
"$srcpath\FL_ie_browser_76156_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\ie.browser",`
"$srcpath\FL_SOS_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\SOS.dll",`
"$srcpath\FL_SmtpSettings_aspx_102013_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\AppConfig\SmtpSettings.aspx",`
"$srcpath\FL_AppLaunch_exe_111659_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\AppLaunch.exe",`
"$srcpath\FL_setUpAuthentication_aspx_resx_103482_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\App_LocalResources\setUpAuthentication.aspx.resx",`
"$srcpath\FL_providerList_ascx_resx_103378_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Providers\App_LocalResources\providerList.ascx.resx",`
"$srcpath\FL_image2_gif_74785_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\image2.gif",`
"$srcpath\FL_CasPol_exe_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CasPol.exe",`
"$srcpath\FL_ManageAppSettings_aspx_resx_103111_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\AppConfig\App_LocalResources\ManageAppSettings.aspx.resx",`
"$srcpath\FL_winwap_browser_109069_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\winwap.browser",`
"$srcpath\FL_winwap_browser_109069_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\winwap.browser",`
"$srcpath\FL__NetworkingPerfCounters_h_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\_NetworkingPerfCounters.h",`
"$srcpath\FL__NetworkingPerfCounters_h_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\_NetworkingPerfCounters.h",`
"$srcpath\FL_mscorsecr_dll_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\MUI\0409\mscorsecr.dll",`
"$srcpath\FL_InstallUtil_exe_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\InstallUtil.exe",`
"$srcpath\FL_regtlib_exe_1_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\regtlibv12.exe",`
"$srcpath\FL_HelpIcon_solid_gif_102058_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\HelpIcon_solid.gif",`
"$srcpath\FL_selectedTab_rightCorner_gif_102050_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\selectedTab_rightCorner.gif",`
"$srcpath\FL_selectedTab_rightCorner_gif_102050_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\unSelectedTab_rightCorner.gif",`
"$srcpath\FL_System_Drawing_tlb_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\System.Drawing.tlb",`
"$srcpath\FL_MSBuildEngine_dll_67852_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\Microsoft.Build.Engine\2.0.0.0__b03f5f7f11d50a3a\Microsoft.Build.Engine.dll",`
"$srcpath\FL_MSBuildEngine_dll_67852_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\Microsoft.Build.Engine.dll",`
"$srcpath\FL_MSBuildEngine_dll_67852_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\Microsoft.Build.Engine.dll",`
"$srcpath\FL_wizardProviderInfo_ascx_resx_103394_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Wizard\App_LocalResources\wizardProviderInfo.ascx.resx",`
"$srcpath\dw20.adm_0001_1033.F0DF3458_A845_11D3_8D0A_0050046416B9" , "$env:Temp\windows\inf\AER_1033.ADM",`
"$srcpath\FL_MSBuild_rsp_113422_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\MSBuild.rsp",`
"$srcpath\FL_MSBuild_rsp_113422_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\MSBuild.rsp",`
"$srcpath\FL_MSBuild_rsp_113422_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\MSBuild.rsp",`
"$srcpath\FL_MSBuild_rsp_113422_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\MSBuild.rsp",`
"$srcpath\FL_mscorsn_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\mscorsn.dll",`
"$srcpath\Microsoft.JScript_dll_2_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\Microsoft.JScript\8.0.0.0__b03f5f7f11d50a3a\Microsoft.JScript.dll",`
"$srcpath\Microsoft.JScript_dll_2_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\Microsoft.JScript.dll",`
"$srcpath\Microsoft.JScript_dll_2_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\Microsoft.JScript.dll",`
"$srcpath\FL_diasymreader_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\diasymreader.dll",`
"$srcpath\FL_sbs_mscorsec_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\sbs_mscorsec.dll",`
"$srcpath\FL_MSBuildUtilities_dll_70717_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\Microsoft.Build.Utilities\2.0.0.0__b03f5f7f11d50a3a\Microsoft.Build.Utilities.dll",`
"$srcpath\FL_MSBuildUtilities_dll_70717_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\Microsoft.Build.Utilities.dll",`
"$srcpath\FL_MSBuildUtilities_dll_70717_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\Microsoft.Build.Utilities.dll",`
"$srcpath\FL_mscortim_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\mscortim.dll",`
"$srcpath\FL_aspnet_regsql_exe_73568_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\aspnet_regsql.exe",`
"$srcpath\msvcr80.dll.8.0.50727.1433.98CB24AD_52FB_DB5F_FF1F_C8B3B9A1E18E" , "$env:Temp\windows\winsxs\x86_Microsoft.VC80.CRT_1fc8b3b9a1e18e3b_8.0.50727.1433_x-ww_5cf844d2\msvcr80.dll",`
"$srcpath\FL_cscmsgs_dll_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\1033\cscompui.dll",`
"$srcpath\FL_aspnet_regsql_exe_73568_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\aspnet_regsql.exe",`
"$srcpath\FL_mozilla_browser_76159_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\mozilla.browser",`
"$srcpath\FL_mozilla_browser_76159_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\mozilla.browser",`
"$srcpath\FL_home2_aspx_resx_103508_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\App_LocalResources\home2.aspx.resx",`
"$srcpath\FL_WebAdminWithConfirmation_master_92851_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\WebAdminWithConfirmation.master",`
"$srcpath\FL_home1_aspx_74745_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\home1.aspx",`
"$srcpath\FL_WMINet_Utils_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\WMINet_Utils.dll",`
"$srcpath\FL_System_Drawing_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.Drawing\2.0.0.0__b03f5f7f11d50a3a\System.Drawing.dll",`
"$srcpath\FL_System_Drawing_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\System.Drawing.dll",`
"$srcpath\FL_System_Drawing_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\System.Drawing.dll",`
"$srcpath\FL_RegAsm_exe_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\RegAsm.exe",`
"$srcpath\FL_netscape_browser_76160_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\netscape.browser",`
"$srcpath\FL_netscape_browser_76160_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\netscape.browser",`
"$srcpath\Microsoft.JScript_tlb_2_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\Microsoft.JScript.tlb",`
"$srcpath\msvcp80.dll.8.0.50727.1433.98CB24AD_52FB_DB5F_FF1F_C8B3B9A1E18E" , "$env:Temp\windows\winsxs\x86_Microsoft.VC80.CRT_1fc8b3b9a1e18e3b_8.0.50727.1433_x-ww_5cf844d2\msvcp80.dll",`
"$srcpath\FL_EventLogMessages_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\EventLogMessages.dll",`
"$srcpath\dw20.adm_0001_1028_1028.F0DF3458_A845_11D3_8D0A_0050046416B9" , "$env:Temp\windows\inf\AER_1028.ADM",`
"$srcpath\mscorrc_dll_2_ENU_X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\mscorrc.dll",`
"$srcpath\FL_alink_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\alink.dll",`
"$srcpath\FL_MSBuild_exe_67853_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\MSBuild.exe",`
"$srcpath\FL_CORPerfMonExt_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CORPerfMonExt.dll",`
"$srcpath\FL_IIEHost_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\IIEHost\2.0.0.0__b03f5f7f11d50a3a\IIEHost.dll",`
"$srcpath\FL_IIEHost_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\IIEHost.dll",`
"$srcpath\FL_IIEHost_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\IIEHost.dll",`
"$srcpath\FL_aspnet_state_perf_h_76107_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\aspnet_state_perf.h",`
"$srcpath\FL_aspnet_state_perf_h_76107_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\aspnet_state_perf.h",`
"$srcpath\FL_ngen_exe_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ngen.exe",`
"$srcpath\filler" , "$env:Temp\windows\assembly\NativeImages_v2.0.50727_32\index24.dat",`
"$srcpath\filler" , "$env:Temp\windows\assembly\NativeImages_v2.0.50727_32\index25.dat",`
"$srcpath\filler" , "$env:Temp\windows\assembly\NativeImages_v2.0.50727_64\index31.dat",`
"$srcpath\filler" , "$env:Temp\windows\Installer\wix{F5B09CFD-F0B2-36AF-8DF4-1DF6B63FC7B4}.SchedServiceConfig.rmi",`
"$srcpath\manifest.8.0.50727.1433.98CB24AD_52FB_DB5F_FF1F_C8B3B9A1E18E" , "$env:Temp\windows\winsxs\manifests\x86_Microsoft.VC80.CRT_1fc8b3b9a1e18e3b_8.0.50727.1433_x-ww_5cf844d2.manifest",`
"$srcpath\FL_opera_browser_76163_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\opera.browser",`
"$srcpath\FL_opera_browser_76163_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\opera.browser",`
"$srcpath\FL_normnfc_nlp_66374_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_32\mscorlib\2.0.0.0__b77a5c561934e089\normnfc.nlp",`
"$srcpath\FL_normnfc_nlp_66374_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_64\mscorlib\2.0.0.0__b77a5c561934e089\normnfc.nlp",`
"$srcpath\FL_normnfc_nlp_66374_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\normnfc.nlp",`
"$srcpath\FL_normnfc_nlp_66374_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\normnfc.nlp",`
"$srcpath\FL_sbs_diasymreader_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\sbs_diasymreader.dll",`
"$srcpath\FL_System_Web_Services_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.Web.Services\2.0.0.0__b03f5f7f11d50a3a\System.Web.Services.dll",`
"$srcpath\FL_System_Web_Services_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\System.Web.Services.dll",`
"$srcpath\FL_System_Web_Services_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\System.Web.Services.dll",`
"$srcpath\FL_System_Runtime_Remoting_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.Runtime.Remoting\2.0.0.0__b77a5c561934e089\System.Runtime.Remoting.dll",`
"$srcpath\FL_System_Runtime_Remoting_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\System.Runtime.Remoting.dll",`
"$srcpath\FL_System_Runtime_Remoting_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\System.Runtime.Remoting.dll",`
"$srcpath\FL_aspnet_perf_h_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\aspnet_perf.h",`
"$srcpath\FL_aspnet_perf_h_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\aspnet_perf.h",`
"$srcpath\FL_gacutil_exe_config_79703_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v1.1.4322\gacutil.exe.config",`
"$srcpath\FL_aspnet_regiis_exe_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\aspnet_regiis.exe",`
"$srcpath\FL_mscorsvc_dll_93043_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\mscorsvc.dll",`
"$srcpath\FL_UninstallRoles_sql_67222_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\UninstallRoles.sql",`
"$srcpath\FL_UninstallRoles_sql_67222_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\UninstallRoles.sql",`
"$srcpath\FL_help_jpg_74778_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\help.jpg",`
"$srcpath\FL_gradient_onBlue_gif_74775_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\gradient_onBlue.gif",`
"$srcpath\FL_System_Design_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.Design\2.0.0.0__b03f5f7f11d50a3a\System.Design.dll",`
"$srcpath\FL_System_Design_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\System.Design.dll",`
"$srcpath\FL_System_Design_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\System.Design.dll",`
"$srcpath\FL_Microsoft_CSharp_targets_106591_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\Microsoft.CSharp.targets",`
"$srcpath\FL_Microsoft_CSharp_targets_106591_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\Microsoft.CSharp.targets",`
"$srcpath\FL_System_Transactions_dll_75016_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_64\System.Transactions\2.0.0.0__b77a5c561934e089\System.Transactions.dll",`
"$srcpath\FL_System_Transactions_dll_75016_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\System.Transactions.dll",`
"$srcpath\FL_mscorpjt_dll_93058_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\mscorpjt.dll",`
"$srcpath\FL_System_EnterpriseServices_Thunk_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\System.EnterpriseServices.Thunk.dll",`
"$srcpath\FL_mscordbc_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\mscordbc.dll",`
"$srcpath\FL_prc_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_32\mscorlib\2.0.0.0__b77a5c561934e089\prc.nlp",`
"$srcpath\FL_prc_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_64\mscorlib\2.0.0.0__b77a5c561934e089\prc.nlp",`
"$srcpath\FL_prc_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\prc.nlp",`
"$srcpath\FL_prc_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\prc.nlp",`
"$srcpath\FL_DefaultWsdlHelpGenerator_aspx_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\DefaultWsdlHelpGenerator.aspx",`
"$srcpath\FL_DefaultWsdlHelpGenerator_aspx_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\DefaultWsdlHelpGenerator.aspx",`
"$srcpath\FL_System_EnterpriseServices_Wrapper_dll_76457_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_64\System.EnterpriseServices\2.0.0.0__b03f5f7f11d50a3a\System.EnterpriseServices.Wrapper.dll",`
"$srcpath\FL_System_EnterpriseServices_Wrapper_dll_76457_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\System.EnterpriseServices.Wrapper.dll",`
"$srcpath\FL_mscorie_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\mscorie.dll",`
"$srcpath\FL_DebugAndTrace_aspx_102018_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\AppConfig\DebugAndTrace.aspx",`
"$srcpath\FL_shfusion_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\shfusion.dll",`
"$srcpath\FL_addUser_aspx_resx_103469_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Users\App_LocalResources\addUser.aspx.resx",`
"$srcpath\FL_System_DeploymentFramework_Service_exe_66797_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\dfsvc.exe",`
"$srcpath\FL_mscorsvw_exe_93402_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\mscorsvw.exe",`
"$srcpath\FL_System_Data_OracleClient_dll_2_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_32\System.Data.OracleClient\2.0.0.0__b77a5c561934e089\System.Data.OracleClient.dll",`
"$srcpath\FL_System_Data_OracleClient_dll_2_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\System.Data.OracleClient.dll",`
"$srcpath\FL_UninstallCommon_sql_74697_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\UninstallCommon.sql",`
"$srcpath\FL_UninstallCommon_sql_74697_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\UninstallCommon.sql",`
"$srcpath\ShFusRes_dll_1_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ShFusRes.dll",`
"$srcpath\FL_SYSTEM_WINDOWS_FORMS_DLL_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.Windows.Forms\2.0.0.0__b77a5c561934e089\System.Windows.Forms.dll",`
"$srcpath\FL_SYSTEM_WINDOWS_FORMS_DLL_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\System.Windows.Forms.dll",`
"$srcpath\FL_SYSTEM_WINDOWS_FORMS_DLL_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\System.Windows.Forms.dll",`
"$srcpath\Microsoft_Vsa_tlb_1_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\Microsoft.Vsa.tlb",`
"$srcpath\FL_manageAllRoles_aspx_74812_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\Roles\manageAllRoles.aspx",`
"$srcpath\FL_AssemblyList_xml_113047_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\RedistList\FrameworkList.xml",`
"$srcpath\FL_openwave_browser_76162_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\openwave.browser",`
"$srcpath\FL_openwave_browser_76162_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\openwave.browser",`
"$srcpath\FL_mscordbi_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\mscordbi.dll",`
"$srcpath\FL_dv_aspnetmmc_chm_121991_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\dv_aspnetmmc.chm",`
"$srcpath\FL_dv_aspnetmmc_chm_121991_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\dv_aspnetmmc.chm",`
"$srcpath\FL_panasonic_browser_76165_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\Browsers\panasonic.browser",`
"$srcpath\FL_panasonic_browser_76165_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\Browsers\panasonic.browser",`
"$srcpath\FL_System_Drawing_tlb_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\System.Drawing.tlb",`
"$srcpath\FL_WMINet_Utils_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\WMINet_Utils.dll",`
"$srcpath\FL_CreateAppSetting_aspx_102017_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\AppConfig\CreateAppSetting.aspx",`
"$srcpath\FL_System_DirectoryServices_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.DirectoryServices\2.0.0.0__b03f5f7f11d50a3a\System.DirectoryServices.dll",`
"$srcpath\FL_System_DirectoryServices_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\System.DirectoryServices.dll",`
"$srcpath\FL_System_DirectoryServices_dll_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\System.DirectoryServices.dll",`
"$srcpath\FL_sbscmp10_dll_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\sbscmp20_mscorlib.dll",`
"$srcpath\FL_InstallWebEventSqlProvider_sql_93276_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\InstallWebEventSqlProvider.sql",`
"$srcpath\FL_InstallWebEventSqlProvider_sql_93276_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\InstallWebEventSqlProvider.sql",`
"$srcpath\FL_deselectedTab_1x1_gif_102056_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\deselectedTab_1x1.gif",`
"$srcpath\mscorrc_dll_2_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\mscorrc.dll",`
"$srcpath\FL_normnfd_nlp_66375_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_32\mscorlib\2.0.0.0__b77a5c561934e089\normnfd.nlp",`
"$srcpath\FL_normnfd_nlp_66375_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_64\mscorlib\2.0.0.0__b77a5c561934e089\normnfd.nlp",`
"$srcpath\FL_normnfd_nlp_66375_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\normnfd.nlp",`
"$srcpath\FL_normnfd_nlp_66375_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\normnfd.nlp",`
"$srcpath\FL_security_aspx_resx_103483_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Security\App_LocalResources\security.aspx.resx",`
"$srcpath\FL_sortkey_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_32\mscorlib\2.0.0.0__b77a5c561934e089\sortkey.nlp",`
"$srcpath\FL_sortkey_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_64\mscorlib\2.0.0.0__b77a5c561934e089\sortkey.nlp",`
"$srcpath\FL_sortkey_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\sortkey.nlp",`
"$srcpath\FL_sortkey_nlp_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\sortkey.nlp"

for ( $j = 0; $j -lt $dotnet20.count; $j+=2 ) {
    Copy-Item -recurse -Path $dotnet20[$j] -Destination ( Join-Path (New-item -Type Directory -Force $(Split-Path -Path $dotnet20[$j+1]))   $(Split-Path -Leaf $dotnet20[$j+1])   ) -Force  -Verbose }


7z x $env:TEMP\\$(verb)\\wcu\\dotNetFramework\\dotNetFX35\\x64\\netfx35_x64.exe "-o$env:TEMP\\$(verb)\\wcu\\dotNetFramework\\dotNetFX35\\x64" -y;
7z x $env:TEMP\\$(verb)\\wcu\\dotNetFramework\\dotNetFX35\\x64\\vs_setup.cab "-o$env:TEMP\\$(verb)\\wcu\\dotNetFramework\\dotNetFX35\\extr" -y;

    $srcpath="$env:TEMP\dotnet35\wcu\dotNetFramework\dotNetFX35\extr"

[array]$dotnet35 = `
"$srcpath\System.Net_dll_x86_gc.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.Net\3.5.0.0__b03f5f7f11d50a3a\System.Net.dll",`
"$srcpath\WapRes_dll_amd64_heb.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1037.dll",`
"$srcpath\FL_npwpf_dll_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\Windows Presentation Foundation\NPWPF.dll",`
"$srcpath\FL_eula_exp_txt_amd64_chs.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.2052.rtf",`
"$srcpath\FL_DirectoryServices_AccountManagement_dll_Gac_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.DirectoryServices.AccountManagement\3.5.0.0__b77a5c561934e089\System.DirectoryServices.AccountManagement.dll",`
"$srcpath\FL_setupres_dll_amd64_cht.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1028.dll",`
"$srcpath\FL_logo_bmp_97496_97496_cn_enu.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\logo.bmp",`
"$srcpath\policy.21022.08.policy_9_0_Microsoft_VC90_CRT_x86.RTM" , "$env:Temp\windows\winsxs\Policies\x86_policy.9.0.Microsoft.VC90.CRT_1fc8b3b9a1e18e3b_x-ww_b7353f75\9.0.21022.8.policy",`
"$srcpath\FL_setupres_dll_amd64_dan.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1030.dll",`
"$srcpath\msvcp90.dll.21022.08.Microsoft_VC90_CRT_x64.RTM" , "$env:Temp\windows\winsxs\amd64_Microsoft.VC90.CRT_1fc8b3b9a1e18e3b_9.0.21022.8_x-ww_0296e955\msvcp90.dll",`
"$srcpath\SQLServer_Targets_v35_x86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\SqlServer.targets",`
"$srcpath\catalog.21022.08.policy_9_0_Microsoft_VC90_CRT_x86.RTM" , "$env:Temp\windows\winsxs\Policies\x86_policy.9.0.Microsoft.VC90.CRT_1fc8b3b9a1e18e3b_x-ww_b7353f75\9.0.21022.8.cat",`
"$srcpath\CSD_SYSTEM_WORKFLOWSERVICES_DLL_3500amd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.WorkflowServices\3.5.0.0__31bf3856ad364e35\System.WorkflowServices.dll",`
"$srcpath\FL_Microsoft_Build_xsd_v35_amd64_enu.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\Microsoft.Build.xsd",`
"$srcpath\FL_Microsoft_Build_xsd_v35_amd64_enu.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft.Build.xsd",`
"$srcpath\FL_setupres_dll_amd64_jpn.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1041.dll",`
"$srcpath\FL_eula_exp_txt_amd64_nld.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1043.rtf",`
"$srcpath\FL_vbc_exe_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\vbc.exe",`
"$srcpath\WapRes_dll_amd64_nld.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1043.dll",`
"$srcpath\FL_vbc7ui_dll_20030_x86_enu.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\1033\vbc7ui.dll",`
"$srcpath\FL_eula_exp_txt_amd64_sve.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1053.rtf",`
"$srcpath\FL_eula_exp_txt_amd64_fra.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1036.rtf",`
"$srcpath\FL_setupres_dll_amd64_nor.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1044.dll",`
"$srcpath\FL_setupres_dll_amd64_trk.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1055.dll",`
"$srcpath\FL_System_AddIn_Con_dll_Gac_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.AddIn.Contract\2.0.0.0__b03f5f7f11d50a3a\System.AddIn.Contract.dll",`
"$srcpath\Microsoft_WinFX_Targets_v35_amd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\Microsoft.WinFx.targets",`
"$srcpath\Microsoft_WinFX_Targets_v35_amd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft.WinFx.targets",`
"$srcpath\FL_MSITOSIT_dll_96104_96104_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\vs_setup.dll",`
"$srcpath\csc_exe_amd64.config" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\csc.exe.config",`
"$srcpath\csc_exe_amd64.config" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\jsc.exe.config",`
"$srcpath\csc_exe_amd64.config" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\vbc.exe.config",`
"$srcpath\csc_exe_amd64.config" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\csc.exe.config",`
"$srcpath\csc_exe_amd64.config" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\vbc.exe.config",`
"$srcpath\csc_exe_amd64.config" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\csc.exe.config",`
"$srcpath\csc_exe_amd64.config" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\jsc.exe.config",`
"$srcpath\csc_exe_amd64.config" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\vbc.exe.config",`
"$srcpath\csc_exe_amd64.config" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\csc.exe.config",`
"$srcpath\csc_exe_amd64.config" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\vbc.exe.config",`
"$srcpath\FL_DeleteTemp_exe_96108_96108_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\DeleteTemp.exe",`
"$srcpath\FL_netfx35_setup_pdi_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\vs_setup.pdi",`
"$srcpath\CSD_CDF_INSTALLER_EXEamd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\WFServicesReg.exe",`
"$srcpath\FL_eula_exp_txt_amd64_jpn.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1041.rtf",`
"$srcpath\WapRes_dll_amd64_jpn.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1041.dll",`
"$srcpath\CFX_SERVICEMODEL35_MOF_UNINSTALLamd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\MOF\ServiceModel35.mof.uninstall",`
"$srcpath\CFX_SERVICEMODEL35_MOF_UNINSTALLamd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\MOF\ServiceModel35.mof.uninstall",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1025.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1028.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1029.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1030.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1031.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1032.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1035.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1036.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1037.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1038.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1040.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1041.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1042.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1043.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1044.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1045.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1046.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1049.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1053.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.1055.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.2052.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.2070.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.3082.ini",`
"$srcpath\FL_locdata_ini_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\locdata.ini",`
"$srcpath\FL_AddInUtil_exe_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\AddInUtil.exe",`
"$srcpath\FL_setupres_dll_amd64_kor.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1042.dll",`
"$srcpath\WapRes_dll_amd64_cht.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1028.dll",`
"$srcpath\FL_setupres_dll_amd64_deu.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1031.dll",`
"$srcpath\FL_AddInProcess_exe_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\AddInProcess.exe",`
"$srcpath\FL_AddInProcess32_exe_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\AddInProcess32.exe",`
"$srcpath\FL_setupres_dll_amd64_nld.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1043.dll",`
"$srcpath\FL_setupres_dll_amd64_fin.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1035.dll",`
"$srcpath\msvcm90.dll.21022.08.Microsoft_VC90_CRT_x64.RTM" , "$env:Temp\windows\winsxs\amd64_Microsoft.VC90.CRT_1fc8b3b9a1e18e3b_9.0.21022.8_x-ww_0296e955\msvcm90.dll",`
"$srcpath\FL_gencomp_dll_98507_98507_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\gencomp.dll",`
"$srcpath\WapRes_dll_amd64_deu.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1031.dll",`
"$srcpath\CFX_SERVICEMODEL35_MOFamd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\MOF\ServiceModel35.mof",`
"$srcpath\CFX_SERVICEMODEL35_MOFamd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\MOF\ServiceModel35.mof",`
"$srcpath\FL_MSBuildTasks_dll_GAC_v35_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft.Build.Tasks.v3.5.dll",`
"$srcpath\FL_AddInUtil_exe_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\AddInUtil.exe",`
"$srcpath\FL_AddInProcess32_exe_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\AddInProcess32.exe",`
"$srcpath\FL_Microsoft_BuildTasks_v35_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\Microsoft.Common.Tasks",`
"$srcpath\FL_Microsoft_BuildTasks_v35_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft.Common.Tasks",`
"$srcpath\FL_eula_exp_txt_amd64_trk.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1055.rtf",`
"$srcpath\FL_Microsoft_CSharp_targets_v35_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\Microsoft.CSharp.targets",`
"$srcpath\FL_Microsoft_CSharp_targets_v35_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft.CSharp.targets",`
"$srcpath\FL_System_Management_Instrumentation_dll_GAC_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.Management.Instrumentation\3.5.0.0__b77a5c561934e089\System.Management.Instrumentation.dll",`
"$srcpath\msvcp90.dll.21022.08.Microsoft_VC90_CRT_x86.RTM" , "$env:Temp\windows\winsxs\x86_Microsoft.VC90.CRT_1fc8b3b9a1e18e3b_9.0.21022.8_x-ww_d08d0375\msvcp90.dll",`
"$srcpath\WapRes_dll_amd64_nor.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1044.dll",`
"$srcpath\CFX_SQL_FILE_LOGIC_DROPamd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\SQL\EN\DropSqlPersistenceProviderLogic.sql",`
"$srcpath\CFX_SQL_FILE_LOGIC_DROPamd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\SQL\EN\DropSqlPersistenceProviderLogic.sql",`
"$srcpath\catalog.21022.08.Microsoft_VC90_CRT_x86.RTM" , "$env:Temp\windows\winsxs\manifests\x86_Microsoft.VC90.CRT_1fc8b3b9a1e18e3b_9.0.21022.8_x-ww_d08d0375.cat",`
"$srcpath\csc_amd64.exe" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\csc.exe",`
"$srcpath\WapRes_dll_amd64_fin.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1035.dll",`
"$srcpath\CSD_CDF_INSTALLER_EXEx86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\WFServicesReg.exe",`
"$srcpath\WapRes_dll_amd64_chs.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.2052.dll",`
"$srcpath\FL_MSBuildFramework_dll_GAC_v35_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\Microsoft.Build.Framework\3.5.0.0__b03f5f7f11d50a3a\Microsoft.Build.Framework.dll",`
"$srcpath\CFX_SQL_FILE_LOGICamd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\SQL\EN\SqlPersistenceProviderLogic.sql",`
"$srcpath\CFX_SQL_FILE_LOGICamd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\SQL\EN\SqlPersistenceProviderLogic.sql",`
"$srcpath\FL_eula_exp_txt_amd64_hun.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1038.rtf",`
"$srcpath\FL_Microsoft_VisualC_STLCLR_dll_1_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft.VisualC.STLCLR.dll",`
"$srcpath\WapRes_dll_amd64_ita.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1040.dll",`
"$srcpath\FL_eula_exp_txt_amd64_ara.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1025.rtf",`
"$srcpath\policy.21022.08.policy_9_0_Microsoft_VC90_CRT_x64.RTM" , "$env:Temp\windows\winsxs\Policies\amd64_policy.9.0.Microsoft.VC90.CRT_1fc8b3b9a1e18e3b_x-ww_16f3e195\9.0.21022.8.policy",`
"$srcpath\FL_SITSetup_dll_96093_96093_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\SITSetup.dll",`
"$srcpath\csc_x86.exe" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\csc.exe",`
"$srcpath\FL_DLinq_dll_24763_GAC_x86_ln.B588F0AF_A1DC_445b_ABE8_B3EDA2EA2F31" , "$env:Temp\windows\assembly\GAC_MSIL\System.Data.Linq\3.5.0.0__b77a5c561934e089\System.Data.Linq.dll",`
"$srcpath\FL_setupres_dll_amd64_rus.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1049.dll",`
"$srcpath\FL_eula_exp_txt_amd64_ptg.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.2070.rtf",`
"$srcpath\FL_setupres_dll_amd64_heb.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1037.dll",`
"$srcpath\FL_setupres_dll_amd64_csy.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1029.dll",`
"$srcpath\FL_eula_exp_txt_amd64_nor.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1044.rtf",`
"$srcpath\FL_Microsoft_VisualC_STLCLR_dll_1_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\Microsoft.VisualC.STLCLR\1.0.0.0__b03f5f7f11d50a3a\Microsoft.VisualC.STLCLR.dll",`
"$srcpath\FL_Microsoft_VisualC_STLCLR_dll_1_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\Microsoft.VisualC.STLCLR.dll",`
"$srcpath\FL_AddInProcess_exe_config_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\AddInProcess.exe.config",`
"$srcpath\FL_AddInProcess_exe_config_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\AddInProcess32.exe.config",`
"$srcpath\FL_AddInProcess_exe_config_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\AddInUtil.exe.config",`
"$srcpath\FL_AddInProcess_exe_config_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\AddInProcess.exe.config",`
"$srcpath\FL_AddInProcess_exe_config_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\AddInProcess32.exe.config",`
"$srcpath\FL_AddInProcess_exe_config_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\AddInUtil.exe.config",`
"$srcpath\FL_setupres_dll_amd64_esn.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.3082.dll",`
"$srcpath\FL_setupres_dll_amd64_enu.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.dll",`
"$srcpath\FL_eula_exp_txt_amd64_ptb.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1046.rtf",`
"$srcpath\CFX_SQL_FILE_SCHEMAamd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\SQL\EN\SqlPersistenceProviderSchema.sql",`
"$srcpath\CFX_SQL_FILE_SCHEMAamd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\SQL\EN\SqlPersistenceProviderSchema.sql",`
"$srcpath\cscrsp_amd64.rsp" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\csc.rsp",`
"$srcpath\cscrsp_amd64.rsp" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\csc.rsp",`
"$srcpath\FL_Microsoft_Build_Conversion_dll_GAC_v35_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\Microsoft.Build.Conversion.v3.5\3.5.0.0__b03f5f7f11d50a3a\Microsoft.Build.Conversion.v3.5.dll",`
"$srcpath\FL_eula_exp_txt_amd64_esn.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.3082.rtf",`
"$srcpath\WapRes_dll_amd64_ara.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1025.dll",`
"$srcpath\FL_MSBuildEngine_dll_GAC_v35_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\Microsoft.Build.Engine\3.5.0.0__b03f5f7f11d50a3a\Microsoft.Build.Engine.dll",`
"$srcpath\catalog.21022.08.Microsoft_VC90_CRT_x64.RTM" , "$env:Temp\windows\winsxs\manifests\amd64_Microsoft.VC90.CRT_1fc8b3b9a1e18e3b_9.0.21022.8_x-ww_0296e955.cat",`
"$srcpath\FL_setupres_dll_amd64_ptb.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1046.dll",`
"$srcpath\FL_AddInProcess_exe_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\AddInProcess.exe",`
"$srcpath\FL_eula_exp_txt_amd64_ita.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1040.rtf",`
"$srcpath\FL_eula_exp_txt_amd64_ell.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1032.rtf",`
"$srcpath\FL_dlmgr_dll_100069_100069_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\dlmgr.dll",`
"$srcpath\FL_deffactory_dat_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\deffactory.dat",`
"$srcpath\FL_Microsoft_Build_Core_xsd_v35_amd64_enu.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\MSBuild\Microsoft.Build.Core.xsd",`
"$srcpath\FL_Microsoft_Build_Core_xsd_v35_amd64_enu.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\MSBuild\Microsoft.Build.Core.xsd",`
"$srcpath\CFX_SQL_FILE_SCHEMA_DROPamd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\SQL\EN\DropSqlPersistenceProviderSchema.sql",`
"$srcpath\CFX_SQL_FILE_SCHEMA_DROPamd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\SQL\EN\DropSqlPersistenceProviderSchema.sql",`
"$srcpath\FL_System_Core_dll_24763_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.Core\3.5.0.0__b77a5c561934e089\System.Core.dll",`
"$srcpath\CSD_SYSTEM_SERVICEMODEL_WEB_DLL_3500amd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.ServiceModel.Web\3.5.0.0__31bf3856ad364e35\System.ServiceModel.Web.dll",`
"$srcpath\FL_setup_sdb_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setup.sdb",`
"$srcpath\WapRes_dll_amd64_hun.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1038.dll",`
"$srcpath\FL_Microsoft_Common_targets_v35_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\Microsoft.Common.targets",`
"$srcpath\FL_Microsoft_Common_targets_v35_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft.Common.targets",`
"$srcpath\FL_System_Data_DataSetExtensions_dll_Gac_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.Data.DataSetExtensions\3.5.0.0__b77a5c561934e089\System.Data.DataSetExtensions.dll",`
"$srcpath\WapRes_dll_amd64_csy.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1029.dll",`
"$srcpath\FL_System_Windows_Presentation_dll_gac_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.Windows.Presentation\3.5.0.0__b77a5c561934e089\System.Windows.Presentation.dll",`
"$srcpath\WapRes_dll_amd64_dan.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1030.dll",`
"$srcpath\WapRes_dll_amd64_rus.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1049.dll",`
"$srcpath\FL_vbc_rsp_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\vbc.rsp",`
"$srcpath\FL_vbc_rsp_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\vbc.rsp",`
"$srcpath\FL_setupres_dll_amd64_ell.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1032.dll",`
"$srcpath\FL_HtmlLite_dll_96198_96198_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\HtmlLite.dll",`
"$srcpath\FL_MSBuild_exe_v35_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\MSBuild.exe",`
"$srcpath\WapRes_dll_amd64_plk.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1045.dll",`
"$srcpath\msvcm90.dll.21022.08.Microsoft_VC90_CRT_x86.RTM" , "$env:Temp\windows\winsxs\x86_Microsoft.VC90.CRT_1fc8b3b9a1e18e3b_9.0.21022.8_x-ww_d08d0375\msvcm90.dll",`
"$srcpath\FL_vbc7ui_dll_20030_amd64_enu.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\1033\vbc7ui.dll",`
"$srcpath\FL_MSBuildUtilities_DLL_GAC_v35_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\Microsoft.Build.Utilities.v3.5\3.5.0.0__b03f5f7f11d50a3a\Microsoft.Build.Utilities.v3.5.dll",`
"$srcpath\FL_Microsoft_VisualBasic_targets_v35_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\Microsoft.VisualBasic.targets",`
"$srcpath\FL_Microsoft_VisualBasic_targets_v35_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft.VisualBasic.targets",`
"$srcpath\FL_setupres_dll_amd64_ara.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1025.dll",`
"$srcpath\FL_eula_exp_txt_amd64_fin.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1035.rtf",`
"$srcpath\FL_MSBuildTasks_dll_GAC_v35_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\Microsoft.Build.Tasks.v3.5\3.5.0.0__b03f5f7f11d50a3a\Microsoft.Build.Tasks.v3.5.dll",`
"$srcpath\FL_MSBuildTasks_dll_GAC_v35_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\Microsoft.Build.Tasks.v3.5.dll",`
"$srcpath\default_win32manifest_amd64" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\default.win32manifest",`
"$srcpath\default_win32manifest_amd64" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\default.win32manifest",`
"$srcpath\FL_setupres_dll_amd64_plk.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1045.dll",`
"$srcpath\FL_eula_exp_txt_amd64_heb.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1037.rtf",`
"$srcpath\FL_setupres_dll_amd64_ita.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1040.dll",`
"$srcpath\WapRes_dll_amd64_kor.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1042.dll",`
"$srcpath\FL_vs70uimgr_dll_96106_96106_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\vs70uimgr.dll",`
"$srcpath\cscompui_x86.dll" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\1033\cscompui.dll",`
"$srcpath\FL_XLinq_dll_Gac_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.Xml.Linq\3.5.0.0__b77a5c561934e089\System.Xml.Linq.dll",`
"$srcpath\FL_eula_exp_txt_amd64_rus.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1049.rtf",`
"$srcpath\WapRes_dll_amd64_esn.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.3082.dll",`
"$srcpath\FL_Microsoft_Build_Commontypes_xsd_v35_amd64_enu.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\MSBuild\Microsoft.Build.Commontypes.xsd",`
"$srcpath\FL_Microsoft_Build_Commontypes_xsd_v35_amd64_enu.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\MSBuild\Microsoft.Build.Commontypes.xsd",`
"$srcpath\FL_eula_exp_txt_amd64_cht.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1028.rtf",`
"$srcpath\FL_MSBuild_rsp_v35_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\MSBuild.rsp",`
"$srcpath\FL_MSBuild_rsp_v35_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\MSBuild.rsp",`
"$srcpath\FL_MSBuild_rsp_v35_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\MSBuild.rsp",`
"$srcpath\FL_MSBuild_rsp_v35_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\MSBuild.rsp",`
"$srcpath\FL_eula_exp_txt_amd64_kor.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1042.rtf",`
"$srcpath\WapRes_dll_amd64_ell.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1032.dll",`
"$srcpath\WapRes_dll_amd64_sve.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1053.dll",`
"$srcpath\WapRes_dll_amd64_ptg.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.2070.dll",`
"$srcpath\FL_eula_exp_txt_amd64_dan.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1030.rtf",`
"$srcpath\catalog.21022.08.policy_9_0_Microsoft_VC90_CRT_x64.RTM" , "$env:Temp\windows\winsxs\Policies\amd64_policy.9.0.Microsoft.VC90.CRT_1fc8b3b9a1e18e3b_x-ww_16f3e195\9.0.21022.8.cat",`
"$srcpath\FL_WapUI_dll_amd64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapUI.dll",`
"$srcpath\FL_MSBuild_exe_v35_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\MSBuild.exe",`
"$srcpath\FL_setupres_dll_amd64_ptg.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.2070.dll",`
"$srcpath\FL_eula_exp_txt_amd64_csy.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1029.rtf",`
"$srcpath\msvcr90.dll.21022.08.Microsoft_VC90_CRT_x64.RTM" , "$env:Temp\windows\winsxs\amd64_Microsoft.VC90.CRT_1fc8b3b9a1e18e3b_9.0.21022.8_x-ww_0296e955\msvcr90.dll",`
"$srcpath\FL_System_AddIn_dll_Gac_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.AddIn\3.5.0.0__b77a5c561934e089\System.AddIn.dll",`
"$srcpath\FL_baseline_dat_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\baseline.dat",`
"$srcpath\WapRes_dll_amd64_ptb.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1046.dll",`
"$srcpath\FL_vbc_exe_x86_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\vbc.exe",`
"$srcpath\FL_setupres_dll_amd64_hun.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1038.dll",`
"$srcpath\FL_setupres_dll_amd64_fra.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1036.dll",`
"$srcpath\FL_setupres_dll_amd64_sve.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.1053.dll",`
"$srcpath\System.Web.Extensions_dll_x86_gc.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.Web.Extensions\3.5.0.0__31bf3856ad364e35\System.Web.Extensions.dll",`
"$srcpath\msvcr90.dll.21022.08.Microsoft_VC90_CRT_x86.RTM" , "$env:Temp\windows\winsxs\x86_Microsoft.VC90.CRT_1fc8b3b9a1e18e3b_9.0.21022.8_x-ww_d08d0375\msvcr90.dll",`
"$srcpath\FL_vsscenario_dll_98517_98517_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\vsscenario.dll",`
"$srcpath\manifest.21022.08.Microsoft_VC90_CRT_x64.RTM" , "$env:Temp\windows\winsxs\manifests\amd64_Microsoft.VC90.CRT_1fc8b3b9a1e18e3b_9.0.21022.8_x-ww_0296e955.manifest",`
"$srcpath\FL_eula_exp_txt_amd64_plk.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1045.rtf",`
"$srcpath\FL_setupres_dll_amd64_chs.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setupres.2052.dll",`
"$srcpath\FL_eula_exp_txt_amd64_deu.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1031.rtf",`
"$srcpath\WapRes_dll_amd64_enu.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.dll",`
"$srcpath\System.Web.Extensions.Design_dll_x86_gc.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.Web.Extensions.Design\3.5.0.0__31bf3856ad364e35\System.Web.Extensions.Design.dll",`
"$srcpath\WapRes_dll_amd64_fra.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1036.dll",`
"$srcpath\FL_eula_exp_txt_amd64_enu.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\eula.1033.rtf",`
"$srcpath\FL_msbuild_urt_config_v35_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.5\msbuild.exe.config",`
"$srcpath\FL_msbuild_urt_config_v35_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\msbuild.exe.config",`
"$srcpath\FL_vsbasereqs_dll_98508_98508_amd64_ln.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\vsbasereqs.dll",`
"$srcpath\cscompui_amd64.dll" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\1033\cscompui.dll",`
"$srcpath\WapRes_dll_amd64_trk.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\WapRes.1055.dll",`
"$srcpath\FL_setup_exe_96103_96103_amd64_enu.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.5\Microsoft .NET Framework 3.5\setup.exe",`
"$srcpath\manifest.21022.08.Microsoft_VC90_CRT_x86.RTM" , "$env:Temp\windows\winsxs\manifests\x86_Microsoft.VC90.CRT_1fc8b3b9a1e18e3b_9.0.21022.8_x-ww_d08d0375.manifest"

for ( $j = 0; $j -lt $dotnet35.count; $j+=2 ) {
    Copy-Item -recurse -Path $dotnet35[$j] -Destination ( Join-Path (New-item -Type Directory -Force $(Split-Path -Path $dotnet35[$j+1]))   $(Split-Path -Leaf $dotnet35[$j+1])   ) -Force  -Verbose }


    Remove-Item -Force  $env:TEMP\\$(verb)\\wcu\\dotNetFramework\\dotNetFX30\\PCW_CAB_NetFX*
    foreach($i in $( ls $env:TEMP\\$(verb)\\wcu\\dotNetFramework\\dotNetFX30\\*.msp) )
        {7z x $i "-o$env:TEMP\\$(verb)\\wcu\\dotNetFramework\\dotNetFX30" "PCW_CAB_NetFX" -aou -y;}
    quit?(7z) ;
    foreach($i in $( ls $env:TEMP\\$(verb)\\wcu\\dotNetFramework\\dotNetFX30\\PCW_CAB_NetFX*) )
        {7z x $i "-o$env:TEMP\\$(verb)\\wcu\\dotNetFramework\\dotNetFX30\\extr" -y; } 
    quit?(7z)

    $srcpath="$env:TEMP\dotnet35\wcu\dotNetFramework\dotNetFX30\extr"

[array]$dotnet30 = `
"$srcpath\XamlViewer_X86.xbap" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\WPF\XamlViewer\XamlViewer_v0300.xbap",`
"$srcpath\PresentationHostDLL_X86.dll.mui" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\WPF\en-us\PresentationHostDLL.dll.mui",`
"$srcpath\PresentationHost_X86.exe.mui" , "$env:Temp\windows\syswow64\en-us\PresentationHost.exe.mui",`
"$srcpath\NlsData0009_A64.dll" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\WPF\NlsData0009.dll",`
"$srcpath\FL_infocardcpl_cpl_134629_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\syswow64\infocardcpl.cpl",`
"$srcpath\UIAutomationClient_A64.dll" , "$env:Temp\windows\assembly\GAC_MSIL\UIAutomationClient\3.0.0.0__31bf3856ad364e35\UIAutomationClient.dll",`
"$srcpath\PenIMC_X86.dll" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\WPF\PenIMC.dll",`
"$srcpath\FL__ServiceModelEndpointPerfCounters_ini_134737_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_ServiceModelEndpointPerfCounters.ini",`
"$srcpath\FL__ServiceModelEndpointPerfCounters_ini_134737_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_ServiceModelEndpointPerfCounters.ini",`
"$srcpath\WindowsBase_A64.dll" , "$env:Temp\windows\assembly\GAC_MSIL\WindowsBase\3.0.0.0__31bf3856ad364e35\WindowsBase.dll",`
"$srcpath\XamlViewer_X86.exe.manifest" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\WPF\XamlViewer\XamlViewer_v0300.exe.manifest",`
"$srcpath\ReachFramework_A64.dll" , "$env:Temp\windows\assembly\GAC_MSIL\ReachFramework\3.0.0.0__31bf3856ad364e35\ReachFramework.dll",`
"$srcpath\PresentationNative_X86.dll" , "$env:Temp\windows\syswow64\PresentationNative_v0300.dll",`
"$srcpath\XamlViewer_X86.exe" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\WPF\XamlViewer\XamlViewer_v0300.exe",`
"$srcpath\FL__TransactionBridgePerfCounters_h_133787_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_TransactionBridgePerfCounters.h",`
"$srcpath\FL__TransactionBridgePerfCounters_h_133787_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_TransactionBridgePerfCounters.h",`
"$srcpath\PenIMC_A64.dll" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\WPF\PenIMC.dll",`
"$srcpath\cPerfCnt.ini.246A212A_8E55_48AF_B8DC_0E9A4E0AD039" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Workflow Foundation\PerfCounters.ini",`
"$srcpath\GlobalMonospace.CompositeFont" , "$env:Temp\windows\Fonts\GlobalMonospace.CompositeFont",`
"$srcpath\FL_WsatConfig_exe_148103_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\WsatConfig.exe",`
"$srcpath\FL_WsatConfig_exe_148103_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\WsatConfig.exe",`
"$srcpath\cPerfCnt.reg.246A212A_8E55_48AF_B8DC_0E9A4E0AD039" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Workflow Foundation\PerfCounters.reg",`
"$srcpath\FL__ServiceModelEndpointPerfCounters_h_134738_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_ServiceModelEndpointPerfCounters.h",`
"$srcpath\FL__ServiceModelEndpointPerfCounters_h_134738_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_ServiceModelEndpointPerfCounters.h",`
"$srcpath\XPSViewer_X86.exe.mui" , "$env:Temp\windows\syswow64\XPSViewer\en-us\XPSViewer.exe.mui",`
"$srcpath\PresentationUI_A64.dll" , "$env:Temp\windows\assembly\GAC_MSIL\PresentationUI\3.0.0.0__31bf3856ad364e35\PresentationUI.dll",`
"$srcpath\PresentationUI_A64.dll" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\WPF\PresentationUI.dll",`
"$srcpath\FL_System_ServiceModel_dll_133679_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.ServiceModel\3.0.0.0__b77a5c561934e089\System.ServiceModel.dll",`
"$srcpath\FL_System_ServiceModel_dll_133679_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\System.ServiceModel.dll",`
"$srcpath\FL_System_ServiceModel_dll_133679_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\System.ServiceModel.dll",`
"$srcpath\milcore_X86.dll" , "$env:Temp\windows\syswow64\milcore.dll",`
"$srcpath\UIAutomationClientsideProviders_A64.dll" , "$env:Temp\windows\assembly\GAC_MSIL\UIAutomationClientsideProviders\3.0.0.0__31bf3856ad364e35\UIAutomationClientsideProviders.dll",`
"$srcpath\FL__TransactionBridgePerfCounters_reg_133789_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_TransactionBridgePerfCounters.reg",`
"$srcpath\FL__TransactionBridgePerfCounters_reg_133789_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_TransactionBridgePerfCounters.reg",`
"$srcpath\FL_icardagt_exe_134628_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\syswow64\icardagt.exe",`
"$srcpath\fTrackSchema_EN.246A212B_8E55_48AF_B8DC_0E9A4E0AD039" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Workflow Foundation\SQL\EN\Tracking_Schema.sql",`
"$srcpath\cPerfCnt.vrg.246A212A_8E55_48AF_B8DC_0E9A4E0AD039" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Workflow Foundation\PerfCounters.vrg",`
"$srcpath\FL_ServiceModelEvents_dll_mui_148753_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\ServiceModelEvents.dll.mui",`
"$srcpath\FL_ServiceModelEvents_dll_mui_148753_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\MUI\0409\ServiceModelEvents.dll.mui",`
"$srcpath\FL_System_ServiceModel_WasHosting_dll_134736_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.ServiceModel.WasHosting\3.0.0.0__b77a5c561934e089\System.ServiceModel.WasHosting.dll",`
"$srcpath\FL_System_ServiceModel_WasHosting_dll_134736_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\System.ServiceModel.WasHosting.dll",`
"$srcpath\FL_System_ServiceModel_WasHosting_dll_134736_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\System.ServiceModel.WasHosting.dll",`
"$srcpath\fWEAct.dll.I_IL.2C0646A5_257B_44EA_803B_3C8E81C4F428" , "$env:Temp\windows\assembly\GAC_MSIL\System.Workflow.Activities\3.0.0.0__31bf3856ad364e35\System.Workflow.Activities.dll",`
"$srcpath\FL_icardagt_exe_134628_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\system32\icardagt.exe",`
"$srcpath\UIAutomationTypes_A64.dll" , "$env:Temp\windows\assembly\GAC_MSIL\UIAutomationTypes\3.0.0.0__31bf3856ad364e35\UIAutomationTypes.dll",`
"$srcpath\FL__ServiceModelOperationPerfCounters_ini_134194_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_ServiceModelOperationPerfCounters.ini",`
"$srcpath\FL__ServiceModelOperationPerfCounters_ini_134194_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_ServiceModelOperationPerfCounters.ini",`
"$srcpath\XamlViewer_A64.exe.manifest" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\WPF\XamlViewer\XamlViewer_v0300.exe.manifest",`
"$srcpath\GlobalSansSerif.CompositeFont" , "$env:Temp\windows\Fonts\GlobalSansSerif.CompositeFont",`
"$srcpath\FL__ServiceModelOperationPerfCounters_vrg_134196_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_ServiceModelOperationPerfCounters.vrg",`
"$srcpath\FL__ServiceModelOperationPerfCounters_vrg_134196_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_ServiceModelOperationPerfCounters.vrg",`
"$srcpath\System.Printing_GAC_X86.dll" , "$env:Temp\windows\assembly\GAC_32\System.Printing\3.0.0.0__31bf3856ad364e35\System.Printing.dll",`
"$srcpath\PresentationHostDLL_A64.dll" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\WPF\PresentationHostDLL.dll",`
"$srcpath\FL__SMSvcHostPerfCounters_ini_143455_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_SMSvcHostPerfCounters.ini",`
"$srcpath\FL__SMSvcHostPerfCounters_ini_143455_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_SMSvcHostPerfCounters.ini",`
"$srcpath\fSqlSrvcSch_EN.246A212B_8E55_48AF_B8DC_0E9A4E0AD039" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Workflow Foundation\SQL\EN\SqlPersistenceService_Schema.sql",`
"$srcpath\Speech_A64.dll" , "$env:Temp\windows\assembly\GAC_MSIL\System.Speech\3.0.0.0__31bf3856ad364e35\System.Speech.dll",`
"$srcpath\PresentationCFFRasterizerNative_A64.dll" , "$env:Temp\windows\system32\PresentationCFFRasterizerNative_v0300.dll",`
"$srcpath\WFSet.ico.246A212A_8E55_48AF_B8DC_0E9A4E0AD039" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Workflow Foundation\Setup.ico",`
"$srcpath\FL_ServiceMonikerSupport_dll_133768_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\ServiceMonikerSupport.dll",`
"$srcpath\FL__ServiceModelServicePerfCounters_ini_134741_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_ServiceModelServicePerfCounters.ini",`
"$srcpath\FL__ServiceModelServicePerfCounters_ini_134741_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_ServiceModelServicePerfCounters.ini",`
"$srcpath\FL__ServiceModelOperationPerfCounters_reg_134195_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_ServiceModelOperationPerfCounters.reg",`
"$srcpath\FL__ServiceModelOperationPerfCounters_reg_134195_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_ServiceModelOperationPerfCounters.reg",`
"$srcpath\FL__SMSvcHostPerfCounters_vrg_143458_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_SMSvcHostPerfCounters.vrg",`
"$srcpath\FL__SMSvcHostPerfCounters_vrg_143458_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_SMSvcHostPerfCounters.vrg",`
"$srcpath\FL_ServiceModelEvents_dll_mui_148753_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\ServiceModelEvents.dll.mui",`
"$srcpath\FL_ServiceModelEvents_dll_mui_148753_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\MUI\0409\ServiceModelEvents.dll.mui",`
"$srcpath\PresentationCFFRasterizerNative_X86.dll" , "$env:Temp\windows\syswow64\PresentationCFFRasterizerNative_v0300.dll",`
"$srcpath\UIAutomationCore_A64.dll.mui" , "$env:Temp\windows\system32\en-us\UIAutomationCore.dll.mui",`
"$srcpath\fTracLogic_EN.246A212B_8E55_48AF_B8DC_0E9A4E0AD039" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Workflow Foundation\SQL\EN\Tracking_Logic.sql",`
"$srcpath\FL__ServiceModelEndpointPerfCounters_vrg_134740_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_ServiceModelEndpointPerfCounters.vrg",`
"$srcpath\FL__ServiceModelEndpointPerfCounters_vrg_134740_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_ServiceModelEndpointPerfCounters.vrg",`
"$srcpath\PresentationFontCache_A64.cat" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\WPF\PresentationFontCache.cat",`
"$srcpath\PresentationFontCache_A64.cat" , "$env:Temp\windows\system32\catroot\{f750e6c3-38ee-11d1-85e5-00c04fc295ee}\PresentationFontCache.cat",`
"$srcpath\FL_servicemodel_mof_uninstall_143451_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\ServiceModel.mof.uninstall",`
"$srcpath\FL_servicemodel_mof_uninstall_143451_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\ServiceModel.mof.uninstall",`
"$srcpath\NlsData0009_X86.dll" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\WPF\NlsData0009.dll",`
"$srcpath\PresentationCFFRasterizer_GAC_X86.dll" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\WPF\PresentationCFFRasterizer.dll",`
"$srcpath\FL__TransactionBridgePerfCounters_vrg_133790_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_TransactionBridgePerfCounters.vrg",`
"$srcpath\FL__TransactionBridgePerfCounters_vrg_133790_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_TransactionBridgePerfCounters.vrg",`
"$srcpath\TSWPFWrp_X86.exe" , "$env:Temp\windows\syswow64\tswpfwrp.exe",`
"$srcpath\FL_inforcardapi_dll_134627_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\syswow64\infocardapi.dll",`
"$srcpath\GlobalUserInterface.CompositeFont" , "$env:Temp\windows\Fonts\GlobalUserInterface.CompositeFont",`
"$srcpath\PresentationUI_GAC_X86.dll" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\WPF\PresentationUI.dll",`
"$srcpath\PresentationCore_A64.dll" , "$env:Temp\windows\assembly\GAC_64\PresentationCore\3.0.0.0__31bf3856ad364e35\PresentationCore.dll",`
"$srcpath\XPSViewerManifest_X86.xml" , "$env:Temp\windows\syswow64\XPSViewer\XPSViewerManifest.xml",`
"$srcpath\milcore_A64.dll" , "$env:Temp\windows\system32\milcore.dll",`
"$srcpath\PresentationFontCache_A64.exe" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\WPF\PresentationFontCache.exe",`
"$srcpath\PresentationFramework.Classic_A64.dll" , "$env:Temp\windows\assembly\GAC_MSIL\PresentationFramework.Classic\3.0.0.0__31bf3856ad364e35\PresentationFramework.Classic.dll",`
"$srcpath\FL_ServiceMonikerSupport_dll_133768_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\ServiceMonikerSupport.dll",`
"$srcpath\UIAutomationCore_X86.dll.mui" , "$env:Temp\windows\syswow64\en-us\UIAutomationCore.dll.mui",`
"$srcpath\FL_SMSvcHost_exe_config_143453_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\SMSvcHost.exe.config",`
"$srcpath\FL_SMSvcHost_exe_config_143453_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\SMSvcHost.exe.config",`
"$srcpath\FL_icardres_dll_mui_149310_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\system32\icardres.dll.mui",`
"$srcpath\FL_icardres_dll_mui_149310_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\system32\mui\0409\icardres.dll.mui",`
"$srcpath\FL__ServiceModelServicePerfCounters_reg_134744_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_ServiceModelServicePerfCounters.reg",`
"$srcpath\FL__ServiceModelServicePerfCounters_reg_134744_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_ServiceModelServicePerfCounters.reg",`
"$srcpath\NaturalLanguage6_A64.dll" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\WPF\NaturalLanguage6.dll",`
"$srcpath\FL_ServiceModelEvents_dll_143449_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\ServiceModelEvents.dll",`
"$srcpath\PresentationFramework.Luna_A64.dll" , "$env:Temp\windows\assembly\GAC_MSIL\PresentationFramework.Luna\3.0.0.0__31bf3856ad364e35\PresentationFramework.Luna.dll",`
"$srcpath\System.Printing_A64.dll" , "$env:Temp\windows\assembly\GAC_64\System.Printing\3.0.0.0__31bf3856ad364e35\System.Printing.dll",`
"$srcpath\NaturalLanguage6_X86.dll" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\WPF\NaturalLanguage6.dll",`
"$srcpath\FL_infocard_exe_134626_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\infocard.exe",`
"$srcpath\PresentationCFFRasterizer_A64.dll" , "$env:Temp\windows\assembly\GAC_MSIL\PresentationCFFRasterizer\3.0.0.0__31bf3856ad364e35\PresentationCFFRasterizer.dll",`
"$srcpath\PresentationCFFRasterizer_A64.dll" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\WPF\PresentationCFFRasterizer.dll",`
"$srcpath\FL_System_ServiceModel_Install_dll_133794_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.ServiceModel.Install\3.0.0.0__b77a5c561934e089\System.ServiceModel.Install.dll",`
"$srcpath\FL_System_ServiceModel_Install_dll_133794_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\System.ServiceModel.Install.dll",`
"$srcpath\FL_System_ServiceModel_Install_dll_133794_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\System.ServiceModel.Install.dll",`
"$srcpath\FL__ServiceModelEndpointPerfCounters_reg_134739_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_ServiceModelEndpointPerfCounters.reg",`
"$srcpath\FL__ServiceModelEndpointPerfCounters_reg_134739_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_ServiceModelEndpointPerfCounters.reg",`
"$srcpath\FL_system_identitymodel_selectors_dll_147068_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.IdentityModel.Selectors\3.0.0.0__b77a5c561934e089\System.IdentityModel.Selectors.dll",`
"$srcpath\cPerfCnt.exe.246A212A_8E55_48AF_B8DC_0E9A4E0AD039" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Workflow Foundation\PerformanceCounterInstaller.exe",`
"$srcpath\PresentationCore_GAC_X86.dll" , "$env:Temp\windows\assembly\GAC_32\PresentationCore\3.0.0.0__31bf3856ad364e35\PresentationCore.dll",`
"$srcpath\FL__ServiceModelOperationPerfCounters_h_134193_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_ServiceModelOperationPerfCounters.h",`
"$srcpath\FL__ServiceModelOperationPerfCounters_h_134193_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_ServiceModelOperationPerfCounters.h",`
"$srcpath\fCompdll.I_IL.2C0646A5_257B_44EA_803B_3C8E81C4F428" , "$env:Temp\windows\assembly\GAC_MSIL\System.Workflow.ComponentModel\3.0.0.0__31bf3856ad364e35\System.Workflow.ComponentModel.dll",`
"$srcpath\XamlViewer_A64.exe" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\WPF\XamlViewer\XamlViewer_v0300.exe",`
"$srcpath\FL_ServiceModelReg_exe_143454_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\ServiceModelReg.exe",`
"$srcpath\FL_ServiceModelReg_exe_143454_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\ServiceModelReg.exe",`
"$srcpath\PresentationFramework.Aero_A64.dll" , "$env:Temp\windows\assembly\GAC_MSIL\PresentationFramework.Aero\3.0.0.0__31bf3856ad364e35\PresentationFramework.Aero.dll",`
"$srcpath\NlsLexicons0009_X86.dll" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\WPF\NlsLexicons0009.dll",`
"$srcpath\fWEExec.dll.I_IL.2C0646A5_257B_44EA_803B_3C8E81C4F428" , "$env:Temp\windows\assembly\GAC_MSIL\System.Workflow.Runtime\3.0.0.0__31bf3856ad364e35\System.Workflow.Runtime.dll",`
"$srcpath\XamlViewer_A64.xbap" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\WPF\XamlViewer\XamlViewer_v0300.xbap",`
"$srcpath\PresentationBuildTasks_A64.dll" , "$env:Temp\windows\assembly\GAC_MSIL\PresentationBuildTasks\3.0.0.0__31bf3856ad364e35\PresentationBuildTasks.dll",`
"$srcpath\FL__TransactionBridgePerfCounters_ini_133788_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_TransactionBridgePerfCounters.ini",`
"$srcpath\FL__TransactionBridgePerfCounters_ini_133788_ENU_A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_TransactionBridgePerfCounters.ini",`
"$srcpath\FL_SMSvcHost_exe_143452_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\SMSvcHost.exe",`
"$srcpath\FL_SMSvcHost_exe_143452_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\SMSvcHost.exe",`
"$srcpath\FL_SMDiagnostics_dll_147054_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\SMDiagnostics\3.0.0.0__b77a5c561934e089\SMdiagnostics.dll",`
"$srcpath\FL_SMDiagnostics_dll_147054_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\SMDiagnostics.dll",`
"$srcpath\FL_SMDiagnostics_dll_147054_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\SMDiagnostics.dll",`
"$srcpath\FL_ComSvcConfig_exe_133774_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\ComSvcConfig.exe",`
"$srcpath\FL_ComSvcConfig_exe_133774_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\ComSvcConfig.exe",`
"$srcpath\FL__ServiceModelServicePerfCounters_vrg_134743_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_ServiceModelServicePerfCounters.vrg",`
"$srcpath\FL__ServiceModelServicePerfCounters_vrg_134743_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_ServiceModelServicePerfCounters.vrg",`
"$srcpath\FL_icardres_dll_142943_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\system32\icardres.dll",`
"$srcpath\FL_infocard_exe_134626_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\infocard.exe",`
"$srcpath\PresentationFramework_A64.dll" , "$env:Temp\windows\assembly\GAC_MSIL\PresentationFramework\3.0.0.0__31bf3856ad364e35\PresentationFramework.dll",`
"$srcpath\PresentationHostDLL_X86.dll" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\WPF\PresentationHostDLL.dll",`
"$srcpath\WindowsFormsIntegration_A64.dll" , "$env:Temp\windows\assembly\GAC_MSIL\WindowsFormsIntegration\3.0.0.0__31bf3856ad364e35\WindowsFormsIntegration.dll",`
"$srcpath\GlobalSerif.CompositeFont" , "$env:Temp\windows\Fonts\GlobalSerif.CompositeFont",`
"$srcpath\PresentationFramework.Royale_A64.dll" , "$env:Temp\windows\assembly\GAC_MSIL\PresentationFramework.Royale\3.0.0.0__31bf3856ad364e35\PresentationFramework.Royale.dll",`
"$srcpath\FL_inforcardapi_dll_134627_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\system32\infocardapi.dll",`
"$srcpath\FL_System_IO_Log_dll_133671_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.IO.Log\3.0.0.0__b03f5f7f11d50a3a\System.IO.Log.dll",`
"$srcpath\FL__SMSvcHostPerfCounters_h_143456_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_SMSvcHostPerfCounters.h",`
"$srcpath\FL__SMSvcHostPerfCounters_h_143456_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_SMSvcHostPerfCounters.h",`
"$srcpath\NlsLexicons0009_A64.dll" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\WPF\NlsLexicons0009.dll",`
"$srcpath\FL__SMSvcHostPerfCounters_reg_143457_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_SMSvcHostPerfCounters.reg",`
"$srcpath\FL__SMSvcHostPerfCounters_reg_143457_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_SMSvcHostPerfCounters.reg",`
"$srcpath\fSqlPersSLgic_EN.246A212B_8E55_48AF_B8DC_0E9A4E0AD039" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Workflow Foundation\SQL\EN\SqlPersistenceService_Logic.sql",`
"$srcpath\FL_icardres_dll_mui_149310_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\syswow64\icardres.dll.mui",`
"$srcpath\FL_icardres_dll_mui_149310_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\syswow64\mui\0409\icardres.dll.mui",`
"$srcpath\FL_infocardcpl_cpl_134629_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\system32\infocardcpl.cpl",`
"$srcpath\FL_system_identitymodel_dll_147070_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.IdentityModel\3.0.0.0__b77a5c561934e089\System.IdentityModel.dll",`
"$srcpath\FL_Microsoft_Transactions_Bridge_dll_133653_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\Microsoft.Transactions.Bridge\3.0.0.0__b03f5f7f11d50a3a\Microsoft.Transactions.Bridge.dll",`
"$srcpath\FL_Microsoft_Transactions_Bridge_dll_133653_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\Microsoft.Transactions.Bridge.dll",`
"$srcpath\FL_Microsoft_Transactions_Bridge_dll_133653_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\Microsoft.Transactions.Bridge.dll",`
"$srcpath\FL_Microsoft_Transactions_Bridge_DTC_dll_133669_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_32\Microsoft.Transactions.Bridge.Dtc\3.0.0.0__b03f5f7f11d50a3a\Microsoft.Transactions.Bridge.Dtc.dll",`
"$srcpath\FL_Microsoft_Transactions_Bridge_DTC_dll_133669_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\Microsoft.Transactions.Bridge.Dtc.dll",`
"$srcpath\UIAutomationProvider_A64.dll" , "$env:Temp\windows\assembly\GAC_MSIL\UIAutomationProvider\3.0.0.0__31bf3856ad364e35\UIAutomationProvider.dll",`
"$srcpath\Microsoft.WinFX_A64.targets" , "$env:Temp\windows\Microsoft.NET\Framework\v2.0.50727\Microsoft.WinFX.targets",`
"$srcpath\Microsoft.WinFX_A64.targets" , "$env:Temp\windows\Microsoft.NET\Framework64\v2.0.50727\Microsoft.WinFX.targets",`
"$srcpath\TSWPFWrp_A64.exe" , "$env:Temp\windows\system32\tswpfwrp.exe",`
"$srcpath\cPerfCnt.h.246A212A_8E55_48AF_B8DC_0E9A4E0AD039" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Workflow Foundation\PerfCounters.h",`
"$srcpath\XPSViewer_X86.exe" , "$env:Temp\windows\syswow64\XPSViewer\XPSViewer.exe",`
"$srcpath\filler" , "$env:Temp\windows\assembly\NativeImages_v2.0.50727_32\index24.dat",`
"$srcpath\filler" , "$env:Temp\windows\assembly\NativeImages_v2.0.50727_32\index25.dat",`
"$srcpath\filler" , "$env:Temp\windows\assembly\NativeImages_v2.0.50727_64\index31.dat",`
"$srcpath\filler" , "$env:Temp\windows\Installer\wix{F5B09CFD-F0B2-36AF-8DF4-1DF6B63FC7B4}.SchedServiceConfig.rmi",`
"$srcpath\FL_servicemodel_mof_143450_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\ServiceModel.mof",`
"$srcpath\FL_servicemodel_mof_143450_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\ServiceModel.mof",`
"$srcpath\FL_ServiceModelEvents_dll_143449_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\ServiceModelEvents.dll",`
"$srcpath\FL_System_Runtime_Serialization_dll_133675_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_MSIL\System.Runtime.Serialization\3.0.0.0__b77a5c561934e089\System.Runtime.Serialization.dll",`
"$srcpath\FL_System_Runtime_Serialization_dll_133675_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\System.Runtime.Serialization.dll",`
"$srcpath\FL_System_Runtime_Serialization_dll_133675_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\System.Runtime.Serialization.dll",`
"$srcpath\PresentationHostDLL_A64.dll.mui" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\WPF\en-us\PresentationHostDLL.dll.mui",`
"$srcpath\FL_Microsoft_Transactions_Bridge_DTC_dll_133669_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\assembly\GAC_64\Microsoft.Transactions.Bridge.Dtc\3.0.0.0__b03f5f7f11d50a3a\Microsoft.Transactions.Bridge.Dtc.dll",`
"$srcpath\FL_Microsoft_Transactions_Bridge_DTC_dll_133669_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\Microsoft.Transactions.Bridge.Dtc.dll",`
"$srcpath\PresentationNative_A64.dll" , "$env:Temp\windows\system32\PresentationNative_v0300.dll",`
"$srcpath\FL__ServiceModelServicePerfCounters_h_134742_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\_ServiceModelServicePerfCounters.h",`
"$srcpath\FL__ServiceModelServicePerfCounters_h_134742_____A64.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\_ServiceModelServicePerfCounters.h",`
"$srcpath\FL_icardres_dll_142943_____X86.3643236F_FC70_11D3_A536_0090278A1BB8" , "$env:Temp\windows\syswow64\icardres.dll"

for ( $j = 0; $j -lt $dotnet30.count; $j+=2 ) {
    Copy-Item -recurse -Path $dotnet30[$j] -Destination ( Join-Path (New-item -Type Directory -Force $(Split-Path -Path $dotnet30[$j+1]))   $(Split-Path -Leaf $dotnet30[$j+1])   ) -Force  -Verbose }

7z a -r -t7z -m0=lzma2 -mx=9 -mfb=273 -md=29 -ms=8g -mmt=off -mmtf=off -mqs=on -bt -bb3 "$cachedir\$(verb)\$(verb).7z" "$env:TEMP\windows"

Remove-Item -Force -Recurse  "$env:TEMP\windows"
Remove-Item -Force -Recurse  "$env:TEMP\dotnet35"
Remove-Item -Force "$env:TEMP\dotnetfx35.exe"
}

7z x "$cachedir\$(verb)\$(verb).7z" -o"$env:SystemDrive" -y

$regkey = @"
REGEDIT4
[HKEY_LOCAL_MACHINE\Software\Microsoft\.NETFramework]
"OnlyUseLatestCLR"=dword:00000000
"@

    reg_edit $regkey

    foreach ($i in 'mscorwks') { dlloverride 'native' $i }
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
                   else { 'if(!(Test-Path ''' + $path + ''' )) {New-Item -Path ''' + $path +''' -Force};' + 'New-ItemProperty -Path ''' + $path +''' -Name ''' + $Regname + ''' -Value ''' + $value.Value +''' -PropertyType '''+ $propertyType + ''' -Force' |out-file "$env:TEMP\reg_keys.ps1" -append } #-Verbose
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
            $finalpath = "$env:systemroot\Microsoft.NET\assembly\GAC_64";if($prefix) {$finalpath = join-path $prefix $finalpath};                if (-not (Test-Path -Path $finalpath )) { New-Item -Path $finalpath -ItemType directory -Force }######
            if($file) {Copy-Item -Path $file -Destination $finalpath -Force  -verbose} # -ErrorAction SilentlyContinue 
        }
        elseif ( $Xml.assembly.assemblyIdentity.processorArchitecture -eq 'x86' -and -not $file_names.destinationpath) { # no destinationpath, put it in GAC_64
            $finalpath = "$env:systemroot\Microsoft.NET\assembly\GAC_32";if($prefix) {$finalpath = join-path $prefix $finalpath};                if (-not (Test-Path -Path $finalpath )) { New-Item -Path $finalpath -ItemType directory -Force }
######
            if($file) {Copy-Item -Path $file -Destination $finalpath -Force  -verbose } #-ErrorAction SilentlyContinue 
        }
        else { if($file) { Write-Host -foregroundcolor yellow "***  No way found to install the file, copy it manually from location $file  ***" } else {Write-Host $null}<#FIXME#>}
} <# end function install_from_manifest #>

function func_dotnet481
{
    if (![System.IO.File]::Exists(  [IO.Path]::Combine($cachedir,  $(verb),  "$(verb).7z" ) ) ){

    w_download_to $(verb) "https://download.visualstudio.microsoft.com/download/pr/6f083c7e-bd40-44d4-9e3f-ffba71ec8b09/3951fd5af6098f2c7e8ff5c331a0679c/ndp481-x86-x64-allos-enu.exe" "ndp481-x86-x64-allos-enu.exe" 
    7z x $cachedir\\$(verb)\\ndp481-x86-x64-allos-enu.exe "-o$env:TEMP\\$(verb)\\" "x64-Windows10.0-KB5011048-x64.cab" -y; quit?(7z)
    7z x $env:TEMP\\$(verb)\\x64-Windows10.0-KB5011048-x64.cab "-o$env:TEMP\\$(verb)\\" "amd64*/*" "x86*/*" "wow64*/*" "*.manifest" -y; quit?(7z)

    Stop-Process -Name mscorsvw -ErrorAction SilentlyContinue <# otherwise some dlls fail to be replaced as they are in use by mscorvw; only mscoreei.dll has to be copied manually afaict as it is in use by pwsh #>

    Write-Host -foregroundColor yellow 'Starting copying files , this takes a while (> 3 minutes), patience...'    
    foreach ($i in $(Get-ChildItem $env:TEMP\\dotnet481\\*.manifest).FullName) { install_from_manifest -manifestfile $i -prefix "$env:TEMP"  }

    foreach ($i in $(Get-ChildItem $env:TEMP\\dotnet481\\*.manifest).FullName ) { write_keys_from_manifest $i -to_file }
    Write-Host -foregroundColor yellow 'Done , hopefully nothing''s screwed up ;)' 

    Remove-Item -Force -Recurse "$env:TEMP\\dotnet481"

    Push-Location ; Set-Location $env:TEMP 
    7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on  "$cachedir\$(verb)\$(verb).7z" ".\c:\"
    Pop-Location
    
    7z a -spf -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on  "$cachedir\$(verb)\$(verb).7z" "$env:TEMP\reg_keys.ps1"  
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
  
    Write-HOST SGAHSJGGGGGGGGGGGGGGGGGGGGGH
    7z x -spf "$cachedir\$(verb)\$(verb).7z" -aoa 
    $null =  . "$env:TEMP\reg_keys.ps1"

    
    <# FIXME:  mscoreei.dll is not installed as it is in use by pwsh.exe #>
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
foreach($i in 'wldp') { dlloverride 'disabled' $i }
winecfg /v win7
choco install webview2-runtime
foreach($i in 'wldp') { dlloverride 'builtin' $i }
}

function func_mspaint
{
choco install wget

wget.exe -P "$env:TEMP\"  --referer 'https://win7games.com/' 'https://win7games.com/download/ClassicPaint.zip'

7z x "$env:TEMP\ClassicPaint.zip" "-o$env:TEMP"

& "$env:TEMP\ClassicPaint-1.1-setup.exe " /silent

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
{
    func_wine_combase
    func_wine_windows.ui
    func_wine_wintypes
    func_winmetadata
    func_dotnet481
}

function func_chocolatey_upgrade
{
    func_ps51
    choco pin remove -n chocolatey
    choco.exe feature enable --name=powershellHost
    choco upgrade chocolatey    
}

<# Main function #> 
if ( $args[0] -eq "no_args") {
    $custom_array = @()
    for ( $j = 1; $j -lt $args.count; $j+=2 ) { $custom_array += [PSCustomObject]@{ name = $args[$j]; Description = $args[$j+1] } } 
    $args =  $($custom_array  | select name,description | Out-GridView  -PassThru  -Title 'Make a  selection').name
}
foreach ($i in $args) { & $('func_' + $i); }
