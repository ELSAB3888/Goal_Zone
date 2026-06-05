import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/stadium_provider.dart';
import '../../widgets/main_layout.dart';
import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _animationDuration = Duration(seconds: 2);
  static const Duration _splashDelay = Duration(seconds: 3);

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _prefetchData();
    _scheduleNavigation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);
    _animationController.forward();
  }

  void _prefetchData() {
    Future.microtask(() {
      if (!mounted) return;
      context.read<StadiumProvider>().fetchStadiums();
    });
  }

  void _scheduleNavigation() {
    Timer(_splashDelay, _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;

    final isAuthenticated = await _checkAuthToken();

    if (!mounted) return;

    if (isAuthenticated) {
      final success = await context.read<AuthProvider>().loadUser();
      if (success && mounted) {
        _goToHome();
        return;
      }
    }

    if (mounted) _goToLogin();
  }

  Future<bool> _checkAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }

  void _goToHome() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const MainLayout()));
  }

  void _goToLogin() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _GreenSemiCircle(),
          _AnimatedLogo(fadeAnimation: _fadeAnimation),
        ],
      ),
    );
  }
}

class _GreenSemiCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Positioned(
      top: -size.width * 0.5,
      left: -size.width * 0.1,
      right: -size.width * 0.1,
      child: Container(
        height: size.width * 1.2,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _AnimatedLogo extends StatelessWidget {
  const _AnimatedLogo({required this.fadeAnimation});

  final Animation<double> fadeAnimation;

  static const _logoTextStyle = TextStyle(
    color: AppColors.primary,
    fontSize: 36,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.2,
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: fadeAnimation,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Welcome', style: _logoTextStyle),
            SizedBox(height: 8),
            Text('Goal Zone', style: _logoTextStyle),
          ],
        ),
      ),
    );
  }
}
