import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'PackEasy'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue sur PackEasy'**
  String get welcome;

  /// No description provided for @login.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get login;

  /// No description provided for @register.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get confirmPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get forgotPassword;

  /// No description provided for @home.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get home;

  /// No description provided for @favorites.
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get favorites;

  /// No description provided for @history.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get history;

  /// No description provided for @settings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settings;

  /// No description provided for @darkTheme.
  ///
  /// In fr, this message translates to:
  /// **'Thème sombre'**
  String get darkTheme;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @search.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une ville, un pays...'**
  String get search;

  /// No description provided for @destinations.
  ///
  /// In fr, this message translates to:
  /// **'Destinations'**
  String get destinations;

  /// No description provided for @programs.
  ///
  /// In fr, this message translates to:
  /// **'Programmes et séjours'**
  String get programs;

  /// No description provided for @trips.
  ///
  /// In fr, this message translates to:
  /// **'Voyages à venir'**
  String get trips;

  /// No description provided for @noDestination.
  ///
  /// In fr, this message translates to:
  /// **'Aucune destination trouvée'**
  String get noDestination;

  /// No description provided for @noProgram.
  ///
  /// In fr, this message translates to:
  /// **'Aucun programme disponible'**
  String get noProgram;

  /// No description provided for @noTrip.
  ///
  /// In fr, this message translates to:
  /// **'Aucun voyage planifié'**
  String get noTrip;

  /// No description provided for @loading.
  ///
  /// In fr, this message translates to:
  /// **'Préparation de votre voyage...'**
  String get loading;

  /// No description provided for @profile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @admin.
  ///
  /// In fr, this message translates to:
  /// **'Administrateur'**
  String get admin;

  /// No description provided for @user.
  ///
  /// In fr, this message translates to:
  /// **'Voyageur'**
  String get user;

  /// No description provided for @addDestination.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une destination'**
  String get addDestination;

  /// No description provided for @addProgram.
  ///
  /// In fr, this message translates to:
  /// **'Créer un programme'**
  String get addProgram;

  /// No description provided for @addTrip.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un voyage'**
  String get addTrip;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @errorEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email invalide'**
  String get errorEmail;

  /// No description provided for @errorPassword.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe doit contenir au moins 6 caractères'**
  String get errorPassword;

  /// No description provided for @errorPasswordMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get errorPasswordMismatch;

  /// No description provided for @monEspace.
  ///
  /// In fr, this message translates to:
  /// **'Mon Espace'**
  String get monEspace;

  /// No description provided for @discover.
  ///
  /// In fr, this message translates to:
  /// **'Découvrir'**
  String get discover;

  /// No description provided for @profileTab.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get profileTab;

  /// No description provided for @backToApp.
  ///
  /// In fr, this message translates to:
  /// **'Retour à l\'application'**
  String get backToApp;

  /// No description provided for @dashboard.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord'**
  String get dashboard;

  /// No description provided for @users.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateurs'**
  String get users;

  /// No description provided for @upcomingDepartures.
  ///
  /// In fr, this message translates to:
  /// **'Départs imminents'**
  String get upcomingDepartures;

  /// No description provided for @noUpcomingTrip.
  ///
  /// In fr, this message translates to:
  /// **'Aucun voyage à venir.'**
  String get noUpcomingTrip;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @errorGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue. Réessayez.'**
  String get errorGeneric;

  /// No description provided for @errorLoading.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les données'**
  String get errorLoading;

  /// No description provided for @errorNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez votre connexion internet'**
  String get errorNetwork;

  /// No description provided for @add.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get add;

  /// No description provided for @create.
  ///
  /// In fr, this message translates to:
  /// **'Créer'**
  String get create;

  /// No description provided for @close.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get close;

  /// No description provided for @deleted.
  ///
  /// In fr, this message translates to:
  /// **'Supprimé'**
  String get deleted;

  /// No description provided for @saved.
  ///
  /// In fr, this message translates to:
  /// **'Enregistré'**
  String get saved;

  /// No description provided for @loginRequired.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour continuer'**
  String get loginRequired;

  /// No description provided for @view.
  ///
  /// In fr, this message translates to:
  /// **'Voir'**
  String get view;

  /// No description provided for @guest.
  ///
  /// In fr, this message translates to:
  /// **'Invité'**
  String get guest;

  /// No description provided for @errorRequired.
  ///
  /// In fr, this message translates to:
  /// **'Ce champ est obligatoire'**
  String get errorRequired;

  /// No description provided for @errorNumber.
  ///
  /// In fr, this message translates to:
  /// **'Entrez un nombre valide'**
  String get errorNumber;

  /// No description provided for @errorPositive.
  ///
  /// In fr, this message translates to:
  /// **'Entrez une valeur supérieure à 0'**
  String get errorPositive;

  /// No description provided for @errorMinLength.
  ///
  /// In fr, this message translates to:
  /// **'Minimum {min} caractères'**
  String errorMinLength(int min);

  /// No description provided for @errorUrl.
  ///
  /// In fr, this message translates to:
  /// **'URL invalide (commencez par http ou https)'**
  String get errorUrl;

  /// No description provided for @errorDate.
  ///
  /// In fr, this message translates to:
  /// **'Date invalide (JJ/MM/AAAA)'**
  String get errorDate;

  /// No description provided for @errorDateOrder.
  ///
  /// In fr, this message translates to:
  /// **'La date de fin doit être après la date de début'**
  String get errorDateOrder;

  /// No description provided for @errorAmount.
  ///
  /// In fr, this message translates to:
  /// **'Entrez un montant valide (supérieur à 0)'**
  String get errorAmount;

  /// No description provided for @errorBudget.
  ///
  /// In fr, this message translates to:
  /// **'Entrez un budget valide (nombre supérieur à 0)'**
  String get errorBudget;

  /// No description provided for @errorDestination.
  ///
  /// In fr, this message translates to:
  /// **'Entrez une destination (2 caractères minimum)'**
  String get errorDestination;

  /// No description provided for @errorName.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre nom (2 caractères minimum)'**
  String get errorName;

  /// No description provided for @errorItemExists.
  ///
  /// In fr, this message translates to:
  /// **'Cet objet existe déjà'**
  String get errorItemExists;

  /// No description provided for @authInvalidCredential.
  ///
  /// In fr, this message translates to:
  /// **'Email ou mot de passe incorrect'**
  String get authInvalidCredential;

  /// No description provided for @authUserNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun compte ne correspond à cet email'**
  String get authUserNotFound;

  /// No description provided for @authEmailInUse.
  ///
  /// In fr, this message translates to:
  /// **'Cet email est déjà utilisé'**
  String get authEmailInUse;

  /// No description provided for @authWeakPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe trop faible'**
  String get authWeakPassword;

  /// No description provided for @authNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Problème de connexion internet'**
  String get authNetwork;

  /// No description provided for @authTooMany.
  ///
  /// In fr, this message translates to:
  /// **'Trop de tentatives, réessayez plus tard'**
  String get authTooMany;

  /// No description provided for @authCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Connexion Google annulée'**
  String get authCancelled;

  /// No description provided for @authUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Échec de l\'authentification'**
  String get authUnknown;

  /// No description provided for @loginSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Connexion réussie'**
  String get loginSuccess;

  /// No description provided for @welcomeBack.
  ///
  /// In fr, this message translates to:
  /// **'Ravi de vous revoir sur PackEasy !'**
  String get welcomeBack;

  /// No description provided for @registerSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Compte créé'**
  String get registerSuccess;

  /// No description provided for @welcomeNew.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue ! Votre compte a été créé avec succès.'**
  String get welcomeNew;

  /// No description provided for @loginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bon retour !'**
  String get loginTitle;

  /// No description provided for @createAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get createAccount;

  /// No description provided for @continueGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Google'**
  String get continueGoogle;

  /// No description provided for @noAccount.
  ///
  /// In fr, this message translates to:
  /// **'Pas de compte ? S\'inscrire'**
  String get noAccount;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié'**
  String get forgotPasswordTitle;

  /// No description provided for @resetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialisation'**
  String get resetTitle;

  /// No description provided for @resetHint.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre email pour recevoir un lien.'**
  String get resetHint;

  /// No description provided for @sendLink.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer le lien'**
  String get sendLink;

  /// No description provided for @resetSent.
  ///
  /// In fr, this message translates to:
  /// **'Email envoyé, vérifiez votre boîte de réception'**
  String get resetSent;

  /// No description provided for @onbTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre guide de voyage ultime.'**
  String get onbTitle;

  /// No description provided for @onbSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Trouvez la destination adaptée à votre budget, planifiez vos visites et préparez vos bagages.'**
  String get onbSubtitle;

  /// No description provided for @start.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get start;

  /// No description provided for @destinationsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} destinations - 5 continents'**
  String destinationsCount(int count);

  /// No description provided for @phrase1.
  ///
  /// In fr, this message translates to:
  /// **'Où voulez-vous aller ?'**
  String get phrase1;

  /// No description provided for @phrase2.
  ///
  /// In fr, this message translates to:
  /// **'Plages de rêve'**
  String get phrase2;

  /// No description provided for @phrase3.
  ///
  /// In fr, this message translates to:
  /// **'Villes inoubliables'**
  String get phrase3;

  /// No description provided for @phrase4.
  ///
  /// In fr, this message translates to:
  /// **'Aventures nature'**
  String get phrase4;

  /// No description provided for @phrase5.
  ///
  /// In fr, this message translates to:
  /// **'Culture et histoire'**
  String get phrase5;

  /// No description provided for @changeTheme.
  ///
  /// In fr, this message translates to:
  /// **'Changer de thème'**
  String get changeTheme;

  /// No description provided for @all.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get all;

  /// No description provided for @africa.
  ///
  /// In fr, this message translates to:
  /// **'Afrique'**
  String get africa;

  /// No description provided for @europe.
  ///
  /// In fr, this message translates to:
  /// **'Europe'**
  String get europe;

  /// No description provided for @asia.
  ///
  /// In fr, this message translates to:
  /// **'Asie'**
  String get asia;

  /// No description provided for @america.
  ///
  /// In fr, this message translates to:
  /// **'Amérique'**
  String get america;

  /// No description provided for @oceania.
  ///
  /// In fr, this message translates to:
  /// **'Océanie'**
  String get oceania;

  /// No description provided for @beach.
  ///
  /// In fr, this message translates to:
  /// **'Plage'**
  String get beach;

  /// No description provided for @culture.
  ///
  /// In fr, this message translates to:
  /// **'Culture'**
  String get culture;

  /// No description provided for @nature.
  ///
  /// In fr, this message translates to:
  /// **'Nature'**
  String get nature;

  /// No description provided for @city.
  ///
  /// In fr, this message translates to:
  /// **'Ville'**
  String get city;

  /// No description provided for @practicalInfo.
  ///
  /// In fr, this message translates to:
  /// **'Infos pratiques'**
  String get practicalInfo;

  /// No description provided for @bestSeason.
  ///
  /// In fr, this message translates to:
  /// **'Meilleure saison'**
  String get bestSeason;

  /// No description provided for @avgTemp.
  ///
  /// In fr, this message translates to:
  /// **'Température moyenne'**
  String get avgTemp;

  /// No description provided for @languages.
  ///
  /// In fr, this message translates to:
  /// **'Langues'**
  String get languages;

  /// No description provided for @currency.
  ///
  /// In fr, this message translates to:
  /// **'Monnaie'**
  String get currency;

  /// No description provided for @mustSee.
  ///
  /// In fr, this message translates to:
  /// **'À ne pas manquer'**
  String get mustSee;

  /// No description provided for @budgetIndicative.
  ///
  /// In fr, this message translates to:
  /// **'Budget indicatif : ~{budget} € / personne'**
  String budgetIndicative(int budget);

  /// No description provided for @createTrip.
  ///
  /// In fr, this message translates to:
  /// **'Créer un voyage'**
  String get createTrip;

  /// No description provided for @tripCreated.
  ///
  /// In fr, this message translates to:
  /// **'Voyage vers {destination} créé'**
  String tripCreated(String destination);

  /// No description provided for @reservationConfirmed.
  ///
  /// In fr, this message translates to:
  /// **'Réservation confirmée'**
  String get reservationConfirmed;

  /// No description provided for @reservationBody.
  ///
  /// In fr, this message translates to:
  /// **'Votre voyage vers {destination} a bien été réservé.'**
  String reservationBody(String destination);

  /// No description provided for @addedToFavorites.
  ///
  /// In fr, this message translates to:
  /// **'{name} ajouté aux favoris'**
  String addedToFavorites(String name);

  /// No description provided for @removedFromFavorites.
  ///
  /// In fr, this message translates to:
  /// **'{name} retiré des favoris'**
  String removedFromFavorites(String name);

  /// No description provided for @liveWeather.
  ///
  /// In fr, this message translates to:
  /// **'Météo en direct'**
  String get liveWeather;

  /// No description provided for @weatherUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Météo indisponible pour cette destination'**
  String get weatherUnavailable;

  /// No description provided for @wind.
  ///
  /// In fr, this message translates to:
  /// **'Vent : {speed} km/h'**
  String wind(String speed);

  /// No description provided for @weatherClear.
  ///
  /// In fr, this message translates to:
  /// **'Ciel dégagé'**
  String get weatherClear;

  /// No description provided for @weatherCloudy.
  ///
  /// In fr, this message translates to:
  /// **'Nuageux'**
  String get weatherCloudy;

  /// No description provided for @weatherFog.
  ///
  /// In fr, this message translates to:
  /// **'Brouillard'**
  String get weatherFog;

  /// No description provided for @weatherRain.
  ///
  /// In fr, this message translates to:
  /// **'Pluie'**
  String get weatherRain;

  /// No description provided for @weatherSnow.
  ///
  /// In fr, this message translates to:
  /// **'Neige'**
  String get weatherSnow;

  /// No description provided for @weatherStorm.
  ///
  /// In fr, this message translates to:
  /// **'Orage'**
  String get weatherStorm;

  /// No description provided for @mySpace.
  ///
  /// In fr, this message translates to:
  /// **'Mon espace voyageur'**
  String get mySpace;

  /// No description provided for @myTrips.
  ///
  /// In fr, this message translates to:
  /// **'Mes voyages'**
  String get myTrips;

  /// No description provided for @budget.
  ///
  /// In fr, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @myBag.
  ///
  /// In fr, this message translates to:
  /// **'Ma valise'**
  String get myBag;

  /// No description provided for @exploreDestinations.
  ///
  /// In fr, this message translates to:
  /// **'Explorer les destinations'**
  String get exploreDestinations;

  /// No description provided for @hello.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour, {name}'**
  String hello(String name);

  /// No description provided for @readyAdventure.
  ///
  /// In fr, this message translates to:
  /// **'Prêt pour votre prochaine aventure ?'**
  String get readyAdventure;

  /// No description provided for @noTripPlanned.
  ///
  /// In fr, this message translates to:
  /// **'Aucun voyage prévu'**
  String get noTripPlanned;

  /// No description provided for @noTripHint.
  ///
  /// In fr, this message translates to:
  /// **'Explorez les destinations ou créez votre premier voyage.'**
  String get noTripHint;

  /// No description provided for @explore.
  ///
  /// In fr, this message translates to:
  /// **'Explorer'**
  String get explore;

  /// No description provided for @newTrip.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau voyage'**
  String get newTrip;

  /// No description provided for @expense.
  ///
  /// In fr, this message translates to:
  /// **'Dépense'**
  String get expense;

  /// No description provided for @item.
  ///
  /// In fr, this message translates to:
  /// **'Objet'**
  String get item;

  /// No description provided for @tripsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Voyages'**
  String get tripsLabel;

  /// No description provided for @spent.
  ///
  /// In fr, this message translates to:
  /// **'Dépensé'**
  String get spent;

  /// No description provided for @bag.
  ///
  /// In fr, this message translates to:
  /// **'Valise'**
  String get bag;

  /// No description provided for @quickAccess.
  ///
  /// In fr, this message translates to:
  /// **'Accès rapide'**
  String get quickAccess;

  /// No description provided for @daysLeft.
  ///
  /// In fr, this message translates to:
  /// **'J-{days}'**
  String daysLeft(int days);

  /// No description provided for @today.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get today;

  /// No description provided for @ongoing.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get ongoing;

  /// No description provided for @daysAndBudget.
  ///
  /// In fr, this message translates to:
  /// **'{days} jours • Budget {budget} €'**
  String daysAndBudget(int days, int budget);

  /// No description provided for @upcoming.
  ///
  /// In fr, this message translates to:
  /// **'À venir'**
  String get upcoming;

  /// No description provided for @noUpcomingTrips.
  ///
  /// In fr, this message translates to:
  /// **'Aucun voyage à venir'**
  String get noUpcomingTrips;

  /// No description provided for @noPastTrips.
  ///
  /// In fr, this message translates to:
  /// **'Aucun voyage passé'**
  String get noPastTrips;

  /// No description provided for @destination.
  ///
  /// In fr, this message translates to:
  /// **'Destination'**
  String get destination;

  /// No description provided for @budgetEuro.
  ///
  /// In fr, this message translates to:
  /// **'Budget (€)'**
  String get budgetEuro;

  /// No description provided for @chooseDates.
  ///
  /// In fr, this message translates to:
  /// **'Choisir les dates'**
  String get chooseDates;

  /// No description provided for @chooseDatesError.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez les dates du voyage'**
  String get chooseDatesError;

  /// No description provided for @tripDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Voyage vers {destination} supprimé'**
  String tripDeleted(String destination);

  /// No description provided for @createFirstTrip.
  ///
  /// In fr, this message translates to:
  /// **'Créez d\'abord un voyage'**
  String get createFirstTrip;

  /// No description provided for @budgetLinked.
  ///
  /// In fr, this message translates to:
  /// **'Le budget est lié à votre prochain voyage.'**
  String get budgetLinked;

  /// No description provided for @budgetOf.
  ///
  /// In fr, this message translates to:
  /// **'Budget : {amount} €'**
  String budgetOf(int amount);

  /// No description provided for @spentOf.
  ///
  /// In fr, this message translates to:
  /// **'Dépensé : {amount} €'**
  String spentOf(int amount);

  /// No description provided for @remaining.
  ///
  /// In fr, this message translates to:
  /// **'Reste : {amount} €'**
  String remaining(int amount);

  /// No description provided for @overBudget.
  ///
  /// In fr, this message translates to:
  /// **'Dépassement : {amount} €'**
  String overBudget(int amount);

  /// No description provided for @byCategory.
  ///
  /// In fr, this message translates to:
  /// **'Par catégorie'**
  String get byCategory;

  /// No description provided for @expenses.
  ///
  /// In fr, this message translates to:
  /// **'Dépenses'**
  String get expenses;

  /// No description provided for @noExpense.
  ///
  /// In fr, this message translates to:
  /// **'Aucune dépense pour le moment'**
  String get noExpense;

  /// No description provided for @addExpense.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une dépense'**
  String get addExpense;

  /// No description provided for @description.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @amountEuro.
  ///
  /// In fr, this message translates to:
  /// **'Montant (€)'**
  String get amountEuro;

  /// No description provided for @category.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get category;

  /// No description provided for @expenseAdded.
  ///
  /// In fr, this message translates to:
  /// **'Dépense ajoutée'**
  String get expenseAdded;

  /// No description provided for @catTransport.
  ///
  /// In fr, this message translates to:
  /// **'Transport'**
  String get catTransport;

  /// No description provided for @catLodging.
  ///
  /// In fr, this message translates to:
  /// **'Hébergement'**
  String get catLodging;

  /// No description provided for @catFood.
  ///
  /// In fr, this message translates to:
  /// **'Nourriture'**
  String get catFood;

  /// No description provided for @catActivities.
  ///
  /// In fr, this message translates to:
  /// **'Activités'**
  String get catActivities;

  /// No description provided for @catOther.
  ///
  /// In fr, this message translates to:
  /// **'Autres'**
  String get catOther;

  /// No description provided for @packedCount.
  ///
  /// In fr, this message translates to:
  /// **'{done} / {total} objets préparés'**
  String packedCount(int done, int total);

  /// No description provided for @readyToFly.
  ///
  /// In fr, this message translates to:
  /// **'Prêt au décollage !'**
  String get readyToFly;

  /// No description provided for @bagEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Votre valise est vide'**
  String get bagEmpty;

  /// No description provided for @addItem.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un objet'**
  String get addItem;

  /// No description provided for @itemHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex : Parapluie'**
  String get itemHint;

  /// No description provided for @sugPassport.
  ///
  /// In fr, this message translates to:
  /// **'Passeport'**
  String get sugPassport;

  /// No description provided for @sugCharger.
  ///
  /// In fr, this message translates to:
  /// **'Chargeur de téléphone'**
  String get sugCharger;

  /// No description provided for @sugToiletries.
  ///
  /// In fr, this message translates to:
  /// **'Trousse de toilette'**
  String get sugToiletries;

  /// No description provided for @sugClothes.
  ///
  /// In fr, this message translates to:
  /// **'Vêtements'**
  String get sugClothes;

  /// No description provided for @sugUmbrella.
  ///
  /// In fr, this message translates to:
  /// **'Parapluie'**
  String get sugUmbrella;

  /// No description provided for @sugSwimsuit.
  ///
  /// In fr, this message translates to:
  /// **'Maillot de bain'**
  String get sugSwimsuit;

  /// No description provided for @sugAdapter.
  ///
  /// In fr, this message translates to:
  /// **'Adaptateur de prise'**
  String get sugAdapter;

  /// No description provided for @sugSunglasses.
  ///
  /// In fr, this message translates to:
  /// **'Lunettes de soleil'**
  String get sugSunglasses;

  /// No description provided for @sugSunscreen.
  ///
  /// In fr, this message translates to:
  /// **'Crème solaire'**
  String get sugSunscreen;

  /// No description provided for @sugMedicine.
  ///
  /// In fr, this message translates to:
  /// **'Médicaments'**
  String get sugMedicine;

  /// No description provided for @sugHeadphones.
  ///
  /// In fr, this message translates to:
  /// **'Écouteurs'**
  String get sugHeadphones;

  /// No description provided for @sugBankCard.
  ///
  /// In fr, this message translates to:
  /// **'Carte bancaire'**
  String get sugBankCard;

  /// No description provided for @tripDetails.
  ///
  /// In fr, this message translates to:
  /// **'Détails du voyage'**
  String get tripDetails;

  /// No description provided for @dates.
  ///
  /// In fr, this message translates to:
  /// **'Dates'**
  String get dates;

  /// No description provided for @durationDays.
  ///
  /// In fr, this message translates to:
  /// **'{days} jours'**
  String durationDays(int days);

  /// No description provided for @tripExpenses.
  ///
  /// In fr, this message translates to:
  /// **'Dépenses du voyage'**
  String get tripExpenses;

  /// No description provided for @deleteTrip.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le voyage'**
  String get deleteTrip;

  /// No description provided for @confirmDelete.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer la suppression ?'**
  String get confirmDelete;

  /// No description provided for @tripFromTo.
  ///
  /// In fr, this message translates to:
  /// **'Du {start} au {end}'**
  String tripFromTo(String start, String end);

  /// No description provided for @fullName.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get fullName;

  /// No description provided for @profileUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Profil mis à jour'**
  String get profileUpdated;

  /// No description provided for @role.
  ///
  /// In fr, this message translates to:
  /// **'Rôle'**
  String get role;

  /// No description provided for @appearance.
  ///
  /// In fr, this message translates to:
  /// **'Apparence'**
  String get appearance;

  /// No description provided for @themeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get themeLabel;

  /// No description provided for @themeSystem.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get themeDark;

  /// No description provided for @notifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @offersNotif.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir les offres et actualités'**
  String get offersNotif;

  /// No description provided for @testNotification.
  ///
  /// In fr, this message translates to:
  /// **'Tester une notification'**
  String get testNotification;

  /// No description provided for @testNotifBody.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez ici pour ouvrir vos voyages.'**
  String get testNotifBody;

  /// No description provided for @about.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get about;

  /// No description provided for @aboutText.
  ///
  /// In fr, this message translates to:
  /// **'PackEasy vous aide à choisir, planifier et préparer vos voyages.'**
  String get aboutText;

  /// No description provided for @version.
  ///
  /// In fr, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @noFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Aucun favori pour le moment'**
  String get noFavorites;

  /// No description provided for @noFavoritesHint.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez sur le cœur d\'une destination pour l\'ajouter ici.'**
  String get noFavoritesHint;

  /// No description provided for @currencyConverter.
  ///
  /// In fr, this message translates to:
  /// **'Convertisseur de devises'**
  String get currencyConverter;

  /// No description provided for @amount.
  ///
  /// In fr, this message translates to:
  /// **'Montant'**
  String get amount;

  /// No description provided for @baseCurrency.
  ///
  /// In fr, this message translates to:
  /// **'Devise de départ'**
  String get baseCurrency;

  /// No description provided for @exchangeRates.
  ///
  /// In fr, this message translates to:
  /// **'Taux de change'**
  String get exchangeRates;

  /// No description provided for @ratesError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les taux de change'**
  String get ratesError;

  /// No description provided for @lastUpdate.
  ///
  /// In fr, this message translates to:
  /// **'Mis à jour : {date}'**
  String lastUpdate(String date);

  /// No description provided for @adminGreeting.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour, Admin'**
  String get adminGreeting;

  /// No description provided for @adminTitle.
  ///
  /// In fr, this message translates to:
  /// **'Admin PackEasy'**
  String get adminTitle;

  /// No description provided for @name.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get name;

  /// No description provided for @country.
  ///
  /// In fr, this message translates to:
  /// **'Pays'**
  String get country;

  /// No description provided for @flagEmoji.
  ///
  /// In fr, this message translates to:
  /// **'Emoji du drapeau'**
  String get flagEmoji;

  /// No description provided for @continent.
  ///
  /// In fr, this message translates to:
  /// **'Continent'**
  String get continent;

  /// No description provided for @imageUrl.
  ///
  /// In fr, this message translates to:
  /// **'URL de l\'image'**
  String get imageUrl;

  /// No description provided for @programTitle.
  ///
  /// In fr, this message translates to:
  /// **'Titre du programme'**
  String get programTitle;

  /// No description provided for @programType.
  ///
  /// In fr, this message translates to:
  /// **'Type de programme'**
  String get programType;

  /// No description provided for @durationField.
  ///
  /// In fr, this message translates to:
  /// **'Durée (jours)'**
  String get durationField;

  /// No description provided for @priceEuro.
  ///
  /// In fr, this message translates to:
  /// **'Prix (€)'**
  String get priceEuro;

  /// No description provided for @tripTitle.
  ///
  /// In fr, this message translates to:
  /// **'Titre du voyage'**
  String get tripTitle;

  /// No description provided for @startDate.
  ///
  /// In fr, this message translates to:
  /// **'Date de début (JJ/MM/AAAA)'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In fr, this message translates to:
  /// **'Date de fin (JJ/MM/AAAA)'**
  String get endDate;

  /// No description provided for @departure.
  ///
  /// In fr, this message translates to:
  /// **'Départ : {date}'**
  String departure(String date);

  /// No description provided for @noNotification.
  ///
  /// In fr, this message translates to:
  /// **'Aucune notification'**
  String get noNotification;

  /// No description provided for @importSamples.
  ///
  /// In fr, this message translates to:
  /// **'Importer les destinations d\'exemple'**
  String get importSamples;

  /// No description provided for @samplesImported.
  ///
  /// In fr, this message translates to:
  /// **'{count} destinations importées'**
  String samplesImported(int count);

  /// No description provided for @typeSeminar.
  ///
  /// In fr, this message translates to:
  /// **'Séminaire'**
  String get typeSeminar;

  /// No description provided for @typeGroup.
  ///
  /// In fr, this message translates to:
  /// **'Voyage de groupe'**
  String get typeGroup;

  /// No description provided for @typeEurope.
  ///
  /// In fr, this message translates to:
  /// **'Tour d\'Europe'**
  String get typeEurope;

  /// No description provided for @typeAdventure.
  ///
  /// In fr, this message translates to:
  /// **'Aventure'**
  String get typeAdventure;

  /// No description provided for @typeRelax.
  ///
  /// In fr, this message translates to:
  /// **'Détente'**
  String get typeRelax;

  /// No description provided for @typeOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get typeOther;

  /// No description provided for @durationShort.
  ///
  /// In fr, this message translates to:
  /// **'{days} j'**
  String durationShort(int days);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
