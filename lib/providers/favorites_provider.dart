import 'package:flutter/material.dart';
import '../models/plant_model.dart';
import '../services/firestore_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();

  List<String> _favoriteIds = [];
  String? _uid; // current logged-in user's UID

  List<String> get favoriteIds => _favoriteIds;
  int get count => _favoriteIds.length;

  /// Call when user logs in or changes.
  Future<void> loadFavorites(String? uid) async {
    _uid = uid;
    if (uid == null) {
      _favoriteIds = [];
      notifyListeners();
      return;
    }
    try {
      _favoriteIds = await _firestore.loadFavoriteIds(uid);
    } catch (e) {
      _favoriteIds = [];
    }
    notifyListeners();
  }

  bool isFavorite(String plantId) => _favoriteIds.contains(plantId);

  Future<void> toggleFavorite(String plantId, {bool requireLogin = false}) async {
    if (_uid == null) return; // not logged in — handled by UI

    if (_favoriteIds.contains(plantId)) {
      _favoriteIds.remove(plantId);
    } else {
      _favoriteIds.add(plantId);
    }

    notifyListeners();

    // Persist to Firestore
    try {
      await _firestore.saveFavoriteIds(_uid!, _favoriteIds);
    } catch (e) {
      debugPrint('Favorites save error: $e');
    }
  }

  /// Clear favorites on sign-out.
  void clear() {
    _uid = null;
    _favoriteIds = [];
    notifyListeners();
  }

  List<PlantModel> getFavoritePlants(List<PlantModel> allPlants) {
    return allPlants.where((p) => _favoriteIds.contains(p.id)).toList();
  }
}
