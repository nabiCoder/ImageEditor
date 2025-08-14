import SwiftUI

struct BaseButtonModifier: ViewModifier {
    
    var isDisabled: Bool
    var backgroundColor: Color?
    var foregroundColor: Color?

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity) 
            .disabled(isDisabled)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
    }
}
