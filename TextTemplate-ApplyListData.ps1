#Config Variables
$SiteURL = "https://ChangeToTARGETSharePointSite.com"
$ListName = "TextTemplate"
$CSVFolder = "C:\temp\PnP\v2\"
$CSVFields=@("Title","BodyText","Notes") # Not currently being used below
###!!! CSV Fields need to be hard coded in script below. 
###To Do: investigate using for loop to iterate through columns 
 
#Get the CSV file contents
$CSVData = Import-Csv -Path ($CSVFolder + $ListName + ".csv") -header "Title","BodyText","Notes" -delimiter "|" -Encoding Unicode
 
#Connect to site
Connect-PnPOnline $SiteUrl -UseWebLogin
 
#Iterate through each Row in the CSV and import data to SharePoint Online List
foreach ($Row in $CSVData)
{
	if ($Row.Title -ne "Title")	
	{

		Add-PnPListItem -List $ListName -Values @{"Title" = $($Row.Title)
                            "BodyText" = $($Row.BodyText)
                            "Notes" = $($Row.Notes)}
    }
}

