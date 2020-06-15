#Config Variables
$SiteURL = "https://ChangeToTARGETSharePointSite.com"
$TemplateFile = "C:\Temp\PnP\OfficeEntryListSchemas.xml"
 
#Connect to PNP Online
Connect-PnPOnline -Url $SiteURL -UseWebLogin
 
Write-Host "Creating List(s) from Template File..."
Apply-PnPProvisioningTemplate -Path $TemplateFile

