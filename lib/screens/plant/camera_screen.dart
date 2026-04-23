import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../providers/plant_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/plant_identifier_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _image;
  bool _isIdentifying = false;
  final ImagePicker _picker = ImagePicker();
  final PlantIdentifierService _service = PlantIdentifierService();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? photo = await _picker.pickImage(
      source: source,
      imageQuality: 95,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (photo != null) {
      setState(() {
        _image = File(photo.path);
      });
    }
  }

  Future<void> _identify() async {
    if (_image == null) return;
    setState(() => _isIdentifying = true);

    final allPlants = context.read<PlantProvider>().allPlants;
    final results = await _service.identify(_image!, allPlants);

    if (!mounted) return;
    setState(() => _isIdentifying = false);

    // Empty results = APIs confirmed this is NOT a plant
    if (results.isEmpty) {
      _showNotAPlantDialog();
      return;
    }

    Navigator.pushNamed(
      context,
      '/result',
      arguments: {
        'imagePath': _image!.path,
        'results': results,
      },
    );
  }

  void _showNotAPlantDialog() {
    final settings = context.read<SettingsProvider>();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.not_interested,
                    size: 44, color: Colors.red.shade400),
              ),
              const SizedBox(height: 20),
              Text(
                settings.text("That's not a plant!", 'එය පැළෑටියක් නොවේ!'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                settings.text(
                  'Our AI could not detect any plant in this image.\n\nPlease take a clear photo of a plant leaf, fruit or flower.',
                  'AI හට රූපයේ පැළෑටියක් හඳුනා ගත නොහැකි විය.\n\nකොළයක්, ඵලයක් හෝ මලක් පැහැදිලිව ඡායාරූප ගන්න.',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _pickImage(ImageSource.gallery);
                      },
                      icon: const Icon(Icons.photo_library, size: 18),
                      label: Text(settings.text('Gallery', 'ගැලරිය')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1E4D2B),
                        side: const BorderSide(color: Color(0xFF1E4D2B)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _pickImage(ImageSource.camera);
                      },
                      icon: const Icon(Icons.camera_alt, size: 18),
                      label: Text(settings.text('Retake', 'නැවත ගන්න')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E4D2B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF1E4D2B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E4D2B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          settings.text('Scan Plant', 'පැළය ස්කෑන් කරන්න'),
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Image preview ──────────────────────────────────
          Expanded(
            child: _isIdentifying
                ? _IdentifyingOverlay(settings: settings)
                : _image == null
                    ? _PlaceholderView(settings: settings)
                    : _ImagePreview(image: _image!),
          ),

          // ── Buttons ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            decoration: BoxDecoration(
              color: const Color(0xFF1E4D2B),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Camera
                _ScanButton(
                  icon: Icons.camera_alt,
                  label: settings.text(
                      'Open Camera', 'කැමරාව විවෘත කරන්න'),
                  color: const Color(0xFFD4A017),
                  onTap: _isIdentifying
                      ? null
                      : () => _pickImage(ImageSource.camera),
                ),
                const SizedBox(height: 10),
                // Gallery
                _ScanButton(
                  icon: Icons.photo_library,
                  label: settings.text(
                      'Choose from Gallery', 'ගැලරිය'),
                  color: Colors.white.withOpacity(0.18),
                  onTap: _isIdentifying
                      ? null
                      : () => _pickImage(ImageSource.gallery),
                ),
                if (_image != null) ...[
                  const SizedBox(height: 10),
                  // Identify
                  _ScanButton(
                    icon: Icons.search,
                    label: settings.text(
                        'Identify Plant', 'පැළය හඳුනා ගන්න'),
                    color: Colors.green.shade600,
                    onTap: _isIdentifying ? null : _identify,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────

class _PlaceholderView extends StatelessWidget {
  final SettingsProvider settings;
  const _PlaceholderView({required this.settings});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.camera_alt,
                size: 80, color: Colors.white54),
          ),
          const SizedBox(height: 24),
          Text(
            settings.text(
                'Take a photo of a plant', 'පැළයක් ඡායාරූප ගන්න'),
            style: GoogleFonts.dmSans(
                color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 6),
          Text(
            settings.text(
                'Point your camera at any plant',
                'ඕනෑම පැළෙකට කැමරාව යොමු කරන්න'),
            style: GoogleFonts.dmSans(
                color: Colors.white38, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final File image;
  const _ImagePreview({required this.image});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.file(
          image,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }
}

class _IdentifyingOverlay extends StatelessWidget {
  final SettingsProvider settings;
  const _IdentifyingOverlay({required this.settings});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SpinKitRipple(
            color: Color(0xFFD4A017),
            size: 100,
          ),
          const SizedBox(height: 24),
          Text(
            settings.text('Identifying plant...', 'පැළය හඳුනා ගනිමින්...'),
            style: GoogleFonts.playfairDisplay(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            settings.text(
                'AI is analyzing the image', 'AI රූපය විශ්ලේෂණය කරයි'),
            style: GoogleFonts.dmSans(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ScanButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 22),
        label: Text(label, style: GoogleFonts.dmSans(fontSize: 15)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
    );
  }
}
