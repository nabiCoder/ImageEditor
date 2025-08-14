import SwiftUI

struct ResetPasswordScreen<ViewModel>: View where ViewModel: AuthViewModelType {
    // MARK: - States
    @State private var email: String = ""
    @State private var showResetSuccess: Bool = false
    @FocusState private var focusedField: AuthField?
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject private var viewModel: ViewModel
    
    // MARK: - Computed Properties
    private var showEmailValidation: Bool { !email.isEmpty }
    private var resetButtonDisabled: Bool { email.isEmpty || email.isValidEmail == false }
    
    // MARK: - Initialization
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 12) {
            
            BaseTitle(text: AppConstants.AuthScenesConstants.resetPasswordTitle,
                      textSize: AppConstants.AuthScenesConstants.titleSize)
            
            BaseTextField(
                bindedText: $email,
                title: AppConstants.AuthScenesConstants.emailPlaceholder,
                isEmailValidationActive: showEmailValidation,
                isValidEmail: email.isValidEmail
            )
            .padding([.leading, .trailing])
            .focused($focusedField, equals: .email)
            
            BaseButton(
                title: AppConstants.AuthScenesConstants.resetButtonTitle,
                isDisabled: resetButtonDisabled,
                action: {
                    viewModel.requestPasswordReset(email: email)
                }
            )
            .padding([.leading, .trailing])
            
        }
        .hideKeyboardOnTap($focusedField)
        .onChange(of: viewModel.showResetSuccessMessage, { _, newValue in
            if newValue == true {
                showResetSuccess = true
            }
        })
        // MARK: - Alerts
        .alert(AppConstants.AuthScenesConstants.errorAlertTitle,
               isPresented: .constant(viewModel.errorMessage != nil),
               actions: {
            Button(AppConstants.AuthScenesConstants.okButtonTitle, role: .cancel) {
                viewModel.errorMessage = nil
            }
        }, message: {
            Text(viewModel.errorMessage ?? "")
        })
        .alert(AppConstants.AuthScenesConstants.successAlertTitle,
               isPresented: $showResetSuccess,
               actions: {
            Button(AppConstants.AuthScenesConstants.okButtonTitle) {
                viewModel.showResetSuccessMessage = nil
                dismiss()
            }
        }, message: {
            Text(AppConstants.AuthScenesConstants.successAlertMessage)
        })
        // MARK: - Loading Indicator
        .withSpinnerOverlay(isLoading: viewModel.isLoading)
    }
}

#Preview {
    ResetPasswordScreen(
        viewModel: AuthViewModel(
            authService: FirebaseAuthService(),
            googleAuthService: GoogleAuthService()
        )
    )
}
