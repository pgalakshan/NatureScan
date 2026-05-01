import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/plant_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/auth_provider.dart' as ap;
import '../../models/plant_model.dart';
import 'admin_plant_form_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final plantProvider = context.watch<PlantProvider>();
    final settings = context.watch<SettingsProvider>();
    final auth = context.watch<ap.AuthProvider>();
    final plants = plantProvider.allPlants;

    // ── Guard: only admins may enter ────────────────────────
    if (!auth.isLoggedIn || !auth.isAdmin) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5EDD8),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Admin Access Only',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'You do not have permission to view this page.',
                style: GoogleFonts.dmSans(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E4D2B),
                    foregroundColor: Colors.white),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5EDD8),
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 56, 16, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF212121), Color(0xFF424242)],
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
                          '🔐 Admin Panel',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'NaturaScan Plant Management',
                          style: GoogleFonts.dmSans(
                              fontSize: 12, color: Colors.white54),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade700,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${plants.length} plants',
                        style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Stats row
                Row(
                  children: [
                    _AdminStat(
                      label: 'Trees',
                      value: '${plants.where((p) => p.category == 'tree').length}',
                      color: Colors.green,
                    ),
                    const SizedBox(width: 10),
                    _AdminStat(
                      label: 'Herbs',
                      value: '${plants.where((p) => p.category == 'herb').length}',
                      color: Colors.teal,
                    ),
                    const SizedBox(width: 10),
                    _AdminStat(
                      label: 'Plants',
                      value: '${plants.where((p) => p.category == 'plant').length}',
                      color: Colors.lime,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Toolbar ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Row(
              children: [
                Text(
                  'Plant Database',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminPlantFormScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text('Add Plant',
                      style: GoogleFonts.dmSans(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E4D2B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                  ),
                ),
              ],
            ),
          ),

          // ── Plant list ───────────────────────────────────────
          Expanded(
            child: plants.isEmpty
                ? Center(
                    child: Text('No plants yet.',
                        style: GoogleFonts.dmSans(
                            color: Colors.grey, fontSize: 16)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: plants.length,
                    itemBuilder: (ctx, i) {
                      final plant = plants[i];
                      return _AdminPlantTile(
                        plant: plant,
                        onEdit: () => Navigator.push(
                          ctx,
                          MaterialPageRoute(
                            builder: (_) =>
                                AdminPlantFormScreen(plant: plant),
                          ),
                        ),
                        onDelete: () =>
                            _confirmDelete(ctx, plant, plantProvider),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, PlantModel plant,
      PlantProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Plant',
            style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to delete "${plant.nameEnglish}"? This cannot be undone.',
          style: GoogleFonts.dmSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deletePlant(plant.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${plant.nameEnglish} deleted.'),
                  backgroundColor: Colors.red.shade700,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _AdminStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _AdminStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$value $label',
        style: GoogleFonts.dmSans(
            color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _AdminPlantTile extends StatelessWidget {
  final PlantModel plant;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminPlantTile({
    required this.plant,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(plant.colorValue);
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
          width: 46,
          height: 46,
          decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12)),
          child: Center(
              child: Text(plant.emoji, style: const TextStyle(fontSize: 24))),
        ),
        title: Text(
          plant.nameEnglish,
          style: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plant.nameSinhala,
                style: GoogleFonts.dmSans(fontSize: 12)),
            Text(plant.scientificName,
                style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic)),
          ],
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(plant.category,
                  style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w600)),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: onDelete,
            ),
          ],
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      ),
    );
  }
}
