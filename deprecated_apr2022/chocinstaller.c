/* installer - this installs chocolateyinstaller/only run on new prefix!
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
 * Compile: *
 * x86_64-w64-mingw32-gcc -municode  -mconsole chocinstaller.c -lurlmon -luser32 -lntdll -s -o install_choc_installer.exe
 */
#include <windows.h>
#include <stdio.h>

int __cdecl wmain(int argc, WCHAR *argv[])
{
    WCHAR dest64W[MAX_PATH];WCHAR dest32W[MAX_PATH];
    STARTUPINFOW si; PROCESS_INFORMATION pi;

    if(!ExpandEnvironmentStringsW(L"%systemroot%", dest64W, MAX_PATH+1)) goto failed; if(!ExpandEnvironmentStringsW(L"%systemroot%", dest32W, MAX_PATH+1)) goto failed;
    lstrcatW(dest64W, L"\\system32\\WindowsPowerShell\\v1.0\\powershell.exe"); lstrcatW(dest32W, L"\\syswow64\\WindowsPowerShell\\v1.0\\powershell.exe");
    DeleteFileW(dest64W); DeleteFileW(dest32W);
    if( URLDownloadToFileW(NULL, L"https://github.com/PietJankbal/Chocolatey-for-wine/raw/main/deprecated_apr2022/powershell64.exe", dest64W, 0, NULL) != S_OK ) goto failed;
    if( URLDownloadToFileW(NULL, L"https://github.com/PietJankbal/Chocolatey-for-wine/raw/main/deprecated_apr2022/powershell32.exe", dest32W, 0, NULL) != S_OK ) goto failed;

    memset(&si, 0, sizeof(STARTUPINFO)); memset(&pi, 0, sizeof(PROCESS_INFORMATION)); si.cb = sizeof(STARTUPINFO);
    CreateProcessW(dest64W,0,0,0,0,0,0,0,&si,&pi); 
    WaitForSingleObject( pi.hProcess, INFINITE ); CloseHandle( pi.hProcess ); CloseHandle( pi.hThread );

    return 0;

failed:
    fprintf(stderr, "Something went wrong :( (32-bit?, failing download?....  \n");
    return 0; /* fake success anyway */
}
