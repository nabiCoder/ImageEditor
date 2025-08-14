import SwiftUI

struct SignInScreen<ViewModel>: View where ViewModel: AuthViewModelType{
    // MARK: - States
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showSuccessAlert: Bool = false
    @State private var showErrorMessage: Bool = false
    @State private var goToSignUp = false
    @State private var showResetPasswordScreen: Bool = false
    @FocusState private var focusedField: AuthField?
    
    @ObservedObject private var viewModel: ViewModel
    // MARK: - Computed Properties
    private var showEmailValidation: Bool { !email.isEmpty }
    private var isSignInButtonDisabled: Bool { email.isEmpty || password.isEmpty || email.isValidEmail == false }
    
    // MARK: - Initialization
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack {
                BaseTitle(text: AppConstants.AuthScenesConstants.signInTitle,
                          textSize: AppConstants.AuthScenesConstants.titleSize)
                // MARK: - Fields & Buttons
                VStack(spacing: 0) {
                    BaseTextField(bindedText: $email,
                                  title: AppConstants.AuthScenesConstants.emailPlaceholder,
                                  isEmailValidationActive: showEmailValidation,
                                  isValidEmail: email.isValidEmail)
                    .padding(.horizontal)
                    .focused($focusedField, equals: .email)
                    
                    BaseSecureField(bindedText: $password,
                                    title: AppConstants.AuthScenesConstants.passwordPlaceholder)
                    .padding()
                    .focused($focusedField, equals: .email)
                    
                    
                    BaseButton(
                        title: AppConstants.AuthScenesConstants.signInTitle,
                        isDisabled: isSignInButtonDisabled,
                        action: {
                            viewModel.signIn(email: email, password: password)
                        }
                    )
                    .padding()
                    
                    BaseButton(
                        title: AppConstants.AuthScenesConstants.googleButton,
                        action: {
                            viewModel.authenticateWithGoogle()
                        }
                    )
                    .padding(.horizontal)
                    
                    BaseButton(
                        title: AppConstants.AuthScenesConstants.resetButtonTitle,
                        style: .plain,
                        action: {
                            showResetPasswordScreen = true
                        }
                    )
                    .sheet(isPresented: $showResetPasswordScreen) {
                        print(showResetPasswordScreen)
                    } content: {
                        ResetPasswordScreen(viewModel: viewModel)
                    }
                    .padding(.horizontal)
                }
                // MARK: - Sign Up Link
                HStack {
                    Text(AppConstants.AuthScenesConstants.dontAccountTitle)
                        .font(.system(.body, design: .rounded))
                    
                    BaseButton(
                        title: AppConstants.AuthScenesConstants.registerButton,
                        style: .plain,
                        action: {
                            goToSignUp = true
                        }
                    )
                }
                .padding(.horizontal)
            }
            
            .hideKeyboardOnTap($focusedField)
            .navigationDestination(isPresented: $goToSignUp, destination: {
                SignUpScreen(viewModel: viewModel)
            })
            // MARK: - Alerts
            .onChange(of: viewModel.showSignInSuccessMessage, { _, newValue in
                if newValue == true {
                    showSuccessAlert = true
                }
            })
            .onChange(of: showSuccessAlert, { _, newValue in
                if newValue == true {
                    viewModel.showSignInSuccessMessage = nil
                }
            })
            .onChange(of: viewModel.errorMessage != nil, { _, newValue in
                if newValue == true {
                    viewModel.errorMessage = nil
                    showErrorMessage = true
                }
            })
            .alert(AppConstants.AuthScenesConstants.signInTitle,
                   isPresented: $showSuccessAlert,
                   actions: {
                Button(AppConstants.AuthScenesConstants.okButtonTitle) {
                    showSuccessAlert = false
                    viewModel.handleSignInSuccess()
                }
            }, message: {
                Text(AppConstants.AuthScenesConstants.signInSuccessMessage)
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
            
            // MARK: - Loading Indicator
            .withSpinnerOverlay(isLoading: viewModel.isLoading)
        }
    }
}
// MARK: - Preview
#Preview {
    SignInScreen(viewModel: AuthViewModel(authService: FirebaseAuthService(),
                                          googleAuthService: GoogleAuthService()))
}
