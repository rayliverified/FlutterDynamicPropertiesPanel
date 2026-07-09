/// AxisControl — thin delegate over [SoftSaaSAxisPickerInspector].
library;

import 'package:flutter/material.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

class AxisControl extends StatelessWidget {
  const AxisControl({super.key, required this.value, required this.onChanged});

  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  Axis _parse() {
    final v = value;
    if (v is Axis) return v;
    if (v is String) {
      for (final a in Axis.values) {
        if (a.name == v) return a;
      }
    }
    return Axis.horizontal;
  }

  @override
  Widget build(BuildContext context) {
    return SoftSaaSAxisPickerInspector(
      value: _parse(),
      onChanged: (v) => onChanged(v.name),
    );
  }
}
