// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'PackEasy';

  @override
  String get welcome => 'Bienvenue sur PackEasy';

  @override
  String get login => 'Se connecter';

  @override
  String get register => 'S\'inscrire';

  @override
  String get logout => 'Déconnexion';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mot de passe';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get home => 'Accueil';

  @override
  String get favorites => 'Favoris';

  @override
  String get history => 'Historique';

  @override
  String get settings => 'Paramètres';

  @override
  String get darkTheme => 'Thème sombre';

  @override
  String get language => 'Langue';

  @override
  String get search => 'Rechercher une ville, un pays...';

  @override
  String get destinations => 'Destinations';

  @override
  String get programs => 'Programmes et séjours';

  @override
  String get trips => 'Voyages à venir';

  @override
  String get noDestination => 'Aucune destination trouvée';

  @override
  String get noProgram => 'Aucun programme disponible';

  @override
  String get noTrip => 'Aucun voyage planifié';

  @override
  String get loading => 'Préparation de votre voyage...';

  @override
  String get profile => 'Profil';

  @override
  String get admin => 'Administrateur';

  @override
  String get user => 'Voyageur';

  @override
  String get addDestination => 'Ajouter une destination';

  @override
  String get addProgram => 'Créer un programme';

  @override
  String get addTrip => 'Ajouter un voyage';

  @override
  String get delete => 'Supprimer';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get errorEmail => 'Email invalide';

  @override
  String get errorPassword =>
      'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get errorPasswordMismatch => 'Les mots de passe ne correspondent pas';

  @override
  String get monEspace => 'Mon Espace';

  @override
  String get discover => 'Découvrir';

  @override
  String get profileTab => 'Profil';

  @override
  String get backToApp => 'Retour à l\'application';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get users => 'Utilisateurs';

  @override
  String get upcomingDepartures => 'Départs imminents';

  @override
  String get noUpcomingTrip => 'Aucun voyage à venir.';

  @override
  String get retry => 'Réessayer';

  @override
  String get errorGeneric => 'Une erreur est survenue. Réessayez.';

  @override
  String get errorLoading => 'Impossible de charger les données';

  @override
  String get errorNetwork => 'Vérifiez votre connexion internet';

  @override
  String get add => 'Ajouter';

  @override
  String get create => 'Créer';

  @override
  String get close => 'Fermer';

  @override
  String get deleted => 'Supprimé';

  @override
  String get saved => 'Enregistré';

  @override
  String get loginRequired => 'Connectez-vous pour continuer';

  @override
  String get view => 'Voir';

  @override
  String get guest => 'Invité';

  @override
  String get errorRequired => 'Ce champ est obligatoire';

  @override
  String get errorNumber => 'Entrez un nombre valide';

  @override
  String get errorPositive => 'Entrez une valeur supérieure à 0';

  @override
  String errorMinLength(int min) {
    return 'Minimum $min caractères';
  }

  @override
  String get errorUrl => 'URL invalide (commencez par http ou https)';

  @override
  String get errorDate => 'Date invalide (JJ/MM/AAAA)';

  @override
  String get errorDateOrder =>
      'La date de fin doit être après la date de début';

  @override
  String get errorAmount => 'Entrez un montant valide (supérieur à 0)';

  @override
  String get errorBudget => 'Entrez un budget valide (nombre supérieur à 0)';

  @override
  String get errorDestination =>
      'Entrez une destination (2 caractères minimum)';

  @override
  String get errorName => 'Entrez votre nom (2 caractères minimum)';

  @override
  String get errorItemExists => 'Cet objet existe déjà';

  @override
  String get authInvalidCredential => 'Email ou mot de passe incorrect';

  @override
  String get authUserNotFound => 'Aucun compte ne correspond à cet email';

  @override
  String get authEmailInUse => 'Cet email est déjà utilisé';

  @override
  String get authWeakPassword => 'Mot de passe trop faible';

  @override
  String get authNetwork => 'Problème de connexion internet';

  @override
  String get authTooMany => 'Trop de tentatives, réessayez plus tard';

  @override
  String get authCancelled => 'Connexion Google annulée';

  @override
  String get authUnknown => 'Échec de l\'authentification';

  @override
  String get loginSuccess => 'Connexion réussie';

  @override
  String get welcomeBack => 'Ravi de vous revoir sur PackEasy !';

  @override
  String get registerSuccess => 'Compte créé';

  @override
  String get welcomeNew => 'Bienvenue ! Votre compte a été créé avec succès.';

  @override
  String get loginTitle => 'Bon retour !';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get continueGoogle => 'Continuer avec Google';

  @override
  String get noAccount => 'Pas de compte ? S\'inscrire';

  @override
  String get forgotPasswordTitle => 'Mot de passe oublié';

  @override
  String get resetTitle => 'Réinitialisation';

  @override
  String get resetHint => 'Entrez votre email pour recevoir un lien.';

  @override
  String get sendLink => 'Envoyer le lien';

  @override
  String get resetSent => 'Email envoyé, vérifiez votre boîte de réception';

  @override
  String get onbTitle => 'Votre guide de voyage ultime.';

  @override
  String get onbSubtitle =>
      'Trouvez la destination adaptée à votre budget, planifiez vos visites et préparez vos bagages.';

  @override
  String get start => 'Commencer';

  @override
  String destinationsCount(int count) {
    return '$count destinations - 5 continents';
  }

  @override
  String get phrase1 => 'Où voulez-vous aller ?';

  @override
  String get phrase2 => 'Plages de rêve';

  @override
  String get phrase3 => 'Villes inoubliables';

  @override
  String get phrase4 => 'Aventures nature';

  @override
  String get phrase5 => 'Culture et histoire';

  @override
  String get changeTheme => 'Changer de thème';

  @override
  String get all => 'Tous';

  @override
  String get africa => 'Afrique';

  @override
  String get europe => 'Europe';

  @override
  String get asia => 'Asie';

  @override
  String get america => 'Amérique';

  @override
  String get oceania => 'Océanie';

  @override
  String get beach => 'Plage';

  @override
  String get culture => 'Culture';

  @override
  String get nature => 'Nature';

  @override
  String get city => 'Ville';

  @override
  String get practicalInfo => 'Infos pratiques';

  @override
  String get bestSeason => 'Meilleure saison';

  @override
  String get avgTemp => 'Température moyenne';

  @override
  String get languages => 'Langues';

  @override
  String get currency => 'Monnaie';

  @override
  String get mustSee => 'À ne pas manquer';

  @override
  String budgetIndicative(int budget) {
    return 'Budget indicatif : ~$budget € / personne';
  }

  @override
  String get createTrip => 'Créer un voyage';

  @override
  String tripCreated(String destination) {
    return 'Voyage vers $destination créé';
  }

  @override
  String get reservationConfirmed => 'Réservation confirmée';

  @override
  String reservationBody(String destination) {
    return 'Votre voyage vers $destination a bien été réservé.';
  }

  @override
  String addedToFavorites(String name) {
    return '$name ajouté aux favoris';
  }

  @override
  String removedFromFavorites(String name) {
    return '$name retiré des favoris';
  }

  @override
  String get liveWeather => 'Météo en direct';

  @override
  String get weatherUnavailable => 'Météo indisponible pour cette destination';

  @override
  String wind(String speed) {
    return 'Vent : $speed km/h';
  }

  @override
  String get weatherClear => 'Ciel dégagé';

  @override
  String get weatherCloudy => 'Nuageux';

  @override
  String get weatherFog => 'Brouillard';

  @override
  String get weatherRain => 'Pluie';

  @override
  String get weatherSnow => 'Neige';

  @override
  String get weatherStorm => 'Orage';

  @override
  String get mySpace => 'Mon espace voyageur';

  @override
  String get myTrips => 'Mes voyages';

  @override
  String get budget => 'Budget';

  @override
  String get myBag => 'Ma valise';

  @override
  String get exploreDestinations => 'Explorer les destinations';

  @override
  String hello(String name) {
    return 'Bonjour, $name';
  }

  @override
  String get readyAdventure => 'Prêt pour votre prochaine aventure ?';

  @override
  String get noTripPlanned => 'Aucun voyage prévu';

  @override
  String get noTripHint =>
      'Explorez les destinations ou créez votre premier voyage.';

  @override
  String get explore => 'Explorer';

  @override
  String get newTrip => 'Nouveau voyage';

  @override
  String get expense => 'Dépense';

  @override
  String get item => 'Objet';

  @override
  String get tripsLabel => 'Voyages';

  @override
  String get spent => 'Dépensé';

  @override
  String get bag => 'Valise';

  @override
  String get quickAccess => 'Accès rapide';

  @override
  String daysLeft(int days) {
    return 'J-$days';
  }

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get ongoing => 'En cours';

  @override
  String daysAndBudget(int days, int budget) {
    return '$days jours • Budget $budget €';
  }

  @override
  String get upcoming => 'À venir';

  @override
  String get noUpcomingTrips => 'Aucun voyage à venir';

  @override
  String get noPastTrips => 'Aucun voyage passé';

  @override
  String get destination => 'Destination';

  @override
  String get budgetEuro => 'Budget (€)';

  @override
  String get chooseDates => 'Choisir les dates';

  @override
  String get chooseDatesError => 'Choisissez les dates du voyage';

  @override
  String tripDeleted(String destination) {
    return 'Voyage vers $destination supprimé';
  }

  @override
  String get createFirstTrip => 'Créez d\'abord un voyage';

  @override
  String get budgetLinked => 'Le budget est lié à votre prochain voyage.';

  @override
  String budgetOf(int amount) {
    return 'Budget : $amount €';
  }

  @override
  String spentOf(int amount) {
    return 'Dépensé : $amount €';
  }

  @override
  String remaining(int amount) {
    return 'Reste : $amount €';
  }

  @override
  String overBudget(int amount) {
    return 'Dépassement : $amount €';
  }

  @override
  String get byCategory => 'Par catégorie';

  @override
  String get expenses => 'Dépenses';

  @override
  String get noExpense => 'Aucune dépense pour le moment';

  @override
  String get addExpense => 'Ajouter une dépense';

  @override
  String get description => 'Description';

  @override
  String get amountEuro => 'Montant (€)';

  @override
  String get category => 'Catégorie';

  @override
  String get expenseAdded => 'Dépense ajoutée';

  @override
  String get catTransport => 'Transport';

  @override
  String get catLodging => 'Hébergement';

  @override
  String get catFood => 'Nourriture';

  @override
  String get catActivities => 'Activités';

  @override
  String get catOther => 'Autres';

  @override
  String packedCount(int done, int total) {
    return '$done / $total objets préparés';
  }

  @override
  String get readyToFly => 'Prêt au décollage !';

  @override
  String get bagEmpty => 'Votre valise est vide';

  @override
  String get addItem => 'Ajouter un objet';

  @override
  String get itemHint => 'Ex : Parapluie';

  @override
  String get sugPassport => 'Passeport';

  @override
  String get sugCharger => 'Chargeur de téléphone';

  @override
  String get sugToiletries => 'Trousse de toilette';

  @override
  String get sugClothes => 'Vêtements';

  @override
  String get sugUmbrella => 'Parapluie';

  @override
  String get sugSwimsuit => 'Maillot de bain';

  @override
  String get sugAdapter => 'Adaptateur de prise';

  @override
  String get sugSunglasses => 'Lunettes de soleil';

  @override
  String get sugSunscreen => 'Crème solaire';

  @override
  String get sugMedicine => 'Médicaments';

  @override
  String get sugHeadphones => 'Écouteurs';

  @override
  String get sugBankCard => 'Carte bancaire';

  @override
  String get tripDetails => 'Détails du voyage';

  @override
  String get dates => 'Dates';

  @override
  String durationDays(int days) {
    return '$days jours';
  }

  @override
  String get tripExpenses => 'Dépenses du voyage';

  @override
  String get deleteTrip => 'Supprimer le voyage';

  @override
  String get confirmDelete => 'Confirmer la suppression ?';

  @override
  String tripFromTo(String start, String end) {
    return 'Du $start au $end';
  }

  @override
  String get fullName => 'Nom complet';

  @override
  String get profileUpdated => 'Profil mis à jour';

  @override
  String get role => 'Rôle';

  @override
  String get appearance => 'Apparence';

  @override
  String get themeLabel => 'Thème';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get notifications => 'Notifications';

  @override
  String get offersNotif => 'Recevoir les offres et actualités';

  @override
  String get testNotification => 'Tester une notification';

  @override
  String get testNotifBody => 'Appuyez ici pour ouvrir vos voyages.';

  @override
  String get about => 'À propos';

  @override
  String get aboutText =>
      'PackEasy vous aide à choisir, planifier et préparer vos voyages.';

  @override
  String get version => 'Version';

  @override
  String get noFavorites => 'Aucun favori pour le moment';

  @override
  String get noFavoritesHint =>
      'Appuyez sur le cœur d\'une destination pour l\'ajouter ici.';

  @override
  String get currencyConverter => 'Convertisseur de devises';

  @override
  String get amount => 'Montant';

  @override
  String get baseCurrency => 'Devise de départ';

  @override
  String get exchangeRates => 'Taux de change';

  @override
  String get ratesError => 'Impossible de charger les taux de change';

  @override
  String lastUpdate(String date) {
    return 'Mis à jour : $date';
  }

  @override
  String get adminGreeting => 'Bonjour, Admin';

  @override
  String get adminTitle => 'Admin PackEasy';

  @override
  String get name => 'Nom';

  @override
  String get country => 'Pays';

  @override
  String get flagEmoji => 'Emoji du drapeau';

  @override
  String get continent => 'Continent';

  @override
  String get imageUrl => 'URL de l\'image';

  @override
  String get programTitle => 'Titre du programme';

  @override
  String get programType => 'Type de programme';

  @override
  String get durationField => 'Durée (jours)';

  @override
  String get priceEuro => 'Prix (€)';

  @override
  String get tripTitle => 'Titre du voyage';

  @override
  String get startDate => 'Date de début (JJ/MM/AAAA)';

  @override
  String get endDate => 'Date de fin (JJ/MM/AAAA)';

  @override
  String departure(String date) {
    return 'Départ : $date';
  }

  @override
  String get noNotification => 'Aucune notification';

  @override
  String get importSamples => 'Importer les destinations d\'exemple';

  @override
  String samplesImported(int count) {
    return '$count destinations importées';
  }

  @override
  String get typeSeminar => 'Séminaire';

  @override
  String get typeGroup => 'Voyage de groupe';

  @override
  String get typeEurope => 'Tour d\'Europe';

  @override
  String get typeAdventure => 'Aventure';

  @override
  String get typeRelax => 'Détente';

  @override
  String get typeOther => 'Autre';

  @override
  String durationShort(int days) {
    return '$days j';
  }
}
