/// Minimal internal Soft SaaS UI surface used by dynamic_properties_panel.
///
/// This file intentionally exports only the small subset of primitives used by
/// the package and its example app. The original design-system snapshot was
/// pruned so the published package does not ship unused components.
library soft_saas_ui;

// Design foundations.
export 'soft_saas/design_tokens.dart';
export 'soft_saas/theme.dart';
export 'soft_saas/typography.dart';

// Controls and primitives used by the package/example.
export 'soft_saas/components/action_button.dart';
export 'soft_saas/components/alignment_picker_inspector.dart';
export 'soft_saas/components/axis_picker_inspector.dart';
export 'soft_saas/components/badge.dart';
export 'soft_saas/components/border_radius_picker_inspector.dart';
export 'soft_saas/components/box_constraints_picker_inspector.dart';
export 'soft_saas/components/button.dart';
export 'soft_saas/components/checkbox.dart';
export 'soft_saas/components/color_input.dart';
export 'soft_saas/components/combo_input.dart';
export 'soft_saas/components/cross_axis_alignment_picker_inspector.dart';
export 'soft_saas/components/dropdown_multiselect.dart';
export 'soft_saas/components/edge_insets_picker_inspector.dart';
export 'soft_saas/components/expandable.dart';
export 'soft_saas/components/icon_picker.dart';
export 'soft_saas/components/icon_picker_inspector.dart';
export 'soft_saas/components/main_axis_alignment_picker_inspector.dart';
export 'soft_saas/components/main_axis_size_picker_inspector.dart';
export 'soft_saas/components/number_input.dart';
export 'soft_saas/components/panel.dart';
export 'soft_saas/components/reorderable_list.dart';
export 'soft_saas/components/resizable_row.dart';
export 'soft_saas/components/rich_text_field.dart';
export 'soft_saas/components/rich_text_toolbar.dart';
export 'soft_saas/components/rotation_picker_inspector.dart';
export 'soft_saas/components/select.dart';
export 'soft_saas/components/size_picker_inspector.dart';
export 'soft_saas/components/slider.dart';
export 'soft_saas/components/switch.dart';
export 'soft_saas/components/tabs.dart';
export 'soft_saas/components/text_align_picker_inspector.dart';
export 'soft_saas/components/text_input.dart';
