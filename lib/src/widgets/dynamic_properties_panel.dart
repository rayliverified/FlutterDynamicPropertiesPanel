import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

import '../controls/alignment_control.dart';
import '../controls/axis_control.dart';
import '../controls/border_radius_control.dart';
import '../controls/box_constraints_control.dart';
import '../controls/bound_text_input.dart';
import '../controls/color_control.dart';
import '../controls/icon_control.dart';
import '../controls/component_slot_control.dart';
import '../controls/cross_axis_alignment_control.dart';
import '../controls/date_control.dart';
import '../controls/duration_control.dart';
import '../controls/slider_control.dart';
import '../controls/edge_insets_control.dart';
import '../controls/json_text_box.dart';
import '../controls/json_view_edit_box.dart';
import '../controls/main_axis_alignment_control.dart';
import '../controls/main_axis_size_control.dart';
import '../controls/map_control.dart';
import '../controls/multi_select_control.dart';
import '../controls/preset_management_dialogs.dart';
import '../controls/preset_toolbar.dart';
import '../controls/reorderable_list_editor.dart';
import '../controls/rotation_control.dart';
import '../controls/size_control.dart';
import '../controls/suggestions_combo_control.dart';
import '../controls/text_align_control.dart';
import '../controls/text_style_control.dart';
import '../core/dynamic_properties_controller.dart';
import '../core/dynamic_properties_panel_manager.dart';
import '../core/navigation_controller.dart';
import '../models/dynamic_property_definition.dart';
import '../models/property_preset.dart';
import '../navigation/breadcrumb_bar.dart';

part 'property_helpers.dart';
part 'control_builders.dart';

/// Schema-driven dynamic properties panel with polished controls.
///
/// Renders editable controls for a set of properties. Property values are
/// held in a [DynamicPropertiesController] — either supplied by the caller
/// (for shared/bidirectional state) or created internally from [values].
///
/// ## Controller-based (recommended for preview sync or large schemas)
///
/// ```dart
/// final controller = DynamicPropertiesController(initial: loadedValues);
/// // ...
/// DynamicPropertiesPanel(controller: controller, properties: schema);
/// // Save snapshot on demand:
/// save(controller.snapshot());
/// // Or listen to commit events only:
/// controller.commits.listen(...);
/// ```
///
/// ## Map-based (backwards-compatible)
///
/// ```dart
/// DynamicPropertiesPanel(
///   values: myValues,
///   properties: schema,
///   onChanged: (updated) => setState(() => _values = updated),
/// )
/// ```
///
/// With the Map-based API, [onChanged] fires only on **committed** changes
/// (drag end, typing complete, preset applied) — NOT on every drag tick.
class DynamicPropertiesPanel extends StatefulWidget {
  /// Controller-based constructor. The caller owns + disposes [controller].
  const DynamicPropertiesPanel({
    super.key,
    this.controller,
    this.values,
    this.onChanged,
    this.properties,
    this.presets,
    this.onPresetSelected,
    this.onPresetsChanged,
    this.componentPresets,
    this.onComponentPresetsChanged,
    this.title,
    this.isDark,
    this.padding = EdgeInsets.zero,
    this.showContainer = true,
    this.showResetButtons = true,
    this.showBreadcrumbs = true,
    this.emptyWidget,
    this.smartLayout = false,
    this.manager,
    this.depth = 0,
  }) : assert(
         controller == null || values == null,
         'controller and values are mutually exclusive',
       ),
       assert(
         controller != null || values != null || properties != null,
         'Provide controller, values, or properties',
       );

  /// External controller. When provided, the panel does not own its
  /// lifecycle — the caller must dispose it.
  final DynamicPropertiesController? controller;

  /// Values for the internally owned controller. These override matching
  /// [DynamicPropertyDefinition.defaultValue] entries from [properties].
  /// Mutually exclusive with [controller].
  final Map<String, dynamic>? values;

  /// Called on **committed** changes (drag end, preset applied, etc.).
  /// Does NOT fire during drag ticks. Emits a deep-copied snapshot.
  final ValueChanged<Map<String, dynamic>>? onChanged;

  /// Optional control schema. When supplied, it is authoritative (including
  /// an empty list). When omitted, a basic schema is inferred from state.
  /// If no [controller] or [values] are supplied, defaults from this schema
  /// initialize an internally owned controller.
  final List<DynamicPropertyDefinition>? properties;

  /// Named presets for the root-level component.
  final List<PropertyPreset>? presets;

  /// Called when a preset is selected.
  final ValueChanged<PropertyPreset>? onPresetSelected;

  /// Called when the root preset list is modified (preset saved or deleted).
  final ValueChanged<List<PropertyPreset>>? onPresetsChanged;

  /// Presets for nested components, keyed by component ID.
  final Map<String, List<PropertyPreset>>? componentPresets;

  /// Called when a nested component's preset list is modified.
  final void Function(String componentId, List<PropertyPreset>)?
  onComponentPresetsChanged;

  final String? title;
  final bool? isDark;
  final EdgeInsetsGeometry padding;
  final bool showContainer;
  final bool showResetButtons;
  final bool showBreadcrumbs;

  /// Widget shown when the resolved property schema is empty. Defaults to a
  /// centered "No editable properties" message.
  final Widget? emptyWidget;

  /// When true, compact-width controls (integer, double, string, color,
  /// enum, date, duration, icon, boolean) may share a row with an adjacent
  /// property of the same category when the panel is wide enough. Full-width
  /// controls and nested objects/arrays always take a full row, so nested
  /// properties are never grouped with siblings at a different level.
  final bool smartLayout;

  /// Optional manager override. Defaults to [DynamicPropertiesPanelManager.instance].
  final DynamicPropertiesPanelManager? manager;

  /// Current nesting depth. Incremented for each nested object panel.
  /// Expandable rendering is disabled at depth >= 3.
  final int depth;

  @override
  State<DynamicPropertiesPanel> createState() => _DynamicPropertiesPanelState();
}

class _DynamicPropertiesPanelState extends State<DynamicPropertiesPanel>
    with TickerProviderStateMixin {
  /// The active controller. Either external (widget.controller) or internal
  /// (created from widget.values). Assigned in initState / didUpdateWidget.
  late DynamicPropertiesController _controller;

  /// True when we own and must dispose [_controller].
  bool _ownsController = false;

  /// Subscription to controller.commits — used to drive the Map-based
  /// `onChanged` callback when the caller is using the Map API.
  StreamSubscription<PropertyChange>? _commitsSub;

  /// Scroll controllers created per-view; disposed when replaced or on widget dispose.
  final List<ScrollController> _scrollControllers = [];

  /// The navigation depth we're currently displaying.
  int _displayedDepth = 0;

  // ── Preset state ─────────────────────────────────────────────────
  List<PropertyPreset> _presetConfigurations = [];
  String? _selectedPresetId;

  /// Presets for nested components, keyed by component ID.
  /// Local copy of widget.componentPresets; synced in didUpdateWidget.
  Map<String, List<PropertyPreset>> _componentPresetConfigurations = {};

  /// Track selected preset IDs for nested components.
  /// Key format: nav stack path, e.g. "child.inner"
  final Map<String, String> _nestedPresetSelections = {};

  DynamicPropertiesPanelManager get _manager =>
      widget.manager ?? DynamicPropertiesPanelManager.instance;

  NavigationController get _nav => _manager.navigationController;

  bool get _isDark =>
      widget.isDark ?? Theme.of(context).brightness == Brightness.dark;

  /// True when the host has opted into the preset system (even with an empty list).
  bool get _hasPresets => widget.presets != null;

  @override
  void initState() {
    super.initState();
    _attachController();
    _initPresets();
    _componentPresetConfigurations = _deepCopyComponentPresets(
      widget.componentPresets,
    );
    if (widget.showBreadcrumbs) {
      _nav.addListener(_onNavigationChanged);
    }
  }

  /// Attach the active controller — external or newly-created — and subscribe
  /// to its commits stream to power the Map-based [widget.onChanged] callback.
  void _attachController() {
    final defaults = _propertyDefaults(widget.properties);
    if (widget.controller != null) {
      _controller = widget.controller!;
      _ownsController = false;
      final missingDefaults = <String, dynamic>{
        for (final entry in defaults.entries)
          if (!_controller.hasValue(entry.key)) entry.key: entry.value,
      };
      if (missingDefaults.isNotEmpty) {
        _controller.applyAllSilent(missingDefaults);
      }
    } else {
      _controller = DynamicPropertiesController(
        initial: <String, dynamic>{...defaults, ...?widget.values},
      );
      _ownsController = true;
    }
    _commitsSub = _controller.commits.listen(_onControllerCommit);
  }

  Map<String, dynamic> _propertyDefaults(
    List<DynamicPropertyDefinition>? properties,
  ) {
    if (properties == null) return const <String, dynamic>{};
    return <String, dynamic>{
      for (final property in properties)
        if (property.defaultValue != null) property.name: property.defaultValue,
    };
  }

  /// Called whenever the controller emits a committed change. Mirrors the
  /// change to the legacy Map-based [widget.onChanged] callback, and also
  /// keeps preset-selection state in sync so the preset toolbar highlights
  /// the right entry after external mutations (including bidirectional sync
  /// from components writing back to the controller).
  void _onControllerCommit(PropertyChange _) {
    _syncSelectedPresetFromValues();
    // setState so the preset toolbar / reset-button affordances rebuild.
    if (mounted) setState(() {});
    widget.onChanged?.call(_controller.snapshot());
  }

  void _initPresets() {
    if (!_hasPresets) return;
    _presetConfigurations = List<PropertyPreset>.from(widget.presets!);
    final hasDefault = _presetConfigurations.any((p) => p.id == 'default');
    if (hasDefault) {
      _selectedPresetId = 'default';
    } else if (_presetConfigurations.isNotEmpty) {
      _selectedPresetId = _presetConfigurations.first.id;
    } else {
      _selectedPresetId = 'default';
    }
  }

  @override
  void dispose() {
    _commitsSub?.cancel();
    if (_ownsController) {
      _controller.dispose();
    }
    if (widget.showBreadcrumbs) {
      _nav.removeListener(_onNavigationChanged);
    }
    for (final c in _scrollControllers) {
      c.dispose();
    }
    _scrollControllers.clear();
    super.dispose();
  }

  void _onNavigationChanged() {
    // Save the current scroll offset before the view changes.
    final lastController = _scrollControllers.lastOrNull;
    if (lastController != null && lastController.hasClients) {
      _nav.saveScrollOffset(_displayedDepth, lastController.offset);
    }
    _displayedDepth = _nav.depth;

    setState(() {});
  }

  @override
  void didUpdateWidget(covariant DynamicPropertiesPanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Controller swap — rare but supported.
    if (oldWidget.controller != widget.controller) {
      _commitsSub?.cancel();
      if (_ownsController) {
        _controller.dispose();
      }
      _attachController();
    } else if (_ownsController &&
        widget.values != null &&
        !mapEquals(oldWidget.values, widget.values)) {
      // Map-based API: parent pushed new values. Apply without commit so we
      // don't echo back to the host that just told us about this change.
      // External value push from the host — don't echo back to onChanged.
      _controller.applyAllSilent(widget.values!);
    }

    // Sync preset list from parent (e.g. after persistence round-trip)
    if (widget.presets != null && widget.presets != oldWidget.presets) {
      _presetConfigurations = List<PropertyPreset>.from(widget.presets!);
      if (_selectedPresetId != null &&
          !_presetConfigurations.any((p) => p.id == _selectedPresetId)) {
        _selectedPresetId = _presetConfigurations.isNotEmpty
            ? _presetConfigurations.first.id
            : 'default';
      }
    }
    if (widget.presets != oldWidget.presets ||
        (oldWidget.values != null &&
            !mapEquals(oldWidget.values, widget.values))) {
      _syncSelectedPresetFromValues();
    }
    // Sync component presets from parent
    if (widget.componentPresets != oldWidget.componentPresets) {
      _componentPresetConfigurations = _deepCopyComponentPresets(
        widget.componentPresets,
      );
    }
  }

  /// Creates a [ScrollController] that restores the saved offset for [depth].
  ScrollController _scrollControllerForDepth(int depth) {
    final saved = _nav.consumeScrollOffset(depth);
    final controller = ScrollController(initialScrollOffset: saved ?? 0.0);
    // Clean up old controllers that are no longer attached (animation done).
    _scrollControllers.removeWhere((c) {
      if (!c.hasClients) {
        c.dispose();
        return true;
      }
      return false;
    });
    _scrollControllers.add(controller);
    return controller;
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    // Sub-panels (showBreadcrumbs: false) just render the root view directly.
    if (!widget.showBreadcrumbs) {
      return _buildRootView(brightness);
    }

    final isNested = !_nav.isAtRoot;
    final forward = _nav.lastTransitionWasForward;

    final content = isNested
        ? _buildNavigatedView(brightness)
        : _buildRootView(brightness);

    final animatedContent = ClipRect(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              ...previousChildren,
              // ignore: use_null_aware_elements
              if (currentChild case final child?) child,
            ],
          );
        },
        transitionBuilder: (child, animation) {
          final isIncoming = child.key == ValueKey<int>(_nav.depth);
          final Offset beginOffset;
          if (isIncoming) {
            beginOffset = forward
                ? const Offset(1.0, 0.0)
                : const Offset(-1.0, 0.0);
          } else {
            beginOffset = forward
                ? const Offset(-1.0, 0.0)
                : const Offset(1.0, 0.0);
          }
          return SlideTransition(
            position: Tween<Offset>(
              begin: beginOffset,
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        child: KeyedSubtree(key: ValueKey<int>(_nav.depth), child: content),
      ),
    );

    // When inside a bounded parent, use Expanded; otherwise shrink-wrap.
    return LayoutBuilder(
      builder: (context, constraints) {
        final bounded = constraints.hasBoundedHeight;
        return Column(
          mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preset toolbar — fixed above scroll, full-width, only at root
            if (!isNested && _hasPresets)
              PresetToolbar(
                presets: _getAllPresets(),
                selectedPresetId: _selectedPresetId,
                onPresetChanged: _onPresetDropdownChanged,
                onSave: _hasPresetModifications() ? _saveCurrentAsPreset : null,
                onReset: _hasPresetModifications()
                    ? _resetToCurrentPreset
                    : null,
                onDelete: _deleteCurrentPreset,
                hasModifications: _hasPresetModifications(),
              ),
            // Breadcrumb bar — fixed above scroll, full-width, only nested
            if (isNested) BreadcrumbBar(controller: _nav, isDark: _isDark),
            // Nested component preset toolbar — shown below breadcrumbs
            if (isNested) _buildNestedPresetToolbar(),
            if (bounded) Expanded(child: animatedContent) else animatedContent,
          ],
        );
      },
    );
  }

  // ── Nested component presets ─────────────────────────────────────

  /// Build the nav path key for nested preset selection tracking.
  String _nestedPresetPath() {
    return _nav.stack.map((l) => l.label).join('.');
  }

  /// Build a PresetToolbar for the nested component.
  Widget _buildNestedPresetToolbar() {
    final level = _nav.currentLevel;
    if (level == null) return const SizedBox.shrink();
    final componentId = level.schema?['componentId'] as String?;
    if (componentId == null) return const SizedBox.shrink();

    final savedPresets = List<PropertyPreset>.from(
      _componentPresetConfigurations[componentId] ?? [],
    );
    final nestedValues = level.value is Map
        ? Map<String, dynamic>.from(level.value as Map)
        : <String, dynamic>{};
    final path = _nestedPresetPath();

    // Synthesize Default from ComponentInfo.defaultConfig if not already present.
    final component = _manager.componentRegistry.getById(componentId);
    final List<PropertyPreset> presets;
    if (savedPresets.any((p) => p.id == 'default')) {
      presets = savedPresets;
    } else {
      presets = [
        PropertyPreset(
          id: 'default',
          name: 'Default',
          values: Map<String, dynamic>.from(component?.defaultConfig ?? {}),
        ),
        ...savedPresets,
      ];
    }

    // Determine selected preset — stored selection, or try to match values.
    String? selectedId = _nestedPresetSelections[path];
    if (selectedId == null) {
      for (final preset in presets) {
        if (preset.matches(nestedValues)) {
          selectedId = preset.id;
          break;
        }
      }
      selectedId ??= 'default';
    }

    final selectedPreset = presets.where((p) => p.id == selectedId).firstOrNull;
    final hasMods =
        selectedPreset != null &&
        !PropertyPreset.mapsEqual(nestedValues, selectedPreset.values);

    return PresetToolbar(
      presets: presets,
      selectedPresetId: selectedId,
      hasModifications: hasMods,
      onPresetChanged: (id) {
        final preset = presets.where((p) => p.id == id).firstOrNull;
        if (preset == null) return;
        _nestedPresetSelections[path] = preset.id;
        final schema = level.schema;
        final updatedConfig = _deepCopyMap(preset.values);
        _nav.replaceTop(level.copyWith(value: updatedConfig));
        _onNestedConfigChanged(schema, updatedConfig);
      },
      onSave: () =>
          _saveNestedPreset(componentId, selectedId, presets, nestedValues),
      onReset: hasMods
          ? () {
              final schema = level.schema;
              final resetConfig = _deepCopyMap(selectedPreset.values);
              _nav.replaceTop(level.copyWith(value: resetConfig));
              _onNestedConfigChanged(schema, resetConfig);
            }
          : null,
      onDelete: (selectedId != 'default' && presets.isNotEmpty)
          ? () => _deleteNestedPreset(componentId, selectedId, presets, path)
          : null,
    );
  }

  void _saveNestedPreset(
    String componentId,
    String? selectedId,
    List<PropertyPreset> currentPresets,
    Map<String, dynamic> currentValues,
  ) {
    showSavePresetDialog(
      context,
      selectedPresetId: selectedId,
      presets: currentPresets,
      onSave: (name, description) {
        final existingIndex = currentPresets.indexWhere(
          (p) => p.name == name && p.id != 'default',
        );
        List<PropertyPreset> updated;
        String newId;
        if (existingIndex != -1) {
          final existing = currentPresets[existingIndex];
          newId = existing.id;
          final updatedPreset = PropertyPreset(
            id: newId,
            name: name,
            description: description.isNotEmpty ? description : null,
            values: _deepCopyMap(currentValues),
          );
          updated = List.from(currentPresets);
          updated[existingIndex] = updatedPreset;
        } else {
          newId = 'custom_${DateTime.now().millisecondsSinceEpoch}';
          final newPreset = PropertyPreset(
            id: newId,
            name: name,
            description: description.isNotEmpty ? description : null,
            values: _deepCopyMap(currentValues),
          );
          updated = [...currentPresets, newPreset];
        }
        setState(() {
          _componentPresetConfigurations[componentId] = updated;
          _nestedPresetSelections[_nestedPresetPath()] = newId;
        });
        widget.onComponentPresetsChanged?.call(componentId, updated);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Preset "$name" saved')));
        }
      },
    );
  }

  void _deleteNestedPreset(
    String componentId,
    String? presetId,
    List<PropertyPreset> currentPresets,
    String path,
  ) {
    final preset = currentPresets.where((p) => p.id == presetId).firstOrNull;
    if (preset == null) return;
    showDeletePresetDialog(
      context,
      preset: preset,
      onDelete: () {
        final updated = currentPresets.where((p) => p.id != preset.id).toList();
        setState(() {
          _componentPresetConfigurations[componentId] = updated;
          _nestedPresetSelections[path] = updated.isNotEmpty
              ? updated.first.id
              : '';
        });
        widget.onComponentPresetsChanged?.call(componentId, updated);
      },
    );
  }

  /// Deep copy helper for component presets map.
  static Map<String, List<PropertyPreset>> _deepCopyComponentPresets(
    Map<String, List<PropertyPreset>>? source,
  ) {
    if (source == null) return {};
    return {
      for (final entry in source.entries)
        entry.key: List<PropertyPreset>.from(entry.value),
    };
  }

  // ── Navigated (nested component) view ─────────────────────────────

  Widget _buildNavigatedView(Brightness brightness) {
    final level = _nav.currentLevel!;
    final nestedProperties =
        level.properties?.whereType<DynamicPropertyDefinition>().toList() ?? [];
    final nestedValues = level.value is Map
        ? Map<String, dynamic>.from(level.value as Map)
        : <String, dynamic>{};
    final schema = level.schema;

    Widget body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (nestedProperties.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'No editable properties',
              style: TextStyle(
                fontSize: SoftSaaSTokens.fontSizeXS,
                color: SoftSaaSTokens.tertiaryText(brightness),
              ),
            ),
          )
        else
          DynamicPropertiesPanel(
            values: nestedValues,
            properties: nestedProperties,
            isDark: _isDark,
            showContainer: false,
            showResetButtons: widget.showResetButtons,
            showBreadcrumbs: false,
            smartLayout: widget.smartLayout,
            padding: EdgeInsets.zero,
            manager: _manager,
            onChanged: (updatedConfig) {
              _onNestedConfigChanged(schema, updatedConfig);
            },
          ),
      ],
    );

    Widget content;
    if (!widget.showContainer) {
      content = body;
    } else {
      content = SoftSaaSPanel(child: body);
    }

    final scrollController = widget.showBreadcrumbs
        ? _scrollControllerForDepth(_nav.depth)
        : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: widget.padding,
          child: constraints.hasBoundedHeight
              ? ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.hasBoundedWidth
                        ? constraints.maxWidth
                        : 0,
                  ),
                  child: content,
                )
              : content,
        );
      },
    );
  }

  /// Propagate config changes from a nested component back to the parent values.
  void _onNestedConfigChanged(
    Map<String, dynamic>? schema,
    Map<String, dynamic> updatedConfig,
  ) {
    if (schema == null) return;
    final parameterName = schema['parameterName'] as String?;
    final componentId = schema['componentId'] as String?;
    if (parameterName == null || componentId == null) return;

    final currentLevel = _nav.currentLevel;
    if (currentLevel != null) {
      _nav.replaceTop(currentLevel.copyWith(value: updatedConfig));
    }

    final updatedSlot = {'componentId': componentId, 'config': updatedConfig};
    final listItemMatch = RegExp(r'^(.+)\[(\d+)\]$').firstMatch(parameterName);
    if (listItemMatch != null) {
      final listName = listItemMatch.group(1)!;
      final index = int.parse(listItemMatch.group(2)!);
      final current = _controller[listName];
      if (current is List && index < current.length) {
        final updatedList = List<dynamic>.from(current);
        updatedList[index] = updatedSlot;
        _controller.setValue(listName, updatedList);
      }
      return;
    }

    _controller.setValue(parameterName, updatedSlot);
  }

  // ── Preset management ────────────────────────────────────────────────

  List<PropertyPreset> _getAllPresets() {
    if (_presetConfigurations.any((p) => p.id == 'default')) {
      return _presetConfigurations;
    }
    if (_presetConfigurations.isNotEmpty) {
      return _presetConfigurations;
    }
    final defaultPreset = PropertyPreset(
      id: 'default',
      name: 'Default',
      description: 'Default configuration',
      values: _controller.snapshot(),
    );
    return [defaultPreset];
  }

  void _syncSelectedPresetFromValues() {
    if (!_hasPresets) return;
    final allPresets = _getAllPresets();
    final current = _controller.snapshotShallow();
    final matchingPreset = allPresets
        .where((preset) => PropertyPreset.mapsEqual(current, preset.values))
        .firstOrNull;
    if (matchingPreset != null) {
      _selectedPresetId = matchingPreset.id;
    }
  }

  Map<String, dynamic> _referenceConfig() {
    if (_selectedPresetId == null || _selectedPresetId == 'default') {
      final defaultPreset = _presetConfigurations
          .where((p) => p.id == 'default')
          .firstOrNull;
      return defaultPreset?.values ?? (widget.values ?? _controller.snapshot());
    }
    final preset = _presetConfigurations.firstWhere(
      (p) => p.id == _selectedPresetId,
      orElse: () => PropertyPreset(
        id: '',
        name: '',
        values: widget.values ?? _controller.snapshot(),
      ),
    );
    return preset.values;
  }

  bool _hasPresetModifications() {
    if (!_hasPresets) return false;
    return !PropertyPreset.mapsEqual(
      _controller.snapshotShallow(),
      _referenceConfig(),
    );
  }

  void _onPresetDropdownChanged(String? id) {
    if (id == null) return;
    final allPresets = _getAllPresets();
    final preset = allPresets.firstWhere(
      (p) => p.id == id,
      orElse: () => allPresets.first,
    );
    _selectedPresetId = preset.id;
    _controller.applyAll(_deepCopyMap(preset.values));
    widget.onPresetSelected?.call(preset);
  }

  void _saveCurrentAsPreset() {
    showSavePresetDialog(
      context,
      selectedPresetId: _selectedPresetId,
      presets: _presetConfigurations,
      onSave: _doSavePreset,
    );
  }

  void _doSavePreset(String name, String description) {
    setState(() {
      final existingIndex = _presetConfigurations.indexWhere(
        (p) => p.name == name && p.id != 'default',
      );

      if (existingIndex != -1) {
        final existing = _presetConfigurations[existingIndex];
        _presetConfigurations[existingIndex] = PropertyPreset(
          id: existing.id,
          name: name,
          description: description.isNotEmpty ? description : null,
          values: _controller.snapshot(),
        );
        _selectedPresetId = existing.id;
      } else {
        final newPreset = PropertyPreset(
          id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          description: description.isNotEmpty ? description : null,
          values: _controller.snapshot(),
        );
        _presetConfigurations.add(newPreset);
        _selectedPresetId = newPreset.id;
      }
    });
    widget.onPresetsChanged?.call(List.from(_presetConfigurations));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Preset "$name" saved')));
    }
  }

  void _resetToCurrentPreset() {
    _controller.applyAll(_deepCopyMap(_referenceConfig()));
  }

  void _deleteCurrentPreset() {
    if (_selectedPresetId == null || _selectedPresetId == 'default') return;
    final preset = _presetConfigurations.firstWhere(
      (p) => p.id == _selectedPresetId,
      orElse: () => PropertyPreset(id: '', name: '', values: const {}),
    );
    if (preset.id.isEmpty) return;

    showDeletePresetDialog(
      context,
      preset: preset,
      onDelete: () {
        setState(() {
          _presetConfigurations.removeWhere((p) => p.id == preset.id);
          _selectedPresetId = 'default';
        });
        final defaultRef = _presetConfigurations
            .where((p) => p.id == 'default')
            .firstOrNull;
        _controller.applyAll(
          _deepCopyMap(defaultRef?.values ?? widget.values ?? const {}),
        );
        widget.onPresetsChanged?.call(List.from(_presetConfigurations));
      },
    );
  }

  // ── Root view ─────────────────────────────────────────────────────

  /// Minimum usable width for a single half-width (0.5) control. Two of these
  /// must fit side-by-side for smart layout to pair them.
  static const double _smartLayoutMinHalfControlWidth = 160.0;

  /// Minimum panel width at which smart layout pairs two half-width controls
  /// into the same row. Below this width, everything falls back to full-width
  /// single-column rendering.
  static const double _smartLayoutPairThreshold =
      _smartLayoutMinHalfControlWidth * 2;

  /// Horizontal gap between paired half-width cells.
  static const double _smartLayoutPairGap = 10.0;

  Widget _buildRootView(Brightness brightness) {
    final properties = _resolveProperties();

    final scrollController = widget.showBreadcrumbs
        ? _scrollControllerForDepth(0)
        : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : double.infinity;

        Widget body = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.title != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                child: Text(
                  widget.title!,
                  style: TextStyle(
                    fontSize: SoftSaaSTokens.fontSizeSM,
                    fontWeight: SoftSaaSTokens.fontWeightSemibold,
                    color: SoftSaaSTokens.primaryText(brightness),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (properties.isEmpty)
              widget.emptyWidget ??
                  Center(
                    child: Text(
                      'No editable properties',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: SoftSaaSTokens.fontSizeXS,
                        color: SoftSaaSTokens.tertiaryText(brightness),
                      ),
                    ),
                  )
            else
              ..._buildPropertyRowWidgets(properties, availableWidth),
          ],
        );

        final content = widget.showContainer
            ? SoftSaaSPanel(child: body)
            : body;

        return SingleChildScrollView(
          controller: scrollController,
          padding: widget.padding,
          child: constraints.hasBoundedHeight
              ? ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.hasBoundedWidth
                        ? constraints.maxWidth
                        : 0,
                  ),
                  child: content,
                )
              : content,
        );
      },
    );
  }

  /// Produce the vertical list of property row widgets. When [smartLayout] is
  /// enabled and the panel is wide enough, consecutive half-width properties
  /// with the same category are paired into a single row.
  List<Widget> _buildPropertyRowWidgets(
    List<DynamicPropertyDefinition> properties,
    double availableWidth,
  ) {
    final canPair =
        widget.smartLayout && availableWidth >= _smartLayoutPairThreshold;

    final rows = <Widget>[];
    for (int i = 0; i < properties.length; i++) {
      final current = properties[i];
      final nextIndex = i + 1;
      final pair = canPair && nextIndex < properties.length
          ? _tryPair(current, properties[nextIndex])
          : false;

      if (pair) {
        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildPropertyRow(current)),
                const SizedBox(width: _smartLayoutPairGap),
                Expanded(child: _buildPropertyRow(properties[nextIndex])),
              ],
            ),
          ),
        );
        i++; // consume the paired neighbour
      } else {
        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildPropertyRow(current),
          ),
        );
      }
    }
    return rows;
  }

  /// Two properties can share a row iff both are half-width and share the
  /// same effective category. Categories keep numeric controls with numeric
  /// controls, colours with colours, etc. Nested kinds (object / array / map
  /// / json / widget) are always full-width, so they never pair — enforcing
  /// the "don't group across levels" rule naturally.
  bool _tryPair(DynamicPropertyDefinition a, DynamicPropertyDefinition b) {
    if (a.effectiveWidthFactor > 0.5 || b.effectiveWidthFactor > 0.5) {
      return false;
    }
    return a.effectiveCategory == b.effectiveCategory;
  }

  // ── Property Resolution ──────────────────────────────────────────

  List<DynamicPropertyDefinition> _resolveProperties() {
    // A non-null schema is authoritative, including an explicitly empty one.
    // Only infer controls when the caller omits [properties] altogether.
    if (widget.properties != null) {
      return widget.properties!;
    }
    // Infer from currently-touched keys in the controller.
    return _controller
        .snapshotShallow()
        .entries
        .map(
          (entry) => DynamicPropertyDefinition(
            name: entry.key,
            kind: _inferKindFromRuntime(entry.value),
            defaultValue: entry.value,
          ),
        )
        .toList();
  }

  // ── Property Row ─────────────────────────────────────────────────

  /// Each row binds to exactly one property's notifier. Only that row rebuilds
  /// when the property changes — the outer panel build() is not re-run.
  Widget _buildPropertyRow(DynamicPropertyDefinition property) {
    return ValueListenableBuilder<dynamic>(
      valueListenable: _controller.notifierFor(property.name),
      builder: (context, value, _) {
        final brightness = Theme.of(context).brightness;
        // Treat a null notifier value as "use the schema default" so controls
        // render meaningfully before the user has touched the property.
        final displayValue = value ?? property.defaultValue;
        final isModified = _isModified(property, displayValue);

        late final Widget row;
        if (property.kind == DynamicPropertyKind.boolean) {
          row = _buildBooleanRow(
            property,
            displayValue,
            brightness,
            isModified,
          );
        } else if (property.kind == DynamicPropertyKind.object &&
            widget.depth < 3) {
          final objectValue = displayValue is Map
              ? Map<String, dynamic>.from(displayValue)
              : <String, dynamic>{};
          final count = property.properties?.length ?? objectValue.length;
          if (count > 0) {
            row = _ExpandablePropertyRow(
              title: property.label,
              subtitle: '$count nested field${count == 1 ? '' : 's'}',
              isModified: isModified,
              onReset:
                  widget.showResetButtons && _controller.hasValue(property.name)
                  ? () => _setValue(property.name, property.defaultValue)
                  : null,
              defaultOpen: true,
              child: _buildControl(property, displayValue),
            );
          } else {
            row = const SizedBox.shrink();
          }
        } else {
          final control = _buildControl(property, displayValue);
          row = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (isModified) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 1, bottom: 1),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: SoftSaaSTokens.primaryColor(brightness),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    fit: FlexFit.loose,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        property.label,
                        style: TextStyle(
                          fontSize: SoftSaaSTokens.fontSizeXS,
                          fontWeight: SoftSaaSTokens.fontWeightSemibold,
                          color: SoftSaaSTokens.primaryText(brightness),
                        ),
                      ),
                    ),
                  ),
                  if (widget.showResetButtons &&
                      _controller.hasValue(property.name))
                    IconButton(
                      icon: Icon(
                        Icons.refresh,
                        size: 10,
                        color: SoftSaaSTokens.secondaryText(brightness),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      padding: EdgeInsets.zero,
                      tooltip: 'Reset',
                      onPressed: () =>
                          _setValue(property.name, property.defaultValue),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              control,
            ],
          );
        }

        return row;
      },
    );
  }

  // ── Boolean Row (full-width inline) ──────────────────────────────

  Widget _buildBooleanRow(
    DynamicPropertyDefinition property,
    dynamic value,
    Brightness brightness,
    bool isModified,
  ) {
    final boolValue = value is bool ? value : false;

    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (isModified) ...[
          Padding(
            padding: const EdgeInsets.only(top: 1, bottom: 1),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: SoftSaaSTokens.primaryColor(brightness),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 5),
        ],
        Padding(
          padding: EdgeInsets.only(bottom: 2),
          child: Text(
            _capitalize(property.label),
            style: TextStyle(
              fontSize: SoftSaaSTokens.fontSizeXS,
              fontWeight: SoftSaaSTokens.fontWeightSemibold,
              color: SoftSaaSTokens.primaryText(brightness),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),

        if (widget.showResetButtons && _controller.hasValue(property.name))
          IconButton(
            icon: Icon(
              Icons.refresh,
              size: 10,
              color: SoftSaaSTokens.secondaryText(brightness),
            ),
            constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
            padding: EdgeInsets.zero,
            tooltip: 'Reset',
            onPressed: () => _setValue(property.name, property.defaultValue),
          ),
        const Spacer(),
        SoftSaaSSwitch(
          value: boolValue,
          size: SoftSaaSCheckboxSize.small,
          onChanged: (next) => _setValue(property.name, next),
        ),
      ],
    );
  }
}
