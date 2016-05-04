function Wait-ComputerPort
{
     param ([string]$ComputerName,[int]$Port='3389')
 
    $sock = new-object System.Net.Sockets.Socket `
        -ArgumentList $([System.Net.Sockets.AddressFamily]::InterNetwork), `
                      $([System.Net.Sockets.SocketType]::Stream), `
                      $([System.Net.Sockets.ProtocolType]::Tcp)
    try {
        $sock.Connect($ComputerName,$Port)
        $sock.Connected
        $sock.Close()
        }
    catch {
        if ($_.exception -like '*Exception calling "Connect" with "2" argument(s): "No connection could be made because the target machine actively refused it*')
            {
            Switch ($Port){
            3389 {$Protocol = 'RDP'; break}
            80 {$Protocol = 'HTTP'; break}
            443 {$Protocol = 'HTTPS'; break}
            9 {$Protocol = 'Wake-On-LAN'; break}
            20 {$Protocol = 'FTP'; break}
            22 {$Protocol = 'SSH'; break}
            23 {$Protocol = 'Telnet'; break}
            25 {$Protocol = 'SMTP'; break}
            53 {$Protocol = 'DNS'; break}
            Default {$protocol = $Port; break}
            }
            return "Error connecting to system: Connection Refused: Is $Protocol enabled?"
            }
        Wait-ComputerPort = $false
        }
}
