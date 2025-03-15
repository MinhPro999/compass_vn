import UIKit
import Flutter
import CoreMotion

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private let CHANNEL = "compass_stream"
    private let motionManager = CMMotionManager()

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController
        let channel = FlutterEventChannel(name: CHANNEL, binaryMessenger: controller.binaryMessenger)

        channel.setStreamHandler(CompassStreamHandler(motionManager: motionManager))
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

class CompassStreamHandler: NSObject, FlutterStreamHandler {
    private let motionManager: CMMotionManager
    private var filteredAngle: Double = 0.0 // Góc đã làm mượt
    private let alpha: Double = 0.33 // Hệ số làm mượt

    init(motionManager: CMMotionManager) {
        self.motionManager = motionManager
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        if motionManager.isMagnetometerAvailable {
            motionManager.magnetometerUpdateInterval = 0.1
            motionManager.startMagnetometerUpdates(to: OperationQueue.main) { (data, error) in
                if let data = data {
                    // Tính hướng từ magnetometer
                    var direction = atan2(data.magneticField.y, data.magneticField.x) * 180 / .pi
                    let newAngle = direction >= 0 ? direction : direction + 360

                    // Tính delta góc
                    var deltaAngle = newAngle - self.filteredAngle
                    if deltaAngle > 180 { deltaAngle -= 360 }
                    else if deltaAngle < -180 { deltaAngle += 360 }

                    // Làm mượt góc
                    self.filteredAngle += self.alpha * deltaAngle

                    // Giới hạn trong 0-360
                    if self.filteredAngle >= 360 { self.filteredAngle -= 360 }
                    else if self.filteredAngle < 0 { self.filteredAngle += 360 }

                    events(self.filteredAngle)
                }
            }
        } else {
            events(FlutterError(code: "UNAVAILABLE", message: "Magnetometer not available", details: nil))
        }
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        motionManager.stopMagnetometerUpdates()
        return nil
    }
}