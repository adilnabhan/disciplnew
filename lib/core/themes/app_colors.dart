import 'package:flutter/material.dart';

/// App Color Palette adhering to the Discipl Cyber Sport (Red, Black & Cyber Gold) Theme
@immutable
abstract class AppColors {
  // Brand & High-Octane Cyber Accents
  static const Color primary = Color(0xFFFFDE03); // Cyber Yellow / Gold
  static const Color lightPrimary = Color(0x33FFDE03); // Translucent Cyber Gold
  static const Color secondary = Color(0xFFFFD700); // Electric Gold
  static const Color accent = Color(0xFFFF334B); // Crimson Red (Target Muscle / Strain)
  static const Color brandRed = Color(0xFFE50914); // Discipl Core Red
  static const Color neonGreen = Color(0xFF00E676); // High Vitality Green
  static const Color restBlue = Color(0xFF4A90E2); // Recovery Rest Blue
  
  // Surfaces & Backgrounds (Deep Dark / Glassmorphism)
  static const Color dark = Color(0xFF0D0D11); // Deep OLED Black
  static const Color light = Color(0xFFFFFFFF); // High Contrast White
  static const Color bgcolorgrey = Color(0xFF0D0D11); // Main Background Dark Void
  static const Color surfaceWarm = Color(0xFF16161D); // Primary Card Glass Surface
  static const Color fieldFillColor = Color(0xFF1C1C24); // Elevated Container Surface
  static const Color cardElevated = Color(0xFF22222E);

  // Buttons & Interactions
  static const Color button = Color(0xFFFFDE03); // Gold CTA Button
  static const Color buttonText = Color(0xFF000000); // Black text on Gold Button
  static const Color disabledButton = Color(0xFF2D2D3A);
  static const Color error = Color(0xFFFF3434);
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFDE03);
  static const Color grey = Color(0xFF262633);

  // Typography & Borders
  static const Color textDark = Color(0xFFFFFFFF); // Primary White Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFF9E9EB2); // Secondary Silver Text
  static const Color textMuted = Color(0xFF62627A); // Muted Meta Text
  static const Color borderGrey = Color(0xFF2A2A38); // Subtle 1px Border
  static const Color borderGold = Color(0x66FFDE03); // Glowing Gold Border
  static const Color borderRed = Color(0x66FF334B); // Glowing Red Border
  static const Color iconBackground = Color(0xFF242432);
  static const Color lightGrey = Color(0xFF1F1F2B);
}
