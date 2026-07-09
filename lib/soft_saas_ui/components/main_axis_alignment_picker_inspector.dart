// Inspector-style MainAxisAlignment picker.
library;

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'inspector_toggle_row.dart';

const _primary = <SoftSaaSInspectorToggleOption<MainAxisAlignment>>[
  SoftSaaSInspectorToggleOption(
    value: MainAxisAlignment.start,
    icon: LucideIcons.align_horizontal_justify_start,
    tooltip: 'Start',
  ),
  SoftSaaSInspectorToggleOption(
    value: MainAxisAlignment.center,
    icon: LucideIcons.align_horizontal_justify_center,
    tooltip: 'Center',
  ),
  SoftSaaSInspectorToggleOption(
    value: MainAxisAlignment.end,
    icon: LucideIcons.align_horizontal_justify_end,
    tooltip: 'End',
  ),
];

const _overflow = <SoftSaaSInspectorToggleOption<MainAxisAlignment>>[
  SoftSaaSInspectorToggleOption(
    value: MainAxisAlignment.spaceBetween,
    icon: LucideIcons.align_horizontal_space_between,
    tooltip: 'Space between',
  ),
  SoftSaaSInspectorToggleOption(
    value: MainAxisAlignment.spaceAround,
    icon: LucideIcons.align_horizontal_space_around,
    tooltip: 'Space around',
  ),
  SoftSaaSInspectorToggleOption(
    value: MainAxisAlignment.spaceEvenly,
    icon: LucideIcons.align_horizontal_distribute_center,
    tooltip: 'Space evenly',
  ),
];

class SoftSaaSMainAxisAlignmentPickerInspector extends StatelessWidget {
  const SoftSaaSMainAxisAlignmentPickerInspector({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final MainAxisAlignment value;
  final ValueChanged<MainAxisAlignment> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SoftSaaSInspectorToggleRow<MainAxisAlignment>(
      value: value,
      primaryOptions: _primary,
      overflowOptions: _overflow,
      onChanged: onChanged,
      enabled: enabled,
    );
  }
}
