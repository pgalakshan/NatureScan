import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SafetyBadge extends StatelessWidget {
  final String status; // 'safe' | 'caution' | 'toxic'
  final bool isSinhala;

  const SafetyBadge({super.key, required this.status, this.isSinhala = false});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;
    String label;
    String labelSi;

    switch (status) {
      case 'caution':
        bg = Colors.orange.shade100;
        fg = Colors.orange.shade800;
        icon = Icons.warning_amber_rounded;
        label = 'Caution';
        labelSi = 'ප්‍රවේශම්';
        break;
      case 'toxic':
        bg = Colors.red.shade100;
        fg = Colors.red.shade800;
        icon = Icons.dangerous_rounded;
        label = 'Toxic';
        labelSi = 'විෂ සහිතයි';
        break;
      default:
        bg = Colors.green.shade100;
        fg = Colors.green.shade800;
        icon = Icons.check_circle_rounded;
        label = 'Safe';
        labelSi = 'ආරක්ෂිතයි';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            isSinhala ? labelSi : label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
