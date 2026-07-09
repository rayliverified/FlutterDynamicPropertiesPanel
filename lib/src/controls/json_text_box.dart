library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

class JsonTextBox extends StatefulWidget {
  const JsonTextBox({super.key, required this.value, required this.onChanged});

  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  @override
  State<JsonTextBox> createState() => _JsonTextBoxState();
}

class _JsonTextBoxState extends State<JsonTextBox> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _prettyJson(widget.value));
  }

  @override
  void didUpdateWidget(covariant JsonTextBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_deepEquals(oldWidget.value, widget.value)) {
      _controller.text = _prettyJson(widget.value);
      _error = null;
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
      hintText: '{\n  "key": "value"\n}',
      errorText: _error,
      maxLines: 4,
      onChanged: _onTextChanged,
    );
  }

  void _onTextChanged(String text) {
    try {
      final decoded = jsonDecode(text);
      setState(() => _error = null);
      widget.onChanged(decoded);
    } catch (_) {
      setState(() => _error = 'Invalid JSON');
    }
  }

  static String _prettyJson(dynamic value) {
    const encoder = JsonEncoder.withIndent('  ');
    try {
      return encoder.convert(value);
    } catch (_) {
      return value?.toString() ?? 'null';
    }
  }

  static bool _deepEquals(dynamic a, dynamic b) {
    try {
      return jsonEncode(a) == jsonEncode(b);
    } catch (_) {
      return a == b;
    }
  }
}
