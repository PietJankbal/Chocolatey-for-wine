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

        if (!CopyFileW(L"c:\\windows\\system32\\write.exe", L"c:\\Program Files\\Internet Explorer\\test_app.exe", FALSE)) { MessageBoxW(0,L"copy failed",0,0);}
        if (!CopyFileW(L"c:\\a,b.ps1", L"c:\\Program Files\\Internet Explorer\\file with spaces .txt", FALSE)) { MessageBoxW(0,L"copy failed",0,0);}

    char commandA[][1024]= {
	"powershell \"& {echo hallo}\"",
        "cmd /c powershell -NoLogo -NoProfile -Noninteractive -ExecutionPolicy    Unrestricted -InputFormat   None -Command \"& \"\"\"C:\\a,b.ps1\"\"\" ;  ' -f /f  ff  / f -' |out-null; exit $LastExitCode\"   ",
     //   " powershell -NoLogo -NoProfile -Noninteractive -ExecutionPolicy    Unrestricted -InputFormat   None -Command \"& \"\"\"C:\\a,b.ps1\"\"\" ;\"   ",
        "cmd /c echo \"$(get-date)\" |powershell -nologo -executionpolicy bypass -   ",
        "cmd /c  echo '\"$(get-date)\"' |powershell -nologo -executionpolicy bypass -   ",
        "\"c:\\windows\\syswow64\\WindowsPowershell\\v1.0\\powershell.exe\" -nol \"& \"\"\"c:\\a,b.ps1\"\"\" \"" ,
        "PowerShell      -nol    -executionpolicy   unrestricted   \"& \"\"\"c:\\a,b.ps1\"\"\" \"",
        "powerShell -nol -enc ZQBjAGgAbwAgACIARABvAHIAbwB0AGgAeQAiAA==",
        "powershell /e ZQBjAGgAbwAgACIARABvAHIAbwB0AGgAeQAiAA==",
         "PowerShell -version 4.0 -NoLogo -InputFormat text -OutputFormat Text echo hello",
         "cmd.exe /c powershell < \"\"\"c:\\a,b.ps1\"\"\"",
         "powershell Start-Process powershell -RedirectStandardInput \"\"\"c:\\a,b.ps1\"\"\"  -NoNewWindow -Wait",
      	 "powershell      '\"\"{0} MB\"\"' -f ((Get-ChildItem $env:TMP -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB)",
         //"powershell Start-Process -Verb RunAs -FilePath \"c:\\Program Files\\Internet Explorer\\test_app.exe\"  -ArgumentList  \"c:\\Program Files\\Internet Explorer\\file with spaces.txt\"; Sleep 5; Stop-Process -Name 'test_app'",
         "powershell Start-Process -Verb RunAs -FilePath \"\"\"c:\\Program Files\\Internet Explorer\\test_app.exe\"\"\"  -ArgumentList '\"\"\"c:\\Program Files\\Internet Explorer\\file with spaces .txt\"\"\"' ; Sleep 1.5; Stop-Process -Name 'wordpad'",
         "wmic logicaldisk where \"deviceid='C:'\" get freespace",
         "wmic logicaldisk where 'deviceid=\"C:\"' get freespace",
         "wmic logicaldisk get size, freespace, caption",
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
