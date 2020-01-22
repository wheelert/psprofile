#created by Thomas Wheeler wheelert@airtop.net
Function pass_gen{
[CmdletBinding()]
Param (
    [Parameter(HelpMessage="Provide a length", Position=1)]
        [int]$len   
)

    if($len -eq 0){
       Write-Warning "No Length Specified! Defaulting to 10 Characters";
       $len = 10;
    }

    $chars = "abcdefghijklmnopqrstuvwxyz123456789!#@*.^ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789";
    $data = $chars.ToCharArray();
    $rand = New-Object  System.Random
    $i = 1;
    $pass = "";

    while($i -le $len){
        $num = $rand.next(0,76);
        $pass += $data[$num];
        $i++;
    }

    Write-Host "";
    Write-Host -nonewline "Generated Password: ";
    Write-Host -foregroundcolor green $pass;
    Write-Host "";

}