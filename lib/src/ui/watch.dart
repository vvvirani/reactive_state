import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../reactive_base.dart';
import '../reactive_tracker.dart';

/// ---------------------------------------------------------------------------
/// Reactive widget observer
/// ---------------------------------------------------------------------------

/// A widget that automatically rebuilds when any accessed `Reactive`
/// value changes.
///
/// Dependencies are detected automatically by tracking
/// which reactive values are accessed during the [builder] execution.
///
/// No manual dependency list is required.
///
/// Example:
/// ```dart
/// Watch(
///   builder: () => Column(
///     children: [
///       Text('${counter.value}'),
///       Text(name.value),
///       Switch(
///         value: isDark.value,
///         onChanged: (v) => isDark.value = v,
///       ),
///     ],
///   ),
/// )
/// ```
///
/// Conditional dependencies are also supported:
///
/// ```dart
/// Watch(
///   builder: () => isDark.value
///       ? Text(darkLabel.value)
///       : Text(lightLabel.value),
/// )
/// ```
///
/// In this case:
/// - `darkLabel` is only tracked when `isDark == true`
/// - `lightLabel` is only tracked when `isDark == false`
class Watch extends StatefulWidget {
  /// Builder executed whenever tracked dependencies change.
  final Widget Function() builder;

  const Watch({super.key, required this.builder});

  @override
  State<Watch> createState() => _WatchState();
}

/// Internal state for [Watch].
class _WatchState extends State<Watch> {
  /// Currently subscribed reactive dependencies.
  Set<ReactiveBase> _subscribed = {};

  /// Shared listener attached to all tracked dependencies.
  late final VoidCallback _listener;

  @override
  void initState() {
    super.initState();

    _listener = _onNotify;

    // Initial dependency collection before the first real build.
    _collectDependencies();
  }

  /// Called when any subscribed reactive dependency changes.
  void _onNotify() {
    if (mounted) {
      (context as Element).markNeedsBuild();
    }
  }

  /// Executes the builder while dependency tracking is enabled.
  ///
  /// Used to discover all accessed reactive dependencies.
  ///
  /// The returned widget is ignored because this is only
  /// a dependency discovery pass.
  void _collectDependencies() {
    ReactiveTracker.start();

    widget.builder();

    final Set<ReactiveBase> dependencies = ReactiveTracker.stop();

    _updateSubscriptions(dependencies);
  }

  /// Updates reactive subscriptions.
  ///
  /// Removes old listeners and subscribes to new dependencies.
  void _updateSubscriptions(Set<ReactiveBase> newDependencies) {
    if (setEquals(newDependencies, _subscribed)) {
      return;
    }

    for (final ReactiveBase reactive in _subscribed) {
      reactive.removeListener(_listener);
    }

    _subscribed = newDependencies;

    for (final ReactiveBase reactive in _subscribed) {
      reactive.addListener(_listener);
    }
  }

  @override
  void didUpdateWidget(Watch oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Recollect dependencies if the builder changes.
    if (oldWidget.builder != widget.builder) {
      _collectDependencies();
    }
  }

  @override
  void dispose() {
    for (final ReactiveBase reactive in _subscribed) {
      reactive.removeListener(_listener);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Real build with dependency tracking enabled.
    ReactiveTracker.start();

    final Widget result = widget.builder();

    final Set<ReactiveBase> dependencies = ReactiveTracker.stop();

    _updateSubscriptions(dependencies);

    return result;
  }
}
