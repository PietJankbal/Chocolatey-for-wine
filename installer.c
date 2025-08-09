/* Installs PowerShell Core, net48, chocolatey and ConEmu
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
  -nostdlib  -Wall -Wextra  -finline-limit=64 -Wl,-gc-sections  installer.c -lurlmon -lkernel32 -lucrtbase -luser32 -nostdlib -ladvapi32 -lntdll -lshell32 -s -o ChoCinstaller_0.5c.751.exe && strip -R .reloc ChoCinstaller_0.5a.751.exe
 */
 
#include <stdio.h>
#include <windows.h>
#include <winternl.h>

struct paths {
    wchar_t pathW[MAX_PATH];
    wchar_t setupcache[MAX_PATH];
    wchar_t *filenameW;
    wchar_t sevenzippath[MAX_PATH];
    wchar_t cache_dir[MAX_PATH];
    wchar_t argv[MAX_PATH];
};

DWORD WINAPI net48_install(void *ptr){

    wchar_t bufW[525]=L"", bufW1[MAX_PATH]=L"";
    struct paths *p = (struct paths*)ptr;
    STARTUPINFOW si = {0}, si1 = {0};
    PROCESS_INFORMATION pi = {0}, pi1= {0};

    if(GetFileAttributesW( wcscat(wcscat(bufW1, p->cache_dir + 4), L"v4.8.03761\\netfx_Full_x64.msi")) != INVALID_FILE_ATTRIBUTES)
        wcscat(wcscat(wcscat(bufW, L"msiexec.exe /i "), bufW1), L" MSIFASTINSTALL=2 DISABLEROLLBACK=1 /QN");
    else {
        wcscat(wcscat(wcscat(wcscat(wcscat(wcscat(bufW,p->sevenzippath) ,L" x -x!\"*.cab\" -x!\"netfx_c*\" -x!\"netfx_e*\" -x!\"NetFx4*\" -ms190M "), p->setupcache),L"\\ndp48-x86-x64-allos-enu.exe -o"), p->setupcache), L"\\v4.8.03761" );
 
        CreateProcessW(0, bufW, 0, 0, 0, 0, 0, 0, &si, &pi);
        WaitForSingleObject(pi.hProcess, INFINITE); /*GetExitCodeProcess(pi.hProcess, &exitcode);*/ CloseHandle(pi.hProcess); CloseHandle(pi.hThread);

        bufW[0]=0;
        wcscat(wcscat(wcscat(bufW, L"msiexec.exe /i "), p->setupcache), L"\\v4.8.03761\\netfx_Full_x64.msi MSIFASTINSTALL=2 DISABLEROLLBACK=1 /QN");
    }

    CreateProcessW(0, bufW, 0, 0, 0, REALTIME_PRIORITY_CLASS, 0, 0, &si1, &pi1);
    WaitForSingleObject(pi1.hProcess, INFINITE); CloseHandle(pi1.hProcess); CloseHandle(pi1.hThread);

    return 0;
}

DWORD WINAPI chocolatey_install(void *ptr){

    wchar_t dest[MAX_PATH], bufW[MAX_PATH]=L"", bufW1[525]=L"", url[] = L"https://packages.chocolatey.org/chocolatey.2.5.0.nupkg";
    struct paths *p = (struct paths*)ptr;
    STARTUPINFOW si = {0};
    PROCESS_INFORMATION pi = {0};

    ExpandEnvironmentStringsW(L"%ProgramData%", dest, MAX_PATH + 1);

    if(GetFileAttributesW( wcscat(wcscat(bufW1, p->cache_dir + 4), wcsrchr(url, L'/') + 1)) == INVALID_FILE_ATTRIBUTES) {
        URLDownloadToFileW(NULL, url, wcscat(wcscat(bufW, p->setupcache), wcsrchr(url, L'/') + 1), 0, NULL);
    }
    else {
        wcscat(wcscat(bufW, p->cache_dir + 4), wcsrchr(url, L'/') + 1);
    }
    
    bufW1[0] = 0;
    wcscat(wcscat(wcscat(wcscat( wcscat(bufW1, p->sevenzippath) ,L" x "), bufW), L" tools/chocolateyInstall/* -o"), dest);
    
    CreateProcessW(0, bufW1, 0, 0, 0, 0, 0, 0, &si, &pi);
    WaitForSingleObject(pi.hProcess, INFINITE); /*GetExitCodeProcess(pi.hProcess, &exitcode);*/ CloseHandle(pi.hProcess); CloseHandle(pi.hThread);

    return 0;
}

DWORD WINAPI pscore_install(void *ptr){

    wchar_t cmdlineW[MAX_PATH]=L"", bufW[MAX_PATH] = L"", bufW1[MAX_PATH] = L"", pwsh_pathW[MAX_PATH];
    int i;
    STARTUPINFOW si = {0}, si1 = {0};
    PROCESS_INFORMATION pi = {0}, pi1 = {0};
    HKEY hKey;
    struct paths *p = (struct paths*)ptr;
    
    ExpandEnvironmentStringsW(L"%ProgramFiles%\\Powershell\\7\\pwsh.exe", pwsh_pathW, MAX_PATH + 1);

    /* Download and Install */
    WCHAR versionW[] = L".....", msiW[MAX_PATH]=L"", downloadW[MAX_PATH]=L"";
 
    versionW[0] = p->filenameW[20]; versionW[2] = p->filenameW[21]; versionW[4] = p->filenameW[22];
    wcscat(wcscat(msiW, L"PowerShell-"), versionW);
    wcscat(msiW, L"-win-x64.msi");
        
    wchar_t *ps_url = wcscat(wcscat(wcscat(wcscat(downloadW, L"https://github.com/PowerShell/PowerShell/releases/download/v"), versionW), L"/"), msiW);
    
    if(GetFileAttributesW( wcscat(wcscat(bufW1, p->cache_dir + 4), wcsrchr(ps_url, L'/') + 1)) == INVALID_FILE_ATTRIBUTES) {
        bufW1[0] = 0;
        URLDownloadToFileW(NULL, ps_url, wcscat(wcscat(bufW1, p->setupcache), wcsrchr(ps_url, L'/') + 1) , 0, NULL);
    }
    
    CreateProcessW(0, wcscat(  wcscat( wcscat(bufW, L"msiexec.exe /i "), bufW1), L" DISABLE_TELEMETRY=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 MSIFASTINSTALL=2 DISABLEROLLBACK=1 MSIDISABLEEEUI=1 /QN"), 0, 0, 0, REALTIME_PRIORITY_CLASS, 0, 0, &si, &pi);

    WCHAR url[6][MAX_PATH] = {L"http://download.windowsupdate.com/msdownload/update/software/crup/2010/06/windows6.1-kb958488-v6001-x64_a137e4f328f01146dfa75d7b5a576090dee948dc.msu",
             L"https://github.com/mozilla/fxc2/raw/master/dll/d3dcompiler_47.dll",
             L"https://github.com/mozilla/fxc2/raw/master/dll/d3dcompiler_47_32.dll",
             L"https://github.com/Maximus5/ConEmu/releases/download/v23.07.24/ConEmuPack.230724.7z",
             L"https://globalcdn.nuget.org/packages/sevenzipextractor.1.0.19.nupkg",
             L"https://catalog.s.download.windowsupdate.com/msdownload/update/software/updt/2009/11/windowsserver2003-kb968930-x64-eng_8ba702aa016e4c5aed581814647f4d55635eff5c.exe"};
 
    for(i=0 ; i<6; i++) {
		bufW[0]=0;
        if(GetFileAttributesW( wcscat(wcscat(bufW, p->cache_dir + 4), wcsrchr(url[i], L'/') + 1)) == INVALID_FILE_ATTRIBUTES) {
            bufW[0]=0;
            URLDownloadToFileW(NULL, url[i], wcscat(wcscat(bufW,p->setupcache),  wcsrchr(url[i],L'/') + 1) , 0, NULL);
        }
    }
           
    RegCreateKeyExW(HKEY_CURRENT_USER, L"Environment", 0, NULL, REG_OPTION_NON_VOLATILE, KEY_SET_VALUE, NULL, &hKey, NULL);
    RegSetValueExW(hKey, L"PS7\0", 0, REG_SZ, (BYTE*) pwsh_pathW, sizeof(WCHAR)*wcslen(pwsh_pathW)+1); RegCloseKey(hKey);
    
    WaitForSingleObject(pi.hProcess, INFINITE); CloseHandle(pi.hProcess); CloseHandle(pi.hThread);
    
    wcscat(wcscat(wcscat(wcscat( wcscat( wcscat(cmdlineW, L" -f ") , p->pathW ), L"\\"), L"choc_install.ps1 "), p->pathW), p->argv);

    CreateProcessW(pwsh_pathW, cmdlineW, 0, 0, 0, 0, 0, 0, &si1, &pi1);
    WaitForSingleObject(pi1.hProcess, INFINITE); /*GetExitCodeProcess(pi1.hProcess, &exitcode);*/ CloseHandle(pi1.hProcess); CloseHandle(pi1.hThread);

    return 0;
}

DWORD WINAPI cdrive_install(void *ptr){

    wchar_t bufW[MAX_PATH]=L"";
    struct paths *p = (struct paths*)ptr;
    STARTUPINFOW si = {0};
    PROCESS_INFORMATION pi = {0};
    wcscat(wcscat(wcscat(wcscat(bufW, p->sevenzippath), L" x -spf -aoa "), p->pathW), L"\\c_drive.7z" );

    CreateProcessW(0, bufW, 0, 0, 0, 0, 0, 0, &si, &pi);
    WaitForSingleObject(pi.hProcess, INFINITE); /*GetExitCodeProcess(pi.hProcess, &exitcode);*/ CloseHandle(pi.hProcess); CloseHandle(pi.hThread);

    return 0;
}

__attribute__((externally_visible)) /* for -fwhole-program */
int mainCRTStartup(void) {
    wchar_t bufW[MAX_PATH] = L"",bufW1[MAX_PATH] = L"",   pwsh_pathW[MAX_PATH], **argv;
    int i = 0, argc;
    HKEY hKey; HANDLE hThread[4];
    struct paths p = {0};

    argv = CommandLineToArgvW(GetCommandLineW(), &argc);

    RegCreateKeyExW(HKEY_CURRENT_USER, L"Software\\Wine\\DllOverrides", 0, NULL, REG_OPTION_NON_VOLATILE, KEY_SET_VALUE, NULL, &hKey, NULL);
    const WCHAR info[] = L""; RegSetValueExW(hKey, L"mscorsvc", 0, REG_SZ, (BYTE*) info, sizeof(info)); RegCloseKey(hKey);

    ExpandEnvironmentStringsW(L"%WINEHOMEDIR%\\.cache\\choc_install_files\\", p.cache_dir, MAX_PATH + 1);
    ExpandEnvironmentStringsW(L"%ProgramFiles%\\Powershell\\7\\pwsh.exe", pwsh_pathW, MAX_PATH + 1);
    ExpandEnvironmentStringsW(L"%SystemRoot%\\Microsoft.NET\\Framework64\\v4.0.30319\\SetupCache\\", p.setupcache, MAX_PATH + 1);
    CreateDirectoryW(p.setupcache, 0);

    GetModuleFileNameW(NULL, p.pathW, MAX_PATH);
   
    p.filenameW = wcsdup(wcsrchr(p.pathW, L'\\')); p.pathW[ wcslen(p.pathW) - 26] = 0;
    wcscat(wcscat(p.sevenzippath, p.pathW), L"\\7z.exe");
    for(int i = 1; i < argc; i++) wcscat(wcscat(p.argv,L" "), argv[i]);

    wchar_t url[] = L"https://download.visualstudio.microsoft.com/download/pr/7afca223-55d2-470a-8edc-6a1739ae3252/abd170b4b0ec15ad0222a809b761a036/ndp48-x86-x64-allos-enu.exe";

    if(GetFileAttributesW( wcscat(wcscat(bufW1, p.cache_dir + 4), L"v4.8.03761\\netfx_Full_x64.msi")) == INVALID_FILE_ATTRIBUTES)
       URLDownloadToFileW(NULL, url, wcscat(wcscat(bufW, p.setupcache), wcsrchr(url, L'/') + 1), 0, NULL);
    /* https://aljensencprogramming.wordpress.com/tag/createthread/ */
    hThread[3] = CreateThread(NULL, 0, cdrive_install, &p, 0, 0);   
    hThread[0] = CreateThread(NULL, 0, net48_install, &p, 0, 0);   
    hThread[2] = CreateThread(NULL, 0, pscore_install, &p, 0, 0);  
    hThread[1] = CreateThread(NULL, 0, chocolatey_install, &p, 0, 0);
    SetThreadPriority(hThread[0],THREAD_PRIORITY_HIGHEST);
    WaitForMultipleObjects(4, hThread, TRUE, INFINITE);
    for (int i = 0; i < 4; i++)  CloseHandle(hThread[i]); 
    
    ExitProcess(0);
}
