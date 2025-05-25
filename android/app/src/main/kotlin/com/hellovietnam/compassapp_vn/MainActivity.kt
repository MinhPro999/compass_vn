package com.hellovietnam.compassapp_vn

import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import kotlin.math.atan2

class MainActivity : FlutterActivity() {
    private val CHANNEL = "compass_stream"
    private lateinit var sensorManager: SensorManager
    private var accelerometer: Sensor? = null
    private var magnetometer: Sensor? = null
    private var accelerometerReading = FloatArray(3)
    private var magnetometerReading = FloatArray(3)
    private var filteredAngle = 0.0
    private val alpha = 0.33

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                private var eventSink: EventChannel.EventSink? = null
                private var sensorListener: SensorEventListener? = null

                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    sensorManager = getSystemService(SENSOR_SERVICE) as SensorManager
                    accelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
                    magnetometer = sensorManager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD)

                    if (accelerometer == null || magnetometer == null) {
                        eventSink?.error("UNAVAILABLE", "Cảm biến không khả dụng", null)
                        return
                    }

                    filteredAngle = 0.0 // Reset góc

                    sensorListener = object : SensorEventListener {
                        override fun onSensorChanged(event: SensorEvent?) {
                            if (event == null) return

                            when (event.sensor.type) {
                                Sensor.TYPE_ACCELEROMETER -> {
                                    System.arraycopy(event.values, 0, accelerometerReading, 0, accelerometerReading.size)
                                }
                                Sensor.TYPE_MAGNETIC_FIELD -> {
                                    System.arraycopy(event.values, 0, magnetometerReading, 0, magnetometerReading.size)
                                }
                            }

                            val rotationMatrix = FloatArray(9)
                            val inclinationMatrix = FloatArray(9)
                            val success = SensorManager.getRotationMatrix(
                                rotationMatrix, inclinationMatrix, accelerometerReading, magnetometerReading
                            )

                            if (success) {
                                val orientation = FloatArray(3)
                                SensorManager.getOrientation(rotationMatrix, orientation)
                                var direction = Math.toDegrees(orientation[0].toDouble())
                                val newAngle = if (direction >= 0) direction else direction + 360

                                var deltaAngle = newAngle - filteredAngle
                                if (deltaAngle > 180) deltaAngle -= 360
                                else if (deltaAngle < -180) deltaAngle += 360

                                filteredAngle += alpha * deltaAngle

                                if (filteredAngle >= 360) filteredAngle -= 360
                                else if (filteredAngle < 0) filteredAngle += 360

                                eventSink?.success(filteredAngle)
                            }
                        }

                        override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
                    }

                    sensorManager.registerListener(sensorListener, accelerometer, SensorManager.SENSOR_DELAY_UI)
                    sensorManager.registerListener(sensorListener, magnetometer, SensorManager.SENSOR_DELAY_UI)
                }

                override fun onCancel(arguments: Any?) {
                    sensorListener?.let {
                        sensorManager.unregisterListener(it)
                    }
                    sensorListener = null
                    eventSink = null
                }
            }
        )
    }
}