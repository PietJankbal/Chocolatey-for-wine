    (New-Object System.Net.WebClient).DownloadFile('https://conemu.github.io/install2.ps1', $(Join-Path "$env:TEMP" 'install2.ps1') )
    Invoke-Expression  $(cat $(Join-Path "$env:TEMP" 'install2.ps1') | Select-string 'url_7za =')  <# Get the 7za.exe downloadlink from install2.ps1 file #>
    (New-Object System.Net.WebClient).DownloadFile($url_7za, $(Join-Path "$env:TEMP" '7za.exe') )

    <# fragile test... If install files already present skip downloads. Run choc_installer once with 'SAVEINSTALLFILES=1' to cache downloads #>
    if (!(Test-Path -Path "$env:WINEHOMEDIR\.cache\choc_install_files\netfx_Full_x64.msi".substring(4) -PathType Leaf)) { <# First download/extract/install dotnet48 as job, this takes most time #>
        (New-Object System.Net.WebClient).DownloadFile('https://download.visualstudio.microsoft.com/download/pr/7afca223-55d2-470a-8edc-6a1739ae3252/abd170b4b0ec15ad0222a809b761a036/ndp48-x86-x64-allos-enu.exe', $(Join-Path "$env:TEMP" 'ndp48-x86-x64-allos-enu.exe') )
        Start-Job -ScriptBlock {[System.Threading.Thread]::CurrentThread.Priority = 'RealTime'; Start-Process -FilePath $env:TEMP\\7za.exe -NoNewWindow -ArgumentList  "x -x!*.cab -ms190M $env:TEMP\\ndp48-x86-x64-allos-enu.exe -o$env:TEMP"}
        Start-Job -ScriptBlock {  while(!(Test-Path -Path "$env:TEMP\1025") ) {Sleep 0.25} ;[System.Threading.Thread]::CurrentThread.Priority = 'RealTime'; &{ c:\\windows\\system32\\msiexec.exe  /i $env:TEMP\\netfx_Full_x64.msi EXTUI=1 /sfxlang:1033 /q /norestart} }

        $url = @('http://download.windowsupdate.com/msdownload/update/software/crup/2010/06/windows6.1-kb958488-v6001-x64_a137e4f328f01146dfa75d7b5a576090dee948dc.msu', `
                 'https://mirrors.kernel.org/gentoo/distfiles/arial32.exe', `
                 'https://mirrors.kernel.org/gentoo/distfiles/arialb32.exe', `
                 'https://github.com/mozilla/fxc2/raw/master/dll/d3dcompiler_47.dll', `
                 'https://github.com/mozilla/fxc2/raw/master/dll/d3dcompiler_47_32.dll' `
                 )
       <# Download stuff #>
       $url | ForEach-Object { Write-Host -ForeGroundColor Yellow "Downloading $PSItem" && (New-Object System.Net.WebClient).DownloadFile($PSItem, $(Join-Path "$env:TEMP" ($PSItem  -split '/' | Select-Object -Last 1)))}
       <# Extract stuff we need for quick dotnet40 install, only mscoree (probably)#>
       Start-Process -FilePath $env:TEMP\\7za.exe -NoNewWindow -Wait -ArgumentList  "x $env:TEMP\\windows6.1-kb958488-v6001-x64_a137e4f328f01146dfa75d7b5a576090dee948dc.msu -o$env:TEMP\\dotnet40 Windows6.1-KB958488-x64.cab";
       Start-Process -FilePath $env:TEMP\\7za.exe -NoNewWindow -Wait -ArgumentList  "x $env:TEMP\\dotnet40\\Windows6.1-KB958488-x64.cab -o$env:TEMP\\dotnet40 x86_netfx-mscoree_dll_31bf3856ad364e35_6.2.7600.16513_none_7daed23956119a9f/mscoree.dll";
       Start-Process -FilePath $env:TEMP\\7za.exe -NoNewWindow -Wait -ArgumentList  "x $env:TEMP\\dotnet40\\Windows6.1-KB958488-x64.cab -o$env:TEMP\\dotnet40 amd64_netfx-mscoree_dll_31bf3856ad364e35_6.2.7600.16513_none_d9cd6dbd0e6f0bd5/mscoree.dll";
       Start-Process -FilePath $env:TEMP\\7za.exe -NoNewWindow -Wait -ArgumentList  "x $(Join-Path $args[0] 'EXTRAS\wine_robocopy.7z') -o$env:TEMP"
       Start-Process -FilePath $env:TEMP\\7za.exe -NoNewWindow -Wait -ArgumentList  "x $(Join-Path $args[0] 'EXTRAS\wine_user32_for_conemu_hack_for_wine7_8.7z') -o$env:TEMP"
       Get-Process '7za' -ErrorAction:SilentlyContinue | Foreach-Object { $_.WaitForExit() }
       Start-Job -ScriptBlock { & $env:TEMP\\install2.ps1 } <# ConEmu install #>
       $C_TMP = $env:TEMP
    }
    else {
        $C_TMP = "$env:WINEHOMEDIR\.cache\choc_install_files\".substring(4)
        Start-Job -ScriptBlock { & $env:TEMP\\install2.ps1 }  <# ConEmu install #>
        &{c:\\windows\\system32\\msiexec.exe  /i $C_TMP\\netfx_Full_x64.msi EXTUI=1 /sfxlang:1033 /q /norestart} ;Get-Process 'msiexec' -ErrorAction:SilentlyContinue | Foreach-Object { $_.WaitForExit()}
    }
    
    Copy-Item $(Join-Path $args[0] "misc.reg") $env:TEMP
    Copy-Item $(Join-Path $args[0] "profile.ps1") $env:TEMP
    Copy-Item $(Join-Path $args[0] "profile.ps1") $(Join-Path $(Split-Path -Path (Get-Process -Id $pid).Path) "profile.ps1") <# Copy profile.ps1 to Powershell directory #>
    <# Install Chocolatey #>
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    <# This makes Astro Photography Tool happy #>  
    Copy-Item -Path $env:systemroot\\Microsoft.NET\\Framework\\v4.0.30319\\RegAsm.exe -Destination $env:systemroot\\Microsoft.NET\\Framework\\v2.0.50727\\RegAsm.exe  
    <# Many programs need arial and native d3dcompiler_47, so install it #>
    Start-Process -FilePath "$C_TMP\\arial32.exe" -Wait -ArgumentList  "-q" &
    Start-Process -FilePath "$C_TMP\\arialb32.exe" -Wait -ArgumentList  "-q" &
    Copy-Item -Path "$C_TMP\\d3dcompiler_47_32.dll" -Destination "$env:SystemRoot\\SysWOW64\\d3dcompiler_47.dll" -Force
    Copy-Item -Path "$C_TMP\\d3dcompiler_47_32.dll" -Destination "$env:SystemRoot\\SysWOW64\\d3dcompiler_43.dll" -Force
    Copy-Item -Path "$C_TMP\\d3dcompiler_47.dll" -Destination "$env:SystemRoot\\System32\\d3dcompiler_47.dll" -Force
    Copy-Item -Path "$C_TMP\\d3dcompiler_47.dll" -Destination "$env:SystemRoot\\System32\\d3dcompiler_43.dll" -Force
    <# Replace some system programs by functions (in profile.ps1); This also makes wusa a dummy program: we don`t want windows updates and it doesn`t work anyway #>
    ForEach ($file in "schtasks.exe") {
        Copy-Item -Path "$env:windir\\SysWOW64\\$file" -Destination "$env:windir\\SysWOW64\\QPR.$file" -Force
        Copy-Item -Path "$env:winsysdir\\$file" -Destination "$env:winsysdir\\QPR.$file" -Force}
    ForEach ($file in "wusa.exe","tasklist.exe","winebrowser.exe","schtasks.exe","systeminfo.exe","wmic.exe") {
        Copy-Item -Path "$env:windir\\SysWOW64\\WindowsPowerShell\\v1.0\\powershell.exe" -Destination "$env:windir\\SysWOW64\\$file" -Force
        Copy-Item -Path "$env:winsysdir\\WindowsPowerShell\\v1.0\\powershell.exe" -Destination "$env:winsysdir\\$file" -Force}
    <# dotnet40: we (probably) only need mscoree.dll from winetricks dotnet40 recipe, so just copy it and write registry values from it`s manifest file. This saves quite some time!#>
    Copy-Item -Path "$C_TMP\\dotnet40\\x86_netfx-mscoree_dll_31bf3856ad364e35_6.2.7600.16513_none_7daed23956119a9f/mscoree.dll" -Destination "$env:systemroot\\syswow64\\" -Force
    Copy-Item -Path "$C_TMP\\dotnet40\\amd64_netfx-mscoree_dll_31bf3856ad364e35_6.2.7600.16513_none_d9cd6dbd0e6f0bd5/mscoree.dll" -Destination "$env:systemroot\\system32\\" -Force
    <# Import reg keys: keys from mscoree manifest files, tweaks to advertise compability with lower .Net versions, and set some native dlls #>
    reg.exe  IMPORT  $C_TMP\\misc.reg /reg:64
    reg.exe  IMPORT  $C_TMP\\misc.reg /reg:32      
    <# wine robocopy and hack for ConEmu #>
    Copy-Item -Path "$C_TMP\\robocopy64.exe" -Destination "$env:SystemRoot\\System32\\robocopy.exe" -Force
    Copy-Item -Path "$C_TMP\\robocopy32.exe" -Destination "$env:SystemRoot\\syswow64\\robocopy.exe" -Force
    Copy-Item -Path "$C_TMP\\user32_32.dll" -Destination "$env:SystemDrive\\ConEmu\\user32.dll" -Force
    <# do not use chocolatey's builtin powershell host #>
    cd c:\; c:\\ProgramData\\chocolatey\\choco.exe feature disable --name=powershellHost; winecfg /v win10
    c:\\ProgramData\\chocolatey\\choco.exe feature enable -n allowGlobalConfirmation <# to confirm automatically (no -y needed) #>
    # Add-Type -AssemblyName PresentationCore,PresentationFramework; [System.Windows.MessageBox]::Show('Chocolatey installed','Congrats','ok','exclamation')
    # choco install tccle -y; & "$env:ProgramFiles\\JPSoft\\TCCLE14x64\\tcc.exe" "$env:ProgramFiles\\JPSoft\\TCCLE14x64\\tccbatch.btm"; <># cmd.exe replacement #
    Start-Process "powershell" -NoNewWindow
################################################################################################################### 
#  All code below is only for sending a single keystroke (ENTER) to ConEmu's annoying                             #
#  fast configuration window to dismiss it...............                                                         #
#  Based on https://github.com/nylyst/PowerShell/blob/master/Send-KeyPress.ps1 -> so credits to that author       #
#  Could be replaced with [System.Windows.Forms.SendKeys]::SendWait("{ENTER}") if that one day works in wine...   #
###################################################################################################################
    <# add a C# class to access the WIN32 API SetForegroundWindow #>
    Add-Type @"
    using System;
    using System.Runtime.InteropServices;

    public class StartActivateProgramClass {
    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
    }
"@
    <# get the application and window handle and set it to foreground #>
    while(!$p) {$p = Get-Process | Where-Object { $_.MainWindowTitle -Match "Conemu" }; Start-Sleep -Milliseconds 200}
    $h = $p[0].MainWindowHandle
    [void] [StartActivateProgramClass]::SetForegroundWindow($h)
    <# add a C# class to access the WIN32 API SendInput #>
    Add-Type @"
    using System;
    using System.Collections.Generic;
    using System.Runtime.InteropServices;

    public static class Synthesize_Keystrokes {    
        public enum InputType : uint {
            INPUT_MOUSE = 0,
            INPUT_KEYBOARD = 1,
            INPUT_HARDWARE = 3
        }

        [Flags]
        internal enum KEYEVENTF : uint
        {
            KEYDOWN = 0x0,
            EXTENDEDKEY = 0x0001,
            KEYUP = 0x0002,
            SCANCODE = 0x0008,
            UNICODE = 0x0004
        }

        [Flags]
        internal enum MOUSEEVENTF : uint
        {
            ABSOLUTE = 0x8000,
            HWHEEL = 0x01000,
            MOVE = 0x0001,
            MOVE_NOCOALESCE = 0x2000,
            LEFTDOWN = 0x0002,
            LEFTUP = 0x0004,
            RIGHTDOWN = 0x0008,
            RIGHTUP = 0x0010,
            MIDDLEDOWN = 0x0020,
            MIDDLEUP = 0x0040,
            VIRTUALDESK = 0x4000,
            WHEEL = 0x0800,
            XDOWN = 0x0080,
            XUP = 0x0100
        }

        [StructLayout(LayoutKind.Sequential)] /* Master Input structure */
        public struct lpInput {
            internal InputType type;
            internal InputUnion Data;
            internal static int Size { get { return Marshal.SizeOf(typeof(lpInput)); } }            
        }

        [StructLayout(LayoutKind.Explicit)] /* Union structure */
        internal struct InputUnion {
            [FieldOffset(0)]
            internal MOUSEINPUT mi;
            [FieldOffset(0)]
            internal KEYBDINPUT ki;
            [FieldOffset(0)]
            internal HARDWAREINPUT hi;
        }

        [StructLayout(LayoutKind.Sequential)] /* Input Types */
        internal struct MOUSEINPUT
        {
            internal int dx;
            internal int dy;
            internal int mouseData;
            internal MOUSEEVENTF dwFlags;
            internal uint time;
            internal UIntPtr dwExtraInfo;
        }

        [StructLayout(LayoutKind.Sequential)]
        internal struct KEYBDINPUT
        {
            internal short wVk;
            internal short wScan;
            internal KEYEVENTF dwFlags;
            internal int time;
            internal UIntPtr dwExtraInfo;
        }

        [StructLayout(LayoutKind.Sequential)]
        internal struct HARDWAREINPUT
        {
            internal int uMsg;
            internal short wParamL;
            internal short wParamH;
        }

        private class unmanaged {
            [DllImport("user32.dll", SetLastError = true)]
            internal static extern uint SendInput (
                uint cInputs, 
                [MarshalAs(UnmanagedType.LPArray)]
                lpInput[] inputs,
                int cbSize
            );

            [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
            public static extern short VkKeyScan(char ch);
        }

        internal static uint SendInput(uint cInputs, lpInput[] inputs, int cbSize) {
            return unmanaged.SendInput(cInputs, inputs, cbSize);
        }

        public static void SendKeyStroke() {
            lpInput[] KeyInputs = new lpInput[2];
            lpInput KeyInput = new lpInput();
            /* Generic Keyboard Event */
            KeyInput.type = InputType.INPUT_KEYBOARD;
            KeyInput.Data.ki.wScan = 0;
            KeyInput.Data.ki.time = 0;
            KeyInput.Data.ki.dwExtraInfo = UIntPtr.Zero;
            /* Emulate keypress */
            KeyInput.Data.ki.wVk = 13; /* VK_RETURN */
            KeyInput.Data.ki.dwFlags = KEYEVENTF.KEYDOWN;
            KeyInputs[0] = KeyInput;
            KeyInput.Data.ki.wVk = 13; /* VK_RETURN */
            KeyInput.Data.ki.dwFlags = KEYEVENTF.KEYUP;
            KeyInputs[1] = KeyInput;
            
            SendInput(2, KeyInputs, lpInput.Size);
            return;
            }
    }
"@
    <# Dismiss ConEmu's fast configuration window by hitting enter #>
    [Synthesize_Keystrokes]::SendKeyStroke()

    <# fragile test...; Download and 'install' NoPowerShell.exe which has some extra Powershell cmdlets #>
    if (!(Test-Path -Path "$env:WINEHOMEDIR\.cache\choc_install_files\netfx_Full_x64.msi".substring(4) -PathType Leaf)) {
        (New-Object System.Net.WebClient).DownloadFile('https://github.com/bitsadmin/nopowershell/releases/download/1.23/NoPowerShell_trunk.zip', $(Join-Path "$env:TEMP" 'NoPowerShell_trunk.zip') )
        Start-Process -FilePath $env:TEMP\\7za.exe -NoNewWindow -Wait -ArgumentList  "x $env:TEMP\\NoPowerShell_trunk.zip Dotnet45/* -o$env:TEMP"}
    Copy-Item "$C_TMP\\DOTNET45\\*.*" "$env:SystemRoot\\system32\\WindowsPowershell\\v1.0\\"
    <# Backup files if wanted #>
    if (Test-Path 'env:SAVEINSTALLFILES') { 
        New-Item -Path "$env:WINEHOMEDIR\.cache\".substring(4) -Name "choc_install_files" -ItemType "directory" -ErrorAction SilentlyContinue
        Copy-Item -Recurse -Path $env:TEMP\\* -Destination "$env:WINEHOMEDIR\.cache\choc_install_files\".substring(4)  -force
    }
    <# NexusTK checks for this key #>
    New-Item -Path "$env:SystemRoot\Microsoft.NET\Framework64" -Name "v3.5" -ItemType "directory" -ErrorAction SilentlyContinue <# for NexusTK #>
    New-Item -Path "$env:SystemRoot\Microsoft.NET\Framework" -Name "v3.5" -ItemType "directory" -ErrorAction SilentlyContinue
    New-Item -Path "$env:LOCALAPPDATA" -Name "Temp" -ItemType "directory" -ErrorAction SilentlyContinue
