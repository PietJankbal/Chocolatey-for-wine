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
 * x86_64-w64-mingw32-gcc -O1 -fno-ident -fno-stack-protector -fomit-frame-pointer -fno-unwind-tables -fno-asynchronous-unwind-tables -mconsole -municode -mno-stack-arg-probe -Xlinker --stack=0x200000,0x200000\
  -nostdlib  -Wall -Wextra  -finline-limit=64 -Wl,-gc-sections  installer.c -lurlmon -lkernel32 -lucrtbase -luser32 -nostdlib -lshell32 -lntdll -s -o ChoCinstaller_0.5g.743.exe && strip -R .reloc ChoCinstaller_0.5g.743.exe
 */
#include <stdio.h>
#include <windows.h>
#include <winternl.h>

__attribute__((externally_visible)) /* for -fwhole-program */
int mainCRTStartup(void) {
    wchar_t cmdlineW[MAX_PATH]=L"";
    wchar_t bufW[MAX_PATH] = L"", *filenameW, pathW[MAX_PATH]=L"", pwsh_pathW[MAX_PATH];
    DWORD exitcode;
    STARTUPINFOW si = {0};
    PROCESS_INFORMATION pi = {0};

    GetModuleFileNameW(NULL, pathW, MAX_PATH);
   
    filenameW = wcsdup(wcsrchr(pathW, L'\\') + 1);
    pathW[ wcslen(pathW) - 27] = 0;   
    ExpandEnvironmentStringsW(L"%ProgramW6432%\\Powershell\\7\\pwsh.exe", pwsh_pathW, MAX_PATH + 1);

    /* Download and Install */

        WCHAR tmpW[MAX_PATH]=L"", versionW[] = L".....", msiW[MAX_PATH]=L"", downloadW[MAX_PATH]=L""; 
        
        GetWindowsDirectoryW(bufW, MAX_PATH + 1);
        if (!CopyFileW(wcscat(pathW,L"\\powershell64.exe"), wcscat(bufW, L"\\system32\\WindowsPowershell\\v1.0\\powershell.exe"), FALSE)) {
            MessageBoxA(0, "copy failed\n", 0, 0);
            return 1;
        }
        
        versionW[0] = filenameW[19]; versionW[2] = filenameW[20]; versionW[4] = filenameW[21];
        wcscat(wcscat(msiW, L"PowerShell-"), versionW);
        wcscat(msiW, L"-win-x64.msi");
        ExpandEnvironmentStringsW(L"%WINEHOMEDIR%\\.cache\\choc_install_files\\", bufW, MAX_PATH + 1);

        GetTempPathW(MAX_PATH, tmpW);
        if (!CopyFileW(wcscat(bufW, msiW), wcscat(tmpW, msiW), FALSE)) {
            if (URLDownloadToFileW(NULL, wcscat(wcscat(wcscat(wcscat(downloadW, L"https://github.com/PowerShell/PowerShell/releases/download/v"), versionW), L"/"), msiW), tmpW, 0, NULL) != S_OK) {
                MessageBoxA(0, "download failed\n", 0, 0);
                return 1;
            }
        }
        
        pathW[wcslen(pathW) - 17] = 0;
        GetTempPathW(MAX_PATH, tmpW);
        bufW[0] = 0;
        CreateProcessW(0, wcscat(wcscat(bufW, L"msiexec.exe /i "), wcscat(wcscat(tmpW, msiW), L" ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 /q")), 0, 0, 0, HIGH_PRIORITY_CLASS, 0, 0, &si, &pi);
        WaitForSingleObject(pi.hProcess, INFINITE);
        CloseHandle(pi.hProcess);
        CloseHandle(pi.hThread);

        wcscat(wcscat(wcscat( wcscat( wcscat(cmdlineW, L" -f ") , pathW ), L"\\"), L"choc_install.ps1 "), pathW);

        CreateProcessW(pwsh_pathW, cmdlineW, 0, 0, 0, 0, 0, 0, &si, &pi);
        WaitForSingleObject(pi.hProcess, INFINITE); GetExitCodeProcess(pi.hProcess, &exitcode); CloseHandle(pi.hProcess); CloseHandle(pi.hThread);

        return (exitcode);
}
