import SwiftUI

struct TextOverlay: Identifiable {
    let id = UUID()
    var text: String
    var font: UIFont
    var color: Color
    var size: CGFloat
    var offset: CGSize = .zero
}
