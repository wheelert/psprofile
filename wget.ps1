#created by Thomas Wheeler wheelert@airtop.net
Function wget{
[CmdletBinding()]
 Param (
    [Parameter(Mandatory=$True, HelpMessage="ERROR: You must provide a URL!", Position=1, ValueFromPipeline = $true)]
        [string]$url,

    [Parameter(Position=2)]
        [alias("o")]
        [string]$file,

    [Parameter(Position=3)]
        [alias("DD")]
        [string]$DstDir = $env:HOMEDRIVE + "\" + $env:HOMEPATH + "\Downloads\"       
 )

Begin{
    #get Filename
    if($file.length -eq 0){
        $file = split-path $url -Leaf;
    }

    $file = [regex]::replace($file, '[^a-zA-Z0-9\s.-_]','');


    $directorypath = $DstDir;
    $path = $directorypath + '\' + $file;
    Write-Host -foregroundcolor green "Downloading " $path;

}

Process{
    $client = new-object System.Net.WebClient
    $client.DownloadFileAsync( $url, $path);
    $i = 0;
    Do{
          $_sec = $i;
          $_min = 00;
          $_hrs = 00;

            if($i > 60){
                $_min++;
                $_sec = 00;
            }
            
            if($_min > 60){
                $_hrs++;
                $_min = 00;
            }
              
          if(Get-Item $path){   
          $_status = "Downloading "+ "{0:N0}" -f ((Get-Item $path).Length / 1024)+"Mb Elapse: " + $_hrs +":" + $_min + ":" + $_sec;
          $_activity = "Downloading " + $file;
           Write-Progress -Activity $_activity -PercentComplete -1 -Status $_status;
           Start-Sleep -Seconds 1;
            
          } 

          $i++;
          
    } while($client.IsBusy)


}

End{
  [console]::Beep();
  Write-Host -foregroundcolor yellow "Download Completed in: " $_hrs "hrs " $_min "mins " $_sec "sec";
}
}