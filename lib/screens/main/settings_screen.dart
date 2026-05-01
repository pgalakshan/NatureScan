import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/plant_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/auth_provider.dart' as ap;
import '../../widgets/app_bottom_nav.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final plantProvider = context.watch<PlantProvider>();
    final favProvider = context.watch<FavoritesProvider>();
    final auth = context.watch<ap.AuthProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E4D2B), Color(0xFF2E7D42)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  settings.text('Settings', 'සැකසුම්', 'அமைப்புகள்'),
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // ── Language ─────────────────────────────────
                _SectionHeader(
                    title: settings.text('Language', 'භාෂාව', 'மொழி')),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settings.text(
                            'Select App Language',
                            'යෙදුම් භාෂාව තෝරන්න',
                            'பயன்பாட்டு மொழியை தேர்ந்தெடுக்கவும்'),
                        style: GoogleFonts.dmSans(
                            fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _LangChip(
                            flag: '🇬🇧',
                            label: 'English',
                            selected: settings.language == AppLanguage.english,
                            onTap: () =>
                                settings.setLanguage(AppLanguage.english),
                          ),
                          const SizedBox(width: 8),
                          _LangChip(
                            flag: '🇱🇰',
                            label: 'සිංහල',
                            selected: settings.language == AppLanguage.sinhala,
                            onTap: () =>
                                settings.setLanguage(AppLanguage.sinhala),
                          ),
                          const SizedBox(width: 8),
                          _LangChip(
                            flag: '🇱🇰',
                            label: 'தமிழ்',
                            selected: settings.language == AppLanguage.tamil,
                            onTap: () =>
                                settings.setLanguage(AppLanguage.tamil),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Appearance ───────────────────────────────
                _SectionHeader(
                    title: settings.text('Appearance', 'පෙනුම', 'தோற்றம்')),
                _SettingsTile(
                  icon: Icons.dark_mode,
                  iconColor: Colors.indigo,
                  title: settings.text(
                      'Dark Mode', 'අඳුරු ප්‍රකාරය', 'இருண்ட முறை'),
                  subtitle: settings.text(
                      'Switch to dark theme',
                      'අඳුරු තේමාවට මාරු වන්න',
                      'இருண்ட தீம் கிடைக்கும்'),
                  trailing: Switch(
                    value: settings.isDarkMode,
                    onChanged: (_) => settings.toggleDarkMode(),
                    activeColor: const Color(0xFF1E4D2B),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Stats ─────────────────────────────────────
                _SectionHeader(
                    title: settings.text(
                        'Stats', 'සංඛ්‍යාලේඛන', 'புள்ளிவிவரங்கள்')),
                _StatsCard(
                  totalPlants: plantProvider.allPlants.length,
                  favorites: favProvider.count,
                  settings: settings,
                ),

                const SizedBox(height: 20),

                // ── Account ───────────────────────────────────
                _SectionHeader(
                    title: settings.text('Account', 'ගිනුම', 'கணக்கு')),
                if (auth.isLoggedIn) ...[
                  _SettingsTile(
                    icon: Icons.person,
                    iconColor: const Color(0xFF1E4D2B),
                    title: auth.displayName,
                    subtitle: auth.email,
                    trailing: TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/profile'),
                      child: Text(settings.text('View', 'බලන්න', 'காண்க'),
                          style: const TextStyle(
                              color: Color(0xFF1E4D2B))),
                    ),
                  ),
                  if (auth.isAdmin)
                    _SettingsTile(
                      icon: Icons.admin_panel_settings,
                      iconColor: Colors.deepPurple,
                      title: 'Admin Panel',
                      subtitle: 'Manage plant database',
                      trailing: const Icon(Icons.arrow_forward_ios,
                          size: 14, color: Colors.grey),
                      onTap: () => Navigator.pushNamed(context, '/admin'),
                    ),
                ] else ...[
                  _SettingsTile(
                    icon: Icons.login,
                    iconColor: const Color(0xFF1E4D2B),
                    title: settings.text('Sign In', 'ඇතුල් වන්න', 'உள்நுழை'),
                    subtitle: settings.text(
                        'Login to save favorites',
                        'ප්‍රිය ශාක සුරැකීමට',
                        'பிடித்தவற்றை சேமிக்க'),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 14, color: Colors.grey),
                    onTap: () => Navigator.pushNamed(context, '/login'),
                  ),
                ],

                const SizedBox(height: 20),

                // ── About ──────────────────────────────────────
                _SectionHeader(
                    title: settings.text('About', 'ගැන', 'பற்றி')),
                _SettingsTile(
                  icon: Icons.eco,
                  iconColor: const Color(0xFF1E4D2B),
                  title: 'NaturaScan v1.0.0',
                  subtitle: settings.text(
                    'AI-Powered Sri Lankan Plant Identification',
                    'AI ශ්‍රී ලාංකික ශාක හඳුනා ගැනීම',
                    'AI இலங்கை தாவர அடையாளம்',
                  ),
                  trailing: null,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }
}

// ── Widgets ──────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title,
          style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E4D2B))),
    );
  }
}

class _LangChip extends StatelessWidget {
  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _LangChip(
      {required this.flag,
      required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF1E4D2B)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text('$flag $label',
                style: GoogleFonts.dmSans(
                    color: selected ? Colors.white : Colors.grey.shade700,
                    fontSize: 11,
                    fontWeight: selected
                        ? FontWeight.bold
                        : FontWeight.normal)),
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title,
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle,
            style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey)),
        trailing: trailing,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final int totalPlants;
  final int favorites;
  final SettingsProvider settings;
  const _StatsCard(
      {required this.totalPlants,
      required this.favorites,
      required this.settings});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF1E4D2B), Color(0xFF2E7D42)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
              value: '$totalPlants',
              label: settings.text('Plants', 'ශාක', 'செடிகள்'),
              icon: Icons.eco),
          Container(width: 1, height: 40, color: Colors.white30),
          _StatItem(
              value: '$favorites',
              label: settings.text('Favorites', 'ප්‍රියතම', 'பிடித்தவை'),
              icon: Icons.favorite),
          Container(width: 1, height: 40, color: Colors.white30),
          _StatItem(
              value: '3',
              label: settings.text('Categories', 'කාණ්ඩ', 'வகைகள்'),
              icon: Icons.category),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const _StatItem(
      {required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.dmSans(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        Text(label,
            style:
                GoogleFonts.dmSans(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
