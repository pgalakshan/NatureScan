import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as ap;
import '../../providers/settings_provider.dart';
import '../../widgets/auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<ap.AuthProvider>();
    final ok = await auth.login(
      email: _emailCtrl.text,
      password: _passCtrl.text,
    );
    if (ok && mounted) Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ap.AuthProvider>();
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E4D2B), Color(0xFF2E7D42)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // ── Logo ────────────────────────────────────
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child:
                        const Icon(Icons.eco, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'NaturaScan',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    settings.text(
                      'Sign in to your account',
                      'ඔබේ ගිනුමට ඇතුල් වන්න',
                      'உங்கள் கணக்கில் உள்நுழைக',
                    ),
                    style:
                        GoogleFonts.dmSans(color: Colors.white70, fontSize: 14),
                  ),

                  const SizedBox(height: 48),

                  // ── Error banner ─────────────────────────────
                  if (auth.error != null)
                    AuthErrorBanner(
                        message: auth.error!, onDismiss: auth.clearError),

                  // ── Email field ──────────────────────────────
                  AuthField(
                    controller: _emailCtrl,
                    label: settings.text(
                        'Email', 'විද්‍යුත් තැපෑල', 'மின்னஞ்சல்'),
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'Email is required';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // ── Password field ───────────────────────────
                  AuthField(
                    controller: _passCtrl,
                    label: settings.text(
                        'Password', 'මුරපදය', 'கடவுச்சொல்'),
                    icon: Icons.lock_outline,
                    obscure: _obscure,
                    suffix: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white54,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscure = !_obscure),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password is required';
                      if (v.length < 6) return 'At least 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  // ── Login button ─────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4A017),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: auth.isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white)
                          : Text(
                              settings.text(
                                  'Sign In', 'ඇතුල් වන්න', 'உள்நுழை'),
                              style: GoogleFonts.dmSans(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Register link ────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        settings.text(
                            "Don't have an account? ",
                            'ගිනුමක් නැද්ද? ',
                            'கணக்கு இல்லையா? '),
                        style: GoogleFonts.dmSans(color: Colors.white70),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(
                            context, '/register'),
                        child: Text(
                          settings.text('Register', 'ලියාපදිංචි වන්න',
                              'பதிவு செய்யுங்கள்'),
                          style: GoogleFonts.dmSans(
                            color: const Color(0xFFD4A017),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ── Guest / Browse without login ─────────────
                  TextButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/home'),
                    child: Text(
                      settings.text(
                        'Browse as Guest →',
                        'ආගන්තුකයෙකු ලෙස →',
                        'விருந்தினராக உலாவுக →',
                      ),
                      style: GoogleFonts.dmSans(
                          color: Colors.white54, fontSize: 13),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Language selector ────────────────────────
                  AuthLangSelector(settings: settings),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
