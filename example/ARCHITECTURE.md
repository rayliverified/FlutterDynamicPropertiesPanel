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

---

# v2 — The generic staging layer

Validated in production (NOCD linked-account screens) and hardened by an independent
architecture review, v2 replaces per-screen tooling plumbing with one generic layer.
Nothing about how UI is built changes: state is still ordinary variables declared on the
StatefulWidget's State. Everything below hooks into the Flutter framework; none of it
replaces it.

## Layer map

```text
AI / MCP / properties panel
        │  stage_state · read_state · list_state_targets   (generic commands)
        ▼
StoryboardStageRegistry        one typed adapter per screen, registered at APP STARTUP
        │  apply(state, values) — pure   ·   read(state) — ground truth
        ▼
StoryboardStateRegistry        semantic ID → GlobalKey (screens only)
        │  GlobalKey.currentState
        ▼
Screen State                   plain typed fields · plain setState
        │  constructor data ↓ / callbacks ↑ / findAncestorStateOfType for in-tree lookup
        ▼
Stateless children & nested components
```

## What each built-in Flutter mechanism is for

| Mechanism | Role in this architecture |
|---|---|
| Public `State` + `GlobalKey.currentState` | THE staging primitive: external, typed, live read/write |
| `context.findAncestorStateOfType<T>()` | In-tree child→screen coordination (children never need keys for this) |
| `InheritedWidget` / `InheritedModel` | Downward dependency injection (fake services/fixtures in storyboard wrappers) — not state addressing |
| Restoration framework | Actual persistence needs only — never repurposed as a tooling registry |
| Element-tree APIs | Diagnostics (widget tree, capture) — never deterministic staging |

## Stage adapters (kills the per-screen wrapper code)

One adapter per stageable screen, registered ONCE at startup — never from widget
lifecycle. That decoupling eliminated an entire class of races where a driver property
existed only while its registering wrapper happened to be mounted.

```dart
stageTarget<ProfileSwitcherPageState>(
  id: 'linkedAccount.profileSwitcher.default',
  apply: (state, values) { /* pure field assignment only */ },
  read: (state) => { /* typed ground truth */ },
  afterApply: (state, values) { /* post-frame, may self-notify */ },
)
```

The generic layer owns: mount lookup, mounted checks, wrapping `apply` in the target's
own `setState`, post-frame `afterApply`, error shapes, JSON, introspection
(`list_state_targets`). The screen owns only its semantic ID and the typed mapping.
Unmounted target ⇒ clean `"not mounted"` — never `"unknown"`.

### The apply-mode rule (codified, not conventional)

`apply` is **pure field assignment**: no `setState`, no `notifyListeners`, no
self-notifying setters. Anything that must run after the staged frame (form
revalidation, focus, scroll) goes in `afterApply`, which runs post-frame outside
`setState`. This is what makes staging safe to wrap in the target's `setState`.

## Legacy state machines: the DefaultStateMixin pattern

Existing mixins with built-in behaviors are decomposed into two layers rather than
rewritten:

- **Self-notifying layer** (unchanged, production keeps using it): `setLoading()`,
  `setLoaded()`, `setError()` — resolve the machine and call `setState` themselves.
- **Pure staging layer** (added): `stageDataState(state, {errorMessage})` assigns
  `state`/`loading`/`errorMessage`/`loadingVisibility` as one consistent unit, never
  notifies, and resolves animations immediately (deterministic capture frames).
  `describeDataState()` is the readback half.

The stage registry then handles the machine **generically**: any target whose State uses
the mixin accepts `{"dataState": "loading" | "loaded" | "error", "errorMessage": ...}`
and includes the machine snapshot in every read — zero adapter code per screen for it.
This is the template for rolling any legacy self-notifying mixin into the system: split
pure-assign + describe out of the notifying methods, then let the generic layer speak it.

## Capture integrity rules (learned the hard way)

1. Never trust route/selection metadata — verify via `read_state` ground truth +
   widget-tree markers + frame dimensions before accepting any capture.
2. One storyboard item per screen; every stable variant/state combination is a persisted
   preset. No per-state routes — they sidestep the variant/preset model.
   Every review item also carries a **named preset with id `default`** — the
   `*.default.json` defaults file is a values bucket, not driver-addressable, so
   without it `select_story` has no default story to land on.
3. Driver `select_story` without a preset lands on the `default` preset; showcase views
   reject component capture outright (UI clicks still show the showcase).
4. Offscreen capture (own BuildOwner/PipelineOwner/RenderView, FIFO on the UI thread)
   resolves targets through the same variant/preset pipeline and reports per-target
   errors; beware `ScrollAwareImageProvider` + ImageCache poisoning in detached trees.

## Production-side contract (the whole ask of app code)

1. Public State class; ordinary typed fields; plain `setState`.
2. Honest constructor params for side-effect gating (`autoLoad`, and for IO-heavy pages
   split flags: `autoConnectRealtime`, `autoPromptPermissions`,
   `autoRefreshOnLifecycle`) — never one flag overloaded to mean "disable everything".
3. Nested stateful children: parent owns the key, exposes a typed accessor.
4. Zero tooling imports. Keys arrive from outside via `super.key`.
