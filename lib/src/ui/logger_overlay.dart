import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:reactive_flutter/reactive_flutter.dart';

class LoggerOverlay extends StatefulWidget {
  final ReactiveLogger logger;
  final Widget child;

  const LoggerOverlay({
    super.key,
    required this.logger,
    required this.child,
  });

  @override
  State<LoggerOverlay> createState() => _LoggerOverlayState();
}

class _LoggerOverlayState extends State<LoggerOverlay> {
  final Reactive<bool> _open = Reactive<bool>(false);

  final Reactive<double> _dx = Reactive<double>(20);
  final Reactive<double> _dy = Reactive<double>(100);

  static const double _buttonSize = 60;
  static const double _screenPadding = 20;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return widget.child;

    return LayoutBuilder(
      builder: (context, constraints) {
        final ThemeData theme = Theme.of(context);

        return Watch(
          builder: () {
            return Stack(
              children: [
                widget.child,
                Positioned(
                  left: _dx.value,
                  top: _dy.value,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      _dx.value += details.delta.dx;
                      _dy.value += details.delta.dy;

                      // Prevent outside screen with padding
                      _dx.value = _dx.value.clamp(
                        _screenPadding,
                        constraints.maxWidth - _buttonSize - _screenPadding,
                      );

                      _dy.value = _dy.value.clamp(
                        _screenPadding,
                        constraints.maxHeight - _buttonSize - _screenPadding,
                      );
                    },
                    onTap: () => _open.value = true,
                    child: Container(
                      width: _buttonSize,
                      height: _buttonSize,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.bug_report_rounded,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
                if (_open.value)
                  Positioned.fill(
                    child: LoggerView.build(
                      logger: widget.logger,
                      onClose: () => _open.value = false,
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
