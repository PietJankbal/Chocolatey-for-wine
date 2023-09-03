# Chocolatey-for-wine
Chocolatey packagemanager automatic installer in wine, handy to install quickly programs in wine

Install :
- Download and unzip the release zip-file and do 'wine ChoCinstaller_0.5i.715.exe' (takes about a minute to complete)

Optional:
- Check if things went well: "choco install chromium" and  "start chrome.exe (--no-sandbox not needed anymore as of wine-8,4)" 
  
  Or if you like to install via GUI: "choco install ChocolateyGUI" and "start chocolateygui.exe"
  
Optional:

- Run the installer like 'SAVEINSTALLFILES=1 wine ChoCinstaller_0.5i.715.exe' , then the install files (like Powershell.msi and dotnet48) are saved in
  '$HOME/.cache/choc_install_files' and they don't need to be downloaded again if you create a new prefix)
  
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


![Screenshot from 2022-09-10 19-36-30](https://user-images.githubusercontent.com/26839562/189495238-2b4893ba-09d1-4e60-bb4c-f326d4939482.png)


About ConEmu:

ConEmu console suffers from a few wine-bugs:
  - Ctrl^C to quit a program that doesn't return to the console doesn`t work. Use Shift^Ctrl^C instead.
  - Selecting text in the ConEmu window (for copy/paste) doesn't highlight the selection. Included is a very sad hack       against recent wine versions that works around this, so highlighting should just work now.
   
About system programs:

Feature is added to replace simple system programs like for example systeminfo.exe by a function in
c:\\Program Files\Powershell\7\profile.ps1. Or add system programs that are missing like getmac.exe.
If programs fail because of insufficient mature or missing system programs one could write a 
function to return whatever the program expects. 
Like in profile.ps1 I added (amongst others) a wmic.exe that supports a bit more options,
and a basic systeminfo.exe and setx.exe.
Or you could just manipulate the arguments passed to the system program. See profile.ps1 and choc_install.ps1.
No garantuee this works for more complex programs as well... 
 
![screenshot](https://github.com/PietJankbal/Chocolatey-for-wine/assets/26839562/7732da99-e215-4df6-bb60-d55ddb8d9d63)

About winetricks(.ps1):

- If you don't call it ('winetricks' in powershell-console) , nothing gets downloadeded so no overhead there. 
- A lot of verbs (like powershell 5.1) need a few essential files to extract stuff from msu packages. Installing these essential files requires first huge downloads , and       takes lots of time during 1st time usage. But after things are cached it goes quickly . For example if you might wanna try 'winetricks ps51' first, it will take about       approx. 15 minutes. Some other verbs might take 5 minutes on first time usage. But after you called a verb once this nuisance is gone.
- Files are cached in directory '$HOME/.cache/winetrickxs'
- Hopefully some better 64-bit support for some verbs.
- Possibility to extract a file and (try) install from an msu file. Do 'winetricks install_dll_from_msu' to see how.
- A rudimentary Powershell 5.1.
- experimental dotnet481 installation, and dotnet35 (might be needed by apps not satisfied with current dotnet48 installation).
- Autotab-completion. Note: while using multiple verbs from command line they have to be seperated by a comma
  from now on (this is how powershell handles multiple arguments)
  So 'winetricks riched20 gdiplus' won't work anymore, use 'winetricks riched20,gdiplus' instead
- Some programs fail to install/run due to wine-bugs. I added a few workarounds in winetricks, see below:
- A special verb to install requirements to get Affinity Photo/Designer started.
- Special verb (winetricks vs19)to install a working Visual Studio Community 2019 (see screenshot, >10 mins to install and requires approx. 10GB!, after install start devenv.exe from directory c:\Program\ Files (x86)\Microsoft Visual Studio\2019\Community\Common7\IDE/)
  ![screenshot](https://github.com/PietJankbal/Chocolatey-for-wine/assets/26839562/d576a619-c752-4eb1-81c2-6f6b66b50ff6)
- Special verb to get access to various unix commands like grep,sed, file, less etc. etc. (winetricks git.portable, Disclaimer: some commands do not yet work due to wine bug
- Also included a few powershell scripts adapted from codesnippets found on the internet:
    - How to embed an exe in a powershell script via Invoke-ReflectivePEInjection (the exe won't show up in tasklist).
    - How to make fancy messageboxes
    - Convert a powershell script (ps1) into an exe.
    - And a few other

Notes:

  - Do NOT use on existing wineprefix, only on fresh new created prefix! The installer just stupidly installs dotnet48 itsself and messes with registrykeys.
    If you have any dotnet version already installed with winetricks, it will likely fail, and even if it succeeds, you'll likely end up with a broken prefix.
    If you need to install stuff via winetricks for programs, do NOT use any of the dotnet* verbs. 
    BTW 'Arial' and 'd3dcompiler_47' verbs are already installed by default.
  - WINEARCH=win32 is _not_ supported!
  - Updating from a previous version is for now not (yet) supported, maybe later

Compile:
  - If you want to compile yourself instead of downloading binaries: see compilation instructions in mainv1.c  
  - Then copy choc_install.ps1 into the same directory
  - Then do 'wine ChoCinstaller_0.5i.715.exe'
  
