# Manuel de configuration de l'application COVID-19 Entrée au bureau

**Date: 30 novembre 2020**

**Version: 2.0**

**Auteur: Centre analytique des affaires, ministère de la Justice**

**Contact: BACentre@justice.gc.ca**

## Résumé

L'application COVID-19 Entrée au bureau permet aux employés de demander l'accès aux édifices pour eux-mêmes et les visiteurs dans des édifices pendant certaines périodes, et pour que les demandes soient approuvées par leurs gestionnaires. Cela permet au département d'assurer un environnement sûr avec une chance beaucoup plus faible que les employés entrent en contact les uns avec les autres. L'application a été développée par le Centre analytique des affaires du ministère de la Justice à l'aide du << Office 365 Power Platform >>. Les éléments principaux comprennent une application Power Apps, une série de listes SharePoint qui stockeront les données créées et / ou référencées par l'application, plusieurs flux de Power Automate pour l'envoi de courriels et le transfert d'information, ainsi qu'un formulaire d'attestation. Ce document fournit les détails pour configurer cette application pour qu'elle fonctionne dans un environnement Office 365 différent ou sous un locataire différent.

## Configuration des listes SharePoint et du contenu

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
    - Sélectionnez **Contenu du site** sur le côté gauche de l'écran SharePoint, puis sélectionnez **Paramètres du site** sur la droite, puis **Sites et espaces de travail** sous «Administration du site», puis **Créer**.
    - Fournissez au minimum un **titre** et une **adresse de site Web** appropriés. La sélection de modèle peut être laissée par défaut: Site d'équipe (pas de groupe Office 365)
4. Exécutez la commande **./OfficeEntry-ApplyListSchemas** (remarque: vous devez être dans le même répertoire que le script et le fichier XML lorsque vous l'exécutez.)
5. Si vous ne vous êtes pas encore connecté à Office 365 au cours de cette session, vous serez invité avec une fenêtre contextuelle à vous connecter à Office 365 de la manière habituelle.
6. Les nouvelles listes seront ensuite créées sur le site SharePoint cible.
7. Si vous êtes intéressé, reportez-vous au fichier **OfficeEntry-GetListSchemas.ps1** pour voir comment le fichier XML a été généré. Cela peut être utile si vous souhaitez créer une copie des modèles de liste sur votre propre site pour migrer vers un autre environnement.

### Remplissage des listes SharePoint

Il y a une liste qui doit être au préalabreremplie pour commencer à utiliser l'application, **TextTemplate**. Pour ce faire, procédez comme suit:
1. Enregistrez le fichier **TextTempate.csv** dans votre répertoire de travail.
2. Ouvrez le fichier **TextTemplate-ApplyListData.ps1** et mettez à jour les variables **$SiteURL** avec votre site SharePoint cible et **$CSVFolder** avec le chemin complet de votre répertoire de travail (où vous avez enregistré le fichier CSV). Assurez-vous que le chemin complet a «\\» à la fin.
3. Exécutez la commande **./TextTemplate-ApplyListData**. La liste sera remplie sur le site SharePoint cible.
4. Si vous êtes intéressé, reportez-vous au fichier **TextTemplate-GetListData.ps1** pour voir comment le fichier CSV a été généré. Cela peut être utile si vous souhaitez copier des données d'un environnement à un autre au cours de votre cycle de développement. Les scripts d'extraction ou de chargement de données pour d'autres tables peuvent être créés de la même manière.

### Configuration des paramètres de sécurité et de l'accès utilisateur pour le site SharePoint

La sécurité des listes doit être définie de telle sorte que les utilisateurs y aient indirectement un accès en écriture (lors de la création d'une nouvelle demande d'accès au bâtiment via l'application, par exemple), mais ils ne devraient pas pouvoir voir ou modifier les listes directement. Pour atteindre cet objectif, procédez comme suit:

1.  Passez au groupe privé SharePoint de niveau supérieur (le niveau au-dessus de tous les sous-sites).
2.  En haut à droite, cliquez sur **l'engrenage** (pour **Paramètres**) --> **Autorisations du site** --> **Paramètres des autorisations avancées**.
3.  L'onglet «Permissions» devrait maintenant être sélectionné près du coin supérieur gauche. Dans la partie «Gérer» de ce menu, cliquez sur **Niveaux d'autorisation**.
4.  Cliquez sur **Ajouter un niveau d'autorisation**.
5.  Indiquez un nom pour le niveau d'autorisation (par exemple, **Power Apps**) et une description (par exemple, **Les utilisateurs ne pourront ajouter, mettre à jour et afficher des éléments qu'à partir d'une interface distante.**)
6.  Pour les autorisations requises, cochez les cases suivantes:
    - **Autorisations de liste**
        - Ajouter des articles
        - Modifier les éléments
        - Voir les articles
        - Éléments ouverts
    - **Autorisations du site**
        - Afficher les pages
        - Parcourir les informations utilisateur
        - Utiliser des interfaces distantes
        - Ouvrir
7.  Créez un groupe SharePoint pour les utilisateurs de l'application sur le sous-site contenant les listes. Tout d'abord, accédez au contenu du site du sous-site qui contient les nouvelles listes.
8.  Sur le côté droit, cliquez sur **Paramètres du site**, puis sous «Utilisateurs et autorisations», sélectionnez **Autorisations du site**.
9.  L'onglet «Permissions» devrait maintenant être sélectionné près du coin supérieur gauche. Dans la partie «Accorder» de ce menu, cliquez sur **Créer un groupe**.
10. Fournissez un nom pour le groupe (par exemple, **Utilisateurs de l'application Office Entry Power Apps**) et appliquez les paramètres suivants:
    - Paramètres du groupe - Qui peut voir l'appartenance au groupe? **Les membres du groupe**
    - Paramètres du groupe - Qui peut modifier l'appartenance au groupe? **Propriétaire du groupe**
    - Demandes d'adhésion - Autoriser les demandes de rejoindre / quitter ce groupe? **Oui**
    - Demandes d'adhésion - Demandes d'acceptation automatique? **Non**
    - Donner une autorisation de groupe à ce site - sélectionnez le niveau d'autorisation qui a été créé à l'étape 5 (par exemple, **Power Apps**)
11. Vous devriez maintenant voir une liste de toutes les personnes qui sont membres du nouveau groupe. Il ne devrait avoir que le propriétaire qui a créé la liste. Sélectionnez **Nouveau** --> **Ajouter des utilisateurs**.
12. Une fenêtre contextuelle apparaîtra avec le titre «Partager (nom du sous-site)». Cliquez sur **Afficher les options** et décochez **Envoyer une invitation par e-mail**, puis entrez **Tout le monde sauf les utilisateurs externes** pour les noms. Cliquez ensuite sur **Partager**.

### Ajout de contenu supplémentaire à SharePoint

Certains contenus, spécifiques à votre organisation, doivent être ajoutés à certaines listes à l'avance afin de profiter pleinement des fonctionnalités de l'application.

**Building** - une rangée est requise pour chaque bâtiment pour lequel vous souhaitez utiliser l'application. *TimeZoneOffset* représente le nombre d'heures en retard sur le temps universel pour le fuseau horaire du bâtiment (par exemple, l'heure normale de l'Est serait «-5»). Le *CommissionnaireEmail* est la principale adresse courriel des commissionnaires responsables de ce bâtiment. (Ils recevront par courriel électronique une liste des demandes d'accès au bureau chaque jour).

**Floor** - chaque étage ou surface de bureau que vous souhaitez voir dans l'application doit être un élément de la liste. Le *BuildingID* de l'étage doit être le même identifiant que la valeur Title du bâtiment associé dans la liste Building. La *CurrentCapacity* doit être renseignée avec le nombre de places disponible qui ont été attribuées pour la zone particulière. Les valeurs *Capacity* et *DefaultCapacityPortion* ne sont pas obligatoires, mais peuvent être utilisées pour suivre facilement la capacité normale et le pourcentage de capacité normale qui est représenté par *CurrentCapacity*, respectivement. Exemples de valeurs pour un étage: *Capacity* = 10, *CurrentCapacity* = 2, *DefaultCapacityPortion* = 20 (c'est-à-dire 20% de 10 = 2)

**UserSetting** - ce tableau peut être utilisé pour permettre à un employé de soumettre une demande d'accès au nom de quelqu'un d'autre, généralement si quelqu'un est incapable d'utiliser l'application pour une raison quelconque (accessibilité, manque d'Internet, etc.). La première fois qu'un employé se connecte à l'application, une nouvelle entrée sera ajoutée à la liste *UserSetting* (la connexion O365 de l'employé apparaîtra dans la colonne Titre). Ou, la connexion de l'employé peut être ajoutée manuellement à la liste. Ensuite, pour l'employé nécessitant une assistance, entrez le nom de connexion Office 365 de la personne qui sera autorisée à soumettre des demandes pour cet employé dans la colonne *AssistantLogin*. Lorsque l'assistant commence une nouvelle session dans l'application, une option apparaît sur l'écran titre pour lui permettre de basculer vers la personne qu'il soutient.

### Ajout de documents sur la santé et la sécurité à SharePoint

Le flux « Livraison par courriel » envoie des courriels contenant des fichiers PDF. Ces fichiers doivent être ajoutées à SharePoint comme suit:

1. Procurez-vous les fichiers *HealthAndSafetyEN.docx* et *HealthAndSafetyFR.docx*.
2. Pour chaque fichier, modifiez le contenu selon vos besoins (en-tête, pied de page, texte et images).
3. Enregistrez les fichiers au format PDF sous les noms **HealthAndSafetyEN.pdf** et **HealthAndSafetyFR.pdf**.
4. Accédez au sous-site SharePoint où les listes ont été créées.
5. Sélectionnez **Documents** dans le menu sur le côté gauche.
6. Dans le menu supérieur, sélectionnez **Télécharger**, puis **Fichiers**.
7. Sélectionnez les fichiers PDF, puis cliquez sur **Ouvrir** pour les enregistrer sur le site SharePoint.

### Informations concernant le nombre d'éléments dans les listes SharePoint

Il est important de noter que SharePoint Online a un comportement différent lorsque le nombre d'éléments dans une liste dépasse 5 000. Cela peut à son tour entraîner un comportement étrange de l'application ou nécessiter un dépannage. La rapidité avec laquelle une liste approche plus de 5 000 éléments dépend du nombre d'employés utilisant l'application, mais vous pouvez vous attendre à ce que les listes *AccessRequest*, *EmailQueue* et *LoginLog* accumulent plus de 5000 éléments au fil du temps. Si vous rencontrez des problèmes, une suggestion consiste à supprimer les éléments de liste historiques qui ne sont plus nécessaires. Pour conserver les informations avant de les supprimer de SharePoint, certaines options sont les suivantes:

- créez des flux Power Automate pour envoyer des éléments de liste à un emplacement sur site, à l'aide d'un « Data Gateway », un par un, au fur et à mesure qu'ils sont créés ou modifiés dans SharePoint. Vous pouvez rencontrer des problèmes si vous essayez de copier une grande liste en masse de cette manière.
- utiliser un script PowerShell pour exporter le contenu de la liste vers un fichier CSV et le charger dans une base de données.
- utiliser une application d'ETL pour transférer les données de SharePoint.

## Création d'un formulaire d'attestation

Un sondage doit être créé qui servira de formulaire d'attestation qui devrait être rempli par toute personne entrant dans le bureau, avant l'arrivée. Dynamics 365 Customer Voice, anciennement appelé Forms Pro (qui fait partie d'Office 365), est une option pour créer ce formulaire. Les formulaires dans Office 365 peuvent également être utilisés, mais il est important de noter que les résultats saisis à l'aide de Forms sont stockés dans un centre de données américain (et non au Canada), ce qui rend les formulaires non adaptés à l'utilisation du gouvernement canadien dans cette situation. Le formulaire n'est pas autonome; il est référencé et exploité par d'autres composants de l'application.

Veuillez consulter [attestation-fr.md](attestation-fr.md) pour un exemple de contenu d'un formulaire d'attestation.


## Configuration de << Power Apps >>

### Installation

1. Accédez à la page principale de Power Apps. Vous pouvez y accéder sur [https://make.powerapps.com](https://make.powerapps.com/). Vous devrez vous connecter avec vos informations d'identification Office 365 si vous ne l'avez pas déjà fait. Basculez vers votre environnement souhaité en haut à droite de la fenêtre si nécessaire.
2. Dans le menu de gauche, cliquez sur **Apps**.
3. Dans le menu supérieur de la page Web, sélectionnez **Importer l'application de canevas**.
4. Cliquez sur **Télécharger**, accédez au dossier qui contient le fichier ZIP Power Apps pour l'application (*OGD-AM-COVID-19OfficeEntry-Entréeaubureau-PowerApps.zip*) et sélectionnez-le. Il sera téléchargé. Une fois terminé, cliquez sur **Importer**.
5. Pour **consulter le contenu du package**, si vous le souhaitez, sélectionnez la clé et remplacez le nom de l'application par le nom souhaité.
6. Sélectionnez **Importer**.

### Configuration de l'ID d'application et du formulaire d'attestation 

1. Sur la page principale des applications, cliquez sur… à côté de l'application importée et cliquez sur **Détails**.
2. Copiez l'ID d'application qui apparaît dans les détails.
3. De retour sur la page principale des applications, cliquez sur… à côté de l'application importée et cliquez sur **Modifier**.
4. Sur la page d'édition, sur le côté gauche, cliquez sur les trois carrés empilés les uns sur les autres pour afficher la **Vue d'arbre**.
5. Pour les **écrans**, cliquez sur **App** (le premier élément), puis au milieu de l'écran au-dessus de la vue de l'application, reportez-vous à la fenêtre de code à côté de l' icône **fx**.
6. Sur le côté droit de la fenêtre de code, cliquez sur l'indicateur bas pour agrandir la fenêtre.
7. Recherchez la section du code qui fait référence à **_appID**. Dans les devis, supprimez le texte et collez l'ID d'application qui a été copiée à une étape antérieure.
8. Accédez à la section du code qui fait référence à **_attestationLink**. Dans les citations, supprimez le texte et collez l'URL du formulaire d'attestation qui a été créé à un stade antérieur.

### Liens avec les sources de données

Toutes les sources de données ont été supprimées de l'application avant de la partager. Plusieurs sources de données devront donc être ajoutées à l'application comme suit:

1. Sur la page principale des applications, cliquez sur… à côté de l'application importée et cliquez sur **Modifier**.
2. Sur la page d'édition, sur le côté gauche, cliquez sur le cylindre pour afficher le menu Sources de données.
3. Développez le sous-menu **Connecteurs**
4. Sélectionnez **Office 365 Outlook**, puis **Ajouter une connexion**. Ensuite, **Connecter**.
5. Sélectionnez **Utilisateurs Office 365**, puis **Ajouter une connexion**. Ensuite, **Connecter**.
6. Sélectionnez **SharePoint**, puis **Ajouter une connexion**. Assurez-vous que le bouton radio est sur **Connecter directement (services info-nuage)**, puis cliquez sur **Connecter**. Entrez l'URL du site SharePoint qui contient toutes les listes que vous avez créées, puis cliquez sur **Connecter**. Sélectionnez les listes que vous avez créées précédemment: *AccessRequest*, *Building*, *EmailQueue*, *Floor*, *LoginLog*, *TextTemplate*, *UserSetting*, *VisitorAttestation*, *VisitorLog*; puis cliquez sur **Connecter**.
7. Sélectionnez **Notification Power Apps**, puis **Ajouter une connexion**. Pour l'application cible, entrez l'ID d'application de la section précédente, puis cliquez sur **Connecter**.
 
### Activation de l'utilisation des applications

1. Sur la page principale des Apps, cliquez sur… à côté de l'application importée et cliquez sur **Détails**.
2. Sélectionnez la vue **Versions**.
3. Sélectionnez … à côté de la version que vous souhaitez publier, si elle n'est pas déjà en ligne.
4. Sélectionnez **Publier cette version**, puis **Publier cette version**.
5. Sur la page principale des applications, cliquez sur… à côté de l'application et cliquez sur **Partager**.
6. Ajoutez des utilisateurs comme vous le souhaitez, puis cliquez sur **Partager**.

## Configuration des flux Power Automate

Trois flux doivent être importés pour utiliser l'application:

-  Livraison par courriel (*OGD-AM-EmailDelivery-Livraisoncourriel-PowerAutomate.ZIP*)
-  Courriel pour les commissionnaires (*OGD-AM-CommissionaireEmail-Courrielpourlescommissionaires-PowerAutomate.ZIP*)
-  Réponses aux attestations (*OGD-AM-AttestationResponse-Reponsesauxattestations-PowerAutomate.ZIP*)

Pour chaque flux, procédez comme suit:

1. Ouvrez chaque fichier ZIP, accédez au fichier **definition.json** (le chemin complet pour accéder au fichier est **Microsoft.Flow\flows\{nom du dossier à numéro hexadécimal}**) et remplacez le texte *YOUR_SHAREPOINT_ONLINE_SITE_HERE* par l'URL complète de SharePoint site sur lequel les listes ont été créées. Le nombre d'occurrences où le texte doit être mis à jour est le suivant:
   - Livraison par courriel : 5 fois
   - Courriel pour les commissionnaires : 4 fois
   - Réponses aux attestations : 1 fois
2. Accédez à la page principale de Power Automate. Cela peut être consulté à [https://flow.microsoft.com](https://flow.microsoft.com). Vous devrez vous connecter avec vos informations d'identification Office 365 si vous ne l'avez pas déjà fait. Basculez vers l'environnement souhaité en haut à droite de la fenêtre si nécessaire.
3. Dans le menu de gauche, cliquez sur **Mes flux**.
4. Dans le menu supérieur de la page Web, sélectionnez **Importer**.
5. Cliquez sur **Télécharger**, accédez au dossier contenant le fichier de flux ZIP souhaité et sélectionnez-le. Il sera téléchargé. Une fois terminé, cliquez sur **Importer**.
6. Pour **consulter le contenu du package**, si vous le souhaitez, sélectionnez la clé et remplacez le nom de l'application par le nom souhaité.
7. Pour chaque ressource associée, cliquez sur **Sélectionner lors de l'importation**. Si vous disposez déjà du type de connexion précédemment établie dans l'environnement, vous pouvez le sélectionner. Sinon, cliquez sur **Créer nouveau** et une nouvelle page apparaîtra montrant toutes les connexions dans l'environnement actuel. Sélectionnez **Nouvelle connexion** et recherchez le type de connexion qui correspond au type de ressource sur la page Importer le package, puis sélectionnez-le. Ensuite, vous pouvez revenir à la page Configuration de l'importation pour sélectionner cette nouvelle connexion. Les types de connexion utilisés par chaque flux sont:
   - Livraison par courriel: SharePoint, Office 365 Outlook
   - Courriel du commissionnaire: SharePoint, Office 365 Outlook
   - Réponses aux attestations: SharePoint, Microsoft Forms
8. Sélectionnez **Importer**.

Le flux de **réponses aux attestations** doit être modifié avant de pouvoir être utilisé. Procédez comme suit:

1. Accédez à **Mes flux**.
2. Survolez le flux dans la liste et cliquez sur le crayon pour modifier le flux.
3. Pour «Lorsqu'une nouvelle réponse est soumise» et «Obtenir les détails de la réponse», cliquez sur l'étape du flux afin que les détails apparaissent.
4. Il y aura un menu déroulant pour le << Form Id >>. Ouvrez ce menu et sélectionnez le formulaire d'attestation dans la liste précédemment créée.
5. Cliquez sur **Enregistrer**.
