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

    #$Inputstring =Write-Output $(wmic path Win32_OperatingSystem get Version) 


   $os = [os]@{
   Version = '6.1.7601'
   ServicePackMajorVersion = '1'
   Caption = 'Microsoft Windows 7 Professional'
   ProductType = '1'
   }

   $os
}

