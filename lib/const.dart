import 'package:flutter/material.dart' show Color;

abstract class AppColors {
  static const Color secondaryColor = Color(0xFF015F9A);
  static const Color primaryColor = Color(0xFF00ADEE);
  static const Color accentNavy = Color(0xFF0A192F);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color surfaceBg = Color(0xFFF8FAFC);
  static const Color baltic = Color(0xFF006494);

  static const Color success = Color(0xFF159A62);
  static const Color danger = Color(0xFFE34D4D);
  static const Color muted = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color statusLead = Color(0xFFD97706); // Amber
  static const Color statusProspect = Color(0xFF2563EB); // Blue
  static const Color statusClient = Color(0xFF16A34A); // Green
  static const Color statusLapsed = Color(0xFFDC2626); // Red
  static const Color statusDraft = Color(0xFF64748B);
  static const Color statusSubmitted = Color(0xFF2563EB);
  static const Color statusUnderwriting = Color(0xFF7C3AED);
  static const Color statusCorrection = Color(0xFFEA580C);
  static const Color statusApproved = Color(0xFF16A34A);
  static const Color statusRejected = Color(0xFFDC2626);
  static const Color deep = Color(0xFF003554);
  static const Color cream = Color(0xFFECEEF2);
  static const Color paper = Color(0xFFFFFFFF);

  static const Color mint = Color(0xFF57C785);
  static const Color warn = Color(0xFFF59E0B);

  static Color deepAlpha(double opacity) => deep.withValues(alpha: opacity);
}

class AppRadii {
  AppRadii._();
  static const double card = 18;
  static const double button = 14;
  static const double sheet = 24;
  static const double pill = 999;
}
