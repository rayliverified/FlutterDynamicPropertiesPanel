# Dynamic Properties Panel example

Production-style demo app for [`dynamic_properties_panel`](../README.md).

## What it shows

- Schema-driven controls for primitives, enums, nested objects, maps, arrays, JSON, colors, icons, dates, durations, layout values, and widget slots
- Controller-based granular updates with commit-only change handling
- Live preview synchronization from panel to rendered widgets and back
- Preset save/restore workflows
- Published `color_picker_plus` and `json_view_plus` integrations

## Run locally

```sh
flutter pub get
flutter run -d chrome
```

For desktop smoke testing on Windows:

```sh
flutter run -d windows
```

For web release validation:

```sh
flutter build web --wasm --web-resources-cdn --no-tree-shake-icons
```

`--no-tree-shake-icons` is required because the demo supports serialized `IconData` values and dynamically restores icons at runtime.
