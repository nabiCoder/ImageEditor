import SwiftUI

struct BaseTextField: View {
    
    @Binding var bindedText: String
    
    let title: String
    let isEmailValidationActive: Bool
    let isValidEmail: Bool

    var body: some View {
        TextField(title, text: $bindedText)
            .modifier(BaseTextFieldModifier(isEmailValidationActive: isEmailValidationActive,
                                            isValidEmail: isValidEmail))
    }
}
