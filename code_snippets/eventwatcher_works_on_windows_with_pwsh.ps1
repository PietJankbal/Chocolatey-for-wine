#  "System.Management,Version=4.2.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a",

$Assembly = (
   "System.Management",
   "System.Runtime",
   "System.Threading.Thread",
   "System.ComponentModel.Primitives",
   "System.Console"
    )

#Read more: https://www.sharepointdiary.com/2013/07/how-to-run-csharp-code-from-powershell.html#ixzz7PJY8PQfu
$id = get-random

$code = @"
using System;
using System.Management;
using static System.Threading.Thread;
using System.ComponentModel;

namespace HelloWorld
{
	
public class Program$id
 {
  public static void Main(/*string[] args*/)
  {
   //Console.WriteLine("Name");
   string query = "Select * From __InstanceCreationEvent WITHIN 0.1 WHERE TargetInstance Isa 'Win32_Process' and TargetInstance.Name='Notepad.exe'";
   ManagementEventWatcher watcher = new ManagementEventWatcher(query);
   watcher.EventArrived += new EventArrivedEventHandler(HandleEvent);
   watcher.Start();
   System.Threading.Thread.Sleep(200000);
   watcher.Stop();
   //Console.WriteLine("Name");
  }
  static void HandleEvent(object sender, EventArrivedEventArgs e)
  {
   ManagementBaseObject targetInstance = (ManagementBaseObject)e.NewEvent["TargetInstance"];
   Console.WriteLine("Name");
  }
 }
}
"@
#-WarningAction Ignore -IgnoreWarnings 
#"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Management.dll"
Add-Type  -TypeDefinition $code -ReferencedAssemblies $Assembly -Language CSharp -WarningAction Ignore -IgnoreWarnings
iex "[HelloWorld.Program$id]::Main()"