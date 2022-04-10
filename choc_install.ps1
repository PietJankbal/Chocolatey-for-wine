    function quit?([string] $process)  <# wait for a process to quit #>
    {
         Get-Process $process -ErrorAction:SilentlyContinue | Foreach-Object { $_.WaitForExit() }
    }
    
    <# fragile test... If install files already present skip downloads. Run choc_installer once with 'SAVEINSTALLFILES=1' to cache downloads #>
    if (!(Test-Path -Path "$env:WINEHOMEDIR\.cache\choc_install_files\netfx_Full_x64.msi".substring(4) -PathType Leaf)) {
        $url = @('http://download.windowsupdate.com/msdownload/update/software/crup/2010/06/windows6.1-kb958488-v6001-x64_a137e4f328f01146dfa75d7b5a576090dee948dc.msu', `
                 'https://download.visualstudio.microsoft.com/download/pr/7afca223-55d2-470a-8edc-6a1739ae3252/abd170b4b0ec15ad0222a809b761a036/ndp48-x86-x64-allos-enu.exe', `
                 'https://mirrors.kernel.org/gentoo/distfiles/arial32.exe', `
                 'https://mirrors.kernel.org/gentoo/distfiles/arialb32.exe', `
                 'https://github.com/mozilla/fxc2/raw/master/dll/d3dcompiler_47.dll', `
                 'https://github.com/mozilla/fxc2/raw/master/dll/d3dcompiler_47_32.dll', `
                 'https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/misc.reg')
        <# Download stuff #>
        $url | ForEach-Object { Write-Host -ForeGroundColor Yellow "Downloading $PSItem" && (New-Object System.Net.WebClient).DownloadFile($PSItem, $(Join-Path "$env:TEMP" ($PSItem  -split '/' | Select-Object -Last 1)))}
        <# Extract stuff we need for quick dotnet48 install #>
        Start-Process -FilePath $env:TEMP\\ConEmuDownloads\\7za.exe -NoNewWindow -Wait -ArgumentList  "x $env:TEMP\\windows6.1-kb958488-v6001-x64_a137e4f328f01146dfa75d7b5a576090dee948dc.msu -o$env:TEMP\\dotnet40 Windows6.1-KB958488-x64.cab"; quit?('7za')
        Start-Process -FilePath $env:TEMP\\ConEmuDownloads\\7za.exe -NoNewWindow -Wait -ArgumentList  "x -x!*.cab -ms190M $env:TEMP\\ndp48-x86-x64-allos-enu.exe -o$env:TEMP" ; quit?('7za')
        Start-Process -FilePath $env:TEMP\\ConEmuDownloads\\7za.exe -NoNewWindow -Wait -ArgumentList  "x $env:TEMP\\dotnet40\\Windows6.1-KB958488-x64.cab -o$env:TEMP\\dotnet40 x86_netfx-mscoree_dll_31bf3856ad364e35_6.2.7600.16513_none_7daed23956119a9f/mscoree.dll"; quit?('7za')
        Start-Process -FilePath $env:TEMP\\ConEmuDownloads\\7za.exe -NoNewWindow -Wait -ArgumentList  "x $env:TEMP\\dotnet40\\Windows6.1-KB958488-x64.cab -o$env:TEMP\\dotnet40 amd64_netfx-mscoree_dll_31bf3856ad364e35_6.2.7600.16513_none_d9cd6dbd0e6f0bd5/mscoree.dll"; quit?('7za')
        $C_TMP = $env:TEMP
    }
    else {
        $C_TMP = "$env:WINEHOMEDIR\.cache\choc_install_files\".substring(4)
    }
    <# Install choco #>
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) 
    <# dotnet48: Install from extracted msi file;  Experimental dotnet48 installation; this is faster then 'winetricks dotnet48', hopefully doesn`t cause issues... #>
    Start-Process -FilePath msiexec.exe -ArgumentList "/i $C_TMP\\netfx_Full_x64.msi EXTUI=1 /sfxlang:1033 /q /norestart"; quit?('msiexec')
    <# dotnet40: we (probably) only need mscoree.dll from winetricks dotnet40 recipe, so just extract it and write registry values from it`s manifest file. This saves quite some time!#>
    Copy-Item -Path "$C_TMP\\dotnet40\\x86_netfx-mscoree_dll_31bf3856ad364e35_6.2.7600.16513_none_7daed23956119a9f/mscoree.dll" -Destination "$env:systemroot\\syswow64\\" -Force
    Copy-Item -Path "$C_TMP\\dotnet40\\amd64_netfx-mscoree_dll_31bf3856ad364e35_6.2.7600.16513_none_d9cd6dbd0e6f0bd5/mscoree.dll" -Destination "$env:systemroot\\system32\\" -Force
    <# This makes Astro Photography Tool happy #>
    Copy-Item -Path $env:systemroot\\Microsoft.NET\\Framework\\v4.0.30319\\RegAsm.exe -Destination $env:systemroot\\Microsoft.NET\\Framework\\v2.0.50727\\RegAsm.exe  
    <# Many programs need arial and native d3dcompiler_47, so install it #>
    Start-Process -FilePath "$C_TMP\\arial32.exe" -Wait -ArgumentList  "-q"
    Start-Process -FilePath "$C_TMP\\arialb32.exe" -Wait -ArgumentList  "-q";
    Copy-Item -Path "$C_TMP\\d3dcompiler_47_32.dll" -Destination "$env:SystemRoot\\SysWOW64\\d3dcompiler_47.dll" -Force
    Copy-Item -Path "$C_TMP\\d3dcompiler_47_32.dll" -Destination "$env:SystemRoot\\SysWOW64\\d3dcompiler_43.dll" -Force
    Copy-Item -Path "$C_TMP\\d3dcompiler_47.dll" -Destination "$env:SystemRoot\\System32\\d3dcompiler_47.dll" -Force
    Copy-Item -Path "$C_TMP\\d3dcompiler_47.dll" -Destination "$env:SystemRoot\\System32\\d3dcompiler_43.dll" -Force
    <# Make wusa a dummy program, we don`t want windows updates and it doesn`t work anyway #>
    ForEach ($file in "schtasks.exe") {
        Copy-Item -Path "$env:windir\\SysWOW64\\$file" -Destination "$env:windir\\SysWOW64\\QPR.$file" -Force
        Copy-Item -Path "$env:winsysdir\\$file" -Destination "$env:winsysdir\\QPR.$file" -Force}
    ForEach ($file in "wusa.exe","tasklist.exe","iexplore.exe","winebrowser.exe") {
        Copy-Item -Path "$env:windir\\SysWOW64\\WindowsPowerShell\\v1.0\\powershell.exe" -Destination "$env:windir\\SysWOW64\\$file" -Force
        Copy-Item -Path "$env:winsysdir\\WindowsPowerShell\\v1.0\\powershell.exe" -Destination "$env:winsysdir\\$file" -Force}
    <# Import reg keys: keys from mscoree manifest files, tweaks to advertise compability with lower .Net versions, and set some native dlls#>
    reg.exe  IMPORT  $C_TMP\\misc.reg /reg:64; quit?('reg')
    reg.exe  IMPORT  $C_TMP\\misc.reg /reg:32; quit?('reg')
    <# do not use chocolatey's builtin powershell host #>
    cd c:\; c:\\ProgramData\\chocolatey\\choco.exe feature disable --name=powershellHost; winecfg /v win10
    c:\\ProgramData\\chocolatey\\choco.exe feature enable -n allowGlobalConfirmation <# to confirm automatically (no -y needed) #>
    # Add-Type -AssemblyName PresentationCore,PresentationFramework; [System.Windows.MessageBox]::Show('Chocolatey installed','Congrats','ok','exclamation')
    if (Test-Path 'env:SAVEINSTALLFILES') { 
        New-Item -Path "$env:WINEHOMEDIR\.cache\".substring(4) -Name "choc_install_files" -ItemType "directory" -ErrorAction SilentlyContinue
        Move-Item -Path $env:TEMP\\* -Destination "$env:WINEHOMEDIR\.cache\choc_install_files\".substring(4)  -force
    }
    # choco install tccle -y; & "$env:ProgramFiles\\JPSoft\\TCCLE14x64\\tcc.exe" "$env:ProgramFiles\\JPSoft\\TCCLE14x64\\tccbatch.btm";
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
    
    <# Lines below are only here to show how to intercept executables, see further profile.ps1#>
    Copy-Item -Path "$env:windir\\\Microsoft.NET\Framework\v4.0.30319\\csc.exe" -Destination "$env:windir\\Microsoft.NET\\Framework\\v4.0.30319\\QPR.csc.exe" -Force
    Copy-Item -Path "$env:windir\\SysWOW64\\WindowsPowerShell\\v1.0\\powershell.exe" -Destination "$env:windir\\Microsoft.NET\\Framework\\v4.0.30319\\csc.exe" -Force
