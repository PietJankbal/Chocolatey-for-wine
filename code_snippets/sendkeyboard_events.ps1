#Stolen from https://github.com/nylyst/PowerShell/blob/master/Send-KeyPress.ps1
<#

.SYNOPSIS

Send a sequence of keys to an application window


.DESCRIPTION

This Send-Keys script send a sequence of keys to an application window.

To have more information about the key representation look at http://msdn.microsoft.com/en-us/library/System.Windows.Forms.SendKeys(v=vs.100).aspx

(C)2013 Massimo A. Santin - Use it at your own risk.


.PARAMETER ApplicationTitle

The title of the application window


.PARAMETER Keys

The sequence of keys to send


.PARAMETER WaitTime

An optional number of seconds to wait after the sending of the keys


.EXAMPLE

Send-Keys "foobar - Notepad" "Hello world"


Send the sequence of keys "Hello world" to the application titled "foobar - Notepad".


.EXAMPLE

Send-Keys "foobar - Notepad" "Hello world" -WaitTime 5


Send the sequence of keys "Hello world" to the application titled "foobar - Notepad" 

and wait 5 seconds.


.EXAMPLE 

 New-Item foobar.txt -ItemType File; notepad foobar.txt ; Send-Keys "foobar - Notepad" "Hello world{ENTER}Ciao mondo{ENTER}" -WaitTime 1; Send-Keys "foobar - Notepad" "^s"


This command sequence creates a new text file called foobar.txt, opens the file using a notepad,

writes some text and saves the file using notepad.


.LINK

http://msdn.microsoft.com/en-us/library/System.Windows.Forms.SendKeys(v=vs.100).aspx

#>


Start-Process "notepad"

#Sleep 3


# load assembly cotaining class System.Windows.Forms.SendKeys

[void] [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

#Add-Type -AssemblyName System.Windows.Forms


# add a C# class to access the WIN32 API SetForegroundWindow

Add-Type @"

 using System;

 using System.Runtime.InteropServices;

 public class StartActivateProgramClass {

 [DllImport("user32.dll")]

 [return: MarshalAs(UnmanagedType.Bool)]

 public static extern bool SetForegroundWindow(IntPtr hWnd);

 }

"@


# get the applications with the specified title

$p = Get-Process | Where-Object { $_.MainWindowTitle -Match "Notepad" }
while(!$p) {Sleep 1}

if ($p) 

{

 # get the window handle of the first application

 $h = $p[0].MainWindowHandle

 $h

 # set the application to foreground

 [void] [StartActivateProgramClass]::SetForegroundWindow($h)


 # send the keys sequence

 # more info on MSDN at http://msdn.microsoft.com/en-us/library/System.Windows.Forms.SendKeys(v=vs.100).aspx

 #[System.Windows.Forms.SendKeys]::SendWait("+{p}")



$key = "p"
$Scancode = 58

$code = @"
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;

public static class KBEmulator {    
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

    // Master Input structure
    [StructLayout(LayoutKind.Sequential)]
    public struct lpInput {
        internal InputType type;
        internal InputUnion Data;
        internal static int Size { get { return Marshal.SizeOf(typeof(lpInput)); } }            
    }

    // Union structure
    [StructLayout(LayoutKind.Explicit)]
    internal struct InputUnion {
        [FieldOffset(0)]
        internal MOUSEINPUT mi;
        [FieldOffset(0)]
        internal KEYBDINPUT ki;
        [FieldOffset(0)]
        internal HARDWAREINPUT hi;
    }

    // Input Types
    [StructLayout(LayoutKind.Sequential)]
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

    internal static short VkKeyScan(char ch) {
        return unmanaged.VkKeyScan(ch);
    }

    internal static uint SendInput(uint cInputs, lpInput[] inputs, int cbSize) {
        return unmanaged.SendInput(cInputs, inputs, cbSize);
    }


    public static void SendScanCode2(short scanCode) {
        lpInput[] KeyInputs = new lpInput[4];
        lpInput KeyInput = new lpInput();
        // Generic Keyboard Event
        KeyInput.type = InputType.INPUT_KEYBOARD;
        KeyInput.Data.ki.wScan = 0;
        KeyInput.Data.ki.time = 0;
        KeyInput.Data.ki.dwExtraInfo = UIntPtr.Zero;



        // Push the correct key
        KeyInput.Data.ki.wVk = 17; //Ctrl
        KeyInput.Data.ki.dwFlags = KEYEVENTF.KEYDOWN;
        KeyInputs[0] = KeyInput;



        // Push the correct key
        KeyInput.Data.ki.wVk = 70; //f
        KeyInput.Data.ki.dwFlags = KEYEVENTF.KEYDOWN;
        KeyInputs[1] = KeyInput;



        // Release the key
        KeyInput.Data.ki.wVk = 70;
        KeyInput.Data.ki.dwFlags = KEYEVENTF.KEYUP;
        KeyInputs[2] = KeyInput;

        // Release the key
        KeyInput.Data.ki.wVk = 17;
        KeyInput.Data.ki.dwFlags = KEYEVENTF.KEYUP;
        KeyInputs[3] = KeyInput;

        SendInput(4, KeyInputs, lpInput.Size);



        return;
    }



    public static void SendKeyboard(char ch) {
        lpInput[] KeyInputs = new lpInput[1];
        lpInput KeyInput = new lpInput();
        // Generic Keyboard Event
        KeyInput.type = InputType.INPUT_KEYBOARD;
        KeyInput.Data.ki.wScan = 0;
        KeyInput.Data.ki.time = 0;
        KeyInput.Data.ki.dwExtraInfo = UIntPtr.Zero;


        // Push the correct key
        KeyInput.Data.ki.wVk = VkKeyScan(ch);
        KeyInput.Data.ki.dwFlags = KEYEVENTF.KEYDOWN;
        KeyInputs[0] = KeyInput;
        SendInput(1, KeyInputs, lpInput.Size);

        // Release the key
        KeyInput.Data.ki.dwFlags = KEYEVENTF.KEYUP;
        KeyInputs[0] = KeyInput;
        SendInput(1, KeyInputs, lpInput.Size);

        return;
    }
}
"@

if(([System.AppDomain]::CurrentDomain.GetAssemblies() | ?{$_ -match "KBEmulator"}) -eq $null) {
    Add-Type -TypeDefinition $code
}

     [KBEmulator]::SendScanCode2($ScanCode)

 #    [KBEmulator]::SendKeyboard($Key) 








$WaitTime = 1

 if ($WaitTime) 

 {

 Start-Sleep -Seconds $WaitTime

 }

}