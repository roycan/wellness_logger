import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Simple debug utility to write test data to file system
/// This helps us debug storage persistence issues
class DebugStorage {
  static Future<void> writeDebugInfo(String info) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/debug_log.txt');
      final timestamp = DateTime.now().toIso8601String();
      await file.writeAsString('[$timestamp] $info\n', mode: FileMode.append);
      print('DEBUG: Wrote to ${file.path}: $info');
    } catch (e) {
      print('DEBUG: Failed to write debug info: $e');
    }
  }
  
  static Future<String> readDebugInfo() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/debug_log.txt');
      if (await file.exists()) {
        final content = await file.readAsString();
        print('DEBUG: Read debug log: ${content.length} chars');
        return content;
      } else {
        print('DEBUG: Debug log file does not exist');
        return 'Debug log file does not exist';
      }
    } catch (e) {
      print('DEBUG: Failed to read debug info: $e');
      return 'Error reading debug log: $e';
    }
  }
  
  static Future<void> clearDebugInfo() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/debug_log.txt');
      if (await file.exists()) {
        await file.delete();
        print('DEBUG: Cleared debug log');
      }
    } catch (e) {
      print('DEBUG: Failed to clear debug info: $e');
    }
  }
}
