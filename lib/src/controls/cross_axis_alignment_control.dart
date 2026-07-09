/// CrossAxisAlignmentControl — thin delegate over [SoftSaaSCrossAxisAlignmentPickerInspector].
library;

import 'package:flutter/material.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

class CrossAxisAlignmentControl extends StatelessWidget {
  const CrossAxisAlignmentControl({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  CrossAxisAlignment _parse() {
    final v = value;
    if (v is CrossAxisAlignment) return v;
    if (v is String) {
      for (final m in CrossAxisAlignment.values) {
        if (m.name == v) return m;
      }
    }
    return CrossAxisAlignment.center;
  }

  @override
  Widget build(BuildContext context) {
    return SoftSaaSCrossAxisAlignmentPickerInspector(
      value: _parse(),
      onChanged: (v) => onChanged(v.name),
    );
  }
}
