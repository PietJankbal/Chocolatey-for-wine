/* Wraps cmdline into correct syntax for pwsh.exe + code allowing calls to an exe (like wusa.exe) to be replaced by a function in profile.ps1
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
 * x86_64-w64-mingw32-gcc -Os -fomit-frame-pointer -fno-asynchronous-unwind-tables -municode -Wall -Wextra -Wl,-gc-sections mainv1.c -nostdlib -lucrtbase -lkernel32 -s -o powershell64.exe && strip -R .reloc powershell64.exe
   i686-w64-mingw32-gcc -Os -fomit-frame-pointer -fno-asynchronous-unwind-tables -mno-stack-arg-probe -municode -Wall -Wextra -Wl,-gc-sections mainv1.c -nostdlib -lucrtbase -lkernel32 -s -o powershell32.exe && strip -R .reloc  powershell32.exe
 */

#include <wchar.h>
#include <windows.h>
#include <winternl.h>

/* clbuf = incoming cmdline */
#define clbuf peb->ProcessParameters->CommandLine.Buffer
/* for e.g. -noprofile, -nologo , -mta etc */
static BOOL is_single_option(WCHAR* opt) { return !!wcschr(L"nNmMsS", opt[1]); }
/* no new options may follow -c, -f , -e (but not -ex(ecutionpolicy)! and '-') */
static BOOL is_last_option(WCHAR* opt) { return ((wcschr(L"cCfFeE\0", opt[1]) && _wcsnicmp(&opt[1], L"ex", 2) && _wcsnicmp(&opt[1], L"config", 6))); }
/* join strings with a space in between */
static __attribute__((noinline)) void join(WCHAR* string1, WCHAR* string2) { if (string2) wcscat(wcscat(string1, L" "), string2); }

int mainCRTStartup(PPEB peb) {
    wchar_t pwsh[MAX_PATH], ps51[MAX_PATH], file[_MAX_FNAME], *cl = calloc(4096, sizeof(wchar_t)); /* cl = new outgoing cmdline */
    DWORD exitcode;
    STARTUPINFOW si = {0};
    PROCESS_INFORMATION pi = {0};

    ExpandEnvironmentStringsW(L"%ProgramW6432%\\Powershell\\7\\pwsh.exe", pwsh, MAX_PATH + 1);
    ExpandEnvironmentStringsW(L"%winsysdir%\\WindowsPowershell\\v1.0\\ps51.exe", ps51, MAX_PATH + 1);
    _wsplitpath(peb->ProcessParameters->ImagePathName.Buffer, NULL, NULL, file, NULL);

    /* Skip arg[0] to get the cmdline to be executed */
    WCHAR* cmd = (clbuf[0] == L'"') ? wcschr(clbuf + 1, L'"') + 1 : wcschr(clbuf, L' ');

    /* I can also act as a dummy program if my exe-name is not powershell, allows to replace a system exe (like wusa.exe, or any exe really) by a function in profile.ps1 */
    if (_wcsnicmp(file, L"Powershell", 10)) {        /* note: set desired exitcode in the function in profile.ps1 */
        wcscat(wcscat(cl, L"-nop -c QPR."), file);   /* add some prefix to the exe and execute it through pwsh , so we can query for program replacement in profile.ps1 */
        SetEnvironmentVariableW(L"QPRCMDLINE", cmd); /* track cmdline via $env:QPRCMDLINE ($MyInvocation.Line seems to remove quotes (!)) */
    } else {
        /* Main program: pwsh requires a command option "-c" , powershell doesn`t;  insert it e.g. 'powershell -nologo 2+1' should go into 'powershell -nologo -c 2+1'*/
        WCHAR *ptr = 0, delim = L' ', *token = (cmd ? wcstok_s(cmd, &delim, &ptr) : 0); /* Start breaking up cmdline to look for options */
        /* Break up cmdline manually (as CommandLineToArgVW seems to remove some (double) qoutes) */
        while (token) {
            if (token[0] == L'/') token[0] = L'-'; /* deprecated '/' still works in powershell 5.1, replace to simplify code */

            if (token[0] != L'-' || is_last_option(token)) {                                     /* no further options in cmdline, or final {-c, -f ,-enc, -} : no new options may follow  these */
                if ((token[0] != L'-' && _waccess(token, 0)) || (token[0] == L'-' && !token[1])) /* insert '-c' if necessary (no option, no file, or '-')*/
                    join(cl, L"-c");
                join(cl, token);                                                                /* add arg */
                join(cl, ptr);                                                                  /* add remainder of cmdline and done */
                break;
            }

            if (is_single_option(token)) {        /* e.g. -noprofile, -nologo , -mta etc */
                if (_wcsnicmp(token, L"-nop", 4)) /* skip -noprofile to alays enable hacks in profile.ps1 */
                    join(cl, token);
            } else {                              /* assuming option + argument (e.g. '-executionpolicy bypass') AND a valid command!!!, no check for garbage commands!!!!!! */
                if (!_wcsnicmp(token, L"-ve", 3)) /* skip incompatible version option, like '-version 3.0' */
                    token = wcstok_s(NULL, &delim, &ptr);
                else {
                    join(cl, token);              /* concatenate option + arg for option with argument */
                    token = wcstok_s(NULL, &delim, &ptr);
                    join(cl, token);
                }
            }
            token = wcstok_s(NULL, &delim, &ptr);
        }
    }
    // /*track the cmd:*/ FILE *fptr; fptr = fopen("c:\\log.txt", "a");fputws(L"used commandline is now: ",fptr); fputws(cl,fptr); fclose(fptr);
    CreateProcessW(_wgetenv(L"PS51") ? ps51 : pwsh, cl, 0, 0, 0, 0, 0, 0, &si, &pi);
    WaitForSingleObject(pi.hProcess, INFINITE);GetExitCodeProcess(pi.hProcess, &exitcode);CloseHandle(pi.hProcess);CloseHandle(pi.hThread);

    return (exitcode);
}
