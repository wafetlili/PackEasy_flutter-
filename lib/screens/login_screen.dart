// ============================================================
// login_screen.dart
// Écran de connexion avec notification et redirection.
// ============================================================
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../widgets/travel_background.dart';
import '../services/notification_service.dart';

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
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // Connexion + Notification + Redirection
  // ------------------------------------------------------------
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final user = await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      setState(() => _isLoading = false);

      if (user != null) {
        // 1. Notification
        NotificationService().showNotification(
          title: 'Connexion réussie',
          body: 'Ravi de vous revoir sur PackEasy !',
        );

        // 2. SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bienvenue sur PackEasy !")),
        );

        // 3. REDIRECTION (C'est ce qui manquait !)
        Navigator.pushReplacementNamed(context, '/home'); 
        
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email ou mot de passe incorrect")),
        );
      }
    }
  }

  // Style des champs
  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20, color: Colors.teal.shade300),
      filled: true,
      fillColor: Colors.white.withOpacity(0.4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      labelStyle: const TextStyle(color: Colors.black54),
      floatingLabelStyle: const TextStyle(color: Colors.teal),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TravelBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
          title: const Text(
            "Connexion",
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 30, spreadRadius: 5),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flight_takeoff, size: 50, color: Colors.teal),
                    const SizedBox(height: 16),
                    const Text(
                      "Bon retour !",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                    const SizedBox(height: 32),

                    TextFormField(
                      controller: _emailController,
                      decoration: _inputStyle("Email", Icons.email_outlined),
                      validator: (v) => v!.isEmpty || !v.contains('@') ? "Email invalide" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: _inputStyle("Mot de passe", Icons.lock_outline),
                      validator: (v) => v!.length < 6 ? "Min 6 caractères" : null,
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isLoading ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                        child: const Text("Mot de passe oublié ?", style: TextStyle(fontSize: 13, color: Colors.teal)),
                      ),
                    ),

                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                      ),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: _isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                          : const Text("Se connecter", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _isLoading ? null : () async {
                        // Logique Google
                      },
                      icon: const Icon(Icons.g_mobiledata, size: 28),
                      label: const Text("Continuer avec Google"),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        side: BorderSide(color: Colors.teal.shade200),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                      child: const Text("Pas de compte ? S'inscrire", style: TextStyle(color: Colors.teal)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}