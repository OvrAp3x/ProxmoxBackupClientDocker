#To be called from backupscript.ps1


$Errorstrings="error","warning","fail"

$transcript=get-content /root/$now

##Check for error text

$errorlines=$transcript | Select-String -Pattern $Errorstrings


if($env:ELASTIC_SERVER){
    
    $data=@{
      log=$transcript
      status=$status
      errorlines=$errorlines
    } | convertto-json
    dbinfo=@{
        server = "$ENV:ELASTIC_SERVER"
        user = "$ENV:ELASTIC_USERNAME"
        password = "$ENV:ELASTIC_PASSWORD"
        protocol = "$ENV:ELASTICPROTOCOL"
        index = "$ENV:ELASTIC_INDEX"
    }
    #if index does not exist create it
    if(Get-Elasticindex @dbinfo ){}
    else{
        New-Elasticindex @dbinfo
    sleep 10
    }
    Add-elasticdata @dbinfo -body $data
    
}
