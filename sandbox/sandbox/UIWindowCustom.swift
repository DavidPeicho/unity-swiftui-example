import UIKit

/// Custom Window class used to allow events to pass through
/// depending on what view is targeted.
///
/// Because our application is multi-windows, this is useful to allow event
/// to go through
class UIWindowCustom: UIWindow {
    
    /// The tag is used to identify the view during `hitTest`.
    ///
    /// - Note:
    /// Be careful not to share this tag with other views that shouldn't act as passthroughs.
    public static let PassthroughTag = 999999
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else {
            return nil
        }
        if view.tag == UIWindowCustom.PassthroughTag {
            // Propagates event that are caught by passthrough views.
            return nil
        }
        // Do not propagate events, we reached a "normal" view.
        return view
    }
    
}
