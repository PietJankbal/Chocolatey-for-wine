    [System.IO.Directory]::SetCurrentDirectory("$env:TEMP")
    #$wc=new-object system.net.webclient
    #$wc.UseDefaultCredentials = $true
    #$wc.downloadfile("your_url","your_file")
    (New-Object System.Net.WebClient).DownloadFile("https://www.7-zip.org/a/7z1900-x64.exe", "$env:TEMP\\7z1900-x64.exe")
    (New-Object System.Net.WebClient).DownloadFile("http://download.windowsupdate.com/msdownload/update/software/updt/2009/11/windowsserver2003-kb968930-x64-eng_8ba702aa016e4c5aed581814647f4d55635eff5c.exe", "$env:TEMP\\windowsserver2003-kb968930-x64-eng_8ba702aa016e4c5aed581814647f4d55635eff5c.exe")
    (New-Object System.Net.WebClient).DownloadFile("https://download.microsoft.com/download/9/5/A/95A9616B-7A37-4AF6-BC36-D6EA96C8DAAE/dotNetFx40_Full_x86_x64.exe", "$env:TEMP\\dotNetFx40_Full_x86_x64.exe")
    (New-Object System.Net.WebClient).DownloadFile("https://download.visualstudio.microsoft.com/download/pr/7afca223-55d2-470a-8edc-6a1739ae3252/abd170b4b0ec15ad0222a809b761a036/ndp48-x86-x64-allos-enu.exe", "$env:TEMP\\ndp48-x86-x64-allos-enu.exe")

    Start-Process -FilePath 7z1900-x64.exe -Wait -ArgumentList "/S"

    #/* remove_mono */

#FIXME!! Needs to be updated when Mono updates; Find better solution...........
$f = uninstaller --list  | Select-String 'Mono'
$g = $f -split "\|" |Select-string "{"
Uninstaller --remove $g[0]
Uninstaller --remove $g[1]

   # Start-Process uninstaller -Wait -ArgumentList  "--remove", "{0A7C8977-1185-5C3F-A4E7-7A90611227C3}"
   # Start-Process uninstaller -Wait -ArgumentList "--remove", "{05C9CD26-9144-58FC-8A6E-B4DE47B661EC}"
     Get-Process uninstaller | Foreach-Object { $_.WaitForExit() }

   # Remove-Item -Path 'HKLM:\\Software\\Microsoft\\NET Framework Setup\\NDP\\v3.5' -Recurse
  #  Remove-Item -Path 'HKLM:\\Software\\Microsoft\\NET Framework Setup\\NDP\\v4'  -Recurse  

  #  Remove-Item -Path 'HKLM:\\Software\\Wow6432Node\\Microsoft\\NET Framework Setup\\NDP\\v3.5' -Recurse
  #  Remove-Item -Path 'HKLM:\\Software\\Wow6432Node\\Microsoft\\NET Framework Setup\\NDP\\v4'  -Recurse  

    Remove-Item -Path "$env:SystemRoot\\SysWOW64\\mscoree.dll" -Force
    Remove-Item -Path "$env:SystemRoot\\System32\\mscoree.dll" -Force
    #/* END remove_mono */
    
    

#if(Test-Path 'env:ROTZOOI'){

    Copy-Item -Path "$env:windir\\SysWOW64\\WindowsPowerShell\\v1.0\\powershell.exe" -Destination "$env:windir\\SysWOW64\\WindowsPowerShell\\v1.0\\powershell_orig.exe"
    Copy-Item -Path "$env:winsysdir\\WindowsPowerShell\\v1.0\\powershell.exe" -Destination "$env:winsysdir\\WindowsPowerShell\\v1.0\\powershell_orig.exe"

    Start-Process  "winecfg.exe" -Wait -ArgumentList "/v win2003"

    Start-Process  "windowsserver2003-kb968930-x64-eng_8ba702aa016e4c5aed581814647f4d55635eff5c.exe" -Wait -ArgumentList "/q /passive /nobackup"
    $w2003id = (Get-Process windowsserver2003-kb968930-x64-eng_8ba702aa016e4c5aed581814647f4d55635eff5c).id; Wait-Process -Id $w2003id
    Start-Process  "winecfg.exe" -Wait -ArgumentList "/v win7"
    $winecfgid = (Get-Process winecfg).id; Wait-Process -Id $winecfgid


 

    Start-Process -FilePath ${env:ProgramFiles}\\7-zip\\7z.exe -Wait -ArgumentList  "x windowsserver2003-kb968930-x64-eng_8ba702aa016e4c5aed581814647f4d55635eff5c.exe wow64/powershell.exe"
    Start-Process -FilePath ${env:ProgramFiles}\\7-zip\\7z.exe -Wait -ArgumentList "x windowsserver2003-kb968930-x64-eng_8ba702aa016e4c5aed581814647f4d55635eff5c.exe powershell.exe"

    Copy-Item -Path "$env:windir\\SysWOW64\\WindowsPowerShell\\v1.0\\powershell.exe" -Destination "$env:windir\\SysWOW64\\WindowsPowerShell\\v1.0\\powershell20.exe"
    Copy-Item -Path "$env:winsysdir\\WindowsPowerShell\\v1.0\\powershell.exe" -Destination "$env:winsysdir\\WindowsPowerShell\\v1.0\\powershell20.exe"

    Copy-Item -Path "$env:windir\\SysWOW64\\WindowsPowerShell\\v1.0\\powershell_orig.exe" -Destination "$env:windir\\SysWOW64\\WindowsPowerShell\\v1.0\\powershell.exe"
    Copy-Item -Path "$env:winsysdir\\WindowsPowerShell\\v1.0\\powershell_orig.exe" -Destination "$env:winsysdir\\WindowsPowerShell\\v1.0\\powershell.exe"




function set_HKLM_SM_key()
{
 Param ($path, $name, $val, $prop) 
 $HKLM_SM = 'HKLM:\\Software\\Microsoft\\'
  $HKLM_SM_WOW = 'HKLM:\\Software\\Wow6432Node\\Microsoft\\'
 New-ItemProperty -Path "$(Join-Path $HKLM_SM $path)" -Name  $name -Value $val -PropertyType $prop
   $newpath = "$(Join-Path $HKLM_SM_WOW $path)" -replace 'system32','syswow64'
 New-ItemProperty -Path "$newpath" -Name  $name -Value $val -PropertyType $prop
}


function new_HKLM_SM_key()
{
 Param ($path) 
 $HKLM_SM = 'HKLM:\\Software\\Microsoft\\'
  $HKLM_SM_WOW = 'HKLM:\\Software\\Wow6432Node\\Microsoft\\'
  $newpath = "$(Join-Path $HKLM_SM_WOW $path)" -replace 'system32','syswow64'
 New-Item -Path "$newpath" 
 #New-Item -Path "$(Join-Path $HKLM_SM_WOW $path) -replace 'system32','syswow64'"
}

    #Try fix wrong registrykeys due to bug https://bugs.winehq.org/show_bug.cgi?id=25740
    New-ItemProperty -Path 'HKLM:\\Software\\Classes\\Microsoft.PowerShellConsole.1\\shell\\open\\command' -force -Name '(Default)' -Value   'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\powershell.exe -p %1 '  -PropertyType 'String' 
    New-ItemProperty -Path 'HKLM:\\Software\\Classes\\Microsoft.PowerShellConsole.1\\shell\\Run as 32\\command' -force -Name '(Default)' -Value   'c:\\windows\\sysWOW64\\WindowsPowerShell\\v1.0\\powershell.exe -p %1 '  -PropertyType 'String' 
    New-ItemProperty -Path 'HKLM:\\Software\\Classes\\Microsoft.PowerShellData.1\\shell\\Edit\\command' -force -Name '(Default)' -Value   'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\powershell_ise.exe %1 '  -PropertyType 'String' 
    New-ItemProperty -Path 'HKLM:\\Software\\Classes\\Microsoft.PowerShellData.1\\shell\\Open\\command' -force -Name '(Default)' -Value   'c:\\windows\\system32\\notepad.exe %1 '  -PropertyType 'String' 
    New-ItemProperty -Path 'HKLM:\\Software\\Classes\\Microsoft.PowerShellModule.1\\shell\\Edit\\command' -force -Name '(Default)' -Value   'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\powershell_ise.exe %1 '  -PropertyType 'String' 
    New-ItemProperty -Path 'HKLM:\\Software\\Classes\\Microsoft.PowerShellModule.1\\shell\\Open\\command' -force -Name '(Default)' -Value   'c:\\windows\\system32\\notepad.exe %1 '  -PropertyType 'String' 
    New-ItemProperty -Path 'HKLM:\\Software\\Classes\\Microsoft.PowerShellScript.1\\DefaultIcon' -force -Name '(Default)' -Value   'c:\\windows\\system32\\WindowsPowerShell\\V1.0\\powershell_ise.exe,1'  -PropertyType 'String' 
    New-ItemProperty -Path 'HKLM:\\Software\\Classes\\Microsoft.PowerShellScript.1\\shell\\Edit\\command' -force -Name '(Default)' -Value   'c:\\windows\\system32\\WindowsPowerShell\\V1.0\\powershell_ise.exe %1 '  -PropertyType 'String' 
    New-ItemProperty -Path 'HKLM:\\Software\\Classes\\Microsoft.PowerShellScript.1\\shell\\Open\\command' -force -Name '(Default)' -Value   'c:\\windows\\system32\\notepad.exe %1 '  -PropertyType 'String' 
    New-ItemProperty -Path 'HKLM:\\Software\\Classes\\Microsoft.PowerShellScript.1\\shell\\Run with PowerShell\\command' -Name '(Default)' -force -Value   'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\powershell.exe -file %1 '  -PropertyType 'String' 
    New-ItemProperty -Path 'HKLM:\\Software\\Classes\\VBSFile\\Shell\\Edit\\Command' -force -Name '(Default)' -Value   'c:\\windows\\system32\\notepad.exe %1'  -PropertyType 'String' 
    New-ItemProperty -Path 'HKLM:\\Software\\Classes\\VBSFile\\Shell\\Open\\Command' -force -Name '(Default)' -Value   'c:\\windows\\system32\\wscript.exe %1 %*'  -PropertyType 'String' 
    New-ItemProperty -Path 'HKLM:\\Software\\Classes\\VBSFile\\Shell\\Open2\\Command' -force -Name '(Default)' -Value   'c:\\windows\\system32\\cscript.exe %1 %*'  -PropertyType 'String' 
    New-ItemProperty -Path 'HKLM:\\Software\\Classes\\VBSFile\\Shell\\Print\\Command' -force -Name '(Default)' -Value   'c:\\windows\\system32\\notepad.exe /p %1'  -PropertyType 'String' 

    set_HKLM_SM_key 'Cryptography\\OID\\EncodingType 0\\CryptSIPDllCreateIndirectData\\{603BCC1F-4B59-4E08-B724-D2C6297EF351}' -force -Name 'Dll'         -Value 'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\pwrshsip.dll'  -PropertyType 'String' 
    set_HKLM_SM_key 'Cryptography\\OID\\EncodingType 0\\CryptSIPDllGetSignedDataMsg\\{603BCC1F-4B59-4E08-B724-D2C6297EF351}' -force -Name 'Dll'         -Value 'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\pwrshsip.dll'  -PropertyType 'String' 
    set_HKLM_SM_key 'Cryptography\\OID\\EncodingType 0\\CryptSIPDllIsMyFileType2\\{603BCC1F-4B59-4E08-B724-D2C6297EF351}' -force -Name 'Dll'         -Value 'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\pwrshsip.dll'  -PropertyType 'String' 
    set_HKLM_SM_key 'Cryptography\\OID\\EncodingType 0\\CryptSIPDllPutSignedDataMsg\\{603BCC1F-4B59-4E08-B724-D2C6297EF351}' -force -Name 'Dll'         -Value 'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\pwrshsip.dll'  -PropertyType 'String' 
    set_HKLM_SM_key 'Cryptography\\OID\\EncodingType 0\\CryptSIPDllRemoveSignedDataMsg\\{603BCC1F-4B59-4E08-B724-D2C6297EF351}' -force -Name 'Dll'        -Value 'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\pwrshsip.dll'  -PropertyType 'String' 
    set_HKLM_SM_key 'Cryptography\\OID\\EncodingType 0\\CryptSIPDllVerifyIndirectData\\{603BCC1F-4B59-4E08-B724-D2C6297EF351}' -force -Name 'Dll'         -Value 'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\pwrshsip.dll'  -PropertyType 'String' 
    set_HKLM_SM_key 'PowerShell\\1\\PowerShellEngine' -force -Name 'ApplicationBase'        -Value 'c:\\windows\\system32\\WindowsPowerShell\\v1.0'  -PropertyType 'String' 
    set_HKLM_SM_key 'PowerShell\\1\\PowerShellEngine' -force -Name 'ConsoleHostModuleName'  -Value 'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\Microsoft.PowerShell.ConsoleHost.dll'  -PropertyType 'String' 
    set_HKLM_SM_key 'PowerShell\\1\\ShellIds\\Microsoft.PowerShell' -force -Name 'Path'        -Value 'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\powershell.exe'  -PropertyType 'String' 
    set_HKLM_SM_key 'Windows\\CurrentVersion\\WSMAN\\Plugin\\Event' -force -Name 'Forwarding Plugin ConfigXML'   -Value '<PlugInConfiguration xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Name=\"Event Forwarding Plugin\" Filename=\"c:\\windows\\system32\\wevtfwd.dll\" SDKVersion=\"1\" XmlRenderingType=\"text\" ><Resources><Resource ResourceUri=\"http://schemas.microsoft.com/wbem/wsman/1/windows/EventLog\" SupportsOptions=\"true\" ><Security Uri=\"\" ExactMatch=\"false\" Sddl=\"O:NSG:BAD:P(A;;GA;;;BA)S:P(AU;FA;GA;;;WD)(AU;SA;GWGX;;;WD)\" /><Capability Type=\"Subscribe\" SupportsFiltering=\"true\" /></Resource></Resources></PlugInConfiguration>'  -PropertyType 'String' 
    set_HKLM_SM_key 'Windows\\CurrentVersion\\WSMAN\\Plugin\\SEL Plugin' -force -Name 'ConfigXML'   -Value '<PlugInConfiguration xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Name=\"SEL Plugin\" Filename=\"c:\\windows\\system32\\wsmselpl.dll\" SDKVersion=\"1\" XmlRenderingType=\"text\" ><Resources><Resource ResourceUri=\"http://schemas.microsoft.com/wbem/wsman/1/logrecord/sel\" SupportsOptions=\"true\" ><Security Uri=\"\" ExactMatch=\"false\" Sddl=\"O:NSG:BAD:P(A;;GA;;;BA)(A;;GA;;;NS)S:P(AU;FA;GA;;;WD)(AU;SA;GXGW;;;WD)\" /><Capability Type=\"Subscribe\" /></Resource></Resources></PlugInConfiguration>'  -PropertyType 'String' 
    set_HKLM_SM_key 'Windows\\CurrentVersion\\WSMAN\\Plugin\\WMI' -force -Name 'Provider ConfigXML'   -Value '<PlugInConfiguration xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Name=\"WMI Provider\" Filename=\"c:\\windows\\system32\\WsmWmiPl.dll\" SDKVersion=\"1\" XmlRenderingType=\"text\" ><Resources><Resource ResourceUri=\"http://schemas.microsoft.com/wbem/wsman/1/wmi\" SupportsOptions=\"true\" ><Capability Type=\"Get\" SupportsFragment=\"true\" /><Capability Type=\"Put\" SupportsFragment=\"true\" /><Capability Type=\"Invoke\" /><Capability Type=\"Enumerate\" SupportsFiltering=\"true\"/></Resource><Resource ResourceUri=\"http://schemas.dmtf.org/wbem/wscim/1/cim-schema\" SupportsOptions=\"true\" ><Capability Type=\"Get\" SupportsFragment=\"true\" /><Capability Type=\"Put\" SupportsFragment=\"true\" /><Capability Type=\"Invoke\" /><Capability Type=\"Enumerate\" /></Resource><Resource ResourceUri=\"http://schemas.dmtf.org/wbem/wscim/1/*\" SupportsOptions=\"true\" ExactMatch=\"true\" ><Capability Type=\"Enumerate\" SupportsFiltering=\"true\"/></Resource></Resources></PlugInConfiguration>'  -PropertyType 'String' 
    New-ItemProperty -Path 'HKLM:\\System\\CurrentControlSet\\Services\\WinRM' -force -Name 'ImagePath'         -Value 'c:\\windows\\system32\\svchost.exe -k WINRM'  -PropertyType 'String' 
    #Install choco
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) 


#}end ROTZOOI


    #/* Install dotnet48 otherwise choco fails to install packages; procedure copied from winetricks */


 



    #New-Item -Path 'HKCU:\\Software\\Wine\\DllOverrides'
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'mscorwks' -Value 'native' -PropertyType 'String'
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'mscoree' -Value 'native' -PropertyType 'String'

    #Remove-Item -Path "$env:SystemRoot\\SysWOW64\\mscoree.dll" #-Force
    #Remove-Item -Path "$env:SystemRoot\\System32\\mscoree.dll" #-Force


    Start-Process winecfg.exe  -Wait -ArgumentList "/v win7" 
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'fusion' -Value 'builtin' -PropertyType 'String'
#//    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'mscoree' -Value 'native' -PropertyType 'String'

    Start-Process winecfg.exe  -Wait -ArgumentList "/v winxp64"

    Start-Process dotNetFx40_Full_x86_x64.exe  -Wait -ArgumentList "/q /c:install.exe /q"
    $dotnet40id = (Get-Process dotNetFx40_Full_x86_x64).id; Wait-Process -Id $dotnet40id

    Start-Process winecfg.exe  -Wait -ArgumentList "/v win7" 
    Remove-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -Name 'fusion'

#    New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\NET Framework Setup\\NDP\\v4\\Full' -Name 'Install' -Value '0001' -PropertyType 'DWord'
 #   New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\NET Framework Setup\\NDP\\v4\\Full' -Name 'Version' -Value '4.0.30319' -PropertyType 'String'

    #/*FIXME FIXME commented out for now, installation already takes >5 minutes without this*/
    #system(" start /WAIT %SystemDrive%\\windows\\Microsoft.NET\\Framework\\v4.0.30319\\ngen.exe executequeueditems "

    #/*FIXME FIXME  add norestart????*/
    Start-Process ndp48-x86-x64-allos-enu.exe  -Wait -ArgumentList "sfxlang:1027 /q /norestart"
    $dotnet48id = (Get-Process ndp48-x86-x64-allos-enu).id; Wait-Process -Id $dotnet48id

    #"${WINE}" reg add "HKLM\\Software\\Microsoft\\.NETFramework" /v OnlyUseLatestCLR /t REG_DWORD /d 0001 /f
    New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\.NETFramework' -Name 'OnlyUseLatestCLR' -Value '0001' -PropertyType 'DWord'
    New-ItemProperty -Path 'HKLM:\\Software\\Wow6432Node\\Microsoft\\.NETFramework' -Name 'OnlyUseLatestCLR' -Value '0001' -PropertyType 'DWord'


#    New-Item -Path 'HKLM:\\Software\\Microsoft\\NET Framework Setup\\NDP\\v3.0'
#    New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\NET Framework Setup\\NDP\\v3.0' -Name 'Install' -Value '1' -PropertyType 'DWord'
##    New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\NET Framework Setup\\NDP\\v3.0' -Name 'SP' -Value '2' -PropertyType 'DWord'
#    New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\NET Framework Setup\\NDP\\v3.0' -Name 'Version' -Value '3.2.30729' -PropertyType 'String'
    new_HKLM_SM_key 'NET Framework Setup\\NDP\\v3.0'
    set_HKLM_SM_key 'NET Framework Setup\\NDP\\v3.0' 'Install' '1' 'dword'
    set_HKLM_SM_key 'NET Framework Setup\\NDP\\v3.0' 'SP' '2' 'dword'
    set_HKLM_SM_key 'NET Framework Setup\\NDP\\v3.0' 'Version' '3.2.30729' 'string'

#    New-Item -Path 'HKLM:\\Software\\Microsoft\\NET Framework Setup\\NDP\\v3.0\\Setup'
#    New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\NET Framework Setup\\NDP\\v3.0\\Setup' -Name 'InstallSuccess' -Value '1' -PropertyType 'DWord'
#    New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\NET Framework Setup\\NDP\\v3.0\\Setup' -Name 'Version' -Value '3.2.30729' -PropertyType 'String'
    new_HKLM_SM_key 'NET Framework Setup\\NDP\\v3.0\\Setup'
    set_HKLM_SM_key 'NET Framework Setup\\NDP\\v3.0\\Setup' 'InstallSuccess' '1' 'dword'
    set_HKLM_SM_key 'NET Framework Setup\\NDP\\v3.0\\Setup' 'Version' '3.2.30729' 'string'


#    New-Item -Path 'HKLM:\\Software\\Microsoft\\NET Framework Setup\\NDP\\v3.5'
#    New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\NET Framework Setup\\NDP\\v3.5' -Name 'Install' -Value '1' -PropertyType 'DWord'
#    New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\NET Framework Setup\\NDP\\v3.5' -Name 'SP' -Value '2' -PropertyType 'DWord'
#    New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\NET Framework Setup\\NDP\\v3.5' -Name 'Version' -Value '3.5.30729.4926' -PropertyType 'String'

    new_HKLM_SM_key 'NET Framework Setup\\NDP\\v3.5'
    set_HKLM_SM_key 'NET Framework Setup\\NDP\\v3.5' 'Install' '1' 'dword'
    set_HKLM_SM_key 'NET Framework Setup\\NDP\\v3.5' 'SP' '2' 'dword'
    set_HKLM_SM_key 'NET Framework Setup\\NDP\\v3.0' 'Version' '3.5.30729.4926' 'string'


    #New-Item -Path 'HKLM:\\Software\\Microsoft\\NET Framework Setup\\NDP\\v3.5\\1033'
    #New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\NET Framework Setup\\NDP\\v3.5\\1033' -Name 'Install' -Value '1' -PropertyType 'DWord'
    new_HKLM_SM_key 'NET Framework Setup\\NDP\\v3.5\\1033'
    set_HKLM_SM_key 'NET Framework Setup\\NDP\\v3.5\\1033' 'Install' '1' 'dword'

##[HKEY_CURRENT_USER\Software\Wine\Fonts\Replacements]
#"Lucida Console"="Tahoma"

    New-Item -Path 'HKCU:\\Software\\Wine\\Fonts\\Replacements'
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\Fonts\\Replacements' -Name 'Lucida Console' -Value 'Tahoma' -PropertyType 'String'

#HKEY_CURRENT_USER\SOFTWARE\Microsoft\Avalon.Graphics\DisableHWAcceleration
 New-Item -Path 'HKCU:\\Software\\Microsoft\\Avalon.Graphics' -force
 New-ItemProperty -Path 'HKCU:\\Software\\Microsoft\\Avalon.Graphics' -Name 'DisableHWAcceleration' -Value '1' -PropertyType 'dword'  
#    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\powershell_ise.exe\\DllOverrides' -force -Name 'd3d9' -Value 'disable' -PropertyType 'String'

#[HKEY_LOCAL_MACHINE\Software\Microsoft\NET Framework Setup\NDP\v3.0]
#"Increment"="01"
#"Install"=dword:00000001
#"MSI"=dword:00000001
#"SP"=dword:00000002
#"Version"="3.2.30729"


#[HKEY_LOCAL_MACHINE\Software\Microsoft\NET Framework Setup\NDP\v3.5]
#"Install"=dword:00000001
#"InstallPath"="C:\\windows\\Microsoft.NET\\Framework64\\v3.5\\"
#"MSI"=dword:00000001
#"SP"=dword:00000001
#"Version"="3.5.30729.01"

#[HKEY_LOCAL_MACHINE\Software\Microsoft\NET Framework Setup\NDP\v3.0\Setup]
#"InstallSuccess"=dword:00000001
#"Version"="3.2.30729"








    Copy-Item -Path "$env:windir\\SysWOW64\\WindowsPowerShell\\v1.0\\powershell.exe" -Destination "$env:windir\\SysWOW64\\wusa.exe" -Force
    Copy-Item -Path "$env:winsysdir\\WindowsPowerShell\\v1.0\\powershell.exe" -Destination "$env:winsysdir\\wusa.exe" -Force
#    Copy-Item -Path "$env:winsysdir\\WindowsPowerShell\\v1.0\\powershell.exe" -Destination "$env:winsysdir\\wusadummy.exe" -Force
#    Copy-Item -Path "$env:windir\\SysWOW64\\WindowsPowerShell\\v1.0\\powershell.exe" -Destination "$env:windir\\SysWOW64\\wusadummy.exe" -Force

#http://vcloud-lab.com/entries/powershell/powershell-invoke-webrequest-the-request-was-aborted-could-not-create-ssl-tls-secure-channel
#[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls, [Net.SecurityProtocolType]::Tls11, [Net.SecurityProtocolType]::Tls12, [Net.SecurityProtocolType]::Ssl3
#[Net.ServicePointManager]::SecurityProtocol = "Tls, Tls11, Tls12, Ssl3"

    #Import-Module -Name C:\Windows\System32\WindowsPowerShell\v1.0\Modules\NetTCPIP -Verbose

    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'wusa.exe' -Value 'native' -PropertyType 'String'
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'd3dcompiler_47' -Value 'native' -PropertyType 'String'

    #Start-Process  "winecfg.exe" -Wait -ArgumentList "/v win81"
    Add-Type -AssemblyName PresentationCore,PresentationFramework; [System.Windows.MessageBox]::Show('Chocolatey installed','Congrats','ok','exclamation')
    powershell.exe
