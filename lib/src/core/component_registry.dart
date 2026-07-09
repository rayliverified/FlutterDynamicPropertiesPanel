import 'package:flutter/material.dart';

import '../models/dynamic_property_definition.dart';

/// Describes a component that can be selected in a widget slot picker.
class ComponentInfo {
  const ComponentInfo({
    required this.id,
    required this.name,
    this.description,
    this.icon = Icons.widgets_outlined,
    this.category,
    this.tags = const [],
    this.defaultConfig = const {},
    this.properties,
  });

  /// Unique identifier (e.g. file path or component key).
  final String id;

  /// Human-readable name.
  final String name;

  /// Optional short description.
  final String? description;

  /// Icon to display in the picker.
  final IconData icon;

  /// Optional category for grouping.
  final String? category;

  /// Tags for search filtering.
  final List<String> tags;

  /// Default configuration values when this component is selected.
  final Map<String, dynamic> defaultConfig;

  /// Optional property schema for this component's config.
  ///
  /// When provided, the panel can drill into the component's configuration
  /// and render editable controls for each property.
  final List<DynamicPropertyDefinition>? properties;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ComponentInfo && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Registry of available components for widget slot pickers.
///
/// Consumers register their project's components so the
/// [ComponentSlotControl] can offer them as choices.
///
/// ```dart
/// final registry = ComponentRegistry();
/// registry.register(ComponentInfo(
///   id: 'my_button',
///   name: 'MyButton',
///   description: 'Custom branded button',
///   category: 'Buttons',
/// ));
/// ```
class ComponentRegistry {
  final Map<String, ComponentInfo> _components = {};

  ComponentRegistry();

  // ── Registration ────────────────────────────────────────────────

  /// Register a single component.
  void register(ComponentInfo component) {
    _components[component.id] = component;
  }

  /// Register multiple components at once.
  void registerAll(List<ComponentInfo> components) {
    for (final c in components) {
      _components[c.id] = c;
    }
  }

  /// Unregister a component by ID.
  void unregister(String id) {
    _components.remove(id);
  }

  /// Clear all registered components.
  void clear() => _components.clear();

  // ── Lookup ──────────────────────────────────────────────────────

  /// Get a component by ID.
  ComponentInfo? getById(String id) => _components[id];

  /// All registered components.
  List<ComponentInfo> get all => _components.values.toList();

  /// Components filtered by category.
  List<ComponentInfo> byCategory(String category) =>
      all.where((c) => c.category == category).toList();

  /// Components matching a search query (name, description, tags).
  List<ComponentInfo> search(String query) {
    final lower = query.toLowerCase();
    return all.where((c) {
      return c.name.toLowerCase().contains(lower) ||
          (c.description?.toLowerCase().contains(lower) ?? false) ||
          c.tags.any((t) => t.toLowerCase().contains(lower));
    }).toList();
  }

  /// All unique categories present in the registry.
  List<String> get categories {
    final cats = <String>{};
    for (final c in _components.values) {
      if (c.category != null) cats.add(c.category!);
    }
    return cats.toList()..sort();
  }

  /// Number of registered components.
  int get length => _components.length;
}
