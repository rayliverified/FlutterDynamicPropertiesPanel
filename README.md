# dynamic_properties_panel

Schema-driven property editing panel for Flutter — with a companion
`DynamicPropertiesController` that enables **granular rebuilds**,
**bidirectional sync** between panel and rendered components, and
**commit-only callbacks** for expensive persistence layers.

Polished controls are included for primitives, enums, objects, arrays, maps,
colors, icons, dates, durations, and more — plus widget-slot pickers,
breadcrumb navigation, and preset toolbars.

## Live demo

Try the production example: https://flutterdynamicpropertiespanel.netlify.app/

## Production package notes

This standalone package uses the published [`color_picker_plus`](https://pub.dev/packages/color_picker_plus) and [`json_view_plus`](https://pub.dev/packages/json_view_plus) packages instead of vendored local copies. Its bundled design-system snapshot is also pruned to the internal primitives the panel and example actually use, keeping the package smaller, easier to update, and aligned with the production-ready color and JSON controls used by the example app.

## Installation

```yaml
dependencies:
  dynamic_properties_panel: ^1.0.0
```

```dart
import 'package:dynamic_properties_panel/dynamic_properties_panel.dart';
```

---

## Two ways to use it

### 1. Controller-based (recommended)

Use this when you want:
- Granular rebuilds (changing one property only rebuilds its control)
- Live updates during drag without full-tree rebuilds
- Bidirectional sync — a rendered preview component writes back to the panel
  (Storybook-args pattern)
- Explicit save/persist without hidden serialization on every keystroke

```dart
import 'package:dynamic_properties_panel/dynamic_properties_panel.dart';

class MyPage extends StatefulWidget { ... }

class _MyPageState extends State<MyPage> {
  late final DynamicPropertiesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DynamicPropertiesController(initial: loadedValues);
  }

  @override
  void dispose() {
    _controller.dispose();  // mandatory — caller owns lifecycle
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicPropertiesPanel(
      controller: _controller,
      properties: DynamicPropertyDefinition.listFromJson(schema),
    );
  }

  void _save() {
    // Snapshot on demand — not synced on every change.
    final values = _controller.snapshot();
    persistToDisk(values);
  }
}
```

### 2. Map-based (backwards-compatible)

The legacy constructor still works — the panel creates an internal
controller. `onChanged` now fires only on **committed** changes (drag end,
typing complete, preset applied), not on every drag tick:

```dart
DynamicPropertiesPanel(
  values: values,
  properties: DynamicPropertyDefinition.listFromJson(schema),
  onChanged: (next) => setState(() => values = next),
)
```

---

## DynamicPropertiesController API

```dart
// Construction
final controller = DynamicPropertiesController(initial: {'fontSize': 16});

// Reading
controller['fontSize'];              // dynamic — null if never set
controller.notifierFor('fontSize');  // ValueNotifier<dynamic>
controller.hasValue('fontSize');     // bool — has it been explicitly set?
controller.snapshot();               // Map<String,dynamic> — deep-copied
controller.snapshotShallow();        // Map<String,dynamic> — cheap

// Writing — every write fires all listeners and the commits stream.
controller['fontSize'] = 18;                          // idiomatic
controller.setValue('fontSize', 18);                  // equivalent
controller.applyAll({'a': 1, 'b': 2});                // bulk

// Listening
controller.addListener(() { ... });                   // any change
ValueListenableBuilder(                               // single property, granular
  valueListenable: controller.notifierFor('enabled'),
  builder: (context, value, _) => ...,
);
controller.commits.listen((change) { ... });          // every write (debounce if persisting)

// Lifecycle
controller.dispose();                                 // mandatory
```

---

## Bidirectional sync (Storybook-args pattern)

The real payoff of the controller is that any widget — not just the panel —
can bind to the same notifiers. Rendered preview components become
**participants** in the shared state: the user can toggle a switch inside
the live preview and the panel's corresponding row flips to match.

```dart
// The panel binds 'enabled' to its switch row automatically.
DynamicPropertiesPanel(controller: controller, properties: ...)

// Your preview component reads and writes the same state.
Widget previewSwitch(DynamicPropertiesController ctrl) {
  final on = ctrl['enabled'] as bool? ?? false;
  return ReboundSwitch(
    value: on,
    onChanged: (next) => ctrl['enabled'] = next, // panel's row flips to match
  );
}
```

---

## Persistence — debounce in your handler

Every write fires listeners and the [commits] stream, including on every
drag tick. Hosts that persist should debounce in their own handler:

```dart
Timer? saveTimer;
controller.commits.listen((_) {
  saveTimer?.cancel();
  saveTimer = Timer(const Duration(milliseconds: 300), () {
    saveToDisk(controller.snapshot());
  });
});
```

Granular rebuilds inside the panel mean the drag-tick firehose is cheap
to observe — only the affected row rebuilds, not the whole panel or host.

---

## Three listener tiers

| Mechanism | Scope | Best for |
|---|---|---|
| `controller.notifierFor(key)` | one property | per-field rebuilds in preview components |
| `controller.addListener(...)` / `ListenableBuilder(listenable: controller)` | all properties | live JSON display, debug panels, component preview |
| `controller.commits.listen(...)` | all writes, as `PropertyChange` events | save-to-disk (with debounce), analytics |

Pick the tier that matches how expensive your consumer is.

---

## Presets

Preset toolbars (save / reset / delete) are built in. Pass `presets`,
`onPresetSelected`, and `onPresetsChanged` on the panel — those work the
same in both controller and Map-based modes. Nested component presets use
`componentPresets` / `onComponentPresetsChanged`.

---

## Property Types And Flutter Mapping

Use `type` in your schema to select a control. `DynamicPropertyDefinition.inferKind`
maps these strings to `DynamicPropertyKind`.

### Core types

| Schema `type` | Kind | Stored value format | Flutter mapping |
|---|---|---|---|
| `String` | `string` | `String` | `String` properties |
| `int` / `integer` | `integer` | `int` | numeric integer props |
| `double` / `num` / `number` | `double` | `double` | numeric double props |
| `bool` / `boolean` | `boolean` | `bool` | toggle/boolean props |
| any type + `enumValues` | `enumValue` | selected enum item | enum-like props (stored as listed value) |
| any type + `enumValues` + `multiSelect: true` | `multiEnum` | `List<dynamic>` | multi-select enum props |
| `object` or `properties` | `object` | `Map<String,dynamic>` | nested config objects |
| `List<...>` / `array` / `list` | `array` | `List<dynamic>` | list props |
| `Map<...>` / `map` | `map` | `Map<String,dynamic>` | key/value map props |
| `json` / `dynamic` | `json` | any JSON-serializable value | raw fallback editor |

### Flutter convenience types

| Schema `type` | Kind | Stored value format | Flutter mapping |
|---|---|---|---|
| `Color` | `color` | `#RRGGBB` or `#AARRGGBB` | `Color` |
| `Color.swatch` / `ColorSwatch` | `colorSwatch` | `#RRGGBB` | `Color` |
| `icon` / `IconData` | `icon` | icon name `String` | `IconData` via registry/picker |
| `Icon.swatch` / `IconSwatch` | `iconSwatch` | icon name `String` | `IconData` via swatch picker |
| `date` / `DateTime` | `date` | ISO-8601 `String` | `DateTime` |
| `Duration` / `duration` | `duration` | `int` milliseconds | `Duration` |
| `Slider` | `slider` | `double` | `double` range values |
| `Alignment` / `AlignmentGeometry` | `alignment` | `{x: double, y: double}` | `Alignment` |
| `EdgeInsets` / `EdgeInsetsGeometry` | `edgeInsets` | `{top,right,bottom,left}` | `EdgeInsets` |
| `BorderRadius` / `BorderRadiusGeometry` | `borderRadius` | `{topLeft,topRight,bottomLeft,bottomRight}` | `BorderRadius` |
| `BoxConstraints` | `boxConstraints` | `{minWidth,maxWidth,minHeight,maxHeight}` | `BoxConstraints` |
| `TextStyle` | `textStyle` | `{markdown: String, ...}` | `TextStyle`-adjacent rich text config |
| `MainAxisAlignment` | `mainAxisAlignment` | enum name `String` (for example `start`) | `MainAxisAlignment` |
| `CrossAxisAlignment` | `crossAxisAlignment` | enum name `String` | `CrossAxisAlignment` |
| `MainAxisSize` | `mainAxisSize` | enum name `String` | `MainAxisSize` |
| `Axis` | `axis` | enum name `String` | `Axis` |
| `TextAlign` | `textAlign` | enum name `String` | `TextAlign` |
| `Size` | `size` | `{width: double?, height: double?}` | `Size` |
| `Rotation` | `rotation` | `double` degrees | rotation angle props |

### Widget slots

| Schema `type` | Kind | Stored value format |
|---|---|---|
| `Widget` | `widget` | `{componentId: String, config: Map<String,dynamic>}` or `null` |
| `List<Widget>` | `widgetList` | `List<{componentId, config}?>` |

### Example schema

```dart
final properties = DynamicPropertyDefinition.listFromJson([
  {'name': 'title', 'type': 'String'},
  {'name': 'themeColor', 'type': 'Color'},
  {'name': 'padding', 'type': 'EdgeInsets'},
  {'name': 'layout', 'type': 'object', 'properties': {'radius': {'type': 'double'}}},
  {'name': 'child', 'type': 'Widget'},
]);
```

---

## Example

See `/example` for a complete app with:
- Nested object editing
- Map editing
- Widget and widget-list slot editing
- Live JSON preview (via `ListenableBuilder`)
- Interactive preview with bidirectional switch + slider
- Preset save/restore
- Widget-slot picker with child component config

Run it with `flutter run` from the `/example` directory.
