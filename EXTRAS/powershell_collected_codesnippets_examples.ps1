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

function func_glxgears2
{
<# compiled from https://raw.githubusercontent.com/CalvinHartwell/windows-glxgears/master/glxgears/main.cpp + added copyright notice

/*
 * Copyright (C) 1999-2001  Brian Paul   All Rights Reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
 * BRIAN PAUL BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
 * AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
/* $XFree86: xc/programs/glxgears/glxgears.c,v 1.3tsi Exp $ */

/*
 * This is a port of the infamous "gears" demo to straight GLX (i.e. no GLUT)
 * Port by Brian Paul  23 March 2001
 *
 * Command line options:
 *    -info      print GL implementation information
 *
 */

/* Modified from X11/GLX to Win32/WGL by Ben Skeggs 25th October 2004 */

/* Modified to compile in Visual Studio 2012 by Calvin Hartwell 28th February 2013 */ #>

<#generated this base64 string in linux: 'cat glxgears.exe | base64 -w 120 ' #>

$glxgears ='
TVqQAAMAAAAEAAAA//8AALgAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA8AAAAA4fug4AtAnNIbgBTM0hVGhpcyBwcm9ncmFt
IGNhbm5vdCBiZSBydW4gaW4gRE9TIG1vZGUuDQ0KJAAAAAAAAAA4B8b9fGaornxmqK58ZqiudR47rnJmqK5pGamvfmaormkZra9oZqiuaRmsr3BmqK5pGauv
fWaorjceqa91ZqiufGaprhxmqK5E5qGvfWaorkTmV659ZqiuROaqr31mqK5SaWNofGaorgAAAAAAAAAAUEUAAEwBAwDgcgVlAAAAAAAAAADgAAIBCwEOJQAg
AAAAEAAAAIAAAICsAAAAkAAAALAAAAAAQAAAEAAAAAIAAAYAAAAAAAAABgAAAAAAAAAAwAAAAAQAAAAAAAADAECBAAAQAAAQAAAAABAAABAAAAAAAAAQAAAA
AAAAAAAAAADcsQAAVAMAAACwAADcAQAAAAAAAAAAAAAAAAAAAAAAADC1AAAUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABUrgAAwAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABVUFgwAAAAAACAAAAAEAAAAAAAAAAEAAAAAAAAAAAAAAAAAACAAADgVVBYMQAAAAAAIAAA
AJAAAAAgAAAABAAAAAAAAAAAAAAAAAAAQAAA4C5yc3JjAAAAABAAAACwAAAABgAAACQAAAAAAAAAAAAAAAAAAEAAAMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
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
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABABgAAAAYAACAAAAAAAAAAAAAAAAAAAABAAEAAAAwAACAAAAAAAAA
AAAAAAAAAAABAAkEAABIAAAAXLAAAH0BAAAAAAAAAAAAAGBwAAA8P3htbCB2ZXJzaW9uPScxLjAnIGVuY29kaW5nPSdVVEYtOCcgc3RhbmRhbG9uZT0neWVz
Jz8+DQo8YXNzZW1ibHkgeG1sbnM9J3VybjpzY2hlbWFzLW1pY3Jvc29mdC1jb206YXNtLnYxJyBtYW5pZmVzdFZlcnNpb249JzEuMCc+DQogIDx0cnVzdElu
Zm8geG1sbnM9InVybjpzY2hlbWFzLW1pY3Jvc29mdC1jb206YXNtLnYzIj4NCiAgICA8c2VjdXJpdHk+DQogICAgICA8cmVxdWVzdGVkUHJpdmlsZWdlcz4N
CiAgICAgICAgPHJlcXVlc3RlZEV4ZWN1dGlvbkxldmVsIGxldmVsPSdhc0ludm9rZXInIHVpQWNjZXNzPSdmYWxzZScgLz4NCiAgICAgIDwvcmVxdWVzdGVk
UHJpdmlsZWdlcz4NCiAgICA8L3NlY3VyaXR5Pg0KICA8L3RydXN0SW5mbz4NCjwvYXNzZW1ibHk+DQoAAAAAAAAAAAAAAAAAAABMswAA4LIAAAAAAAAAAAAA
AAAAAGuzAADosgAAAAAAAAAAAAAAAAAAjLMAAPCyAAAAAAAAAAAAAAAAAACrswAA+LIAAAAAAAAAAAAAAAAAAM2zAAAAswAAAAAAAAAAAAAAAAAA7bMAAAiz
AAAAAAAAAAAAAAAAAAAOtAAAELMAAAAAAAAAAAAAAAAAAC20AAAYswAAAAAAAAAAAAAAAAAAN7QAACCzAAAAAAAAAAAAAAAAAABEtAAANLMAAAAAAAAAAAAA
AAAAAFG0AAA8swAAAAAAAAAAAAAAAAAAXLQAAESzAAAAAAAAAAAAAAAAAAAAAAAAAAAAAG60AAAAAAAAfrQAAAAAAACUtAAAAAAAAKa0AAAAAAAArLQAAAAA
AAC4tAAAAAAAAMK0AAAAAAAAzLQAAAAAAAD4tAAA2rQAAOi0AAAGtQAAAAAAABa1AAAAAAAAHrUAAAAAAAAmtQAAAAAAAGFwaS1tcy13aW4tY3J0LWhlYXAt
bDEtMS0wLmRsbABhcGktbXMtd2luLWNydC1sb2NhbGUtbDEtMS0wLmRsbABhcGktbXMtd2luLWNydC1tYXRoLWwxLTEtMC5kbGwAYXBpLW1zLXdpbi1jcnQt
cnVudGltZS1sMS0xLTAuZGxsAGFwaS1tcy13aW4tY3J0LXN0ZGlvLWwxLTEtMC5kbGwAYXBpLW1zLXdpbi1jcnQtc3RyaW5nLWwxLTEtMC5kbGwAYXBpLW1z
LXdpbi1jcnQtdGltZS1sMS0xLTAuZGxsAEdESTMyLmRsbABLRVJORUwzMi5ETEwAT1BFTkdMMzIuZGxsAFVTRVIzMi5kbGwAVkNSVU5USU1FMTQwLmRsbAAA
AABfc2V0X25ld19tb2RlAAAAX2NvbmZpZ3RocmVhZGxvY2FsZQAAAF9fc2V0dXNlcm1hdGhlcnIAAGV4aXQAAF9zZXRfZm1vZGUAAHN0cm5jbXAAAABfdGlt
ZTY0AAAAU3dhcEJ1ZmZlcnMAAABFeGl0UHJvY2VzcwAAAEdldFByb2NBZGRyZXNzAABMb2FkTGlicmFyeUEAAFZpcnR1YWxQcm90ZWN0AABnbEVuZAAAAEdl
dERDAAAAbWVtc2V0AAAAoAAAFAAAAII8kD6UPpw+9D4MPwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'

[IO.File]::WriteAllBytes("$env:Temp\glxgears.exe", [System.Convert]::FromBase64String($glxgears))

& $env:Temp\glxgears.exe
}


function func_access_winrt_from_powershell2
{

func_wine_wintypes |out-null
func_winmetadata |out-null
func_ps51 |out-null 

 ps51.exe  {

$addType = [Windows.System.Profile.SystemManufacturers.SmbiosInformation, Windows.System.Profile.SystemManufacturers, ContentType=WindowsRuntime]

$Serialnumber = [Windows.System.Profile.SystemManufacturers.SmbiosInformation]::SerialNumber 

Write-Host ' '
Write-Host Reported serialNumber via class [Windows.System.Profile.SystemManufacturers.SmbiosInformation] is: $Serialnumber }
Write-Host ' '
}

function func_vanara2
{
    $wc = New-Object System.Net.WebClient

    if (![System.IO.File]::Exists(  [IO.Path]::Combine($env:Temp,"vanara.core.3.4.16.nupkg")  )) {
        $wc.DownloadFile('https://globalcdn.nuget.org/packages/vanara.core.3.4.16.nupkg', "$env:Temp\vanara.core.3.4.16.nupkg")
    } 

    7z e "$env:Temp\vanara.core.3.4.16.nupkg" "-o$env:ProgramFiles\Powershell\7\modules\vanara" "lib/netstandard2.0/Vanara.Core.dll" -y 
    
    foreach( $i in '.ntdll', '.shared', '.kernel32', '.gdi32', '.user32' <# vanara #> )
    {
        if (![System.IO.File]::Exists(  [IO.Path]::Combine($env:Temp,"vanara.pinvoke$i.3.4.16.nupkg")  )) {
            $wc.DownloadFile("https://globalcdn.nuget.org/packages/vanara.pinvoke$i.3.4.16.nupkg", "$env:Temp\vanara.pinvoke$i.3.4.16.nupkg")
        } 

        7z e "$env:Temp\vanara.pinvoke$i.3.4.16.nupkg" "-o$env:ProgramFiles\Powershell\7\modules\vanara" "lib/netstandard2.0/Vanara.PInvoke$i.dll" -y 
    }
@'    
    function Vanara { }
'@ |Out-File ( New-Item -Path $env:ProgramFiles\Powershell\7\Modules\Vanara\Vanara.psm1 -Force )

@'
@{

# Version number of this module.
ModuleVersion = '0.0.1'

# Assemblies that must be loaded prior to importing this module
 RequiredAssemblies = @("$env:ProgramFiles\Powershell\7\Modules\Vanara\Vanara.Core.dll" 
"$env:ProgramFiles\Powershell\7\Modules\Vanara\Vanara.PInvoke.Gdi32.dll"
"$env:ProgramFiles\Powershell\7\Modules\Vanara\Vanara.PInvoke.Kernel32.dll"
"$env:ProgramFiles\Powershell\7\Modules\Vanara\Vanara.PInvoke.NtDll.dll"
"$env:ProgramFiles\Powershell\7\Modules\Vanara\Vanara.PInvoke.Shared.dll"
"$env:ProgramFiles\Powershell\7\Modules\Vanara\Vanara.PInvoke.User32.dll"
)
}
'@ |Out-File ( New-Item -Path $env:ProgramFiles\Powershell\7\Modules\Vanara\Vanara.psd1 -Force ) 

Import-module Vanara

[Vanara.PInvoke.User32]::MessageBox([IntPtr]::Zero,'Do "Import-Module Vanara" to use the functions  ','',0)

}


function func_Get-PEHeader2
{
$script = @'
<#
.SYNOPSIS

Parses and outputs the PE header of a process in memory or a PE file on disk.

PowerSploit Function: Get-PEHeader
Author: Matthew Graeber (@mattifestation)
License: BSD 3-Clause
Required Dependencies: None
Optional Dependencies: PETools.format.ps1xml

.DESCRIPTION

Get-PEHeader retrieves PE headers including imports and exports from either a file on disk or a module in memory. Get-PEHeader will operate on single PE header but you can also feed it the output of Get-ChildItem or Get-Process! Get-PEHeader works on both 32 and 64-bit modules.

.PARAMETER FilePath

Specifies the path to the portable executable file on disk

.PARAMETER ProcessID

Specifies the process ID.

.PARAMETER Module

The name of the module. This parameter is typically only used in pipeline expressions

.PARAMETER ModuleBaseAddress

The base address of the module

.PARAMETER GetSectionData

Retrieves raw section data.

.OUTPUTS

System.Object

Returns a custom object consisting of the following: compile time, section headers, module name, DOS header, imports, exports, file header, optional header, and PE signature.

.EXAMPLE

C:\PS> Get-Process cmd | Get-PEHeader

Description
-----------
Returns the full PE headers of every loaded module in memory

.EXAMPLE

C:\PS> Get-ChildItem C:\Windows\*.exe | Get-PEHeader

Description
-----------
Returns the full PE headers of every exe in C:\Windows\

.EXAMPLE

C:\PS> Get-PEHeader C:\Windows\System32\kernel32.dll

Module : C:\Windows\System32\kernel32.dll
DOSHeader : PE+_IMAGE_DOS_HEADER
FileHeader : PE+_IMAGE_FILE_HEADER
OptionalHeader : PE+_IMAGE_OPTIONAL_HEADER32
SectionHeaders : {.text, .data, .rsrc, .reloc}
Imports : {@{Ordinal=; FunctionName=RtlUnwind; ModuleName=API-MS-Win-Core-RtlSupport-L1-1-0.
                 dll; VA=0x000CB630}, @{Ordinal=; FunctionName=RtlCaptureContext; ModuleName=API-MS
                 -Win-Core-RtlSupport-L1-1-0.dll; VA=0x000CB63C}, @{Ordinal=; FunctionName=RtlCaptu
                 reStackBackTrace; ModuleName=API-MS-Win-Core-RtlSupport-L1-1-0.dll; VA=0x000CB650}
                 , @{Ordinal=; FunctionName=NtCreateEvent; ModuleName=ntdll.dll; VA=0x000CB66C}...}
Exports : {@{ForwardedName=; FunctionName=lstrlenW; Ordinal=0x0552; VA=0x0F022708}, @{Forwar
                 dedName=; FunctionName=lstrlenA; Ordinal=0x0551; VA=0x0F026A23}, @{ForwardedName=;
                  FunctionName=lstrlen; Ordinal=0x0550; VA=0x0F026A23}, @{ForwardedName=; FunctionN
                 ame=lstrcpynW; Ordinal=0x054F; VA=0x0F04E54E}...}

.EXAMPLE

C:\PS> $Proc = Get-Process cmd
C:\PS> $Kernel32Base = ($Proc.Modules | Where-Object {$_.ModuleName -eq 'kernel32.dll'}).BaseAddress
C:\PS> Get-PEHeader -ProcessId $Proc.Id -ModuleBaseAddress $Kernel32Base

Module :
DOSHeader : PE+_IMAGE_DOS_HEADER
FileHeader : PE+_IMAGE_FILE_HEADER
OptionalHeader : PE+_IMAGE_OPTIONAL_HEADER32
SectionHeaders : {.text, .data, .rsrc, .reloc}
Imports : {@{Ordinal=; FunctionName=RtlUnwind; ModuleName=API-MS-Win-Core-RtlSupport-L1-1-0.
                 dll; VA=0x77B8B6D9}, @{Ordinal=; FunctionName=RtlCaptureContext; ModuleName=API-MS
                 -Win-Core-RtlSupport-L1-1-0.dll; VA=0x77B8B4CB}, @{Ordinal=; FunctionName=RtlCaptu
                 reStackBackTrace; ModuleName=API-MS-Win-Core-RtlSupport-L1-1-0.dll; VA=0x77B95277}
                 , @{Ordinal=; FunctionName=NtCreateEvent; ModuleName=ntdll.dll; VA=0x77B4FF54}...}
Exports : {@{ForwardedName=; FunctionName=lstrlenW; Ordinal=0x0552; VA=0x08221720}, @{Forwar
                 dedName=; FunctionName=lstrlenA; Ordinal=0x0551; VA=0x08225A3B}, @{ForwardedName=;
                  FunctionName=lstrlen; Ordinal=0x0550; VA=0x08225A3B}, @{ForwardedName=; FunctionN
                 ame=lstrcpynW; Ordinal=0x054F; VA=0x0824D566}...}

Description
-----------
A PE header is returned upon providing the module's base address. This technique would be useful for dumping the PE header of a rogue module that is invisible to Windows - e.g. a reflectively loaded meterpreter binary (metsrv.dll).

.NOTES

Be careful if you decide to specify a module base address. Get-PEHeader does not check for the existence of an MZ header. An MZ header is not a prerequisite for reflectively loading a module in memory. If you provide an address that is not an actual PE header, you could crash the process.

.LINK

http://www.exploit-monday.com/2012/07/get-peheader.html
#>

function Get-PEHeader {

    [CmdletBinding(DefaultParameterSetName = 'OnDisk')] Param (
        [Parameter(Position = 0, Mandatory = $True, ParameterSetName = 'OnDisk', ValueFromPipelineByPropertyName = $True)] [Alias('FullName')] [String[]] $FilePath,
        [Parameter(Position = 0, Mandatory = $True, ParameterSetName = 'InMemory', ValueFromPipelineByPropertyName = $True)] [Alias('Id')] [Int] $ProcessID,
        [Parameter(Position = 2, ParameterSetName = 'InMemory', ValueFromPipelineByPropertyName = $True)] [Alias('MainModule')] [Alias('Modules')] [System.Diagnostics.ProcessModule[]] $Module,
        [Parameter(Position = 1, ParameterSetName = 'InMemory')] [IntPtr] $ModuleBaseAddress,
        [Parameter()] [Switch] $GetSectionData
    )

PROCESS {
    
    switch ($PsCmdlet.ParameterSetName) {
        'OnDisk' {
        
            if ($FilePath.Length -gt 1) {
                foreach ($Path in $FilePath) { Get-PEHeader $Path }
            }
            
            if (!(Test-Path $FilePath)) {
                Write-Warning 'Invalid path or file does not exist.'
                return
            }
            
            $FilePath = Resolve-Path $FilePath
            
            if ($FilePath.GetType() -eq [System.Array]) {
                $ModuleName = $FilePath[0]
            } else {
                $ModuleName = $FilePath
            }
            
        }
        'InMemory' {
        
            if ($Module.Length -gt 1) {
                foreach ($Mod in $Module) {
                    $BaseAddr = $Mod.BaseAddress
                    Get-PEHeader -ProcessID $ProcessID -Module $Mod -ModuleBaseAddress $BaseAddr
                }
            }

            if (-not $ModuleBaseAddress) { return }
            
            if ($ProcessID -eq $PID) {
                Write-Warning 'You cannot parse the PE header of the current process. Open another instance of PowerShell.'
                return
            }
            
            if ($Module) {
                $ModuleName = $Module[0].FileName
            } else {
                $ModuleName = ''
            }
            
        }
    }
    
    try { [PE] | Out-Null } catch [Management.Automation.RuntimeException]
    {
        $code = @"
        using System;
        using System.Runtime.InteropServices;

        public class PE
        {
            [Flags]
            public enum IMAGE_DOS_SIGNATURE : ushort
            {
                DOS_SIGNATURE = 0x5A4D, // MZ
                OS2_SIGNATURE = 0x454E, // NE
                OS2_SIGNATURE_LE = 0x454C, // LE
                VXD_SIGNATURE = 0x454C, // LE
            }
        
            [Flags]
            public enum IMAGE_NT_SIGNATURE : uint
            {
                VALID_PE_SIGNATURE = 0x00004550 // PE00
            }
        
            [Flags]
            public enum IMAGE_FILE_MACHINE : ushort
            {
                UNKNOWN = 0,
                I386 = 0x014c, // Intel 386.
                R3000 = 0x0162, // MIPS little-endian =0x160 big-endian
                R4000 = 0x0166, // MIPS little-endian
                R10000 = 0x0168, // MIPS little-endian
                WCEMIPSV2 = 0x0169, // MIPS little-endian WCE v2
                ALPHA = 0x0184, // Alpha_AXP
                SH3 = 0x01a2, // SH3 little-endian
                SH3DSP = 0x01a3,
                SH3E = 0x01a4, // SH3E little-endian
                SH4 = 0x01a6, // SH4 little-endian
                SH5 = 0x01a8, // SH5
                ARM = 0x01c0, // ARM Little-Endian
                THUMB = 0x01c2,
                ARMNT = 0x01c4, // ARM Thumb-2 Little-Endian
                AM33 = 0x01d3,
                POWERPC = 0x01F0, // IBM PowerPC Little-Endian
                POWERPCFP = 0x01f1,
                IA64 = 0x0200, // Intel 64
                MIPS16 = 0x0266, // MIPS
                ALPHA64 = 0x0284, // ALPHA64
                MIPSFPU = 0x0366, // MIPS
                MIPSFPU16 = 0x0466, // MIPS
                AXP64 = ALPHA64,
                TRICORE = 0x0520, // Infineon
                CEF = 0x0CEF,
                EBC = 0x0EBC, // EFI public byte Code
                AMD64 = 0x8664, // AMD64 (K8)
                M32R = 0x9041, // M32R little-endian
                CEE = 0xC0EE
            }
        
            [Flags]
            public enum IMAGE_FILE_CHARACTERISTICS : ushort
            {
                IMAGE_RELOCS_STRIPPED = 0x0001, // Relocation info stripped from file.
                IMAGE_EXECUTABLE_IMAGE = 0x0002, // File is executable (i.e. no unresolved external references).
                IMAGE_LINE_NUMS_STRIPPED = 0x0004, // Line nunbers stripped from file.
                IMAGE_LOCAL_SYMS_STRIPPED = 0x0008, // Local symbols stripped from file.
                IMAGE_AGGRESIVE_WS_TRIM = 0x0010, // Agressively trim working set
                IMAGE_LARGE_ADDRESS_AWARE = 0x0020, // App can handle >2gb addresses
                IMAGE_REVERSED_LO = 0x0080, // public bytes of machine public ushort are reversed.
                IMAGE_32BIT_MACHINE = 0x0100, // 32 bit public ushort machine.
                IMAGE_DEBUG_STRIPPED = 0x0200, // Debugging info stripped from file in .DBG file
                IMAGE_REMOVABLE_RUN_FROM_SWAP = 0x0400, // If Image is on removable media =copy and run from the swap file.
                IMAGE_NET_RUN_FROM_SWAP = 0x0800, // If Image is on Net =copy and run from the swap file.
                IMAGE_SYSTEM = 0x1000, // System File.
                IMAGE_DLL = 0x2000, // File is a DLL.
                IMAGE_UP_SYSTEM_ONLY = 0x4000, // File should only be run on a UP machine
                IMAGE_REVERSED_HI = 0x8000 // public bytes of machine public ushort are reversed.
            }
        
            [Flags]
            public enum IMAGE_NT_OPTIONAL_HDR_MAGIC : ushort
            {
                PE32 = 0x10b,
                PE64 = 0x20b
            }
        
            [Flags]
            public enum IMAGE_SUBSYSTEM : ushort
            {
                UNKNOWN = 0, // Unknown subsystem.
                NATIVE = 1, // Image doesn't require a subsystem.
                WINDOWS_GUI = 2, // Image runs in the Windows GUI subsystem.
                WINDOWS_CUI = 3, // Image runs in the Windows character subsystem.
                OS2_CUI = 5, // image runs in the OS/2 character subsystem.
                POSIX_CUI = 7, // image runs in the Posix character subsystem.
                NATIVE_WINDOWS = 8, // image is a native Win9x driver.
                WINDOWS_CE_GUI = 9, // Image runs in the Windows CE subsystem.
                EFI_APPLICATION = 10,
                EFI_BOOT_SERVICE_DRIVER = 11,
                EFI_RUNTIME_DRIVER = 12,
                EFI_ROM = 13,
                XBOX = 14,
                WINDOWS_BOOT_APPLICATION = 16
            }
        
            [Flags]
            public enum IMAGE_DLLCHARACTERISTICS : ushort
            {
                DYNAMIC_BASE = 0x0040, // DLL can move.
                FORCE_INTEGRITY = 0x0080, // Code Integrity Image
                NX_COMPAT = 0x0100, // Image is NX compatible
                NO_ISOLATION = 0x0200, // Image understands isolation and doesn't want it
                NO_SEH = 0x0400, // Image does not use SEH. No SE handler may reside in this image
                NO_BIND = 0x0800, // Do not bind this image.
                WDM_DRIVER = 0x2000, // Driver uses WDM model
                TERMINAL_SERVER_AWARE = 0x8000
            }
        
            [Flags]
            public enum IMAGE_SCN : uint
            {
                TYPE_NO_PAD = 0x00000008, // Reserved.
                CNT_CODE = 0x00000020, // Section contains code.
                CNT_INITIALIZED_DATA = 0x00000040, // Section contains initialized data.
                CNT_UNINITIALIZED_DATA = 0x00000080, // Section contains uninitialized data.
                LNK_INFO = 0x00000200, // Section contains comments or some other type of information.
                LNK_REMOVE = 0x00000800, // Section contents will not become part of image.
                LNK_COMDAT = 0x00001000, // Section contents comdat.
                NO_DEFER_SPEC_EXC = 0x00004000, // Reset speculative exceptions handling bits in the TLB entries for this section.
                GPREL = 0x00008000, // Section content can be accessed relative to GP
                MEM_FARDATA = 0x00008000,
                MEM_PURGEABLE = 0x00020000,
                MEM_16BIT = 0x00020000,
                MEM_LOCKED = 0x00040000,
                MEM_PRELOAD = 0x00080000,
                ALIGN_1BYTES = 0x00100000,
                ALIGN_2BYTES = 0x00200000,
                ALIGN_4BYTES = 0x00300000,
                ALIGN_8BYTES = 0x00400000,
                ALIGN_16BYTES = 0x00500000, // Default alignment if no others are specified.
                ALIGN_32BYTES = 0x00600000,
                ALIGN_64BYTES = 0x00700000,
                ALIGN_128BYTES = 0x00800000,
                ALIGN_256BYTES = 0x00900000,
                ALIGN_512BYTES = 0x00A00000,
                ALIGN_1024BYTES = 0x00B00000,
                ALIGN_2048BYTES = 0x00C00000,
                ALIGN_4096BYTES = 0x00D00000,
                ALIGN_8192BYTES = 0x00E00000,
                ALIGN_MASK = 0x00F00000,
                LNK_NRELOC_OVFL = 0x01000000, // Section contains extended relocations.
                MEM_DISCARDABLE = 0x02000000, // Section can be discarded.
                MEM_NOT_CACHED = 0x04000000, // Section is not cachable.
                MEM_NOT_PAGED = 0x08000000, // Section is not pageable.
                MEM_SHARED = 0x10000000, // Section is shareable.
                MEM_EXECUTE = 0x20000000, // Section is executable.
                MEM_READ = 0x40000000, // Section is readable.
                MEM_WRITE = 0x80000000 // Section is writeable.
            }
    
            [StructLayout(LayoutKind.Sequential, Pack=1)]
            public struct _IMAGE_DOS_HEADER
            {
                public IMAGE_DOS_SIGNATURE e_magic; // Magic number
                public ushort e_cblp; // public bytes on last page of file
                public ushort e_cp; // Pages in file
                public ushort e_crlc; // Relocations
                public ushort e_cparhdr; // Size of header in paragraphs
                public ushort e_minalloc; // Minimum extra paragraphs needed
                public ushort e_maxalloc; // Maximum extra paragraphs needed
                public ushort e_ss; // Initial (relative) SS value
                public ushort e_sp; // Initial SP value
                public ushort e_csum; // Checksum
                public ushort e_ip; // Initial IP value
                public ushort e_cs; // Initial (relative) CS value
                public ushort e_lfarlc; // File address of relocation table
                public ushort e_ovno; // Overlay number
                [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 8)]
                public string e_res; // This will contain 'Detours!' if patched in memory
                public ushort e_oemid; // OEM identifier (for e_oeminfo)
                public ushort e_oeminfo; // OEM information; e_oemid specific
                [MarshalAsAttribute(UnmanagedType.ByValArray, SizeConst=10)] // , ArraySubType=UnmanagedType.U4
                public ushort[] e_res2; // Reserved public ushorts
                public int e_lfanew; // File address of new exe header
            }
        
            [StructLayout(LayoutKind.Sequential, Pack=1)]
            public struct _IMAGE_FILE_HEADER
            {
                public IMAGE_FILE_MACHINE Machine;
                public ushort NumberOfSections;
                public uint TimeDateStamp;
                public uint PointerToSymbolTable;
                public uint NumberOfSymbols;
                public ushort SizeOfOptionalHeader;
                public IMAGE_FILE_CHARACTERISTICS Characteristics;
            }
        
            [StructLayout(LayoutKind.Sequential, Pack=1)]
            public struct _IMAGE_NT_HEADERS32
            {
                public IMAGE_NT_SIGNATURE Signature;
                public _IMAGE_FILE_HEADER FileHeader;
                public _IMAGE_OPTIONAL_HEADER32 OptionalHeader;
            }
        
            [StructLayout(LayoutKind.Sequential, Pack=1)]
            public struct _IMAGE_NT_HEADERS64
            {
                public IMAGE_NT_SIGNATURE Signature;
                public _IMAGE_FILE_HEADER FileHeader;
                public _IMAGE_OPTIONAL_HEADER64 OptionalHeader;
            }
        
            [StructLayout(LayoutKind.Sequential, Pack=1)]
            public struct _IMAGE_OPTIONAL_HEADER32
            {
                public IMAGE_NT_OPTIONAL_HDR_MAGIC Magic;
                public byte MajorLinkerVersion;
                public byte MinorLinkerVersion;
                public uint SizeOfCode;
                public uint SizeOfInitializedData;
                public uint SizeOfUninitializedData;
                public uint AddressOfEntryPoint;
                public uint BaseOfCode;
                public uint BaseOfData;
                public uint ImageBase;
                public uint SectionAlignment;
                public uint FileAlignment;
                public ushort MajorOperatingSystemVersion;
                public ushort MinorOperatingSystemVersion;
                public ushort MajorImageVersion;
                public ushort MinorImageVersion;
                public ushort MajorSubsystemVersion;
                public ushort MinorSubsystemVersion;
                public uint Win32VersionValue;
                public uint SizeOfImage;
                public uint SizeOfHeaders;
                public uint CheckSum;
                public IMAGE_SUBSYSTEM Subsystem;
                public IMAGE_DLLCHARACTERISTICS DllCharacteristics;
                public uint SizeOfStackReserve;
                public uint SizeOfStackCommit;
                public uint SizeOfHeapReserve;
                public uint SizeOfHeapCommit;
                public uint LoaderFlags;
                public uint NumberOfRvaAndSizes;
                [MarshalAsAttribute(UnmanagedType.ByValArray, SizeConst=16)]
                public _IMAGE_DATA_DIRECTORY[] DataDirectory;
            }
        
            [StructLayout(LayoutKind.Sequential, Pack=1)]
            public struct _IMAGE_OPTIONAL_HEADER64
            {
                public IMAGE_NT_OPTIONAL_HDR_MAGIC Magic;
                public byte MajorLinkerVersion;
                public byte MinorLinkerVersion;
                public uint SizeOfCode;
                public uint SizeOfInitializedData;
                public uint SizeOfUninitializedData;
                public uint AddressOfEntryPoint;
                public uint BaseOfCode;
                public ulong ImageBase;
                public uint SectionAlignment;
                public uint FileAlignment;
                public ushort MajorOperatingSystemVersion;
                public ushort MinorOperatingSystemVersion;
                public ushort MajorImageVersion;
                public ushort MinorImageVersion;
                public ushort MajorSubsystemVersion;
                public ushort MinorSubsystemVersion;
                public uint Win32VersionValue;
                public uint SizeOfImage;
                public uint SizeOfHeaders;
                public uint CheckSum;
                public IMAGE_SUBSYSTEM Subsystem;
                public IMAGE_DLLCHARACTERISTICS DllCharacteristics;
                public ulong SizeOfStackReserve;
                public ulong SizeOfStackCommit;
                public ulong SizeOfHeapReserve;
                public ulong SizeOfHeapCommit;
                public uint LoaderFlags;
                public uint NumberOfRvaAndSizes;
                [MarshalAsAttribute(UnmanagedType.ByValArray, SizeConst=16)]
                public _IMAGE_DATA_DIRECTORY[] DataDirectory;
            }
        
            [StructLayout(LayoutKind.Sequential, Pack=1)]
            public struct _IMAGE_DATA_DIRECTORY
            {
                public uint VirtualAddress;
                public uint Size;
            }
        
            [StructLayout(LayoutKind.Sequential, Pack=1)]
            public struct _IMAGE_EXPORT_DIRECTORY
            {
                public uint Characteristics;
                public uint TimeDateStamp;
                public ushort MajorVersion;
                public ushort MinorVersion;
                public uint Name;
                public uint Base;
                public uint NumberOfFunctions;
                public uint NumberOfNames;
                public uint AddressOfFunctions; // RVA from base of image
                public uint AddressOfNames; // RVA from base of image
                public uint AddressOfNameOrdinals; // RVA from base of image
            }
       
            [StructLayout(LayoutKind.Sequential, Pack=1)]
            public struct _IMAGE_SECTION_HEADER
            {
                [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 8)]
                public string Name;
                public uint VirtualSize;
                public uint VirtualAddress;
                public uint SizeOfRawData;
                public uint PointerToRawData;
                public uint PointerToRelocations;
                public uint PointerToLinenumbers;
                public ushort NumberOfRelocations;
                public ushort NumberOfLinenumbers;
                public IMAGE_SCN Characteristics;
            }
        
            [StructLayout(LayoutKind.Sequential, Pack=1)]
            public struct _IMAGE_IMPORT_DESCRIPTOR
            {
                public uint OriginalFirstThunk; // RVA to original unbound IAT (PIMAGE_THUNK_DATA)
                public uint TimeDateStamp; // 0 if not bound,
                                                    // -1 if bound, and real date/time stamp
                                                    // in IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT (new BIND)
                                                    // O.W. date/time stamp of DLL bound to (Old BIND)
                public uint ForwarderChain; // -1 if no forwarders
                public uint Name;
                public uint FirstThunk; // RVA to IAT (if bound this IAT has actual addresses)
            }

            [StructLayout(LayoutKind.Sequential, Pack=1)]
            public struct _IMAGE_THUNK_DATA32
            {
                public Int32 AddressOfData; // PIMAGE_IMPORT_BY_NAME
            }

            [StructLayout(LayoutKind.Sequential, Pack=1)]
            public struct _IMAGE_THUNK_DATA64
            {
                public Int64 AddressOfData; // PIMAGE_IMPORT_BY_NAME
            }
        
            [StructLayout(LayoutKind.Sequential, Pack=1)]
            public struct _IMAGE_IMPORT_BY_NAME
            {
                public ushort Hint;
                public char Name;
            }
        }
"@


#($cp = new-object System.CodeDom.Compiler.CompilerParameters).CompilerOptions = '/unsafe' 

        ($compileParams = New-Object System.CodeDom.Compiler.CompilerParameters).CompilerOptions = '/unsafe'
        #$compileParams.ReferencedAssemblies.AddRange(@('System.dll', 'mscorlib.dll'))
        $compileParams.GenerateInMemory = $True
        Add-Type -TypeDefinition $code -CompilerOptions "/unsafe"  -PassThru -WarningAction SilentlyContinue | Out-Null
    }

    function Get-DelegateType
    {
        Param (
            [Parameter(Position = 0, Mandatory = $True)] [Type[]] $Parameters,
            [Parameter(Position = 1)] [Type] $ReturnType = [Void]
        )

        $Domain = [AppDomain]::CurrentDomain
        $DynAssembly = New-Object System.Reflection.AssemblyName('ReflectedDelegate')
        #$AssemblyBuilder = $Domain.DefineDynamicAssembly($DynAssembly, [System.Reflection.Emit.AssemblyBuilderAccess]::Run)
        $AssemblyBuilder = [System.Reflection.Emit.AssemblyBuilder]::DefineDynamicAssembly($DynAssembly, 'Run')
        if ( [System.Convert]::ToDecimal( $PSVersionTable.PSVersion.Minor) -lt 3 ) {
        $ModuleBuilder = $AssemblyBuilder.DefineDynamicModule('InMemoryModule', $false) }
        else { $ModuleBuilder = $AssemblyBuilder.DefineDynamicModule('InMemoryModule')  }
        $TypeBuilder = $ModuleBuilder.DefineType('MyDelegateType', 'Class, Public, Sealed, AnsiClass, AutoClass', [System.MulticastDelegate])
        $ConstructorBuilder = $TypeBuilder.DefineConstructor('RTSpecialName, HideBySig, Public', [System.Reflection.CallingConventions]::Standard, $Parameters)
        $ConstructorBuilder.SetImplementationFlags('Runtime, Managed')
        $MethodBuilder = $TypeBuilder.DefineMethod('Invoke', 'Public, HideBySig, NewSlot, Virtual', $ReturnType, $Parameters)
        $MethodBuilder.SetImplementationFlags('Runtime, Managed')
        
        return $TypeBuilder.CreateType()
    }

    function Get-ProcAddress
    {
        Param (
            [Parameter(Position = 0, Mandatory = $True)] [String] $Module,
            [Parameter(Position = 1, Mandatory = $True)] [String] $Procedure
        )

        # Get a reference to System.dll in the GAC
        #$SystemAssembly = [AppDomain]::CurrentDomain.GetAssemblies() |
           # Where-Object { $_.GlobalAssemblyCache -And $_.Location.Split('\\')[-1].Equals('System.dll') }
        $SystemAssembly=[Reflection.Assembly]::LoadFile('C:\windows\Microsoft.NET\assembly\GAC_MSIL\System\v4.0_4.0.0.0__b77a5c561934e089\system.dll')
        $UnsafeNativeMethods = $SystemAssembly.GetType('Microsoft.Win32.UnsafeNativeMethods')
        # Get a reference to the GetModuleHandle and GetProcAddress methods
        $GetModuleHandle = $UnsafeNativeMethods.GetMethod('GetModuleHandle')
        $GetProcAddress = $UnsafeNativeMethods.GetMethod('GetProcAddress', [reflection.bindingflags] "Public,Static", $null, [System.Reflection.CallingConventions]::Any, @((New-Object System.Runtime.InteropServices.HandleRef).GetType(), [string]), $null);
        # Get a handle to the module specified
        $Kern32Handle = $GetModuleHandle.Invoke($null, @($Module))
        $tmpPtr = New-Object IntPtr
        $HandleRef = New-Object System.Runtime.InteropServices.HandleRef($tmpPtr, $Kern32Handle)
        # Return the address of the function
        
        return $GetProcAddress.Invoke($null, @([System.Runtime.InteropServices.HandleRef]$HandleRef, $Procedure))
    }
    
    $OnDisk = $True
    if ($PsCmdlet.ParameterSetName -eq 'InMemory') { $OnDisk = $False }
    
    
    $OpenProcessAddr = Get-ProcAddress kernel32.dll OpenProcess
    $OpenProcessDelegate = Get-DelegateType @([UInt32], [Bool], [UInt32]) ([IntPtr])
    $OpenProcess = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($OpenProcessAddr, [Type] $OpenProcessDelegate)
    $ReadProcessMemoryAddr = Get-ProcAddress kernel32.dll ReadProcessMemory
    $ReadProcessMemoryDelegate = Get-DelegateType @([IntPtr], [IntPtr], [IntPtr], [Int], [Int].MakeByRefType()) ([Bool])
    $ReadProcessMemory = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($ReadProcessMemoryAddr, [Type] $ReadProcessMemoryDelegate)
    $CloseHandleAddr = Get-ProcAddress kernel32.dll CloseHandle
    $CloseHandleDelegate = Get-DelegateType @([IntPtr]) ([Bool])
    $CloseHandle = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($CloseHandleAddr, [Type] $CloseHandleDelegate)
    
    if ($OnDisk) {
    
        $FileStream = New-Object System.IO.FileStream($FilePath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read)
        $FileByteArray = New-Object Byte[]($FileStream.Length)
        $FileStream.Read($FileByteArray, 0, $FileStream.Length) | Out-Null
        $FileStream.Close()
        $Handle = [System.Runtime.InteropServices.GCHandle]::Alloc($FileByteArray, 'Pinned')
        $PEBaseAddr = $Handle.AddrOfPinnedObject()
        
    } else {
    
        # Size of the memory page allocated for the PE header
        $HeaderSize = 0x1000
        # Allocate space for when the PE header is read from the remote process
        $PEBaseAddr = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($HeaderSize + 1)
        # Get handle to the process
        $hProcess = $OpenProcess.Invoke(0x10, $false, $ProcessID) # PROCESS_VM_READ (0x00000010)
        
        # Read PE header from remote process
        if (!$ReadProcessMemory.Invoke($hProcess, $ModuleBaseAddress, $PEBaseAddr, $HeaderSize, [Ref] 0)) {
            if ($ModuleName) {
                Write-Warning "Failed to read PE header of $ModuleName"
            } else {
                Write-Warning "Failed to read PE header of process ID: $ProcessID"
            }
            
            Write-Warning "Error code: 0x$([System.Runtime.InteropServices.Marshal]::GetLastWin32Error().ToString('X8'))"
            $CloseHandle.Invoke($hProcess) | Out-Null
            return
        }
        
    }
    
    $DosHeader = [System.Runtime.InteropServices.Marshal]::PtrToStructure($PEBaseAddr, [Type] [PE+_IMAGE_DOS_HEADER])
    $PointerNtHeader = [IntPtr] ($PEBaseAddr.ToInt64() + $DosHeader.e_lfanew)
    $NtHeader = [System.Runtime.InteropServices.Marshal]::PtrToStructure($PointerNtHeader, [Type] [PE+_IMAGE_NT_HEADERS32])
    $Architecture = ($NtHeader.FileHeader.Machine).ToString()
    
    $BinaryPtrWidth = 4

    # Define relevant structure types depending upon whether the binary is 32 or 64-bit
    if ($Architecture -eq 'AMD64') {
    
        $BinaryPtrWidth = 8

        $PEStruct = @{
            IMAGE_OPTIONAL_HEADER = [PE+_IMAGE_OPTIONAL_HEADER64]
            NT_HEADER = [PE+_IMAGE_NT_HEADERS64]
        }

        $ThunkDataStruct = [PE+_IMAGE_THUNK_DATA64]

        Write-Verbose "Architecture: $Architecture"
        Write-Verbose 'Proceeding with parsing a 64-bit binary.'
        
    } elseif ($Architecture -eq 'I386' -or $Architecture -eq 'ARMNT' -or $Architecture -eq 'THUMB') {
    
        $PEStruct = @{
            IMAGE_OPTIONAL_HEADER = [PE+_IMAGE_OPTIONAL_HEADER32]
            NT_HEADER = [PE+_IMAGE_NT_HEADERS32]
        }

        $ThunkDataStruct = [PE+_IMAGE_THUNK_DATA32]

        Write-Verbose "Architecture: $Architecture"
        Write-Verbose 'Proceeding with parsing a 32-bit binary.'
        
    } else {
    
        Write-Warning 'Get-PEHeader only supports binaries compiled for x86, AMD64, and ARM.'
        return
        
    }
    
    # Need to get a new NT header in case the architecture changed
    $NtHeader = [System.Runtime.InteropServices.Marshal]::PtrToStructure($PointerNtHeader, [Type] $PEStruct['NT_HEADER'])
    # Display all section headers
    $NumSections = $NtHeader.FileHeader.NumberOfSections
    $NumRva = $NtHeader.OptionalHeader.NumberOfRvaAndSizes
    $PointerSectionHeader = [IntPtr] ($PointerNtHeader.ToInt64() + [System.Runtime.InteropServices.Marshal]::SizeOf([Type] $PEStruct['NT_HEADER']))
    $SectionHeaders = New-Object PSObject[]($NumSections)
    foreach ($i in 0..($NumSections - 1))
    {
        $SectionHeaders[$i] = [System.Runtime.InteropServices.Marshal]::PtrToStructure(([IntPtr] ($PointerSectionHeader.ToInt64() + ($i * [System.Runtime.InteropServices.Marshal]::SizeOf([Type] [PE+_IMAGE_SECTION_HEADER])))), [Type] [PE+_IMAGE_SECTION_HEADER])
    }
    
    
    if (!$OnDisk) {
        
        $ReadSize = $NtHeader.OptionalHeader.SizeOfImage
        # Free memory allocated for the PE header
        [System.Runtime.InteropServices.Marshal]::FreeHGlobal($PEBaseAddr)
        $PEBaseAddr = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($ReadSize + 1)
        
        # Read process memory of each section header
        foreach ($SectionHeader in $SectionHeaders) {
            if (!$ReadProcessMemory.Invoke($hProcess, [IntPtr] ($ModuleBaseAddress.ToInt64() + $SectionHeader.VirtualAddress), [IntPtr] ($PEBaseAddr.ToInt64() + $SectionHeader.VirtualAddress), $SectionHeader.VirtualSize, [Ref] 0)) {
                if ($ModuleName) {
                    Write-Warning "Failed to read $($SectionHeader.Name) section of $ModuleName"
                } else {
                    Write-Warning "Failed to read $($SectionHeader.Name) section of process ID: $ProcessID"
                }
                
                Write-Warning "Error code: 0x$([System.Runtime.InteropServices.Marshal]::GetLastWin32Error().ToString('X8'))"
                $CloseHandle.Invoke($hProcess) | Out-Null
                return
            }
        }
        
        # Close handle to the remote process since we no longer need to access the process.
        $CloseHandle.Invoke($hProcess) | Out-Null
        
    }

    if ($PSBoundParameters['GetSectionData'])
    {
        foreach ($i in 0..($NumSections - 1))
        {
            $RawBytes = $null

            if ($OnDisk)
            {
                $RawBytes = New-Object Byte[]($SectionHeaders[$i].SizeOfRawData)
                [Runtime.InteropServices.Marshal]::Copy([IntPtr] ($PEBaseAddr.ToInt64() + $SectionHeaders[$i].PointerToRawData), $RawBytes, 0, $SectionHeaders[$i].SizeOfRawData)
            }
            else
            {
                $RawBytes = New-Object Byte[]($SectionHeaders[$i].VirtualSize)
                [Runtime.InteropServices.Marshal]::Copy([IntPtr] ($PEBaseAddr.ToInt64() + $SectionHeaders[$i].VirtualAddress), $RawBytes, 0, $SectionHeaders[$i].VirtualSize)
            }

            $SectionHeaders[$i] = Add-Member -InputObject ($SectionHeaders[$i]) -MemberType NoteProperty -Name RawData -Value $RawBytes -PassThru -Force
        }
    }
    
    function Get-Exports()
    {
    
        if ($NTHeader.OptionalHeader.DataDirectory[0].VirtualAddress -eq 0) {
            Write-Verbose 'Module does not contain any exports'
            return
        }

        # List all function Rvas in the export table
        $ExportPointer = [IntPtr] ($PEBaseAddr.ToInt64() + $NtHeader.OptionalHeader.DataDirectory[0].VirtualAddress)
        # This range will be used to test for the existence of forwarded functions
        $ExportDirLow = $NtHeader.OptionalHeader.DataDirectory[0].VirtualAddress
        if ($OnDisk) { 
            $ExportPointer = Convert-RVAToFileOffset $ExportPointer
            $ExportDirLow = Convert-RVAToFileOffset $ExportDirLow
            $ExportDirHigh = $ExportDirLow.ToInt32() + $NtHeader.OptionalHeader.DataDirectory[0].Size
        } else { $ExportDirHigh = $ExportDirLow + $NtHeader.OptionalHeader.DataDirectory[0].Size }
        
        $ExportDirectory = [System.Runtime.InteropServices.Marshal]::PtrToStructure($ExportPointer, [Type] [PE+_IMAGE_EXPORT_DIRECTORY])
        $AddressOfNamePtr = [IntPtr] ($PEBaseAddr.ToInt64() + $ExportDirectory.AddressOfNames)
        $NameOrdinalAddrPtr = [IntPtr] ($PEBaseAddr.ToInt64() + $ExportDirectory.AddressOfNameOrdinals)
        $AddressOfFunctionsPtr = [IntPtr] ($PEBaseAddr.ToInt64() + $ExportDirectory.AddressOfFunctions)
        $NumNamesFuncs = $ExportDirectory.NumberOfFunctions - $ExportDirectory.NumberOfNames
        $NumNames = $ExportDirectory.NumberOfNames
        $NumFunctions = $ExportDirectory.NumberOfFunctions
        $Base = $ExportDirectory.Base
        
        # Recalculate file offsets based upon relative virtual addresses
        if ($OnDisk) {
            $AddressOfNamePtr = Convert-RVAToFileOffset $AddressOfNamePtr
            $NameOrdinalAddrPtr = Convert-RVAToFileOffset $NameOrdinalAddrPtr
            $AddressOfFunctionsPtr = Convert-RVAToFileOffset $AddressOfFunctionsPtr
        }

        if ($NumFunctions -gt 0) {
        
            # Create an empty hash table that will contain indices to exported functions and their RVAs
            $FunctionHashTable = @{}
        
            foreach ($i in 0..($NumFunctions - 1))
            {
                
                $RvaFunction = [System.Runtime.InteropServices.Marshal]::ReadInt32($AddressOfFunctionsPtr.ToInt64() + ($i * 4))
                # Function is exported by ordinal if $RvaFunction -ne 0. I.E. NumberOfFunction != the number of actual, exported functions.
                if ($RvaFunction) { $FunctionHashTable[[Int]$i] = $RvaFunction }
                
            }
            
            # Create an empty hash table that will contain indices into RVA array and the function's name
            $NameHashTable = @{}
            
            foreach ($i in 0..($NumNames - 1))
            {
            
                $RvaName = [System.Runtime.InteropServices.Marshal]::ReadInt32($AddressOfNamePtr.ToInt64() + ($i * 4))
                $FuncNameAddr = [IntPtr] ($PEBaseAddr.ToInt64() + $RvaName)
                if ($OnDisk) { $FuncNameAddr= Convert-RVAToFileOffset $FuncNameAddr }
                $FuncName = [System.Runtime.InteropServices.Marshal]::PtrToStringAnsi($FuncNameAddr)
                $NameOrdinal = [Int][System.Runtime.InteropServices.Marshal]::ReadInt16($NameOrdinalAddrPtr.ToInt64() + ($i * 2))
                $NameHashTable[$NameOrdinal] = $FuncName
                
            }
            
            foreach ($Key in $FunctionHashTable.Keys)
            {
                $Result = @{}
                
                if ($NameHashTable[$Key]) {
                    $Result['FunctionName'] = $NameHashTable[$Key]
                } else {
                    $Result['FunctionName'] = ''
                }
                
                if (($FunctionHashTable[$Key] -ge $ExportDirLow) -and ($FunctionHashTable[$Key] -lt $ExportDirHigh)) {
                    $ForwardedNameAddr = [IntPtr] ($PEBaseAddr.ToInt64() + $FunctionHashTable[$Key])
                    if ($OnDisk) { $ForwardedNameAddr = Convert-RVAToFileOffset $ForwardedNameAddr }
                    $ForwardedName = [System.Runtime.InteropServices.Marshal]::PtrToStringAnsi($ForwardedNameAddr)
                    # This script does not attempt to resolve the virtual addresses of forwarded functions
                    $Result['ForwardedName'] = $ForwardedName
                } else {
                    $Result['ForwardedName'] = ''
                }
                
                $Result['Ordinal'] = "0x$(($Key + $Base).ToString('X4'))"
                $Result['RVA'] = "0x$($FunctionHashTable[$Key].ToString("X$($BinaryPtrWidth*2)"))"
                #$Result['VA'] = "0x$(($FunctionHashTable[$Key] + $PEBaseAddr.ToInt64()).ToString("X$($BinaryPtrWidth*2)"))"
                
                $Export = New-Object PSObject -Property $Result
                $Export.PSObject.TypeNames.Insert(0, 'Export')
                
                $Export
                
            }
            
        } else {  Write-Verbose 'Module does not export any functions.' }

    }

    function Get-Imports()
    {
        if ($NTHeader.OptionalHeader.DataDirectory[1].VirtualAddress -eq 0) {
            Write-Verbose 'Module does not contain any imports'
            return
        }
    
        $FirstImageImportDescriptorPtr = [IntPtr] ($PEBaseAddr.ToInt64() + $NtHeader.OptionalHeader.DataDirectory[1].VirtualAddress)
        if ($OnDisk) { $FirstImageImportDescriptorPtr = Convert-RVAToFileOffset $FirstImageImportDescriptorPtr }
        $ImportDescriptorPtr = $FirstImageImportDescriptorPtr
        
        $i = 0
        # Get all imported modules
        while ($true)
        {
            $ImportDescriptorPtr = [IntPtr] ($FirstImageImportDescriptorPtr.ToInt64() + ($i * [System.Runtime.InteropServices.Marshal]::SizeOf([Type] [PE+_IMAGE_IMPORT_DESCRIPTOR])))
            $ImportDescriptor = [System.Runtime.InteropServices.Marshal]::PtrToStructure($ImportDescriptorPtr, [Type] [PE+_IMAGE_IMPORT_DESCRIPTOR])
            if ($ImportDescriptor.OriginalFirstThunk -eq 0) { break }
            $DllNamePtr = [IntPtr] ($PEBaseAddr.ToInt64() + $ImportDescriptor.Name)
            if ($OnDisk) { $DllNamePtr = Convert-RVAToFileOffset $DllNamePtr }
            $DllName = [System.Runtime.InteropServices.Marshal]::PtrToStringAnsi($DllNamePtr)
            $FirstFuncAddrPtr = [IntPtr] ($PEBaseAddr.ToInt64() + $ImportDescriptor.FirstThunk)
            if ($OnDisk) { $FirstFuncAddrPtr = Convert-RVAToFileOffset $FirstFuncAddrPtr }
            $FuncAddrPtr = $FirstFuncAddrPtr
            $FirstOFTPtr = [IntPtr] ($PEBaseAddr.ToInt64() + $ImportDescriptor.OriginalFirstThunk)
            if ($OnDisk) { $FirstOFTPtr = Convert-RVAToFileOffset $FirstOFTPtr }
            $OFTPtr = $FirstOFTPtr
            $j = 0
            while ($true)
            {
                $FuncAddrPtr = [IntPtr] ($FirstFuncAddrPtr.ToInt64() + ($j * [System.Runtime.InteropServices.Marshal]::SizeOf([Type] $ThunkDataStruct)))
                $FuncAddr = [System.Runtime.InteropServices.Marshal]::PtrToStructure($FuncAddrPtr, [Type] $ThunkDataStruct)
                $OFTPtr = [IntPtr] ($FirstOFTPtr.ToInt64() + ($j * [System.Runtime.InteropServices.Marshal]::SizeOf([Type] $ThunkDataStruct)))
                $ThunkData = [System.Runtime.InteropServices.Marshal]::PtrToStructure($OFTPtr, [Type] $ThunkDataStruct)
                $Result = @{ ModuleName = $DllName }
                
                if (([System.Convert]::ToString($ThunkData.AddressOfData, 2)).PadLeft(32, '0')[0] -eq '1')
                {
                    # Trim high order bit in order to get the ordinal value
                    $TempOrdinal = [System.Convert]::ToInt64(([System.Convert]::ToString($ThunkData.AddressOfData, 2))[1..63] -join '', 2)
                    $TempOrdinal = $TempOrdinal.ToString('X16')[-1..-4]
                    [Array]::Reverse($TempOrdinal)
                    $Ordinal = ''
                    $TempOrdinal | ForEach-Object { $Ordinal += $_ }
                    $Result['Ordinal'] = "0x$Ordinal"
                    $Result['FunctionName'] = ''
                }
                else
                {
                    $ImportByNamePtr = [IntPtr] ($PEBaseAddr.ToInt64() + [Int64]$ThunkData.AddressOfData + 2)
                    if ($OnDisk) { $ImportByNamePtr = Convert-RVAToFileOffset $ImportByNamePtr }
                    $FuncName = [System.Runtime.InteropServices.Marshal]::PtrToStringAnsi($ImportByNamePtr)
                    $Result['Ordinal'] = ''
                    $Result['FunctionName'] = $FuncName
                }
                
                $Result['RVA'] = "0x$($FuncAddr.AddressOfData.ToString("X$($BinaryPtrWidth*2)"))"

                if ($FuncAddr.AddressOfData -eq 0) { break }
                if ($OFTPtr -eq 0) { break }
                
                $Import = New-Object PSObject -Property $Result
                $Import.PSObject.TypeNames.Insert(0, 'Import')
                
                $Import
                
                $j++
                
            }
            
            $i++
            
        }

    }
    
    function Convert-RVAToFileOffset([IntPtr] $Rva)
    {
    
        foreach ($Section in $SectionHeaders) {
            if ((($Rva.ToInt64() - $PEBaseAddr.ToInt64()) -ge $Section.VirtualAddress) -and (($Rva.ToInt64() - $PEBaseAddr.ToInt64()) -lt ($Section.VirtualAddress + $Section.VirtualSize))) {
                return [IntPtr] ($Rva.ToInt64() - ($Section.VirtualAddress - $Section.PointerToRawData))
            }
        }
        
        # Pointer did not fall in the address ranges of the section headers
        return $Rva
        
    }
    
    $PEFields = @{
        Module = $ModuleName
        DOSHeader = $DosHeader
        PESignature = $NTHeader.Signature
        FileHeader = $NTHeader.FileHeader
        OptionalHeader = $NTHeader.OptionalHeader
        SectionHeaders = $SectionHeaders
        Imports = Get-Imports
        Exports = Get-Exports
    }
    
    if ($Ondisk) {
        $Handle.Free()
    } else {
        # Free memory allocated for the PE header
        [System.Runtime.InteropServices.Marshal]::FreeHGlobal($PEBaseAddr)
    }
    
    $PEHeader = New-Object PSObject -Property $PEFields
    $PEHeader.PSObject.TypeNames.Insert(0, 'PEHeader')

    $ScriptBlock = {
        $SymServerURL = 'http://msdl.microsoft.com/download/symbols'
        $FileName = $this.Module.Split('\')[-1]
        $Request = "{0}/{1}/{2:X8}{3:X}/{1}" -f $SymServerURL, $FileName, $this.FileHeader.TimeDateStamp, $this.OptionalHeader.SizeOfImage
        $Request = "$($Request.Substring(0, $Request.Length - 1))_"
        $WebClient = New-Object Net.WebClient
        $WebClient.Headers.Add('User-Agent', 'Microsoft-Symbol-Server/6.6.0007.5')
        Write-Host "Downloading $FileName from the Microsoft symbol server..."
        $CabBytes = $WebClient.DownloadData($Request)
        $CabPath = "$PWD\$($FileName.Split('.')[0]).cab"
        Write-Host "Download complete. Saving it to $("$(Split-Path $CabPath)\$FileName")."
        [IO.File]::WriteAllBytes($CabPath, $CabBytes)
        $Shell = New-Object -Comobject Shell.Application
        $CabFile = $Shell.Namespace($CabPath).Items()
        $Destination = $Shell.Namespace((Split-Path $CabPath))
        $Destination.CopyHere($CabFile)
        Remove-Item $CabPath -Force
    }

    $PEHeader = Add-Member -InputObject $PEHeader -MemberType ScriptMethod -Name DownloadFromMSSymbolServer -Value $ScriptBlock -PassThru -Force

    return $PEHeader
    

}
}
'@

New-Item -Force -ItemType Directory -Path "$env:ProgramFiles\PowerShell\7\Modules\Get-PEHeader"
$script |Out-File "$env:ProgramFiles\PowerShell\7\Modules\Get-PEHeader\Get-PEHeader.psm1"
}
