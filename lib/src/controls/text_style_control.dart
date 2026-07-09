/// TextStyleControl — rich-text editor powered by textf + kitchen-sink toolbar.
library;

import 'package:flutter/material.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';
import 'package:textf/textf.dart';

class TextStyleControl extends StatefulWidget {
  const TextStyleControl({
    super.key,
    required this.value,
    required this.onChanged,
    this.fontFamilyOptions,
  });

  final dynamic value;
  final ValueChanged<Map<String, dynamic>> onChanged;

  /// Kept for backwards compatibility with existing constructor callsites.
  /// This control now uses markdown markers via `textf` instead.
  final List<String>? fontFamilyOptions;

  @override
  State<TextStyleControl> createState() => _TextStyleControlState();
}

class _TextStyleControlState extends State<TextStyleControl> {
  late final TextfEditingController _controller;
  late final UndoHistoryController _undoController;
  final Object _tapRegionGroup = Object();

  @override
  void initState() {
    super.initState();
    _controller = TextfEditingController(text: _extractMarkdown(widget.value));
    _undoController = UndoHistoryController();
  }

  @override
  void didUpdateWidget(covariant TextStyleControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextMarkdown = _extractMarkdown(widget.value);
    if (nextMarkdown != _controller.text) {
      _controller.value = TextEditingValue(
        text: nextMarkdown,
        selection: TextSelection.collapsed(offset: nextMarkdown.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _undoController.dispose();
    super.dispose();
  }

  String _extractMarkdown(dynamic value) {
    if (value is String) return value;
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      final markdown = map['markdown'];
      if (markdown is String) return markdown;
      final text = map['text'];
      if (text is String) return text;
    }
    return '';
  }

  void _emitMarkdown(String markdown) {
    final map = widget.value is Map
        ? Map<String, dynamic>.from(widget.value as Map)
        : <String, dynamic>{};
    map['markdown'] = markdown;
    widget.onChanged(map);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SoftSaaSRichTextToolbar.full(
          controller: _controller,
          undoController: _undoController,
          groupId: _tapRegionGroup,
        ),
        const SizedBox(height: 8),
        SoftSaaSRichTextField(
          controller: _controller,
          undoController: _undoController,
          groupId: _tapRegionGroup,
          size: SoftSaaSRichTextFieldSize.small,
          minLines: 3,
          maxLines: 8,
          hintText: 'Type label text and format it with the toolbar',
          onChanged: _emitMarkdown,
        ),
      ],
    );
  }
}
