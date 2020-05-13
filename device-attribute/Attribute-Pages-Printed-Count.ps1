try
{
        # Sets Custom Attribute 3 with the total number of pages printed
        # Set new environment for Action Extensions Methods 
        Add-Type -Path $env:STEELCENTRAL_ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll
               
#We define a Variable call TotalPages with a value of zero
$TotalPages=0

#We create a variable called "Results" that contains the output of the below command
$Results = Get-WinEvent -FilterHashTable @{LogName="Microsoft-Windows-PrintService/Operational"; ID=307} | Where-Object Message -Notlike '*Microsoft Print to PDF*'
#Debug to check the "Results" variable
#$Results

#Create a Loop for each reasult to parse the output and gather the Page Count properties and sort into Respective Alias
ForEach($Result in $Results){
  $ProperyData = [xml]$Result.ToXml()
    #Here we map each property to the variable of ProperyData 
    $hItemDetails = New-Object -TypeName psobject -Property @{
      UserName = $ProperyData.Event.UserData.DocumentPrinted.Param3
      MachineName = $ProperyData.Event.UserData.DocumentPrinted.Param4
      PageCount = $ProperyData.Event.UserData.DocumentPrinted.Param8
      TimeCreated = $Result.TimeCreated
      }
#We tally the PageCount to Total Pages
$TotalPages += $hItemDetails.PageCount
}

#Output the contents of the TotalPages Variable
echo $TotalPages

[ActionExtensionsMethods.PowershellPluginMethods]::SetAttributeValueString("Custom Attribute 3","$TotalPages" + " Pages") 
}

catch
{
 #[ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}
