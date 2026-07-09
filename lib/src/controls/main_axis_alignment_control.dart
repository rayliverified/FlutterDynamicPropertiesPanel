/// MainAxisAlignmentControl — thin delegate over [SoftSaaSMainAxisAlignmentPickerInspector].
library;

import 'package:flutter/material.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

class MainAxisAlignmentControl extends StatelessWidget {
  const MainAxisAlignmentControl({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  MainAxisAlignment _parse() {
    final v = value;
    if (v is MainAxisAlignment) return v;
    if (v is String) {
      for (final m in MainAxisAlignment.values) {
        if (m.name == v) return m;
      }
    }
    return MainAxisAlignment.start;
  }

  @override
  Widget build(BuildContext context) {
    return SoftSaaSMainAxisAlignmentPickerInspector(
      value: _parse(),
      onChanged: (v) => onChanged(v.name),
    );
  }
}
