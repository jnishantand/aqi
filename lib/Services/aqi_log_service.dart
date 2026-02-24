import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class LogService {
  static Future<File> _getLogFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/aqi_logs.txt');

    if (!(await file.exists())) {
      await file.create(recursive: true);
    }

    return file;
  }

  // Write Log
  static Future<void> writeLog({
    String? sensordata,
    required String city,
    required double aqi,
    required String level,
  }) async {
    final file = await _getLogFile();

    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    final logLine =
        '$formattedDate | $city | AQI: ${aqi.toStringAsFixed(0)} | Level: $level\n | Sensor: $sensordata';

    await file.writeAsString(logLine, mode: FileMode.append);
  }

  // Read Logs
  static Future<String> readLogs() async {
    final file = await _getLogFile();
    return file.readAsString();
  }

  // Delete Logs
  static Future<void> deleteLogs() async {
    final file = await _getLogFile();
    if (await file.exists()) {
      await file.writeAsString('');
    }
  }

  // Share Logs
  static Future<void> shareLogs() async {
    final file = await _getLogFile();
    await Share.shareXFiles([XFile(file.path)], text: 'My AQI History Logs');
  }

  // Export Logs (copy to Downloads folder for Android)
  static Future<String?> exportLogs() async {
    final file = await _getLogFile();

    if (Platform.isAndroid) {
      final directory = Directory('/storage/emulated/0/Download');
      final exportFile = File(
        '${directory.path}/aqi_logs_export_${DateTime.now().millisecondsSinceEpoch}.txt',
      );

      await exportFile.writeAsString(await file.readAsString());
      return exportFile.path;
    }

    return null;
  }
}

final aqiReadprovider = FutureProvider<String>((ref) => LogService.readLogs());

final aqiDeleteprovider = FutureProvider<void>(
  (ref) => LogService.deleteLogs(),
);

final aqiWriterProvider =
    FutureProvider.family<void, ({String city, double aqi, String level})>((
      ref,
      data,
    ) {
      return LogService.writeLog(
        city: data.city,
        aqi: data.aqi,
        level: data.level,
      );
    });
