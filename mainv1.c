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
 * x86_64-w64-mingw32-gcc -municode  -mconsole mainv1.c -lurlmon -lshlwapi -s -o ChoCinstaller_0.5i.703.exe
 * Btw: The included binaries are compiled with windows mingw (after 'choco install mingw' and 'choco install mingw --x86') and compressed with upx:
 * gcc -s -Os -fno-ident -fno-stack-protector -fomit-frame-pointer -fno-unwind-tables -fno-asynchronous-unwind-tables -falign-functions=1  -mpreferred-stack-boundary=2{32-bit}4{64-bit} -falign-jumps=1 -falign-loops=1 -mconsole -municode  -o h.exe mainv1.c -lurlmon -lshlwapi
 */

#include <windows.h>
#include <stdio.h>
#include "shlwapi.h"

BOOL is_single_or_last_option (WCHAR *opt)
{
    return ( ( ( !_wcsnicmp( opt, L"-c", 2 ) && _wcsnicmp( opt, L"-config", 7 ) ) || !_wcsnicmp( opt, L"-n", 2 ) || !_wcsnicmp( opt, L"-enc", 4 ) ||\
                 !_wcsnicmp( opt, L"-m", 2 ) || !_wcsnicmp( opt, L"-s", 2 )  || !wcscmp( opt, L"-" ) || !_wcsnicmp( opt, L"-f", 2 ) ) ? TRUE : FALSE );
}

BOOL read_char_from_handle(HANDLE handle, char *char_out)
{
    static char buffer[4096];
    static DWORD buffer_max = 0, buffer_pos = 0;
    /* Read next content into buffer */
    if (buffer_pos >= buffer_max)
    {
        BOOL success = ReadFile(handle, buffer, 4096, &buffer_max, NULL);
        if (!success || !buffer_max) return FALSE;
        buffer_pos = 0;
    }
    *char_out = buffer[buffer_pos++];
    return TRUE;
}
/* Read a line from a handle, returns NULL if the end is reached */
WCHAR* read_line_from_handle(HANDLE handle)
{
    int line_max = 4096, length = 0, line_converted_length;
    WCHAR *line_converted;
    BOOL success;
    char *line = (char *)HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, line_max);

    for (;;)
    {
        char c;
        success = read_char_from_handle(handle, &c);
        /* Check for EOF */
        if (!success) { if (length == 0) return NULL; else break; }
        if (c == '\n') break;
        if (length + 2 >= line_max) /* Make sure buffer is large enough */
        { 
            line_max *= 2;
            line = line ? (char *)HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, line_max) :  (char *)HeapReAlloc(GetProcessHeap(), 0, line, line_max);
        }
        if (c == '"')  line[length++] = '\\';  /* escape the double quotes so they won`t get lost */
        //if (c == '\'') line[length++] = '\'';  /* escape the single quote so they won`t get lost */
        if (c == '\r') c = ';';                /* carriage return should be replaced */
        line[length++] = c;   
    }
    line[length] = 0; /* Strip \r of windows line endings */
    if (length - 1 >= 0 && line[length - 1] == '\r') line[length - 1] = 0;
    line_converted_length = MultiByteToWideChar(CP_ACP, 0, line, -1, 0, 0);
    line_converted = (WCHAR *)HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, line_converted_length * sizeof(WCHAR)); 
    MultiByteToWideChar(CP_ACP, 0, line, -1, line_converted, line_converted_length);
    HeapFree(GetProcessHeap(), 0, line);
    return line_converted;
}

int __cdecl wmain(int argc, WCHAR *argv[])
{
    BOOL read_from_stdin = FALSE;
    WCHAR conemu_pathW[MAX_PATH], cmdlineW[MAX_PATH]=L"", pwsh_pathW[MAX_PATH], bufW[MAX_PATH] = L"", *filenameW;
    DWORD exitcode;       
    STARTUPINFOW si;
    PROCESS_INFORMATION pi;
    int i = 1, j = 1;

    if(!ExpandEnvironmentStringsW(L"%ProgramW6432%", pwsh_pathW, MAX_PATH+1)) goto failed; /* win32 only apparently, not supported... */
    if(!ExpandEnvironmentStringsW(L"%SystemDrive%", conemu_pathW, MAX_PATH+1)) goto failed;

    wcscat(conemu_pathW, L"\\ConEmu\\ConEmu64.exe");
    wcscat(pwsh_pathW, L"\\Powershell\\7\\pwsh.exe");

    filenameW = wcsrchr( argv[0], '\\') + 1;

    /* Download and Install */
    memset( &si, 0, sizeof( STARTUPINFO )); si.cb = sizeof( STARTUPINFO ); memset( &pi, 0, sizeof( PROCESS_INFORMATION ) );
    if ( !wcsncmp( filenameW , L"ChoCinstaller_" , 14 ) )
    {    
       WCHAR ps_pathW[MAX_PATH] = L"", setup_pathW[MAX_PATH]= L"", tmpW[MAX_PATH], versionW[] = L".....";
       WCHAR profile_pathW[MAX_PATH], msiexecW[MAX_PATH], cacheW[MAX_PATH], msiW[MAX_PATH] = L"", downloadW[MAX_PATH] = L"";
       
       if ( !ExpandEnvironmentStringsW( L"%SystemRoot%", ps_pathW, MAX_PATH + 1 ) ) goto failed; 
       if ( !CopyFileW( argv[0], wcscat(ps_pathW, L"\\system32\\WindowsPowershell\\v1.0\\powershell.exe" ), FALSE) ) goto failed;
       wcscpy( setup_pathW, argv[0] );
       versionW[0] = (PathFindFileNameW( setup_pathW ))[19]; versionW[2] = PathFindFileNameW( setup_pathW )[20]; versionW[4] = PathFindFileNameW( setup_pathW )[21];
       PathRemoveFileSpecW( setup_pathW );
 
       if( !ExpandEnvironmentStringsW( L"%SystemRoot%", ps_pathW, MAX_PATH + 1 ) ) goto failed;
       if( !CopyFileW( wcscat( setup_pathW, L"\\powershell32.exe" ), wcscat( ps_pathW, L"\\syswow64\\WindowsPowershell\\v1.0\\powershell.exe" ), FALSE) ) goto failed;
       /* Download and install*/
       wcscat( wcscat( msiW, L"PowerShell-"), versionW ); wcscat( msiW, L"-win-x64.msi" ); 

       if ( !ExpandEnvironmentStringsW( L"%ProgramW6432%", profile_pathW, MAX_PATH + 1 ) ) goto failed; /* win32 only apparently, not supported... */
       if ( !ExpandEnvironmentStringsW( L"%winsysdir%", msiexecW, MAX_PATH + 1 ) ) goto failed; 
       if ( !ExpandEnvironmentStringsW( L"%WINEHOMEDIR%", cacheW, MAX_PATH+1) ) goto failed; 
       
        GetTempPathW( MAX_PATH, tmpW ); wcscat ( wcscat( cacheW, L"\\.cache\\choc_install_files\\" ), msiW );
        if ( !CopyFileW( cacheW , wcscat( tmpW, msiW ), FALSE ) )
        {
            //fwprintf( stderr, L"\033[1;93m" ); fwprintf( stderr, L"\nDownloading %ls \n", msiW ); fwprintf( stderr, L"\033[0m\n" );
            if( URLDownloadToFileW( NULL, wcscat( wcscat( wcscat ( wcscat ( downloadW, L"https://github.com/PowerShell/PowerShell/releases/download/v" ), versionW) , L"/" ), msiW), tmpW,0 , NULL ) != S_OK )
                goto failed;
        }

        memset( &si, 0, sizeof( STARTUPINFO )); si.cb = sizeof( STARTUPINFO ); memset( &pi, 0, sizeof( PROCESS_INFORMATION ));
        GetTempPathW( MAX_PATH, tmpW );
        CreateProcessW(wcscat( msiexecW, L"\\msiexec.exe" ), wcscat( wcscat( bufW, L" /i " ), wcscat( wcscat( tmpW, msiW ) , L" ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 /q" ) ), 0, 0, 0, HIGH_PRIORITY_CLASS, 0, 0, &si, &pi);
        WaitForSingleObject( pi.hProcess, INFINITE ); CloseHandle( pi.hProcess ); CloseHandle( pi.hThread );   

        memset( &si, 0, sizeof( STARTUPINFO ) ); si.cb = sizeof( STARTUPINFO ); memset( &pi , 0, sizeof( PROCESS_INFORMATION ) );
        GetTempPathW( MAX_PATH, tmpW ); bufW[0] = 0;
        PathRemoveFileSpecW( setup_pathW );
        CreateProcessW( pwsh_pathW, wcscat ( wcscat( wcscat( wcscat( bufW, L" -file " ), setup_pathW ), L"\\choc_install.ps1 " ), setup_pathW ), 0, 0, 0, HIGH_PRIORITY_CLASS, 0, 0, &si, &pi);
        WaitForSingleObject( pi.hProcess, INFINITE ); CloseHandle( pi.hProcess ); CloseHandle( pi.hThread );
        
        return 0;  /* End download and install */    
    } 
    /* I can also act as a dummy program if my exe-name is not powershell, allows to replace a system exe (like wusa.exe, or any exe really) by a function in profile.ps1 */

    if ( _wcsnicmp( filenameW , L"powershell" , 10 ) )
    {   
        WCHAR *ptr = argv[0]; 
        while( *ptr ) { 
            if( *ptr=='/' ) { *ptr='\\'; } ptr++; } /* some programs call like 'c:\\windows/system32/setx' so we replace forward with back slashes */
        wcscat( wcscat( cmdlineW, L" -c QPR." ) , argv[0] ); /* add some prefix to the executable, so we can query for program replacement in profile.ps1 */
        if ( _wcsnicmp ( &argv[0][ wcslen(argv[0]) - 4 ] , L".exe" , 4 ) ) wcscat( cmdlineW, L".exe" ); /* and add '.exe' if necessary */
        for( i = 1; i < argc; i++ ) { /* concatenate the rest of the arguments into the new cmdline */
            wcscat( wcscat( wcscat( cmdlineW, L" '\"" )  , argv[i] ), L"\"'" ); }
        SetEnvironmentVariableW( L"QPRCMDLINE", GetCommandLineW() ); /* option to track the complete commandline via $env:QPRCMDLINE */
        CreateProcessW( pwsh_pathW, cmdlineW , 0, 0, 0, 0, 0, 0, &si, &pi ); /* send the new commandline to pwsh.exe */
        WaitForSingleObject( pi.hProcess, INFINITE ); GetExitCodeProcess( pi.hProcess, &exitcode ); CloseHandle( pi.hProcess ); CloseHandle( pi.hThread );    
        return ( GetEnvironmentVariableW( L"QPREXITCODE", bufW, MAX_PATH + 1 ) ? _wtoi( bufW ) : exitcode );
    }
    /* by setting this env variable, there's a possibility to execute the cmd through rudimentary windows powershell 5.1, requires 'winetricks ps51' first */
    if ( GetEnvironmentVariableW( L"PS51", bufW, MAX_PATH + 1 ) && !wcscmp( bufW, L"1") )
    {   /* Note: when run from bash, escape special char $ with single quotes and backtick e.g. PS51=1 wine powershell '`SPSVersionTable' */
        wcscat( cmdlineW, L" -c ps51 " );
        for ( i = 1 ; argv[i] ; i++) wcscat( wcscat( cmdlineW, L" " ), argv[i] ); 
        goto exec;
    }
    /* Main program: wrap the original powershell-commandline into correct syntax, and send it to pwsh.exe */ 
    /* pwsh requires a command option "-c" , powershell doesn`t, so we have to insert it somewhere e.g. 'powershell -nologo 2+1' should go into 'powershell -nologo -c 2+1'*/ 
    if ( !argv[1] ) goto exec;
    for (i = 1;  argv[i] &&  !wcsncmp(  argv[i], L"-" , 1 ); i++ ) { if ( !is_single_or_last_option ( argv[i] ) ) i++; if(!argv[i]) break;} /* Search for 1st argument after options */
    for (j = 1; j < i ; j++ ) /* concatenate options into new cmdline, meanwhile working around some incompabilities */ 
    { 
        if ( !wcscmp( L"-", argv[j] ) ) {read_from_stdin = TRUE; continue;} /* hyphen handled later on */
        if ( !_wcsnicmp(  argv[j], L"-ve", 3 ) ) {j++;  continue;}            /* -Version, exclude from new cmdline, incompatible... */
        if ( !_wcsnicmp( argv[j], L"-nop", 4 ) ) continue;                   /* -NoProfile, also exclude to always enable profile.ps1 to work around possible incompatibilities */   
        wcscat( wcscat( cmdlineW, L" " ), argv[j] );
    }
    /* now insert a '-c' (if necessary) */
    if ( argv[i] && _wcsnicmp( argv[i-1], L"-c", 2 ) && _wcsnicmp( argv[i-1], L"-enc", 4 ) && _wcsnicmp( argv[i-1], L"-f", 2 ) && _wcsnicmp( argv[i], L"/c", 2 ) )
        wcscat( wcscat( cmdlineW, L" " ), L"-c " );
    /* concatenate the rest of the arguments into the new cmdline */
    for( j = i; j < argc; j++ ) wcscat( wcscat( cmdlineW, L" " ), argv[j] );
    /* support pipeline to handle something like " '$(get-date) | powershell - ' */
    /* following code for reading console is shamelessly stolen and adapted from wine/programs/find/find.c */
       if( read_from_stdin ) {
        WCHAR *line;

        HANDLE input = GetStdHandle(STD_INPUT_HANDLE);
        DWORD type = GetFileType(input);
        if ( type == FILE_TYPE_CHAR ) goto exec; /* not redirected (FILE_TYPE_PIPE or FILE_TYPE_DISK) */
        if( !wcscmp(argv[argc-1], L"-" ) && _wcsnicmp(argv[argc-2], L"-c", 2 ) ) wcscat(cmdlineW, L" -c ");
        wcscat(cmdlineW, L" \"& {"); /* embed cmdline in scriptblock */
        while ((line = read_line_from_handle(input)) != NULL) wcscat( cmdlineW, line); 
        wcscat(cmdlineW, L"}\"");
    } /* end support pipeline */ 
exec: 
    //if ( GetEnvironmentVariableW( L"PWSHVERBOSE", bufW, MAX_PATH + 1 ) ) 
    //{ fwprintf( stderr, L"\033[1;35m" ); fwprintf( stderr, L"\n command line is %ls \n", cmdlineW ); fwprintf( stderr, L"\033[0m\n" ); }
    bufW[0] = 0; /* Execute the command through pwsh.exe (or start PSconsole via ConEmu if no command found) */
    CreateProcessW( pwsh_pathW, !( (i == argc ) && !read_from_stdin ) ? cmdlineW : wcscat( wcscat ( wcscat( wcscat( wcscat( \
                    bufW, L" -c " ) , conemu_pathW ) , L" -NoUpdate -LoadRegistry -run "), pwsh_pathW ), cmdlineW ), 0, 0, 0, 0, 0, 0, &si, &pi );
    WaitForSingleObject( pi.hProcess, INFINITE ); GetExitCodeProcess( pi.hProcess, &exitcode ); CloseHandle( pi.hProcess ); CloseHandle( pi.hThread );    

    return ( GetEnvironmentVariableW( L"FAKESUCCESS", bufW, MAX_PATH + 1 ) ? 0 : exitcode ); 

failed:  
    fprintf( stderr, "Something went wrong :( (failing download?\n" );
    return 0; /* fake success anyway */
}
