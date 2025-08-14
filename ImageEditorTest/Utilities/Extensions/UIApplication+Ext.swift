import UIKit

extension UIApplication {
    var firstKeyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }?
            .windows
            .first(where: \.isKeyWindow)
    }
    
    var rootViewController: UIViewController? {
        firstKeyWindow?.rootViewController
    }
}

