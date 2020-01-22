#
#
# Clean Windows temp folders 
#
#
#
#
#
########## OPTIONS ##################

Function CleanPC{
[CmdletBinding()]
Param (
        [bool]$empty_recycle = $true,
        [DateTime]$limit = (Get-Date).AddDays(-1)  
)


$folders = @(“C:\Windows\Temp\*”, “C:\Windows\Prefetch\*”, 
    “C:\Documents and Settings\*\Local Settings\temp\*”, 
    “C:\Users\*\Appdata\Local\Temp\*”,
    "C:\Users\*\AppData\Local\Temp\Temporary Internet Files\Content.IE5\*",
    "C:\Users\*\AppData\Local\Google\Chrome\User Data\Default\Cache\*",
    "C:\Users\*\AppData\Local\Spotify\Data\*",
    "C:\Users\*\AppData\Local\Google\Chrome\User Data\Default\Cache\*",
    "C:\Users\*\AppData\Local\Microsoft\Office\*\OfficeFileCache\*",
    "C:\Users\*\AppData\Local\Microsoft\Office\*\Lync\Tracing\*"
    )

$exclude = @("C:\Users\twheeler\AppData\Local\Microsoft\Office\*\Lync\Tracing\WPPMedia","C:\Users\twheeler\AppData\Local\Microsoft\Office\*\Lync\Tracing\OCAddin")


#####################################

$total = 0;

function dataOut {
param(
    [string]$path,
    [string]$size
)

  $size = "{0:N2}" -f ($size / 1MB)  

  $obj = New-Object PSObject
  $obj | Add-Member NoteProperty Size($size + " MB")   
  $obj | Add-Member NoteProperty Path($path)

  $obj | fl
}  


write-host -ForegroundColor Green "removing files created before" $limit

foreach($item in $folders){

    if( (test-path -Path $item) -eq $true){

     
        $colItems = (Get-ChildItem $item -ErrorAction SilentlyContinue | Measure-Object -property length -sum -ErrorAction SilentlyContinue) 
        $total = $total + $colItems.sum
     
        dataOut $item $colItems.sum
        Get-ChildItem -Path $item -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue -Exclude $exclude
        
      

    }


}

$totalsize = "{0:N2}" -f ($total / 1MB) + " MB"
Write-host "-----------------------------------------------------------"
write-host -ForegroundColor Yellow "  Cleaned a total of $totalsize"
Write-host "-----------------------------------------------------------"

Write-output "-----------------------------------------------------------"

if($empty_recycle -eq $true){
    Write-output "Emptying recycle bin...."

    if( (test-path 'C:\$Recycle.Bin') -eq $true){
        Remove-Item -force -Recurse 'C:\$Recycle.Bin'
    }


}

Clear-EventLog -log system,application,security 




}