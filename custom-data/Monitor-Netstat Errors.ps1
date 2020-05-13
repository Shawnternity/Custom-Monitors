try
{
        # Set new environment for Action Extensions Methods 
        Add-Type -Path $env:STEELCENTRAL_ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll

        # This script can be modified to be either Network Discards, Errors or ReAssemble Failures for a Health Check Measure where the value should be 0.
        # The Non-Unicast packets is a large counter used for test purposes only


        # Test Array for Validation Check
        [array]$netstat = netstat -e -s  | Select-String -Pattern 'Non-unicast packets'
        [array]$nup = $netstat[0]  -split '\s+'
        #$errors[0]
        #NUP Test = " + $nup[2]   # Test on a value that has > 0
 
        # Network Interface Errors
        [array]$netstat = netstat -e -s  | Select-String -Pattern Errors
        [array]$errors = $netstat[0]  -split '\s+'
        #RX Errors = " + $errors[1]   # Debug RX
        #TX Errors = " + $errors[2]   # Debug Tx

        # Network Interface Discards
        [array]$netstat = netstat -e -s  | Select-String -Pattern Discards
        [array]$discards = $netstat[0]  -split '\s+'
        #"RX Discards = " + $discards[1]  # Debug RX
        #"TX Discards = " + $discards[2]  # Debug TX

        # ReAssemble Failures in the IPv4 stats
        [array]$netstat = netstat -e -s  | Select-String -Pattern 'Reassembly Failures'
        [array]$reassembles = $netstat[0]  -split '\s+'
        #"Reassemble Failures = " + $reassembles[4]  # Debug Value
  
       if ($errors[1] -gt 0 -OR $errors[2] -gt 0)
       {
        [ActionExtensionsMethods.PowershellPluginMethods]::SetAttributeValueString("Custom Attribute 1",$errors[1]) 
       }   
    Else
    {
    }
}

catch
{
 [ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}
