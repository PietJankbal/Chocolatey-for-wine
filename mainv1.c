/* Installs PowerShell Core, wraps powershell`s commandline into correct syntax for pwsh.exe,
 * and some code that allows calls to an exe (like wusa.exe) to be replaced by a function in profile.ps1
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
 * Compile: // For fun I changed code from standard main(argc,*argv[]) to something like https://nullprogram.com/blog/2016/01/31/)
 * x86_64-w64-mingw32-gcc -O1 -fno-ident -fno-stack-protector -fomit-frame-pointer -fno-unwind-tables -fno-asynchronous-unwind-tables -falign-functions=1 -falign-jumps=1 -falign-loops=1 -fwhole-program\
 -mconsole -municode -mno-stack-arg-probe -Xlinker --stack=0x200000,0x200000 -nostdlib  -Wall -Wextra -ffreestanding  mainv1.c -lurlmon -lkernel32 -lucrtbase -luser32 -nostdlib -lshell32 -lntdll -s -o ChoCinstaller_0.5e.715.exe
 * i686-w64-mingw32-gcc -O1 -fno-ident -fno-stack-protector -fomit-frame-pointer -fno-unwind-tables -fno-asynchronous-unwind-tables -falign-functions=1 -falign-jumps=1 -falign-loops=1 -fwhole-program\
 -mconsole -municode -mno-stack-arg-probe -Xlinker --stack=0x200000,0x200000 -nostdlib  -Wall -Wextra -ffreestanding mainv1.c -lurlmon -lkernel32 -lucrtbase -luser32 -nostdlib -lshell32 -lntdll -s -o powershell32.exe
 * Btw: The included binaries are compressed with upx to make them even smaller (choco install upx):
 */
#include <stdio.h>
#include <windows.h>
#include <winternl.h>

/* for e.g. -noprofile, -nologo , -mta etc */ 
static inline BOOL is_single_option(WCHAR* opt) { return (wcschr(L"nNmMsS", opt[1]) ? TRUE : FALSE); }
/* no new options may follow -c, -f , and -e (but not -ex(ecutionpolicy)!) */ 
static inline BOOL is_last_option(WCHAR* opt) { return (wcschr(L"cCfF", opt[1]) || (wcschr(L"eE", opt[1]) && (!opt[2] || !wcschr(L"xX", opt[2])))); }

__attribute__((externally_visible)) /* for -fwhole-program */
int mainCRTStartup(void) {
    BOOL read_from_stdin = FALSE;
    wchar_t cmdlineW[4096] = L"", pwsh_pathW[MAX_PATH] = L"", bufW[MAX_PATH] = L"", drive[MAX_PATH], dir[_MAX_FNAME], filenameW[_MAX_FNAME], **argv;
    DWORD exitcode;
    STARTUPINFOW si = {0};
    PROCESS_INFORMATION pi = {0};
    int i = 1, argc;

    argv = CommandLineToArgvW(GetCommandLineW(), &argc);
    _wsplitpath(argv[0], drive, dir, filenameW, NULL);

    ExpandEnvironmentStringsW(L"%ProgramW6432%\\Powershell\\7\\pwsh.exe", pwsh_pathW, MAX_PATH + 1);
    /* Download and Install */
    if (!wcsncmp(filenameW, L"ChoCinstaller_", 14)) {
        WCHAR tmpW[MAX_PATH], versionW[] = L".....", msiW[MAX_PATH] = L"", downloadW[MAX_PATH] = L"";

        ExpandEnvironmentStringsW(L"%SystemRoot%\\system32\\WindowsPowershell\\v1.0\\powershell.exe", bufW, MAX_PATH + 1);
        if (!CopyFileW(argv[0], bufW, FALSE)) {
            MessageBoxA(0, "copy file failed\n", 0, 0);
            return 1;
        }
        versionW[0] = filenameW[19]; versionW[2] = filenameW[20]; versionW[4] = filenameW[21];

        ExpandEnvironmentStringsW(L"%SystemRoot%\\syswow64\\WindowsPowershell\\v1.0\\powershell.exe", bufW, MAX_PATH + 1);
        if (!CopyFileW(wcscat(wcscat(wcscat(drive, L"\\"), dir), L"powershell32.exe"), bufW, FALSE)) {
            MessageBoxA(0, "copy file failed\n", 0, 0);
            return 1;
        }

        wcscat(wcscat(msiW, L"PowerShell-"), versionW);
        wcscat(msiW, L"-win-x64.msi");
        ExpandEnvironmentStringsW(L"%WINEHOMEDIR%\\.cache\\choc_install_files\\", bufW, MAX_PATH + 1);

        GetTempPathW(MAX_PATH, tmpW);
        if (!CopyFileW(wcscat(bufW, msiW), wcscat(tmpW, msiW), FALSE)) {
            if (URLDownloadToFileW(NULL, wcscat(wcscat(wcscat(wcscat(downloadW, L"https://github.com/PowerShell/PowerShell/releases/download/v"), versionW), L"/"), msiW), tmpW, 0, NULL) != S_OK) {
                MessageBoxA(0, "download failed :( \n", 0, 0);
                return 1;
            }
        }

        GetTempPathW(MAX_PATH, tmpW);
        bufW[0] = 0;
        CreateProcessW(0, wcscat(wcscat(bufW, L"msiexec.exe /i "), wcscat(wcscat(tmpW, msiW), L" ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 /q")), 0, 0, 0, HIGH_PRIORITY_CLASS, 0, 0, &si, &pi);
        WaitForSingleObject(pi.hProcess, INFINITE); CloseHandle(pi.hProcess); CloseHandle(pi.hThread);
        GetTempPathW(MAX_PATH, tmpW);
        bufW[0] = 0;
        _wsplitpath(argv[0], drive, dir, filenameW, NULL);
        wcscat(wcscat(wcscat(wcscat(wcscat(wcscat(wcscat(wcscat(cmdlineW, L" -file "), drive), L"\\"), dir), L"choc_install.ps1 "), drive), L"\\"), dir);
        goto exec; /* End download and install */
    }
    /* I can also act as a dummy program if my exe-name is not powershell, allows to replace a system exe (like wusa.exe, or any exe really) by a function in profile.ps1 */
    else if (_wcsnicmp(filenameW, L"powershell", 10)) {
        /* add some prefix to the exe and execute it through pwsh , so we can query for program replacement in profile.ps1 */
        wcscat(wcscat(cmdlineW, L" -nop -c QPR."), filenameW);
        for (i = 1; i < argc; i++) {
            /* concatenate the rest of the arguments into the new cmdline */
            wcscat(wcscat(wcscat(cmdlineW, L" '\""), argv[i]), L"\"'");
        }
        SetEnvironmentVariableW(L"QPRCMDLINE", GetCommandLineW()); /* option to track the complete commandline via $env:QPRCMDLINE */
        goto exec;
    } /* note: set desired exitcode in the function in profile.ps1 */
    /* Main program: wrap the original powershell-commandline into correct syntax, and send it to pwsh.exe */
    /* pwsh requires a command option "-c" , powershell doesn`t, so we have to insert it somewhere e.g. 'powershell -nologo 2+1' should go into 'powershell -nologo -c 2+1'*/
    if (!argv[1])
        read_from_stdin = TRUE; /* might be redirected like 'cmd.exe /c "powershell < ""c:\a.txt"""' */
    else {
        WCHAR *cmd = wcsdup(wcsstr(GetCommandLineW(), argv[1])), *ptr, delim = L' '; /* fetch cmdline without the application name (powershell)*/
        WCHAR* token = wcstok_s(cmd, &delim, &ptr); /* Start breaking up cmdline to look for options */

        while (token) {
            if (!wcscmp(token, L"-")) {
                read_from_stdin = 1;
                break;
            }
            if (token[0] == L'/') token[0] = L'-'; /* deprecated '/' still works in powershell 5.1, replace to simplify code */
            
            if (token[0] != '-' || is_last_option(token)) { /* no further options in cmdline, or final {-c, -f , -enc} : no new options may follow  these */
                wcscat(wcscat(cmdlineW, (token[0] != '-') ? L" -c " : L" "), token); /* insert '-c' if necessary */
                if (*ptr) wcscat(wcscat(cmdlineW, L" "), ptr); /* add remainder of cmdline and done */
                break;
            } else if (is_single_option(token)) { /* e.g. -noprofile, -nologo , -mta etc */
                if (_wcsnicmp(token, L"-nop", 4)) wcscat(wcscat(cmdlineW, L" "), token); /* skip -noprofile to enable hacks in profile.ps1 */
            } else { /* assuming option + argument (e.g. '-executionpolicy bypass') AND a valid command!!!, no check for garbage commands!!!!!! */
                if (!_wcsnicmp(token, L"-ve", 3)) 
                    token = wcstok_s(NULL, &delim, &ptr); /* skip incompatible version option, like '-version 3.0' */
                else { /* concatenate option + arg for option with argument */
                    wcscat(wcscat(cmdlineW, L" "), token);
                    token = wcstok_s(NULL, &delim, &ptr);
                    if (token) wcscat(wcscat(cmdlineW, L" "), token);
                }
            }
            token = wcstok_s(NULL, &delim, &ptr);
        }
    }
    /* by setting "PS51" env variable, there's a possibility to execute the cmd through rudimentary windows powershell 5.1, requires 'winetricks ps51' first */
    /* Note: when run from bash, escape special char $ with single quotes and backtick e.g. PS51=1 wine powershelL'`SPSVersionTable' */
    if (GetEnvironmentVariableW(L"PS51", bufW, MAX_PATH + 1) && !wcscmp(bufW, L"1")) ExpandEnvironmentStringsW(L"%SystemRoot%\\system32\\WindowsPowershell\\v1.0\\ps51.exe ", pwsh_pathW, MAX_PATH + 1);
    /* support pipeline to handle something like " '$(get-date)'| powershell - " or redirected from file */
    if (read_from_stdin) {
        WCHAR defline[4096];
        char line[4096];
        HANDLE input = GetStdHandle(STD_INPUT_HANDLE);
        DWORD type = GetFileType(input);
        /* handle pipe */
        if (type != FILE_TYPE_CHAR) {
            /* not redirected (FILE_TYPE_PIPE or FILE_TYPE_DISK); otherwise 'wine powershell' will hang waiting for input... */
            if ((!wcscmp(argv[argc - 1], L"-") && _wcsnicmp(argv[argc - 2], L"-c", 2)) || !argv[1]) wcscat(cmdlineW, L" -c ");
            wcscat(cmdlineW, L" ");
            while (fgets(line, 4096, stdin) != NULL) {
                mbstowcs(defline, line, 4096);
                wcscat(cmdlineW, defline);
            }
        }  // FILE *fptr; fptr = fopen("c:\\log.txt", "a");fputws(L"Note: command was read from stdin\n", stderr);fclose(fptr);
    }      /* end support pipeline */
exec:      // FILE *fptr; fptr = fopen("c:\\log.txt", "a");fputws(L"used commandline is now: ",fptr); fputws(cmdlineW,fptr);fputws(L"\n",fptr); fclose(fptr);
    if (!cmdlineW[0]) ExpandEnvironmentStringsW(L" -c %SystemDrive%\\ConEmu\\ConEmu64.exe -NoUpdate -LoadRegistry -run %ProgramW6432%\\Powershell\\7\\pwsh.exe ", bufW, MAX_PATH + 1);
    CreateProcessW(pwsh_pathW, !cmdlineW[0] ? bufW : cmdlineW, 0, 0, 0, 0, 0, 0, &si, &pi);
    WaitForSingleObject(pi.hProcess, INFINITE); GetExitCodeProcess(pi.hProcess, &exitcode); CloseHandle(pi.hProcess); CloseHandle(pi.hThread);
    LocalFree(argv);

    return (exitcode);
}
