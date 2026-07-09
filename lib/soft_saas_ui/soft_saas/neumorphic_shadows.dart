/// Neumorphic Shadow System for Soft SaaS UI
///
/// This file implements the multi-layer neumorphic shadow system that gives
/// the Soft SaaS UI its characteristic embossed, tactile appearance.
///
/// Each shadow consists of multiple layers:
/// 1. Outer drop shadow - creates elevation
/// 2. Inner top highlight - creates embossed effect
/// 3. Inner bottom shadow - creates depth

import 'package:flutter/material.dart';

/// Neumorphic shadow definitions for Soft SaaS UI
class NeumorphicShadows {
  NeumorphicShadows._();

  // ══════════════════════════════════════════════════════════════════════
  // LIGHT MODE SHADOWS
  // ══════════════════════════════════════════════════════════════════════

  /// Level 1 - Subtle (Badges, dots, small elements)
  static final List<BoxShadow> level1Light = [
    const BoxShadow(
      color: Color(0x0D000000), // rgba(0, 0, 0, 0.05)
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
    const BoxShadow(
      color: Color(0x1AFFFFFF), // rgba(255, 255, 255, 0.1) - inset highlight
      offset: Offset(0, 1),
      blurRadius: 1,
      spreadRadius: 0,
    ),
    const BoxShadow(
      color: Color(0x05000000), // rgba(0, 0, 0, 0.02) - inset shadow
      offset: Offset(0, -1),
      blurRadius: 1,
      spreadRadius: 0,
    ),
  ];

  /// Level 2 - Standard (Buttons, inputs, cards)
  static final List<BoxShadow> level2Light = [
    const BoxShadow(
      color: Color(0x1A000000), // rgba(0, 0, 0, 0.1)
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -1,
    ),
    const BoxShadow(
      color: Color(0x0D000000), // rgba(0, 0, 0, 0.05)
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
    const BoxShadow(
      color: Color(0x1AFFFFFF), // rgba(255, 255, 255, 0.1) - inset highlight
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  /// Level 3 - Elevated (Dropdowns, popovers, floating elements)
  static final List<BoxShadow> level3Light = [
    const BoxShadow(
      color: Color(0x26000000), // rgba(0, 0, 0, 0.15)
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: -2,
    ),
    const BoxShadow(
      color: Color(0x1AFFFFFF), // rgba(255, 255, 255, 0.1) - inset highlight
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  /// Level 4 - Floating (Modals, dialogs, overlays)
  static final List<BoxShadow> level4Light = [
    const BoxShadow(
      color: Color(0x26000000), // rgba(0, 0, 0, 0.15)
      offset: Offset(0, 8),
      blurRadius: 32,
      spreadRadius: 0,
    ),
    const BoxShadow(
      color: Color(0x1AFFFFFF), // rgba(255, 255, 255, 0.1) - inset highlight
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  /// Enhanced hover shadow for cards (light mode)
  static final List<BoxShadow> enhancedHoverLight = [
    const BoxShadow(
      color: Color(0x33000000), // rgba(0, 0, 0, 0.2)
      offset: Offset(0, 20),
      blurRadius: 25,
      spreadRadius: -5,
    ),
    const BoxShadow(
      color: Color(0x1F000000), // rgba(0, 0, 0, 0.12)
      offset: Offset(0, 10),
      blurRadius: 15,
      spreadRadius: -3,
    ),
    const BoxShadow(
      color: Color(0x0F000000), // rgba(0, 0, 0, 0.06)
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -2,
    ),
    const BoxShadow(
      color: Color(0x26FFFFFF), // rgba(255, 255, 255, 0.15) - inset highlight
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
    const BoxShadow(
      color: Color(0x14000000), // rgba(0, 0, 0, 0.08) - inset shadow
      offset: Offset(0, -2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  /// Focus shadow for inputs (light mode)
  static final List<BoxShadow> focusShadowLight = [
    const BoxShadow(
      color: Color(0x26000000), // rgba(0, 0, 0, 0.15)
      offset: Offset(0, 25),
      blurRadius: 50,
      spreadRadius: -12,
    ),
    const BoxShadow(
      color: Color(0x1A000000), // rgba(0, 0, 0, 0.1)
      offset: Offset(0, 20),
      blurRadius: 25,
      spreadRadius: -5,
    ),
    const BoxShadow(
      color: Color(0x0A000000), // rgba(0, 0, 0, 0.04)
      offset: Offset(0, 10),
      blurRadius: 10,
      spreadRadius: -5,
    ),
    const BoxShadow(
      color: Color(0x1AFFFFFF), // rgba(255, 255, 255, 0.1) - inset highlight
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
    const BoxShadow(
      color: Color(0x0D000000), // rgba(0, 0, 0, 0.05) - inset shadow
      offset: Offset(0, -2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  // ══════════════════════════════════════════════════════════════════════
  // DARK MODE SHADOWS
  // ══════════════════════════════════════════════════════════════════════

  /// Level 1 - Subtle (Dark mode)
  static final List<BoxShadow> level1Dark = [
    const BoxShadow(
      color: Color(0x4D000000), // rgba(0, 0, 0, 0.3)
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
    const BoxShadow(
      color: Color(0x0AFFFFFF), // rgba(255, 255, 255, 0.04) - inset highlight
      offset: Offset(0, 1),
      blurRadius: 1,
      spreadRadius: 0,
    ),
    const BoxShadow(
      color: Color(0x1A000000), // rgba(0, 0, 0, 0.1) - inset shadow
      offset: Offset(0, -1),
      blurRadius: 1,
      spreadRadius: 0,
    ),
  ];

  /// Level 2 - Standard (Dark mode)
  static final List<BoxShadow> level2Dark = [
    const BoxShadow(
      color: Color(0x4D000000), // rgba(0, 0, 0, 0.3)
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -1,
    ),
    const BoxShadow(
      color: Color(0x0AFFFFFF), // rgba(255, 255, 255, 0.04) - inset highlight
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  /// Level 3 - Elevated (Dark mode)
  static final List<BoxShadow> level3Dark = [
    const BoxShadow(
      color: Color(0x80000000), // rgba(0, 0, 0, 0.5)
      offset: Offset(0, 8),
      blurRadius: 16,
      spreadRadius: -4,
    ),
    const BoxShadow(
      color: Color(0x0AFFFFFF), // rgba(255, 255, 255, 0.04) - inset highlight
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  /// Level 4 - Floating (Dark mode)
  static final List<BoxShadow> level4Dark = [
    const BoxShadow(
      color: Color(0x99000000), // rgba(0, 0, 0, 0.6)
      offset: Offset(0, 20),
      blurRadius: 40,
      spreadRadius: -8,
    ),
    const BoxShadow(
      color: Color(0x0AFFFFFF), // rgba(255, 255, 255, 0.04) - inset highlight
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  /// Enhanced hover shadow for cards (dark mode)
  static final List<BoxShadow> enhancedHoverDark = [
    const BoxShadow(
      color: Color(0xB3000000), // rgba(0, 0, 0, 0.7)
      offset: Offset(0, 20),
      blurRadius: 25,
      spreadRadius: -5,
    ),
    const BoxShadow(
      color: Color(0x80000000), // rgba(0, 0, 0, 0.5)
      offset: Offset(0, 10),
      blurRadius: 15,
      spreadRadius: -3,
    ),
    const BoxShadow(
      color: Color(0x4D000000), // rgba(0, 0, 0, 0.3)
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -2,
    ),
    const BoxShadow(
      color: Color(0x14FFFFFF), // rgba(255, 255, 255, 0.08) - inset highlight
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
    const BoxShadow(
      color: Color(0x66000000), // rgba(0, 0, 0, 0.4) - inset shadow
      offset: Offset(0, -2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  /// Focus shadow for inputs (dark mode)
  static final List<BoxShadow> focusShadowDark = [
    const BoxShadow(
      color: Color(0x99000000), // rgba(0, 0, 0, 0.6)
      offset: Offset(0, 25),
      blurRadius: 50,
      spreadRadius: -12,
    ),
    const BoxShadow(
      color: Color(0x80000000), // rgba(0, 0, 0, 0.5)
      offset: Offset(0, 20),
      blurRadius: 25,
      spreadRadius: -5,
    ),
    const BoxShadow(
      color: Color(0x66000000), // rgba(0, 0, 0, 0.4)
      offset: Offset(0, 10),
      blurRadius: 10,
      spreadRadius: -5,
    ),
    const BoxShadow(
      color: Color(0x14FFFFFF), // rgba(255, 255, 255, 0.08) - inset highlight
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
    const BoxShadow(
      color: Color(0x66000000), // rgba(0, 0, 0, 0.4) - inset shadow
      offset: Offset(0, -2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  // ══════════════════════════════════════════════════════════════════════
  // COLOR-TINTED SHADOWS (For Colored Buttons)
  // ══════════════════════════════════════════════════════════════════════

  /// Blue button shadow (light mode)
  static final List<BoxShadow> blueTintedLight = [
    const BoxShadow(
      color: Color(0x4D3B82F6), // rgba(59, 130, 246, 0.3)
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -1,
    ),
    const BoxShadow(
      color: Color(0x333B82F6), // rgba(59, 130, 246, 0.2)
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: -1,
    ),
    const BoxShadow(
      color: Color(0x26FFFFFF), // rgba(255, 255, 255, 0.15) - inset highlight
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
    const BoxShadow(
      color: Color(0x0D000000), // rgba(0, 0, 0, 0.05) - inset shadow
      offset: Offset(0, -1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  /// Red button shadow (light mode)
  static final List<BoxShadow> redTintedLight = [
    const BoxShadow(
      color: Color(0x4DDC2626), // rgba(220, 38, 38, 0.3)
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -1,
    ),
    const BoxShadow(
      color: Color(0x33DC2626), // rgba(220, 38, 38, 0.2)
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: -1,
    ),
    const BoxShadow(
      color: Color(0x26FFFFFF), // rgba(255, 255, 255, 0.15) - inset highlight
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
    const BoxShadow(
      color: Color(0x0D000000), // rgba(0, 0, 0, 0.05) - inset shadow
      offset: Offset(0, -1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  /// Green button shadow (light mode)
  static final List<BoxShadow> greenTintedLight = [
    const BoxShadow(
      color: Color(0x4D22C55E), // rgba(34, 197, 94, 0.3)
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -1,
    ),
    const BoxShadow(
      color: Color(0x3322C55E), // rgba(34, 197, 94, 0.2)
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: -1,
    ),
    const BoxShadow(
      color: Color(0x26FFFFFF), // rgba(255, 255, 255, 0.15) - inset highlight
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
    const BoxShadow(
      color: Color(0x0D000000), // rgba(0, 0, 0, 0.05) - inset shadow
      offset: Offset(0, -1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  /// Orange button shadow (light mode)
  static final List<BoxShadow> orangeTintedLight = [
    const BoxShadow(
      color: Color(0x4DEA580C), // rgba(234, 88, 12, 0.3)
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -1,
    ),
    const BoxShadow(
      color: Color(0x33EA580C), // rgba(234, 88, 12, 0.2)
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: -1,
    ),
    const BoxShadow(
      color: Color(0x26FFFFFF), // rgba(255, 255, 255, 0.15) - inset highlight
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
    const BoxShadow(
      color: Color(0x0D000000), // rgba(0, 0, 0, 0.05) - inset shadow
      offset: Offset(0, -1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  /// Purple button shadow (light mode)
  static final List<BoxShadow> purpleTintedLight = [
    const BoxShadow(
      color: Color(0x4D9333EA), // rgba(147, 51, 234, 0.3)
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -1,
    ),
    const BoxShadow(
      color: Color(0x339333EA), // rgba(147, 51, 234, 0.2)
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: -1,
    ),
    const BoxShadow(
      color: Color(0x26FFFFFF), // rgba(255, 255, 255, 0.15) - inset highlight
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
    const BoxShadow(
      color: Color(0x0D000000), // rgba(0, 0, 0, 0.05) - inset shadow
      offset: Offset(0, -1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  // ══════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ══════════════════════════════════════════════════════════════════════

  /// Get shadow level based on brightness
  static List<BoxShadow> getLevel1(Brightness brightness) {
    return brightness == Brightness.light ? level1Light : level1Dark;
  }

  static List<BoxShadow> getLevel2(Brightness brightness) {
    return brightness == Brightness.light ? level2Light : level2Dark;
  }

  static List<BoxShadow> getLevel3(Brightness brightness) {
    return brightness == Brightness.light ? level3Light : level3Dark;
  }

  static List<BoxShadow> getLevel4(Brightness brightness) {
    return brightness == Brightness.light ? level4Light : level4Dark;
  }

  static List<BoxShadow> getEnhancedHover(Brightness brightness) {
    return brightness == Brightness.light
        ? enhancedHoverLight
        : enhancedHoverDark;
  }

  static List<BoxShadow> getFocusShadow(Brightness brightness) {
    return brightness == Brightness.light ? focusShadowLight : focusShadowDark;
  }

  /// Inset shadow for pressed/filled states
  static List<BoxShadow> insetShadow(Brightness brightness) {
    if (brightness == Brightness.light) {
      return [
        const BoxShadow(
          color: Color(0x1A000000), // rgba(0, 0, 0, 0.1)
          offset: Offset(0, 2),
          blurRadius: 4,
          spreadRadius: 0,
        ),
        const BoxShadow(
          color: Color(0x0D000000), // rgba(0, 0, 0, 0.05)
          offset: Offset(0, -1),
          blurRadius: 2,
          spreadRadius: 0,
        ),
      ];
    } else {
      return [
        const BoxShadow(
          color: Color(0x4D000000), // rgba(0, 0, 0, 0.3)
          offset: Offset(0, 2),
          blurRadius: 4,
          spreadRadius: 0,
        ),
        const BoxShadow(
          color: Color(0x1A000000), // rgba(0, 0, 0, 0.1)
          offset: Offset(0, -1),
          blurRadius: 2,
          spreadRadius: 0,
        ),
      ];
    }
  }
}
