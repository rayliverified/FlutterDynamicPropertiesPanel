/// Theme Configuration for Soft SaaS UI
///
/// This file combines all design tokens, typography, and shadows into
/// a complete Flutter ThemeData configuration.
library;

import 'package:flutter/material.dart';
import 'design_tokens.dart';
import 'typography.dart';

/// Soft SaaS UI theme configuration
class SoftSaaSTheme {
  SoftSaaSTheme._();

  // ══════════════════════════════════════════════════════════════════════
  // THEME DATA
  // ══════════════════════════════════════════════════════════════════════

  /// Get light theme
  static ThemeData light() {
    const brightness = Brightness.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: SoftSaaSTokens.fontFamilyBase,

      // Color scheme
      colorScheme: ColorScheme.light(
        primary: SoftSaaSTokens.primary,
        onPrimary: Colors.white,
        secondary: SoftSaaSTokens.gray700,
        onSecondary: Colors.white,
        error: SoftSaaSTokens.error,
        onError: Colors.white,
        surface: SoftSaaSTokens.lightPrimaryBackground,
        onSurface: SoftSaaSTokens.lightPrimaryText,
        surfaceContainerHighest: SoftSaaSTokens.lightSecondaryBackground,
        outline: SoftSaaSTokens.lightPrimaryBorder,
      ),

      // Scaffold
      scaffoldBackgroundColor: SoftSaaSTokens.lightSecondaryBackground,

      // App bar
      appBarTheme: AppBarTheme(
        backgroundColor: SoftSaaSTokens.lightPrimaryBackground,
        foregroundColor: SoftSaaSTokens.lightPrimaryText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: SoftSaaSTypography.heading4(brightness),
      ),

      // Card
      cardTheme: CardThemeData(
        color: SoftSaaSTokens.lightPrimaryBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusXLarge),
          side: BorderSide(color: SoftSaaSTokens.lightPrimaryBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Text theme
      textTheme: SoftSaaSTypography.getTextTheme(brightness),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SoftSaaSTokens.lightPrimaryBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusXLarge),
          borderSide: BorderSide(
            color: SoftSaaSTokens.lightTertiaryBackground,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusXLarge),
          borderSide: BorderSide(
            color: SoftSaaSTokens.lightTertiaryBackground,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusXLarge),
          borderSide: BorderSide(
            color: SoftSaaSTokens.lightPrimaryBorder,
            width: 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusXLarge),
          borderSide: BorderSide(color: SoftSaaSTokens.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: SoftSaaSTypography.bodyMediumTertiary(brightness),
      ),

      // Elevated button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SoftSaaSTokens.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusLarge),
          ),
          padding: SoftSaaSTokens.buttonPaddingMedium,
          textStyle: SoftSaaSTypography.buttonMedium(Colors.white),
        ),
      ),

      // Outlined button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SoftSaaSTokens.lightPrimaryText,
          side: BorderSide(color: SoftSaaSTokens.lightPrimaryBorder, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusLarge),
          ),
          padding: SoftSaaSTokens.buttonPaddingMedium,
          textStyle: SoftSaaSTypography.buttonMedium(
            SoftSaaSTokens.lightPrimaryText,
          ),
        ),
      ),

      // Text button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: SoftSaaSTokens.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusLarge),
          ),
          padding: SoftSaaSTokens.buttonPaddingMedium,
          textStyle: SoftSaaSTypography.buttonMedium(SoftSaaSTokens.primary),
        ),
      ),

      // Icon button
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: SoftSaaSTokens.lightSecondaryText,
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: SoftSaaSTokens.lightTertiaryBackground,
        deleteIconColor: SoftSaaSTokens.lightSecondaryText,
        disabledColor: SoftSaaSTokens.lightTertiaryBackground.withValues(
          alpha: 0.5,
        ),
        selectedColor: SoftSaaSTokens.primary,
        secondarySelectedColor: SoftSaaSTokens.primary.withValues(alpha: 0.1),
        padding: SoftSaaSTokens.badgePaddingMedium,
        labelStyle: SoftSaaSTypography.badgeMedium(
          SoftSaaSTokens.lightPrimaryText,
        ),
        secondaryLabelStyle: SoftSaaSTypography.badgeMedium(Colors.white),
        brightness: brightness,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusMedium),
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: SoftSaaSTokens.lightPrimaryBorder,
        thickness: 1,
        space: 1,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: SoftSaaSTokens.lightPrimaryBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SoftSaaSTokens.radius2XLarge),
        ),
        titleTextStyle: SoftSaaSTypography.heading3(brightness),
        contentTextStyle: SoftSaaSTypography.bodyMedium(brightness),
      ),

      // Bottom sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: SoftSaaSTokens.lightPrimaryBackground,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(SoftSaaSTokens.radius2XLarge),
          ),
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: SoftSaaSTokens.gray800,
        contentTextStyle: SoftSaaSTypography.bodyMedium(Brightness.dark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusLarge),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return SoftSaaSTokens.lightTertiaryText;
          }
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return SoftSaaSTokens.lightTertiaryBackground;
          }
          if (states.contains(WidgetState.selected)) {
            return SoftSaaSTokens.primary;
          }
          return SoftSaaSTokens.gray300;
        }),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return SoftSaaSTokens.lightTertiaryBackground;
          }
          if (states.contains(WidgetState.selected)) {
            return SoftSaaSTokens.primary;
          }
          return SoftSaaSTokens.lightPrimaryBackground;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: SoftSaaSTokens.lightSecondaryBorder, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusSmall),
        ),
      ),

      // Radio
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return SoftSaaSTokens.lightTertiaryBackground;
          }
          if (states.contains(WidgetState.selected)) {
            return SoftSaaSTokens.primary;
          }
          return SoftSaaSTokens.lightSecondaryBorder;
        }),
      ),

      // Tooltip
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: SoftSaaSTokens.gray800,
          borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusLarge),
        ),
        textStyle: SoftSaaSTypography.bodySmall(Brightness.dark),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  /// Get dark theme
  static ThemeData dark() {
    const brightness = Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: SoftSaaSTokens.fontFamilyBase,

      // Color scheme
      colorScheme: ColorScheme.dark(
        primary: SoftSaaSTokens.primaryDark,
        onPrimary: Colors.white,
        secondary: SoftSaaSTokens.gray600,
        onSecondary: Colors.white,
        error: SoftSaaSTokens.errorDark,
        onError: Colors.white,
        surface: SoftSaaSTokens.darkPrimaryBackground,
        onSurface: SoftSaaSTokens.darkPrimaryText,
        surfaceContainerHighest: SoftSaaSTokens.darkSecondaryBackground,
        outline: SoftSaaSTokens.darkPrimaryBorder,
      ),

      // Scaffold
      scaffoldBackgroundColor: SoftSaaSTokens.darkSecondaryBackground,

      // App bar
      appBarTheme: AppBarTheme(
        backgroundColor: SoftSaaSTokens.darkPrimaryBackground,
        foregroundColor: SoftSaaSTokens.darkPrimaryText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: SoftSaaSTypography.heading4(brightness),
      ),

      // Card
      cardTheme: CardThemeData(
        color: SoftSaaSTokens.darkPrimaryBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusXLarge),
          side: BorderSide(color: SoftSaaSTokens.darkPrimaryBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Text theme
      textTheme: SoftSaaSTypography.getTextTheme(brightness),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SoftSaaSTokens.darkPrimaryBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusXLarge),
          borderSide: BorderSide(
            color: SoftSaaSTokens.darkTertiaryBackground,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusXLarge),
          borderSide: BorderSide(
            color: SoftSaaSTokens.darkTertiaryBackground,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusXLarge),
          borderSide: BorderSide(
            color: SoftSaaSTokens.darkSecondaryBorder,
            width: 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusXLarge),
          borderSide: BorderSide(color: SoftSaaSTokens.errorDark, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: SoftSaaSTypography.bodyMediumTertiary(brightness),
      ),

      // Elevated button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SoftSaaSTokens.primaryDark,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusLarge),
          ),
          padding: SoftSaaSTokens.buttonPaddingMedium,
          textStyle: SoftSaaSTypography.buttonMedium(Colors.white),
        ),
      ),

      // Outlined button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SoftSaaSTokens.darkPrimaryText,
          side: BorderSide(color: SoftSaaSTokens.darkPrimaryBorder, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusLarge),
          ),
          padding: SoftSaaSTokens.buttonPaddingMedium,
          textStyle: SoftSaaSTypography.buttonMedium(
            SoftSaaSTokens.darkPrimaryText,
          ),
        ),
      ),

      // Text button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: SoftSaaSTokens.primaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusLarge),
          ),
          padding: SoftSaaSTokens.buttonPaddingMedium,
          textStyle: SoftSaaSTypography.buttonMedium(
            SoftSaaSTokens.primaryDark,
          ),
        ),
      ),

      // Icon button
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: SoftSaaSTokens.darkSecondaryText,
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: SoftSaaSTokens.darkTertiaryBackground,
        deleteIconColor: SoftSaaSTokens.darkSecondaryText,
        disabledColor: SoftSaaSTokens.darkTertiaryBackground.withValues(
          alpha: 0.5,
        ),
        selectedColor: SoftSaaSTokens.primaryDark,
        secondarySelectedColor: SoftSaaSTokens.primaryDark.withValues(
          alpha: 0.2,
        ),
        padding: SoftSaaSTokens.badgePaddingMedium,
        labelStyle: SoftSaaSTypography.badgeMedium(
          SoftSaaSTokens.darkPrimaryText,
        ),
        secondaryLabelStyle: SoftSaaSTypography.badgeMedium(Colors.white),
        brightness: brightness,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusMedium),
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: SoftSaaSTokens.darkPrimaryBorder,
        thickness: 1,
        space: 1,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: SoftSaaSTokens.darkPrimaryBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SoftSaaSTokens.radius2XLarge),
        ),
        titleTextStyle: SoftSaaSTypography.heading3(brightness),
        contentTextStyle: SoftSaaSTypography.bodyMedium(brightness),
      ),

      // Bottom sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: SoftSaaSTokens.darkPrimaryBackground,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(SoftSaaSTokens.radius2XLarge),
          ),
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: SoftSaaSTokens.gray700,
        contentTextStyle: SoftSaaSTypography.bodyMedium(Brightness.dark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusLarge),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return SoftSaaSTokens.darkTertiaryText;
          }
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return SoftSaaSTokens.darkTertiaryBackground;
          }
          if (states.contains(WidgetState.selected)) {
            return SoftSaaSTokens.primaryDark;
          }
          return SoftSaaSTokens.gray600;
        }),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return SoftSaaSTokens.darkTertiaryBackground;
          }
          if (states.contains(WidgetState.selected)) {
            return SoftSaaSTokens.primaryDark;
          }
          return SoftSaaSTokens.darkPrimaryBackground;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: SoftSaaSTokens.darkSecondaryBorder, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusSmall),
        ),
      ),

      // Radio
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return SoftSaaSTokens.darkTertiaryBackground;
          }
          if (states.contains(WidgetState.selected)) {
            return SoftSaaSTokens.primaryDark;
          }
          return SoftSaaSTokens.darkSecondaryBorder;
        }),
      ),

      // Tooltip
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: SoftSaaSTokens.gray700,
          borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusLarge),
        ),
        textStyle: SoftSaaSTypography.bodySmall(Brightness.dark),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
