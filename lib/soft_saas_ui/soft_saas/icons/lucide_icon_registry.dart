/// Curated registry of Lucide icons for runtime name lookup.
///
/// ## Why curated?
///
/// Flutter's `--tree-shake-icons` flag works by statically collecting the
/// const `IconData` literals the Dart compiler can see. Referencing all
/// 1,600+ Lucide icons via a `Map<String, IconData>` forces every one of
/// them into the bundle. Instead, this registry hand-picks ~180 common
/// icons — the compiler records each as a used literal, tree-shaking
/// stays intact, and runtime string lookup works.
///
/// ## Adding an icon
///
/// Pick the `snake_case` name from
/// [Lucide icons](https://lucide.dev/icons/) and add it to [lucideIconRegistry]
/// as `'name': LucideIcons.name,`. It will become immediately available
/// to anything using [SoftSaaSIconPicker] or [lookupLucideIcon].
library;

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

/// Look up an icon by name. Returns null if not in the registry.
IconData? lookupLucideIcon(String name) => lucideIconRegistry[name];

/// A small grouping hint used by [SoftSaaSIconPicker] to section search
/// results. Not a hard taxonomy — just a UX convenience.
enum LucideIconCategory {
  common,
  navigation,
  files,
  text,
  media,
  layout,
  alignment,
  shapes,
  status,
  commerce,
  misc,
}

class LucideIconEntry {
  const LucideIconEntry(this.name, this.icon, this.category);

  final String name;
  final IconData icon;
  final LucideIconCategory category;
}

/// Flat name → icon map. Use this for quick existence checks and lookup.
const Map<String, IconData> lucideIconRegistry = <String, IconData>{
  // Common
  'house': LucideIcons.house,
  'settings': LucideIcons.settings,
  'search': LucideIcons.search,
  'plus': LucideIcons.plus,
  'minus': LucideIcons.minus,
  'check': LucideIcons.check,
  'x': LucideIcons.x,
  'ellipsis': LucideIcons.ellipsis,
  'ellipsis_vertical': LucideIcons.ellipsis_vertical,
  'menu': LucideIcons.menu,
  'sparkles': LucideIcons.sparkles,
  'wand': LucideIcons.wand,
  'star': LucideIcons.star,
  'heart': LucideIcons.heart,
  'bookmark': LucideIcons.bookmark,
  'eye': LucideIcons.eye,
  'eye_off': LucideIcons.eye_off,
  'lightbulb': LucideIcons.lightbulb,
  'bot': LucideIcons.bot,
  'rocket': LucideIcons.rocket,
  'zap': LucideIcons.zap,
  'flame': LucideIcons.flame,
  'droplet': LucideIcons.droplet,
  'sun': LucideIcons.sun,
  'moon': LucideIcons.moon,

  // Navigation
  'arrow_left': LucideIcons.arrow_left,
  'arrow_right': LucideIcons.arrow_right,
  'arrow_up': LucideIcons.arrow_up,
  'arrow_down': LucideIcons.arrow_down,
  'chevron_left': LucideIcons.chevron_left,
  'chevron_right': LucideIcons.chevron_right,
  'chevron_up': LucideIcons.chevron_up,
  'chevron_down': LucideIcons.chevron_down,
  'external_link': LucideIcons.external_link,
  'link': LucideIcons.link,
  'link_2': LucideIcons.link_2,
  'unlink': LucideIcons.unlink,
  'move': LucideIcons.move,
  'mouse_pointer': LucideIcons.mouse_pointer,
  'history': LucideIcons.history,
  'rotate_cw': LucideIcons.rotate_cw,
  'rotate_ccw': LucideIcons.rotate_ccw,
  'refresh_cw': LucideIcons.refresh_cw,

  // Files
  'folder': LucideIcons.folder,
  'folders': LucideIcons.folders,
  'file': LucideIcons.file,
  'file_text': LucideIcons.file_text,
  'file_code': LucideIcons.file_code,
  'archive': LucideIcons.archive,
  'package': LucideIcons.package,
  'box': LucideIcons.box,
  'book': LucideIcons.book,
  'book_open': LucideIcons.book_open,
  'notebook_pen': LucideIcons.notebook_pen,
  'clipboard': LucideIcons.clipboard,
  'copy': LucideIcons.copy,
  'save': LucideIcons.save,
  'trash': LucideIcons.trash,
  'trash_2': LucideIcons.trash_2,
  'upload': LucideIcons.upload,
  'download': LucideIcons.download,
  'paperclip': LucideIcons.paperclip,

  // Text / editing
  'type': LucideIcons.type,
  'pen': LucideIcons.pen,
  'pen_line': LucideIcons.pen_line,
  'pencil': LucideIcons.pencil,
  'square_pen': LucideIcons.square_pen,
  'bold': LucideIcons.bold,
  'italic': LucideIcons.italic,
  'underline': LucideIcons.underline,
  'strikethrough': LucideIcons.strikethrough,
  'subscript': LucideIcons.subscript,
  'superscript': LucideIcons.superscript,
  'heading_1': LucideIcons.heading_1,
  'heading_2': LucideIcons.heading_2,
  'heading_3': LucideIcons.heading_3,
  'quote': LucideIcons.quote,
  'pilcrow': LucideIcons.pilcrow,
  'list': LucideIcons.list,
  'list_ordered': LucideIcons.list_ordered,
  'list_todo': LucideIcons.list_todo,
  'list_tree': LucideIcons.list_tree,
  'scissors': LucideIcons.scissors,
  'at_sign': LucideIcons.at_sign,
  'hash': LucideIcons.hash,
  'pin': LucideIcons.pin,
  'tag': LucideIcons.tag,

  // Media / communication
  'image': LucideIcons.image,
  'video': LucideIcons.video,
  'music': LucideIcons.music,
  'camera': LucideIcons.camera,
  'mic': LucideIcons.mic,
  'play': LucideIcons.play,
  'pause': LucideIcons.pause,
  'square_play': LucideIcons.square_play,
  'send': LucideIcons.send,
  'share': LucideIcons.share,
  'share_2': LucideIcons.share_2,
  'mail': LucideIcons.mail,
  'phone': LucideIcons.phone,
  'bell': LucideIcons.bell,
  'speaker': LucideIcons.speaker,
  'printer': LucideIcons.printer,
  'camera_off': LucideIcons.camera,

  // Layout / panels
  'layout_grid': LucideIcons.layout_grid,
  'grid_2x2': LucideIcons.grid_2x2,
  'panel_left': LucideIcons.panel_left,
  'panel_right': LucideIcons.panel_right,
  'layers': LucideIcons.layers,
  'layers_2': LucideIcons.layers_2,
  'square_dashed': LucideIcons.square_dashed,
  'square_menu': LucideIcons.square_menu,
  'square_terminal': LucideIcons.square_terminal,
  'square_code': LucideIcons.square_code,
  'square_function': LucideIcons.square_function,
  'square_chart_gantt': LucideIcons.square_chart_gantt,
  'maximize': LucideIcons.maximize,
  'minimize': LucideIcons.minimize,
  'maximize_2': LucideIcons.maximize_2,
  'minimize_2': LucideIcons.minimize_2,
  'expand': LucideIcons.expand,
  'shrink': LucideIcons.shrink,
  'fullscreen': LucideIcons.fullscreen,
  'crop': LucideIcons.crop,
  'zoom_in': LucideIcons.zoom_in,
  'zoom_out': LucideIcons.zoom_out,
  'scan': LucideIcons.scan,

  // Alignment
  'align_horizontal_justify_start': LucideIcons.align_horizontal_justify_start,
  'align_horizontal_justify_center':
      LucideIcons.align_horizontal_justify_center,
  'align_horizontal_justify_end': LucideIcons.align_horizontal_justify_end,
  'align_vertical_justify_center': LucideIcons.align_vertical_justify_center,
  'align_horizontal_distribute_center':
      LucideIcons.align_horizontal_distribute_center,
  'align_vertical_distribute_center':
      LucideIcons.align_vertical_distribute_center,
  'align_start_horizontal': LucideIcons.align_start_horizontal,
  'align_center_horizontal': LucideIcons.align_center_horizontal,
  'align_end_horizontal': LucideIcons.align_end_horizontal,
  'align_start_vertical': LucideIcons.align_start_vertical,
  'align_center_vertical': LucideIcons.align_center_vertical,
  'align_end_vertical': LucideIcons.align_end_vertical,
  'text_align_center': LucideIcons.text_align_center,
  'text_align_justify': LucideIcons.text_align_justify,

  // Shapes
  'circle': LucideIcons.circle,
  'square': LucideIcons.square,
  'triangle': LucideIcons.triangle,
  'circle_dot': LucideIcons.circle_dot,
  'palette': LucideIcons.palette,
  'brush': LucideIcons.brush,

  // Status
  'info': LucideIcons.info,
  'circle_alert': LucideIcons.circle_alert,
  'circle_check': LucideIcons.circle_check,
  'circle_x': LucideIcons.circle_x,
  'circle_ellipsis': LucideIcons.circle_ellipsis,
  'octagon_alert': LucideIcons.octagon_alert,
  'ban': LucideIcons.ban,
  'shield': LucideIcons.shield,
  'bug': LucideIcons.bug,
  'lock': LucideIcons.lock,
  'key': LucideIcons.key,
  'log_in': LucideIcons.log_in,
  'log_out': LucideIcons.log_out,

  // Users / people
  'user': LucideIcons.user,
  'users': LucideIcons.users,
  'user_round': LucideIcons.user_round,
  'users_round': LucideIcons.users_round,
  'circle_user': LucideIcons.circle_user,
  'user_plus': LucideIcons.user_plus,
  'user_minus': LucideIcons.user_minus,
  'user_check': LucideIcons.user_check,

  // Commerce / data
  'dollar_sign': LucideIcons.dollar_sign,
  'percent': LucideIcons.percent,
  'calculator': LucideIcons.calculator,
  'chart_bar': LucideIcons.chart_bar,
  'chart_line': LucideIcons.chart_line,
  'chart_pie': LucideIcons.chart_pie,
  'target': LucideIcons.target,
  'gauge': LucideIcons.gauge,

  // Tech / infrastructure
  'code': LucideIcons.code,
  'code_xml': LucideIcons.code_xml,
  'terminal': LucideIcons.terminal,
  'database': LucideIcons.database,
  'server': LucideIcons.server,
  'cloud': LucideIcons.cloud,
  'globe': LucideIcons.globe,
  'map': LucideIcons.map,
  'map_pin': LucideIcons.map_pin,
  'wifi': LucideIcons.wifi,
  'bluetooth': LucideIcons.bluetooth,
  'battery': LucideIcons.battery,
  'power': LucideIcons.power,
  'wrench': LucideIcons.wrench,
  'laptop': LucideIcons.laptop,
  'smartphone': LucideIcons.smartphone,

  // Misc
  'calendar': LucideIcons.calendar,
  'clock': LucideIcons.clock,
  'flag': LucideIcons.flag,
  'gift': LucideIcons.gift,
  'award': LucideIcons.award,
  'trophy': LucideIcons.trophy,
  'smile': LucideIcons.smile,
  'frown': LucideIcons.frown,
  'coffee': LucideIcons.coffee,
  'funnel': LucideIcons.funnel,
};

/// Alphabetically-sorted list of registry names. Safe to cache at module
/// scope because the registry is const.
final List<String> lucideIconNames = () {
  final names = lucideIconRegistry.keys.toList()..sort();
  return List<String>.unmodifiable(names);
}();

/// Default 12 icons shown when the picker opens with an empty search.
const List<String> lucideIconPresetNames = <String>[
  'house',
  'settings',
  'search',
  'user',
  'folder',
  'file_text',
  'bell',
  'star',
  'heart',
  'bookmark',
  'tag',
  'calendar',
];
