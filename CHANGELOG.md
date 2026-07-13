## 1.1.0

- Added properties-only panel usage: schemas can now initialize an internal controller from `defaultValue` entries without passing `values`.
- Added `emptyWidget` and made explicit `properties: []` render an empty state instead of falling back to inferred controls.
- Added typed map value schemas via the `value` field for `Map<String, T>` controls, including icon-picker map values and map entry defaults.
- Improved widget-list editing with the shared reorderable list shell, add/remove/reorder support, maximum-item bounds, and correct nested slot updates.
- Expanded the example app with storyboard state architecture, live feature block tiles, reach/conversion cards, scoped property demos, and architecture documentation.
- Added a full API reference and refreshed README guidance for controller-based, properties-only, and map-based usage.
- Normalized public documentation comments across SoftSaaS UI components.

### Changed

- `controller` and `values` are now mutually exclusive; use `controller` for externally managed state or `values` for an internally owned controller.

## 1.0.0

- Initial release.
