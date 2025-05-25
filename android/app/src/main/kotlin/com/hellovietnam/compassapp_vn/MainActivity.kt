package com.hellovietnam.compassapp_vn

import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Bundle
import com.facebook.FacebookSdk
import com.facebook.appevents.AppEventsLogger
import com.facebook.appevents.AppEventsConstants
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlin.math.atan2

class MainActivity : FlutterActivity() {
    private val CHANNEL = "compass_stream"
    private val ANALYTICS_CHANNEL = "facebook_analytics"
    private lateinit var sensorManager: SensorManager
    private var accelerometer: Sensor? = null
    private var magnetometer: Sensor? = null
    private var accelerometerReading = FloatArray(3)
    private var magnetometerReading = FloatArray(3)
    private var filteredAngle = 0.0
    private val alpha = 0.33
    private lateinit var appEventsLogger: AppEventsLogger

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Initialize Facebook SDK
        FacebookSdk.sdkInitialize(applicationContext)
        AppEventsLogger.activateApp(application)

        // Initialize Facebook Analytics Logger
        appEventsLogger = AppEventsLogger.newLogger(this)

        // Track App Launch Event
        trackAppLaunch()
    }

    private fun trackAppLaunch() {
        val parameters = Bundle()
        parameters.putString("app_version", "2.2.1")
        parameters.putString("platform", "android")
        appEventsLogger.logEvent("app_launch", parameters)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Setup Facebook Analytics Method Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ANALYTICS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "logEvent" -> {
                    val eventName = call.argument<String>("eventName") ?: ""
                    val parameters = call.argument<Map<String, Any>>("parameters") ?: emptyMap()
                    logFacebookEvent(eventName, parameters)
                    result.success(true)
                }
                "logCompassUsage" -> {
                    logCompassUsage()
                    result.success(true)
                }
                "logScreenView" -> {
                    val screenName = call.argument<String>("screenName") ?: ""
                    logScreenView(screenName)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

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

    // Facebook Analytics tracking methods
    private fun logFacebookEvent(eventName: String, parameters: Map<String, Any>) {
        val bundle = Bundle()
        for ((key, value) in parameters) {
            when (value) {
                is String -> bundle.putString(key, value)
                is Int -> bundle.putInt(key, value)
                is Double -> bundle.putDouble(key, value)
                is Boolean -> bundle.putBoolean(key, value)
                else -> bundle.putString(key, value.toString())
            }
        }
        appEventsLogger.logEvent(eventName, bundle)
    }

    private fun logCompassUsage() {
        val parameters = Bundle()
        parameters.putString("feature", "compass")
        parameters.putString("action", "view_compass")
        parameters.putLong("timestamp", System.currentTimeMillis())
        appEventsLogger.logEvent("compass_usage", parameters)
    }

    private fun logScreenView(screenName: String) {
        val parameters = Bundle()
        parameters.putString("screen_name", screenName)
        parameters.putLong("timestamp", System.currentTimeMillis())
        appEventsLogger.logEvent(AppEventsConstants.EVENT_NAME_VIEWED_CONTENT, parameters)
    }

    override fun onResume() {
        super.onResume()
        // Track app resume
        val parameters = Bundle()
        parameters.putString("action", "app_resume")
        appEventsLogger.logEvent("app_activity", parameters)
    }

    override fun onPause() {
        super.onPause()
        // Track app pause
        val parameters = Bundle()
        parameters.putString("action", "app_pause")
        appEventsLogger.logEvent("app_activity", parameters)
    }
}