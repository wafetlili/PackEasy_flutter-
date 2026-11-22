// ============================================================
// login_screen.dart
// Connexion : email / mot de passe ou Google.
// Formulaire validé (Form + TextFormField), erreurs claires,
// notification de confirmation et redirection selon le rôle.
// ============================================================
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../utils/l10n_ext.dart';
import '../utils/labels.dart';
import '../utils/ui.dart';
import '../utils/validators.dart';
import '../widgets/auth_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Connexion avec email et mot de passe
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    await _run(() => _authService.signIn(
          _emailController.text.trim(),
          _passwordController.text,
        ));
  }

  // Connexion avec Google
  Future<void> _loginWithGoogle() async {
    await _run(() => _authService.signInWithGoogle());
  }

  // Exécute une connexion : chargement, erreur éventuelle, puis redirection
  Future<void> _run(Future<User> Function() action) async {
    final l = context.l10n;
    setState(() => _isLoading = true);
    try {
      final user = await action();
      final role = await _authService.getUserRole(user.uid);
      if (!mounted) return;

      // Notification locale de confirmation
      NotificationService().showNotification(
        title: l.loginSuccess,
        body: l.welcomeBack,
        payload: 'favorites',
      );
      showMessage(context, l.loginSuccess);

      // L'admin va vers son tableau de bord, les autres vers l'accueil
      Navigator.pushReplacementNamed(
        context,
        role == 'admin' ? '/admin_dashboard' : '/home',
      );
    } catch (e) {
      if (!mounted) return;
      // Fermer la fenêtre Google n'est pas une vraie erreur
      showMessage(context, errorMessage(l, e), error: e is! AuthCancelledException);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final v = Validators(l);
    final primary = Theme.of(context).colorScheme.primary;

    return AuthScaffold(
      title: l.login,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flight_takeoff, size: 50, color: primary),
            const SizedBox(height: 16),
            Text(l.loginTitle,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: primary)),
            const SizedBox(height: 28),

            // Champ email
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: authInputStyle(context, l.email, Icons.email_outlined),
              validator: v.email,
            ),
            const SizedBox(height: 16),

            // Champ mot de passe (avec bouton afficher/masquer)
            TextFormField(
              controller: _passwordController,
              obscureText: _hidePassword,
              decoration: authInputStyle(context, l.password, Icons.lock_outline)
                  .copyWith(
                suffixIcon: IconButton(
                  icon: Icon(_hidePassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _hidePassword = !_hidePassword),
                ),
              ),
              validator: v.password,
            ),

            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: _isLoading
                    ? null
                    : () => Navigator.pushNamed(context, '/forgot_password'),
                child: Text(l.forgotPassword, style: const TextStyle(fontSize: 13)),
              ),
            ),

            // Bouton de connexion
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l.login, style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 14),

            // Bouton Google
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _loginWithGoogle,
              icon: const Icon(Icons.g_mobiledata, size: 28),
              label: Text(l.continueGoogle),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 10),

            TextButton(
              onPressed: _isLoading
                  ? null
                  : () => Navigator.pushNamed(context, '/register'),
              child: Text(l.noAccount),
            ),
          ],
        ),
      ),
    );
  }
}
