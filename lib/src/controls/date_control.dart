/// DateControl — read-only hex-like field that opens the platform date picker.
library;

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

class DateControl extends StatefulWidget {
  const DateControl({
    super.key,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
  });

  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  State<DateControl> createState() => _DateControlState();
}

class _DateControlState extends State<DateControl> {
  late TextEditingController _controller;

  DateTime? _parse(dynamic v) {
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is double) return DateTime.fromMillisecondsSinceEpoch(v.round());
    return null;
  }

  String _format(DateTime? d) => d == null
      ? ''
      : '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _format(_parse(widget.value)));
  }

  @override
  void didUpdateWidget(covariant DateControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _controller.text = _format(_parse(widget.value));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SoftSaaSTextInput(
      controller: _controller,
      hintText: 'YYYY-MM-DD',
      size: SoftSaaSTextInputSize.small,
      readOnly: true,
      suffixIcon: LucideIcons.calendar,
      onTap: () async {
        final firstDate = widget.firstDate ?? DateTime(2000);
        final lastDate = widget.lastDate ?? DateTime(2100);
        final parsed = _parse(widget.value) ?? DateTime.now();
        final initialDate = parsed.isBefore(firstDate)
            ? firstDate
            : (parsed.isAfter(lastDate) ? lastDate : parsed);
        final picked = await showDatePicker(
          context: context,
          firstDate: firstDate,
          lastDate: lastDate,
          initialDate: initialDate,
        );
        if (picked != null) widget.onChanged(picked.toIso8601String());
      },
    );
  }
}
