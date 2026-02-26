import 'package:flutter/services.dart';

class SensorServiceController {
  static const MethodChannel _channel = MethodChannel('sensor_service_channel');

  static Future<void> start() async {
    await _channel.invokeMethod("startService");
  }

  static Future<void> stop() async {
    await _channel.invokeMethod("stopService");
  }

  static Future<void> delete() async {
    await _channel.invokeMethod("deleteFile");
  }

  static const EventChannel _eventChannel = EventChannel("sensor_stream");

  static Stream<double> sensorStream() {
    return _eventChannel.receiveBroadcastStream().map((event) {
      final data = Map<String, dynamic>.from(event);
      return (data["x"] as double); // rotate based on X
    });
  }
}
