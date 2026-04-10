import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart'; // also exports kAdminEmail, RestAuthSuccess, RestAuthResult
import '../services/firestore_service.dart';

// SharedPreferences keys for REST API session persistence
const _kPrefUid = 'rest_uid';
const _kPrefEmail = 'rest_email';
const _kPrefName = 'rest_name';
const _kPrefRefresh = 'rest_refresh';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? _user;               // Firebase SDK user (null when using REST API path)
  Map<String, dynamic>? _profile;
  bool _isAdmin = false;
  bool _isLoading = false;
  String? _error;

  // REST API fallback user fields (populated when SDK auth isn't available)
  String? _restUid;
  String? _restEmail;
  String? _restDisplayName;

  // ── Public getters ────────────────────────────────────────
  User? get user => _user;
  Map<String, dynamic>? get profile => _profile;

  /// True when either SDK user or REST API user is active.
  bool get isLoggedIn => _user != null || _restUid != null;

  bool get isAdmin => _isAdmin;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get displayName =>
      _profile?['name'] ?? _user?.displayName ?? _restDisplayName ?? 'User';
  String get email => _user?.email ?? _restEmail ?? '';

  /// UID works for both SDK and REST API users.
  String? get uid => _user?.uid ?? _restUid;

  // ── Init: listen to Firebase auth state + restore REST session ──
  void init() {
    _authService.authStateChanges.listen((user) async {
      _user = user;
      if (user != null) {
        // SDK user signed in — clear any stored REST session
        _restUid = null;
        _restEmail = null;
        _restDisplayName = null;
        await _clearRestSession();
        await _loadProfile(user.uid);
      } else if (_restUid == null) {
        // No SDK user and no REST user → logged out
        _profile = null;
        _isAdmin = false;
      }
      notifyListeners();
    });

    // Try to restore a persisted REST API session on cold start
    _restoreRestSession();
  }

  Future<void> _loadProfile(String uid) async {
    try {
      _profile = await _firestoreService.getProfile(uid);
    } catch (e) {
      debugPrint('[Auth] Profile load failed: $e');
    }
    _isAdmin = _profile?['isAdmin'] == true ||
        (_user?.email?.toLowerCase() == kAdminEmail.toLowerCase()) ||
        (_restEmail?.toLowerCase() == kAdminEmail.toLowerCase());
  }

  // ── Register ───────────────────────────────────────────────
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String language,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.register(
        name: name,
        email: email,
        password: password,
        language: language,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on RestAuthSuccess catch (e) {
      // REST API path succeeded — set user state manually
      debugPrint('[Auth] Register via REST API succeeded: ${e.result.uid}');
      await _applyRestUser(
        result: e.result,
        name: name,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('[Auth] Register FirebaseAuthException: ${e.code} — ${e.message}');
      _error = _friendlyError(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e, stack) {
      debugPrint('[Auth] Register unexpected error: $e');
      debugPrint('[Auth] Stack: $stack');
      _error = kDebugMode ? e.toString() : 'Registration failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Login ──────────────────────────────────────────────────
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.login(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } on RestAuthSuccess catch (e) {
      debugPrint('[Auth] Login via REST API succeeded: ${e.result.uid}');
      await _applyRestUser(result: e.result);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('[Auth] Login FirebaseAuthException: ${e.code} — ${e.message}');
      _error = _friendlyError(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e, stack) {
      debugPrint('[Auth] Login unexpected error: $e');
      debugPrint('[Auth] Stack: $stack');
      _error = kDebugMode ? e.toString() : 'Login failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Sign out ───────────────────────────────────────────────
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _profile = null;
    _isAdmin = false;
    _restUid = null;
    _restEmail = null;
    _restDisplayName = null;
    await _clearRestSession();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ── REST API session helpers ──────────────────────────────

  Future<void> _applyRestUser({
    required RestAuthResult result,
    String? name,
  }) async {
    _restUid = result.uid;
    _restEmail = result.email;
    _restDisplayName = name;

    // Try to load Firestore profile (rules permitting)
    await _loadProfile(result.uid);

    // Persist so session survives app restarts
    await _saveRestSession(result, name);
  }

  Future<void> _saveRestSession(RestAuthResult result, String? name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kPrefUid, result.uid);
      await prefs.setString(_kPrefEmail, result.email);
      await prefs.setString(_kPrefRefresh, result.refreshToken);
      if (name != null) await prefs.setString(_kPrefName, name);
    } catch (e) {
      debugPrint('[Auth] Prefs save failed: $e');
    }
  }

  Future<void> _restoreRestSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString(_kPrefUid);
      final email = prefs.getString(_kPrefEmail);
      if (uid != null && email != null) {
        _restUid = uid;
        _restEmail = email;
        _restDisplayName = prefs.getString(_kPrefName);
        await _loadProfile(uid);
        debugPrint('[Auth] Restored REST session for $email');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[Auth] Prefs restore failed: $e');
    }
  }

  Future<void> _clearRestSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kPrefUid);
      await prefs.remove(_kPrefEmail);
      await prefs.remove(_kPrefRefresh);
      await prefs.remove(_kPrefName);
    } catch (e) {
      debugPrint('[Auth] Prefs clear failed: $e');
    }
  }

  // ── User-friendly Firebase error messages ──────────────────
  String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection. Please try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
