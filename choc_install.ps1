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
    # & "${env:ProgramFiles}\\7-zip\\7z.exe" rn "$env:TEMP\\winpe32.wim"  "Windows/System32" "Windows/syswow64"
     Get-Process 7z | Foreach-Object { $_.WaitForExit() }
     Start-Process ${env:ProgramFiles}\\7-zip\\7z.exe  -ArgumentList "x","-r","$env:TEMP\\winpe32.wim","-aou","-o$env:SystemDrive","Windows"
    # & "${env:ProgramFiles}\\7-zip\\7z.exe" x -r "$env:TEMP\winpe32.wim" -aou "-o$env:SystemDrive" Windows
    Get-Process 7z | Foreach-Object { $_.WaitForExit() }
    Start-Process ${env:ProgramFiles}\\7-zip\\7z.exe  -ArgumentList "x","-r","$env:TEMP\\winpe64.wim","-aou","-o$env:SystemDrive","Windows"
  #   & "${env:ProgramFiles}\\7-zip\\7z.exe" x -r "$env:TEMP\winpe64.wim" -aou "-o$env:SystemDrive" Windows
    Get-Process 7z | Foreach-Object { $_.WaitForExit() }


#$MethodDefinition = @’

#[DllImport(“kernel32.dll”, CharSet = CharSet.Unicode)]

#public static extern bool CopyFile(string lpExistingFileName, string lpNewFileName, bool bFailIfExists);

#‘@

#$Kernel32 = Add-Type -MemberDefinition $MethodDefinition -Name ‘Kernel32’ -Namespace ‘Win32’ -PassThru

# You may now call the CopyFile function

# Copy calc.exe to the user’s desktop

# $Kernel32::CopyFile(“$($Env:SystemRoot)\System32\calc.exe”, “$($Env:USERPROFILE)\Desktop\calc.exe”, $False) 





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


#    New-Item -Path 'HKCU:\\Software\\Wine\\AppDefaults\\expand.exe' -force
#    New-Item -Path 'HKCU:\\Software\\Wine\\AppDefaults\\expand.exe\\DllOverrides' -force  
#    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\expand.exe\\DllOverrides' -force -Name 'cabinet' -Value 'native' -PropertyType 'String'



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
$f = uninstaller --list  | Select-String 'Mono'
$g = $f -split "\|" |Select-string "{"
Uninstaller --remove $g[0]
Uninstaller --remove $g[1]

   # Start-Process uninstaller -Wait -ArgumentList  "--remove", "{0A7C8977-1185-5C3F-A4E7-7A90611227C3}"
   # Start-Process uninstaller -Wait -ArgumentList "--remove", "{05C9CD26-9144-58FC-8A6E-B4DE47B661EC}"
     Get-Process uninstaller | Foreach-Object { $_.WaitForExit() }

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

    if (-not (Test-Path -Path "$env:systemroot\assembly" )) { New-Item -Path "$env:systemroot\assembly"  -ItemType directory -Force}

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

    Remove-Item -Path "$env:SystemRoot\\SysWOW64\\mscoree.dll" #-Force
    Remove-Item -Path "$env:SystemRoot\\System32\\mscoree.dll" #-Force


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


    New-Item -Path 'HKCU:\\Software\\Wine\\AppDefaults\\expand.exe' -force
    New-Item -Path 'HKCU:\\Software\\Wine\\AppDefaults\\expand.exe\\DllOverrides' -force
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\expand.exe\\DllOverrides' -force -Name 'expand.exe' -Value 'native' -PropertyType 'String' 
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\expand.exe\\DllOverrides' -force -Name 'cabinet' -Value 'native' -PropertyType 'String' 


    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'expand.exe' -Value 'native' -PropertyType 'String' 
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'cabinet' -Value 'native' -PropertyType 'String' 


#    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'cabinet' -Value 'native' -PropertyType 'String' 
#    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'expand.exe' -Value 'native' -PropertyType 'String' 

    #FIXME try get regkeys from manifest 
    # $Xml = [xml](Get-Content -Path '.\x86_microsoft-windows-msmpeg2vdec_31f3856ad364e35_6.1.7601.23403_none_9391e9c22f5ac446.manifest')
    # $Xml.assembly.registrykeys.registrykey.keyname
    # https://stackoverflow.com/questions/50157672/powershell-importing-registry-values-from-xml
    Start-Process expand.exe -ArgumentList "$env:TEMP\\Windows6.1-KB3191566-x64.cab","-F:powershell.exe","$env:TEMP"
    $expandid = (Get-Process expand).id; Wait-Process -Id $expandid;
    Copy-Item -Path "$env:TEMP\\amd64_*\\powershell.exe" -Destination "$env:SystemRoot\\system32\\WindowsPowerShell\\v1.0\\powershell51.exe"
    Copy-Item -Path "$env:TEMP\\wow64_*\\powershell.exe" -Destination "$env:SystemRoot\\syswow64\\WindowsPowerShell\\v1.0\\powershell51.exe"
    Remove-Item -Recurse "$env:TEMP\\amd64_*"  ; Remove-Item -Recurse "$env:TEMP\\wow64_*"  
    # remove the _en-us_ _it-it_ etc from list: grep -v '_[[:alpha:]]\{1,\}-[[:alpha:]]\{1,\}_'
    $dll_or_exe = (`
'amd64_microsoft.managemen..frastructure.native_31bf3856ad364e35_7.3.7601.16384_none_8ab57567838da803/microsoft.management.infrastructure.native.dll',`
'amd64_microsoft.managemen..mcmdlets.deployment_31bf3856ad364e35_7.3.7601.16384_none_f2d33d24ddc237ab/cimcmdlets.psd1',`
'amd64_microsoft.managemen..re.native.unmanaged_31bf3856ad364e35_7.3.7601.16384_none_85c07ad567985f16/microsoft.management.infrastructure.native.unmanaged.dll',`
'amd64_microsoft.management.odata.events_31bf3856ad364e35_7.3.7601.16384_none_406f4df63a19de94/modataevents.dll',`
'amd64_microsoft.management.odata.perfcounters_31bf3856ad364e35_7.3.7601.16384_none_8d4938e0b9e6cf31/modataperfcounters.dll',`
'amd64_microsoft-networksw..anagement-component_31bf3856ad364e35_7.3.7601.16384_none_2b05c5d83624b512/cmdlethelpers.psm1',`
'amd64_microsoft-networksw..anagement-component_31bf3856ad364e35_7.3.7601.16384_none_2b05c5d83624b512/networkswitchconfiguration.psm1',`
'amd64_microsoft-networksw..anagement-component_31bf3856ad364e35_7.3.7601.16384_none_2b05c5d83624b512/networkswitchethernetport.psm1',`
'amd64_microsoft-networksw..anagement-component_31bf3856ad364e35_7.3.7601.16384_none_2b05c5d83624b512/networkswitchfeature.psm1',`
'amd64_microsoft-networksw..anagement-component_31bf3856ad364e35_7.3.7601.16384_none_2b05c5d83624b512/networkswitchglobalsettingdata.psm1',`
'amd64_microsoft-networksw..anagement-component_31bf3856ad364e35_7.3.7601.16384_none_2b05c5d83624b512/networkswitchmanager.format.ps1xml',`
'amd64_microsoft-networksw..anagement-component_31bf3856ad364e35_7.3.7601.16384_none_2b05c5d83624b512/networkswitchmanager.psd1',`
'amd64_microsoft-networksw..anagement-component_31bf3856ad364e35_7.3.7601.16384_none_2b05c5d83624b512/networkswitchmanager.types.ps1xml',`
'amd64_microsoft-networksw..anagement-component_31bf3856ad364e35_7.3.7601.16384_none_2b05c5d83624b512/networkswitchvlan.psm1',`
'amd64_microsoft.packagema..ement.coreproviders_31bf3856ad364e35_7.3.7601.16384_none_e608061da75cac41/microsoft.packagemanagement.coreproviders.dll',`
'amd64_microsoft.packagemanagement_31bf3856ad364e35_7.3.7601.16384_none_f23f0a687ff51c88/microsoft.packagemanagement.dll',`
'amd64_microsoft.packagemanagement.common_31bf3856ad364e35_7.3.7601.16384_none_ee66270965c165ab/packagemanagement.format.ps1xml',`
'amd64_microsoft.packagemanagement.common_31bf3856ad364e35_7.3.7601.16384_none_ee66270965c165ab/packagemanagement.psd1',`
'amd64_microsoft.packagemanagement.common_31bf3856ad364e35_7.3.7601.16384_none_ee66270965c165ab/packageproviderfunctions.psm1',`
'amd64_microsoft.packagemanagement.msiprovider_31bf3856ad364e35_7.3.7601.16384_none_ae42a045a84e072e/microsoft.packagemanagement.msiprovider.dll',`
'amd64_microsoft.packagemanagement.msuprovider_31bf3856ad364e35_7.3.7601.16384_none_1d94626aaa846d42/microsoft.packagemanagement.msuprovider.dll',`
'amd64_microsoft.packagema..provider.powershell_31bf3856ad364e35_7.3.7601.16384_none_eabaaa48c94e7a15/microsoft.packagemanagement.metaprovider.powershell.dll',`
'amd64_microsoft.packagema..t.archiverproviders_31bf3856ad364e35_7.3.7601.16384_none_a98e3ebb18648eb6/microsoft.packagemanagement.archiverproviders.dll',`
'amd64_microsoft.powershell.archive_31bf3856ad364e35_7.3.7601.16384_none_f7ab4242f320bef0/microsoft.powershell.archive.psd1',`
'amd64_microsoft.powershell.archive_31bf3856ad364e35_7.3.7601.16384_none_f7ab4242f320bef0/microsoft.powershell.archive.psm1',`
'amd64_microsoft.powershell.dsc_31bf3856ad364e35_7.3.7601.16384_none_c5414d3f28319934/disable-dscdebug.cdxml',`
'amd64_microsoft.powershell.dsc_31bf3856ad364e35_7.3.7601.16384_none_c5414d3f28319934/enable-dscdebug.cdxml',`
'amd64_microsoft.powershell.dsc_31bf3856ad364e35_7.3.7601.16384_none_c5414d3f28319934/get-dscconfiguration.cdxml',`
'amd64_microsoft.powershell.dsc_31bf3856ad364e35_7.3.7601.16384_none_c5414d3f28319934/get-dscconfigurationstatus.cdxml',`
'amd64_microsoft.powershell.dsc_31bf3856ad364e35_7.3.7601.16384_none_c5414d3f28319934/get-dsclocalconfigurationmanager.cdxml',`
'amd64_microsoft.powershell.dsc_31bf3856ad364e35_7.3.7601.16384_none_c5414d3f28319934/psdesiredstateconfiguration.format.ps1xml',`
'amd64_microsoft.powershell.dsc_31bf3856ad364e35_7.3.7601.16384_none_c5414d3f28319934/psdesiredstateconfiguration.psd1',`
'amd64_microsoft.powershell.dsc_31bf3856ad364e35_7.3.7601.16384_none_c5414d3f28319934/psdesiredstateconfiguration.psm1',`
'amd64_microsoft.powershell.dsc_31bf3856ad364e35_7.3.7601.16384_none_c5414d3f28319934/psdesiredstateconfiguration.types.ps1xml',`
'amd64_microsoft.powershell.dsc_31bf3856ad364e35_7.3.7601.16384_none_c5414d3f28319934/remove-dscconfigurationdocument.cdxml',`
'amd64_microsoft.powershell.dsc_31bf3856ad364e35_7.3.7601.16384_none_c5414d3f28319934/restore-dscconfiguration.cdxml',`
'amd64_microsoft.powershell.dsc_31bf3856ad364e35_7.3.7601.16384_none_c5414d3f28319934/stop-dscconfiguration.cdxml',`
'amd64_microsoft.powershell.dsc_31bf3856ad364e35_7.3.7601.16384_none_c5414d3f28319934/webdownloadmanager.psd1',`
'amd64_microsoft.powershell.dsc.managedworker_31bf3856ad364e35_7.3.7601.16384_none_85727e5a66d176db/dscpspluginwkr.dll',`
'amd64_microsoft.powershell.dsc.mpeval_31bf3856ad364e35_7.3.7601.16384_none_0a1349d786324b6b/mpeval.dll',`
'amd64_microsoft.powershell.dsc.mpeval_31bf3856ad364e35_7.3.7601.16384_none_0a1349d786324b6b/mpeval.mof',`
'amd64_microsoft.powershell.dsc.mpunits_31bf3856ad364e35_7.3.7601.16384_none_959143af27700eca/mpunits.dll',`
'amd64_microsoft.powershell.dsc.proxy_31bf3856ad364e35_7.3.7601.16384_none_8d98fd7ee457d1dc/dscproxy.dll',`
'amd64_microsoft.powershell.dsc.proxy_31bf3856ad364e35_7.3.7601.16384_none_8d98fd7ee457d1dc/dscproxy.mof',`
'amd64_microsoft.powershell.dsc.proxy.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_8a2f6ac5652a8762/dscproxy.dll.mui',`
'amd64_microsoft.powershell.dsc.proxy.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_8a2f6ac5652a8762/dscproxy.mfl',`
'amd64_microsoft.powershell.dsc.pullserver_31bf3856ad364e35_7.3.7601.16384_none_c512c91bac913f92/devices.mdb',`
'amd64_microsoft.powershell.dsc.pullserver_31bf3856ad364e35_7.3.7601.16384_none_c512c91bac913f92/global.asax',`
'amd64_microsoft.powershell.dsc.pullserver_31bf3856ad364e35_7.3.7601.16384_none_c512c91bac913f92/iisselfsignedcertmodule.dll',`
'amd64_microsoft.powershell.dsc.pullserver_31bf3856ad364e35_7.3.7601.16384_none_c512c91bac913f92/microsoft.powershell.desiredstateconfiguration.service.dll',`
'amd64_microsoft.powershell.dsc.pullserver_31bf3856ad364e35_7.3.7601.16384_none_c512c91bac913f92/psdsccomplianceserver.config',`
'amd64_microsoft.powershell.dsc.pullserver_31bf3856ad364e35_7.3.7601.16384_none_c512c91bac913f92/psdsccomplianceserver.mof',`
'amd64_microsoft.powershell.dsc.pullserver_31bf3856ad364e35_7.3.7601.16384_none_c512c91bac913f92/psdsccomplianceserver.svc',`
'amd64_microsoft.powershell.dsc.pullserver_31bf3856ad364e35_7.3.7601.16384_none_c512c91bac913f92/psdsccomplianceserver.xml',`
'amd64_microsoft.powershell.dsc.pullserver_31bf3856ad364e35_7.3.7601.16384_none_c512c91bac913f92/psdscpullserver.config',`
'amd64_microsoft.powershell.dsc.pullserver_31bf3856ad364e35_7.3.7601.16384_none_c512c91bac913f92/psdscpullserver.mof',`
'amd64_microsoft.powershell.dsc.pullserver_31bf3856ad364e35_7.3.7601.16384_none_c512c91bac913f92/psdscpullserver.svc',`
'amd64_microsoft.powershell.dsc.pullserver_31bf3856ad364e35_7.3.7601.16384_none_c512c91bac913f92/psdscpullserver.xml',`
'amd64_microsoft.powershell.dsc.pullserver_31bf3856ad364e35_7.3.7601.16384_none_c512c91bac913f92/psdscserverevents.dll',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/compositeresourcehelper.psm1',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/dscresourcehelper.psm1',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/groupset.psd1',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/groupset.schema.psm1',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/msft_archiveresource.psm1',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/msft_archiveresource.schema.mof',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/msft_environmentresource.psm1',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/msft_environmentresource.schema.mof',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/msft_groupresource.psm1',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/msft_groupresource.schema.mof',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/msft_logresource.schema.mof',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/msft_packageresource.psm1',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/msft_packageresource.schema.mof',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/msft_processresource.psm1',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/msft_processresource.schema.mof',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/msft_registryresource.psm1',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/msft_registryresource.schema.mof',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/msft_roleresource.psm1',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/msft_roleresource.schema.mof',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/msft_scriptresource.psm1',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/msft_scriptresource.schema.mof',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/msft_serviceresource.psm1',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/msft_serviceresource.schema.mof',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/msft_userresource.psm1',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/msft_userresource.schema.mof',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/msft_waitforall.psm1',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/msft_waitforall.schema.mof',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/msft_waitforany.psm1',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/msft_waitforany.schema.mof',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/msft_waitforsome.psm1',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/msft_waitforsome.schema.mof',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/processset.psd1',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/processset.schema.psm1',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/psdscxmachine.psm1',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/runashelper.psm1',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/serviceset.psd1',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/serviceset.schema.psm1',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/windowsfeatureset.psd1',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/windowsfeatureset.schema.psm1',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/windowsoptionalfeatureset.psd1',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/windowsoptionalfeatureset.schema.psm1',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/windowspackagecab.cs',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/windowspackagecab.psd1',`
'amd64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_7a1733867cefe7ed/windowspackagecab.psm1',`
'amd64_microsoft.powershell.odatautils_31bf3856ad364e35_7.3.7601.16384_none_ba9bb6402beeb6ae/microsoft.powershell.odataadapter.ps1',`
'amd64_microsoft.powershell.odatautils_31bf3856ad364e35_7.3.7601.16384_none_ba9bb6402beeb6ae/microsoft.powershell.odatautilshelper.ps1',`
'amd64_microsoft.powershell.odatautils_31bf3856ad364e35_7.3.7601.16384_none_ba9bb6402beeb6ae/microsoft.powershell.odatautils.psd1',`
'amd64_microsoft.powershell.odatautils_31bf3856ad364e35_7.3.7601.16384_none_ba9bb6402beeb6ae/microsoft.powershell.odatautils.psm1',`
'amd64_microsoft.powershell.odatautils_31bf3856ad364e35_7.3.7601.16384_none_ba9bb6402beeb6ae/microsoft.powershell.odatav4adapter.ps1',`
'amd64_microsoft.powershell.packagemanagement_31bf3856ad364e35_7.3.7601.16384_none_b4441ea69b526c0b/microsoft.powershell.packagemanagement.dll',`
'amd64_microsoft.powershell.psget_31bf3856ad364e35_7.3.7601.16384_none_c9db05c823f10f09/powershellget.psd1',`
'amd64_microsoft.powershell.psget_31bf3856ad364e35_7.3.7601.16384_none_c9db05c823f10f09/psget.format.ps1xml',`
'amd64_microsoft.powershell.psget_31bf3856ad364e35_7.3.7601.16384_none_c9db05c823f10f09/psget.resource.psd1',`
'amd64_microsoft.powershell.psget_31bf3856ad364e35_7.3.7601.16384_none_c9db05c823f10f09/psmodule.psm1',`
'amd64_microsoft.powershell.scheduledjob.module_31bf3856ad364e35_7.3.7601.16384_none_f695e8419979e172/psscheduledjob.format.ps1xml',`
'amd64_microsoft.powershell.scheduledjob.module_31bf3856ad364e35_7.3.7601.16384_none_f695e8419979e172/psscheduledjob.psd1',`
'amd64_microsoft.powershell.scheduledjob.module_31bf3856ad364e35_7.3.7601.16384_none_f695e8419979e172/psscheduledjob.types.ps1xml',`
'amd64_microsoft.powershell.workflow_31bf3856ad364e35_7.3.7601.16384_none_5c8d324c56833a77/psworkflow.psd1',`
'amd64_microsoft.powershell.workflow_31bf3856ad364e35_7.3.7601.16384_none_5c8d324c56833a77/psworkflow.psm1',`
'amd64_microsoft.powershell.workflow_31bf3856ad364e35_7.3.7601.16384_none_5c8d324c56833a77/psworkflow.types.ps1xml',`
'amd64_microsoft.powershell.workflow_31bf3856ad364e35_7.3.7601.16384_none_5c8d324c56833a77/psworkflowutility.psd1',`
'amd64_microsoft.powershell.workflow_31bf3856ad364e35_7.3.7601.16384_none_5c8d324c56833a77/psworkflowutility.psm1',`
'amd64_microsoft.powershel..nfigurationprovider_31bf3856ad364e35_7.3.7601.16384_none_d915010a0c1be306/baseresource.schema.mof',`
'amd64_microsoft.powershel..nfigurationprovider_31bf3856ad364e35_7.3.7601.16384_none_d915010a0c1be306/dsccoreconfprov.dll',`
'amd64_microsoft.powershel..nfigurationprovider_31bf3856ad364e35_7.3.7601.16384_none_d915010a0c1be306/dsccoreconfprov.mof',`
'amd64_microsoft.powershel..nfigurationprovider_31bf3856ad364e35_7.3.7601.16384_none_d915010a0c1be306/msft_dscmetaconfiguration.mof',`
'amd64_microsoft.powershel..nfigurationprovider_31bf3856ad364e35_7.3.7601.16384_none_d915010a0c1be306/msft_filedirectoryconfiguration.registration.mof',`
'amd64_microsoft.powershel..nfigurationprovider_31bf3856ad364e35_7.3.7601.16384_none_d915010a0c1be306/msft_filedirectoryconfiguration.schema.mof',`
'amd64_microsoft.powershel..nfigurationprovider_31bf3856ad364e35_7.3.7601.16384_none_d915010a0c1be306/msft_metaconfigurationextensionclasses.schema.mof',`
'amd64_microsoft.powershel..nloadmanager.events_31bf3856ad364e35_7.3.7601.16384_none_065b7e35d11633b0/psdscfiledownloadmanagerevents.dll',`
'amd64_microsoft.powershel..nprovider.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_bdd2a6b54f85bede/baseresource.schema.mfl',`
'amd64_microsoft.powershel..nprovider.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_bdd2a6b54f85bede/dsccoreconfprov.dll.mui',`
'amd64_microsoft.powershel..nprovider.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_bdd2a6b54f85bede/dsccoreconfprov.mfl',`
'amd64_microsoft.powershel..nprovider.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_bdd2a6b54f85bede/msft_dscmetaconfiguration.mfl',`
'amd64_microsoft.powershel..nprovider.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_bdd2a6b54f85bede/msft_filedirectoryconfiguration.registration.mfl',`
'amd64_microsoft.powershel..nprovider.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_bdd2a6b54f85bede/msft_filedirectoryconfiguration.schema.mfl',`
'amd64_microsoft.powershel..nprovider.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_bdd2a6b54f85bede/msft_metaconfigurationextensionclasses.schema.mfl',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_eef2e374494701f9/archiveprovider.psd1',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_eef2e374494701f9/msft_archiveresource.schema.mfl',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_eef2e374494701f9/msft_environmentresource.schema.mfl',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_eef2e374494701f9/msft_environmentresource.strings.psd1',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_eef2e374494701f9/msft_groupresource.schema.mfl',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_eef2e374494701f9/msft_groupresource.strings.psd1',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_eef2e374494701f9/msft_logresource.schema.mfl',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_eef2e374494701f9/msft_packageresource.schema.mfl',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_eef2e374494701f9/msft_processresource.schema.mfl',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_eef2e374494701f9/msft_processresource.strings.psd1',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_eef2e374494701f9/msft_registryresource.schema.mfl',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_eef2e374494701f9/msft_registryresource.strings.psd1',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_eef2e374494701f9/msft_roleresource.schema.mfl',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_eef2e374494701f9/msft_roleresourcestrings.psd1',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_eef2e374494701f9/msft_scriptresource.schema.mfl',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_eef2e374494701f9/msft_scriptresourcestrings.psd1',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_eef2e374494701f9/msft_serviceresource.schema.mfl',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_eef2e374494701f9/msft_serviceresource.strings.psd1',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_eef2e374494701f9/msft_userresource.schema.mfl',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_eef2e374494701f9/msft_userresource.strings.psd1',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_eef2e374494701f9/msft_waitforall.schema.mfl',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_eef2e374494701f9/msft_waitforany.schema.mfl',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_eef2e374494701f9/msft_waitforsome.schema.mfl',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_eef2e374494701f9/packageprovider.psd1',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_eef2e374494701f9/psdscxmachine.strings.psd1',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_eef2e374494701f9/runashelper.strings.psd1',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_eef2e374494701f9/windowspackagecab.strings.psd1',`
'amd64_microsoft.powershel..sc.mpeval.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_e9a304b095554141/mpeval.dll.mui',`
'amd64_microsoft.powershel..sc.mpeval.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_e9a304b095554141/mpeval.mfl',`
'amd64_microsoft.windows.dsc.core_31bf3856ad364e35_7.3.7601.16384_none_ee28ef4c400e8037/dsccore.dll',`
'amd64_microsoft.windows.dsc.core_31bf3856ad364e35_7.3.7601.16384_none_ee28ef4c400e8037/dsccore.mof',`
'amd64_microsoft.windows.dsc.core.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_87a23e7b99f4797f/dsccore.dll.mui',`
'amd64_microsoft.windows.dsc.core.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_87a23e7b99f4797f/dsccore.mfl',`
'amd64_microsoft.windows.dsc.dsctimer_31bf3856ad364e35_7.3.7601.16384_none_6d717b0437e7ccb3/dsctimer.dll',`
'amd64_microsoft.windows.dsc.dsctimer_31bf3856ad364e35_7.3.7601.16384_none_6d717b0437e7ccb3/dsctimer.mof',`
'amd64_microsoft.windows.dsc.dsctimer.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_98639bcfc484d1c9/dsctimer.dll.mui',`
'amd64_microsoft.windows.dsc.dsctimer.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_98639bcfc484d1c9/dsctimer.mfl',`
'amd64_microsoft-windows-eventcollector_31bf3856ad364e35_7.3.7601.16384_none_dab622ad54088a83/wecapi.dll',`
'amd64_microsoft-windows-eventcollector_31bf3856ad364e35_7.3.7601.16384_none_dab622ad54088a83/wecsvc.dll',`
'amd64_microsoft-windows-eventcollector_31bf3856ad364e35_7.3.7601.16384_none_dab622ad54088a83/wecutil.exe',`
'amd64_microsoft-windows-eventforwarding-adm_31bf3856ad364e35_7.3.7601.16384_none_d03f891a012c2ca8/eventforwarding.admx',`
'amd64_microsoft-windows-eventlog-forwardplugin_31bf3856ad364e35_7.3.7601.16384_none_5512a920cd2f7dab/wevtfwd.dll',`
'amd64_microsoft-windows-gpowershell-exe_31bf3856ad364e35_7.3.7601.16384_none_18399f68810ab2ef/ise.psd1',`
'amd64_microsoft-windows-gpowershell-exe_31bf3856ad364e35_7.3.7601.16384_none_18399f68810ab2ef/ise.psm1',`
'amd64_microsoft-windows-gpowershell-exe_31bf3856ad364e35_7.3.7601.16384_none_18399f68810ab2ef/powershell_ise.exe',`
'amd64_microsoft-windows-gpowershell-exe_31bf3856ad364e35_7.3.7601.16384_none_18399f68810ab2ef/powershell_ise.exe.config',`
'amd64_microsoft-windows-mistreamprovider_31bf3856ad364e35_7.3.7601.16384_none_c8d405fc0a29a761/mistreamprov.dll',`
'amd64_microsoft-windows-mistreamprovider_31bf3856ad364e35_7.3.7601.16384_none_c8d405fc0a29a761/mistreamprov.mof',`
'amd64_microsoft-windows-mistreamprovider_31bf3856ad364e35_7.3.7601.16384_none_c8d405fc0a29a761/mistreamprov_uninstall.mof',`
'amd64_microsoft-windows-mistreamprovider_31bf3856ad364e35_7.3.7601.16384_none_c8d405fc0a29a761/silsysprep.dll',`
'amd64_microsoft-windows-m..mprovider.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_5c1cc323c6a98e2b/mistreamprov.dll.mui',`
'amd64_microsoft-windows-m..mprovider.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_5c1cc323c6a98e2b/mistreamprov.mfl',`
'amd64_microsoft-windows-m..mprovider.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_5c1cc323c6a98e2b/mistreamprov_uninstall.mfl',`
'amd64_microsoft-windows-m..reamprovider-module_31bf3856ad364e35_7.3.7601.16384_none_401512d9fe7a62f4/msft_mistreamtasks.cdxml',`
'amd64_microsoft-windows-powershell_31bf3856ad364e35_7.3.7601.16384_none_dcd932aa8610ea09/certificate.format.ps1xml',`
'amd64_microsoft-windows-powershell_31bf3856ad364e35_7.3.7601.16384_none_dcd932aa8610ea09/diagnostics.format.ps1xml',`
'amd64_microsoft-windows-powershell_31bf3856ad364e35_7.3.7601.16384_none_dcd932aa8610ea09/dotnettypes.format.ps1xml',`
'amd64_microsoft-windows-powershell_31bf3856ad364e35_7.3.7601.16384_none_dcd932aa8610ea09/filesystem.format.ps1xml',`
'amd64_microsoft-windows-powershell_31bf3856ad364e35_7.3.7601.16384_none_dcd932aa8610ea09/getevent.types.ps1xml',`
'amd64_microsoft-windows-powershell_31bf3856ad364e35_7.3.7601.16384_none_dcd932aa8610ea09/help.format.ps1xml',`
'amd64_microsoft-windows-powershell_31bf3856ad364e35_7.3.7601.16384_none_dcd932aa8610ea09/powershellcore.format.ps1xml',`
'amd64_microsoft-windows-powershell_31bf3856ad364e35_7.3.7601.16384_none_dcd932aa8610ea09/powershelltrace.format.ps1xml',`
'amd64_microsoft-windows-powershell_31bf3856ad364e35_7.3.7601.16384_none_dcd932aa8610ea09/profile.ps1',`
'amd64_microsoft-windows-powershell_31bf3856ad364e35_7.3.7601.16384_none_dcd932aa8610ea09/psdiagnostics.psd1',`
'amd64_microsoft-windows-powershell_31bf3856ad364e35_7.3.7601.16384_none_dcd932aa8610ea09/psdiagnostics.psm1',`
'amd64_microsoft-windows-powershell_31bf3856ad364e35_7.3.7601.16384_none_dcd932aa8610ea09/registry.format.ps1xml',`
'amd64_microsoft-windows-powershell_31bf3856ad364e35_7.3.7601.16384_none_dcd932aa8610ea09/types.ps1xml',`
'amd64_microsoft-windows-powershell_31bf3856ad364e35_7.3.7601.16384_none_dcd932aa8610ea09/windows powershell.lnk',`
'amd64_microsoft-windows-powershell_31bf3856ad364e35_7.3.7601.16384_none_dcd932aa8610ea09/windows powershell (x86).lnk',`
'amd64_microsoft-windows-powershell_31bf3856ad364e35_7.3.7601.16384_none_dcd932aa8610ea09/wsman.format.ps1xml',`
'amd64_microsoft-windows-powershell-adm_31bf3856ad364e35_7.3.7601.16384_none_48d50221e17a9af6/powershellexecutionpolicy.admx',`
'amd64_microsoft.windows.powershell.dsc.events_31bf3856ad364e35_7.3.7601.16384_none_f8ae867317563762/dsccorer.dll',`
'amd64_microsoft-windows-powershell-events_31bf3856ad364e35_7.3.7601.16384_none_b87aa2f9825e90a3/psevents.dll',`
<#'amd64_microsoft-windows-powershell-exe_31bf3856ad364e35_7.3.7601.16384_none_48be7e79e188387e/powershell.exe',#>`
'amd64_microsoft-windows-powershell-message_31bf3856ad364e35_7.3.7601.16384_none_0ced77cc17ba7907/pwrshmsg.dll',`
'amd64_microsoft-windows-powershell-sip_31bf3856ad364e35_7.3.7601.16384_none_481720a3e2085d7e/pwrshsip.dll',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/baseconditional.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/base.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/blockcommon.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/blocksoftware.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/block.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/command.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/conditionset.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/developercommand.rld',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/developercommand.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/developermanagedclass.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/developermanagedconstructor.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/developermanageddelegate.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/developermanagedenumeration.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/developermanagedevent.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/developermanagedfield.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/developermanagedinterface.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/developermanagedmethod.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/developermanagednamespace.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/developermanagedoperator.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/developermanagedoverload.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/developermanagedproperty.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/developermanagedstructure.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/developermanaged.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/developerreference.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/developerstructure.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/developerxaml.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/developer.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/enduser.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/event.format.ps1xml',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/faq.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/glossary.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/helpv3.format.ps1xml',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/hierarchy.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/inlinecommon.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/inlinesoftware.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/inlineui.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/inline.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/itpro.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/maml_html_style.xsl',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/maml_html.xsl',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/maml.rld',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/maml.tbr',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/maml.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/maml.xsx',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/manageddeveloperstructure.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/manageddeveloper.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/microsoft.powershell.diagnostics.psd1',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/microsoft.powershell.host.psd1',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/microsoft.powershell.management.psd1',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/microsoft.powershell.security.psd1',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/microsoft.powershell.utility.psd1',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/microsoft.powershell.utility.psm1',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/providerhelp.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/shellexecute.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/structureglossary.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/structurelist.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/structureprocedure.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/structuretable.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/structuretaskexecution.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/structure.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/task.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/troubleshooting.xsd',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/typesv3.ps1xml',`
'amd64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_77331ae862faf7ef/wmf3.inf',`
'amd64_microsoft.windows.powershell.v3.wsman_31bf3856ad364e35_7.3.7601.16384_none_da4925265ab933b4/microsoft.wsman.management.psd1',`
'amd64_microsoft-windows-p..rshell-wsman-plugin_31bf3856ad364e35_7.3.7601.16384_none_56b7be1dc81a819a/pwrshplugin.dll',`
'amd64_microsoft-windows-p..-wsman-pluginworker_31bf3856ad364e35_7.3.7601.16384_none_3fa320855ec191a8/pspluginwkr.dll',`
'amd64_microsoft-windows-s..anager-mgmtprovider_31bf3856ad364e35_7.3.7601.16384_none_6d6f9b6d42d331cb/calluxxprovider.vbs',`
'amd64_microsoft-windows-s..anager-mgmtprovider_31bf3856ad364e35_7.3.7601.16384_none_6d6f9b6d42d331cb/featureinfodl.xml',`
'amd64_microsoft-windows-s..anager-mgmtprovider_31bf3856ad364e35_7.3.7601.16384_none_6d6f9b6d42d331cb/mgmtprovider.dll',`
'amd64_microsoft-windows-s..anager-mgmtprovider_31bf3856ad364e35_7.3.7601.16384_none_6d6f9b6d42d331cb/mgmtprovider.mof',`
'amd64_microsoft-windows-s..anager-mgmtprovider_31bf3856ad364e35_7.3.7601.16384_none_6d6f9b6d42d331cb/mgmtprovider_uninstall.mof',`
'amd64_microsoft-windows-selplugin_31bf3856ad364e35_7.3.7601.16384_none_62e17a8cd110db21/wsmselpl.dll',`
'amd64_microsoft-windows-selplugin_31bf3856ad364e35_7.3.7601.16384_none_62e17a8cd110db21/wsmselrr.dll',`
'amd64_microsoft-windows-s..ging-scheduledtasks_31bf3856ad364e35_7.3.7601.16384_none_db11c3b567e6b732/silcollector.cmd',`
'amd64_microsoft-windows-s..ging-scheduledtasks_31bf3856ad364e35_7.3.7601.16384_none_db11c3b567e6b732/silstream.mof',`
'amd64_microsoft-windows-s..ntorylogging-module_31bf3856ad364e35_7.3.7601.16384_none_cc16ef0913cde161/msftsil_computer.cdxml',`
'amd64_microsoft-windows-s..ntorylogging-module_31bf3856ad364e35_7.3.7601.16384_none_cc16ef0913cde161/msftsil_computeridentity.cdxml',`
'amd64_microsoft-windows-s..ntorylogging-module_31bf3856ad364e35_7.3.7601.16384_none_cc16ef0913cde161/msftsil_data.cdxml',`
'amd64_microsoft-windows-s..ntorylogging-module_31bf3856ad364e35_7.3.7601.16384_none_cc16ef0913cde161/msftsil_managementtasks.psm1',`
'amd64_microsoft-windows-s..ntorylogging-module_31bf3856ad364e35_7.3.7601.16384_none_cc16ef0913cde161/msftsil_software.cdxml',`
'amd64_microsoft-windows-s..ntorylogging-module_31bf3856ad364e35_7.3.7601.16384_none_cc16ef0913cde161/msftsil_ualaccess.cdxml',`
'amd64_microsoft-windows-s..ntorylogging-module_31bf3856ad364e35_7.3.7601.16384_none_cc16ef0913cde161/msftsil_windowsupdate.cdxml',`
'amd64_microsoft-windows-s..ntorylogging-module_31bf3856ad364e35_7.3.7601.16384_none_cc16ef0913cde161/softwareinventorylogging.format.ps1xml',`
'amd64_microsoft-windows-s..ntorylogging-module_31bf3856ad364e35_7.3.7601.16384_none_cc16ef0913cde161/softwareinventorylogging.psd1',`
'amd64_microsoft-windows-s..ntorylogging-module_31bf3856ad364e35_7.3.7601.16384_none_cc16ef0913cde161/softwareinventorylogging.types.ps1xml',`
'amd64_microsoft-windows-s..orylogging-provider_31bf3856ad364e35_7.3.7601.16384_none_04a986e0dedff222/silprovider.dll',`
'amd64_microsoft-windows-s..orylogging-provider_31bf3856ad364e35_7.3.7601.16384_none_04a986e0dedff222/silprovider.mof',`
'amd64_microsoft-windows-s..orylogging-provider_31bf3856ad364e35_7.3.7601.16384_none_04a986e0dedff222/silprovider_uninstall.mof',`
'amd64_microsoft-windows-s..-provider.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_7c835a3dd8233c32/silprovider.dll.mui',`
'amd64_microsoft-windows-s..-provider.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_7c835a3dd8233c32/silprovider.mfl',`
'amd64_microsoft-windows-s..-provider.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_7c835a3dd8233c32/silprovider_uninstall.mfl',`
'amd64_microsoft-windows-s..tprovider.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_1f9a065cfe468889/mgmtprovider.dll.mui',`
'amd64_microsoft-windows-s..tprovider.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_1f9a065cfe468889/mgmtprovider.mfl',`
'amd64_microsoft-windows-s..tprovider.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_1f9a065cfe468889/mgmtprovider_uninstall.mfl',`
'amd64_microsoft-windows-w..adapter-wmitomi-dll_31bf3856ad364e35_7.3.7601.16384_none_5af4c06e966e0853/wmitomi.dll',`
'amd64_microsoft-windows-w..emotemanagement-adm_31bf3856ad364e35_7.3.7601.16384_none_29d0ae8c21e64d9d/windowsremotemanagement.admx',`
'amd64_microsoft-windows-w..for-management-core_31bf3856ad364e35_7.3.7601.16384_none_aa0df5258c5d614f/winrm.cmd',`
'amd64_microsoft-windows-w..for-management-core_31bf3856ad364e35_7.3.7601.16384_none_aa0df5258c5d614f/winrm.vbs',`
'amd64_microsoft-windows-w..for-management-core_31bf3856ad364e35_7.3.7601.16384_none_aa0df5258c5d614f/wsmagent.dll',`
'amd64_microsoft-windows-w..for-management-core_31bf3856ad364e35_7.3.7601.16384_none_aa0df5258c5d614f/wsmagent.mof',`
'amd64_microsoft-windows-w..for-management-core_31bf3856ad364e35_7.3.7601.16384_none_aa0df5258c5d614f/wsmagentuninstall.mof',`
'amd64_microsoft-windows-w..for-management-core_31bf3856ad364e35_7.3.7601.16384_none_aa0df5258c5d614f/wsmanconfig_schema.xml',`
'amd64_microsoft-windows-w..for-management-core_31bf3856ad364e35_7.3.7601.16384_none_aa0df5258c5d614f/wsmanhttpconfig.exe',`
'amd64_microsoft-windows-w..for-management-core_31bf3856ad364e35_7.3.7601.16384_none_aa0df5258c5d614f/wsmanmigrationplugin.dll',`
'amd64_microsoft-windows-w..for-management-core_31bf3856ad364e35_7.3.7601.16384_none_aa0df5258c5d614f/wsmauto.dll',`
'amd64_microsoft-windows-w..for-management-core_31bf3856ad364e35_7.3.7601.16384_none_aa0df5258c5d614f/wsmauto.mof',`
'amd64_microsoft-windows-w..for-management-core_31bf3856ad364e35_7.3.7601.16384_none_aa0df5258c5d614f/wsmgcdeps.dll',`
'amd64_microsoft-windows-w..for-management-core_31bf3856ad364e35_7.3.7601.16384_none_aa0df5258c5d614f/wsmplpxy.dll',`
'amd64_microsoft-windows-w..for-management-core_31bf3856ad364e35_7.3.7601.16384_none_aa0df5258c5d614f/wsmprovhost.exe',`
'amd64_microsoft-windows-w..for-management-core_31bf3856ad364e35_7.3.7601.16384_none_aa0df5258c5d614f/wsmpty.xsl',`
'amd64_microsoft-windows-w..for-management-core_31bf3856ad364e35_7.3.7601.16384_none_aa0df5258c5d614f/wsmres.dll',`
'amd64_microsoft-windows-w..for-management-core_31bf3856ad364e35_7.3.7601.16384_none_aa0df5258c5d614f/wsmsvc.dll',`
'amd64_microsoft-windows-w..for-management-core_31bf3856ad364e35_7.3.7601.16384_none_aa0df5258c5d614f/wsmtxt.xsl',`
'amd64_microsoft-windows-w..for-management-core_31bf3856ad364e35_7.3.7601.16384_none_aa0df5258c5d614f/wsmwmipl.dll',`
'amd64_microsoft-windows-winomi-mibincodec-dll_31bf3856ad364e35_7.3.7601.16384_none_2843075b4d1c9fce/mibincodec.dll',`
'amd64_microsoft-windows-winomi-mimofcodec-dll_31bf3856ad364e35_7.3.7601.16384_none_252e922f06bafedb/mimofcodec.dll',`
'amd64_microsoft-windows-winrs-adm_31bf3856ad364e35_7.3.7601.16384_none_79d4f6fab572396a/windowsremoteshell.admx',`
'amd64_microsoft-windows-winrsplugins_31bf3856ad364e35_7.3.7601.16384_none_f5def62d10fce4a9/winrscmd.dll',`
'amd64_microsoft-windows-winrsplugins_31bf3856ad364e35_7.3.7601.16384_none_f5def62d10fce4a9/winrs.exe',`
'amd64_microsoft-windows-winrsplugins_31bf3856ad364e35_7.3.7601.16384_none_f5def62d10fce4a9/winrshost.exe',`
'amd64_microsoft-windows-winrsplugins_31bf3856ad364e35_7.3.7601.16384_none_f5def62d10fce4a9/winrsmgr.dll',`
'amd64_microsoft-windows-winrsplugins_31bf3856ad364e35_7.3.7601.16384_none_f5def62d10fce4a9/winrssrv.dll',`
'amd64_microsoft-windows-wmi-consumers_31bf3856ad364e35_7.3.7601.16384_none_2a7aa72e3836f5bf/scrcons.exe',`
'amd64_microsoft-windows-wmi-consumers_31bf3856ad364e35_7.3.7601.16384_none_2a7aa72e3836f5bf/smtpcons.dll',`
'amd64_microsoft-windows-wmi-consumers_31bf3856ad364e35_7.3.7601.16384_none_2a7aa72e3836f5bf/wbemcons.dll',`
'amd64_microsoft-windows-wmi-core_31bf3856ad364e35_7.3.7601.16384_none_98fc82dafeee34ed/cim20.dtd',`
'amd64_microsoft-windows-wmi-core_31bf3856ad364e35_7.3.7601.16384_none_98fc82dafeee34ed/esscli.dll',`
'amd64_microsoft-windows-wmi-core_31bf3856ad364e35_7.3.7601.16384_none_98fc82dafeee34ed/framedyn.dll',`
'amd64_microsoft-windows-wmi-core_31bf3856ad364e35_7.3.7601.16384_none_98fc82dafeee34ed/framedynos.dll',`
'amd64_microsoft-windows-wmi-core_31bf3856ad364e35_7.3.7601.16384_none_98fc82dafeee34ed/mofcomp.exe',`
'amd64_microsoft-windows-wmi-core_31bf3856ad364e35_7.3.7601.16384_none_98fc82dafeee34ed/mofd.dll',`
'amd64_microsoft-windows-wmi-core_31bf3856ad364e35_7.3.7601.16384_none_98fc82dafeee34ed/ncobjapi.dll',`
'amd64_microsoft-windows-wmi-core_31bf3856ad364e35_7.3.7601.16384_none_98fc82dafeee34ed/ncprov.dll',`
'amd64_microsoft-windows-wmi-core_31bf3856ad364e35_7.3.7601.16384_none_98fc82dafeee34ed/unsecapp.exe',`
'amd64_microsoft-windows-wmi-core_31bf3856ad364e35_7.3.7601.16384_none_98fc82dafeee34ed/wbemprox.dll',`
'amd64_microsoft-windows-wmi-core_31bf3856ad364e35_7.3.7601.16384_none_98fc82dafeee34ed/wbemsvc.dll',`
'amd64_microsoft-windows-wmi-core_31bf3856ad364e35_7.3.7601.16384_none_98fc82dafeee34ed/winmgmtr.dll',`
'amd64_microsoft-windows-wmi-core_31bf3856ad364e35_7.3.7601.16384_none_98fc82dafeee34ed/wmi20.dtd',`
'amd64_microsoft-windows-wmi-core_31bf3856ad364e35_7.3.7601.16384_none_98fc82dafeee34ed/wmiadap.exe',`
'amd64_microsoft-windows-wmi-core_31bf3856ad364e35_7.3.7601.16384_none_98fc82dafeee34ed/wmiapres.dll',`
'amd64_microsoft-windows-wmi-core_31bf3856ad364e35_7.3.7601.16384_none_98fc82dafeee34ed/wmiapsrv.exe',`
'amd64_microsoft-windows-wmi-core_31bf3856ad364e35_7.3.7601.16384_none_98fc82dafeee34ed/wmicookr.dll',`
'amd64_microsoft-windows-wmi-core_31bf3856ad364e35_7.3.7601.16384_none_98fc82dafeee34ed/wmimigrationplugin.dll',`
'amd64_microsoft-windows-wmi-core_31bf3856ad364e35_7.3.7601.16384_none_98fc82dafeee34ed/wmiutils.dll',`
'amd64_microsoft-windows-wmi-core-fastprox-dll_31bf3856ad364e35_7.3.7601.16384_none_daf1d320591238e2/fastprox.dll',`
'amd64_microsoft-windows-wmi-core-providerhost_31bf3856ad364e35_7.3.7601.16384_none_f00b3e516aba9ec1/wmidcprv.dll',`
'amd64_microsoft-windows-wmi-core-providerhost_31bf3856ad364e35_7.3.7601.16384_none_f00b3e516aba9ec1/wmiprvsd.dll',`
'amd64_microsoft-windows-wmi-core-providerhost_31bf3856ad364e35_7.3.7601.16384_none_f00b3e516aba9ec1/wmiprvse.exe',`
'amd64_microsoft-windows-wmi-core-repdrvfs-dll_31bf3856ad364e35_7.3.7601.16384_none_5dea39a71040b415/repdrvfs.dll',`
'amd64_microsoft-windows-wmi-core-svc_31bf3856ad364e35_7.3.7601.16384_none_805b3b95d646b388/winmgmt.exe',`
'amd64_microsoft-windows-wmi-core-svc_31bf3856ad364e35_7.3.7601.16384_none_805b3b95d646b388/wmiaprpl.dll',`
'amd64_microsoft-windows-wmi-core-svc_31bf3856ad364e35_7.3.7601.16384_none_805b3b95d646b388/wmisvc.dll',`
'amd64_microsoft-windows-wmi-core-wbemcomn2-dll_31bf3856ad364e35_7.3.7601.16384_none_30c9dd6b1f8af019/wbemcomn2.dll',`
'amd64_microsoft-windows-wmi-core-wbemcore-dll_31bf3856ad364e35_7.3.7601.16384_none_c16832a9b627436f/wbemcore.dll',`
'amd64_microsoft-windows-wmi-core-wbemess-dll_31bf3856ad364e35_7.3.7601.16384_none_437dceea0ef67c39/wbemess.dll',`
'amd64_microsoft-windows-wmi-mofinstaller_31bf3856ad364e35_7.3.7601.16384_none_f1c5df020b164246/mofinstall.dll',`
'amd64_microsoft-windows-wmi-stdprov-provider_31bf3856ad364e35_7.3.7601.16384_none_1e36dee6a5e4ea9a/regevent.mof',`
'amd64_microsoft-windows-wmi-stdprov-provider_31bf3856ad364e35_7.3.7601.16384_none_1e36dee6a5e4ea9a/stdprov.dll',`
'amd64_microsoft-windows-wmi-text-encoding_31bf3856ad364e35_7.3.7601.16384_none_9929e6d31b662d2f/wmi2xml.dll',`
'amd64_microsoft-windows-wmi-time-provider_31bf3856ad364e35_7.3.7601.16384_none_ccda9a7a07d1f7d9/wmitimep.dll',`
'amd64_microsoft-windows-wmi-time-provider_31bf3856ad364e35_7.3.7601.16384_none_ccda9a7a07d1f7d9/wmitimep.mof',`
'amd64_microsoft-windows-wmi-tools_31bf3856ad364e35_7.3.7601.16384_none_b7a3e9a762f4fb5d/wbemtest.exe',`
'amd64_microsoft-windows-wmi-tools_31bf3856ad364e35_7.3.7601.16384_none_b7a3e9a762f4fb5d/wmimgmt.msc',`
'amd64_microsoft-windows-wmiv2-mi-dll_31bf3856ad364e35_7.3.7601.16384_none_69e9c14cef43c68d/mi.dll',`
'amd64_microsoft-windows-wmiv2-miutils-dll_31bf3856ad364e35_7.3.7601.16384_none_4aed51d5fd144672/miutils.dll',`
'amd64_microsoft-windows-wmiv2-prvdmofcomp-dll_31bf3856ad364e35_7.3.7601.16384_none_b76c85a7d27dd260/prvdmofcomp.dll',`
'amd64_microsoft-windows-wmiv2-wmidcom-dll_31bf3856ad364e35_7.3.7601.16384_none_1b521f4a82d13599/wmidcom.dll',`
'amd64_microsoft-windows-w..-provider.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_3c9c83125815d808/regevent.mfl',`
'amd64_microsoft-windows-w..-provider.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_dafeec8c2847d9c1/wmitimep.mfl',`
'amd64_microsoft-windows-w..scoveryprovider-dll_31bf3856ad364e35_7.3.7601.16384_none_535229022ef0ff35/psmodulediscoveryprovider.dll',`
'amd64_microsoft-windows-w..scoveryprovider-dll_31bf3856ad364e35_7.3.7601.16384_none_535229022ef0ff35/psmodulediscoveryprovider.mof',`
'amd64_microsoft-windows-w..ter-cimprovider-exe_31bf3856ad364e35_7.3.7601.16384_none_42f21dcfcb4ba5c5/register-cimprovider.exe',`
'amd64_microsoft-windows-w..vider-dll.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_c8a9eccc83b43c93/psmodulediscoveryprovider.dll.mui',`
'amd64_microsoft-windows-w..vider-dll.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_c8a9eccc83b43c93/psmodulediscoveryprovider.mfl',`
'amd64_powershell-gac-tool_exe_31bf3856ad364e35_7.3.7601.16384_none_98a9bac53345fd0c/pscustomsetupinstaller.exe',`
'wow64_microsoft.managemen..mcmdlets.deployment_31bf3856ad364e35_7.3.7601.16384_none_fd27e7771222f9a6/cimcmdlets.psd1',`
'wow64_microsoft.managemen..re.native.unmanaged_31bf3856ad364e35_7.3.7601.16384_none_901525279bf92111/microsoft.management.infrastructure.native.unmanaged.dll',`
'wow64_microsoft.packagema..ement.coreproviders_31bf3856ad364e35_7.3.7601.16384_none_f05cb06fdbbd6e3c/microsoft.packagemanagement.coreproviders.dll',`
'wow64_microsoft.packagemanagement_31bf3856ad364e35_7.3.7601.16384_none_fc93b4bab455de83/microsoft.packagemanagement.dll',`
'wow64_microsoft.packagemanagement.common_31bf3856ad364e35_7.3.7601.16384_none_f8bad15b9a2227a6/packagemanagement.format.ps1xml',`
'wow64_microsoft.packagemanagement.common_31bf3856ad364e35_7.3.7601.16384_none_f8bad15b9a2227a6/packagemanagement.psd1',`
'wow64_microsoft.packagemanagement.common_31bf3856ad364e35_7.3.7601.16384_none_f8bad15b9a2227a6/packageproviderfunctions.psm1',`
'wow64_microsoft.packagemanagement.msiprovider_31bf3856ad364e35_7.3.7601.16384_none_b8974a97dcaec929/microsoft.packagemanagement.msiprovider.dll',`
'wow64_microsoft.packagemanagement.msuprovider_31bf3856ad364e35_7.3.7601.16384_none_27e90cbcdee52f3d/microsoft.packagemanagement.msuprovider.dll',`
'wow64_microsoft.packagema..provider.powershell_31bf3856ad364e35_7.3.7601.16384_none_f50f549afdaf3c10/microsoft.packagemanagement.metaprovider.powershell.dll',`
'wow64_microsoft.packagema..t.archiverproviders_31bf3856ad364e35_7.3.7601.16384_none_b3e2e90d4cc550b1/microsoft.packagemanagement.archiverproviders.dll',`
'wow64_microsoft.powershell.archive_31bf3856ad364e35_7.3.7601.16384_none_01ffec95278180eb/microsoft.powershell.archive.psd1',`
'wow64_microsoft.powershell.archive_31bf3856ad364e35_7.3.7601.16384_none_01ffec95278180eb/microsoft.powershell.archive.psm1',`
'wow64_microsoft.powershell.dsc_31bf3856ad364e35_7.3.7601.16384_none_cf95f7915c925b2f/disable-dscdebug.cdxml',`
'wow64_microsoft.powershell.dsc_31bf3856ad364e35_7.3.7601.16384_none_cf95f7915c925b2f/enable-dscdebug.cdxml',`
'wow64_microsoft.powershell.dsc_31bf3856ad364e35_7.3.7601.16384_none_cf95f7915c925b2f/get-dscconfiguration.cdxml',`
'wow64_microsoft.powershell.dsc_31bf3856ad364e35_7.3.7601.16384_none_cf95f7915c925b2f/get-dscconfigurationstatus.cdxml',`
'wow64_microsoft.powershell.dsc_31bf3856ad364e35_7.3.7601.16384_none_cf95f7915c925b2f/get-dsclocalconfigurationmanager.cdxml',`
'wow64_microsoft.powershell.dsc_31bf3856ad364e35_7.3.7601.16384_none_cf95f7915c925b2f/psdesiredstateconfiguration.format.ps1xml',`
'wow64_microsoft.powershell.dsc_31bf3856ad364e35_7.3.7601.16384_none_cf95f7915c925b2f/psdesiredstateconfiguration.psd1',`
'wow64_microsoft.powershell.dsc_31bf3856ad364e35_7.3.7601.16384_none_cf95f7915c925b2f/psdesiredstateconfiguration.psm1',`
'wow64_microsoft.powershell.dsc_31bf3856ad364e35_7.3.7601.16384_none_cf95f7915c925b2f/psdesiredstateconfiguration.types.ps1xml',`
'wow64_microsoft.powershell.dsc_31bf3856ad364e35_7.3.7601.16384_none_cf95f7915c925b2f/remove-dscconfigurationdocument.cdxml',`
'wow64_microsoft.powershell.dsc_31bf3856ad364e35_7.3.7601.16384_none_cf95f7915c925b2f/restore-dscconfiguration.cdxml',`
'wow64_microsoft.powershell.dsc_31bf3856ad364e35_7.3.7601.16384_none_cf95f7915c925b2f/stop-dscconfiguration.cdxml',`
'wow64_microsoft.powershell.dsc_31bf3856ad364e35_7.3.7601.16384_none_cf95f7915c925b2f/webdownloadmanager.psd1',`
'wow64_microsoft.powershell.dsc.pullserver_31bf3856ad364e35_7.3.7601.16384_none_cf67736de0f2018d/devices.mdb',`
'wow64_microsoft.powershell.dsc.pullserver_31bf3856ad364e35_7.3.7601.16384_none_cf67736de0f2018d/global.asax',`
'wow64_microsoft.powershell.dsc.pullserver_31bf3856ad364e35_7.3.7601.16384_none_cf67736de0f2018d/iisselfsignedcertmodule.dll',`
'wow64_microsoft.powershell.dsc.pullserver_31bf3856ad364e35_7.3.7601.16384_none_cf67736de0f2018d/microsoft.powershell.desiredstateconfiguration.service.dll',`
'wow64_microsoft.powershell.dsc.pullserver_31bf3856ad364e35_7.3.7601.16384_none_cf67736de0f2018d/psdsccomplianceserver.config',`
'wow64_microsoft.powershell.dsc.pullserver_31bf3856ad364e35_7.3.7601.16384_none_cf67736de0f2018d/psdsccomplianceserver.mof',`
'wow64_microsoft.powershell.dsc.pullserver_31bf3856ad364e35_7.3.7601.16384_none_cf67736de0f2018d/psdsccomplianceserver.svc',`
'wow64_microsoft.powershell.dsc.pullserver_31bf3856ad364e35_7.3.7601.16384_none_cf67736de0f2018d/psdsccomplianceserver.xml',`
'wow64_microsoft.powershell.dsc.pullserver_31bf3856ad364e35_7.3.7601.16384_none_cf67736de0f2018d/psdscpullserver.config',`
'wow64_microsoft.powershell.dsc.pullserver_31bf3856ad364e35_7.3.7601.16384_none_cf67736de0f2018d/psdscpullserver.mof',`
'wow64_microsoft.powershell.dsc.pullserver_31bf3856ad364e35_7.3.7601.16384_none_cf67736de0f2018d/psdscpullserver.svc',`
'wow64_microsoft.powershell.dsc.pullserver_31bf3856ad364e35_7.3.7601.16384_none_cf67736de0f2018d/psdscpullserver.xml',`
'wow64_microsoft.powershell.dsc.pullserver_31bf3856ad364e35_7.3.7601.16384_none_cf67736de0f2018d/psdscserverevents.dll',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/compositeresourcehelper.psm1',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/dscresourcehelper.psm1',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/groupset.psd1',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/groupset.schema.psm1',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/msft_archiveresource.psm1',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/msft_archiveresource.schema.mof',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/msft_environmentresource.psm1',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/msft_environmentresource.schema.mof',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/msft_groupresource.psm1',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/msft_groupresource.schema.mof',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/msft_logresource.schema.mof',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/msft_packageresource.psm1',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/msft_packageresource.schema.mof',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/msft_processresource.psm1',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/msft_processresource.schema.mof',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/msft_registryresource.psm1',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/msft_registryresource.schema.mof',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/msft_roleresource.psm1',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/msft_roleresource.schema.mof',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/msft_scriptresource.psm1',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/msft_scriptresource.schema.mof',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/msft_serviceresource.psm1',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/msft_serviceresource.schema.mof',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/msft_userresource.psm1',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/msft_userresource.schema.mof',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/msft_waitforall.psm1',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/msft_waitforall.schema.mof',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/msft_waitforany.psm1',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/msft_waitforany.schema.mof',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/msft_waitforsome.psm1',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/msft_waitforsome.schema.mof',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/processset.psd1',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/processset.schema.psm1',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/psdscxmachine.psm1',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/runashelper.psm1',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/serviceset.psd1',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/serviceset.schema.psm1',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/windowsfeatureset.psd1',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/windowsfeatureset.schema.psm1',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/windowsoptionalfeatureset.psd1',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/windowsoptionalfeatureset.schema.psm1',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/windowspackagecab.cs',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/windowspackagecab.psd1',`
'wow64_microsoft.powershell.dscresources_31bf3856ad364e35_7.3.7601.16384_none_846bddd8b150a9e8/windowspackagecab.psm1',`
'wow64_microsoft.powershell.odatautils_31bf3856ad364e35_7.3.7601.16384_none_c4f06092604f78a9/microsoft.powershell.odataadapter.ps1',`
'wow64_microsoft.powershell.odatautils_31bf3856ad364e35_7.3.7601.16384_none_c4f06092604f78a9/microsoft.powershell.odatautilshelper.ps1',`
'wow64_microsoft.powershell.odatautils_31bf3856ad364e35_7.3.7601.16384_none_c4f06092604f78a9/microsoft.powershell.odatautils.psd1',`
'wow64_microsoft.powershell.odatautils_31bf3856ad364e35_7.3.7601.16384_none_c4f06092604f78a9/microsoft.powershell.odatautils.psm1',`
'wow64_microsoft.powershell.odatautils_31bf3856ad364e35_7.3.7601.16384_none_c4f06092604f78a9/microsoft.powershell.odatav4adapter.ps1',`
'wow64_microsoft.powershell.packagemanagement_31bf3856ad364e35_7.3.7601.16384_none_be98c8f8cfb32e06/microsoft.powershell.packagemanagement.dll',`
'wow64_microsoft.powershell.psget_31bf3856ad364e35_7.3.7601.16384_none_d42fb01a5851d104/powershellget.psd1',`
'wow64_microsoft.powershell.psget_31bf3856ad364e35_7.3.7601.16384_none_d42fb01a5851d104/psget.format.ps1xml',`
'wow64_microsoft.powershell.psget_31bf3856ad364e35_7.3.7601.16384_none_d42fb01a5851d104/psget.resource.psd1',`
'wow64_microsoft.powershell.psget_31bf3856ad364e35_7.3.7601.16384_none_d42fb01a5851d104/psmodule.psm1',`
'wow64_microsoft.powershell.scheduledjob.module_31bf3856ad364e35_7.3.7601.16384_none_00ea9293cddaa36d/psscheduledjob.format.ps1xml',`
'wow64_microsoft.powershell.scheduledjob.module_31bf3856ad364e35_7.3.7601.16384_none_00ea9293cddaa36d/psscheduledjob.psd1',`
'wow64_microsoft.powershell.scheduledjob.module_31bf3856ad364e35_7.3.7601.16384_none_00ea9293cddaa36d/psscheduledjob.types.ps1xml',`
'wow64_microsoft.powershel..nfigurationprovider_31bf3856ad364e35_7.3.7601.16384_none_e369ab5c407ca501/baseresource.schema.mof',`
'wow64_microsoft.powershel..nfigurationprovider_31bf3856ad364e35_7.3.7601.16384_none_e369ab5c407ca501/dsccoreconfprov.dll',`
'wow64_microsoft.powershel..nfigurationprovider_31bf3856ad364e35_7.3.7601.16384_none_e369ab5c407ca501/dsccoreconfprov.mof',`
'wow64_microsoft.powershel..nfigurationprovider_31bf3856ad364e35_7.3.7601.16384_none_e369ab5c407ca501/msft_dscmetaconfiguration.mof',`
'wow64_microsoft.powershel..nfigurationprovider_31bf3856ad364e35_7.3.7601.16384_none_e369ab5c407ca501/msft_filedirectoryconfiguration.registration.mof',`
'wow64_microsoft.powershel..nfigurationprovider_31bf3856ad364e35_7.3.7601.16384_none_e369ab5c407ca501/msft_filedirectoryconfiguration.schema.mof',`
'wow64_microsoft.powershel..nfigurationprovider_31bf3856ad364e35_7.3.7601.16384_none_e369ab5c407ca501/msft_metaconfigurationextensionclasses.schema.mof',`
'wow64_microsoft.powershel..nprovider.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_c827510783e680d9/baseresource.schema.mfl',`
'wow64_microsoft.powershel..nprovider.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_c827510783e680d9/msft_dscmetaconfiguration.mfl',`
'wow64_microsoft.powershel..nprovider.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_c827510783e680d9/msft_filedirectoryconfiguration.registration.mfl',`
'wow64_microsoft.powershel..nprovider.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_c827510783e680d9/msft_filedirectoryconfiguration.schema.mfl',`
'wow64_microsoft.powershel..nprovider.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_c827510783e680d9/msft_metaconfigurationextensionclasses.schema.mfl',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_f9478dc67da7c3f4/archiveprovider.psd1',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_f9478dc67da7c3f4/msft_archiveresource.schema.mfl',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_f9478dc67da7c3f4/msft_environmentresource.schema.mfl',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_f9478dc67da7c3f4/msft_environmentresource.strings.psd1',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_f9478dc67da7c3f4/msft_groupresource.schema.mfl',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_f9478dc67da7c3f4/msft_groupresource.strings.psd1',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_f9478dc67da7c3f4/msft_logresource.schema.mfl',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_f9478dc67da7c3f4/msft_packageresource.schema.mfl',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_f9478dc67da7c3f4/msft_processresource.schema.mfl',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_f9478dc67da7c3f4/msft_processresource.strings.psd1',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_f9478dc67da7c3f4/msft_registryresource.schema.mfl',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_f9478dc67da7c3f4/msft_registryresource.strings.psd1',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_f9478dc67da7c3f4/msft_roleresource.schema.mfl',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_f9478dc67da7c3f4/msft_roleresourcestrings.psd1',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_f9478dc67da7c3f4/msft_scriptresource.schema.mfl',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_f9478dc67da7c3f4/msft_scriptresourcestrings.psd1',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_f9478dc67da7c3f4/msft_serviceresource.schema.mfl',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_f9478dc67da7c3f4/msft_serviceresource.strings.psd1',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_f9478dc67da7c3f4/msft_userresource.schema.mfl',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_f9478dc67da7c3f4/msft_userresource.strings.psd1',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_f9478dc67da7c3f4/msft_waitforall.schema.mfl',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_f9478dc67da7c3f4/msft_waitforany.schema.mfl',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_f9478dc67da7c3f4/msft_waitforsome.schema.mfl',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_f9478dc67da7c3f4/packageprovider.psd1',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_f9478dc67da7c3f4/psdscxmachine.strings.psd1',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_f9478dc67da7c3f4/runashelper.strings.psd1',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_f9478dc67da7c3f4/windowspackagecab.strings.psd1',`
'wow64_microsoft-windows-eventcollector_31bf3856ad364e35_7.3.7601.16384_none_e50accff88694c7e/wecapi.dll',`
'wow64_microsoft-windows-eventcollector_31bf3856ad364e35_7.3.7601.16384_none_e50accff88694c7e/wecutil.exe',`
'wow64_microsoft-windows-gpowershell-exe_31bf3856ad364e35_7.3.7601.16384_none_228e49bab56b74ea/ise.psd1',`
'wow64_microsoft-windows-gpowershell-exe_31bf3856ad364e35_7.3.7601.16384_none_228e49bab56b74ea/ise.psm1',`
'wow64_microsoft-windows-gpowershell-exe_31bf3856ad364e35_7.3.7601.16384_none_228e49bab56b74ea/powershell_ise.exe',`
'wow64_microsoft-windows-gpowershell-exe_31bf3856ad364e35_7.3.7601.16384_none_228e49bab56b74ea/powershell_ise.exe.config',`
'wow64_microsoft-windows-powershell-events_31bf3856ad364e35_7.3.7601.16384_none_c2cf4d4bb6bf529e/psevents.dll',`
<#'wow64_microsoft-windows-powershell-exe_31bf3856ad364e35_7.3.7601.16384_none_531328cc15e8fa79/powershell.exe',#>`
'wow64_microsoft-windows-powershell-message_31bf3856ad364e35_7.3.7601.16384_none_1742221e4c1b3b02/pwrshmsg.dll',`
'wow64_microsoft-windows-powershell-sip_31bf3856ad364e35_7.3.7601.16384_none_526bcaf616691f79/pwrshsip.dll',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/baseconditional.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/base.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/blockcommon.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/blocksoftware.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/block.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/command.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/conditionset.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/developercommand.rld',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/developercommand.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/developermanagedclass.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/developermanagedconstructor.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/developermanageddelegate.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/developermanagedenumeration.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/developermanagedevent.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/developermanagedfield.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/developermanagedinterface.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/developermanagedmethod.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/developermanagednamespace.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/developermanagedoperator.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/developermanagedoverload.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/developermanagedproperty.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/developermanagedstructure.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/developermanaged.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/developerreference.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/developerstructure.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/developerxaml.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/developer.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/enduser.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/event.format.ps1xml',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/faq.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/glossary.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/helpv3.format.ps1xml',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/hierarchy.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/inlinecommon.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/inlinesoftware.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/inlineui.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/inline.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/itpro.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/maml_html_style.xsl',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/maml_html.xsl',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/maml.rld',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/maml.tbr',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/maml.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/maml.xsx',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/manageddeveloperstructure.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/manageddeveloper.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/microsoft.powershell.diagnostics.psd1',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/microsoft.powershell.host.psd1',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/microsoft.powershell.management.psd1',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/microsoft.powershell.security.psd1',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/microsoft.powershell.utility.psd1',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/microsoft.powershell.utility.psm1',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/providerhelp.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/shellexecute.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/structureglossary.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/structurelist.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/structureprocedure.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/structuretable.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/structuretaskexecution.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/structure.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/task.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/troubleshooting.xsd',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/typesv3.ps1xml',`
'wow64_microsoft.windows.powershell.v3.common_31bf3856ad364e35_7.3.7601.16384_none_8187c53a975bb9ea/wmf3.inf',`
'wow64_microsoft.windows.powershell.v3.wsman_31bf3856ad364e35_7.3.7601.16384_none_e49dcf788f19f5af/microsoft.wsman.management.psd1',`
'wow64_microsoft-windows-p..rshell-wsman-plugin_31bf3856ad364e35_7.3.7601.16384_none_610c686ffc7b4395/pwrshplugin.dll',`
'wow64_microsoft-windows-p..-wsman-pluginworker_31bf3856ad364e35_7.3.7601.16384_none_49f7cad7932253a3/pspluginwkr.dll',`
'wow64_microsoft-windows-w..adapter-wmitomi-dll_31bf3856ad364e35_7.3.7601.16384_none_65496ac0caceca4e/wmitomi.dll',`
'wow64_microsoft-windows-w..for-management-core_31bf3856ad364e35_7.3.7601.16384_none_b4629f77c0be234a/winrm.cmd',`
'wow64_microsoft-windows-w..for-management-core_31bf3856ad364e35_7.3.7601.16384_none_b4629f77c0be234a/winrm.vbs',`
'wow64_microsoft-windows-w..for-management-core_31bf3856ad364e35_7.3.7601.16384_none_b4629f77c0be234a/wsmagent.dll',`
'wow64_microsoft-windows-w..for-management-core_31bf3856ad364e35_7.3.7601.16384_none_b4629f77c0be234a/wsmagent.mof',`
'wow64_microsoft-windows-w..for-management-core_31bf3856ad364e35_7.3.7601.16384_none_b4629f77c0be234a/wsmagentuninstall.mof',`
'wow64_microsoft-windows-w..for-management-core_31bf3856ad364e35_7.3.7601.16384_none_b4629f77c0be234a/wsmanconfig_schema.xml',`
'wow64_microsoft-windows-w..for-management-core_31bf3856ad364e35_7.3.7601.16384_none_b4629f77c0be234a/wsmanhttpconfig.exe',`
'wow64_microsoft-windows-w..for-management-core_31bf3856ad364e35_7.3.7601.16384_none_b4629f77c0be234a/wsmanmigrationplugin.dll',`
'wow64_microsoft-windows-w..for-management-core_31bf3856ad364e35_7.3.7601.16384_none_b4629f77c0be234a/wsmauto.dll',`
'wow64_microsoft-windows-w..for-management-core_31bf3856ad364e35_7.3.7601.16384_none_b4629f77c0be234a/wsmauto.mof',`
'wow64_microsoft-windows-w..for-management-core_31bf3856ad364e35_7.3.7601.16384_none_b4629f77c0be234a/wsmgcdeps.dll',`
'wow64_microsoft-windows-w..for-management-core_31bf3856ad364e35_7.3.7601.16384_none_b4629f77c0be234a/wsmplpxy.dll',`
'wow64_microsoft-windows-w..for-management-core_31bf3856ad364e35_7.3.7601.16384_none_b4629f77c0be234a/wsmprovhost.exe',`
'wow64_microsoft-windows-w..for-management-core_31bf3856ad364e35_7.3.7601.16384_none_b4629f77c0be234a/wsmpty.xsl',`
'wow64_microsoft-windows-w..for-management-core_31bf3856ad364e35_7.3.7601.16384_none_b4629f77c0be234a/wsmres.dll',`
'wow64_microsoft-windows-w..for-management-core_31bf3856ad364e35_7.3.7601.16384_none_b4629f77c0be234a/wsmsvc.dll',`
'wow64_microsoft-windows-w..for-management-core_31bf3856ad364e35_7.3.7601.16384_none_b4629f77c0be234a/wsmtxt.xsl',`
'wow64_microsoft-windows-w..for-management-core_31bf3856ad364e35_7.3.7601.16384_none_b4629f77c0be234a/wsmwmipl.dll',`
'wow64_microsoft-windows-winomi-mibincodec-dll_31bf3856ad364e35_7.3.7601.16384_none_3297b1ad817d61c9/mibincodec.dll',`
'wow64_microsoft-windows-winomi-mimofcodec-dll_31bf3856ad364e35_7.3.7601.16384_none_2f833c813b1bc0d6/mimofcodec.dll',`
'wow64_microsoft-windows-wmi-core_31bf3856ad364e35_7.3.7601.16384_none_a3512d2d334ef6e8/cim20.dtd',`
'wow64_microsoft-windows-wmi-core_31bf3856ad364e35_7.3.7601.16384_none_a3512d2d334ef6e8/esscli.dll',`
'wow64_microsoft-windows-wmi-core_31bf3856ad364e35_7.3.7601.16384_none_a3512d2d334ef6e8/framedyn.dll',`
'wow64_microsoft-windows-wmi-core_31bf3856ad364e35_7.3.7601.16384_none_a3512d2d334ef6e8/framedynos.dll',`
'wow64_microsoft-windows-wmi-core_31bf3856ad364e35_7.3.7601.16384_none_a3512d2d334ef6e8/mofcomp.exe',`
'wow64_microsoft-windows-wmi-core_31bf3856ad364e35_7.3.7601.16384_none_a3512d2d334ef6e8/mofd.dll',`
'wow64_microsoft-windows-wmi-core_31bf3856ad364e35_7.3.7601.16384_none_a3512d2d334ef6e8/ncobjapi.dll',`
'wow64_microsoft-windows-wmi-core_31bf3856ad364e35_7.3.7601.16384_none_a3512d2d334ef6e8/wbemprox.dll',`
'wow64_microsoft-windows-wmi-core_31bf3856ad364e35_7.3.7601.16384_none_a3512d2d334ef6e8/wbemsvc.dll',`
'wow64_microsoft-windows-wmi-core_31bf3856ad364e35_7.3.7601.16384_none_a3512d2d334ef6e8/wmi20.dtd',`
'wow64_microsoft-windows-wmi-core_31bf3856ad364e35_7.3.7601.16384_none_a3512d2d334ef6e8/wmiadap.exe',`
'wow64_microsoft-windows-wmi-core_31bf3856ad364e35_7.3.7601.16384_none_a3512d2d334ef6e8/wmicookr.dll',`
'wow64_microsoft-windows-wmi-core_31bf3856ad364e35_7.3.7601.16384_none_a3512d2d334ef6e8/wmimigrationplugin.dll',`
'wow64_microsoft-windows-wmi-core_31bf3856ad364e35_7.3.7601.16384_none_a3512d2d334ef6e8/wmiutils.dll',`
'wow64_microsoft-windows-wmi-core-fastprox-dll_31bf3856ad364e35_7.3.7601.16384_none_e5467d728d72fadd/fastprox.dll',`
'wow64_microsoft-windows-wmi-core-providerhost_31bf3856ad364e35_7.3.7601.16384_none_fa5fe8a39f1b60bc/wmidcprv.dll',`
'wow64_microsoft-windows-wmi-core-providerhost_31bf3856ad364e35_7.3.7601.16384_none_fa5fe8a39f1b60bc/wmiprvse.exe',`
'wow64_microsoft-windows-wmi-core-repdrvfs-dll_31bf3856ad364e35_7.3.7601.16384_none_683ee3f944a17610/repdrvfs.dll',`
'wow64_microsoft-windows-wmi-core-svc_31bf3856ad364e35_7.3.7601.16384_none_8aafe5e80aa77583/winmgmt.exe',`
'wow64_microsoft-windows-wmi-core-svc_31bf3856ad364e35_7.3.7601.16384_none_8aafe5e80aa77583/wmiaprpl.dll',`
'wow64_microsoft-windows-wmi-core-wbemcomn2-dll_31bf3856ad364e35_7.3.7601.16384_none_3b1e87bd53ebb214/wbemcomn2.dll',`
'wow64_microsoft-windows-wmi-core-wbemcore-dll_31bf3856ad364e35_7.3.7601.16384_none_cbbcdcfbea88056a/wbemcore.dll',`
'wow64_microsoft-windows-wmiv2-mi-dll_31bf3856ad364e35_7.3.7601.16384_none_743e6b9f23a48888/mi.dll',`
'wow64_microsoft-windows-wmiv2-miutils-dll_31bf3856ad364e35_7.3.7601.16384_none_5541fc283175086d/miutils.dll',`
'wow64_microsoft-windows-wmiv2-prvdmofcomp-dll_31bf3856ad364e35_7.3.7601.16384_none_c1c12ffa06de945b/prvdmofcomp.dll',`
'wow64_microsoft-windows-wmiv2-wmidcom-dll_31bf3856ad364e35_7.3.7601.16384_none_25a6c99cb731f794/wmidcom.dll',`
'wow64_microsoft-windows-w..scoveryprovider-dll_31bf3856ad364e35_7.3.7601.16384_none_5da6d3546351c130/psmodulediscoveryprovider.dll',`
'wow64_microsoft-windows-w..ter-cimprovider-exe_31bf3856ad364e35_7.3.7601.16384_none_4d46c821ffac67c0/register-cimprovider.exe',`
'wow64_microsoft-windows-w..vider-dll.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_d2fe971eb814fe8e/psmodulediscoveryprovider.dll.mui',`
'wow64_powershell-gac-tool_exe_31bf3856ad364e35_7.3.7601.16384_none_a2fe651767a6bf07/pscustomsetupinstaller.exe',`
'x86_microsoft.managemen..frastructure.native_31bf3856ad364e35_7.3.7601.16384_none_d262ac3e9809d109/microsoft.management.infrastructure.native.dll',`
'x86_microsoft-windows-eventlog-forwardplugin_31bf3856ad364e35_7.3.7601.16384_none_f8f40d9d14d20c75/wevtfwd.dll',`
'x86_microsoft-windows-powershell-adm_31bf3856ad364e35_7.3.7601.16384_none_ecb6669e291d29c0/powershellexecutionpolicy.admx',`
'x86_microsoft-windows-winrsplugins_31bf3856ad364e35_7.3.7601.16384_none_99c05aa9589f7373/winrscmd.dll',`
'x86_microsoft-windows-winrsplugins_31bf3856ad364e35_7.3.7601.16384_none_99c05aa9589f7373/winrs.exe',`
'x86_microsoft-windows-winrsplugins_31bf3856ad364e35_7.3.7601.16384_none_99c05aa9589f7373/winrshost.exe',`
'x86_microsoft-windows-winrsplugins_31bf3856ad364e35_7.3.7601.16384_none_99c05aa9589f7373/winrsmgr.dll',`
'x86_microsoft-windows-winrsplugins_31bf3856ad364e35_7.3.7601.16384_none_99c05aa9589f7373/winrssrv.dll',`
'x86_microsoft-windows-wmi-stdprov-provider_31bf3856ad364e35_7.3.7601.16384_none_c2184362ed877964/regevent.mof',`
'x86_microsoft-windows-wmi-stdprov-provider_31bf3856ad364e35_7.3.7601.16384_none_c2184362ed877964/stdprov.dll',`
'x86_microsoft-windows-wmi-text-encoding_31bf3856ad364e35_7.3.7601.16384_none_3d0b4b4f6308bbf9/wmi2xml.dll',`
'x86_microsoft-windows-w..-provider.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_e07de78e9fb866d2/regevent.mfl',`
<# en-us #>
'amd64_microsoft.managemen..fcounters.resources_31bf3856ad364e35_7.3.7601.16384_en-us_00797ec2b76b6330/modataperfcounters.dll.mui',`
'amd64_microsoft.managemen..ta.events.resources_31bf3856ad364e35_7.3.7601.16384_en-us_bc9895bfb0510a83/modataevents.dll.mui',`
'amd64_microsoft.packagema..iprovider.resources_31bf3856ad364e35_7.3.7601.16384_en-us_63768885e00caf49/microsoft.packagemanagement.msiprovider.resources.dll',`
'amd64_microsoft.packagemanagement.resources_31bf3856ad364e35_7.3.7601.16384_en-us_8888feebceb17083/microsoft.packagemanagement.resources.dll',`
'amd64_microsoft.packagema..owershell.resources_31bf3856ad364e35_7.3.7601.16384_en-us_5a69b982b28643be/microsoft.packagemanagement.metaprovider.powershell.resources.dll',`
'amd64_microsoft.packagema..providers.resources_31bf3856ad364e35_7.3.7601.16384_en-us_20120370cf0442de/microsoft.packagemanagement.coreproviders.resources.dll',`
'amd64_microsoft.packagema..providers.resources_31bf3856ad364e35_7.3.7601.16384_en-us_7c6fd725986da543/microsoft.packagemanagement.archiverproviders.resources.dll',`
'amd64_microsoft.packagema..uprovider.resources_31bf3856ad364e35_7.3.7601.16384_en-us_ea473b4bfaeb3295/microsoft.packagemanagement.msuprovider.resources.dll',`
'amd64_microsoft.powershel..anagement.resources_31bf3856ad364e35_7.3.7601.16384_en-us_dac4e42392511f9e/microsoft.powershell.packagemanagement.resources.dll',`
'amd64_microsoft.powershel..c.mpunits.resources_31bf3856ad364e35_7.3.7601.16384_en-us_6e8327409edf1a0b/mpunits.dll.mui',`
'amd64_microsoft.powershel..datautils.resources_31bf3856ad364e35_7.3.7601.16384_en-us_815844d4da4fdd19/microsoft.powershell.odatautilsstrings.psd1',`
'amd64_microsoft.powershel..er.events.resources_31bf3856ad364e35_7.3.7601.16384_en-us_1d1a2d0ffd205689/psdscfiledownloadmanagerevents.dll.mui',`
'amd64_microsoft.powershell.archive.resources_31bf3856ad364e35_7.3.7601.16384_en-us_e5b2789278b68c71/archiveresources.psd1',`
'amd64_microsoft.powershell.dsc.proxy.resources_31bf3856ad364e35_7.3.7601.16384_en-us_fcb0c467a95fdf7d/dscproxy.dll.mui',`
'amd64_microsoft.powershell.dsc.proxy.resources_31bf3856ad364e35_7.3.7601.16384_en-us_fcb0c467a95fdf7d/dscproxy.mfl',`
'amd64_microsoft.powershell.dsc.resources_31bf3856ad364e35_7.3.7601.16384_en-us_a3ba6d67c2d3c219/psdesiredstateconfiguration.resource.psd1',`
'amd64_microsoft.powershell.psget.resources_31bf3856ad364e35_7.3.7601.16384_en-us_69bcbc54ce12360e/psget.resource.psd1',`
'amd64_microsoft.powershel..nprovider.resources_31bf3856ad364e35_7.3.7601.16384_en-us_3054005793bb16f9/baseresource.schema.mfl',`
'amd64_microsoft.powershel..nprovider.resources_31bf3856ad364e35_7.3.7601.16384_en-us_3054005793bb16f9/dsccoreconfprov.dll.mui',`
'amd64_microsoft.powershel..nprovider.resources_31bf3856ad364e35_7.3.7601.16384_en-us_3054005793bb16f9/dsccoreconfprov.mfl',`
'amd64_microsoft.powershel..nprovider.resources_31bf3856ad364e35_7.3.7601.16384_en-us_3054005793bb16f9/msft_dscmetaconfiguration.mfl',`
'amd64_microsoft.powershel..nprovider.resources_31bf3856ad364e35_7.3.7601.16384_en-us_3054005793bb16f9/msft_filedirectoryconfiguration.registration.mfl',`
'amd64_microsoft.powershel..nprovider.resources_31bf3856ad364e35_7.3.7601.16384_en-us_3054005793bb16f9/msft_filedirectoryconfiguration.schema.mfl',`
'amd64_microsoft.powershel..nprovider.resources_31bf3856ad364e35_7.3.7601.16384_en-us_3054005793bb16f9/msft_metaconfigurationextensionclasses.schema.mfl',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_61743d168d7c5a14/archiveprovider.psd1',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_61743d168d7c5a14/msft_archiveresource.schema.mfl',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_61743d168d7c5a14/msft_environmentresource.schema.mfl',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_61743d168d7c5a14/msft_environmentresource.strings.psd1',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_61743d168d7c5a14/msft_groupresource.schema.mfl',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_61743d168d7c5a14/msft_groupresource.strings.psd1',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_61743d168d7c5a14/msft_logresource.schema.mfl',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_61743d168d7c5a14/msft_packageresource.schema.mfl',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_61743d168d7c5a14/msft_processresource.schema.mfl',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_61743d168d7c5a14/msft_processresource.strings.psd1',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_61743d168d7c5a14/msft_registryresource.schema.mfl',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_61743d168d7c5a14/msft_registryresource.strings.psd1',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_61743d168d7c5a14/msft_roleresource.schema.mfl',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_61743d168d7c5a14/msft_roleresourcestrings.psd1',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_61743d168d7c5a14/msft_scriptresource.schema.mfl',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_61743d168d7c5a14/msft_scriptresourcestrings.psd1',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_61743d168d7c5a14/msft_serviceresource.schema.mfl',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_61743d168d7c5a14/msft_serviceresource.strings.psd1',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_61743d168d7c5a14/msft_userresource.schema.mfl',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_61743d168d7c5a14/msft_userresource.strings.psd1',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_61743d168d7c5a14/msft_waitforall.schema.mfl',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_61743d168d7c5a14/msft_waitforany.schema.mfl',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_61743d168d7c5a14/msft_waitforsome.schema.mfl',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_61743d168d7c5a14/packageprovider.psd1',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_61743d168d7c5a14/psdscxmachine.strings.psd1',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_61743d168d7c5a14/runashelper.strings.psd1',`
'amd64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_61743d168d7c5a14/windowspackagecab.strings.psd1',`
'amd64_microsoft.powershel..sc.mpeval.resources_31bf3856ad364e35_7.3.7601.16384_en-us_5c245e52d98a995c/mpeval.dll.mui',`
'amd64_microsoft.powershel..sc.mpeval.resources_31bf3856ad364e35_7.3.7601.16384_en-us_5c245e52d98a995c/mpeval.mfl',`
'amd64_microsoft.windows.dsc.core.resources_31bf3856ad364e35_7.3.7601.16384_en-us_fa23981dde29d19a/dsccore.dll.mui',`
'amd64_microsoft.windows.dsc.core.resources_31bf3856ad364e35_7.3.7601.16384_en-us_fa23981dde29d19a/dsccore.mfl',`
'amd64_microsoft.windows.dsc.dsctimer.resources_31bf3856ad364e35_7.3.7601.16384_en-us_0ae4f57208ba29e4/dsctimer.dll.mui',`
'amd64_microsoft.windows.dsc.dsctimer.resources_31bf3856ad364e35_7.3.7601.16384_en-us_0ae4f57208ba29e4/dsctimer.mfl',`
'amd64_microsoft-windows-e..ardplugin.resources_31bf3856ad364e35_7.3.7601.16384_en-us_25bdbf78b26cd83e/wevtfwd.dll.mui',`
'amd64_microsoft-windows-e..collector.resources_31bf3856ad364e35_7.3.7601.16384_en-us_94a019b70553b5d8/wecsvc.dll.mui',`
'amd64_microsoft-windows-e..collector.resources_31bf3856ad364e35_7.3.7601.16384_en-us_94a019b70553b5d8/wecutil.exe.mui',`
'amd64_microsoft-windows-e..rding-adm.resources_31bf3856ad364e35_7.3.7601.16384_en-us_abdc81b934745f8b/eventforwarding.adml',`
'amd64_microsoft-windows-g..shell-exe.resources_31bf3856ad364e35_7.3.7601.16384_en-us_206d8bb9d456e1fe/powershell_ise.resources.dll',`
'amd64_microsoft-windows-m..mprovider.resources_31bf3856ad364e35_7.3.7601.16384_en-us_ce9e1cc60adee646/mistreamprov.dll.mui',`
'amd64_microsoft-windows-m..mprovider.resources_31bf3856ad364e35_7.3.7601.16384_en-us_ce9e1cc60adee646/mistreamprov.mfl',`
'amd64_microsoft-windows-m..mprovider.resources_31bf3856ad364e35_7.3.7601.16384_en-us_ce9e1cc60adee646/mistreamprov_uninstall.mfl',`
'amd64_microsoft-windows-p..an-plugin.resources_31bf3856ad364e35_7.3.7601.16384_en-us_eec093a37d6a00b5/pwrshplugin.dll.mui',`
'amd64_microsoft-windows-p..ll-events.resources_31bf3856ad364e35_7.3.7601.16384_en-us_c2917ac639a71c5a/psevents.dll.mui',`
'amd64_microsoft-windows-p..ll-preloc.resources_31bf3856ad364e35_7.3.7601.16384_en-us_a15ad21d80c331e0/default.help.txt',`
'amd64_microsoft-windows-p..l-message.resources_31bf3856ad364e35_7.3.7601.16384_en-us_2014b2a9a26e3168/pwrshmsg.dll.mui',`
'amd64_microsoft.windows.p..sc.events.resources_31bf3856ad364e35_7.3.7601.16384_en-us_a1dc94a72a48e38b/dsccorer.dll.mui',`
'amd64_microsoft-windows-p..shell-adm.resources_31bf3856ad364e35_7.3.7601.16384_en-us_a369321e76717d2d/powershellexecutionpolicy.adml',`
'amd64_microsoft-windows-p..shell-mui.resources_31bf3856ad364e35_7.3.7601.16384_en-us_2091e54a558538fe/powershell.exe.mui',`
'amd64_microsoft-windows-selplugin.resources_31bf3856ad364e35_7.3.7601.16384_en-us_ed69c76b20a04470/wsmselrr.dll.mui',`
'amd64_microsoft-windows-s..-provider.resources_31bf3856ad364e35_7.3.7601.16384_en-us_ef04b3e01c58944d/silprovider.dll.mui',`
'amd64_microsoft-windows-s..-provider.resources_31bf3856ad364e35_7.3.7601.16384_en-us_ef04b3e01c58944d/silprovider.mfl',`
'amd64_microsoft-windows-s..-provider.resources_31bf3856ad364e35_7.3.7601.16384_en-us_ef04b3e01c58944d/silprovider_uninstall.mfl',`
'amd64_microsoft-windows-s..tprovider.resources_31bf3856ad364e35_7.3.7601.16384_en-us_921b5fff427be0a4/mgmtprovider.dll.mui',`
'amd64_microsoft-windows-s..tprovider.resources_31bf3856ad364e35_7.3.7601.16384_en-us_921b5fff427be0a4/mgmtprovider.mfl',`
'amd64_microsoft-windows-s..tprovider.resources_31bf3856ad364e35_7.3.7601.16384_en-us_921b5fff427be0a4/mgmtprovider_uninstall.mfl',`
'amd64_microsoft-windows-w..codec-dll.resources_31bf3856ad364e35_7.3.7601.16384_en-us_612d7421161adb71/mibincodec.dll.mui',`
'amd64_microsoft-windows-w..codec-dll.resources_31bf3856ad364e35_7.3.7601.16384_en-us_bd3ace27ac3ec0b6/mimofcodec.dll.mui',`
'amd64_microsoft-windows-w..consumers.resources_31bf3856ad364e35_7.3.7601.16384_en-us_3fc30558fe7167d2/scrcons.exe.mui',`
'amd64_microsoft-windows-w..ement-adm.resources_31bf3856ad364e35_7.3.7601.16384_en-us_e06b54c049137f4a/windowsremotemanagement.adml',`
'amd64_microsoft-windows-winrs-adm.resources_31bf3856ad364e35_7.3.7601.16384_en-us_182ab5297c744a17/windowsremoteshell.adml',`
'amd64_microsoft-windows-winrsplugins.resources_31bf3856ad364e35_7.3.7601.16384_en-us_9946d3e59fbb0134/winrs.exe.mui',`
'amd64_microsoft-windows-w..itomi-dll.resources_31bf3856ad364e35_7.3.7601.16384_en-us_3b6b60cc5a0ade60/wmitomi.dll.mui',`
'amd64_microsoft-windows-w..mcore-dll.resources_31bf3856ad364e35_7.3.7601.16384_en-us_b7685dd60931a32e/wbemcore.dll.mui',`
'amd64_microsoft-windows-w..ment-core.resources_31bf3856ad364e35_7.3.7601.16384_en-us_a3e588ebdc943920/winrm.ini',`
'amd64_microsoft-windows-w..ment-core.resources_31bf3856ad364e35_7.3.7601.16384_en-us_a3e588ebdc943920/wsmres.dll.mui',`
'amd64_microsoft-windows-w..ment-core.resources_31bf3856ad364e35_7.3.7601.16384_en-us_a3e588ebdc943920/wsmsvc.dll.mui',`
'amd64_microsoft-windows-wmi-core.resources_31bf3856ad364e35_7.3.7601.16384_en-us_b4700e00a6fe5426/mofcomp.exe.mui',`
'amd64_microsoft-windows-wmi-core.resources_31bf3856ad364e35_7.3.7601.16384_en-us_b4700e00a6fe5426/mofd.dll.mui',`
'amd64_microsoft-windows-wmi-core.resources_31bf3856ad364e35_7.3.7601.16384_en-us_b4700e00a6fe5426/ncprov.dll.mui',`
'amd64_microsoft-windows-wmi-core.resources_31bf3856ad364e35_7.3.7601.16384_en-us_b4700e00a6fe5426/winmgmtr.dll.mui',`
'amd64_microsoft-windows-wmi-core.resources_31bf3856ad364e35_7.3.7601.16384_en-us_b4700e00a6fe5426/wmiapres.dll.mui',`
'amd64_microsoft-windows-wmi-core.resources_31bf3856ad364e35_7.3.7601.16384_en-us_b4700e00a6fe5426/wmiapsrv.exe.mui',`
'amd64_microsoft-windows-wmi-core.resources_31bf3856ad364e35_7.3.7601.16384_en-us_b4700e00a6fe5426/wmiutils.dll.mui',`
'amd64_microsoft-windows-wmi-core-svc.resources_31bf3856ad364e35_7.3.7601.16384_en-us_6c50c7e00ba83bff/winmgmt.exe.mui',`
'amd64_microsoft-windows-wmi-core-svc.resources_31bf3856ad364e35_7.3.7601.16384_en-us_6c50c7e00ba83bff/wmiaprpl.dll.mui',`
'amd64_microsoft-windows-wmi-core-svc.resources_31bf3856ad364e35_7.3.7601.16384_en-us_6c50c7e00ba83bff/wmisvc.dll.mui',`
'amd64_microsoft-windows-wmi-tools.resources_31bf3856ad364e35_7.3.7601.16384_en-us_271f862803c9d702/wbemtest.exe.mui',`
'amd64_microsoft-windows-wmi-tools.resources_31bf3856ad364e35_7.3.7601.16384_en-us_271f862803c9d702/wmimgmt.msc',`
'amd64_microsoft-windows-wmiv2-mi-dll.resources_31bf3856ad364e35_7.3.7601.16384_en-us_75fca22e5d09f766/mi.dll.mui',`
'amd64_microsoft-windows-w..-provider.resources_31bf3856ad364e35_7.3.7601.16384_en-us_4d80462e6c7d31dc/wmitimep.mfl',`
'amd64_microsoft-windows-w..-provider.resources_31bf3856ad364e35_7.3.7601.16384_en-us_af1ddcb49c4b3023/regevent.mfl',`
'amd64_microsoft-windows-w..utils-dll.resources_31bf3856ad364e35_7.3.7601.16384_en-us_06fe41a1e0a9a971/miutils.dll.mui',`
'amd64_microsoft-windows-w..vider-dll.resources_31bf3856ad364e35_7.3.7601.16384_en-us_3b2b466ec7e994ae/psmodulediscoveryprovider.dll.mui',`
'amd64_microsoft-windows-w..vider-dll.resources_31bf3856ad364e35_7.3.7601.16384_en-us_3b2b466ec7e994ae/psmodulediscoveryprovider.mfl',`
'amd64_microsoft-windows-w..vider-exe.resources_31bf3856ad364e35_7.3.7601.16384_en-us_09b520b696165164/register-cimprovider.exe.mui',`
'amd64_win7-microsoft-netw..anagement.resources_31bf3856ad364e35_7.3.7601.16384_en-us_faafe212cbf0c5cf/networkswitchmanager.resource.psd1',`
'msil_microsoft.data.edm.powershell.resources_31bf3856ad364e35_7.3.7601.16384_en-us_dd3b179e7930194d/microsoft.data.edm.powershell.resources.dll',`
'msil_microsoft.data.odat..owershell.resources_31bf3856ad364e35_7.3.7601.16384_en-us_381213d8de50bca2/microsoft.data.odata.powershell.resources.dll',`
'msil_microsoft.data.serv..owershell.resources_31bf3856ad364e35_7.3.7601.16384_en-us_3d6c61319d92a647/microsoft.data.services.powershell.resources.dll',`
'msil_microsoft.data.serv..owershell.resources_31bf3856ad364e35_7.3.7601.16384_en-us_bf2c49a926d03144/microsoft.data.services.client.powershell.resources.dll',`
'msil_microsoft.managemen..imcmdlets.resources_31bf3856ad364e35_7.3.7601.16384_en-us_fbf75442950218d1/microsoft.management.infrastructure.cimcmdlets.resources.dll',`
'msil_microsoft.managemen..structure.resources_31bf3856ad364e35_7.3.7601.16384_en-us_fd4fb4a45a74838e/microsoft.management.infrastructure.resources.dll',`
'msil_microsoft.management.odata.resources_31bf3856ad364e35_7.3.7601.16384_en-us_0dde1af30dbcd842/microsoft.management.odata.resources.dll',`
'msil_microsoft.powershel..admanager.resources_31bf3856ad364e35_7.3.7601.16384_en-us_c2151c566efa758d/microsoft.powershell.dsc.filedownloadmanager.resources.dll',`
'msil_microsoft.powershel..agnostics.resources_31bf3856ad364e35_7.3.7601.16384_en-us_71a29db1e5132a95/microsoft.powershell.commands.diagnostics.resources.dll',`
'msil_microsoft.powershel..anagement.resources_31bf3856ad364e35_7.3.7601.16384_en-us_40b802d9d3279976/microsoft.powershell.commands.management.resources.dll',`
'msil_microsoft.powershel..ctivities.resources_31bf3856ad364e35_7.3.7601.16384_en-us_c7b6b360a48aa40d/microsoft.powershell.utility.activities.resources.dll',`
'msil_microsoft.powershel..ctivities.resources_31bf3856ad364e35_7.3.7601.16384_en-us_d7eebc487e4563eb/microsoft.powershell.activities.resources.dll',`
'msil_microsoft.powershel..eduledjob.resources_31bf3856ad364e35_7.3.7601.16384_en-us_7a1826de83366e8d/microsoft.powershell.scheduledjob.resources.dll',`
'msil_microsoft.powershel..hicalhost.resources_31bf3856ad364e35_7.3.7601.16384_en-us_cbc50ac3b32a4799/microsoft.powershell.graphicalhost.resources.dll',`
'msil_microsoft.powershel..ion.odata.resources_31bf3856ad364e35_7.3.7601.16384_en-us_834b022eb9bbd39c/microsoft.powershell.cmdletization.odata.resources.dll',`
'msil_microsoft.powershel..laccounts.resources_31bf3856ad364e35_7.3.7601.16384_en-us_0fb8f1ee0e7735dd/microsoft.powershell.localaccounts.resources.dll',`
'msil_microsoft.powershell.editor.resources_31bf3856ad364e35_7.3.7601.16384_en-us_f8e10b1ad8834791/microsoft.powershell.editor.resources.dll',`
'msil_microsoft.powershell.isecommon.resources_31bf3856ad364e35_7.3.7601.16384_en-us_dbf170485f98c3a0/microsoft.powershell.isecommon.resources.dll',`
'msil_microsoft.powershell.security.resources_31bf3856ad364e35_7.3.7601.16384_en-us_bfc2e5340d1efab7/microsoft.powershell.security.resources.dll',`
'msil_microsoft.powershel..nsolehost.resources_31bf3856ad364e35_7.3.7601.16384_en-us_0e8538ba7cca1942/microsoft.powershell.consolehost.resources.dll',`
'msil_microsoft.powershel..owershell.resources_31bf3856ad364e35_7.3.7601.16384_en-us_7625140b76a7c100/microsoft.powershell.gpowershell.resources.dll',`
'msil_microsoft.powershel..r.managed.resources_31bf3856ad364e35_7.3.7601.16384_en-us_5b79024048ea0f8d/microsoft.powershell.desiredstateconfiguration.service.resources.dll',`
'msil_microsoft.powershel..rvicecore.resources_31bf3856ad364e35_7.3.7601.16384_en-us_99a28ba068cc1a09/microsoft.powershell.workflow.servicecore.resources.dll',`
'msil_microsoft.powershel..s.utility.resources_31bf3856ad364e35_7.3.7601.16384_en-us_474010a2b20dcfb5/microsoft.powershell.commands.utility.resources.dll',`
'msil_microsoft.powershel..ullserver.resources_31bf3856ad364e35_7.3.7601.16384_en-us_a805a30ab617776a/psdsccomplianceserver.mfl',`
'msil_microsoft.powershel..ullserver.resources_31bf3856ad364e35_7.3.7601.16384_en-us_a805a30ab617776a/psdscpullserver.mfl',`
'msil_microsoft.powershel..ullserver.resources_31bf3856ad364e35_7.3.7601.16384_en-us_a805a30ab617776a/psdscserverevents.dll.mui',`
'msil_microsoft.windows.d..providers.resources_31bf3856ad364e35_7.3.7601.16384_en-us_96124b26b5327f31/microsoft.windows.dsc.coreconfproviders.resources.dll',`
'msil_microsoft.wsman.management.resources_31bf3856ad364e35_7.3.7601.16384_en-us_f4450cc96e1fb7c1/microsoft.wsman.management.resources.dll',`
'msil_system.management.automation.resources_31bf3856ad364e35_7.3.7601.16384_en-us_24dfc35d7bea3767/system.management.automation.resources.dll',`
'msil_system.spatial.powershell.resources_31bf3856ad364e35_7.3.7601.16384_en-us_1cc339b2d577129a/system.spatial.powershell.resources.dll',`
'wow64_microsoft.packagema..iprovider.resources_31bf3856ad364e35_7.3.7601.16384_en-us_6dcb32d8146d7144/microsoft.packagemanagement.msiprovider.resources.dll',`
'wow64_microsoft.packagemanagement.resources_31bf3856ad364e35_7.3.7601.16384_en-us_92dda93e0312327e/microsoft.packagemanagement.resources.dll',`
'wow64_microsoft.packagema..owershell.resources_31bf3856ad364e35_7.3.7601.16384_en-us_64be63d4e6e705b9/microsoft.packagemanagement.metaprovider.powershell.resources.dll',`
'wow64_microsoft.packagema..providers.resources_31bf3856ad364e35_7.3.7601.16384_en-us_2a66adc3036504d9/microsoft.packagemanagement.coreproviders.resources.dll',`
'wow64_microsoft.packagema..providers.resources_31bf3856ad364e35_7.3.7601.16384_en-us_86c48177ccce673e/microsoft.packagemanagement.archiverproviders.resources.dll',`
'wow64_microsoft.packagema..uprovider.resources_31bf3856ad364e35_7.3.7601.16384_en-us_f49be59e2f4bf490/microsoft.packagemanagement.msuprovider.resources.dll',`
'wow64_microsoft.powershel..anagement.resources_31bf3856ad364e35_7.3.7601.16384_en-us_e5198e75c6b1e199/microsoft.powershell.packagemanagement.resources.dll',`
'wow64_microsoft.powershel..datautils.resources_31bf3856ad364e35_7.3.7601.16384_en-us_8bacef270eb09f14/microsoft.powershell.odatautilsstrings.psd1',`
'wow64_microsoft.powershell.archive.resources_31bf3856ad364e35_7.3.7601.16384_en-us_f00722e4ad174e6c/archiveresources.psd1',`
'wow64_microsoft.powershell.dsc.resources_31bf3856ad364e35_7.3.7601.16384_en-us_ae0f17b9f7348414/psdesiredstateconfiguration.resource.psd1',`
'wow64_microsoft.powershell.psget.resources_31bf3856ad364e35_7.3.7601.16384_en-us_741166a70272f809/psget.resource.psd1',`
'wow64_microsoft.powershel..nprovider.resources_31bf3856ad364e35_7.3.7601.16384_en-us_3aa8aaa9c81bd8f4/baseresource.schema.mfl',`
'wow64_microsoft.powershel..nprovider.resources_31bf3856ad364e35_7.3.7601.16384_en-us_3aa8aaa9c81bd8f4/msft_dscmetaconfiguration.mfl',`
'wow64_microsoft.powershel..nprovider.resources_31bf3856ad364e35_7.3.7601.16384_en-us_3aa8aaa9c81bd8f4/msft_filedirectoryconfiguration.registration.mfl',`
'wow64_microsoft.powershel..nprovider.resources_31bf3856ad364e35_7.3.7601.16384_en-us_3aa8aaa9c81bd8f4/msft_filedirectoryconfiguration.schema.mfl',`
'wow64_microsoft.powershel..nprovider.resources_31bf3856ad364e35_7.3.7601.16384_en-us_3aa8aaa9c81bd8f4/msft_metaconfigurationextensionclasses.schema.mfl',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_6bc8e768c1dd1c0f/archiveprovider.psd1',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_6bc8e768c1dd1c0f/msft_archiveresource.schema.mfl',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_6bc8e768c1dd1c0f/msft_environmentresource.schema.mfl',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_6bc8e768c1dd1c0f/msft_environmentresource.strings.psd1',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_6bc8e768c1dd1c0f/msft_groupresource.schema.mfl',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_6bc8e768c1dd1c0f/msft_groupresource.strings.psd1',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_6bc8e768c1dd1c0f/msft_logresource.schema.mfl',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_6bc8e768c1dd1c0f/msft_packageresource.schema.mfl',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_6bc8e768c1dd1c0f/msft_processresource.schema.mfl',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_6bc8e768c1dd1c0f/msft_processresource.strings.psd1',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_6bc8e768c1dd1c0f/msft_registryresource.schema.mfl',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_6bc8e768c1dd1c0f/msft_registryresource.strings.psd1',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_6bc8e768c1dd1c0f/msft_roleresource.schema.mfl',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_6bc8e768c1dd1c0f/msft_roleresourcestrings.psd1',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_6bc8e768c1dd1c0f/msft_scriptresource.schema.mfl',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_6bc8e768c1dd1c0f/msft_scriptresourcestrings.psd1',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_6bc8e768c1dd1c0f/msft_serviceresource.schema.mfl',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_6bc8e768c1dd1c0f/msft_serviceresource.strings.psd1',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_6bc8e768c1dd1c0f/msft_userresource.schema.mfl',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_6bc8e768c1dd1c0f/msft_userresource.strings.psd1',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_6bc8e768c1dd1c0f/msft_waitforall.schema.mfl',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_6bc8e768c1dd1c0f/msft_waitforany.schema.mfl',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_6bc8e768c1dd1c0f/msft_waitforsome.schema.mfl',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_6bc8e768c1dd1c0f/packageprovider.psd1',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_6bc8e768c1dd1c0f/psdscxmachine.strings.psd1',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_6bc8e768c1dd1c0f/runashelper.strings.psd1',`
'wow64_microsoft.powershel..resources.resources_31bf3856ad364e35_7.3.7601.16384_en-us_6bc8e768c1dd1c0f/windowspackagecab.strings.psd1',`
'wow64_microsoft-windows-g..shell-exe.resources_31bf3856ad364e35_7.3.7601.16384_en-us_2ac2360c08b7a3f9/powershell_ise.resources.dll',`
'wow64_microsoft-windows-p..an-plugin.resources_31bf3856ad364e35_7.3.7601.16384_en-us_f9153df5b1cac2b0/pwrshplugin.dll.mui',`
'wow64_microsoft-windows-p..ll-events.resources_31bf3856ad364e35_7.3.7601.16384_en-us_cce625186e07de55/psevents.dll.mui',`
'wow64_microsoft-windows-p..ll-preloc.resources_31bf3856ad364e35_7.3.7601.16384_en-us_abaf7c6fb523f3db/default.help.txt',`
'wow64_microsoft-windows-p..l-message.resources_31bf3856ad364e35_7.3.7601.16384_en-us_2a695cfbd6cef363/pwrshmsg.dll.mui',`
'wow64_microsoft-windows-p..shell-mui.resources_31bf3856ad364e35_7.3.7601.16384_en-us_2ae68f9c89e5faf9/powershell.exe.mui',`
'wow64_microsoft-windows-w..codec-dll.resources_31bf3856ad364e35_7.3.7601.16384_en-us_6b821e734a7b9d6c/mibincodec.dll.mui',`
'wow64_microsoft-windows-w..codec-dll.resources_31bf3856ad364e35_7.3.7601.16384_en-us_c78f7879e09f82b1/mimofcodec.dll.mui',`
'wow64_microsoft-windows-w..itomi-dll.resources_31bf3856ad364e35_7.3.7601.16384_en-us_45c00b1e8e6ba05b/wmitomi.dll.mui',`
'wow64_microsoft-windows-wmi-core.resources_31bf3856ad364e35_7.3.7601.16384_en-us_bec4b852db5f1621/mofcomp.exe.mui',`
'wow64_microsoft-windows-wmi-core.resources_31bf3856ad364e35_7.3.7601.16384_en-us_bec4b852db5f1621/mofd.dll.mui',`
'wow64_microsoft-windows-wmi-core.resources_31bf3856ad364e35_7.3.7601.16384_en-us_bec4b852db5f1621/wmiutils.dll.mui',`
'wow64_microsoft-windows-wmi-core-svc.resources_31bf3856ad364e35_7.3.7601.16384_en-us_76a572324008fdfa/winmgmt.exe.mui',`
'wow64_microsoft-windows-wmi-core-svc.resources_31bf3856ad364e35_7.3.7601.16384_en-us_76a572324008fdfa/wmiaprpl.dll.mui',`
'wow64_microsoft-windows-wmiv2-mi-dll.resources_31bf3856ad364e35_7.3.7601.16384_en-us_80514c80916ab961/mi.dll.mui',`
'wow64_microsoft-windows-w..utils-dll.resources_31bf3856ad364e35_7.3.7601.16384_en-us_1152ebf4150a6b6c/miutils.dll.mui',`
'wow64_microsoft-windows-w..vider-dll.resources_31bf3856ad364e35_7.3.7601.16384_en-us_457ff0c0fc4a56a9/psmodulediscoveryprovider.dll.mui',`
'wow64_microsoft-windows-w..vider-exe.resources_31bf3856ad364e35_7.3.7601.16384_en-us_1409cb08ca77135f/register-cimprovider.exe.mui',`
'x86_microsoft-windows-e..ardplugin.resources_31bf3856ad364e35_7.3.7601.16384_en-us_c99f23f4fa0f6708/wevtfwd.dll.mui',`
'x86_microsoft-windows-e..collector.resources_31bf3856ad364e35_7.3.7601.16384_en-us_38817e334cf644a2/wecsvc.dll.mui',`
'x86_microsoft-windows-e..collector.resources_31bf3856ad364e35_7.3.7601.16384_en-us_38817e334cf644a2/wecutil.exe.mui',`
'x86_microsoft-windows-p..shell-adm.resources_31bf3856ad364e35_7.3.7601.16384_en-us_474a969abe140bf7/powershellexecutionpolicy.adml',`
'x86_microsoft-windows-winrsplugins.resources_31bf3856ad364e35_7.3.7601.16384_en-us_3d283861e75d8ffe/winrs.exe.mui',`
'x86_microsoft-windows-w..mcore-dll.resources_31bf3856ad364e35_7.3.7601.16384_en-us_5b49c25250d431f8/wbemcore.dll.mui',`
'x86_microsoft-windows-w..ment-core.resources_31bf3856ad364e35_7.3.7601.16384_en-us_47c6ed682436c7ea/winrm.ini',`
'x86_microsoft-windows-w..ment-core.resources_31bf3856ad364e35_7.3.7601.16384_en-us_47c6ed682436c7ea/wsmres.dll.mui',`
'x86_microsoft-windows-w..ment-core.resources_31bf3856ad364e35_7.3.7601.16384_en-us_47c6ed682436c7ea/wsmsvc.dll.mui',`
'x86_microsoft-windows-w..-provider.resources_31bf3856ad364e35_7.3.7601.16384_en-us_52ff4130e3edbeed/regevent.mfl'`
)

$msil_files = (`
<# now follows msil manifests #>'msil_microsoft.data.edm.powershell_31bf3856ad364e35_7.3.7601.16384_none_5e5d15e9ff190c3c/microsoft.data.edm.powershell.dll',`
'msil_microsoft.data.odata.powershell_31bf3856ad364e35_7.3.7601.16384_none_ca8df33eeaa8f1b9/microsoft.data.odata.powershell.dll',`
'msil_microsoft.data.services.powershell_31bf3856ad364e35_7.3.7601.16384_none_1e8fc61d9e9fd86c/microsoft.data.services.powershell.dll',`
'msil_microsoft.data.serv..s.client.powershell_31bf3856ad364e35_7.3.7601.16384_none_828c2a2d74ff82ad/microsoft.data.services.client.powershell.dll',`
'msil_microsoft.management.infrastructure_31bf3856ad364e35_7.3.7601.16384_none_8310156aa31a52f1/microsoft.management.infrastructure.dll',`
'msil_microsoft.management.odata_31bf3856ad364e35_7.3.7601.16384_none_9122b9d4248eaee5/microsoft.management.odata.dll',`
'msil_microsoft.managemen..tructure.cimcmdlets_31bf3856ad364e35_7.3.7601.16384_none_febcb79165fcbbc0/microsoft.management.infrastructure.cimcmdlets.dll',`
'msil_microsoft.powershel..filedownloadmanager_31bf3856ad364e35_7.3.7601.16384_none_f5212d1867d7a0e2/dscfiledownloadmanager.psd1',`
'msil_microsoft.powershel..filedownloadmanager_31bf3856ad364e35_7.3.7601.16384_none_f5212d1867d7a0e2/microsoft.powershell.dsc.filedownloadmanager.dll',`
'msil_microsoft.powershel..gnostics.activities_31bf3856ad364e35_7.3.7601.16384_none_8aa149263729e7f6/microsoft.powershell.diagnostics.activities.dll',`
'msil_microsoft.powershell.activities_31bf3856ad364e35_7.3.7601.16384_none_0ba6129f6229442e/microsoft.powershell.activities.dll',`
'msil_microsoft.powershell.cmdletization.odata_31bf3856ad364e35_7.3.7601.16384_none_8948691f63fd1f1d/microsoft.powershell.cmdletization.odata.dll',`
'msil_microsoft.powershell.commands.management_31bf3856ad364e35_7.3.7601.16384_none_c1a0335546714b23/microsoft.powershell.commands.management.dll',`
'msil_microsoft.powershell.commands.utility_31bf3856ad364e35_7.3.7601.16384_none_d96091fd5568ce18/microsoft.powershell.commands.utility.dll',`
'msil_microsoft.powershell.consolehost_31bf3856ad364e35_7.3.7601.16384_none_8634e813855724c9/microsoft.powershell.consolehost.dll',`
'msil_microsoft.powershell.core.activities_31bf3856ad364e35_7.3.7601.16384_none_04541481b71affd5/microsoft.powershell.core.activities.dll',`
'msil_microsoft.powershell.editor_31bf3856ad364e35_7.3.7601.16384_none_63323f1238aa80de/microsoft.powershell.editor.dll',`
'msil_microsoft.powershell.gpowershell_31bf3856ad364e35_7.3.7601.16384_none_4ae744e0977d3ba7/microsoft.powershell.gpowershell.dll',`
'msil_microsoft.powershell.graphicalhost_31bf3856ad364e35_7.3.7601.16384_none_c32121af2a1808d4/microsoft.powershell.graphicalhost.dll',`
'msil_microsoft.powershell.isecommon_31bf3856ad364e35_7.3.7601.16384_none_a33e3db6b35267f1/microsoft.powershell.isecommon.dll',`
'msil_microsoft.powershell.localaccounts_31bf3856ad364e35_7.3.7601.16384_none_1f0ea0622c9e6c6e/localaccounts.format.ps1xml',`
'msil_microsoft.powershell.localaccounts_31bf3856ad364e35_7.3.7601.16384_none_1f0ea0622c9e6c6e/microsoft.powershell.localaccounts.dll',`
'msil_microsoft.powershell.localaccounts_31bf3856ad364e35_7.3.7601.16384_none_1f0ea0622c9e6c6e/microsoft.powershell.localaccounts.psd1',`
'msil_microsoft.powershell.scheduledjob_31bf3856ad364e35_7.3.7601.16384_none_1f3eb51513816c84/microsoft.powershell.scheduledjob.dll',`
'msil_microsoft.powershell.security_31bf3856ad364e35_7.3.7601.16384_none_64c18e3e0eafee92/microsoft.powershell.security.dll',`
'msil_microsoft.powershell.security.activities_31bf3856ad364e35_7.3.7601.16384_none_a01756726f3d9c76/microsoft.powershell.security.activities.dll',`
'msil_microsoft.powershell.utility.activities_31bf3856ad364e35_7.3.7601.16384_none_4953a4de91667258/microsoft.powershell.utility.activities.dll',`
'msil_microsoft.powershel..nagement.activities_31bf3856ad364e35_7.3.7601.16384_none_5f1f98a5d302cd75/microsoft.powershell.management.activities.dll',`
'msil_microsoft.powershel..ommands.diagnostics_31bf3856ad364e35_7.3.7601.16384_none_3cbfce2c3881d318/microsoft.powershell.commands.diagnostics.dll',`
'msil_microsoft.powershel..orkflow.servicecore_31bf3856ad364e35_7.3.7601.16384_none_103ee78e8c944c02/microsoft.powershell.workflow.servicecore.dll',`
'msil_microsoft.powershel..ullserver.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_3584496871e21f4f/psdsccomplianceserver.mfl',`
'msil_microsoft.powershel..ullserver.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_3584496871e21f4f/psdscpullserver.mfl',`
'msil_microsoft.powershel..ullserver.resources_31bf3856ad364e35_7.3.7601.16384_sr-..-rs_3584496871e21f4f/psdscserverevents.dll.mui',`
'msil_microsoft.windows.dsc.coreconfproviders_31bf3856ad364e35_7.3.7601.16384_none_2c2648d0ad302d40/microsoft.windows.dsc.coreconfproviders.dll',`
'msil_microsoft.wsman.management_31bf3856ad364e35_7.3.7601.16384_none_60964e40b40fafee/microsoft.wsman.management.dll',`
'msil_microsoft.wsman.management.activities_31bf3856ad364e35_7.3.7601.16384_none_84eab5a56f3d00c8/microsoft.wsman.management.activities.dll',`
'msil_microsoft.wsman.runtime_31bf3856ad364e35_7.3.7601.16384_none_a19b148df40272fb/microsoft.wsman.runtime.dll',`
'msil_policy.1.0.microsof..commands.management_31bf3856ad364e35_7.3.7601.16384_none_f737d900f3b69af8/policy.1.0.microsoft.powershell.commands.management.config',`
'msil_policy.1.0.microsof..commands.management_31bf3856ad364e35_7.3.7601.16384_none_f737d900f3b69af8/policy.1.0.microsoft.powershell.commands.management.dll',`
'msil_policy.1.0.microsof..ershell.consolehost_31bf3856ad364e35_7.3.7601.16384_none_563dc4fe7390f6a2/policy.1.0.microsoft.powershell.consolehost.config',`
'msil_policy.1.0.microsof..ershell.consolehost_31bf3856ad364e35_7.3.7601.16384_none_563dc4fe7390f6a2/policy.1.0.microsoft.powershell.consolehost.dll',`
'msil_policy.1.0.microsof..ll.commands.utility_31bf3856ad364e35_7.3.7601.16384_none_f505318918c2a5f9/policy.1.0.microsoft.powershell.commands.utility.config',`
'msil_policy.1.0.microsof..ll.commands.utility_31bf3856ad364e35_7.3.7601.16384_none_f505318918c2a5f9/policy.1.0.microsoft.powershell.commands.utility.dll',`
'msil_policy.1.0.microsoft.powershell.security_31bf3856ad364e35_7.3.7601.16384_none_2a2ce1504a93c9ef/policy.1.0.microsoft.powershell.security.config',`
'msil_policy.1.0.microsoft.powershell.security_31bf3856ad364e35_7.3.7601.16384_none_2a2ce1504a93c9ef/policy.1.0.microsoft.powershell.security.dll',`
'msil_policy.1.0.system.management.automation_31bf3856ad364e35_7.3.7601.16384_none_79a60ff187b4c325/policy.1.0.system.management.automation.config',`
'msil_policy.1.0.system.management.automation_31bf3856ad364e35_7.3.7601.16384_none_79a60ff187b4c325/policy.1.0.system.management.automation.dll',`
'msil_system.management.automation_31bf3856ad364e35_7.3.7601.16384_none_85266a48f56bfafc/system.management.automation.dll',`
'msil_system.spatial.powershell_31bf3856ad364e35_7.3.7601.16384_none_aed0875610edb843/system.spatial.powershell.dll'`
)

    $cab = "$env:TEMP\\Windows6.1-KB3191566-x64.cab"

    Start-Process expand.exe -ArgumentList $cab,"-F:*","$env:TEMP"
    #expand.exe $cab -F:* $env:TEMP
    $expandid = (Get-Process expand).id; Wait-Process -Id $expandid;



#    Copy-Item -Path "$env:TEMP\\amd64_*\\$i" -Destination "$env:SystemRoot\\system32\\$i"
#    Copy-Item -Path "$env:TEMP\\wow64_*\\$i" -Destination "$env:SystemRoot\\syswow64\\$i"
    #also extract manifest


    Function write_keys_from_manifest{
    Param ($filetoget)

    #$relativePath = Get-Item $amd64_or_wow64_*\$filetoget | Resolve-Path -Relative
    $relativePath = $filetoget #Resolve-Path  ($amd64_or_wow64 + "_*\$filetoget") -Relative #; if (-not ($relativePath)) {Write-Host "empty path for $amd64_or_wow64 $filetoget"; continue}
    $manifest = $relativePath.split('/')[0] + ".manifest"
    $file_name = $relativePath.split('/')[1]
    
    $Xml = [xml](Get-Content -Path "$env:TEMP\$manifest")
    #copy files from manifest
#    foreach ($file in  $Xml.assembly.file) {
#    $destpath = '{0}' -f $file.destinationpath
#    $filename = '{0}' -f $file.name

    # $Xml.assembly.file | Where-Object -Property name -eq -Value "profile.ps1"
      $select= $Xml.assembly.file | Where-Object -Property name -eq -Value $file_name
      $destpath = $select.destinationpath  
      #HACKKKK         #$filename = $select.name                multiple cases:     {$_ -in 'wow', 'x86'}
      if ($destpath) {
          switch ( $manifest.SubString(0,3) ) {
              'amd' { $finalpath = $destpath -replace ([Regex]::Escape('$(runtime.system32)')),"$env:systemroot\\system32"
	              $finalpath = $finalpath -replace ([Regex]::Escape('$(runtime.programFiles)')),"$env:ProgramFiles" 
		      $finalpath = $finalpath -replace ([Regex]::Escape('$(runtime.wbem)')),"$env:systemroot\\system32\\wbem"}
               {$_ -in 'wow', 'x86'} { $finalpath = $destpath -replace ([Regex]::Escape('$(runtime.system32)')),"$env:systemroot\\syswow64"
	              $finalpath = $finalpath -replace ([Regex]::Escape('$(runtime.programFiles)')),([Regex]::Escape('ProgramFiles(x86)'))#"$env:ProgramW6432" 
		      $finalpath = $finalpath -replace ([Regex]::Escape('$(runtime.wbem)')),"$env:systemroot\\syswow64\\wbem"}
	      'msi' { $finalpath = $destpath -replace ([Regex]::Escape('$(runtime.system32)')),"$env:systemroot\\system32"  }#????
          }
          $finalpath = $finalpath -replace ([Regex]::Escape('$(runtime.windows)')),"$env:systemroot"
          #$(runtime.programFiles)  $(runtime.wbem)

          if (-not (Test-Path -Path $finalpath )) {
              New-Item -Path $finalpath -ItemType directory -Force
	  }
          Write-Host finalpath is $finalpath
          Copy-Item -Path $filetoget -Destination $finalpath -Force
      }
      else {  #HACK where should these files go to??
           Write-Host "possible error! destpath is null for $manifest"
	   Copy-Item -Path $filetoget -Destination "$env:systemdrive\\ConEmu" -Force #to track
	   Copy-Item -Path $filetoget -Destination "$env:systemroot\\syswow64\\WindowsPowerShell\\v1.0" -Force	   
	   Copy-Item -Path $filetoget -Destination "$env:systemroot\\system32\\WindowsPowerShell\\v1.0" -Force
	   
	   $MSILTOKEN=$Xml.assembly.assemblyIdentity.publicKeyToken #  = 31bf3856ad364e35 | Where-Object -Property name -eq -Value $file_name
           Write-Host msiltoken is "$MSILTOKEN" 
           $DIRNAME=$Xml.assembly.assemblyIdentity.name #System.Managment.Automation
	    Write-Host dirname is "$DIRNAME" 
          #C:\windows\assembly\GAC_MSIL\System.Management.Automation\1.0.0.0__31bf3856ad364e35"C:\windows\assembly\GAC_MSIL\System.Manageent.Automation\1.0.0.0__31bf3856ad364e35
           $ABSPATH= "$env:systemroot\assembly\GAC_MSIL\" + "$DIRNAME\1.0.0.0__" +"$MSILTOKEN"
           Write-Host ABSPATH is "$ABSPATH"
          if (-not (Test-Path -Path "$ABSPATH" )) { New-Item -Path "$ABSPATH" -ItemType directory -Force}
	  
	   Copy-Item -Path $filetoget -Destination "$ABSPATH" -Force
	      
	   
      }
    
      #try write regkeys from manifest file
   #thanks some guy from freenode webchat channel powershell who wrote skeleton of this in 4 minutes...
   foreach ($key in $Xml.assembly.registryKeys.registryKey) {
    $path = 'Registry::{0}' -f $key.keyName
    
    
        #if($manifest.SubString(0,3) -eq 'wow')
	 switch ( $manifest.SubString(0,3) ) {
	 {$_ -in 'wow', 'x86'}  {$path = $path -replace 'HKEY_LOCAL_MACHINE\\SOFTWARE','HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node'
                                 $path = $path -replace 'HKEY_CLASSES_ROOT','HKEY_CLASSES_ROOT\Wow6432Node'}
	 default                {}			 
         }
	 
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
	
	
	   switch ( $manifest.SubString(0,3) )
           {
	             'amd' { $value.Value = $value.Value -replace ([Regex]::Escape('$(runtime.system32)')),"$env:systemroot\\system32"
	              $value.Value = $value.Value -replace ([Regex]::Escape('$(runtime.programFiles)')),"$env:ProgramFiles"
		      $value.Value = $value.Value -replace ([Regex]::Escape('$(runtime.wbem)')),"$env:systemroot\\system32\\wbem"}
               {$_ -in 'wow', 'x86'} { $value.Value = $value.Value -replace ([Regex]::Escape('$(runtime.system32)')),"$env:systemroot\\syswow64"
	              $value.Value = $value.Value -replace ([Regex]::Escape('$(runtime.programFiles)')),([Regex]::Escape('ProgramFiles(x86)')) 
		      $value.Value = $value.Value -replace ([Regex]::Escape('$(runtime.wbem)')),"$env:systemroot\\syswow64\\wbem"}
	   
           #    'amd' {  $value.Value = $value.Value -replace ([Regex]::Escape('$(runtime.system32)')),"$env:systemroot\system32"  }
           #     {$_ -in 'wow', 'x86'} {  $value.Value = $value.Value -replace ([Regex]::Escape('$(runtime.system32)')),"$env:systemroot\syswow64" }

           }
	   $value.Value = $value.Value -replace ([Regex]::Escape('$(runtime.windows)')),"$env:systemroot"
        #$value.Value = $value.Value -replace ([Regex]::Escape('$(runtime.system32)')),"$env:systemroot\$runtime_system32" #????syswow64??

        New-ItemProperty -Path $path -Name $Regname -Value $value.Value -PropertyType $propertyType -Force}
# }#end if($manifest.SubString(0,3) -ne 'msi')
}
}

}  


    foreach ($i in $dll_or_exe) {
        write_keys_from_manifest $i
    }
    
     foreach ($i in $msil_files) {
         write_keys_from_manifest $i
    }   
    #HACK For bug in wintrust's WinVerifyTrust (???)
    #pwrshsip
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'pwrshsip' -Value 'disabled' -PropertyType 'String' 

   # New-Item -Path 'HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Management Infrastructure'
   # New-Item -Path 'HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Management Infrastructure\\protocols'
   # New-Item -Path 'HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Management Infrastructure\\protocols\\WMIDCOM'
  #  New-Item -Path 'HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Management Infrastructure\\protocols\\WMIDCOM\\1.0'
    #windows10
  #  New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Management Infrastructure\\protocols\\WMIDCOM\\1.0' -force -Name 'dllEntryPoint' -Value 'MI_Application_InitializeV1' -PropertyType 'String' 
  #   New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Management Infrastructure\\protocols\\WMIDCOM\\1.0' -force -Name 'dllpath' -Value 'c:\\Program Files\\PowerShell\\7\\mi.dll' -PropertyType 'String' 

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

    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'expand.exe' -Value 'builtin' -PropertyType 'String' 
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'cabinet' -Value 'builtin' -PropertyType 'String' 

    New-Item -Path 'HKCU:\\Software\\Wine\\AppDefaults\\expand.exe' -force
    New-Item -Path 'HKCU:\\Software\\Wine\\AppDefaults\\expand.exe\\DllOverrides' -force
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\expand.exe\\DllOverrides' -force -Name 'expand.exe' -Value 'native' -PropertyType 'String' 
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\expand.exe\\DllOverrides' -force -Name 'cabinet' -Value 'native' -PropertyType 'String' 


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
