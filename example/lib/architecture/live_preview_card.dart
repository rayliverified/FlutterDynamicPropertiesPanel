import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

import 'preview_carousel.dart';
import 'tiles/tiles.dart';

/// Example-app level: the storyboard-style preview host.
///
/// This is tooling chrome, not production UI. It shows the real
/// [FeatureBlock] component (passed in as [featureBlock], keyed from the
/// storyboard registry by the app) as the "All previews" card, plus one
/// standalone card per tile so each can be staged and inspected in
/// isolation.
///
/// The standalone cards are rendered from the grouped [values] payload —
/// the same shape the properties panel edits — and report interactions
/// through [onValuesChanged]. The host itself is stateless: the app owns
/// the values (controller) and the FeatureBlock owns its own State.
class LivePreviewCard extends StatelessWidget {
  const LivePreviewCard({
    super.key,
    required this.values,
    required this.featureBlock,
    required this.brightness,
    this.expandBody = true,
    this.collapsible = false,
    this.expanded = true,
    this.onToggle,
    this.showContainer = true,
    this.selectedPropertyName,
    this.onPropertySelected,
    this.onValuesChanged,
  });

  /// Grouped values (panel/JSON shape) used to render the standalone cards.
  final Map<String, dynamic> values;

  /// The production component under test, constructed (and keyed) by the app.
  final Widget featureBlock;

  final Brightness brightness;
  final bool expandBody;
  final bool collapsible;
  final bool expanded;
  final VoidCallback? onToggle;
  final bool showContainer;

  /// Which carousel card is focused (semantic property name, null = all).
  final String? selectedPropertyName;
  final ValueChanged<String?>? onPropertySelected;

  /// Fired when the user interacts with a *standalone* card (slider,
  /// switch) — carries the full merged values payload.
  final ValueChanged<Map<String, dynamic>>? onValuesChanged;

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
                child: SizedBox(width: targetWidth, child: _carousel()),
              ),
            ),
          ),
        );
      },
    );

    if (!showContainer) return body;

    if (collapsible) {
      return SoftSaaSPanel.expandable(
        title: 'Live Preview',
        subtitle: 'Bidirectional — edit here or in the panel',
        expandBody: expandBody,
        defaultOpen: expanded,
        onToggleOpen: (_) => onToggle?.call(),
        child: body,
      );
    }

    return SoftSaaSPanel(
      title: 'Live Preview',
      subtitle: 'Bidirectional — edit here or in the panel',
      expandBody: expandBody,
      child: body,
    );
  }

  Widget _carousel() {
    final items = _carouselItems();
    var initialIndex = 0;
    if (selectedPropertyName != null) {
      final index = items.indexWhere(
        (item) => item.propertyName == selectedPropertyName,
      );
      if (index >= 0) initialIndex = index;
    }
    return PreviewCarousel(
      items: items,
      brightness: brightness,
      initialIndex: initialIndex,
      onItemSelected: (item) => onPropertySelected?.call(item.propertyName),
    );
  }

  List<PreviewCarouselItem> _carouselItems() {
    return [
      PreviewCarouselItem(
        'All previews',
        null,
        featureBlock,
        width: 520,
        height: 620,
      ),
      PreviewCarouselItem('Live CTA', 'cta', _ctaTile()),
      PreviewCarouselItem('Reach', 'reach', _reachTile()),
      PreviewCarouselItem('Audience', 'audience', _audienceTile()),
      PreviewCarouselItem('Conversion', 'conversion', _conversionTile()),
      PreviewCarouselItem('Appearance', 'appearance', _appearanceTile()),
      PreviewCarouselItem('Rollout %', 'rolloutPercentage', _rolloutTile()),
      PreviewCarouselItem('Rollout', 'rollout', _activityTile()),
      PreviewCarouselItem('Tags', 'tags', _tagsTile()),
      PreviewCarouselItem('Child slot', 'child', _childTile()),
      PreviewCarouselItem('Frame', 'frame', _frameTile()),
      PreviewCarouselItem('Metadata', 'metadata', _metaTile()),
      PreviewCarouselItem('Layout Showcase', 'showcase', _showcaseTile()),
    ];
  }

  // ── Values access (tooling side: grouped map, like the panel) ─────

  Map<String, dynamic> _group(String name) {
    final g = values[name];
    return g is Map ? Map<String, dynamic>.from(g) : <String, dynamic>{};
  }

  /// Merge a single key into its group and report the full payload upward.
  void _set(String group, String key, dynamic value) {
    final next = Map<String, dynamic>.from(values);
    final g = _group(group);
    g[key] = value;
    next[group] = g;
    onValuesChanged?.call(next);
  }

  // ── Standalone cards ──────────────────────────────────────────────

  Widget _ctaTile() {
    final g = _group('cta');
    return CtaTile(
      title: (g['title'] ?? 'Checkout CTA').toString(),
      variant: (g['variant'] ?? 'primary').toString(),
      fontSize: toDoubleOrNull(g['fontSize']) ?? 16,
      lineHeight: toDoubleOrNull(g['lineHeight']) ?? 1.2,
      brightness: brightness,
    );
  }

  Widget _reachTile() {
    final g = _group('reach');
    final trend = g['trend'];
    return ReachTile(
      users: toDoubleOrNull(g['users'])?.round() ?? 0,
      window: (g['window'] ?? '7d').toString(),
      trend: trend is List
          ? trend
                .map(toDoubleOrNull)
                .whereType<double>()
                .toList(growable: false)
          : const [],
      brightness: brightness,
    );
  }

  Widget _audienceTile() {
    return AudienceTile(
      audiences: asStringList(_group('targeting')['audiences']),
      brightness: brightness,
    );
  }

  Widget _conversionTile() {
    final g = _group('conversion');
    return ConversionTile(
      rate: toDoubleOrNull(g['rate']) ?? 0,
      unit: (g['unit'] ?? 'percent').toString(),
      delta: toDoubleOrNull(g['delta']) ?? 0,
      comparison: (g['comparison'] ?? '').toString(),
      brightness: brightness,
    );
  }

  Widget _appearanceTile() {
    final g = _group('appearance');
    final layout = g['layout'];
    final layoutMap = layout is Map
        ? Map<String, dynamic>.from(layout)
        : <String, dynamic>{};
    return AppearanceTile(
      layoutPadding: toDoubleOrNull(layoutMap['padding']) ?? 12,
      layoutRadius: toDoubleOrNull(layoutMap['radius']) ?? 8,
      showShadow: layoutMap['showShadow'] != false,
      animDurationMs: toDoubleOrNull(g['animDuration'])?.round() ?? 220,
      brightness: brightness,
    );
  }

  Widget _rolloutTile() {
    return RolloutPercentTile(
      percentage: toDoubleOrNull(_group('schedule')['rolloutPercentage']) ?? 0,
      brightness: brightness,
      onChanged: (next) => _set('schedule', 'rolloutPercentage', next),
    );
  }

  Widget _activityTile() {
    return ActivityTile(
      rollout: _group('schedule')['rollout'] == true,
      brightness: brightness,
      onRolloutChanged: (next) => _set('schedule', 'rollout', next),
    );
  }

  Widget _tagsTile() {
    return TagsTile(
      tags: asStringList(_group('targeting')['tags']),
      brightness: brightness,
    );
  }

  Widget _childTile() {
    final child = _group('slot')['child'];
    final isMap = child is Map;
    return ChildSlotTile(
      componentId: isMap ? child['componentId']?.toString() : null,
      config: isMap && child['config'] is Map
          ? Map<String, dynamic>.from(child['config'] as Map)
          : const <String, dynamic>{},
      brightness: brightness,
    );
  }

  Widget _frameTile() {
    final g = _group('slot');
    final frameSize = g['frameSize'];
    final constraints = g['sizeConstraints'];
    return FrameTile(
      width: toDoubleOrNull(frameSize is Map ? frameSize['width'] : null) ??
          240,
      height: toDoubleOrNull(frameSize is Map ? frameSize['height'] : null) ??
          120,
      maxWidth:
          toDoubleOrNull(constraints is Map ? constraints['maxWidth'] : null) ??
          320,
      maxHeight:
          toDoubleOrNull(
            constraints is Map ? constraints['maxHeight'] : null,
          ) ??
          200,
      brightness: brightness,
    );
  }

  Widget _metaTile() {
    final meta = values['metadata'];
    final map = meta is Map ? meta : const {};
    return MetaTile(
      source: (map['source'] ?? '—').toString(),
      version: map['version']?.toString(),
      brightness: brightness,
    );
  }

  Widget _showcaseTile() {
    final g = _group('showcase');
    final children = g['children'];
    final attributes = g['attributes'];
    return ShowcaseTile(
      mainAxisAlignmentName: (g['mainAxisAlignment'] ?? 'start').toString(),
      crossAxisAlignmentName: (g['crossAxisAlignment'] ?? 'center').toString(),
      children: children is List
          ? children
                .whereType<Map>()
                .map((c) => Map<String, dynamic>.from(c))
                .toList(growable: false)
          : const [],
      attributes: attributes is Map
          ? Map<String, dynamic>.from(attributes)
          : const {},
      brightness: brightness,
    );
  }
}
