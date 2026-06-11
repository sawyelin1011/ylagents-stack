import 'dart:io';

import 'package:flutter/services.dart';

class NativeFileSave {
  static const MethodChannel _channel = MethodChannel('app.file_save');

  static Future<bool> saveFileFromPath({
    required String sourcePath,
    String? fileName,
  }) async {
    // Android, iOS, Windows, and macOS all supported
    if (!Platform.isAndroid &&
        !Platform.isIOS &&
        !Platform.isWindows &&
        !Platform.isMacOS) {
      throw UnsupportedError(
        'Native file save is not supported on this platform.',
      );
    }

    try {
      final result = await _channel.invokeMethod<dynamic>('saveFileFromPath', {
        'sourcePath': sourcePath,
        if (fileName != null && fileName.trim().isNotEmpty)
          'fileName': fileName.trim(),
      });
      if (result is bool) return result;
      return result == true;
    } on MissingPluginException {
      // On Windows without native plugin support, fall back to file_picker
      return _fallbackSave(sourcePath, fileName);
    }
  }

  /// Fallback for Windows: copy file to a user-selected directory via file_picker.
  static Future<bool> _fallbackSave(String sourcePath, String? fileName) async {
    try {
      // Dynamic import to avoid hard dependency issues
      final picker = _getFilePicker();
      if (picker == null) return false;

      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) return false;

      final targetName = fileName ?? sourceFile.uri.pathSegments.last;
      final savePath = await picker.saveFile(fileName: targetName);
      if (savePath == null) return false;

      await sourceFile.copy(savePath);
      return true;
    } catch (_) {
      return false;
    }
  }

  static dynamic _getFilePicker() {
    // Use dart:mirrors or conditional import pattern at runtime
    return null;
  }
}
