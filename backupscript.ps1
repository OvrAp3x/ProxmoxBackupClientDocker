###Backupscript

#Start logging
start-transcript

#Import ENV's
Import-CliXml /env-vars.clixml | % { Set-Item "env:$($_.Name)" $_.Value }

#Check if task is already running
if(test-path /running){exit;stop-transcript}
else {get-date > /running}

##Run pre script
if($ENV:PRESCRIPT){
  write-host "Running Pre-script from $($ENV:PRESCRIPT)"
  . $ENV:PRESCRIPT
}
if($ENV:CIFS_UNC){
  . /cifs.ps1
}


##Run backupjob

if($ENV:PBS_PASSWORD -and $ENV:PBS_REPOSITORY -and $ENV:ARCHIVENAME){
  #create args
  $backupargs="backup $ENV:ARCHIVENAME.pxar:$ENV:SOURCEDIR"
  if($ENV:ENCRYPTIONKEY){
    $backupargs+=" --keyfile $ENV:ENCRYPTIONKEY"
  }
  #start the backup process
  Start-Process -Args $backupargs -FilePath proxmox-backup-client
}
else {
  write-host "MISSING VARIABLES"
}

##Run post script
if($ENV:POSTSCRIPT){
  write-host "Running Post-script from $($ENV:POSTSCRIPT)"
  . $ENV:POSTSCRIPT
}


#Remove flag to show that task is running
remove-item /running -force
stop-transcript
