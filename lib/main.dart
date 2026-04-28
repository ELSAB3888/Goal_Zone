import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/main_layout.dart';
import 'screens/auth/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/booking_provider.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/navigation_provider.dart';
import 'core/providers/stadium_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  runApp(const SportsBookingApp());
}

class SportsBookingApp extends StatelessWidget {
  const SportsBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => StadiumProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            title: 'Goal Zone',
            debugShowCheckedModeBanner: false,
            locale: localeProvider.locale,
            theme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(
                0xFF1E1E1E,
              ), // Dark background
              primaryColor: const Color(
                0xFF4C8C18,
              ), // The green color from the image
              textTheme: const TextTheme(
                displayLarge: TextStyle(
                  color: Color(0xFF4C8C18),
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Setup simple fade animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);

    _animationController.forward();

    // Fetch initial data
    Future.microtask(() {
      if (mounted) {
        Provider.of<StadiumProvider>(context, listen: false).fetchStadiums();
      }
    });

    // Navigate to next screen after animation, checking authentication state
    Timer(const Duration(seconds: 3), () async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (mounted) {
        if (token != null && token.isNotEmpty) {
          // Fetch user profile
          final success = await Provider.of<AuthProvider>(
            context,
            listen: false,
          ).loadUser();
          if (success && mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MainLayout()),
            );
            return;
          }
        }

        // Fallback to LoginScreen if no token or loadUser failed
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final greenColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: Stack(
        children: [
          // The large green semi-circle at the top
          Positioned(
            top: -size.width * 0.5,
            left: -size.width * 0.1,
            right: -size.width * 0.1,
            child: Container(
              height: size.width * 1.2,
              decoration: BoxDecoration(
                color: greenColor,
                shape: BoxShape.circle,
              ),
            ),
          ),

          // The centered text
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome',
                    style: TextStyle(
                      color: greenColor,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Goal Zone',
                    style: TextStyle(
                      color: greenColor,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
