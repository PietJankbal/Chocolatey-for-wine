    [System.IO.Directory]::SetCurrentDirectory("$env:TEMP")

    (New-Object System.Net.WebClient).DownloadFile("https://www.7-zip.org/a/7z1900-x64.exe", "$env:TEMP\\7z1900-x64.exe")
    (New-Object System.Net.WebClient).DownloadFile("http://download.windowsupdate.com/msdownload/update/software/updt/2009/11/windowsserver2003-kb968930-x64-eng_8ba702aa016e4c5aed581814647f4d55635eff5c.exe", "$env:TEMP\\windowsserver2003-kb968930-x64-eng_8ba702aa016e4c5aed581814647f4d55635eff5c.exe")
    (New-Object System.Net.WebClient).DownloadFile("https://download.microsoft.com/download/9/5/A/95A9616B-7A37-4AF6-BC36-D6EA96C8DAAE/dotNetFx40_Full_x86_x64.exe", "$env:TEMP\\dotNetFx40_Full_x86_x64.exe")
    (New-Object System.Net.WebClient).DownloadFile("https://download.visualstudio.microsoft.com/download/pr/7afca223-55d2-470a-8edc-6a1739ae3252/abd170b4b0ec15ad0222a809b761a036/ndp48-x86-x64-allos-enu.exe", "$env:TEMP\\ndp48-x86-x64-allos-enu.exe")

    Start-Process -FilePath 7z1900-x64.exe -Wait -ArgumentList "/S"


if(Test-Path 'env:SCOOP_INSTALL'){
    (New-Object System.Net.WebClient).DownloadFile("https://download.microsoft.com/download/6/A/E/6AEA92B0-A412-4622-983E-5B305D2EBE56/adk/adksetup.exe", "$env:TEMP\\adksetup.exe")

    #[System.Environment]::SetEnvironmentVariable('OnlyUseLatestCLR', '1',[System.EnvironmentVariableTarget]::Machine)
    #Start-Process reg.exe -Wait  -ArgumentList "add \"HKLM\\Software\\Microsoft\\.NETFramework\" /v OnlyUseLatestCLR /t REG_DWORD /d 0001 /f"
    Write-Host "Downloading and installing adk, this may take quite some time..."
    #Start-Process wineboot.exe  -Wait -ArgumentList "-u"

    Start-Process winecfg.exe  -Wait -ArgumentList "/v win81" 
    
    Write-Host "Downloading and installing adk, this may take quite some time..."

    
    New-Item -Path 'HKCU:\\Software\\Wine\\DllOverrides'
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'aclui' -Value 'builtin' -PropertyType 'String'
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'userenv' -Value 'builtin' -PropertyType 'String'
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'shcore' -Value 'builtin' -PropertyType 'String'
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'hid' -Value 'builtin' -PropertyType 'String'
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'dwmapi' -Value 'builtin' -PropertyType 'String'
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'msctf' -Value 'builtin' -PropertyType 'String'
    

#    (New-Object System.Net.WebClient).DownloadFile("https://download.microsoft.com/download/a/9/4/a94c5d25-3195-43dc-8dbe-28e1a87e1b59/Windows6.0-KB936330-X64-wave1.exe", "$env:TEMP\\Windows6.0-KB936330-X64-wave1.exe")


    Start-Process adksetup.exe  -ArgumentList "/quiet /features OptionId.WindowsPreinstallationEnvironment"
#    $adkid = (Get-Process adksetup).id; Wait-Process -Id $adkid;
     Get-Process adksetup | Foreach-Object { $_.WaitForExit() }
 
    Copy-Item "${env:ProgramFiles`(x86`)}\\Windows Kits\\8.1\\Assessment and Deployment Kit\\Windows Preinstallation Environment\\amd64\\en-us\\winpe.wim" "$env:TEMP\\winpe64.wim"

    Copy-Item "${env:ProgramFiles`(x86`)}\\Windows Kits\\8.1\\Assessment and Deployment Kit\\Windows Preinstallation Environment\\x86\\en-us\\winpe.wim" "$env:TEMP\\winpe32.wim"


  #  Rename-Item "$env:SystemRoot\\win.ini" "$env:SystemRoot\\winbak.ini" 

 #   Remove-Item –path c:\windows –recurse
#7z.exe x -r -aoa
#7z d archive.7z -r dir/

    Start-Process ${env:ProgramFiles}\\7-zip\\7z.exe  -ArgumentList "d","$env:TEMP\\winpe32.wim","-r","Windows/WinSxS/"

    Start-Process ${env:ProgramFiles}\\7-zip\\7z.exe  -ArgumentList "d","$env:TEMP\\winpe64.wim","-r","Windows/WinSxS/"

    Get-Process 7z | Foreach-Object { $_.WaitForExit() }

    Start-Process ${env:ProgramFiles}\\7-zip\\7z.exe  -ArgumentList "rn","$env:TEMP\\winpe32.wim","Windows/System32","Windows/syswow64"
    Get-Process 7z | Foreach-Object { $_.WaitForExit() }
    Start-Process ${env:ProgramFiles}\\7-zip\\7z.exe  -ArgumentList "x","-r","$env:TEMP\\winpe32.wim","-aou","-o$env:SystemDrive","Windows"
    Get-Process 7z | Foreach-Object { $_.WaitForExit() }
    Start-Process ${env:ProgramFiles}\\7-zip\\7z.exe  -ArgumentList "x","-r","$env:TEMP\\winpe64.wim","-aou","-o$env:SystemDrive","Windows"
    Get-Process 7z | Foreach-Object { $_.WaitForExit() }
    #$7zid = (Get-Process 7z).id; Wait-Process -Id $7zid;

#    Rename-Item "$env:TEMP\\pe32\\Windows\System32" "$env:TEMP\\pe32\\Windows\syswow64"
    
   # Copy-Item -Path "$env:TEMP\\pe64\\Windows\\*"  -Destination "C:\\Windows" -Recurse
#    Copy-Item -Path "$env:TEMP\\pe32\\Windows\\syswow64\\*"  -Destination "C:\\Windows\\syswow64" -Recurse -Force

#    Rename-Item "$env:SystemDrive\\winbak.ini" "$env:SystemDrive\\win.ini" -Force 
  #   Get-Process 7z | Foreach-Object { $_.WaitForExit() }


#    Copy-Item -Path "$env:TEMP\\expand.exe" -Destination "$env:SystemRoot\\syswow64\\expand.exe"
 #   Copy-Item -Path "$env:TEMP\\Windows\\System32\\expand.exe" -Destination "$env:SystemRoot\\system32\\expand.exe"

  #  Copy-Item -Path "$env:TEMP\\dpx.dll" -Destination "$env:SystemRoot\\syswow64\\dpx.dll"
  #  Copy-Item -Path "$env:TEMP\\Windows\\System32\\dpx.dll" -Destination "$env:SystemRoot\\system32\\dpx.dll"

 #   Copy-Item -Path "$env:TEMP\\cabinet.dll" -Destination "$env:SystemRoot\\syswow64\\cabinet.dll"
  #  Copy-Item -Path "$env:TEMP\\Windows\\System32\\cabinet.dll" -Destination "$env:SystemRoot\\system32\\cabinet.dll"

   # Copy-Item -Path "$env:TEMP\\msdelta.dll" -Destination "$env:SystemRoot\\syswow64\\msdelta.dll"
#    Copy-Item -Path "$env:TEMP\\Windows\\System32\\msdelta.dll" -Destination "$env:SystemRoot\\system32\\msdelta.dll"

 #   Copy-Item -Path "$env:TEMP\\Robocopy.exe" -Destination "$env:SystemRoot\\syswow64\\robocopy.exe"
  #  Copy-Item -Path "$env:TEMP\\Windows\\WinSxS\\amd64_microsoft-windows-robocopy_31bf3856ad364e35_6.3.9600.16384_none_b7c58f8bc05b432d\\Robocopy.exe" -Destination "$env:SystemRoot\\system32\\robocopy.exe"

   # Copy-Item -Path "$env:TEMP\\mfc42u.dll" -Destination "$env:SystemRoot\\syswow64\\mfc42u.dll"
    #Copy-Item -Path "$env:TEMP\\Windows\\WinSxS\\amd64_microsoft-windows-mfc42x_31bf3856ad364e35_6.3.9600.16384_none_e3d32e4c2985bf8e/mfc42u.dll" -Destination "$env:SystemRoot\\system32\\mfc42u.dll"



#    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'cabinet' -Value 'native' -PropertyType 'String' 
#    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'expand.exe' -Value 'native' -PropertyType 'String' 


    Start-Sleep -Second 10

    Start-Process  "pwsh.exe" -Wait -ArgumentList "-c iwr -useb get.scoop.sh | iex"

    Start-Process  "pwsh.exe" -Wait -ArgumentList "-c scoop config MSIEXTRACT_USE_LESSMSI true"

    Start-Process  "pwsh.exe" -Wait -ArgumentList "-c scoop install 7zip"
    
    #Get-Process pwsh | Foreach-Object { $_.WaitForExit() }

}



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





    #/* Install dotnet48 otherwise choco fails to install packages; procedure copied from winetricks */
    #/* remove_mono */

#FIXME!! Needs to be updated when Mono updates; Find better solution...........
    Start-Process uninstaller -Wait -ArgumentList "--remove {0A7C8977-1185-5C3F-A4E7-7A90611227C3}"
    Start-Process uninstaller  -Wait -ArgumentList "--remove {05C9CD26-9144-58FC-8A6E-B4DE47B661EC}"

    Remove-Item -Path 'HKLM:\\Software\\Microsoft\\NET Framework Setup\\NDP\\v3.5' -Recurse
    Remove-Item -Path 'HKLM:\\Software\\Microsoft\\NET Framework Setup\\NDP\\v4'  -Recurse  

    Remove-Item -Path 'HKLM:\\Software\\Wow6432Node\\Microsoft\\NET Framework Setup\\NDP\\v3.5' -Recurse
    Remove-Item -Path 'HKLM:\\Software\\Wow6432Node\\Microsoft\\NET Framework Setup\\NDP\\v4'  -Recurse  

    Remove-Item -Path "$env:SystemRoot\\SysWOW64\\mscoree.dll" -Force
    Remove-Item -Path "$env:SystemRoot\\System32\\mscoree.dll" -Force
    #/* END remove_mono */

 


   #/* dotnet35 */
if(Test-Path 'env:SCOOP_INSTALL'){

    (New-Object System.Net.WebClient).DownloadFile("https://download.microsoft.com/download/2/0/e/20e90413-712f-438c-988e-fdaa79a8ac3d/dotnetfx35.exe", "$env:TEMP\\dotnetfx35.exe")
    (New-Object System.Net.WebClient).DownloadFile("https://download.microsoft.com/download/6/A/E/6AEA92B0-A412-4622-983E-5B305D2EBE56/adk/adksetup.exe", "$env:TEMP\\adksetup.exe")
    (New-Object System.Net.WebClient).DownloadFile("https://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/Win7AndW2K8R2-KB3191566-x64.zip", "$env:TEMP\\Win7AndW2K8R2-KB3191566-x64.zip")



    New-Item -Path 'HKCU:\\Software\\Wine\\DllOverrides'
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'mscorwks' -Value 'native' -PropertyType 'String'
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'mscoree' -Value 'native' -PropertyType 'String'



    Start-Process winecfg.exe  -Wait -ArgumentList "/v winxp64"
    Start-Process dotnetfx35.exe  -Wait -ArgumentList "/q /lang:ENU"
    $dotnet35id = (Get-Process dotnetfx35).id; Wait-Process -Id $dotnet35id
}
    #/* END dotnet35 */




    New-Item -Path 'HKCU:\\Software\\Wine\\DllOverrides'
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'mscorwks' -Value 'native' -PropertyType 'String'
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'mscoree' -Value 'native' -PropertyType 'String'

    Remove-Item -Path "$env:SystemRoot\\SysWOW64\\mscoree.dll" -Force
    Remove-Item -Path "$env:SystemRoot\\System32\\mscoree.dll" -Force


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

    #"${WINE}" reg add "HKLM\\Software\\Microsoft\\.NETFramework" /v OnlyUseLatestCLR /t REG_DWORD /d 0001 /f
    New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\.NETFramework' -Name 'OnlyUseLatestCLR' -Value '0001' -PropertyType 'DWord'
    New-ItemProperty -Path 'HKLM:\\Software\\Wow6432Node\\Microsoft\\.NETFramework' -Name 'OnlyUseLatestCLR' -Value '0001' -PropertyType 'DWord'

if(Test-Path 'env:SCOOP_INSTALL'){

    $folders = @('msxml3','msxml6','gdiplus','cabinet','msdelta','netapi32','wininet','urlmon','winhttp','windowscodecs', `
                 'riched20','riched32','netcfgx','netutils','oleaut32','msvcrt','msvcirt','mspatcha','msls31','crypt32', `
                 'rsaenh','schannel','iertutil')
    $exe = @('expand','find','cmd','xcopy')
    
    foreach ($i in $folders) {

                              $src = ("$i" + "_1.dll")
                              $dst = ("$i" + ".dll")
                           
                              Copy-Item -Path "$env:winsysdir\\$src" -Destination "$env:winsysdir\\$dst"
                              Copy-Item -Path "$env:windir\\SysWOW64\\$src" -Destination "$env:windir\\SysWOW64\\$dst"

                              }
    foreach ($i in $exe) {

                              $src = ("$i" + "_1.exe")
                              $dst = ("$i" + ".exe")
                           
                              Copy-Item -Path "$env:winsysdir\\$src" -Destination "$env:winsysdir\\$dst"
                              Copy-Item -Path "$env:windir\\SysWOW64\\$src" -Destination "$env:windir\\SysWOW64\\$dst"
                              }
                              
    $native = @('msxml3','msxml6','gdiplus','windowscodecs','riched20','riched32','iertutil')
    foreach ($i in $native) {
                              New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name $i -Value 'native' -PropertyType 'String'
                              }

#    Start-Process wineboot.exe  -Wait -ArgumentList "-u"
    Start-Process winecfg.exe  -Wait -ArgumentList "/v win7" 


    Start-Process -FilePath ${env:ProgramFiles}\\7-zip\\7z.exe  -ArgumentList "x","$env:TEMP\\Win7AndW2K8R2-KB3191566-x64.zip","-o$env:TEMP","Win7AndW2K8R2-KB3191566-x64.msu"
    $7zid = (Get-Process 7z).id; Wait-Process -Id $7zid;
    Start-Process -FilePath ${env:ProgramFiles}\\7-zip\\7z.exe  -ArgumentList "x","$env:TEMP\\Win7AndW2K8R2-KB3191566-x64.msu","-o$env:TEMP","Windows6.1-KB3191566-x64.cab"
    $7zid = (Get-Process 7z).id; Wait-Process -Id $7zid;

    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'cabinet' -Value 'native' -PropertyType 'String' 
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'expand.exe' -Value 'native' -PropertyType 'String' 

    #FIXME try get regkeys from manifest 
    # $Xml = [xml](Get-Content -Path '.\x86_microsoft-windows-msmpeg2vdec_31f3856ad364e35_6.1.7601.23403_none_9391e9c22f5ac446.manifest')
    # $Xml.assembly.registrykeys.registrykey.keyname
    # https://stackoverflow.com/questions/50157672/powershell-importing-registry-values-from-xml
    Start-Process expand.exe -ArgumentList "$env:TEMP\\Windows6.1-KB3191566-x64.cab","-F:powershell.exe","$env:TEMP"
    $expandid = (Get-Process expand).id; Wait-Process -Id $expandid;
    Copy-Item -Path "$env:TEMP\\amd64_*\\powershell.exe" -Destination "$env:SystemRoot\\system32\\WindowsPowerShell\\v1.0\\powershell51.exe"
    Copy-Item -Path "$env:TEMP\\wow64_*\\powershell.exe" -Destination "$env:SystemRoot\\syswow64\\WindowsPowerShell\\v1.0\\powershell51.exe"
    Remove-Item -Recurse "$env:TEMP\\amd64_*"  ; Remove-Item -Recurse "$env:TEMP\\wow64_*"  
    
    $dll_or_exe = @('wmitomi.dll','wsmsvc.dll','wmidcom.dll','pspluginwkr.dll','mi.dll','miutils.dll','Certificate.format.ps1xml','WSMan.Format.ps1xml','PSDiagnostics.psd1')
    $cab = "$env:TEMP\\Windows6.1-KB3191566-x64.cab"

    foreach ($i in $dll_or_exe) {
    Start-Process expand.exe -ArgumentList $cab,"-F:$i","$env:TEMP"
    $expandid = (Get-Process expand).id; Wait-Process -Id $expandid;
#    Copy-Item -Path "$env:TEMP\\amd64_*\\$i" -Destination "$env:SystemRoot\\system32\\$i"
#    Copy-Item -Path "$env:TEMP\\wow64_*\\$i" -Destination "$env:SystemRoot\\syswow64\\$i"
    #also extract manifest


    Function write_keys_from_manifest{
    Param ($filetoget, $amd64_or_wow64, $sys32_or_syswow64, $runtime_system32)

    #Write-Output "$Name's Average = $Avg, $Runs, $Outs"

    #$relativePath = Get-Item $amd64_or_wow64_*\$filetoget | Resolve-Path -Relative
    $relativePath = Resolve-Path  ($amd64_or_wow64 + "_*\$filetoget") -Relative; if (-not ($relativePath)) {Write-Host "empty path for $amd64_or_wow64 $filetoget"; return}
    $manifest = $relativePath.split('\')[1] + ".manifest"
    Start-Process expand.exe -ArgumentList $cab,"-F:$manifest","$env:SystemRoot\\$sys32_or_syswow64\\"
    $expandid = (Get-Process expand).id; Wait-Process -Id $expandid;
    
    
    $Xml = [xml](Get-Content -Path "$env:SystemRoot\\$sys32_or_syswow64\\$manifest")
    #copy files from manifest
#    foreach ($file in  $Xml.assembly.file) {
#    $destpath = '{0}' -f $file.destinationpath
#    $filename = '{0}' -f $file.name

    # $Xml.assembly.file | Where-Object -Property name -eq -Value "profile.ps1"
      $select= $Xml.assembly.file | Where-Object -Property name -eq -Value $filetoget
      $destpath = $select.destinationpath
      $filename = $select.name

    $finalpath = $destpath -replace ([Regex]::Escape('$(runtime.system32)')),"$env:systemroot\$sys32_or_syswow64"
    #$filename
    if (-not (Test-Path -Path $finalpath )) {
        New-Item -Path $finalpath -ItemType directory -Force}


    $absPath =  Resolve-Path  ($amd64_or_wow64 + "_*\$filetoget") #$amd64_or_wow64_*\$filetoget
     Write-Host Abspath is $absPath.Path
     Write-Host finalpath is $finalpath
     

        Copy-Item -Path $absPath.Path -Destination $finalpath -Force

#    Copy-Item -Path "$env:TEMP\\wow64_*\\$filename" -Destination "$finalpath\\$filename"

    
    
    
    
    
    
    
        #try write regkeys from manifest file

#Write the regkeys from manifest file
#thanks some guy from freenode webchat channel powershell who wrote skeleton of this in 4 minutes...
foreach ($key in $Xml.assembly.registryKeys.registryKey) {
    $path = 'Registry::{0}' -f $key.keyName
    
    
        if($amd64_or_wow64 -ne 'amd64')
                {$path = $path -replace 'HKEY_LOCAL_MACHINE\\SOFTWARE','HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node'
                 $path = $path -replace 'HKEY_CLASSES_ROOT','HKEY_CLASSES_ROOT\Wow6432Node'}
    
    if (-not (Test-Path -Path $path)) {
        New-Item -Path $path -ItemType Key -Force
    }

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
        If ($propertyType -eq "Binary") {$hashByteArray = [byte[]] ($value.Value -replace '..', '0x$&,' -split ',' -ne '');New-ItemProperty -Path $path -Name $Regname -Value $hashByteArray  -PropertyType $propertyType -Force}
        else{
        $value.Value = $value.Value -replace ([Regex]::Escape('$(runtime.system32)')),"$env:systemroot\$runtime_system32" #????syswow64??

        New-ItemProperty -Path $path -Name $Regname -Value $value.Value -PropertyType $propertyType -Force}
    }
}

}  
    
     #Param ($filetoget $amd64_or_wow64, $sys32_or_syswow64, $runtime_system32)
     write_keys_from_manifest $i amd64 system32 system32   
     write_keys_from_manifest $i wow64 syswow64 system32  #what should $(runtime.system32) be here, maybe syswow64???????????
















    
    }

   # New-Item -Path 'HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Management Infrastructure'
   # New-Item -Path 'HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Management Infrastructure\\protocols'
   # New-Item -Path 'HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Management Infrastructure\\protocols\\WMIDCOM'
  #  New-Item -Path 'HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Management Infrastructure\\protocols\\WMIDCOM\\1.0'
    #windows10
  #  New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Management Infrastructure\\protocols\\WMIDCOM\\1.0' -force -Name 'dllEntryPoint' -Value 'MI_Application_InitializeV1' -PropertyType 'String' 
     New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Management Infrastructure\\protocols\\WMIDCOM\\1.0' -force -Name 'dllpath' -Value 'c:\\Program Files\\PowerShell\\7\\mi.dll' -PropertyType 'String' 

 #   New-Item -Path 'HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Management Infrastructure\\protocols\\WMIRM'
  #  New-Item -Path 'HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Management Infrastructure\\protocols\\WMIRM\\1.0'

  #  New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Management Infrastructure\\protocols\\WMIRM\\1.0' -force -Name 'dllEntryPoint' -Value 'MI_Application_InitializeV1' -PropertyType 'String' 
  #  New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Management Infrastructure\\protocols\\WMIRM\\1.0' -force -Name 'dllpath' -Value 'c:\\windows\\system32\\WsmSvc.dll' -PropertyType 'String' 

  #  New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'cabinet' -Value 'builtin' -PropertyType 'String' 
  #  New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'expand.exe' -Value 'builtin' -PropertyType 'String' 


    #REGEDIT4

    #[HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Internet Settings\Lockdown_Zones]

    #[HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Internet Settings\Lockdown_Zones\0]

    #https://download.microsoft.com/download/E/7/F/E7F5E0D8-F9DE-4195-9627-A7F884B61686/IE10-Windows6.1-KB2859903-x64.msu 
    # has more recent mshtml etc. but currently only gives black screen (with coreldrawdemo installer). Fall back to ancient ie8 dlls..

    [System.IO.Directory]::SetCurrentDirectory("$env:TEMP")

    (New-Object System.Net.WebClient).DownloadFile("http://download.microsoft.com/download/7/5/4/754D6601-662D-4E39-9788-6F90D8E5C097/IE8-WindowsServer2003-x64-ENU.exe", "$env:TEMP\\IE8-WindowsServer2003-x64-ENU.exe")

    Start-Process ${env:ProgramFiles}\\7-zip\\7z.exe  -ArgumentList "x","$env:TEMP\\IE8-WindowsServer2003-x64-ENU.exe","-y"
    Get-Process 7z | Foreach-Object { $_.WaitForExit() }


    $iedlls = @('ieframe','urlmon','mshtml','iertutil','jscript')

    foreach ($i in $iedlls) {

                              $wsrc = ("w"+"$i"+".dll")
                              $dlls = ("$i"+".dll")
                           
                              Copy-Item -Path "$env:TEMP\\$dlls" -Destination "$env:winsysdir\\$dlls"
                              Copy-Item -Path "$env:TEMP\\wow\\$wsrc" -Destination "$env:windir\\SysWOW64\\$dlls"
                              
                              New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name $i -Value 'native,builtin' -PropertyType 'String'

                              }

    New-Item -Path 'HKLM:\\Software\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Internet Settings\\Lockdown_Zones'
    New-Item -Path 'HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings\\Lockdown_Zones'

    New-Item -Path 'HKLM:\\Software\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Internet Settings\\Lockdown_Zones\\0'
    New-Item -Path 'HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings\\Lockdown_Zones\\0'
}

#KB2454826 KB2519277 KB2533552 KB2533623 KB2534366 KB2670838 kb2701373-v2-64bit KB2842230 KB2919442 KB2999226 KB3063858
#kb4480955 KB4554364 KB4554364 KB4567512 KB976932 

    Copy-Item -Path "$env:windir\\SysWOW64\\WindowsPowerShell\\v1.0\\powershell.exe" -Destination "$env:windir\\SysWOW64\\wusa.exe" -Force
    Copy-Item -Path "$env:winsysdir\\WindowsPowerShell\\v1.0\\powershell.exe" -Destination "$env:winsysdir\\wusa.exe" -Force
#    Copy-Item -Path "$env:winsysdir\\WindowsPowerShell\\v1.0\\powershell.exe" -Destination "$env:winsysdir\\wusadummy.exe" -Force
#    Copy-Item -Path "$env:windir\\SysWOW64\\WindowsPowerShell\\v1.0\\powershell.exe" -Destination "$env:windir\\SysWOW64\\wusadummy.exe" -Force

    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'wusa.exe' -Value 'native' -PropertyType 'String'
    #Start-Process  "winecfg.exe" -Wait -ArgumentList "/v win81"
    Add-Type -AssemblyName PresentationCore,PresentationFramework; [System.Windows.MessageBox]::Show('Chocolatey installed','Congrats','ok','exclamation')
    powershell.exe
