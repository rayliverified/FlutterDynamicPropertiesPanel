import 'package:flutter/foundation.dart';

/// Represents a single level in the navigation stack for nested editing.
///
/// Each level captures the context needed to render and navigate back:
/// - [label] is displayed in the breadcrumb bar
/// - [type] is an optional type annotation shown instead of the label
/// - [value] is the data snapshot at this level
/// - [schema] is the optional property schema at this level
class NavigationLevel {
  const NavigationLevel({
    required this.label,
    this.type,
    this.value,
    this.schema,
    this.properties,
  });

  /// Display name for the breadcrumb.
  final String label;

  /// Optional type annotation shown in breadcrumb instead of [label].
  final String? type;

  /// The data value at this navigation level.
  final dynamic value;

  /// Optional schema describing the shape of [value].
  final Map<String, dynamic>? schema;

  /// Optional list of property definitions for this level.
  final List<dynamic>? properties;

  /// Whether this level represents a list item.
  bool get isListItem => _index != null;
  int? get _index => value is int ? value : null;

  NavigationLevel copyWith({
    String? label,
    String? type,
    dynamic value,
    Map<String, dynamic>? schema,
    List<dynamic>? properties,
  }) {
    return NavigationLevel(
      label: label ?? this.label,
      type: type ?? this.type,
      value: value ?? this.value,
      schema: schema ?? this.schema,
      properties: properties ?? this.properties,
    );
  }

  @override
  String toString() =>
      'NavigationLevel($label${type != null ? ': $type' : ''})';
}

/// Manages navigation state for nested property editing.
///
/// Maintains a stack of [NavigationLevel]s and notifies listeners when
/// the stack changes. The panel uses this to render breadcrumbs and
/// switch between root-level and nested property views.
///
/// Self-contained — no external dependencies. Consumers observe via
/// [addListener] / [removeListener] or read [breadcrumbs].
///
/// ```dart
/// final controller = NavigationController();
/// controller.navigateInto(label: 'layout', type: 'EdgeInsets');
/// // ... user edits nested properties ...
/// controller.navigateBack();
/// ```
class NavigationController extends ChangeNotifier {
  final List<NavigationLevel> _stack = [];

  /// Saved scroll offsets per navigation depth (depth → offset).
  final Map<int, double> _scrollOffsets = {};

  /// The direction of the last navigation transition.
  /// `true` = pushed forward, `false` = popped back.
  bool get lastTransitionWasForward => _lastForward;
  bool _lastForward = true;

  /// Save the scroll offset for the given [depth].
  void saveScrollOffset(int depth, double offset) {
    _scrollOffsets[depth] = offset;
  }

  /// Retrieve and clear the saved scroll offset for [depth].
  double? consumeScrollOffset(int depth) {
    return _scrollOffsets.remove(depth);
  }

  // ── Read ────────────────────────────────────────────────────────

  /// The current navigation stack (unmodifiable).
  List<NavigationLevel> get stack => List.unmodifiable(_stack);

  /// The current (deepest) level, or `null` if at root.
  NavigationLevel? get currentLevel => _stack.isEmpty ? null : _stack.last;

  /// Whether the stack is at root (empty).
  bool get isAtRoot => _stack.isEmpty;

  /// The depth of the navigation stack.
  int get depth => _stack.length;

  /// Breadcrumb-friendly list of levels.
  ///
  /// Each item contains a [NavigationLevel] and an optional [onTap]
  /// callback that pops to that level.
  List<NavigationBreadcrumb> get breadcrumbs {
    return [
      for (var i = 0; i < _stack.length; i++)
        NavigationBreadcrumb(
          level: _stack[i],
          isCurrent: i == _stack.length - 1,
          onTap: i < _stack.length - 1 ? () => popTo(i) : null,
        ),
    ];
  }

  // ── Mutate ──────────────────────────────────────────────────────

  /// Push a new [level] onto the stack.
  void push(NavigationLevel level) {
    _lastForward = true;
    _stack.add(level);
    notifyListeners();
  }

  /// Pop the top level from the stack.
  void pop() {
    if (_stack.isNotEmpty) {
      _lastForward = false;
      _stack.removeLast();
      notifyListeners();
    }
  }

  /// Pop to a specific stack [index] (inclusive).
  void popTo(int index) {
    if (index < 0 || index >= _stack.length) return;
    _lastForward = false;
    _stack.removeRange(index + 1, _stack.length);
    notifyListeners();
  }

  /// Replace the top level without double notification.
  ///
  /// Useful for updating the current level's value (e.g. when nested
  /// config changes) without popping and pushing which would fire twice.
  void replaceTop(NavigationLevel level) {
    if (_stack.isNotEmpty) {
      _stack[_stack.length - 1] = level;
      notifyListeners();
    }
  }

  /// Clear the entire navigation stack (return to root).
  void clear() {
    if (_stack.isNotEmpty) {
      _lastForward = false;
      _stack.clear();
      notifyListeners();
    }
  }

  /// Convenience: navigate into a nested property.
  void navigateInto({
    required String label,
    String? type,
    dynamic value,
    Map<String, dynamic>? schema,
    List<dynamic>? properties,
  }) {
    push(
      NavigationLevel(
        label: label,
        type: type,
        value: value,
        schema: schema,
        properties: properties,
      ),
    );
  }

  /// Convenience: navigate back one level.
  void navigateBack() => pop();

  /// Convenience: navigate back to root.
  void navigateToRoot() => clear();

  @override
  void dispose() {
    _stack.clear();
    super.dispose();
  }
}

/// A breadcrumb item produced by [NavigationController.breadcrumbs].
class NavigationBreadcrumb {
  const NavigationBreadcrumb({
    required this.level,
    required this.isCurrent,
    this.onTap,
  });

  final NavigationLevel level;
  final bool isCurrent;
  final VoidCallback? onTap;
}
