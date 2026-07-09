// Soft SaaS UI Reorderable List Component
//
// A bordered container with a header (title + count badge + add button),
// reorderable items with drag handles, and an empty state.
// Production flat style — border + bg, no shadow.

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../design_tokens.dart';
import 'button.dart';

// ══════════════════════════════════════════════════════════════════════
// REORDERABLE LIST
// ══════════════════════════════════════════════════════════════════════

/// A bordered reorderable list with header, drag handles, and empty state.
///
/// ```dart
/// SoftSaaSReorderableList(
///   itemCount: items.length,
///   itemBuilder: (context, index) => Text(items[index]),
///   onReorder: (old, new) => ...,
///   onAdd: () => ...,
/// )
/// ```
class SoftSaaSReorderableList extends StatelessWidget {
  const SoftSaaSReorderableList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.onReorder,
    this.title = 'Items',
    this.onAdd,
    this.emptyLabel = 'Add item',
  });

  /// Number of items.
  final int itemCount;

  /// Builds each item row. The row should contain the drag handle area,
  /// content, and any action buttons.
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// Called when items are reordered.
  final ReorderCallback onReorder;

  /// Header title. Defaults to 'Items'.
  final String title;

  /// Called when the add button is pressed.
  final VoidCallback? onAdd;

  /// Label for the empty state add button.
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final border = SoftSaaSTokens.primaryBorder(brightness);

    return Container(
      decoration: BoxDecoration(
        color: SoftSaaSTokens.primaryBackground(brightness),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row — always visible
          Container(
            padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: border, width: 1)),
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                    color: SoftSaaSTokens.primaryText(brightness),
                  ),
                ),
                const SizedBox(width: 6),
                // Count badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: SoftSaaSTokens.tertiaryBackground(brightness),
                    borderRadius: BorderRadius.circular(
                      SoftSaaSTokens.radiusFull,
                    ),
                  ),
                  child: Text(
                    '$itemCount',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: SoftSaaSTokens.fontWeightSemibold,
                      color: SoftSaaSTokens.secondaryText(brightness),
                    ),
                  ),
                ),
                const Spacer(),
                if (onAdd != null)
                  SoftSaaSIconButton(
                    icon: LucideIcons.plus,
                    size: SoftSaaSButtonSize.small,
                    variant: SoftSaaSIconButtonVariant.ghost,
                    iconColor: SoftSaaSTokens.tertiaryText(brightness),
                    onPressed: onAdd,
                  ),
              ],
            ),
          ),
          // Items or empty state
          if (itemCount == 0)
            _buildEmptyState(brightness)
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: itemCount,
              proxyDecorator: (child, index, animation) {
                return Material(color: Colors.transparent, child: child);
              },
              onReorder: onReorder,
              itemBuilder: itemBuilder,
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Brightness brightness) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          'Empty',
          style: TextStyle(
            fontSize: 11,
            color: SoftSaaSTokens.tertiaryText(brightness),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// LIST ITEM ROW
// ══════════════════════════════════════════════════════════════════════

/// A list item row with drag handle, content, and optional remove button.
///
/// Provides the hover highlight and drag handle wrapping. Place your
/// content widget as [child].
///
/// ```dart
/// SoftSaaSReorderableListItem(
///   index: index,
///   onRemove: () => ...,
///   child: SoftSaaSTextInput(...),
/// )
/// ```
class SoftSaaSReorderableListItem extends StatefulWidget {
  const SoftSaaSReorderableListItem({
    super.key,
    required this.index,
    required this.child,
    this.onRemove,
  });

  /// Index for the reorderable drag handle.
  final int index;

  /// Content widget (input, switch, etc).
  final Widget child;

  /// Called when remove button is pressed.
  final VoidCallback? onRemove;

  @override
  State<SoftSaaSReorderableListItem> createState() =>
      _SoftSaaSReorderableListItemState();
}

class _SoftSaaSReorderableListItemState
    extends State<SoftSaaSReorderableListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.fromLTRB(0, 4, 6, 4),
        decoration: BoxDecoration(
          color: _isHovered
              ? (brightness == Brightness.light
                    ? Colors.black.withValues(alpha: 0.02)
                    : Colors.white.withValues(alpha: 0.03))
              : Colors.transparent,
        ),
        child: Row(
          children: [
            // Drag handle
            ReorderableDragStartListener(
              index: widget.index,
              child: MouseRegion(
                cursor: SystemMouseCursors.grab,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    LucideIcons.grip_vertical,
                    size: 14,
                    color: SoftSaaSTokens.tertiaryText(brightness),
                  ),
                ),
              ),
            ),
            // Content
            Expanded(child: widget.child),
            const SizedBox(width: 4),
            // Remove button
            if (widget.onRemove != null)
              SoftSaaSIconButton(
                icon: LucideIcons.x,
                size: SoftSaaSButtonSize.small,
                variant: SoftSaaSIconButtonVariant.ghost,
                iconColor: _isHovered
                    ? SoftSaaSTokens.errorColor(brightness)
                    : SoftSaaSTokens.tertiaryText(brightness),
                onPressed: widget.onRemove,
              ),
          ],
        ),
      ),
    );
  }
}
