/* installer - this installs chocolatey for wine/only run on new prefix!
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
 * x86_64-w64-mingw32-gcc -municode  -mconsole chocdeprecatedinstaller.c -lurlmon -luser32 -lntdll -s -o chocdeprecatedinstaller.exe
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

int __cdecl wmain(int argc, WCHAR *argv[])
{
    WCHAR dest64W[MAX_PATH];WCHAR dest32W[MAX_PATH];

    if(!ExpandEnvironmentStringsW(L"%systemroot%", dest64W, MAX_PATH+1)) goto failed;
    if(!ExpandEnvironmentStringsW(L"%systemroot%", dest32W, MAX_PATH+1)) goto failed;
      
    lstrcatW(dest64W, L"\\system32\\WindowsPowerShell\\v1.0\\powershell.exe");
    lstrcatW(dest32W, L"\\syswow64\\WindowsPowerShell\\v1.0\\powershell.exe");

    DeleteFileW(dest64W); DeleteFileW(dest32W);

    if( URLDownloadToFileW(NULL, L"https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/deprecated/powershell64.exe ", dest64W, 0, NULL) != S_OK )
        goto failed;
   
    if( URLDownloadToFileW(NULL, L"https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/deprecated/powershell32.exe ", dest32W, 0, NULL) != S_OK )
        goto failed;

    STARTUPINFOW startup_info; PROCESS_INFORMATION process_info;
    memset(&startup_info, 0, sizeof(STARTUPINFO)); memset(&process_info, 0, sizeof(PROCESS_INFORMATION));
    startup_info.cb = sizeof(STARTUPINFO);

    CreateProcessW(dest64W,0,0,0,0,0,0,0,&startup_info,&process_info); 
    return 0;

failed:
    fprintf(stderr, "Something went wrong :( (32-bit?, winversion < win7?, failing download?....  \n");
    return 0; /* fake success anyway */
}