package com.example.aqi

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import java.io.File
import android.content.ContentValues
import android.os.Build
import android.provider.MediaStore

import java.io.OutputStream


class MainActivity: FlutterActivity() {

    private val METHOD_CHANNEL = "sensor_service_channel"
    private val EVENT_CHANNEL = "sensor_stream"

    companion object {
        var eventSink: EventChannel.EventSink? = null
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Method Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {


                    "saveImage"->{
                         val bytes = call.arguments as ByteArray

                    val resolver = applicationContext.contentResolver

                    val contentValues = ContentValues().apply {
                        put(MediaStore.Images.Media.DISPLAY_NAME, "image_${System.currentTimeMillis()}.jpg")
                        put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg")
                        put(MediaStore.Images.Media.RELATIVE_PATH, "DCIM/FlutterImages")
                    }

                    val uri = resolver.insert(
                        MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                        contentValues
                    )

                    uri?.let {
                        val outputStream: OutputStream? =
                            resolver.openOutputStream(it)
                        outputStream?.write(bytes)
                        outputStream?.close()
                        result.success("Saved")
                    } ?: result.error("ERROR", "Failed", null)
                    }        

                    "startService" -> {
                        val intent = Intent(this, SensorForegroundService::class.java)
                        startForegroundService(intent)
                        result.success("Service Started")
                    }
                    "stopService" -> {
                        val intent = Intent(this, SensorForegroundService::class.java)
                        stopService(intent)
                        result.success("Service Stopped")
                    }
                    "deleteFile" -> {
                        val flutterDir = File(filesDir.parent, "app_flutter")
                        val file = File(flutterDir, "sensor_log.txt")

                        if (file.exists()) {
                            file.delete()
                            result.success("File Deleted")
                        } else {
                            result.success("File Not Found")
                        }
                    }
                }
            }

        // Event Channel
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            })
    }
}