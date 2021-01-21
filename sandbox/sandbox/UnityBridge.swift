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
            self.bridge.unityGotReady()
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
    
    internal(set) public var isReady: Bool = false
    public var api: API
    private let ufw: UnityFramework
    
    public var view: UIView? {
        get { return self.ufw.appController()?.rootView }
    }
    public var onReady: () -> () = {}
    
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
    
    public func show(controller: UIViewController) {
        if self.isReady {
            self.ufw.showUnityWindow()
        }
        if let view = self.view {
            controller.view?.addSubview(view)
        }
    }

    public func unload() {
        self.ufw.unloadApplication()
    }
    
    internal func unityGotReady() {
        self.isReady = true
        onReady()
    }
    
    internal func unityDidUnload(_ notification: Notification!) {
        ufw.unregisterFrameworkListener(self)
        UnityBridge.instance = nil
    }
 
}
