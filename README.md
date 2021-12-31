# Chocolatey-for-wine
Chocolatey packagemanager automatic installer in wine, handy to install quickly programs in wine

Install :
- wget https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/chocinstaller.exe
- wine chocinstaller.exe
- Update: Now chocolateys builtin powershell-host is disabled in the installscript, so we don`t have to install
        powershell2.0, and added an experimental dotnet48 installation that is much quicker than the plain old recipe.
        This way install time went down from 5 minutes to about 2 minutes. The old installer can still be found in
        the folder 'deprecated' 

Optional:
- Check if things went well: "choco install chromium -y" and  "start chrome.exe"
  
  Or if you like to install via GUI: "choco install ChocolateyGUI" and "start chocolateygui.exe"

- Update 2: Added a custom (ps-)winetricks script to keep myself busy during lockdown, and to get some progams 
           (hopefully) better running. All experimental, use at your own risk...
           Drawback: eats whopping gigs of diskspace. Pro/goal: hopefully more 64-bit compatibility...
           If you don't want this ps-winetricks, just don't call it then it won't get downloaded/installed (or remove it from                  c:\\Program Files\\Powershell\\7\\profile.ps1)

Notes:

  - Only works on recent wine-versions (>5.18 probably); Will fail for sure in wine-stable 5.0....
  - Do NOT use on existing wineprefix, only on fresh new created prefix! The installation just stupidly installs dotnet48 itsself and messes with registrykeys.
    If you have any dotnet version already installed with winetricks, it will likely fail, and even if it succeeds, you'll likely end up with a broken prefix.
    If you need to install stuff via winetricks for programs, do not use any of the dotnet* verbs. 
    BTW 'Arial' and 'd3dcompiler_47' verbs are already installed by default.
  - WINEARCH=win32 is _not_ supported!
  - If you want to compile yourself instead of downloading binaries:
    
    i686-w64-mingw32-gcc -municode -mconsole mainv1.c -lurlmon -s -o powershell32.exe

    x86_64-w64-mingw32-gcc -municode -mconsole mainv1.c -lurlmon -s -o powershell64.exe
    
    Then copy 
    - powershell32.exe to ~/.wine/drive_c/windows/syswow64/WindowsPowerShell/v1.0/powershell.exe
    - powershell64.exe to ~/.wine/drive_c/windows/system32/WindowsPowerShell/v1.0/powershell.exe

    and do "wine powershell"
