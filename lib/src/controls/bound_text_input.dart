library;

import 'package:flutter/material.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

class BoundTextInput extends StatefulWidget {
  const BoundTextInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.hintText,
  });

  final String value;
  final String? hintText;
  final ValueChanged<String> onChanged;

  @override
  State<BoundTextInput> createState() => _BoundTextInputState();
}

class _BoundTextInputState extends State<BoundTextInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant BoundTextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value;
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
      hintText: widget.hintText,
      size: SoftSaaSTextInputSize.small,
      onChanged: widget.onChanged,
    );
  }
}
