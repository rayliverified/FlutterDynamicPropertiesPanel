// Soft SaaS UI Combo Input.
//
// A text input with a right-side chevron that opens a dropdown menu
// anchored to the field. Unlike [SoftSaaSCombobox] (which is a
// search-to-filter select), this is a **free-text field** with an
// optional preset list — pick from the menu or type anything.
//
// Used for:
//   - Language/extension filters (replaces the `PopupMenuButton`
//     suffix in compact token-input UIs)
//   - Font family picker with custom-value fallback
//   - Enum props that allow a custom literal
//
// The menu visual matches [SoftSaaSDropdown] exactly (radius, shadow,
// option padding, selected highlight).
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../design_tokens.dart';
import '../typography.dart';
import 'select.dart' show SelectOption;

enum SoftSaaSComboInputSize { small, medium, large }

class SoftSaaSComboInput extends StatefulWidget {
  const SoftSaaSComboInput({
    super.key,
    this.controller,
    this.options = const <SelectOption>[],
    this.onChanged,
    this.onSubmitted,
    this.onOptionSelected,
    this.placeholder,
    this.size = SoftSaaSComboInputSize.medium,
    this.enabled = true,
    this.errorText,
    this.label,
    this.prefixIcon,
  });

  final TextEditingController? controller;

  /// Preset options shown when the chevron is tapped.
  final List<SelectOption> options;

  /// Called on every keystroke.
  final ValueChanged<String>? onChanged;

  /// Called when the user presses Enter.
  final ValueChanged<String>? onSubmitted;

  /// Called when the user picks a preset option from the menu.
  /// If null, the option's `value` is written into the field and
  /// [onChanged] fires.
  final ValueChanged<SelectOption>? onOptionSelected;

  final String? placeholder;
  final SoftSaaSComboInputSize size;
  final bool enabled;
  final String? errorText;
  final String? label;
  final IconData? prefixIcon;

  @override
  State<SoftSaaSComboInput> createState() => _SoftSaaSComboInputState();
}

class _SoftSaaSComboInputState extends State<SoftSaaSComboInput> {
  TextEditingController? _internalController;
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  final ScrollController _menuScrollController = ScrollController();
  OverlayEntry? _overlayEntry;
  bool _menuOpen = false;
  bool _isFocused = false;
  // When opened via chevron, show all options; typing activates filter.
  bool _chevronOpen = false;
  String _filterText = '';
  int? _highlightedIndex;

  TextEditingController get _controller =>
      widget.controller ?? (_internalController ??= TextEditingController());

  List<SelectOption> get _visibleOptions {
    if (_chevronOpen || _filterText.isEmpty) return widget.options;
    final q = _filterText.toLowerCase();
    return widget.options
        .where(
          (o) =>
              o.label.toLowerCase().contains(q) ||
              o.value.toLowerCase().contains(q),
        )
        .toList();
  }

  void _handleTextChanged(String text) {
    setState(() {
      _filterText = text;
      _chevronOpen = false;
      _highlightedIndex = null;
    });
    widget.onChanged?.call(text);
    if (!_menuOpen && text.isNotEmpty && widget.options.isNotEmpty) {
      _openMenu();
    }
    _overlayEntry?.markNeedsBuild();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (!_menuOpen) return KeyEventResult.ignored;
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final options = _visibleOptions;
    if (options.isEmpty) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        _highlightedIndex = _highlightedIndex == null
            ? 0
            : (_highlightedIndex! + 1) % options.length;
      });
      _scrollToHighlighted();
      _overlayEntry?.markNeedsBuild();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _highlightedIndex = _highlightedIndex == null
            ? options.length - 1
            : (_highlightedIndex! - 1 + options.length) % options.length;
      });
      _scrollToHighlighted();
      _overlayEntry?.markNeedsBuild();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      final idx = _highlightedIndex;
      if (idx != null && idx < options.length) {
        final option = options[idx];
        if (!option.disabled) {
          _selectOption(option);
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _closeMenu();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _scrollToHighlighted() {
    if (_highlightedIndex == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_menuScrollController.hasClients) return;
      final itemHeight = widget.size == SoftSaaSComboInputSize.large
          ? 30.0
          : 28.0;
      final targetOffset = (_highlightedIndex! * itemHeight).clamp(
        0.0,
        _menuScrollController.position.maxScrollExtent,
      );
      _menuScrollController.jumpTo(targetOffset);
    });
  }

  void _selectOption(SelectOption option) {
    setState(() {
      _chevronOpen = false;
      _filterText = '';
      _highlightedIndex = null;
    });
    if (widget.onOptionSelected != null) {
      widget.onOptionSelected!(option);
    } else {
      final display = option.label.isNotEmpty ? option.label : option.value;
      _controller.value = TextEditingValue(
        text: display,
        selection: TextSelection.collapsed(offset: display.length),
      );
      widget.onChanged?.call(display);
    }
    _closeMenu();
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocus);
    _focusNode.onKeyEvent = _handleKeyEvent;
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocus);
    _focusNode.dispose();
    _menuScrollController.dispose();
    _closeMenu();
    _internalController?.dispose();
    super.dispose();
  }

  void _handleFocus() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  void _toggleMenu() {
    if (!widget.enabled || widget.options.isEmpty) return;
    if (_menuOpen) {
      _closeMenu();
    } else {
      setState(() => _chevronOpen = true);
      _focusNode.requestFocus();
      _openMenu();
    }
  }

  void _openMenu() {
    if (_menuOpen) return;
    final currentText = _controller.text;
    final matchIdx = widget.options.indexWhere(
      (o) => o.value == currentText || o.label == currentText,
    );
    setState(() {
      _menuOpen = true;
      _highlightedIndex = matchIdx >= 0 ? matchIdx : null;
    });
    _overlayEntry = _createOverlay();
    Overlay.of(context).insert(_overlayEntry!);
    if (_highlightedIndex != null) _scrollToHighlighted();
  }

  void _closeMenu() {
    if (!_menuOpen && _overlayEntry == null) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _menuOpen = false;
        _highlightedIndex = null;
      });
    }
  }

  OverlayEntry _createOverlay() {
    final renderBox = context.findRenderObject() as RenderBox;
    final triggerSize = renderBox.size;
    final overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final triggerTop = renderBox
        .localToGlobal(Offset.zero, ancestor: overlayBox)
        .dy;
    final triggerBottom = triggerTop + triggerSize.height;
    final spaceBelow = overlayBox.size.height - triggerBottom;
    final spaceAbove = triggerTop;
    const gap = 4.0;
    const menuMaxHeight = 240.0;
    final openUp = spaceBelow < menuMaxHeight && spaceAbove > spaceBelow;
    final availableHeight = (openUp ? spaceAbove : spaceBelow) - gap;
    final menuMax = availableHeight.clamp(120.0, menuMaxHeight).toDouble();

    return OverlayEntry(
      builder: (_) {
        final targetAnchor = openUp ? Alignment.topLeft : Alignment.bottomLeft;
        final followerAnchor = openUp
            ? Alignment.bottomLeft
            : Alignment.topLeft;
        final menuOffset = Offset(0, openUp ? -gap : gap);

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _closeMenu,
              ),
            ),
            Positioned(
              width: triggerSize.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                targetAnchor: targetAnchor,
                followerAnchor: followerAnchor,
                offset: menuOffset,
                child: Material(
                  type: MaterialType.transparency,
                  child: _OptionsMenu(
                    options: _visibleOptions,
                    currentValue: _controller.text,
                    query: _filterText,
                    highlightedIndex: _highlightedIndex,
                    scrollController: _menuScrollController,
                    size: widget.size,
                    maxHeight: menuMax,
                    onSelected: _selectOption,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  double _height() {
    switch (widget.size) {
      case SoftSaaSComboInputSize.small:
        return 32;
      case SoftSaaSComboInputSize.medium:
        return 36;
      case SoftSaaSComboInputSize.large:
        return 44;
    }
  }

  double _fontSize() {
    switch (widget.size) {
      case SoftSaaSComboInputSize.small:
      case SoftSaaSComboInputSize.medium:
        return 13;
      case SoftSaaSComboInputSize.large:
        return 15;
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final hasError = widget.errorText != null;
    final showFocusRing = _isFocused || _menuOpen;
    final border = hasError
        ? SoftSaaSTokens.errorColor(brightness)
        : showFocusRing
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
        CompositedTransformTarget(
          link: _layerLink,
          child: AnimatedContainer(
            duration: SoftSaaSTokens.transitionDuration,
            curve: SoftSaaSTokens.transitionCurve,
            height: _height(),
            decoration: BoxDecoration(
              color: SoftSaaSTokens.primaryBackground(brightness),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: border, width: 1.5),
            ),
            child: Row(
              children: [
                if (widget.prefixIcon != null) ...[
                  const SizedBox(width: 10),
                  Icon(
                    widget.prefixIcon,
                    size: 16,
                    color: SoftSaaSTokens.secondaryText(brightness),
                  ),
                ],
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: widget.prefixIcon != null ? 8 : 10,
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      enabled: widget.enabled,
                      onChanged: _handleTextChanged,
                      onSubmitted: widget.onSubmitted,
                      onTap: () => _controller.selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: _controller.text.length,
                      ),
                      style: TextStyle(
                        fontSize: _fontSize(),
                        color: SoftSaaSTokens.primaryText(brightness),
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: widget.placeholder,
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
                _ChevronButton(
                  open: _menuOpen,
                  enabled: widget.enabled && widget.options.isNotEmpty,
                  brightness: brightness,
                  onTap: _toggleMenu,
                ),
              ],
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            widget.errorText!,
            style: SoftSaaSTypography.bodySmallSecondary(
              brightness,
            ).copyWith(color: SoftSaaSTokens.errorColor(brightness)),
          ),
        ],
      ],
    );
  }
}

/// Compact, non-splashy chevron button sized to match the field.
/// Fixes the oversized-splash problem seen when using [PopupMenuButton]
/// as a suffix icon.
class _ChevronButton extends StatelessWidget {
  const _ChevronButton({
    required this.open,
    required this.enabled,
    required this.brightness,
    required this.onTap,
  });

  final bool open;
  final bool enabled;
  final Brightness brightness;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = enabled
        ? SoftSaaSTokens.tertiaryText(brightness)
        : SoftSaaSTokens.tertiaryText(brightness).withValues(alpha: 0.5);
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (event) {
          if (!enabled) return;
          if (event.kind == PointerDeviceKind.mouse) {
            // Avoid stealing focus from the text field.
            onTap();
          }
        },
        onPointerUp: (event) {
          if (!enabled) return;
          if (event.kind != PointerDeviceKind.mouse) {
            onTap();
          }
        },
        child: SizedBox(
          width: 28,
          height: double.infinity,
          child: Center(
            child: AnimatedRotation(
              duration: SoftSaaSTokens.transitionDuration,
              turns: open ? 0.5 : 0,
              child: Icon(LucideIcons.chevron_down, size: 16, color: color),
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionsMenu extends StatelessWidget {
  const _OptionsMenu({
    required this.options,
    required this.currentValue,
    required this.query,
    required this.highlightedIndex,
    required this.scrollController,
    required this.size,
    required this.maxHeight,
    required this.onSelected,
  });

  final List<SelectOption> options;
  final String currentValue;
  final String query;
  final int? highlightedIndex;
  final ScrollController scrollController;
  final SoftSaaSComboInputSize size;
  final double maxHeight;
  final ValueChanged<SelectOption> onSelected;

  double get _fontSize => size == SoftSaaSComboInputSize.large ? 15 : 13;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: SoftSaaSTokens.primaryBackground(brightness),
        border: Border.all(color: SoftSaaSTokens.primaryBorder(brightness)),
        borderRadius: BorderRadius.circular(7),
        boxShadow: brightness == Brightness.light
            ? const [
                BoxShadow(
                  color: Color(0x14000000),
                  offset: Offset(0, 8),
                  blurRadius: 18,
                  spreadRadius: -6,
                ),
              ]
            : const [
                BoxShadow(
                  color: Color(0x52000000),
                  offset: Offset(0, 10),
                  blurRadius: 22,
                  spreadRadius: -8,
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: ListView.builder(
          controller: scrollController,
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: options.length,
          itemBuilder: (_, index) {
            final option = options[index];
            final isSelected =
                option.value == currentValue || option.label == currentValue;
            return _OptionTile(
              option: option,
              isSelected: isSelected,
              isHighlighted: index == highlightedIndex,
              query: query,
              fontSize: _fontSize,
              onTap: option.disabled ? null : () => onSelected(option),
            );
          },
        ),
      ),
    );
  }
}

class _OptionTile extends StatefulWidget {
  const _OptionTile({
    required this.option,
    required this.isSelected,
    required this.isHighlighted,
    required this.query,
    required this.fontSize,
    required this.onTap,
  });

  final SelectOption option;
  final bool isSelected;
  final bool isHighlighted;
  final String query;
  final double fontSize;
  final VoidCallback? onTap;

  @override
  State<_OptionTile> createState() => _OptionTileState();
}

class _OptionTileState extends State<_OptionTile> {
  bool _isHovered = false;

  List<TextSpan> _buildLabelSpans(String label, TextStyle base) {
    final q = widget.query.toLowerCase();
    if (q.isEmpty) return [TextSpan(text: label, style: base)];
    final idx = label.toLowerCase().indexOf(q);
    if (idx < 0) return [TextSpan(text: label, style: base)];
    return [
      if (idx > 0) TextSpan(text: label.substring(0, idx), style: base),
      TextSpan(
        text: label.substring(idx, idx + q.length),
        style: base.copyWith(fontWeight: FontWeight.bold),
      ),
      if (idx + q.length < label.length)
        TextSpan(text: label.substring(idx + q.length), style: base),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;

    final baseStyle = TextStyle(
      fontSize: widget.fontSize,
      color: widget.isSelected
          ? SoftSaaSTokens.primaryColor(brightness)
          : (widget.option.disabled
                ? (isLight ? SoftSaaSTokens.gray400 : SoftSaaSTokens.gray600)
                : SoftSaaSTokens.primaryText(brightness)),
      height: 1.0,
    ).merge(widget.option.labelStyle);

    final showBackground = widget.isHighlighted || _isHovered;

    return MouseRegion(
      cursor: widget.onTap == null
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      onEnter: widget.option.disabled
          ? null
          : (_) => setState(() => _isHovered = true),
      onExit: widget.option.disabled
          ? null
          : (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Container(
          color: showBackground
              ? SoftSaaSTokens.secondaryBackground(brightness)
              : Colors.transparent,
          padding: const EdgeInsets.fromLTRB(12, 7, 10, 7),
          child: Row(
            children: [
              if (widget.option.leading != null) ...[
                widget.option.leading!,
                const SizedBox(width: 8),
              ],
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: _buildLabelSpans(widget.option.label, baseStyle),
                  ),
                ),
              ),
              if (widget.isSelected) ...[
                const SizedBox(width: 8),
                Icon(
                  LucideIcons.check,
                  size: 14,
                  color: SoftSaaSTokens.primaryColor(brightness),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
