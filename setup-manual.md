# COVID-19 Office Entry App Setup Manual

**Date: November 30, 2020**

**Version: 2.0**

**Author: Business Analytics Centre, Department of Justice**

**Contact: BACentre@justice.gc.ca**

## Summary

The COVID-19 Office Entry app allows employees to request access to specific floors for themselves and visitors in specific buildings during certain times, and for those requests to be approved by managers. This allows the department to ensure a safe environment with a much lower chance of employees coming into contact with each other. The app has been developed by the Department of Justice Business Analytics Centre using the Office 365 Power Platform. The main pieces include a Power Apps application, a series of SharePoint lists that will store the data that is created and/or referenced by the application, several Power Automate Flows for sending e-mails and transferring information, and an attestation form. This document provides the details for setting up this application to work in a different Office 365 environment or under a different tenant.

## SharePoint Lists and Content Setup

The solution uses PowerShell scripting and incorporates the SharePoint Patterns and Practices (PnP) library to populate the SharePoint environment. The first time you setup the SharePoint environment, you might first need to adjust your PowerShell environment, as described below.

### PowerShell and PnP Library Setup

1. Open a PowerShell window while logged in with an administrator account. This will require going to the folder that contains the executable for PowerShell (likely %SystemRoot%\system32\WindowsPowerShell\v1.0\), holding Control-Shift, and right-clicking to select &quot;Run as different user&quot;. Enter the administrator account credentials. Or, if you are already logged in as an administrator, you can just right-click and select &quot;Run as Administrator&quot;.
2. Run the command **Get-ExecutionPolicy**
3. If the current policy is not set to &quot;Unrestricted&quot;, run the command **Set-ExecutionPolicy Unrestricted**. \*\* Note: for safety, it is advised to switch the policy back to what it previously was, if it was not Unrestricted already, after you are done all of the required tasks in PowerShell.
4. Run this command to change the security protocol of your current session to TLS1.2: **[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12**
5. Install the PnP Library (if it has never been installed before) by running this command: **Install-Module SharePointPnPPowerShellOnline**
6. Run the command **$ExecutionContext.SessionState.LanguageMode**, to see if you are in Full language mode or constrained language mode.
7. If you are in constrained language mode, you will need to switch it to full by creating an environment variable called **\_PSLockDownPolicy** and giving it a value of 0, or changing its value to 0 if it already exists (if you are in constrained language mode, this variable likely has a value of 4). This can be done by doing observing the steps in this screenshot:

![](images/EnvironmentVariables-en.png)

\*\* Note: for safety, it is advised to switch the policy back to constrained language mode (i.e. changing the variable back to 4) if it was previously set to that mode, after you are done all of the required tasks in PowerShell.

### SharePoint List Templates Creation

1. Close any PowerShell window that may be open and open a new one as an administrator, as per Step 1 of the previous section.
2. Open file **OfficeEntry-ApplyListSchemas.ps1** and update the variables **$SiteURL** with your target SharePoint site and **$TemplateFile** with the full path and filename of the XML file that contains the List Template definitions.
3. Note that weird results may be expected if lists of the same name already exist in the SharePoint site. It is recommended to create a new, empty, SharePoint subsite for the lists that will be used by this app. To create a new subsite:
    - Select **Site contents** on the left hand side of the SharePoint screen, then Select **Site Settings** on the right, then **Sites and workspaces** under "Site Administration", then **Create**.
    - At minimum, provide a suitable **Title** and **Web Site Address**. The Template selection can be left as the default: Team site (no Office 365 group)
4. Run the command **./OfficeEntry-ApplyListSchemas** (note: you must be in the same directory as the script and the XML file when you run this.)
5. If you have not yet logged into Office 365 during this session, you will be prompted with a pop-up to login to Office 365 in the usual way.
6. The new lists will then be created on the target SharePoint site.
7. If interested, refer to file **OfficeEntry-GetListSchemas.ps1** to see how the XML file was generated. This may come in handy if you wish to create a copy of the list templates on your own site to migrate to a different environment.

### Populating SharePoint Lists

There is one list that needs to be pre-populated in order to begin using the app, **TextTemplate**. To do so, perform the following steps:  
1.	Save the file **TextTempate.csv** in your working directory.
2.	Open file **TextTemplate-ApplyListData.ps1** and update the variables **$SiteURL** with your target SharePoint site and **$CSVFolder** with the full path of your working directory (where you saved the CSV file). Ensure the full path has "\\" at the end.
3.	Run the command **./TextTemplate-ApplyListData**. The list will be populated on the target SharePoint site.
4.	If interested, refer to file **TextTemplate-GetListData.ps1** to see how the CSV file was generated. This may come in handy if you wish to copy data from one environment to another in your development cycle. Scripts for extracting or loading data for other tables can be created in the same fashion.

### Configuring Security Settings and User Access for SharePoint Site

The security of the lists needs to be set such that users indirectly have write access to them (when creating a new building access request through the app, for example) but they should not be able to see or modify the lists directly. In order to achieve this goal, do the following:

1.	Proceed to the top level SharePoint private group (the level above any subsites).
2.	At the top right, click the **Gear** (for **Settings**) --> **Site permissions** --> **Advanced permissions settings**.
3.	The "Permissions" tab should now be selected near the top left. In the "Manage" portion of that menu, click **Permission Levels**.
4.	Click **Add a Permission Level**.
5.	Provide a name for the Permission Level (e.g. **Power Apps**) and a description (e.g. **Users will only be able to add, update, and view items from a remote interface.**)
6.	For the required permissions, select the following check boxes:
    - **List Permissions**
        - Add Items
        - Edit Items
        - View Items
        - Open Items
    - **Site Permissions**
        - View Pages
        - Browse User Information
        - Use Remote Interfaces
        - Open
7.	Create a SharePoint Group for the users of the app on the subsite containing the lists. First, navigate to the site contents of the subsite that contains the new lists.
8.	On the right hand side, click **Site Settings**, then under "Users and Permissions", select **Site permissions**.
9.	The "Permissions" tab should now be selected near the top left. In the "Grant" portion of that menu, click **Create Group**.
10.	Provide a name for the group (e.g. **Office Entry Power App Users**) and apply the following settings:
    - Group Settings - Who can view the membership of the group? **Group Members**
    - Group Settings - Who can edit the membership of the group? **Group Owner**
    - Membership Requests - Allow requests to join/leave this group? **Yes**
    - Membership Requests - Auto-accept requests? **No** 
    - Give Group Permission to this Site - select the Permission Level that was created at step 5 (e.g. **Power Apps**)
11.	You should now see a list of all people who are members of the new group. It should only have the owner who created the list. Select **New** --> **Add Users**.
12.	A popup will appear with the title "Share (name of Subsite)". Click **Show Options** and uncheck **Send an email invitation**, and enter **Everyone except external users** for the names. Then click **Share**.

### Adding Additional Content to SharePoint

Certain content, specific to your organization, must be added to some lists in advance in order to take full advantage of the app’s functionality.

**Building** - one row is required for each building for which you wish to use the app. The *TimeZoneOffset* represents the number of hours behind Universal Time for the time zone of the building (e.g. Eastern Standard Time would be "-5"). The *CommissionaireEmail* is the main e-mail address for commissionaires that are responsible for that building. (They will be e-mailed a list of office access requests each day).

**Floor** - each floor, or floor area, that you would like to see in the app, needs to be an item in the list. The *BuildingID* for the floor should be the same identifier as the Title value for the associated building in the Building list. The *CurrentCapacity* must be populated with the number of reservable spots that have been assigned for the particular area. The *Capacity* and *DefaultCapacityPortion* values are not mandatory but can be used for easily tracking the normal capacity and the percentage of normal capacity that is represented by *CurrentCapacity*, respectively. Sample values for a floor could be: *Capacity* = 10, *CurrentCapacity* = 2, *DefaultCapacityPortion* = 20 (i.e. 20% of 10 = 2)

**UserSetting** - this table can be used to allow an employee to submit an access request on behalf of somebody else, typically if someone is unable to use the app for any reason (accessibility, lack of Internet, etc.). The first time an employee logs into the app, a new entry will be added to the *UserSetting* list (the employee’s O365 login will appear in the Title column). Or, the employee’s login can be added manually to the list. Then, for the employee requiring assistance, enter the Office 365 login name of the person who will be permitted to submit requests for that employee in the *AssistantLogin* column. When the assistant begins a new session in the app, an option will appear on the title screen to allow them to switch over to the person they are supporting.

### Adding Health and Safety Documents to SharePoint

The "Email Delivery" flow sends email messages that contain PDF attachments. These attachments need to be added to SharePoint as follows:

1.	Obtain the files *HealthAndSafetyEN.docx* and *HealthAndSafetyFR.docx*. 
2.	For each file, modify the content as required (header, footer, text and images).
3.	Save the files in PDF format with the names **HealthAndSafetyEN.pdf** and **HealthAndSafetyFR.pdf**.
4.	Proceed to the SharePoint subsite where the lists were created.
5.	Select **Documents** on the menu on the left-hand side. 
6.	In the upper menu, select **Upload**, then **Files**.
7.	Select the PDF files and then click **Open** to save them to the SharePoint site.

### Info Regarding Number of Items in SharePoint Lists

It is important to note that SharePoint online has different behaviour when the number of items in a list exceeds 5000. This may in turn cause the app to experience odd behaviour or require troubleshooting. How soon a list approaches more than 5000 items depends on the number of employees using the app, but you can expect lists *AccessRequest*, *EmailQueue*, and *LoginLog* to accumulate more than 5000 items over time. If you experience problems, one suggestion is to remove historical list items that are no longer required. To preserve the information prior to removing it from SharePoint, some options are:

-	create Power Automate Flows to send list items to an on-prem location, using a Data Gateway, one-by-one, as they are created or modified in SharePoint. You may experience issues if you attempt to copy a large list in bulk in this fashion.
-	use a PowerShell script to export list contents to a CSV file and load to a database.
-	use an ETL toolkit to transfer the data from SharePoint.

## Attestation Form Creation

A survey needs to be created that will serve as an attestation form that should be filled by anyone entering the office, prior to arrival. Dynamics 365 Customer Voice, formerly called Forms Pro (part of Office 365) is one option for creating this form. Forms in Office 365 could also be used but it is important to note that results entered using Forms are stored in a U.S. data centre (not Canada), making Forms not suitable for Canadian government usage in this situation. The form is not standalone; it is referred to and leveraged by other components of the app.

Please refer to [attestation-en.md](attestation-en.md) for sample content of an attestation form.

## Power Apps Setup

### Installation

1. Navigate to the main page for Power Apps. This can be accessed at [https://make.powerapps.com](https://make.powerapps.com/). You will need to login with your Office 365 credentials if you have not already done so. Toggle to your desired environment at the top right of the window if required.
2. On the left hand menu, click **Apps**.
3. At the top menu of the webpage, select **Import canvas app**.
4. Click **Upload**, navigate to the folder that contains the Power Apps ZIP file for the app (*OGD-AM-COVID-19OfficeEntry-Entréeaubureau-PowerApps.zip*) and select it. It will upload. Once complete, click **Import**.
5. For **Review Package content**, if desired, select the wrench and change the app name to the desired name.
6. Select **Import**.

### App ID and Attestation Form Configuration

1. On the main Apps page, click the … beside the imported app and click **Details**.
2. Copy the App ID that appears in the Details.
3. Back on the main Apps page, click the … beside the imported app and click **Edit**.
4. On the editing page, on the left hand side, click the three squares stacked on each other to bring up the **Tree View**.
5. For **Screens**, click **App** (the first item), then in the middle of the screen above the app view, refer to the code window beside the **fx** icon.
6. On the right hand side of the code window, click the down indicator to expand the window.
7. Find the section of the code that refers to **\_appID**. In the quotations, remove the text and paste the App ID that was copied in an earlier step.
8. Go to the section of the code that refers to **_attestationLink**. In the quotations, remove the text and paste the URL of the attestation form that was created at an earlier stage.

### Data Source Linkages

All data sources have been stripped from the app prior to sharing it. Several data sources will therefore need to be added to the app as follows:

1. On the main Apps page, click the … beside the imported app and click **Edit**.
2. On the editing page, on the left hand side, click the cylinder to bring up the Data Sources menu.
3. Expand the **Connectors** submenu
4. Select **Office 365 Outlook** and then **Add a connection**. Then **Connect**.
5. Select **Office 365 Users** and then **Add a connection**. Then **Connect**.
6. Select **SharePoint** and then **Add a connection**. Ensure radio button is on **Connect directly (cloud services)** and then click **Connect**. Enter the URL of the SharePoint site that contains all the lists you created, then click **Connect**. Select these lists that you previously created: *AccessRequest*, *Building*, *EmailQueue*, *Floor*, *LoginLog*, *TextTemplate*, *UserSetting*, *VisitorAttestation*, *VisitorLog*; then click **Connect**.
7. Select **Power Apps Notification** and then **Add a connection**. For the target application, enter the App ID from the previous section, then click **Connect**.

### Enabling App Usage

1. On the main Apps page, click the … beside the imported app and click **Details**.
2. Select the **Versions** view.
3. Select the … beside the version you wish to publish, if it is not already Live.
4. Select **Publish this version** , then **Publish this version**.
5. On the main Apps page, click the … beside the app and click **Share**.
6. Add users as desired, then click **Share**.

## Power Automate Flows Setup

There are three flows that need to be imported to use the app:

-	Email Delivery (*OGD-AM-EmailDelivery-Livraisoncourriel-PowerAutomate.ZIP*)
-	Commissionaire Email (*OGD-AM-CommissionaireEmail-Courrielpourlescommissionaires-PowerAutomate.ZIP*)
-	Attestation Response (*OGD-AM-AttestationResponse-Reponsesauxattestations-PowerAutomate.ZIP*)

For each flow, do the following:

1.	Open each ZIP file, navigate to the file **definition.json** (full path to get to the file is **Microsoft.Flow\flows\{hex-numbered folder name}**), and replace the text *YOUR_SHAREPOINT_ONLINE_SITE_HERE* with the full URL of the SharePoint site where the lists were created. The number of occurrences where the text needs to be updated is as follows:
    - Email Delivery: 5 times
    - Commissionaire Email:  4 times
    - Attestation Response: 1 time
2.	Navigate to the main page for Power Automate. This can be accessed at [https://flow.microsoft.com](https://flow.microsoft.com). You will need to login with your Office 365 credentials if you have not already done so. Toggle to your desired environment at the top right of the window if required.
3.	On the left hand menu, click **My flows**.
4.	At the top menu of the webpage, select **Import**.
5.	Click **Upload**, navigate to the folder that contains the desired Flow ZIP file and select it. It will upload. Once complete, click **Import**.
6.	For **Review Package content**, if desired, select the wrench and change the app name to the desired name.
7.	For each related resource, click **Select during import**. If you already have the type of connection previously established in the environment, you can select it. Otherwise, click **Create new** and a new page will appear showing all of the connections in the current environment. Select **New Connection** and find the connection type that matches the Resource Type on the Import package page, then select it. Then you can go back to the Import Setup page to select this new connection. The connection types that are used by each Flow are:
    - Email Delivery: SharePoint, Office 365 Outlook
    - Commissionaire Email: SharePoint, Office 365 Outlook
    - Attestation Response: SharePoint, Microsoft Forms
8.	Select **Import**.

The **Attestation Response** flow needs to be edited before it can be used. Do the following:

1.	Navigate to **My flows**.
2.	Hover over the flow in the list, and click the pencil to edit the flow.
3.	For both "When a new response is submitted" and "Get response details", click the step of the flow so that the details appear.
4.	There will be a drop down menu for the Form Id. Open this menu and select the attestation form from the list that was previously created.
5.	Click **Save**.


