/// Hex color parsing and normalization utilities.
///
/// Color parsing helpers used by the color control.
/// behavior for short-hex expansion, alpha handling, and hash normalization.
///
/// Supported formats (with or without leading `#`):
///   - 2-char:   `FF`         → expands to `FFFFFF` (grayscale)
///   - 3-char:   `ABC`        → expands to `AABBCC`
///   - 6-char:   `FF0000`     → RGB
///   - 8-char:   `80FF0000`   → ARGB (alpha first)
library;

import 'package:flutter/material.dart';

/// Parse and normalize a hex string. Returns uppercase digits without `#`.
///
/// - Short formats expand (2 → 6, 3 → 6).
/// - Strings longer than target length are truncated.
/// - Strings shorter than target length are right-padded with `0`.
String parseHex(String hex, {bool withAlpha = false}) {
  if (hex.isEmpty) return '';

  String text = hex.startsWith('#') ? hex.substring(1) : hex;
  if (text.isEmpty) return '';

  final int targetLength = withAlpha ? 8 : 6;

  if (text.length == 2) {
    // 'FF' → 'FFFFFF'
    text = text * 3;
  } else if (text.length == 3) {
    // 'ABC' → 'AABBCC'
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      final c = text[i];
      buffer.write(c);
      buffer.write(c);
    }
    text = buffer.toString();
  }

  if (text.length > targetLength) {
    text = text.substring(0, targetLength);
  } else if (text.length < targetLength) {
    text = text.padRight(targetLength, '0');
  }

  return text.toUpperCase();
}

/// Format a [Color] as a hex string.
String colorToHex(
  Color color, {
  bool withAlpha = false,
  bool withHashtag = false,
}) {
  String toByte(double channel) =>
      ((channel * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0');

  final r = toByte(color.r);
  final g = toByte(color.g);
  final b = toByte(color.b);
  final a = toByte(color.a);
  return '${withHashtag ? '#' : ''}${withAlpha ? a : ''}$r$g$b'.toUpperCase();
}

/// Parse a hex string to a [Color]. Returns [fallback] on failure.
Color? hexToColor(String hex, {Color? fallback}) {
  if (hex.isEmpty) return fallback;

  String normalized = parseHex(hex, withAlpha: true);
  if (normalized.length < 8) {
    normalized = 'FF$normalized';
  }

  final value = int.tryParse(normalized, radix: 16);
  if (value == null) return fallback;
  return Color(value);
}

/// Validate whether [hex] has a recognizable length + alphabet.
bool isValidHex(String hex, {bool withAlpha = false}) {
  if (hex.isEmpty) return false;

  var text = hex;
  if (text.startsWith('#')) text = text.substring(1);

  if (!RegExp(r'^[0-9A-Fa-f]+$').hasMatch(text)) return false;

  final expected = withAlpha ? 8 : 6;
  return text.length == 2 ||
      text.length == 3 ||
      text.length == expected ||
      (withAlpha && text.length == 8);
}
