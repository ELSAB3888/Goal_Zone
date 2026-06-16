import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/constants/app_colors.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/booking_provider.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/navigation_provider.dart';
import 'core/providers/stadium_provider.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebase();
  runApp(const SportsBookingApp());
}

Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
}

class SportsBookingApp extends StatelessWidget {
  const SportsBookingApp({super.key});

  static final List<SingleChildWidget> _appProviders = [
    ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
    ChangeNotifierProvider<BookingProvider>(create: (_) => BookingProvider()),
    ChangeNotifierProvider<LocaleProvider>(create: (_) => LocaleProvider()),
    ChangeNotifierProvider<NavigationProvider>(
      create: (_) => NavigationProvider(),
    ),
    ChangeNotifierProvider<StadiumProvider>(create: (_) => StadiumProvider()),
  ];

  static ThemeData _buildAppTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 32,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: _appProviders,
      child: Consumer<LocaleProvider>(
        builder: (_, localeProvider, _) => MaterialApp(
          title: 'Goal Zone',
          debugShowCheckedModeBanner: false,
          locale: localeProvider.locale,
          theme: _buildAppTheme(),
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
