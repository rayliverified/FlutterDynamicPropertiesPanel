/// EdgeInsetsControl — thin delegate over [SoftSaaSEdgeInsetsPickerInspector].
///
/// Compact 2×2 grid of side-letter-prefixed number inputs with a uniform-lock
/// toggle and preset dropdown.
library;

import 'package:flutter/material.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

class EdgeInsetsControl extends StatelessWidget {
  const EdgeInsetsControl({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 999,
  });

  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final double min;
  final double max;

  EdgeInsets _parse() {
    final v = value;
    if (v is EdgeInsets) return v;
    if (v is num) return EdgeInsets.all(v.toDouble());
    if (v is Map) {
      double d(String k) => (v[k] as num?)?.toDouble() ?? 0;
      return EdgeInsets.fromLTRB(d('left'), d('top'), d('right'), d('bottom'));
    }
    return EdgeInsets.zero;
  }

  @override
  Widget build(BuildContext context) {
    return SoftSaaSEdgeInsetsPickerInspector(
      value: _parse(),
      min: min,
      max: max,
      onChanged: (e) => onChanged({
        'top': e.top,
        'right': e.right,
        'bottom': e.bottom,
        'left': e.left,
      }),
    );
  }
}
