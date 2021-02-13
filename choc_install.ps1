    [System.IO.Directory]::SetCurrentDirectory("$env:TEMP")

    (New-Object System.Net.WebClient).DownloadFile("https://www.7-zip.org/a/7z1900-x64.exe", "$env:TEMP\\7z1900-x64.exe")
    (New-Object System.Net.WebClient).DownloadFile("http://download.windowsupdate.com/msdownload/update/software/updt/2009/11/windowsserver2003-kb968930-x64-eng_8ba702aa016e4c5aed581814647f4d55635eff5c.exe", "$env:TEMP\\windowsserver2003-kb968930-x64-eng_8ba702aa016e4c5aed581814647f4d55635eff5c.exe")
    (New-Object System.Net.WebClient).DownloadFile("https://download.microsoft.com/download/9/5/A/95A9616B-7A37-4AF6-BC36-D6EA96C8DAAE/dotNetFx40_Full_x86_x64.exe", "$env:TEMP\\dotNetFx40_Full_x86_x64.exe")
    (New-Object System.Net.WebClient).DownloadFile("https://download.visualstudio.microsoft.com/download/pr/7afca223-55d2-470a-8edc-6a1739ae3252/abd170b4b0ec15ad0222a809b761a036/ndp48-x86-x64-allos-enu.exe", "$env:TEMP\\ndp48-x86-x64-allos-enu.exe")

    Start-Process -FilePath 7z1900-x64.exe -Wait -ArgumentList "/S"


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
    New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\Cryptography\\OID\\EncodingType 0\\CryptSIPDllCreateIndirectData\\{603BCC1F-4B59-4E08-B724-D2C6297EF351}' -force -Name 'Dll'         -Value 'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\pwrshsip.dll'  -PropertyType 'String' 
    New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\Cryptography\\OID\\EncodingType 0\\CryptSIPDllGetSignedDataMsg\\{603BCC1F-4B59-4E08-B724-D2C6297EF351}' -force -Name 'Dll'         -Value 'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\pwrshsip.dll'  -PropertyType 'String' 
    New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\Cryptography\\OID\\EncodingType 0\\CryptSIPDllIsMyFileType2\\{603BCC1F-4B59-4E08-B724-D2C6297EF351}' -force -Name 'Dll'         -Value 'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\pwrshsip.dll'  -PropertyType 'String' 
    New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\Cryptography\\OID\\EncodingType 0\\CryptSIPDllPutSignedDataMsg\\{603BCC1F-4B59-4E08-B724-D2C6297EF351}' -force -Name 'Dll'         -Value 'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\pwrshsip.dll'  -PropertyType 'String' 
    New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\Cryptography\\OID\\EncodingType 0\\CryptSIPDllRemoveSignedDataMsg\\{603BCC1F-4B59-4E08-B724-D2C6297EF351}' -force -Name 'Dll'        -Value 'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\pwrshsip.dll'  -PropertyType 'String' 
    New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\Cryptography\\OID\\EncodingType 0\\CryptSIPDllVerifyIndirectData\\{603BCC1F-4B59-4E08-B724-D2C6297EF351}' -force -Name 'Dll'         -Value 'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\pwrshsip.dll'  -PropertyType 'String' 
    New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\PowerShell\\1\\PowerShellEngine' -force -Name 'ApplicationBase'        -Value 'c:\\windows\\system32\\WindowsPowerShell\\v1.0'  -PropertyType 'String' 
    New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\PowerShell\\1\\PowerShellEngine' -force -Name 'ConsoleHostModuleName'  -Value 'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\Microsoft.PowerShell.ConsoleHost.dll'  -PropertyType 'String' 
    New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\PowerShell\\1\\ShellIds\\Microsoft.PowerShell' -force -Name 'Path'        -Value 'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\powershell.exe'  -PropertyType 'String' 
    New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\WSMAN\\Plugin\\Event' -force -Name 'Forwarding Plugin ConfigXML'   -Value '<PlugInConfiguration xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Name=\"Event Forwarding Plugin\" Filename=\"c:\\windows\\system32\\wevtfwd.dll\" SDKVersion=\"1\" XmlRenderingType=\"text\" ><Resources><Resource ResourceUri=\"http://schemas.microsoft.com/wbem/wsman/1/windows/EventLog\" SupportsOptions=\"true\" ><Security Uri=\"\" ExactMatch=\"false\" Sddl=\"O:NSG:BAD:P(A;;GA;;;BA)S:P(AU;FA;GA;;;WD)(AU;SA;GWGX;;;WD)\" /><Capability Type=\"Subscribe\" SupportsFiltering=\"true\" /></Resource></Resources></PlugInConfiguration>'  -PropertyType 'String' 
    New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\WSMAN\\Plugin\\SEL Plugin' -force -Name 'ConfigXML'   -Value '<PlugInConfiguration xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Name=\"SEL Plugin\" Filename=\"c:\\windows\\system32\\wsmselpl.dll\" SDKVersion=\"1\" XmlRenderingType=\"text\" ><Resources><Resource ResourceUri=\"http://schemas.microsoft.com/wbem/wsman/1/logrecord/sel\" SupportsOptions=\"true\" ><Security Uri=\"\" ExactMatch=\"false\" Sddl=\"O:NSG:BAD:P(A;;GA;;;BA)(A;;GA;;;NS)S:P(AU;FA;GA;;;WD)(AU;SA;GXGW;;;WD)\" /><Capability Type=\"Subscribe\" /></Resource></Resources></PlugInConfiguration>'  -PropertyType 'String' 
    New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\WSMAN\\Plugin\\WMI' -force -Name 'Provider ConfigXML'   -Value '<PlugInConfiguration xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Name=\"WMI Provider\" Filename=\"c:\\windows\\system32\\WsmWmiPl.dll\" SDKVersion=\"1\" XmlRenderingType=\"text\" ><Resources><Resource ResourceUri=\"http://schemas.microsoft.com/wbem/wsman/1/wmi\" SupportsOptions=\"true\" ><Capability Type=\"Get\" SupportsFragment=\"true\" /><Capability Type=\"Put\" SupportsFragment=\"true\" /><Capability Type=\"Invoke\" /><Capability Type=\"Enumerate\" SupportsFiltering=\"true\"/></Resource><Resource ResourceUri=\"http://schemas.dmtf.org/wbem/wscim/1/cim-schema\" SupportsOptions=\"true\" ><Capability Type=\"Get\" SupportsFragment=\"true\" /><Capability Type=\"Put\" SupportsFragment=\"true\" /><Capability Type=\"Invoke\" /><Capability Type=\"Enumerate\" /></Resource><Resource ResourceUri=\"http://schemas.dmtf.org/wbem/wscim/1/*\" SupportsOptions=\"true\" ExactMatch=\"true\" ><Capability Type=\"Enumerate\" SupportsFiltering=\"true\"/></Resource></Resources></PlugInConfiguration>'  -PropertyType 'String' 
    New-ItemProperty -Path 'HKLM:\\Software\\Wow6432Node\\Microsoft\\Cryptography\\OID\\EncodingType 0\\CryptSIPDllCreateIndirectData\\{603BCC1F-4B59-4E08-B724-D2C6297EF351}' -force -Name 'Dll'         -Value 'c:\\windows\\syswow64\\WindowsPowerShell\\v1.0\\pwrshsip.dll'  -PropertyType 'String' 
    New-ItemProperty -Path 'HKLM:\\Software\\Wow6432Node\\Microsoft\\Cryptography\\OID\\EncodingType 0\\CryptSIPDllGetSignedDataMsg\\{603BCC1F-4B59-4E08-B724-D2C6297EF351}' -force -Name 'Dll'         -Value 'c:\\windows\\syswow64\\WindowsPowerShell\\v1.0\\pwrshsip.dll'  -PropertyType 'String' 
    New-ItemProperty -Path 'HKLM:\\Software\\Wow6432Node\\Microsoft\\Cryptography\\OID\\EncodingType 0\\CryptSIPDllIsMyFileType2\\{603BCC1F-4B59-4E08-B724-D2C6297EF351}' -force -Name 'Dll'         -Value 'c:\\windows\\syswow64\\WindowsPowerShell\\v1.0\\pwrshsip.dll'  -PropertyType 'String' 
    New-ItemProperty -Path 'HKLM:\\Software\\Wow6432Node\\Microsoft\\Cryptography\\OID\\EncodingType 0\\CryptSIPDllPutSignedDataMsg\\{603BCC1F-4B59-4E08-B724-D2C6297EF351}' -force -Name 'Dll'         -Value 'c:\\windows\\syswow64\\WindowsPowerShell\\v1.0\\pwrshsip.dll'  -PropertyType 'String' 
    New-ItemProperty -Path 'HKLM:\\Software\\Wow6432Node\\Microsoft\\Cryptography\\OID\\EncodingType 0\\CryptSIPDllRemoveSignedDataMsg\\{603BCC1F-4B59-4E08-B724-D2C6297EF351}' -force -Name 'Dll'         -Value 'c:\\windows\\syswow64\\WindowsPowerShell\\v1.0\\pwrshsip.dll'  -PropertyType 'String' 
    New-ItemProperty -Path 'HKLM:\\Software\\Wow6432Node\\Microsoft\\Cryptography\\OID\\EncodingType 0\\CryptSIPDllVerifyIndirectData\\{603BCC1F-4B59-4E08-B724-D2C6297EF351}' -force -Name 'Dll'         -Value 'c:\\windows\\syswow64\\WindowsPowerShell\\v1.0\\pwrshsip.dll'  -PropertyType 'String' 
    New-ItemProperty -Path 'HKLM:\\Software\\Wow6432Node\\Microsoft\\PowerShell\\1\\PowerShellEngine' -force -Name 'ApplicationBase'        -Value 'c:\\windows\\syswow64\\WindowsPowerShell\\v1.0'  -PropertyType 'String' 
    New-ItemProperty -Path 'HKLM:\\Software\\Wow6432Node\\Microsoft\\PowerShell\\1\\PowerShellEngine' -force -Name 'ConsoleHostModuleName'   -Value 'c:\\windows\\syswow64\\WindowsPowerShell\\v1.0\\Microsoft.PowerShell.ConsoleHost.dll'  -PropertyType 'String' 
    New-ItemProperty -Path 'HKLM:\\Software\\Wow6432Node\\Microsoft\\PowerShell\\1\\ShellIds\\Microsoft.PowerShell' -force -Name 'Path'        -Value 'c:\\windows\\syswow64\\WindowsPowerShell\\v1.0\\powershell.exe'  -PropertyType 'String' 
    New-ItemProperty -Path 'HKLM:\\System\\CurrentControlSet\\Services\\WinRM' -force -Name 'ImagePath'         -Value 'c:\\windows\\system32\\svchost.exe -k WINRM'  -PropertyType 'String' 
    #Install choco
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) 


if(Test-Path 'env:SCOOP_INSTALL'){
    (New-Object System.Net.WebClient).DownloadFile("https://download.microsoft.com/download/6/A/E/6AEA92B0-A412-4622-983E-5B305D2EBE56/adk/adksetup.exe", "$env:TEMP\\adksetup.exe")

    #[System.Environment]::SetEnvironmentVariable('OnlyUseLatestCLR', '1',[System.EnvironmentVariableTarget]::Machine)
    #Start-Process reg.exe -Wait  -ArgumentList "add \"HKLM\\Software\\Microsoft\\.NETFramework\" /v OnlyUseLatestCLR /t REG_DWORD /d 0001 /f"
    Write-Host "Downloading and installing adk, this may take quite some time..."
    #Start-Process wineboot.exe  -Wait -ArgumentList "-u"
    Start-Sleep -Second 10
    Start-Process winecfg.exe  -Wait -ArgumentList "/v win7" 
    
    Write-Host "Downloading and installing adk, this may take quite some time..."

#    (New-Object System.Net.WebClient).DownloadFile("https://download.microsoft.com/download/a/9/4/a94c5d25-3195-43dc-8dbe-28e1a87e1b59/Windows6.0-KB936330-X64-wave1.exe", "$env:TEMP\\Windows6.0-KB936330-X64-wave1.exe")


    Start-Process adksetup.exe  -ArgumentList "/quiet /features OptionId.WindowsPreinstallationEnvironment"
#    $adkid = (Get-Process adksetup).id; Wait-Process -Id $adkid;
     Get-Process adksetup | Foreach-Object { $_.WaitForExit() }
 
    Copy-Item "${env:ProgramFiles`(x86`)}\\Windows Kits\\8.1\\Assessment and Deployment Kit\\Windows Preinstallation Environment\\amd64\\en-us\\winpe.wim" "$env:TEMP\\winpe64.wim"

    Copy-Item "${env:ProgramFiles`(x86`)}\\Windows Kits\\8.1\\Assessment and Deployment Kit\\Windows Preinstallation Environment\\x86\\en-us\\winpe.wim" "$env:TEMP\\winpe32.wim"



    Start-Process ${env:ProgramFiles}\\7-zip\\7z.exe  -ArgumentList "x","$env:TEMP\\winpe64.wim","-o$env:TEMP","Windows/System32/expand.exe"
    Start-Process ${env:ProgramFiles}\\7-zip\\7z.exe  -ArgumentList "e","$env:TEMP\\winpe32.wim","-o$env:TEMP","Windows/System32/expand.exe"

    Start-Process ${env:ProgramFiles}\\7-zip\\7z.exe  -ArgumentList "x","$env:TEMP\\winpe64.wim","-o$env:TEMP","Windows/System32/dpx.dll"
    Start-Process ${env:ProgramFiles}\\7-zip\\7z.exe  -ArgumentList "e","$env:TEMP\\winpe32.wim","-o$env:TEMP","Windows/System32/dpx.dll"

    Start-Process ${env:ProgramFiles}\\7-zip\\7z.exe  -ArgumentList "x","$env:TEMP\\winpe64.wim","-o$env:TEMP","Windows/System32/cabinet.dll"
    Start-Process ${env:ProgramFiles}\\7-zip\\7z.exe  -ArgumentList "e","$env:TEMP\\winpe32.wim","-o$env:TEMP","Windows/System32/cabinet.dll"

    Start-Process ${env:ProgramFiles}\\7-zip\\7z.exe  -ArgumentList "x","$env:TEMP\\winpe64.wim","-o$env:TEMP","Windows/System32/msdelta.dll"
    Start-Process ${env:ProgramFiles}\\7-zip\\7z.exe  -ArgumentList "e","$env:TEMP\\winpe32.wim","-o$env:TEMP","Windows/System32/msdelta.dll"

    Start-Process ${env:ProgramFiles}\\7-zip\\7z.exe  -ArgumentList "x","$env:TEMP\\winpe64.wim","-o$env:TEMP","Windows/WinSxS/amd64_microsoft-windows-robocopy_31bf3856ad364e35_6.3.9600.16384_none_b7c58f8bc05b432d/Robocopy.exe"
    Start-Process ${env:ProgramFiles}\\7-zip\\7z.exe  -ArgumentList "e","$env:TEMP\\winpe32.wim","-o$env:TEMP","Windows/WinSxS/x86_microsoft-windows-robocopy_31bf3856ad364e35_6.3.9600.16384_none_5ba6f40807fdd1f7/Robocopy.exe"

    Start-Process ${env:ProgramFiles}\\7-zip\\7z.exe  -ArgumentList "x","$env:TEMP\\winpe64.wim","-o$env:TEMP","Windows/WinSxS/amd64_microsoft-windows-mfc42x_31bf3856ad364e35_6.3.9600.16384_none_e3d32e4c2985bf8e/mfc42u.dll"
    Start-Process ${env:ProgramFiles}\\7-zip\\7z.exe  -ArgumentList "e","$env:TEMP\\winpe32.wim","-o$env:TEMP","Windows/WinSxS/x86_microsoft-windows-mfc42x_31bf3856ad364e35_6.3.9600.16384_none_87b492c871284e58/mfc42u.dll"


    Get-Process 7z | Foreach-Object { $_.WaitForExit() }
    #$7zid = (Get-Process 7z).id; Wait-Process -Id $7zid;

    Copy-Item -Path "$env:TEMP\\expand.exe" -Destination "$env:SystemRoot\\syswow64\\expand.exe"
    Copy-Item -Path "$env:TEMP\\Windows\\System32\\expand.exe" -Destination "$env:SystemRoot\\system32\\expand.exe"

    Copy-Item -Path "$env:TEMP\\dpx.dll" -Destination "$env:SystemRoot\\syswow64\\dpx.dll"
    Copy-Item -Path "$env:TEMP\\Windows\\System32\\dpx.dll" -Destination "$env:SystemRoot\\system32\\dpx.dll"

    Copy-Item -Path "$env:TEMP\\cabinet.dll" -Destination "$env:SystemRoot\\syswow64\\cabinet.dll"
    Copy-Item -Path "$env:TEMP\\Windows\\System32\\cabinet.dll" -Destination "$env:SystemRoot\\system32\\cabinet.dll"

    Copy-Item -Path "$env:TEMP\\msdelta.dll" -Destination "$env:SystemRoot\\syswow64\\msdelta.dll"
    Copy-Item -Path "$env:TEMP\\Windows\\System32\\msdelta.dll" -Destination "$env:SystemRoot\\system32\\msdelta.dll"

    Copy-Item -Path "$env:TEMP\\Robocopy.exe" -Destination "$env:SystemRoot\\syswow64\\robocopy.exe"
    Copy-Item -Path "$env:TEMP\\Windows\\WinSxS\\amd64_microsoft-windows-robocopy_31bf3856ad364e35_6.3.9600.16384_none_b7c58f8bc05b432d\\Robocopy.exe" -Destination "$env:SystemRoot\\system32\\robocopy.exe"

    Copy-Item -Path "$env:TEMP\\mfc42u.dll" -Destination "$env:SystemRoot\\syswow64\\mfc42u.dll"
    Copy-Item -Path "$env:TEMP\\Windows\\WinSxS\\amd64_microsoft-windows-mfc42x_31bf3856ad364e35_6.3.9600.16384_none_e3d32e4c2985bf8e/mfc42u.dll" -Destination "$env:SystemRoot\\system32\\mfc42u.dll"



#    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'cabinet' -Value 'native' -PropertyType 'String' 
#    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'expand.exe' -Value 'native' -PropertyType 'String' 




    Start-Process  "pwsh.exe" -Wait -ArgumentList "-c iwr -useb get.scoop.sh | iex"

    Start-Process  "pwsh.exe" -Wait -ArgumentList "-c scoop config MSIEXTRACT_USE_LESSMSI true"

    Start-Process  "pwsh.exe" -Wait -ArgumentList "-c scoop install 7zip"
    
    Get-Process pwsh | Foreach-Object { $_.WaitForExit() }

}








    #/* Install dotnet48 otherwise choco fails to install packages; procedure copied from winetricks */
    #/* remove_mono */
    Start-Process uninstaller -Wait -ArgumentList "--remove {3731D2B3-8EA4-5C7F-9F05-AB04B8C3070E}"
    Start-Process uninstaller  -Wait -ArgumentList "--remove {671DE1A2-3373-5AAD-8227-C62B4E5CAEF6}"

    Remove-Item -Path 'HKLM:\\Software\\Microsoft\\NET Framework Setup\\NDP\\v3.5' -Recurse
    Remove-Item -Path 'HKLM:\\Software\\Microsoft\\NET Framework Setup\\NDP\\v4'  -Recurse  

    Remove-Item -Path "$env:windir\\SysWOW64\\mscoree.dll" -Force
    Remove-Item -Path "$env:winsysdir\\mscoree.dll" -Force
    #/* END remove_mono */

 

    New-Item -Path 'HKCU:\\Software\\Wine\\DllOverrides'
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'mscorwks' -Value 'native' -PropertyType 'String'
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'mscoree' -Value 'native' -PropertyType 'String'
   #/* dotnet35 */
if(Test-Path 'env:CHOC_INSTALL_ALL'){

    (New-Object System.Net.WebClient).DownloadFile("https://download.microsoft.com/download/6/0/f/60fc5854-3cb8-4892-b6db-bd4f42510f28/dotnetfx35.exe", "$env:TEMP\\dotnetfx35.exe")
    (New-Object System.Net.WebClient).DownloadFile("https://download.microsoft.com/download/6/A/E/6AEA92B0-A412-4622-983E-5B305D2EBE56/adk/adksetup.exe", "$env:TEMP\\adksetup.exe")
    (New-Object System.Net.WebClient).DownloadFile("https://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/Win7AndW2K8R2-KB3191566-x64.zip", "$env:TEMP\\Win7AndW2K8R2-KB3191566-x64.zip")

    Start-Process winecfg.exe  -Wait -ArgumentList "/v winxp64"
    Start-Process dotnetfx35.exe  -Wait -ArgumentList "/q /lang:ENU"
    $dotnet35id = (Get-Process dotnetfx35).id; Wait-Process -Id $dotnet35id
}
    #/* END dotnet35 */

    Start-Process winecfg.exe  -Wait -ArgumentList "/v win7" 
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'fusion' -Value 'builtin' -PropertyType 'String'
#//    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'mscoree' -Value 'native' -PropertyType 'String'

    Start-Process winecfg.exe  -Wait -ArgumentList "/v winxp64"

    Start-Process dotNetFx40_Full_x86_x64.exe  -Wait -ArgumentList "/q /c:install.exe /q"
    $dotnet40id = (Get-Process dotNetFx40_Full_x86_x64).id; Wait-Process -Id $dotnet40id

    Start-Process winecfg.exe  -Wait -ArgumentList "/v win7" 
    Remove-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -Name 'fusion'

    New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\NET Framework Setup\\NDP\\v4\\Full' -Name 'Install' -Value '0001' -PropertyType 'DWord'
    New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\NET Framework Setup\\NDP\\v4\\Full' -Name 'Version' -Value '4.0.30319' -PropertyType 'String'

    #/*FIXME FIXME commented out for now, installation already takes >5 minutes without this*/
    #system(" start /WAIT %SystemDrive%\\windows\\Microsoft.NET\\Framework\\v4.0.30319\\ngen.exe executequeueditems "

    #/*FIXME FIXME  add norestart????*/
    Start-Process ndp48-x86-x64-allos-enu.exe  -Wait -ArgumentList "sfxlang:1027 /q /norestart"
    $dotnet48id = (Get-Process ndp48-x86-x64-allos-enu).id; Wait-Process -Id $dotnet48id



if(Test-Path 'env:CHOC_INSTALL_ALL'){

    Start-Process wineboot.exe  -Wait -ArgumentList "-u"
    Start-Process winecfg.exe  -Wait -ArgumentList "/v win7" 

    Start-Process adksetup.exe  -ArgumentList "/quiet /features OptionId.WindowsPreinstallationEnvironment"
    $adkid = (Get-Process adksetup).id; Wait-Process -Id $adkid;

    Copy-Item "${env:ProgramFiles`(x86`)}\\Windows Kits\\8.1\\Assessment and Deployment Kit\\Windows Preinstallation Environment\\amd64\\en-us\\winpe.wim" "$env:TEMP\\winpe64.wim"

    Copy-Item "${env:ProgramFiles`(x86`)}\\Windows Kits\\8.1\\Assessment and Deployment Kit\\Windows Preinstallation Environment\\x86\\en-us\\winpe.wim" "$env:TEMP\\winpe32.wim"



    Start-Process ${env:ProgramFiles}\\7-zip\\7z.exe  -ArgumentList "x","$env:TEMP\\winpe64.wim","-o$env:TEMP","Windows/System32/expand.exe"
    Start-Process ${env:ProgramFiles}\\7-zip\\7z.exe  -ArgumentList "e","$env:TEMP\\winpe32.wim","-o$env:TEMP","Windows/System32/expand.exe"

    Start-Process ${env:ProgramFiles}\\7-zip\\7z.exe  -ArgumentList "x","$env:TEMP\\winpe64.wim","-o$env:TEMP","Windows/System32/dpx.dll"
    Start-Process ${env:ProgramFiles}\\7-zip\\7z.exe  -ArgumentList "e","$env:TEMP\\winpe32.wim","-o$env:TEMP","Windows/System32/dpx.dll"

    Start-Process ${env:ProgramFiles}\\7-zip\\7z.exe  -ArgumentList "x","$env:TEMP\\winpe64.wim","-o$env:TEMP","Windows/System32/cabinet.dll"
    Start-Process ${env:ProgramFiles}\\7-zip\\7z.exe  -ArgumentList "e","$env:TEMP\\winpe32.wim","-o$env:TEMP","Windows/System32/cabinet.dll"

    Start-Process ${env:ProgramFiles}\\7-zip\\7z.exe  -ArgumentList "x","$env:TEMP\\winpe64.wim","-o$env:TEMP","Windows/System32/msdelta.dll"
    Start-Process ${env:ProgramFiles}\\7-zip\\7z.exe  -ArgumentList "e","$env:TEMP\\winpe32.wim","-o$env:TEMP","Windows/System32/msdelta.dll"

    $7zid = (Get-Process 7z).id; Wait-Process -Id $7zid;

    Copy-Item -Path "$env:TEMP\\expand.exe" -Destination "$env:SystemRoot\\syswow64\\expand.exe"
    Copy-Item -Path "$env:TEMP\\Windows\\System32\\expand.exe" -Destination "$env:SystemRoot\\system32\\expand.exe"

    Copy-Item -Path "$env:TEMP\\dpx.dll" -Destination "$env:SystemRoot\\syswow64\\dpx.dll"
    Copy-Item -Path "$env:TEMP\\Windows\\System32\\dpx.dll" -Destination "$env:SystemRoot\\system32\\dpx.dll"

    Copy-Item -Path "$env:TEMP\\cabinet.dll" -Destination "$env:SystemRoot\\syswow64\\cabinet.dll"
    Copy-Item -Path "$env:TEMP\\Windows\\System32\\cabinet.dll" -Destination "$env:SystemRoot\\system32\\cabinet.dll"

    Copy-Item -Path "$env:TEMP\\msdelta.dll" -Destination "$env:SystemRoot\\syswow64\\msdelta.dll"
    Copy-Item -Path "$env:TEMP\\Windows\\System32\\msdelta.dll" -Destination "$env:SystemRoot\\system32\\msdelta.dll"

    Start-Process -FilePath ${env:ProgramFiles}\\7-zip\\7z.exe  -ArgumentList "x","$env:TEMP\\Win7AndW2K8R2-KB3191566-x64.zip","-o$env:TEMP","Win7AndW2K8R2-KB3191566-x64.msu"
    $7zid = (Get-Process 7z).id; Wait-Process -Id $7zid;
    Start-Process -FilePath ${env:ProgramFiles}\\7-zip\\7z.exe  -ArgumentList "x","$env:TEMP\\Win7AndW2K8R2-KB3191566-x64.msu","-o$env:TEMP","Windows6.1-KB3191566-x64.cab"
    $7zid = (Get-Process 7z).id; Wait-Process -Id $7zid;

    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'cabinet' -Value 'native' -PropertyType 'String' 
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'expand.exe' -Value 'native' -PropertyType 'String' 

    Start-Process expand.exe -ArgumentList "$env:TEMP\\Windows6.1-KB3191566-x64.cab","-F:powershell.exe","$env:TEMP"
    $expandid = (Get-Process expand).id; Wait-Process -Id $expandid;
    Copy-Item -Path "$env:TEMP\\amd64_*\\powershell.exe" -Destination "$env:SystemRoot\\system32\\WindowsPowerShell\\v1.0\\powershell51.exe"
    Copy-Item -Path "$env:TEMP\\wow64_*\\powershell.exe" -Destination "$env:SystemRoot\\syswow64\\WindowsPowerShell\\v1.0\\powershell51.exe"
    Remove-Item -Recurse "$env:TEMP\\amd64_*"  ; Remove-Item -Recurse "$env:TEMP\\wow64_*"  

    Start-Process expand.exe -ArgumentList "$env:TEMP\\Windows6.1-KB3191566-x64.cab","-F:pspluginwkr.dll","$env:TEMP"
    $expandid = (Get-Process expand).id; Wait-Process -Id $expandid;
    Copy-Item -Path "$env:TEMP\\amd64_*\\pspluginwkr.dll" -Destination "$env:SystemRoot\\system32\\pspluginwkr.dll"
    Copy-Item -Path "$env:TEMP\\wow64_*\\pspluginwkr.dll" -Destination "$env:SystemRoot\\syswow64\\pspluginwkr.dll"
    Remove-Item -Recurse "$env:TEMP\\amd64_*"  ; Remove-Item -Recurse "$env:TEMP\\wow64_*"  


    Start-Process expand.exe -ArgumentList "$env:TEMP\\Windows6.1-KB3191566-x64.cab","-F:wsmsvc.dll","$env:TEMP"
    $expandid = (Get-Process expand).id; Wait-Process -Id $expandid;
    Copy-Item -Path "$env:TEMP\\amd64_*\\wsmsvc.dll" -Destination "$env:SystemRoot\\system32\\wsmsvc.dll"
    Copy-Item -Path "$env:TEMP\\wow64_*\\wsmsvc.dll" -Destination "$env:SystemRoot\\syswow64\\wsmsvc.dll"
    Remove-Item -Recurse "$env:TEMP\\amd64_*"  ; Remove-Item -Recurse "$env:TEMP\\wow64_*"  

    Start-Process expand.exe -ArgumentList "$env:TEMP\\Windows6.1-KB3191566-x64.cab","-F:wmitomi.dll","$env:TEMP"
    $expandid = (Get-Process expand).id; Wait-Process -Id $expandid;
    Copy-Item -Path "$env:TEMP\\amd64_*\\wmitomi.dll" -Destination "$env:SystemRoot\\system32\\wmitomi.dll"
    Copy-Item -Path "$env:TEMP\\wow64_*\\wmitomi.dll" -Destination "$env:SystemRoot\\syswow64\\wmitomi.dll"
    Remove-Item -Recurse "$env:TEMP\\amd64_*"  ; Remove-Item -Recurse "$env:TEMP\\wow64_*"  

    Start-Process expand.exe -ArgumentList "$env:TEMP\\Windows6.1-KB3191566-x64.cab","-F:mi.dll","$env:TEMP"
    $expandid = (Get-Process expand).id; Wait-Process -Id $expandid;
    Copy-Item -Path "$env:TEMP\\amd64_*\\mi.dll" -Destination "$env:SystemRoot\\system32\\mi.dll"
    Copy-Item -Path "$env:TEMP\\wow64_*\\mi.dll" -Destination "$env:SystemRoot\\syswow64\\mi.dll"
    Remove-Item -Recurse "$env:TEMP\\amd64_*"  ; Remove-Item -Recurse "$env:TEMP\\wow64_*"  

    New-Item -Path 'HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Management Infrastructure'
    New-Item -Path 'HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Management Infrastructure\\protocols'
    New-Item -Path 'HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Management Infrastructure\\protocols\\WMIDCOM'
    New-Item -Path 'HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Management Infrastructure\\protocols\\WMIDCOM\\1.0'

    New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Management Infrastructure\\protocols\\WMIDCOM\\1.0' -force -Name 'dllEntryPoint' -Value 'MI_Application_InitializeV1' -PropertyType 'String' 
    New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Management Infrastructure\\protocols\\WMIDCOM\\1.0' -force -Name 'dllpath' -Value 'c:\\windows\\system32\\WsmSvc.dll' -PropertyType 'String' 

    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'cabinet' -Value 'builtin' -PropertyType 'String' 
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'expand.exe' -Value 'builtin' -PropertyType 'String' 
}
    Add-Type -AssemblyName PresentationCore,PresentationFramework; [System.Windows.MessageBox]::Show('Chocolatey installed','Congrats','ok','exclamation')
