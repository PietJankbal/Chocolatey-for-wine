$cachedir = ("$env:WINEHOMEDIR" + "\.cache\winetrickxs").substring(4)

if (!(Test-Path -Path "$env:ProgramW6432\7-Zip\7z.exe" -PathType Leaf)) {
    choco install 7zip -y
}

function validate_param
{
[CmdletBinding()]
 Param(
        [Parameter(Mandatory=$false)]
        [ValidateSet('msxml3', 'msxml6','gdiplus', 'robocopy', 'msado15')]
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
	       "msado15","some minimal mdac dlls"

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

if ( -not(Test-Path $cachedir\\$dldir\\WinPE.cab -PathType Leaf) ){
    Start-Process <#-Windowstyle hidden#> 7z -Wait -ArgumentList "x",$cachedir\\$dldir\\$cab,"-o$cachedir\\$dldir","-y"; quit?('7z')
   } 

if ( -not(Test-Path $cachedir\\$dldir\\F1_WINPE.WIM -PathType Leaf) ){ #fragile test...
    Start-Process <#-Windowstyle hidden#> 7z -Wait -ArgumentList "x",$cachedir\\$dldir\\WinPE.cab,"-o$cachedir\\$dldir","-y"; quit?('7z')
   }


if ( -not(Test-Path $cachedir\\$dldir\\F_WINPEOC_AMD64__WINPE_WINPE_MDAC.CAB -PathType Leaf) ){ #fragile test...
    Start-Process <#-Windowstyle hidden#> 7z -Wait -ArgumentList "x",$cachedir\\$dldir\\Neutral.cab,"-o$cachedir\\$dldir\\","-y"; quit?('7z')
   }

}

function func_msxml3
{
    validate_cab_existence
    $dlls = @('msxml3.dll','msxml3r.dll'); $dldir = "aik70"

    foreach ($i in $dlls) {
        Start-Process <#-Windowstyle hidden#> 7z  -ArgumentList "e",$cachedir\\$dldir\\F3_WINPE.WIM,"-o$env:systemroot\\system32",Windows/System32/$i,"-y"
        Start-Process <#-Windowstyle hidden#> 7z  -ArgumentList "e",$cachedir\\$dldir\\F1_WINPE.WIM,"-o$env:systemroot\\syswow64",Windows/System32/$i,"-y"
    }
    Get-Process 7z -ErrorAction:SilentlyContinue | Foreach-Object { $_.WaitForExit() }
   New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'msxml3' -Value 'native' -PropertyType 'String'
}

function func_msxml6
{
    validate_cab_existence
    $dlls = @('msxml6.dll', 'msxml6r.dll'); $dldir = "aik70"

    foreach ($i in $dlls) {
        Start-Process <#-Windowstyle hidden#> 7z  -ArgumentList "e",$cachedir\\$dldir\\F3_WINPE.WIM,"-o$env:systemroot\\system32",Windows/System32/$i,"-y"
        Start-Process <#-Windowstyle hidden#> 7z  -ArgumentList "e",$cachedir\\$dldir\\F1_WINPE.WIM,"-o$env:systemroot\\syswow64",Windows/System32/$i,"-y"
    }
    Get-Process 7z -ErrorAction:SilentlyContinue | Foreach-Object { $_.WaitForExit() }
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'msxml6' -Value 'native' -PropertyType 'String'
}

function func_robocopy
{
    validate_cab_existence
    $dlls = @('robocopy.exe', 'mfc42.dll', 'mfc42u.dll'); $dldir = "aik70"

    foreach ($i in $dlls) {
        Start-Process <#-Windowstyle hidden#> 7z  -ArgumentList "e",$cachedir\\$dldir\\F3_WINPE.WIM,"-o$env:systemroot\\system32",Windows/System32/$i,"-y"
        Start-Process <#-Windowstyle hidden#> 7z  -ArgumentList "e",$cachedir\\$dldir\\F1_WINPE.WIM,"-o$env:systemroot\\syswow64",Windows/System32/$i,"-y"
    }
    Get-Process 7z -ErrorAction:SilentlyContinue | Foreach-Object { $_.WaitForExit() }
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'robocopy.exe' -Value 'native' -PropertyType 'String'
}

function func_gdiplus
{
    validate_cab_existence; $dldir = "aik70"
    $sxsdlls = @( 'amd64_microsoft.windows.gdiplus_6595b64144ccf1df_1.0.7600.16385_none_3bfdd703d890231d/gdiplus.dll', `
                  'x86_microsoft.windows.gdiplus_6595b64144ccf1df_1.0.7600.16385_none_83ab0ddaed0c4c23/gdiplus.dll' )
		  
    foreach ($i in $sxsdlls) {
        switch ( $i.SubString(0,3) ) {
            'amd'    {Start-Process <#-Windowstyle hidden#> 7z  -ArgumentList "e",$cachedir\\$dldir\\F3_WINPE.WIM,"-o$env:systemroot\\system32",Windows/winsxs/$i,"-y"}
            'x86'    {Start-Process <#-Windowstyle hidden#> 7z  -ArgumentList "e",$cachedir\\$dldir\\F1_WINPE.WIM,"-o$env:systemroot\\syswow64",Windows/winsxs/$i,"-y"}
        }
    }
    Get-Process 7z -ErrorAction:SilentlyContinue | Foreach-Object { $_.WaitForExit() }
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'gdiplus' -Value 'native' -PropertyType 'String'
}

function func_msado15
{
    validate_cab_existence; $dldir = "aik70"

    $adodlls = @( 'amd64_microsoft-windows-m..ents-mdac-ado15-dll_31bf3856ad364e35_6.1.7600.16385_none_6825d42d8a57b77d/msado15.dll', `
                  'x86_microsoft-windows-m..ents-mdac-ado15-dll_31bf3856ad364e35_6.1.7600.16385_none_0c0738a9d1fa4647/msado15.dll' )

    foreach ($i in $adodlls) {
        switch ( $i.SubString(0,3) ) { 
            'amd'    {Start-Process 7z -ArgumentList "e $cachedir\\$dldir\\F_WINPEOC_AMD64__WINPE_WINPE_MDAC.CAB `"-o$env:CommonProgramFiles\\System\\ADO`" $i -y"}
            'x86'    {Start-Process 7z  -ArgumentList "e $cachedir\\$dldir\\F_WINPEOC_X86__WINPE_WINPE_MDAC.CAB `"-o${env:CommonProgramFiles`(x86`)}\\System\\ADO`" $i -y"}
        }
    } quit?('7z')

    $dlls = @( 'amd64_microsoft-windows-m..ponents-mdac-msdart_31bf3856ad364e35_6.1.7600.16385_none_42074b3f2553d5bd/msdart.dll', `
               'x86_microsoft-windows-m..ponents-mdac-msdart_31bf3856ad364e35_6.1.7600.16385_none_e5e8afbb6cf66487/msdart.dll' )
		 
    foreach ($i in $dlls) {
        switch ( $i.SubString(0,3) ) {
            'amd'    {Start-Process 7z  -ArgumentList "e",$cachedir\\$dldir\\F_WINPEOC_AMD64__WINPE_WINPE_MDAC.CAB,"-o$env:systemroot\\system32",$i,"-y"}
            'x86'    {Start-Process  7z  -ArgumentList "e",$cachedir\\$dldir\\F_WINPEOC_X86__WINPE_WINPE_MDAC.CAB,"-o$env:systemroot\\syswow64",$i,"-y"}
        }
    } quit?('7z')

    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'msado15' -Value 'native' -PropertyType 'String'

    & "$env:systemroot\\system32\\regsvr32" "$env:CommonProgramFiles\\System\\ADO\\msado15.dll"
    & "$env:systemroot\\syswow64\\regsvr32"  "${env:CommonProgramFiles`(x86`)}\\System\\ADO\\msado15.dll"
}

# Main
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
