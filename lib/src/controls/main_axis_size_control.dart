/// MainAxisSizeControl — thin delegate over [SoftSaaSMainAxisSizePickerInspector].
library;

import 'package:flutter/material.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

class MainAxisSizeControl extends StatelessWidget {
  const MainAxisSizeControl({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  MainAxisSize _parse() {
    final v = value;
    if (v is MainAxisSize) return v;
    if (v is String) {
      for (final m in MainAxisSize.values) {
        if (m.name == v) return m;
      }
    }
    return MainAxisSize.max;
  }

  @override
  Widget build(BuildContext context) {
    return SoftSaaSMainAxisSizePickerInspector(
      value: _parse(),
      onChanged: (v) => onChanged(v.name),
    );
  }
}
