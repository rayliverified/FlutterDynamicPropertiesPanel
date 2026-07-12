import 'package:flutter/material.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

import 'tiles/tiles.dart';

/// The sample full UI: the complete Feature Block component — header strip
/// plus the whole bento grid of standalone tiles — written the way a
/// production app would write a screen:
///
/// - All of its state lives as ordinary typed fields on [FeatureBlockState].
///   No controller is passed into the constructor.
/// - Every tile is a StatelessWidget receiving plain constructor data;
///   interactive tiles report changes through callbacks and this State calls
///   `setState`.
/// - [FeatureBlockState] is **public** so external tooling (storyboard,
///   dynamic properties panel) can address it through a
///   `GlobalKey<FeatureBlockState>` supplied from outside via
///   `StoryboardStateRegistry` — the component has zero tooling imports.
///
/// Tooling contract:
/// - [FeatureBlockState.applyValues] maps a grouped value payload (the
///   panel/JSON shape) onto the typed fields. Call it inside
///   `registry.update(...)` so it runs in `setState`.
/// - [FeatureBlockState.toValues] serializes the typed fields back into the
///   same grouped shape.
/// - [onStateChanged] fires with a fresh [FeatureBlockState.toValues]
///   payload whenever the *user* mutates state from inside the component
///   (slider drag, switch toggle) — the "state → panel" direction.
class FeatureBlock extends StatefulWidget {
  const FeatureBlock({
    super.key,
    this.initialValues = const {},
    required this.brightness,
    this.onStateChanged,
  });

  /// Initial grouped values (same shape the properties panel uses).
  final Map<String, dynamic> initialValues;

  final Brightness brightness;

  /// Fired when the user changes state from inside the component.
  final ValueChanged<Map<String, dynamic>>? onStateChanged;

  @override
  State<FeatureBlock> createState() => FeatureBlockState();
}

class FeatureBlockState extends State<FeatureBlock> {
  // ── Component state: ordinary typed fields ───────────────────────
  // CTA
  String ctaTitle = 'Checkout CTA';
  double ctaFontSize = 16;
  double ctaLineHeight = 1.2;
  String ctaVariant = 'primary';

  // Schedule
  bool rollout = true;
  double rolloutPercentage = 75;
  String? expiresAt;
  String? language;

  // Targeting
  List<String> audiences = const [];
  List<String> tags = const [];

  // Appearance
  String themeColorHex = '#3B82F6';
  String? iconName;
  double layoutPadding = 12;
  double layoutRadius = 8;
  bool showShadow = true;
  int animDurationMs = 300;

  // Slot
  Map<String, dynamic>? slotChild;
  double frameWidth = 240;
  double frameHeight = 120;
  double frameMaxWidth = 320;
  double frameMaxHeight = 200;

  // Reach
  int reachUsers = 0;
  String reachWindow = '7d';
  List<num> reachTrend = const [];

  // Conversion
  double conversionRate = 0;
  String conversionUnit = 'percent';
  double conversionDelta = 0;
  String conversionComparison = '';

  // Metadata (schemaless — stays a map)
  Map<String, dynamic> metadata = const {};

  // Showcase
  String showcaseMainAxis = 'start';
  String showcaseCrossAxis = 'center';
  List<Map<String, dynamic>> showcaseChildren = const [];
  Map<String, dynamic> showcaseAttributes = const {};

  /// Group keys the panel edits that the component doesn't render
  /// (textAlign, cornerRadius, swatches, …). Kept verbatim so [toValues]
  /// round-trips the full payload without loss.
  final Map<String, Map<String, dynamic>> _extras = {};

  @override
  void initState() {
    super.initState();
    applyValues(widget.initialValues);
  }

  // ── Tooling contract: grouped values ⇄ typed fields ──────────────

  /// Map a grouped payload onto the typed fields. Only groups present in
  /// [values] are touched. Does NOT call `setState` — callers wrap it
  /// (registry.update does, initState doesn't need it).
  void applyValues(Map<String, dynamic> values) {
    Map<String, dynamic> group(String name) {
      final g = values[name];
      return g is Map ? Map<String, dynamic>.from(g) : <String, dynamic>{};
    }

    void keepExtras(String name, Map<String, dynamic> g, Set<String> used) {
      g.removeWhere((key, _) => used.contains(key));
      _extras[name] = g;
    }

    if (values.containsKey('cta')) {
      final g = group('cta');
      ctaTitle = (g['title'] ?? ctaTitle).toString();
      ctaFontSize = toDoubleOrNull(g['fontSize']) ?? ctaFontSize;
      ctaLineHeight = toDoubleOrNull(g['lineHeight']) ?? ctaLineHeight;
      ctaVariant = (g['variant'] ?? ctaVariant).toString();
      keepExtras('cta', g, {'title', 'fontSize', 'lineHeight', 'variant'});
    }
    if (values.containsKey('schedule')) {
      final g = group('schedule');
      rollout = g['rollout'] == true;
      rolloutPercentage =
          toDoubleOrNull(g['rolloutPercentage']) ?? rolloutPercentage;
      expiresAt = g['expiresAt']?.toString();
      language = g['language']?.toString();
      keepExtras('schedule', g, {
        'rollout',
        'rolloutPercentage',
        'expiresAt',
        'language',
      });
    }
    if (values.containsKey('targeting')) {
      final g = group('targeting');
      audiences = asStringList(g['audiences']);
      tags = asStringList(g['tags']);
      keepExtras('targeting', g, {'audiences', 'tags'});
    }
    if (values.containsKey('appearance')) {
      final g = group('appearance');
      themeColorHex = (g['themeColor'] ?? themeColorHex).toString();
      iconName = g['iconName']?.toString();
      final layout = g['layout'];
      if (layout is Map) {
        layoutPadding = toDoubleOrNull(layout['padding']) ?? layoutPadding;
        layoutRadius = toDoubleOrNull(layout['radius']) ?? layoutRadius;
        showShadow = layout['showShadow'] != false;
      }
      animDurationMs =
          toDoubleOrNull(g['animDuration'])?.round() ?? animDurationMs;
      keepExtras('appearance', g, {
        'themeColor',
        'iconName',
        'layout',
        'animDuration',
      });
    }
    if (values.containsKey('slot')) {
      final g = group('slot');
      final child = g['child'];
      slotChild = child is Map ? Map<String, dynamic>.from(child) : null;
      final frameSize = g['frameSize'];
      if (frameSize is Map) {
        frameWidth = toDoubleOrNull(frameSize['width']) ?? frameWidth;
        frameHeight = toDoubleOrNull(frameSize['height']) ?? frameHeight;
      }
      final constraints = g['sizeConstraints'];
      if (constraints is Map) {
        frameMaxWidth =
            toDoubleOrNull(constraints['maxWidth']) ?? frameMaxWidth;
        frameMaxHeight =
            toDoubleOrNull(constraints['maxHeight']) ?? frameMaxHeight;
      }
      keepExtras('slot', g, {'child', 'frameSize'});
    }
    if (values.containsKey('reach')) {
      final g = group('reach');
      reachUsers = toDoubleOrNull(g['users'])?.round() ?? reachUsers;
      reachWindow = (g['window'] ?? reachWindow).toString();
      final trend = g['trend'];
      reachTrend = trend is List
          ? trend.whereType<num>().toList(growable: false)
          : reachTrend;
      keepExtras('reach', g, {'users', 'window', 'trend'});
    }
    if (values.containsKey('conversion')) {
      final g = group('conversion');
      conversionRate = toDoubleOrNull(g['rate']) ?? conversionRate;
      conversionUnit = (g['unit'] ?? conversionUnit).toString();
      conversionDelta = toDoubleOrNull(g['delta']) ?? conversionDelta;
      conversionComparison = (g['comparison'] ?? conversionComparison)
          .toString();
      keepExtras('conversion', g, {'rate', 'unit', 'delta', 'comparison'});
    }
    if (values.containsKey('metadata')) {
      final meta = values['metadata'];
      metadata = meta is Map
          ? Map<String, dynamic>.from(meta)
          : <String, dynamic>{};
    }
    if (values.containsKey('showcase')) {
      final g = group('showcase');
      showcaseMainAxis = (g['mainAxisAlignment'] ?? showcaseMainAxis)
          .toString();
      showcaseCrossAxis = (g['crossAxisAlignment'] ?? showcaseCrossAxis)
          .toString();
      final children = g['children'];
      showcaseChildren = children is List
          ? children
                .whereType<Map>()
                .map((c) => Map<String, dynamic>.from(c))
                .toList(growable: false)
          : showcaseChildren;
      final attributes = g['attributes'];
      showcaseAttributes = attributes is Map
          ? Map<String, dynamic>.from(attributes)
          : showcaseAttributes;
      keepExtras('showcase', g, {
        'mainAxisAlignment',
        'crossAxisAlignment',
        'children',
        'attributes',
      });
    }
  }

  /// Serialize the typed fields back into the grouped panel/JSON shape.
  Map<String, dynamic> toValues() {
    Map<String, dynamic> withExtras(String name, Map<String, dynamic> typed) {
      return <String, dynamic>{...?_extras[name], ...typed};
    }

    // Preserve whatever frame keys the panel manages beyond width/height.
    final slotExtras = _extras['slot'] ?? const <String, dynamic>{};
    final prevConstraints = slotExtras['sizeConstraints'];
    final constraints = <String, dynamic>{
      if (prevConstraints is Map) ...Map<String, dynamic>.from(prevConstraints),
      'maxWidth': frameMaxWidth,
      'maxHeight': frameMaxHeight,
    };

    return <String, dynamic>{
      'cta': withExtras('cta', {
        'title': ctaTitle,
        'fontSize': ctaFontSize,
        'lineHeight': ctaLineHeight,
        'variant': ctaVariant,
      }),
      'schedule': withExtras('schedule', {
        'rollout': rollout,
        'rolloutPercentage': rolloutPercentage,
        if (expiresAt != null) 'expiresAt': expiresAt,
        if (language != null) 'language': language,
      }),
      'targeting': withExtras('targeting', {
        'audiences': audiences,
        'tags': tags,
      }),
      'appearance': withExtras('appearance', {
        'themeColor': themeColorHex,
        if (iconName != null) 'iconName': iconName,
        'layout': {
          'padding': layoutPadding,
          'radius': layoutRadius,
          'showShadow': showShadow,
        },
        'animDuration': animDurationMs,
      }),
      'slot': withExtras('slot', {
        if (slotChild != null) 'child': slotChild,
        'frameSize': {'width': frameWidth, 'height': frameHeight},
        'sizeConstraints': constraints,
      }),
      'reach': withExtras('reach', {
        'users': reachUsers,
        'window': reachWindow,
        'trend': reachTrend,
      }),
      'conversion': withExtras('conversion', {
        'rate': conversionRate,
        'unit': conversionUnit,
        'delta': conversionDelta,
        'comparison': conversionComparison,
      }),
      'metadata': metadata,
      'showcase': withExtras('showcase', {
        'mainAxisAlignment': showcaseMainAxis,
        'crossAxisAlignment': showcaseCrossAxis,
        'children': showcaseChildren,
        'attributes': showcaseAttributes,
      }),
    };
  }

  /// User-initiated mutation: rebuild AND report upward so external tooling
  /// (panel, JSON card) stays in sync.
  void _mutate(VoidCallback fn) {
    setState(fn);
    widget.onStateChanged?.call(toValues());
  }

  // ── Build: typed fields → stateless constructors ──────────────────

  Brightness get brightness => widget.brightness;

  Color get _themeColor =>
      parsePreviewColor(themeColorHex) ??
      SoftSaaSTokens.primaryColor(brightness);

  @override
  Widget build(BuildContext context) {
    final radius = layoutRadius.clamp(0.0, 40.0);
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
          FeatureBlockHeader(
            title: ctaTitle,
            variant: ctaVariant,
            themeColor: _themeColor,
            iconName: iconName,
            rollout: rollout,
            language: language,
            expiresAt: expiresAt,
            brightness: brightness,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: _bentoGrid(),
          ),
        ],
      ),
    );
  }

  // Tiles are also exposed individually so tooling hosts (the storyboard
  // carousel) can render single tiles from this component's live state.
  Widget ctaTile() => CtaTile(
    title: ctaTitle,
    variant: ctaVariant,
    fontSize: ctaFontSize,
    lineHeight: ctaLineHeight,
    brightness: brightness,
  );

  Widget reachTile() => ReachTile(
    users: reachUsers,
    window: reachWindow,
    trend: reachTrend.map((n) => n.toDouble()).toList(growable: false),
    brightness: brightness,
  );

  Widget audienceTile() =>
      AudienceTile(audiences: audiences, brightness: brightness);

  Widget conversionTile() => ConversionTile(
    rate: conversionRate,
    unit: conversionUnit,
    delta: conversionDelta,
    comparison: conversionComparison,
    brightness: brightness,
  );

  Widget appearanceTile() => AppearanceTile(
    layoutPadding: layoutPadding,
    layoutRadius: layoutRadius,
    showShadow: showShadow,
    animDurationMs: animDurationMs,
    brightness: brightness,
  );

  Widget rolloutTile() => RolloutPercentTile(
    percentage: rolloutPercentage,
    brightness: brightness,
    onChanged: (next) => _mutate(() => rolloutPercentage = next),
  );

  Widget activityTile() => ActivityTile(
    rollout: rollout,
    brightness: brightness,
    onRolloutChanged: (next) => _mutate(() => rollout = next),
  );

  Widget tagsTile() => TagsTile(tags: tags, brightness: brightness);

  Widget childTile() => ChildSlotTile(
    componentId: slotChild?['componentId']?.toString(),
    config: slotChild?['config'] is Map
        ? Map<String, dynamic>.from(slotChild!['config'] as Map)
        : const <String, dynamic>{},
    brightness: brightness,
  );

  Widget frameTile() => FrameTile(
    width: frameWidth,
    height: frameHeight,
    maxWidth: frameMaxWidth,
    maxHeight: frameMaxHeight,
    brightness: brightness,
  );

  Widget metaTile() => MetaTile(
    source: (metadata['source'] ?? '—').toString(),
    version: metadata['version']?.toString(),
    brightness: brightness,
  );

  Widget showcaseTile() => ShowcaseTile(
    mainAxisAlignmentName: showcaseMainAxis,
    crossAxisAlignmentName: showcaseCrossAxis,
    children: showcaseChildren,
    attributes: showcaseAttributes,
    brightness: brightness,
  );

  Widget _bentoGrid() {
    return Column(
      children: [
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 3, child: ctaTile()),
              const SizedBox(width: 8),
              Expanded(flex: 2, child: reachTile()),
            ],
          ),
        ),
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 2, child: audienceTile()),
              const SizedBox(width: 8),
              Expanded(flex: 3, child: conversionTile()),
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
                  appearanceTile(),
                  const SizedBox(height: 8),
                  rolloutTile(),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(flex: 2, child: activityTile()),
          ],
        ),
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 2, child: tagsTile()),
              const SizedBox(width: 8),
              Expanded(flex: 3, child: childTile()),
            ],
          ),
        ),
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 3, child: frameTile()),
              const SizedBox(width: 8),
              Expanded(flex: 2, child: metaTile()),
            ],
          ),
        ),
      ],
    );
  }
}
