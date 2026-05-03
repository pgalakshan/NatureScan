import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/plant_provider.dart';
import '../../models/plant_model.dart';

class AdminPlantFormScreen extends StatefulWidget {
  final PlantModel? plant; // null = Add mode, non-null = Edit mode

  const AdminPlantFormScreen({super.key, this.plant});

  @override
  State<AdminPlantFormScreen> createState() => _AdminPlantFormScreenState();
}

class _AdminPlantFormScreenState extends State<AdminPlantFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool get isEdit => widget.plant != null;

  // Controllers
  late TextEditingController _nameEnCtrl;
  late TextEditingController _nameSiCtrl;
  late TextEditingController _scientificCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _descSiCtrl;
  late TextEditingController _habitatCtrl;
  late TextEditingController _habitatSiCtrl;
  late TextEditingController _emojiCtrl;

  String _category = 'tree';
  String _safetyStatus = 'safe';

  // Medicinal uses (editable list)
  List<String> _uses = [''];
  List<String> _usesSi = [''];
  List<String> _regions = [''];

  @override
  void initState() {
    super.initState();
    final p = widget.plant;
    _nameEnCtrl = TextEditingController(text: p?.nameEnglish ?? '');
    _nameSiCtrl = TextEditingController(text: p?.nameSinhala ?? '');
    _scientificCtrl = TextEditingController(text: p?.scientificName ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _descSiCtrl = TextEditingController(text: p?.descriptionSinhala ?? '');
    _habitatCtrl = TextEditingController(text: p?.habitat ?? '');
    _habitatSiCtrl = TextEditingController(text: p?.habitatSinhala ?? '');
    _emojiCtrl = TextEditingController(text: p?.emoji ?? '🌿');
    _category = p?.category ?? 'tree';
    _safetyStatus = p?.safetyStatus ?? 'safe';
    _uses = p?.medicinalUses.isNotEmpty == true
        ? List<String>.from(p!.medicinalUses)
        : [''];
    _usesSi = p?.medicinalUsesSinhala.isNotEmpty == true
        ? List<String>.from(p!.medicinalUsesSinhala)
        : [''];
    _regions = p?.regions.isNotEmpty == true
        ? List<String>.from(p!.regions)
        : [''];
  }

  @override
  void dispose() {
    _nameEnCtrl.dispose();
    _nameSiCtrl.dispose();
    _scientificCtrl.dispose();
    _descCtrl.dispose();
    _descSiCtrl.dispose();
    _habitatCtrl.dispose();
    _habitatSiCtrl.dispose();
    _emojiCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<PlantProvider>();

    final newPlant = PlantModel(
      id: widget.plant?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      nameEnglish: _nameEnCtrl.text.trim(),
      nameSinhala: _nameSiCtrl.text.trim(),
      scientificName: _scientificCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      descriptionSinhala: _descSiCtrl.text.trim(),
      medicinalUses: _uses.where((u) => u.trim().isNotEmpty).toList(),
      medicinalUsesSinhala: _usesSi.where((u) => u.trim().isNotEmpty).toList(),
      habitat: _habitatCtrl.text.trim(),
      habitatSinhala: _habitatSiCtrl.text.trim(),
      safetyStatus: _safetyStatus,
      regions: _regions.where((r) => r.trim().isNotEmpty).toList(),
      category: _category,
      emoji: _emojiCtrl.text.trim().isEmpty ? '🌿' : _emojiCtrl.text.trim(),
      colorValue: _colorForCategory(_category),
    );

    if (isEdit) {
      await provider.updatePlant(newPlant);
    } else {
      await provider.addPlant(newPlant);
    }

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEdit
            ? '${newPlant.nameEnglish} updated!'
            : '${newPlant.nameEnglish} added!'),
        backgroundColor: const Color(0xFF1E4D2B),
      ),
    );
  }

  int _colorForCategory(String cat) {
    switch (cat) {
      case 'herb':
        return 0xFF2E7D32;
      case 'plant':
        return 0xFF558B2F;
      default:
        return 0xFF1E4D2B;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EDD8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF212121),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          isEdit ? 'Edit Plant' : 'Add New Plant',
          style: GoogleFonts.playfairDisplay(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save, color: Color(0xFFD4A017)),
            label: Text('Save',
                style: GoogleFonts.dmSans(
                    color: const Color(0xFFD4A017),
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Basic Info ─────────────────────────────────
              _sectionTitle('Basic Information'),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _Field(
                      label: 'English Name *',
                      controller: _nameEnCtrl,
                      validator: (v) =>
                          v!.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 80,
                    child: _Field(
                      label: 'Emoji',
                      controller: _emojiCtrl,
                    ),
                  ),
                ],
              ),
              _Field(
                label: 'Sinhala Name *',
                controller: _nameSiCtrl,
                validator: (v) => v!.trim().isEmpty ? 'Required' : null,
              ),
              _Field(
                label: 'Scientific Name *',
                controller: _scientificCtrl,
                hint: 'e.g. Mangifera indica',
                validator: (v) => v!.trim().isEmpty ? 'Required' : null,
              ),

              // ── Category & Safety ─────────────────────────
              _sectionTitle('Category & Safety'),
              Row(
                children: [
                  Expanded(
                    child: _DropdownField(
                      label: 'Category',
                      value: _category,
                      items: const ['tree', 'herb', 'plant'],
                      onChanged: (v) => setState(() => _category = v!),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DropdownField(
                      label: 'Safety Status',
                      value: _safetyStatus,
                      items: const ['safe', 'caution', 'toxic'],
                      onChanged: (v) => setState(() => _safetyStatus = v!),
                    ),
                  ),
                ],
              ),

              // ── Description ───────────────────────────────
              _sectionTitle('Description'),
              _Field(
                label: 'Description (English) *',
                controller: _descCtrl,
                maxLines: 3,
                validator: (v) => v!.trim().isEmpty ? 'Required' : null,
              ),
              _Field(
                label: 'Description (Sinhala)',
                controller: _descSiCtrl,
                maxLines: 3,
              ),

              // ── Habitat ───────────────────────────────────
              _sectionTitle('Habitat'),
              _Field(label: 'Habitat (English)', controller: _habitatCtrl),
              _Field(label: 'Habitat (Sinhala)', controller: _habitatSiCtrl),

              // ── Medicinal Uses ─────────────────────────────
              _sectionTitle('Medicinal Uses (English)'),
              _DynamicList(
                items: _uses,
                hint: 'e.g. Treats skin diseases',
                onChanged: (list) => setState(() => _uses = list),
              ),

              _sectionTitle('Medicinal Uses (Sinhala)'),
              _DynamicList(
                items: _usesSi,
                hint: 'සිංහලෙන් ලියන්න',
                onChanged: (list) => setState(() => _usesSi = list),
              ),

              // ── Regions ───────────────────────────────────
              _sectionTitle('Regions Found in Sri Lanka'),
              _DynamicList(
                items: _regions,
                hint: 'e.g. Western, Central',
                onChanged: (list) => setState(() => _regions = list),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: Text(
                    isEdit ? 'Update Plant' : 'Add Plant',
                    style: GoogleFonts.dmSans(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E4D2B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.playfairDisplay(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1E4D2B),
        ),
      ),
    );
  }
}

// ── Form sub-widgets ─────────────────────────────────────────────

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final String? hint;
  final String? Function(String?)? validator;

  const _Field({
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.hint,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: GoogleFonts.dmSans(fontSize: 13),
          hintStyle:
              GoogleFonts.dmSans(fontSize: 12, color: Colors.grey.shade400),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFF1E4D2B), width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.dmSans(fontSize: 13),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        items: items
            .map((i) => DropdownMenuItem(
                value: i, child: Text(i, style: GoogleFonts.dmSans())))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _DynamicList extends StatefulWidget {
  final List<String> items;
  final String hint;
  final ValueChanged<List<String>> onChanged;

  const _DynamicList({
    required this.items,
    required this.hint,
    required this.onChanged,
  });

  @override
  State<_DynamicList> createState() => _DynamicListState();
}

class _DynamicListState extends State<_DynamicList> {
  late List<TextEditingController> _ctrls;

  @override
  void initState() {
    super.initState();
    _ctrls = widget.items
        .map((t) => TextEditingController(text: t))
        .toList();
  }

  @override
  void dispose() {
    for (var c in _ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _notify() {
    widget.onChanged(_ctrls.map((c) => c.text).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ..._ctrls.asMap().entries.map((e) {
          final i = e.key;
          final ctrl = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: ctrl,
                    onChanged: (_) => _notify(),
                    decoration: InputDecoration(
                      hintText: '${i + 1}. ${widget.hint}',
                      hintStyle: GoogleFonts.dmSans(
                          fontSize: 12, color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                if (_ctrls.length > 1) ...[
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.remove_circle,
                        color: Colors.red, size: 22),
                    onPressed: () {
                      setState(() {
                        _ctrls[i].dispose();
                        _ctrls.removeAt(i);
                      });
                      _notify();
                    },
                  ),
                ],
              ],
            ),
          );
        }),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              setState(() => _ctrls.add(TextEditingController()));
              _notify();
            },
            icon: const Icon(Icons.add, color: Color(0xFF1E4D2B), size: 18),
            label: Text('Add another',
                style: GoogleFonts.dmSans(color: const Color(0xFF1E4D2B))),
          ),
        ),
      ],
    );
  }
}
