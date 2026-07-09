// Inspector-style TextAlign picker — left / center / right / justify toggle chips.
library;

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'inspector_toggle_row.dart';

const _options = <SoftSaaSInspectorToggleOption<TextAlign>>[
  SoftSaaSInspectorToggleOption(
    value: TextAlign.left,
    icon: LucideIcons.text_align_start,
    tooltip: 'Left',
  ),
  SoftSaaSInspectorToggleOption(
    value: TextAlign.center,
    icon: LucideIcons.text_align_center,
    tooltip: 'Center',
  ),
  SoftSaaSInspectorToggleOption(
    value: TextAlign.right,
    icon: LucideIcons.text_align_end,
    tooltip: 'Right',
  ),
  SoftSaaSInspectorToggleOption(
    value: TextAlign.justify,
    icon: LucideIcons.text_align_justify,
    tooltip: 'Justify',
  ),
];

class SoftSaaSTextAlignPickerInspector extends StatelessWidget {
  const SoftSaaSTextAlignPickerInspector({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final TextAlign value;
  final ValueChanged<TextAlign> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SoftSaaSInspectorToggleRow<TextAlign>(
      value: value,
      primaryOptions: _options,
      onChanged: onChanged,
      enabled: enabled,
    );
  }
}
