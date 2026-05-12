import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:reactive_flutter/reactive_flutter.dart';

class LoggerExamplePage extends StatelessWidget {
  const LoggerExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reactive Logger Example')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Stats ───────────────────────────────────────────
            Watch(
              builder: () {
                final LoggerState s = logger.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ready       : ${s.isReady}'),
                    Text('Total lines : ${s.totalLogs}'),
                    if (s.lastCleared != null)
                      Text('Last cleared: ${s.lastCleared}'),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            // ── Log buttons ─────────────────────────────────────
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton(
                  onPressed: () {
                    logger.debug('User tapped button', tag: 'UI');
                  },
                  child: const Text('Debug'),
                ),
                ElevatedButton(
                  onPressed: () {
                    logger.info(
                      'Data loaded successfully',
                      tag: 'API',
                      extra: {'count': 42},
                    );
                  },
                  child: const Text('Info'),
                ),
                ElevatedButton(
                  onPressed: () {
                    logger.warning(
                      'Slow response detected',
                      tag: 'API',
                      error: 'Response time: 3200ms',
                      extra: {'endpoint': '/posts', 'ms': 3200},
                    );
                  },
                  child: const Text('Warning'),
                ),
                ElevatedButton(
                  onPressed: () {
                    try {
                      throw Exception('Failed to parse JSON response');
                    } catch (e, stack) {
                      logger.error(
                        'API call failed',
                        tag: 'API',
                        error: e,
                        stack: stack,
                        extra: {'url': '/posts/1'},
                      );
                    }
                  },
                  child: const Text('Error'),
                ),
                ElevatedButton(
                  onPressed: () {
                    logger.fatal(
                      'App is in unrecoverable state',
                      tag: 'App',
                      error: 'OutOfMemoryError',
                    );
                  },
                  child: const Text('Fatal'),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── File operations ──────────────────────────────────
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton(
                  onPressed: () => logger.clearFile(),
                  child: const Text('Clear file'),
                ),
                ElevatedButton(
                  onPressed: () => logger.deleteFile(),
                  child: const Text('Delete file'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final String? path = await logger.getFilePath();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(path ?? 'No file')),
                      );
                    }
                  },
                  child: const Text('Get path'),
                ),
                ElevatedButton(
                  onPressed: () {
                    LoggerView.open(context, logger: logger);
                  },
                  child: const Text('Open Log Viewer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
