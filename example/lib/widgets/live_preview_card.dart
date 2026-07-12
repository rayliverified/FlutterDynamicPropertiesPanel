import 'dart:math' as math;

import 'package:dynamic_properties_panel/dynamic_properties_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

/// Live Preview Card — renders a realistic SaaS "Feature Block" bento
/// dashboard that visualizes the shared [controller]'s property values.
class LivePreviewCard extends StatefulWidget {
  const LivePreviewCard({
    super.key,
    required this.controller,
    required this.brightness,
    this.expandBody = true,
    this.collapsible = false,
    this.expanded = true,
    this.onToggle,
    this.showContainer = true,
    this.selectedPropertyName,
    this.onPropertySelected,
    this.standaloneControllers = const {},
  });

  final DynamicPropertiesController controller;
  final Brightness brightness;
  final bool expandBody;
  final bool collapsible;
  final bool expanded;
  final VoidCallback? onToggle;
  final bool showContainer;
  final String? selectedPropertyName;
  final ValueChanged<String?>? onPropertySelected;
  final Map<String, DynamicPropertiesController> standaloneControllers;

  @override
  State<LivePreviewCard> createState() => _LivePreviewCardState();
}

class _LivePreviewCardState extends State<LivePreviewCard>
    with SingleTickerProviderStateMixin {
  int _activeIndex = 0;
  double _dragOffset = 0;
  double _lastItemSpacing = 420;
  late final AnimationController _snapController;
  Animation<double>? _snapOffsetAnimation;

  DynamicPropertiesController get controller =>
      widget.standaloneControllers[widget.selectedPropertyName] ??
      widget.controller;
  Brightness get brightness => widget.brightness;

  @override
  void initState() {
    super.initState();
    _activeIndex = _indexForProperty(widget.selectedPropertyName);
    _snapController = AnimationController(vsync: this)
      ..addListener(() {
        final animation = _snapOffsetAnimation;
        if (animation == null || !mounted) return;
        setState(() => _dragOffset = animation.value);
      });
  }

  @override
  void didUpdateWidget(covariant LivePreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedPropertyName != oldWidget.selectedPropertyName) {
      final nextIndex = _indexForProperty(widget.selectedPropertyName);
      if (nextIndex != _activeIndex) {
        setState(() => _activeIndex = nextIndex);
      }
    }
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.hasBoundedWidth && constraints.maxWidth < 760;
        final minPreviewHeight = compact ? 460.0 : 820.0;
        final targetHeight = constraints.hasBoundedHeight
            ? math.max(minPreviewHeight, constraints.maxHeight)
            : minPreviewHeight;
        final targetWidth = constraints.hasBoundedWidth
            ? math.max(0.0, constraints.maxWidth - (compact ? 0 : 24))
            : 900.0;
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: targetHeight),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 0 : 12,
                vertical: compact ? 12 : 20,
              ),
              child: Align(
                alignment: compact ? Alignment.topCenter : Alignment.center,
                child: SizedBox(width: targetWidth, child: _bentoGrid()),
              ),
            ),
          ),
        );
      },
    );

    if (!widget.showContainer) return body;

    if (widget.collapsible) {
      return SoftSaaSPanel.expandable(
        title: 'Live Preview',
        subtitle: 'Bidirectional — edit here or in the panel',
        expandBody: widget.expandBody,
        defaultOpen: widget.expanded,
        onToggleOpen: (_) => widget.onToggle?.call(),
        child: body,
      );
    }

    return SoftSaaSPanel(
      title: 'Live Preview',
      subtitle: 'Bidirectional — edit here or in the panel',
      expandBody: widget.expandBody,
      child: body,
    );
  }

  // ── Group accessor helpers ─────────────────────────────────────────

  dynamic _groupGet(String group, String key) {
    final g = controller[group];
    if (g is Map) return g[key];
    return null;
  }

  void _groupSet(String group, String key, dynamic value) {
    final g = controller[group];
    final map = g is Map ? Map<String, dynamic>.from(g) : <String, dynamic>{};
    map[key] = value;
    controller[group] = map;
  }

  // ── Header strip ──────────────────────────────────────────────────

  Widget _header() {
    return ListenableBuilder(
      listenable: Listenable.merge([
        controller.notifierFor('cta'),
        controller.notifierFor('appearance'),
        controller.notifierFor('schedule'),
      ]),
      builder: (context, _) {
        final title = (_groupGet('cta', 'title') ?? 'Checkout CTA').toString();
        final variant = (_groupGet('cta', 'variant') ?? 'primary').toString();
        final themeColor =
            _parseColor(_groupGet('appearance', 'themeColor')) ??
            SoftSaaSTokens.primaryColor(brightness);
        final iconName = _groupGet('appearance', 'iconName')?.toString();
        final rollout = _groupGet('schedule', 'rollout') == true;
        final language = _groupGet('schedule', 'language')?.toString();
        final expiresAt = _groupGet('schedule', 'expiresAt')?.toString();
        return Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: SoftSaaSTokens.primaryBorder(brightness),
              ),
            ),
          ),
          child: Row(
            children: [
              _brandIcon(color: themeColor, iconName: iconName),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: SoftSaaSTokens.primaryText(brightness),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Wrap(
                      spacing: 4,
                      runSpacing: 3,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Feature block',
                          style: TextStyle(
                            fontSize: 10,
                            color: SoftSaaSTokens.tertiaryText(brightness),
                          ),
                        ),
                        Text(
                          '·',
                          style: TextStyle(
                            fontSize: 10,
                            color: SoftSaaSTokens.tertiaryText(brightness),
                          ),
                        ),
                        _variantPill(variant, color: themeColor),
                        if (language != null && language.isNotEmpty)
                          _langPill(language),
                        if (expiresAt != null && expiresAt.isNotEmpty)
                          _expiryPill(expiresAt),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _liveChip(rollout),
            ],
          ),
        );
      },
    );
  }

  Widget _liveChip(bool live) {
    final color = live
        ? const Color(0xFF10B981)
        : SoftSaaSTokens.warningColor(brightness);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: live
            ? const Color(0xFF10B981).withValues(alpha: 0.10)
            : SoftSaaSTokens.warningColor(brightness).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: live
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            live ? 'Live' : 'Paused',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _brandIcon({Color? color, String? iconName}) {
    final c = color ?? SoftSaaSTokens.primaryColor(brightness);
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c.withValues(alpha: 0.22), c.withValues(alpha: 0.08)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withValues(alpha: 0.25)),
      ),
      child: Icon(LucideIcons.flag, size: 16, color: c),
    );
  }

  Widget _variantPill(String variant, {Color? color}) {
    final c = color ?? SoftSaaSTokens.primaryColor(brightness);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: SoftSaaSTokens.tertiaryBackground(brightness),
        borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusFull),
        border: Border.all(color: SoftSaaSTokens.primaryBorder(brightness)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.sparkles, size: 9, color: c),
          const SizedBox(width: 3),
          Text(
            variant,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: SoftSaaSTokens.secondaryText(brightness),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _langPill(String language) {
    final code = language.length > 2
        ? language.substring(0, 2).toUpperCase()
        : language.toUpperCase();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: SoftSaaSTokens.tertiaryBackground(brightness),
        borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusFull),
        border: Border.all(color: SoftSaaSTokens.primaryBorder(brightness)),
      ),
      child: Text(
        code,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: SoftSaaSTokens.secondaryText(brightness),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _expiryPill(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return const SizedBox.shrink();
    final expired = date.isBefore(DateTime.now());
    final color = expired
        ? const Color(0xFFEF4444)
        : SoftSaaSTokens.tertiaryText(brightness);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: expired
            ? const Color(0xFFEF4444).withValues(alpha: 0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Text(
        '${date.month}/${date.day}/${date.year}',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // ── Bento grid ────────────────────────────────────────────────────

  Widget _bentoGrid() {
    return ListenableBuilder(
      listenable: controller.notifierFor('targeting'),
      builder: (context, _) {
        final tags = _asStringList(_groupGet('targeting', 'tags'));
        final audiences = _asStringList(_groupGet('targeting', 'audiences'));
        final items = _carouselItems(tags: tags, audiences: audiences);

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
            final threshold = 80.0;
            final shouldGoNext = velocity < -120 || _dragOffset < -threshold;
            final shouldGoPrevious = velocity > 120 || _dragOffset > threshold;
            if (shouldGoNext) {
              _selectCarouselIndex(
                math.min(_activeIndex + 1, items.length - 1),
              );
            } else if (shouldGoPrevious) {
              _selectCarouselIndex(math.max(_activeIndex - 1, 0));
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
                            _positionedCarouselItem(
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
                          child: _carouselArrow(
                            icon: LucideIcons.chevron_left,
                            enabled: _activeIndex > 0,
                            onPressed: () =>
                                _selectCarouselIndex(_activeIndex - 1),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: _carouselArrow(
                            icon: LucideIcons.chevron_right,
                            enabled: _activeIndex < items.length - 1,
                            onPressed: () =>
                                _selectCarouselIndex(_activeIndex + 1),
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
      },
    );
  }

  Widget _positionedCarouselItem({
    required _PreviewCarouselItem item,
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
              child: Transform.scale(
                scale: scale,
                child: _carouselCard(item, index),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _carouselArrow({
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
                    ? SoftSaaSTokens.secondaryText(brightness)
                    : SoftSaaSTokens.tertiaryText(brightness),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fullFeatureBlockCard({
    required List<String> tags,
    required List<String> audiences,
  }) {
    return ListenableBuilder(
      listenable: controller.notifierFor('appearance'),
      builder: (context, _) {
        final layout = _groupGet('appearance', 'layout');
        final layoutMap = layout is Map
            ? Map<String, dynamic>.from(layout)
            : <String, dynamic>{};
        final radius = (_toDouble(layoutMap['radius']) ?? 14)
            .clamp(0, 40)
            .toDouble();
        final showShadow = layoutMap['showShadow'] != false;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: SoftSaaSTokens.primaryBorder(brightness)),
            boxShadow: showShadow
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.16),
                      blurRadius: 30,
                      offset: const Offset(0, 16),
                      spreadRadius: -10,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                child: _allBentoGrid(tags: tags, audiences: audiences),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _allBentoGrid({
    required List<String> tags,
    required List<String> audiences,
  }) {
    return Column(
      children: [
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 3, child: _ctaTile()),
              const SizedBox(width: 8),
              Expanded(flex: 2, child: _reachTile()),
            ],
          ),
        ),
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 2, child: _audienceTile(audiences: audiences)),
              const SizedBox(width: 8),
              Expanded(flex: 3, child: _conversionTile()),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _appearanceTile(),
                  const SizedBox(height: 8),
                  _rolloutPercentTile(),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(flex: 2, child: _activityTile()),
          ],
        ),
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 2, child: _tagsTile(tags: tags)),
              const SizedBox(width: 8),
              Expanded(flex: 3, child: _childTile()),
            ],
          ),
        ),
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 3, child: _frameTile()),
              const SizedBox(width: 8),
              Expanded(flex: 2, child: _metaTile()),
            ],
          ),
        ),
      ],
    );
  }

  List<_PreviewCarouselItem> _carouselItems({
    required List<String> tags,
    required List<String> audiences,
  }) {
    return [
      _PreviewCarouselItem(
        'All previews',
        null,
        _fullFeatureBlockCard(tags: tags, audiences: audiences),
        width: 520,
        height: 620,
      ),
      _PreviewCarouselItem('Live CTA', 'cta', _ctaTile()),
      _PreviewCarouselItem('Reach', 'reach', _reachTile()),
      _PreviewCarouselItem(
        'Audience',
        'audience',
        _audienceTile(audiences: audiences),
      ),
      _PreviewCarouselItem('Conversion', 'conversion', _conversionTile()),
      _PreviewCarouselItem('Appearance', 'appearance', _appearanceTile()),
      _PreviewCarouselItem(
        'Rollout %',
        'rolloutPercentage',
        _rolloutPercentTile(),
      ),
      _PreviewCarouselItem('Rollout', 'rollout', _activityTile()),
      _PreviewCarouselItem('Tags', 'tags', _tagsTile(tags: tags)),
      _PreviewCarouselItem('Child slot', 'child', _childTile()),
      _PreviewCarouselItem('Frame', 'frame', _frameTile()),
      _PreviewCarouselItem('Metadata', 'metadata', _metaTile()),
      _PreviewCarouselItem('Layout Showcase', 'showcase', _showcaseTile()),
    ];
  }

  int _indexForProperty(String? propertyName) {
    if (propertyName == null) return 0;
    final items = _carouselItems(tags: const [], audiences: const []);
    final index = items.indexWhere((item) => item.propertyName == propertyName);
    return index < 0 ? 0 : index;
  }

  void _selectCarouselIndex(int index) {
    final items = _carouselItems(tags: const [], audiences: const []);
    if (index < 0 || index >= items.length) return;

    final previousIndex = _activeIndex;
    final continuityOffset =
        _dragOffset + ((index - previousIndex) * _lastItemSpacing);

    _snapController.stop();
    _snapOffsetAnimation = null;
    setState(() {
      _activeIndex = index;
      _dragOffset = continuityOffset;
    });
    widget.onPropertySelected?.call(items[index].propertyName);
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

  Widget _carouselCard(_PreviewCarouselItem item, int index) {
    final active = index == _activeIndex;
    final compact = MediaQuery.sizeOf(context).width < 760;
    final cardScale = compact ? 0.60 : 1.0;
    final cardWidth = item.width * cardScale;
    final cardHeight = item.height == null ? null : item.height! * cardScale;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _selectCarouselIndex(index),
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
                    ? SoftSaaSTokens.primaryText(brightness)
                    : SoftSaaSTokens.tertiaryText(brightness),
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

  // ── Tile shell ────────────────────────────────────────────────────

  Widget _tile({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(12),
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: -10,
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }

  Widget _tileLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 11, color: SoftSaaSTokens.tertiaryText(brightness)),
        const SizedBox(width: 5),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: SoftSaaSTokens.tertiaryText(brightness),
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  // ── Individual tiles ──────────────────────────────────────────────

  Widget _ctaTile() {
    return _tile(
      child: ListenableBuilder(
        listenable: controller.notifierFor('cta'),
        builder: (context, _) {
          final title = (_groupGet('cta', 'title') ?? 'Checkout CTA')
              .toString();
          final variant = (_groupGet('cta', 'variant') ?? 'primary').toString();
          final fontSize = (_toDouble(_groupGet('cta', 'fontSize')) ?? 16)
              .clamp(8.0, 72.0);
          final lineHeight = _toDouble(_groupGet('cta', 'lineHeight')) ?? 1.2;
          final v = switch (variant) {
            'secondary' => SoftSaaSButtonVariant.secondary,
            'ghost' => SoftSaaSButtonVariant.ghost,
            _ => SoftSaaSButtonVariant.primary,
          };
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _tileLabel('Live CTA', LucideIcons.square_mouse_pointer),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: SoftSaaSButton(
                  variant: v,
                  size: SoftSaaSButtonSize.large,
                  onPressed: () {},
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: fontSize.clamp(10, 20),
                      height: lineHeight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    LucideIcons.type,
                    size: 12,
                    color: SoftSaaSTokens.tertiaryText(brightness),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${fontSize.toStringAsFixed(0)}px · $variant',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: SoftSaaSTokens.secondaryText(brightness),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _reachTile() {
    return _tile(
      child: ListenableBuilder(
        listenable: controller.notifierFor('reach'),
        builder: (context, _) {
          final users = (_toDouble(_groupGet('reach', 'users')) ?? 0).round();
          final window = (_groupGet('reach', 'window') ?? '7d').toString();
          final rawTrend = _groupGet('reach', 'trend');
          final trend = rawTrend is List
              ? rawTrend
                    .map(_toDouble)
                    .whereType<double>()
                    .toList(growable: false)
              : const <double>[];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _tileLabel('Reach', LucideIcons.eye),
              const SizedBox(height: 8),
              Text(
                users.toString().replaceAllMapped(
                  RegExp(r'\B(?=(\d{3})+(?!\d))'),
                  (_) => ',',
                ),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: SoftSaaSTokens.primaryText(brightness),
                  height: 1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'users · $window',
                style: TextStyle(
                  fontSize: 10,
                  color: SoftSaaSTokens.tertiaryText(brightness),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 24,
                width: double.infinity,
                child: _Sparkline(
                  data: trend.isEmpty ? const [0, 0] : trend,
                  color: SoftSaaSTokens.primaryColor(brightness),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _audienceTile({required List<String> audiences}) {
    const allSegments = <String, ({String label, int reach, IconData icon})>{
      'consumer': (label: 'Consumer', reach: 2842, icon: LucideIcons.user),
      'power_user': (label: 'Power User', reach: 914, icon: LucideIcons.zap),
      'enterprise': (
        label: 'Enterprise',
        reach: 312,
        icon: LucideIcons.building_2,
      ),
    };
    final selectedSet = audiences.toSet();
    final entries = allSegments.entries.toList();
    return _tile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _tileLabel('Audience', LucideIcons.users),
              const Spacer(),
              Text(
                '${selectedSet.length}/${entries.length}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: SoftSaaSTokens.tertiaryText(brightness),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...entries.map((e) {
            final active = selectedSet.contains(e.key);
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(
                    e.value.icon,
                    size: 12,
                    color: active
                        ? SoftSaaSTokens.primaryColor(brightness)
                        : SoftSaaSTokens.tertiaryText(brightness),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      e.value.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: active
                            ? SoftSaaSTokens.primaryText(brightness)
                            : SoftSaaSTokens.tertiaryText(brightness),
                      ),
                    ),
                  ),
                  Text(
                    _formatReach(e.value.reach),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: active
                          ? SoftSaaSTokens.secondaryText(brightness)
                          : SoftSaaSTokens.tertiaryText(brightness),
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active
                          ? SoftSaaSTokens.primaryColor(brightness)
                          : SoftSaaSTokens.primaryBorder(brightness),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _appearanceTile() {
    return _tile(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: ListenableBuilder(
        listenable: controller.notifierFor('appearance'),
        builder: (context, _) {
          final layout = _groupGet('appearance', 'layout');
          final layoutMap = layout is Map
              ? Map<String, dynamic>.from(layout)
              : <String, dynamic>{};
          final padding = (_toDouble(layoutMap['padding']) ?? 12)
              .clamp(0, 40)
              .toDouble();
          final radius = (_toDouble(layoutMap['radius']) ?? 8)
              .clamp(0, 40)
              .toDouble();
          final showShadow = layoutMap['showShadow'] != false;
          final animDuration =
              (_toDouble(_groupGet('appearance', 'animDuration')) ?? 220)
                  .round()
                  .clamp(0, 2000);
          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _tileLabel('Appearance', LucideIcons.layout_panel_top),
                    const SizedBox(height: 8),
                    _appearanceMetric(
                      'Padding',
                      '${padding.toStringAsFixed(0)}px',
                    ),
                    const SizedBox(height: 3),
                    _appearanceMetric(
                      'Radius',
                      '${radius.toStringAsFixed(0)}px',
                    ),
                    const SizedBox(height: 3),
                    _appearanceMetric('Shadow', showShadow ? 'On' : 'Off'),
                    const SizedBox(height: 3),
                    _appearanceMetric('Anim', '${animDuration}ms'),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 120,
                height: 68,
                child: Center(
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: animDuration),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.all(padding.clamp(0, 20)),
                    decoration: BoxDecoration(
                      color: SoftSaaSTokens.primaryBackground(brightness),
                      borderRadius: BorderRadius.circular(radius),
                      border: Border.all(
                        color: SoftSaaSTokens.primaryBorder(brightness),
                      ),
                      boxShadow: showShadow
                          ? [
                              BoxShadow(
                                color: brightness == Brightness.dark
                                    ? Colors.black.withValues(alpha: 0.35)
                                    : Colors.black.withValues(alpha: 0.10),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                                spreadRadius: -4,
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 6,
                          width: 38,
                          decoration: BoxDecoration(
                            color: SoftSaaSTokens.primaryColor(
                              brightness,
                            ).withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          height: 4,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: SoftSaaSTokens.primaryBorder(brightness),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          height: 4,
                          width: 56,
                          decoration: BoxDecoration(
                            color: SoftSaaSTokens.primaryBorder(brightness),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _appearanceMetric(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: SoftSaaSTokens.tertiaryText(brightness),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: SoftSaaSTokens.primaryText(brightness),
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _rolloutPercentTile() {
    return _tile(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: ListenableBuilder(
        listenable: controller.notifierFor('schedule'),
        builder: (context, _) {
          final pct =
              (_toDouble(_groupGet('schedule', 'rolloutPercentage')) ?? 0)
                  .clamp(0.0, 100.0);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _tileLabel('Rollout %', LucideIcons.percent),
                  const Spacer(),
                  Text(
                    '${pct.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: SoftSaaSTokens.primaryText(brightness),
                      height: 1,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              SoftSaaSSlider(
                value: pct,
                min: 0,
                max: 100,
                showValue: false,
                showMinMaxLabels: false,
                isDarkMode: brightness == Brightness.dark,
                onChanged: (next) =>
                    _groupSet('schedule', 'rolloutPercentage', next),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _formatReach(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(n >= 10000 ? 0 : 1)}K';
    return n.toString();
  }

  Widget _conversionTile() {
    return _tile(
      child: ListenableBuilder(
        listenable: controller.notifierFor('conversion'),
        builder: (context, _) {
          final rate = _toDouble(_groupGet('conversion', 'rate')) ?? 0;
          final unit = (_groupGet('conversion', 'unit') ?? 'percent')
              .toString();
          final delta = _toDouble(_groupGet('conversion', 'delta')) ?? 0;
          final comparison = (_groupGet('conversion', 'comparison') ?? '')
              .toString();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _tileLabel('Conversion', LucideIcons.trending_up),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    rate.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: SoftSaaSTokens.primaryText(brightness),
                      height: 1,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: 2),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      unit == 'percent' ? '%' : unit,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: SoftSaaSTokens.secondaryText(brightness),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    delta >= 0
                        ? LucideIcons.arrow_up_right
                        : LucideIcons.arrow_down_right,
                    size: 11,
                    color: delta >= 0
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: delta >= 0
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    comparison,
                    style: TextStyle(
                      fontSize: 10,
                      color: SoftSaaSTokens.tertiaryText(brightness),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 16,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(12, (i) {
                    const heights = <double>[
                      4,
                      6,
                      5,
                      8,
                      7,
                      10,
                      9,
                      12,
                      11,
                      13,
                      12,
                      14,
                    ];
                    return Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: Container(
                            height: heights[i],
                            decoration: BoxDecoration(
                              color: SoftSaaSTokens.primaryColor(
                                brightness,
                              ).withValues(alpha: 0.4 + (i / 24)),
                              borderRadius: BorderRadius.circular(1.5),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _showcaseTile() {
    return _tile(
      child: ListenableBuilder(
        listenable: controller.notifierFor('showcase'),
        builder: (context, _) {
          final main = (_groupGet('showcase', 'mainAxisAlignment') ?? 'start')
              .toString();
          final cross =
              (_groupGet('showcase', 'crossAxisAlignment') ?? 'center')
                  .toString();
          final rawChildren = _groupGet('showcase', 'children');
          final childConfigs = rawChildren is List
              ? rawChildren
                    .whereType<Map>()
                    .map((child) {
                      return Map<String, dynamic>.from(child);
                    })
                    .toList(growable: false)
              : const <Map<String, dynamic>>[];
          final rawAttributes = _groupGet('showcase', 'attributes');
          final attributes = rawAttributes is Map
              ? Map<String, dynamic>.from(rawAttributes)
              : const <String, dynamic>{};
          final mainAlignment = switch (main) {
            'center' => MainAxisAlignment.center,
            'end' => MainAxisAlignment.end,
            'spaceBetween' || 'between' => MainAxisAlignment.spaceBetween,
            'spaceAround' || 'around' => MainAxisAlignment.spaceAround,
            'spaceEvenly' || 'evenly' => MainAxisAlignment.spaceEvenly,
            _ => MainAxisAlignment.start,
          };
          final crossAlignment = switch (cross) {
            'start' => CrossAxisAlignment.start,
            'end' => CrossAxisAlignment.end,
            'stretch' => CrossAxisAlignment.stretch,
            _ => CrossAxisAlignment.center,
          };

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _tileLabel('Layout Showcase', LucideIcons.panels_top_left),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: 96,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: SoftSaaSTokens.tertiaryBackground(brightness),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: SoftSaaSTokens.primaryBorder(brightness),
                  ),
                ),
                child: childConfigs.isEmpty
                    ? _emptyHint(LucideIcons.box, 'No child components')
                    : Row(
                        mainAxisAlignment: mainAlignment,
                        crossAxisAlignment: crossAlignment,
                        children: childConfigs
                            .take(4)
                            .map((child) {
                              final id = child['componentId']?.toString();
                              final rawConfig = child['config'];
                              final config = rawConfig is Map
                                  ? Map<String, dynamic>.from(rawConfig)
                                  : <String, dynamic>{};
                              return ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 132,
                                  maxHeight: 72,
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: id == null
                                      ? _emptyHint(
                                          LucideIcons.box,
                                          'Unconfigured',
                                        )
                                      : _renderComponent(id, config),
                                ),
                              );
                            })
                            .toList(growable: false),
                      ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    LucideIcons.list_tree,
                    size: 11,
                    color: SoftSaaSTokens.tertiaryText(brightness),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Attributes',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: SoftSaaSTokens.secondaryText(brightness),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (attributes.isEmpty)
                Text(
                  'No attributes',
                  style: TextStyle(
                    fontSize: 10,
                    color: SoftSaaSTokens.tertiaryText(brightness),
                  ),
                )
              else
                Wrap(
                  spacing: 6,
                  runSpacing: 5,
                  children: attributes.entries
                      .map((entry) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: SoftSaaSTokens.tertiaryBackground(
                              brightness,
                            ),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: SoftSaaSTokens.primaryBorder(brightness),
                            ),
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 9,
                                color: SoftSaaSTokens.tertiaryText(brightness),
                              ),
                              children: [
                                TextSpan(
                                  text: '${entry.key}: ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(text: entry.value.toString()),
                              ],
                            ),
                          ),
                        );
                      })
                      .toList(growable: false),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _tagsTile({required List<String> tags}) {
    return _tile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _tileLabel('Tags', LucideIcons.tag),
              const Spacer(),
              Text(
                tags.length.toString(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: SoftSaaSTokens.tertiaryText(brightness),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (tags.isEmpty)
            _emptyHint(LucideIcons.tag, 'No tags assigned')
          else
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: tags
                  .map(
                    (t) => SoftSaaSBadge(
                      label: t,
                      variant: SoftSaaSBadgeVariant.primary,
                      size: SoftSaaSBadgeSize.small,
                      shape: SoftSaaSBadgeShape.pill,
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _emptyHint(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: SoftSaaSTokens.tertiaryText(brightness)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: SoftSaaSTokens.tertiaryText(brightness),
            ),
          ),
        ),
      ],
    );
  }

  Widget _activityTile() {
    return _tile(
      child: ListenableBuilder(
        listenable: controller.notifierFor('schedule'),
        builder: (context, _) {
          final rollout = _groupGet('schedule', 'rollout') == true;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _tileLabel('Rollout', LucideIcons.rocket),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      rollout ? 'Live' : 'Paused',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: rollout
                            ? const Color(0xFF10B981)
                            : SoftSaaSTokens.warningColor(brightness),
                      ),
                    ),
                  ),
                  SoftSaaSSwitch(
                    value: rollout,
                    size: SoftSaaSCheckboxSize.small,
                    onChanged: (next) => _groupSet('schedule', 'rollout', next),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Divider(
                  height: 1,
                  color: SoftSaaSTokens.primaryBorder(brightness),
                ),
              ),
              _activityRow(
                icon: rollout ? LucideIcons.rocket : LucideIcons.circle_pause,
                color: rollout
                    ? const Color(0xFF10B981)
                    : SoftSaaSTokens.warningColor(brightness),
                title: rollout ? 'Deployed' : 'Paused',
                time: '2h ago',
              ),
              const SizedBox(height: 8),
              _activityRow(
                icon: LucideIcons.git_commit_horizontal,
                color: SoftSaaSTokens.primaryColor(brightness),
                title: 'Variant synced',
                time: '6h ago',
              ),
              const SizedBox(height: 8),
              _activityRow(
                icon: LucideIcons.users,
                color: SoftSaaSTokens.tertiaryText(brightness),
                title: 'Audience updated',
                time: '1d ago',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _activityRow({
    required IconData icon,
    required Color color,
    required String title,
    required String time,
  }) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.14),
          ),
          child: Icon(icon, size: 10, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: SoftSaaSTokens.primaryText(brightness),
            ),
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontSize: 10,
            color: SoftSaaSTokens.tertiaryText(brightness),
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _childTile() {
    return ListenableBuilder(
      listenable: controller.notifierFor('slot'),
      builder: (context, _) {
        final child = _groupGet('slot', 'child');
        final isMap = child is Map;
        final componentId = isMap ? child['componentId'] as String? : null;
        final config = isMap && child['config'] is Map
            ? Map<String, dynamic>.from(child['config'] as Map)
            : <String, dynamic>{};
        return _tile(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _tileLabel('Child slot', LucideIcons.box),
                  const Spacer(),
                  if (componentId != null)
                    Text(
                      componentId.replaceAll('__builtin_', ''),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: SoftSaaSTokens.tertiaryText(brightness),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              if (componentId == null)
                _emptyHint(LucideIcons.box, 'No component assigned')
              else
                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _renderComponent(componentId, config),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _frameTile() {
    return ListenableBuilder(
      listenable: controller.notifierFor('slot'),
      builder: (context, _) {
        final frameSize = _groupGet('slot', 'frameSize');
        final sizeConstraints = _groupGet('slot', 'sizeConstraints');
        final w =
            _toDouble(frameSize is Map ? frameSize['width'] : null) ?? 240.0;
        final h =
            _toDouble(frameSize is Map ? frameSize['height'] : null) ?? 120.0;
        final maxW =
            _toDouble(
              sizeConstraints is Map ? sizeConstraints['maxWidth'] : null,
            ) ??
            320.0;
        final maxH =
            _toDouble(
              sizeConstraints is Map ? sizeConstraints['maxHeight'] : null,
            ) ??
            200.0;
        return _tile(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _tileLabel('Frame', LucideIcons.frame),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: CustomPaint(
                  painter: _FrameBoxPainter(
                    w: w,
                    h: h,
                    maxW: maxW,
                    maxH: maxH,
                    color: SoftSaaSTokens.primaryColor(brightness),
                    borderColor: SoftSaaSTokens.primaryBorder(brightness),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _frameMetric('W', '${w.toStringAsFixed(0)}px'),
                  const SizedBox(width: 12),
                  _frameMetric('H', '${h.toStringAsFixed(0)}px'),
                  const Spacer(),
                  _frameMetric(
                    'Max',
                    '${maxW.toStringAsFixed(0)}×${maxH.toStringAsFixed(0)}',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _frameMetric(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: SoftSaaSTokens.tertiaryText(brightness),
          ),
        ),
        const SizedBox(width: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: SoftSaaSTokens.primaryText(brightness),
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _metaTile() {
    return ListenableBuilder(
      listenable: controller.notifierFor('metadata'),
      builder: (context, _) {
        final meta = controller['metadata'];
        final source = (meta is Map ? meta['source'] : null)?.toString() ?? '—';
        final version = meta is Map ? meta['version']?.toString() : null;
        return _tile(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _tileLabel('Metadata', LucideIcons.database),
              const SizedBox(height: 10),
              Wrap(
                spacing: 5,
                runSpacing: 5,
                children: [
                  _metaBadge(source, SoftSaaSTokens.primaryColor(brightness)),
                  if (version != null)
                    _metaBadge(
                      'v$version',
                      SoftSaaSTokens.tertiaryText(brightness),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _metaBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // ── Component renderers ───────────────────────────────────────────

  Widget _renderComponent(String id, Map<String, dynamic> config) {
    return switch (id) {
      'custom_button' => _renderButton(config),
      'avatar' => _renderAvatar(config),
      'badge' => _renderBadge(config),
      '__builtin_container' => _renderBuiltinContainer(config),
      '__builtin_text' => _renderBuiltinText(config),
      '__builtin_sizedbox' => _renderBuiltinSizedBox(config),
      _ => Text(
        '$id (no preview)',
        key: ValueKey(id),
        style: TextStyle(
          fontSize: 11,
          color: SoftSaaSTokens.tertiaryText(brightness),
        ),
      ),
    };
  }

  Widget _renderBuiltinContainer(Map<String, dynamic> config) {
    final color =
        _parseColor(config['color']) ?? SoftSaaSTokens.primaryColor(brightness);
    final width = (_toDouble(config['width']) ?? 80).clamp(8, 320).toDouble();
    final height = (_toDouble(config['height']) ?? 80).clamp(8, 320).toDouble();
    final radius = (_toDouble(config['borderRadius']) ?? 8)
        .clamp(0, 80)
        .toDouble();
    final padding = (_toDouble(config['padding']) ?? 0).clamp(0, 40).toDouble();
    return AnimatedContainer(
      key: const ValueKey('__builtin_container'),
      duration: const Duration(milliseconds: 200),
      width: width,
      height: height,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Center(
        child: Text(
          '${width.toInt()}×${height.toInt()}',
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white,
            shadows: [Shadow(blurRadius: 2, color: Colors.black26)],
          ),
        ),
      ),
    );
  }

  Widget _renderBuiltinText(Map<String, dynamic> config) {
    final text = (config['text'] ?? 'Hello, world!').toString();
    final fontSize = (_toDouble(config['fontSize']) ?? 16)
        .clamp(8, 72)
        .toDouble();
    final color =
        _parseColor(config['color']) ?? SoftSaaSTokens.primaryText(brightness);
    final weight = switch ((config['fontWeight'] ?? 'normal').toString()) {
      'medium' => FontWeight.w500,
      'semibold' => FontWeight.w600,
      'bold' => FontWeight.w700,
      _ => FontWeight.w400,
    };
    return Text(
      text,
      key: const ValueKey('__builtin_text'),
      style: TextStyle(fontSize: fontSize, fontWeight: weight, color: color),
    );
  }

  Widget _renderBuiltinSizedBox(Map<String, dynamic> config) {
    final width = (_toDouble(config['width']) ?? 48).clamp(0, 320).toDouble();
    final height = (_toDouble(config['height']) ?? 48).clamp(0, 320).toDouble();
    return AnimatedContainer(
      key: const ValueKey('__builtin_sizedbox'),
      duration: const Duration(milliseconds: 200),
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: SoftSaaSTokens.primaryBorder(brightness),
          width: 1,
        ),
        color: SoftSaaSTokens.tertiaryBackground(brightness),
      ),
      child: Center(
        child: Text(
          '${width.toInt()}×${height.toInt()}',
          style: TextStyle(
            fontSize: 10,
            color: SoftSaaSTokens.tertiaryText(brightness),
          ),
        ),
      ),
    );
  }

  Widget _renderButton(Map<String, dynamic> config) {
    final label = (config['label'] ?? 'Click Me').toString();
    final variant = (config['variant'] ?? 'primary').toString();
    final fs = _toDouble(config['fontSize']) ?? 14;
    final enabled = config['enabled'] != false;
    final v = switch (variant) {
      'secondary' => SoftSaaSButtonVariant.secondary,
      'ghost' => SoftSaaSButtonVariant.ghost,
      _ => SoftSaaSButtonVariant.primary,
    };
    return SoftSaaSButton(
      key: const ValueKey('custom_button'),
      variant: v,
      size: SoftSaaSButtonSize.medium,
      onPressed: enabled ? () {} : null,
      child: Text(
        label,
        style: TextStyle(fontSize: fs, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _renderAvatar(Map<String, dynamic> config) {
    final initials = (config['initials'] ?? 'AB').toString();
    final size = (_toDouble(config['size']) ?? 40).clamp(16, 96).toDouble();
    final showStatus = config['showStatus'] == true;
    final statusColor = _parseColor(config['statusColor']) ?? Colors.green;
    return Stack(
      key: const ValueKey('avatar'),
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: SoftSaaSTokens.primaryColor(
              brightness,
            ).withValues(alpha: 0.15),
            border: Border.all(
              color: SoftSaaSTokens.primaryColor(
                brightness,
              ).withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              initials,
              style: TextStyle(
                fontSize: size * 0.38,
                fontWeight: FontWeight.w700,
                color: SoftSaaSTokens.primaryColor(brightness),
              ),
            ),
          ),
        ),
        if (showStatus)
          Positioned(
            right: 0,
            bottom: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: size * 0.28,
              height: size * 0.28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: statusColor,
                border: Border.all(
                  color: SoftSaaSTokens.primaryBackground(brightness),
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _renderBadge(Map<String, dynamic> config) {
    final text = (config['text'] ?? 'Active').toString();
    final bgColor = _parseColor(config['color']) ?? Colors.blue;
    return Container(
      key: const ValueKey('badge'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusFull),
        border: Border.all(color: bgColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: bgColor,
        ),
      ),
    );
  }

  // ── Static helpers ────────────────────────────────────────────────

  static List<String> _asStringList(dynamic v) {
    if (v is List) return v.map((e) => e.toString()).toList();
    return const [];
  }

  static Color? _parseColor(dynamic value) {
    if (value is Color) return value;
    if (value is String) {
      final hex = value.replaceAll('#', '');
      if (hex.length == 6) {
        final v = int.tryParse(hex, radix: 16);
        if (v != null) return Color(0xFF000000 | v);
      }
      if (hex.length == 8) {
        final v = int.tryParse(hex, radix: 16);
        if (v != null) return Color(v);
      }
    }
    return null;
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

// ── Sparkline painter ───────────────────────────────────────────────

class _PreviewCarouselItem {
  const _PreviewCarouselItem(
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

class _Sparkline extends StatelessWidget {
  const _Sparkline({required this.data, required this.color});

  final List<double> data;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SparklinePainter(data: data, color: color),
      size: Size.infinite,
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.data, required this.color});

  final List<double> data;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final maxV = data.reduce((a, b) => a > b ? a : b);
    final minV = data.reduce((a, b) => a < b ? a : b);
    final range = (maxV - minV).abs() < 1e-6 ? 1.0 : (maxV - minV);
    final dx = size.width / (data.length - 1);

    final path = Path();
    final fill = Path();
    for (var i = 0; i < data.length; i++) {
      final x = dx * i;
      final y = size.height - ((data[i] - minV) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
        fill.moveTo(x, size.height);
        fill.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fill.lineTo(x, y);
      }
    }
    fill.lineTo(size.width, size.height);
    fill.close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0.0)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.data != data || old.color != color;
}

// ── Frame box painter ───────────────────────────────────────────────

class _FrameBoxPainter extends CustomPainter {
  _FrameBoxPainter({
    required this.w,
    required this.h,
    required this.maxW,
    required this.maxH,
    required this.color,
    required this.borderColor,
  });

  final double w;
  final double h;
  final double maxW;
  final double maxH;
  final Color color;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = maxW > 0 ? (w / maxW).clamp(0.1, 1.0) : 0.5;
    final scaleY = maxH > 0 ? (h / maxH).clamp(0.1, 1.0) : 0.5;
    final boxW = size.width * scaleX * 0.85;
    final boxH = size.height * scaleY * 0.85;
    final left = (size.width - boxW) / 2;
    final top = (size.height - boxH) / 2;
    final rect = Rect.fromLTWH(left, top, boxW, boxH);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = borderColor.withValues(alpha: 0.15),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      Paint()
        ..color = color.withValues(alpha: 0.12)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      Paint()
        ..color = color.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final cornerSize = math.min(8.0, boxW / 4);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.square;

    canvas.drawLine(Offset(left, top + cornerSize), Offset(left, top), paint);
    canvas.drawLine(Offset(left, top), Offset(left + cornerSize, top), paint);
    canvas.drawLine(
      Offset(left + boxW - cornerSize, top),
      Offset(left + boxW, top),
      paint,
    );
    canvas.drawLine(
      Offset(left + boxW, top),
      Offset(left + boxW, top + cornerSize),
      paint,
    );
    canvas.drawLine(
      Offset(left, top + boxH - cornerSize),
      Offset(left, top + boxH),
      paint,
    );
    canvas.drawLine(
      Offset(left, top + boxH),
      Offset(left + cornerSize, top + boxH),
      paint,
    );
    canvas.drawLine(
      Offset(left + boxW - cornerSize, top + boxH),
      Offset(left + boxW, top + boxH),
      paint,
    );
    canvas.drawLine(
      Offset(left + boxW, top + boxH),
      Offset(left + boxW, top + boxH - cornerSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(_FrameBoxPainter old) =>
      old.w != w || old.h != h || old.maxW != maxW || old.maxH != maxH;
}
