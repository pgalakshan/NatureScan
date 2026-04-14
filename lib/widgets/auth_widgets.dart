import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/settings_provider.dart';

/// Styled text field for auth screens (green gradient background).
class AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const AuthField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.dmSans(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.dmSans(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white54, size: 20),
        suffixIcon: suffix,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD4A017), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        errorStyle: const TextStyle(color: Colors.orangeAccent),
      ),
    );
  }
}

/// Red error banner shown above the form on auth screens.
class AuthErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;
  const AuthErrorBanner(
      {super.key, required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.shade900.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style:
                    GoogleFonts.dmSans(color: Colors.white, fontSize: 13)),
          ),
          GestureDetector(
            onTap: onDismiss,
            child:
                const Icon(Icons.close, color: Colors.white54, size: 16),
          ),
        ],
      ),
    );
  }
}

/// 3-language chip row (EN / සිංහල / தமிழ்) used on auth screens.
class AuthLangSelector extends StatelessWidget {
  final SettingsProvider settings;
  const AuthLangSelector({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LangChip(
          label: 'English',
          flag: '🇬🇧',
          selected: settings.language == AppLanguage.english,
          onTap: () => settings.setLanguage(AppLanguage.english),
        ),
        const SizedBox(width: 8),
        _LangChip(
          label: 'සිංහල',
          flag: '🇱🇰',
          selected: settings.language == AppLanguage.sinhala,
          onTap: () => settings.setLanguage(AppLanguage.sinhala),
        ),
        const SizedBox(width: 8),
        _LangChip(
          label: 'தமிழ்',
          flag: '🇱🇰',
          selected: settings.language == AppLanguage.tamil,
          onTap: () => settings.setLanguage(AppLanguage.tamil),
        ),
      ],
    );
  }
}

class _LangChip extends StatelessWidget {
  final String label;
  final String flag;
  final bool selected;
  final VoidCallback onTap;
  const _LangChip({
    required this.label,
    required this.flag,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFD4A017)
              : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFFD4A017)
                : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Text(
          '$flag $label',
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontSize: 12,
            fontWeight:
                selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
