/*
 * Installs PowerShell Core, wraps powershell`s commandline into correct syntax for pwsh.exe, 
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
 * Compile:
 * i686-w64-mingw32-gcc -municode  -mconsole mainv1.c -lurlmon -lshlwapi -s -o powershell32.exe
 * x86_64-w64-mingw32-gcc -municode  -mconsole mainv1.c -lurlmon -lshlwapi -s -o ChoCinstaller_0.0.703.exe
 */
#include <windows.h>
#include <stdio.h>
#include "shlwapi.h"

int __cdecl wmain(int argc, WCHAR *argv[])
{
    BOOL no_psconsole = TRUE, noexit = FALSE;
    WCHAR conemu_pathW[MAX_PATH], cmdlineW[MAX_PATH]=L"", pwsh_pathW[MAX_PATH], bufW[MAX_PATH] = L" /i ";
    DWORD exitcode;       
    STARTUPINFOW si;
    PROCESS_INFORMATION pi;
    int i = 1, j = 1;
    
    if(!ExpandEnvironmentStringsW(L"%ProgramW6432%", pwsh_pathW, MAX_PATH+1)) goto failed; /* win32 only apparently, not supported... */
    if(!ExpandEnvironmentStringsW(L"%SystemDrive%", conemu_pathW, MAX_PATH+1)) goto failed;

    lstrcatW(conemu_pathW, L"\\ConEmu\\ConEmu64.exe");
    lstrcatW(pwsh_pathW, L"\\Powershell\\7\\pwsh.exe");
    /* Download and Install */
    memset( &si, 0, sizeof( STARTUPINFO )); si.cb = sizeof( STARTUPINFO ); memset( &pi, 0, sizeof( PROCESS_INFORMATION ) );
    if ( !wcsncmp ( &argv[0][lstrlenW(argv[0])-25] , L"ChoCinstaller_" , 14 ) )
    {    
       WCHAR ps_pathW[MAX_PATH] = L"", setup_pathW[MAX_PATH]= L"", tmpW[MAX_PATH], versionW[] = L".....";
       WCHAR profile_pathW[MAX_PATH], msiexecW[MAX_PATH], cacheW[MAX_PATH], msiW[MAX_PATH] = L"", downloadW[MAX_PATH] = L"";
       
       if ( !ExpandEnvironmentStringsW( L"%SystemRoot%", ps_pathW, MAX_PATH + 1 ) ) goto failed; 
       if ( !CopyFileW( argv[0], lstrcatW(ps_pathW, L"\\system32\\WindowsPowershell\\v1.0\\powershell.exe" ), FALSE) ) goto failed;
       lstrcpyW( setup_pathW, argv[0] );
       versionW[0] = (PathFindFileNameW( setup_pathW ))[18]; versionW[2] = PathFindFileNameW( setup_pathW )[19]; versionW[4] = PathFindFileNameW( setup_pathW )[20];
       PathRemoveFileSpecW( setup_pathW );
 
       if( !ExpandEnvironmentStringsW( L"%SystemRoot%", ps_pathW, MAX_PATH + 1 ) ) goto failed;
       if( !CopyFileW( lstrcatW( setup_pathW, L"\\powershell32.exe" ), lstrcatW( ps_pathW, L"\\syswow64\\WindowsPowershell\\v1.0\\powershell.exe" ), FALSE) ) goto failed;
       /* Download and install*/
       lstrcatW( lstrcatW( msiW, L"PowerShell-"), versionW ); lstrcatW( msiW, L"-win-x64.msi" ); 

       if ( !ExpandEnvironmentStringsW( L"%ProgramW6432%", profile_pathW, MAX_PATH + 1 ) ) goto failed; /* win32 only apparently, not supported... */
       if ( !ExpandEnvironmentStringsW( L"%winsysdir%", msiexecW, MAX_PATH + 1 ) ) goto failed; 
       if ( !ExpandEnvironmentStringsW( L"%WINEHOMEDIR%", cacheW, MAX_PATH+1) ) goto failed; 
       
        GetTempPathW( MAX_PATH, tmpW ); lstrcatW ( lstrcatW( cacheW, L"\\.cache\\choc_install_files\\" ), msiW );
        if ( !CopyFileW( cacheW , lstrcatW( tmpW, msiW ), FALSE ) )
        {
            fwprintf( stderr, L"\033[1;93m" ); fwprintf( stderr, L"\nDownloading %ls \n", msiW ); fwprintf( stderr, L"\033[0m\n" );
            if( URLDownloadToFileW( NULL, lstrcatW( lstrcatW( lstrcatW ( lstrcatW ( downloadW, L"https://github.com/PowerShell/PowerShell/releases/download/v" ), versionW) , L"/" ), msiW), tmpW,0 , NULL ) != S_OK )
                goto failed;
        }

        memset( &si, 0, sizeof( STARTUPINFO )); si.cb = sizeof( STARTUPINFO ); memset( &pi, 0, sizeof( PROCESS_INFORMATION ));
        GetTempPathW( MAX_PATH, tmpW );
        CreateProcessW(lstrcatW( msiexecW, L"\\msiexec.exe" ), lstrcatW( bufW, lstrcatW( lstrcatW( tmpW, msiW ) , L" ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 /q" ) ), 0, 0, 0, HIGH_PRIORITY_CLASS, 0, 0, &si, &pi);
        WaitForSingleObject( pi.hProcess, INFINITE ); CloseHandle( pi.hProcess ); CloseHandle( pi.hThread );   

        memset( &si, 0, sizeof( STARTUPINFO ) ); si.cb = sizeof( STARTUPINFO ); memset( &pi , 0, sizeof( PROCESS_INFORMATION ) );
        GetTempPathW( MAX_PATH, tmpW ); bufW[0] = 0;
        PathRemoveFileSpecW( setup_pathW );
        CreateProcessW( pwsh_pathW, lstrcatW ( lstrcatW( lstrcatW( lstrcatW( bufW, L" -file " ), setup_pathW ), L"\\choc_install.ps1 " ), setup_pathW ), 0, 0, 0, HIGH_PRIORITY_CLASS, 0, 0, &si, &pi);
        WaitForSingleObject( pi.hProcess, INFINITE ); CloseHandle( pi.hProcess ); CloseHandle( pi.hThread );
        
        return 0;  /* End download and install */    
    }
    /* I can also act as a dummy program if my exe-name is not powershell */ 
    /* Allows to replace a system executable (like wusa.exe, or any exe really) by a function in profile.ps1 */
    memset( &si, 0, sizeof( STARTUPINFO )); si.cb = sizeof( STARTUPINFO ); memset( &pi, 0, sizeof( PROCESS_INFORMATION ) );
    if ( wcsnicmp ( &argv[0][lstrlenW(argv[0]) - 14 ] , L"powershell.exe" , 14 ) && wcsnicmp ( &argv[0][lstrlenW(argv[0]) - 10 ] , L"powershell" , 10 ) )
    {    /* Rename the exe in the cmdline: add some prefix to it, so we can query for program replacement in profile.ps1) */
        lstrcatW ( lstrcatW( lstrcatW( lstrcatW( cmdlineW, L" " ), L" -c " ), L"QPR." ) , argv[0] );
        while( i  < argc ) {/* concatenate the rest of the arguments into the new cmdline */
            lstrcatW( lstrcatW( cmdlineW, L" " ), argv[i] ); i++;}
        CreateProcessW( pwsh_pathW, cmdlineW , 0, 0, 0, 0, 0, 0, &si, &pi ); /* send the new commandline to pwsh.exe */
        WaitForSingleObject( pi.hProcess, INFINITE ); GetExitCodeProcess( pi.hProcess, &exitcode ); CloseHandle( pi.hProcess ); CloseHandle( pi.hThread );    
        return ( GetEnvironmentVariable( L"FAKESUCCESS", bufW, MAX_PATH + 1 ) ? 0 : exitcode );
    }
    /* Main program: wrap the original powershell-commandline into correct syntax, and send it to pwsh.exe */ 
    BOOL is_single_or_last_option (WCHAR *opt)
    {
        return ( ( ( !wcsnicmp( opt, L"-c", 2 ) && wcsnicmp( opt, L"-config", 7 ) ) || !wcsnicmp( opt, L"-n", 2 ) || \
                     !wcsnicmp( opt, L"-m", 2 ) || !wcsnicmp( opt, L"-s", 2 )  || !wcsicmp( opt, L"-" ) || !wcsnicmp( opt, L"-f", 2 ) ) ? TRUE : FALSE );
    }
    /* pwsh requires a command option "-c" , powershell doesn`t, so we have to insert it somewhere e.g. 'powershell -nologo 2+1' should go into 'powershell -nologo -c 2+1'*/ 
    while ( !wcsnicmp(L"-", argv[i], 1 ) ) /* Search for 1st argument after options */
    {
        if ( !is_single_or_last_option ( argv[i] ) ) i++;
        i++;
    }

    if( i == argc) no_psconsole = FALSE;  /*no command found, start PSConsole later in ConEmu to work around bug https://bugs.winehq.org/show_bug.cgi?id=49780*/

    while (j < i ) /* concatenate options into new cmdline, meanwhile working around some incompabilities */ 
    {   
        if ( !wcsnicmp( L"-noe", argv[j], 4 ) ) noexit = TRUE;      /* -NoExit, hack to start PSConsole in ConEmu later to work around bug https://bugs.winehq.org/show_bug.cgi?id=49780)*/
        if ( !wcsnicmp( L"-f", argv[j], 2 ) ) no_psconsole = TRUE;  /* -File, do not start in PSConsole */
        if ( !wcsnicmp( L"-ve", argv[j], 3 ) ) {j++;  goto done;}   /* -Version, exclude from new cmdline, incompatible... */
        if ( !wcsnicmp( L"-nop", argv[j], 4 ) ) goto done;          /* -NoProfile, also exclude to always enable profile.ps1 to work around possible incompatibilities */   
        lstrcatW( lstrcatW( cmdlineW, L" " ), argv[j] );
        done: j++;
    }
    /* now insert a '-c' (if necessary) */
    if ( argv[i] && wcsnicmp( argv[i-1], L"-c", 2 ) && wcsicmp( argv[i-1], L"-" ) && wcsnicmp( argv[i-1], L"-f", 2 ) && wcsnicmp( argv[i], L"/c", 2 ) )
        lstrcatW( lstrcatW( cmdlineW, L" " ), L"-c " );

    while( i  < argc ) /* concatenate the rest of the arguments into the new cmdline */
    {
        lstrcatW( lstrcatW( cmdlineW, L" " ), argv[i] );
        i++;
    }
 
    if ( GetEnvironmentVariable( L"PWSHVERBOSE", bufW, MAX_PATH + 1 ) ) 
        { fwprintf( stderr, L"\033[1;35m" ); fwprintf( stderr, L"\n command line is %ls \n", cmdlineW ); fwprintf( stderr, L"\033[0m\n" ); }
    /* if not a command, start powershellconsole in ConEmu to work around missing ENABLE_VIRTUAL_TERMINAL_PROCESSING (bug https://bugs.winehq.org/show_bug.cgi?id=49780) */
    if( !no_psconsole || noexit)
    {
        bufW[0] = 0;
        CreateProcessW( conemu_pathW, lstrcatW( lstrcatW( lstrcatW( bufW, L" -NoUpdate -Title \"This is Powershell Core (pwsh.exe), not (!) powershell.exe\" -run "), pwsh_pathW), cmdlineW), 0, 0, 0, 0, 0, 0, &si, &pi) ;
        WaitForSingleObject( pi.hProcess, INFINITE ); CloseHandle( pi.hProcess ); CloseHandle( pi.hThread );
        return 0;
    }
    /* Otherwise execute the command through pwsh.exe */
    CreateProcessW( pwsh_pathW, cmdlineW , 0, 0, 0, 0, 0, 0, &si, &pi );
    WaitForSingleObject( pi.hProcess, INFINITE ); GetExitCodeProcess( pi.hProcess, &exitcode ); CloseHandle( pi.hProcess ); CloseHandle( pi.hThread );    

    return ( GetEnvironmentVariable( L"FAKESUCCESS", bufW, MAX_PATH + 1 ) ? 0 : exitcode ); 

failed:
    fprintf( stderr, "Something went wrong :( (32-bit?, winversion <win7?, failing download? ....  \n" );
    return 0; /* fake success anyway */
}
