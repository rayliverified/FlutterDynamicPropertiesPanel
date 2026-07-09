import 'dart:convert';

/// A named preset configuration for a dynamic properties panel.
///
/// Presets define complete parameter value sets that can be applied
/// to the panel with a single click. They appear in a dropdown selector
/// with save, reset, and delete actions.
///
/// ```dart
/// PropertyPreset(
///   id: 'compact',
///   name: 'Compact',
///   description: 'Minimal spacing and small font',
///   values: {'fontSize': 12, 'padding': 4, 'showShadow': false},
/// )
/// ```
class PropertyPreset {
  const PropertyPreset({
    required this.id,
    required this.name,
    this.description,
    required this.values,
  });

  /// Unique identifier for this preset.
  final String id;

  /// Display name shown in the preset selector.
  final String name;

  /// Optional description.
  final String? description;

  /// The parameter values for this preset configuration.
  final Map<String, dynamic> values;

  PropertyPreset copyWith({
    String? id,
    String? name,
    String? description,
    Map<String, dynamic>? values,
  }) {
    return PropertyPreset(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      values: values ?? this.values,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      'values': values,
    };
  }

  /// Deserialize from JSON.
  factory PropertyPreset.fromJson(Map<String, dynamic> json) {
    return PropertyPreset(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? json['id'] ?? '').toString(),
      description: json['description']?.toString(),
      values: json['values'] is Map
          ? Map<String, dynamic>.from(json['values'] as Map)
          : json['parameters'] is Map
          ? Map<String, dynamic>.from(json['parameters'] as Map)
          : json['parametersJson'] is Map
          ? Map<String, dynamic>.from(json['parametersJson'] as Map)
          : const {},
    );
  }

  /// Deserialize a list of presets from JSON.
  static List<PropertyPreset> listFromJson(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map(
            (item) => PropertyPreset.fromJson(Map<String, dynamic>.from(item)),
          )
          .where((p) => p.id.isNotEmpty)
          .toList();
    }
    return const [];
  }

  /// Returns true when every key in [values] is present in [other] with an
  /// equal value (compared via JSON encoding for deep equality).
  bool matches(Map<String, dynamic> other) {
    for (final entry in values.entries) {
      if (!other.containsKey(entry.key)) return false;
      try {
        if (jsonEncode(other[entry.key]) != jsonEncode(entry.value)) {
          return false;
        }
      } catch (_) {
        if (other[entry.key] != entry.value) return false;
      }
    }
    return true;
  }

  /// Deep equality check between two maps (JSON-serializable values).
  static bool mapsEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    try {
      return jsonEncode(a) == jsonEncode(b);
    } catch (_) {
      return false;
    }
  }
}
