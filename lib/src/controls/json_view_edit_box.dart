library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:json_view_plus/json_view_plus.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

/// Read-only [JsonView] with a toggle to raw JSON editing.
class JsonViewEditBox extends StatefulWidget {
  const JsonViewEditBox({
    super.key,
    required this.value,
    required this.onChanged,
    this.defaultLines = 4,
  });

  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final int defaultLines;

  @override
  State<JsonViewEditBox> createState() => _JsonViewEditBoxState();
}

class _JsonViewEditBoxState extends State<JsonViewEditBox> {
  bool _editing = false;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight = constraints.hasBoundedHeight;
        final effectiveHeight = hasBoundedHeight
            ? constraints.maxHeight
            : _heightForLines(widget.defaultLines);

        final content = _editing
            ? _RawJsonEditor(
                value: widget.value,
                brightness: brightness,
                fillHeight: true,
                onChanged: widget.onChanged,
              )
            // No outer GestureDetector here — a DoubleTap recognizer above
            // JsonView makes every chevron tap wait ~300ms in the gesture
            // arena, which feels like expand/collapse lag. The pencil icon
            // in the top-right already toggles edit mode, so the double-tap
            // shortcut isn't load-bearing.
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: SoftSaaSTokens.primaryBorder(brightness),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: JsonView(
                  json: _normalize(widget.value),
                  padding: const EdgeInsets.only(top: 8, right: 12),
                ),
              );

        return SizedBox(
          width: double.infinity,
          height: effectiveHeight,
          child: Stack(
            children: [
              Positioned.fill(child: content),
              Positioned(
                top: 6,
                right: 6,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SoftSaaSActionButton(
                      icon: LucideIcons.copy,
                      tooltip: 'Copy JSON',
                      size: 12,
                      buttonSize: 20,
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: _encodeForCopy(widget.value)),
                        );
                      },
                    ),
                    const SizedBox(width: 2),
                    IconButton(
                      onPressed: () => setState(() => _editing = !_editing),
                      tooltip: _editing ? 'View JSON' : 'Edit raw JSON',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      icon: Icon(
                        _editing ? LucideIcons.eye : LucideIcons.pencil,
                        size: 12,
                        color: SoftSaaSTokens.tertiaryText(brightness),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _encodeForCopy(dynamic value) {
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } catch (_) {
      return value?.toString() ?? 'null';
    }
  }

  static double _heightForLines(int lines) {
    const fontSize = 11.0;
    const lineHeight = 1.4;
    const verticalPadding = 24.0; // top+bottom
    const border = 2.0; // top+bottom
    final safeLines = lines < 1 ? 1 : lines;
    return (safeLines * fontSize * lineHeight) + verticalPadding + border;
  }

  static dynamic _normalize(dynamic value) {
    if (value is Map || value is List) return value;
    return {'value': value};
  }
}

class _RawJsonEditor extends StatefulWidget {
  const _RawJsonEditor({
    required this.value,
    required this.brightness,
    required this.fillHeight,
    required this.onChanged,
  });

  final dynamic value;
  final Brightness brightness;
  final bool fillHeight;
  final ValueChanged<dynamic> onChanged;

  @override
  State<_RawJsonEditor> createState() => _RawJsonEditorState();
}

class _RawJsonEditorState extends State<_RawJsonEditor> {
  late final TextEditingController _controller;
  String? _error;
  late String _lastExternal;

  @override
  void initState() {
    super.initState();
    _lastExternal = _prettyJson(widget.value);
    _controller = TextEditingController(text: _lastExternal);
  }

  @override
  void didUpdateWidget(covariant _RawJsonEditor old) {
    super.didUpdateWidget(old);
    final encoded = _prettyJson(widget.value);
    if (encoded == _lastExternal) return;
    // Only overwrite the text field if the user hasn't modified it since we
    // last populated it — otherwise their in-progress edit would be lost.
    final canAdopt = _controller.text == _lastExternal;
    _lastExternal = encoded;
    if (canAdopt) {
      _controller.text = encoded;
      _error = null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    try {
      final decoded = jsonDecode(text);
      setState(() => _error = null);
      widget.onChanged(decoded);
    } catch (_) {
      setState(() => _error = 'Invalid JSON');
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = widget.brightness;
    final bg = SoftSaaSTokens.primaryBackground(brightness);
    final primary = SoftSaaSTokens.primaryText(brightness);
    final tertiary = SoftSaaSTokens.tertiaryText(brightness);
    final border = SoftSaaSTokens.primaryBorder(brightness);
    final errorColor = SoftSaaSTokens.errorColor(brightness);
    final hasError = _error != null;

    final outlineBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: BorderSide(color: hasError ? errorColor : border),
    );
    final focusedOutline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: BorderSide(
        color: hasError
            ? errorColor
            : SoftSaaSTokens.primaryColor(brightness).withValues(alpha: 0.5),
        width: 1.5,
      ),
    );

    final field = TextField(
      controller: _controller,
      expands: widget.fillHeight,
      maxLines: null,
      minLines: null,
      keyboardType: TextInputType.multiline,
      textAlignVertical: TextAlignVertical.top,
      style: TextStyle(
        fontSize: 11,
        fontFamily: 'monospace',
        color: primary,
        height: 1.4,
      ),
      decoration: InputDecoration(
        hintText: '{\n  "key": "value"\n}',
        hintStyle: TextStyle(
          fontSize: 11,
          fontFamily: 'monospace',
          color: tertiary,
        ),
        filled: true,
        fillColor: bg,
        isDense: true,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        contentPadding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
        border: outlineBorder,
        enabledBorder: outlineBorder,
        focusedBorder: focusedOutline,
      ),
      onChanged: _onChanged,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.fillHeight) Expanded(child: field) else field,
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Icon(Icons.error_outline, size: 14, color: errorColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _error!,
                    style: TextStyle(fontSize: 11, color: errorColor),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static String _prettyJson(dynamic value) {
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } catch (_) {
      return value?.toString() ?? 'null';
    }
  }
}
