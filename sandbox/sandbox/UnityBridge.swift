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
    private let rootVCKeyPath = "rootViewController"
    private var view: UIView? {
        get { return ufw.appController()?.window?.rootViewController?.view }
    }

    public var api: API
    public var onReady: () -> () = {}
    public var superview: UIView? {
        didSet {
            let window = ufw.appController()?.window

            if oldValue != nil {
                // prevent accumulation of multiple observers
                window?.removeObserver(self, forKeyPath: rootVCKeyPath)
            }
            if superview != nil {
                // register new observer; it fires on register and on new value at key path
                window?.addObserver(self, forKeyPath: rootVCKeyPath, options: [.initial, .new], context: nil)
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
        if bundle?.isLoaded == false {
            bundle?.load()
        }
   
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
   
        ufw.runEmbedded(withArgc: CommandLine.argc, argv: CommandLine.unsafeArgv, appLaunchOpts: nil)
    }
    
    internal override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == rootVCKeyPath, let superview = self.superview, let view = self.view  {
            // the root UIViewController of Unity's UIWindow has been assigned
            // now is the proper moment to apply our superview if we have one
            superview.addSubview(view)
            view.frame = superview.frame
        }
   }

    public func unload() {
        ufw.unloadApplication()
    }
    
    internal func unityDidUnload(_ notification: Notification!) {
        ufw.unregisterFrameworkListener(self)
        UnityBridge.instance = nil
    }
}
