import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

/// One card in the [PreviewCarousel].
class PreviewCarouselItem {
  const PreviewCarouselItem(
    this.name,
    this.propertyName,
    this.child, {
    this.width = 330,
    this.height,
  });

  final String name;
  final String? propertyName;
  final Widget child;
  final double width;
  final double? height;
}

/// Horizontally swipeable card deck.
///
/// This is a nested StatefulWidget with genuinely independent state (the
/// active index plus drag/snap animation). Its [PreviewCarouselState] is
/// public, but its key is owned by the parent screen State — not the
/// registry. Tooling addresses it through the screen:
///
/// ```dart
/// registry.state<FeatureBlockScreenState>('example.featureBlock')
///     ?.carousel?.activeIndex = 3;
/// ```
class PreviewCarousel extends StatefulWidget {
  const PreviewCarousel({
    super.key,
    required this.items,
    required this.brightness,
    this.initialIndex = 0,
    this.onItemSelected,
  });

  final List<PreviewCarouselItem> items;
  final Brightness brightness;
  final int initialIndex;

  /// Fired when the user (or tooling) lands on a card. Carries the item's
  /// semantic property name (null for the "all" card).
  final ValueChanged<PreviewCarouselItem>? onItemSelected;

  @override
  State<PreviewCarousel> createState() => PreviewCarouselState();
}

class PreviewCarouselState extends State<PreviewCarousel>
    with SingleTickerProviderStateMixin {
  int _activeIndex = 0;
  double _dragOffset = 0;
  double _lastItemSpacing = 420;
  late final AnimationController _snapController;
  Animation<double>? _snapOffsetAnimation;

  /// The currently centered card. Settable by storyboards through the
  /// registry — assigning animates to the requested card and fires
  /// [PreviewCarousel.onItemSelected].
  int get activeIndex => _activeIndex;
  set activeIndex(int value) => select(value);

  @override
  void initState() {
    super.initState();
    _activeIndex = widget.initialIndex.clamp(0, widget.items.length - 1);
    _snapController = AnimationController(vsync: this)
      ..addListener(() {
        final animation = _snapOffsetAnimation;
        if (animation == null || !mounted) return;
        setState(() => _dragOffset = animation.value);
      });
  }

  @override
  void didUpdateWidget(covariant PreviewCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex &&
        widget.initialIndex != _activeIndex) {
      final next = widget.initialIndex.clamp(0, widget.items.length - 1);
      setState(() => _activeIndex = next);
    }
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  /// Animate to card [index] and notify the parent.
  void select(int index) {
    if (index < 0 || index >= widget.items.length) return;

    final previousIndex = _activeIndex;
    final continuityOffset =
        _dragOffset + ((index - previousIndex) * _lastItemSpacing);

    _snapController.stop();
    _snapOffsetAnimation = null;
    setState(() {
      _activeIndex = index;
      _dragOffset = continuityOffset;
    });
    widget.onItemSelected?.call(widget.items[index]);
    _animateDragOffsetToZero(continuityOffset);
  }

  void _animateDragOffsetToZero(double from) {
    _snapController.stop();
    _snapOffsetAnimation = Tween<double>(begin: from, end: 0).animate(
      CurvedAnimation(parent: _snapController, curve: Curves.easeOutCubic),
    );
    final distance = from.abs();
    _snapController.duration = Duration(
      milliseconds: (420 + distance * 0.65).round().clamp(520, 920),
    );
    _snapController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (_) => setState(() {
        _snapController.stop();
        _snapOffsetAnimation = null;
        _dragOffset = 0;
      }),
      onHorizontalDragUpdate: (details) {
        setState(() => _dragOffset += details.delta.dx);
      },
      onHorizontalDragCancel: () {
        _animateDragOffsetToZero(_dragOffset);
      },
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        const threshold = 80.0;
        final shouldGoNext = velocity < -120 || _dragOffset < -threshold;
        final shouldGoPrevious = velocity > 120 || _dragOffset > threshold;
        if (shouldGoNext) {
          select(math.min(_activeIndex + 1, items.length - 1));
        } else if (shouldGoPrevious) {
          select(math.max(_activeIndex - 1, 0));
        } else {
          _animateDragOffsetToZero(_dragOffset);
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          return SizedBox(
            height: compact ? 430 : 780,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final activeWidth = items[_activeIndex].width;
                final itemSpacing = math.max(
                  360.0,
                  math.min(activeWidth * 0.96, constraints.maxWidth * 0.44),
                );
                _lastItemSpacing = itemSpacing;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (var index = items.length - 1; index >= 0; index--)
                      if ((index - _activeIndex).abs() <= 2)
                        _positionedItem(
                          item: items[index],
                          index: index,
                          itemSpacing: itemSpacing,
                          offsetX:
                              (index - _activeIndex) * itemSpacing +
                              _dragOffset,
                        ),
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: _arrow(
                        icon: LucideIcons.chevron_left,
                        enabled: _activeIndex > 0,
                        onPressed: () => select(_activeIndex - 1),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: _arrow(
                        icon: LucideIcons.chevron_right,
                        enabled: _activeIndex < items.length - 1,
                        onPressed: () => select(_activeIndex + 1),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _positionedItem({
    required PreviewCarouselItem item,
    required int index,
    required double itemSpacing,
    required double offsetX,
  }) {
    final virtualIndex = _activeIndex - (_dragOffset / itemSpacing);
    final compact = MediaQuery.sizeOf(context).width < 760;
    final distance = (virtualIndex - index).abs().clamp(0.0, 2.0);
    final scale = 1.0 - (distance * 0.24);
    final opacity = (1.0 - (distance * 0.42)).clamp(0.22, 1.0);
    final yOffset = distance * (compact ? 12 : 26);

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: distance > 1.2,
        child: Opacity(
          opacity: opacity,
          child: Align(
            alignment: Alignment.center,
            child: Transform.translate(
              offset: Offset(offsetX, yOffset),
              child: Transform.scale(scale: scale, child: _card(item, index)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _arrow({
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    final compact = MediaQuery.sizeOf(context).width < 760;
    final buttonSize = compact ? 34.0 : 42.0;
    final iconSize = compact ? 18.0 : 22.0;

    return Center(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: enabled ? 1 : 0.35,
        child: Material(
          color: Colors.white,
          shape: const CircleBorder(),
          elevation: enabled ? 10 : 2,
          shadowColor: Colors.black.withValues(alpha: 0.18),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: enabled ? onPressed : null,
            child: SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: Icon(
                icon,
                size: iconSize,
                color: enabled
                    ? SoftSaaSTokens.secondaryText(widget.brightness)
                    : SoftSaaSTokens.tertiaryText(widget.brightness),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(PreviewCarouselItem item, int index) {
    final active = index == _activeIndex;
    final compact = MediaQuery.sizeOf(context).width < 760;
    final cardScale = compact ? 0.60 : 1.0;
    final cardWidth = item.width * cardScale;
    final cardHeight = item.height == null ? null : item.height! * cardScale;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => select(index),
      child: SizedBox(
        width: cardWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: TextStyle(
                fontSize: active ? 15 : 13,
                fontWeight: FontWeight.w800,
                color: active
                    ? SoftSaaSTokens.primaryText(widget.brightness)
                    : SoftSaaSTokens.tertiaryText(widget.brightness),
              ),
              child: Text(item.name),
            ),
            SizedBox(height: compact ? 12 : 22),
            if (item.height == null)
              SizedBox(
                width: cardWidth,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topCenter,
                  child: SizedBox(width: item.width, child: item.child),
                ),
              )
            else
              SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topCenter,
                  child: SizedBox(width: item.width, child: item.child),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
