import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reactive_flutter/src/isolate/reactive_isolate_task.dart';
import 'package:reactive_flutter/src/log/clear_policy.dart';
import 'package:reactive_flutter/src/log/log_level.dart';
import 'package:reactive_flutter/src/log/logger_state.dart';
import 'package:reactive_flutter/src/reactive.dart';

// ── ReactiveLogger ────────────────────────────────────────────────────────────

/// Lightweight file-based reactive logger for Flutter.
///
/// Features:
/// - Persistent log file storage
/// - Reactive logger state updates
/// - Auto file clearing policies
/// - Buffered disk writes
/// - Console logging support
/// - Error & stack trace logging
/// - Metadata persistence
/// - Log level filtering
///
/// Example:
/// ```dart
/// final ReactiveLogger logger = ReactiveLogger(
///   fileName: 'app_logs',
///   clearPolicy: ClearPolicy.weekly,
/// );
///
/// await logger.init();
///
/// logger.info('Application started');
/// logger.error('API failed', error: exception);
/// ```
class ReactiveLogger extends Reactive<LoggerState> {
  ReactiveLogger({
    this.fileName = 'app_logs',
    this.clearPolicy = ClearPolicy.weekly,
    this.minLevel = LogLevel.debug,
    this.printToConsole = true,
  }) : super(const LoggerState());

  /// Base file name used for the log file.
  ///
  /// Example:
  /// `app_logs.log`
  final String fileName;

  /// Determines when logs should be cleared automatically.
  final ClearPolicy clearPolicy;

  /// Minimum log level allowed to be written.
  ///
  /// Logs below this level are ignored.
  final LogLevel minLevel;

  /// Whether logs should also be printed to console in debug mode.
  final bool printToConsole;

  /// Internal log file reference.
  File? _file;

  /// Metadata file storing log information.
  File? _metaFile;

  /// Periodic timer used for buffered flushing.
  Timer? _flushTimer;

  /// In-memory log buffer.
  final StringBuffer _buffer = StringBuffer();

  // ── Initialization ────────────────────────────────────────────────────────

  /// Initializes the logger.
  ///
  /// Responsibilities:
  /// - creates log files
  /// - loads metadata
  /// - applies clear policy
  /// - restores logger state
  /// - starts periodic flushing
  Future<void> init() async {
    final Directory dir = await getApplicationSupportDirectory();

    _file = File('${dir.path}/.$fileName.log');

    _metaFile = File('${dir.path}/$fileName.meta');

    // Auto-create log file if missing.
    if (!(_file?.existsSync() ?? false)) {
      await _file?.create(recursive: true);

      await _writeHeader();
    }

    // Apply auto-clear policy.
    await _checkClearPolicy();

    // Load metadata.
    final Map<String, String> meta = await _loadMeta();

    final DateTime? lastCleared = meta['lastCleared'] != null
        ? DateTime.tryParse(meta['lastCleared']!)
        : null;

    final int totalLines = int.tryParse(meta['totalLines'] ?? '0') ?? 0;

    value = LoggerState(
      isReady: true,
      totalLogs: totalLines,
      lastCleared: lastCleared,
    );

    // Flush memory buffer to disk every 2 seconds.
    _flushTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _flush(),
    );

    info(
      'ReactiveLogger Ready • Clear Policy: ${clearPolicy.displayName}',
      tag: 'Logger',
    );
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Write a debug log.
  void debug(
    String msg, {
    String? tag,
    Map<String, dynamic>? extra,
  }) {
    _log(
      LogLevel.debug,
      msg,
      tag: tag,
      extra: extra,
    );
  }

  /// Write an informational log.
  void info(
    String msg, {
    String? tag,
    Map<String, dynamic>? extra,
  }) {
    _log(
      LogLevel.info,
      msg,
      tag: tag,
      extra: extra,
    );
  }

  /// Write a warning log.
  void warning(
    String msg, {
    String? tag,
    Object? error,
    Map<String, dynamic>? extra,
  }) {
    _log(
      LogLevel.warning,
      msg,
      tag: tag,
      error: error,
      extra: extra,
    );
  }

  /// Write an error log.
  ///
  /// Supports:
  /// - exceptions
  /// - stack traces
  /// - extra metadata
  void error(
    String msg, {
    String? tag,
    Object? error,
    StackTrace? stack,
    Map<String, dynamic>? extra,
  }) {
    _log(
      LogLevel.error,
      msg,
      tag: tag,
      error: error,
      stack: stack,
      extra: extra,
    );
  }

  /// Write a fatal log.
  ///
  /// Intended for critical unrecoverable failures.
  void fatal(
    String msg, {
    String? tag,
    Object? error,
    StackTrace? stack,
    Map<String, dynamic>? extra,
  }) {
    _log(
      LogLevel.fatal,
      msg,
      tag: tag,
      error: error,
      stack: stack,
      extra: extra,
    );
  }

  // ── File Operations ───────────────────────────────────────────────────────

  /// Clears the current log file contents.
  ///
  /// The file itself remains and a fresh header is written.
  Future<void> clearFile() async {
    await _flush();

    await _file?.writeAsString('');

    await _writeHeader();

    await _saveMeta(
      lastCleared: DateTime.now(),
      totalLines: 0,
    );

    value = value.copyWith(
      totalLogs: 0,
      lastCleared: DateTime.now(),
    );

    info('Log file cleared', tag: 'Logger');
  }

  /// Deletes the log file completely.
  ///
  /// A new empty file is recreated automatically.
  Future<void> deleteFile() async {
    await _flush();

    if (await (_file?.exists() ?? Future.value(false))) {
      await _file!.delete();
    }

    if (await (_metaFile?.exists() ?? Future.value(false))) {
      await _metaFile!.delete();
    }

    await _file?.create(recursive: true);

    await _writeHeader();

    value = const LoggerState(isReady: true);

    info(
      'Log file deleted and recreated',
      tag: 'Logger',
    );
  }

  final ReactiveIsolateTask<String> _readRawTask =
      ReactiveIsolateTask<String>();
  final ReactiveIsolateTask<List<String>> _readLinesTask =
      ReactiveIsolateTask<List<String>>();

  /// Returns the full log file path.
  Future<String?> getFilePath() async => _file?.path;

  /// Reads raw file content in isolate
  Future<String> readRaw() async {
    final String? path = _file?.path;
    if (path == null) return '';

    return await _readRawTask.runOrThrow<String>(
      ReactiveTaskPayload(
        input: path,
        callback: (path) {
          final File file = File(path);
          if (!file.existsSync()) return '';
          return file.readAsStringSync();
        },
      ),
    );
  }

  /// Reads all log lines in isolate
  Future<List<String>> readLines() async {
    final String? path = _file?.path;
    if (path == null) return [];

    return await _readLinesTask.runOrThrow<String>(
      ReactiveTaskPayload(
        input: path,
        callback: (path) {
          final File file = File(path);
          if (!file.existsSync()) return [];
          return file
              .readAsStringSync()
              .split('\n')
              .where((l) => l.isNotEmpty)
              .toList();
        },
      ),
    );
  }

  /// Disposes the logger.
  ///
  /// Cancels timers and flushes pending logs.
  void dispose() {
    _flushTimer?.cancel();
    _flush();
  }

  // ── Internal Logging ──────────────────────────────────────────────────────

  /// Internal log writer.
  ///
  /// Handles:
  /// - formatting
  /// - buffering
  /// - console printing
  /// - stack traces
  /// - metadata updates
  void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stack,
    Map<String, dynamic>? extra,
  }) {
    // Ignore logs below minimum level.
    if (level.index < minLevel.index) return;

    final DateTime now = DateTime.now();

    final String ts = '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}.'
        '${now.millisecond.toString().padLeft(3, '0')}';

    final String lv = '[${level.displayName}]'.padRight(2);

    final String tg = tag != null ? '[$tag] ' : '';

    final String line = '$ts $lv $tg$message';

    _buffer.writeln(line);

    if (error != null) {
      _buffer.writeln('     └─ error: $error');
    }

    if (stack != null) {
      _buffer.writeln('     └─ stack:');

      for (final String l in stack.toString().trimRight().split('\n').take(8)) {
        _buffer.writeln('              $l');
      }
    }

    if (extra != null) {
      _buffer.writeln('     └─ extra: $extra');
    }

    // Console output for debug builds.
    if (printToConsole && kDebugMode) {
      debugPrint('${level.emoji} $line');

      if (error != null) {
        debugPrint('     └─ $error');
      }
    }

    value = value.copyWith(
      totalLogs: value.totalLogs + 1,
    );
  }

  // ── Disk Flush ────────────────────────────────────────────────────────────

  /// Flushes buffered logs to disk.
  Future<void> _flush() async {
    if (_buffer.isEmpty || _file == null) return;

    final String content = _buffer.toString();

    _buffer.clear();

    try {
      await _file?.writeAsString(content, mode: FileMode.append);

      await _saveMeta(totalLines: value.totalLogs);
    } catch (e) {
      debugPrint('ReactiveLogger flush error: $e');
    }
  }

  // ── Header ────────────────────────────────────────────────────────────────

  /// Writes the log file header.
  ///
  /// Includes:
  /// - platform
  /// - date/time
  /// - clear policy
  Future<void> _writeHeader() async {
    String two(int n) => n.toString().padLeft(2, '0');

    final DateTime now = DateTime.now().toLocal();

    final int hour = now.hour > 12 ? now.hour - 12 : now.hour;

    final String period = now.hour >= 12 ? 'PM' : 'AM';

    final String formatted = '${two(now.day)} '
        '${two(now.month)} '
        '${now.year} '
        '${two(hour == 0 ? 12 : hour)}:'
        '${two(now.minute)} '
        '$period';

    final String line = '=' * 41;

    final String header = '$line\n'
        'Platform: ${defaultTargetPlatform.name.toUpperCase()} • Date & Time: $formatted\n'
        'Logs auto-clear policy: ${clearPolicy.displayName}\n'
        '$line\n\n';

    await _file?.writeAsString(
      header,
      mode: FileMode.append,
    );
  }

  // ── Clear Policy ──────────────────────────────────────────────────────────

  /// Checks whether logs should be auto-cleared.
  Future<void> _checkClearPolicy() async {
    if (clearPolicy == ClearPolicy.never) {
      return;
    }

    final Duration? threshold = clearPolicy.duration;

    if (threshold == null) return;

    final Map<String, String> meta = await _loadMeta();

    final DateTime? lastCleared = meta['lastCleared'] != null
        ? DateTime.tryParse(meta['lastCleared']!)
        : null;

    final bool shouldClear = lastCleared == null ||
        DateTime.now().difference(lastCleared) >= threshold;

    if (shouldClear) {
      await clearFile();
    }
  }

  // ── Metadata ──────────────────────────────────────────────────────────────

  /// Loads metadata from disk.
  Future<Map<String, String>> _loadMeta() async {
    try {
      if (await (_metaFile?.exists() ?? Future.value(false))) {
        final List<String> lines = await _metaFile!.readAsLines();

        final Map<String, String> map = <String, String>{};

        for (final String l in lines) {
          final int i = l.indexOf('=');

          if (i > 0) {
            map[l.substring(0, i).trim()] = l.substring(i + 1).trim();
          }
        }

        return map;
      }
    } catch (_) {}

    return {};
  }

  /// Saves metadata to disk.
  Future<void> _saveMeta({
    DateTime? lastCleared,
    int? totalLines,
  }) async {
    final Map<String, String> meta = await _loadMeta();

    if (lastCleared != null) {
      meta['lastCleared'] = lastCleared.toIso8601String();
    }

    if (totalLines != null) {
      meta['totalLines'] = totalLines.toString();
    }

    final String content =
        meta.entries.map((e) => '${e.key}=${e.value}').join('\n');

    await _metaFile?.writeAsString(content);
  }

  bool get isLoading {
    return _readRawTask.isLoading || _readLinesTask.isLoading;
  }
}
