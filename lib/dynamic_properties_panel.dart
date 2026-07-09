/// Dynamic Properties Panel
///
/// A schema-driven properties panel with polished controls for editing
/// primitives, enums, objects, arrays, and Flutter convenience types
/// (alignment, edge insets, border radius, box constraints, text style,
/// color, icon, date, duration) plus widget slot pickers.
///
/// Quick start:
/// ```dart
/// DynamicPropertiesPanel(
///   values: myValues,
///   properties: DynamicPropertyDefinition.listFromJson(schema),
///   onChanged: (updated) => setState(() => _values = updated),
/// )
/// ```
library;

// Core
export 'src/core/dynamic_properties_controller.dart';
export 'src/core/dynamic_properties_panel_manager.dart';
export 'src/core/icon_registry.dart';
export 'src/core/navigation_controller.dart';
export 'src/core/component_registry.dart';

// Models
export 'src/models/dynamic_property_definition.dart';
export 'src/models/property_preset.dart';

// Widgets
export 'src/widgets/dynamic_properties_panel.dart';

// Navigation
export 'src/navigation/breadcrumb_bar.dart';

// Presets
export 'src/controls/preset_toolbar.dart';
export 'src/controls/preset_management_dialogs.dart';

// Controls (exported for direct use or customization)
export 'src/controls/property_section.dart';
export 'src/controls/alignment_control.dart';
export 'src/controls/axis_control.dart';
export 'src/controls/border_radius_control.dart';
export 'src/controls/box_constraints_control.dart';
export 'src/controls/bound_text_input.dart';
export 'src/controls/cross_axis_alignment_control.dart';
export 'src/controls/main_axis_alignment_control.dart';
export 'src/controls/main_axis_size_control.dart';
export 'src/controls/reorderable_list_editor.dart';
export 'src/controls/rotation_control.dart';
export 'src/controls/size_control.dart';
export 'src/controls/suggestions_combo_control.dart';
export 'src/controls/text_align_control.dart';
export 'src/controls/color_control.dart';
export 'src/controls/component_slot_control.dart';
export 'src/controls/date_control.dart';
export 'src/controls/duration_control.dart';
export 'src/controls/slider_control.dart';
export 'src/controls/edge_insets_control.dart';
export 'src/controls/error_control.dart';
export 'src/controls/icon_control.dart';
export 'src/controls/icon_grid_control.dart';
export 'src/controls/map_control.dart';
export 'src/controls/json_text_box.dart';
export 'src/controls/json_view_edit_box.dart';
export 'src/controls/multi_select_control.dart';
export 'src/controls/text_style_control.dart';
