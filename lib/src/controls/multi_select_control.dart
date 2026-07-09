import 'package:flutter/material.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

import '../core/dynamic_properties_panel_manager.dart';
import '../core/icon_registry.dart';

/// Control for selecting multiple values from a list (multi-enum).
///
/// Uses [SoftSaaSDropdownMultiselect] so multi-enum has the same polished
/// field-style interaction as single enum dropdowns.
class MultiSelectControl extends StatelessWidget {
  const MultiSelectControl({
    super.key,
    required this.values,
    required this.options,
    required this.onChanged,
    this.labels,
    this.iconNames,
    this.manager,
  });

  final List<dynamic> values;
  final List<dynamic> options;
  final ValueChanged<List<dynamic>> onChanged;
  final Map<String, String>? labels;
  final Map<String, String>? iconNames;
  final DynamicPropertiesPanelManager? manager;

  IconRegistry get _registry =>
      (manager ?? DynamicPropertiesPanelManager.instance).iconRegistry;

  @override
  Widget build(BuildContext context) {
    final selected = values.map((v) => v.toString()).toSet();

    final selectOptions = options.map((option) {
      final value = option.toString();
      final label = labels?[value] ?? value;
      final iconName = iconNames?[value];
      final iconData = iconName != null ? _registry.getIcon(iconName) : null;

      return SelectOption(
        value: value,
        label: label,
        leading: iconData != null ? Icon(iconData, size: 14) : null,
      );
    }).toList();

    return SoftSaaSDropdownMultiselect(
      options: selectOptions,
      values: selected,
      placeholder: 'Select...',
      emptyStateLabel: 'No options available',
      size: SoftSaaSSelectSize.small,
      onChanged: (updated) {
        final ordered = options
            .where((option) => updated.contains(option.toString()))
            .toList();
        onChanged(ordered);
      },
    );
  }
}
