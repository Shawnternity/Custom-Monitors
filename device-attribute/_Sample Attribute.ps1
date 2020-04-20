<#
.Synopsis
   Aternity - Sample script to collect a custom attribute
.DESCRIPTION
	Collects "abc" to "custom attribute 3"
 	
	References:
	* https://www.aternity.com
	* https://help.aternity.com/csh?Product=latest&topicname=console_admin_custom_data.html
.EXAMPLE
   Information need to be provided to Aternity-SaaSAdmin@aternity.com to add this attribute: 
   Which custom attribute: 3
   Attribute nice name: 
   Run the script in the System account or user account (elavated): 
#>

try
{
    # Load Agent Module 
    Add-Type -Path $env:STEELCENTRAL_ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll

    # Logic to collect data for the custom attribute
	$data = "abc"
	
	[ActionExtensionsMethods.PowershellPluginMethods]::SetAttributeValueString("Custom Attribute 3",$data)
}
catch
{
	[ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}
