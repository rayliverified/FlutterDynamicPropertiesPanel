enum DynamicPropertyKind {
  // Primitives
  string,
  integer,
  double,
  boolean,

  // Enums
  enumValue,
  multiEnum,

  // Collections
  object,
  array,
  map,

  // Flutter convenience types
  icon,
  iconSwatch,
  color,
  colorSwatch,
  date,
  duration,
  slider,
  alignment,
  edgeInsets,
  borderRadius,
  boxConstraints,
  textStyle,

  // Segmented / picker controls
  mainAxisAlignment,
  crossAxisAlignment,
  mainAxisSize,
  axis,
  textAlign,

  // Composite controls
  size,
  rotation,

  // Component slots
  widget,
  widgetList,

  // Fallback
  json,
  unknown,
}

/// Schema definition for a single editable property.
///
/// Describes the property's type, constraints, default value, and
/// nested structure. The panel uses this to select the correct control
/// widget automatically.
class DynamicPropertyDefinition {
  const DynamicPropertyDefinition({
    required this.name,
    required this.kind,
    this.title,
    this.description,
    this.defaultValue,
    this.required = false,
    this.enumValues,
    this.enumLabels,
    this.enumIconNames,
    this.bounds,
    this.properties,
    this.item,
    this.mapValue,
    this.rawType,
    this.iconName,
    this.suggestions,
    this.widthFactor,
    this.category,
  });

  /// Property identifier / key in the values map.
  final String name;

  /// The type of control to render.
  final DynamicPropertyKind kind;

  /// Optional display title (falls back to [name]).
  final String? title;

  /// Optional description shown below the label.
  final String? description;

  /// Default value when the property hasn't been set.
  final dynamic defaultValue;

  /// Whether the property must have a value.
  final bool required;

  /// Allowed values for [enumValue] / [multiEnum] kinds.
  final List<dynamic>? enumValues;

  /// Display labels for enum values: `{'primary': 'Primary Style'}`.
  final Map<String, String>? enumLabels;

  /// Icon names for enum values: `{'primary': 'check'}`.
  /// Resolved through the [IconRegistry].
  final Map<String, String>? enumIconNames;

  /// Numeric / string constraints.
  ///
  /// Common keys:
  /// - `minimum`, `maximum`, `step` (numbers)
  /// - `minLength`, `maxLength` (strings)
  /// - `allowedIcons` (icon)
  final Map<String, dynamic>? bounds;

  /// Nested property definitions for [object] kind.
  final List<DynamicPropertyDefinition>? properties;

  /// Item definition for [array] kind.
  final DynamicPropertyDefinition? item;

  /// Value definition for [map] kind. Map keys remain strings while each
  /// value uses this schema to select and configure its input control.
  final DynamicPropertyDefinition? mapValue;

  /// Original Dart type string (e.g. `'int'`, `'Alignment'`, `'TextStyle'`).
  final String? rawType;

  /// Initial icon name for [icon] kind.
  final String? iconName;

  /// Freeform string suggestions — when non-empty on a [string] property,
  /// the control renders as `SoftSaaSComboInput` (text field + chevron →
  /// dropdown of suggestions). Unlike [enumValues], the user can still type
  /// arbitrary values.
  final List<String>? suggestions;

  /// Explicit width factor for smart layout. `null` = auto-inferred from [kind].
  /// Currently supported values: `1.0` (full row) and `0.5` (two per row).
  final double? widthFactor;

  /// Explicit category for smart-layout grouping. `null` = auto-inferred
  /// from [kind]. Only adjacent properties with the same effective category
  /// are eligible to share a row.
  final String? category;

  /// Human-readable label (title or name).
  String get label => title ?? name;

  /// Effective width factor used by smart layout (1.0 or 0.5).
  double get effectiveWidthFactor =>
      widthFactor ??
      _defaultWidthFactor(
        kind,
        hasSuggestions: suggestions != null && suggestions!.isNotEmpty,
      );

  /// Effective category used by smart-layout grouping.
  String get effectiveCategory => category ?? _defaultCategory(kind);

  static double _defaultWidthFactor(
    DynamicPropertyKind kind, {
    bool hasSuggestions = false,
  }) {
    if (hasSuggestions) return 1.0;
    switch (kind) {
      case DynamicPropertyKind.integer:
      case DynamicPropertyKind.double:
      case DynamicPropertyKind.string:
      case DynamicPropertyKind.enumValue:
      case DynamicPropertyKind.slider:
      case DynamicPropertyKind.color:
      case DynamicPropertyKind.colorSwatch:
      case DynamicPropertyKind.date:
      case DynamicPropertyKind.icon:
      case DynamicPropertyKind.iconSwatch:
      case DynamicPropertyKind.boolean:
      case DynamicPropertyKind.mainAxisAlignment:
      case DynamicPropertyKind.crossAxisAlignment:
      case DynamicPropertyKind.mainAxisSize:
      case DynamicPropertyKind.axis:
      case DynamicPropertyKind.textAlign:
        return 0.5;
      default:
        return 1.0;
    }
  }

  static String _defaultCategory(DynamicPropertyKind kind) {
    switch (kind) {
      case DynamicPropertyKind.integer:
      case DynamicPropertyKind.double:
      case DynamicPropertyKind.slider:
        return 'numbers';
      case DynamicPropertyKind.string:
        return 'text';
      case DynamicPropertyKind.enumValue:
      case DynamicPropertyKind.multiEnum:
        return 'selection';
      case DynamicPropertyKind.boolean:
        return 'toggle';
      case DynamicPropertyKind.color:
      case DynamicPropertyKind.colorSwatch:
      case DynamicPropertyKind.icon:
      case DynamicPropertyKind.iconSwatch:
        return 'appearance';
      case DynamicPropertyKind.date:
      case DynamicPropertyKind.duration:
        return 'datetime';
      case DynamicPropertyKind.alignment:
      case DynamicPropertyKind.edgeInsets:
      case DynamicPropertyKind.borderRadius:
      case DynamicPropertyKind.boxConstraints:
      case DynamicPropertyKind.mainAxisAlignment:
      case DynamicPropertyKind.crossAxisAlignment:
      case DynamicPropertyKind.mainAxisSize:
      case DynamicPropertyKind.axis:
      case DynamicPropertyKind.textAlign:
      case DynamicPropertyKind.size:
      case DynamicPropertyKind.rotation:
        return 'layout';
      case DynamicPropertyKind.textStyle:
        return 'typography';
      case DynamicPropertyKind.object:
      case DynamicPropertyKind.array:
      case DynamicPropertyKind.map:
      case DynamicPropertyKind.json:
        return 'nested';
      case DynamicPropertyKind.widget:
      case DynamicPropertyKind.widgetList:
        return 'slot';
      case DynamicPropertyKind.unknown:
        return 'other';
    }
  }

  DynamicPropertyDefinition copyWith({
    String? name,
    DynamicPropertyKind? kind,
    String? title,
    String? description,
    dynamic defaultValue,
    bool? required,
    List<dynamic>? enumValues,
    Map<String, String>? enumLabels,
    Map<String, String>? enumIconNames,
    Map<String, dynamic>? bounds,
    List<DynamicPropertyDefinition>? properties,
    DynamicPropertyDefinition? item,
    DynamicPropertyDefinition? mapValue,
    String? rawType,
    String? iconName,
    List<String>? suggestions,
    double? widthFactor,
    String? category,
  }) {
    return DynamicPropertyDefinition(
      name: name ?? this.name,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      description: description ?? this.description,
      defaultValue: defaultValue ?? this.defaultValue,
      required: required ?? this.required,
      enumValues: enumValues ?? this.enumValues,
      enumLabels: enumLabels ?? this.enumLabels,
      enumIconNames: enumIconNames ?? this.enumIconNames,
      bounds: bounds ?? this.bounds,
      properties: properties ?? this.properties,
      item: item ?? this.item,
      mapValue: mapValue ?? this.mapValue,
      rawType: rawType ?? this.rawType,
      iconName: iconName ?? this.iconName,
      suggestions: suggestions ?? this.suggestions,
      widthFactor: widthFactor ?? this.widthFactor,
      category: category ?? this.category,
    );
  }

  // ── JSON deserialization ─────────────────────────────────────────

  factory DynamicPropertyDefinition.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] ?? json['key'] ?? json['id'] ?? '').toString();
    final rawType = json['type']?.toString();

    final dynamicEnum = json['enumValues'] ?? json['enum'];
    final enumValues = dynamicEnum is List
        ? List<dynamic>.from(dynamicEnum)
        : null;

    final rawEnumLabels = json['enumLabels'];
    final enumLabels = rawEnumLabels is Map
        ? Map<String, String>.from(
            rawEnumLabels.map((k, v) => MapEntry(k.toString(), v.toString())),
          )
        : null;

    final rawEnumIcons = json['enumIconNames'] ?? json['enumIcons'];
    final enumIconNames = rawEnumIcons is Map
        ? Map<String, String>.from(
            rawEnumIcons.map((k, v) => MapEntry(k.toString(), v.toString())),
          )
        : null;

    final nestedProperties = _parseProperties(json['properties']);
    final nestedItem = _parseItem(json['items'] ?? json['item']);
    final mapValue = _parseItem(json['value'], fallbackName: 'value');

    final kind = inferKind(
      rawType,
      enumValues: enumValues,
      properties: nestedProperties,
      item: nestedItem,
      multiSelect: json['multiSelect'] as bool? ?? false,
    );

    return DynamicPropertyDefinition(
      name: name,
      kind: kind,
      title: json['title']?.toString() ?? json['label']?.toString(),
      description: json['description']?.toString(),
      defaultValue: json['defaultValue'] ?? json['default'],
      required: json['required'] as bool? ?? false,
      enumValues: enumValues,
      enumLabels: enumLabels,
      enumIconNames: enumIconNames,
      bounds: (json['bounds'] is Map)
          ? Map<String, dynamic>.from(json['bounds'] as Map)
          : null,
      properties: nestedProperties,
      item: nestedItem,
      mapValue: mapValue,
      rawType: rawType,
      iconName: json['iconName']?.toString(),
      suggestions: (json['suggestions'] is List)
          ? List<String>.from(
              (json['suggestions'] as List).map((e) => e.toString()),
            )
          : null,
      widthFactor: (json['widthFactor'] as num?)?.toDouble(),
      category: json['category']?.toString(),
    );
  }

  // ── Kind inference ───────────────────────────────────────────────

  /// Infer the property kind from a raw type string and optional metadata.
  static DynamicPropertyKind inferKind(
    String? rawType, {
    List<dynamic>? enumValues,
    List<DynamicPropertyDefinition>? properties,
    DynamicPropertyDefinition? item,
    bool multiSelect = false,
  }) {
    // Enum detection (must come first)
    if (enumValues != null && enumValues.isNotEmpty) {
      return multiSelect
          ? DynamicPropertyKind.multiEnum
          : DynamicPropertyKind.enumValue;
    }

    // Object with nested properties
    if (properties != null && properties.isNotEmpty) {
      return DynamicPropertyKind.object;
    }

    // Array with item definition
    if (item != null) {
      return DynamicPropertyKind.array;
    }

    final cleanType = (rawType ?? '').replaceAll('?', '').trim();
    final lower = cleanType.toLowerCase();

    // List / Array
    if (cleanType.startsWith('List<') || lower == 'array' || lower == 'list') {
      // Check for List<Widget>
      if (cleanType.contains('Widget')) {
        return DynamicPropertyKind.widgetList;
      }
      return DynamicPropertyKind.array;
    }

    // Widget slots
    if (cleanType == 'Widget' || lower == 'widget') {
      return DynamicPropertyKind.widget;
    }

    // Map
    if (cleanType.startsWith('Map<') || lower == 'map') {
      return DynamicPropertyKind.map;
    }

    // Flutter convenience types — match before primitives
    switch (lower) {
      case 'icondata':
      case 'icon':
        return DynamicPropertyKind.icon;
      case 'icon.swatch':
      case 'iconswatch':
      case 'icon.inspector.swatch': // legacy alias
      case 'iconinspectorswatch': // legacy alias
        return DynamicPropertyKind.iconSwatch;
      case 'color':
        return DynamicPropertyKind.color;
      case 'color.swatch':
      case 'colorswatch':
        return DynamicPropertyKind.colorSwatch;
      case 'datetime':
      case 'date':
        return DynamicPropertyKind.date;
      case 'duration':
        return DynamicPropertyKind.duration;
      case 'slider':
        return DynamicPropertyKind.slider;
      case 'alignment':
      case 'alignmentgeometry':
      case 'alignment.inspector': // legacy alias
      case 'alignmentinspector': // legacy alias
        return DynamicPropertyKind.alignment;
      case 'edgeinsets':
      case 'edgeinsetsgeometry':
      case 'edgeinsets.inspector': // legacy alias
      case 'edgeinsetsinspector': // legacy alias
        return DynamicPropertyKind.edgeInsets;
      case 'borderradius':
      case 'borderradiusgeometry':
      case 'borderradius.inspector': // legacy alias
      case 'borderradiusinspector': // legacy alias
        return DynamicPropertyKind.borderRadius;
      case 'boxconstraints':
      case 'boxconstraints.inspector': // legacy alias
      case 'boxconstraintsinspector': // legacy alias
        return DynamicPropertyKind.boxConstraints;
      case 'textstyle':
        return DynamicPropertyKind.textStyle;

      // Segmented / picker controls
      case 'mainaxisalignment':
      case 'mainaxisalignment.inspector': // legacy alias
      case 'mainaxisalignmentinspector': // legacy alias
        return DynamicPropertyKind.mainAxisAlignment;
      case 'crossaxisalignment':
      case 'crossaxisalignment.inspector': // legacy alias
      case 'crossaxisalignmentinspector': // legacy alias
        return DynamicPropertyKind.crossAxisAlignment;
      case 'mainaxissize':
      case 'mainaxissize.inspector': // legacy alias
      case 'mainaxissizeinspector': // legacy alias
        return DynamicPropertyKind.mainAxisSize;
      case 'axis':
      case 'axis.inspector': // legacy alias
      case 'axisinspector': // legacy alias
        return DynamicPropertyKind.axis;
      case 'textalign':
      case 'textalign.inspector': // legacy alias
      case 'textaligninspector': // legacy alias
        return DynamicPropertyKind.textAlign;

      // Composite controls
      case 'size':
      case 'size.inspector': // legacy alias
      case 'sizeinspector': // legacy alias
        return DynamicPropertyKind.size;
      case 'rotation':
      case 'rotation.inspector': // legacy alias
      case 'rotationinspector': // legacy alias
        return DynamicPropertyKind.rotation;
    }

    // Primitives
    switch (lower) {
      case 'string':
        return DynamicPropertyKind.string;
      case 'int':
      case 'integer':
        return DynamicPropertyKind.integer;
      case 'double':
      case 'num':
      case 'number':
        return DynamicPropertyKind.double;
      case 'bool':
      case 'boolean':
        return DynamicPropertyKind.boolean;
      case 'object':
        return DynamicPropertyKind.object;
      case 'json':
      case 'dynamic':
        return DynamicPropertyKind.json;
    }

    if (cleanType.isEmpty) {
      return DynamicPropertyKind.unknown;
    }

    // Complex custom types → JSON fallback
    return DynamicPropertyKind.json;
  }

  // ── Batch parsing ───────────────────────────────────────────────

  /// Parse a list or map of property definitions from JSON.
  static List<DynamicPropertyDefinition> listFromJson(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map(
            (item) => DynamicPropertyDefinition.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .where((item) => item.name.isNotEmpty)
          .toList();
    }

    if (raw is Map) {
      return _parseProperties(raw) ?? const [];
    }

    return const [];
  }

  static List<DynamicPropertyDefinition>? _parseProperties(
    dynamic rawProperties,
  ) {
    if (rawProperties is! Map) return null;

    final propertiesMap = Map<String, dynamic>.from(rawProperties);
    final results = <DynamicPropertyDefinition>[];

    for (final entry in propertiesMap.entries) {
      final value = entry.value;
      if (value is! Map) continue;

      final normalized = Map<String, dynamic>.from(value);
      normalized.putIfAbsent('name', () => entry.key);
      final parsed = DynamicPropertyDefinition.fromJson(normalized);
      if (parsed.name.isNotEmpty) results.add(parsed);
    }

    return results;
  }

  static DynamicPropertyDefinition? _parseItem(
    dynamic rawItem, {
    String fallbackName = 'item',
  }) {
    if (rawItem is! Map) return null;

    final normalized = Map<String, dynamic>.from(rawItem);
    normalized.putIfAbsent('name', () => fallbackName);
    final parsed = DynamicPropertyDefinition.fromJson(normalized);
    if (parsed.name.isEmpty) return null;
    return parsed;
  }
}
