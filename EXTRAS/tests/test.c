/*  
 * Compile:
 * i686-w64-mingw32-gcc -municode  -mconsole tests.c -lurlmon -luser32 -s -o tests.exe
 * x86_64-w64-mingw32-gcc -municode  -mconsole tests.c -lurlmon -luser32 -s -o tests.exe
 */
#include <windows.h>
#include <stdio.h>
#include <assert.h>

int __cdecl wmain( int argc, WCHAR *argv[] )
{
   
    STARTUPINFOA si;
    PROCESS_INFORMATION pi;     DWORD exitcode; int i;
 
    FILE *fptr;

    // Open a file in writing mode
    fptr = fopen("c:\\a,b.ps1", "w"); 

    // Write some text to the file
    fprintf(fptr, "echo hello\necho Dorothy");

    // Close the file
    fclose(fptr); 

    char commandA[][1024]= {
		"powershell \"& {echo hallo}\"",
        "cmd /c powershell -NoLogo -NoProfile -Noninteractive -ExecutionPolicy    Unrestricted -InputFormat   None -Command \"& \"\"\"C:\\a,b.ps1\"\"\" ; out-null ' -f /f  ff  / f -'; exit $LastExitCode\"   ",		"cmd /c echo \"$(get-date)\" |powershell -   ",
        "\"c:\\windows\\system32\\WindowsPowershell\\v1.0\\powershell.exe\" -nol \"& \"\"\"c:\\a,b.ps1\"\"\" \"" ,
        "powershell      -nol    -executionpolicy   unrestricted   \"& \"\"\"c:\\a,b.ps1\"\"\" \"",
        "powershell -nol -enc ZQBjAGgAbwAgACIARABvAHIAbwB0AGgAeQAiAA==",
        "powershell /e ZQBjAGgAbwAgACIARABvAHIAbwB0AGgAeQAiAA==",
         "PowerShell -version 4.0 -NoLogo -InputFormat text -OutputFormat Text echo hello",
         "cmd.exe /c powershell < \"\"\"c:\\a,b.ps1\"\"\"",
         "powershell Start-Process powershell -RedirectStandardInput \"\"\"c:\\a,b.ps1\"\"\"  -NoNewWindow -Wait",
	"\"\"\"{0} MB\"\" -f ((Get-ChildItem C:\\windows\\ -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB)\"",

    };
                                                             

    for ( i = 0; i < sizeof(commandA)/sizeof(commandA[0]) ; i++) {
        memset( &si, 0, sizeof( STARTUPINFO )); si.cb = sizeof( STARTUPINFO ); memset( &pi, 0, sizeof( PROCESS_INFORMATION ) );
        printf("\033[1;93m"); printf("executing command %s \n", commandA[i]); printf("\033[0m\n");
        CreateProcessA( 0, commandA[i], 0, 0, 0, 0, 0, 0, &si, &pi );
        WaitForSingleObject( pi.hProcess, INFINITE ); GetExitCodeProcess( pi.hProcess, &exitcode ); CloseHandle( pi.hProcess ); CloseHandle( pi.hThread ); 
        printf("\033[1;92m");printf("returning exitcode %d\n", exitcode);printf("\033[0m\n");
        if( exitcode != 0) { printf("\033[1;91m");printf("test failed!\n", exitcode);printf("\033[0m\n");assert(0);}
   }
 
    return 0;
}
