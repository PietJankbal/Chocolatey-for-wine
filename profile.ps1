New-Alias Goto Set-Location
 #$env:PSModulePath=Join-Path -Path $env:ProgramFiles -ChildPath 'Powershell\7\Modules'
 
 
 $path = $env:PSModulePath -split ';'
 $env:PSModulePath = $path[1]

Set-Alias -name Domain.DefineDynamicAssembly  [System.Reflection.Emit.AssemblyBuilder]::DefineDynamicAssembly

#Remove-Item alias:Install-Module -force

#Set-Alias Install-Module "Install-Module -SkipPublisherCheck"

New-Alias Get-CimInstance Get-WmiObject

class os
{
    # Optionally, add attributes to prevent invalid values
    [ValidateNotNullOrEmpty()][string]$Version
    [ValidateNotNullOrEmpty()][uint16]$ServicePackMajorVersion
    [ValidateNotNullOrEmpty()][string]$Caption
    [ValidateNotNullOrEmpty()][uint32]$ProductType
}

class bios
{
    # Optionally, add attributes to prevent invalid values
    [ValidateNotNullOrEmpty()][string]$Manufacturer
}

function Get-WmiObject
{

    Write-Warning "Using hacks to work around missing Get-WmiObject; Hopefully it works....."

    $class = $args[1]
    
  
    #wmic puts out utf-16 :(
    #https://lazywinadmin.com/2015/08/powershell-remove-special-characters.html helps a bit
 
   $os = [os]@{
   Version = $(wmic path win32_operatingsystem get Version) -replace '[^\x20-\x7E]+', '' |Select -Index 2
   ServicePackMajorVersion = $(wmic path win32_operatingsystem get ServicePackMajorVersion) -replace '[^\x20-\x7E]+', '' |Select -Index 2
   Caption = $(wmic path win32_operatingsystem get Caption) -replace '[^\x20-\x7E]+', '' |Select -Index 2
   ProductType = $(wmic path win32_operatingsystem get ProductType) -replace '[^\x20-\x7E]+', '' |Select -Index 2
   }

   $bios = [bios]@{
   Manufacturer = $(wmic path win32_bios get Manufacturer) -replace '[^\x20-\x7E]+', '' |Select -Index 2
   }

    switch ($class)
    {
    win32_operatingsystem {$os}
    win32_bios {$bios}
    }


}


 
if(Test-Path 'env:PSREFLECT'){
set-PSRepository psgallery -InstallationPolicy trusted


# vervang: $AssemblyBuilder = $Domain.DefineDynamicAssembly($DynAssembly, 'Run')
#met : $AssemblyBuilder = [System.Reflection.Emit.AssemblyBuilder]::DefineDynamicAssembly($DynAssembly, 'Run')

 
 
Install-Module PSReflect-Functions -RequiredVersion 1.1 -SkipPublisherCheck

#function Domain.DefineDynamicAssembly($assemblyName, $Run)
#{

# [System.Reflection.Emit.AssemblyBuilder]::DefineDynamicAssembly($assemblyName, $Run)
# }
 
#((Get-Content -path $env:PSModulePath/PSReflect-Functions/1.1/PSReflect.ps1 -Raw) -replace `
#"$AssemblyBuilder = $Domain.DefineDynamicAssembly($DynAssembly, 'Run')", `
#"$AssemblyBuilder = [System.Reflection.Emit.AssemblyBuilder]::DefineDynamicAssembly($DynAssembly, 'Run')" `
#| Set-Content -Path $env:PSModulePath/PSReflect-Functions/1.1/PSReflect.ps1)


Import-Module PSReflect-Functions -SkipPublisherCheck

}
