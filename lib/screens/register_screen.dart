// ============================================================
// register_screen.dart
// Inscription par email / mot de passe (ou Google depuis la
// page de connexion). Validation complète des champs.
// ============================================================
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../utils/l10n_ext.dart';
import '../utils/labels.dart';
import '../utils/ui.dart';
import '../utils/validators.dart';
import '../widgets/auth_scaffold.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final l = context.l10n;
    setState(() => _isLoading = true);

    try {
      await _authService.signUp(
        _emailController.text.trim(),
        _passwordController.text,
        name: _nameController.text.trim(),
      );
      if (!mounted) return;

      // Notification locale + message de bienvenue
      NotificationService().showNotification(
        title: l.registerSuccess,
        body: l.welcomeNew,
        payload: 'favorites',
      );
      showMessage(context, l.welcomeNew);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (mounted) showMessage(context, errorMessage(l, e), error: true);
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
      title: l.register,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.createAccount,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: primary)),
            const SizedBox(height: 28),
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: authInputStyle(context, l.fullName, Icons.person_outline),
              validator: (value) => v.minLength(value, 2),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: authInputStyle(context, l.email, Icons.email_outlined),
              validator: v.email,
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmController,
              obscureText: _hidePassword,
              decoration:
                  authInputStyle(context, l.confirmPassword, Icons.lock_outline),
              validator: (value) =>
                  v.confirmPassword(value, _passwordController.text),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _isLoading ? null : _register,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l.register, style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
