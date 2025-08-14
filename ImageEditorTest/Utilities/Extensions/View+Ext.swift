import SwiftUI

extension View {
    func withSpinnerOverlay(isLoading: Bool) -> some View {
        self.modifier(SpinnerOverlayView(isLoading: isLoading))
    }
    
    func hideKeyboardOnTap(_ focusedField: FocusState<AuthField?>.Binding) -> some View {
        self.onTapGesture {
            focusedField.wrappedValue = nil
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
    }
}
