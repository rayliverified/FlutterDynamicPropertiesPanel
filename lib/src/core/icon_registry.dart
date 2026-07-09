import 'package:flutter/material.dart';

/// Concrete registry for named icons used by [IconControl].
///
/// Stores `String → IconData` mappings. Consumers register icons
/// directly — no abstract layer. The registry provides lookup, listing,
/// and serialization helpers out of the box.
///
/// ```dart
/// // Use the global manager's registry
/// DynamicPropertiesPanelManager.instance.iconRegistry
///   ..register('home', Icons.home)
///   ..register('search', Icons.search);
///
/// // Or create a standalone registry with Material defaults
/// final registry = IconRegistry.withMaterialDefaults();
/// ```
class IconRegistry {
  final Map<String, IconData> _icons = {};

  IconRegistry();

  /// Creates a registry pre-loaded with common Material Icons.
  IconRegistry.withMaterialDefaults() {
    _icons.addAll(materialDefaults);
  }

  // ── Registration ────────────────────────────────────────────────

  /// Register a single named icon.
  void register(String name, IconData icon) {
    _icons[name.toLowerCase()] = icon;
  }

  /// Register all icons from a map.
  void registerAll(Map<String, IconData> icons) {
    icons.forEach((name, icon) {
      _icons[name.toLowerCase()] = icon;
    });
  }

  /// Remove a named icon.
  void unregister(String name) {
    _icons.remove(name.toLowerCase());
  }

  /// Clear all registered icons.
  void clear() => _icons.clear();

  // ── Lookup ──────────────────────────────────────────────────────

  /// Look up an icon by name (case-insensitive).
  IconData? getIcon(String name) => _icons[name.toLowerCase()];

  /// Whether an icon name is registered.
  bool hasIcon(String name) => _icons.containsKey(name.toLowerCase());

  /// All registered icon names, sorted alphabetically.
  List<String> get allNames => _icons.keys.toList()..sort();

  /// Number of registered icons.
  int get length => _icons.length;

  // ── Parse / Serialize ───────────────────────────────────────────

  /// Parse a dynamic value into an [IconData].
  ///
  /// Supports:
  /// - `IconData` returned as-is
  /// - `String` name looked up in registry
  /// - `Map` with `codePoint` key deserialized
  /// - `int` treated as raw codepoint
  IconData? parse(dynamic value) {
    if (value == null) return null;
    if (value is IconData) return value;

    if (value is String) {
      // Try name lookup first
      final icon = getIcon(value);
      if (icon != null) return icon;

      // Try JSON map
      if (value.startsWith('{')) {
        try {
          // Simple JSON parse — avoid dart:convert dependency
          final map = _parseSimpleJson(value);
          if (map != null) return _deserializeIconData(map);
        } catch (_) {}
      }
      return null;
    }

    if (value is Map) {
      return _deserializeIconData(Map<String, dynamic>.from(value));
    }

    if (value is int) {
      // ignore: non_const_argument_for_const_parameter
      return IconData(value, fontFamily: 'MaterialIcons');
    }

    return null;
  }

  /// Get the icon name for a given [IconData] (reverse lookup).
  String? iconName(IconData? icon) {
    if (icon == null) return null;
    for (final entry in _icons.entries) {
      if (entry.value.codePoint == icon.codePoint &&
          entry.value.fontFamily == icon.fontFamily) {
        return entry.key;
      }
    }
    return icon.codePoint.toString();
  }

  // ── Helpers ─────────────────────────────────────────────────────

  static IconData? _deserializeIconData(Map<String, dynamic> json) {
    final codePoint = json['codePoint'];
    if (codePoint is! int) return null;
    // Icon data is intentionally restored from serialized user values.
    // ignore: non_const_argument_for_const_parameter
    return IconData(
      // ignore: non_const_argument_for_const_parameter
      codePoint,
      // ignore: non_const_argument_for_const_parameter
      fontFamily: json['fontFamily'] as String?,
      // ignore: non_const_argument_for_const_parameter
      fontPackage: json['fontPackage'] as String?,
      // ignore: non_const_argument_for_const_parameter
      matchTextDirection: json['matchTextDirection'] as bool? ?? false,
    );
  }

  static Map<String, dynamic>? _parseSimpleJson(String json) {
    // Minimal JSON parser for {"codePoint": 123, ...} format
    if (!json.startsWith('{') || !json.endsWith('}')) return null;
    final result = <String, dynamic>{};
    final inner = json.substring(1, json.length - 1).trim();
    if (inner.isEmpty) return result;
    for (final part in inner.split(',')) {
      final kv = part.split(':');
      if (kv.length != 2) continue;
      final key = kv[0].trim().replaceAll('"', '').replaceAll("'", '');
      var val = kv[1].trim();
      if (val.endsWith('.0')) val = val.substring(0, val.length - 2);
      final asInt = int.tryParse(val);
      if (asInt != null) {
        result[key] = asInt;
      } else {
        result[key] = val.replaceAll('"', '').replaceAll("'", '');
      }
    }
    return result;
  }

  // ── Pre-built icon maps ─────────────────────────────────────────

  /// Comprehensive Material Icons set for common UI patterns.
  static Map<String, IconData> get materialDefaults => const {
    // Navigation
    'home': Icons.home,
    'menu': Icons.menu,
    'arrow_back': Icons.arrow_back,
    'arrow_forward': Icons.arrow_forward,
    'arrow_upward': Icons.arrow_upward,
    'arrow_downward': Icons.arrow_downward,
    'chevron_left': Icons.chevron_left,
    'chevron_right': Icons.chevron_right,
    'arrow_drop_down': Icons.arrow_drop_down,
    'arrow_drop_up': Icons.arrow_drop_up,
    'arrow_back_ios': Icons.arrow_back_ios,
    'arrow_forward_ios': Icons.arrow_forward_ios,
    'arrow_left': Icons.arrow_left,
    'arrow_right': Icons.arrow_right,
    'first_page': Icons.first_page,
    'last_page': Icons.last_page,
    'navigate_before': Icons.navigate_before,
    'navigate_next': Icons.navigate_next,

    // Actions
    'add': Icons.add,
    'add_circle': Icons.add_circle,
    'add_circle_outline': Icons.add_circle_outline,
    'remove': Icons.remove,
    'remove_circle': Icons.remove_circle,
    'remove_circle_outline': Icons.remove_circle_outline,
    'delete': Icons.delete,
    'delete_outline': Icons.delete_outline,
    'edit': Icons.edit,
    'edit_note': Icons.edit_note,
    'create': Icons.create,
    'save': Icons.save,
    'save_as': Icons.save_as,
    'cancel': Icons.cancel,
    'check': Icons.check,
    'check_circle': Icons.check_circle,
    'check_circle_outline': Icons.check_circle_outline,
    'close': Icons.close,
    'done': Icons.done,
    'done_all': Icons.done_all,
    'refresh': Icons.refresh,
    'sync': Icons.sync,
    'update': Icons.update,
    'clear': Icons.clear,
    'undo': Icons.undo,
    'redo': Icons.redo,
    'content_copy': Icons.content_copy,
    'content_cut': Icons.content_cut,
    'content_paste': Icons.content_paste,

    // Communication
    'search': Icons.search,
    'email': Icons.email,
    'phone': Icons.phone,
    'chat': Icons.chat,
    'chat_bubble': Icons.chat_bubble,
    'send': Icons.send,
    'reply': Icons.reply,
    'forward': Icons.forward,
    'share': Icons.share,
    'link': Icons.link,

    // Content
    'favorite': Icons.favorite,
    'favorite_border': Icons.favorite_border,
    'star': Icons.star,
    'star_border': Icons.star_border,
    'star_half': Icons.star_half,
    'bookmark': Icons.bookmark,
    'bookmark_border': Icons.bookmark_border,
    'flag': Icons.flag,
    'flag_outlined': Icons.flag_outlined,
    'thumb_up': Icons.thumb_up,
    'thumb_down': Icons.thumb_down,
    'attach_file': Icons.attach_file,
    'image': Icons.image,
    'photo': Icons.photo,
    'photo_camera': Icons.photo_camera,
    'videocam': Icons.videocam,
    'mic': Icons.mic,
    'camera_alt': Icons.camera_alt,

    // Media
    'play_arrow': Icons.play_arrow,
    'pause': Icons.pause,
    'stop': Icons.stop,
    'skip_next': Icons.skip_next,
    'skip_previous': Icons.skip_previous,
    'fast_forward': Icons.fast_forward,
    'fast_rewind': Icons.fast_rewind,
    'volume_up': Icons.volume_up,
    'volume_down': Icons.volume_down,
    'volume_off': Icons.volume_off,
    'volume_mute': Icons.volume_mute,
    'fullscreen': Icons.fullscreen,
    'fullscreen_exit': Icons.fullscreen_exit,

    // Status
    'info': Icons.info,
    'info_outline': Icons.info_outline,
    'warning': Icons.warning,
    'warning_amber': Icons.warning_amber,
    'error': Icons.error,
    'error_outline': Icons.error_outline,
    'help': Icons.help,
    'help_outline': Icons.help_outline,
    'notifications': Icons.notifications,
    'notifications_none': Icons.notifications_none,
    'notifications_off': Icons.notifications_off,
    'notifications_active': Icons.notifications_active,

    // People
    'person': Icons.person,
    'person_outline': Icons.person_outline,
    'person_add': Icons.person_add,
    'people': Icons.people,
    'people_outline': Icons.people_outline,
    'group': Icons.group,
    'group_add': Icons.group_add,
    'account_circle': Icons.account_circle,
    'contacts': Icons.contacts,

    // Layout / View
    'grid_view': Icons.grid_view,
    'view_list': Icons.view_list,
    'view_module': Icons.view_module,
    'view_compact': Icons.view_compact,
    'view_agenda': Icons.view_agenda,
    'view_column': Icons.view_column,
    'view_stream': Icons.view_stream,
    'view_carousel': Icons.view_carousel,
    'dashboard': Icons.dashboard,
    'dashboard_customize': Icons.dashboard_customize,
    'apps': Icons.apps,
    'list': Icons.list,
    'list_alt': Icons.list_alt,
    'grid_on': Icons.grid_on,
    'grid_off': Icons.grid_off,
    'crop_square': Icons.crop_square,
    'crop_free': Icons.crop_free,

    // Settings
    'settings': Icons.settings,
    'settings_applications': Icons.settings_applications,
    'tune': Icons.tune,
    'build': Icons.build,
    'construction': Icons.construction,
    'engineering': Icons.engineering,

    // Toggle
    'visibility': Icons.visibility,
    'visibility_off': Icons.visibility_off,
    'lock': Icons.lock,
    'lock_open': Icons.lock_open,
    'lock_outline': Icons.lock_outline,
    'toggle_on': Icons.toggle_on,
    'toggle_off': Icons.toggle_off,

    // Commerce
    'shopping_cart': Icons.shopping_cart,
    'shopping_bag': Icons.shopping_bag,
    'store': Icons.store,
    'payment': Icons.payment,
    'credit_card': Icons.credit_card,
    'receipt': Icons.receipt,
    'sell': Icons.sell,
    'local_offer': Icons.local_offer,
    'inventory': Icons.inventory,
    'inventory_2': Icons.inventory_2,

    // Time
    'schedule': Icons.schedule,
    'today': Icons.today,
    'calendar_today': Icons.calendar_today,
    'date_range': Icons.date_range,
    'access_time': Icons.access_time,
    'timer': Icons.timer,
    'hourglass_empty': Icons.hourglass_empty,
    'history': Icons.history,

    // Files
    'folder': Icons.folder,
    'folder_open': Icons.folder_open,
    'description': Icons.description,
    'insert_drive_file': Icons.insert_drive_file,
    'cloud': Icons.cloud,
    'cloud_upload': Icons.cloud_upload,
    'cloud_download': Icons.cloud_download,
    'download': Icons.download,
    'upload': Icons.upload,
    'download_done': Icons.download_done,

    // Formatting
    'format_bold': Icons.format_bold,
    'format_italic': Icons.format_italic,
    'format_underline': Icons.format_underline,
    'format_strikethrough': Icons.format_strikethrough,
    'format_align_left': Icons.format_align_left,
    'format_align_center': Icons.format_align_center,
    'format_align_right': Icons.format_align_right,
    'format_align_justify': Icons.format_align_justify,
    'format_size': Icons.format_size,
    'text_fields': Icons.text_fields,
    'title': Icons.title,
    'notes': Icons.notes,
    'subject': Icons.subject,
    'article': Icons.article,

    // Misc
    'more_vert': Icons.more_vert,
    'more_horiz': Icons.more_horiz,
    'sort': Icons.sort,
    'filter_list': Icons.filter_list,
    'filter_alt': Icons.filter_alt,
    'language': Icons.language,
    'public': Icons.public,
    'map': Icons.map,
    'place': Icons.place,
    'location_on': Icons.location_on,
    'widgets': Icons.widgets,
    'extension': Icons.extension,
    'category': Icons.category,
    'label': Icons.label,
    'label_outline': Icons.label_outline,
    'space_bar': Icons.space_bar,
    'rounded_corner': Icons.rounded_corner,
    'analytics': Icons.analytics,
    'insights': Icons.insights,
    'trending_up': Icons.trending_up,
    'trending_down': Icons.trending_down,
    'open_in_new': Icons.open_in_new,
    'code': Icons.code,
    'bug_report': Icons.bug_report,
    'data_object': Icons.data_object,
    'hub': Icons.hub,
    'flight_takeoff': Icons.flight_takeoff,
    'auto_awesome': Icons.auto_awesome,
    'rocket_launch': Icons.rocket_launch,
    'psychology': Icons.psychology,
    'smart_toy': Icons.smart_toy,
    'bolt': Icons.bolt,
    'flash_on': Icons.flash_on,
    'power': Icons.power,
    'color_lens': Icons.color_lens,
    'palette': Icons.palette,
    'brush': Icons.brush,
    'design_services': Icons.design_services,
  };
}
