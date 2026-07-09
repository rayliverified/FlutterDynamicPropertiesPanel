// Soft SaaS UI Dropdown Component
//
// Dropdown menu for actions and options

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_tokens.dart';
import '../neumorphic_shadows.dart';

// ══════════════════════════════════════════════════════════════════════
// DROPDOWN
// ══════════════════════════════════════════════════════════════════════

/// Dropdown menu item
class DropdownMenuItem {
  const DropdownMenuItem({
    required this.label,
    this.icon,
    this.onTap,
    this.isDivider = false,
    this.isDanger = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isDivider;
  final bool isDanger;
}

/// Soft SaaS UI Menu Dropdown Component
class SoftSaaSMenuDropdown extends StatefulWidget {
  const SoftSaaSMenuDropdown({
    super.key,
    required this.trigger,
    required this.items,
    this.alignment = SoftSaaSMenuDropdownAlignment.end,
    this.width,
    this.verticalOffset,
  });

  final Widget trigger;
  final List<DropdownMenuItem> items;
  final SoftSaaSMenuDropdownAlignment alignment;

  /// Override the dropdown panel width. Defaults to 186 for backward compat.
  final double? width;

  /// Vertical gap between trigger bottom and menu top. If null, uses the
  /// legacy `triggerHeight + 4` offset so existing call-sites don't shift.
  final double? verticalOffset;

  @override
  State<SoftSaaSMenuDropdown> createState() => _SoftSaaSMenuDropdownState();
}

/// Horizontal dropdown alignment relative to trigger.
enum SoftSaaSMenuDropdownAlignment {
  /// Align left edges (menu prefers opening toward the right).
  start,

  /// Align right edges (menu prefers opening toward the left).
  end,
}

class _SoftSaaSMenuDropdownState extends State<SoftSaaSMenuDropdown> {
  static const _dropdownWidth = 186.0;
  static const _viewportPadding = 8.0;

  bool _isOpen = false;
  final LayerLink _layerLink = LayerLink();
  final FocusScopeNode _menuFocusScopeNode = FocusScopeNode(
    debugLabel: 'SoftSaaSDropdownMenu',
  );
  OverlayEntry? _overlayEntry;
  LocalHistoryEntry? _localHistoryEntry;
  bool _isClosingFromHistory = false;

  @override
  void dispose() {
    _removeLocalHistoryEntry();
    _removeOverlay();
    _menuFocusScopeNode.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    final overlay = Overlay.of(context);
    if (_isOpen) {
      return;
    }

    setState(() => _isOpen = true);
    _registerLocalHistoryEntry();
    _overlayEntry = _createOverlayEntry();
    overlay.insert(_overlayEntry!);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isOpen && mounted) {
        _menuFocusScopeNode.requestFocus();
      }
    });
  }

  void _closeDropdown() {
    if (!_isOpen) {
      _removeOverlay();
      _removeLocalHistoryEntry();
      return;
    }

    if (mounted) {
      setState(() => _isOpen = false);
    } else {
      _isOpen = false;
    }

    _removeOverlay();
    _removeLocalHistoryEntry();
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

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final topLeft = renderBox.localToGlobal(Offset.zero);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final triggerRight = topLeft.dx + size.width;
    final effectiveWidth = widget.width ?? _dropdownWidth;
    final canOpenRight =
        topLeft.dx + effectiveWidth <= screenWidth - _viewportPadding;
    final canOpenLeft = triggerRight - effectiveWidth >= _viewportPadding;

    final preferRight = widget.alignment == SoftSaaSMenuDropdownAlignment.start;
    final alignToLeftEdge = preferRight
        ? (canOpenRight || !canOpenLeft)
        : !(canOpenLeft || !canOpenRight);

    return OverlayEntry(
      builder: (context) => Shortcuts(
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            DismissIntent: CallbackAction<DismissIntent>(
              onInvoke: (intent) {
                _closeDropdown();
                return null;
              },
            ),
          },
          child: FocusScope(
            node: _menuFocusScopeNode,
            autofocus: true,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _closeDropdown,
              child: Stack(
                children: [
                  Positioned(
                    width: effectiveWidth,
                    child: CompositedTransformFollower(
                      link: _layerLink,
                      showWhenUnlinked: false,
                      targetAnchor: alignToLeftEdge
                          ? Alignment.bottomLeft
                          : Alignment.bottomRight,
                      followerAnchor: alignToLeftEdge
                          ? Alignment.topLeft
                          : Alignment.topRight,
                      offset: Offset(
                        0,
                        widget.verticalOffset ?? size.height + 4,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: _buildDropdownMenu(),
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

    return Container(
      decoration: BoxDecoration(
        color: SoftSaaSTokens.primaryBackground(brightness),
        border: Border.all(color: SoftSaaSTokens.primaryBorder(brightness)),
        borderRadius: BorderRadius.circular(SoftSaaSTokens.radius2XLarge),
        // Use neumorphic shadows for elevated dropdown effect
        boxShadow: brightness == Brightness.light
            ? NeumorphicShadows.level3Light
            : NeumorphicShadows.level3Dark,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SoftSaaSTokens.radius2XLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: widget.items.map((item) {
            if (item.isDivider) {
              return Divider(
                height: 1,
                color: SoftSaaSTokens.primaryBorder(brightness),
              );
            }
            return _buildMenuItem(brightness, item);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMenuItem(Brightness brightness, DropdownMenuItem item) {
    return _DropdownMenuRow(
      brightness: brightness,
      item: item,
      onClose: _closeDropdown,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(onTap: _toggleDropdown, child: widget.trigger),
      ),
    );
  }
}

class _DropdownMenuRow extends StatelessWidget {
  const _DropdownMenuRow({
    required this.brightness,
    required this.item,
    required this.onClose,
  });

  final Brightness brightness;
  final DropdownMenuItem item;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            item.onTap?.call();
            onClose();
          },
          hoverColor: brightness == Brightness.light
              ? SoftSaaSTokens.gray50
              : SoftSaaSTokens.gray700.withValues(alpha: 0.5),
          child: Focus(
            onKeyEvent: (node, event) {
              if (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.space) {
                if (event is KeyDownEvent) {
                  item.onTap?.call();
                  onClose();
                  return KeyEventResult.handled;
                }
              }
              return KeyEventResult.ignored;
            },
            child: Builder(
              builder: (context) {
                final isFocused = Focus.of(context).hasFocus;
                return Ink(
                  decoration: BoxDecoration(
                    border: isFocused
                        ? Border.all(
                            color: SoftSaaSTokens.primaryColor(brightness),
                            width: 2,
                          )
                        : null,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: Semantics(
                      button: true,
                      label: item.label,
                      child: Row(
                        children: [
                          if (item.icon != null) ...[
                            Icon(
                              item.icon,
                              size: 14,
                              color: item.isDanger
                                  ? SoftSaaSTokens.errorColor(brightness)
                                  : SoftSaaSTokens.secondaryText(brightness),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Expanded(
                            child: Text(
                              item.label,
                              style: TextStyle(
                                fontSize: SoftSaaSTokens.fontSizeXS,
                                fontWeight: SoftSaaSTokens.fontWeightMedium,
                                color: item.isDanger
                                    ? SoftSaaSTokens.errorColor(brightness)
                                    : SoftSaaSTokens.primaryText(brightness),
                                letterSpacing: -0.01,
                                height: 1.25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
