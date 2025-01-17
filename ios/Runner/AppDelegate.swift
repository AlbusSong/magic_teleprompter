import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        Trifles()
        
        let rootVC = self.window.rootViewController as! FlutterViewController
        let testChannel = FlutterMethodChannel.init(name: "com.albus.magic_teleprompter/trifles", binaryMessenger: rootVC.binaryMessenger)
        
        testChannel.setMethodCallHandler { (call, res) in
            print("call: \(call.method)")
            if (call.method == "justTest") {
                res("testMesssage333")
            } else if (call.method == "setupVideoSDK") {
                Trifles().setupVideoSDK()
                res("here is msg for setup video sdk")
            }
        }
        
//        Trifles().channel = FlutterMethodChannel.init(name: "com.albus.magic_teleprompter/trifles", binaryMessenger: rootVC.binaryMessenger)
//        Trifles().setupChannelHandler()
        
        GeneratedPluginRegistrant.register(with: self)
        //        IOSCameraViewPlugin.register(with: self)
        
        
        let registrar:FlutterPluginRegistrar = self.registrar(forPlugin: "Runner")!
        let factory = CameraViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "ios_camera_view")
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
}
