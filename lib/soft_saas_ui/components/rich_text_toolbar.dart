/// Soft SaaS UI Rich Text Toolbar — the kitchen sink of inline-formatting
/// buttons for [SoftSaaSRichTextField] / [TextfEditingController].
///
/// Because `textf` stores formatting as Markdown markers in plain text,
/// each toolbar button is a *wrap toggle*: it inserts (or removes) a pair
/// of markers around the current selection. Active state is detected by
/// peeking at the characters immediately surrounding the selection.
///
/// Variants:
///   * `mini`: undo/redo + core inline buttons + overflow menu
///   * `full`: everything in mini, plus highlight + clear formatting section
///
/// Block-level formatting (headings, lists, color) is deliberately
/// **not** included — `textf` is inline-only. Use AppFlowy for block
/// editors.
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:textf/textf.dart';

import '../design_tokens.dart';
import 'dropdown.dart' as ssd;

enum SoftSaaSRichTextToolbarVariant { mini, full }

/// Markers supported by `textf`.
enum _Marker {
  bold,
  italic,
  underline,
  strike,
  code,
  highlight,
  superscript,
  subscript,
}

extension on _Marker {
  String get open => switch (this) {
    _Marker.bold => '**',
    _Marker.italic => '*',
    _Marker.underline => '++',
    _Marker.strike => '~~',
    _Marker.code => '`',
    _Marker.highlight => '==',
    _Marker.superscript => '^',
    _Marker.subscript => '~',
  };

  IconData get icon => switch (this) {
    _Marker.bold => LucideIcons.bold,
    _Marker.italic => LucideIcons.italic,
    _Marker.underline => LucideIcons.underline,
    _Marker.strike => LucideIcons.strikethrough,
    _Marker.code => LucideIcons.code,
    _Marker.highlight => LucideIcons.highlighter,
    _Marker.superscript => LucideIcons.superscript,
    _Marker.subscript => LucideIcons.subscript,
  };

  String get label => switch (this) {
    _Marker.bold => 'Bold',
    _Marker.italic => 'Italic',
    _Marker.underline => 'Underline',
    _Marker.strike => 'Strikethrough',
    _Marker.code => 'Inline code',
    _Marker.highlight => 'Highlight',
    _Marker.superscript => 'Superscript',
    _Marker.subscript => 'Subscript',
  };
}

class SoftSaaSRichTextToolbar extends StatefulWidget {
  const SoftSaaSRichTextToolbar({
    super.key,
    required this.controller,
    this.undoController,
    this.variant = SoftSaaSRichTextToolbarVariant.mini,
    this.groupId = EditableText,
  });

  const SoftSaaSRichTextToolbar.full({
    super.key,
    required this.controller,
    this.undoController,
    this.groupId = EditableText,
  }) : variant = SoftSaaSRichTextToolbarVariant.full;

  final TextfEditingController controller;

  /// External undo history controller for programmatic undo/redo buttons.
  final UndoHistoryController? undoController;

  /// Tap region group shared with the paired text field so toolbar taps don't
  /// count as outside taps that would clear text selection/focus.
  final Object groupId;

  final SoftSaaSRichTextToolbarVariant variant;

  @override
  State<SoftSaaSRichTextToolbar> createState() =>
      _SoftSaaSRichTextToolbarState();
}

class _SoftSaaSRichTextToolbarState extends State<SoftSaaSRichTextToolbar> {
  static const _overflowMarkers = <_Marker>[
    _Marker.strike,
    _Marker.subscript,
    _Marker.superscript,
  ];

  final ScrollController _scrollController = ScrollController();

  Set<_Marker> _active = <_Marker>{};
  bool _showLeftFade = false;
  bool _showRightFade = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_recomputeActive);
    widget.undoController?.addListener(_onUndoStateChanged);
    _scrollController.addListener(_updateOverflowState);
    _recomputeActive();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateOverflowState());
  }

  @override
  void didUpdateWidget(covariant SoftSaaSRichTextToolbar old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_recomputeActive);
      widget.controller.addListener(_recomputeActive);
      _recomputeActive();
    }
    if (old.undoController != widget.undoController) {
      old.undoController?.removeListener(_onUndoStateChanged);
      widget.undoController?.addListener(_onUndoStateChanged);
      _onUndoStateChanged();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateOverflowState());
  }

  @override
  void dispose() {
    widget.controller.removeListener(_recomputeActive);
    widget.undoController?.removeListener(_onUndoStateChanged);
    _scrollController.removeListener(_updateOverflowState);
    _scrollController.dispose();
    super.dispose();
  }

  void _onUndoStateChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _updateOverflowState() {
    if (!mounted || !_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final showLeft = max > 0 && _scrollController.offset > 0.5;
    final showRight = max > 0 && _scrollController.offset < max - 0.5;
    if (showLeft != _showLeftFade || showRight != _showRightFade) {
      setState(() {
        _showLeftFade = showLeft;
        _showRightFade = showRight;
      });
    }
  }

  void _scrollLeft() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      (_scrollController.offset - 160).clamp(0.0, double.infinity),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _scrollRight() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      (_scrollController.offset + 160).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  // Conservative marker-active detection.
  void _recomputeActive() {
    final text = widget.controller.text;
    final sel = widget.controller.selection;
    final start = sel.start;
    final end = sel.end;
    if (start < 0 || end < 0 || start > text.length || end > text.length) {
      if (_active.isNotEmpty) setState(() => _active = <_Marker>{});
      return;
    }
    final active = <_Marker>{};
    for (final m in _Marker.values) {
      if (_isWrapped(text, start, end, m)) active.add(m);
    }
    if (active.length != _active.length ||
        !active.containsAll(_active) ||
        !_active.containsAll(active)) {
      setState(() => _active = active);
    }
  }

  bool _isWrapped(String text, int start, int end, _Marker m) {
    final marker = m.open;
    final lineStart = text.lastIndexOf('\n', start - 1) + 1;
    final lineEndIdx = text.indexOf('\n', end);
    final lineEnd = lineEndIdx == -1 ? text.length : lineEndIdx;

    final openIndex = _findLastMarker(
      text: text,
      marker: marker,
      fromInclusive: lineStart,
      toExclusive: start,
    );
    if (openIndex == null) return false;

    if (_containsMarker(
      text: text,
      marker: marker,
      fromInclusive: openIndex + marker.length,
      toExclusive: start,
    )) {
      return false;
    }

    final closeIndex = _findFirstMarker(
      text: text,
      marker: marker,
      fromInclusive: end,
      toExclusive: lineEnd,
    );
    if (closeIndex == null) return false;

    if (_containsMarker(
      text: text,
      marker: marker,
      fromInclusive: end,
      toExclusive: closeIndex,
    )) {
      return false;
    }

    return true;
  }

  int? _findFirstMarker({
    required String text,
    required String marker,
    required int fromInclusive,
    required int toExclusive,
  }) {
    var cursor = fromInclusive;
    while (cursor < toExclusive) {
      final idx = text.indexOf(marker, cursor);
      if (idx == -1 || idx >= toExclusive) return null;
      if (_isStandaloneMarkerAt(text, idx, marker)) return idx;
      cursor = idx + 1;
    }
    return null;
  }

  int? _findLastMarker({
    required String text,
    required String marker,
    required int fromInclusive,
    required int toExclusive,
  }) {
    var cursor = toExclusive - marker.length;
    while (cursor >= fromInclusive) {
      final idx = text.lastIndexOf(marker, cursor);
      if (idx < fromInclusive) return null;
      if (_isStandaloneMarkerAt(text, idx, marker)) return idx;
      cursor = idx - 1;
    }
    return null;
  }

  bool _containsMarker({
    required String text,
    required String marker,
    required int fromInclusive,
    required int toExclusive,
  }) {
    return _findFirstMarker(
          text: text,
          marker: marker,
          fromInclusive: fromInclusive,
          toExclusive: toExclusive,
        ) !=
        null;
  }

  bool _isStandaloneMarkerAt(String text, int index, String marker) {
    if (index < 0 || index + marker.length > text.length) return false;
    if (text.substring(index, index + marker.length) != marker) return false;

    if (marker == '*' || marker == '~') {
      final prevSame = index > 0 && text[index - 1] == marker;
      final nextSame =
          index + marker.length < text.length &&
          text[index + marker.length] == marker;
      if (prevSame || nextSame) return false;
    }
    return true;
  }

  void _toggle(_Marker m) {
    final ctrl = widget.controller;
    final text = ctrl.text;
    final sel = ctrl.selection;
    if (sel.start < 0 || sel.end < 0) return;

    final open = m.open;

    if (_active.contains(m)) {
      final before = text.substring(0, sel.start);
      final after = text.substring(sel.end);
      final lastOpen = before.lastIndexOf(open);
      final firstClose = after.indexOf(open);
      if (lastOpen == -1 || firstClose == -1) return;

      final newText =
          before.substring(0, lastOpen) +
          before.substring(lastOpen + open.length) +
          text.substring(sel.start, sel.end) +
          after.substring(0, firstClose) +
          after.substring(firstClose + open.length);

      final delta = -open.length;
      ctrl.value = TextEditingValue(
        text: newText,
        selection: TextSelection(
          baseOffset: sel.start + delta,
          extentOffset: sel.end + delta,
        ),
      );
      return;
    }

    final selected = sel.start == sel.end
        ? ''
        : text.substring(sel.start, sel.end);
    final newText =
        '${text.substring(0, sel.start)}$open$selected$open${text.substring(sel.end)}';
    final newStart = sel.start + open.length;
    final newEnd = newStart + selected.length;
    ctrl.value = TextEditingValue(
      text: newText,
      selection: sel.start == sel.end
          ? TextSelection.collapsed(offset: newStart)
          : TextSelection(baseOffset: newStart, extentOffset: newEnd),
    );
  }

  void _insertLink() {
    final ctrl = widget.controller;
    final text = ctrl.text;
    final sel = ctrl.selection;
    if (sel.start < 0) return;
    final selected = sel.start == sel.end
        ? 'link text'
        : text.substring(sel.start, sel.end);
    final snippet = '[$selected](https://)';
    final newText =
        '${text.substring(0, sel.start)}$snippet${text.substring(sel.end)}';
    final urlStart = sel.start + snippet.indexOf('https://');
    final urlEnd = urlStart + 'https://'.length;
    ctrl.value = TextEditingValue(
      text: newText,
      selection: TextSelection(baseOffset: urlStart, extentOffset: urlEnd),
    );
  }

  void _clearFormatting() {
    final ctrl = widget.controller;
    final text = ctrl.text;
    final sel = ctrl.selection;
    if (sel.start < 0 || sel.end < 0) return;

    // Collapsed cursor: clear enclosing active markers around the caret,
    // so users can clear formatting without manually selecting text.
    if (sel.isCollapsed) {
      var workingText = text;
      var caret = sel.start;
      var changed = false;

      final activeMarkers = _Marker.values.where(_active.contains).toList()
        ..sort((a, b) => b.open.length.compareTo(a.open.length));

      for (final m in activeMarkers) {
        final marker = m.open;
        final openIndex = _findLastMarker(
          text: workingText,
          marker: marker,
          fromInclusive: 0,
          toExclusive: caret,
        );
        final closeIndex = _findFirstMarker(
          text: workingText,
          marker: marker,
          fromInclusive: caret,
          toExclusive: workingText.length,
        );

        if (openIndex == null || closeIndex == null) continue;

        workingText =
            workingText.substring(0, closeIndex) +
            workingText.substring(closeIndex + marker.length);
        workingText =
            workingText.substring(0, openIndex) +
            workingText.substring(openIndex + marker.length);

        caret = (caret - marker.length).clamp(0, workingText.length);
        changed = true;
      }

      if (!changed) return;
      ctrl.value = TextEditingValue(
        text: workingText,
        selection: TextSelection.collapsed(offset: caret),
      );
      return;
    }

    // Selection: clear markers within the selected range.
    final selected = text.substring(sel.start, sel.end);
    var cleaned = selected;
    for (final m in const ['**', '++', '~~', '==', '*', '`', '^', '~']) {
      cleaned = cleaned.replaceAll(m, '');
    }
    if (cleaned == selected) return;

    final newText =
        '${text.substring(0, sel.start)}$cleaned${text.substring(sel.end)}';
    final newEnd = sel.start + cleaned.length;
    ctrl.value = TextEditingValue(
      text: newText,
      selection: TextSelection(baseOffset: sel.start, extentOffset: newEnd),
    );
  }

  void _undo() {
    final undo = widget.undoController;
    if (undo == null || !undo.value.canUndo) return;
    undo.undo();
  }

  void _redo() {
    final undo = widget.undoController;
    if (undo == null || !undo.value.canRedo) return;
    undo.redo();
  }

  _Marker? _activeOverflowMarker() {
    for (final m in _overflowMarkers) {
      if (_active.contains(m)) return m;
    }
    return null;
  }

  Widget _section(List<Widget> children) {
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }

  List<Widget> _interleaveSections(List<Widget> sections) {
    final out = <Widget>[];
    for (var i = 0; i < sections.length; i++) {
      if (i > 0) out.add(const _ToolbarDivider());
      out.add(sections[i]);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final canUndo = widget.undoController?.value.canUndo ?? false;
    final canRedo = widget.undoController?.value.canRedo ?? false;
    final hasActiveOverflow = _activeOverflowMarker() != null;

    final sections = <Widget>[
      _section([
        _ToolbarButton(
          icon: _Marker.bold.icon,
          tooltip: _Marker.bold.label,
          active: _active.contains(_Marker.bold),
          onPressed: () => _toggle(_Marker.bold),
        ),
        _ToolbarButton(
          icon: _Marker.italic.icon,
          tooltip: _Marker.italic.label,
          active: _active.contains(_Marker.italic),
          onPressed: () => _toggle(_Marker.italic),
        ),
        _ToolbarButton(
          icon: _Marker.underline.icon,
          tooltip: _Marker.underline.label,
          active: _active.contains(_Marker.underline),
          onPressed: () => _toggle(_Marker.underline),
        ),
        for (final m in _overflowMarkers)
          if (_active.contains(m))
            _ToolbarButton(
              icon: m.icon,
              tooltip: m.label,
              active: true,
              onPressed: () => _toggle(m),
            ),
        _OverflowToolbarButton(
          icon: LucideIcons.ellipsis_vertical,
          tooltip: 'More formatting',
          selected: hasActiveOverflow,
          items: [
            for (final m in _overflowMarkers)
              ssd.DropdownMenuItem(
                label: m.label,
                icon: m.icon,
                onTap: () => _toggle(m),
              ),
          ],
        ),
      ]),
      _section([
        _ToolbarButton(
          icon: LucideIcons.undo_2,
          tooltip: 'Undo',
          enabled: canUndo,
          onPressed: _undo,
        ),
        _ToolbarButton(
          icon: LucideIcons.redo_2,
          tooltip: 'Redo',
          enabled: canRedo,
          onPressed: _redo,
        ),
      ]),
      _section([
        _ToolbarButton(
          icon: _Marker.code.icon,
          tooltip: _Marker.code.label,
          active: _active.contains(_Marker.code),
          onPressed: () => _toggle(_Marker.code),
        ),
        _ToolbarButton(
          icon: LucideIcons.link,
          tooltip: 'Insert link',
          onPressed: _insertLink,
        ),
        if (widget.variant == SoftSaaSRichTextToolbarVariant.full)
          _ToolbarButton(
            icon: _Marker.highlight.icon,
            tooltip: _Marker.highlight.label,
            active: _active.contains(_Marker.highlight),
            onPressed: () => _toggle(_Marker.highlight),
          ),
        if (widget.variant == SoftSaaSRichTextToolbarVariant.full)
          const _ToolbarDivider(),
        if (widget.variant == SoftSaaSRichTextToolbarVariant.full)
          _ToolbarButton(
            icon: LucideIcons.eraser,
            tooltip: 'Clear formatting',
            onPressed: _clearFormatting,
          ),
      ]),
    ];

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: _interleaveSections(sections),
    );

    return TextFieldTapRegion(
      groupId: widget.groupId,
      child: Container(
        width: double.infinity,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: SoftSaaSTokens.primaryBorder(brightness)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            children: [
              ScrollConfiguration(
                behavior: const MaterialScrollBehavior().copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.stylus,
                    PointerDeviceKind.invertedStylus,
                    PointerDeviceKind.trackpad,
                    PointerDeviceKind.unknown,
                  },
                ),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (_) {
                    _updateOverflowState();
                    return false;
                  },
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(2),
                    child: row,
                  ),
                ),
              ),
              if (_showLeftFade)
                _ToolbarScrim(side: _ScrimSide.left, onTapArrow: _scrollLeft),
              if (_showRightFade)
                _ToolbarScrim(side: _ScrimSide.right, onTapArrow: _scrollRight),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatefulWidget {
  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.active = false,
    this.enabled = true,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool active;
  final bool enabled;

  @override
  State<_ToolbarButton> createState() => _ToolbarButtonState();
}

class _ToolbarButtonState extends State<_ToolbarButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return _chipShell(
      selected: widget.active,
      hovered: _hovered,
      brightness: brightness,
      enabled: widget.enabled,
      tooltip: widget.tooltip,
      onEnter: () => setState(() => _hovered = true),
      onExit: () => setState(() => _hovered = false),
      onTap: widget.onPressed,
      child: Icon(
        widget.icon,
        size: 14,
        color: !widget.enabled
            ? SoftSaaSTokens.tertiaryText(brightness)
            : widget.active
            ? (brightness == Brightness.dark
                  ? SoftSaaSTokens.primaryText(brightness)
                  : SoftSaaSTokens.secondaryText(brightness))
            : SoftSaaSTokens.secondaryText(brightness),
      ),
    );
  }
}

class _OverflowToolbarButton extends StatefulWidget {
  const _OverflowToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.selected,
    required this.items,
  });

  final IconData icon;
  final String tooltip;
  final bool selected;
  final List<ssd.DropdownMenuItem> items;

  @override
  State<_OverflowToolbarButton> createState() => _OverflowToolbarButtonState();
}

class _OverflowToolbarButtonState extends State<_OverflowToolbarButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return ssd.SoftSaaSMenuDropdown(
      alignment: ssd.SoftSaaSMenuDropdownAlignment.end,
      width: 160,
      verticalOffset: 4,
      items: widget.items,
      trigger: _chipShell(
        selected: widget.selected,
        hovered: _hovered,
        brightness: brightness,
        enabled: true,
        tooltip: widget.tooltip,
        onEnter: () => setState(() => _hovered = true),
        onExit: () => setState(() => _hovered = false),
        onTap: null,
        child: Icon(
          widget.icon,
          size: 14,
          color: widget.selected
              ? (brightness == Brightness.dark
                    ? SoftSaaSTokens.primaryText(brightness)
                    : SoftSaaSTokens.secondaryText(brightness))
              : SoftSaaSTokens.secondaryText(brightness),
        ),
      ),
    );
  }
}

class _ToolbarDivider extends StatelessWidget {
  const _ToolbarDivider();

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Container(
      width: 1,
      height: 18,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: SoftSaaSTokens.primaryBorder(brightness),
    );
  }
}

enum _ScrimSide { left, right }

class _ToolbarScrim extends StatelessWidget {
  const _ToolbarScrim({required this.side, required this.onTapArrow});

  final _ScrimSide side;
  final VoidCallback onTapArrow;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final fadeBg = SoftSaaSTokens.primaryBackground(brightness);

    return Positioned(
      left: side == _ScrimSide.left ? 0 : null,
      right: side == _ScrimSide.right ? 0 : null,
      top: 0,
      bottom: 0,
      child: SizedBox(
        width: 52,
        child: Stack(
          children: [
            // Match the scrollable tabs affordance: a non-interactive edge
            // gradient shows that more content is hidden off-screen.
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: side == _ScrimSide.left
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      end: side == _ScrimSide.left
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      stops: const [0, 0.58, 1],
                      colors: [
                        fadeBg,
                        fadeBg.withValues(alpha: 0.86),
                        fadeBg.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: side == _ScrimSide.left
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _ScrollArrowButton(
                  icon: side == _ScrimSide.left
                      ? LucideIcons.chevron_left
                      : LucideIcons.chevron_right,
                  onPressed: onTapArrow,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScrollArrowButton extends StatelessWidget {
  const _ScrollArrowButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: SoftSaaSTokens.tertiaryBackground(brightness),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 14,
            color: SoftSaaSTokens.secondaryText(brightness),
          ),
        ),
      ),
    );
  }
}

Widget _chipShell({
  required bool selected,
  required bool hovered,
  required Brightness brightness,
  required bool enabled,
  required String tooltip,
  required VoidCallback onEnter,
  required VoidCallback onExit,
  required VoidCallback? onTap,
  required Widget child,
}) {
  final bg = selected
      ? (brightness == Brightness.dark
            ? SoftSaaSTokens.tertiaryBackground(brightness)
            : Colors.white)
      : (hovered
            ? SoftSaaSTokens.controlHoverOverlay(brightness)
            : Colors.transparent);

  final border = selected
      ? Border.all(color: SoftSaaSTokens.primaryBorder(brightness))
      : null;

  Widget chip = Container(
    width: 32,
    height: double.infinity,
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(6),
      border: border,
      boxShadow: selected
          ? (brightness == Brightness.dark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ])
          : null,
    ),
    alignment: Alignment.center,
    child: child,
  );

  if (onTap != null) {
    chip = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: chip,
    );
  }

  return Tooltip(
    message: tooltip,
    waitDuration: const Duration(milliseconds: 400),
    child: MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => onEnter(),
      onExit: (_) => onExit(),
      child: chip,
    ),
  );
}
