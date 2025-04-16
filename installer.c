/* Installs PowerShell Core
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
  -nostdlib  -Wall -Wextra  -finline-limit=64 -Wl,-gc-sections  installer.c -lurlmon -lkernel32 -lucrtbase -luser32 -nostdlib -ladvapi32 -lntdll -s -o ChoCinstaller_0.5q.745.exe && strip -R .reloc ChoCinstaller_0.5q.745.exe
 */
 
#include <stdio.h>
#include <windows.h>
#include <winternl.h>

__attribute__((externally_visible)) /* for -fwhole-program */
int mainCRTStartup(void) {
    wchar_t cmdlineW[MAX_PATH]=L""; wchar_t bufW[MAX_PATH] = L"",bufW1[MAX_PATH] = L"",  *filenameW, pathW[MAX_PATH]=L"", pwsh_pathW[MAX_PATH], setupcacheW[MAX_PATH];
    DWORD exitcode;
    STARTUPINFOW si = {0}, si1 = {0};
    PROCESS_INFORMATION pi = {0}, pi1 = {0};
    HKEY hKey;

    RegCreateKeyExW(HKEY_CURRENT_USER, L"Software\\Wine\\DllOverrides", 0, NULL, REG_OPTION_NON_VOLATILE, KEY_SET_VALUE, NULL, &hKey, NULL);
    const WCHAR info[] = L""; RegSetValueExW(hKey, L"mscorsvc", 0, REG_SZ, (BYTE*) info, sizeof(info)); RegCloseKey(hKey);

    ExpandEnvironmentStringsW(L"%WINEHOMEDIR%\\.cache\\choc_install_files\\v4.8.03761\\netfx_Full_x64.msi", bufW1, MAX_PATH + 1);

    if(GetFileAttributesW(bufW1+4) != INVALID_FILE_ATTRIBUTES) {
        CreateProcessW(0, wcscat(   wcscat(   wcscat(bufW, L"msiexec.exe /i ")   , bufW1+4   ), L" MSIFASTINSTALL=2 DISABLEROLLBACK=1 /QN"), 0, 0, 0, REALTIME_PRIORITY_CLASS, 0, 0, &si1, &pi1);
    }

    GetModuleFileNameW(NULL, pathW, MAX_PATH);
   
    filenameW = wcsdup(wcsrchr(pathW, L'\\')), pathW[ wcslen(pathW) - 26] = 0;
    
    ExpandEnvironmentStringsW(L"%ProgramFiles%\\Powershell\\7\\pwsh.exe", pwsh_pathW, MAX_PATH + 1);
    ExpandEnvironmentStringsW(L"%SystemRoot%\\Microsoft.NET\\Framework64\\v4.0.30319\\SetupCache\\", setupcacheW, MAX_PATH + 1);
    CreateDirectoryW(setupcacheW, 0);
    
    /* Download and Install */
        WCHAR tmpW[MAX_PATH]=L"", versionW[] = L".....", msiW[MAX_PATH]=L"", downloadW[MAX_PATH]=L"";
 
        versionW[0] = filenameW[20]; versionW[2] = filenameW[21]; versionW[4] = filenameW[22];
        wcscat(wcscat(msiW, L"PowerShell-"), versionW);
        wcscat(msiW, L"-win-x64.msi");
        
        ExpandEnvironmentStringsW(L"%WINEHOMEDIR%\\.cache\\choc_install_files\\", bufW, MAX_PATH + 1);
          
        GetTempPathW(MAX_PATH, tmpW);
        if (!CopyFileW(wcscat(bufW + 4, msiW), wcscat(setupcacheW, msiW), FALSE)) { 
            if (URLDownloadToFileW(NULL, wcscat(wcscat(wcscat(wcscat(downloadW, L"https://github.com/PowerShell/PowerShell/releases/download/v"), versionW), L"/"), msiW), setupcacheW, 0, NULL) != S_OK) {
                MessageBoxA(0, "download failed\n", 0, 0);
                return 1;
            }
        }
                
        bufW[0] = 0;
        CreateProcessW(0, wcscat(wcscat(bufW, L"msiexec.exe /i "), wcscat(setupcacheW, L" DISABLE_TELEMETRY=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 MSIFASTINSTALL=2 DISABLEROLLBACK=1 MSIDISABLEEEUI=1 /QN")), 0, 0, 0, REALTIME_PRIORITY_CLASS, 0, 0, &si, &pi);
        WaitForSingleObject(pi.hProcess, INFINITE); CloseHandle(pi.hProcess); CloseHandle(pi.hThread);
               
        RegCreateKeyExW(HKEY_CURRENT_USER, L"Environment", 0, NULL, REG_OPTION_NON_VOLATILE, KEY_SET_VALUE, NULL, &hKey, NULL);
        RegSetValueExW(hKey, L"PS7\0", 0, REG_SZ, (BYTE*) pwsh_pathW, sizeof(pwsh_pathW)); RegCloseKey(hKey);
    
        wcscat(wcscat(wcscat( wcscat( wcscat(cmdlineW, L" -f ") , pathW ), L"\\"), L"choc_install.ps1 "), pathW);

        CreateProcessW(pwsh_pathW, cmdlineW, 0, 0, 0, 0, 0, 0, &si, &pi);
        WaitForSingleObject(pi.hProcess, INFINITE); GetExitCodeProcess(pi.hProcess, &exitcode); CloseHandle(pi.hProcess); CloseHandle(pi.hThread);

        WaitForSingleObject(pi1.hProcess, INFINITE); CloseHandle(pi1.hProcess); CloseHandle(pi1.hThread);

        return (exitcode);
}
