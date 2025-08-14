import UIKit.UIImage

extension UIImage: @retroactive Identifiable {
    public var id: String {
        self.pngData()?.base64EncodedString() ?? UUID().uuidString
    }
}

