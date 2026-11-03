import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ AJOUT : identifiants du super admin (change-les)
  static const String adminEmail = 'admin@packeasy.com';
  static const String adminPassword = 'Admin@12345'; // minimum 6 caractères

  // Variable statique pour éviter l'erreur "init() already called" sur mobile
  static bool _googleInitialized = false;

  // Initialisation conditionnelle de Google Sign-In (uniquement sur mobile)
  Future<void> _initGoogle() async {
    if (kIsWeb || _googleInitialized) return;
    await GoogleSignIn.instance.initialize();
    _googleInitialized = true;
  }

  // ✅ AJOUT : création du super admin (à appeler UNE SEULE FOIS)
  Future<void> createSuperAdmin() async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );

      await _firestore.collection('users').doc(result.user!.uid).set({
        'email': adminEmail,
        'role': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _auth.signOut(); // on se déconnecte après la création
      debugPrint('Super admin créé avec succès');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        debugPrint('Le super admin existe déjà');
      } else {
        debugPrint('Erreur création admin: ${e.message}');
      }
    } catch (e) {
      debugPrint('Erreur création admin: $e');
    }
  }

  // --- 1. INSCRIPTION ---
  Future<User?> signUp(String email, String password, {String role = 'user'}) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        await _firestore.collection('users').doc(result.user!.uid).set({
          'email': email,
          'role': role, // 'user' ou 'admin'
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return result.user;
    } catch (e) {
      debugPrint("Erreur d'inscription: $e");
      return null;
    }
  }

  // --- 2. CONNEXION EMAIL ---
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      debugPrint("Erreur de connexion: $e");
      return null;
    }
  }

  // --- 3. RÉCUPÉRER LE RÔLE --- ✅ CORRIGÉ (plus de plantage si 'role' est absent)
  Future<String> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      final data = doc.data() as Map<String, dynamic>?;
      return data?['role'] ?? 'user';
    } catch (e) {
      debugPrint("Erreur lors de la récupération du rôle: $e");
      return 'user';
    }
  }

  // --- 4. CONNEXION GOOGLE ---
  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        UserCredential result = await _auth.signInWithPopup(googleProvider);

        if (result.additionalUserInfo?.isNewUser ?? false) {
          await _firestore.collection('users').doc(result.user!.uid).set({
            'email': result.user!.email,
            'role': 'user',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        return result.user;
      } else {
        await _initGoogle();
        final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();
        final GoogleSignInAuthentication googleAuth = googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        UserCredential result = await _auth.signInWithCredential(credential);
        return result.user;
      }
    } catch (e) {
      debugPrint("Erreur Google Sign-In: $e");
      return null;
    }
  }

  // --- 5. DÉCONNEXION ---
  Future<void> signOut() async {
    if (!kIsWeb) {
      await GoogleSignIn.instance.signOut();
    }
    await _auth.signOut();
  }

  // --- 6. RÉINITIALISATION DU MOT DE PASSE ---
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      debugPrint("Erreur reset password: $e");
      return false;
    }
  }
}