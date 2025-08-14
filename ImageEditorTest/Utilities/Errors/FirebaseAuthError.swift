import Foundation

enum FirebaseAuthError: LocalizedError {
    case unknownError
    case userNotAuthenticated
    case invalidCredentials
    case emailAlreadyInUse
    case weakPassword
    case custom(message: String, code: Int?)
    
    var errorDescription: String? {
        switch self {
        case .unknownError:
            return NSLocalizedString("Unknown error while trying to log in", comment: "")
        case .userNotAuthenticated:
            return NSLocalizedString("User is not authenticated", comment: "")
        case .invalidCredentials:
            return NSLocalizedString("Invalid email or password", comment: "")
        case .emailAlreadyInUse:
            return NSLocalizedString("Email is already in use", comment: "")
        case .weakPassword:
            return NSLocalizedString("Password is too weak", comment: "")
        case .custom(let message, _):
            return message
        }
    }
    
    var errorCode: Int {
        switch self {
        case .unknownError:
            return 1001
        case .userNotAuthenticated:
            return 1002
        case .invalidCredentials:
            return 1003
        case .emailAlreadyInUse:
            return 1004
        case .weakPassword:
            return 1005
        case .custom(_, let code):
            return code ?? 0
        }
    }
}
