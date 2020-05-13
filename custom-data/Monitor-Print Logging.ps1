try
{
        # Uses Custom Attribute 5 to return "True" or "False" if Print Logging is enabled or Not.
        # Set new environment for Action Extensions Methods 
        Add-Type -Path $env:STEELCENTRAL_ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll

        # Check Logging status of Printing
        $Check=$(Get-WinEvent -ListLog Microsoft-Windows-PrintService/Operational).IsEnabled
        $Check

        #evaluate Check 
            if($Check -like 'False')  
            {
                [ActionExtensionsMethods.PowershellPluginMethods]::SetAttributeValueString("Custom Attribute 5","False")

            }
            else
            {
                [ActionExtensionsMethods.PowershellPluginMethods]::SetAttributeValueString("Custom Attribute 5","True")
            }

}
Catch
{
[ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}