import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/plant_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/auth_provider.dart' as ap;
import '../../models/plant_model.dart';
import '../../widgets/safety_badge.dart';
import '../../widgets/app_bottom_nav.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final plantProvider = context.watch<PlantProvider>();
    final favProvider = context.watch<FavoritesProvider>();
    final settings = context.watch<SettingsProvider>();
    final auth = context.watch<ap.AuthProvider>();
    final featured = plantProvider.featuredPlant;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NaturaScan',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            settings.text(
                              'Scan. Identify. Discover.',
                              'ස්කෑන් කරන්න. හඳුනා ගන්න.',
                              'ஸ்கேன். அடையாளம். கண்டுபிடி.',
                            ),
                            style: GoogleFonts.dmSans(
                                fontSize: 12, color: Colors.white60),
                          ),
                        ],
                      ),
                      // Profile avatar button
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, '/profile'),
                        child: CircleAvatar(
                          backgroundColor: const Color(0xFFD4A017),
                          radius: 22,
                          child: Text(
                            auth.isLoggedIn
                                ? auth.displayName[0].toUpperCase()
                                : '?',
                            style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Welcome text
                  Text(
                    auth.isLoggedIn
                        ? settings.text(
                            'Welcome, ${auth.displayName}!',
                            'සාදරයෙන් පිළිගනිමු, ${auth.displayName}!',
                            'வரவேற்கிறோம், ${auth.displayName}!',
                          )
                        : settings.text(
                            'Welcome, Guest!',
                            'ආගන්තුක, සාදරයෙන් පිළිගනිමු!',
                            'வரவேற்கிறோம், விருந்தினர்!',
                          ),
                    style: GoogleFonts.dmSans(
                        color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),

                  // Stats
                  Row(
                    children: [
                      _StatChip(
                        icon: Icons.eco,
                        value: '${plantProvider.allPlants.length}',
                        label: settings.text('Plants', 'ශාක', 'செடிகள்'),
                      ),
                      const SizedBox(width: 12),
                      _StatChip(
                        icon: Icons.favorite,
                        value: '${favProvider.count}',
                        label: settings.text(
                            'Favorites', 'ප්‍රියතම', 'பிடித்தவை'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Quick Actions ──────────────────────────
                  Text(
                    settings.text(
                        'Quick Actions', 'ඉක්මන් ක්‍රියා', 'விரைவு செயல்கள்'),
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.15,
                    children: [
                      _ActionCard(
                        icon: Icons.camera_alt,
                        title: settings.text(
                            'Scan Plant', 'පැළය ස්කෑන්', 'தாவரத்தை ஸ்கேன்'),
                        subtitle: settings.text(
                            'Identify instantly', 'ක්ෂණිකව හඳුනා ගන්න', 'உடனே அடையாளம் காண'),
                        color: const Color(0xFF1E4D2B),
                        onTap: () => Navigator.pushNamed(context, '/camera'),
                      ),
                      _ActionCard(
                        icon: Icons.library_books,
                        title: settings.text(
                            'Plant Library', 'පැළ පුස්තකාලය', 'தாவர நூலகம்'),
                        subtitle: settings.text(
                            'Browse all plants', 'සියළු පැළ බලන්න', 'அனைத்து செடிகளும்'),
                        color: const Color(0xFF7B4F2E),
                        onTap: () => Navigator.pushNamed(context, '/library'),
                      ),
                      _ActionCard(
                        icon: Icons.favorite,
                        title: settings.text(
                            'Favorites', 'ප්‍රියතම', 'பிடித்தவை'),
                        subtitle: auth.isLoggedIn
                            ? settings.text(
                                'Your saved plants', 'ඔබේ ප්‍රිය ශාක', 'உங்கள் சேமிப்புகள்')
                            : settings.text(
                                'Login to save', 'සුරැකීමට ඇතුල් වන්න', 'சேமிக்க உள்நுழைக'),
                        color: const Color(0xFFC0392B),
                        onTap: () {
                          if (!auth.isLoggedIn) {
                            _showLoginPrompt(context, settings);
                          } else {
                            Navigator.pushNamed(context, '/favorites');
                          }
                        },
                      ),
                      _ActionCard(
                        icon: Icons.travel_explore,
                        title: settings.text(
                            'Tourist Mode', 'සංචාරක ප්‍රකාරය', 'சுற்றுலா முறை'),
                        subtitle: settings.text(
                            'Explore Sri Lanka', 'ශ්‍රී ලංකාව සොයන්න', 'இலங்கையை ஆராயுங்கள்'),
                        color: const Color(0xFF7B68EE),
                        onTap: () => Navigator.pushNamed(context, '/tourist'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── Plant of the Day ───────────────────────
                  Text(
                    settings.text(
                        'Plant of the Day', 'දිනයේ ශාකය', 'இன்றைய செடி'),
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  if (featured != null)
                    _FeaturedCard(plant: featured, settings: settings),

                  const SizedBox(height: 28),

                  // ── All Plants preview ─────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        settings.text(
                            'All Plants', 'සියළු ශාක', 'அனைத்து செடிகளும்'),
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/library'),
                        child: Text(
                          settings.text('See all', 'සියල්ල', 'அனைத்தும்'),
                          style: const TextStyle(color: Color(0xFF1E4D2B)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...plantProvider.allPlants.take(3).map(
                    (plant) => _MiniPlantRow(
                      plant: plant,
                      settings: settings,
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/plant-detail',
                        arguments: plant.id,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }

  void _showLoginPrompt(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          settings.text('Login Required', 'ඇතුල් වීම අවශ්‍යයි', 'உள்நுழைவு தேவை'),
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
        content: Text(
          settings.text(
            'Please sign in to save your favorite plants.',
            'ප්‍රිය ශාක සුරැකීමට ඇතුල් වන්න.',
            'பிடித்த செடிகளை சேமிக்க உள்நுழைக.',
          ),
          style: GoogleFonts.dmSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(settings.text('Cancel', 'අවලංගු', 'ரத்து')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E4D2B)),
            child: Text(
              settings.text('Sign In', 'ඇතුල් වන්න', 'உள்நுழை'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets ──────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatChip(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              Text(label,
                  style:
                      GoogleFonts.dmSans(color: Colors.white70, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 10),
            Text(title,
                style:
                    GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.bold)),
            Text(subtitle,
                style: GoogleFonts.dmSans(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final PlantModel plant;
  final SettingsProvider settings;
  const _FeaturedCard({required this.plant, required this.settings});

  @override
  Widget build(BuildContext context) {
    final color = Color(plant.colorValue);
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, '/plant-detail', arguments: plant.id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16)),
              child: Center(
                  child:
                      Text(plant.emoji, style: const TextStyle(fontSize: 40))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    settings.text(
                        plant.nameEnglish, plant.nameSinhala, plant.nameEnglish),
                    style: GoogleFonts.dmSans(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (!settings.isSinhala)
                    Text(plant.nameSinhala,
                        style: GoogleFonts.dmSans(
                            fontSize: 13, color: Colors.grey)),
                  Text(plant.scientificName,
                      style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic)),
                  const SizedBox(height: 8),
                  SafetyBadge(
                      status: plant.safetyStatus,
                      isSinhala: settings.isSinhala),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: Color(0xFF1E4D2B)),
          ],
        ),
      ),
    );
  }
}

class _MiniPlantRow extends StatelessWidget {
  final PlantModel plant;
  final SettingsProvider settings;
  final VoidCallback onTap;
  const _MiniPlantRow(
      {required this.plant, required this.settings, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Color(plant.colorValue);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12)),
              child: Center(
                  child: Text(plant.emoji,
                      style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    settings.text(plant.nameEnglish, plant.nameSinhala,
                        plant.nameEnglish),
                    style: GoogleFonts.dmSans(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  Text(plant.scientificName,
                      style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            SafetyBadge(
                status: plant.safetyStatus, isSinhala: settings.isSinhala),
          ],
        ),
      ),
    );
  }
}

