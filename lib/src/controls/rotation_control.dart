/// RotationControl — thin delegate over [SoftSaaSRotationPickerInspector].
library;

import 'package:flutter/material.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

class RotationControl extends StatelessWidget {
  const RotationControl({
    super.key,
    required this.value,
    required this.onChanged,
  });

  /// Rotation in degrees.
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  double _parse() => (value as num?)?.toDouble() ?? 0;

  @override
  Widget build(BuildContext context) {
    return SoftSaaSRotationPickerInspector(
      value: _parse(),
      onChanged: onChanged,
    );
  }
}
