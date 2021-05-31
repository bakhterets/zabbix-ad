param ([Parameter(Position=0, Mandatory=$False)][string]$action,
       [Parameter(Position=1, Mandatory=$False)][string][string]$Partner,
       [Parameter(Position=2, Mandatory=$False)][string][string]$Parameter
       )

switch ($action)
# receive the partners list
{ 
"discovery" {
    $adpartner = (Get-ADReplicationPartnerMetadata -target $env:COMPUTERNAME).partner | ForEach-Object {[regex]::split($_,",CN=")[1]}
    convertto-json @{"data"= [array]($adpartner | select-object @{l="{#PARTNER}";e={$_}})}
}
#
"value" {
    (Get-ADReplicationPartnerMetadata -target $env:COMPUTERNAME -Filter {Partner -like "*$Partner*"}).$Parameter
}
# convert the time value into the form: dd-MM-yyyy HH:mm:ss
"lastreplicationtime" {
    $time=(Get-ADReplicationPartnerMetadata -target $env:COMPUTERNAME -Filter {Partner -like "*$Partner*"}).$Parameter
    (Get-Date $time -Format "dd-MM-yyyy HH:mm:ss")
}
# convert the time value into the form: dd-MM-yyyy HH:mm:ss
"firstfailuretime" {
    $time=(Get-ADReplicationFailure -target $env:COMPUTERNAME -Filter {Partner -like "*$Partner*"}).$Parameter
    if ($time -eq $null) {"Active Directory replication errors not found"} 
    else {(Get-Date $time -Format "dd-MM-yyyy HH:mm:ss")}
}
# value "-1" was created for converting to text message in zabbix
"failure" {
    if ($Parameter -eq "FailureType") {$fail=(Get-ADReplicationFailure -target $env:COMPUTERNAME -Filter {Partner -like "*$Partner*"}).$Parameter.value__}
    else {$fail=(Get-ADReplicationFailure -target $env:COMPUTERNAME -Filter {Partner -like "*$Partner*"}).$Parameter}
	if ($fail -eq $null) {"-1"} else {$fail}
}
default {"Script error"}
}