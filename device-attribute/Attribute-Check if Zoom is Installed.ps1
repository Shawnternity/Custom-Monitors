try
{
        # Set the Custom Attribute 4 value of "Installed" or "Not Installed" depending on the presence of Zoom Install directory. This needs to run in context of "User"
        # Set new environment for Action Extensions Methods 
        Add-Type -Path $env:STEELCENTRAL_ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll

        # Check If Zoom is installed
        $Check=Test-Path "$($env:USERPROFILE)\AppData\Roaming\Zoom"
        #$Check

        #evaluate Check 
            if($Check -eq $false)  
            {
                [ActionExtensionsMethods.PowershellPluginMethods]::SetAttributeValueString("Custom Attribute 4","Not Installed")

            }
            else
            {
                [ActionExtensionsMethods.PowershellPluginMethods]::SetAttributeValueString("Custom Attribute 4","Installed")
            }

}
Catch
{
 [ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}