import 'package:flutter/widgets.dart';

/// Maps stable semantic identifiers (e.g. `campaign.screen`,
/// `campaign.screen.carousel`) to [GlobalKey]s so tooling — storyboards,
/// dynamic property panels, tests — can read and mutate live [State] objects
/// without the production widget tree knowing anything about the tooling.
///
/// Production code only receives a key from the outside:
///
/// ```dart
/// CampaignScreen(
///   key: StoryboardStateRegistry.instance
///       .key<CampaignScreenState>('campaign.screen'),
/// )
/// ```
///
/// Tooling then stages any state programmatically:
///
/// ```dart
/// StoryboardStateRegistry.instance.update<CampaignScreenState>(
///   'campaign.screen',
///   (state) {
///     state.loading = false;
///     state.cards = stagedCards;
///   },
/// );
/// ```
///
/// Rules:
/// - One stable ID maps to one [GlobalKey]. Never create keys inside `build()`.
/// - A [GlobalKey] may be mounted on only one widget at a time; repeated
///   components need instance IDs (`profileSwitcher.profile.1001`).
/// - Stateless children are controlled through parent constructor data, not
///   keys. Only StatefulWidgets with genuinely independent state get keys.
/// - All mutation goes through [update], which wraps the target's `setState`.
class StoryboardStateRegistry {
  StoryboardStateRegistry._();

  static final StoryboardStateRegistry instance = StoryboardStateRegistry._();

  final Map<String, GlobalKey<State>> _keys = {};

  /// Returns the stable key for [id], creating it on first request.
  ///
  /// Throws [StateError] if [id] was previously registered for a different
  /// [State] type.
  GlobalKey<T> key<T extends State>(String id) {
    final existing = _keys[id];
    if (existing != null) {
      if (existing is! GlobalKey<T>) {
        throw StateError(
          'Storyboard key "$id" was registered for a different State type '
          '(${existing.runtimeType}, requested GlobalKey<$T>).',
        );
      }
      return existing;
    }
    final created = GlobalKey<T>(debugLabel: 'storyboard:$id');
    _keys[id] = created;
    return created;
  }

  /// The live [State] for [id], or null if unregistered or not mounted.
  T? state<T extends State>(String id) {
    final registered = _keys[id];
    if (registered == null) return null;
    if (registered is! GlobalKey<T>) {
      throw StateError(
        'Storyboard state "$id" does not match requested type $T.',
      );
    }
    return registered.currentState;
  }

  /// Read a value out of the live state. Returns null when unmounted.
  R? read<T extends State, R>(String id, R Function(T state) reader) {
    final target = state<T>(id);
    return target == null ? null : reader(target);
  }

  /// Mutate the live state inside its own `setState`. Returns false when the
  /// target isn't mounted.
  bool update<T extends State>(String id, void Function(T state) mutation) {
    final target = state<T>(id);
    if (target == null || !target.mounted) return false;
    // ignore: invalid_use_of_protected_member
    target.setState(() => mutation(target));
    return true;
  }

  /// Whether any registered key currently has a mounted state.
  bool get isMounted =>
      _keys.values.any((key) => key.currentState?.mounted ?? false);

  /// IDs currently registered (mounted or not).
  Iterable<String> get ids => _keys.keys;

  /// Remove a run-specific key when a storyboard scenario is destroyed.
  void remove(String id) => _keys.remove(id);

  /// Drop all registered keys.
  void clear() => _keys.clear();
}
