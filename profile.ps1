
New-Alias Goto Set-Location

 
 
 $psp = $env:PSModulePath -split ';'
 $env:PSModulePath  = ( $psp | Select-Object -Skip 1 | Sort-Object -Unique) -join ';'



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



 
Find-Module -Name 'psreflect-functions' -Repository 'PSGallery' | Save-Module -Path 'c:\'


((Get-Content -path c:\PSReflect-Functions/2.0.0/PSReflect.ps1 -Raw) -replace `
 "\`$Domain.DefineDynamicAssembly", `
 "[System.Reflection.Emit.AssemblyBuilder]::DefineDynamicAssembly" `
 | Set-Content -Path c:\PSReflect-Functions/2.0.0/PSReflect.ps1)

Import-Module -FullyQualifiedName 'c:\psreflect-functions'

}
