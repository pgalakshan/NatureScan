import 'package:flutter/material.dart';
import '../models/plant_model.dart';
import '../services/firestore_service.dart';
import '../data/plants_data.dart';

class PlantProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();

  List<PlantModel> _allPlants = [];
  List<PlantModel> _filtered = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isLoading = false;

  List<PlantModel> get plants => _filtered;
  List<PlantModel> get allPlants => _allPlants;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;

  final List<String> categories = ['All', 'tree', 'herb', 'plant'];

  // ── Load from Firestore (seeds if empty) ──────────────────
  Future<void> loadPlants() async {
    _isLoading = true;
    notifyListeners();

    // Run after first frame so we never block the UI thread at startup
    await Future.microtask(() async {
      try {
        _allPlants = await _firestore.loadPlants();
        debugPrint('[Plants] Loaded ${_allPlants.length} plants from Firestore.');
      } catch (e) {
        debugPrint('[Plants] Firestore load error: $e');
        // Fall back to local default data so the app is usable offline
        _allPlants = defaultPlants;
        debugPrint('[Plants] Loaded ${_allPlants.length} local default plants.');
      }
      _applyFilter();
      _isLoading = false;
      notifyListeners();
    });
  }

  // ── Search & Filter ───────────────────────────────────────
  void search(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilter();
    notifyListeners();
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    _filtered = _allPlants.where((p) {
      final matchesSearch = _searchQuery.isEmpty ||
          p.nameEnglish.toLowerCase().contains(_searchQuery) ||
          p.nameSinhala.contains(_searchQuery) ||
          p.scientificName.toLowerCase().contains(_searchQuery);
      final matchesCategory =
          _selectedCategory == 'All' || p.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  PlantModel? getById(String id) {
    try {
      return _allPlants.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── CRUD (Admin) ──────────────────────────────────────────
  Future<void> addPlant(PlantModel plant) async {
    await _firestore.addPlant(plant);
    _allPlants.add(plant);
    _applyFilter();
    notifyListeners();
  }

  Future<void> updatePlant(PlantModel updated) async {
    await _firestore.updatePlant(updated);
    final idx = _allPlants.indexWhere((p) => p.id == updated.id);
    if (idx != -1) _allPlants[idx] = updated;
    _applyFilter();
    notifyListeners();
  }

  Future<void> deletePlant(String id) async {
    await _firestore.deletePlant(id);
    _allPlants.removeWhere((p) => p.id == id);
    _applyFilter();
    notifyListeners();
  }

  // ── Featured plant (changes daily) ───────────────────────
  PlantModel? get featuredPlant {
    if (_allPlants.isEmpty) return null;
    return _allPlants[DateTime.now().day % _allPlants.length];
  }
}
