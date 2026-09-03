import 'package:flutter/material.dart';

// ── Static color constants (used only in const contexts / theme registration) ──
abstract class AppColors {
  static const Color primaryColor = Color(0xFF00ADEE);
  static const Color secondaryColor = Color(0xFF015F9A);
  static const Color accentNavy = Color(0xFF0A192F);
  static const Color deep = Color(0xFF00ADEE);
  static const Color mint = Color(0xFF57C785);
  static const Color warn = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFE34D4D);
  static const Color muted = Color(0xFF64748B);
  static const Color baltic = Color(0xFF006494);
  static const Color cream = Color(0xFFECEEF2);
  static const Color paper = Color(0xFFFFFFFF);
  static const Color chipBg = Color(0xFFF1F5F9);
  static Color deepAlpha(double opacity) => deep.withValues(alpha: opacity);
}

// ── Convenience extension for accessing colors from BuildContext ──
extension BuildContextColors on BuildContext {
  AppColorsExtension get colors =>
      Theme.of(this).extension<AppColorsExtension>() ?? kAppColors;
}

// ── ThemeExtension ──
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentNavy,
    required this.goldAccent,
    required this.baltic,
    required this.deep,
    required this.mint,
    required this.surfaceBg,
    required this.cream,
    required this.paper,
    required this.chipBg,
    required this.sectionBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.muted,
    required this.border,
    required this.divider,
    required this.success,
    required this.successText,
    required this.successLight,
    required this.successAccent,
    required this.successAccentLight,
    required this.danger,
    required this.errorText,
    required this.errorLight,
    required this.warn,
    required this.warningText,
    required this.warningLight,
    required this.warningBorder,
    required this.infoText,
    required this.infoLight,
    required this.infoBorder,
    required this.statusLead,
    required this.statusProspect,
    required this.statusClient,
    required this.statusLapsed,
    required this.statusDraft,
    required this.statusSubmitted,
    required this.statusUnderwriting,
    required this.statusCorrection,
    required this.statusApproved,
    required this.statusRejected,
    required this.cyanAccent,
    required this.purpleAccent,
    required this.purpleLight,
    required this.roseAccent,
    required this.roseLight,
    required this.indigoAccent,
    required this.emeraldAccent,
    required this.emeraldLight,
    required this.online,
    required this.away,
  });

  final Color primaryColor;
  final Color secondaryColor;
  final Color accentNavy;
  final Color goldAccent;
  final Color baltic;
  final Color deep;
  final Color mint;
  final Color surfaceBg;
  final Color cream;
  final Color paper;
  final Color chipBg;
  final Color sectionBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color muted;
  final Color border;
  final Color divider;
  final Color success;
  final Color successText;
  final Color successLight;
  final Color successAccent;
  final Color successAccentLight;
  final Color danger;
  final Color errorText;
  final Color errorLight;
  final Color warn;
  final Color warningText;
  final Color warningLight;
  final Color warningBorder;
  final Color infoText;
  final Color infoLight;
  final Color infoBorder;
  final Color statusLead;
  final Color statusProspect;
  final Color statusClient;
  final Color statusLapsed;
  final Color statusDraft;
  final Color statusSubmitted;
  final Color statusUnderwriting;
  final Color statusCorrection;
  final Color statusApproved;
  final Color statusRejected;
  final Color cyanAccent;
  final Color purpleAccent;
  final Color purpleLight;
  final Color roseAccent;
  final Color roseLight;
  final Color indigoAccent;
  final Color emeraldAccent;
  final Color emeraldLight;
  final Color online;
  final Color away;

  Color deepAlpha(double opacity) => deep.withValues(alpha: opacity);

  @override
  AppColorsExtension copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    Color? accentNavy,
    Color? goldAccent,
    Color? baltic,
    Color? deep,
    Color? mint,
    Color? surfaceBg,
    Color? cream,
    Color? paper,
    Color? chipBg,
    Color? sectionBg,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? muted,
    Color? border,
    Color? divider,
    Color? success,
    Color? successText,
    Color? successLight,
    Color? successAccent,
    Color? successAccentLight,
    Color? danger,
    Color? errorText,
    Color? errorLight,
    Color? warn,
    Color? warningText,
    Color? warningLight,
    Color? warningBorder,
    Color? infoText,
    Color? infoLight,
    Color? infoBorder,
    Color? statusLead,
    Color? statusProspect,
    Color? statusClient,
    Color? statusLapsed,
    Color? statusDraft,
    Color? statusSubmitted,
    Color? statusUnderwriting,
    Color? statusCorrection,
    Color? statusApproved,
    Color? statusRejected,
    Color? cyanAccent,
    Color? purpleAccent,
    Color? purpleLight,
    Color? roseAccent,
    Color? roseLight,
    Color? indigoAccent,
    Color? emeraldAccent,
    Color? emeraldLight,
    Color? online,
    Color? away,
  }) {
    return AppColorsExtension(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      accentNavy: accentNavy ?? this.accentNavy,
      goldAccent: goldAccent ?? this.goldAccent,
      baltic: baltic ?? this.baltic,
      deep: deep ?? this.deep,
      mint: mint ?? this.mint,
      surfaceBg: surfaceBg ?? this.surfaceBg,
      cream: cream ?? this.cream,
      paper: paper ?? this.paper,
      chipBg: chipBg ?? this.chipBg,
      sectionBg: sectionBg ?? this.sectionBg,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      muted: muted ?? this.muted,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      success: success ?? this.success,
      successText: successText ?? this.successText,
      successLight: successLight ?? this.successLight,
      successAccent: successAccent ?? this.successAccent,
      successAccentLight: successAccentLight ?? this.successAccentLight,
      danger: danger ?? this.danger,
      errorText: errorText ?? this.errorText,
      errorLight: errorLight ?? this.errorLight,
      warn: warn ?? this.warn,
      warningText: warningText ?? this.warningText,
      warningLight: warningLight ?? this.warningLight,
      warningBorder: warningBorder ?? this.warningBorder,
      infoText: infoText ?? this.infoText,
      infoLight: infoLight ?? this.infoLight,
      infoBorder: infoBorder ?? this.infoBorder,
      statusLead: statusLead ?? this.statusLead,
      statusProspect: statusProspect ?? this.statusProspect,
      statusClient: statusClient ?? this.statusClient,
      statusLapsed: statusLapsed ?? this.statusLapsed,
      statusDraft: statusDraft ?? this.statusDraft,
      statusSubmitted: statusSubmitted ?? this.statusSubmitted,
      statusUnderwriting: statusUnderwriting ?? this.statusUnderwriting,
      statusCorrection: statusCorrection ?? this.statusCorrection,
      statusApproved: statusApproved ?? this.statusApproved,
      statusRejected: statusRejected ?? this.statusRejected,
      cyanAccent: cyanAccent ?? this.cyanAccent,
      purpleAccent: purpleAccent ?? this.purpleAccent,
      purpleLight: purpleLight ?? this.purpleLight,
      roseAccent: roseAccent ?? this.roseAccent,
      roseLight: roseLight ?? this.roseLight,
      indigoAccent: indigoAccent ?? this.indigoAccent,
      emeraldAccent: emeraldAccent ?? this.emeraldAccent,
      emeraldLight: emeraldLight ?? this.emeraldLight,
      online: online ?? this.online,
      away: away ?? this.away,
    );
  }

  @override
  AppColorsExtension lerp(AppColorsExtension? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t)!,
      secondaryColor: Color.lerp(secondaryColor, other.secondaryColor, t)!,
      accentNavy: Color.lerp(accentNavy, other.accentNavy, t)!,
      goldAccent: Color.lerp(goldAccent, other.goldAccent, t)!,
      baltic: Color.lerp(baltic, other.baltic, t)!,
      deep: Color.lerp(deep, other.deep, t)!,
      mint: Color.lerp(mint, other.mint, t)!,
      surfaceBg: Color.lerp(surfaceBg, other.surfaceBg, t)!,
      cream: Color.lerp(cream, other.cream, t)!,
      paper: Color.lerp(paper, other.paper, t)!,
      chipBg: Color.lerp(chipBg, other.chipBg, t)!,
      sectionBg: Color.lerp(sectionBg, other.sectionBg, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      success: Color.lerp(success, other.success, t)!,
      successText: Color.lerp(successText, other.successText, t)!,
      successLight: Color.lerp(successLight, other.successLight, t)!,
      successAccent: Color.lerp(successAccent, other.successAccent, t)!,
      successAccentLight: Color.lerp(
        successAccentLight,
        other.successAccentLight,
        t,
      )!,
      danger: Color.lerp(danger, other.danger, t)!,
      errorText: Color.lerp(errorText, other.errorText, t)!,
      errorLight: Color.lerp(errorLight, other.errorLight, t)!,
      warn: Color.lerp(warn, other.warn, t)!,
      warningText: Color.lerp(warningText, other.warningText, t)!,
      warningLight: Color.lerp(warningLight, other.warningLight, t)!,
      warningBorder: Color.lerp(warningBorder, other.warningBorder, t)!,
      infoText: Color.lerp(infoText, other.infoText, t)!,
      infoLight: Color.lerp(infoLight, other.infoLight, t)!,
      infoBorder: Color.lerp(infoBorder, other.infoBorder, t)!,
      statusLead: Color.lerp(statusLead, other.statusLead, t)!,
      statusProspect: Color.lerp(statusProspect, other.statusProspect, t)!,
      statusClient: Color.lerp(statusClient, other.statusClient, t)!,
      statusLapsed: Color.lerp(statusLapsed, other.statusLapsed, t)!,
      statusDraft: Color.lerp(statusDraft, other.statusDraft, t)!,
      statusSubmitted: Color.lerp(statusSubmitted, other.statusSubmitted, t)!,
      statusUnderwriting: Color.lerp(
        statusUnderwriting,
        other.statusUnderwriting,
        t,
      )!,
      statusCorrection: Color.lerp(
        statusCorrection,
        other.statusCorrection,
        t,
      )!,
      statusApproved: Color.lerp(statusApproved, other.statusApproved, t)!,
      statusRejected: Color.lerp(statusRejected, other.statusRejected, t)!,
      cyanAccent: Color.lerp(cyanAccent, other.cyanAccent, t)!,
      purpleAccent: Color.lerp(purpleAccent, other.purpleAccent, t)!,
      purpleLight: Color.lerp(purpleLight, other.purpleLight, t)!,
      roseAccent: Color.lerp(roseAccent, other.roseAccent, t)!,
      roseLight: Color.lerp(roseLight, other.roseLight, t)!,
      indigoAccent: Color.lerp(indigoAccent, other.indigoAccent, t)!,
      emeraldAccent: Color.lerp(emeraldAccent, other.emeraldAccent, t)!,
      emeraldLight: Color.lerp(emeraldLight, other.emeraldLight, t)!,
      online: Color.lerp(online, other.online, t)!,
      away: Color.lerp(away, other.away, t)!,
    );
  }
}

// ── Default color values ──
abstract class _Defaults {
  static const Color primaryColor = Color(0xFF00ADEE);
  // navy -> 0B54B8 lightBlue -> 00ADEE  darkBlue -> 015F9A
  static const Color secondaryColor = Color(0xFF0B54B8);
  static const Color accentNavy = Color(0xFF0A192F);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color baltic = Color(0xFF006494);
  static const Color deep = Color(0xFF003554);
  static const Color mint = Color(0xFF57C785);
  static const Color surfaceBg = Color(0xFFECEEF2);
  static const Color cream = Color(0xFFECEEF2);
  static const Color paper = Color(0xFFFFFFFF);
  static const Color chipBg = Color(0xFFF1F5F9);
  static const Color sectionBg = Color(0xFFF8F9FA);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF334155);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color muted = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color success = Color(0xFF159A62);
  static const Color successText = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color successAccent = Color(0xFF16A34A);
  static const Color successAccentLight = Color(0xFFDCFCE7);
  static const Color danger = Color(0xFFE34D4D);
  static const Color errorText = Color(0xFFC62828);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color warn = Color(0xFFF59E0B);
  static const Color warningText = Color(0xFFF97316);
  static const Color warningLight = Color(0xFFFFF7ED);
  static const Color warningBorder = Color(0xFFFFEDD5);
  static const Color infoText = Color(0xFF2563EB);
  static const Color infoLight = Color(0xFFEFF6FF);
  static const Color infoBorder = Color(0xFFBFDBFE);
  static const Color statusLead = Color(0xFFD97706);
  static const Color statusProspect = Color(0xFF2563EB);
  static const Color statusClient = Color(0xFF16A34A);
  static const Color statusLapsed = Color(0xFFDC2626);
  static const Color statusDraft = Color(0xFF64748B);
  static const Color statusSubmitted = Color(0xFF2563EB);
  static const Color statusUnderwriting = Color(0xFF7C3AED);
  static const Color statusCorrection = Color(0xFFEA580C);
  static const Color statusApproved = Color(0xFF16A34A);
  static const Color statusRejected = Color(0xFFDC2626);
  static const Color cyanAccent = Color(0xFFE0F7FA);
  static const Color purpleAccent = Color(0xFF9333EA);
  static const Color purpleLight = Color(0xFFF3E8FF);
  static const Color roseAccent = Color(0xFFE11D48);
  static const Color roseLight = Color(0xFFFFE4E6);
  static const Color indigoAccent = Color(0xFF6366F1);
  static const Color emeraldAccent = Color(0xFF10B981);
  static const Color emeraldLight = Color(0xFFECFDF5);
  static const Color online = Color(0xFF4CAF50);
  static const Color away = Color(0xFFFF9800);
}

const AppColorsExtension kAppColors = AppColorsExtension(
  primaryColor: _Defaults.primaryColor,
  secondaryColor: _Defaults.secondaryColor,
  accentNavy: _Defaults.accentNavy,
  goldAccent: _Defaults.goldAccent,
  baltic: _Defaults.baltic,
  deep: _Defaults.deep,
  mint: _Defaults.mint,
  surfaceBg: _Defaults.surfaceBg,
  cream: _Defaults.cream,
  paper: _Defaults.paper,
  chipBg: _Defaults.chipBg,
  sectionBg: _Defaults.sectionBg,
  textPrimary: _Defaults.textPrimary,
  textSecondary: _Defaults.textSecondary,
  textMuted: _Defaults.textMuted,
  muted: _Defaults.muted,
  border: _Defaults.border,
  divider: _Defaults.divider,
  success: _Defaults.success,
  successText: _Defaults.successText,
  successLight: _Defaults.successLight,
  successAccent: _Defaults.successAccent,
  successAccentLight: _Defaults.successAccentLight,
  danger: _Defaults.danger,
  errorText: _Defaults.errorText,
  errorLight: _Defaults.errorLight,
  warn: _Defaults.warn,
  warningText: _Defaults.warningText,
  warningLight: _Defaults.warningLight,
  warningBorder: _Defaults.warningBorder,
  infoText: _Defaults.infoText,
  infoLight: _Defaults.infoLight,
  infoBorder: _Defaults.infoBorder,
  statusLead: _Defaults.statusLead,
  statusProspect: _Defaults.statusProspect,
  statusClient: _Defaults.statusClient,
  statusLapsed: _Defaults.statusLapsed,
  statusDraft: _Defaults.statusDraft,
  statusSubmitted: _Defaults.statusSubmitted,
  statusUnderwriting: _Defaults.statusUnderwriting,
  statusCorrection: _Defaults.statusCorrection,
  statusApproved: _Defaults.statusApproved,
  statusRejected: _Defaults.statusRejected,
  cyanAccent: _Defaults.cyanAccent,
  purpleAccent: _Defaults.purpleAccent,
  purpleLight: _Defaults.purpleLight,
  roseAccent: _Defaults.roseAccent,
  roseLight: _Defaults.roseLight,
  indigoAccent: _Defaults.indigoAccent,
  emeraldAccent: _Defaults.emeraldAccent,
  emeraldLight: _Defaults.emeraldLight,
  online: _Defaults.online,
  away: _Defaults.away,
);

class AppRadii {
  AppRadii._();
  static const double card = 18;
  static const double button = 14;
  static const double sheet = 24;
  static const double pill = 999;
}

// ── Responsive icon sizes ──
class AppIconSizes {
  AppIconSizes._();

  // Base sizes (for ~375px width - iPhone SE)
  static const double _xs = 10;
  static const double _sm = 12;
  static const double _md = 14;
  static const double _base = 16;
  static const double _lg = 18;
  static const double _xl = 20;
  static const double _xxl = 22;
  static const double _xxxl = 24;
  static const double _fourXl = 28;
  static const double _fiveXl = 32;
  static const double _sixXl = 40;
  static const double _sevenXl = 48;
  static const double _eightXl = 90;

  /// Get responsive size based on screen width
  static double responsive(BuildContext context, double baseSize) {
    final width = MediaQuery.sizeOf(context).width;
    final scale = width / 375; // 375 = iPhone SE baseline
    return baseSize * scale;
  }

  static double xs(BuildContext context) => responsive(context, _xs);
  static double sm(BuildContext context) => responsive(context, _sm);
  static double md(BuildContext context) => responsive(context, _md);
  static double base(BuildContext context) => responsive(context, _base);
  static double lg(BuildContext context) => responsive(context, _lg);
  static double xl(BuildContext context) => responsive(context, _xl);
  static double xxl(BuildContext context) => responsive(context, _xxl);
  static double xxxl(BuildContext context) => responsive(context, _xxxl);
  static double fourXl(BuildContext context) => responsive(context, _fourXl);
  static double fiveXl(BuildContext context) => responsive(context, _fiveXl);
  static double sixXl(BuildContext context) => responsive(context, _sixXl);
  static double sevenXl(BuildContext context) => responsive(context, _sevenXl);
  static double eightXl(BuildContext context) => responsive(context, _eightXl);
}

extension IconSizeX on BuildContext {
  double get iconXs => AppIconSizes.xs(this);
  double get iconSm => AppIconSizes.sm(this);
  double get iconMd => AppIconSizes.md(this);
  double get iconBase => AppIconSizes.base(this);
  double get iconLg => AppIconSizes.lg(this);
  double get iconXl => AppIconSizes.xl(this);
  double get iconXxl => AppIconSizes.xxl(this);
  double get iconXxxl => AppIconSizes.xxxl(this);
  double get icon4xl => AppIconSizes.fourXl(this);
  double get icon5xl => AppIconSizes.fiveXl(this);
  double get icon6xl => AppIconSizes.sixXl(this);
  double get icon7xl => AppIconSizes.sevenXl(this);
  double get icon8xl => AppIconSizes.eightXl(this);
}
