import 'package:getaqi/Services/aqi_log_service.dart';
import 'package:workmanager/workmanager.dart';

const String aqiTask = "fetchAqiTask";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // final accel = await accelerometerEvents.first;
      //"${accel.x}, ${accel.y}, ${accel.z}
      await LogService.writeLog(
        city: "indore",
        aqi: 100,
        level: "Medium",
        sensordata: "No data",
      ); // Important: reinitialize any plugins or services you need here, as this runs in a separate isolate
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  });
}
