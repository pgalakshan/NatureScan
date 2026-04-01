import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'providers/plant_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/auth_provider.dart' as ap;

import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/main/home_screen.dart';
import 'screens/main/favorites_screen.dart';
import 'screens/main/settings_screen.dart';
import 'screens/main/tourist_screen.dart';
import 'screens/main/profile_screen.dart';
import 'screens/plant/camera_screen.dart';
import 'screens/plant/library_screen.dart';
import 'screens/plant/plant_detail_screen.dart';
import 'screens/plant/result_screen.dart';
import 'screens/admin/admin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Global Flutter framework error handler ─────────────────
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('════════ FLUTTER ERROR ════════');
    debugPrint('${details.exception}');
    debugPrint('${details.stack}');
    debugPrint('═══════════════════════════════');
  };

  // ── Global async / platform error handler ──────────────────
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('════════ UNHANDLED ERROR ═══════');
    debugPrint('$error');
    debugPrint('$stack');
    debugPrint('═══════════════════════════════');
    return true; // mark as handled — prevents crash dialog
  };

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ── Disable reCAPTCHA verification in debug mode ────────────
  // Firebase Auth 5.x uses reCAPTCHA Enterprise on Android.
  // Without SHA-1 + SHA-256 registered in Firebase Console this
  // throws CONFIGURATION_NOT_FOUND and blocks registration/login.
  // Remove this block (or wrap in kDebugMode) before going to production.
  if (kDebugMode) {
    await FirebaseAuth.instance.setSettings(
      appVerificationDisabledForTesting: true,
    );
    debugPrint('[Auth] reCAPTCHA disabled for debug build.');
  }

  runApp(const NaturaScanApp());
}

class NaturaScanApp extends StatelessWidget {
  const NaturaScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth must be first — others may depend on it
        ChangeNotifierProvider(create: (_) => ap.AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..loadSettings()),
        ChangeNotifierProvider(create: (_) => PlantProvider()..loadPlants()),
        // FavoritesProvider is loaded after auth state is known (see _AppRoot)
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'NaturaScan',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1E4D2B),
                primary: const Color(0xFF1E4D2B),
                secondary: const Color(0xFFD4A017),
                brightness: settings.isDarkMode
                    ? Brightness.dark
                    : Brightness.light,
              ),
              scaffoldBackgroundColor: settings.isDarkMode
                  ? const Color(0xFF121212)
                  : const Color(0xFFF5EDD8),
              textTheme: GoogleFonts.dmSansTextTheme(),
              useMaterial3: true,
            ),
            initialRoute: '/',
            routes: {
              '/': (context) => const _AppRoot(),
              '/home': (context) => const HomeScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/camera': (context) => const CameraScreen(),
              '/library': (context) => const LibraryScreen(),
              '/favorites': (context) => const FavoritesScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/tourist': (context) => const TouristScreen(),
              '/admin': (context) => const AdminScreen(),
            },
            onGenerateRoute: (routeSettings) {
              if (routeSettings.name == '/plant-detail') {
                return MaterialPageRoute(
                  builder: (_) => PlantDetailScreen(
                    plantId: routeSettings.arguments as String,
                  ),
                );
              }
              if (routeSettings.name == '/result') {
                final args =
                    routeSettings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (_) => ResultScreen(
                    imagePath: args['imagePath'] as String,
                    results: args['results'],
                  ),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}

/// _AppRoot listens to auth state and:
///   1. Shows SplashScreen while Firebase is initializing.
///   2. Loads / clears favorites whenever the logged-in user changes.
///   3. Navigates to /home or /login after splash completes.
class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  String? _lastUid; // track uid so we only reload on actual change

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.watch<ap.AuthProvider>();
    final favProvider = context.read<FavoritesProvider>();

    // auth.uid covers both SDK users and REST API fallback users
    final currentUid = auth.isLoggedIn ? auth.uid : null;

    if (currentUid != _lastUid) {
      _lastUid = currentUid;
      // Load favorites for the new user (null = guest → clears list)
      favProvider.loadFavorites(currentUid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
