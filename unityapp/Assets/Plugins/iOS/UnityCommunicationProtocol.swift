public protocol UnityCommunicationProtocol: AnyObject {
    func sendMessageToGameObject(go: String, function: String, message: String) -> ()
}
