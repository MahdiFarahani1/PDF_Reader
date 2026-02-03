import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

class FileService {
  Future<File?> pickFile(List<String> allowedExtensions) async {
    // Permission handling for Windows is less strict for user-initiated picks,
    // but on Android/iOS logic might be needed.
    // FilePicker handles most permissions automatically.

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );

    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  // Copies the file to the app's local document directory
  Future<String> copyFileToAppDirectory(String sourcePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = p.basename(sourcePath);
    final sourceFile = File(sourcePath);
    final savedFile = await sourceFile.copy('${appDir.path}/$fileName');
    return savedFile.path;
  }

  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Scans the device for files with specific extensions.
  /// Returns a list of File objects.
  /// This is a simplified scanner that looks in common directories.
  Future<List<File>> scanDeviceForFiles(List<String> extensions) async {
    List<File> foundFiles = [];
    List<Directory> searchDirectories = [];

    // Request permissions on Android
    if (Platform.isAndroid) {
      if (await Permission.storage.status.isDenied) {
        await Permission.storage.request();
      }
      // For Android 11+ (API 30+)
      if (await Permission.manageExternalStorage.status.isDenied) {
        await Permission.manageExternalStorage.request();
      }
    }

    try {
      if (Platform.isAndroid) {
        // Scan root storage to find all files
        searchDirectories.add(Directory('/storage/emulated/0'));
      } else if (Platform.isWindows) {
        final profile = Platform.environment['USERPROFILE'];
        if (profile != null) {
          searchDirectories.add(Directory(p.join(profile, 'Downloads')));
          searchDirectories.add(Directory(p.join(profile, 'Documents')));
          searchDirectories.add(Directory(p.join(profile, 'Desktop')));
        }
      } else if (Platform.isIOS) {
        final docs = await getApplicationDocumentsDirectory();
        searchDirectories.add(docs);
      }

      for (var dir in searchDirectories) {
        if (await dir.exists()) {
          // Increased maxDepth for better reach since we are scanning from root in Android
          // but we will be careful with exclusions in recursiveSearch
          await _recursiveSearch(dir, extensions, foundFiles, maxDepth: 4);
        }
      }
    } catch (e) {
      debugPrint("Error scanning files: $e");
    }

    return foundFiles;
  }

  Future<void> _recursiveSearch(
    Directory dir,
    List<String> extensions,
    List<File> foundFiles, {
    int currentDepth = 0,
    int maxDepth = 2,
  }) async {
    if (currentDepth > maxDepth) return;

    try {
      final entities = dir.list(followLinks: false);
      await for (var entity in entities) {
        if (entity is File) {
          final ext = p
              .extension(entity.path)
              .toLowerCase()
              .replaceAll('.', '');
          if (extensions.contains(ext)) {
            foundFiles.add(entity);
          }
        } else if (entity is Directory) {
          if (!entity.path.contains('/.') && !entity.path.contains(r'\.')) {
            // Skip 'Android' system folder to avoid permissions issues and junk files
            if (p.basename(entity.path) == 'Android') continue;

            await _recursiveSearch(
              entity,
              extensions,
              foundFiles,
              currentDepth: currentDepth + 1,
              maxDepth: maxDepth,
            );
          }
        }
      }
    } catch (e) {
      // Ignore access errors
    }
  }
}
