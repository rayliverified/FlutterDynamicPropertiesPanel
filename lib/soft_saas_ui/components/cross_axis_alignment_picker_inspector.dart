// Inspector-style CrossAxisAlignment picker.
library;

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'inspector_toggle_row.dart';

const _primary = <SoftSaaSInspectorToggleOption<CrossAxisAlignment>>[
  SoftSaaSInspectorToggleOption(
    value: CrossAxisAlignment.start,
    icon: LucideIcons.align_start_horizontal,
    tooltip: 'Start',
  ),
  SoftSaaSInspectorToggleOption(
    value: CrossAxisAlignment.center,
    icon: LucideIcons.align_center_horizontal,
    tooltip: 'Center',
  ),
  SoftSaaSInspectorToggleOption(
    value: CrossAxisAlignment.end,
    icon: LucideIcons.align_end_horizontal,
    tooltip: 'End',
  ),
];

const _overflow = <SoftSaaSInspectorToggleOption<CrossAxisAlignment>>[
  SoftSaaSInspectorToggleOption(
    value: CrossAxisAlignment.stretch,
    icon: LucideIcons.stretch_horizontal,
    tooltip: 'Stretch',
  ),
  SoftSaaSInspectorToggleOption(
    value: CrossAxisAlignment.baseline,
    icon: LucideIcons.baseline,
    tooltip: 'Baseline',
  ),
];

class SoftSaaSCrossAxisAlignmentPickerInspector extends StatelessWidget {
  const SoftSaaSCrossAxisAlignmentPickerInspector({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final CrossAxisAlignment value;
  final ValueChanged<CrossAxisAlignment> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SoftSaaSInspectorToggleRow<CrossAxisAlignment>(
      value: value,
      primaryOptions: _primary,
      overflowOptions: _overflow,
      onChanged: onChanged,
      enabled: enabled,
    );
  }
}
