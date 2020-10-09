/*
 * Installs chocolatey
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
 *
 * Commands that Waves Central calls, the last one fails but not fatal for Waves Central
 * powershell.exe Write-Host $PSVersionTable.PSVersion.Major $PSVersionTable.PSVersion.Minor
 * powershell.exe -command &{'{0}.{1}' -f $PSVersionTable.PSVersion.Major, $PSVersionTable.PSVersion.Minor}
 * powershell.exe (Get-PSDrive C).Free
 * powershell.exe -noLogo -noExit  -c Register-WMIEvent -Query 'SELECT * FROM Win32_DeviceChangeEvent WHERE (EventType = 2 OR EventType = 3) GROUP WITHIN 4' -Action { [System.Console]::WriteLine('Devices Changed') }
 *
 * Compile:
 * i686-w64-mingw32-gcc -municode  -mconsole main.c -lurlmon -luser32 -lntdll -s -o powershell.exe
 * x86_64-w64-mingw32-gcc -municode  -mconsole main.c -lurlmon -luser32 -lntdll -s -o powershell.exe
 */

#define WIN32_LEAN_AND_MEAN
#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))

#include <windows.h>
#include <winuser.h>
#include <winternl.h>
#include <winbase.h>
#include <stdio.h>
#include <stdlib.h>
#include <urlmon.h>
#include <wchar.h>

NTSTATUS WINAPI RtlGetVersion(RTL_OSVERSIONINFOEXW*);

/* Following function taken from https://creativeandcritical.net/downloads/replacebench.c which is in public domain; Credits to the there mentioned authors*/
/* replaces in the string "str" all the occurrences of the string "sub" with the string "rep" */
wchar_t* replace_smart (const wchar_t *str, const wchar_t *sub, const wchar_t *rep)
{
    size_t slen = lstrlenW(sub);
    size_t rlen = lstrlenW(rep);
    size_t size = lstrlenW(str) + 1;
    size_t diff = rlen - slen;
    size_t capacity = (diff>0 && slen) ? 2 * size : size;
    wchar_t *buf = (wchar_t *)HeapAlloc(GetProcessHeap(),8,sizeof(wchar_t)*capacity);
    wchar_t *find, *b = buf;

    if (b == NULL) return NULL;
    if (slen == 0) return memcpy(b, str, sizeof(wchar_t)*size);

    while((find = /*strstrW*/(wchar_t *)wcsstr((const wchar_t *)str, (const wchar_t *)sub))) {
        if ((size += diff) > capacity) {
            wchar_t *ptr = (wchar_t *)HeapReAlloc(GetProcessHeap(), 0, buf, capacity = 2 * size*sizeof(wchar_t));
            if (ptr == NULL) {HeapFree(GetProcessHeap(), 0, buf); return NULL;}
            b = ptr + (b - buf);
            buf = ptr;
        }
        memcpy(b, str, (find - str) * sizeof(wchar_t)); /* copy up to occurrence */
        b += find - str;
        memcpy(b, rep, rlen * sizeof(wchar_t));       /* add replacement */
        b += rlen;
        str = find + slen;
    }
    memcpy(b, str, (size - (b - buf)) * sizeof(wchar_t));
    b = (wchar_t *)HeapReAlloc(GetProcessHeap(), 0, buf, size * sizeof(wchar_t));         /* trim to size */
    return b ? b : buf;
}

int __cdecl wmain(int argc, WCHAR *argv[])
{
    int i, cmd_idx = 0;

    char tmp[MAX_PATH];
    const WCHAR pwsh_exeW[] = L"pwsh.exe";
    WCHAR start_conemuW[MAX_PATH] = L"%SystemDrive%\\ConEmu\\ConEmu.exe";
    WCHAR cur_dirW[MAX_PATH];
    WCHAR cmdlineW [MAX_PATH]=L"";
    WCHAR cmdW[MAX_PATH] = L"-c ";

    BOOL contains_noexit = 0;
    const WCHAR *new_args[3];
    WCHAR pwsh_pathW[MAX_PATH];
    WCHAR *bufW = NULL;
    RTL_OSVERSIONINFOEXW info;

    if(!ExpandEnvironmentStringsW(L"%ProgramW6432%", pwsh_pathW, MAX_PATH+1)) goto failed; /* win32 only apparently, not supported... */

    lstrcatW(pwsh_pathW, L"\\Powershell\\7\\pwsh.exe");

    if ( (GetFileAttributesW(pwsh_pathW) != INVALID_FILE_ATTRIBUTES) )
        goto already_installed;

    /* Download */

    info.dwOSVersionInfoSize = sizeof(RTL_OSVERSIONINFOEXW);
    if (RtlGetVersion(&info)) goto failed;;
    if (info.dwMajorVersion < 6 || (info.dwMajorVersion == 6 && info.dwMinorVersion < 1) ) goto failed;

    MessageBoxA(NULL, "Looks like Powershell Core is not installed \nWill start downloading and install now\n \
    This will take quite some time!!!\nNo progress bar is shown!", "Message", MB_ICONWARNING | MB_OK);

    GetCurrentDirectoryW(MAX_PATH+1, cur_dirW);

    fprintf(stderr, "Downloading Files...\n");

    const char url_destination[][MAX_PATH] = { "https://github.com/PowerShell/PowerShell/releases/download/v7.0.3/PowerShell-7.0.3-win-x64.msi",
                                               "PowerShell-7.0.3-win-x64.msi",
                                               "https://conemu.github.io/install2.ps1",
                                               "install2.ps1",
                                               "http://download.windowsupdate.com/msdownload/update/software/updt/2009/11/windowsserver2003-kb968930-x64-eng_8ba702aa016e4c5aed581814647f4d55635eff5c.exe",
                                               "windowsserver2003-kb968930-x64-eng_8ba702aa016e4c5aed581814647f4d55635eff5c.exe",
                                             };

    for(i=0; i < ARRAY_SIZE(url_destination);i+=2)
    {   
        GetTempPathA(MAX_PATH,tmp);
        if( URLDownloadToFileA(NULL, url_destination[i], strcat(tmp, url_destination[i+1]), 0, NULL) != S_OK ) goto failed;
    }
    fprintf(stderr, "Files Successfully Downloaded \n");

    GetTempPathA(MAX_PATH, tmp); SetCurrentDirectoryA(tmp);
    system("start /WAIT msiexec.exe /i PowerShell-7.0.3-win-x64.msi /*INSTALLFOLDER=\"C:\\Windows\\Powershell6\\\"*/ /q");
    system("start /WAIT pwsh.exe -file install2.ps1");

    system("copy %SystemDrive%\\windows\\SysNative\\WindowsPowerShell\\v1.0\\powershell.exe %SystemDrive%\\windows\\SysNative\\WindowsPowerShell\\v1.0\\powershell_orig.exe /y");
    system("copy %WinSysDir%\\WindowsPowerShell\\v1.0\\powershell.exe %WinSysDir%\\WindowsPowerShell\\v1.0\\powershell_orig.exe /y");

    system("start /WAIT winecfg.exe /v win2003");
    system("start /WAIT windowsserver2003-kb968930-x64-eng_8ba702aa016e4c5aed581814647f4d55635eff5c.exe /q /passive /nobackup");

    system("copy %SystemDrive%\\windows\\SysNative\\WindowsPowerShell\\v1.0\\powershell.exe %SystemDrive%\\windows\\SysNative\\WindowsPowerShell\\v1.0\\powershell20.exe /y");
    system("copy %WinSysDir%\\WindowsPowerShell\\v1.0\\powershell.exe %WinSysDir%\\WindowsPowerShell\\v1.0\\powershell20.exe /y");

    system("copy %SystemDrive%\\windows\\SysNative\\WindowsPowerShell\\v1.0\\powershell_orig.exe %SystemDrive%\\windows\\SysNative\\WindowsPowerShell\\v1.0\\powershell.exe /y");
    system("copy %WinSysDir%\\WindowsPowerShell\\v1.0\\powershell_orig.exe %WinSysDir%\\WindowsPowerShell\\v1.0\\powershell.exe /y");

    system("start /WAIT winecfg.exe /v win7");
    /*Try fix wrong registrykeys from bug https://bugs.winehq.org/show_bug.cgi?id=25740 , probably not necessary after all ...... */
    system(" start /WAIT pwsh.exe -c New-ItemProperty -Path 'HKLM:\\Software\\Classes\\Microsoft.PowerShellConsole.1\\shell\\open\\command' -force -Name '(Default)' -Value   'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\powershell.exe -p %1 '  -PropertyType 'String' ");
    system(" start /WAIT pwsh.exe -c New-ItemProperty -Path 'HKLM:\\Software\\Classes\\Microsoft.PowerShellConsole.1\\shell\\Run as 32\\command' -force -Name '(Default)' -Value   'c:\\windows\\sysWOW64\\WindowsPowerShell\\v1.0\\powershell.exe -p %1 '  -PropertyType 'String' ");
    system(" start /WAIT pwsh.exe -c New-ItemProperty -Path 'HKLM:\\Software\\Classes\\Microsoft.PowerShellData.1\\shell\\Edit\\command' -force -Name '(Default)' -Value   'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\powershell_ise.exe %1 '  -PropertyType 'String' ");
    system(" start /WAIT pwsh.exe -c New-ItemProperty -Path 'HKLM:\\Software\\Classes\\Microsoft.PowerShellData.1\\shell\\Open\\command' -force -Name '(Default)' -Value   'c:\\windows\\system32\\notepad.exe %1 '  -PropertyType 'String' ");
    system(" start /WAIT pwsh.exe -c New-ItemProperty -Path 'HKLM:\\Software\\Classes\\Microsoft.PowerShellModule.1\\shell\\Edit\\command' -force -Name '(Default)' -Value   'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\powershell_ise.exe %1 '  -PropertyType 'String' ");
    system(" start /WAIT pwsh.exe -c New-ItemProperty -Path 'HKLM:\\Software\\Classes\\Microsoft.PowerShellModule.1\\shell\\Open\\command' -force -Name '(Default)' -Value   'c:\\windows\\system32\\notepad.exe %1 '  -PropertyType 'String' ");
    system(" start /WAIT pwsh.exe -c New-ItemProperty -Path 'HKLM:\\Software\\Classes\\Microsoft.PowerShellScript.1\\DefaultIcon' -force -Name '(Default)' -Value   'c:\\windows\\system32\\WindowsPowerShell\\V1.0\\powershell_ise.exe,1'  -PropertyType 'String' ");
    system(" start /WAIT pwsh.exe -c New-ItemProperty -Path 'HKLM:\\Software\\Classes\\Microsoft.PowerShellScript.1\\shell\\Edit\\command' -force -Name '(Default)' -Value   'c:\\windows\\system32\\WindowsPowerShell\\V1.0\\powershell_ise.exe %1 '  -PropertyType 'String' ");
    system(" start /WAIT pwsh.exe -c New-ItemProperty -Path 'HKLM:\\Software\\Classes\\Microsoft.PowerShellScript.1\\shell\\Open\\command' -force -Name '(Default)' -Value   'c:\\windows\\system32\\notepad.exe %1 '  -PropertyType 'String' ");
    system(" start /WAIT pwsh.exe -c New-ItemProperty -Path 'HKLM:\\Software\\Classes\\Microsoft.PowerShellScript.1\\shell\\Run with PowerShell\\command' -Name '(Default)' -force -Value   'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\powershell.exe -file %1 '  -PropertyType 'String' ");
    system(" start /WAIT pwsh.exe -c New-ItemProperty -Path 'HKLM:\\Software\\Classes\\VBSFile\\Shell\\Edit\\Command' -force -Name '(Default)' -Value   'c:\\windows\\system32\\notepad.exe %1'  -PropertyType 'String' ");
    system(" start /WAIT pwsh.exe -c New-ItemProperty -Path 'HKLM:\\Software\\Classes\\VBSFile\\Shell\\Open\\Command' -force -Name '(Default)' -Value   'c:\\windows\\system32\\wscript.exe %1 %*'  -PropertyType 'String' ");
    system(" start /WAIT pwsh.exe -c New-ItemProperty -Path 'HKLM:\\Software\\Classes\\VBSFile\\Shell\\Open2\\Command' -force -Name '(Default)' -Value   'c:\\windows\\system32\\cscript.exe %1 %*'  -PropertyType 'String' ");
    system(" start /WAIT pwsh.exe -c New-ItemProperty -Path 'HKLM:\\Software\\Classes\\VBSFile\\Shell\\Print\\Command' -force -Name '(Default)' -Value   'c:\\windows\\system32\\notepad.exe /p %1'  -PropertyType 'String' ");
    system(" start /WAIT pwsh.exe -c New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\Cryptography\\OID\\EncodingType 0\\CryptSIPDllCreateIndirectData\\{603BCC1F-4B59-4E08-B724-D2C6297EF351}' -force -Name 'Dll'         -Value 'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\pwrshsip.dll'  -PropertyType 'String' ");
    system(" start /WAIT pwsh.exe -c New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\Cryptography\\OID\\EncodingType 0\\CryptSIPDllGetSignedDataMsg\\{603BCC1F-4B59-4E08-B724-D2C6297EF351}' -force -Name 'Dll'         -Value 'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\pwrshsip.dll'  -PropertyType 'String' ");
    system(" start /WAIT pwsh.exe -c New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\Cryptography\\OID\\EncodingType 0\\CryptSIPDllIsMyFileType2\\{603BCC1F-4B59-4E08-B724-D2C6297EF351}' -force -Name 'Dll'         -Value 'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\pwrshsip.dll'  -PropertyType 'String' ");
    system(" start /WAIT pwsh.exe -c New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\Cryptography\\OID\\EncodingType 0\\CryptSIPDllPutSignedDataMsg\\{603BCC1F-4B59-4E08-B724-D2C6297EF351}' -force -Name 'Dll'         -Value 'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\pwrshsip.dll'  -PropertyType 'String' ");
    system(" start /WAIT pwsh.exe -c New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\Cryptography\\OID\\EncodingType 0\\CryptSIPDllRemoveSignedDataMsg\\{603BCC1F-4B59-4E08-B724-D2C6297EF351}' -force -Name 'Dll'        -Value 'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\pwrshsip.dll'  -PropertyType 'String' ");
    system(" start /WAIT pwsh.exe -c New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\Cryptography\\OID\\EncodingType 0\\CryptSIPDllVerifyIndirectData\\{603BCC1F-4B59-4E08-B724-D2C6297EF351}' -force -Name 'Dll'         -Value 'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\pwrshsip.dll'  -PropertyType 'String' ");
    system(" start /WAIT pwsh.exe -c New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\PowerShell\\1\\PowerShellEngine' -force -Name 'ApplicationBase'        -Value 'c:\\windows\\system32\\WindowsPowerShell\\v1.0'  -PropertyType 'String' ");
    system(" start /WAIT pwsh.exe -c New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\PowerShell\\1\\PowerShellEngine' -force -Name 'ConsoleHostModuleName'  -Value 'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\Microsoft.PowerShell.ConsoleHost.dll'  -PropertyType 'String' ");
    system(" start /WAIT pwsh.exe -c New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\PowerShell\\1\\ShellIds\\Microsoft.PowerShell' -force -Name 'Path'        -Value 'c:\\windows\\system32\\WindowsPowerShell\\v1.0\\powershell.exe'  -PropertyType 'String' ");
    system(" start /WAIT pwsh.exe -c New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\WSMAN\\Plugin\\Event' -force -Name 'Forwarding Plugin ConfigXML'   -Value '<PlugInConfiguration xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Name=\"Event Forwarding Plugin\" Filename=\"c:\\windows\\system32\\wevtfwd.dll\" SDKVersion=\"1\" XmlRenderingType=\"text\" ><Resources><Resource ResourceUri=\"http://schemas.microsoft.com/wbem/wsman/1/windows/EventLog\" SupportsOptions=\"true\" ><Security Uri=\"\" ExactMatch=\"false\" Sddl=\"O:NSG:BAD:P(A;;GA;;;BA)S:P(AU;FA;GA;;;WD)(AU;SA;GWGX;;;WD)\" /><Capability Type=\"Subscribe\" SupportsFiltering=\"true\" /></Resource></Resources></PlugInConfiguration>'  -PropertyType 'String' ");
    system(" start /WAIT pwsh.exe -c New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\WSMAN\\Plugin\\SEL Plugin' -force -Name 'ConfigXML'   -Value '<PlugInConfiguration xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Name=\"SEL Plugin\" Filename=\"c:\\windows\\system32\\wsmselpl.dll\" SDKVersion=\"1\" XmlRenderingType=\"text\" ><Resources><Resource ResourceUri=\"http://schemas.microsoft.com/wbem/wsman/1/logrecord/sel\" SupportsOptions=\"true\" ><Security Uri=\"\" ExactMatch=\"false\" Sddl=\"O:NSG:BAD:P(A;;GA;;;BA)(A;;GA;;;NS)S:P(AU;FA;GA;;;WD)(AU;SA;GXGW;;;WD)\" /><Capability Type=\"Subscribe\" /></Resource></Resources></PlugInConfiguration>'  -PropertyType 'String' ");
    system(" start /WAIT pwsh.exe -c New-ItemProperty -Path 'HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\WSMAN\\Plugin\\WMI' -force -Name 'Provider ConfigXML'   -Value '<PlugInConfiguration xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Name=\"WMI Provider\" Filename=\"c:\\windows\\system32\\WsmWmiPl.dll\" SDKVersion=\"1\" XmlRenderingType=\"text\" ><Resources><Resource ResourceUri=\"http://schemas.microsoft.com/wbem/wsman/1/wmi\" SupportsOptions=\"true\" ><Capability Type=\"Get\" SupportsFragment=\"true\" /><Capability Type=\"Put\" SupportsFragment=\"true\" /><Capability Type=\"Invoke\" /><Capability Type=\"Enumerate\" SupportsFiltering=\"true\"/></Resource><Resource ResourceUri=\"http://schemas.dmtf.org/wbem/wscim/1/cim-schema\" SupportsOptions=\"true\" ><Capability Type=\"Get\" SupportsFragment=\"true\" /><Capability Type=\"Put\" SupportsFragment=\"true\" /><Capability Type=\"Invoke\" /><Capability Type=\"Enumerate\" /></Resource><Resource ResourceUri=\"http://schemas.dmtf.org/wbem/wscim/1/*\" SupportsOptions=\"true\" ExactMatch=\"true\" ><Capability Type=\"Enumerate\" SupportsFiltering=\"true\"/></Resource></Resources></PlugInConfiguration>'  -PropertyType 'String' ");
    system(" start /WAIT pwsh.exe -c New-ItemProperty -Path 'HKLM:\\Software\\Wow6432Node\\Microsoft\\Cryptography\\OID\\EncodingType 0\\CryptSIPDllCreateIndirectData\\{603BCC1F-4B59-4E08-B724-D2C6297EF351}' -force -Name 'Dll'         -Value 'c:\\windows\\syswow64\\WindowsPowerShell\\v1.0\\pwrshsip.dll'  -PropertyType 'String' ");
    system(" start /WAIT pwsh.exe -c New-ItemProperty -Path 'HKLM:\\Software\\Wow6432Node\\Microsoft\\Cryptography\\OID\\EncodingType 0\\CryptSIPDllGetSignedDataMsg\\{603BCC1F-4B59-4E08-B724-D2C6297EF351}' -force -Name 'Dll'         -Value 'c:\\windows\\syswow64\\WindowsPowerShell\\v1.0\\pwrshsip.dll'  -PropertyType 'String' ");
    system(" start /WAIT pwsh.exe -c New-ItemProperty -Path 'HKLM:\\Software\\Wow6432Node\\Microsoft\\Cryptography\\OID\\EncodingType 0\\CryptSIPDllIsMyFileType2\\{603BCC1F-4B59-4E08-B724-D2C6297EF351}' -force -Name 'Dll'         -Value 'c:\\windows\\syswow64\\WindowsPowerShell\\v1.0\\pwrshsip.dll'  -PropertyType 'String' ");
    system(" start /WAIT pwsh.exe -c New-ItemProperty -Path 'HKLM:\\Software\\Wow6432Node\\Microsoft\\Cryptography\\OID\\EncodingType 0\\CryptSIPDllPutSignedDataMsg\\{603BCC1F-4B59-4E08-B724-D2C6297EF351}' -force -Name 'Dll'         -Value 'c:\\windows\\syswow64\\WindowsPowerShell\\v1.0\\pwrshsip.dll'  -PropertyType 'String' ");
    system(" start /WAIT pwsh.exe -c New-ItemProperty -Path 'HKLM:\\Software\\Wow6432Node\\Microsoft\\Cryptography\\OID\\EncodingType 0\\CryptSIPDllRemoveSignedDataMsg\\{603BCC1F-4B59-4E08-B724-D2C6297EF351}' -force -Name 'Dll'         -Value 'c:\\windows\\syswow64\\WindowsPowerShell\\v1.0\\pwrshsip.dll'  -PropertyType 'String' ");
    system(" start /WAIT pwsh.exe -c New-ItemProperty -Path 'HKLM:\\Software\\Wow6432Node\\Microsoft\\Cryptography\\OID\\EncodingType 0\\CryptSIPDllVerifyIndirectData\\{603BCC1F-4B59-4E08-B724-D2C6297EF351}' -force -Name 'Dll'         -Value 'c:\\windows\\syswow64\\WindowsPowerShell\\v1.0\\pwrshsip.dll'  -PropertyType 'String' ");
    system(" start /WAIT pwsh.exe -c New-ItemProperty -Path 'HKLM:\\Software\\Wow6432Node\\Microsoft\\PowerShell\\1\\PowerShellEngine' -force -Name 'ApplicationBase'        -Value 'c:\\windows\\syswow64\\WindowsPowerShell\\v1.0'  -PropertyType 'String' ");
    system(" start /WAIT pwsh.exe -c New-ItemProperty -Path 'HKLM:\\Software\\Wow6432Node\\Microsoft\\PowerShell\\1\\PowerShellEngine' -force -Name 'ConsoleHostModuleName'   -Value 'c:\\windows\\syswow64\\WindowsPowerShell\\v1.0\\Microsoft.PowerShell.ConsoleHost.dll'  -PropertyType 'String' ");
    system(" start /WAIT pwsh.exe -c New-ItemProperty -Path 'HKLM:\\Software\\Wow6432Node\\Microsoft\\PowerShell\\1\\ShellIds\\Microsoft.PowerShell' -force -Name 'Path'        -Value 'c:\\windows\\syswow64\\WindowsPowerShell\\v1.0\\powershell.exe'  -PropertyType 'String' ");
    system(" start /WAIT pwsh.exe -c New-ItemProperty -Path 'HKLM:\\System\\CurrentControlSet\\Services\\WinRM' -force -Name 'ImagePath'         -Value 'c:\\windows\\system32\\svchost.exe -k WINRM'  -PropertyType 'String' ");
    /* Install choco */
    system("start /WAIT pwsh.exe -c Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) ");

    SetCurrentDirectoryW(cur_dirW); 

    fprintf(stderr, "FIXME Waiting for 5 secs to finish things, otherwise it just fails on first run...  \n");
    Sleep(5000);
    MessageBoxA(NULL, "Done, but you _must_ do \"winetricks dotnet40 dotnet48\"\n. After that restart \"wine powershell\" and try e.g. \"choco install audacity -y\" to check if things work... \n" , "Message", MB_ICONWARNING | MB_OK);
    return 0;

already_installed:

    for (i = 1; i < argc; i++) /* concatenate all args into one single commandline */
    {
        if (!_wcsnicmp(L"-ve", argv[i],3)) i +=2;    /* -Version, just skip*/

        if(!argv[i]) break;

        lstrcatW(cmdlineW, L" "); lstrcatW(cmdlineW, argv[i]); 

        if (!_wcsnicmp(L"-noe", argv[i],4)) contains_noexit++;   /* -NoExit */
    }

    i = 1;

     /* pwsh requires a command option "-c" , powershell doesn`t e.g. "powershell -NoLogo echo $env:username" should go
    into "pwsh -NoLogo -c echo $env:username".... */

    while(i<argc) /* Step through all options until we reach command */
    {
        if ( !_wcsnicmp(L"-c", argv[i],2) )    /* -Command or -c */
        {
            cmd_idx = i;
            break;
        }     
        /* try handle something like powershell -nologo -windowstyle normal -outputformat text -version 1.0 echo \$env:username */
        if ( !_wcsnicmp(L"-f", argv[i],2)  ||  /* -File */              !_wcsnicmp(L"-ps", argv[i],3) ||  /* -PSConsoleFile */ \
             !_wcsnicmp(L"-ve", argv[i],3) ||  /* -Version */           !_wcsnicmp(L"-in", argv[i],3) ||  /* -InputFormat */ \
             !_wcsnicmp(L"-ou", argv[i],3) ||  /* -OutputFormat */      !_wcsnicmp(L"-wi", argv[i],3) ||  /* -WindowStyle */ \
             !_wcsnicmp(L"-en", argv[i],3) ||  /* -EncodedCommand */    !_wcsnicmp(L"-ex", argv[i],3)     /* -ExecutionPolicy */ )
             {
                 i++;
                 goto done;
             }

        if ( !_wcsnicmp(L"-", argv[i],1) ) goto done;      /* -nologo or -noexit etc.*/
        /* We should now have arrived at (1st) command */
        lstrcatW(cmdW,argv[i]); cmd_idx = i; break;

        done: i++;
    }
    /* Replace incompitable commands here (e.g. Get-WmiObject --> Get-CimInstance which btw doesn't work anyway atm, wine-bug??)             */
    /* Or just feed your app what it it wants, e.g. if something like [System.Math]::sqrt(64) wouldn`t work (it does work btw),              */
    /* feed it the desired output like below ....                                                                                            */
    /* put replacements here....        from                                         to                                                      */
    const WCHAR from_to[][MAX_PATH] = { L"[System.Math]::sqrt(64)",                  L"Write-Host 8",  /* just an example, not necassary.... */
                                        L"Get-WmiObject",                            L"Get-CimInstance"
                                      };

    fwprintf(stderr, L"\033[1;35m"); fwprintf(stderr, L"\nold command line is %ls \n", cmdlineW); fwprintf(stderr, L"\033[0m\n");

    if(cmd_idx)
    {
        bufW = replace_smart(cmdlineW, argv[cmd_idx], cmdW);
        lstrcpyW(cmdlineW, bufW); HeapFree(GetProcessHeap(), 0, bufW);
    }

    for(i=0; i < ARRAY_SIZE(from_to);i+=2)
    {
        bufW = replace_smart(cmdlineW, from_to[i], from_to[i+1]);
        lstrcpyW( cmdlineW, bufW ); HeapFree(GetProcessHeap(), 0, bufW);
    }

    fwprintf(stderr, L"\033[1;93m"); fwprintf(stderr, L"\nnew command line is %ls \n", cmdlineW); fwprintf(stderr, L"\033[0m\n");

    new_args[0] = pwsh_exeW;
    new_args[1] = cmdlineW;
    new_args[2] = NULL;

    /* HACK  It crashes with Invalid Handle if -noexit is present or just e.g. "powershell -nologo"; if powershellconsole is started it doesn`t crash... */
    if(!cmd_idx || contains_noexit)
    {
         _wsystem(lstrcatW(lstrcatW(start_conemuW, L" -resetdefault -run pwsh.exe "), cmdlineW));
         return 0;
    }

    _wspawnv(2/*_P_OVERLAY*/, pwsh_pathW, new_args);
    return 0;

failed:
    fprintf(stderr, "Something went wrong :( (32-bit?, winversion <win7?, failing download? ....  \n");
    return 0; /* fake success anyway */
}
