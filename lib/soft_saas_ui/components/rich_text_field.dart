// Soft SaaS UI Rich Text Field.
//
// A [TextField]-like widget backed by [TextfEditingController] from the
// `textf` package. Formatting is stored as Markdown-style markers in
// the plain text (e.g. `**bold**`, `*italic*`, `~~strike~~`). Pair with
// [SoftSaaSRichTextToolbar] for a click-to-wrap experience.
//
// Inline-only: bold / italic / underline / strike / code / highlight /
// sub- and super-script / links. No block formatting (textf doesn't do
// headings, lists, or colors). For block formatting, use AppFlowy.
library;

import 'package:flutter/material.dart';
import 'package:textf/textf.dart';

import '../design_tokens.dart';
import '../typography.dart';

enum SoftSaaSRichTextFieldSize { small, medium, large }

class SoftSaaSRichTextField extends StatefulWidget {
  const SoftSaaSRichTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.undoController,
    this.groupId = EditableText,
    this.initialMarkdown,
    this.onChanged,
    this.label,
    this.hintText,
    this.size = SoftSaaSRichTextFieldSize.medium,
    this.minLines = 3,
    this.maxLines = 10,
    this.enabled = true,
  });

  /// Provide a [TextfEditingController] from outside, or one will be created
  /// from [initialMarkdown].
  final TextfEditingController? controller;
  final FocusNode? focusNode;
  final UndoHistoryController? undoController;

  /// Tap region group used with [TextFieldTapRegion] wrappers (e.g. toolbars)
  /// so taps on companion controls don't count as outside taps.
  final Object groupId;

  final String? initialMarkdown;
  final ValueChanged<String>? onChanged;

  final String? label;
  final String? hintText;
  final SoftSaaSRichTextFieldSize size;
  final int? minLines;
  final int? maxLines;
  final bool enabled;

  @override
  State<SoftSaaSRichTextField> createState() => SoftSaaSRichTextFieldState();
}

class SoftSaaSRichTextFieldState extends State<SoftSaaSRichTextField> {
  TextfEditingController? _internal;
  FocusNode? _internalFocus;
  bool _focused = false;

  TextfEditingController get controller =>
      widget.controller ??
      (_internal ??= TextfEditingController(
        text: widget.initialMarkdown ?? '',
      ));

  FocusNode get focusNode =>
      widget.focusNode ?? (_internalFocus ??= FocusNode());

  @override
  void initState() {
    super.initState();
    focusNode.addListener(_onFocus);
  }

  @override
  void dispose() {
    focusNode.removeListener(_onFocus);
    _internal?.dispose();
    _internalFocus?.dispose();
    super.dispose();
  }

  void _onFocus() {
    if (!mounted) return;
    setState(() => _focused = focusNode.hasFocus);
  }

  double _fontSize() {
    switch (widget.size) {
      case SoftSaaSRichTextFieldSize.small:
      case SoftSaaSRichTextFieldSize.medium:
        return 13;
      case SoftSaaSRichTextFieldSize.large:
        return 15;
    }
  }

  EdgeInsets _padding() {
    switch (widget.size) {
      case SoftSaaSRichTextFieldSize.small:
        return const EdgeInsets.symmetric(horizontal: 10, vertical: 8);
      case SoftSaaSRichTextFieldSize.medium:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 10);
      case SoftSaaSRichTextFieldSize.large:
        return const EdgeInsets.symmetric(horizontal: 14, vertical: 12);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final border = _focused
        ? SoftSaaSTokens.primaryColor(brightness).withValues(alpha: 0.5)
        : SoftSaaSTokens.primaryBorder(brightness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: SoftSaaSTypography.label(brightness)),
          const SizedBox(height: 6),
        ],
        AnimatedContainer(
          duration: SoftSaaSTokens.transitionDuration,
          curve: SoftSaaSTokens.transitionCurve,
          decoration: BoxDecoration(
            color: SoftSaaSTokens.primaryBackground(brightness),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: border, width: 1.5),
          ),
          padding: _padding(),
          child: Material(
            color: Colors.transparent,
            child: Theme(
              data: Theme.of(context).copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
              ),
              child: TextSelectionTheme(
                data: TextSelectionThemeData(
                  selectionColor: Theme.of(
                    context,
                  ).textSelectionTheme.selectionColor,
                  selectionHandleColor: Colors.transparent,
                ),
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  undoController: widget.undoController,
                  groupId: widget.groupId,
                  enabled: widget.enabled,
                  minLines: widget.minLines,
                  maxLines: widget.maxLines,
                  onChanged: widget.onChanged,
                  style: TextStyle(
                    fontSize: _fontSize(),
                    color: SoftSaaSTokens.primaryText(brightness),
                    height: 1.45,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      fontSize: _fontSize(),
                      color: SoftSaaSTokens.tertiaryText(brightness),
                    ),
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
