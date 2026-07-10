---
format: api_reference
version: 1
---

# API Reference

# Dynamic Properties Panel — API Reference

## Setup

### Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  dynamic_properties_panel: ^1.0.0
```

Then import the umbrella library:

```dart
import 'package:dynamic_properties_panel/dynamic_properties_panel.dart';
```

### SoftSaaS UI Theme (optional but recommended)

The panel ships a bundled `SoftSaaSTheme` that provides consistent light/dark styling for all controls. Wrap your app with it:

```dart
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

MaterialApp(
  theme: SoftSaaSTheme.light(),
  darkTheme: SoftSaaSTheme.dark(),
  themeMode: ThemeMode.system,
  home: …,
);
```

Without this theme, the panel still renders but controls fall back to the default Flutter `ThemeData`.

### Registering Icons and Components

The global `DynamicPropertiesPanelManager` holds shared registries. Call this early in your app (e.g. in `initState` or `main`):

```dart
final manager = DynamicPropertiesPanelManager.instance;

// Icons — the default instance already includes 150+ Material icons.
// Add custom ones:
manager.iconRegistry.register('my_icon', Icons.ac_unit);

// Components for widget slot pickers:
manager.componentRegistry.register(ComponentInfo(
  id: 'hero_banner',
  name: 'HeroBanner',
  description: 'Full-width hero section',
  icon: Icons.image,
  category: 'Layout',
  defaultConfig: {'title': 'Welcome', 'height': 300.0},
  properties: DynamicPropertyDefinition.listFromJson([
    {'name': 'title', 'type': 'String'},
    {'name': 'height', 'type': 'double', 'bounds': {'minimum': 100, 'maximum': 800}},
  ]),
));
```

### Scoped Managers (testing / isolation)

Create isolated manager instances instead of using the global singleton:

```dart
final manager = DynamicPropertiesPanelManager(
  iconRegistry: IconRegistry.withMaterialDefaults(),
  componentRegistry: ComponentRegistry(),
);
DynamicPropertiesPanel(
  controller: controller,
  properties: schema,
  manager: manager,
);
```

### Property Schema Format

Properties are defined as `DynamicPropertyDefinition` instances, typically parsed from JSON-like maps via `DynamicPropertyDefinition.listFromJson`:

```dart
final properties = DynamicPropertyDefinition.listFromJson([
  {'name': 'title', 'type': 'String', 'description': 'Card heading'},
  {'name': 'fontSize', 'type': 'double', 'bounds': {'minimum': 8, 'maximum': 72, 'step': 1}},
  {'name': 'themeColor', 'type': 'Color'},
  {'name': 'padding', 'type': 'EdgeInsets'},
  {
    'name': 'layout',
    'type': 'object',
    'properties': {
      'radius': {'type': 'double'},
      'alignment': {'type': 'Alignment'},
    },
  },
  {'name': 'tags', 'type': 'List<String>', 'items': {'type': 'String'}},
  {
    'name': 'priority',
    'type': 'String',
    'enumValues': ['low', 'medium', 'high', 'critical'],
    'enumLabels': {'low': 'Low', 'medium': 'Medium', 'high': 'High', 'critical': 'Critical'},
  },
  {'name': 'child', 'type': 'Widget'},
]);
```

The `type` string is mapped to a `DynamicPropertyKind` via `DynamicPropertyDefinition.inferKind`. Common type aliases are supported (e.g. `"int"`, `"integer"`, `"number"`, `"num"` all map to `integer`/`double`; `"icon"` and `"IconData"` both map to `icon`).

## Usage Examples

> Full lifecycle boilerplate (controller creation, disposal, panel widget) is shown in Example 1. All subsequent examples assume that context and show only the distinctive code for each feature.

---

### Example 1 — Controller-based panel with full lifecycle

```dart
class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  late final DynamicPropertiesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DynamicPropertiesController(initial: {
      'title': 'My Card',
      'fontSize': 16.0,
      'themeColor': '#2563EB',
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicPropertiesPanel(
      controller: _controller,
      properties: DynamicPropertyDefinition.listFromJson([
        {'name': 'title', 'type': 'String'},
        {'name': 'fontSize', 'type': 'double', 'bounds': {'minimum': 8, 'maximum': 72}},
        {'name': 'themeColor', 'type': 'Color'},
      ]),
    );
  }
}
```

The controller provides granular rebuilds — changing `fontSize` only rebuilds that row's `ValueNotifier`, not the entire panel tree.

---

### Example 2 — Map-based panel (backwards-compatible)

```dart
DynamicPropertiesPanel(
  values: _values,
  properties: _schema,
  onChanged: (updated) => setState(() => _values = updated),
);
```

The panel creates an internal controller. `onChanged` fires only on committed changes (drag end, typing complete, preset applied), not on every drag tick.

---

### Example 3 — Bidirectional sync with a live preview

```dart
// Panel binds 'enabled' to its switch automatically.
DynamicPropertiesPanel(controller: _controller, properties: _schema);

// Your preview widget reads and writes the same controller.
Widget previewSwitch(DynamicPropertiesController ctrl) {
  final on = ctrl['enabled'] as bool? ?? false;
  return Switch(
    value: on,
    onChanged: (next) => ctrl['enabled'] = next,
    // The panel's corresponding row flips to match immediately.
  );
}
```

Any widget can participate in the shared state via the controller's per-key notifiers.

---

### Example 4 — Listening to changes at three tiers

```dart
// Tier 1: Single property — cheapest, for per-field rebuilds.
ValueListenableBuilder(
  valueListenable: controller.notifierFor('fontSize'),
  builder: (context, value, _) => Text('Size: $value'),
);

// Tier 2: Any change — for JSON preview, debug panels.
ListenableBuilder(
  listenable: controller,
  builder: (context, _) => JsonView(json: controller.snapshot()),
);

// Tier 3: Commit events — for persistence, analytics.
controller.commits.listen((change) {
  if (change.isBulk) {
    print('Bulk: ${change.bulkValues}');
  } else {
    print('Key: ${change.key} = ${change.value}');
  }
});
```

---

### Example 5 — Debounced persistence on commits

```dart
Timer? _saveTimer;
controller.commits.listen((_) {
  _saveTimer?.cancel();
  _saveTimer = Timer(const Duration(milliseconds: 300), () {
    saveToDisk(controller.snapshot());
  });
});
```

---

### Example 6 — Presets (save, restore, delete)

```dart
DynamicPropertiesPanel(
  controller: _controller,
  properties: _schema,
  presets: _presets,
  onPresetSelected: (preset) {
    // Fires when user selects a preset from dropdown.
    _controller.applyAll(preset.values);
  },
  onPresetsChanged: (updated) {
    setState(() => _presets = updated);
  },
  componentPresets: _componentPresets,
  onComponentPresetsChanged: (componentId, presets) {
    setState(() => _componentPresets[componentId] = presets);
  },
);
```

`PresetToolbar` can also be used standalone outside the panel for custom toolbar layouts.

---

### Example 7 — Nested object editing with breadcrumb navigation

```dart
DynamicPropertiesPanel(
  controller: _controller,
  properties: DynamicPropertyDefinition.listFromJson([
    {
      'name': 'padding',
      'type': 'EdgeInsets',
      'description': 'Card padding',
    },
    {
      'name': 'layout',
      'type': 'object',
      'properties': {
        'radius': {'type': 'BorderRadius'},
        'alignment': {'type': 'Alignment'},
      },
    },
    {
      'name': 'items',
      'type': 'List<String>',
      'items': {'type': 'String'},
    },
  ]),
  showBreadcrumbs: true,
);
```

Object properties expand inline (up to depth 3) and support drill-in navigation with `BreadcrumbBar`.

---

### Example 8 — Widget slot pickers

```dart
// Register components first:
DynamicPropertiesPanelManager.instance.componentRegistry.registerAll([
  ComponentInfo(
    id: 'my_button',
    name: 'BrandedButton',
    properties: DynamicPropertyDefinition.listFromJson([
      {'name': 'label', 'type': 'String'},
      {'name': 'variant', 'type': 'String', 'enumValues': ['primary', 'ghost']},
    ]),
  ),
]);

// Then use Widget type in schema:
DynamicPropertyDefinition.listFromJson([
  {'name': 'child', 'type': 'Widget'},
  {'name': 'children', 'type': 'List<Widget>'},
]);
```

Selecting a component with properties shows a drill-in gear icon for inline configuration editing.

---

### Example 9 — Enum, multi-enum, and suggestions

```dart
DynamicPropertyDefinition.listFromJson([
  // Single-select enum
  {
    'name': 'priority',
    'type': 'String',
    'enumValues': ['low', 'medium', 'high'],
    'enumLabels': {'low': 'Low Priority', 'medium': 'Medium', 'high': 'High'},
  },
  // Multi-select enum
  {
    'name': 'features',
    'type': 'String',
    'enumValues': ['search', 'sort', 'filter', 'pagination'],
    'multiSelect': true,
    'enumIconNames': {'search': 'search', 'sort': 'sort'},
  },
  // Free-text with suggestions combo
  {
    'name': 'fontFamily',
    'type': 'String',
    'suggestions': ['Inter', 'Roboto', 'Open Sans', 'Lato'],
  },
]);
```

---

### Example 10 — Smart layout, dark mode, and advanced options

```dart
DynamicPropertiesPanel(
  controller: _controller,
  properties: _schema,
  title: 'Card Properties',
  isDark: true,
  smartLayout: true,
  showContainer: true,
  showResetButtons: true,
  showBreadcrumbs: true,
  padding: const EdgeInsets.all(12),
  manager: myScopedManager,
  depth: 0,
);
```

`smartLayout` pairs adjacent compact-width controls (numbers, strings, colors, enums, etc.) on the same row when they share the same effective category.

## Reference

### DynamicPropertiesController

Central state container for property values. Holds per-key `ValueNotifier`s so changing one property only rebuilds listeners of that property. Extends `ChangeNotifier`.

**Constructors:** `DynamicPropertiesController({Map<String, dynamic> initial = const {}})`

| Member | Description |
|--------|-------------|
| `ValueNotifier<dynamic> notifierFor(String key)` | Returns notifier for `key`, creating one if absent. Accessing does NOT mark as touched. |
| `dynamic operator [](String key)` | Current value for `key` without subscribing. Returns `null` if never set. |
| `void operator []=(String key, dynamic value)` | Write and fire all listeners + commits stream. Equivalent to `setValue`. |
| `bool hasValue(String key)` | Whether `key` has been explicitly set (touched semantics). |
| `Iterable<String> get touchedKeys` | Set of keys that have been explicitly set. |
| `void setValue(String key, dynamic value)` | Update a property and fire per-key notifier, `notifyListeners`, and `commits` stream. |
| `void applyAll(Map<String, dynamic> values)` | Bulk-replace multiple values; each affected notifier fires once, then one bulk `PropertyChange` emitted on `commits`. |
| `void remove(String key)` | Remove a property entirely (disposes its notifier). |
| `Map<String, dynamic> snapshot()` | Deep-copied snapshot of all touched, non-null values. Safe for persistence. |
| `Map<String, dynamic> snapshotShallow()` | Shallow snapshot — same keys without JSON deep copy. |
| `Stream<PropertyChange> get commits` | Fires on every write. Consumers should debounce if persisting. |
| `void dispose()` | Mandatory — disposes all notifiers and closes commits stream. |

### PropertyChange

Describes a change emitted by `DynamicPropertiesController.commits`.

| Member | Description |
|--------|-------------|
| `const PropertyChange(String? key, dynamic value)` | Single-key commit. `bulkValues` is `null`. |
| `const PropertyChange.bulk(Map<String, dynamic> bulkValues)` | Bulk commit (e.g. preset application). `key`/`value` are `null`. |
| `String? get key` | Affected key for single commits. |
| `dynamic get value` | New value for single commits. |
| `Map<String, dynamic>? get bulkValues` | All affected values for bulk commits. |
| `bool get isBulk` | Whether this is a bulk commit. |

### DynamicPropertiesPanel

Top-level stateful widget that renders editable controls for a set of property definitions. Accepts either an external `DynamicPropertiesController` or a simple `values` map.

**Constructors:** `const DynamicPropertiesPanel({…})`

| Member | Description |
|--------|-------------|
| `DynamicPropertiesController? controller` | External controller. Caller owns lifecycle. |
| `Map<String, dynamic>? values` | Initial values; panel creates internal controller when `controller` is null. |
| `ValueChanged<Map<String, dynamic>>? onChanged` | Called on committed changes (drag end, preset applied). Emits deep-copied snapshot. |
| `List<DynamicPropertyDefinition>? properties` | Property schema defining controls to render. |
| `List<PropertyPreset>? presets` | Named presets for root-level component. |
| `ValueChanged<PropertyPreset>? onPresetSelected` | Called when a preset is selected. |
| `ValueChanged<List<PropertyPreset>>? onPresetsChanged` | Called when root preset list is modified. |
| `Map<String, List<PropertyPreset>>? componentPresets` | Presets for nested components, keyed by component ID. |
| `void Function(String componentId, List<PropertyPreset>)? onComponentPresetsChanged` | Called when a nested component's preset list is modified. |
| `String? title` | Optional panel title. |
| `bool? isDark` | Override dark mode detection. Defaults to theme brightness. |
| `EdgeInsetsGeometry padding` | Inner padding. Defaults to `EdgeInsets.zero`. |
| `bool showContainer` | Whether to wrap in a bordered container. Defaults to `true`. |
| `bool showResetButtons` | Whether to show per-property reset buttons. Defaults to `true`. |
| `bool showBreadcrumbs` | Whether to show the breadcrumb navigation bar. Defaults to `true`. |
| `bool smartLayout` | When `true`, compact-width controls may share rows with adjacent same-category properties. Defaults to `false`. |
| `DynamicPropertiesPanelManager? manager` | Optional manager override. Defaults to `DynamicPropertiesPanelManager.instance`. |
| `int depth` | Current nesting depth. Incremented for each nested object panel. |

### DynamicPropertyKind

Enumeration of all supported property control types.

| Value | Description |
|-------|-------------|
| `string` | Text input control. |
| `integer` | Integer numeric input with stepper. |
| `double` | Double numeric input with stepper. |
| `boolean` | Toggle switch. |
| `enumValue` | Single-select dropdown from `enumValues`. |
| `multiEnum` | Multi-select dropdown (requires `multiSelect: true` in schema). |
| `object` | Nested object with inline property controls or JSON fallback. |
| `array` | Reorderable list editor for primitive arrays; JSON fallback for complex items. |
| `map` | Key-value map editor with add/remove. |
| `icon` | Icon name picker (stores string name). |
| `iconSwatch` | Icon swatch grid picker. |
| `color` | Color swatch + hex input. |
| `colorSwatch` | Standalone color swatch button. |
| `date` | Platform date picker (stores ISO-8601 string). |
| `duration` | H/M/S/ms fields (stores milliseconds int). |
| `slider` | Inline range slider. |
| `alignment` | 3×3 alignment grid picker. |
| `edgeInsets` | 2×2 edge inset number inputs with uniform lock. |
| `borderRadius` | 2×2 corner radius inputs with uniform lock. |
| `boxConstraints` | Min/max width/height inputs. |
| `textStyle` | Rich-text editor with markdown toolbar. |
| `mainAxisAlignment` | MainAxisAlignment segmented picker. |
| `crossAxisAlignment` | CrossAxisAlignment segmented picker. |
| `mainAxisSize` | MainAxisSize segmented picker. |
| `axis` | Axis picker. |
| `textAlign` | TextAlign picker. |
| `size` | Width/height inspector. |
| `rotation` | Rotation angle dial. |
| `widget` | Component slot picker. |
| `widgetList` | List of component slot pickers with add button. |
| `json` | Raw JSON editor (text or tree view). |
| `unknown` | Fallback to JSON editor. |

### DynamicPropertyDefinition

Schema definition for a single editable property. The panel uses this to select the correct control widget automatically.

**Constructors:** `const DynamicPropertyDefinition({required String name, required DynamicPropertyKind kind, …})`, `factory DynamicPropertyDefinition.fromJson(Map<String, dynamic> json)`

| Member | Description |
|--------|-------------|
| `String name` | Property key in the values map. |
| `DynamicPropertyKind kind` | Type of control to render. |
| `String? title` | Optional display title; falls back to `name`. |
| `String? description` | Optional description shown below label. |
| `dynamic defaultValue` | Default value when property hasn't been set. |
| `bool required` | Whether the property must have a value. |
| `List<dynamic>? enumValues` | Allowed values for `enumValue` / `multiEnum` kinds. |
| `Map<String, String>? enumLabels` | Display labels for enum values. |
| `Map<String, String>? enumIconNames` | Icon names for enum values, resolved via `IconRegistry`. |
| `Map<String, dynamic>? bounds` | Numeric/string constraints (`minimum`, `maximum`, `step`, `minLength`, `maxLength`, `suffix`, `decimalPlaces`, `showOpacity`, `allowedIcons`). |
| `List<DynamicPropertyDefinition>? properties` | Nested property definitions for `object` kind. |
| `DynamicPropertyDefinition? item` | Item definition for `array` kind. |
| `String? rawType` | Original Dart type string from schema. |
| `String? iconName` | Initial icon name for `icon` kind. |
| `List<String>? suggestions` | Freeform suggestions for combo input on `string` kind. |
| `double? widthFactor` | Explicit width factor for smart layout (`1.0` or `0.5`). |
| `String? category` | Explicit category for smart-layout grouping. |
| `String get label` | Human-readable label (title or name). |
| `double get effectiveWidthFactor` | Inferred width factor (`widthFactor` or kind-based default). |
| `String get effectiveCategory` | Inferred category (`category` or kind-based default). |
| `DynamicPropertyDefinition copyWith(…)` | Supports `copyWith`. |
| `static List<DynamicPropertyDefinition> listFromJson(dynamic raw)` | Parse a list or map of definitions from JSON-like data. |
| `static DynamicPropertyKind inferKind(String? rawType, {…})` | Infer kind from raw type string and optional metadata. |

### PropertyPreset

Named preset configuration that can be applied to the panel.

**Constructors:** `const PropertyPreset({required String id, required String name, …})`, `factory PropertyPreset.fromJson(Map<String, dynamic> json)`

| Member | Description |
|--------|-------------|
| `String id` | Unique identifier. |
| `String name` | Display name in preset selector. |
| `String? description` | Optional description. |
| `Map<String, dynamic> values` | Parameter values for this preset. |
| `PropertyPreset copyWith(…)` | Supports `copyWith`. |
| `Map<String, dynamic> toJson()` | Serialize to JSON map. |
| `bool matches(Map<String, dynamic> other)` | Deep equality check against another values map. |
| `static List<PropertyPreset> listFromJson(dynamic raw)` | Deserialize a list of presets from JSON. |

### DynamicPropertiesPanelManager

Global manager holding shared instances of `NavigationController`, `IconRegistry`, and `ComponentRegistry`.

**Constructors:** `DynamicPropertiesPanelManager._default()` (private singleton), `DynamicPropertiesPanelManager({NavigationController? navigationController, IconRegistry? iconRegistry, ComponentRegistry? componentRegistry})`

| Member | Description |
|--------|-------------|
| `static final DynamicPropertiesPanelManager instance` | Shared global instance with Material icon defaults. |
| `NavigationController navigationController` | Navigation controller for nested property drill-in. |
| `IconRegistry iconRegistry` | Icon registry for icon picker controls. |
| `ComponentRegistry componentRegistry` | Component registry for widget slot picker controls. |

### NavigationController

Manages navigation state for nested property editing. Maintains a stack of `NavigationLevel`s. Extends `ChangeNotifier`.

**Constructors:** `NavigationController()`

| Member | Description |
|--------|-------------|
| `List<NavigationLevel> get stack` | Current navigation stack (unmodifiable). |
| `NavigationLevel? get currentLevel` | The deepest level, or `null` at root. |
| `bool get isAtRoot` | Whether the stack is empty. |
| `int get depth` | Current stack depth. |
| `List<NavigationBreadcrumb> get breadcrumbs` | Breadcrumb-friendly list with optional `onTap` callbacks. |
| `bool get lastTransitionWasForward` | Direction of the last transition. |
| `void push(NavigationLevel level)` | Push a new level onto the stack. |
| `void pop()` | Pop the top level from the stack. |
| `void popTo(int index)` | Pop to a specific stack index (inclusive). |
| `void replaceTop(NavigationLevel level)` | Replace the top level without double notification. |
| `void clear()` | Clear entire stack (return to root). |
| `void navigateInto({required String label, String? type, dynamic value, Map<String, dynamic>? schema, List<dynamic>? properties})` | Convenience push. |
| `void navigateBack()` | Convenience pop. |
| `void navigateToRoot()` | Convenience clear. |
| `void saveScrollOffset(int depth, double offset)` | Save scroll position for a given depth. |
| `double? consumeScrollOffset(int depth)` | Retrieve and clear saved scroll offset. |
| `void dispose()` | Clear stack and dispose listeners. |

### NavigationLevel & NavigationBreadcrumb

`NavigationLevel` captures the context for one level in the navigation stack. `NavigationBreadcrumb` wraps a level with a `bool isCurrent` flag and optional `onTap`.

| Member | Description |
|--------|-------------|
| `NavigationLevel({required String label, String? type, dynamic value, Map<String, dynamic>? schema, List<dynamic>? properties})` | Constructor. |
| `bool get isListItem` | Whether this level represents a list item. |
| `NavigationLevel copyWith(…)` | Supports `copyWith`. |
| `NavigationBreadcrumb({required NavigationLevel level, required bool isCurrent, VoidCallback? onTap})` | Constructor. |

### IconRegistry

Stores `String → IconData` mappings. Case-insensitive lookup.

**Constructors:** `IconRegistry()`, `IconRegistry.withMaterialDefaults()`

| Member | Description |
|--------|-------------|
| `void register(String name, IconData icon)` | Register a single named icon. |
| `void registerAll(Map<String, IconData> icons)` | Register all icons from a map. |
| `void unregister(String name)` | Remove a named icon. |
| `void clear()` | Clear all registered icons. |
| `IconData? getIcon(String name)` | Look up by name (case-insensitive). |
| `bool hasIcon(String name)` | Whether a name is registered. |
| `List<String> get allNames` | All names, sorted alphabetically. |
| `int get length` | Number of registered icons. |
| `IconData? parse(dynamic value)` | Parse `IconData`, `String`, `Map`, or `int` into `IconData`. |
| `String? iconName(IconData? icon)` | Reverse lookup: icon → name. |
| `static Map<String, IconData> get materialDefaults` | 150+ pre-built Material icon mappings. |

### ComponentRegistry

Registry of `ComponentInfo` entries for widget slot pickers.

**Constructors:** `ComponentRegistry()`

| Member | Description |
|--------|-------------|
| `void register(ComponentInfo component)` | Register a single component. |
| `void registerAll(List<ComponentInfo> components)` | Register multiple components. |
| `void unregister(String id)` | Remove by ID. |
| `void clear()` | Clear all. |
| `ComponentInfo? getById(String id)` | Get component by ID. |
| `List<ComponentInfo> get all` | All registered components. |
| `List<ComponentInfo> byCategory(String category)` | Components filtered by category. |
| `List<ComponentInfo> search(String query)` | Components matching search query (name, description, tags). |
| `List<String> get categories` | All unique categories, sorted. |
| `int get length` | Number of registered components. |

### ComponentInfo

Describes a selectable component for the slot picker.

**Constructors:** `const ComponentInfo({required String id, required String name, …})`

| Member | Description |
|--------|-------------|
| `String id` | Unique identifier. |
| `String name` | Human-readable name. |
| `String? description` | Optional short description. |
| `IconData icon` | Icon displayed in picker. Defaults to `Icons.widgets_outlined`. |
| `String? category` | Optional category for grouping. |
| `List<String> tags` | Tags for search filtering. |
| `Map<String, dynamic> defaultConfig` | Default config values when selected. |
| `List<DynamicPropertyDefinition>? properties` | Optional property schema for this component's config. |

### BreadcrumbBar

Renders the `NavigationController` stack as clickable breadcrumbs. Styled with SoftSaaS tokens.

**Constructors:** `const BreadcrumbBar({required NavigationController controller, bool? isDark, VoidCallback? onHomePressed})`

| Member | Description |
|--------|-------------|
| `NavigationController controller` | Navigation controller driving the breadcrumbs. |
| `bool? isDark` | Override dark mode. Defaults to theme brightness. |
| `VoidCallback? onHomePressed` | Called when home icon is tapped. Defaults to `navigateToRoot`. |

### PresetToolbar

Toolbar for managing presets — dropdown selector, save/reset/delete actions, and a modification indicator dot.

**Constructors:** `const PresetToolbar({required List<PropertyPreset> presets, required String? selectedPresetId, required ValueChanged<String?> onPresetChanged, …})`

| Member | Description |
|--------|-------------|
| `List<PropertyPreset> presets` | Available presets. |
| `String? selectedPresetId` | Currently selected preset ID. |
| `ValueChanged<String?> onPresetChanged` | Called when a preset is selected from dropdown. |
| `VoidCallback? onSave` | Called when save button is pressed. |
| `VoidCallback? onReset` | Called when reset button is pressed. |
| `VoidCallback? onDelete` | Called when delete button is pressed. |
| `bool hasModifications` | Whether unsaved changes exist (shows blue dot). |

### PropertySection, LabeledField, NumberField, PresetButtonGroup, ToggleChip, InlineNumberInput

Reusable layout primitives from `property_section.dart`. All are `StatelessWidget`s or `StatefulWidget`s designed for inspector-style layouts.

| Class | Description |
|-------|-------------|
| `PropertySection({required String title, String? subtitle, IconData? icon, bool isModified, bool defaultOpen, required Widget child})` | Collapsible section wrapper delegating to `SoftSaaSExpandable`. |
| `LabeledField({required String label, required Widget child, String? hint})` | Compact label above a child control. |
| `NumberField({required String label, required double? value, double? min, double? max, double? step, String? suffix, ValueChanged<double?>? onChanged})` | Label-left, number-input-right row. |
| `PresetButtonGroup({required List<PresetOption> presets, required dynamic currentValue, required ValueChanged<dynamic> onSelected})` | Row of pill buttons with selected state. |
| `ToggleChip({required String label, IconData? icon, required bool isActive, required VoidCallback onPressed})` | Icon/text toggle chip for bold/italic/underline etc. |
| `InlineNumberInput({String? label, required double value, ValueChanged<double?>? onChanged})` | Compact number input for grid layouts. |

### Controls — Alignment, Axis, BorderRadius, BoxConstraints, EdgeInsets, Cross/MainAxisAlignment, MainAxisSize, TextAlign, Size, Rotation

Thin delegates over their corresponding `SoftSaaS*PickerInspector` widgets. All share the same pattern:

**Constructors:** `const XxxControl({required dynamic value, required ValueChanged<dynamic> onChanged})`

| Class | Value format (input) | Value format (output via `onChanged`) |
|-------|---------------------|---------------------------------------|
| `AlignmentControl` | `Alignment`, `Map`, or null | `{x: double, y: double}` |
| `AxisControl` | `Axis`, `String` | `String` (e.g. `"horizontal"`) |
| `BorderRadiusControl` | `BorderRadius`, `num`, `Map` | `{topLeft, topRight, bottomLeft, bottomRight}` |
| `BoxConstraintsControl` | `Map` | `{minWidth?, maxWidth?, minHeight?, maxHeight?}` |
| `CrossAxisAlignmentControl` | `CrossAxisAlignment`, `String` | `String` (e.g. `"center"`) |
| `EdgeInsetsControl` | `EdgeInsets`, `num`, `Map` | `{top, right, bottom, left}` |
| `MainAxisAlignmentControl` | `MainAxisAlignment`, `String` | `String` (e.g. `"start"`) |
| `MainAxisSizeControl` | `MainAxisSize`, `String` | `String` (e.g. `"max"`) |
| `RotationControl` | `num` (degrees) | `num` (degrees) |
| `SizeControl` | `Size`, `Map` | `{width?, height?}` |
| `TextAlignControl` | `TextAlign`, `String` | `String` (e.g. `"left"`) |

Additional constructor parameters:
- `EdgeInsetsControl` accepts `double min = 0` and `double max = 999`.

### Controls — Color, ColorSwatch, Icon, IconGrid

| Class | Constructor | Description |
|-------|-------------|-------------|
| `ColorControl` | `({required Color? value, required ValueChanged<Color?> onChanged, bool showOpacity = false})` | Swatch + hex input row using `color_picker_plus`. |
| `ColorSwatchControl` | `({required Color? value, required ValueChanged<Color?> onChanged, double size = 32})` | Standalone swatch button. |
| `IconControl` | `({required String? value, required ValueChanged<String?> onChanged, List<String>? allowedIcons, DynamicPropertiesPanelManager? manager})` | Dropdown-style icon selector. |
| `IconGridControl` | `({required String? value, required DynamicPropertiesPanelManager manager, required ValueChanged<String?> onChanged, List<String>? allowedIcons})` | Full icon grid inspector. |

### Controls — Date, Duration, Slider

| Class | Constructor | Description |
|-------|-------------|-------------|
| `DateControl` | `({required dynamic value, required ValueChanged<dynamic> onChanged, DateTime? firstDate, DateTime? lastDate})` | Read-only field opening platform date picker. Stores ISO-8601 string. |
| `DurationControl` | `({required dynamic value, required ValueChanged<int> onChanged, bool hourEnabled = false, bool minuteEnabled = true, bool secondEnabled = true, bool msEnabled = true})` | H/M/S/ms row. Stores `int` milliseconds. |
| `SliderControl` | `({required dynamic value, required ValueChanged<double> onChanged, double min = 0.0, double max = 100.0, String? suffix, int? decimalPlaces})` | Inline slider with value display. |

### Controls — BoundTextInput, SuggestionsComboControl, MapControl, MultiSelectControl, ReorderableListEditor, TextStyleControl, JsonTextBox, JsonViewEditBox, ErrorControl

| Class | Constructor | Description |
|-------|-------------|-------------|
| `BoundTextInput` | `({required String value, required ValueChanged<String> onChanged, String? hintText})` | Text input synced to external value. |
| `SuggestionsComboControl` | `({required String initialValue, required List<String> suggestions, required String hintText, required ValueChanged<String> onChanged})` | Text input with dropdown suggestions (free-text allowed). |
| `MapControl` | `({required dynamic value, required ValueChanged<dynamic> onChanged})` | Key-value map editor with add/remove. |
| `MultiSelectControl` | `({required List<dynamic> values, required List<dynamic> options, required ValueChanged<List<dynamic>> onChanged, Map<String, String>? labels, Map<String, String>? iconNames, DynamicPropertiesPanelManager? manager})` | Multi-select dropdown for `multiEnum` kind. |
| `ReorderableListEditor` | `({required List<dynamic> items, required DynamicPropertyKind itemKind, required ValueChanged<List<dynamic>> onChanged})` | Reorderable list for primitive arrays. |
| `TextStyleControl` | `({required dynamic value, required ValueChanged<Map<String, dynamic>> onChanged, List<String>? fontFamilyOptions})` | Rich-text editor with markdown toolbar via `textf`. |
| `JsonTextBox` | `({required dynamic value, required ValueChanged<dynamic> onChanged})` | Editable JSON text field with validation. |
| `JsonViewEditBox` | `({required dynamic value, required ValueChanged<dynamic> onChanged, int defaultLines = 4})` | Read-only tree view with toggle to raw JSON editing. |
| `ErrorControl` | `({String? typeName, String? error, dynamic value})` | Fallback for unsupported types. |
| `ComponentSlotControl` | `({required dynamic value, required ValueChanged<dynamic> onChanged, bool allowNull = true, DynamicPropertiesPanelManager? manager, String? parameterName})` | Component picker for widget slot properties. |

### Preset Dialogs

Top-level functions for preset management dialogs.

| Function | Description |
|----------|-------------|
| `Future<void> showSavePresetDialog(BuildContext context, {required String? selectedPresetId, required List<PropertyPreset>? presets, required void Function(String name, String description) onSave})` | Shows save preset dialog with name/description fields. Pre-populates for overwrite. |
| `Future<void> showDeletePresetDialog(BuildContext context, {required PropertyPreset preset, required VoidCallback onDelete})` | Shows confirmation dialog before deleting a preset. |

### SoftSaaSTheme & SoftSaaSTokens

Bundled theme and design token system for consistent panel styling in light and dark modes.

| Member | Description |
|--------|-------------|
| `static ThemeData SoftSaaSTheme.light()` | Light `ThemeData` with SoftSaaS tokens. |
| `static ThemeData SoftSaaSTheme.dark()` | Dark `ThemeData` with SoftSaaS tokens. |
| `static Color SoftSaaSTokens.primaryColor(Brightness brightness)` | Primary color for given brightness mode. |
| `static Color SoftSaaSTokens.primaryText(Brightness brightness)` | Primary text color. |
| `static Color SoftSaaSTokens.primaryBackground(Brightness brightness)` | Primary background color. |
| `static Color SoftSaaSTokens.primaryBorder(Brightness brightness)` | Primary border color. |