# PackEasy

Application Flutter de voyage : destinations, voyages, budget, valise.

## Lancer le projet

```bash
flutter pub get          # installe les paquets (et régénère les traductions)
flutter run              # Android / iOS recommandé (publicités et notifications)
flutter test             # tests des validateurs
```

Commande de traduction (si vous modifiez les fichiers `lib/l10n/*.arb`) : `flutter gen-l10n`

## Ce qui est branché sur Firestore (plus rien de statique)

| Donnée | Emplacement Firestore |
|---|---|
| Destinations | `destinations` (liste d'exemple affichée si la collection est vide) |
| Programmes / voyages proposés | `programs`, `trips` (gérés par l'admin) |
| Profil, rôle, jeton de notification | `users/{uid}` |
| Mes voyages | `users/{uid}/trips` |
| Mes dépenses (liées à un voyage) | `users/{uid}/expenses` |
| Ma valise | `users/{uid}/packing` |
| Mes favoris | `users/{uid}/favorites` |

Admin : bouton **Importer les destinations d'exemple** (onglet Destinations) pour copier les 17 destinations dans Firestore.
Le fichier `firestore.rules` contient des règles de sécurité prêtes à publier (optionnel).

## Cahier des charges : où est chaque point ?

| Exigence | Fichier(s) |
|---|---|
| Cloud Firestore | `providers/*`, `services/*`, `screens/admin_dashboard.dart` |
| Auth email + Google | `services/auth_service.dart`, `screens/login_screen.dart` |
| Formulaires validés | `utils/validators.dart` + tous les écrans de saisie |
| Notifications push (FCM) | `services/notification_service.dart`, `main.dart`, `utils/app_navigator.dart` |
| FR / EN / AR + RTL | `lib/l10n/*.arb`, `main.dart`, `screens/settings_screen.dart` |
| Thème clair / sombre persistant | `providers/theme_provider.dart` |
| Drawer, BottomNavigationBar, TabBar | `home_screen.dart`, `user_dashboard.dart`, `trips_tab.dart` |
| 10 écrans ou plus | 13 écrans (liste ci-dessous) |
| Animations | Hero, AnimatedContainer, AnimatedOpacity, TweenAnimationBuilder, route avion |
| Provider | `providers/*` |
| Navigation avancée | routes nommées (`main.dart`), arguments, navigateur imbriqué (`user_dashboard.dart`) |
| API REST | `services/api_service.dart` (météo + devises) |
| Erreurs / chargement | `widgets/state_views.dart`, `utils/ui.dart` |
| Publicités (test) | `services/ad_service.dart`, `widgets/banner_ad_widget.dart` |

Écrans : Onboarding, Accueil, Détails destination, Connexion, Inscription, Mot de passe oublié,
Espace voyageur, Détails d'un voyage (imbriqué), Favoris, Profil, Paramètres, Convertisseur de devises, Admin.

## Notifications

* **Locale (déclenchée par une action)** : réservation d'un voyage, connexion, inscription, bouton de test dans Paramètres.
* **Push Firebase** : console Firebase > Cloud Messaging > Nouvelle campagne > Notification.
  Pour ouvrir un écran au clic, ajoutez la donnée personnalisée `screen` = `reservation`, `favorites`, `currency` ou `trips`.
* Premier plan : affichée par `flutter_local_notifications`. Arrière-plan / fermée : affichée par Android.
* Web : ajoutez votre clé VAPID dans `_vapidKey` (`notification_service.dart`).

## À configurer de votre côté

1. **Google Sign-In Android** : ajoutez l'empreinte SHA-1 de votre clé dans Firebase (Paramètres du projet), téléchargez le nouveau `google-services.json`.
   `cd android && ./gradlew signingReport` affiche la SHA-1.
2. **iOS** : activez Push Notifications dans Xcode et envoyez la clé APNs à Firebase.
3. **Compte admin** : créez-le dans Firebase Auth, puis mettez `role: "admin"` dans son document `users/{uid}`.
4. **Publicités** : uniquement les identifiants de TEST de Google (Android et iOS ; rien ne s'affiche sur le web).
