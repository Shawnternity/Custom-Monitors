try
{
    Add-Type -Path $env:STEELCENTRAL_ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll  
    $AtStatus = $false
    $AtDetails = "Current Statuses: ["
    if (Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -ErrorAction Ignore) { $AtDetails+=" RebootPending;"; $AtStatus = $true }
    if (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -ErrorAction Ignore) { $AtDetails+=" RebootRequired;"; $AtStatus = $true }
    if (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations -ErrorAction Ignore) { $AtDetails+=" PendingFileRenameOperations;"; $AtStatus = $true }
    try 
    { 
        $util = [wmiclass]"\\.\root\ccm\clientsdk:CCM_ClientUtilities"
        $status = $util.DetermineIfRebootPending()
        if(($null -ne $status) -and $status.RebootPending)
        {
            $AtDetails+=" RebootPending (WMI);"; $AtStatus = $true
        }
    }
    catch{}
    
    if ($AtStatus -eq $true )
    {
        $AtDetails+=" ]"
        [ActionExtensionsMethods.PowershellPluginMethods]::SetComponent("System")
        [ActionExtensionsMethods.PowershellPluginMethods]::SetDetails($AtDetails)
        [ActionExtensionsMethods.PowershellPluginMethods]::SetComponentType("Operation System")
        [ActionExtensionsMethods.PowershellPluginMethods]::SetEventOccurred()
    }
    else
    {
        "Do nothing since not health event should be generated"
    }
}
catch
{
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}