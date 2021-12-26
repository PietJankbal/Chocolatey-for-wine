
$cachedir = ("$env:WINEHOMEDIR" + "\.cache\xtricks").substring(4)

$pwsh70 = ("$env:WINEHOMEDIR" + "\\.cache\\xtricks\\pwsh70").substring(4) 


if (-not( [System.IO.File]::Exists("$pwsh70\\cabextract32.exe") ) ){ 
(New-Object System.Net.WebClient).DownloadFile("https://github.com/PietJankbal/xtricks/raw/main/cabextract32.exe", "$pwsh70\\cabextract32.exe")
}

if (-not( [System.IO.File]::Exists("$pwsh70\\cabextract64.exe") ) ){ 
(New-Object System.Net.WebClient).DownloadFile("https://github.com/PietJankbal/xtricks/raw/main/cabextract64.exe", "$pwsh70\\cabextract64.exe")
}

Copy-Item -force "$pwsh70\\cabextract32.exe" $env:systemroot\\syswow64\\cabextract.exe
Copy-Item -force "$pwsh70\\cabextract64.exe" $env:systemroot\\system32\\cabextract.exe

#We need 7zip
$pwsh70 = ("$env:WINEHOMEDIR" + "\\.cache\\xtricks\\pwsh70").substring(4) 
$7zpath = ("$env:WINEHOMEDIR" + "\\.cache\\xtricks\\7z").substring(4) 
$7zpath
#if (-not(Test-Path "$pwsh70\\7z1900-x64.exe" -PathType Leaf)){ 
if (-not( [System.IO.File]::Exists("$pwsh70\\7z1900-x64.exe") ) ){ 
Write-Host 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
(New-Object System.Net.WebClient).DownloadFile("https://www.7-zip.org/a/7z1900-x64.exe", "$pwsh70\\7z1900-x64.exe")

}

if (-not(Test-Path "$7zpath\\7z.exe" -PathType Leaf)){ 

#(New-Object System.Net.WebClient).DownloadFile("https://www.7-zip.org/a/7z1900-x64.exe", "$pwsh70\\7z1900-x64.exe")
Start-Process -FilePath "$pwsh70\\7z1900-x64.exe" -Wait -ArgumentList "/S","/D=$7zpath\\"
}





$custom_array = @() ### Creating an empty array to populate data in

[array]$Qenu = "adk70","dffffsssssssssffffffff",`
               "msxml3","aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",`
	       "ie10","fdfsdfsdf",`
	       "ie11","fllllll",`
               "msado15","msado15 + msdart",`
               "msado15_vista","vista",`               
               "findstr","jhafkjd",`
               "robocopy","sdas"
#[array]$desc = 

if($args.count -ne 0){

write-host "Qhere are a total of $($args.count) arguments"
[int] $correctargs =0;
for ( $i = 0; $i -lt $args.count; $i++ ) {
    write-host "Argument  $i is $($args[$i])"
Write-Host hhh is $Qenu.count
#Validate
for ( $j = 0; $j -lt $Qenu.count; $j+=2 ) { if($($args[$i]) -eq $Qenu[$j]) {Write-Host "correct arg"; $correctargs++; break;} else{Write-Host "wrong arg!!";} }
   
} 
if($correctargs -ne $args.count){Write-Host ERROR!!; exit}
}


for ( $j = 0; $j -lt $Qenu.count; $j+=2 )
{ 
 

    $custom_array += New-Object PSObject -Property @{     ### Setting up custom array utilizing a PSObject
 
   name = $Qenu[$j]  
    Description = $Qenu[$j+1]

    }
}



[System.IO.Directory]::CreateDirectory('c:\\rommel')



function func_devenum
{
Write-Host 'Do something'
w_download_to "win7sp1" "http://download.windowsupdate.com/msdownload/update/software/svpk/2011/02/windows6.1-kb976932-x86_c3516bc5c9e69fee6d9ac4f981f5b95977a8a2fa.exe" "windows6.1-KB976932-X64.exe"
Start-Process ${env:ProgramFiles}\\7-zip\\7z.exe  -ArgumentList "x","-r","$env:TEMP\\winpe64.wim","-aou","-o$env:SystemDrive","Windows"
}


function 7zcabhelper
{
Param ($extractfrom, $extractto, $file, $destdir)
Start-Process <#-Windowstyle hidden#> $7zpath\\7z.exe  -ArgumentList "x","-r",$extractfrom,"-aoa","-o$env:TEMP",$extractto 
Get-Process 7z | Foreach-Object { $_.WaitForExit() }
expand.exe $env:TEMP\\$extractto $env:TEMP\\amd64/wow/$file
Move-Item -force $env:TEMP\\amd64/wow/$file $destdir\\$file
#TODO remove stuff from temp
}






    Function copy_from_manifest{
    Param ($filetoget, $dldir)

   #$filetoget = 


    #$relativePath = Get-Item $amd64_or_wow64_*\$filetoget | Resolve-Path -Relative
    $relativePath = $filetoget #Resolve-Path  ($amd64_or_wow64 + "_*\$filetoget") -Relative #; if (-not ($relativePath)) {Write-Host "empty path for $amd64_or_wow64 $filetoget"; continue}
    $manifest = $relativePath.split('/')[0] + ".manifest"
    $file_name = $relativePath.split('/')[1]
    
    $Xml = [xml](Get-Content -Path "$(Join-Path $cachedir $dldir)\$manifest")
    #copy files from manifest
#    foreach ($file in  $Xml.assembly.file) {
#    $destpath = '{0}' -f $file.destinationpath
#    $filename = '{0}' -f $file.name

    # $Xml.assembly.file | Where-Object -Property name -eq -Value "profile.ps1"
      $select= $Xml.assembly.file | Where-Object -Property name -eq -Value $file_name
      $destpath = $select.destinationpath  
      #HACKKKK         #$filename = $select.name                multiple cases:     {$_ -in 'wow', 'x86'}
      if ($destpath) {
          switch ( $manifest.SubString(0,3) ) {
              'amd' { $finalpath = $destpath -replace ([Regex]::Escape('$(runtime.system32)')),"$env:systemroot\\system32"
	              $finalpath = $finalpath -replace ([Regex]::Escape('$(runtime.programFiles)')),"$env:ProgramFiles" 
		      $finalpath = $finalpath -replace ([Regex]::Escape('$(runtime.wbem)')),"$env:systemroot\\system32\\wbem"
 		      $finalpath = $finalpath -replace ([Regex]::Escape('$(runtime.commonFiles)')),"$env:CommonProgramFiles"}
              {$_ -in 'wow', 'x86'} { $finalpath = $destpath -replace ([Regex]::Escape('$(runtime.system32)')),"$env:systemroot\\syswow64"
	              $finalpath = $finalpath -replace ([Regex]::Escape('$(runtime.programFiles)')),"${env:ProgramFiles`(x86`)}" 
Write-Host x86 is equal to "${env:ProgramFiles`(x86`)}";
		      $finalpath = $finalpath -replace ([Regex]::Escape('$(runtime.wbem)')),"$env:systemroot\\syswow64\\wbem"
 		      $finalpath = $finalpath -replace ([Regex]::Escape('$(runtime.commonFiles)')),"${env:CommonProgramFiles`(x86`)}"}
	      'msi' { $finalpath = $destpath -replace ([Regex]::Escape('$(runtime.system32)')),"$env:systemroot\\system32"  }#????
          }
          $finalpath = $finalpath -replace ([Regex]::Escape('$(runtime.windows)')),"$env:systemroot"
          #$(runtime.programFiles)  $(runtime.wbem)

          if (-not (Test-Path -Path $finalpath )) {
              New-Item -Path $finalpath -ItemType directory -Force
	  }
          Write-Host finalpath is $finalpath
          Write-Host filetoget is $filetoget is
          Copy-Item -Path "$(Join-Path $cachedir $dldir)\\$filetoget" -Destination $finalpath -Force
      }
      else {  #HACK where should these files go to??
           Write-Host "possible error! destpath is null for $manifest"
	   Copy-Item -Path $filetoget -Destination "$env:systemdrive\\ConEmu" -Force #to track
	   Copy-Item -Path $filetoget -Destination "$env:systemroot\\syswow64\\WindowsPowerShell\\v1.0" -Force	   
	   Copy-Item -Path $filetoget -Destination "$env:systemroot\\system32\\WindowsPowerShell\\v1.0" -Force
	   
	   $MSILTOKEN=$Xml.assembly.assemblyIdentity.publicKeyToken #  = 31bf3856ad364e35 | Where-Object -Property name -eq -Value $file_name
           Write-Host msiltoken is "$MSILTOKEN" 
           $DIRNAME=$Xml.assembly.assemblyIdentity.name #System.Managment.Automation
	    Write-Host dirname is "$DIRNAME" 
          #C:\windows\assembly\GAC_MSIL\System.Management.Automation\1.0.0.0__31bf3856ad364e35"C:\windows\assembly\GAC_MSIL\System.Manageent.Automation\1.0.0.0__31bf3856ad364e35
           $ABSPATH= "$env:systemroot\assembly\GAC_MSIL\" + "$DIRNAME\1.0.0.0__" +"$MSILTOKEN"
           Write-Host ABSPATH is "$ABSPATH"
          if (-not (Test-Path -Path "$ABSPATH" )) { New-Item -Path "$ABSPATH" -ItemType directory -Force}
	  
	   Copy-Item -Path $filetoget -Destination "$ABSPATH" -Force
	      
	   
      }
 }

    


    Function write_keys_from_manifest{
    Param ($filetoget, $dldir)

   #$filetoget = 


    #$relativePath = Get-Item $amd64_or_wow64_*\$filetoget | Resolve-Path -Relative
    $relativePath = $filetoget #Resolve-Path  ($amd64_or_wow64 + "_*\$filetoget") -Relative #; if (-not ($relativePath)) {Write-Host "empty path for $amd64_or_wow64 $filetoget"; continue}
    $manifest = $relativePath.split('/')[0] + ".manifest"
    $file_name = $relativePath.split('/')[1]
    
    $Xml = [xml](Get-Content -Path "$(Join-Path $cachedir $dldir)\$manifest")
 
      #try write regkeys from manifest file
   #thanks some guy from freenode webchat channel powershell who wrote skeleton of this in 4 minutes...
   foreach ($key in $Xml.assembly.registryKeys.registryKey) {
    $path = 'Registry::{0}' -f $key.keyName
    
    
        #if($manifest.SubString(0,3) -eq 'wow')
	 switch ( $manifest.SubString(0,3) ) {
	 {$_ -in 'wow', 'x86'}  {$path = $path -replace 'HKEY_LOCAL_MACHINE\\SOFTWARE','HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node'
                                 $path = $path -replace 'HKEY_CLASSES_ROOT','HKEY_CLASSES_ROOT\Wow6432Node'}
	 default                {}			 
         }
	 
    if (-not (Test-Path -Path $path)) {
        New-Item -Path $path -ItemType Key -Force
    }

    foreach ($value in $key.registryValue) {
        $propertyType = switch ($value.valueType) {
            'REG_SZ'         { 'String' }
            'REG_BINARY'     { 'Binary' }
            'REG_DWORD'      { 'DWORD'  }
	    'REG_EXPAND_SZ'  { 'ExpandString' } 
	    'REG_MULTI_SZ'   { 'MultiString'  } 
	    'REG_QWORD'      { 'QWord' }
            'REG_NONE'       { '' } 
        }
        $Regname = switch ($value.Name) {
            '' { ‘(Default)’ }
            default { $value.Name }
        }
        #If ($propertyType -eq "Binary") { $value.Value = [System.Text.Encoding]::Unicode.GetBytes($value.Value + "000") ; $value.Value.Replace(" ",",")}
        #https://stackoverflow.com/questions/54543075/how-to-convert-a-hash-string-to-byte-array-in-powershell
        If ($propertyType -eq "Binary") {$hashByteArray = [byte[]] ($value.Value -replace '..', '0x$&,' -split ',' -ne '');New-ItemProperty -Path $path -Name $Regname -Value $hashByteArray  -PropertyType $propertyType -Force}
        else{
	
	
	   switch ( $manifest.SubString(0,3) )
           {
	             'amd' { $value.Value = $value.Value -replace ([Regex]::Escape('$(runtime.system32)')),"$env:systemroot\\system32"
	              $value.Value = $value.Value -replace ([Regex]::Escape('$(runtime.programFiles)')),"$env:ProgramFiles"
                      $finalpath = $finalpath -replace ([Regex]::Escape('$(runtime.commonFiles)')),"$env:CommonProgramFiles"
		      $value.Value = $value.Value -replace ([Regex]::Escape('$(runtime.wbem)')),"$env:systemroot\\system32\\wbem"}
               {$_ -in 'wow', 'x86'} { $value.Value = $value.Value -replace ([Regex]::Escape('$(runtime.system32)')),"$env:systemroot\\syswow64"
	              $value.Value = $value.Value -replace ([Regex]::Escape('$(runtime.programFiles)')),"${env:ProgramFiles`(x86`)}"
                      $finalpath = $finalpath -replace ([Regex]::Escape('$(runtime.commonFiles)')),"${env:CommonProgramFiles`(x86`)}"
		      $value.Value = $value.Value -replace ([Regex]::Escape('$(runtime.wbem)')),"$env:systemroot\\syswow64\\wbem"}
	   
           #    'amd' {  $value.Value = $value.Value -replace ([Regex]::Escape('$(runtime.system32)')),"$env:systemroot\system32"  }
           #     {$_ -in 'wow', 'x86'} {  $value.Value = $value.Value -replace ([Regex]::Escape('$(runtime.system32)')),"$env:systemroot\syswow64" }

           }
	   $value.Value = $value.Value -replace ([Regex]::Escape('$(runtime.windows)')),"$env:systemroot"
        #$value.Value = $value.Value -replace ([Regex]::Escape('$(runtime.system32)')),"$env:systemroot\$runtime_system32" #????syswow64??

        New-ItemProperty -Path $path -Name $Regname -Value $value.Value -PropertyType $propertyType -Force}
# }#end if($manifest.SubString(0,3) -ne 'msi')
}
}

}  


 
function w_download_to
{
Param ($cachepath, $w_url, $w_file) # $w_sum

$path = "$env:WINEHOMEDIR" + "\\.cache\\xtricks\\$cachepath" #$cachepath = win7sp1
$path.substring(4) 
#if (-not(Test-Path $path.substring(4) -PathType Container)){ New-Item -Path $path.substring(4) -ItemType "directory"}
if (![System.IO.Directory]::Exists($path.substring(4))){ [System.IO.Directory]::CreateDirectory($path.substring(4))}

$f = $path.substring(4) + "\\$w_file"
if (-not(Test-Path $f -PathType Leaf)){
(New-Object System.Net.WebClient).DownloadFile($w_url, $f)}
}





function helper_win7sp2()
{
 Param ($filename,  $packagename, $msuname, $cabname,$url) 

# Param ($file,  $dldir, $cabname, $url) 
#http://download.windowsupdate.com/d/msdownload/update/software/updt/2016/05/windows6.1-kb3125574-v4-x64_2dafb1d203c8964239af3048b5dd4b1264cd93b9.msu

#function w_download_to

#Param ($cachepath, $w_url, $w_file, $w_sum)

Write-Host join is $(Join-Path  $cachedir  $packagename  $msuname)


$(Join-Path $cachedir $cabname)
$(Join-Path $cachedir $packagename)
$cabname  

Write-Host cab is $(Join-Path  $cachedir  $packagename  $cabname   ) 



Write-Host extract from $(Join-Path $cachedir $packagename $msuname)
Write-Host to ..  $(Join-Path $cachedir $packagename)
Write-Host following $cabname  

$extracdir = [IO.Path]::Combine($cachedir, $packagename, $msuname)
$extracdir 

    
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'cabinet' -Value 'native' -PropertyType 'String'
    New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'expand.exe' -Value 'native' -PropertyType 'String'
    $file = [IO.Path]::GetFileName($filename)
    Write-Host file is $file
    if (![System.IO.File]::Exists("$(Join-Path $(Join-Path $cachedir $dldir) $filename )")  ){

    if (![System.IO.File]::Exists(  $(Join-Path  $cachedir  $packagename  $cabname) ) ) {

w_download_to $packagename $url $msuname
Start-Process cabextract -argumentlist "-d", "$(Join-Path $cachedir $packagename)" ,"$(Join-Path $cachedir $packagename $msuname)"
Get-Process cabextract | Foreach-Object { $_.WaitForExit() }
    }
    else{
            echo "Windows6.1-KB3125574-v4-x64.cab exists, skipping cabextract ...."
    }


    expand.exe $(Join-Path $cachedir $packagename $cabname) -f:$file $(Join-Path $cachedir $dldir)}
#    Copy-Item -force $(Join-Path $(Join-Path $cachedir $dldir) $filename) $destdir
#Also extract manifest
    $manifest = $filename.split('/')[0] + ".manifest"
    Write-Host manifest is $manifest

    if (![System.IO.File]::Exists("$(Join-Path $(Join-Path $cachedir $dldir) $manifest )")  ){

    if (![System.IO.File]::Exists(  $(Join-Path  $cachedir  $packagename  $cabname) ) ) {

w_download_to $packagename $url $msuname
Start-Process cabextract -argumentlist "-d", "$(Join-Path $cachedir $packagename)" ,"$(Join-Path $cachedir $packagename $msuname)"
Get-Process cabextract | Foreach-Object { $_.WaitForExit() }
    }
    else{
            echo "Windows6.1-KB3125574-v4-x64.cab exists, skipping cabextract ...."
    }


    expand.exe $(Join-Path $cachedir $packagename $cabname) -f:$manifest $(Join-Path $cachedir $dldir)}

}









function func_msxml3
{   func_adk81
    $url = "http://download.windowsupdate.com/d/msdownload/update/software/updt/2016/05/windows6.1-kb3125574-v4-x64_2dafb1d203c8964239af3048b5dd4b1264cd93b9.msu"
    $cab = "Windows6.1-KB3125574-v4-x64.cab"

    $sourcefile = @(`
    'amd64_netfx-microsoft.build.engine_b03f5f7f11d50a3a_6.1.7601.23403_none_eb61a48372b359fd/microsoft.build.engine.dll',`
    'wow64_microsoft-windows-msxml30_31bf3856ad364e35_6.1.7601.23403_none_f17c2b6cfaed11ee/msxml3r.dll',`
    'amd64_microsoft-windows-msxml30_31bf3856ad364e35_6.1.7601.23403_none_e727811ac68c4ff3/msxml3r.dll',`
    'amd64_microsoft-windows-msxml30_31bf3856ad364e35_6.1.7601.23403_none_e727811ac68c4ff3/msxml3.dll',`
    'wow64_microsoft-windows-msxml30_31bf3856ad364e35_6.1.7601.23403_none_f17c2b6cfaed11ee/msxml3.dll'`
    )

    $msu = $url.split('/')[-1] #-1 is last array element...
    $dldir = $($url.split('/')[-1]) -replace '.msu',''

    #w_download_to $dldir $url $msu
    foreach ($i in $sourcefile) {
        helper_win7sp2 $i $dldir $msu $cab $url
        copy_from_manifest $i $dldir
        write_keys_from_manifest $i $dldir
    }
}





function helper_win7sp1()
{
 Param ($file,  $dldir, $cabname, $url) 

    #$file = $filename
    Write-Host file is $file
    if (![System.IO.File]::Exists("$(Join-Path $(Join-Path $cachedir $dldir) $file )")  ){
        w_download_to $dldir $url $cabname
        cabextract -F $file -d $(Join-Path $cachedir $dldir) $(Join-Path $cachedir $dldir $cabname) }

    #Also extract manifest
    $manifest = $file.split('/')[0] + ".manifest"
    Write-Host manifest is $manifest

    if (![System.IO.File]::Exists("$(Join-Path $(Join-Path $cachedir $dldir) $manifest )")  ){
    w_download_to $dldir $url $cabname
    cabextract -F $manifest -d $(Join-Path $cachedir $dldir) $(Join-Path $cachedir $dldir $cabname) }

}




function func_ie10
{   func_adk81
    $url = "https://download.microsoft.com/download/E/7/F/E7F5E0D8-F9DE-4195-9627-A7F884B61686/IE10-Windows6.1-KB2859903-x64.msu"
    $cab = "IE10-Windows6.1-KB2859903-x64.cab"

    $sourcefile = @(`
'amd64_microsoft-windows-ieframe_31bf3856ad364e35_10.2.9200.16618_none_e26f96861e9c5d0d/ieframe.dll',`
'amd64_microsoft-windows-ieframe_31bf3856ad364e35_10.2.9200.16618_none_e26f96861e9c5d0d/ieframe.ptxml',`
'amd64_microsoft-windows-ieframe_31bf3856ad364e35_10.2.9200.16618_none_e26f96861e9c5d0d/ieui.dll',`
'amd64_microsoft-windows-ieframe_31bf3856ad364e35_10.2.9200.20723_none_cb989230384a71e5/ieframe.dll',`
'amd64_microsoft-windows-ieframe_31bf3856ad364e35_10.2.9200.20723_none_cb989230384a71e5/ieframe.ptxml',`
'amd64_microsoft-windows-ieframe_31bf3856ad364e35_10.2.9200.20723_none_cb989230384a71e5/ieui.dll',`
'amd64_microsoft-windows-ie-htmlrendering_31bf3856ad364e35_10.2.9200.16618_none_91103c8292a6cee0/microsoft-windows-ie-htmlrendering.ptxml',`
'amd64_microsoft-windows-ie-htmlrendering_31bf3856ad364e35_10.2.9200.16618_none_91103c8292a6cee0/mshtml.dll',`
'amd64_microsoft-windows-ie-htmlrendering_31bf3856ad364e35_10.2.9200.16618_none_91103c8292a6cee0/mshtml.tlb',`
'amd64_microsoft-windows-ie-htmlrendering_31bf3856ad364e35_10.2.9200.20723_none_7a39382cac54e3b8/microsoft-windows-ie-htmlrendering.ptxml',`
'amd64_microsoft-windows-ie-htmlrendering_31bf3856ad364e35_10.2.9200.20723_none_7a39382cac54e3b8/mshtml.dll',`
'amd64_microsoft-windows-ie-htmlrendering_31bf3856ad364e35_10.2.9200.20723_none_7a39382cac54e3b8/mshtml.tlb',`
'amd64_microsoft-windows-i..ersandsecurityzones_31bf3856ad364e35_10.2.9200.16618_none_32b041c247473f17/urlmon.dll',`
'amd64_microsoft-windows-i..ersandsecurityzones_31bf3856ad364e35_10.2.9200.20723_none_1bd93d6c60f553ef/urlmon.dll',`
'amd64_microsoft-windows-ie-runtimeutilities_31bf3856ad364e35_10.2.9200.16618_none_c570d43ffd018407/iertutil.dll',`
'amd64_microsoft-windows-ie-runtimeutilities_31bf3856ad364e35_10.2.9200.16618_none_c570d43ffd018407/sqmapi.dll',`
'amd64_microsoft-windows-ie-runtimeutilities_31bf3856ad364e35_10.2.9200.20723_none_ae99cfea16af98df/iertutil.dll',`
'amd64_microsoft-windows-ie-runtimeutilities_31bf3856ad364e35_10.2.9200.20723_none_ae99cfea16af98df/sqmapi.dll',`
'wow64_microsoft-windows-ieframe_31bf3856ad364e35_10.2.9200.16618_none_ecc440d852fd1f08/ie9props.propdesc',`
'wow64_microsoft-windows-ieframe_31bf3856ad364e35_10.2.9200.16618_none_ecc440d852fd1f08/ieframe.dll',`
'wow64_microsoft-windows-ieframe_31bf3856ad364e35_10.2.9200.16618_none_ecc440d852fd1f08/ieui.dll',`
'wow64_microsoft-windows-ieframe_31bf3856ad364e35_10.2.9200.16618_none_ecc440d852fd1f08/wow64_ieframe.ptxml',`
'wow64_microsoft-windows-ieframe_31bf3856ad364e35_10.2.9200.20723_none_d5ed3c826cab33e0/ie9props.propdesc',`
'wow64_microsoft-windows-ieframe_31bf3856ad364e35_10.2.9200.20723_none_d5ed3c826cab33e0/ieframe.dll',`
'wow64_microsoft-windows-ieframe_31bf3856ad364e35_10.2.9200.20723_none_d5ed3c826cab33e0/ieui.dll',`
'wow64_microsoft-windows-ieframe_31bf3856ad364e35_10.2.9200.20723_none_d5ed3c826cab33e0/wow64_ieframe.ptxml',`
'wow64_microsoft-windows-ie-htmlrendering_31bf3856ad364e35_10.2.9200.16618_none_9b64e6d4c70790db/mshtml.dll',`
'wow64_microsoft-windows-ie-htmlrendering_31bf3856ad364e35_10.2.9200.16618_none_9b64e6d4c70790db/mshtml.tlb',`
'wow64_microsoft-windows-ie-htmlrendering_31bf3856ad364e35_10.2.9200.16618_none_9b64e6d4c70790db/wow64_microsoft-windows-ie-htmlrendering.ptxml',`
'wow64_microsoft-windows-ie-htmlrendering_31bf3856ad364e35_10.2.9200.20723_none_848de27ee0b5a5b3/mshtml.dll',`
'wow64_microsoft-windows-ie-htmlrendering_31bf3856ad364e35_10.2.9200.20723_none_848de27ee0b5a5b3/mshtml.tlb',`
'wow64_microsoft-windows-ie-htmlrendering_31bf3856ad364e35_10.2.9200.20723_none_848de27ee0b5a5b3/wow64_microsoft-windows-ie-htmlrendering.ptxml',`
'x86_microsoft-windows-i..ersandsecurityzones_31bf3856ad364e35_10.2.9200.16618_none_d691a63e8ee9cde1/urlmon.dll',`
'x86_microsoft-windows-i..ersandsecurityzones_31bf3856ad364e35_10.2.9200.20723_none_bfbaa1e8a897e2b9/urlmon.dll',`
'x86_microsoft-windows-ie-runtimeutilities_31bf3856ad364e35_10.2.9200.16618_none_695238bc44a412d1/iertutil.dll',`
'x86_microsoft-windows-ie-runtimeutilities_31bf3856ad364e35_10.2.9200.16618_none_695238bc44a412d1/sqmapi.dll',`
'x86_microsoft-windows-ie-runtimeutilities_31bf3856ad364e35_10.2.9200.20723_none_527b34665e5227a9/iertutil.dll',`
'x86_microsoft-windows-ie-runtimeutilities_31bf3856ad364e35_10.2.9200.20723_none_527b34665e5227a9/sqmapi.dll'`
)

    $msu = $url.split('/')[-1] #-1 is last array element...
    $dldir = $($url.split('/')[-1]) -replace '.msu',''

    #w_download_to $dldir $url $msu
    foreach ($i in $sourcefile) {
        helper_win7sp2 $i $dldir $msu $cab $url
        copy_from_manifest $i $dldir
       # write_keys_from_manifest $i $dldir
    }
        New-Item -Path 'HKLM:\\Software\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Internet Settings\\Lockdown_Zones'
    New-Item -Path 'HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings\\Lockdown_Zones'

    New-Item -Path 'HKLM:\\Software\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Internet Settings\\Lockdown_Zones\\0'
    New-Item -Path 'HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings\\Lockdown_Zones\\0'
}






function func_findstr
{
    $url = "http://download.windowsupdate.com/msdownload/update/software/svpk/2011/02/windows6.1-kb976932-x64_74865ef2562006e51d7f9333b4a8d45b7a749dab.exe"
    #$cab = "windows6.1-kb976932-x64_74865ef2562006e51d7f9333b4a8d45b7a749dab.cab"

    $sourcefile = @(`
    'amd64_microsoft-windows-findstr_31bf3856ad364e35_6.1.7601.17514_none_855590d1705431c5/findstr.exe',`
    'x86_microsoft-windows-findstr_31bf3856ad364e35_6.1.7601.17514_none_2936f54db7f6c08f/findstr.exe'`
    )

    $cab = $url.split('/')[-1] -replace ".exe",".cab" #-1 is last array element...
    $dldir = $($url.split('/')[-1]) -replace '.exe',''


    foreach ($i in $sourcefile) {
        helper_win7sp1 $i $dldir $cab $url
        copy_from_manifest $i $dldir
        write_keys_from_manifest $i $dldir
    }
}

function func_ie11
{
    $url = "http://download.microsoft.com/download/7/1/7/7179A150-F2D2-4502-9D70-4B59EA148EAA/IE11-Windows6.1-x64-en-us.exe"


    $sourcefile = @(`
    'wow64_microsoft-windows-ie-htmlrendering_31bf3856ad364e35_11.2.9600.16428_none_ffeecffc6b986ebd/mshtml.dll',`
    'amd64_microsoft-windows-ie-htmlrendering_31bf3856ad364e35_11.2.9600.16428_none_f59a25aa3737acc2/mshtml.dll',`
    'wow64_microsoft-windows-i..etexplorer-optional_31bf3856ad364e35_11.2.9600.16428_none_856219b9f734bb75/iexplore.exe',`
    'amd64_microsoft-windows-i..etexplorer-optional_31bf3856ad364e35_11.2.9600.16428_none_7b0d6f67c2d3f97a/iexplore.exe'`
    )

    $cab = $url.split('/')[-1] -replace ".exe",".cab" #-1 is last array element...
    $dldir = $($url.split('/')[-1]) -replace '.exe',''


    foreach ($i in $sourcefile) {
        helper_win7sp1 $i $dldir $cab $url
        copy_from_manifest $i $dldir
        write_keys_from_manifest $i $dldir
    }
}

function func_robocopy
{
    $url = "http://www.download.windowsupdate.com/msdownload/update/software/svpk/2008/04/windows6.0-kb936330-x64_12eed6cf0a842ce2a609c622b843afc289a8f4b9.exe"
    #$cab = "windows6.0-kb936330-x64_12eed6cf0a842ce2a609c622b843afc289a8f4b9.exe"

    $sourcefile = @(`
    'amd64_microsoft-windows-robocopy_31bf3856ad364e35_6.0.6001.18000_none_2325cb04a4c1adef/robocopy.exe',`
    'x86_microsoft-windows-robocopy_31bf3856ad364e35_6.0.6001.18000_none_c7072f80ec643cb9/robocopy.exe',`
    'amd64_microsoft-windows-mfc42x_31bf3856ad364e35_6.0.6001.18000_none_4f3369c50dec2a50/mfc42u.dll',`
    'x86_microsoft-windows-mfc42x_31bf3856ad364e35_6.0.6001.18000_none_f314ce41558eb91a/mfc42u.dll'`
    )

    $cab = $url.split('/')[-1] -replace ".exe",".cab" #-1 is last array element...
    $dldir = $($url.split('/')[-1]) -replace '.exe',''

    #w_download_to $dldir $url $cab
    foreach ($i in $sourcefile) {
        helper_win7sp1 $i $dldir $cab $url
        copy_from_manifest $i $dldir
        write_keys_from_manifest $i $dldir
    }
}



function func_msado15_vista
{    
    $url = "http://www.download.windowsupdate.com/msdownload/update/software/svpk/2008/04/windows6.0-kb936330-x64_12eed6cf0a842ce2a609c622b843afc289a8f4b9.exe"
    #$cab = "windows6.0-kb936330-x64_12eed6cf0a842ce2a609c622b843afc289a8f4b9.exe"

    $sourcefile = @(`
    'x86_microsoft-windows-m..ponents-mdac-msdart_31bf3856ad364e35_6.0.6001.18000_none_e61259980ba2cf16/msdart.dll',`
    'amd64_microsoft-windows-m..ponents-mdac-msdart_31bf3856ad364e35_6.0.6001.18000_none_4230f51bc400404c/msdart.dll',`
    'x86_microsoft-windows-m..ents-mdac-ado15-dll_31bf3856ad364e35_6.0.6001.18000_none_0c30e28670a6b0d6/msado15.dll',`
    'amd64_microsoft-windows-m..ents-mdac-ado15-dll_31bf3856ad364e35_6.0.6001.18000_none_684f7e0a2904220c/msado15.dll'`
    )

    $cab = $url.split('/')[-1] -replace ".exe",".cab" #-1 is last array element...
    $dldir = $($url.split('/')[-1]) -replace '.exe',''

    #w_download_to $dldir $url $cab
    foreach ($i in $sourcefile) {
        helper_win7sp1 $i $dldir $cab $url
        copy_from_manifest $i $dldir
        write_keys_from_manifest $i $dldir
    }
}

#   Remove-Item -Recurse "$env:TEMP\\amd64_*"  ; Remove-Item -Recurse "$env:TEMP\\wow64_*" ; Remove-Item -Recurse "$env:TEMP\\msil*"  ; Remove-Item -Recurse "$env:TEMP\\x86*"


#exit



#func_aclui



function func_msado15
{
Write-Host 'Installing msado15...'
$cab = "windowsserver2003.windowsxp-kb914961-sp2-x64-enu_7f8e909c52d23ac8b5dbfd73f1f12d3ee0fe794c.exe" #$zipName = [IO.Path]::GetFileNameWithoutExtension($url)
$dldir = "win2k3sp2"
$url = "http://www.download.windowsupdate.com/msdownload/update/v3-19990518/cabpool/$cab"
w_download_to $dldir $url $cab

7zcabhelper $cachedir\\$dldir\\$cab amd64/wow/wmsdart.dl_ msdart.dll $env:SystemRoot\\syswow64

7zcabhelper $cachedir\\$dldir\\$cab amd64/msdart.dl_ msdart.dll $env:SystemRoot\\system32

7zcabhelper $cachedir\\$dldir\\$cab amd64/wow/wmsado15.dl_ msado15.dll ${env:CommonProgramFiles`(x86`)}\\System\\ADO

7zcabhelper $cachedir\\$dldir\\$cab amd64/msado15.dl_ msado15.dll $env:CommonProgramFiles\\System\\ADO

New-ItemProperty -Path 'HKCU:\\Software\\Wine\\DllOverrides' -force -Name 'msado15' -Value 'native' -PropertyType 'String'

& "$env:systemroot\\system32\\regsvr32" "$env:CommonProgramFiles\\System\\ADO\\msado15.dll"

& "$env:systemroot\\syswow64\\regsvr32"  "${env:CommonProgramFiles`(x86`)}\\System\\ADO\\msado15.dll"

Add-Type -AssemblyName PresentationCore,PresentationFramework; [System.Windows.MessageBox]::Show('msado15 installed','Congrats','ok','exclamation')


}

function func_adk70
{
Write-Host 'Installing adk...'
$cab = "KB3AIK_EN.iso"
$dldir = "adk70"
$url = "https://download.microsoft.com/download/8/E/9/8E9BBC64-E6F8-457C-9B8D-F6C9A16E6D6A/$cab"
w_download_to $dldir $url $cab

if ( -not(Test-Path $cachedir\\$dldir\\WinPE.cab -PathType Leaf) ){
    Start-Process <#-Windowstyle hidden#> $7zpath\\7z.exe  -ArgumentList "x",$cachedir\\$dldir\\$cab,"-o$cachedir\\$dldir" #\\*.cab"
   }
Get-Process 7z -ErrorAction:SilentlyContinue | Foreach-Object { $_.WaitForExit() }

if ( -not(Test-Path $cachedir\\$dldir\\F1_WINPE.WIM -PathType Leaf) ){
    Start-Process <#-Windowstyle hidden#> $7zpath\\7z.exe  -ArgumentList "x",$cachedir\\$dldir\\WinPE.cab,"-o$cachedir\\$dldir"
   }
Get-Process 7z -ErrorAction:SilentlyContinue | Foreach-Object { $_.WaitForExit() }

if ( -not(Test-Path $cachedir\\$dldir\\F_WINPEOC_AMD64__WINPE_WINPE_MDAC.CAB -PathType Leaf) ){
    Start-Process <#-Windowstyle hidden#> $7zpath\\7z.exe  -ArgumentList "x",$cachedir\\$dldir\\Neutral.cab,"-o$cachedir\\$dldir\\","F_WINPEOC_AMD64__WINPE_WINPE_MDAC.CAB"
   }
Get-Process 7z -ErrorAction:SilentlyContinue | Foreach-Object { $_.WaitForExit() }



$adkdlls = @('expand.exe','dpx.dll','cabinet.dll','msdelta.dll','riched20.dll','riched32.dll','msxml3.dll','msxml3r.dll','msxml6r.dll','msxml6r.dll' )

    foreach ($i in $adkdlls) {

Start-Process <#-Windowstyle hidden#> $7zpath\\7z.exe  -ArgumentList "e",$cachedir\\$dldir\\F3_WINPE.WIM,"-o$env:systemroot\\system32",Windows/System32/$i,"-y"
Start-Process <#-Windowstyle hidden#> $7zpath\\7z.exe  -ArgumentList "e",$cachedir\\$dldir\\F1_WINPE.WIM,"-o$env:systemroot\\syswow64",Windows/System32/$i,"-y"
Get-Process 7z -ErrorAction:SilentlyContinue | Foreach-Object { $_.WaitForExit() }


$sxsdlls = @( 'amd64_microsoft.windows.gdiplus_6595b64144ccf1df_1.0.7600.16385_none_3bfdd703d890231d/gdiplus.dll', `
              'x86_microsoft.windows.gdiplus_6595b64144ccf1df_1.0.7600.16385_none_83ab0ddaed0c4c23/gdiplus.dll')

    foreach ($i in $sxsdlls) {
#Write-Host $("x86" + $i.substring(5))
#exit
switch ( $i.SubString(0,3) ) {
    'amd'    {Start-Process <#-Windowstyle hidden#> $7zpath\\7z.exe  -ArgumentList "e",$cachedir\\$dldir\\F3_WINPE.WIM,"-o$env:systemroot\\system32",Windows/winsxs/$i,"-y"}
    'x86'    {Start-Process <#-Windowstyle hidden#> $7zpath\\7z.exe  -ArgumentList "e",$cachedir\\$dldir\\F1_WINPE.WIM,"-o$env:systemroot\\syswow64",Windows/winsxs/$i,"-y"}
}
#x86_microsoft.windows.gdiplus_6595b64144ccf1df_1.0.7600.16385_none_83ab0ddaed0c4c23/GdiPlus.dll
Get-Process 7z -ErrorAction:SilentlyContinue | Foreach-Object { $_.WaitForExit() }
  }

#Copy-Item -force $env:TEMP\\Windows\\System32\\$i $env:systemroot\\system32\\$i
#Copy-Item -force $env:TEMP\\$i $env:systemroot\\syswow64\\$i
#Remove-Item -Recurse "$env:TEMP\\Windows*"  ; Remove-Item -Recurse "$env:TEMP\\$i" 

}




Write-Host 'Do whatever you  want'
}


#if($args.count -eq 0){
                    
if(!$args.count){



                     $Result = $custom_array  | select name,description | Out-GridView  -PassThru  -Title 'Make a  selection' 

                     Foreach ($i in $Result){ $call = 'func_' +  $i.Name; & $call;}
                     }
else                 {
                     for ( $i = 0; $i -lt $args.count; $i++ ) {$call = 'func_' +  $args[$i]; & $call;}

                     }




 
