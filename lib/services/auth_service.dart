import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Hardcoded admin email — anyone who registers or logs in with this
/// email is automatically granted admin access.
const String kAdminEmail = 'admin@naturescan.com';

// ─────────────────────────────────────────────────────────────────
// Firebase Auth Identity Toolkit REST API
// Used as a fallback when the native SDK throws CONFIGURATION_NOT_FOUND
// (reCAPTCHA Enterprise not yet configured — missing SHA-256 fingerprint).
// REST API endpoints do NOT require reCAPTCHA, so registration and login
// work even before SHA fingerprints are registered in Firebase Console.
// ─────────────────────────────────────────────────────────────────
const String _kApiKey = 'AIzaSyDpNsBOZKYEYntU8keoDu742jLCH6A0HP0';
const String _kAuthBase = 'https://identitytoolkit.googleapis.com/v1';

/// Lightweight result returned by the REST API paths.
class RestAuthResult {
  final String uid;
  final String email;
  final String idToken;
  final String refreshToken;

  const RestAuthResult({
    required this.uid,
    required this.email,
    required this.idToken,
    required this.refreshToken,
  });
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Auth state stream ──────────────────────────────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // ── Register ───────────────────────────────────────────────
  /// Returns the native [UserCredential] when the SDK works, or throws
  /// a [RestAuthSuccess] (caught in AuthProvider) when we fall back to
  /// the REST API because reCAPTCHA Enterprise is not yet configured.
  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
    required String language,
  }) async {
    try {
      // ── Primary path: native Firebase Auth SDK ─────────────
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      await credential.user!.updateDisplayName(name.trim());
      await _writeUserDoc(
        uid: credential.user!.uid,
        name: name.trim(),
        email: email.trim(),
        language: language,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      // CONFIGURATION_NOT_FOUND → reCAPTCHA Enterprise not configured.
      // Fall back to REST API which has no reCAPTCHA requirement.
      if (_isRecaptchaError(e)) {
        debugPrint('[Auth] SDK register blocked by reCAPTCHA — using REST API fallback.');
        final rest = await _restSignUp(email.trim(), password.trim());
        await _restUpdateDisplayName(rest.idToken, name.trim());
        await _writeUserDoc(
          uid: rest.uid,
          name: name.trim(),
          email: email.trim(),
          language: language,
        );
        throw RestAuthSuccess(rest); // caught in AuthProvider
      }
      rethrow;
    }
  }

  // ── Login ──────────────────────────────────────────────────
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      if (_isRecaptchaError(e)) {
        debugPrint('[Auth] SDK login blocked by reCAPTCHA — using REST API fallback.');
        final rest = await _restSignIn(email.trim(), password.trim());
        throw RestAuthSuccess(rest); // caught in AuthProvider
      }
      rethrow;
    }
  }

  // ── Sign out ───────────────────────────────────────────────
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ── Get user profile from Firestore ───────────────────────
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  // ── Check if admin ─────────────────────────────────────────
  Future<bool> isAdmin(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return false;
    return doc.data()?['isAdmin'] == true;
  }

  // ── Update language preference ─────────────────────────────
  Future<void> updateLanguage(String uid, String language) async {
    await _db.collection('users').doc(uid).update({'language': language});
  }

  // ══════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ══════════════════════════════════════════════════════════

  bool _isRecaptchaError(FirebaseAuthException e) {
    final msg = (e.message ?? '').toLowerCase();
    return msg.contains('configuration_not_found') ||
        msg.contains('recaptcha') ||
        e.code == 'unknown';
  }

  /// Create / update Firestore user document (non-fatal).
  Future<void> _writeUserDoc({
    required String uid,
    required String name,
    required String email,
    required String language,
  }) async {
    final bool isAdmin = email.toLowerCase() == kAdminEmail.toLowerCase();
    try {
      await _db.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'language': language,
        'isAdmin': isAdmin,
        'favoriteIds': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[Auth] Firestore user doc write failed (non-fatal): $e');
    }
  }

  // ── REST API helpers ───────────────────────────────────────

  Future<RestAuthResult> _restSignUp(String email, String password) async {
    final resp = await http.post(
      Uri.parse('$_kAuthBase/accounts:signUp?key=$_kApiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );
    return _parseRestResponse(resp);
  }

  Future<RestAuthResult> _restSignIn(String email, String password) async {
    final resp = await http.post(
      Uri.parse('$_kAuthBase/accounts:signInWithPassword?key=$_kApiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );
    return _parseRestResponse(resp);
  }

  Future<void> _restUpdateDisplayName(String idToken, String displayName) async {
    try {
      await http.post(
        Uri.parse('$_kAuthBase/accounts:update?key=$_kApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': idToken,
          'displayName': displayName,
          'returnSecureToken': false,
        }),
      );
    } catch (e) {
      debugPrint('[Auth] REST display name update failed (non-fatal): $e');
    }
  }

  RestAuthResult _parseRestResponse(http.Response resp) {
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    if (data.containsKey('error')) {
      final errMsg = data['error']['message'] as String? ?? 'unknown';
      debugPrint('[Auth] REST API error: $errMsg');
      // Map REST API error codes to FirebaseAuthException codes
      String code = 'unknown';
      if (errMsg.contains('EMAIL_EXISTS')) code = 'email-already-in-use';
      if (errMsg.contains('WEAK_PASSWORD')) code = 'weak-password';
      if (errMsg.contains('INVALID_EMAIL')) code = 'invalid-email';
      if (errMsg.contains('EMAIL_NOT_FOUND')) code = 'user-not-found';
      if (errMsg.contains('INVALID_PASSWORD')) code = 'wrong-password';
      if (errMsg.contains('TOO_MANY_ATTEMPTS')) code = 'too-many-requests';
      throw FirebaseAuthException(code: code, message: errMsg);
    }
    return RestAuthResult(
      uid: data['localId'] as String,
      email: data['email'] as String,
      idToken: data['idToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
  }
}

/// Internal signal thrown by [AuthService] when the REST API path succeeded.
/// [AuthProvider] catches this to set the user state from [RestAuthResult].
class RestAuthSuccess implements Exception {
  final RestAuthResult result;
  const RestAuthSuccess(this.result);
}
