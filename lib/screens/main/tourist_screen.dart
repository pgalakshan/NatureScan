import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/plant_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/plant_model.dart';
import '../../widgets/safety_badge.dart';
import '../../widgets/app_bottom_nav.dart';

// Sri Lanka regions with mapped plants
const _regions = [
  {
    'name': 'Western Province',
    'nameSi': 'බස්නාහිර පළාත',
    'emoji': '🏙️',
    'color': 0xFF1565C0,
    'description': 'Colombo & surroundings — lush home gardens',
    'descriptionSi': 'කොළඹ සහ අවට — නිවෙස් ගෙවතු',
    'plants': ['Coconut', 'Mango', 'Banana', 'Gotukola', 'Papaya', 'Tulsi'],
  },
  {
    'name': 'Central Highlands',
    'nameSi': 'කදුකර ප්‍රදේශය',
    'emoji': '⛰️',
    'color': 0xFF2E7D32,
    'description': 'Kandy, Nuwara Eliya — cool misty hills',
    'descriptionSi': 'මහනුවර, නුවරඑළිය — සිසිල් කඳු',
    'plants': ['Gotukola', 'Banana', 'Jackfruit', 'Tulsi'],
  },
  {
    'name': 'Southern Province',
    'nameSi': 'දකුණු පළාත',
    'emoji': '🌊',
    'color': 0xFF00838F,
    'description': 'Galle, Matara — coastal biodiversity',
    'descriptionSi': 'ගාල්ල, මාතර — වෙරළ ජෛව විවිධත්වය',
    'plants': ['Coconut', 'Jackfruit', 'Breadfruit', 'Mango', 'Papaya', 'Aloe Vera'],
  },
  {
    'name': 'Northern Province',
    'nameSi': 'උතුරු පළාත',
    'emoji': '🌵',
    'color': 0xFFE65100,
    'description': 'Jaffna — arid dry zone plants',
    'descriptionSi': 'යාපනය — වියළි කලාප ශාක',
    'plants': ['Neem', 'Mango', 'Banana', 'Papaya', 'Tulsi', 'Aloe Vera'],
  },
  {
    'name': 'Eastern Province',
    'nameSi': 'නැගෙනහිර පළාත',
    'emoji': '🌴',
    'color': 0xFF6A1B9A,
    'description': 'Trincomalee, Batticaloa — tropical coasts',
    'descriptionSi': 'ත්‍රිකුණාමලය, මඩකලපුව',
    'plants': ['Coconut', 'Neem', 'Mango', 'Banana', 'Aloe Vera'],
  },
  {
    'name': 'North Central (Dry Zone)',
    'nameSi': 'උතුරු මැද (වියළි කලාපය)',
    'emoji': '🦁',
    'color': 0xFF827717,
    'description': 'Anuradhapura, Polonnaruwa — ancient ruins & dry zone',
    'descriptionSi': 'අනුරාධාපුර, පොළොන්නරුව',
    'plants': ['Neem', 'Mango', 'Aloe Vera', 'Tulsi', 'Papaya'],
  },
];

class TouristScreen extends StatefulWidget {
  const TouristScreen({super.key});

  @override
  State<TouristScreen> createState() => _TouristScreenState();
}

class _TouristScreenState extends State<TouristScreen> {
  int? _expandedRegion;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final plantProvider = context.watch<PlantProvider>();

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
                colors: [Color(0xFF7B68EE), Color(0xFF9B59B6)],
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          settings.text('Tourist Mode', 'සංචාරක ප්‍රකාරය'),
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          settings.text(
                            'Explore plants by Sri Lanka region',
                            'කලාප අනුව ශාක සොයා ගන්න',
                          ),
                          style: GoogleFonts.dmSans(
                              fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Text('🇱🇰', style: TextStyle(fontSize: 28)),
                  ],
                ),
                const SizedBox(height: 16),
                // Info chip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.touch_app,
                          color: Colors.white70, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        settings.text(
                          'Tap a region to see its plants',
                          'ශාක බැලීමට කලාපයක් තට්ටු කරන්න',
                        ),
                        style: GoogleFonts.dmSans(
                            fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Region list ──────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _regions.length,
              itemBuilder: (ctx, i) {
                final region = _regions[i];
                final isExpanded = _expandedRegion == i;
                final regionColor = Color(region['color'] as int);

                // Get plants for this region
                final regionPlantNames =
                    (region['plants'] as List<String>);
                final regionPlants = plantProvider.allPlants
                    .where((p) => regionPlantNames.contains(p.nameEnglish))
                    .toList();

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _expandedRegion = isExpanded ? null : i;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Region header row
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: regionColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Text(region['emoji'] as String,
                                      style: const TextStyle(fontSize: 26)),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      settings.isSinhala
                                          ? region['nameSi'] as String
                                          : region['name'] as String,
                                      style: GoogleFonts.dmSans(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      settings.isSinhala
                                          ? region['descriptionSi']
                                              as String
                                          : region['description'] as String,
                                      style: GoogleFonts.dmSans(
                                          fontSize: 12,
                                          color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: regionColor.withOpacity(0.12),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${regionPlants.length} ${settings.text("plants", "ශාක")}',
                                      style: GoogleFonts.dmSans(
                                          fontSize: 11,
                                          color: regionColor,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Icon(
                                    isExpanded
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Expanded plant list
                        if (isExpanded) ...[
                          Divider(
                              height: 1, color: Colors.grey.shade100),
                          ...regionPlants.map((plant) =>
                              _RegionPlantTile(
                                plant: plant,
                                settings: settings,
                                onTap: () => Navigator.pushNamed(
                                  ctx,
                                  '/plant-detail',
                                  arguments: plant.id,
                                ),
                              )),
                          const SizedBox(height: 8),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}

class _RegionPlantTile extends StatelessWidget {
  final PlantModel plant;
  final SettingsProvider settings;
  final VoidCallback onTap;

  const _RegionPlantTile(
      {required this.plant, required this.settings, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Color(plant.colorValue);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10)),
              child: Center(
                  child:
                      Text(plant.emoji, style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    settings.isSinhala ? plant.nameSinhala : plant.nameEnglish,
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
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
