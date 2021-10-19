# Chocolatey-for-wine
Chocolatey packagemanager automatic installer in wine, handy to install quickly programs in wine

This is the old, deprecated, version

Install :
- wget https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/deprecated/chocdeprecatedinstaller.exe
- wine chocdeprecatedinstaller.exe (takes > 5 min. to complete...)

Optional:
- Backup the now created prefix, so you can just copy it back, instead of going through the (>5 min) timeconsuming installation of chocolatey again in case you removed your prefix
- Check if things went well: "choco install chromium -y"

Bonus:

  - As a bonus you get on top of powershell core, also powershell 2.0 that you can start with 'powershell_ise',
    or 'powershell20l.exe'

Notes:

  - Only works on recent wine-versions (>5.18 probably); Will fail for sure in wine-stable 5.0....
  - Do NOT use on existing wineprefix, only on fresh new created prefix! The installation just stupidly installs dotnet40/48 itsself and messes with registrykeys.
    If you have any dotnet version already installed with winetricks, it will likely fail, and even if it succeeds, you'll likely end up with a broken prefix.
  - WINEARCH=win32 is _not_ supported!
  - If you want to compile yourself instead of downloading binaries:
    
    i686-w64-mingw32-gcc -municode -mconsole mainv1.c -lurlmon -s -o powershell32.exe

    x86_64-w64-mingw32-gcc -municode -mconsole mainv1.c -lurlmon -s -o powershell64.exe
    
    Then copy 
    - powershell32.exe to ~/.wine/drive_c/windows/syswow64/WindowsPowerShell/v1.0/powershell.exe
    - powershell64.exe to ~/.wine/drive_c/windows/system32/WindowsPowerShell/v1.0/powershell.exe

    and do "wine powershell"
