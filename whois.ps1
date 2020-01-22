#
# Whois for the power shell
# created by Thomas Wheeler
# wheelert@airtop.net 
#
#created by Thomas Wheeler wheelert@wheelerwire.com
Function whois{
[CmdletBinding()]
 Param (
    [Parameter(Mandatory=$True, HelpMessage="ERROR: You must provide a Hostname or IP!", Position=1, ValueFromPipeline = $true)]
        [string]$hostname,

    [Parameter(Position=2)]
        [alias("server")]
        [string]$_server      
 )

    $port = 43;
    $types = '.com','.org','.net','.edu';

    #servers
     $_server = "whois.internic.net";
     $_orgserver = "whois.pir.org"; 
     $_ipserver = "whois.arin.net";

    #check for Domain or IP
    foreach($val in $types){
    
        if($hostname.IndexOf($val) -eq -1){
           $_server = $_ipserver;
           break;
        }
    
    }

    #update to read txt file of TLD whois servers 
    if($hostname.IndexOf(".org") -gt 0){
        $_server = $_orgserver;
        Write-Host "ORG Server" $_orgserver;
    }

    if($hostname.IndexOf(".net") -gt 0){
        $_server = "whois.verisign-grs.com";
    }
    
    if($hostname.IndexOf(".com") -gt 0){
        $_server = "whois.verisign-grs.com";
    }

    if($hostname.IndexOf(".edu") -gt 0){
        $_server = "whois.verisign-grs.com";
    }

    if($hostname.IndexOf(".gov") -gt 0){
        $_server = "whois.nic.gov";
    }


	
	Write-Host "using Server" $_server;

    #make connection
    $socket = new-object Net.Sockets.TcpClient;
    $socket.Connect($_server, $port);

    if($socket.Connected){
        Write-Host "Connected!";
        $stream = $socket.GetStream();
    
        $writer = new-object System.IO.StreamWriter $stream;
        $line = $hostname;
                $writer.WriteLine($line); 
                $writer.Flush(); 
                Start-Sleep -m 5; 
                #read response
                $buffer = new-object System.Byte[] 1024;
                $encoding = new-object System.Text.AsciiEncoding;
                $stream.ReadTimeout = 1000;
           
                do{ 
                    try{ 
                        $read = $stream.Read($buffer, 0, 1024);
               
                        if($read -gt 0){ 
                            $foundmore = $true; 
                            $outputBuffer += ($encoding.GetString($buffer, 0, $read));
                        } 
                    }catch{ 
                        $foundMore = $false; 
                        $read = 0; 
                    } 
                }while($read -gt 0);
                #display results
                $outputBuffer;
        #close Socket        
        $socket.Close();
 
    }else{
        Write-Host "Unable to Connect!";
    }


}
