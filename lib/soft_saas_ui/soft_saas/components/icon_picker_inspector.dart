/// Soft SaaS UI Icon Picker — Inspector-style inline swatch grid.
///
/// Two variants:
///
/// * [SoftSaaSIconPickerInspector] — the full inspector strip: optional "None"
///   swatch, a short row of frequent icons, then an ellipsis that opens the
///   searchable grid popover.
/// * [SoftSaaSIconSwatchInspector] — a standalone single-button variant (mirrors
///   the standalone color swatch pattern) that renders only the current
///   icon inside a tappable square which opens the same popover.
library;

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../design_tokens.dart';
import '../typography.dart';
import 'text_input.dart';

class SoftSaaSIconPickerInspectorEntry {
  const SoftSaaSIconPickerInspectorEntry({
    required this.name,
    required this.icon,
  });
  final String name;
  final IconData icon;
}

class SoftSaaSIconPickerInspector extends StatefulWidget {
  const SoftSaaSIconPickerInspector({
    super.key,
    required this.value,
    required this.icons,
    required this.onChanged,
    this.enabled = true,
    this.label,
    this.allowNone = true,
    this.inlineCount = 8,
  });

  final String? value;
  final List<SoftSaaSIconPickerInspectorEntry> icons;
  final ValueChanged<String?> onChanged;
  final bool enabled;
  final String? label;
  final bool allowNone;

  /// How many icons to show inline before the "More" button. Caller can
  /// pre-sort the [icons] list by recency/popularity.
  final int inlineCount;

  @override
  State<SoftSaaSIconPickerInspector> createState() =>
      _SoftSaaSIconPickerInspectorState();
}

class _SoftSaaSIconPickerInspectorState
    extends State<SoftSaaSIconPickerInspector> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _overlay;

  @override
  void dispose() {
    _overlay?.remove();
    super.dispose();
  }

  void _openPopover() {
    if (_overlay != null) {
      _closePopover();
      return;
    }
    final box = context.findRenderObject() as RenderBox?;
    final rowWidth = box?.size.width ?? 240;
    _overlay = OverlayEntry(
      builder: (context) => SoftSaaSIconGridPopover(
        link: _link,
        width: rowWidth,
        icons: widget.icons,
        selectedValue: widget.value,
        onClose: _closePopover,
        onPick: (name) {
          widget.onChanged(name);
          _closePopover();
        },
        allowNone: widget.allowNone,
      ),
    );
    Overlay.of(context).insert(_overlay!);
    setState(() {});
  }

  void _closePopover() {
    _overlay?.remove();
    _overlay = null;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final inline = widget.icons.take(widget.inlineCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: SoftSaaSTypography.label(brightness)),
          const SizedBox(height: 6),
        ],
        CompositedTransformTarget(
          link: _link,
          child: Container(
            decoration: BoxDecoration(
              color: SoftSaaSTokens.secondaryBackground(brightness),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: SoftSaaSTokens.primaryBorder(brightness),
              ),
            ),
            padding: const EdgeInsets.all(2),
            child: Row(
              children: [
                if (widget.allowNone)
                  _Swatch(
                    icon: LucideIcons.ban,
                    selected: widget.value == null,
                    enabled: widget.enabled,
                    onTap: () => widget.onChanged(null),
                    brightness: brightness,
                    tooltip: 'None',
                  ),
                for (final e in inline)
                  _Swatch(
                    icon: e.icon,
                    selected: widget.value == e.name,
                    enabled: widget.enabled,
                    onTap: () => widget.onChanged(e.name),
                    brightness: brightness,
                    tooltip: e.name,
                  ),
                const Spacer(),
                _Swatch(
                  icon: LucideIcons.ellipsis,
                  selected: _overlay != null,
                  enabled: widget.enabled,
                  onTap: _openPopover,
                  brightness: brightness,
                  tooltip: 'Browse all icons…',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Standalone single-button icon picker. Matches the standalone color
/// swatch pattern — renders only the current icon inside a tappable square
/// that opens the same searchable popover as [SoftSaaSIconPickerInspector].
class SoftSaaSIconSwatchInspector extends StatefulWidget {
  const SoftSaaSIconSwatchInspector({
    super.key,
    required this.value,
    required this.icons,
    required this.onChanged,
    this.enabled = true,
    this.allowNone = true,
    this.size = 32,
  });

  final String? value;
  final List<SoftSaaSIconPickerInspectorEntry> icons;
  final ValueChanged<String?> onChanged;
  final bool enabled;
  final bool allowNone;
  final double size;

  @override
  State<SoftSaaSIconSwatchInspector> createState() =>
      _SoftSaaSIconSwatchInspectorState();
}

class _SoftSaaSIconSwatchInspectorState
    extends State<SoftSaaSIconSwatchInspector> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _overlay;

  @override
  void dispose() {
    _overlay?.remove();
    super.dispose();
  }

  IconData? _currentIcon() {
    if (widget.value == null) return null;
    for (final e in widget.icons) {
      if (e.name == widget.value) return e.icon;
    }
    return null;
  }

  void _openPopover() {
    if (_overlay != null) {
      _closePopover();
      return;
    }
    _overlay = OverlayEntry(
      builder: (context) => SoftSaaSIconGridPopover(
        link: _link,
        width: 300,
        icons: widget.icons,
        selectedValue: widget.value,
        onClose: _closePopover,
        onPick: (name) {
          widget.onChanged(name);
          _closePopover();
        },
        allowNone: widget.allowNone,
      ),
    );
    Overlay.of(context).insert(_overlay!);
    setState(() {});
  }

  void _closePopover() {
    _overlay?.remove();
    _overlay = null;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final icon = _currentIcon();
    return CompositedTransformTarget(
      link: _link,
      child: MouseRegion(
        cursor: widget.enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: widget.enabled ? _openPopover : null,
          child: AnimatedContainer(
            duration: SoftSaaSTokens.transitionDuration,
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: SoftSaaSTokens.secondaryBackground(brightness),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: SoftSaaSTokens.primaryBorder(brightness),
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon ?? LucideIcons.ban,
              size: widget.size * 0.5,
              color: icon == null
                  ? SoftSaaSTokens.tertiaryText(brightness)
                  : SoftSaaSTokens.primaryText(brightness),
            ),
          ),
        ),
      ),
    );
  }
}

class _Swatch extends StatefulWidget {
  const _Swatch({
    required this.icon,
    required this.selected,
    required this.enabled,
    required this.onTap,
    required this.brightness,
    required this.tooltip,
  });

  final IconData icon;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;
  final Brightness brightness;
  final String tooltip;

  @override
  State<_Swatch> createState() => _SwatchState();
}

class _SwatchState extends State<_Swatch> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.selected
        ? SoftSaaSTokens.primaryColor(widget.brightness)
        : SoftSaaSTokens.secondaryText(widget.brightness);
    final bg = widget.selected
        ? SoftSaaSTokens.controlActiveTint(widget.brightness)
        : (_hovered
              ? SoftSaaSTokens.controlHoverOverlay(widget.brightness)
              : Colors.transparent);
    return MouseRegion(
      cursor: widget.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: Tooltip(
          message: widget.tooltip,
          child: AnimatedContainer(
            duration: SoftSaaSTokens.transitionDuration,
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Icon(widget.icon, size: 13, color: color),
          ),
        ),
      ),
    );
  }
}

class SoftSaaSIconGridPopover extends StatefulWidget {
  const SoftSaaSIconGridPopover({
    super.key,
    required this.link,
    required this.width,
    required this.icons,
    required this.selectedValue,
    required this.onClose,
    required this.onPick,
    required this.allowNone,
  });

  final LayerLink link;
  final double width;
  final List<SoftSaaSIconPickerInspectorEntry> icons;
  final String? selectedValue;
  final VoidCallback onClose;
  final ValueChanged<String?> onPick;
  final bool allowNone;

  @override
  State<SoftSaaSIconGridPopover> createState() =>
      _SoftSaaSIconGridPopoverState();
}

class _SoftSaaSIconGridPopoverState extends State<SoftSaaSIconGridPopover> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final filtered = _query.isEmpty
        ? widget.icons
        : widget.icons
              .where((e) => e.name.toLowerCase().contains(_query.toLowerCase()))
              .toList();

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onClose,
            behavior: HitTestBehavior.opaque,
            child: const SizedBox.shrink(),
          ),
        ),
        CompositedTransformFollower(
          link: widget.link,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, 4),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            color: SoftSaaSTokens.primaryBackground(brightness),
            child: Container(
              width: widget.width.clamp(260, 400),
              constraints: const BoxConstraints(maxHeight: 320),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: SoftSaaSTokens.primaryBorder(brightness),
                ),
              ),
              // Popover itself has NO padding so the scrollable reaches the
              // edges. The search row and the grid each apply their own
              // horizontal padding so the visible left/right rhythm matches.
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                    child: SoftSaaSTextInput(
                      autofocus: true,
                      controller: _searchController,
                      size: SoftSaaSTextInputSize.small,
                      hintText: 'Search icons',
                      prefixIcon: LucideIcons.search,
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ),
                  Flexible(
                    child: GridView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      itemCount: filtered.length + (widget.allowNone ? 1 : 0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 8,
                            mainAxisSpacing: 2,
                            crossAxisSpacing: 2,
                          ),
                      itemBuilder: (context, index) {
                        if (widget.allowNone && index == 0) {
                          return _GridCell(
                            icon: LucideIcons.ban,
                            tooltip: 'None',
                            selected: widget.selectedValue == null,
                            onTap: () => widget.onPick(null),
                            brightness: brightness,
                          );
                        }
                        final entry =
                            filtered[widget.allowNone ? index - 1 : index];
                        return _GridCell(
                          icon: entry.icon,
                          tooltip: entry.name,
                          selected: widget.selectedValue == entry.name,
                          onTap: () => widget.onPick(entry.name),
                          brightness: brightness,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Single grid cell — intentionally WITHOUT a Tooltip.
///
/// Tooltips mount their own [CompositedTransformFollower], and when many
/// cells inside a popover that is already a follower rapidly open/close
/// them on hover, Flutter's paint pipeline throws:
///
///   "The paint transform cannot be reliably computed because of
///    RenderFollowerLayer(s)"
///
/// followed by a `debugNeedsLayout` assertion. Rather than nesting
/// followers we rely on the visible icon itself for recognition; the search
/// input provides the authoritative way to disambiguate by name.
class _GridCell extends StatefulWidget {
  const _GridCell({
    required this.icon,
    required this.tooltip,
    required this.selected,
    required this.onTap,
    required this.brightness,
  });

  final IconData icon;
  // Kept on the API for parity; no Tooltip is mounted (see class doc).
  // ignore: unused_element_parameter
  final String tooltip;
  final bool selected;
  final VoidCallback onTap;
  final Brightness brightness;

  @override
  State<_GridCell> createState() => _GridCellState();
}

class _GridCellState extends State<_GridCell> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: SoftSaaSTokens.transitionDuration,
          decoration: BoxDecoration(
            color: widget.selected
                ? SoftSaaSTokens.controlActiveTint(widget.brightness)
                : (_hovered
                      ? SoftSaaSTokens.controlHoverOverlay(widget.brightness)
                      : Colors.transparent),
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: Icon(
            widget.icon,
            size: 14,
            color: widget.selected
                ? SoftSaaSTokens.primaryColor(widget.brightness)
                : SoftSaaSTokens.primaryText(widget.brightness),
          ),
        ),
      ),
    );
  }
}
