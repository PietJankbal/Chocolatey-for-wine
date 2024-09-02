/* Wraps powershell`s commandline into correct syntax for pwsh.exe,
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
 * Build: // For fun I changed code from standard main(argc,*argv[]) to something like https://nullprogram.com/blog/2016/01/31/ and https://scorpiosoftware.net/2023/03/16/minimal-executables/)
 * x86_64-w64-mingw32-gcc -O1 -fno-ident -fno-stack-protector -fomit-frame-pointer -fno-unwind-tables -fno-asynchronous-unwind-tables -mconsole -municode -mno-stack-arg-probe -Xlinker --stack=0x200000,0x200000\
  -Wall -Wextra -ffreestanding -fno-unroll-loops   mainv1.c -nostdlib -lucrtbase -lkernel32 -s -o powershell64.exe && strip -R .reloc powershell64.exe
 * i686-w64-mingw32-gcc -O1 -fno-ident -fno-stack-protector -fomit-frame-pointer -fno-unwind-tables -fno-asynchronous-unwind-tables -mconsole -municode -mno-stack-arg-probe -Xlinker --stack=0x200000,0x200000\
   -Wall -Wextra -ffreestanding -fno-unroll-loops  mainv1.c -nostdlib -lucrtbase -lkernel32 -s -o powershell32.exe && strip -R .reloc powershell32.exe
 */
#include <stdio.h>
#include <windows.h>
#include <winternl.h>

/* for e.g. -noprofile, -nologo , -mta etc */
static BOOL is_single_option(WCHAR* opt) { return (wcschr(L"nNmMsS", opt[1]) ? TRUE : FALSE); }
/* no new options may follow -c, -f , and -e (but not -ex(ecutionpolicy)!) */
static BOOL is_last_option(WCHAR* opt) { return (wcschr(L"cCfFeE", opt[1]) && _wcsnicmp(&opt[1], L"ex", 2) && _wcsnicmp(&opt[1], L"config", 6)); }

int mainCRTStartup(PPEB peb) {
    BOOL read_from_stdin = FALSE;
    wchar_t pwsh[MAX_PATH] = L"", ps51[MAX_PATH] = L"", filenameW[_MAX_FNAME], cl[4096] = L""; /* cl will be the new cmdline */
    DWORD exitcode;
    STARTUPINFOW si = {0};
    PROCESS_INFORMATION pi = {0};

    ExpandEnvironmentStringsW(L"%ProgramW6432%\\Powershell\\7\\pwsh.exe", pwsh, MAX_PATH + 1);
    ExpandEnvironmentStringsW(L"%winsysdir%\\WindowsPowershell\\v1.0\\ps51.exe", ps51, MAX_PATH + 1);
    _wsplitpath(peb->ProcessParameters->ImagePathName.Buffer, NULL, NULL, filenameW, NULL);
    WCHAR* cmd = (peb->ProcessParameters->CommandLine.Buffer[0] == '"') ? wcschr(peb->ProcessParameters->CommandLine.Buffer + 1, L'"') + 1 : wcschr(peb->ProcessParameters->CommandLine.Buffer + 1, L' ');

    /* I can also act as a dummy program if my exe-name is not powershell, allows to replace a system exe (like wusa.exe, or any exe really) by a function in profile.ps1 */
    if (_wcsnicmp(filenameW, L"Powershell", 10)) {                                          /* note: set desired exitcode in the function in profile.ps1 */
        wcscat(wcscat(wcscat(cl, L" -nop -c QPR."), filenameW), cmd ? cmd : L" ");          /* add some prefix to the exe and execute it through pwsh , so we can query for program replacement in profile.ps1 */
        SetEnvironmentVariableW(L"QPRCMDLINE", peb->ProcessParameters->CommandLine.Buffer); /* track complete cmdline via $env:QPRCMDLINE ($MyInvocation.Line seems to remove quotes (!)) */
    } else {
        /* Main program: pwsh requires a command option "-c" , powershell doesn`t;  insert it e.g. 'powershell -nologo 2+1' should go into 'powershell -nologo -c 2+1'*/
        WCHAR *ptr = 0, delim = L' ', *token = (cmd ? wcstok_s(cmd, &delim, &ptr) : 0); /* Start breaking up cmdline to look for options */

        while (token) {
            if (!wcscmp(token, L"-")) {
                wcscat(cl, L" -c ");
                read_from_stdin = 1;
                break;
            }
            if (token[0] == L'/') token[0] = L'-'; /* deprecated '/' still works in powershell 5.1, replace to simplify code */

            if (token[0] != '-' || is_last_option(token)) {                    /* no further options in cmdline, or final {-c, -f , -enc} : no new options may follow  these */
                wcscat(wcscat(cl, (token[0] != '-') ? L" -c " : L" "), token); /* insert '-c' if necessary */
                if (*ptr) wcscat(wcscat(cl, L" "), ptr);                       /* add remainder of cmdline and done */
                break;
            } else if (is_single_option(token)) {                                  /* e.g. -noprofile, -nologo , -mta etc */
                if (_wcsnicmp(token, L"-nop", 4)) wcscat(wcscat(cl, L" "), token); /* skip -noprofile to enable hacks in profile.ps1 */
            } else {                                                               /* assuming option + argument (e.g. '-executionpolicy bypass') AND a valid command!!!, no check for garbage commands!!!!!! */
                if (!_wcsnicmp(token, L"-ve", 3))
                    token = wcstok_s(NULL, &delim, &ptr); /* skip incompatible version option, like '-version 3.0' */
                else {                                    /* concatenate option + arg for option with argument */
                    wcscat(wcscat(cl, L" "), token);
                    token = wcstok_s(NULL, &delim, &ptr);
                    if (token) wcscat(wcscat(cl, L" "), token);
                }
            }
            token = wcstok_s(NULL, &delim, &ptr);
        }
    }
    if (read_from_stdin) { /* support pipeline to handle something like " '$(get-date)'| powershell - " */
        while (fgetws(cl + wcslen(cl), 4096, stdin) != NULL) continue;
    }
    // /*track the cmd:*/ FILE *fptr; fptr = fopen("c:\\log.txt", "a");fputws(L"used commandline is now: ",fptr); fputws(cl,fptr); fclose(fptr);
    CreateProcessW(_wgetenv(L"PS51") ? ps51 : pwsh, cl, 0, 0, 0, 0, 0, 0, &si, &pi);
    WaitForSingleObject(pi.hProcess, INFINITE); GetExitCodeProcess(pi.hProcess, &exitcode); CloseHandle(pi.hProcess); CloseHandle(pi.hThread);

    return (exitcode);
}
