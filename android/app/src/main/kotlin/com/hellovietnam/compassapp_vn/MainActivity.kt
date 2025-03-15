package com.hellovietnam.compassapp_vn

import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "compass_stream"
    private lateinit var sensorManager: SensorManager
    private var compassSensor: Sensor? = null
    private var filteredAngle = 0.0 // Góc đã làm mượt
    private val alpha = 0.33 // Hệ số làm mượt

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                private var eventSink: EventChannel.EventSink? = null

                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    sensorManager = getSystemService(SENSOR_SERVICE) as SensorManager
                    compassSensor = sensorManager.getDefaultSensor(Sensor.TYPE_ORIENTATION)

                    val listener = object : SensorEventListener {
                        override fun onSensorChanged(event: SensorEvent?) {
                            if (event?.sensor?.type == Sensor.TYPE_ORIENTATION) {
                                var direction = event.values[0].toDouble() // Góc thô
                                // Chuyển góc âm sang dương
                                val newAngle = if (direction >= 0) direction else direction + 360

                                // Tính delta góc
                                var deltaAngle = newAngle - filteredAngle
                                if (deltaAngle > 180) deltaAngle -= 360
                                else if (deltaAngle < -180) deltaAngle += 360

                                // Làm mượt góc
                                filteredAngle += alpha * deltaAngle

                                // Giới hạn trong 0-360
                                if (filteredAngle >= 360) filteredAngle -= 360
                                else if (filteredAngle < 0) filteredAngle += 360

                                eventSink?.success(filteredAngle)
                            }
                        }

                        override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
                    }
                    sensorManager.registerListener(listener, compassSensor, SensorManager.SENSOR_DELAY_UI)
                }

                override fun onCancel(arguments: Any?) {
                    sensorManager.unregisterListener(object : SensorEventListener {
                        override fun onSensorChanged(event: SensorEvent?) {}
                        override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
                    })
                    eventSink = null
                }
            }
        )
    }
}