import 'package:flutter/material.dart';

/// Cyber-Sport Theme Tokens (Red, Deep Black & Cyber Gold)
class CyberWorkoutTheme {
  // Backgrounds
  static const Color bgVoid = Color(0xFF0D0D11);
  static const Color bgSurface = Color(0xFF16161D);
  static const Color bgSurfaceElevated = Color(0xFF20202A);
  static const Color bgCardGlass = Color(0xFF1C1C24);

  // Brand Accents
  static const Color goldPrimary = Color(0xFFFFDE03); // Cyber Yellow / Gold
  static const Color goldAccent = Color(0xFFFFD700);
  static const Color crimsonRed = Color(0xFFFF334B); // Target Muscle / Strain
  static const Color deepCrimson = Color(0xFFE50914);
  static const Color neonGreen = Color(0xFF00E676);
  static const Color restBlue = Color(0xFF4A90E2);

  // Borders & Dividers
  static const Color borderSubtle = Color(0xFF2A2A38);
  static const Color borderGold = Color(0x66FFDE03);
  static const Color borderRed = Color(0x66FF334B);

  // Typography Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9E9EB2);
  static const Color textMuted = Color(0xFF62627A);
  static const Color textGold = Color(0xFFFFDE03);

  // Box Decorations
  static BoxDecoration glassCard({
    Color? borderColor,
    double radius = 16.0,
    bool glow = false,
    Color glowColor = goldPrimary,
  }) {
    return BoxDecoration(
      color: bgCardGlass,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? borderSubtle,
        width: 1.0,
      ),
      boxShadow: glow
          ? [
              BoxShadow(
                color: glowColor.withOpacity(0.18),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ]
          : null,
    );
  }

  static BoxDecoration goldButtonDeco({double radius = 12.0}) {
    return BoxDecoration(
      color: goldPrimary,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: goldPrimary.withOpacity(0.35),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
