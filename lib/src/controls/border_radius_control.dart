/// BorderRadiusControl — thin delegate over [SoftSaaSBorderRadiusPickerInspector].
///
/// Compact single-row inspector: four corner number inputs with
/// corner glyphs and a uniform-lock toggle.
library;

import 'package:flutter/material.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

class BorderRadiusControl extends StatelessWidget {
  const BorderRadiusControl({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  BorderRadius _parse() {
    final v = value;
    if (v is BorderRadius) return v;
    if (v is num) return BorderRadius.circular(v.toDouble());
    if (v is Map) {
      Radius r(String k) => Radius.circular((v[k] as num?)?.toDouble() ?? 0);
      return BorderRadius.only(
        topLeft: r('topLeft'),
        topRight: r('topRight'),
        bottomLeft: r('bottomLeft'),
        bottomRight: r('bottomRight'),
      );
    }
    return BorderRadius.zero;
  }

  @override
  Widget build(BuildContext context) {
    return SoftSaaSBorderRadiusPickerInspector(
      value: _parse(),
      onChanged: (r) => onChanged({
        'topLeft': r.topLeft.x,
        'topRight': r.topRight.x,
        'bottomLeft': r.bottomLeft.x,
        'bottomRight': r.bottomRight.x,
      }),
    );
  }
}
