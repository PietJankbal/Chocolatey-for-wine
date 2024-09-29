/* Wraps cmdline into correct syntax for pwsh.exe + code allowing calls to an exe (like wusa.exe) to be replaced by a function in profile.ps1
 *
 * This library is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either 
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU  Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
 * 
 * To make dummy program handle redirected input, insert after line 49:   FILE_FS_DEVICE_INFORMATION info;IO_STATUS_BLOCK io;HANDLE input=GetStdHandle(STD_INPUT_HANDLE);\
 * NtQueryVolumeInformationFile(input,&io,&info,sizeof(info),FileFsDeviceInformation );if(info.DeviceType==17||info.DeviceType==8){wcscat(cl, L" ");while(fgetws(cl+wcslen(cl),4096,stdin)!=NULL)continue;SetEnvironmentVariableW(L"QPRCMDLINE",cl+17);}
 * Build: For fun I changed code from standard main(argc,*argv[]) to something like https://nullprogram.com/blog/2016/01/31/ and https://scorpiosoftware.net/2023/03/16/minimal-executables/)
 * x86_64-w64-mingw32-gcc -Os -fomit-frame-pointer -fno-asynchronous-unwind-tables -municode -Wall -Wextra -mno-stack-arg-probe -finline-limit=0 -Wl,-gc-sections -Xlinker --stack=0x100000,0x100000 mainv1.c -nostdlib -lucrtbase -lkernel32 -lntdll -s -o powershell64.exe && strip -R .reloc powershell64.exe
   i686-w64-mingw32-gcc -Os -fomit-frame-pointer -fno-asynchronous-unwind-tables -mno-stack-arg-probe -municode -Wall -Wextra -mno-stack-arg-probe -finline-limit=0 -Wl,-gc-sections -Xlinker --stack=0x100000,0x100000 mainv1.c -nostdlib -lucrtbase -lkernel32 -lntdll -s -o powershell32.exe && strip -R .reloc  powershell32.exe
 */
 
#include <wchar.h>
#include <windows.h>
#include <winternl.h>

/* clbuf = incoming cmdline */
#define clbuf peb->ProcessParameters->CommandLine.Buffer
/* copied from dlls/ntdll/wcstring.c, just to make the binary another 0,5 kB smaller... */ 
static __attribute__((noinline)) LPWSTR _wcschr(LPCWSTR str, WCHAR ch) { do { if (*str == ch) return (WCHAR*)(ULONG_PTR)str; } while (*str++); return NULL; }
/* for e.g. -noprofile, -nologo , -mta etc */
static BOOL is_single_option(WCHAR* opt) { return !!_wcschr(L"nNmMsS", opt[1]); }
/* no new options may follow -c, -f , -e (but not -ex(ecutionpolicy)! and '-') */
static BOOL is_last_option(WCHAR* opt) { return ((_wcschr(L"cCfFeE\0", opt[1]) && _wcsnicmp(&opt[1], L"ex", 2) && _wcsnicmp(&opt[1], L"config", 6))); }
/* join strings with a space in between */
static __attribute__((noinline)) void join(WCHAR* string1, WCHAR* string2) { if (string2) wcscat(wcscat(string1, L" "), string2); }

int mainCRTStartup(PPEB peb) {
    wchar_t *file = peb->ProcessParameters->ImagePathName.Buffer, *ptr, *token = wcstok_s(file, L"\\", &ptr), cl[4095];  //*cl = calloc(4096, sizeof(wchar_t)); /* cl = new outgoing cmdline */
    DWORD exitcode;
    STARTUPINFOW si = {0};
    PROCESS_INFORMATION pi = {0};

    WCHAR* cmd = (clbuf[0] == L'"') ? _wcschr(clbuf + 1, L'"') + 1 : _wcschr(clbuf, L' '); /* skip arg[0] to get the cmdline to be executed */
    while (token) {                                                                        /* get the filename */
        token = wcstok_s(NULL, L"\\", &ptr);
        if (!*ptr) break;
    }
    wcstok_s(token, L".", &ptr);
    /* I can also act as a dummy program if my exe-name is not powershell, allows to replace a system exe (like wusa.exe, or any exe really) by a function in profile.ps1 */
    if (_wcsnicmp(token, L"Powershell", 10)) {         /* note: set desired exitcode in the function in profile.ps1 */
        SetEnvironmentVariableW(L"QPRCMDLINE", cmd);   /* track cmdline via $env:QPRCMDLINE ($MyInvocation.Line seems to remove quotes (!)) */
        wcscat(wcscat(cl, L"-nop -c QPR."), token);    /* add some prefix to the exe and execute it through pwsh , so we can query for program replacement in profile.ps1 */
    } else {
        token = (cmd ? wcstok_s(cmd, L" ", &ptr) : 0); /* Start breaking up cmdline to look for options */
        /* Main program: pwsh requires a command option "-c" , powershell doesn`t;  insert it e.g. 'powershell -nologo 2+1' should go into 'powershell -nologo -c 2+1'*/
        while (token) {                                /* Break up cmdline manually (as CommandLineToArgVW seems to remove some (double) qoutes) */
            if (token[0] == L'/') token[0] = L'-';     /* deprecated '/' still works in powershell 5.1, replace to simplify code */

            if (token[0] != L'-' || is_last_option(token)) {                                     /* no further options in cmdline, or final {-c, -f ,-enc, -} : no new options may follow  these */
                if ((token[0] != L'-' && _waccess(token, 0)) || (token[0] == L'-' && !token[1])) /* insert '-c' if necessary (no option, no file, or '-')*/
                    join(cl, L"-c");
                join(cl, token); /* add arg */
                join(cl, ptr);   /* add remainder of cmdline and done */
                break;
            }
            if (is_single_option(token)) {                         /* e.g. -noprofile, -nologo , -mta etc */
                if (_wcsnicmp(token, L"-nop", 4)) join(cl, token); /* skip -noprofile to alays enable hacks in profile.ps1 */
            } else {                                               /* assuming option + argument (e.g. '-executionpolicy bypass') AND a valid command!!!, no check for garbage commands!!!!!! */
                if (!_wcsnicmp(token, L"-ve", 3))                  /* skip incompatible version option, like '-version 3.0' */
                    token = wcstok_s(NULL, L" ", &ptr);
                else {
                    join(cl, token);                               /* concatenate option + arg for option with argument */
                    token = wcstok_s(NULL, L" ", &ptr);
                    join(cl, token);
                }
            }
            token = wcstok_s(NULL, L" ", &ptr);
        }
    }
    // /*track the cmd:*/ FILE *fptr; fptr = fopen("c:\\log.txt", "a");fputws(L"used commandline is now: ",fptr); fputws(cl,fptr); fclose(fptr);
    CreateProcessW(!_wgetenv(L"PS51") ? _wgetenv(L"PS7") : L"c:\\Windows\\system32\\WindowsPowershell\\v1.0\\PS51.exe", cl, 0, 0, 0, 0, 0, 0, &si, &pi);
    WaitForSingleObject(pi.hProcess, INFINITE); GetExitCodeProcess(pi.hProcess, &exitcode); CloseHandle(pi.hProcess); CloseHandle(pi.hThread);
    return (exitcode);
}
