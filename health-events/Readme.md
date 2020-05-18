1. 	Monitor Name: 	Certificate Expires
	Description: 	Creates a health event when the device certificate is 7 days before expiration
	Technology:		Powershell Script
	Frequency:
	
2. 	Monitor Name: 	Slow Outlook Plugins Boot Time
	Description: 	Creates a health event whenever an Outlook’s addon launch takes more 5 sec during Outlook launch. The event also sends a contextual with the Addon name and the launch time. 	
	Technology:		Powershell Script
	Frequency:
	
3. 	Monitor Name: 	Shutdown Restart By
	Description: 	This event is written when an application causes the system to restart, or when the user initiates a restart or shut down by clicking Start or pressing CTRL+ALT+DELETE, and then clicking Shut Down. 	
	Technology:		Event Viewer
	Frequency:
	
4. 	Monitor Name: 	Driver Crash
	Description: 	Alerts when a device is offline due to driver crash.  	
	Technology:		Event Viewer
	Frequency:
	
5. 	Monitor Name: 	Display Driver Crash
	Description: 	  	
	Technology:		Event Viewer
	Frequency:
	
6. 	Monitor Name: 	C Drive Bitlocker Status
	Description: 	Creates a health event when the status on drive ‘C’ is not enable 	
	Technology:		WMI
	Frequency: 		1 Day
	
7. 	Monitor Name: 	Disk Space Under X(GB)
	Description: 	Give the option to decide when to alert low disk space 	
	Technology:		WMI
	Frequency: 		Hourly

8.	Monitor Name: 	DNS Queries Time out over IPv6
	Description: 	Look for Events for DNS queries timeout of failed over DNS server queries with IPv6  	
	Technology:		Event Viewer / Windows Event logs
	Frequency: 		Every Minute
	
