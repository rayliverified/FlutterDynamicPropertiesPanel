import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../design_tokens.dart';
import 'select.dart';

/// Soft SaaS field-style dropdown that supports selecting multiple options.
///
/// This mirrors [SoftSaaSDropdown] trigger styling and overlay behavior while
/// allowing users to toggle many options before dismissing the menu.
class SoftSaaSDropdownMultiselect extends StatefulWidget {
  const SoftSaaSDropdownMultiselect({
    super.key,
    required this.options,
    required this.values,
    this.onChanged,
    this.placeholder = 'Select options',
    this.emptyStateLabel = 'No options available',
    this.size = SoftSaaSSelectSize.medium,
    this.fontSize,
    this.textStyle,
    this.dropUp = false,
    this.error,
    this.enabled = true,
    this.preventEmptySelection = false,
    this.maxMenuHeight = 240,
  }) : _style = _SoftSaaSMultiselectStyle.defaultStyle;

  const SoftSaaSDropdownMultiselect.text({
    super.key,
    required this.options,
    required this.values,
    this.onChanged,
    this.placeholder = 'Select options',
    this.emptyStateLabel = 'No options available',
    this.size = SoftSaaSSelectSize.medium,
    this.fontSize,
    this.textStyle,
    this.dropUp = false,
    this.error,
    this.enabled = true,
    this.preventEmptySelection = false,
    this.maxMenuHeight = 240,
  }) : _style = _SoftSaaSMultiselectStyle.text;

  const SoftSaaSDropdownMultiselect.primary({
    super.key,
    required this.options,
    required this.values,
    this.onChanged,
    this.placeholder = 'Select options',
    this.emptyStateLabel = 'No options available',
    this.size = SoftSaaSSelectSize.medium,
    this.fontSize,
    this.textStyle,
    this.dropUp = false,
    this.error,
    this.enabled = true,
    this.preventEmptySelection = false,
    this.maxMenuHeight = 240,
  }) : _style = _SoftSaaSMultiselectStyle.primary;

  const SoftSaaSDropdownMultiselect.elevated({
    super.key,
    required this.options,
    required this.values,
    this.onChanged,
    this.placeholder = 'Select options',
    this.emptyStateLabel = 'No options available',
    this.size = SoftSaaSSelectSize.medium,
    this.fontSize,
    this.textStyle,
    this.dropUp = false,
    this.error,
    this.enabled = true,
    this.preventEmptySelection = false,
    this.maxMenuHeight = 240,
  }) : _style = _SoftSaaSMultiselectStyle.elevated;

  final List<SelectOption> options;
  final Set<String> values;
  final ValueChanged<Set<String>>? onChanged;
  final String placeholder;
  final String emptyStateLabel;
  final SoftSaaSSelectSize size;
  final double? fontSize;
  final TextStyle? textStyle;
  final bool dropUp;
  final String? error;
  final bool enabled;
  final bool preventEmptySelection;
  final double maxMenuHeight;
  final _SoftSaaSMultiselectStyle _style;

  @override
  State<SoftSaaSDropdownMultiselect> createState() =>
      _SoftSaaSDropdownMultiselectState();
}

enum _SoftSaaSMultiselectStyle { defaultStyle, text, primary, elevated }

class _SoftSaaSDropdownMultiselectState
    extends State<SoftSaaSDropdownMultiselect> {
  bool _isOpen = false;
  bool _isFocused = false;
  Set<String> _localValues = <String>{};
  final LayerLink _layerLink = LayerLink();
  final FocusNode _triggerFocusNode = FocusNode(
    debugLabel: 'SoftSaaSDropdownMultiselectTrigger',
  );
  final FocusScopeNode _menuFocusScopeNode = FocusScopeNode(
    debugLabel: 'SoftSaaSDropdownMultiselectMenu',
  );
  List<FocusNode> _optionFocusNodes = <FocusNode>[];
  List<GlobalKey> _optionKeys = <GlobalKey>[];
  int? _focusedOptionIndex;
  int? _hoveredOptionIndex;
  int? _activeOptionIndex;
  int? _touchPointerId;
  OverlayEntry? _overlayEntry;
  LocalHistoryEntry? _localHistoryEntry;
  bool _isClosingFromHistory = false;

  @override
  void initState() {
    super.initState();
    _syncValuesFromWidget();
    _syncOptionInteractionNodes();
  }

  @override
  void didUpdateWidget(covariant SoftSaaSDropdownMultiselect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.options.length != widget.options.length ||
        oldWidget.options != widget.options) {
      _syncOptionInteractionNodes();
    }
    if (!_setEquals(oldWidget.values, widget.values)) {
      _syncValuesFromWidget();
      _refreshOverlayAfterFrame();
    }
  }

  @override
  void dispose() {
    _removeLocalHistoryEntry();
    _removeOverlay();
    for (final focusNode in _optionFocusNodes) {
      focusNode.dispose();
    }
    _triggerFocusNode.dispose();
    _menuFocusScopeNode.dispose();
    super.dispose();
  }

  void _syncValuesFromWidget() {
    _localValues = Set<String>.from(widget.values);
  }

  void _syncOptionInteractionNodes() {
    for (final focusNode in _optionFocusNodes) {
      focusNode.dispose();
    }
    _optionFocusNodes = List<FocusNode>.generate(
      widget.options.length,
      (index) =>
          FocusNode(debugLabel: 'SoftSaaSDropdownMultiselectOption($index)'),
    );
    _optionKeys = List<GlobalKey>.generate(
      widget.options.length,
      (index) =>
          GlobalKey(debugLabel: 'SoftSaaSDropdownMultiselectOptionKey($index)'),
    );
  }

  void _toggleDropdown() {
    if (!widget.enabled) return;

    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    if (_isOpen) return;

    _setStateAndRefreshOverlay(() {
      _isOpen = true;
      _isFocused = true;
    });

    _registerLocalHistoryEntry();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_isOpen) return;
      _focusInitialMenuItem();
      _setStateAndRefreshOverlay(() {
        _focusedOptionIndex = _initialFocusedOptionIndex;
        _activeOptionIndex = _initialFocusedOptionIndex;
      });
    });
  }

  void _closeDropdown() {
    if (!_isOpen) {
      _removeOverlay();
      _removeLocalHistoryEntry();
      return;
    }

    _triggerFocusNode.unfocus();
    _menuFocusScopeNode.unfocus();

    _setStateAndRefreshOverlay(() {
      _isOpen = false;
      _isFocused = false;
      _focusedOptionIndex = null;
      _hoveredOptionIndex = null;
      _activeOptionIndex = null;
    });

    _removeOverlay();
    _removeLocalHistoryEntry();
  }

  void _setStateAndRefreshOverlay(VoidCallback update) {
    if (!mounted) return;
    setState(update);
    _refreshOverlayAfterFrame();
  }

  void _refreshOverlayAfterFrame() {
    if (!mounted || _overlayEntry == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_isOpen) return;
      _overlayEntry?.markNeedsBuild();
    });
  }

  bool _isTouchLikePointer(PointerEvent event) {
    return event.kind == PointerDeviceKind.touch ||
        event.kind == PointerDeviceKind.stylus ||
        event.kind == PointerDeviceKind.invertedStylus;
  }

  int? _optionIndexAtGlobalPosition(Offset globalPosition) {
    for (var index = 0; index < _optionKeys.length; index++) {
      final context = _optionKeys[index].currentContext;
      if (context == null) continue;
      final renderObject = context.findRenderObject();
      if (renderObject is! RenderBox || !renderObject.hasSize) continue;
      final topLeft = renderObject.localToGlobal(Offset.zero);
      final rect = topLeft & renderObject.size;
      if (rect.contains(globalPosition)) return index;
    }
    return null;
  }

  void _activateOptionFromTouchIndex(int index) {
    if (index < 0 || index >= widget.options.length) return;
    final option = widget.options[index];
    if (option.disabled) return;

    final focusNode = _optionFocusNodes[index];
    _setStateAndRefreshOverlay(() {
      _hoveredOptionIndex = null;
      _activeOptionIndex = index;
    });
    focusNode.requestFocus();
  }

  void _handleTouchTracking(PointerEvent event) {
    final index = _optionIndexAtGlobalPosition(event.position);
    if (index != null) _activateOptionFromTouchIndex(index);
  }

  void _toggleOption(String value) {
    final next = Set<String>.from(_localValues);

    if (next.contains(value)) {
      if (widget.preventEmptySelection && next.length == 1) return;
      next.remove(value);
    } else {
      next.add(value);
    }

    _setStateAndRefreshOverlay(() {
      _localValues = next;
    });

    widget.onChanged?.call(Set<String>.unmodifiable(next));
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _registerLocalHistoryEntry() {
    if (_localHistoryEntry != null) return;

    final route = ModalRoute.of(context);
    if (route == null) return;

    _localHistoryEntry = LocalHistoryEntry(
      onRemove: () {
        _localHistoryEntry = null;
        if (_isClosingFromHistory) {
          _isClosingFromHistory = false;
          return;
        }
        if (_isOpen) _closeDropdown();
      },
    );
    route.addLocalHistoryEntry(_localHistoryEntry!);
  }

  void _removeLocalHistoryEntry() {
    if (_localHistoryEntry == null) return;

    _isClosingFromHistory = true;
    _localHistoryEntry!.remove();
    _localHistoryEntry = null;
  }

  void _focusInitialMenuItem() {
    final targetIndex = _initialFocusedOptionIndex;
    if (targetIndex != null && targetIndex < _optionFocusNodes.length) {
      _optionFocusNodes[targetIndex].requestFocus();
      return;
    }
    _menuFocusScopeNode.requestFocus();
  }

  int? get _initialFocusedOptionIndex {
    final selectedIndex = widget.options.indexWhere(
      (option) => !option.disabled && _localValues.contains(option.value),
    );
    if (selectedIndex != -1) return selectedIndex;

    final firstEnabledIndex = widget.options.indexWhere(
      (option) => !option.disabled,
    );
    return firstEnabledIndex == -1 ? null : firstEnabledIndex;
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final bottomPadding = mediaQuery.padding.bottom;

    final maxDropdownHeight = widget.maxMenuHeight;
    const borderAndShadowBuffer = 20.0;
    final estimatedHeight = _estimateDropdownHeight();
    final dropdownHeight =
        (estimatedHeight < maxDropdownHeight
            ? estimatedHeight
            : maxDropdownHeight) +
        borderAndShadowBuffer;

    const gap = 8.0;
    final spaceAbove = position.dy - gap;
    final spaceBelow =
        screenHeight - (position.dy + size.height) - bottomPadding - gap;

    final hasSpaceAbove = spaceAbove >= dropdownHeight;
    final hasSpaceBelow = spaceBelow >= dropdownHeight;

    final bool shouldOpenUp;
    if (hasSpaceAbove && hasSpaceBelow) {
      shouldOpenUp = widget.dropUp;
    } else if (hasSpaceAbove && !hasSpaceBelow) {
      shouldOpenUp = true;
    } else if (!hasSpaceAbove && hasSpaceBelow) {
      shouldOpenUp = false;
    } else {
      shouldOpenUp = spaceAbove > spaceBelow;
    }

    final dropOffset = shouldOpenUp
        ? Offset(0, -(dropdownHeight + gap))
        : Offset(0, size.height + gap);

    return OverlayEntry(
      builder: (context) => Actions(
        actions: <Type, Action<Intent>>{
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (intent) {
              _closeDropdown();
              return null;
            },
          ),
        },
        child: Shortcuts(
          shortcuts: const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
            SingleActivator(LogicalKeyboardKey.arrowDown): NextFocusIntent(),
            SingleActivator(LogicalKeyboardKey.arrowUp): PreviousFocusIntent(),
            SingleActivator(LogicalKeyboardKey.tab): NextFocusIntent(),
            SingleActivator(LogicalKeyboardKey.tab, shift: true):
                PreviousFocusIntent(),
          },
          child: FocusTraversalGroup(
            policy: WidgetOrderTraversalPolicy(),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _closeDropdown,
              child: Stack(
                children: [
                  Positioned(
                    width: size.width,
                    child: CompositedTransformFollower(
                      link: _layerLink,
                      showWhenUnlinked: false,
                      offset: dropOffset,
                      child: Material(
                        color: Colors.transparent,
                        child: FocusScope(
                          node: _menuFocusScopeNode,
                          autofocus: true,
                          child: _buildDropdownMenu(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownMenu() {
    final brightness = Theme.of(context).brightness;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        if (!_isTouchLikePointer(event)) return;
        _touchPointerId = event.pointer;
        _handleTouchTracking(event);
      },
      onPointerMove: (event) {
        if (!_isTouchLikePointer(event) || _touchPointerId != event.pointer) {
          return;
        }
        _handleTouchTracking(event);
      },
      onPointerUp: (event) {
        if (_touchPointerId == event.pointer) {
          _touchPointerId = null;
        }
      },
      onPointerCancel: (event) {
        if (_touchPointerId == event.pointer) {
          _touchPointerId = null;
        }
      },
      child: Container(
        constraints: BoxConstraints(maxHeight: widget.maxMenuHeight),
        decoration: BoxDecoration(
          color: SoftSaaSTokens.primaryBackground(brightness),
          border: Border.all(color: SoftSaaSTokens.primaryBorder(brightness)),
          borderRadius: BorderRadius.circular(7),
          boxShadow: _getDropdownShadow(brightness),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: widget.options.isEmpty
              ? _buildEmptyState(brightness)
              : ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: List<Widget>.generate(widget.options.length, (
                    index,
                  ) {
                    final option = widget.options[index];
                    final isSelected = _localValues.contains(option.value);
                    return _buildOption(brightness, option, isSelected, index);
                  }),
                ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(Brightness brightness) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        widget.emptyStateLabel,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: _getFontSize(),
          color: SoftSaaSTokens.tertiaryText(brightness),
          height: 1.0,
        ),
      ),
    );
  }

  Widget _buildOption(
    Brightness brightness,
    SelectOption option,
    bool isSelected,
    int index,
  ) {
    final isLight = brightness == Brightness.light;

    final selectedHighlight = SoftSaaSTokens.primaryColor(
      brightness,
    ).withValues(alpha: isLight ? 0.14 : 0.22);
    final interactionHighlight = isLight
        ? const Color(0xFFF3F4F6)
        : const Color(0x1AFFFFFF);
    final focusNode = _optionFocusNodes[index];
    final isActive = _activeOptionIndex == index;

    return Material(
      color: isSelected
          ? selectedHighlight
          : (isActive ? interactionHighlight : Colors.transparent),
      child: KeyedSubtree(
        key: _optionKeys[index],
        child: MouseRegion(
          onEnter: option.disabled
              ? null
              : (_) {
                  _setStateAndRefreshOverlay(() {
                    _hoveredOptionIndex = index;
                    _activeOptionIndex = index;
                  });
                  focusNode.requestFocus();
                },
          onExit: option.disabled
              ? null
              : (_) {
                  if (_hoveredOptionIndex == index) {
                    _setStateAndRefreshOverlay(() {
                      _hoveredOptionIndex = null;
                      if (_activeOptionIndex == index &&
                          _focusedOptionIndex != index) {
                        _activeOptionIndex = null;
                      }
                    });
                  }
                },
          child: Focus(
            focusNode: focusNode,
            onFocusChange: (hasFocus) {
              if (hasFocus) {
                _setStateAndRefreshOverlay(() {
                  _focusedOptionIndex = index;
                  _activeOptionIndex = index;
                });
              } else if (_focusedOptionIndex == index) {
                _setStateAndRefreshOverlay(() {
                  _focusedOptionIndex = null;
                  if (_hoveredOptionIndex == index) {
                    _activeOptionIndex = index;
                  } else if (_activeOptionIndex == index) {
                    _activeOptionIndex = null;
                  }
                });
              }
            },
            onKeyEvent: (node, event) {
              if (event is! KeyDownEvent || option.disabled) {
                return KeyEventResult.ignored;
              }
              if (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.space) {
                _toggleOption(option.value);
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: InkWell(
              canRequestFocus: false,
              onTap: option.disabled ? null : () => _toggleOption(option.value),
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              highlightColor: isSelected
                  ? Colors.transparent
                  : interactionHighlight,
              splashColor: Colors.transparent,
              child: Padding(
                padding: _getOptionPadding(hasLeading: option.leading != null),
                child: Row(
                  children: [
                    _SelectionBox(
                      selected: isSelected,
                      disabled: option.disabled,
                      brightness: brightness,
                    ),
                    const SizedBox(width: 8),
                    if (option.leading != null) ...[
                      option.leading!,
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        option.label,
                        style: TextStyle(
                          fontSize: _getFontSize(),
                          color: option.disabled
                              ? (isLight
                                    ? SoftSaaSTokens.gray400
                                    : SoftSaaSTokens.gray600)
                              : SoftSaaSTokens.primaryText(brightness),
                          height: 1.0,
                        ).merge(option.labelStyle),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    final isText = widget._style == _SoftSaaSMultiselectStyle.text;
    final isPrimary = widget._style == _SoftSaaSMultiselectStyle.primary;
    final isElevated = widget._style == _SoftSaaSMultiselectStyle.elevated;

    final label = _selectedSummaryLabel();
    final hasSelection = _localValues.isNotEmpty;

    final defaultTextColor = isPrimary
        ? Colors.white
        : hasSelection
        ? SoftSaaSTokens.primaryText(brightness)
        : (brightness == Brightness.light
              ? SoftSaaSTokens.gray500
              : SoftSaaSTokens.gray400);

    final baseStyle = TextStyle(
      fontSize: _getFontSize(),
      color: defaultTextColor,
      fontWeight: (isPrimary || isElevated)
          ? SoftSaaSTokens.fontWeightMedium
          : SoftSaaSTokens.fontWeightNormal,
      height: 1.0,
    );

    final textStyle = widget.textStyle ?? baseStyle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CompositedTransformTarget(
          link: _layerLink,
          child: FocusableActionDetector(
            enabled: widget.enabled,
            focusNode: _triggerFocusNode,
            shortcuts: const <ShortcutActivator, Intent>{
              SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
              SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
              SingleActivator(LogicalKeyboardKey.arrowDown): ActivateIntent(),
              SingleActivator(LogicalKeyboardKey.arrowUp): ActivateIntent(),
            },
            actions: <Type, Action<Intent>>{
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (intent) {
                  _toggleDropdown();
                  return null;
                },
              ),
            },
            onShowFocusHighlight: (isFocused) {
              if (_isFocused == isFocused) return;
              setState(() {
                _isFocused = isFocused || _isOpen;
              });
            },
            child: Semantics(
              button: true,
              enabled: widget.enabled,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggleDropdown,
                child: isText
                    ? _buildTextOnlyTrigger(brightness, textStyle, label)
                    : _buildFieldTrigger(
                        brightness,
                        textStyle,
                        label,
                        primary: isPrimary,
                        elevated: isElevated,
                      ),
              ),
            ),
          ),
        ),
        if (widget.error != null && widget.size != SoftSaaSSelectSize.small)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              widget.error!,
              style: TextStyle(
                fontSize: 12,
                color: SoftSaaSTokens.errorColor(brightness),
                height: 1.0,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  Widget _buildFieldTrigger(
    Brightness brightness,
    TextStyle textStyle,
    String label, {
    required bool primary,
    required bool elevated,
  }) {
    final showBlueOutline = _isOpen || _isFocused;
    final borderColor = widget.error != null
        ? SoftSaaSTokens.errorColor(brightness)
        : showBlueOutline
        ? SoftSaaSTokens.primaryColor(brightness).withValues(alpha: 0.45)
        : SoftSaaSTokens.primaryBorder(brightness);
    final backgroundColor = primary
        ? SoftSaaSTokens.primaryColor(brightness)
        : SoftSaaSTokens.primaryBackground(brightness);
    final chevronColor = primary
        ? Colors.white.withValues(alpha: 0.92)
        : SoftSaaSTokens.tertiaryText(brightness);

    return Container(
      height: _getHeight(),
      padding: _getTriggerPadding(),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(7),
        boxShadow: (primary || elevated)
            ? _getElevatedTriggerShadow(brightness, primary: primary)
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: textStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          AnimatedRotation(
            duration: SoftSaaSTokens.transitionDuration,
            turns: _isOpen ? 0.5 : 0,
            child: Icon(
              LucideIcons.chevron_down,
              size: 16,
              color: chevronColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextOnlyTrigger(
    Brightness brightness,
    TextStyle textStyle,
    String label,
  ) {
    final textColor = widget.enabled
        ? textStyle.color
        : (brightness == Brightness.light
              ? SoftSaaSTokens.gray400
              : SoftSaaSTokens.gray600);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            label,
            style: textStyle.copyWith(color: textColor),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 6),
        AnimatedRotation(
          duration: SoftSaaSTokens.transitionDuration,
          turns: _isOpen ? 0.5 : 0,
          child: Icon(LucideIcons.chevron_down, size: 14, color: textColor),
        ),
      ],
    );
  }

  String _selectedSummaryLabel() {
    if (_localValues.isEmpty) return widget.placeholder;

    final selected = widget.options
        .where((option) => _localValues.contains(option.value))
        .toList();

    if (selected.isEmpty) return '${_localValues.length} selected';
    if (selected.length <= 2) {
      return selected.map((option) => option.label).join(', ');
    }
    return '${selected.length} selected';
  }

  bool _setEquals(Set<String> a, Set<String> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (final value in a) {
      if (!b.contains(value)) return false;
    }
    return true;
  }

  double _getHeight() {
    switch (widget.size) {
      case SoftSaaSSelectSize.small:
        return 32.0;
      case SoftSaaSSelectSize.medium:
        return 36.0;
      case SoftSaaSSelectSize.large:
        return 44.0;
    }
  }

  EdgeInsets _getTriggerPadding() {
    switch (widget.size) {
      case SoftSaaSSelectSize.small:
        return const EdgeInsets.fromLTRB(10, 4, 8, 4);
      case SoftSaaSSelectSize.medium:
        return const EdgeInsets.fromLTRB(12, 6, 10, 6);
      case SoftSaaSSelectSize.large:
        return const EdgeInsets.fromLTRB(14, 8, 12, 8);
    }
  }

  EdgeInsets _getOptionPadding({bool hasLeading = false}) {
    final leftReduction = hasLeading ? 4.0 : 0.0;
    switch (widget.size) {
      case SoftSaaSSelectSize.small:
        return EdgeInsets.fromLTRB(10 - leftReduction, 5, 8, 5);
      case SoftSaaSSelectSize.medium:
        return EdgeInsets.fromLTRB(12 - leftReduction, 7, 10, 7);
      case SoftSaaSSelectSize.large:
        return EdgeInsets.fromLTRB(12 - leftReduction, 8, 10, 8);
    }
  }

  double _getFontSize() {
    if (widget.fontSize != null) return widget.fontSize!;

    switch (widget.size) {
      case SoftSaaSSelectSize.small:
      case SoftSaaSSelectSize.medium:
        return 13.0;
      case SoftSaaSSelectSize.large:
        return 15.0;
    }
  }

  double _estimateDropdownHeight() {
    if (widget.options.isEmpty) return 56;

    final optionHeight =
        (_getFontSize() * 1.4) + (_getOptionPadding().vertical);
    final estimated = optionHeight * widget.options.length;
    return estimated.clamp(0, widget.maxMenuHeight).toDouble();
  }

  List<BoxShadow> _getElevatedTriggerShadow(
    Brightness brightness, {
    required bool primary,
  }) {
    if (primary) {
      return brightness == Brightness.light
          ? [
              BoxShadow(
                color: SoftSaaSTokens.primaryColor(
                  brightness,
                ).withValues(alpha: 0.22),
                offset: const Offset(0, 4),
                blurRadius: 10,
                spreadRadius: -4,
              ),
              ..._getDefaultShadow(brightness),
            ]
          : [
              BoxShadow(
                color: SoftSaaSTokens.primaryColor(
                  brightness,
                ).withValues(alpha: 0.28),
                offset: const Offset(0, 6),
                blurRadius: 14,
                spreadRadius: -6,
              ),
              ..._getDefaultShadow(brightness),
            ];
    }

    return _getDefaultShadow(brightness);
  }

  List<BoxShadow> _getDefaultShadow(Brightness brightness) {
    return brightness == Brightness.light
        ? [
            const BoxShadow(
              color: Color(0x0F000000),
              offset: Offset(0, 2),
              blurRadius: 4,
              spreadRadius: -1,
            ),
            const BoxShadow(
              color: Color(0x0A000000),
              offset: Offset(0, 1),
              blurRadius: 2,
              spreadRadius: -1,
            ),
            const BoxShadow(
              color: Color(0x0AFFFFFF),
              offset: Offset(0, 1),
              blurRadius: 2,
            ),
            const BoxShadow(
              color: Color(0x03000000),
              offset: Offset(0, -1),
              blurRadius: 2,
            ),
          ]
        : [
            const BoxShadow(
              color: Color(0x33000000),
              offset: Offset(0, 2),
              blurRadius: 4,
              spreadRadius: -1,
            ),
            const BoxShadow(
              color: Color(0x26000000),
              offset: Offset(0, 1),
              blurRadius: 2,
              spreadRadius: -1,
            ),
            const BoxShadow(
              color: Color(0x05FFFFFF),
              offset: Offset(0, 1),
              blurRadius: 2,
            ),
            const BoxShadow(
              color: Color(0x1A000000),
              offset: Offset(0, -1),
              blurRadius: 2,
            ),
          ];
  }

  List<BoxShadow> _getDropdownShadow(Brightness brightness) {
    return brightness == Brightness.light
        ? [
            const BoxShadow(
              color: Color(0x14000000),
              offset: Offset(0, 8),
              blurRadius: 18,
              spreadRadius: -6,
            ),
          ]
        : [
            const BoxShadow(
              color: Color(0x52000000),
              offset: Offset(0, 10),
              blurRadius: 22,
              spreadRadius: -8,
            ),
          ];
  }
}

class _SelectionBox extends StatelessWidget {
  const _SelectionBox({
    required this.selected,
    required this.disabled,
    required this.brightness,
  });

  final bool selected;
  final bool disabled;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final borderColor = disabled
        ? SoftSaaSTokens.secondaryBorder(brightness)
        : SoftSaaSTokens.primaryBorder(brightness);

    final fillColor = selected
        ? SoftSaaSTokens.primaryColor(brightness)
        : Colors.transparent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: selected
              ? SoftSaaSTokens.primaryColor(brightness)
              : borderColor,
          width: 1.2,
        ),
      ),
      child: selected
          ? Icon(
              LucideIcons.check,
              size: 12,
              color: brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white,
            )
          : const SizedBox.shrink(),
    );
  }
}
