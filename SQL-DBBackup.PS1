function SQL-DBBackup {
#
#
#
#
######### OPTIONS ########################
    
 param(
    [string]$backupName = "BACKUP",
    [Parameter(Mandatory=$True)]
    [string]$server = "VISION-SQL01",
    [Parameter(Mandatory=$True,HelpMessage="Databases to backup seperated by ,")]
    [System.Collections.Generic.List[System.Object]]$database,
    [string]$backupDir = "c:\software\Backups\",
    [bool]$systemDatabases = $true
 )

$date = get-date -UFormat "%Y%m%d"
$backupName = "$backupName-$date"




##########################################



$tmpDir = "$backupDir\tmp\"
$tmpFile = "$tmpDir$filename"

#Add system databases to the backup
if($systemDatabases -eq $true){
    $database.Add("master") | Out-Null
    $database.Add("model") | Out-Null
    $database.Add("msdb") | Out-Null
}


function MSSQL-Backup {
    param(
        [string] $dataSource = "SERVER",
        [string] $database = "DATABASE",
        [string] $backupFile = "c:\temp\$database.bak"
      )

    $date = get-date -UFormat "%Y%m%d"

    $sqlCommand = "BACKUP DATABASE $database TO DISK='$backupFile' WITH STATS, COPY_ONLY, DESCRIPTION = '$database backup on $date ' "

    $connectionString = "Data Source=$dataSource; " +
            "Integrated Security=SSPI; " +
            "Initial Catalog=$database"

    $connection = new-object system.data.SqlClient.SQLConnection($connectionString)
 
    $connection.Open()


    $sqlcmd = new-object "System.data.sqlclient.sqlcommand"
    $sqlcmd.connection = $connection
    $sqlcmd.CommandTimeout = 600000
    $sqlcmd.CommandText = $sqlCommand
    $rowsAffected = $sqlcmd.ExecuteNonQuery()

    $connection.Close()

}

function checkDotNet(){


$vers = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -recurse |
Get-ItemProperty -name Version,Release -EA 0 |
Where { $_.PSChildName -match '^(?!S)\p{L}'} |
Select PSChildName, Version, Release | sort-object Version | ForEach-Object {

    $req = [version]"4.5"
    $v = [version]$_.Version
    $name = $_.PSChildName
    $r = $_.Release


    if($v -gt $req){
        
        $go = $true
        
    }else{
        
        $go = $false
    }


}
     
       if($go -eq $false){
           Write-host -ForegroundColor yellow "ERROR: .NET $req or higher is required!"
           exit
       }




}

function createDirZip{

    param(
        [string]$path,
        [string]$filename   
    )
 
    if(Test-path -path $filename){
    
        Write-host -ForegroundColor Red "$filename Already Exists!"
        break
    }

    if(Test-Path -path $path){
        Add-Type -Assembly "System.IO.Compression.FileSystem" ;
       
        [System.IO.Compression.ZipFile]::CreateFromDirectory($path, $filename) ;

        Write-Host -ForegroundColor Green "backup has been compressed to $filename"
    }


}


if(!(test-Path $tmpDir)){
    Write-Host "Creating $tmpDir"
    New-Item $tmpDir -ItemType directory | Out-Null
}else{
    Write-Host "Recreating $tmpDir"
    Remove-Item $tmpDir -recurse 
    New-Item $tmpDir -ItemType directory | Out-Null
}

## Check for .NET
checkDotNet

foreach($db in $database){
    $filename = "$db-$date.bak"
    $backupFile = "$tmpDir$filename"

    Write-Host "backing up Database $db ..."
    MSSQL-Backup -dataSource $server -database $db -backupFile $backupFile
   
}

createDirZip $tmpDir "$backupdir$backupName.zip"

Write-Host "Cleaning up ...."
Remove-Item $tmpDir -recurse


}