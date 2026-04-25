import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/plant_model.dart';

// ═══════════════════════════════════════════════════════════════
// PlantIdentifierService — PlantNet API + deterministic mock
//
// PlantNet is a FREE plant-identification API that recognises
// plants from photos of leaves, fruits, flowers or bark.
// Register for a FREE key at: https://my.plantnet.org/
// (500 identifications / day on the free plan — enough for dev)
//
// HOW TO ACTIVATE:
//   1. Go to https://my.plantnet.org/ → Sign up → My Account → API Keys
//   2. Copy your key and paste it below in place of the placeholder.
//   3. Hot-restart the app — real identification starts immediately.
// ═══════════════════════════════════════════════════════════════

// ── Paste your PlantNet API key here ───────────────────────────
const String _kPlantNetApiKey = '2b10wTZiVg8PsJ1cXL2HXYe';

// Set to false to force the deterministic mock (no API calls)
const bool _kUsePlantNet = true;

// Minimum confidence to trust a result (below this = "not a plant")
const double _kMinConfidence = 0.15; // 15%

// ── PlantNet API base URL ──────────────────────────────────────
const String _kPlantNetBase = 'https://my-api.plantnet.org/v2';

class IdentificationResult {
  final PlantModel plant;
  final double confidence; // 0.0 – 1.0
  final String? apiScientificName; // name returned by PlantNet

  const IdentificationResult({
    required this.plant,
    required this.confidence,
    this.apiScientificName,
  });
}

class PlantIdentifierService {
  // ── Public entry point ──────────────────────────────────────
  /// Identifies the plant in [imageFile] and returns top-3 matches.
  /// Uses PlantNet API when a key is configured, falls back to mock.
  Future<List<IdentificationResult>> identify(
    File imageFile,
    List<PlantModel> allPlants,
  ) async {
    if (allPlants.isEmpty) return [];

    if (_kUsePlantNet && _kPlantNetApiKey != 'YOUR_PLANTNET_API_KEY') {
      try {
        return await _runPlantNet(imageFile, allPlants);
      } catch (e) {
        debugPrint('[PlantID] PlantNet failed: $e — using mock fallback');
        return _runMock(imageFile, allPlants);
      }
    }

    debugPrint('[PlantID] PlantNet key not set — using deterministic mock');
    return _runMock(imageFile, allPlants);
  }

  // ── PlantNet REST API ───────────────────────────────────────
  Future<List<IdentificationResult>> _runPlantNet(
    File imageFile,
    List<PlantModel> allPlants,
  ) async {
    final plantNetResult = await _tryPlantNet(imageFile, allPlants);
    if (plantNetResult != null) return plantNetResult;

    // PlantNet found nothing — this is NOT a plant
    debugPrint('[PlantID] PlantNet: no plant detected → returning empty');
    return []; // empty = "not a plant" dialog shown in camera_screen
  }

  // ── PlantNet ────────────────────────────────────────────────
  Future<List<IdentificationResult>?> _tryPlantNet(
    File imageFile,
    List<PlantModel> allPlants,
  ) async {
    try {
      debugPrint('[PlantID] Calling PlantNet API…');

      final uri = Uri.parse(
        '$_kPlantNetBase/identify/all'
        '?include-related-images=false'
        '&no-reject=true'
        '&nb-results=5'
        '&lang=en'
        '&api-key=$_kPlantNetApiKey',
      );

      final request = http.MultipartRequest('POST', uri);
      request.fields['organs'] = 'auto';
      request.files.add(
        await http.MultipartFile.fromPath('images', imageFile.path),
      );

      final streamed =
          await request.send().timeout(const Duration(seconds: 25));
      final response = await http.Response.fromStream(streamed);

      debugPrint('[PlantID] PlantNet status: ${response.statusCode}');

      if (response.statusCode == 404) {
        debugPrint('[PlantID] PlantNet: Species not found');
        return null;
      }

      if (response.statusCode != 200) {
        debugPrint('[PlantID] PlantNet error: ${response.body}');
        return null;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final results = body['results'] as List<dynamic>;
      debugPrint('[PlantID] PlantNet returned ${results.length} candidates');

      return _parseAndMatch(results, allPlants, source: 'PlantNet');
    } catch (e) {
      debugPrint('[PlantID] PlantNet exception: $e');
      return null;
    }
  }

  // ── iNaturalist Computer Vision (free, no key needed) ───────
  Future<List<IdentificationResult>?> _tryINaturalist(
    File imageFile,
    List<PlantModel> allPlants,
  ) async {
    try {
      debugPrint('[PlantID] Calling iNaturalist API…');

      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http
          .post(
            Uri.parse('https://api.inaturalist.org/v1/computervision/score_image'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'image': 'data:image/jpeg;base64,$base64Image',
            }),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('[PlantID] iNaturalist status: ${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint('[PlantID] iNaturalist error: ${response.body}');
        return null;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final results = (body['results'] as List<dynamic>?) ?? [];
      debugPrint('[PlantID] iNaturalist returned ${results.length} candidates');

      if (results.isEmpty) return null;

      final List<IdentificationResult> matched = [];

      for (final r in results) {
        final score = (r['combined_score'] as num? ?? 0).toDouble() / 100.0;
        final taxon = r['taxon'] as Map<String, dynamic>? ?? {};
        final sciName = (taxon['name'] as String? ?? '').trim();
        final commonName =
            (taxon['preferred_common_name'] as String? ?? '').toLowerCase();

        debugPrint(
            '[PlantID] iNat → $sciName / $commonName '
            '(${(score * 100).toStringAsFixed(1)}%)');

        final plant =
            _matchToDatabase(sciName, [commonName], allPlants);
        if (plant != null) {
          matched.add(IdentificationResult(
            plant: plant,
            confidence: score,
            apiScientificName: sciName,
          ));
        }
      }

      final seen = <String>{};
      final deduped = matched.where((r) => seen.add(r.plant.id)).toList();

      if (deduped.isEmpty) return null;

      debugPrint(
          '[PlantID] iNat best: ${deduped.first.plant.nameEnglish} '
          '(${(deduped.first.confidence * 100).toStringAsFixed(1)}%)');

      return deduped.take(3).toList();
    } catch (e) {
      debugPrint('[PlantID] iNaturalist exception: $e');
      return null;
    }
  }

  // ── Parse PlantNet response format ──────────────────────────
  List<IdentificationResult>? _parseAndMatch(
    List<dynamic> results,
    List<PlantModel> allPlants, {
    required String source,
  }) {
    final List<IdentificationResult> matched = [];

    for (final r in results) {
      final score = (r['score'] as num).toDouble();
      final species = r['species'] as Map<String, dynamic>;
      final sciName =
          (species['scientificNameWithoutAuthor'] as String? ?? '').trim();
      final commonNames = (species['commonNames'] as List<dynamic>?)
              ?.map((e) => e.toString().toLowerCase().trim())
              .toList() ??
          [];

      debugPrint(
          '[PlantID] $source → $sciName '
          '(${(score * 100).toStringAsFixed(1)}%)');

      // Skip anything below minimum confidence threshold
      if (score < _kMinConfidence) {
        debugPrint('[PlantID] Skipping — below ${(_kMinConfidence * 100).toInt()}% threshold');
        continue;
      }

      final plant = _matchToDatabase(sciName, commonNames, allPlants);
      if (plant != null) {
        matched.add(IdentificationResult(
          plant: plant,
          confidence: score,
          apiScientificName: sciName,
        ));
      }
    }

    final seen = <String>{};
    final deduped = matched.where((r) => seen.add(r.plant.id)).toList();

    if (deduped.isEmpty) return null;

    debugPrint(
        '[PlantID] Best match: ${deduped.first.plant.nameEnglish} '
        '(${(deduped.first.confidence * 100).toStringAsFixed(1)}%)');

    return deduped.take(3).toList();
  }

  // ── Database matching ───────────────────────────────────────
  /// Tries to find a [PlantModel] whose scientific name or English
  /// common name matches what PlantNet returned.
  PlantModel? _matchToDatabase(
    String apiSciName,
    List<String> apiCommonNames,
    List<PlantModel> allPlants,
  ) {
    final sciLower = apiSciName.toLowerCase();

    // Build a map of known synonyms / alternate scientific names
    const synonyms = <String, String>{
      // Aloe vera has two accepted names
      'aloe vera': 'aloe barbadensis',
      // Tulsi synonyms
      'ocimum sanctum': 'ocimum tenuiflorum',
      // Banana — PlantNet may return the old name
      'musa paradisiaca': 'musa acuminata',
    };
    final resolved = synonyms[sciLower] ?? sciLower;

    // 1. Exact scientific name match
    for (final p in allPlants) {
      if (p.scientificName.toLowerCase() == resolved) return p;
    }

    // 2. Genus-level match (e.g. Artocarpus sp. → Jackfruit / Breadfruit)
    final genus = resolved.split(' ').first;
    if (genus.length > 3) {
      for (final p in allPlants) {
        if (p.scientificName.toLowerCase().startsWith('$genus ')) return p;
      }
    }

    // 3. Common-name match (English name from our DB appears in PlantNet list)
    for (final p in allPlants) {
      final eng = p.nameEnglish.toLowerCase();
      if (apiCommonNames.any((cn) =>
          cn.contains(eng) || eng.contains(cn) || _isSimilar(cn, eng))) {
        return p;
      }
    }

    return null;
  }

  /// Very lightweight fuzzy match — true when strings share ≥70 % of chars
  bool _isSimilar(String a, String b) {
    if (a.isEmpty || b.isEmpty) return false;
    final shorter = a.length < b.length ? a : b;
    final longer = a.length < b.length ? b : a;
    int matches = 0;
    for (final ch in shorter.split('')) {
      if (longer.contains(ch)) matches++;
    }
    return matches / shorter.length >= 0.7;
  }

  // ── Deterministic mock (used when no API key is set) ────────
  /// Returns plausible-looking results that are consistent for the
  /// same image (seeded from file size + path hash).
  List<IdentificationResult> _runMock(
    File imageFile,
    List<PlantModel> allPlants,
  ) {
    int seed = imageFile.path.hashCode;
    try {
      seed = imageFile.statSync().size ^ imageFile.path.hashCode;
    } catch (_) {}

    final rng = Random(seed);
    final shuffled = List<PlantModel>.from(allPlants)..shuffle(rng);

    final scores = <double>[
      0.65 + rng.nextDouble() * 0.25, // 65–90 %
      0.30 + rng.nextDouble() * 0.20, // 30–50 %
      0.08 + rng.nextDouble() * 0.17, // 8–25 %
    ]..sort((a, b) => b.compareTo(a));

    debugPrint(
        '[PlantID] Mock → ${shuffled[0].nameEnglish} '
        '(${(scores[0] * 100).toStringAsFixed(1)}%)');

    return List.generate(
      min(3, shuffled.length),
      (i) => IdentificationResult(plant: shuffled[i], confidence: scores[i]),
    );
  }
}
