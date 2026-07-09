// Soft SaaS UI Select/Dropdown Component
//
// Dropdown selection with neumorphic styling

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../design_tokens.dart';

// ══════════════════════════════════════════════════════════════════════
// SELECT/DROPDOWN
// ══════════════════════════════════════════════════════════════════════

/// Select option
class SelectOption {
  const SelectOption({
    required this.value,
    required this.label,
    this.disabled = false,
    this.leading,
    this.labelStyle,
  });

  final String value;
  final String label;
  final bool disabled;
  final Widget? leading;

  /// Optional style override for this option's label text.
  ///
  /// Applied via [TextStyle.merge] over the default style, so only the fields
  /// you specify (e.g. [TextStyle.fontWeight]) are overridden.
  final TextStyle? labelStyle;
}

/// Select size
enum SoftSaaSSelectSize {
  small, // 32px
  medium, // 36px
  large, // 44px
}

/// Soft SaaS UI Dropdown Component
class SoftSaaSDropdown extends StatefulWidget {
  const SoftSaaSDropdown({
    super.key,
    required this.options,
    this.value,
    this.onChanged,
    this.placeholder = 'Select an option',
    this.emptyStateLabel = 'No options available',
    this.size = SoftSaaSSelectSize.medium,
    this.fontSize,
    this.textStyle,
    this.dropUp = false,
    this.error,
    this.enabled = true,
    this.selectedLeading,
  }) : _style = _SoftSaaSSelectStyle.defaultStyle;

  const SoftSaaSDropdown.text({
    super.key,
    required this.options,
    this.value,
    this.onChanged,
    this.placeholder = 'Select an option',
    this.emptyStateLabel = 'No options available',
    this.size = SoftSaaSSelectSize.medium,
    this.fontSize,
    this.textStyle,
    this.dropUp = false,
    this.error,
    this.enabled = true,
    this.selectedLeading,
  }) : _style = _SoftSaaSSelectStyle.text;

  const SoftSaaSDropdown.primary({
    super.key,
    required this.options,
    this.value,
    this.onChanged,
    this.placeholder = 'Select an option',
    this.emptyStateLabel = 'No options available',
    this.size = SoftSaaSSelectSize.medium,
    this.fontSize,
    this.textStyle,
    this.dropUp = false,
    this.error,
    this.enabled = true,
    this.selectedLeading,
  }) : _style = _SoftSaaSSelectStyle.primary;

  const SoftSaaSDropdown.elevated({
    super.key,
    required this.options,
    this.value,
    this.onChanged,
    this.placeholder = 'Select an option',
    this.emptyStateLabel = 'No options available',
    this.size = SoftSaaSSelectSize.medium,
    this.fontSize,
    this.textStyle,
    this.dropUp = false,
    this.error,
    this.enabled = true,
    this.selectedLeading,
  }) : _style = _SoftSaaSSelectStyle.elevated;

  final List<SelectOption> options;
  final String? value;
  final ValueChanged<String>? onChanged;
  final String placeholder;
  final String emptyStateLabel;
  final SoftSaaSSelectSize size;
  final double? fontSize;
  final TextStyle? textStyle;

  /// Preferred direction for opening the dropdown (true = upward, false = downward).
  ///
  /// This is a *preference* rather than a strict rule. The dropdown will
  /// automatically override this setting if:
  /// - There's insufficient space in the preferred direction
  /// - There's sufficient space in the opposite direction
  /// - Opening in the opposite direction prevents clipping
  ///
  /// See [_createOverlayEntry] for the full positioning algorithm.
  final bool dropUp;
  final String? error;
  final bool enabled;

  /// Optional leading widget rendered only in the trigger/selector.
  ///
  /// Unlike [SelectOption.leading], this does not appear in menu options.
  final Widget? selectedLeading;
  final _SoftSaaSSelectStyle _style;

  @override
  State<SoftSaaSDropdown> createState() => _SoftSaaSDropdownState();
}

enum _SoftSaaSSelectStyle { defaultStyle, text, primary, elevated }

class _SoftSaaSDropdownState extends State<SoftSaaSDropdown> {
  bool _isOpen = false;
  bool _isFocused = false;
  final LayerLink _layerLink = LayerLink();
  final FocusNode _triggerFocusNode = FocusNode(
    debugLabel: 'SoftSaaSDropdownTrigger',
  );
  final FocusScopeNode _menuFocusScopeNode = FocusScopeNode(
    debugLabel: 'SoftSaaSDropdownMenu',
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
    _syncOptionFocusNodes();
  }

  @override
  void didUpdateWidget(covariant SoftSaaSDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.options.length != widget.options.length ||
        oldWidget.options != widget.options) {
      _syncOptionFocusNodes();
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

  void _syncOptionFocusNodes() {
    for (final focusNode in _optionFocusNodes) {
      focusNode.dispose();
    }
    _optionFocusNodes = List<FocusNode>.generate(
      widget.options.length,
      (index) => FocusNode(debugLabel: 'SoftSaaSDropdownOption($index)'),
    );
    _optionKeys = List<GlobalKey>.generate(
      widget.options.length,
      (index) => GlobalKey(debugLabel: 'SoftSaaSDropdownOptionKey($index)'),
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
    if (_isOpen) {
      return;
    }

    _setStateAndRefreshOverlay(() {
      _isOpen = true;
      _isFocused = true;
    });

    _registerLocalHistoryEntry();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_isOpen) {
        return;
      }
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
    if (!mounted) {
      return;
    }

    setState(update);
    _overlayEntry?.markNeedsBuild();
  }

  bool _isTouchLikePointer(PointerEvent event) {
    return event.kind == PointerDeviceKind.touch ||
        event.kind == PointerDeviceKind.stylus ||
        event.kind == PointerDeviceKind.invertedStylus;
  }

  int? _optionIndexAtGlobalPosition(Offset globalPosition) {
    for (var index = 0; index < _optionKeys.length; index++) {
      final context = _optionKeys[index].currentContext;
      if (context == null) {
        continue;
      }
      final renderObject = context.findRenderObject();
      if (renderObject is! RenderBox || !renderObject.hasSize) {
        continue;
      }
      final topLeft = renderObject.localToGlobal(Offset.zero);
      final rect = topLeft & renderObject.size;
      if (rect.contains(globalPosition)) {
        return index;
      }
    }
    return null;
  }

  void _activateOptionFromTouchIndex(int index) {
    if (index < 0 || index >= widget.options.length) {
      return;
    }
    final option = widget.options[index];
    if (option.disabled) {
      return;
    }
    final focusNode = _optionFocusNodes[index];
    _setStateAndRefreshOverlay(() {
      _hoveredOptionIndex = null;
      _activeOptionIndex = index;
    });
    focusNode.requestFocus();
  }

  void _handleTouchTracking(PointerEvent event) {
    final index = _optionIndexAtGlobalPosition(event.position);
    if (index != null) {
      _activateOptionFromTouchIndex(index);
    }
  }

  void _handleTouchSelection(PointerEvent event) {
    final index =
        _optionIndexAtGlobalPosition(event.position) ?? _activeOptionIndex;
    if (index == null || index < 0 || index >= widget.options.length) {
      return;
    }
    final option = widget.options[index];
    if (option.disabled) {
      return;
    }
    widget.onChanged?.call(option.value);
    _closeDropdown();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _registerLocalHistoryEntry() {
    if (_localHistoryEntry != null) {
      return;
    }

    final route = ModalRoute.of(context);
    if (route == null) {
      return;
    }

    _localHistoryEntry = LocalHistoryEntry(
      onRemove: () {
        _localHistoryEntry = null;
        if (_isClosingFromHistory) {
          _isClosingFromHistory = false;
          return;
        }
        if (_isOpen) {
          _closeDropdown();
        }
      },
    );
    route.addLocalHistoryEntry(_localHistoryEntry!);
  }

  void _removeLocalHistoryEntry() {
    if (_localHistoryEntry == null) {
      return;
    }

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
      (option) => !option.disabled && option.value == widget.value,
    );
    if (selectedIndex != -1) {
      return selectedIndex;
    }

    final firstEnabledIndex = widget.options.indexWhere(
      (option) => !option.disabled,
    );
    return firstEnabledIndex == -1 ? null : firstEnabledIndex;
  }

  /// Creates an overlay entry for the dropdown menu with intelligent positioning.
  ///
  /// This method implements smart positioning logic that automatically determines
  /// whether the dropdown should open upward or downward based on available
  /// screen space.
  ///
  /// **Positioning Algorithm:**
  /// 1. Measures available space above and below the trigger element
  /// 2. Accounts for safe area insets (iPhone home indicator, etc.)
  /// 3. Adds buffer for borders (2px), shadows (~8px), and safety margin
  /// 4. Decides direction based on:
  ///    - If both directions have space → uses [dropUp] preference
  ///    - If only one direction has space → uses that direction
  ///    - If neither has space → uses direction with MORE available space
  ///
  /// **Key Considerations:**
  /// - The dropdown has a max height of 240px (see [_buildDropdownMenu])
  /// - Border and shadow decorations add ~20px to the visual height
  /// - Bottom safe area padding (iPhone home indicator) reduces usable space
  /// - An 8px gap provides visual separation from the trigger
  ///
  /// This ensures the dropdown never opens in a direction that would clip
  /// off-screen when a better alternative exists.
  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final bottomPadding = mediaQuery.padding.bottom;

    // Actual max height of the dropdown (matches _buildDropdownMenu constraint)
    // Add extra buffer for borders (2px) and shadows (~8px) and safety margin
    const maxDropdownHeight = 240.0;
    const borderAndShadowBuffer = 20.0; // Generous buffer for all decorations
    final estimatedHeight = _estimateDropdownHeight();
    final dropdownHeight =
        (estimatedHeight < maxDropdownHeight
            ? estimatedHeight
            : maxDropdownHeight) +
        borderAndShadowBuffer;

    // Calculate available space above and below the trigger
    // Account for safe area insets (iPhone home indicator, etc)
    const gap = 4.0; // Visual separation between trigger and dropdown
    final spaceAbove = position.dy - gap;
    final spaceBelow =
        screenHeight - (position.dy + size.height) - bottomPadding - gap;

    // Determine if we should open upward based on available space
    final bool shouldOpenUp;
    final hasSpaceAbove = spaceAbove >= dropdownHeight;
    final hasSpaceBelow = spaceBelow >= dropdownHeight;

    // Decision tree for positioning:
    if (hasSpaceAbove && hasSpaceBelow) {
      // Case 1: Both directions have sufficient space
      // → Honor the user's preference (dropUp parameter)
      shouldOpenUp = widget.dropUp;
    } else if (hasSpaceAbove && !hasSpaceBelow) {
      // Case 2: Only upward has space
      // → Open upward (even if dropUp is false)
      shouldOpenUp = true;
    } else if (!hasSpaceAbove && hasSpaceBelow) {
      // Case 3: Only downward has space
      // → Open downward (even if dropUp is true)
      shouldOpenUp = false;
    } else {
      // Case 4: Neither direction has enough space
      // → Pick the direction with MORE available space (best fit)
      shouldOpenUp = spaceAbove > spaceBelow;
    }

    // Anchor the menu to the trigger so its position is independent of the
    // estimated height. Opening up: align the menu's bottom edge to the
    // trigger's top edge (only `gap` of separation). Opening down: align the
    // menu's top edge to the trigger's bottom edge. This avoids the large
    // vertical gap that resulted from offsetting by an over-estimated height.
    final targetAnchor = shouldOpenUp
        ? Alignment.topLeft
        : Alignment.bottomLeft;
    final followerAnchor = shouldOpenUp
        ? Alignment.bottomLeft
        : Alignment.topLeft;
    final dropOffset = Offset(0, shouldOpenUp ? -gap : gap);

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
                      targetAnchor: targetAnchor,
                      followerAnchor: followerAnchor,
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
        if (!_isTouchLikePointer(event)) {
          return;
        }
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
        if (_touchPointerId != event.pointer) {
          return;
        }
        _handleTouchSelection(event);
        _touchPointerId = null;
      },
      onPointerCancel: (event) {
        if (_touchPointerId == event.pointer) {
          _touchPointerId = null;
        }
      },
      child: Container(
        constraints: const BoxConstraints(maxHeight: 240),
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
                    final isSelected = widget.value == option.value;

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

    // Material must sit INSIDE the dropdown container so InkWell hover
    // effects paint above the opaque background, not behind it.
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
            child: InkWell(
              canRequestFocus: false,
              onTap: option.disabled
                  ? null
                  : () {
                      widget.onChanged?.call(option.value);
                      _closeDropdown();
                    },
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
                    if (option.leading != null) ...[
                      option.leading!,
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        option.label,
                        style: TextStyle(
                          fontSize: _getFontSize(),
                          color: isSelected
                              ? SoftSaaSTokens.primaryColor(brightness)
                              : (option.disabled
                                    ? (isLight
                                          ? SoftSaaSTokens.gray400
                                          : SoftSaaSTokens.gray600)
                                    : SoftSaaSTokens.primaryText(brightness)),
                          height: 1.0,
                        ).merge(option.labelStyle),
                      ),
                    ),
                    if (isSelected) ...[
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
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final selectedOption = widget.options.firstWhere(
      (opt) => opt.value == widget.value,
      orElse: () => const SelectOption(value: '', label: ''),
    );

    final isText = widget._style == _SoftSaaSSelectStyle.text;
    final isPrimary = widget._style == _SoftSaaSSelectStyle.primary;
    final isElevated = widget._style == _SoftSaaSSelectStyle.elevated;
    final defaultTextColor = isPrimary
        ? Colors.white
        : selectedOption.label.isEmpty
        ? (brightness == Brightness.light
              ? SoftSaaSTokens.gray500
              : SoftSaaSTokens.gray400)
        : SoftSaaSTokens.primaryText(brightness);

    final baseStyle = TextStyle(
      fontSize: _getFontSize(),
      color: defaultTextColor,
      fontWeight: (isPrimary || isElevated)
          ? SoftSaaSTokens.fontWeightMedium
          : SoftSaaSTokens.fontWeightNormal,
      height: 1.0,
    );
    final textStyle = (widget.textStyle ?? baseStyle).merge(
      selectedOption.labelStyle,
    );
    final triggerLeading = widget.selectedLeading ?? selectedOption.leading;

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
              if (_isFocused == isFocused) {
                return;
              }
              setState(() {
                _isFocused = isFocused || _isOpen;
              });
            },
            child: Semantics(
              button: true,
              enabled: widget.enabled,
              child: MouseRegion(
                cursor: widget.enabled
                    ? SystemMouseCursors.click
                    : SystemMouseCursors.basic,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _toggleDropdown,
                  child: isText
                      ? _buildTextOnlyTrigger(
                          brightness,
                          textStyle,
                          selectedOption,
                          triggerLeading: triggerLeading,
                        )
                      : _buildFieldTrigger(
                          brightness,
                          textStyle,
                          selectedOption,
                          triggerLeading: triggerLeading,
                          primary: isPrimary,
                          elevated: isElevated,
                        ),
                ),
              ),
            ),
          ),
        ),
        if (widget.error != null && widget.size != SoftSaaSSelectSize.small)
          Flexible(
            child: Padding(
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
          ),
      ],
    );
  }

  Widget _buildFieldTrigger(
    Brightness brightness,
    TextStyle textStyle,
    SelectOption selectedOption, {
    required Widget? triggerLeading,
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

    final leadingSpacing = widget.selectedLeading != null ? 0.0 : 8.0;

    return Container(
      height: _getHeight(),
      padding: _getTriggerPadding(hasLeading: triggerLeading != null),
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
          if (triggerLeading != null) ...[
            triggerLeading,
            SizedBox(width: leadingSpacing),
          ],
          Expanded(
            child: Text(
              selectedOption.label.isEmpty
                  ? widget.placeholder
                  : selectedOption.label,
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

  EdgeInsets _getTriggerPadding({bool hasLeading = false}) {
    final leftReduction = hasLeading ? 4.0 : 0.0;
    switch (widget.size) {
      case SoftSaaSSelectSize.small:
        return EdgeInsets.fromLTRB(10 - leftReduction, 4, 8, 4);
      case SoftSaaSSelectSize.medium:
        return EdgeInsets.fromLTRB(12 - leftReduction, 6, 10, 6);
      case SoftSaaSSelectSize.large:
        return EdgeInsets.fromLTRB(14 - leftReduction, 8, 12, 8);
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
    if (widget.fontSize != null) {
      return widget.fontSize!;
    }
    switch (widget.size) {
      case SoftSaaSSelectSize.small:
        return 13.0;
      case SoftSaaSSelectSize.medium:
        return 13.0;
      case SoftSaaSSelectSize.large:
        return 15.0;
    }
  }

  double _estimateDropdownHeight() {
    if (widget.options.isEmpty) {
      return 56;
    }
    final optionHeight =
        (_getFontSize() * 1.4) + (_getOptionPadding().vertical);
    final estimated = optionHeight * widget.options.length;
    return estimated.clamp(0, 240).toDouble();
  }

  Widget _buildTextOnlyTrigger(
    Brightness brightness,
    TextStyle textStyle,
    SelectOption selectedOption, {
    required Widget? triggerLeading,
  }) {
    final label = selectedOption.label.isEmpty
        ? widget.placeholder
        : selectedOption.label;
    final textColor = widget.enabled
        ? textStyle.color
        : (brightness == Brightness.light
              ? SoftSaaSTokens.gray400
              : SoftSaaSTokens.gray600);

    final leadingSpacing = widget.selectedLeading != null ? 0.0 : 6.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (triggerLeading != null) ...[
          triggerLeading,
          SizedBox(width: leadingSpacing),
        ],
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
