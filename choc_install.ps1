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
    
        function quit?([string] $process)  <# wait for a process to quit #>
    {
         Get-Process $process -ErrorAction:SilentlyContinue | Foreach-Object { $_.WaitForExit() }
    }

    $url = @('https://download.microsoft.com/download/9/5/A/95A9616B-7A37-4AF6-BC36-D6EA96C8DAAE/dotNetFx40_Full_x86_x64.exe', `
             'https://download.visualstudio.microsoft.com/download/pr/7afca223-55d2-470a-8edc-6a1739ae3252/abd170b4b0ec15ad0222a809b761a036/ndp48-x86-x64-allos-enu.exe', `
             'https://mirrors.kernel.org/gentoo/distfiles/arial32.exe', `
             'https://mirrors.kernel.org/gentoo/distfiles/arialb32.exe', `
             'https://download-installer.cdn.mozilla.net/pub/firefox/releases/62.0.3/win32/ach/Firefox%20Setup%2062.0.3.exe', `
             'https://download-installer.cdn.mozilla.net/pub/firefox/releases/62.0.2/win64/ach/Firefox%20Setup%2062.0.2.exe', `
             'https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/x86.reg', `
             'https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/amd.reg')
    <# Download stuff #>
    $url | ForEach-Object { Write-Host -ForeGroundColor Yellow "Downloading $PSItem" && (New-Object System.Net.WebClient).DownloadFile($PSItem, $(Join-Path "$env:TEMP" ($PSItem  -split '/' | Select-Object -Last 1)))}
    <# Install choco #>
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) 
    <# Extract stuff we need for quick dotnet48 install #>
    Start-Process -FilePath $env:TEMP\\ConEmuDownloads\\7za.exe -NoNewWindow -Wait -ArgumentList  "x $env:TEMP\\dotNetFx40_Full_x86_x64.exe -o$env:TEMP\\dotnet40 Windows6.1-KB958488-v6001-x64.msu"; quit?('7za')
    Start-Process -FilePath $env:TEMP\\ConEmuDownloads\\7za.exe -NoNewWindow -Wait -ArgumentList  "x $env:TEMP\\dotNet40\\Windows6.1-KB958488-v6001-x64.msu -o$env:TEMP\\dotnet40 Windows6.1-KB958488-x64.cab"; quit?('7za')
    Start-Process -FilePath $env:TEMP\\ConEmuDownloads\\7za.exe -NoNewWindow -Wait -ArgumentList  "x $env:TEMP\\ndp48-x86-x64-allos-enu.exe -o$env:TEMP"; quit?('7za')
    Start-Process -FilePath $env:TEMP\\ConEmuDownloads\\7za.exe -NoNewWindow -Wait -ArgumentList  "x $env:TEMP\\dotnet40\\Windows6.1-KB958488-x64.cab -o$env:TEMP\\dotnet40 x86_netfx-mscoree_dll_31bf3856ad364e35_6.2.7600.16513_none_7daed23956119a9f/mscoree.dll"; quit?('7za')
    Start-Process -FilePath $env:TEMP\\ConEmuDownloads\\7za.exe -NoNewWindow -Wait -ArgumentList  "x $env:TEMP\\dotnet40\\Windows6.1-KB958488-x64.cab -o$env:TEMP\\dotnet40 amd64_netfx-mscoree_dll_31bf3856ad364e35_6.2.7600.16513_none_d9cd6dbd0e6f0bd5/mscoree.dll"; quit?('7za')
    <# remove mono #>    
    $f = uninstaller --list  | Select-String 'Mono'; $g = $f -split "\|" |Select-string "{"; uninstaller --remove $g[0]; uninstaller --remove $g[1]
    <# Experimental dotnet48 installation; this is much faster then 'winetricks dotnet48', hopefully doesn`t cause issues... #>
    <# dotnet40: we (probably) only need mscoree.dll from winetricks dotnet40 recipe, so just extract it and write registry values from it`s manifest file. This saves quite some time!#>
    Copy-Item -Path "$env:TEMP\\dotnet40\\x86_netfx-mscoree_dll_31bf3856ad364e35_6.2.7600.16513_none_7daed23956119a9f/mscoree.dll" -Destination "$env:systemroot\\syswow64\\" -Force
    Copy-Item -Path "$env:TEMP\\dotnet40\\amd64_netfx-mscoree_dll_31bf3856ad364e35_6.2.7600.16513_none_d9cd6dbd0e6f0bd5/mscoree.dll" -Destination "$env:systemroot\\system32\\" -Force
    reg.exe  IMPORT  $env:TEMP\\amd.reg /reg:64; quit?('reg')
    reg.exe  IMPORT  $env:TEMP\\x86.reg /reg:32; quit?('reg')
    <# dotnet48: Install from extracted msi file, seems faster as well. #>
    Start-Process -FilePath msiexec.exe -ArgumentList "/i $env:TEMP\\netfx_Full_x64.msi EXTUI=1 /sfxlang:1033 /q /norestart"; quit?('msiexec')
    <# use further the winetricks recipe for some essential registry keys #>
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'mscorwks' -Value 'native' -PropertyType 'String'
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'mscoree' -Value 'native' -PropertyType 'String'
    New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\.NETFramework' -Name 'OnlyUseLatestCLR' -Value '0001' -PropertyType 'DWord'
    New-ItemProperty -Path 'HKLM:\\Software\\Wow6432Node\\Microsoft\\.NETFramework' -Name 'OnlyUseLatestCLR' -Value '0001' -PropertyType 'DWord'
    <# Tweaks to advertise compability with lower .Net versions #>
    md $env:systemroot\\Microsoft.NET\\Framework\\v2.0.50727 <# This makes Astro Photography Tool happy #>
    Copy-Item -Path $env:systemroot\\Microsoft.NET\\Framework\\v4.0.30319\\RegAsm.exe -Destination $env:systemroot\\Microsoft.NET\\Framework\\v2.0.50727\\RegAsm.exe  

    new_HKLM_SM_key '.NETFramework\\Policy\\v2.0'

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
    
    #New-Item -Path 'HKCU:\\Software\\Microsoft\\Avalon.Graphics' -force
    #New-ItemProperty -Path 'HKCU:\\Software\\Microsoft\\Avalon.Graphics' -Name 'DisableHWAcceleration' -Value '0' -PropertyType 'dword'  

    <# Many programs need arial and native d3dcompiler_47, so install it #>
    Start-Process -FilePath "$env:TEMP\\arial32.exe" -Wait -ArgumentList  "-q"
    Start-Process -FilePath "$env:TEMP\\arialb32.exe" -Wait -ArgumentList  "-q"
    Start-Process -FilePath $env:TEMP\\ConEmuDownloads\\7za.exe -NoNewWindow -Wait -ArgumentList  "x $env:TEMP\\Firefox%20Setup%2062.0.3.exe  -o$env:TEMP\\core32 core/d3dcompiler_47.dll"; quit?('7za')
    Start-Process -FilePath $env:TEMP\\ConEmuDownloads\\7za.exe -NoNewWindow -Wait -ArgumentList  "x $env:TEMP\\Firefox%20Setup%2062.0.2.exe -o$env:TEMP\\core64 core/d3dcompiler_47.dll"; quit?('7za')
   
    Copy-Item -Path "$env:TEMP\\core32\\core\\d3dcompiler_47.dll" -Destination "$env:SystemRoot\\SysWOW64\\d3dcompiler_47.dll" -Force
    Copy-Item -Path "$env:TEMP\\core32\\core\\d3dcompiler_47.dll" -Destination "$env:SystemRoot\\SysWOW64\\d3dcompiler_43.dll" -Force
    Copy-Item -Path "$env:TEMP\\core64\\core\\d3dcompiler_47.dll" -Destination "$env:SystemRoot\\System32\\d3dcompiler_47.dll" -Force
    Copy-Item -Path "$env:TEMP\\core64\\core\\d3dcompiler_47.dll" -Destination "$env:SystemRoot\\System32\\d3dcompiler_43.dll" -Force
    <# Make wusa a dummy program, we don`t want windows updates and it doesn`t work anyway #>
    Copy-Item -Path "$env:windir\\SysWOW64\\WindowsPowerShell\\v1.0\\powershell.exe" -Destination "$env:windir\\SysWOW64\\wusa.exe" -Force
    Copy-Item -Path "$env:winsysdir\\WindowsPowerShell\\v1.0\\powershell.exe" -Destination "$env:winsysdir\\wusa.exe" -Force

    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'wusa.exe' -Value 'native' -PropertyType 'String'
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'd3dcompiler_47' -Value 'native' -PropertyType 'String'
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'd3dcompiler_43' -Value 'native' -PropertyType 'String'
    <# do not use chocolatey's builtin powershell host #>
    cd c:\; c:\\ProgramData\\chocolatey\\choco.exe feature disable --name=powershellHost

    Add-Type -AssemblyName PresentationCore,PresentationFramework; [System.Windows.MessageBox]::Show('Chocolatey installed','Congrats','ok','exclamation')
    
    powershell.exe
