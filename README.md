# Chocolatey-for-wine
Chocolatey packagemanager automatic installer in wine, handy to install quickly programs in wine

Install :
- Download and unzip the release zip-file and do 'wine ChoCinstaller_0.3.703.exe 

- Update: Now chocolateys builtin powershell-host is disabled in the installscript, so we don't have to install
        powershell2.0, and added an experimental dotnet48 installation that is much quicker than the plain old recipe.
        This way install time went down from 5 minutes to less then one minute. The old installer can still be found in
        the folder 'deprecated' 

- Update 2: As I was bored during lock-down I wrote a custom winetricks(.ps1) with some verbs I find handy. If you don't call it, it won't get downloaded so no overhead there. It eats gigs of diskspace, and takes lots of time during 1st time usage. But after things are cached it goes quickly + hopefully some better 64-bit support for some verbs + possibility to extract msu files + a rudimentary Powershell 4.0.  

Optional:
- Check if things went well: "choco install chromium -y" and  "start chrome.exe"  (--no-sandbox not needed anymore since wine-7.8)
  
  Or if you like to install via GUI: "choco install ChocolateyGUI" and "start chocolateygui.exe"

Notes:

  - Do NOT use on existing wineprefix, only on fresh new created prefix! The installation just stupidly installs dotnet48 itsself and messes with registrykeys.
    If you have any dotnet version already installed with winetricks, it will likely fail, and even if it succeeds, you'll likely end up with a broken prefix.
    If you need to install stuff via winetricks for programs, do NOT use any of the dotnet* verbs. 
    BTW 'Arial' and 'd3dcompiler_47' verbs are already installed by default.
  - WINEARCH=win32 is _not_ supported!
  - If you want to compile yourself instead of downloading binaries:
    
    i686-w64-mingw32-gcc -municode -mconsole mainv1.c -lurlmon -lshlwapi -s -o powershell32.exe

    x86_64-w64-mingw32-gcc -municode -mconsole mainv1.c -lurlmon -lshlwapi -s -o ChoCinstaller_0.3.703.exe
    
  - Then copy choc_install.ps1 into the same directory
  - Then do 'wine ChoCinstaller_0.3.703.exe'
  
