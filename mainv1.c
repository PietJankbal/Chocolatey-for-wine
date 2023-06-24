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
 * x86_64-w64-mingw32-gcc -O1 -fno-ident -fno-stack-protector -fomit-frame-pointer -fno-unwind-tables -fno-asynchronous-unwind-tables -falign-functions=1 -falign-jumps=1 -falign-loops=1 -fwhole-program\
 -mconsole -municode -mno-stack-arg-probe -Xlinker --stack=0x200000,0x200000 -nostdlib  -Wall -Wextra -ffreestanding  mainv1.c -lurlmon -lkernel32 -lucrtbase -luser32 -nostdlib -lshell32 -lntdll -s -o ChoCinstaller_0.5y.703.exe
 * i686-w64-mingw32-gcc -O1 -fno-ident -fno-stack-protector -fomit-frame-pointer -fno-unwind-tables -fno-asynchronous-unwind-tables -falign-functions=1 -falign-jumps=1 -falign-loops=1 -fwhole-program\
 -mconsole -municode -mno-stack-arg-probe -Xlinker --stack=0x200000,0x200000 -nostdlib  -Wall -Wextra -ffreestanding mainv1.c -lurlmon -lkernel32 -lucrtbase -luser32 -nostdlib -lshell32 -lntdll -s -o powershell32.exe
 * Btw: The included binaries are compressed with upx to make them even smaller (choco install upx):
 */
#include <windows.h>
#include <winternl.h> 

static inline BOOL is_single_or_last_option (WCHAR *opt)
{
    return ( ( ( !_wcsnicmp( opt, L"-c", 2 ) && _wcsnicmp( opt, L"-config", 7 ) ) || !_wcsnicmp( opt, L"-n", 2 ) || !_wcsnicmp( opt, L"-enc", 4 ) ||\
                 !_wcsnicmp( opt, L"-m", 2 ) || !_wcsnicmp( opt, L"-s", 2 )  || !wcscmp( opt, L"-" ) || !_wcsnicmp( opt, L"-f", 2 ) ) ? TRUE : FALSE );
}
/* following code for reading console is shamelessly stolen (and adapted) from wine/programs/find/find.c */
static inline BOOL read_char_from_handle(HANDLE handle, char *char_out)
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
static inline WCHAR* read_line_from_handle(HANDLE handle, BOOL replace_cr)
{
    int line_max = 4096, length = 0, line_converted_length;
    WCHAR *line_converted;
    BOOL success;
    char *line = (char *)HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, line_max);

    for (;;)
    {
        char c;
        success = read_char_from_handle(handle, &c); //MessageBoxW(0, tmpp , 0, 0);
        /* Check for EOF */
        if (!success) { if (length == 0) return NULL; else break; }
        if (c == '\n') break;
        if (length + 2 >= line_max) /* Make sure buffer is large enough */
        { 
            line_max *= 2;
            line = line ? (char *)HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, line_max) :  (char *)HeapReAlloc(GetProcessHeap(), 0, line, line_max);
        }
        if (c == '"')  line[length++] = '\\';    /* escape the double quotes so they won`t get lost */
        //if (c == '\'') line[length++] = '\'';  /* escape the single quote so they won`t get lost */
        if (c == '\r' && replace_cr) c = ';';    /* carriage return replacement */
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

__attribute__((externally_visible))  /* for -fwhole-program */
int mainCRTStartup(void)
{
    BOOL read_from_stdin = FALSE, ps_console = FALSE;
    wchar_t conemu_pathW[MAX_PATH]=L"", cmdlineW[4096]=L"", pwsh_pathW[MAX_PATH] =L"", bufW[MAX_PATH] = L"", drive[MAX_PATH] , dir[_MAX_FNAME], filenameW[_MAX_FNAME], **argv;;
    DWORD exitcode;       
    STARTUPINFOW si = {0};
    PROCESS_INFORMATION pi = {0};
    int i = 1, j = 1, argc;
    
    argv = CommandLineToArgvW ( GetCommandLineW(), &argc);
    _wsplitpath( argv[0], drive, dir, filenameW, NULL );

    ExpandEnvironmentStringsW(L"%ProgramW6432%\\Powershell\\7\\pwsh.exe", pwsh_pathW, MAX_PATH+1);
    ExpandEnvironmentStringsW(L"%SystemDrive%\\ConEmu\\ConEmu64.exe", conemu_pathW, MAX_PATH+1);
    /* Download and Install */
    if ( !wcsncmp( filenameW , L"ChoCinstaller_" , 14 ) )
    {    
       WCHAR tmpW[MAX_PATH], versionW[] = L".....", msiW[MAX_PATH] = L"", downloadW[MAX_PATH] = L"";
  
       ExpandEnvironmentStringsW( L"%SystemRoot%\\system32\\WindowsPowershell\\v1.0\\powershell.exe", bufW, MAX_PATH + 1 );      
       if ( !CopyFileW( argv[0], bufW ,FALSE) ) {
           MessageBoxA(0, "copy file failed\n", 0, 0); return 1; }
       versionW[0] = filenameW[19]; versionW[2] = filenameW[20]; versionW[4] = filenameW[21];

       ExpandEnvironmentStringsW( L"%SystemRoot%\\syswow64\\WindowsPowershell\\v1.0\\powershell.exe", bufW, MAX_PATH + 1 );      
       if( !CopyFileW( wcscat( wcscat( wcscat( drive , L"\\" ) , dir ) , L"powershell32.exe"  ), bufW , FALSE) ) { 
           MessageBoxA(0, "copy file failed\n", 0, 0); return 1; }

       wcscat( wcscat( msiW, L"PowerShell-"), versionW ); wcscat( msiW, L"-win-x64.msi" ); 
       ExpandEnvironmentStringsW( L"%WINEHOMEDIR%\\.cache\\choc_install_files\\", bufW, MAX_PATH+1); 
       
       GetTempPathW( MAX_PATH, tmpW );
       if ( !CopyFileW( wcscat( bufW, msiW ) , wcscat( tmpW, msiW ), FALSE ) )
       {
           if( URLDownloadToFileW( NULL, wcscat( wcscat( wcscat ( wcscat ( downloadW, L"https://github.com/PowerShell/PowerShell/releases/download/v" ), versionW) , L"/" ), msiW), tmpW,0 , NULL ) != S_OK ) {
               MessageBoxA(0, "download failed :( \n", 0, 0); return 1; }
       }

       GetTempPathW( MAX_PATH, tmpW ); bufW[0] = 0;
       CreateProcessW( 0, wcscat( wcscat( bufW, L"msiexec.exe /i " ), wcscat( wcscat( tmpW, msiW ) , L" ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 /q" ) ), 0, 0, 0, HIGH_PRIORITY_CLASS, 0, 0, &si, &pi);
       WaitForSingleObject( pi.hProcess, INFINITE ); CloseHandle( pi.hProcess ); CloseHandle( pi.hThread );   
       GetTempPathW( MAX_PATH, tmpW ); bufW[0] = 0; _wsplitpath( argv[0], drive, dir, filenameW, NULL );
       wcscat( wcscat( wcscat( wcscat( wcscat ( wcscat( wcscat( wcscat( cmdlineW , L" -file " ), drive ), L"\\" ), dir ), L"choc_install.ps1 " ), drive ), L"\\" ), dir );
       goto exec; /* End download and install */
    } 
    /* I can also act as a dummy program if my exe-name is not powershell, allows to replace a system exe (like wusa.exe, or any exe really) by a function in profile.ps1 */
    else if ( _wcsnicmp( filenameW , L"powershell" , 10 ) )
    {   /* add some prefix to the exe and execute it through pwsh , so we can query for program replacement in profile.ps1 */
        wcscat( wcscat( cmdlineW, L" -c QPR." ) , filenameW );
        for( i = 1; i < argc; i++ ) { /* concatenate the rest of the arguments into the new cmdline */
            wcscat( wcscat( wcscat( cmdlineW, L" '\"" )  , argv[i] ), L"\"'" ); }

        FILE_FS_DEVICE_INFORMATION info; IO_STATUS_BLOCK io;
        HANDLE input = GetStdHandle(STD_INPUT_HANDLE); /* try handle pipe with ugly hack */

        NtQueryVolumeInformationFile( input, &io, &info, sizeof(info), FileFsDeviceInformation ); 

        if(info.DeviceType == 8 ) {
            WCHAR *line=0, pipeW[32767] = L"\"\n";

            while ( (line = read_line_from_handle( input, FALSE ) ) != NULL) { wcscat( pipeW, line); wcscat( pipeW,L"\n"); }
            wcscat( pipeW, L"\"");
            SetEnvironmentVariableW( L"QPRPIPE", pipeW ); /* FIXME, very ugly, store pipe in envvar; */
        } /* end handle pipe */
        SetEnvironmentVariableW( L"QPRCMDLINE", GetCommandLineW() ); /* option to track the complete commandline via $env:QPRCMDLINE */
        goto exec;
    }  /* note: set desired exitcode in the function in profile.ps1 */ 
    /* Main program: wrap the original powershell-commandline into correct syntax, and send it to pwsh.exe */ 
    /* pwsh requires a command option "-c" , powershell doesn`t, so we have to insert it somewhere e.g. 'powershell -nologo 2+1' should go into 'powershell -nologo -c 2+1'*/ 
    for (i = 1;  argv[i] &&  !wcsncmp(  argv[i], L"-" , 1 ); i++ ) { if ( !is_single_or_last_option ( argv[i] ) ) i++; if(!argv[i]) break;} /* Search for 1st argument after options */
    /* by setting this env variable, there's a possibility to execute the cmd through rudimentary windows powershell 5.1, requires 'winetricks ps51' first */
    if ( GetEnvironmentVariableW( L"PS51", bufW, MAX_PATH + 1 ) && !wcscmp( bufW, L"1") )
    {   /* Note: when run from bash, escape special char $ with single quotes and backtick e.g. PS51=1 wine powershell '`SPSVersionTable' */
        if( i == argc) ps_console = TRUE;
        ExpandEnvironmentStringsW( L"%SystemRoot%\\system32\\WindowsPowershell\\v1.0\\ps51.exe ", pwsh_pathW, MAX_PATH + 1 ); 
        for ( i = 1 ; argv[i] ; i++) wcscat( wcscat( cmdlineW, L" " ), argv[i] ); 
        goto exec;
    }
    for (j = 1; j < i ; j++ ) /* concatenate options into new cmdline, meanwhile working around some incompabilities */ 
    { 
        if ( !wcscmp( L"-", argv[j] ) ) {read_from_stdin = TRUE; continue;}   /* hyphen handled later on */
        if ( !_wcsnicmp(  argv[j], L"-ve", 3 ) ) {j++;  continue;}            /* -Version, exclude from new cmdline, incompatible... */
        if ( !_wcsnicmp( argv[j], L"-nop", 4 ) ) continue;                    /* -NoProfile, also exclude to always enable profile.ps1 to work around possible incompatibilities */   
        wcscat( wcscat( cmdlineW, L" " ), argv[j] );
    }
    /* now insert a '-c' (if necessary) */
    if ( argv[i] && _wcsnicmp( argv[i-1], L"-c", 2 ) && _wcsnicmp( argv[i-1], L"-enc", 4 ) && _wcsnicmp( argv[i-1], L"-f", 2 ) && _wcsnicmp( argv[i], L"/c", 2 ) )
        wcscat( wcscat( cmdlineW, L" " ), L"-c " );
    /* concatenate the rest of the arguments into the new cmdline */
    for( j = i; j < argc; j++ ) wcscat( wcscat( cmdlineW, L" " ), argv[j] );
    /* support pipeline to handle something like " '$(get-date) | powershell - ' */
    if( read_from_stdin ) {
        WCHAR *line;
        HANDLE input = GetStdHandle(STD_INPUT_HANDLE); DWORD type = GetFileType(input);
        /* handle pipe */
        if ( type == FILE_TYPE_CHAR ) goto exec; /* not redirected (FILE_TYPE_PIPE or FILE_TYPE_DISK) */
        if( !wcscmp(argv[argc-1], L"-" ) && _wcsnicmp(argv[argc-2], L"-c", 2 ) ) wcscat(cmdlineW, L" -c ");
        wcscat(cmdlineW, L" \"& {"); /* embed cmdline in scriptblock */
        while ((line = read_line_from_handle( input, TRUE )) != NULL) wcscat( cmdlineW, line); 
        wcscat(cmdlineW, L"}\"");
    } /* end support pipeline */
    if ( i == argc && !read_from_stdin ) ps_console = TRUE;
exec: 
    bufW[0] = 0; /* Execute the command through pwsh.exe (or start PSconsole via ConEmu if no command found) */
    CreateProcessW( pwsh_pathW, !ps_console ? cmdlineW : wcscat( wcscat ( wcscat( wcscat( wcscat( \
                    bufW, L" -c " ) , conemu_pathW ) , L" -NoUpdate -LoadRegistry -run "), pwsh_pathW ), cmdlineW ), 0, 0, 0, 0, 0, 0, &si, &pi );
    WaitForSingleObject( pi.hProcess, INFINITE ); GetExitCodeProcess( pi.hProcess, &exitcode ); CloseHandle( pi.hProcess ); CloseHandle( pi.hThread );    
    LocalFree(argv);

    return ( exitcode ); 
}
