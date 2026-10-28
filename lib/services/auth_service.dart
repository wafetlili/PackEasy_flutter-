import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Variable statique pour éviter l'erreur "init() already called" sur mobile
  static bool _googleInitialized = false;

  // Initialisation conditionnelle de Google Sign-In (uniquement sur mobile)
  Future<void> _initGoogle() async {
    if (kIsWeb || _googleInitialized) return;
    await GoogleSignIn.instance.initialize();
    _googleInitialized = true;
  }

  // --- 1. INSCRIPTION ---
  // Accepte un rôle (par défaut 'user') et l'enregistre dans Firestore
  Future<User?> signUp(String email, String password, {String role = 'user'}) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // On crée le profil de l'utilisateur dans Firestore avec son rôle
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

  // --- 3. RÉCUPÉRER LE RÔLE ---
  // Lit le rôle de l'utilisateur dans Firestore pour savoir où le rediriger
  Future<String> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.get('role') ?? 'user'; // Par défaut : 'user'
      }
      return 'user';
    } catch (e) {
      debugPrint("Erreur lors de la récupération du rôle: $e");
      return 'user';
    }
  }

  // --- 4. CONNEXION GOOGLE ---
  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // LOGIQUE WEB : Utilisation de la popup Firebase (contourne les limites de GoogleSignIn v7)
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        UserCredential result = await _auth.signInWithPopup(googleProvider);
        
        // Si c'est un nouvel utilisateur (1ère connexion avec Google), on crée son profil
        if (result.additionalUserInfo?.isNewUser ?? false) {
          await _firestore.collection('users').doc(result.user!.uid).set({
            'email': result.user!.email,
            'role': 'user', // Par défaut, les connexions Google sont des 'user'
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        return result.user;
      } else {
        // LOGIQUE MOBILE (Android/iOS)
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
      // Sur le Web, GoogleSignIn.instance n'est pas initialisé, on évite de l'appeler
      await GoogleSignIn.instance.signOut();
    }
    await _auth.signOut();
  }

    // --- 6. RÉINITIALISATION DU MOT DE PASSE ---
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true; // Email envoyé avec succès
    } catch (e) {
      debugPrint("Erreur reset password: $e");
      return false;
    }
  }
}