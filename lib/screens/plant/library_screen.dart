import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/plant_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/plant_card.dart';
import '../../widgets/app_bottom_nav.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plantProvider = context.watch<PlantProvider>();
    final settings = context.watch<SettingsProvider>();
    final plants = plantProvider.plants;

    final categoryLabels = {
      'All': settings.text('All', 'සියල්ල'),
      'tree': settings.text('Trees', 'ගස්'),
      'herb': settings.text('Herbs', 'ඖෂධ පැළෑටි'),
      'plant': settings.text('Plants', 'පැළ'),
    };

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      settings.text('Plant Library', 'පැළ පුස්තකාලය'),
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (q) => plantProvider.search(q),
                    decoration: InputDecoration(
                      hintText: settings.text(
                          'Search plants...', 'පැළ සොයන්න...'),
                      hintStyle: GoogleFonts.dmSans(color: Colors.grey),
                      prefixIcon:
                          const Icon(Icons.search, color: Color(0xFF1E4D2B)),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchCtrl.clear();
                                plantProvider.search('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Category filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: plantProvider.categories.map((cat) {
                      final selected = plantProvider.selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            categoryLabels[cat] ?? cat,
                            style: GoogleFonts.dmSans(
                              color: selected
                                  ? Colors.white
                                  : const Color(0xFF1E4D2B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          selected: selected,
                          selectedColor: const Color(0xFFD4A017),
                          backgroundColor: Colors.white,
                          onSelected: (_) => plantProvider.filterByCategory(cat),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // ── Plant count ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Row(
              children: [
                Text(
                  settings.text(
                    '${plants.length} plants found',
                    'පැළ ${plants.length}ක් හමු විය',
                  ),
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // ── Grid ─────────────────────────────────────────────
          Expanded(
            child: plantProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF1E4D2B)))
                : plants.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🌿',
                                style: TextStyle(fontSize: 56)),
                            const SizedBox(height: 12),
                            Text(
                              settings.text(
                                  'No plants found', 'පැළ හමු නොවිණ'),
                              style: GoogleFonts.dmSans(
                                  fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.80,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        itemCount: plants.length,
                        itemBuilder: (ctx, i) {
                          final plant = plants[i];
                          return PlantCard(
                            plant: plant,
                            isSinhala: settings.isSinhala,
                            onTap: () => Navigator.pushNamed(
                              ctx,
                              '/plant-detail',
                              arguments: plant.id,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}
