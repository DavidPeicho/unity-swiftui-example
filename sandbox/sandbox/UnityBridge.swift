import Foundation
import UnityFramework

class UnityBridge: UIResponder, UIApplicationDelegate, UnityFrameworkListener {
 
    private static var instance : UnityBridge?
    
    internal(set) public var isReady: Bool = false
    public var ready: () -> () = {}
    
    public let api: UnityAPI
    private let ufw: UnityFramework
    
    public var view: UIView? {
        get { return self.ufw.appController()?.rootView }
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
        self.api = UnityAPI()
        super.init()
        self.api.communicator = self
        self.ufw.register(self)
        FrameworkLibAPI.registerAPIforNativeCalls(self.api)
   
        self.api.ready = {
            self.isReady = true
            self.ready()
        }
        
        ufw.runEmbedded(withArgc: CommandLine.argc, argv: CommandLine.unsafeArgv, appLaunchOpts: nil)
    }
    
    public func show() {
        if self.isReady {
            self.ufw.showUnityWindow()
        }
    }
    
    public func show(controller: UIViewController) {
        if self.isReady {
            self.ufw.showUnityWindow()
        }
        if let view = self.view {
            controller.view?.addSubview(view)
            // view.addSubview(controller.view!)
        }
    }

    public func unload() {
        self.ufw.unloadApplication()
    }
    
    internal func unityDidUnload(_ notification: Notification!) {
        ufw.unregisterFrameworkListener(self)
        UnityBridge.instance = nil
    }
 
}

extension UnityBridge: UnityCommunicationProtocol {
    
    public func sendMessageToGameObject(go: String, function: String, message: String) {
        self.ufw.sendMessageToGO(withName: go, functionName: function, message: message)
    }

}
