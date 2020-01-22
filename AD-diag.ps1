#
# Quick Workstation checks for common AD issues
#
# Created by Thomas Wheeler (wheelert@wheelerwire.com)
#
#

 Function Test-CommandExists{

        Param ($command)
        $oldPreference = $ErrorActionPreference
        $ErrorActionPreference = 'stop'

     Try {if(Get-Command $command){"$command exists"}}

     Catch {Write-Host -ForegroundColor red "Cant find $command skipping...."; RETURN $false}
     
     Finally {$ErrorActionPreference=$oldPreference}

} #end function test-CommandExists

Function AD-diag{
[CmdletBinding()]
    

param (
    [string]$domain = $( 
                        $def = $env:USERDNSDOMAIN
                        if(($result = Read-Host "AD Domain default value [$def]") -eq ''){$def}else{$result} 
                    )
 )



Begin{
    
    Write-Host -ForegroundColor Yellow "Generating basic AD report for $env:USERNAME on $env:COMPUTERNAME"

    write-host -ForegroundColor Green "[Domain controlers for $domain]"
    nltest /dclist:$domain 

    write-host -ForegroundColor Green "[Details for the DC we are authenticated to]"
    nltest /dsgetdc:$domain

    write-host -ForegroundColor Green "[Applied group policy settings & security groups]"
    gpresult -R

    write-host ([Environment]::NewLine)

    If(Test-CommandExists Get-ADdomain){
     
      write-host -ForegroundColor Green "[Getting AD specific details]"
      get-ADdomain
     
    }
   
    
    

}

Process{}
End{
    [console]::Beep();
    Write-Host -ForegroundColor Yellow "Generation complete!"
}


}

