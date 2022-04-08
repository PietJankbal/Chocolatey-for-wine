#https://stackoverflow.com/questions/53522016/how-to-measure-tcp-and-icmp-connection-time-on-remote-machine-like-ping

function Ping {
    <#
        .SYNOPSIS
            Implementation PS du ping + tcp-Ping
        .DESCRIPTION
            retourne les temps de reponce ICMP (port 0) et TCP (port 1-65535)
        .PARAMETER DestNode
            HostName ou IP a tester,
            pour le HostName une resolution DNS est faite a chaque boucle
        .PARAMETER ports
            Liste des ports TCP-IP a tester, le port 0 pour l'ICMP
        .PARAMETER timeout
            TimeOut des test individuel
        .PARAMETER loop
            nombre de boucle a effectuer, par defaut Infini
        .PARAMETER Intervale
            intervale entre chaque series de test
        .PARAMETER ComputerName
            permet de faire ce Ping en total remote,
            si ComputerName est fournis, joignable et different de localhost alors c'est lui qui executera ce code et retourne le resultat
            Requiere "Enable-PSRemoting -force"
        .EXAMPLE
            Ping sur ICMP + TCP:53,80,666 timeout 80ms (par test)
            Ping 8.8.8.8 -ports 0,53,80,666 -timeout 80 | ft
        .EXAMPLE
            3 ping en remote depuis le serveur vdiv05 sur ICMP,3389,6516 le tous dans une jolie fenetre
            ping 10.48.50.27 0,3389,6516 -ComputerName vdiv05 -count 3 | Out-GridView
        .NOTES
            Alban LOPEZ 2018
            alban.lopez @t gmail.com
        #>
    Param(
        [string]$DestNode = 'vps.opt2', 
        [ValidateRange(0, 65535)]
        [int[]]$ports = @(0, 22, 135), 
        [ValidateRange(0, 2000)]
        [int]$timeout = 200,
        [alias("count")][int32]$loop = [int32]::MaxValue, # 68 annees !
        [ValidateSet(250, 500, 1000, 2000, 4000, 10000)]
        [int]$Intervale = 2000,
        $size = 1Kb,
        $ComputerName = $null
    )
    begin {
        if ($computerName -and $computerName -notmatch "^(\.|localhost|127.0.0.1)$|^$($env:computername)" -and (Test-TcpPort -DestNodes $computerName -ConfirmIfDown)) {
            $pingScriptBlock = Include-ToScriptblock -functions 'write-logStep', 'write-color', 'Write-Host', 'ping', 'Test-TcpPort', 'Include-ToScriptblock'
        } else {
            $ComputerName = $null
            $ObjPing = [pscustomobject]@{
                DateTime   = $null
                IP         = $null
                Status     = $null
                hasChanged = $null
            }
            $ObjPings = $test = @()
            if (!$ports) {$ports = @(0)}
            $Ports | ForEach-Object {
                if ($_) {
                    # TCP
                    $ObjPing | Add-Member -MemberType NoteProperty -Name "Tcp-$_" -Value $null
                    $test += "Tcp-$_"
                }
                else {
                    # ICMP
                    $ping = new-object System.Net.NetworkInformation.Ping
                    $ObjPing | Add-Member -MemberType NoteProperty -Name ICMP -Value $null

                    $ObjPing | Add-Member -MemberType NoteProperty -Name 'ICMP-Ttl' -Value $null
                    # $ObjPing | Add-Member -MemberType NoteProperty -Name 'ICMP-Size' -Value $size
                    $buffer = [byte[]](1..$size | ForEach-Object {get-random -Minimum 20 -Maximum 255})
                    $test += "ICMP ($size Octs)"
                }
            }
            # Write-LogStep -prefixe 'L.%Line% Ping' "Ping [$DestNode] ", ($test -join(' + ')) ok
        }
    }
    process {
        if(!$ComputerName){
            While ($loop--) {
                $ms = (Measure-Command {
                    try {
                        $ObjPing.DateTime = (get-date)
                        $ObjPing.status = $ObjPing.haschanged = $null
                        $ObjPing.IP = [string][System.Net.Dns]::GetHostAddresses($DestNode).IPAddressToString
                        #Write-LogStep -prefixe 'L.%Line% Ping' "Ping $DestNode", $ObjPing.IP wait
                            foreach ($port in $ports) {
                                if ($port) {
                                    # TCP
                                    $ObjPing."Tcp-$port" = $iar = $null
                                    try {
                                        $tcpclient = new-Object system.Net.Sockets.TcpClient # Create TCP Client
                                        $iar = $tcpclient.BeginConnect($ObjPing.IP, $port, $null, $null) # Tell TCP Client to connect to machine on Port
                                        $timeMs = (Measure-Command {
                                                $wait = $iar.AsyncWaitHandle.WaitOne($timeout, $false) # Set the wait time
                                            }).TotalMilliseconds
                                    }
                                    catch {
                                        # Write-verbose $_
                                    }
                                    # Write-LogStep -prefixe 'L.%Line% Ping' "Tcp-$port", $x.status, $timeMs ok
                                    # Check to see if the connection is done
                                    if (!$wait) {
                                        # Close the connection and report timeout
                                        $ObjPing."Tcp-$port" = 'TimeOut'
                                        $tcpclient.Close()
                                    }
                                    else {
                                        try {
                                            $ObjPing."Tcp-$port" = [int]$timeMs
                                            $ObjPing.status ++
                                            # Write-LogStep -prefixe 'L.%Line% Ping' 'TCP ', "$($ObjPing."Tcp-$port") ms" ok
                                            $tcpclient.EndConnect($iar) | out-Null
                                            $tcpclient.Close()
                                        }
                                        catch {
                                            # $ObjPing."Tcp-$port" = 'Unknow Host'
                                        }
                                    }
                                    if ($tcpclient) {
                                        $tcpclient.Dispose()
                                        $tcpclient.Close()
                                    }
                                }
                                else {
                                    # ICMP
                                    $ObjPing.ICMP = $ObjPing."ICMP-Ttl"  = $null # $ObjPing."ICMP-Size"
                                    try {
                                        $x = $ping.send($ObjPing.IP, $timeOut, $Buffer)
                                        if ($x.status -like 'Success') {
                                            $ObjPing."ICMP" = [int]$x.RoundtripTime
                                            $ObjPing."ICMP-Ttl" = $x.Options.Ttl
                                            # $ObjPing."ICMP-Size" = $x.Buffer.Length
                                            $ObjPing.status ++
                                            # Write-LogStep -prefixe 'L.%Line% Ping' 'ICMP ', "$($x.RoundtripTime) ms", $x.Options.Ttl, $x.Buffer.Length ok
                                        }
                                        else {
                                            # Write-LogStep -prefixe 'L.%Line% Ping' 'ICMP ', "$($x.RoundtripTime) ms", $x.Options.Ttl, $x.Buffer.Length Warn
                                            $ObjPing."ICMP" = $x.status
                                            $ObjPing."ICMP-Ttl" = $ObjPing."ICMP-Size" = '-'
                                        }
                                    }
                                    catch {
                                        # $ObjPing.ICMP =  'Unknow Host'
                                    }
                                }
                            }
                        }
                        catch {
                            # Write-LogStep -prefixe 'L.%Line% Ping' '', 'Inpossible de determiner le noeud de destination !' error
                            $ObjPing.Status = 0
                        }
                        $ObjPing.status = "$([int]([Math]::Round($ObjPing.status / $ports.count,2) * 100))%"
                        $ObjPing.hasChanged = !($ObjPing.Status -eq $last -and $ObjPing.IP -eq $IP )
                        $last = $ObjPing.Status
                        $IP = $ObjPing.IP
                        ipconfig /flushdns
                    }).TotalMilliseconds

                $ObjPings += $ObjPing
                $ObjPing

                if ($loop -and $Intervale - $ms -gt 0) {
                    start-sleep -m ($Intervale - $ms)
                }
            }
        }
    }
    end {
        if ($computerName) {
            $pingScriptBlock = $pingScriptBlock | Include-ToScriptblock -StringBlocks "Ping -DestNode $DestNode -ports $($ports -join(',')) -timeout $timeout -loop $loop -Intervale $Intervale"
            Invoke-Command -ComputerName $ComputerName -ScriptBlock $pingScriptBlock | Select-Object -Property * -ExcludeProperty RunspaceID
        }
    }
}