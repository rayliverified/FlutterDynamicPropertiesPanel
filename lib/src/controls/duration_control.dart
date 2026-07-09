/// DurationControl — compact H/M/S/ms row stored as milliseconds.
library;

import 'package:flutter/material.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

class DurationControl extends StatelessWidget {
  const DurationControl({
    super.key,
    required this.value,
    required this.onChanged,
    this.hourEnabled = false,
    this.minuteEnabled = true,
    this.secondEnabled = true,
    this.msEnabled = true,
  });

  final dynamic value;
  final ValueChanged<int> onChanged;
  final bool hourEnabled;
  final bool minuteEnabled;
  final bool secondEnabled;
  final bool msEnabled;

  @override
  Widget build(BuildContext context) {
    final totalMs = switch (value) {
      int ms => ms,
      double ms => ms.round(),
      Duration d => d.inMilliseconds,
      _ => 0,
    };
    final h = (totalMs ~/ 3600000);
    final m = (totalMs % 3600000) ~/ 60000;
    final s = (totalMs % 60000) ~/ 1000;
    final ms = totalMs % 1000;

    void emit(int nh, int nm, int ns, int nms) {
      onChanged(nh * 3600000 + nm * 60000 + ns * 1000 + nms);
    }

    Widget cell(int v, String label, void Function(int) set) => Expanded(
      child: SoftSaaSNumberInput(
        label: label,
        showLabel: true,
        value: v.toDouble(),
        size: SoftSaaSNumberInputSize.small,
        showStepper: false,
        allowNegative: false,
        decimalPlaces: 0,
        width: double.infinity,
        onChanged: (nv) => set((nv ?? 0).round()),
      ),
    );

    final brightness = Theme.of(context).brightness;

    // SizedBox(height: 32) matches the small input height. Center() vertically
    // centers the colon inside it. CrossAxisAlignment.end on the Row aligns the
    // 32px colon box with the bottom of each cell (label + input column), so
    // the colon sits exactly in the middle of the input area, not the label.
    final colon = SizedBox(
      height: 32,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            ':',
            style: SoftSaaSTypography.bodySmall(brightness).copyWith(
              color: SoftSaaSTokens.secondaryText(brightness),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );

    // Build cells and colons dynamically, inserting colons only between visible cells.
    final cells = <({Widget widget, bool enabled})>[
      (widget: cell(h, 'h', (v) => emit(v, m, s, ms)), enabled: hourEnabled),
      (widget: cell(m, 'm', (v) => emit(h, v, s, ms)), enabled: minuteEnabled),
      (widget: cell(s, 's', (v) => emit(h, m, v, ms)), enabled: secondEnabled),
      (widget: cell(ms, 'ms', (v) => emit(h, m, s, v)), enabled: msEnabled),
    ];

    final children = <Widget>[];
    bool lastWasCell = false;
    for (final c in cells) {
      if (!c.enabled) continue;
      if (lastWasCell) children.add(colon);
      children.add(c.widget);
      lastWasCell = true;
    }

    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: children);
  }
}
