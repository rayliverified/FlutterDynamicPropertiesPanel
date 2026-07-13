/// Typography System for Soft SaaS UI
///
/// This file defines the typography styles used throughout the Soft SaaS UI
/// design system, matching the React/TypeScript implementation.
library;

import 'package:flutter/material.dart';
import 'design_tokens.dart';

/// Typography styles for Soft SaaS UI
class SoftSaaSTypography {
  SoftSaaSTypography._();

  // ══════════════════════════════════════════════════════════════════════
  // TEXT STYLES
  // ══════════════════════════════════════════════════════════════════════

  /// Main title/headline (text-3xl font-bold)
  static TextStyle heading1(Brightness brightness) => TextStyle(
    fontFamily: SoftSaaSTokens.fontFamilyBase,
    fontSize: SoftSaaSTokens.fontSize3XL,
    fontWeight: SoftSaaSTokens.fontWeightBold,
    color: SoftSaaSTokens.primaryText(brightness),
  );

  /// Large heading (text-2xl font-bold)
  static TextStyle heading2(Brightness brightness) => TextStyle(
    fontFamily: SoftSaaSTokens.fontFamilyBase,
    fontSize: SoftSaaSTokens.fontSize2XL,
    fontWeight: SoftSaaSTokens.fontWeightBold,
    color: SoftSaaSTokens.primaryText(brightness),
  );

  /// Section headers (text-lg font-semibold)
  static TextStyle heading3(Brightness brightness) => TextStyle(
    fontFamily: SoftSaaSTokens.fontFamilyBase,
    fontSize: SoftSaaSTokens.fontSizeLG,
    fontWeight: SoftSaaSTokens.fontWeightSemibold,
    color: SoftSaaSTokens.primaryText(brightness),
  );

  /// Card titles (text-md font-semibold)
  static TextStyle heading4(Brightness brightness) => TextStyle(
    fontFamily: SoftSaaSTokens.fontFamilyBase,
    fontSize: SoftSaaSTokens.fontSizeMD,
    fontWeight: SoftSaaSTokens.fontWeightSemibold,
    color: SoftSaaSTokens.primaryText(brightness),
  );

  /// Button text / field labels (text-sm font-semibold)
  static TextStyle heading5(Brightness brightness) => TextStyle(
    fontFamily: SoftSaaSTokens.fontFamilyBase,
    fontSize: SoftSaaSTokens.fontSizeSM,
    fontWeight: SoftSaaSTokens.fontWeightSemibold,
    color: SoftSaaSTokens.primaryText(brightness),
  );

  /// Badge/small text (text-xs font-medium)
  static TextStyle heading6(Brightness brightness) => TextStyle(
    fontFamily: SoftSaaSTokens.fontFamilyBase,
    fontSize: SoftSaaSTokens.fontSizeXS,
    fontWeight: SoftSaaSTokens.fontWeightMedium,
    color: SoftSaaSTokens.primaryText(brightness),
  );

  // ══════════════════════════════════════════════════════════════════════
  // BODY TEXT STYLES
  // ══════════════════════════════════════════════════════════════════════

  /// Large body text (text-base)
  static TextStyle bodyLarge(Brightness brightness) => TextStyle(
    fontFamily: SoftSaaSTokens.fontFamilyBase,
    fontSize: SoftSaaSTokens.fontSizeMD,
    fontWeight: SoftSaaSTokens.fontWeightNormal,
    color: SoftSaaSTokens.primaryText(brightness),
  );

  /// Standard body text (text-sm)
  static TextStyle bodyMedium(Brightness brightness) => TextStyle(
    fontFamily: SoftSaaSTokens.fontFamilyBase,
    fontSize: SoftSaaSTokens.fontSizeSM,
    fontWeight: SoftSaaSTokens.fontWeightNormal,
    color: SoftSaaSTokens.primaryText(brightness),
  );

  /// Small body text (text-xs)
  static TextStyle bodySmall(Brightness brightness) => TextStyle(
    fontFamily: SoftSaaSTokens.fontFamilyBase,
    fontSize: SoftSaaSTokens.fontSizeXS,
    fontWeight: SoftSaaSTokens.fontWeightNormal,
    color: SoftSaaSTokens.primaryText(brightness),
  );

  // ══════════════════════════════════════════════════════════════════════
  // SECONDARY TEXT STYLES
  // ══════════════════════════════════════════════════════════════════════

  /// Secondary large body text
  static TextStyle bodyLargeSecondary(Brightness brightness) => TextStyle(
    fontFamily: SoftSaaSTokens.fontFamilyBase,
    fontSize: SoftSaaSTokens.fontSizeMD,
    fontWeight: SoftSaaSTokens.fontWeightNormal,
    color: SoftSaaSTokens.secondaryText(brightness),
  );

  /// Secondary standard body text
  static TextStyle bodyMediumSecondary(Brightness brightness) => TextStyle(
    fontFamily: SoftSaaSTokens.fontFamilyBase,
    fontSize: SoftSaaSTokens.fontSizeSM,
    fontWeight: SoftSaaSTokens.fontWeightNormal,
    color: SoftSaaSTokens.secondaryText(brightness),
  );

  /// Secondary small body text
  static TextStyle bodySmallSecondary(Brightness brightness) => TextStyle(
    fontFamily: SoftSaaSTokens.fontFamilyBase,
    fontSize: SoftSaaSTokens.fontSizeXS,
    fontWeight: SoftSaaSTokens.fontWeightNormal,
    color: SoftSaaSTokens.secondaryText(brightness),
  );

  // ══════════════════════════════════════════════════════════════════════
  // TERTIARY TEXT STYLES
  // ══════════════════════════════════════════════════════════════════════

  /// Tertiary body text (placeholders, disabled text)
  static TextStyle bodyMediumTertiary(Brightness brightness) => TextStyle(
    fontFamily: SoftSaaSTokens.fontFamilyBase,
    fontSize: SoftSaaSTokens.fontSizeSM,
    fontWeight: SoftSaaSTokens.fontWeightNormal,
    color: SoftSaaSTokens.tertiaryText(brightness),
  );

  /// Tertiary small text
  static TextStyle bodySmallTertiary(Brightness brightness) => TextStyle(
    fontFamily: SoftSaaSTokens.fontFamilyBase,
    fontSize: SoftSaaSTokens.fontSizeXS,
    fontWeight: SoftSaaSTokens.fontWeightNormal,
    color: SoftSaaSTokens.tertiaryText(brightness),
  );

  // ══════════════════════════════════════════════════════════════════════
  // BUTTON TEXT STYLES
  // ══════════════════════════════════════════════════════════════════════

  /// Button text small (text-xs)
  static TextStyle buttonSmall(Color textColor) => TextStyle(
    fontFamily: SoftSaaSTokens.fontFamilyBase,
    fontSize: SoftSaaSTokens.fontSizeXS,
    fontWeight: SoftSaaSTokens.fontWeightMedium,
    color: textColor,
  );

  /// Button text medium (text-xs) - default
  static TextStyle buttonMedium(Color textColor) => TextStyle(
    fontFamily: SoftSaaSTokens.fontFamilyBase,
    fontSize: SoftSaaSTokens.fontSizeXS,
    fontWeight: SoftSaaSTokens.fontWeightMedium,
    color: textColor,
  );

  /// Button text large (text-sm)
  static TextStyle buttonLarge(Color textColor) => TextStyle(
    fontFamily: SoftSaaSTokens.fontFamilyBase,
    fontSize: SoftSaaSTokens.fontSizeSM,
    fontWeight: SoftSaaSTokens.fontWeightMedium,
    color: textColor,
  );

  // ══════════════════════════════════════════════════════════════════════
  // LABEL TEXT STYLES
  // ══════════════════════════════════════════════════════════════════════

  /// Form label (text-sm font-medium)
  static TextStyle label(Brightness brightness) => TextStyle(
    fontFamily: SoftSaaSTokens.fontFamilyBase,
    fontSize: SoftSaaSTokens.fontSizeSM,
    fontWeight: SoftSaaSTokens.fontWeightMedium,
    color: SoftSaaSTokens.primaryText(brightness),
  );

  /// Medium label helper to align with Material naming (alias for [label]).
  static TextStyle labelMedium(Brightness brightness) => label(brightness);

  /// Small label (text-xs font-medium)
  static TextStyle labelSmall(Brightness brightness) => TextStyle(
    fontFamily: SoftSaaSTokens.fontFamilyBase,
    fontSize: SoftSaaSTokens.fontSizeXS,
    fontWeight: SoftSaaSTokens.fontWeightMedium,
    color: SoftSaaSTokens.secondaryText(brightness),
  );

  // ══════════════════════════════════════════════════════════════════════
  // BADGE TEXT STYLES
  // ══════════════════════════════════════════════════════════════════════

  /// Badge text small (text-xs)
  static TextStyle badgeSmall(Color textColor) => TextStyle(
    fontFamily: SoftSaaSTokens.fontFamilyBase,
    fontSize: SoftSaaSTokens.fontSizeXS,
    fontWeight: SoftSaaSTokens.fontWeightMedium,
    color: textColor,
  );

  /// Badge text medium (text-xs)
  static TextStyle badgeMedium(Color textColor) => TextStyle(
    fontFamily: SoftSaaSTokens.fontFamilyBase,
    fontSize: SoftSaaSTokens.fontSizeXS,
    fontWeight: SoftSaaSTokens.fontWeightMedium,
    color: textColor,
  );

  /// Badge text large (text-sm)
  static TextStyle badgeLarge(Color textColor) => TextStyle(
    fontFamily: SoftSaaSTokens.fontFamilyBase,
    fontSize: SoftSaaSTokens.fontSizeSM,
    fontWeight: SoftSaaSTokens.fontWeightMedium,
    color: textColor,
  );

  // ══════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ══════════════════════════════════════════════════════════════════════

  /// Get TextTheme for Flutter MaterialApp
  static TextTheme getTextTheme(Brightness brightness) {
    return TextTheme(
      displayLarge: heading1(brightness),
      displayMedium: heading2(brightness),
      displaySmall: heading3(brightness),
      headlineMedium: heading4(brightness),
      headlineSmall: heading5(brightness),
      titleLarge: heading4(brightness),
      titleMedium: heading5(brightness),
      titleSmall: heading6(brightness),
      bodyLarge: bodyLarge(brightness),
      bodyMedium: bodyMedium(brightness),
      bodySmall: bodySmall(brightness),
      labelLarge: label(brightness),
      labelMedium: label(brightness),
      labelSmall: labelSmall(brightness),
    );
  }
}
