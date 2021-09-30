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
 * Compile:
 * i686-w64-mingw32-gcc -municode  -mconsole mainv1.c -lurlmon -s -o powershell32.exe
 * x86_64-w64-mingw32-gcc -municode  -mconsole mainv1.c -lurlmon -s -o powershell64.exe
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

    WCHAR tmp[MAX_PATH];
    const WCHAR pwsh_exeW[] = L"pwsh.exe"; const WCHAR pwsh20_exeW[] = L"powershell20l.exe";
    WCHAR start_conemuW[MAX_PATH];
    WCHAR cur_dirW[MAX_PATH];
    WCHAR cmdlineW [MAX_PATH]=L"";
    WCHAR cmdW[MAX_PATH] = L"-c ";

    BOOL contains_noexit = 0; BOOL use_pwsh20 = 0;
    WCHAR envvar[MAX_PATH] = L"";
    const WCHAR *new_args[3];
    WCHAR pwsh_pathW[MAX_PATH]; WCHAR pwsh20_pathW[MAX_PATH];
    WCHAR *bufW = NULL;
    DWORD exitcode;

    if(!ExpandEnvironmentStringsW(L"%ProgramW6432%", pwsh_pathW, MAX_PATH+1)) goto failed; /* win32 only apparently, not supported... */
    if(!ExpandEnvironmentStringsW(L"%SystemRoot%", pwsh20_pathW, MAX_PATH+1)) goto failed; /* win32 only apparently, not supported... */
    if(!ExpandEnvironmentStringsW(L"%SystemDrive%", start_conemuW, MAX_PATH+1)) goto failed; /* win32 only apparently, not supported... */

    lstrcatW(start_conemuW, L"\\ConEmu\\ConEmu.exe");
    lstrcatW(pwsh_pathW, L"\\Powershell\\7\\pwsh.exe"); lstrcatW(pwsh20_pathW, L"\\system32\\WindowsPowerShell\\v1.0\\powershell20l.exe");
    /* I can also act as a dummy program as long as my exe-name doesn`t end with the letter "l" .... */
    if ( wcsncmp  (  &argv[0][lstrlenW(argv[0]) - 5 ]  , L"l" , 1 ) )
        {fprintf(stderr, "This is wusa-dummy, installing nothing... \n"); return 0;}
    
    if ( (GetFileAttributesW(pwsh_pathW) != INVALID_FILE_ATTRIBUTES) )
        goto already_installed;

    /* Download */
    GetCurrentDirectoryW(MAX_PATH+1, cur_dirW);

    fprintf(stderr, "Downloading Files...\n");

    const WCHAR url_destination[][MAX_PATH] = {L"https://github.com/PowerShell/PowerShell/releases/download/v7.0.3/PowerShell-7.0.3-win-x64.msi",
                                               L"PowerShell-7.0.3-win-x64.msi",
                                               L"https://conemu.github.io/install2.ps1",
                                               L"install2.ps1",
                                               L"https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/choc_install.ps1",
                                               L"choc_install.ps1"
                                             };

    for(i=0; i < ARRAY_SIZE(url_destination);i+=2)
    {   
        GetTempPathW(MAX_PATH,tmp);
        fwprintf(stderr, L"\033[1;93m"); fwprintf(stderr, L"\nDownloading %ls \n", url_destination[i+1]); fwprintf(stderr, L"\033[0m\n");
        if( URLDownloadToFileW(NULL, url_destination[i], lstrcatW(tmp, url_destination[i+1]), 0, NULL) != S_OK ) goto failed;
    }
    fprintf(stderr, "Files Successfully Downloaded \n");

    GetTempPathW(MAX_PATH, tmp); SetCurrentDirectoryW(tmp);
       
    STARTUPINFOW startup_info;
    PROCESS_INFORMATION process_info;
    memset(&startup_info, 0, sizeof(STARTUPINFO));
    startup_info.cb = sizeof(STARTUPINFO);
    memset(&process_info, 0, sizeof(PROCESS_INFORMATION));
    
    WCHAR argsW[MAX_PATH] = L" /i "; WCHAR msiexecW[MAX_PATH]; 
    if(!ExpandEnvironmentStringsW(L"%winsysdir%", msiexecW, MAX_PATH+1)) goto failed;

    CreateProcessW(lstrcatW(msiexecW,L"\\msiexec.exe"), lstrcatW(  lstrcatW(argsW,L"PowerShell-7.0.3-win-x64.msi"),L" /q")     ,0,0,0,0,0,0,&startup_info,&process_info); SetCurrentDirectoryW(cur_dirW);
    WaitForSingleObject( process_info.hProcess, INFINITE ); //Wait for it to finish.
    // Get the exit code : result = GetExitCodeProcess(processInformation.hProcess, &exitCode);
    CloseHandle( process_info.hProcess ); CloseHandle( process_info.hThread );   

    memset(&startup_info, 0, sizeof(STARTUPINFO)); memset(&process_info, 0, sizeof(PROCESS_INFORMATION));
    argsW[0] = 0;

    CreateProcessW(pwsh_pathW, lstrcatW(lstrcatW(lstrcatW(argsW,L" -file "), tmp), L"\\install2.ps1"),0,0,0,0,0,0,&startup_info,&process_info); //Sleep(10000);
    WaitForSingleObject( process_info.hProcess, INFINITE ); //Wait for it to finish.
    // Get the exit code : result = GetExitCodeProcess(processInformation.hProcess, &exitCode);
    CloseHandle( process_info.hProcess ); CloseHandle( process_info.hThread );  
    memset(&startup_info, 0, sizeof(STARTUPINFO)); memset(&process_info, 0, sizeof(PROCESS_INFORMATION));
    argsW[0] = 0;
    CreateProcessW(pwsh_pathW, lstrcatW(lstrcatW(lstrcatW(argsW,L" -file "), tmp), L"\\choc_install.ps1"),0,0,0,0,0,0,&startup_info,&process_info);
    WaitForSingleObject( process_info.hProcess, INFINITE ); //Wait for it to finish.
    CloseHandle( process_info.hProcess ); CloseHandle( process_info.hThread );   

already_installed:

    for (i = 1; i < argc; i++) /* concatenate all args into one single commandline */
    {
        if (!_wcsnicmp(L"-ve", argv[i],3)) i +=2;    /* -Version, just skip*/

        if(!argv[i]) break;
        
        if (!_wcsnicmp(L"-nop", argv[i],4)) i +=1;    /* -NoProfile, just skip*/

        if(!argv[i]) break;

        if (!_wcsicmp(L"Install-WindowsUpdate.ps1", argv[i])) return 0;

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
                                        L"notdeeded",                                L"probably"
                                      };
    if (GetEnvironmentVariable(L"PWSHVERBOSE", envvar, MAX_PATH+1)) 
        {fwprintf(stderr, L"\033[1;35m"); fwprintf(stderr, L"\nold command line is %ls \n", cmdlineW); fwprintf(stderr, L"\033[0m\n");}

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

    if (GetEnvironmentVariable(L"PWSHVERBOSE", envvar, MAX_PATH+1))
        {fwprintf(stderr, L"\033[1;93m"); fwprintf(stderr, L"\nnew command line is %ls \n", cmdlineW); fwprintf(stderr, L"\033[0m\n");}

    if (GetEnvironmentVariable(L"WINEPWSH", envvar, MAX_PATH+1)  && !_wcsicmp(L"PWSH20", envvar) ) use_pwsh20 = TRUE;

//  new_args[0] = !use_pwsh20 ? pwsh_exeW : pwsh20_exeW;
//  new_args[1] = cmdlineW;
//  new_args[2] = NULL;

    /* HACK  It crashes with Invalid Handle if -noexit is present or just e.g. "powershell -nologo"; if powershellconsole is started it doesn`t crash... */
    if(!cmd_idx || contains_noexit)
    {
        memset(&startup_info, 0, sizeof(STARTUPINFO)); memset(&process_info, 0, sizeof(PROCESS_INFORMATION));
        argsW[0] = 0;
        if(!use_pwsh20)
        {
            CreateProcessW(start_conemuW, lstrcatW(lstrcatW(argsW, L" -resetdefault -Title \"This is Powershell Core (pwsh.exe), not (!) powershell.exe\" -run pwsh.exe "),cmdlineW),0,0,0,0,0,0,&startup_info,&process_info);
            WaitForSingleObject( process_info.hProcess, INFINITE ); //Wait for it to finish.
            CloseHandle( process_info.hProcess ); CloseHandle( process_info.hThread );
        }// _wsystem(lstrcatW(lstrcatW(start_conemuW, L" -resetdefault -Title \"This is Powershell Core (pwsh.exe), not (!) powershell.exe\" -run pwsh.exe "), cmdlineW));
        else
        {
            CreateProcessW(start_conemuW, lstrcatW(lstrcatW(argsW, L" -resetdefault -run powershell20l.exe "),cmdlineW),0,0,0,0,0,0,&startup_info,&process_info);
            WaitForSingleObject( process_info.hProcess, INFINITE ); //Wait for it to finish.
            CloseHandle( process_info.hProcess ); CloseHandle( process_info.hThread ); 
        }// _wsystem(lstrcatW(lstrcatW(start_conemuW, L" -resetdefault -run powershell20l.exe "), cmdlineW));
    
         return 0;
    }

    //   _wspawnv(2/*_P_OVERLAY*/, !use_pwsh20 ? pwsh_pathW : pwsh20_pathW, new_args);
    memset(&startup_info, 0, sizeof(STARTUPINFO)); memset(&process_info, 0, sizeof(PROCESS_INFORMATION));
    //argsW[0] = 0;
    CreateProcessW(!use_pwsh20 ? pwsh_pathW : pwsh20_pathW, cmdlineW,0,0,0,0,0,0,&startup_info,&process_info);
    WaitForSingleObject( process_info.hProcess, INFINITE ); //Wait for it to finish.
    if(!GetExitCodeProcess(process_info.hProcess, &exitcode)) goto failed;
    CloseHandle( process_info.hProcess ); CloseHandle( process_info.hThread );    

    return exitcode;

failed:
    fprintf(stderr, "Something went wrong :( (32-bit?, winversion <win7?, failing download? ....  \n");
    return 0; /* fake success anyway */
}
