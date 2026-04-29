import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/plant_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/plant_card.dart';
import '../../widgets/app_bottom_nav.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favProvider = context.watch<FavoritesProvider>();
    final plantProvider = context.watch<PlantProvider>();
    final settings = context.watch<SettingsProvider>();
    final favorites = favProvider.getFavoritePlants(plantProvider.allPlants);

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
                colors: [Color(0xFFC0392B), Color(0xFFE74C3C)],
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
                const SizedBox(width: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      settings.text('My Favorites', 'ප්‍රියතම පැළ'),
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      settings.text(
                        '${favorites.length} plants saved',
                        'පැළ ${favorites.length}ක් සුරකිනු ලැබේ',
                      ),
                      style: GoogleFonts.dmSans(
                          fontSize: 13, color: Colors.white70),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.favorite, color: Colors.white, size: 28),
              ],
            ),
          ),

          // ── Content ──────────────────────────────────────────
          Expanded(
            child: favorites.isEmpty
                ? _EmptyFavorites(settings: settings)
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.80,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: favorites.length,
                    itemBuilder: (ctx, i) {
                      final plant = favorites[i];
                      return Stack(
                        children: [
                          PlantCard(
                            plant: plant,
                            isSinhala: settings.isSinhala,
                            onTap: () => Navigator.pushNamed(
                              ctx,
                              '/plant-detail',
                              arguments: plant.id,
                            ),
                          ),
                          // Remove from favorites button
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => favProvider.toggleFavorite(plant.id),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.favorite,
                                    color: Colors.red, size: 18),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  final SettingsProvider settings;
  const _EmptyFavorites({required this.settings});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌿', style: TextStyle(fontSize: 72)),
          const SizedBox(height: 16),
          Text(
            settings.text('No favorites yet', 'ප්‍රියතම නැත'),
            style: GoogleFonts.playfairDisplay(
                fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            settings.text(
              'Tap the heart icon on any plant to save it here.',
              'ඕනෑම පැළෙහි හදවත් නිරූපකය තට්ටු කරන්න.',
            ),
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
                fontSize: 14, color: Colors.grey, height: 1.5),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/library'),
            icon: const Icon(Icons.library_books),
            label: Text(settings.text('Browse Library', 'පුස්තකාලය')),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E4D2B),
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }
}
