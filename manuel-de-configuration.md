# Manuel de configuration de l'application COVID-19 Entrée au bureau

**Date: 15 juin 2020**

**Version: 1.0**

**Auteur: Centre analytique des affaires, ministère de la Justice**

**Contact: BACentre@justice.gc.ca**

## Résumé

L'application COVID-19 Entrée au bureau permet aux employés de demander l'accès aux édifices pour eux-mêmes et les visiteurs dans des édifices pendant certaines périodes, et pour que les demandes soient approuvées par leurs gestionnaires. Cela permet au département d'assurer un environnement sûr avec une chance beaucoup plus faible que les employés entrent en contact les uns avec les autres. L'application a été développée par le Centre analytique des affaires du ministère de la Justice à l'aide du << Office 365 Power Platform >>. Les éléments principaux comprennent une application Power Apps et une série de listes SharePoint qui stockeront les données créées et / ou référencées par l'application. Ce document fournit les détails pour configurer cette application pour qu'elle fonctionne dans un environnement Office 365 différent ou sous un locataire différent.

## Configuration des listes SharePoint

La solution utilise les scripts PowerShell et incorpore la bibliothèque de << Patterns and Practices >> SharePoint (PnP) pour créé l'environnement SharePoint. La première fois que vous configurez l'environnement SharePoint, vous devrez peut-être d'abord ajuster votre environnement PowerShell, comme décrit ci-dessous.

### Configuration de PowerShell et la bibliothèque PnP

1. Ouvrez une fenêtre PowerShell lorsque vous êtes connecté avec un compte administrateur. Cela nécessite d'aller dans le dossier qui contient l'exécutable pour PowerShell (probablement %SystemRoot%\system32\WindowsPowerShell\v1.0), en maintenant Control-Maj et en cliquant avec le bouton droit pour sélectionner << Exécuter en tant qu'utilisateur différent >>. Entrez les informations d'identification du compte administrateur. Ou, si vous êtes déjà connecté en tant qu'administrateur, vous pouvez simplement cliquer avec le bouton droit et sélectionner « Exécuter en tant qu'administrateur ».
2. Exécutez la commande **Get-ExecutionPolicy**
3. Si la stratégie actuelle n'est pas définie sur << Unrestricted >>, exécutez la commande **Set-ExecutionPolicy Unrestricted**. ** Remarque : pour des raisons de sécurité, il est conseillé de ramener la stratégie à ce qu'elle était auparavant, si elle n'était pas déjà << Unrestricted >>, après avoir effectué toutes les tâches requises dans PowerShell.
4. Exécutez cette commande pour changer le protocole de sécurité de votre session actuelle en TLS1.2: **[Net.ServicePointManager] :: SecurityProtocol = [Net.SecurityProtocolType] :: Tls12**
5. Installez la bibliothèque PnP (si elle n'a jamais été installée auparavant) en exécutant cette commande: **Install-Module SharePointPnPPowerShellOnline**
6. Exécutez la commande **$ExecutionContext.SessionState.LanguageMode** pour voir si vous êtes en mode << Full language >> ou en mode << Constrained Language >>.
7. Si vous êtes en mode << constrained language >>, vous devrez le basculer sur << full >> en créant une variable d'environnement appelée **_PSLockDownPolicy** et en lui donnant une valeur de 0, ou en changeant sa valeur en 0 si elle existe déjà (si vous êtes en mode << constrained language >>, cette variable a probablement une valeur de 4). Cela peut être fait en observant les étapes de cette capture d'écran:

### << Ajoutez une capture d'écran >>

\*\* Remarque: pour des raisons de sécurité, il est conseillé de remettre la politique en mode de << constrained language >> (c'est-à-dire de changer la variable à 4) si elle a été précédemment définie sur ce mode, après avoir effectué toutes les tâches requises dans PowerShell.

### Création de modèles de liste SharePoint

1. Fermez toute fenêtre PowerShell qui peut être ouverte et ouvrez-en une nouvelle en tant qu'administrateur, conformément à l'étape 1 de la section précédente.
2. Ouvrez le fichier **OfficeEntry-ApplyListSchemas.ps1** et mettez à jour les variables **$SiteURL** avec votre site SharePoint cible et **$TemplateFile** avec le chemin d'accès complet et le nom de fichier du fichier XML qui contient les définitions du modèle de liste.
3. Notez que des résultats étranges peuvent être attendus si des listes du même nom existent déjà dans le site SharePoint. Il est recommandé de créer un nouveau sous-site SharePoint vide pour les listes qui seront utilisées par cette application. Pour créer un nouveau sous-site:
    - sélectionnez le **contenu du site** sur le côté gauche de l'écran SharePoint, puis sélectionnez **Nouveau -> Sous-site**
    - Fournissez au minimum un **titre** et une **adresse de site Web** appropriés. La sélection de modèle peut être laissée par défaut: Site d'équipe (pas de groupe Office 365)
4. Exécutez la commande **./OfficeEntry-ApplyListSchemas** (remarque: vous devez être dans le même répertoire que le script et le fichier XML lorsque vous l'exécutez.)
5. Si vous ne vous êtes pas encore connecté à Office 365 au cours de cette session, vous serez invité avec une fenêtre contextuelle à vous connecter à Office 365 de la manière habituelle.
6. Les nouvelles listes seront ensuite créées sur le site SharePoint cible.
7. Configurez les autorisations du site SharePoint pour permettre aux utilisateurs de l'organisation d'avoir accès aux nouvelles listes, par exemple, en créant un nouveau groupe contenant tous les utilisateurs souhaités. Les autorisations pour le groupe peuvent être: "Les utilisateurs ne pourront ajouter, mettre à jour et afficher des éléments qu'à partir d'une interface distante."
8. Si vous êtes intéressé, reportez-vous au fichier **OfficeEntry-GetListSchemas.ps1** pour voir comment le fichier XML a été généré. Cela peut être utile si vous souhaitez créer une copie des modèles de liste sur votre propre site pour migrer vers un autre environnement.

### Remplissage des listes SharePoint

Aucune liste ne doit être pré-remplie pour commencer à utiliser l'application, mais vous souhaiterez peut-être copier des données d'un environnement à un autre dans votre cycle de développement. Des exemples de scripts ont été fournis pour montrer comment procéder. Reportez - vous à **Building-GetListData.ps1** et **Building-ApplyListData.ps1** pour les scripts qui fonctionneront avec la liste << **Building** >>; les scripts pour d'autres tables peuvent être créés de la même manière.

## Configuration de << Power Apps >>

### Installation

1. Accédez à la page principale de Power Apps. Vous pouvez y accéder sur https://make.powerapps.com. Vous devrez vous connecter avec vos informations d'identification Office 365 si vous ne l'avez pas déjà fait. Basculez vers votre environnement souhaité en haut à droite de la fenêtre si nécessaire.
2. Dans le menu de gauche, cliquez sur **Apps**.
3. Dans le menu supérieur de la page Web, sélectionnez **Importer l'application de canevas**.
4. Cliquez sur **Télécharger**, accédez au dossier qui contient le fichier ZIP enregistré pour l'application et sélectionnez-le. Il sera téléchargé. Une fois terminé, cliquez sur **Importer**.
5. Pour **consulter le contenu du package**, si vous le souhaitez, sélectionnez la clé et remplacez le nom de l'application par le nom souhaité.
6. Sélectionnez **Importer**.

### Configuration de l'ID d'application

1. Sur la page principale des applications, cliquez sur… à côté de l'application importée et cliquez sur **Détails**.
2. Copiez l'ID d'application qui apparaît dans les détails.
3. De retour sur la page principale des applications, cliquez sur… à côté de l'application importée et cliquez sur **Modifier**.
4. Sur la page d'édition, sur le côté gauche, cliquez sur les trois carrés empilés les uns sur les autres pour afficher la **Vue d'arbre**.
5. Pour les **écrans**, cliquez sur **App** (le premier élément), puis au milieu de l'écran au-dessus de la vue de l'application, reportez-vous à la fenêtre de code à côté de l' icône **fx**.
6. Sur le côté droit de la fenêtre de code, cliquez sur l'indicateur bas pour agrandir la fenêtre.
7. Recherchez la section du code qui fait référence à **_appID**. Dans les devis, supprimez le texte et collez l'ID d'application qui a été copiée à une étape antérieure.

### Liens avec les sources de données

Toutes les sources de données ont été supprimées de l'application avant de la partager. Plusieurs sources de données devront donc être ajoutées à l'application comme suit:

1. Sur la page principale des applications, cliquez sur… à côté de l'application importée et cliquez sur **Modifier**.
2. Sur la page d'édition, sur le côté gauche, cliquez sur le cylindre pour afficher le menu Sources de données.
3. Développez le sous-menu **Connecteurs**
4. Sélectionnez **Office 365 Outlook**, puis **Ajouter une connexion**. Ensuite, **Connecter**.
5. Sélectionnez **Utilisateurs Office 365**, puis **Ajouter une connexion**. Ensuite, **Connecter**.
6. Sélectionnez **SharePoint**, puis **Ajouter une connexion**. Assurez-vous que le bouton radio est sur **Connecter directement (services info-nuage)**, puis cliquez sur **Connecter**. Entrez l'URL du site SharePoint qui contient toutes les listes que vous avez créées, puis cliquez sur **Connecter**. Sélectionnez les listes que vous avez créées précédemment: AccessRequest, Building, Floor, UserSetting, VisitorLog; puis cliquez sur **Connecter**.
7. Sélectionnez **Notification Power Apps**, puis **Ajouter une connexion**. Pour l'application cible, entrez l'ID d'application de la section précédente, puis cliquez sur **Connecter**.
 
### Activation de l'utilisation des applications

1. Sur la page principale des Apps, cliquez sur… à côté de l'application importée et cliquez sur **Détails**.
2. Sélectionnez la vue **Versions**.
3. Sélectionnez … à côté de la version que vous souhaitez publier, si elle n'est pas déjà en ligne.
4. Sélectionnez **Publier cette version**, puis **Publier cette version**.
5. Sur la page principale des applications, cliquez sur… à côté de l'application et cliquez sur **Partager**.
6. Ajoutez des utilisateurs comme vous le souhaitez, puis cliquez sur **Partager**.
