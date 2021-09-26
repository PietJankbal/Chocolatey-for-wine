    [System.IO.Directory]::SetCurrentDirectory("$env:TEMP")

    (New-Object System.Net.WebClient).DownloadFile("https://www.7-zip.org/a/7z1900-x64.exe", "$env:TEMP\\7z1900-x64.exe")
    (New-Object System.Net.WebClient).DownloadFile("http://download.windowsupdate.com/msdownload/update/software/updt/2009/11/windowsserver2003-kb968930-x64-eng_8ba702aa016e4c5aed581814647f4d55635eff5c.exe", "$env:TEMP\\windowsserver2003-kb968930-x64-eng_8ba702aa016e4c5aed581814647f4d55635eff5c.exe")
    (New-Object System.Net.WebClient).DownloadFile("https://download.microsoft.com/download/9/5/A/95A9616B-7A37-4AF6-BC36-D6EA96C8DAAE/dotNetFx40_Full_x86_x64.exe", "$env:TEMP\\dotNetFx40_Full_x86_x64.exe")
    (New-Object System.Net.WebClient).DownloadFile("https://download.visualstudio.microsoft.com/download/pr/7afca223-55d2-470a-8edc-6a1739ae3252/abd170b4b0ec15ad0222a809b761a036/ndp48-x86-x64-allos-enu.exe", "$env:TEMP\\ndp48-x86-x64-allos-enu.exe")
    #(New-Object System.Net.WebClient).DownloadFile("https://github.com/PietJankbal/xtricks/raw/main/cabextract32.exe", "$env:windir\\SysWOW64\\cabextract.exe")
    #(New-Object System.Net.WebClient).DownloadFile("https://github.com/PietJankbal/xtricks/raw/main/cabextract64.exe", "$env:winsysdir\\cabextract.exe")

    #Start-Process -FilePath 7z1900-x64.exe -Wait -ArgumentList "/S"

#if(Test-Path 'env:ROTZOOI'){
    Copy-Item -Path "$env:windir\\SysWOW64\\WindowsPowerShell\\v1.0\\powershell.exe" -Destination "$env:windir\\SysWOW64\\WindowsPowerShell\\v1.0\\powershell_orig.exe"
    Copy-Item -Path "$env:winsysdir\\WindowsPowerShell\\v1.0\\powershell.exe" -Destination "$env:winsysdir\\WindowsPowerShell\\v1.0\\powershell_orig.exe"

    Start-Process  "winecfg.exe" -Wait -ArgumentList "/v win2003"

    Start-Process  "windowsserver2003-kb968930-x64-eng_8ba702aa016e4c5aed581814647f4d55635eff5c.exe" -Wait -ArgumentList "/q /passive /nobackup"
    $w2003id = (Get-Process windowsserver2003-kb968930-x64-eng_8ba702aa016e4c5aed581814647f4d55635eff5c).id; Wait-Process -Id $w2003id
    Start-Process  "winecfg.exe" -Wait -ArgumentList "/v win7"
    $winecfgid = (Get-Process winecfg).id; Wait-Process -Id $winecfgid

    #Start-Process -FilePath $env:TEMP\\ConEmuDownloads\\7za.exe -Wait -ArgumentList  "x windowsserver2003-kb968930-x64-eng_8ba702aa016e4c5aed581814647f4d55635eff5c.exe wow64/powershell.exe"
    #Start-Process -FilePath $env:TEMP\\ConEmuDownloads\\7za.exe -Wait -ArgumentList "x windowsserver2003-kb968930-x64-eng_8ba702aa016e4c5aed581814647f4d55635eff5c.exe powershell.exe"

    #Copy-Item -Path "$env:windir\\SysWOW64\\WindowsPowerShell\\v1.0\\powershell.exe" -Destination "$env:windir\\SysWOW64\\WindowsPowerShell\\v1.0\\powershell20l.exe"
    #Copy-Item -Path "$env:winsysdir\\WindowsPowerShell\\v1.0\\powershell.exe" -Destination "$env:winsysdir\\WindowsPowerShell\\v1.0\\powershell20l.exe"

    Copy-Item -Path "$env:windir\\SysWOW64\\WindowsPowerShell\\v1.0\\powershell_orig.exe" -Destination "$env:windir\\SysWOW64\\WindowsPowerShell\\v1.0\\powershell.exe"
    Copy-Item -Path "$env:winsysdir\\WindowsPowerShell\\v1.0\\powershell_orig.exe" -Destination "$env:winsysdir\\WindowsPowerShell\\v1.0\\powershell.exe"

    function set_HKLM_SM_key() <# sets key for HKLM:\\Software\\Microsoft #>
    {
        Param ($path, $name, $val, $prop) 
        $HKLM_SM = 'HKLM:\\Software\\Microsoft'; $HKLM_SM_WOW = 'HKLM:\\Software\\Wow6432Node\\Microsoft'
        New-ItemProperty -Path "$(Join-Path $HKLM_SM $path)" -Name  $name -Value $val -PropertyType $prop -force -erroraction 'silentlycontinue'
        $newpath = "$(Join-Path $HKLM_SM_WOW $path)" -replace 'system32','syswow64'
        New-ItemProperty -Path "$newpath" -Name  $name -Value $val -PropertyType $prop -force -erroraction 'silentlycontinue'
    }

    function new_HKLM_SM_key()  <# creates key for HKLM:\\Software\\Microsoft #>
    {
         Param ($path) 
         $HKLM_SM = 'HKLM:\\Software\\Microsoft'; $HKLM_SM_WOW = 'HKLM:\\Software\\Wow6432Node\\Microsoft'
         New-Item -Path "$(Join-Path $HKLM_SM $path)" -force;  New-Item -Path "$(Join-Path $HKLM_SM_WOW $path)" -force
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

    set_HKLM_SM_key 'Cryptography\\OID\\EncodingType 0\\CryptSIPDllCreateIndirectData\\{603BCC1F-4B59-4E08-B724-D2C6297EF351}' 'Dll' 'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\pwrshsip.dll' 'String'
    set_HKLM_SM_key 'Cryptography\\OID\\EncodingType 0\\CryptSIPDllGetSignedDataMsg\\{603BCC1F-4B59-4E08-B724-D2C6297EF351}' 'Dll' 'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\pwrshsip.dll' 'String'
    set_HKLM_SM_key 'Cryptography\\OID\\EncodingType 0\\CryptSIPDllIsMyFileType2\\{603BCC1F-4B59-4E08-B724-D2C6297EF351}' 'Dll' 'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\pwrshsip.dll' 'String'
    set_HKLM_SM_key 'Cryptography\\OID\\EncodingType 0\\CryptSIPDllPutSignedDataMsg\\{603BCC1F-4B59-4E08-B724-D2C6297EF351}' 'Dll' 'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\pwrshsip.dll' 'String'
    set_HKLM_SM_key 'Cryptography\\OID\\EncodingType 0\\CryptSIPDllRemoveSignedDataMsg\\{603BCC1F-4B59-4E08-B724-D2C6297EF351}' 'Dll' 'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\pwrshsip.dll' 'String'
    set_HKLM_SM_key 'Cryptography\\OID\\EncodingType 0\\CryptSIPDllVerifyIndirectData\\{603BCC1F-4B59-4E08-B724-D2C6297EF351}' 'Dll' 'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\pwrshsip.dll' 'String' 
    set_HKLM_SM_key 'PowerShell\\1\\PowerShellEngine' 'ApplicationBase' 'c:\\windows\\system32\\WindowsPowerShell\\v1.0' 'String'
    set_HKLM_SM_key 'PowerShell\\1\\PowerShellEngine' 'ConsoleHostModuleName' 'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\Microsoft.PowerShell.ConsoleHost.dll' 'String'
    set_HKLM_SM_key 'PowerShell\\1\\ShellIds\\Microsoft.PowerShell' 'Path' 'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\powershell.exe' 'String'
    set_HKLM_SM_key 'Windows\\CurrentVersion\\WSMAN\\Plugin\\Event' 'Forwarding Plugin ConfigXML' '<PlugInConfiguration xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Name=\"Event Forwarding Plugin\" Filename=\"c:\\windows\\system32\\wevtfwd.dll\" SDKVersion=\"1\" XmlRenderingType=\"text\" ><Resources><Resource ResourceUri=\"http://schemas.microsoft.com/wbem/wsman/1/windows/EventLog\" SupportsOptions=\"true\" ><Security Uri=\"\" ExactMatch=\"false\" Sddl=\"O:NSG:BAD:P(A;;GA;;;BA)S:P(AU;FA;GA;;;WD)(AU;SA;GWGX;;;WD)\" /><Capability Type=\"Subscribe\" SupportsFiltering=\"true\" /></Resource></Resources></PlugInConfiguration>' 'String'
    set_HKLM_SM_key 'Windows\\CurrentVersion\\WSMAN\\Plugin\\SEL Plugin' 'ConfigXML' '<PlugInConfiguration xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Name=\"SEL Plugin\" Filename=\"c:\\windows\\system32\\wsmselpl.dll\" SDKVersion=\"1\" XmlRenderingType=\"text\" ><Resources><Resource ResourceUri=\"http://schemas.microsoft.com/wbem/wsman/1/logrecord/sel\" SupportsOptions=\"true\" ><Security Uri=\"\" ExactMatch=\"false\" Sddl=\"O:NSG:BAD:P(A;;GA;;;BA)(A;;GA;;;NS)S:P(AU;FA;GA;;;WD)(AU;SA;GXGW;;;WD)\" /><Capability Type=\"Subscribe\" /></Resource></Resources></PlugInConfiguration>' 'String'
    set_HKLM_SM_key 'Windows\\CurrentVersion\\WSMAN\\Plugin\\WMI' 'Provider ConfigXML' '<PlugInConfiguration xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Name=\"WMI Provider\" Filename=\"c:\\windows\\system32\\WsmWmiPl.dll\" SDKVersion=\"1\" XmlRenderingType=\"text\" ><Resources><Resource ResourceUri=\"http://schemas.microsoft.com/wbem/wsman/1/wmi\" SupportsOptions=\"true\" ><Capability Type=\"Get\" SupportsFragment=\"true\" /><Capability Type=\"Put\" SupportsFragment=\"true\" /><Capability Type=\"Invoke\" /><Capability Type=\"Enumerate\" SupportsFiltering=\"true\"/></Resource><Resource ResourceUri=\"http://schemas.dmtf.org/wbem/wscim/1/cim-schema\" SupportsOptions=\"true\" ><Capability Type=\"Get\" SupportsFragment=\"true\" /><Capability Type=\"Put\" SupportsFragment=\"true\" /><Capability Type=\"Invoke\" /><Capability Type=\"Enumerate\" /></Resource><Resource ResourceUri=\"http://schemas.dmtf.org/wbem/wscim/1/*\" SupportsOptions=\"true\" ExactMatch=\"true\" ><Capability Type=\"Enumerate\" SupportsFiltering=\"true\"/></Resource></Resources></PlugInConfiguration>' 'String'
    set_HKLM_SM_key 'HKLM:\\System\\CurrentControlSet\\Services\\WinRM' 'ImagePath' 'c:\\windows\\system32\\svchost.exe -k WINRM' 'String'
    #Install choco
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) 
#}end ROTZOOI
    #/* Install dotnet48 otherwise choco fails to install packages; procedure copied from winetricks */
    #/* remove_mono */
    $f = uninstaller --list  | Select-String 'Mono'
    $g = $f -split "\|" |Select-string "{"
    uninstaller --remove $g[0]
    uninstaller --remove $g[1]

    Remove-Item -Path "$env:SystemRoot\\SysWOW64\\mscoree.dll" -Force
    Remove-Item -Path "$env:SystemRoot\\System32\\mscoree.dll" -Force
    #/* END remove_mono */
    
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'mscorwks' -Value 'native' -PropertyType 'String'
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'mscoree' -Value 'native' -PropertyType 'String'

    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'fusion' -Value 'builtin' -PropertyType 'String'

    Start-Process winecfg.exe  -Wait -ArgumentList "/v winxp64"
    Start-Process dotNetFx40_Full_x86_x64.exe  -Wait -ArgumentList "/q /c:install.exe /q"
    $dotnet40id = (Get-Process dotNetFx40_Full_x86_x64).id; Wait-Process -Id $dotnet40id

    Start-Process winecfg.exe  -Wait -ArgumentList "/v win7" 
    Remove-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -Name 'fusion'
    #/*FIXME FIXME commented out for now, installation already takes >5 minutes without this*/
    #system(" start /WAIT %SystemDrive%\\windows\\Microsoft.NET\\Framework\\v4.0.30319\\ngen.exe executequeueditems "

    Start-Process ndp48-x86-x64-allos-enu.exe  -Wait -ArgumentList "sfxlang:1027 /q /norestart"
    $dotnet48id = (Get-Process ndp48-x86-x64-allos-enu).id; Wait-Process -Id $dotnet48id

    New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\.NETFramework' -Name 'OnlyUseLatestCLR' -Value '0001' -PropertyType 'DWord'
    New-ItemProperty -Path 'HKLM:\\Software\\Wow6432Node\\Microsoft\\.NETFramework' -Name 'OnlyUseLatestCLR' -Value '0001' -PropertyType 'DWord'
    <# workarounds for powershell_ise #>
    new_HKLM_SM_key 'NET Framework Setup\\NDP\\v3.0'
    set_HKLM_SM_key 'NET Framework Setup\\NDP\\v3.0' 'Install' '1' 'dword'
    set_HKLM_SM_key 'NET Framework Setup\\NDP\\v3.0' 'SP' '2' 'dword'
    set_HKLM_SM_key 'NET Framework Setup\\NDP\\v3.0' 'Version' '3.2.30729' 'string'

    new_HKLM_SM_key 'NET Framework Setup\\NDP\\v3.0\\Setup'
    set_HKLM_SM_key 'NET Framework Setup\\NDP\\v3.0\\Setup' 'InstallSuccess' '1' 'dword'
    set_HKLM_SM_key 'NET Framework Setup\\NDP\\v3.0\\Setup' 'Version' '3.2.30729' 'string'

    new_HKLM_SM_key 'NET Framework Setup\\NDP\\v3.5'
    set_HKLM_SM_key 'NET Framework Setup\\NDP\\v3.5' 'Install' '1' 'dword'
    set_HKLM_SM_key 'NET Framework Setup\\NDP\\v3.5' 'SP' '2' 'dword'
    set_HKLM_SM_key 'NET Framework Setup\\NDP\\v3.5' 'Version' '3.5.30729.4926' 'string'

    new_HKLM_SM_key 'NET Framework Setup\\NDP\\v3.5\\1033'
    set_HKLM_SM_key 'NET Framework Setup\\NDP\\v3.5\\1033' 'Install' '1' 'dword'

    New-Item -Path 'HKCU:\\Software\\Wine\\Fonts\\Replacements'
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\Fonts\\Replacements' -Name 'Lucida Console' -Value 'Tahoma' -PropertyType 'String'
    New-Item -Path 'HKCU:\\Software\\Microsoft\\Avalon.Graphics' -force
    New-ItemProperty -Path 'HKCU:\\Software\\Microsoft\\Avalon.Graphics' -Name 'DisableHWAcceleration' -Value '0' -PropertyType 'dword'  
    <# END workarounds for powershell_ise #>
    
    (New-Object System.Net.WebClient).DownloadFile("https://mirrors.kernel.org/gentoo/distfiles/arial32.exe", "$env:TEMP\\arial32.exe")
    Start-Process -FilePath "$env:TEMP\\arial32.exe" -Wait -ArgumentList  "-q"
    (New-Object System.Net.WebClient).DownloadFile("https://mirrors.kernel.org/gentoo/distfiles/arialb32.exe", "$env:TEMP\\arialb32.exe")
    Start-Process -FilePath "$env:TEMP\\arialb32.exe" -Wait -ArgumentList  "-q"

    (New-Object System.Net.WebClient).DownloadFile("https://download-installer.cdn.mozilla.net/pub/firefox/releases/62.0.3/win32/ach/Firefox%20Setup%2062.0.3.exe", "$env:TEMP\\Firefox32.exe")
    Start-Process -FilePath ${env:ProgramFiles}\\7-zip\\7z.exe$env:TEMP\\ConEmuDownloads\\7za.exe -Wait -ArgumentList  "x $env:TEMP\\Firefox32.exe core/d3dcompiler_47.dll -o$env:TEMP\\core32"
    $7zid = (Get-Process 7z).id; Wait-Process -Id $7zid
   
    #Start-Process cabextract -argumentlist "-F", "core/d3dcompiler_47.dll" ,"-d","$env:TEMP", "$env:TEMP\\Firefox32.exe"
    #Get-Process cabextract | Foreach-Object { $_.WaitForExit() }
    Copy-Item -Path "$env:TEMP\\core32\\core\\d3dcompiler_47.dll" -Destination "$env:SystemRoot\\SysWOW64\\d3dcompiler_47.dll" -Force

    (New-Object System.Net.WebClient).DownloadFile("https://download-installer.cdn.mozilla.net/pub/firefox/releases/62.0.3/win64/ach/Firefox%20Setup%2062.0.3.exe", "$env:TEMP\\Firefox64.exe")
    Start-Process -FilePath ${env:ProgramFiles}\\7-zip\\7z.exe$env:TEMP\\ConEmuDownloads\\7za.exe -Wait -ArgumentList  "x $env:TEMP\\Firefox64.exe core/d3dcompiler_47.dll -o$env:TEMP\\core64"
    $7zid = (Get-Process 7z).id; Wait-Process -Id $7zid
    #Start-Process cabextract -argumentlist "-F", "core/d3dcompiler_47.dll" ,"-d","$env:TEMP\\core64", "$env:TEMP\\Firefox64.exe"
    #Get-Process cabextract | Foreach-Object { $_.WaitForExit() }
    Copy-Item -Path "$env:TEMP\\core64\\core\\d3dcompiler_47.dll" -Destination "$env:SystemRoot\\System32\\d3dcompiler_47.dll" -Force

    
    (New-Object System.Net.WebClient).DownloadFile("http://download.windowsupdate.com/msdownload/update/software/crup/2009/11/msxml6-kb973686-enu-amd64_bb420ff844af4603437396d775fa34a47d0718a5.exe", "$env:TEMP\\msxml6-kb973686-enu-amd64_bb420ff844af4603437396d775fa34a47d0718a5.exe")

    Remove-Item -Path "$env:SystemRoot\\SysWOW64\\msxml6.dll" -Force
    Remove-Item -Path "$env:SystemRoot\\System32\\msxml6.dll" -Force
    Start-Process  "winecfg.exe" -Wait -ArgumentList "/v winxp64"
    $winecfgid = (Get-Process winecfg).id; Wait-Process -Id $winecfgid

    Start-Process -FilePath "$env:TEMP\\msxml6-kb973686-enu-amd64_bb420ff844af4603437396d775fa34a47d0718a5.exe" -Wait -ArgumentList  "-q"
    $xml6id = (Get-Process msxml6-kb973686-enu-amd64_bb420ff844af4603437396d775fa34a47d0718a5).id; Wait-Process -Id $xml6id
    Start-Process  "winecfg.exe" -Wait -ArgumentList "/v win7";     $winecfgid = (Get-Process winecfg).id; Wait-Process -Id $winecfgid

    Copy-Item -Path "$env:windir\\SysWOW64\\WindowsPowerShell\\v1.0\\powershell.exe" -Destination "$env:windir\\SysWOW64\\wusa.exe" -Force
    Copy-Item -Path "$env:winsysdir\\WindowsPowerShell\\v1.0\\powershell.exe" -Destination "$env:winsysdir\\wusa.exe" -Force

    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'wusa.exe' -Value 'native' -PropertyType 'String'
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'd3dcompiler_47' -Value 'native' -PropertyType 'String'
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'msxml6' -Value 'native' -PropertyType 'String'
    #Start-Process  "winecfg.exe" -Wait -ArgumentList "/v win7"
    cd c:\
    #$oldPath=(Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).Path
    #$newPath=$oldPath+";$env:systemdrive\\tools\\git\\usr\\bin"
    #Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH –Value $newPath

   # Start-Process choco.exe -Wait -ArgumentList  "install", "git.portable","-y"
   # $chocoid = (Get-Process choco).id; Wait-Process -Id $winecfgid
   # refreshenv

    Start-Process -FilePath $env:TEMP\\ConEmuDownloads\\7za.exe -Wait -ArgumentList  "x windowsserver2003-kb968930-x64-eng_8ba702aa016e4c5aed581814647f4d55635eff5c.exe wow64/powershell.exe"
    Start-Process -FilePath $env:TEMP\\ConEmuDownloads\\7za.exe -Wait -ArgumentList "x windowsserver2003-kb968930-x64-eng_8ba702aa016e4c5aed581814647f4d55635eff5c.exe powershell.exe"

    #Copy-Item -Path "$env:TEMP\\wow64\\powershell.exe" -Destination "$env:windir\\SysWOW64\\WindowsPowerShell\\v1.0\\powershell20l.exe"
    #Copy-Item -Path "$env:TEMP\\powershell.exe" -Destination "$env:winsysdir\\WindowsPowerShell\\v1.0\\powershell20l.exe"

    
    #Start-Process cabextract -argumentlist "-F", "powershell.exe" ,"-d","$env:TEMP", "$env:TEMP\\windowsserver2003-kb968930-x64-eng_8ba702aa016e4c5aed581814647f4d55635eff5c.exe"
    #Get-Process cabextract | Foreach-Object { $_.WaitForExit() }
    #Start-Process cabextract -argumentlist "-F", "wow64/powershell.exe" ,"-d","$env:TEMP", "$env:TEMP\\windowsserver2003-kb968930-x64-eng_8ba702aa016e4c5aed581814647f4d55635eff5c.exe"
    #Get-Process cabextract | Foreach-Object { $_.WaitForExit() }

    Copy-Item -Path "$env:TEMP\\wow64\\powershell.exe" -Destination "$env:windir\\SysWOW64\\WindowsPowerShell\\v1.0\\powershell20l.exe"
    Copy-Item -Path "$env:TEMP\\powershell.exe" -Destination "$env:winsysdir\\WindowsPowerShell\\v1.0\\powershell20l.exe"


    Add-Type -AssemblyName PresentationCore,PresentationFramework; [System.Windows.MessageBox]::Show('Chocolatey installed','Congrats','ok','exclamation')
    # choco feature disable --name='powershellHost'
    #Start-Process choco.exe -Wait -ArgumentList  "feature", "disable","--name='powershellHost'","-NoNewWindow"
    #$chocoid = (Get-Process choco).id; Wait-Process -Id $chocoid
    #'c:\\ProgramData\\chocolatey\\choco.exe feature disable --name=powershellHost'
     #   Start-Process   'c:\\ProgramData\\chocolatey\\choco.exe' -Wait -ArgumentList "feature"."disable","--name=powershellHost","-NoNewWindow"
    powershell.exe 'c:\\ProgramData\\chocolatey\\choco.exe feature disable --name=powershellHost'
    powershell.exe
