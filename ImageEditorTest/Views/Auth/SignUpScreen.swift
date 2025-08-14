import SwiftUI

struct SignUpScreen<ViewModel>: View where ViewModel: AuthViewModelType {
    // MARK: - States
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showSuccessAlert: Bool = false
    @State private var showErrorMessage: Bool = false
    @FocusState private var focusedField: AuthField?
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject private var viewModel: ViewModel
    
    // MARK: - Computed Properties
    private var isSignUpButtonDisabled: Bool {
        email.isEmpty || password.isEmpty || confirmPassword.isEmpty ||
        password != confirmPassword ||
        email.isValidEmail == false
    }
    
    private var showEmailValidation: Bool { !email.isEmpty }
    
    private var showPasswordValidation: Bool { !(password.isEmpty || confirmPassword.isEmpty) }
    
    private var showPasswordMatching: Bool { password == confirmPassword }
    
   
    // MARK: - Initialization
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 12) {
            
            BaseTitle(text: AppConstants.AuthScenesConstants.createProfileTitle,
                      textSize: AppConstants.AuthScenesConstants.titleSize)
            // MARK: - Input Fields
            BaseTextField(
                bindedText: $email,
                title: AppConstants.AuthScenesConstants.emailPlaceholder,
                isEmailValidationActive: showEmailValidation,
                isValidEmail: email.isValidEmail
            )
            .padding([.leading, .trailing])
            .focused($focusedField, equals: .email)
            
            BaseSecureField(
                bindedText: $password,
                title: AppConstants.AuthScenesConstants.passwordPlaceholder,
                isPasswordValidationActive: showPasswordValidation,
                isPasswordMatching: showPasswordMatching
            )
            .padding([.leading, .trailing])
            .focused($focusedField, equals: .password)
            
            BaseSecureField(
                bindedText: $confirmPassword,
                title: AppConstants.AuthScenesConstants.passwordPlaceholder,
                isPasswordValidationActive: showPasswordValidation,
                isPasswordMatching: showPasswordMatching
            )
            .padding([.leading, .trailing])
            .focused($focusedField, equals: .password)
            
            BaseButton(
                title: AppConstants.AuthScenesConstants.signUpTitle,
                isDisabled: isSignUpButtonDisabled,
                action: {
                    viewModel.signUp(email: email, password: password)
                }
            )
            .padding([.leading, .trailing])
        }
        .hideKeyboardOnTap($focusedField)
        // MARK: - Alerts
        .onChange(of: viewModel.showSignUpSuccessMessage, { _, newValue in
            if newValue == true {
                showSuccessAlert = true
            }
        })
        .onChange(of: showSuccessAlert, { _, newValue in
            if newValue == true {
                viewModel.showSignUpSuccessMessage = nil
            }
        })
        .onChange(of: viewModel.errorMessage != nil, { _, newValue in
            if newValue == true {
                viewModel.errorMessage = nil
                showErrorMessage = true
            }
        })
        .alert(AppConstants.AuthScenesConstants.signUpTitle,
               isPresented: $showSuccessAlert,
               actions: {
            Button(AppConstants.AuthScenesConstants.okButtonTitle) {
                showSuccessAlert = false
                dismiss()
            }
        }, message: {
            Text(AppConstants.AuthScenesConstants.textMassage)
        })
        .alert(AppConstants.AuthScenesConstants.errorAlertTitle,
               isPresented: $showErrorMessage,
               actions: {
            Button(AppConstants.AuthScenesConstants.okButtonTitle, role: .cancel) {
                showErrorMessage = false
            }
        }, message: {
            Text(viewModel.errorMessage ?? "")
        })
        
        // MARK: Loading Indicator
        .withSpinnerOverlay(isLoading: viewModel.isLoading)
    }
}
// MARK: - Preview
#Preview {
    SignUpScreen(
        viewModel: AuthViewModel(authService: FirebaseAuthService(),
                                 googleAuthService: GoogleAuthService())
    )
}

