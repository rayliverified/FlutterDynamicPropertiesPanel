/// IconGridControl — thin delegate over [SoftSaaSIconPickerInspector].
library;

import 'package:dynamic_properties_panel/src/core/dynamic_properties_panel_manager.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

class IconGridControl extends StatelessWidget {
  const IconGridControl({
    super.key,
    required this.value,
    required this.manager,
    required this.onChanged,
    this.allowedIcons,
  });

  final String? value;
  final List<String>? allowedIcons;
  final DynamicPropertiesPanelManager manager;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final registry = manager.iconRegistry;
    final names = allowedIcons ?? registry.allNames;
    final entries = <SoftSaaSIconPickerInspectorEntry>[];
    for (final name in names) {
      final icon = registry.getIcon(name);
      if (icon != null) {
        entries.add(SoftSaaSIconPickerInspectorEntry(name: name, icon: icon));
      }
    }

    return SoftSaaSIconPickerInspector(
      value: value,
      icons: entries,
      onChanged: onChanged,
    );
  }
}
