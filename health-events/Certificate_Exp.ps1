
<#
.Synopsis
   Aternity - Remediation Script: Certificate_Exp
.DESCRIPTION
	Script to raise a health event for certificates expiring within 7 days
	
	References:
	* https://www.riverbed.com
	* https://help.aternity.com/search?facetreset=yes&q=remediation
.EXAMPLE
   Deploy in Aternity (Configuration > Remediation > Add Action) 
   Action Name: Certificate About to Expire 7 days
   Description: Script to raise a health event for certificates expiring within 7 days
#>


try
{
    Add-Type -Path $env:STEELCENTRAL_ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll

    #Setting initial value for health event boolean operator (assume no health event until we determine otherwise)
    [bool]$raiseHealthEvent = 0


#Set time span to chaeck log from X time before current time to now can use addminutes, addhours or adddays depending on pollin frequency in XML

$lastpoll=(get-date).adddays(-3)


#Set expiration date target to 7 days before today
$targetdate=(get-date).adddays(7).ToString('yyyy-MM-dd')
$today=(get-date).ToString('yyyy-MM-dd')
#write-output $targetdate

#Set Filter for event log. modify this to match what you're trying to extract
$filter=@{logname="Microsoft-Windows-CertificateServicesClient-Lifecycle-User/Operational"; id=1003; StartTime=$lastpoll }

#set regex to extract date in short format
$regex ="(?<Date>[12]\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01]))"

# Get Events using filter
$eventstream = Get-WinEvent -FilterHashtable $filter -MaxEvents 1
#write-output $events
           
#Convert to XML
$event = [xml]$eventstream[0].ToXml()

#No need to keep the whole cache of events in memory
    $eventstream = ""

#Extract needed data from xml. This needs to match the XML properties of the event
$thumbprint=$event.Event.UserData.CertNotificationData.CertificateDetails.Thumbprint
$expiration=$event.Event.UserData.CertNotificationData.CertificateDetails.NotValidAfter
#write-output $thumbprint


#Extract simplified date format
$expiration -match $regex
$expdate=$matches.Date
#write-output $expdate
#write-output $thumbprint

#Compare against target date
#if($expdate -gt $targetdate){
    #Write-Output "Not Expiring Soon"}
if($expdate -ge $today -and $expdate -le $targetdate){
    Write-Output "Expiring soon" 
    [bool]$raiseHealthEvent = 1}
	

# Check whether a custom health event should be created by the Agent
    if ($raiseHealthEvent -eq $true) 
    {
       #Use the ActionExtensionsMethods in order to set the event attributes (note - only SetEventOccurred is mandatory)
       [ActionExtensionsMethods.PowershellPluginMethods]::SetEventOccurred()
       [ActionExtensionsMethods.PowershellPluginMethods]::SetError("Certicate Expiring in 7 days")
	    [ActionExtensionsMethods.PowershellPluginMethods]::SetComponent("Certicate")
		[ActionExtensionsMethods.PowershellPluginMethods]::SetComponentType("Certificate")
		[ActionExtensionsMethods.PowershellPluginMethods]::SetSubComponent("$Thumbprint")
       [ActionExtensionsMethods.PowershellPluginMethods]::SetDetails("Expiration Date " + "$expdate"  )

    }

    Else
    {
        # No matching event found
      
    }
}
catch
{
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}






# SIG # Begin signature block
# MIIX0wYJKoZIhvcNAQcCoIIXxDCCF8ACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUsRzZ5SnSjGwFrs4+q7pn39l8
# Nl+gghMOMIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
# AQUFADCBizELMAkGA1UEBhMCWkExFTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTEUMBIG
# A1UEBxMLRHVyYmFudmlsbGUxDzANBgNVBAoTBlRoYXd0ZTEdMBsGA1UECxMUVGhh
# d3RlIENlcnRpZmljYXRpb24xHzAdBgNVBAMTFlRoYXd0ZSBUaW1lc3RhbXBpbmcg
# Q0EwHhcNMTIxMjIxMDAwMDAwWhcNMjAxMjMwMjM1OTU5WjBeMQswCQYDVQQGEwJV
# UzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFu
# dGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EgLSBHMjCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBALGss0lUS5ccEgrYJXmRIlcqb9y4JsRDc2vCvy5Q
# WvsUwnaOQwElQ7Sh4kX06Ld7w3TMIte0lAAC903tv7S3RCRrzV9FO9FEzkMScxeC
# i2m0K8uZHqxyGyZNcR+xMd37UWECU6aq9UksBXhFpS+JzueZ5/6M4lc/PcaS3Er4
# ezPkeQr78HWIQZz/xQNRmarXbJ+TaYdlKYOFwmAUxMjJOxTawIHwHw103pIiq8r3
# +3R8J+b3Sht/p8OeLa6K6qbmqicWfWH3mHERvOJQoUvlXfrlDqcsn6plINPYlujI
# fKVOSET/GeJEB5IL12iEgF1qeGRFzWBGflTBE3zFefHJwXECAwEAAaOB+jCB9zAd
# BgNVHQ4EFgQUX5r1blzMzHSa1N197z/b7EyALt0wMgYIKwYBBQUHAQEEJjAkMCIG
# CCsGAQUFBzABhhZodHRwOi8vb2NzcC50aGF3dGUuY29tMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwPwYDVR0fBDgwNjA0oDKgMIYuaHR0cDovL2NybC50aGF3dGUuY29tL1Ro
# YXd0ZVRpbWVzdGFtcGluZ0NBLmNybDATBgNVHSUEDDAKBggrBgEFBQcDCDAOBgNV
# HQ8BAf8EBAMCAQYwKAYDVR0RBCEwH6QdMBsxGTAXBgNVBAMTEFRpbWVTdGFtcC0y
# MDQ4LTEwDQYJKoZIhvcNAQEFBQADgYEAAwmbj3nvf1kwqu9otfrjCR27T4IGXTdf
# plKfFo3qHJIJRG71betYfDDo+WmNI3MLEm9Hqa45EfgqsZuwGsOO61mWAK3ODE2y
# 0DGmCFwqevzieh1XTKhlGOl5QGIllm7HxzdqgyEIjkHq3dlXPx13SYcqFgZepjhq
# IhKjURmDfrYwggSjMIIDi6ADAgECAhAOz/Q4yP6/NW4E2GqYGxpQMA0GCSqGSIb3
# DQEBBQUAMF4xCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3Jh
# dGlvbjEwMC4GA1UEAxMnU3ltYW50ZWMgVGltZSBTdGFtcGluZyBTZXJ2aWNlcyBD
# QSAtIEcyMB4XDTEyMTAxODAwMDAwMFoXDTIwMTIyOTIzNTk1OVowYjELMAkGA1UE
# BhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMTQwMgYDVQQDEytT
# eW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIFNpZ25lciAtIEc0MIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAomMLOUS4uyOnREm7Dv+h8GEKU5Ow
# mNutLA9KxW7/hjxTVQ8VzgQ/K/2plpbZvmF5C1vJTIZ25eBDSyKV7sIrQ8Gf2Gi0
# jkBP7oU4uRHFI/JkWPAVMm9OV6GuiKQC1yoezUvh3WPVF4kyW7BemVqonShQDhfu
# ltthO0VRHc8SVguSR/yrrvZmPUescHLnkudfzRC5xINklBm9JYDh6NIipdC6Anqh
# d5NbZcPuF3S8QYYq3AhMjJKMkS2ed0QfaNaodHfbDlsyi1aLM73ZY8hJnTrFxeoz
# C9Lxoxv0i77Zs1eLO94Ep3oisiSuLsdwxb5OgyYI+wu9qU+ZCOEQKHKqzQIDAQAB
# o4IBVzCCAVMwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAO
# BgNVHQ8BAf8EBAMCB4AwcwYIKwYBBQUHAQEEZzBlMCoGCCsGAQUFBzABhh5odHRw
# Oi8vdHMtb2NzcC53cy5zeW1hbnRlYy5jb20wNwYIKwYBBQUHMAKGK2h0dHA6Ly90
# cy1haWEud3Muc3ltYW50ZWMuY29tL3Rzcy1jYS1nMi5jZXIwPAYDVR0fBDUwMzAx
# oC+gLYYraHR0cDovL3RzLWNybC53cy5zeW1hbnRlYy5jb20vdHNzLWNhLWcyLmNy
# bDAoBgNVHREEITAfpB0wGzEZMBcGA1UEAxMQVGltZVN0YW1wLTIwNDgtMjAdBgNV
# HQ4EFgQURsZpow5KFB7VTNpSYxc/Xja8DeYwHwYDVR0jBBgwFoAUX5r1blzMzHSa
# 1N197z/b7EyALt0wDQYJKoZIhvcNAQEFBQADggEBAHg7tJEqAEzwj2IwN3ijhCcH
# bxiy3iXcoNSUA6qGTiWfmkADHN3O43nLIWgG2rYytG2/9CwmYzPkSWRtDebDZw73
# BaQ1bHyJFsbpst+y6d0gxnEPzZV03LZc3r03H0N45ni1zSgEIKOq8UvEiCmRDoDR
# EfzdXHZuT14ORUZBbg2w6jiasTraCXEQ/Bx5tIB7rGn0/Zy2DBYr8X9bCT2bW+IW
# yhOBbQAuOA2oKY8s4bL0WqkBrxWcLC9JG9siu8P+eJRRw4axgohd8D20UaF5Mysu
# e7ncIAkTcetqGVvP6KUwVyyJST+5z3/Jvz4iaGNTmr1pdKzFHTx/kuDDvBzYBHUw
# ggUwMIIEGKADAgECAhAECRgbX9W7ZnVTQ7VvlVAIMA0GCSqGSIb3DQEBCwUAMGUx
# CzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3
# dy5kaWdpY2VydC5jb20xJDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9v
# dCBDQTAeFw0xMzEwMjIxMjAwMDBaFw0yODEwMjIxMjAwMDBaMHIxCzAJBgNVBAYT
# AlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2Vy
# dC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBDb2RlIFNp
# Z25pbmcgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQD407Mcfw4R
# r2d3B9MLMUkZz9D7RZmxOttE9X/lqJ3bMtdx6nadBS63j/qSQ8Cl+YnUNxnXtqrw
# nIal2CWsDnkoOn7p0WfTxvspJ8fTeyOU5JEjlpB3gvmhhCNmElQzUHSxKCa7JGnC
# wlLyFGeKiUXULaGj6YgsIJWuHEqHCN8M9eJNYBi+qsSyrnAxZjNxPqxwoqvOf+l8
# y5Kh5TsxHM/q8grkV7tKtel05iv+bMt+dDk2DZDv5LVOpKnqagqrhPOsZ061xPeM
# 0SAlI+sIZD5SlsHyDxL0xY4PwaLoLFH3c7y9hbFig3NBggfkOItqcyDQD2RzPJ6f
# pjOp/RnfJZPRAgMBAAGjggHNMIIByTASBgNVHRMBAf8ECDAGAQH/AgEAMA4GA1Ud
# DwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEFBQcDAzB5BggrBgEFBQcBAQRtMGsw
# JAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcw
# AoY3aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElE
# Um9vdENBLmNydDCBgQYDVR0fBHoweDA6oDigNoY0aHR0cDovL2NybDQuZGlnaWNl
# cnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDA6oDigNoY0aHR0cDov
# L2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDBP
# BgNVHSAESDBGMDgGCmCGSAGG/WwAAgQwKjAoBggrBgEFBQcCARYcaHR0cHM6Ly93
# d3cuZGlnaWNlcnQuY29tL0NQUzAKBghghkgBhv1sAzAdBgNVHQ4EFgQUWsS5eyoK
# o6XqcQPAYPkt9mV1DlgwHwYDVR0jBBgwFoAUReuir/SSy4IxLVGLp6chnfNtyA8w
# DQYJKoZIhvcNAQELBQADggEBAD7sDVoks/Mi0RXILHwlKXaoHV0cLToaxO8wYdd+
# C2D9wz0PxK+L/e8q3yBVN7Dh9tGSdQ9RtG6ljlriXiSBThCk7j9xjmMOE0ut119E
# efM2FAaK95xGTlz/kLEbBw6RFfu6r7VRwo0kriTGxycqoSkoGjpxKAI8LpGjwCUR
# 4pwUR6F6aGivm6dcIFzZcbEMj7uo+MUSaJ/PQMtARKUT8OZkDCUIQjKyNookAv4v
# cn4c10lFluhZHen6dGRrsutmQ9qzsIzV6Q3d9gEgzpkxYz0IGhizgZtPxpMQBvwH
# gfqL2vmCSfdibqFT+hKUGIUukpHqaGxEMrJmoecYpJpkUe8wggU9MIIEJaADAgEC
# AhAEI5o4ZuuNiMpHiql0JP8EMA0GCSqGSIb3DQEBCwUAMHIxCzAJBgNVBAYTAlVT
# MRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5j
# b20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBDb2RlIFNpZ25p
# bmcgQ0EwHhcNMTkwMzE0MDAwMDAwWhcNMjEwNTEzMTIwMDAwWjB6MQswCQYDVQQG
# EwJJTDEVMBMGA1UEBxMMSG9kIEhhc2hhcm9uMSkwJwYDVQQKEyBBdGVybml0eSBJ
# bmZvcm1hdGlvbiBTeXN0ZW1zIEx0ZDEpMCcGA1UEAxMgQXRlcm5pdHkgSW5mb3Jt
# YXRpb24gU3lzdGVtcyBMdGQwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQCgSpZkNUNRD1hUMczd2HMp9T/heTd+G+3vSBV3VotxLR0TzER5xMfwWpR3RCo8
# Xq0MtxeNtYs0h3ziLYpJvfc+3/31+3znuyRnflOx+B5j6DyNZ3TVHlx/V7ncUK+w
# G3Bd6Gz+HmYjEInWEK7szZAN3NG34bnzzchKgV3LWj3mX3tsm9zXsPBPPMXBtSU1
# ca3d8wEEAbsbEF1HHfg8LxaJ7+3TA+4EbFkmAj8gLH/CoPXxXmX5ZrtQG1ew3bVx
# 83PPr4bvqpJSoY9+sdV+scGwvcrHLNNEuweeZUS5lGAdndeDqrqJaQkxb4ngtCIB
# sq/OWAUmRC0if/TcbbEB0+NXAgMBAAGjggHFMIIBwTAfBgNVHSMEGDAWgBRaxLl7
# KgqjpepxA8Bg+S32ZXUOWDAdBgNVHQ4EFgQU6Wr2K80pkkXQg3MVX8OdNrPdQrEw
# DgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMHcGA1UdHwRwMG4w
# NaAzoDGGL2h0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9zaGEyLWFzc3VyZWQtY3Mt
# ZzEuY3JsMDWgM6Axhi9odHRwOi8vY3JsNC5kaWdpY2VydC5jb20vc2hhMi1hc3N1
# cmVkLWNzLWcxLmNybDBMBgNVHSAERTBDMDcGCWCGSAGG/WwDATAqMCgGCCsGAQUF
# BwIBFhxodHRwczovL3d3dy5kaWdpY2VydC5jb20vQ1BTMAgGBmeBDAEEATCBhAYI
# KwYBBQUHAQEEeDB2MCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5j
# b20wTgYIKwYBBQUHMAKGQmh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdp
# Q2VydFNIQTJBc3N1cmVkSURDb2RlU2lnbmluZ0NBLmNydDAMBgNVHRMBAf8EAjAA
# MA0GCSqGSIb3DQEBCwUAA4IBAQANmYA5xEP35PUPvXk5KmwWQmA7pjlf94Wg/0iU
# eMB8vnoBHCp/MFovD3pY6a5F9CzaBdy3lImduFa0dXI/xW+1jKImypo3aWSwJbvO
# g5gUyDKEB5hi6SaSGcpVAGdbwpMhiwNQiXtR6z04tOpfDcZF/5flnw4CI38VTn08
# LMUnPKnmWyePlLq26f/kRK4lrs2e7lr98Ejz6ISER1i6ZnSw3Jimdm26mc00MXph
# 0hd8e4nk6qigpL3MX3ubgK0HjXpVxOXa37C8uXIjajrl3ciw1CGe/WQoj3MGwMHw
# ptguRwc6YUS2dJi6asUzWuwq9CAU+vVN42TQd8t/P1TD2M8rMYIELzCCBCsCAQEw
# gYYwcjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UE
# CxMQd3d3LmRpZ2ljZXJ0LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1
# cmVkIElEIENvZGUgU2lnbmluZyBDQQIQBCOaOGbrjYjKR4qpdCT/BDAJBgUrDgMC
# GgUAoHAwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcC
# AQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYE
# FCwG32jv/6vaOigVLGq5mE9MaNpPMA0GCSqGSIb3DQEBAQUABIIBAGLZbC5ihQYT
# 2Ab/wdeOyxujXGqcav1PRSGf3k9hJTVPr6b4Ay3ah9Twt+6upU1hbq+amgk8quz+
# ufIxTNxD9y4goTHkAcO3TqIXQm6vb5bwaTx+Otzb/lzOUxQE3S1f7stf2CD37G5Z
# iZISbEFTkCBZ0iIxECzF6i8aswll8Nfx7bKC8Yo26yzeTkEUOhtOGX8S92vxLAWx
# tu8QVSD59xHThnd09IF/P3iX+ttK/kbwNy3d3wCo32nHE94NjY6Da3IrgeR6xOAA
# YEgTYRxlNAtWHNjhrmDdb5gbBxXFFMp97Imc6RZdtPBdu17Tx+OsH677C0rxAdHN
# 10ECoFO/XfuhggILMIICBwYJKoZIhvcNAQkGMYIB+DCCAfQCAQEwcjBeMQswCQYD
# VQQGEwJVUzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMT
# J1N5bWFudGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EgLSBHMgIQDs/0OMj+
# vzVuBNhqmBsaUDAJBgUrDgMCGgUAoF0wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEH
# ATAcBgkqhkiG9w0BCQUxDxcNMjAwMjI1MDg1OTA1WjAjBgkqhkiG9w0BCQQxFgQU
# n40YVBvbkzQKDFg4FNSPNGn8g2wwDQYJKoZIhvcNAQEBBQAEggEAecbFzxxrYnKT
# ATXJSrA3bo8RB9uc8P+raUoI34t+tAxR+vaNrnVCwk3DhgFbbICp19ZrjZ1+7MLa
# Tv2mp0ROc3CtaAolta4Cl0+Xf++IByqvhRzFld9XXxzMv3FkFxnArFkz/71h9t5U
# IKhUzAdAx8cIuKe4ekJoS1McWOO9/3su//YUo4jcvyvx9lxKvLvTpJmDjlaI+LFa
# 97Aih47xIwkkLM4gSNpDAWYRqFon485LkIwNYdrnjEi3EJ15b0I88c8vsRjko2zx
# XzKMBuLS55uOUFVu/FlIu9FLE97meBVTnInd9vH5pDQX1ijlwI0wzSxKQhKM/vK1
# b8EiljKosQ==
# SIG # End signature block
