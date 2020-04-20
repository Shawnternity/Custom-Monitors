<#
.Synopsis
   Aternity - Sample script to collect custom data - measurements and descriptive data
.DESCRIPTION
	Collects 2 measurements and 2 contextuals (descriptive attribtues of those measurements).
 	
	References:
	* https://www.aternity.com
	* https://help.aternity.com/csh?Product=latest&topicname=console_uc_custom_data.html
.EXAMPLE
   Information need to be provided to Aternity-SaaSAdmin@aternity.com to add this attribute: 
   Which measurements - please provide their nice name to be displayed on dashboards. Up to 12 measurements in a single monitor are supported:
   Which contextuals - please provide their nice name to be displayed on dashboards. Up to 16 measurements in a single monitor are supported:
   Run the script in the System account or user account (elavated): 
#>

try
{
    # Load Aternity Module 
    Add-Type -Path $env:STEELCENTRAL_ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll

	# Logic to get data
	$str1 = "a"
	$str2 = "b"
	$ma1 = 1
	$ma2 = 2
	
    #Set the collected data to be sent to Aternity
    [ActionExtensionsMethods.PowershellPluginMethods]:: SetAttributeValueDouble("measurement1",$ma1)
    [ActionExtensionsMethods.PowershellPluginMethods]:: SetAttributeValueDouble("measurement2",$ma2)

    [ActionExtensionsMethods.PowershellPluginMethods]::SetAttributeValueString("contextual1",$str1)
    [ActionExtensionsMethods.PowershellPluginMethods]::SetAttributeValueString("contextual2",$str2)

}
catch
{
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}
