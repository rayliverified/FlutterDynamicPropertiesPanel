import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Describes a change emitted by [DynamicPropertiesController.commits].
///
/// Single-key commits set [key] and [value]. Bulk commits (e.g. preset
/// application) set [bulkValues] and leave [key]/[value] null.
@immutable
class PropertyChange {
  const PropertyChange(this.key, this.value) : bulkValues = null;
  const PropertyChange.bulk(this.bulkValues) : key = null, value = null;

  final String? key;
  final dynamic value;
  final Map<String, dynamic>? bulkValues;

  bool get isBulk => bulkValues != null;
}

/// Holds property values as independent [ValueNotifier]s so that changing a
/// single property only rebuilds listeners of that property — not the entire
/// panel or every host subtree.
///
/// ## Reading and writing
///
/// ```dart
/// final controller = DynamicPropertiesController(initial: loadedValues);
///
/// // Read:
/// final title = controller['title'] as String? ?? 'Untitled';
///
/// // Write (fires listeners and the commits stream):
/// controller['enabled'] = true;
///
/// // Equivalent form:
/// controller.setValue('enabled', true);
/// ```
///
/// ## Listening
///
/// Every write fires:
/// - The per-key [ValueNotifier] (via [notifierFor]) — granular rebuilds.
/// - [ChangeNotifier.notifyListeners] — any-change rebuilds (e.g. JSON preview).
/// - The [commits] stream — for save/persist consumers.
///
/// Hosts that persist to disk on every change should **debounce in their own
/// handler** — the library fires on every user interaction (including drag
/// ticks) and does not attempt to distinguish "save-worthy" events.
///
/// ```dart
/// Timer? saveTimer;
/// controller.commits.listen((_) {
///   saveTimer?.cancel();
///   saveTimer = Timer(const Duration(milliseconds: 300), () {
///     saveToDisk(controller.snapshot());
///   });
/// });
/// ```
///
/// The caller owns the controller's lifecycle and must call [dispose].
class DynamicPropertiesController extends ChangeNotifier {
  DynamicPropertiesController({Map<String, dynamic> initial = const {}}) {
    for (final entry in initial.entries) {
      _notifiers[entry.key] = ValueNotifier<dynamic>(entry.value);
      if (entry.value != null) _touched.add(entry.key);
    }
  }

  final Map<String, ValueNotifier<dynamic>> _notifiers = {};

  /// Tracks keys that have ever been explicitly set (either via initial values
  /// or [setValue]). Drives the "modified from default" indicator.
  final Set<String> _touched = {};

  final StreamController<PropertyChange> _commitController =
      StreamController<PropertyChange>.broadcast();

  bool _disposed = false;

  /// Returns the notifier for [key], creating one if it doesn't exist yet.
  ///
  /// Accessing a notifier does NOT mark the key as "touched" — binding a UI
  /// control to a property shouldn't count as the user having set a value.
  ValueNotifier<dynamic> notifierFor(String key) {
    return _notifiers.putIfAbsent(key, () => ValueNotifier<dynamic>(null));
  }

  /// Current value for [key] without subscribing.
  dynamic operator [](String key) => _notifiers[key]?.value;

  /// Write a value and fire all listeners + the [commits] stream. Equivalent
  /// to [setValue].
  void operator []=(String key, dynamic value) => setValue(key, value);

  /// Whether [key] has been explicitly set. Used for "is this property
  /// modified from its default" semantics.
  bool hasValue(String key) => _touched.contains(key);

  /// Set of keys that have been explicitly set.
  Iterable<String> get touchedKeys => _touched;

  /// Update a property's value. Fires the per-key notifier, the controller's
  /// [ChangeNotifier], and the [commits] stream.
  void setValue(String key, dynamic value) {
    notifierFor(key).value = value;
    if (value != null) {
      _touched.add(key);
    } else {
      _touched.remove(key);
    }
    if (!_disposed) {
      notifyListeners();
      _commitController.add(PropertyChange(key, value));
    }
  }

  /// Bulk-replace multiple values at once (e.g. preset application). Each
  /// affected notifier fires exactly once, then one bulk [PropertyChange] is
  /// emitted on [commits].
  void applyAll(Map<String, dynamic> values) {
    for (final entry in values.entries) {
      notifierFor(entry.key).value = entry.value;
      if (entry.value != null) {
        _touched.add(entry.key);
      } else {
        _touched.remove(entry.key);
      }
    }
    if (!_disposed) {
      notifyListeners();
      _commitController.add(PropertyChange.bulk(Map.of(values)));
    }
  }

  /// Silent bulk apply — updates notifiers without firing [commits]. Used
  /// internally by the panel to sync external value pushes without echoing
  /// them back to the host's onChanged callback.
  @internal
  void applyAllSilent(Map<String, dynamic> values) {
    for (final entry in values.entries) {
      notifierFor(entry.key).value = entry.value;
      if (entry.value != null) {
        _touched.add(entry.key);
      } else {
        _touched.remove(entry.key);
      }
    }
    if (!_disposed) notifyListeners();
  }

  /// Remove a property entirely (disposes its notifier if present).
  void remove(String key) {
    _notifiers.remove(key)?.dispose();
    _touched.remove(key);
  }

  /// Deep-copied snapshot of all touched, non-null values. Safe for persist.
  Map<String, dynamic> snapshot() {
    final out = <String, dynamic>{};
    for (final key in _touched) {
      final v = _notifiers[key]?.value;
      if (v != null) out[key] = v;
    }
    try {
      return jsonDecode(jsonEncode(out)) as Map<String, dynamic>;
    } catch (_) {
      return Map.of(out);
    }
  }

  /// Shallow snapshot — same keys as [snapshot] but without the JSON deep
  /// copy. Cheap; use when you don't need immutability.
  Map<String, dynamic> snapshotShallow() {
    final out = <String, dynamic>{};
    for (final key in _touched) {
      final v = _notifiers[key]?.value;
      if (v != null) out[key] = v;
    }
    return out;
  }

  /// Emits on every write. Hosts that persist should debounce in their
  /// handler — this fires on every drag tick, keystroke, and preset apply.
  Stream<PropertyChange> get commits => _commitController.stream;

  @override
  void dispose() {
    _disposed = true;
    for (final notifier in _notifiers.values) {
      notifier.dispose();
    }
    _notifiers.clear();
    _touched.clear();
    _commitController.close();
    super.dispose();
  }
}
