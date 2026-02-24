package com.example.aqi

import android.app.*
import android.content.Intent
import android.hardware.*
import android.os.IBinder
import android.os.Build
import androidx.core.app.NotificationCompat
import java.io.File
import java.io.FileWriter
import java.text.SimpleDateFormat
import java.util.*

class SensorForegroundService : Service(), SensorEventListener {

    private lateinit var sensorManager: SensorManager
    private var accelerometer: Sensor? = null
    private val channelId = "sensor_service_channel"

    override fun onCreate() {
        super.onCreate()

        createNotificationChannel()

        val notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("Sensor Logging")
            .setContentText("Collecting accelerometer data")
            .setSmallIcon(android.R.drawable.ic_menu_compass)
            .build()

        startForeground(1, notification)

        sensorManager = getSystemService(SENSOR_SERVICE) as SensorManager
        accelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)

        accelerometer?.also {
            sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_NORMAL)
        }
    }

    override fun onSensorChanged(event: SensorEvent?) {
    event?.let {

        val x = it.values[0]
        val y = it.values[1]
        val z = it.values[2]

        // 🔥 Send to Flutter
        val data = mapOf(
            "x" to x,
            "y" to y,
            "z" to z
        )

        MainActivity.eventSink?.success(data)

        // Save to file (your existing logic)
        val timestamp = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())
            .format(Date())

        val line = "$timestamp, $x, $y, $z\n"

        val flutterDir = File(filesDir.parent, "app_flutter")
        if (!flutterDir.exists()) {
            flutterDir.mkdirs()
        }

        val file = File(flutterDir, "sensor_log.txt")
        FileWriter(file, true).use { writer ->
            writer.append(line)
        }
    }
}
    

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

    override fun onDestroy() {
        super.onDestroy()
        sensorManager.unregisterListener(this)
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                channelId,
                "Sensor Service Channel",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }
}