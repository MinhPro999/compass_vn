import UIKit
import Flutter
import CoreMotion

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private let CHANNEL = "compass_stream"
    private let motionManager = CMMotionManager()
    private var compassStreamHandler: CompassStreamHandler?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Safety check for root view controller
        guard let controller = window?.rootViewController as? FlutterViewController else {
            print("Error: Could not get FlutterViewController")
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }

        let channel = FlutterEventChannel(name: CHANNEL, binaryMessenger: controller.binaryMessenger)
        compassStreamHandler = CompassStreamHandler(motionManager: motionManager)
        channel.setStreamHandler(compassStreamHandler)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func applicationWillTerminate(_ application: UIApplication) {
        // Cleanup motion manager
        if motionManager.isMagnetometerActive {
            motionManager.stopMagnetometerUpdates()
        }
        compassStreamHandler = nil
        super.applicationWillTerminate(application)
    }

    override func applicationDidEnterBackground(_ application: UIApplication) {
        // Stop magnetometer when app goes to background to save battery
        if motionManager.isMagnetometerActive {
            motionManager.stopMagnetometerUpdates()
        }
        super.applicationDidEnterBackground(application)
    }

    override func applicationWillEnterForeground(_ application: UIApplication) {
        // Magnetometer will be restarted when stream is listened to again
        super.applicationWillEnterForeground(application)
    }
}

class CompassStreamHandler: NSObject, FlutterStreamHandler {
    private let motionManager: CMMotionManager
    private var filteredAngle: Double = 0.0
    private let alpha: Double = 0.33
    private var isListening: Bool = false
    private var eventSink: FlutterEventSink?

    init(motionManager: CMMotionManager) {
        self.motionManager = motionManager
        super.init()
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events

        // Check if magnetometer is available
        guard motionManager.isMagnetometerAvailable else {
            events(FlutterError(code: "UNAVAILABLE", message: "Magnetometer not available on this device", details: nil))
            return nil
        }

        // Prevent multiple listeners
        guard !isListening else {
            print("Warning: Magnetometer is already being listened to")
            return nil
        }

        isListening = true

        // Configure magnetometer
        motionManager.magnetometerUpdateInterval = 0.1 // 10Hz update rate

        motionManager.startMagnetometerUpdates(to: OperationQueue.main) { [weak self] (data, error) in
            guard let self = self else { return }

            // Handle errors
            if let error = error {
                print("Magnetometer error: \(error.localizedDescription)")
                events(FlutterError(code: "SENSOR_ERROR", message: error.localizedDescription, details: nil))
                return
            }

            // Process magnetometer data
            guard let data = data else {
                print("Warning: Received nil magnetometer data")
                return
            }

            // Calculate compass heading
            let rawDirection = atan2(data.magneticField.y, data.magneticField.x) * 180 / .pi
            let newAngle = rawDirection >= 0 ? rawDirection : rawDirection + 360

            // Apply low-pass filter to smooth the readings
            var deltaAngle = newAngle - self.filteredAngle

            // Handle angle wrapping (shortest path)
            if deltaAngle > 180 {
                deltaAngle -= 360
            } else if deltaAngle < -180 {
                deltaAngle += 360
            }

            self.filteredAngle += self.alpha * deltaAngle

            // Normalize angle to 0-360 range
            if self.filteredAngle >= 360 {
                self.filteredAngle -= 360
            } else if self.filteredAngle < 0 {
                self.filteredAngle += 360
            }

            // Send filtered angle to Flutter
            events(self.filteredAngle)
        }

        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        print("Stopping magnetometer updates")

        if motionManager.isMagnetometerActive {
            motionManager.stopMagnetometerUpdates()
        }

        isListening = false
        eventSink = nil

        return nil
    }

    deinit {
        // Ensure cleanup on deallocation
        if motionManager.isMagnetometerActive {
            motionManager.stopMagnetometerUpdates()
        }
    }
}
