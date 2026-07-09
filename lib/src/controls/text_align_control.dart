/// TextAlignControl — thin delegate over [SoftSaaSTextAlignPickerInspector].
library;

import 'package:flutter/material.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

class TextAlignControl extends StatelessWidget {
  const TextAlignControl({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  TextAlign _parse() {
    final v = value;
    if (v is TextAlign) return v;
    if (v is String) {
      for (final t in TextAlign.values) {
        if (t.name == v) return t;
      }
    }
    return TextAlign.left;
  }

  @override
  Widget build(BuildContext context) {
    return SoftSaaSTextAlignPickerInspector(
      value: _parse(),
      onChanged: (v) => onChanged(v.name),
    );
  }
}
