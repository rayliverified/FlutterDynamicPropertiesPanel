/// SizeControl — thin delegate over [SoftSaaSSizePickerInspector].
library;

import 'package:flutter/material.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

class SizeControl extends StatelessWidget {
  const SizeControl({super.key, required this.value, required this.onChanged});

  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  (double?, double?) _parse() {
    final v = value;
    if (v is Size) return (v.width, v.height);
    if (v is Map) {
      final w = v['width'] is num ? (v['width'] as num).toDouble() : null;
      final h = v['height'] is num ? (v['height'] as num).toDouble() : null;
      return (w, h);
    }
    return (null, null);
  }

  @override
  Widget build(BuildContext context) {
    final (w, h) = _parse();
    return SoftSaaSSizePickerInspector(
      width: w,
      height: h,
      onChanged: (nw, nh) {
        final out = <String, dynamic>{};
        if (nw != null) out['width'] = nw;
        if (nh != null) out['height'] = nh;
        onChanged(out);
      },
    );
  }
}
