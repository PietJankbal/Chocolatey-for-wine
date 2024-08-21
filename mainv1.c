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
 -mconsole -municode -mno-stack-arg-probe -Xlinker --stack=0x200000,0x200000 -nostdlib  -Wall -Wextra -ffreestanding  mainv1.c -lurlmon -lkernel32 -lucrtbase -luser32 -nostdlib -lshell32 -lntdll -s -o ChoCinstaller_0.5e.715.exe
 * i686-w64-mingw32-gcc -O1 -fno-ident -fno-stack-protector -fomit-frame-pointer -fno-unwind-tables -fno-asynchronous-unwind-tables -falign-functions=1 -falign-jumps=1 -falign-loops=1 -fwhole-program\
 -mconsole -municode -mno-stack-arg-probe -Xlinker --stack=0x200000,0x200000 -nostdlib  -Wall -Wextra -ffreestanding mainv1.c -lurlmon -lkernel32 -lucrtbase -luser32 -nostdlib -lshell32 -lntdll -s -o powershell32.exe
 * Btw: The included binaries are compressed with upx to make them even smaller (choco install upx):
 */
#include <windows.h>
#include <winternl.h> 
#include <stdio.h>

static WCHAR *strip( WCHAR *start ) /* strip spaces*/
{
    WCHAR *str = start, *end = start + wcslen( start ) - 1;
    while (*str == ' ') str++;
    while (end >= start && *end == ' ') *end-- = 0;
    return str;
}

static inline BOOL is_single_option (WCHAR *opt) /* e.g. -noprofile, -nologo , -mta etc */ 
{
    return ( wcschr( L"nNmMsS", opt[0] ) ? TRUE: FALSE );
}  

static inline BOOL is_last_option (WCHAR *opt) /* no new options may follow -c, -f , -, and -e (but not -ex(ecutionpolicy)!) */
{
    return ( wcschr( L"cCfF", opt[0] ) || ( wcschr( L"eE", opt[0] ) && (!opt[1] || !wcschr( L"xX", opt[1] ))) || !strip(opt));
}  
 
__attribute__((externally_visible))  /* for -fwhole-program */
int mainCRTStartup(void)
{
    BOOL read_from_stdin = FALSE;
    wchar_t cmdlineW[4096]=L"", pwsh_pathW[MAX_PATH] =L"", bufW[MAX_PATH] = L"", drive[MAX_PATH] , dir[_MAX_FNAME], filenameW[_MAX_FNAME], **argv;
    DWORD exitcode;       
    STARTUPINFOW si = {0};
    PROCESS_INFORMATION pi = {0};
    int i = 1, argc;

    argv = CommandLineToArgvW ( GetCommandLineW(), &argc);
    _wsplitpath( argv[0], drive, dir, filenameW, NULL );

    ExpandEnvironmentStringsW(L"%ProgramW6432%\\Powershell\\7\\pwsh.exe", pwsh_pathW, MAX_PATH+1);
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
        wcscat( wcscat( cmdlineW, L" -nop -c QPR." ) , filenameW );
        for( i = 1; i < argc; i++ ) { /* concatenate the rest of the arguments into the new cmdline */
            wcscat( wcscat( wcscat( cmdlineW, L" '\"" )  , argv[i] ), L"\"'" ); }
        SetEnvironmentVariableW( L"QPRCMDLINE", GetCommandLineW() ); /* option to track the complete commandline via $env:QPRCMDLINE */
        goto exec;
    }  /* note: set desired exitcode in the function in profile.ps1 */ 
    /* Main program: wrap the original powershell-commandline into correct syntax, and send it to pwsh.exe */ 
    /* pwsh requires a command option "-c" , powershell doesn`t, so we have to insert it somewhere e.g. 'powershell -nologo 2+1' should go into 'powershell -nologo -c 2+1'*/ 
    if( !argv[1] ) read_from_stdin = TRUE; /* might be redirected like 'cmd.exe /c "powershell < ""c:\a.txt"""' */
    else {
      WCHAR *cmd = wcsdup( wcsstr( GetCommandLineW(), argv[1]) ); //futws(L"\n", stderr);futws(cmd, stderr);fputws(L"<--old cmd is:\n", stderr);
      /* No options (-xxx or /xxx) given e.g. {echo hello} or 1+2 or "& whoami" etc: insert '-c' and send to pwsh. */ 
      if ( cmd[0] != '-' && cmd[0] != '/' ) wcscat(wcscat(cmdlineW, L" -c "), cmd);
      else
      {
        if ( cmd[ wcslen(cmd) - 1] == '-' ) { read_from_stdin = 1; } /* e.g. '$(get-date | powershell -') */

        wchar_t *ptr, *token, delim = L'-';
        
        token = wcstok_s(cmd, &delim ,&ptr); /* Break up the options */
        
        if(wcschr(token,L'/')) {
            fputws(L"\033[1;91m",stderr);fputws(L"Deprecated token '/' found!!! Expect problems!! Trying anyway", stderr);fputws(L"\033[0m\n",stderr);
            delim = L'/';
            token = wcstok_s(cmd, &delim ,&ptr);
        }  

        while (token) {
                         WCHAR *p;
			             BOOL skip = (!_wcsnicmp(token,L"ve",2) || !_wcsnicmp(token,L"nop",3)); /* skip '-noprofile' and '-version'*/
   	            			
   	            		 if (is_last_option(token)) { /* there is a command option, no need to take action */
				           if (!skip) wcscat(wcscat(cmdlineW, L" -"),token);
				           if(*ptr) wcscat(wcscat(cmdlineW, &delim),ptr); /* add remainder of command string and exit */
				           break;
			             }
			             else { /* single or double option or garbage -->not handled (!) */
					       /* last option will now have an extra 'tail' e.g ' nologo echo' so search for extra space */
			               if( is_single_option(token) ) p = (wcschr( strip(token),L' ')); 
			               else p = wcschr((strip(wcschr(strip(token),L' '))) ,L' '); /* last double option has two spaces, look for last */
                           /* if there's an extra space, we've arrived at last option, and insert a -c */
			               if(!p) { /* not yet arrived at last option, no need to take action */ 
						     if (!skip) wcscat(wcscat(cmdlineW, L" -"),token);
						   }
			               else {  /* arrived at last option: insert a '-c' */
			                 *p=0; /* break the string in two words by setting '\0' character */
			                 if(!skip) wcscat( wcscat(cmdlineW, L" -"), token); /* concatenate the option (1st part string) */
			                 wcscat(wcscat(cmdlineW, L" -c "), p+1);/* concatenate '-c' and the end of the string (= beginning of command ) */
                             if(*ptr) wcscat(wcscat(cmdlineW, &delim),ptr); /* and the rest of the command string */
                             break;       
			               } 
		                 }
                         token = wcstok_s(NULL, &delim ,&ptr);
                     }
      } 
    }
    /* by setting "PS51" env variable, there's a possibility to execute the cmd through rudimentary windows powershell 5.1, requires 'winetricks ps51' first */
    /* Note: when run from bash, escape special char $ with single quotes and backtick e.g. PS51=1 wine powershell '`SPSVersionTable' */
    if ( GetEnvironmentVariableW( L"PS51", bufW, MAX_PATH + 1 ) && !wcscmp( bufW, L"1") ) 
        ExpandEnvironmentStringsW( L"%SystemRoot%\\system32\\WindowsPowershell\\v1.0\\ps51.exe ", pwsh_pathW, MAX_PATH + 1 );
    /* support pipeline to handle something like " wcschr| powershell - " */
    if( read_from_stdin ) { 
        WCHAR defline[4096]; char line[4096];
        HANDLE input = GetStdHandle(STD_INPUT_HANDLE); DWORD type = GetFileType(input);
        /* handle pipe */
        if (  type != FILE_TYPE_CHAR ) { /* not redirected (FILE_TYPE_PIPE or FILE_TYPE_DISK); otherwise 'wine powershell' will hang waiting for input... */
            if( (!wcscmp(argv[argc-1], L"-" ) && _wcsnicmp(argv[argc-2], L"-c", 2 ) ) || !argv[1]) wcscat(cmdlineW, L" -c ");
            wcscat(cmdlineW, L" ");
            while( fgets(line, 4096, stdin) != NULL ) { mbstowcs(defline, line, 4096); wcscat(cmdlineW, defline);}
 		}   //FILE *fptr; fptr = fopen("c:\\log.txt", "a");fputws(L"Note: command was read from stdin\n", stderr);fclose(fptr);
    } /* end support pipeline */
exec:// FILE *fptr; fptr = fopen("c:\\log.txt", "a");fputws(L"new commandline is now: ",fptr); fputws(cmdlineW,fptr);fputws(L"\n",fptr); fclose(fptr);     
    if (!cmdlineW[0] ) ExpandEnvironmentStringsW( L" -c %SystemDrive%\\ConEmu\\ConEmu64.exe -NoUpdate -LoadRegistry -run %ProgramW6432%\\Powershell\\7\\pwsh.exe ", bufW, MAX_PATH+1);
    CreateProcessW( pwsh_pathW, !cmdlineW[0] ? bufW : cmdlineW, 0, 0, 0, 0, 0, 0, &si, &pi );
    WaitForSingleObject( pi.hProcess, INFINITE ); GetExitCodeProcess( pi.hProcess, &exitcode ); CloseHandle( pi.hProcess ); CloseHandle( pi.hThread );    
    LocalFree(argv);
    
    return ( exitcode ); 
}
