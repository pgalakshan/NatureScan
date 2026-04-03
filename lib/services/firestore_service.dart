import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/plant_model.dart';
import '../data/plants_data.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ══════════════════════════════════════════════════════════
  // PLANTS
  // ══════════════════════════════════════════════════════════

  /// Load all plants from Firestore.
  /// If collection is empty, seeds the 10 default Sri Lankan plants.
  Future<List<PlantModel>> loadPlants() async {
    final snapshot = await _db.collection('plants').get();

    if (snapshot.docs.isEmpty) {
      await seedDefaultPlants();
      final seeded = await _db.collection('plants').get();
      return seeded.docs.map((d) => PlantModel.fromJson(d.data())).toList();
    }

    return snapshot.docs.map((d) => PlantModel.fromJson(d.data())).toList();
  }

  /// Seed the 10 default plants to Firestore (called once when DB is empty).
  Future<void> seedDefaultPlants() async {
    final batch = _db.batch();
    for (final plant in defaultPlants) {
      final ref = _db.collection('plants').doc(plant.id);
      batch.set(ref, plant.toJson());
    }
    await batch.commit();
  }

  /// Add a new plant.
  Future<void> addPlant(PlantModel plant) async {
    await _db.collection('plants').doc(plant.id).set(plant.toJson());
  }

  /// Update an existing plant.
  Future<void> updatePlant(PlantModel plant) async {
    await _db.collection('plants').doc(plant.id).update(plant.toJson());
  }

  /// Delete a plant.
  Future<void> deletePlant(String plantId) async {
    await _db.collection('plants').doc(plantId).delete();
  }

  // ══════════════════════════════════════════════════════════
  // FAVORITES  (stored in users/{uid}.favoriteIds)
  // ══════════════════════════════════════════════════════════

  /// Load favorite plant IDs for a user.
  Future<List<String>> loadFavoriteIds(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return [];
    final data = doc.data();
    return List<String>.from(data?['favoriteIds'] ?? []);
  }

  /// Save favorite IDs for a user.
  Future<void> saveFavoriteIds(String uid, List<String> ids) async {
    await _db.collection('users').doc(uid).set(
      {'favoriteIds': ids},
      SetOptions(merge: true),
    );
  }

  // ══════════════════════════════════════════════════════════
  // USER PROFILE
  // ══════════════════════════════════════════════════════════

  Future<Map<String, dynamic>?> getProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  /// Check if a user has admin rights.
  Future<bool> isAdmin(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['isAdmin'] == true;
  }
}
