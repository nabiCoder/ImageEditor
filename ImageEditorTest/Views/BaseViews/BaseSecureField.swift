import SwiftUI

struct BaseSecureField: View {
    
    var bindedText: Binding<String>
    
    let title: String
    let isPasswordValidationActive: Bool
    let isPasswordMatching: Bool
    
    init(bindedText: Binding<String>,
         title: String,
         isPasswordValidationActive: Bool = false,
         isPasswordMatching: Bool = false) {
        self.bindedText = bindedText
        self.title = title
        self.isPasswordValidationActive = isPasswordValidationActive
        self.isPasswordMatching = isPasswordMatching
    }
    
    var body: some View {
        SecureField(title, text: bindedText)
            .modifier(BaseSecureFieldModifier(isPasswordValidationActive: isPasswordValidationActive,
                                              isPasswordMatching: isPasswordMatching))
    }
}
