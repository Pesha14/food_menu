import 'package:flutter/material.dart';

class AppTokens {
  static const Color bg = Color(0xFF0B1220);
  static const Color surface = Color(0xFF111C2E);
  static const Color surfaceLight = Color(0xFF1A2940);
  static const Color gold = Color(0xFFC9A24C);
  static const Color goldAccent = Color(0xFFE8C878);
  static const Color goldDark = Color(0xFFA8883A);
  static const Color ivory = Color(0xFFF5F1E6);
  static const Color mutedText = Color(0xFF9AA3B2);
  static const Color success = Color(0xFF4CAF77);
  static const Color danger = Color(0xFFE76F51);
  static const Color cardBorder = Color(0xFF2A3A52);

  static LinearGradient get goldGradient => const LinearGradient(
    colors: [gold, goldAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxDecoration get cardDecoration => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: cardBorder, width: 0.5),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.3),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static const double cardRadius = 16.0;
  static const double smallRadius = 8.0;
}
