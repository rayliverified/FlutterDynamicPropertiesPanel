/// Soft SaaS UI Design Tokens
///
/// This file contains all design tokens extracted from the React/TypeScript
/// soft_saas_ui design system. These tokens ensure visual consistency across
/// all components.
library;

import 'package:flutter/material.dart';

/// Design tokens for the Soft SaaS UI design system
class SoftSaaSTokens {
  SoftSaaSTokens._();

  // ══════════════════════════════════════════════════════════════════════
  // COLOR PALETTE
  // ══════════════════════════════════════════════════════════════════════

  /// Light mode colors
  static const lightPrimaryBackground = Color(0xFFFFFFFF);
  static const lightSecondaryBackground = Color(0xFFF9FAFB); // gray-50
  static const lightTertiaryBackground = Color(0xFFF3F4F6); // gray-100

  static const lightPrimaryText = Color(0xFF111827); // gray-900
  static const lightSecondaryText = Color(0xFF4B5563); // gray-600
  static const lightTertiaryText = Color(0xFF9CA3AF); // gray-400

  static const lightPrimaryBorder = Color(0xFFE5E7EB); // gray-200
  static const lightSecondaryBorder = Color(0xFFD1D5DB); // gray-300

  /// Dark mode colors
  static const darkPrimaryBackground = Color(0xFF141414); // neutral-900
  static const darkSecondaryBackground = Color(0xFF1C1C1C); // neutral-800
  static const darkTertiaryBackground = Color(0xFF383838); // neutral-700

  static const darkPrimaryText = Color(0xFFFFFFFF);
  static const darkSecondaryText = Color(0x99FFFFFF); // white/60
  static const darkTertiaryText = Color(0x66FFFFFF); // white/40

  static const darkPrimaryBorder = Color(0xFF383838); // neutral-700
  static const darkSecondaryBorder = Color(0xFF4A4A4A); // neutral-600

  /// Semantic colors (same for light and dark, context determines usage)
  static const primary = Color(0xFF2563EB); // blue-600
  static const primaryDark = Color(0xFF3B82F6); // blue-500

  static const success = Color(0xFF16A34A); // green-600
  static const successDark = Color(0xFF22C55E); // green-500

  // Orange/amber is intentionally excluded from the palette — warnings use the
  // brand blue (warning style must never be yellow/orange).
  static const warning = Color(0xFF2563EB); // blue-600 (was orange-600)
  static const warningDark = Color(0xFF3B82F6); // blue-500 (was orange-500)

  static const error = Color(0xFFDC2626); // red-600
  static const errorDark = Color(0xFFEF4444); // red-500

  static const info = Color(0xFF0891B2); // cyan-600
  static const infoDark = Color(0xFF06B6D4); // cyan-500

  static const purple = Color(0xFF9333EA); // purple-600
  static const purpleDark = Color(0xFFA855F7); // purple-500

  /// Gray scale (used across light/dark modes)
  static const gray700 = Color(0xFF374151);
  static const gray800 = Color(0xFF1F2937);
  static const gray600 = Color(0xFF4B5563);
  static const gray500 = Color(0xFF6B7280);
  static const gray400 = Color(0xFF9CA3AF);
  static const gray300 = Color(0xFFD1D5DB);
  static const gray200 = Color(0xFFE5E7EB);
  static const gray100 = Color(0xFFF3F4F6);
  static const gray50 = Color(0xFFF9FAFB);
  static const gray900 = Color(0xFF111827);

  // ══════════════════════════════════════════════════════════════════════
  // BORDER RADIUS
  // ══════════════════════════════════════════════════════════════════════

  static const radiusSmall = 2.0; // sm - square elements
  static const radiusMedium = 6.0; // md - badges, small elements
  static const radiusLarge = 8.0; // lg - buttons
  static const radiusXLarge = 12.0; // xl - inputs, cards
  static const radius2XLarge = 16.0; // 2xl - modals, large cards
  static const radius3XLarge = 24.0; // 3xl - containers
  static const radiusFull = 9999.0; // full - pills, circles

  // ══════════════════════════════════════════════════════════════════════
  // SPACING (8px Grid System)
  // ══════════════════════════════════════════════════════════════════════

  static const spacing1 = 4.0;
  static const spacing2 = 8.0;
  static const spacing3 = 12.0;
  static const spacing4 = 16.0;
  static const spacing5 = 20.0;
  static const spacing6 = 24.0;
  static const spacing8 = 32.0;
  static const spacing10 = 40.0;
  static const spacing12 = 48.0;
  static const spacing16 = 64.0;

  // ══════════════════════════════════════════════════════════════════════
  // TYPOGRAPHY
  // ══════════════════════════════════════════════════════════════════════

  /// Intentionally null — Soft SaaS UI defers to the platform default font
  /// (SF Pro on Apple platforms, Segoe UI on Windows, Roboto on Android /
  /// Linux). Leaving this unset on a `TextStyle.fontFamily` lets the ambient
  /// theme / platform decide.
  static const String? fontFamilyBase = null;

  // Font sizes (matching Tailwind text-* classes)
  static const fontSize3XL = 30.0; // text-3xl
  static const fontSize2XL = 24.0; // text-2xl
  static const fontSizeXL = 20.0; // text-xl
  static const fontSizeLG = 18.0; // text-lg
  static const fontSizeMD = 16.0; // text-md (base)
  static const fontSizeSM = 14.0; // text-sm
  static const fontSizeXS = 12.0; // text-xs

  // Font weights
  static const fontWeightNormal = FontWeight.w400; // normal
  static const fontWeightMedium = FontWeight.w500; // medium
  static const fontWeightSemibold = FontWeight.w600; // semibold
  static const fontWeightBold = FontWeight.w700; // bold

  // Line heights
  static const lineHeightCompact = 1.2;
  static const lineHeightNormal = 1.5;
  static const lineHeightRelaxed = 1.75;

  // ══════════════════════════════════════════════════════════════════════
  // TRANSITIONS & ANIMATIONS
  // ══════════════════════════════════════════════════════════════════════

  static const transitionDuration = Duration(milliseconds: 200);
  static const transitionCurve = Curves.easeInOut;

  // Scale values for interactions
  static const scaleHoverStandard = 1.05;
  static const scaleActiveStandard = 0.95;
  static const scaleHoverSubtle = 1.02;
  static const scaleActiveSubtle = 0.98;

  // ══════════════════════════════════════════════════════════════════════
  // OPACITY VALUES
  // ══════════════════════════════════════════════════════════════════════

  static const opacityDisabled = 0.5;
  static const opacityHoverLight = 0.05;
  static const opacityHoverDark = 0.10;
  static const opacityPressed = 0.80;

  // Inset highlight opacities
  static const opacityInsetHighlightLight = 0.1;
  static const opacityInsetHighlightDark = 0.04;
  static const opacityInsetShadowLight = 0.02;
  static const opacityInsetShadowDark = 0.1;

  // ══════════════════════════════════════════════════════════════════════
  // ICON SIZES
  // ══════════════════════════════════════════════════════════════════════

  static const iconSizeSmall = 14.0;
  static const iconSizeMedium = 16.0;
  static const iconSizeLarge = 18.0;
  static const iconSizeXL = 24.0;

  // ══════════════════════════════════════════════════════════════════════
  // BUTTON SIZES
  // ══════════════════════════════════════════════════════════════════════

  static const buttonPaddingSmall = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 4,
  );
  static const buttonPaddingMedium = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
  );
  static const buttonPaddingLarge = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 8,
  );

  // ══════════════════════════════════════════════════════════════════════
  // BADGE SIZES
  // ══════════════════════════════════════════════════════════════════════

  static const badgePaddingSmall = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 2,
  );
  static const badgePaddingMedium = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 2,
  );
  static const badgePaddingLarge = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 4,
  );

  // ══════════════════════════════════════════════════════════════════════
  // CARD PADDING
  // ══════════════════════════════════════════════════════════════════════

  static const cardPaddingNone = EdgeInsets.zero;
  static const cardPaddingSmall = EdgeInsets.all(12);
  static const cardPaddingMedium = EdgeInsets.all(16);
  static const cardPaddingLarge = EdgeInsets.all(24);

  // ══════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ══════════════════════════════════════════════════════════════════════

  /// Get primary background color based on theme brightness
  static Color primaryBackground(Brightness brightness) {
    return brightness == Brightness.light
        ? lightPrimaryBackground
        : darkPrimaryBackground;
  }

  /// Get secondary background color based on theme brightness
  static Color secondaryBackground(Brightness brightness) {
    return brightness == Brightness.light
        ? lightSecondaryBackground
        : darkSecondaryBackground;
  }

  /// Get tertiary background color based on theme brightness
  static Color tertiaryBackground(Brightness brightness) {
    return brightness == Brightness.light
        ? lightTertiaryBackground
        : darkTertiaryBackground;
  }

  /// Get primary text color based on theme brightness
  static Color primaryText(Brightness brightness) {
    return brightness == Brightness.light ? lightPrimaryText : darkPrimaryText;
  }

  /// Get secondary text color based on theme brightness
  static Color secondaryText(Brightness brightness) {
    return brightness == Brightness.light
        ? lightSecondaryText
        : darkSecondaryText;
  }

  /// Get tertiary text color based on theme brightness
  static Color tertiaryText(Brightness brightness) {
    return brightness == Brightness.light
        ? lightTertiaryText
        : darkTertiaryText;
  }

  /// Get primary border color based on theme brightness
  static Color primaryBorder(Brightness brightness) {
    return brightness == Brightness.light
        ? lightPrimaryBorder
        : darkPrimaryBorder;
  }

  /// Get secondary border color based on theme brightness
  static Color secondaryBorder(Brightness brightness) {
    return brightness == Brightness.light
        ? lightSecondaryBorder
        : darkSecondaryBorder;
  }

  /// Get semantic color for the given brightness
  static Color primaryColor(Brightness brightness) {
    return brightness == Brightness.light ? primary : primaryDark;
  }

  static Color successColor(Brightness brightness) {
    return brightness == Brightness.light ? success : successDark;
  }

  static Color warningColor(Brightness brightness) {
    return brightness == Brightness.light ? warning : warningDark;
  }

  static Color errorColor(Brightness brightness) {
    return brightness == Brightness.light ? error : errorDark;
  }

  static Color infoColor(Brightness brightness) {
    return brightness == Brightness.light ? info : infoDark;
  }

  static Color purpleColor(Brightness brightness) {
    return brightness == Brightness.light ? purple : purpleDark;
  }

  // ══════════════════════════════════════════════════════════════════════
  // CONTROL STATE HELPERS
  // ══════════════════════════════════════════════════════════════════════

  /// Neutral hover overlay for input-like affordances (chevrons, toolbar
  /// buttons, picker cells, menu rows). **Never blue** — hover is neutral.
  /// Use this over any non-selected surface to indicate hover.
  static Color controlHoverOverlay(Brightness brightness) {
    return brightness == Brightness.light
        ? const Color(0x0A000000) // black 4%
        : const Color(0x14FFFFFF); // white 8%
  }

  /// Active / selected tint used for selected dropdown items, pressed
  /// toolbar buttons, engaged locks. Matches `SoftSaaSDropdown` selected
  /// state: primaryColor @ 14% (light) / 22% (dark).
  static Color controlActiveTint(Brightness brightness) {
    final base = primaryColor(brightness);
    return base.withValues(alpha: brightness == Brightness.light ? 0.14 : 0.22);
  }

  // ══════════════════════════════════════════════════════════════════════
  // ADDITIONAL COLORS
  // ══════════════════════════════════════════════════════════════════════

  /// Additional gray scale colors
  static const gray850 = Color(0xFF1A1A1A); // between neutral800 and neutral900

  /// Primary color variants (blue)
  static const primary400 = Color(0xFF60A5FA); // blue-400
  static const primary500 = Color(0xFF3B82F6); // blue-500
  static const primary600 = Color(0xFF2563EB); // blue-600 (same as primary)

  /// Success color variants (green)
  static const success500 = Color(0xFF22C55E); // green-500
  static const success600 = Color(0xFF16A34A); // green-600 (same as success)
}
