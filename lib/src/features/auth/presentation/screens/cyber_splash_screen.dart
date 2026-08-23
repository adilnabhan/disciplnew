import 'dart:async';
import 'package:flutter/material.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/cyber_workout_theme.dart';
import 'package:customer_mobile_app/src/features/auth/account_creation/presentation/screens/create_options_screen.dart';

class CyberSplashScreen extends StatefulWidget {
  const CyberSplashScreen({super.key, required this.isLoggedIn});

  final bool isLoggedIn;

  @override
  State<CyberSplashScreen> createState() => _CyberSplashScreenState();
}

class _CyberSplashScreenState extends State<CyberSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for logo & halo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Progress bar animation from 0 to 100%
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOutCubic),
    );

    _progressController.forward();

    // Transition after loading completes
    Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, anim, secAnim) => widget.isLoggedIn
                ? const DashboardScreen()
                : const CreateOptionsScreen(),
            transitionsBuilder: (context, anim, secAnim, child) {
              return FadeTransition(
                opacity: anim,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberWorkoutTheme.bgVoid,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Gradient Mesh
          Positioned(
            top: -100,
            right: -100,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        CyberWorkoutTheme.goldPrimary.withOpacity(0.15 * _glowAnimation.value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        CyberWorkoutTheme.crimsonRed.withOpacity(0.12 * _glowAnimation.value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Center Logo & Kinetic Glow Ring
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF13131C),
                          border: Border.all(
                            color: CyberWorkoutTheme.goldPrimary.withOpacity(0.8 * _glowAnimation.value),
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: CyberWorkoutTheme.goldPrimary.withOpacity(0.35 * _glowAnimation.value),
                              blurRadius: 28,
                              spreadRadius: 4,
                            ),
                            BoxShadow(
                              color: CyberWorkoutTheme.crimsonRed.withOpacity(0.25 * _glowAnimation.value),
                              blurRadius: 40,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/png/vectors/discipl_spell.png',
                            width: 85,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.fitness_center,
                              color: CyberWorkoutTheme.goldPrimary,
                              size: 50,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 36),

                // Brand Tagline
                const Text(
                  "DISCIPL",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4.0,
                  ),
                ),
                const SizedBox(height: 6),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "E L I T E   P E R F O R M A N C E",
                      style: TextStyle(
                        color: CyberWorkoutTheme.goldPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // Cyber Loading Progress Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 6,
                          width: double.infinity,
                          color: const Color(0xFF1E1E2C),
                          child: AnimatedBuilder(
                            animation: _progressAnimation,
                            builder: (context, child) {
                              return FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: _progressAnimation.value,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        CyberWorkoutTheme.crimsonRed,
                                        CyberWorkoutTheme.goldPrimary,
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          final int percent = (_progressAnimation.value * 100).toInt();
                          return Text(
                            "INITIALIZING $percent%",
                            style: const TextStyle(
                              color: CyberWorkoutTheme.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
