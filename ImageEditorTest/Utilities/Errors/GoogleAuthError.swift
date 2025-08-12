import Foundation

enum GoogleAuthError: LocalizedError {
    case missingClientID
    case signInFailed(Error)
    case missingTokens
    case firebaseSignInFailed(Error)
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .missingClientID:
            return NSLocalizedString(
                "Missing Google client ID in Firebase configuration.",
                comment: "Google Sign-In error: client ID not found"
            )
        case .signInFailed(let error):
            return NSLocalizedString(
                "Google Sign-In failed: \(error.localizedDescription)",
                comment: "Google Sign-In error with underlying error description"
            )
        case .missingTokens:
            return NSLocalizedString(
                "Failed to retrieve Google authentication tokens.",
                comment: "Google Sign-In error: missing tokens"
            )
        case .firebaseSignInFailed(let error):
            return NSLocalizedString(
                "Firebase authentication with Google credentials failed: \(error.localizedDescription)",
                comment: "Firebase Auth error during Google sign-in"
            )
        case .unknownError:
            return NSLocalizedString(
                "An unknown error occurred during Google Sign-In.",
                comment: "Google Sign-In error: unknown"
            )
        }
    }
}
