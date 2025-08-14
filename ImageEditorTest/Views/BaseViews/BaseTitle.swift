import SwiftUI

struct BaseTitle: View {
    
    let text: String
    let textSize: CGFloat

    var body: some View {
        Text(text)
            .font(.largeTitle)
            .fontWeight(.medium)
    }
}
