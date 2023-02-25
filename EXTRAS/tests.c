/*  
 * Compile:
 * i686-w64-mingw32-gcc -municode  -mconsole tests.c -lurlmon -luser32 -s -o tests.exe
 * x86_64-w64-mingw32-gcc -municode  -mconsole tests.c -lurlmon -luser32 -s -o tests.exe
 */
#include <windows.h>
#include <stdio.h>

int __cdecl wmain( int argc, WCHAR *argv[] )
{
   
    STARTUPINFOA si;
    PROCESS_INFORMATION pi;     DWORD exitcode; int i;
 

    char commandA[][MAX_PATH]= {  "c:\\windows/system32/wbem/wmic os",\
                                  "cmd /c tasklist | findstr \"   pwsh   |   blahblah  | services \" ",\
                                 "cmd /c c:\\windows/system32/setx \"ccc ggg\" \"nnn\"",\
                                 "cmd.exe /c tasklist | findstr \"pwsh\"",\
                                 "cmd /c  tasklist.exe | findstr \"blahblah\"",\
                                 "c:/windows\\system32/wusa.exe 'KB54321.msu'",\
                                 "cmd /c findstr \"msxml3\" \"%Programdata%\\winetricks.ps1\"",\
                                 "cmd /c systeminfo |findstr \"   memory   |   version \" ",\
                                 "cmd /c wmic logicaldisk get size,freespace,caption",\
                                 "cmd /c wmic logicaldisk where \"deviceid='c:'\" get freespace",\
                                 "wmic logicaldisk where \"deviceid='c:'\" get freespace",\
                                 "cmd /c wmic logicaldisk where 'deviceid=\"c:\"' get freespace",\
                                 "cmd /c c:\\windows\\system32\\wbem\\wmic.exe logicaldisk where 'deviceid=\"c:\"' get freespace",\
                                 "cmd /c \"\"C:\\windows\\system32\\wbem\\wmic.exe\" logicaldisk\" "\

                               };
                                                             

    for ( i = 0; i < sizeof(commandA)/sizeof(commandA[0]) ; i++) {
        memset( &si, 0, sizeof( STARTUPINFO )); si.cb = sizeof( STARTUPINFO ); memset( &pi, 0, sizeof( PROCESS_INFORMATION ) );
        printf("\033[1;93m"); printf("executing command %s \n", commandA[i]); printf("\033[0m\n");
        CreateProcessA( 0, commandA[i], 0, 0, 0, 0, 0, 0, &si, &pi );
        WaitForSingleObject( pi.hProcess, INFINITE ); GetExitCodeProcess( pi.hProcess, &exitcode ); CloseHandle( pi.hProcess ); CloseHandle( pi.hThread ); 
        printf("\033[1;92m");printf("returning exitcode %d\n", exitcode);printf("\033[0m\n");
   }


 
    return 0;

}