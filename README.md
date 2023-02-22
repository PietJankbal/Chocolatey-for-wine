# Chocolatey-for-wine
Chocolatey packagemanager automatic installer in wine, handy to install quickly programs in wine

Install :
- Download and unzip the release zip-file and do 'wine ChoCinstaller_0.5u.703.exe' (takes about a minute to complete)

Optional:
- Check if things went well: "choco install chromium" and  "start chrome.exe --no-sandbox" 
  
  Or if you like to install via GUI: "choco install ChocolateyGUI" and "start chocolateygui.exe"
  
  
![Screenshot from 2022-08-26 12-31-18](https://user-images.githubusercontent.com/26839562/186885380-d5a617c4-9cf4-4831-a475-2bd85a3b5784.png)

Updates:

- Update : As I was bored during lock-down I wrote a custom winetricks(.ps1) with some verbs I find handy. 

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
  - Selecting text in the ConEmu window (for copy/paste) doesn't highlight the selection. Included is a very sad hack       against recent wine versions that works around this, so highlighting should just work now.
   
About system programs:

Feature is added to replace simple system programs like for example tasklist.exe by a function in
c:\\Program Files\Powershell\7\profile.ps1. Or add system programs that are missing like getmac.exe.
If programs fail because of insufficient mature or missing system programs one could write a 
function to return whatever the program expects. 
Like in profile.ps1 I added (amongst others) a wmic.exe that supports a bit more options,
and a basic findstr.exe , systeminfo.exe and basic setx.exe.
Or you could just manipulate the arguments passed to the system program. See profile.ps1 and choc_install.ps1.
No garantuee this works for more complex programs as well... 
 

![Screenshot from 2022-11-05 17-59-32](https://user-images.githubusercontent.com/26839562/200132126-d3fbec4b-081d-440c-9ef9-341572ad7787.png)

About winetricks(.ps1):

- If you don't call it ('winetricks' in powershell-console) , nothing gets downloadeded so no overhead there. 
- A lot of verbs (like powershell 5.1) need a few essential files to extract stuff from msu packages. Installing these essential files requires first huge download (gigs of diskspace), and takes lots of time (5 minutes) during 1st time usage. But after things are cached it goes quickly 
- Hopefully some better 64-bit support for some verbs
- Possibility to extract msu files. See winetricks(.ps1) howto. 
- A rudimentary Powershell 5.1.
- experimental dotnet481 installation
- Also included a few powershell scripts adapted from codesnippets found on the internet:
- How to embed an exe in a powershell script via Invoke-ReflectivePEInjection (the exe won't show up in tasklist)
- How to make fancy messageboxes
- Convert a powershell script (ps1) into an exe.
- And a few other

Notes:

  - Do NOT use on existing wineprefix, only on fresh new created prefix! The installer just stupidly installs dotnet48 itsself and messes with registrykeys.
    If you have any dotnet version already installed with winetricks, it will likely fail, and even if it succeeds, you'll likely end up with a broken prefix.
    If you need to install stuff via winetricks for programs, do NOT use any of the dotnet* verbs. 
    BTW 'Arial' and 'd3dcompiler_47' verbs are already installed by default.
  - WINEARCH=win32 is _not_ supported!

Compile:
  - If you want to compile yourself instead of downloading binaries: see compilation instructions in mainv1.c  
  - Then copy choc_install.ps1 into the same directory
  - Then do 'wine ChoCinstaller_0.5u.703.exe'
  
