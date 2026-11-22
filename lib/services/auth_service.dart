// ============================================================
// auth_service.dart
// Authentification Firebase : email / mot de passe et Google.
// Les erreurs ne sont plus cachées : elles sont relancées pour
// que l'écran affiche un message clair à l'utilisateur.
// ============================================================
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Erreur spéciale : l'utilisateur a fermé la fenêtre Google
class AuthCancelledException implements Exception {}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Identifiants du super admin (à changer)
  static const String adminEmail = 'admin@packeasy.com';
  static const String adminPassword = 'Admin@12345'; // minimum 6 caractères

  // Identifiant client "Web" du projet Firebase (fichier google-services.json,
  // client_type 3). Il est nécessaire pour Google Sign-In sur Android.
  static const String _serverClientId =
      '961163650621-nudncsi02i8jt9n41222l6i5bk99ksg9.apps.googleusercontent.com';

  // Google Sign-In ne doit être initialisé qu'une seule fois
  static bool _googleInitialized = false;

  Future<void> _initGoogle() async {
    if (kIsWeb || _googleInitialized) return;
    await GoogleSignIn.instance.initialize(serverClientId: _serverClientId);
    _googleInitialized = true;
  }

  // ------------------------------------------------------------
  // Création du super admin (à appeler UNE SEULE FOIS)
  // ------------------------------------------------------------
  Future<void> createSuperAdmin() async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );
      await _firestore.collection('users').doc(result.user!.uid).set({
        'email': adminEmail,
        'role': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
      });
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      debugPrint('Création admin : ${e.code}');
    }
  }

  // ------------------------------------------------------------
  // Crée le document users/{uid} s'il n'existe pas encore
  // ------------------------------------------------------------
  Future<void> _ensureUserDoc(User user, {String? name}) async {
    final ref = _firestore.collection('users').doc(user.uid);
    final doc = await ref.get();
    if (!doc.exists) {
      await ref.set({
        'email': user.email,
        'name': name ?? user.displayName ?? '',
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // --- 1. INSCRIPTION (email + mot de passe) ---
  Future<User> signUp(String email, String password, {String name = ''}) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = result.user!;
    if (name.isNotEmpty) await user.updateDisplayName(name);
    await _ensureUserDoc(user, name: name);
    return user;
  }

  // --- 2. CONNEXION (email + mot de passe) ---
  Future<User> signIn(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user!;
  }

  // --- 3. CONNEXION GOOGLE ---
  Future<User> signInWithGoogle() async {
    UserCredential result;

    if (kIsWeb) {
      // Sur le web : fenêtre popup Google
      result = await _auth.signInWithPopup(GoogleAuthProvider());
    } else {
      // Sur mobile : sélection du compte puis échange du jeton avec Firebase
      await _initGoogle();
      try {
        final googleUser = await GoogleSignIn.instance.authenticate();
        final credential = GoogleAuthProvider.credential(
          idToken: googleUser.authentication.idToken,
        );
        result = await _auth.signInWithCredential(credential);
      } on GoogleSignInException catch (e) {
        if (e.code == GoogleSignInExceptionCode.canceled) {
          throw AuthCancelledException();
        }
        rethrow;
      }
    }

    final user = result.user!;
    await _ensureUserDoc(user);
    return user;
  }

  // --- 4. RÔLE DE L'UTILISATEUR ('user' ou 'admin') ---
  Future<String> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data()?['role'] ?? 'user';
    } catch (e) {
      debugPrint('Erreur lecture du rôle : $e');
      return 'user';
    }
  }

  // --- 5. MODIFIER LE NOM DU PROFIL ---
  Future<void> updateName(String name) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.updateDisplayName(name);
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set({'name': name}, SetOptions(merge: true));
  }

  // --- 6. DÉCONNEXION ---
  Future<void> signOut() async {
    if (!kIsWeb) {
      try {
        await _initGoogle();
        await GoogleSignIn.instance.signOut();
      } catch (e) {
        debugPrint('Déconnexion Google : $e');
      }
    }
    await _auth.signOut();
  }

  // --- 7. RÉINITIALISATION DU MOT DE PASSE ---
  Future<void> resetPassword(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }
}
