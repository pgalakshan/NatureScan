import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as ap;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();

    // After animation, check auth state and navigate
    Future.delayed(const Duration(seconds: 3), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final auth = context.read<ap.AuthProvider>();
    if (auth.isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E4D2B),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(Icons.eco, size: 80, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Text(
                'NaturaScan',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'නේචරාස්කෑන් • நேச்சர்ஸ்கேன்',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  color: Colors.white60,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Scan. Identify. Discover.',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(color: Color(0xFFD4A017)),
            ],
          ),
        ),
      ),
    );
  }
}
