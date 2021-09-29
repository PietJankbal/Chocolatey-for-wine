New-Alias Goto Set-Location

class os
{
    # Optionally, add attributes to prevent invalid values
    [ValidateNotNullOrEmpty()][string]$Version
    [ValidateNotNullOrEmpty()][uint16]$ServicePackMajorVersion
    [ValidateNotNullOrEmpty()][string]$Caption
    [ValidateNotNullOrEmpty()][uint32]$ProductType
}

function Get-WmiObject
{

    #wmic puts out utf-16 :(
    #https://lazywinadmin.com/2015/08/powershell-remove-special-characters.html helps a bit
   
   $os = [os]@{
   Version = $(wmic path win32_operatingsystem get Version) -replace '[^\x20-\x7E]+', '' |Select -Index 2
   ServicePackMajorVersion = $(wmic path win32_operatingsystem get ServicePackMajorVersion) -replace '[^\x20-\x7E]+', '' |Select -Index 2
   Caption = Version = $(wmic path win32_operatingsystem get Caption) -replace '[^\x20-\x7E]+', '' |Select -Index 2
   ProductType = Version = $(wmic path win32_operatingsystem get ProductType) -replace '[^\x20-\x7E]+', '' |Select -Index 2
   }

   $os
}

