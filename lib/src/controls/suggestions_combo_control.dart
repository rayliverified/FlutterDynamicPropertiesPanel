library;

import 'package:flutter/material.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

/// String input with suggestion dropdown.
class SuggestionsComboControl extends StatefulWidget {
  const SuggestionsComboControl({
    super.key,
    required this.initialValue,
    required this.suggestions,
    required this.hintText,
    required this.onChanged,
  });

  final String initialValue;
  final List<String> suggestions;
  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  State<SuggestionsComboControl> createState() =>
      _SuggestionsComboControlState();
}

class _SuggestionsComboControlState extends State<SuggestionsComboControl> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant SuggestionsComboControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.initialValue,
        selection: TextSelection.collapsed(offset: widget.initialValue.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SoftSaaSComboInput(
      controller: _controller,
      placeholder: widget.hintText,
      size: SoftSaaSComboInputSize.small,
      options: [
        for (final s in widget.suggestions) SelectOption(value: s, label: s),
      ],
      onChanged: widget.onChanged,
    );
  }
}
