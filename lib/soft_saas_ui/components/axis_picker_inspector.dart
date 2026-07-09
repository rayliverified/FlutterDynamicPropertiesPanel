// Inspector-style Axis (direction) picker — horizontal / vertical toggle chips.
library;

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'inspector_toggle_row.dart';

const _options = <SoftSaaSInspectorToggleOption<Axis>>[
  SoftSaaSInspectorToggleOption(
    value: Axis.horizontal,
    icon: LucideIcons.move_horizontal,
    tooltip: 'Horizontal',
  ),
  SoftSaaSInspectorToggleOption(
    value: Axis.vertical,
    icon: LucideIcons.move_vertical,
    tooltip: 'Vertical',
  ),
];

class SoftSaaSAxisPickerInspector extends StatelessWidget {
  const SoftSaaSAxisPickerInspector({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final Axis value;
  final ValueChanged<Axis> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SoftSaaSInspectorToggleRow<Axis>(
      value: value,
      primaryOptions: _options,
      onChanged: onChanged,
      enabled: enabled,
    );
  }
}
