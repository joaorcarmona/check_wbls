#CheckNLBNodeStatus.ps1
#
# Checks For NLB Node Status
#
#
#

Param(
  [Parameter(
    Mandatory=$True,
    Position=1)]
   [string]$computerName
) 

#Nagios ExitStatus
$stateOK = 0
$stateWarning = 1
$stateCritical = 2
$stateUnknown = 3 

#NLB Cluster Node Status
$nlb_stopped = 1005
$nlb_converging = 1006
$nlb_draning = 1009
$nlb_suspended = 1013

#get NLB status
$wmiResult = Get-WmiObject -Class MicrosoftNLB_Node  -namespace root\MicrosoftNLB | Select-Object ComputerName, __Server, statuscode, DedicatedIPAddress
 
 if ($computerName -eq $wmiResult.ComputerName){
    if ($wmiResult.statuscode -eq $nlb_stopped){
        $outputmsg = "CRITICAL - " + $wmiResult.__Server + " is stopped"
        $exitstatus = $stateCritical
    } elseif ($wmiResult.statuscode -eq $nlb_converging) {
        $outputmsg = "WARNING - " + $wmiResult.__Server + " is converging"
        $exitstatus = $stateWarning
    } elseif ($wmiResult.statuscode -eq $nlb_draning) {
        $outputmsg = "CRITICAL - " + $wmiResult.__Server + " is draining"
        $exitstatus = $stateCritical
    } elseif ($wmiResult.statuscode -eq $nlb_suspended) {
        $outputmsg = "CRITICAL - " + $wmiResult.__Server + " is suspended"
        $exitstatus = $stateCritical
    } else {
        $outputmsg = "OK - " + $wmiResult.__Server + " is OK"
        $exitstatus = $stateOK
    }
 
 } else { 
    $outputmsg = "UNKNOWN - "  + $wmiResult.__Server + " not member of NLB Cluster. The Cluster node is not " + $wmiResult.ComputerName + "?"
    $exitStatus = $stateUnknown
 }

Write-Host $outputmsg
exit $exitstatus
