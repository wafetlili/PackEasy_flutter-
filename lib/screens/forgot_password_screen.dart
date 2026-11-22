// ============================================================
// forgot_password_screen.dart
// Envoi d'un lien de réinitialisation du mot de passe par email.
// ============================================================
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/l10n_ext.dart';
import '../utils/labels.dart';
import '../utils/ui.dart';
import '../utils/validators.dart';
import '../widgets/auth_scaffold.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;
    final l = context.l10n;
    setState(() => _isLoading = true);

    try {
      await _authService.resetPassword(_emailController.text.trim());
      if (!mounted) return;
      showMessage(context, l.resetSent);
      Navigator.pop(context);
    } catch (e) {
      if (mounted) showMessage(context, errorMessage(l, e), error: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final primary = Theme.of(context).colorScheme.primary;

    return AuthScaffold(
      title: l.forgotPasswordTitle,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_reset, size: 50, color: primary),
            const SizedBox(height: 16),
            Text(l.resetTitle,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: primary)),
            const SizedBox(height: 8),
            Text(l.resetHint, textAlign: TextAlign.center),
            const SizedBox(height: 28),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: authInputStyle(context, l.email, Icons.email_outlined),
              validator: Validators(l).email,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _isLoading ? null : _sendResetLink,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l.sendLink, style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
