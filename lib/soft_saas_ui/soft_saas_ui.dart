/// Minimal internal Soft SaaS UI surface used by dynamic_properties_panel.
///
/// This file intentionally exports only the small subset of primitives used by
/// the package and its example app. The original design-system snapshot was
/// pruned so the published package does not ship unused components.
library soft_saas_ui;

// Design foundations.
export 'design_tokens.dart';
export 'theme.dart';
export 'typography.dart';

// Controls and primitives used by the package/example.
export 'components/action_button.dart';
export 'components/alignment_picker_inspector.dart';
export 'components/axis_picker_inspector.dart';
export 'components/badge.dart';
export 'components/border_radius_picker_inspector.dart';
export 'components/box_constraints_picker_inspector.dart';
export 'components/button.dart';
export 'components/checkbox.dart';
export 'components/color_input.dart';
export 'components/combo_input.dart';
export 'components/cross_axis_alignment_picker_inspector.dart';
export 'components/dropdown_multiselect.dart';
export 'components/edge_insets_picker_inspector.dart';
export 'components/expandable.dart';
export 'components/icon_picker.dart';
export 'components/icon_picker_inspector.dart';
export 'components/main_axis_alignment_picker_inspector.dart';
export 'components/main_axis_size_picker_inspector.dart';
export 'components/number_input.dart';
export 'components/panel.dart';
export 'components/reorderable_list.dart';
export 'components/resizable_row.dart';
export 'components/rich_text_field.dart';
export 'components/rich_text_toolbar.dart';
export 'components/rotation_picker_inspector.dart';
export 'components/select.dart';
export 'components/size_picker_inspector.dart';
export 'components/slider.dart';
export 'components/switch.dart';
export 'components/tabs.dart';
export 'components/text_align_picker_inspector.dart';
export 'components/text_input.dart';
