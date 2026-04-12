import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as ap;
import '../../providers/plant_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/app_bottom_nav.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ap.AuthProvider>();
    final settings = context.watch<SettingsProvider>();
    final favProvider = context.watch<FavoritesProvider>();
    final plantProvider = context.watch<PlantProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E4D2B), Color(0xFF2E7D42)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      settings.text('My Profile', 'මගේ පැතිකඩ', 'என் சுயவிவரம்'),
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Avatar
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4A017),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Center(
                    child: Text(
                      auth.isLoggedIn
                          ? auth.displayName[0].toUpperCase()
                          : '?',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  auth.isLoggedIn
                      ? auth.displayName
                      : settings.text('Guest User', 'ආගන්තුක', 'விருந்தினர்'),
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (auth.isLoggedIn)
                  Text(
                    auth.email,
                    style: GoogleFonts.dmSans(
                        color: Colors.white70, fontSize: 13),
                  ),
                if (auth.isAdmin) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A017),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '🔐 Admin',
                      style: GoogleFonts.dmSans(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // ── Stats ──────────────────────────────────────
                _StatsRow(
                  totalPlants: plantProvider.allPlants.length,
                  favorites: favProvider.count,
                  settings: settings,
                ),

                const SizedBox(height: 20),

                // ── Language ────────────────────────────────────
                _SectionTitle(
                    title: settings.text('Language', 'භාෂාව', 'மொழி')),
                _LangTile(settings: settings),

                const SizedBox(height: 20),

                // ── Account ─────────────────────────────────────
                _SectionTitle(
                    title: settings.text('Account', 'ගිනුම', 'கணக்கு')),

                if (auth.isLoggedIn) ...[
                  if (auth.isAdmin)
                    _ProfileTile(
                      icon: Icons.admin_panel_settings,
                      iconColor: Colors.deepPurple,
                      title: 'Admin Panel',
                      subtitle: 'Manage plants database',
                      onTap: () => Navigator.pushNamed(context, '/admin'),
                    ),
                  _ProfileTile(
                    icon: Icons.favorite,
                    iconColor: Colors.red,
                    title: settings.text('My Favorites', 'ප්‍රියතම', 'என் பிடித்தவை'),
                    subtitle: settings.text(
                      '${favProvider.count} plants saved',
                      'ශාක ${favProvider.count}ක් සුරකිනා ලදි',
                      '${favProvider.count} செடிகள் சேமிக்கப்பட்டன',
                    ),
                    onTap: () => Navigator.pushNamed(context, '/favorites'),
                  ),
                  _ProfileTile(
                    icon: Icons.logout,
                    iconColor: Colors.red.shade700,
                    title: settings.text('Sign Out', 'පිටවීම', 'வெளியேறு'),
                    subtitle: settings.text(
                      'Sign out of your account',
                      'ගිනුමෙන් ඉවත් වන්න',
                      'உங்கள் கணக்கிலிருந்து வெளியேறவும்',
                    ),
                    onTap: () => _confirmSignOut(context, auth, favProvider),
                  ),
                ] else ...[
                  _ProfileTile(
                    icon: Icons.login,
                    iconColor: const Color(0xFF1E4D2B),
                    title: settings.text('Sign In', 'ඇතුල් වන්න', 'உள்நுழை'),
                    subtitle: settings.text(
                      'Sign in to save favorites & more',
                      'ප්‍රිය ශාක සුරැකීමට ඇතුල් වන්න',
                      'பிடித்தவற்றை சேமிக்க உள்நுழைக',
                    ),
                    onTap: () => Navigator.pushNamed(context, '/login'),
                  ),
                  _ProfileTile(
                    icon: Icons.person_add,
                    iconColor: const Color(0xFFD4A017),
                    title: settings.text('Create Account', 'ගිනුමක් සාදන්න', 'கணக்கு உருவாக்கவும்'),
                    subtitle: settings.text(
                      'Register for free',
                      'නොමිලේ ලියාපදිංචි වන්න',
                      'இலவசமாக பதிவு செய்யுங்கள்',
                    ),
                    onTap: () => Navigator.pushNamed(context, '/register'),
                  ),
                ],

                const SizedBox(height: 20),

                // ── App info ─────────────────────────────────────
                _SectionTitle(title: 'NaturaScan'),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.eco,
                              color: Color(0xFF1E4D2B), size: 20),
                          const SizedBox(width: 8),
                          Text('AI-Powered Sri Lankan Plant ID',
                              style: GoogleFonts.dmSans(
                                  fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Text('v1.0.0',
                              style: GoogleFonts.dmSans(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        settings.text(
                          '10 Sri Lankan plants • 3 Languages • Offline AI',
                          'ශ්‍රී ලාංකික ශාක 10 • භාෂා 3 • Offline AI',
                          'இலங்கை செடிகள் 10 • மொழிகள் 3 • Offline AI',
                        ),
                        style: GoogleFonts.dmSans(
                            fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }

  void _confirmSignOut(
    BuildContext context,
    ap.AuthProvider auth,
    FavoritesProvider favProvider,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              favProvider.clear();
              await auth.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
            child: const Text('Sign Out',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Widgets ──────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

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

class _StatsRow extends StatelessWidget {
  final int totalPlants;
  final int favorites;
  final SettingsProvider settings;
  const _StatsRow(
      {required this.totalPlants,
      required this.favorites,
      required this.settings});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF1E4D2B), Color(0xFF2E7D42)]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat(value: '$totalPlants',
              label: settings.text('Plants', 'ශාක', 'செடிகள்'),
              icon: Icons.eco),
          Container(width: 1, height: 36, color: Colors.white24),
          _Stat(value: '$favorites',
              label: settings.text('Favorites', 'ප්‍රියතම', 'பிடித்தவை'),
              icon: Icons.favorite),
          Container(width: 1, height: 36, color: Colors.white24),
          _Stat(value: '3',
              label: settings.text('Languages', 'භාෂා', 'மொழிகள்'),
              icon: Icons.language),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const _Stat({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.dmSans(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

class _LangTile extends StatelessWidget {
  final SettingsProvider settings;
  const _LangTile({required this.settings});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
            settings.text('App Language', 'යෙදුම් භාෂාව', 'பயன்பாட்டு மொழி'),
            style: GoogleFonts.dmSans(
                fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _LangBtn(
                label: '🇬🇧 English',
                selected: settings.language == AppLanguage.english,
                onTap: () => settings.setLanguage(AppLanguage.english),
              ),
              const SizedBox(width: 8),
              _LangBtn(
                label: '🇱🇰 සිංහල',
                selected: settings.language == AppLanguage.sinhala,
                onTap: () => settings.setLanguage(AppLanguage.sinhala),
              ),
              const SizedBox(width: 8),
              _LangBtn(
                label: '🇱🇰 தமிழ்',
                selected: settings.language == AppLanguage.tamil,
                onTap: () => settings.setLanguage(AppLanguage.tamil),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LangBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _LangBtn(
      {required this.label, required this.selected, required this.onTap});

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
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                color: selected ? Colors.white : Colors.grey.shade700,
                fontSize: 11,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
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
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 14, color: Colors.grey),
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
