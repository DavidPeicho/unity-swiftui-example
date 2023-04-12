//
//  Created by Simon Tysland on 19/08/2019.
//
import Foundation
import UnityFramework

class API: NativeCallsProtocol {

    internal weak var bridge: UnityBridge!
    
    /**
        Function pointers to static functions declared in Unity
     */
    
    private var testCallback: TestDelegate!
    
    /**
        Public API
     */
    
    public func test(_ value: String) {
        self.testCallback(value)
    }
    
    /**
        Internal methods are called by Unity
     */
    
    internal func onUnityStateChange(_ state: String) {
        switch (state) {
        case "ready":
            self.bridge.onReady()
        default:
            return
        }
    }
    
    internal func onSetTestDelegate(_ delegate: TestDelegate!) {
        self.testCallback = delegate
    }
    
}

class UnityBridge: UIResponder, UIApplicationDelegate, UnityFrameworkListener {
 
    private static var instance : UnityBridge?
    private let ufw: UnityFramework
    private var observation: NSKeyValueObservation?

    public var api: API
    public var onReady: () -> () = {}
    public var superview: UIView? {
        didSet {
            // remove old observation
            observation?.invalidate()

            if superview == nil {
                ufw.appController().window.rootViewController?.view.removeFromSuperview()
            } else {
                // register new observation; it fires on register and on new value at .rootViewController
                observation = ufw.appController().window.observe(\.rootViewController, options: [.initial, .new], changeHandler: { [weak self] (window, _) in
                    if let superview = self?.superview, let view = window.rootViewController?.view {
                        // the rootViewController of Unity's window has been assigned
                        // now is the proper moment to apply our superview if we have one
                        superview.addSubview(view)
                        view.frame = superview.frame
                    }
                })
            }
        }
    }

    public static func getInstance() -> UnityBridge {
        if UnityBridge.instance == nil {
            UnityBridge.instance = UnityBridge()
        }
        return UnityBridge.instance!
    }
    
    private static func loadUnityFramework() -> UnityFramework? {
        let bundlePath: String = Bundle.main.bundlePath + "/Frameworks/UnityFramework.framework"
        let bundle = Bundle(path: bundlePath)
        bundle?.load()
   
        let ufw = bundle?.principalClass?.getInstance()
        if ufw?.appController() == nil {
            let machineHeader = UnsafeMutablePointer<MachHeader>.allocate(capacity: 1)
            machineHeader.pointee = _mh_execute_header
            ufw!.setExecuteHeader(machineHeader)
        }
        return ufw
    }
    
    internal override init() {
        self.ufw = UnityBridge.loadUnityFramework()!
        self.ufw.setDataBundleId("com.unity3d.framework")
        self.api = API()
        super.init()
        self.api.bridge = self
        self.ufw.register(self)
        FrameworkLibAPI.registerAPIforNativeCalls(self.api)
   
        // runEmbedded will call the framework's showUnityWindow method internally
        self.ufw.runEmbedded(withArgc: CommandLine.argc, argv: CommandLine.unsafeArgv, appLaunchOpts: nil)

        // Unity claims the key window, so let user interactions passthrough to our window
        self.ufw.appController().window.isUserInteractionEnabled = false
    }

    public func unload() {
        ufw.unloadApplication()
    }
    
    internal func unityDidUnload(_ notification: Notification!) {
        ufw.unregisterFrameworkListener(self)
        UnityBridge.instance = nil
    }
}
