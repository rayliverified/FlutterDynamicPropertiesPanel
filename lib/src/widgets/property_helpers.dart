part of 'dynamic_properties_panel.dart';

// ══════════════════════════════════════════════════════════════════════
// Instance helpers (extension on state)
// ══════════════════════════════════════════════════════════════════════

extension _DppStateHelpers on _DynamicPropertiesPanelState {
  /// Shorthand for writing a value through the controller.
  void _setValue(String key, dynamic value) {
    _controller[key] = value;
  }
}

// ══════════════════════════════════════════════════════════════════════
// Pure static helpers (top-level private functions)
// ══════════════════════════════════════════════════════════════════════

Map<String, dynamic> _deepCopyMap(Map<String, dynamic> value) {
  return jsonDecode(jsonEncode(value)) as Map<String, dynamic>;
}

bool _isModified(DynamicPropertyDefinition property, dynamic value) {
  try {
    return jsonEncode(value) != jsonEncode(property.defaultValue);
  } catch (_) {
    return value != property.defaultValue;
  }
}

String _capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

DynamicPropertyKind _inferKindFromRuntime(dynamic value) {
  if (value is String) return DynamicPropertyKind.string;
  if (value is int) return DynamicPropertyKind.integer;
  if (value is double) return DynamicPropertyKind.double;
  if (value is bool) return DynamicPropertyKind.boolean;
  if (value is Map) return DynamicPropertyKind.object;
  if (value is List) return DynamicPropertyKind.array;
  return DynamicPropertyKind.json;
}

double? _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

Color? _parseColor(dynamic value) {
  if (value is Color) return value;
  if (value is String) {
    var hex = value.trim();
    if (hex.startsWith('#')) {
      hex = hex.substring(1);
    } else if (hex.startsWith('0x') || hex.startsWith('0X')) {
      hex = hex.substring(2);
    }
    if (hex.length == 6) {
      final v = int.tryParse(hex, radix: 16);
      if (v != null) return Color(0xFF000000 | v);
    }
    if (hex.length == 8) {
      final v = int.tryParse(hex, radix: 16);
      if (v != null) return Color(v);
    }
  }
  if (value is int) return Color(value);
  return null;
}

String _colorToHex(Color color) {
  final a = (color.a * 255.0).round().clamp(0, 255);
  final r = (color.r * 255.0).round().clamp(0, 255);
  final g = (color.g * 255.0).round().clamp(0, 255);
  final b = (color.b * 255.0).round().clamp(0, 255);
  final rHex = r.toRadixString(16).padLeft(2, '0').toUpperCase();
  final gHex = g.toRadixString(16).padLeft(2, '0').toUpperCase();
  final bHex = b.toRadixString(16).padLeft(2, '0').toUpperCase();
  if (a < 255) {
    final aHex = a.toRadixString(16).padLeft(2, '0').toUpperCase();
    return '#$aHex$rHex$gHex$bHex';
  }
  return '#$rHex$gHex$bHex';
}
