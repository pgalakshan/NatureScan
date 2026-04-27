import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/plant_identifier_service.dart';
import '../../widgets/safety_badge.dart';

class ResultScreen extends StatelessWidget {
  final String imagePath;
  final List<IdentificationResult> results;

  const ResultScreen({
    super.key,
    required this.imagePath,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final favProvider = context.watch<FavoritesProvider>();

    if (results.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(settings.text('Result', 'ප්‍රතිඵලය'))),
        body: Center(child: Text(settings.text('No result', 'ප්‍රතිඵලයක් නැත'))),
      );
    }

    final top = results.first;
    final alternatives = results.skip(1).toList();
    final color = Color(top.plant.colorValue);
    final isFav = favProvider.isFavorite(top.plant.id);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Hero: Scanned image + top result overlay ─────
            Stack(
              children: [
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
                // Gradient overlay
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.75),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                // Back button
                Positioned(
                  top: 50,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                // Top match info
                Positioned(
                  bottom: 16,
                  left: 20,
                  right: 20,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              settings.isSinhala
                                  ? top.plant.nameSinhala
                                  : top.plant.nameEnglish,
                              style: GoogleFonts.playfairDisplay(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              top.plant.scientificName,
                              style: GoogleFonts.dmSans(
                                color: Colors.white70,
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red.shade300 : Colors.white,
                          size: 28,
                        ),
                        onPressed: () =>
                            favProvider.toggleFavorite(top.plant.id),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Confidence card ─────────────────────────
                  Container(
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
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(top.plant.emoji,
                                    style: const TextStyle(fontSize: 28)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    settings.text(
                                        'Top Match', 'හොඳම ගැළපීම'),
                                    style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        color: Colors.grey),
                                  ),
                                  Text(
                                    settings.isSinhala
                                        ? top.plant.nameSinhala
                                        : top.plant.nameEnglish,
                                    style: GoogleFonts.dmSans(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            SafetyBadge(
                                status: top.plant.safetyStatus,
                                isSinhala: settings.isSinhala),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Confidence bar
                        Row(
                          children: [
                            Text(
                              settings.text('Confidence', 'විශ්වාසය'),
                              style: GoogleFonts.dmSans(
                                  fontSize: 13, color: Colors.grey),
                            ),
                            const Spacer(),
                            Text(
                              '${(top.confidence * 100).toStringAsFixed(1)}%',
                              style: GoogleFonts.dmSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E4D2B)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: top.confidence,
                            minHeight: 10,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF1E4D2B)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // View Details button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              '/plant-detail',
                              arguments: top.plant.id,
                            ),
                            icon: const Icon(Icons.info_outline),
                            label: Text(
                              settings.text(
                                  'View Full Details',
                                  'සම්පූර්ණ විස්තර'),
                              style: GoogleFonts.dmSans(fontSize: 15),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E4D2B),
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Alternatives ────────────────────────────
                  if (alternatives.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      settings.text(
                          'Other Possibilities', 'අනෙකුත් හැකියාවන්'),
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ...alternatives.map((r) => _AltCard(
                          result: r,
                          settings: settings,
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/plant-detail',
                            arguments: r.plant.id,
                          ),
                        )),
                  ],

                  const SizedBox(height: 20),

                  // ── Scan Again ──────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.popUntil(
                            context, ModalRoute.withName('/camera'));
                      },
                      icon: const Icon(Icons.camera_alt,
                          color: Color(0xFF1E4D2B)),
                      label: Text(
                        settings.text('Scan Again', 'නැවත ස්කෑන් කරන්න'),
                        style: GoogleFonts.dmSans(
                            fontSize: 15, color: const Color(0xFF1E4D2B)),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF1E4D2B)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AltCard extends StatelessWidget {
  final IdentificationResult result;
  final SettingsProvider settings;
  final VoidCallback onTap;

  const _AltCard(
      {required this.result, required this.settings, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Color(result.plant.colorValue);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
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
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12)),
              child: Center(
                  child: Text(result.plant.emoji,
                      style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    settings.isSinhala
                        ? result.plant.nameSinhala
                        : result.plant.nameEnglish,
                    style: GoogleFonts.dmSans(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  Text(result.plant.scientificName,
                      style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${(result.confidence * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 70,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: result.confidence,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
