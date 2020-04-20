<#
.Synopsis
   Aternity - Sample script to report on some health issue
.DESCRIPTION
	Identify <something> as a health event
 	
	References:
	* https://www.aternity.com
	* https://help.aternity.com/csh?Product=latest&topicname=admin_script_health_event.html
.EXAMPLE
   Information need to be provided to Aternity-SaaSAdmin@aternity.com to add this attribute: 
   Name of the health event:
   Category and Subcategory:
   Severity: 
   Component / sub component types (if used):
   Run the script in the System account or user account (elavated): 
#>

try
{
    # Load Agent Module 
    Add-Type -Path $env:STEELCENTRAL_ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll

    [bool]$raiseHealthEvent = 0

    # Logic to identify the health issue - assume that health event identified
         [bool]$raiseHealthEvent = 1

    # Check if health issue identified in order to ask the agent to create a health event only if relevant
	if ($raiseHealthEvent -eq $true)
    {
        [ActionExtensionsMethods.PowershellPluginMethods]::SetEventOccurred()
        [ActionExtensionsMethods.PowershellPluginMethods]::SetComponent("component name")
    }
    Else
    {
        # Just do nothing since health event should not be created
    }
}
catch
{
	[ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}
