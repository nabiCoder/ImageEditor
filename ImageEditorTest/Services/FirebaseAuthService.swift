import FirebaseAuth
import Combine

protocol AuthServiceProtocol {
    func signIn(email: String, password: String) -> AnyPublisher<AppUser, Error>
    func signUp(email: String, password: String) -> AnyPublisher<AppUser, Error>
    
    func resetPassword(email: String) -> AnyPublisher<Void, Error>
    func sendEmailVerification() -> AnyPublisher<Void, Error>
    
    func signOut() -> AnyPublisher<Void, Error>
    func isUserSignedIn() -> Bool
}
/// Authentication service for handling Firebase Auth operations.
/// Provides sign-in, sign-up, password reset, email verification,
/// user status checks, and sign-out functionality for use in MVVM architecture.
final class FirebaseAuthService: AuthServiceProtocol {
    // MARK: - Sign In
    
    /// Signs in a user using email and password.
    /// - Returns: `AppUser` on success, or an error if authentication fails.
    func signIn(email: String, password: String) -> AnyPublisher<AppUser, any Error> {
        Future { promise in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let user = result?.user {
                    promise(.success(AppUser(id: user.uid, email: user.email ?? "")))
                } else {
                    promise(.failure(error ?? FirebaseAuthError.unknownError))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    // MARK: - Sign Up
    
    /// Creates a new user account with email and password.
    /// - Returns: `AppUser` on success, or an error if registration fails.
    func signUp(email: String, password: String) -> AnyPublisher<AppUser, any Error> {
        Future { promise in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let result = result {
                    promise(.success(AppUser(id: result.user.uid, email: result.user.email ?? "")))
                } else {
                    promise(.failure(error ?? FirebaseAuthError.unknownError))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    // MARK: - Password Reset
    
    /// Sends a password reset email to the provided address.
    /// - Returns: `Void` on success, or an error if sending fails.
    func resetPassword(email: String) -> AnyPublisher<Void, any Error> {
        Future { promise in
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    // MARK: - Email Verification
    
    /// Sends an email verification link to the currently signed-in user.
    /// - Returns: `Void` on success, or an error if the user is not authenticated or sending fails.
    func sendEmailVerification() -> AnyPublisher<Void, any Error> {
        guard let user = Auth.auth().currentUser else {
            return Fail(error: FirebaseAuthError.userNotAuthenticated)
                .eraseToAnyPublisher()
        }
        return Future { promise in
            user.sendEmailVerification { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    // MARK: - Sign Out
    
    /// Signs out the currently signed-in user.
    /// - Returns: `Void` on success, or an error if sign-out fails.
    func signOut() -> AnyPublisher<Void, any Error> {
        Future { promise in
            do {
                try Auth.auth().signOut()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    // MARK: - User Status
    
    /// Checks whether a user is currently signed in.
    /// - Returns: `true` if a user is signed in, otherwise `false`.
    func isUserSignedIn() -> Bool {
        Auth.auth().currentUser != nil
    }
}
