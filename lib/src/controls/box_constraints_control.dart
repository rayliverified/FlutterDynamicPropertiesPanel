/// BoxConstraintsControl — thin delegate over [SoftSaaSBoxConstraintsPickerInspector].
library;

import 'package:flutter/material.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

class BoxConstraintsControl extends StatelessWidget {
  const BoxConstraintsControl({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  SoftSaaSBoxConstraintsValue _parse() {
    final v = value;
    if (v is Map) {
      double? d(String k) {
        final raw = v[k];
        if (raw is num) return raw.toDouble();
        if (raw is String) {
          final lower = raw.trim().toLowerCase();
          if (lower == '∞' || lower == 'inf' || lower == 'infinity') {
            return double.infinity;
          }
          return double.tryParse(raw);
        }
        return null;
      }

      return SoftSaaSBoxConstraintsValue(
        minWidth: d('minWidth'),
        maxWidth: d('maxWidth'),
        minHeight: d('minHeight'),
        maxHeight: d('maxHeight'),
      );
    }
    return const SoftSaaSBoxConstraintsValue();
  }

  @override
  Widget build(BuildContext context) {
    return SoftSaaSBoxConstraintsPickerInspector(
      value: _parse(),
      onChanged: (c) {
        final out = <String, dynamic>{};
        if (c.minWidth != null) out['minWidth'] = c.minWidth;
        if (c.maxWidth != null) out['maxWidth'] = c.maxWidth;
        if (c.minHeight != null) out['minHeight'] = c.minHeight;
        if (c.maxHeight != null) out['maxHeight'] = c.maxHeight;
        onChanged(out);
      },
    );
  }
}
