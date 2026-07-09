/// IconControl — delegates to [SoftSaaSIconPicker].
///
/// Preserves the string-name storage contract. If a [DynamicPropertiesPanelManager]
/// is provided with its own [IconRegistry], we filter to the intersection of
/// the registry's names and [lucideIconRegistry] — the picker's registry is
/// the source of truth for *which* icons exist.
library;

import 'package:flutter/material.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

import '../core/dynamic_properties_panel_manager.dart';

class IconControl extends StatelessWidget {
  const IconControl({
    super.key,
    required this.value,
    required this.onChanged,
    this.allowedIcons,
    this.manager,
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final List<String>? allowedIcons;
  final DynamicPropertiesPanelManager? manager;

  @override
  Widget build(BuildContext context) {
    return SoftSaaSIconPicker(
      iconName: value,
      allowedIcons: allowedIcons,
      size: SoftSaaSIconPickerSize.small,
      onChanged: (name) => onChanged(name),
    );
  }
}
