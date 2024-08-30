/* Installs PowerShell Core, wraps powershell`s commandline into correct syntax for pwsh.file,
 * and some code that allows calls to an file (like wusa.file) to be replaced by a function in profile.ps1
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
  -Wall -Wextra -ffreestanding -fno-unroll-loops  -finline-limit=0 -Wl,-gc-sections   mainv1.c -nostdlib -lucrtbase -s -o powershell64.exe && strip -R .reloc powershell64.exe
 * i686-w64-mingw32-gcc -O1 -fno-ident -fno-stack-protector -fomit-frame-pointer -fno-unwind-tables -fno-asynchronous-unwind-tables -mconsole -municode -mno-stack-arg-probe -Xlinker --stack=0x200000,0x200000\
   -Wall -Wextra -ffreestanding -fno-unroll-loops  -finline-limit=0 -Wl,-gc-sections   mainv1.c -nostdlib -lucrtbase -s -o powershell32.exe && strip -R .reloc powershell32.exe 
 */
#include <stdio.h>
#include <windows.h>
#include <winternl.h>

/* for e.g. -noprofile, -nologo , -mta etc */
static BOOL is_single_option(WCHAR* opt) { return (wcschr(L"nNmMsS", opt[1]) ? TRUE : FALSE); }
/* no new options may follow -c, -f , and -e (but not -ex(ecutionpolicy)!) */
static BOOL is_last_option(WCHAR* opt) { return (wcschr(L"cCfFeE", opt[1]) && _wcsnicmp(&opt[1], L"ex", 2) && _wcsnicmp(&opt[1], L"config", 6)); }

intptr_t mainCRTStartup(PPEB peb) {
    BOOL read_from_stdin = FALSE;
    wchar_t *file, *cmd, *ptr = 0, *token, delim = L' ', *cl = (wchar_t*)calloc(4096, sizeof(wchar_t)); /* cl will be the new cmdline */

    file = wcsrchr(peb->ProcessParameters->ImagePathName.Buffer, L'\\') + 1; /* fetch the exe name  */
    cmd = _wcsdup(peb->ProcessParameters->CommandLine.Buffer);               /* fetch cmdline */
    /* Stolen from wine's CommandLineToArgvW: skip over argv[0] to get the 'real' commandline */
    if (*cmd == '"') {
        cmd++;
        while (*cmd)
            if (*cmd++ == '"') break;
    } else {
        while (*cmd && *cmd != ' ' && *cmd != '\t') cmd++;
    }
    /* I can also act as a dummy program if my file-name is not powershell, allows to replace a system file (like wusa.file, or any file really) by a function in profile.ps1 */
    if (_wcsnicmp(file, L"powershell", 10)) {
        /* add some prefix to the file and execute it through pwsh , so we can query for program replacement in profile.ps1 */
        wcscat(wcscat(wcscat(cl, L" -nop -c QPR."), file), cmd ? cmd : L" ");
        _wputenv_s(L"QPRCMDLINE", peb->ProcessParameters->CommandLine.Buffer); /* track commandline in some env var to use it in the functions */
    } else { /* note: set desired exitcode in the function in profile.ps1 */
        /* Main program: pwsh requires a command option "-c" , powershell doesn`t;  insert it e.g. 'powershell -nologo 2+1' should go into 'powershell -nologo -c 2+1'*/
        token = (cmd ? wcstok_s(cmd, &delim, &ptr) : 0); /* Start breaking up cmdline to look for options */
        /* CommandLineToArgvW seems to remove quotes somehow, so break up cmdline manually... */
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
    // FILE *fptr; fptr = fopen("c:\\log.txt", "a");fputws(L"used commandline is now: ",fptr); fputws(cmdlineW,fptr); fclose(fptr);
    return _wspawnlp(_P_WAIT, getenv("PS51") ? L"ps51" : L"pwsh", cl, 0); /* by setting "PS51" env var, execute the cmd through windows powershell 5.1, requires 'winetricks ps51' first */
}
