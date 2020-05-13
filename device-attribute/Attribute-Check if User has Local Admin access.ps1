try
{
        # Set Custom Attribute 5 with either "Local Admin" or "Not Local Admin" based on the logic
        # Set new environment for Action Extensions Methods 
        Add-Type -Path $env:STEELCENTRAL_ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll
               
#Collect and create variable called Hostname
$Hostname=$env:computername
#$Hostname

#Collect and create variable called Results
$Results = (Get-LocalGroupMember -Group "Administrators").name | where {$_ -like '*\Administrator*'}
$Results = (Get-LocalGroupMember -Group "Administrators").name | where {$_ -icontains $Hostname}
$Results

#evaluate Results 
            if($Results -contains $Hostname)  
            {
                [ActionExtensionsMethods.PowershellPluginMethods]::SetAttributeValueString("Custom Attribute 5","Local Admin")

            }
            else
            {
                [ActionExtensionsMethods.PowershellPluginMethods]::SetAttributeValueString("Custom Attribute 5","Not Local Admin")
            }
}

catch
{
 #[ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}