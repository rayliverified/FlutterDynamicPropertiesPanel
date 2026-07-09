import 'package:dynamic_properties_panel/dynamic_properties_panel.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

import 'widgets/json_card.dart';
import 'widgets/live_preview_card.dart';
import 'widgets/top_bar.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dynamic Properties Panel',
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: SoftSaaSTheme.light(),
      darkTheme: SoftSaaSTheme.dark(),
      home: ExampleHomePage(
        darkMode: _darkMode,
        onToggleTheme: () => setState(() => _darkMode = !_darkMode),
      ),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({
    super.key,
    required this.darkMode,
    required this.onToggleTheme,
  });

  final bool darkMode;
  final VoidCallback onToggleTheme;

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  /// Authoritative shared state. Both the panel and the preview bind to
  /// this — that's how bidirectional sync works.
  late final DynamicPropertiesController _controller;
  late List<DynamicPropertyDefinition> _properties;
  late List<PropertyPreset> _presets;
  late Map<String, List<PropertyPreset>> _componentPresets;
  bool _previewExpanded = true;
  bool _propertiesExpanded = true;
  bool _jsonExpanded = true;
  bool _smartLayout = true;
  int _mobileSheetTabIndex = 0;
  String? _selectedPropertyName;

  static const _kWideBreakpoint = 800.0;
  static const _kInspectorWidth = 420.0;
  static const _kInspectorMinWidth = 360.0;
  static const _kInspectorMaxWidth = 560.0;
  static const _kCollapsedPanelHeight = 54.0;

  @override
  void initState() {
    super.initState();

    // Register example components for the slot picker — with schemas!
    final manager = DynamicPropertiesPanelManager.instance;
    manager.componentRegistry.registerAll([
      // ── Built-ins ─────────────────────────────────────────────
      ComponentInfo(
        id: '__builtin_container',
        name: 'Container',
        description: 'A box with optional color, size, and border radius',
        icon: Icons.crop_square,
        category: 'Built-in',
        defaultConfig: {
          'color': '#3B82F6',
          'width': 48.0,
          'height': 48.0,
          'borderRadius': 8.0,
          'padding': 0.0,
        },
        properties: DynamicPropertyDefinition.listFromJson([
          {
            'name': 'color',
            'type': 'Color',
            'description': 'Fill color',
            'defaultValue': '#3B82F6',
          },
          {
            'name': 'width',
            'type': 'double',
            'description': 'Width in logical pixels',
            'defaultValue': 80.0,
            'bounds': {'minimum': 8, 'maximum': 320, 'step': 4},
          },
          {
            'name': 'height',
            'type': 'double',
            'description': 'Height in logical pixels',
            'defaultValue': 80.0,
            'bounds': {'minimum': 8, 'maximum': 320, 'step': 4},
          },
          {
            'name': 'borderRadius',
            'type': 'double',
            'description': 'Corner radius',
            'defaultValue': 8.0,
            'bounds': {'minimum': 0, 'maximum': 80, 'step': 2},
          },
          {
            'name': 'padding',
            'type': 'double',
            'description': 'Inner padding',
            'defaultValue': 0.0,
            'bounds': {'minimum': 0, 'maximum': 40, 'step': 2},
          },
        ]),
      ),
      ComponentInfo(
        id: '__builtin_text',
        name: 'Text',
        description: 'A styled text widget',
        icon: Icons.text_fields,
        category: 'Built-in',
        defaultConfig: {
          'text': 'Hello, world!',
          'fontSize': 14.0,
          'color': '#111827',
          'fontWeight': 'normal',
        },
        properties: DynamicPropertyDefinition.listFromJson([
          {
            'name': 'text',
            'type': 'String',
            'description': 'Text content',
            'defaultValue': 'Hello, world!',
            'bounds': {'maxLength': 100},
          },
          {
            'name': 'fontSize',
            'type': 'double',
            'description': 'Font size',
            'defaultValue': 16.0,
            'bounds': {'minimum': 8, 'maximum': 72, 'step': 1},
          },
          {
            'name': 'color',
            'type': 'Color',
            'description': 'Text color',
            'defaultValue': '#111827',
          },
          {
            'name': 'fontWeight',
            'type': 'String',
            'description': 'Font weight',
            'defaultValue': 'normal',
            'enumValues': ['normal', 'medium', 'semibold', 'bold'],
            'enumLabels': {
              'normal': 'Normal',
              'medium': 'Medium',
              'semibold': 'Semibold',
              'bold': 'Bold',
            },
          },
        ]),
      ),
      ComponentInfo(
        id: '__builtin_sizedbox',
        name: 'SizedBox',
        description: 'A fixed-size empty box',
        icon: Icons.crop_square_outlined,
        category: 'Built-in',
        defaultConfig: {'width': 48.0, 'height': 48.0},
        properties: DynamicPropertyDefinition.listFromJson([
          {
            'name': 'width',
            'type': 'double',
            'description': 'Width in logical pixels',
            'defaultValue': 48.0,
            'bounds': {'minimum': 0, 'maximum': 320, 'step': 4},
          },
          {
            'name': 'height',
            'type': 'double',
            'description': 'Height in logical pixels',
            'defaultValue': 48.0,
            'bounds': {'minimum': 0, 'maximum': 320, 'step': 4},
          },
        ]),
      ),
      ComponentInfo(
        id: 'custom_button',
        name: 'CustomButton',
        description: 'Branded button with variants',
        icon: Icons.smart_button,
        category: 'Buttons',
        defaultConfig: {
          'label': 'Click Me',
          'variant': 'primary',
          'fontSize': 14,
          'enabled': true,
        },
        properties: DynamicPropertyDefinition.listFromJson([
          {
            'name': 'label',
            'type': 'String',
            'description': 'Button label text',
            'defaultValue': 'Click Me',
            'bounds': {'maxLength': 30},
          },
          {
            'name': 'variant',
            'type': 'String',
            'description': 'Visual style',
            'defaultValue': 'primary',
            'enumValues': ['primary', 'secondary', 'ghost'],
            'enumLabels': {
              'primary': 'Primary',
              'secondary': 'Secondary',
              'ghost': 'Ghost',
            },
          },
          {
            'name': 'fontSize',
            'type': 'double',
            'description': 'Button text size',
            'defaultValue': 14,
            'bounds': {'minimum': 10, 'maximum': 32, 'step': 1},
          },
          {
            'name': 'enabled',
            'type': 'bool',
            'description': 'Whether the button is interactive',
            'defaultValue': true,
          },
        ]),
      ),
      ComponentInfo(
        id: 'avatar',
        name: 'Avatar',
        description: 'User avatar with status',
        icon: Icons.account_circle,
        category: 'Display',
        defaultConfig: {
          'initials': 'AB',
          'size': 40,
          'showStatus': false,
          'statusColor': '#22C55E',
        },
        properties: DynamicPropertyDefinition.listFromJson([
          {
            'name': 'initials',
            'type': 'String',
            'description': 'Fallback initials when no image',
            'defaultValue': 'AB',
            'bounds': {'maxLength': 3},
          },
          {
            'name': 'size',
            'type': 'double',
            'description': 'Avatar diameter',
            'defaultValue': 40,
            'bounds': {'minimum': 16, 'maximum': 96, 'step': 4},
          },
          {
            'name': 'showStatus',
            'type': 'bool',
            'description': 'Show online status indicator',
            'defaultValue': false,
          },
          {
            'name': 'statusColor',
            'type': 'Color',
            'description': 'Status dot color',
            'defaultValue': '#22C55E',
          },
        ]),
      ),
      ComponentInfo(
        id: 'badge',
        name: 'StatusBadge',
        description: 'Colored status indicator',
        icon: Icons.label,
        category: 'Display',
        defaultConfig: {'text': 'Active', 'color': '#3B82F6'},
        properties: DynamicPropertyDefinition.listFromJson([
          {
            'name': 'text',
            'type': 'String',
            'description': 'Badge label',
            'defaultValue': 'Active',
            'bounds': {'maxLength': 20},
          },
          {
            'name': 'color',
            'type': 'Color',
            'description': 'Badge background color',
            'defaultValue': '#3B82F6',
          },
        ]),
      ),
    ]);

    // Presets define complete value snapshots that can be selected,
    // saved-over, or deleted via the preset toolbar.
    _presets = [
      PropertyPreset(
        id: 'default',
        name: 'Default',
        description: 'Default configuration',
        values: <String, dynamic>{
          'cta': <String, dynamic>{
            'title': 'Checkout CTA',
            'fontSize': 16,
            'lineHeight': 1.2,
            'variant': 'primary',
            'textAlign': 'left',
            'contentAlignment': <String, dynamic>{'x': 0.0, 'y': 0.0},
            'labelStyle': <String, dynamic>{'markdown': '**Checkout CTA**'},
          },
          'schedule': <String, dynamic>{
            'rollout': true,
            'rolloutPercentage': 75.0,
            'expiresAt': '2026-06-30T00:00:00.000Z',
            'language': 'English',
          },
          'targeting': <String, dynamic>{
            'audiences': <dynamic>['consumer', 'power_user'],
            'tags': <dynamic>['new', 'featured'],
            'count': 5,
          },
          'appearance': <String, dynamic>{
            'themeColor': '#3B82F6',
            'swatchColor': '#3B82F6',
            'iconName': 'star',
            'iconNameSwatch': 'star',
            'layout': <String, dynamic>{
              'padding': 12,
              'radius': 8,
              'showShadow': true,
            },
            'padding': <String, dynamic>{
              'top': 8.0,
              'right': 16.0,
              'bottom': 8.0,
              'left': 16.0,
            },
            'cornerRadius': <String, dynamic>{
              'topLeft': 8.0,
              'topRight': 8.0,
              'bottomLeft': 0.0,
              'bottomRight': 0.0,
            },
            'animDuration': 300,
          },
          'slot': <String, dynamic>{
            'child': <String, dynamic>{
              'componentId': 'custom_button',
              'config': <String, dynamic>{
                'label': 'Buy Now',
                'variant': 'primary',
                'fontSize': 14,
                'enabled': true,
              },
            },
            'frameSize': <String, dynamic>{'width': 240.0, 'height': 120.0},
            'rotation': 0.0,
            'sizeConstraints': <String, dynamic>{
              'minWidth': 0.0,
              'maxWidth': 320.0,
              'minHeight': 40.0,
              'maxHeight': 200.0,
            },
            'mainAxisSize': 'max',
            'direction': 'horizontal',
          },
          'metadata': <String, dynamic>{
            'source': 'auto_storyboard',
            'version': 3,
          },
          'showcase': <String, dynamic>{
            'mainAxisAlignment': 'start',
            'crossAxisAlignment': 'center',
            'children': <dynamic>[
              <String, dynamic>{
                'componentId': 'custom_button',
                'config': <String, dynamic>{
                  'label': 'Learn More',
                  'variant': 'secondary',
                  'fontSize': 13,
                  'enabled': true,
                },
              },
            ],
            'attributes': <String, dynamic>{
              'campaign': 'spring_launch',
              'owner': 'growth_team',
            },
          },
        },
      ),
      PropertyPreset(
        id: 'compact',
        name: 'Compact',
        description: 'Smaller text, secondary style',
        values: <String, dynamic>{
          'cta': <String, dynamic>{
            'title': 'Buy',
            'fontSize': 12,
            'lineHeight': 1.1,
            'variant': 'secondary',
            'textAlign': 'left',
            'contentAlignment': <String, dynamic>{'x': -1.0, 'y': 0.0},
            'labelStyle': <String, dynamic>{'markdown': '*Compact label*'},
          },
          'schedule': <String, dynamic>{
            'rollout': true,
            'rolloutPercentage': 25.0,
            'expiresAt': '2026-05-01T00:00:00.000Z',
            'language': 'French',
          },
          'targeting': <String, dynamic>{
            'audiences': <dynamic>['consumer'],
            'tags': <dynamic>['compact'],
            'count': 1,
          },
          'appearance': <String, dynamic>{
            'themeColor': '#6B7280',
            'swatchColor': '#6B7280',
            'iconName': 'minus',
            'iconNameSwatch': 'minus',
            'layout': <String, dynamic>{
              'padding': 4,
              'radius': 4,
              'showShadow': false,
            },
            'padding': <String, dynamic>{
              'top': 4.0,
              'right': 8.0,
              'bottom': 4.0,
              'left': 8.0,
            },
            'cornerRadius': <String, dynamic>{
              'topLeft': 4.0,
              'topRight': 4.0,
              'bottomLeft': 4.0,
              'bottomRight': 4.0,
            },
            'animDuration': 150,
          },
          'slot': <String, dynamic>{
            'child': <String, dynamic>{
              'componentId': '__builtin_text',
              'config': <String, dynamic>{
                'text': 'Buy',
                'fontSize': 12.0,
                'color': '#111827',
                'fontWeight': 'medium',
              },
            },
            'frameSize': <String, dynamic>{'width': 120.0, 'height': 60.0},
            'rotation': 0.0,
            'sizeConstraints': <String, dynamic>{
              'minWidth': 0.0,
              'maxWidth': 160.0,
              'minHeight': 24.0,
              'maxHeight': 80.0,
            },
            'mainAxisSize': 'min',
            'direction': 'horizontal',
          },
          'metadata': <String, dynamic>{
            'source': 'auto_storyboard',
            'version': 3,
          },
          'showcase': <String, dynamic>{
            'mainAxisAlignment': 'start',
            'crossAxisAlignment': 'center',
            'children': <dynamic>[],
            'attributes': <String, dynamic>{
              'campaign': 'compact',
              'owner': 'growth_team',
            },
          },
        },
      ),
      PropertyPreset(
        id: 'hero',
        name: 'Hero',
        description: 'Large prominent call-to-action',
        values: <String, dynamic>{
          'cta': <String, dynamic>{
            'title': 'Get Started Now',
            'fontSize': 24,
            'lineHeight': 1.3,
            'variant': 'primary',
            'textAlign': 'center',
            'contentAlignment': <String, dynamic>{'x': 0.0, 'y': 0.0},
            'labelStyle': <String, dynamic>{'markdown': '==Hero label=='},
          },
          'schedule': <String, dynamic>{
            'rollout': true,
            'rolloutPercentage': 100.0,
            'expiresAt': '2026-12-31T00:00:00.000Z',
            'language': 'English',
          },
          'targeting': <String, dynamic>{
            'audiences': <dynamic>['consumer', 'enterprise'],
            'tags': <dynamic>['hero', 'featured'],
            'count': 99,
          },
          'appearance': <String, dynamic>{
            'themeColor': '#8B5CF6',
            'swatchColor': '#8B5CF6',
            'iconName': 'zap',
            'iconNameSwatch': 'zap',
            'layout': <String, dynamic>{
              'padding': 24,
              'radius': 16,
              'showShadow': true,
            },
            'padding': <String, dynamic>{
              'top': 24.0,
              'right': 32.0,
              'bottom': 24.0,
              'left': 32.0,
            },
            'cornerRadius': <String, dynamic>{
              'topLeft': 16.0,
              'topRight': 16.0,
              'bottomLeft': 16.0,
              'bottomRight': 16.0,
            },
            'animDuration': 600,
          },
          'slot': <String, dynamic>{
            'child': <String, dynamic>{
              'componentId': 'custom_button',
              'config': <String, dynamic>{
                'label': 'Get Started',
                'variant': 'primary',
                'fontSize': 18,
                'enabled': true,
              },
            },
            'frameSize': <String, dynamic>{'width': 360.0, 'height': 160.0},
            'rotation': 0.0,
            'sizeConstraints': <String, dynamic>{
              'minWidth': 200.0,
              'maxWidth': 600.0,
              'minHeight': 80.0,
              'maxHeight': 400.0,
            },
            'mainAxisSize': 'max',
            'direction': 'horizontal',
          },
          'metadata': <String, dynamic>{
            'source': 'auto_storyboard',
            'version': 3,
          },
          'showcase': <String, dynamic>{
            'mainAxisAlignment': 'center',
            'crossAxisAlignment': 'center',
            'children': <dynamic>[],
            'attributes': <String, dynamic>{
              'campaign': 'hero_launch',
              'owner': 'growth_team',
            },
          },
        },
      ),
    ];

    // Component presets

    // Component presets— keyed by component ID, loaded from storage (e.g.
    // SharedPreferences). In a real app, persist and restore via onComponentPresetsChanged.
    _componentPresets = {
      'custom_button': [
        PropertyPreset(
          id: 'default',
          name: 'Default',
          description: 'Standard primary button',
          values: {
            'label': 'Click Me',
            'variant': 'primary',
            'fontSize': 14,
            'enabled': true,
          },
        ),
        PropertyPreset(
          id: 'cta',
          name: 'Call to Action',
          description: 'Large primary button for CTAs',
          values: {
            'label': 'Get Started',
            'variant': 'primary',
            'fontSize': 18,
            'enabled': true,
          },
        ),
        PropertyPreset(
          id: 'subtle',
          name: 'Subtle',
          description: 'Small ghost button',
          values: {
            'label': 'Learn more',
            'variant': 'ghost',
            'fontSize': 12,
            'enabled': true,
          },
        ),
      ],
      'avatar': [
        PropertyPreset(
          id: 'default',
          name: 'Default',
          description: 'Medium avatar, no status',
          values: {
            'initials': 'AB',
            'size': 40,
            'showStatus': false,
            'statusColor': '#22C55E',
          },
        ),
        PropertyPreset(
          id: 'large_online',
          name: 'Large (Online)',
          description: 'Large avatar with green online indicator',
          values: {
            'initials': 'AB',
            'size': 64,
            'showStatus': true,
            'statusColor': '#22C55E',
          },
        ),
        PropertyPreset(
          id: 'small',
          name: 'Small',
          description: 'Compact avatar for lists',
          values: {
            'initials': 'AB',
            'size': 24,
            'showStatus': false,
            'statusColor': '#22C55E',
          },
        ),
      ],
      'badge': [
        PropertyPreset(
          id: 'active',
          name: 'Active',
          description: 'Blue active state',
          values: {'text': 'Active', 'color': '#3B82F6'},
        ),
        PropertyPreset(
          id: 'success',
          name: 'Success',
          description: 'Green success state',
          values: {'text': 'Success', 'color': '#22C55E'},
        ),
        PropertyPreset(
          id: 'warning',
          name: 'Warning',
          description: 'Amber warning state',
          values: {'text': 'Warning', 'color': '#F59E0B'},
        ),
        PropertyPreset(
          id: 'error',
          name: 'Error',
          description: 'Red error state',
          values: {'text': 'Error', 'color': '#EF4444'},
        ),
      ],
    };

    final initialValues = <String, dynamic>{
      'cta': <String, dynamic>{
        'title': 'Checkout CTA',
        'fontSize': 16,
        'lineHeight': 1.2,
        'variant': 'primary',
        'textAlign': 'left',
        'contentAlignment': <String, dynamic>{'x': 0.0, 'y': 0.0},
        'labelStyle': <String, dynamic>{'markdown': '**Checkout CTA**'},
      },
      'schedule': <String, dynamic>{
        'rollout': true,
        'rolloutPercentage': 75.0,
        'expiresAt': '2026-06-30T00:00:00.000Z',
        'language': 'English',
      },
      'targeting': <String, dynamic>{
        'audiences': <dynamic>['consumer', 'power_user'],
        'tags': <dynamic>['new', 'featured'],
        'count': 5,
      },
      'appearance': <String, dynamic>{
        'themeColor': '#3B82F6',
        'swatchColor': '#3B82F6',
        'iconName': 'star',
        'iconNameSwatch': 'star',
        'layout': <String, dynamic>{
          'padding': 12,
          'radius': 8,
          'showShadow': true,
        },
        'padding': <String, dynamic>{
          'top': 8.0,
          'right': 16.0,
          'bottom': 8.0,
          'left': 16.0,
        },
        'cornerRadius': <String, dynamic>{
          'topLeft': 8.0,
          'topRight': 8.0,
          'bottomLeft': 0.0,
          'bottomRight': 0.0,
        },
        'animDuration': 300,
      },
      'slot': <String, dynamic>{
        'child': <String, dynamic>{
          'componentId': 'custom_button',
          'config': <String, dynamic>{
            'label': 'Buy Now',
            'variant': 'primary',
            'fontSize': 14,
            'enabled': true,
          },
        },
        'frameSize': <String, dynamic>{'width': 240.0, 'height': 120.0},
        'rotation': 0.0,
        'sizeConstraints': <String, dynamic>{
          'minWidth': 0.0,
          'maxWidth': 320.0,
          'minHeight': 40.0,
          'maxHeight': 200.0,
        },
        'mainAxisSize': 'max',
        'direction': 'horizontal',
      },
      'metadata': <String, dynamic>{'source': 'auto_storyboard', 'version': 3},
      'showcase': <String, dynamic>{
        'mainAxisAlignment': 'start',
        'crossAxisAlignment': 'center',
        'children': <dynamic>[
          <String, dynamic>{
            'componentId': 'custom_button',
            'config': <String, dynamic>{
              'label': 'Learn More',
              'variant': 'secondary',
              'fontSize': 13,
              'enabled': true,
            },
          },
        ],
        'attributes': <String, dynamic>{
          'campaign': 'spring_launch',
          'owner': 'growth_team',
        },
      },
    };
    _controller = DynamicPropertiesController(initial: initialValues);

    _properties = DynamicPropertyDefinition.listFromJson([
      // ── CTA ──────────────────────────────────────────────────────
      {
        'name': 'cta',
        'type': 'object',
        'title': 'CTA',
        'description':
            'Drives: Live CTA tile — button text, style, typography, alignment',
        'properties': {
          'title': {
            'type': 'String',
            'title': 'Title',
            'description': 'Main display text',
            'defaultValue': 'Checkout CTA',
            'bounds': {'minLength': 1, 'maxLength': 40},
          },
          'fontSize': {
            'type': 'double',
            'title': 'Font Size',
            'description': 'Typography size',
            'defaultValue': 16,
            'bounds': {'minimum': 8, 'maximum': 72, 'step': 1},
          },
          'lineHeight': {
            'type': 'double',
            'title': 'Line Height',
            'description': 'Text line height multiplier',
            'defaultValue': 1.2,
            'bounds': {'minimum': 0.8, 'maximum': 3.0, 'step': 0.1},
          },
          'variant': {
            'type': 'String',
            'title': 'Variant',
            'description': 'Visual style',
            'defaultValue': 'primary',
            'enumValues': ['primary', 'secondary', 'ghost'],
            'enumLabels': {
              'primary': 'Primary',
              'secondary': 'Secondary',
              'ghost': 'Ghost',
            },
          },
          'textAlign': {
            'type': 'TextAlign',
            'title': 'Text Align',
            'description': '4-icon segmented (left / center / right / justify)',
          },
          'contentAlignment': {
            'type': 'Alignment',
            'title': 'Content Alignment',
            'description': 'X/Y inputs + mini anchor grid',
          },
          'labelStyle': {
            'type': 'TextStyle',
            'title': 'Label Style',
            'description': 'Typography settings for the label',
          },
        },
      },

      // ── Schedule ──────────────────────────────────────────────────
      {
        'name': 'schedule',
        'type': 'object',
        'title': 'Schedule',
        'description':
            'Drives: Activity tile, rollout % tile, header live chip',
        'properties': {
          'rollout': {
            'type': 'bool',
            'title': 'Rollout',
            'description':
                'Whether this feature is actively rolled out to traffic',
            'defaultValue': true,
          },
          'rolloutPercentage': {
            'type': 'Slider',
            'title': 'Rollout %',
            'description': 'Percentage of traffic exposed to this variant',
            'defaultValue': 75.0,
            'bounds': {
              'minimum': 0,
              'maximum': 100,
              'step': 1,
              'suffix': '%',
              'decimalPlaces': 0,
            },
          },
          'expiresAt': {
            'type': 'date',
            'title': 'Expires At',
            'description': 'Expiration date/time',
          },
          'language': {
            'type': 'String',
            'title': 'Language',
            'description':
                'Combo input — pick from suggestions or type a custom value',
            'suggestions': [
              'English',
              'English (UK)',
              'French',
              'German',
              'Spanish',
              'Portuguese',
              'Italian',
              'Japanese',
              'Korean',
              'Chinese (Simplified)',
              'Chinese (Traditional)',
            ],
          },
        },
      },

      // ── Targeting ─────────────────────────────────────────────────
      {
        'name': 'targeting',
        'type': 'object',
        'title': 'Targeting',
        'description': 'Drives: Audience tile, tags tile',
        'properties': {
          'audiences': {
            'type': 'List<String>',
            'title': 'Audiences',
            'description': 'Who this variant targets',
            'defaultValue': ['consumer'],
            'multiSelect': true,
            'enumValues': ['consumer', 'power_user', 'enterprise'],
            'enumLabels': {
              'consumer': 'Consumer',
              'power_user': 'Power User',
              'enterprise': 'Enterprise',
            },
          },
          'tags': {
            'type': 'List<String>',
            'title': 'Tags',
            'description': 'Primitive list editor',
            'item': {'type': 'String'},
          },
          'count': {
            'type': 'int',
            'title': 'Count',
            'description': 'Integer counter',
            'defaultValue': 5,
            'bounds': {'minimum': 0, 'maximum': 100},
          },
        },
      },

      // ── Appearance ────────────────────────────────────────────────
      {
        'name': 'appearance',
        'type': 'object',
        'title': 'Appearance',
        'description': 'Drives: Appearance tile, outer card, header icon/color',
        'properties': {
          'themeColor': {
            'type': 'Color',
            'title': 'Theme Color',
            'description': 'Primary brand color',
            'defaultValue': '#3B82F6',
          },
          'swatchColor': {
            'type': 'Color.swatch',
            'title': 'Swatch Color',
            'description': 'Standalone single-button color swatch',
          },
          'iconName': {
            'type': 'icon',
            'title': 'Icon',
            'description': 'Icon picker (Lucide icons)',
          },
          'iconNameSwatch': {
            'type': 'Icon.swatch',
            'title': 'Icon Swatch',
            'description': 'Standalone single-button icon swatch',
          },
          'layout': {
            'type': 'object',
            'title': 'Layout',
            'description': 'Nested layout settings',
            'properties': {
              'padding': {
                'type': 'int',
                'defaultValue': 12,
                'bounds': {'minimum': 0, 'maximum': 80, 'step': 1},
              },
              'radius': {
                'type': 'double',
                'defaultValue': 8,
                'bounds': {'minimum': 0, 'maximum': 40, 'step': 1},
              },
              'showShadow': {'type': 'bool', 'defaultValue': true},
            },
          },
          'padding': {
            'type': 'EdgeInsets',
            'title': 'Padding',
            'description': 'Compact 2×2 inputs with uniform lock',
          },
          'cornerRadius': {
            'type': 'BorderRadius',
            'title': 'Corner Radius',
            'description': 'Compact single-row inputs with corner glyphs',
          },
          'animDuration': {
            'type': 'Duration',
            'title': 'Animation Duration',
            'description': 'Transition timing in milliseconds',
          },
        },
      },

      // ── Slot ──────────────────────────────────────────────────────
      {
        'name': 'slot',
        'type': 'object',
        'title': 'Slot',
        'description': 'Drives: Child slot tile, frame tile',
        'properties': {
          'child': {
            'type': 'Widget',
            'title': 'Child Widget',
            'description': 'Nested component — pick and configure',
          },
          'frameSize': {
            'type': 'Size',
            'title': 'Size (W × H)',
            'description':
                'Width / height inputs with constrain-proportions lock',
          },
          'rotation': {
            'type': 'Rotation',
            'title': 'Rotation',
            'description': 'Angle input with draggable dial',
          },
          'sizeConstraints': {
            'type': 'BoxConstraints',
            'title': 'Size Constraints',
            'description': 'Min/max width and height bounds',
          },
          'mainAxisSize': {
            'type': 'MainAxisSize',
            'title': 'Main Axis Size',
            'description': '2-icon segmented (min / max)',
          },
          'direction': {
            'type': 'Axis',
            'title': 'Direction',
            'description': '2-icon segmented (horizontal / vertical)',
          },
        },
      },

      // ── Metadata (top-level JSON) ─────────────────────────────────
      {
        'name': 'metadata',
        'type': 'json',
        'title': 'Metadata',
        'description': 'Drives: Metadata tile — source + version badges',
      },

      // ── Layout Showcase ───────────────────────────────────────────
      {
        'name': 'showcase',
        'type': 'object',
        'title': 'Layout Showcase',
        'description': 'Axis alignment + widgetList + map controls showcase',
        'properties': {
          'mainAxisAlignment': {
            'type': 'MainAxisAlignment',
            'title': 'Main Axis Alignment',
            'description':
                '6-icon segmented (start / center / end / between / around / evenly)',
          },
          'crossAxisAlignment': {
            'type': 'CrossAxisAlignment',
            'title': 'Cross Axis Alignment',
            'description':
                '5-icon segmented (start / center / end / stretch / baseline)',
          },
          'children': {
            'type': 'List<Widget>',
            'title': 'Children',
            'description': 'List of child components',
          },
          'attributes': {
            'type': 'Map<String, dynamic>',
            'title': 'Attributes',
            'description': 'Simple key/value metadata map',
          },
        },
      },
    ]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildPropertiesEditor({required bool wide}) {
    final padding = EdgeInsets.symmetric(
      horizontal: wide ? 16 : 8,
      vertical: wide ? 8 : 6,
    );

    if (_selectedPropertyName == null) {
      return DynamicPropertiesPanel(
        controller: _controller,
        properties: _properties,
        presets: _presets,
        onPresetsChanged: (updated) => setState(() => _presets = updated),
        componentPresets: _componentPresets,
        onComponentPresetsChanged: (componentId, updated) => setState(() {
          _componentPresets = Map.from(_componentPresets)
            ..[componentId] = updated;
        }),
        smartLayout: _smartLayout,
        showContainer: false,
        padding: padding,
      );
    }

    final scoped = _scopedPropertiesFor(_selectedPropertyName!);
    return DynamicPropertiesPanel(
      values: scoped.values,
      properties: scoped.properties,
      presets: scoped.presets,
      componentPresets: _componentPresets,
      onComponentPresetsChanged: (componentId, updated) => setState(() {
        _componentPresets = Map.from(_componentPresets)
          ..[componentId] = updated;
      }),
      smartLayout: _smartLayout,
      showContainer: false,
      padding: padding,
      onChanged: scoped.onChanged,
    );
  }

  ({
    Map<String, dynamic> values,
    List<DynamicPropertyDefinition> properties,
    ValueChanged<Map<String, dynamic>> onChanged,
    List<PropertyPreset>? presets,
  })
  _scopedPropertiesFor(String key) {
    switch (key) {
      case 'cta':
        return _scopedGroup('cta', const [
          'title',
          'fontSize',
          'lineHeight',
          'variant',
          'textAlign',
          'contentAlignment',
          'labelStyle',
        ]);
      case 'audience':
        return _scopedGroup('targeting', const ['audiences']);
      case 'appearance':
        return _scopedGroup('appearance', const [
          'layout',
          'padding',
          'cornerRadius',
          'animDuration',
        ]);
      case 'rolloutPercentage':
        return _scopedGroup('schedule', const ['rolloutPercentage']);
      case 'rollout':
        return _scopedGroup('schedule', const ['rollout']);
      case 'tags':
        return _scopedGroup('targeting', const ['tags']);
      case 'child':
        return _scopedGroup('slot', const ['child']);
      case 'frame':
        return _scopedGroup('slot', const ['frameSize', 'sizeConstraints']);
      case 'metadata':
        final property = _propertyDefinition('metadata');
        return (
          values: <String, dynamic>{'metadata': _controller['metadata']},
          properties: property == null
              ? <DynamicPropertyDefinition>[]
              : [property],
          onChanged: (updated) => setState(() {
            _controller['metadata'] = updated['metadata'];
          }),
          presets: _scopedPresetsForTopLevel('metadata'),
        );
      case 'reach':
        return _readOnlyScope(<String, dynamic>{
          'reach': <String, dynamic>{
            'users': 4218,
            'window': '7d',
            'trend': <int>[3, 5, 4, 7, 6, 9, 8, 11, 10, 14, 13, 16],
          },
        });
      case 'conversion':
        return _readOnlyScope(<String, dynamic>{
          'conversion': <String, dynamic>{
            'rate': 18.4,
            'unit': 'percent',
            'delta': 2.3,
            'comparison': 'vs last 7d',
          },
        });
      default:
        return _readOnlyScope(<String, dynamic>{});
    }
  }

  ({
    Map<String, dynamic> values,
    List<DynamicPropertyDefinition> properties,
    ValueChanged<Map<String, dynamic>> onChanged,
    List<PropertyPreset>? presets,
  })
  _readOnlyScope(Map<String, dynamic> values) {
    return (
      values: values,
      properties: <DynamicPropertyDefinition>[],
      onChanged: (_) {},
      presets: null,
    );
  }

  ({
    Map<String, dynamic> values,
    List<DynamicPropertyDefinition> properties,
    ValueChanged<Map<String, dynamic>> onChanged,
    List<PropertyPreset>? presets,
  })
  _scopedGroup(String group, List<String> propertyNames) {
    final groupProperty = _propertyDefinition(group);
    final nested =
        groupProperty?.properties ?? const <DynamicPropertyDefinition>[];
    final allowed = propertyNames.toSet();
    final properties = nested
        .where((property) => allowed.contains(property.name))
        .toList(growable: false);
    final values = _filteredMap(_groupValues(group), allowed);

    return (
      values: values,
      properties: properties,
      onChanged: (updated) => setState(() {
        final next = _groupValues(group)..addAll(updated);
        _controller[group] = next;
      }),
      presets: _scopedPresetsForGroup(group, allowed),
    );
  }

  List<PropertyPreset> _scopedPresetsForGroup(
    String group,
    Set<String> allowed,
  ) {
    return _presets
        .map((preset) {
          final groupValues = preset.values[group];
          final values = groupValues is Map
              ? _filteredMap(Map<String, dynamic>.from(groupValues), allowed)
              : <String, dynamic>{};
          return PropertyPreset(
            id: preset.id,
            name: preset.name,
            description: preset.description,
            values: values,
          );
        })
        .toList(growable: false);
  }

  List<PropertyPreset> _scopedPresetsForTopLevel(String key) {
    return _presets
        .map((preset) {
          return PropertyPreset(
            id: preset.id,
            name: preset.name,
            description: preset.description,
            values: <String, dynamic>{key: preset.values[key]},
          );
        })
        .toList(growable: false);
  }

  Map<String, dynamic> _filteredMap(
    Map<String, dynamic> source,
    Set<String> allowed,
  ) {
    return <String, dynamic>{
      for (final entry in source.entries)
        if (allowed.contains(entry.key)) entry.key: entry.value,
    };
  }

  DynamicPropertyDefinition? _propertyDefinition(String name) {
    for (final property in _properties) {
      if (property.name == name) return property;
    }
    return null;
  }

  Map<String, dynamic> _groupValues(String group) {
    final value = _controller[group];
    return value is Map
        ? Map<String, dynamic>.from(value)
        : <String, dynamic>{};
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final wide = MediaQuery.sizeOf(context).width >= _kWideBreakpoint;

    final selectedScope = _selectedPropertyName == null
        ? null
        : _scopedPropertiesFor(_selectedPropertyName!);
    final propertiesEditor = _buildPropertiesEditor(wide: wide);

    // Properties panel — desktop keeps the expandable inspector chrome.
    final propertiesPanel = SoftSaaSPanel.expandable(
      title: 'Component Properties',
      subtitle: _selectedPropertyName == null
          ? (_smartLayout
                ? 'All sections — smart layout ON'
                : 'All sections — smart layout OFF')
          : 'Showing only controls used by this preview card',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Smart layout',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: SoftSaaSTokens.secondaryText(brightness),
            ),
          ),
          const SizedBox(width: 8),
          SoftSaaSSwitch(
            value: _smartLayout,
            size: SoftSaaSCheckboxSize.small,
            onChanged: (next) => setState(() => _smartLayout = next),
          ),
        ],
      ),
      expandBody: true,
      defaultOpen: _propertiesExpanded,
      onToggleOpen: (open) => setState(() => _propertiesExpanded = open),
      child: propertiesEditor,
    );

    // JSON card — desktop keeps the expandable inspector chrome.
    final jsonCard = JsonCard(
      controller: _controller,
      brightness: brightness,
      collapsible: true,
      expanded: _jsonExpanded,
      onToggle: () => setState(() => _jsonExpanded = !_jsonExpanded),
      expandBody: true,
      maxHeight: wide ? 200.0 : 320.0,
      values: selectedScope?.values,
      onValuesChanged: selectedScope?.onChanged,
      subtitle: selectedScope == null
          ? null
          : 'JSON for the active preview card only',
    );

    final mobileJsonCard = JsonCard(
      controller: _controller,
      brightness: brightness,
      expandBody: true,
      showContainer: false,
      values: selectedScope?.values,
      onValuesChanged: selectedScope?.onChanged,
    );

    // Preview — desktop keeps the panel chrome; mobile uses the raw fitted
    // preview so the sheet is the only container on screen.
    final previewCard = LivePreviewCard(
      controller: _controller,
      brightness: brightness,
      expandBody: wide,
      collapsible: false,
      expanded: _previewExpanded,
      onToggle: () => setState(() => _previewExpanded = !_previewExpanded),
      showContainer: wide,
      selectedPropertyName: _selectedPropertyName,
      onPropertySelected: (name) =>
          setState(() => _selectedPropertyName = name),
    );

    return Scaffold(
      backgroundColor: SoftSaaSTokens.secondaryBackground(brightness),
      body: Column(
        children: [
          TopBar(
            isDark: isDark,
            darkMode: widget.darkMode,
            onToggleTheme: widget.onToggleTheme,
          ),
          Expanded(
            child: wide
                ? SoftSaaSResizableRow(
                    initialRightWidth: _kInspectorWidth,
                    minRightWidth: _kInspectorMinWidth,
                    maxRightWidth: _kInspectorMaxWidth,
                    left: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 6, 12),
                      child: previewCard,
                    ),
                    right: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 12, 12, 12),
                      child: _buildInspectorColumn(
                        propertiesPanel: propertiesPanel,
                        jsonCard: jsonCard,
                      ),
                    ),
                  )
                : _buildMobileSheetLayout(
                    previewCard: previewCard,
                    propertiesPanel: propertiesEditor,
                    jsonCard: mobileJsonCard,
                    brightness: brightness,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileSheetLayout({
    required Widget previewCard,
    required Widget propertiesPanel,
    required Widget jsonCard,
    required Brightness brightness,
  }) {
    final sheetCoveragePadding = MediaQuery.sizeOf(context).height * 0.46 + 24;

    return Stack(
      children: [
        Positioned.fill(
          child: ListView(
            padding: EdgeInsets.fromLTRB(12, 12, 12, sheetCoveragePadding),
            children: [previewCard],
          ),
        ),
        DraggableScrollableSheet(
          initialChildSize: 0.46,
          minChildSize: 0.18,
          maxChildSize: 0.92,
          snap: true,
          snapSizes: const [0.18, 0.46, 0.92],
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: SoftSaaSTokens.primaryBackground(brightness),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                border: Border(
                  top: BorderSide(
                    color: SoftSaaSTokens.primaryBorder(brightness),
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: brightness == Brightness.light ? 0.16 : 0.38,
                    ),
                    offset: const Offset(0, -10),
                    blurRadius: 28,
                    spreadRadius: -18,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SingleChildScrollView(
                    controller: scrollController,
                    physics: const ClampingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 6),
                      child: Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: SoftSaaSTokens.primaryBorder(brightness),
                            borderRadius: BorderRadius.circular(
                              SoftSaaSTokens.radiusFull,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SoftSaaSTabs(
                    selectedIndex: _mobileSheetTabIndex,
                    onChanged: (index) =>
                        setState(() => _mobileSheetTabIndex = index),
                    tabs: const [
                      SoftSaaSTab(
                        label: 'Properties',
                        icon: Icons.tune,
                        subtitle: 'Edit schema-driven controls',
                      ),
                      SoftSaaSTab(
                        label: 'JSON',
                        icon: Icons.data_object,
                        subtitle: 'View and edit the live payload',
                      ),
                    ],
                  ),
                  Expanded(
                    child: IndexedStack(
                      index: _mobileSheetTabIndex,
                      children: [propertiesPanel, jsonCard],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInspectorColumn({
    required Widget propertiesPanel,
    required Widget jsonCard,
  }) {
    final bothExpanded = _propertiesExpanded && _jsonExpanded;

    if (bothExpanded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 2, child: propertiesPanel),
          const SizedBox(height: 14),
          Expanded(child: jsonCard),
        ],
      );
    }

    if (_propertiesExpanded && !_jsonExpanded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: propertiesPanel),
          const SizedBox(height: 14),
          SizedBox(height: _kCollapsedPanelHeight, child: jsonCard),
        ],
      );
    }

    if (!_propertiesExpanded && _jsonExpanded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: _kCollapsedPanelHeight, child: propertiesPanel),
          const SizedBox(height: 14),
          Expanded(child: jsonCard),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: _kCollapsedPanelHeight, child: propertiesPanel),
        const SizedBox(height: 14),
        SizedBox(height: _kCollapsedPanelHeight, child: jsonCard),
      ],
    );
  }
}
