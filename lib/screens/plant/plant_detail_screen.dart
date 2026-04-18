import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/plant_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/plant_model.dart';
import '../../widgets/safety_badge.dart';

class PlantDetailScreen extends StatelessWidget {
  final String plantId;
  const PlantDetailScreen({super.key, required this.plantId});

  @override
  Widget build(BuildContext context) {
    final plant = context.read<PlantProvider>().getById(plantId);
    if (plant == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Plant not found')),
        body: const Center(child: Text('Plant data not found.')),
      );
    }
    return _DetailBody(plant: plant);
  }
}

class _DetailBody extends StatefulWidget {
  final PlantModel plant;
  const _DetailBody({required this.plant});

  @override
  State<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends State<_DetailBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plant = widget.plant;
    final color = Color(plant.colorValue);
    final favProvider = context.watch<FavoritesProvider>();
    final settings = context.watch<SettingsProvider>();
    final isFav = favProvider.isFavorite(plant.id);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: color,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red.shade300 : Colors.white,
                ),
                onPressed: () => favProvider.toggleFavorite(plant.id),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    Text(plant.emoji, style: const TextStyle(fontSize: 80)),
                    const SizedBox(height: 8),
                    Text(
                      settings.isSinhala ? plant.nameSinhala : plant.nameEnglish,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      plant.scientificName,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: Column(
          children: [
            // ── Name + badges row ───────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  if (!settings.isSinhala)
                    Text(
                      plant.nameSinhala,
                      style: GoogleFonts.dmSans(
                          fontSize: 16, color: Colors.grey.shade700),
                    ),
                  const Spacer(),
                  SafetyBadge(
                      status: plant.safetyStatus,
                      isSinhala: settings.isSinhala),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      settings.text(
                        plant.category[0].toUpperCase() +
                            plant.category.substring(1),
                        plant.category == 'tree'
                            ? 'ගස'
                            : plant.category == 'herb'
                                ? 'ඖෂධ'
                                : 'පැළය',
                      ),
                      style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            // ── Tabs ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: TabBar(
                controller: _tabCtrl,
                indicatorColor: const Color(0xFF1E4D2B),
                labelColor: const Color(0xFF1E4D2B),
                unselectedLabelColor: Colors.grey,
                labelStyle:
                    GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                tabs: [
                  Tab(text: settings.text('Overview', 'දළ විශ්ලේෂණය')),
                  Tab(text: settings.text('Uses', 'භාවිතය')),
                  Tab(text: settings.text('Regions', 'කලාප')),
                ],
              ),
            ),

            // ── Tab views ───────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  // Overview
                  _OverviewTab(plant: plant, settings: settings),
                  // Medicinal Uses
                  _UsesTab(plant: plant, settings: settings),
                  // Regions
                  _RegionsTab(plant: plant, settings: settings, color: color),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab widgets ─────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final PlantModel plant;
  final SettingsProvider settings;
  const _OverviewTab({required this.plant, required this.settings});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            settings.text('About', 'ගැන'),
            style: GoogleFonts.playfairDisplay(
                fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            settings.isSinhala ? plant.descriptionSinhala : plant.description,
            style: GoogleFonts.dmSans(fontSize: 14, height: 1.6,
                color: Colors.grey.shade800),
          ),
          const SizedBox(height: 20),
          Text(
            settings.text('Habitat', 'වාසස්ථානය'),
            style: GoogleFonts.playfairDisplay(
                fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.green.shade100),
            ),
            child: Row(
              children: [
                const Icon(Icons.forest, color: Color(0xFF1E4D2B)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    settings.isSinhala
                        ? plant.habitatSinhala
                        : plant.habitat,
                    style: GoogleFonts.dmSans(
                        fontSize: 14, color: Colors.grey.shade800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            settings.text('Scientific Classification', 'විද්‍යාත්මක වර්ගීකරණය'),
            style: GoogleFonts.playfairDisplay(
                fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _InfoRow(
              label: settings.text('Scientific Name', 'විද්‍යාත්මක නම'),
              value: plant.scientificName,
              italic: true),
          _InfoRow(
              label: settings.text('Common Name', 'සාමාන්‍ය නම'),
              value: plant.nameEnglish),
          _InfoRow(
              label: settings.text('Sinhala Name', 'සිංහල නම'),
              value: plant.nameSinhala),
          _InfoRow(
              label: settings.text('Category', 'වර්ගය'),
              value: plant.category[0].toUpperCase() +
                  plant.category.substring(1)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool italic;
  const _InfoRow(
      {required this.label, required this.value, this.italic = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value,
                style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontStyle:
                        italic ? FontStyle.italic : FontStyle.normal)),
          ),
        ],
      ),
    );
  }
}

class _UsesTab extends StatelessWidget {
  final PlantModel plant;
  final SettingsProvider settings;
  const _UsesTab({required this.plant, required this.settings});

  @override
  Widget build(BuildContext context) {
    final uses = settings.isSinhala
        ? plant.medicinalUsesSinhala
        : plant.medicinalUses;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            settings.text('Medicinal Uses', 'ඖෂධීය භාවිතය'),
            style: GoogleFonts.playfairDisplay(
                fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          ...uses.asMap().entries.map((e) => _UseCard(
                number: e.key + 1,
                text: e.value,
              )),
          if (plant.safetyStatus == 'caution') ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.orange, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      settings.text(
                        'Use with caution. Consult an Ayurvedic physician before use. Not recommended for children.',
                        'ප්‍රවේශමෙන් භාවිත කරන්න. ළමයින්ට නිර්දේශ නොවේ.',
                      ),
                      style: GoogleFonts.dmSans(
                          fontSize: 13, color: Colors.orange.shade800),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _UseCard extends StatelessWidget {
  final int number;
  final String text;
  const _UseCard({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFF1E4D2B),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('$number',
                  style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style:
                    GoogleFonts.dmSans(fontSize: 14, height: 1.5)),
          ),
        ],
      ),
    );
  }
}

class _RegionsTab extends StatelessWidget {
  final PlantModel plant;
  final SettingsProvider settings;
  final Color color;
  const _RegionsTab(
      {required this.plant, required this.settings, required this.color});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            settings.text(
                'Found in Sri Lanka', 'ශ්‍රී ලංකාවේ හමු වන ස්ථාන'),
            style: GoogleFonts.playfairDisplay(
                fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: plant.regions.map((region) {
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on,
                        color: color, size: 16),
                    const SizedBox(width: 6),
                    Text(region,
                        style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: color,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: Color(0xFF1E4D2B), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      settings.text('Tourist Tip', 'සංචාරක ඉඟිය'),
                      style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E4D2B)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  settings.text(
                    'You can spot this plant in ${plant.regions.join(", ")} of Sri Lanka. Best time to find it is during the growing season.',
                    '${plant.nameSinhala} ශ්‍රී ලංකාවේ ${plant.regions.join(", ")} ප්‍රදේශ වල දකින්නට ලැබේ.',
                  ),
                  style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
