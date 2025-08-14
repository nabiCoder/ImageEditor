import SwiftUI

struct BaseTextFieldModifier: ViewModifier {
    
    let isEmailValidationActive: Bool
    let isValidEmail: Bool
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, AppConstants.TextFieldConstants.horizontalPadding)
            .frame(height: AppConstants.TextFieldConstants.height)
            .background(
                RoundedRectangle(cornerRadius: AppConstants.TextFieldConstants.cornerRadius)
                    .stroke(
                        isEmailValidationActive
                        ? (isValidEmail ? AppConstants.TextFieldConstants.validColor : AppConstants.TextFieldConstants.invalidColor)
                        : AppConstants.TextFieldConstants.defaultStrokeColor,
                        lineWidth: AppConstants.TextFieldConstants.lineWidth
                    )
                    .background(AppConstants.TextFieldConstants.backgroundColor)
            )
            .font(.system(size: AppConstants.TextFieldConstants.fontSize))
    }
}
