import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as ap;
import '../../providers/settings_provider.dart';
import '../../widgets/auth_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<ap.AuthProvider>();
    final settings = context.read<SettingsProvider>();

    final ok = await auth.register(
      name: _nameCtrl.text,
      email: _emailCtrl.text,
      password: _passCtrl.text,
      language: settings.languageCode,
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
                  const SizedBox(height: 40),

                  // ── Header ───────────────────────────────────
                  Text(
                    settings.text('Create Account', 'ගිනුමක් සාදන්න', 'கணக்கு உருவாக்கவும்'),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    settings.text(
                      'Join NaturaScan today',
                      'අද NaturaScan හා එක් වන්න',
                      'இன்று NaturaScan-ஐ சேரவும்',
                    ),
                    style: GoogleFonts.dmSans(color: Colors.white70),
                  ),

                  const SizedBox(height: 32),

                  // ── Language selector ────────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          settings.text(
                              'Select Language', 'භාෂාව තෝරන්න', 'மொழியை தேர்ந்தெடுக்கவும்'),
                          style: GoogleFonts.dmSans(
                              color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 10),
                        AuthLangSelector(settings: settings),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Error ─────────────────────────────────────
                  if (auth.error != null)
                    AuthErrorBanner(
                        message: auth.error!, onDismiss: auth.clearError),

                  // ── Name ──────────────────────────────────────
                  AuthField(
                    controller: _nameCtrl,
                    label: settings.text('Full Name', 'සම්පූර්ණ නම', 'முழு பெயர்'),
                    icon: Icons.person_outline,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 14),

                  // ── Email ─────────────────────────────────────
                  AuthField(
                    controller: _emailCtrl,
                    label: settings.text('Email', 'විද්‍යුත් තැපෑල', 'மின்னஞ்சல்'),
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Email is required';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // ── Password ──────────────────────────────────
                  AuthField(
                    controller: _passCtrl,
                    label: settings.text('Password', 'මුරපදය', 'கடவுச்சொல்'),
                    icon: Icons.lock_outline,
                    obscure: _obscurePass,
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePass ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white54,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePass = !_obscurePass),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password is required';
                      if (v.length < 6) return 'At least 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // ── Confirm Password ──────────────────────────
                  AuthField(
                    controller: _confirmCtrl,
                    label: settings.text(
                        'Confirm Password', 'මුරපදය තහවුරු කරන්න', 'கடவுச்சொல் உறுதிப்படுத்தவும்'),
                    icon: Icons.lock_outline,
                    obscure: _obscureConfirm,
                    suffix: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white54,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    validator: (v) {
                      if (v != _passCtrl.text) return 'Passwords do not match';
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  // ── Register button ───────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4A017),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: auth.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              settings.text(
                                  'Create Account',
                                  'ගිනුම සාදන්න',
                                  'கணக்கை உருவாக்கவும்'),
                              style: GoogleFonts.dmSans(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Login link ─────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        settings.text(
                            'Already have an account? ',
                            'ගිනුමක් ඇද්ද? ',
                            'ஏற்கனவே கணக்கு உள்ளதா? '),
                        style: GoogleFonts.dmSans(color: Colors.white70),
                      ),
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushReplacementNamed(context, '/login'),
                        child: Text(
                          settings.text('Sign In', 'ඇතුල් වන්න', 'உள்நுழை'),
                          style: GoogleFonts.dmSans(
                            color: const Color(0xFFD4A017),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
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
