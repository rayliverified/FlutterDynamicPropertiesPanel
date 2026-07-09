/// Inspector-style MainAxisSize picker — min / max toggle chips.
library;

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'inspector_toggle_row.dart';

const _options = <SoftSaaSInspectorToggleOption<MainAxisSize>>[
  SoftSaaSInspectorToggleOption(
    value: MainAxisSize.min,
    icon: LucideIcons.minimize_2,
    tooltip: 'Hug contents (min)',
  ),
  SoftSaaSInspectorToggleOption(
    value: MainAxisSize.max,
    icon: LucideIcons.maximize_2,
    tooltip: 'Fill container (max)',
  ),
];

class SoftSaaSMainAxisSizePickerInspector extends StatelessWidget {
  const SoftSaaSMainAxisSizePickerInspector({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final MainAxisSize value;
  final ValueChanged<MainAxisSize> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SoftSaaSInspectorToggleRow<MainAxisSize>(
      value: value,
      primaryOptions: _options,
      onChanged: onChanged,
      enabled: enabled,
    );
  }
}
