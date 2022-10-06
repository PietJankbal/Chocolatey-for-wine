# Chocolatey-for-wine
Chocolatey packagemanager automatic installer in wine, handy to install quickly programs in wine

Install :
- Download and unzip the release zip-file and do 'wine ChoCinstaller_0.5e.703.exe' (takes about a minute to complete)

Optional:
- Check if things went well: "choco install chromium" and  "start chrome.exe"  (--no-sandbox not needed anymore since wine-7.8)
  
  Or if you like to install via GUI: "choco install ChocolateyGUI" and "start chocolateygui.exe"
  
  
![Screenshot from 2022-08-26 12-31-18](https://user-images.githubusercontent.com/26839562/186885380-d5a617c4-9cf4-4831-a475-2bd85a3b5784.png)

Updates:

- Update 1: As I was bored during lock-down I wrote a custom winetricks(.ps1) with some verbs I find handy. If you don't call it, nothing gets downloadeded so no overhead there. It eats gigs of diskspace, and takes lots of time during 1st time usage. But after things are cached it goes quickly + hopefully some better 64-bit support for some verbs + possibility to extract msu files + a rudimentary Powershell 5.1.  
  
About PowerShell:

- 'wine powershell.exe' starts the PowerShell-Core console.

  There's also some PowerShell 5.1 support:

- From PowerShell-Core console do 'winetricks ps51' (takes very long time to complete! and downloads gigs of mostly   useless stuff)

  Then from PowerShell-Core console you could:

- start powershell 5.1 console by "ps51"
- or execute some command through powershell 5.1 like (an example)  " ps51 '$PSVersionTable' "
- by setting environment variable "$env:PS51=1" you can start a new powershell 5.1 console by just "powershell" 
  (or from linux bash: "PS51=1 wine powershell")
- or you could work in graphical PowerShell 5.1 Integrated Scripting Environment with 'winetricks ps51_ise' 
- If you really hate Windows you could also start bash (via Busybox) from the PowerShell Core console by just "bash"

![Screenshot from 2022-09-10 19-36-30](https://user-images.githubusercontent.com/26839562/189495238-2b4893ba-09d1-4e60-bb4c-f326d4939482.png)


About ConEmu:

ConEmu console suffers from a few wine-bugs:
  - Ctrl^C to quit a program that doesn't return to the console doesn`t work. Use Shift^Ctrl^C instead.
  - Selecting text in the ConEmu window (for copy/paste) doesn`t highlight the selection. Included is a very sad hack to     work around ConEmu's 'missing highlight selection' bug. This is a hack against recent wine versions.
    To enable the hack just do 'apply_conemu_hack', and highlighting selection should work.
    If you run different wine-versions after each other (or upgrade wine), the hack might break and
    'wine powershell.exe' (ConEmu) might not start anymore.

    * Try 'wine powershell.exe apply_conemu_hack' and it should likely work again.
    * If it still doesn't start, fire up winecfg and remove dll overrides for ConEmu64.exe (hack is incompatible               with your wine version).

About system programs:

Feature is added to replace simple system programs like for example tasklist.exe by a function in
c:\\Program Files\Powershell\7\profile.ps1. Or add system programs that are missing like setx.exe.
If programs fail because of insufficient mature or missing system programs one could write a 
function to return whatever the program expects. Or you could just manipulate the arguments passed to the system program. See profile.ps1 and choc_install.ps1.
No garantuee this works for more complex programs as well...

![Screenshot from 2022-10-06 00-21-16](https://user-images.githubusercontent.com/26839562/194174837-fb54aff1-f31b-4ed6-9fed-4e3b53831189.png)

Notes:

  - Do NOT use on existing wineprefix, only on fresh new created prefix! The installation just stupidly installs dotnet48 itsself and messes with registrykeys.
    If you have any dotnet version already installed with winetricks, it will likely fail, and even if it succeeds, you'll likely end up with a broken prefix.
    If you need to install stuff via winetricks for programs, do NOT use any of the dotnet* verbs. 
    BTW 'Arial' and 'd3dcompiler_47' verbs are already installed by default.
  - WINEARCH=win32 is _not_ supported!

Compile:
  - If you want to compile yourself instead of downloading binaries:
    
    i686-w64-mingw32-gcc -municode -mconsole mainv1.c -lurlmon -lshlwapi -s -o powershell32.exe

    x86_64-w64-mingw32-gcc -municode -mconsole mainv1.c -lurlmon -lshlwapi -s -o ChoCinstaller_0.5c.703.exe
    
  - Then copy choc_install.ps1 into the same directory
  - Then do 'wine ChoCinstaller_0.5c.703.exe'
  
