import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/plant_model.dart';
import 'safety_badge.dart';

class PlantCard extends StatelessWidget {
  final PlantModel plant;
  final bool isSinhala;
  final VoidCallback onTap;

  const PlantCard({
    super.key,
    required this.plant,
    required this.onTap,
    this.isSinhala = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(plant.colorValue);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image / Emoji area
            Container(
              height: 110,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Center(
                child: Text(plant.emoji, style: const TextStyle(fontSize: 52)),
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSinhala ? plant.nameSinhala : plant.nameEnglish,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!isSinhala)
                    Text(
                      plant.nameSinhala,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                    ),
                  Text(
                    plant.scientificName,
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  SafetyBadge(status: plant.safetyStatus, isSinhala: isSinhala),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
