#Config Variables
$SiteURL = "https://ChangeToSOURCESharePointSite.com"
$ListNames = @("AccessRequest", "Building", "Floor", "UserSetting", "VisitorLog")
$ListsOutputFile = "C:\Temp\PnP\OfficeEntryListSchemas.xml"
 
#Connect to PNP Online
Connect-PnPOnline -Url $SiteURL -UseWebLogin
 
#Get the List schemas from the Site Templates and export to XML file
$Templates = Get-PnPProvisioningTemplate -OutputInstance -Handlers Lists -ListsToExtract $ListNames 
Save-PnPProvisioningTemplate -InputInstance $Templates -Out ($ListsOutputFile)	

