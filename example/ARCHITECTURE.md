# Storyboard State Architecture

A Flutter development pattern for building production UI that AI tooling, storyboards, and
dynamic property panels can **stage, inspect, and mutate programmatically** — with minimal
production code changes, using only Flutter's built-in `StatefulWidget` / `GlobalKey`
mechanics. No state-management package, no element-tree walking.

The reference implementation lives in [`lib/architecture/`](lib/architecture) and is wired
up in [`lib/main.dart`](lib/main.dart).

## Core principles

1. **The screen is the state boundary.** A screen (page) is a natural Flutter framework
   boundary. Its `State` holds the entire screen-scoped state as **ordinary typed fields**
   (`String ctaTitle`, `bool rollout`, `double rolloutPercentage`, …) — or holds a
   reference (key) to any nested stateful child, so it can get/set *anything* below it.
2. **No controllers in production constructors.** Widget construction is ordinary:
   `FeatureBlock(initialValues: …)`. State does not arrive through a controller object.
3. **Stateless children are driven by constructors.** Components that are
   `StatelessWidget`s receive plain typed data down and report interactions via callbacks
   up. They never get keys and never know about tooling.
4. **The State class is public.** `FeatureBlockState`, `PreviewCarouselState` — public so
   a `GlobalKey<T>` can address them. This is the whole "API surface" tooling needs.
5. **Keys come from the outside.** The production widget takes `super.key`; the app (or
   storyboard) supplies a `GlobalKey` from the registry. Production code has **zero
   tooling imports**.

## The layers

```text
Dynamic Properties Panel / JSON / Presets / AI
        ↓ writes
DynamicPropertiesController        (tooling-side value map)
        ↓ StoryboardStateRegistry.update → GlobalKey.currentState
Screen State variables             (ordinary typed fields, setState)
        ↓ constructor data
Stateless child components
```

| Layer | Example file | Role |
|---|---|---|
| Production component | `architecture/feature_block.dart` | `FeatureBlock` — the sample full UI. Public `FeatureBlockState` owns all typed state fields. |
| Stateless tiles | `architecture/tiles/*.dart` | One file per card. Constructor data in, callbacks out. |
| Nested stateful child | `architecture/preview_carousel.dart` | Independent state (active index). Key owned by its **parent**, not the registry. |
| Registry | `architecture/storyboard_state_registry.dart` | Semantic ID → `GlobalKey`. Typed `state()`, `read()`, `update()`. |
| Tooling host | `architecture/live_preview_card.dart` | Storyboard chrome. Stateless — owns nothing. |
| App / bridge | `main.dart` | Owns the controller and the bidirectional sync bridge. |

## Writing a production component

```dart
class FeatureBlock extends StatefulWidget {
  const FeatureBlock({
    super.key,                       // key supplied from outside
    this.initialValues = const {},   // plain data in
    this.onStateChanged,             // user interactions out
  });
  // ...
  @override
  State<FeatureBlock> createState() => FeatureBlockState();  // public State
}

class FeatureBlockState extends State<FeatureBlock> {
  // Ordinary typed state variables — this IS the source of truth.
  String ctaTitle = 'Checkout CTA';
  bool rollout = true;
  double rolloutPercentage = 75;
  List<String> tags = const [];
  // ...

  @override
  Widget build(BuildContext context) {
    // Stateless children driven by constructors; callbacks mutate fields.
    return RolloutPercentTile(
      percentage: rolloutPercentage,
      onChanged: (next) => _mutate(() => rolloutPercentage = next),
    );
  }

  void _mutate(VoidCallback fn) {
    setState(fn);
    widget.onStateChanged?.call(toValues());  // keep external tooling in sync
  }
}
```

### The tooling contract

Two mapping methods on the State reconcile typed fields with the grouped
panel/JSON payload shape:

- `applyValues(Map<String, dynamic> values)` — maps a grouped payload onto the typed
  fields. Only groups present are touched. Does **not** call `setState`; callers wrap it
  (`registry.update` does; `initState` doesn't need it). Keys the component doesn't
  render are retained in an `_extras` map so the payload round-trips losslessly.
- `toValues()` — serializes the typed fields back into the same grouped shape.
- `onStateChanged` — fires with a fresh `toValues()` whenever the **user** mutates state
  from inside the component (slider drag, switch toggle). Never fired from
  `applyValues`, which is what breaks echo loops.

This contract is the only tooling-specific code in the component, and it's still just
plain Dart on a plain `State`.

## The registry

```dart
final registry = StoryboardStateRegistry.instance;

// Production mount — the app supplies the key:
FeatureBlock(
  key: registry.key<FeatureBlockState>('example.featureBlock'),
  initialValues: initial,
)

// Stage any state from tooling (wraps the target's setState):
registry.update<FeatureBlockState>('example.featureBlock', (state) {
  state.rollout = false;
  state.ctaTitle = 'Staged scenario';
});

// Read:
final title = registry.read<FeatureBlockState, String>(
  'example.featureBlock', (s) => s.ctaTitle);
```

### Key management rules

1. One stable semantic ID ↔ one `GlobalKey`. Never create keys inside `build()`.
2. A `GlobalKey` may be mounted on only one widget at a time. Repeated components need
   instance IDs (`profileSwitcher.profile.1001`).
3. **Only screens (framework boundaries) go in the registry.** One entry per screen.
4. Stateless children are controlled through parent constructor data — never keys.
5. Registry mutation always goes through `update()` (i.e. the target's `setState`).
6. `remove()` run-specific IDs when a storyboard scenario is destroyed.

### Nested stateful children: the parent owns the key

Controllers and keys for nested stateful widgets do **not** live in the registry. The
parent State holds them as ordinary fields and exposes typed accessors — tooling reaches
nested state *through* the screen:

```dart
class FeatureBlockScreenState extends State<...> {
  final _carouselKey = GlobalKey<PreviewCarouselState>(
    debugLabel: 'featureBlock.carousel');

  PreviewCarouselState? get carousel => _carouselKey.currentState;
}

// Tooling:
registry.state<FeatureBlockScreenState>('example.featureBlock')
    ?.carousel?.activeIndex = 3;
```

This keeps the semantic hierarchy in code (typed accessors) instead of in registry
strings, and keeps the registry small: screens only.

## Bidirectional sync with the properties panel

The app owns one `DynamicPropertiesController` (the panel/JSON representation) and
bridges it to the live State (see `main.dart`):

```dart
// Panel → component: any controller write lands on the typed fields.
void _onControllerChanged() {
  if (!_pushingFromScreen) {
    registry.update<FeatureBlockState>(kScreenId,
      (s) => s.applyValues(_controller.snapshotShallow()));
  }
  setState(() {});  // tooling chrome re-reads the values
}

// Component → panel: user interaction inside the component.
void _onFeatureBlockChanged(Map<String, dynamic> values) {
  _pushingFromScreen = true;         // guard: don't echo back into setState
  try { _controller.applyAll(values); }
  finally { _pushingFromScreen = false; }
}
```

Any write from any surface — panel control, JSON edit, preset apply, a slider **inside**
the component, a slider on a standalone storyboard card — lands in the controller once
and fans out to every other surface. The `_pushingFromScreen` guard is the single
re-entrancy break.

## Adding a new screen (checklist)

1. Build the screen as a `StatefulWidget` with a **public** State holding typed fields.
2. Extract every card/section as a `StatelessWidget` in its own file: typed constructor
   params + change callbacks. Route all user mutations through a `_mutate()` that calls
   `setState` and fires `onStateChanged`.
3. Give nested stateful children a key **owned by the screen State**, exposed via a typed
   getter.
4. Implement `applyValues` / `toValues` for the groups the panel edits (preserve
   unrendered keys in `_extras`).
5. Register exactly one ID in `StoryboardStateRegistry` and pass the key in from the app.
6. Wire the two bridge callbacks in the host (controller listener + guarded
   `onStateChanged`).

## Why this shape

- **Native.** Uses `GlobalKey.currentState` — the supported Flutter mechanism — not
  element-tree traversal or reflection.
- **Minimal production delta.** The component is exactly what you'd write anyway, plus a
  public State name and two mapping methods.
- **AI/storyboard ready.** Any state, on any screen, is addressable by a stable semantic
  ID: read it, stage it, simulate it. The dynamic properties panel is just one client of
  the same contract.
- **Edge cases already solved here:** echo-loop guarding between panel and State;
  lossless round-trip of panel-only keys (`_extras`); nested-state ownership (parent
  holds the key, registry holds screens only); interactive tiles both inside the
  component and on standalone storyboard cards staying in sync through one controller.

Future complex pages (lists of repeated components, async loading states, multi-screen
flows) will extend this pattern — instance IDs for repeated components and per-screen
registry entries are the intended growth path.
