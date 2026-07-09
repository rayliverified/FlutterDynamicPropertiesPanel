/// AlignmentControl — thin delegate over [SoftSaaSAlignmentPickerInspector].
library;

import 'package:flutter/material.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

class AlignmentControl extends StatelessWidget {
  const AlignmentControl({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  Alignment _parse() {
    final v = value;
    if (v is Alignment) return v;
    if (v is Map) {
      final x = (v['x'] as num?)?.toDouble();
      final y = (v['y'] as num?)?.toDouble();
      if (x != null && y != null) return Alignment(x, y);
    }
    return Alignment.center;
  }

  @override
  Widget build(BuildContext context) {
    return SoftSaaSAlignmentPickerInspector(
      alignment: _parse(),
      onChanged: (a) => onChanged({'x': a.x, 'y': a.y}),
    );
  }
}
