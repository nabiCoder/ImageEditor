import Combine
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

protocol GoogleAuthServiceProtocol {
    func signIn(presentingViewController: UIViewController) -> AnyPublisher<AppUser, Error>
}
/// Handles Google Sign-In flow and authenticates the user via Firebase.
final class GoogleAuthService: GoogleAuthServiceProtocol {
    /// Performs Google Sign-In and Firebase authentication.
    ///
    /// Uses the provided view controller to present the Google sign-in screen,
    /// then signs in to Firebase with Google credentials.
    ///
    /// - Parameter presentingViewController: The view controller to present the Google Sign-In UI.
    /// - Returns: A publisher that emits a `User` on success or an error on failure.
    func signIn(presentingViewController: UIViewController) -> AnyPublisher<AppUser, any Error> {
        Future { promise in
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                promise(.failure(GoogleAuthError.missingClientID))
                return
            }
            
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
            
            GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
                if let error = error {
                    promise(.failure(GoogleAuthError.signInFailed(error)))
                    return
                }
                
                guard
                    let googleUser = result?.user,
                    let idToken = googleUser.idToken?.tokenString
                else {
                    promise(.failure(GoogleAuthError.missingTokens))
                    return
                }
                
                let credential = GoogleAuthProvider.credential(
                    withIDToken: idToken,
                    accessToken: googleUser.accessToken.tokenString
                )
                
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        promise(.failure(GoogleAuthError.firebaseSignInFailed(error)))
                    } else if let firebaseUser = authResult?.user {
                        promise(.success(AppUser(id: firebaseUser.uid, email: firebaseUser.email ?? "")))
                    } else {
                        promise(.failure(GoogleAuthError.unknownError))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
