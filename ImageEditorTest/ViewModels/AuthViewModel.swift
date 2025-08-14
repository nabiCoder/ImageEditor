import Combine
import UIKit

typealias AuthViewModelType = ObservableObject & AuthViewModelProtocol

protocol AuthViewModelProtocol: ObservableObject {
    var appState: AppState { get set }
    var isLoading: Bool { get set }
    var showSignUpSuccessMessage: Bool? { get set }
    var showSignInSuccessMessage: Bool? { get set }
    var showResetSuccessMessage: Bool? { get set }
    var errorMessage: String? { get set }
    
    func checkAuthenticationStatus()
    func handleSignInSuccess()
    func handleSignUpSuccess()
    func signOut()
    
    func signUp(email: String, password: String)
    func signIn(email: String, password: String)
    func authenticateWithGoogle()
    func requestPasswordReset(email: String)
    func sendVerificationEmail() -> AnyPublisher<Void, Error>
}

final class AuthViewModel: AuthViewModelType {
    
    // MARK: — Published properties (UI state)
    @Published var appState: AppState = .auth
    @Published var isLoading: Bool = false
    @Published var showSignUpSuccessMessage: Bool?
    @Published var showSignInSuccessMessage: Bool?
    @Published var showResetSuccessMessage: Bool?
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let authService: AuthServiceProtocol
    private let googleAuthService: GoogleAuthServiceProtocol
    
    // MARK: — Init
    init(authService: AuthServiceProtocol, googleAuthService: GoogleAuthServiceProtocol) {
        self.authService = authService
        self.googleAuthService = googleAuthService
        checkAuthenticationStatus()
    }
    
    // MARK: — Auth flow control
    func checkAuthenticationStatus() {
        if authService.isUserSignedIn() {
            appState = .editor
        } else {
            appState = .auth
        }
    }
    
    func handleSignInSuccess() {
        appState = .editor
    }
    
    func handleSignUpSuccess() {
        appState = .auth
    }
    
    func signOut() {
        authService.signOut()
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.appState = .auth
                case .failure(let error):
                    print("Sign out error: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                    self?.appState = .auth
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    // MARK: — Sign Up
    func signUp(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        authService
            .signUp(email: email, password: password)
            .flatMap { [weak self] _ -> AnyPublisher<Void, Error> in
                guard let self = self else {
                    return Fail(error: NSError(
                        domain: "AuthViewModel",
                        code: -1,
                        userInfo: nil
                    ))
                    .eraseToAnyPublisher()
                }
                return self.authService.sendEmailVerification()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] in
                self?.showSignUpSuccessMessage = true
            }
            .store(in: &cancellables)
    }
    
    // MARK: — Sign In
    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        authService
            .signIn(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                self?.showSignInSuccessMessage = true
            }
            .store(in: &cancellables)
    }
    
    // MARK: — Google Sign In
    func authenticateWithGoogle() {
        guard let rootViewController = UIApplication.shared.rootViewController else {
            print("Failed to get rootViewController")
            return
        }
        
        isLoading = true
        
        googleAuthService.signIn(presentingViewController: rootViewController)
            .receive(on: DispatchQueue.main)
            .sink { [ weak self ] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    print("Successful login Google")
                case .failure(let error):
                    print("Login error through Google: \(error.localizedDescription)")
                }
            } receiveValue: { [ weak self ] user in
                print("User logged in: \(user.email)")
                self?.isLoading = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self?.appState = .editor
                    self?.isLoading = false
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: — Reset Password
    func requestPasswordReset(email: String) {
        isLoading = true
        errorMessage = nil
        
        authService
            .resetPassword(email: email)
            .receive(on: DispatchQueue.main)
            .sink { [ weak self ] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                self?.showResetSuccessMessage = true
            }
            .store(in: &cancellables)
    }
    
    // MARK: — Email Verification
    func sendVerificationEmail() -> AnyPublisher<Void, Error> {
        authService
            .sendEmailVerification()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    
}

