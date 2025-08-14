import SwiftUI

enum AppConstants {
    
    enum TitleConstants {
        static let defaultFontSize: CGFloat = 24
        static let defaultBottomPadding: CGFloat = 16
    }
    
    enum TextFieldConstants {
        static let horizontalPadding: CGFloat = 12
        static let height: CGFloat = 44
        static let cornerRadius: CGFloat = 12
        static let lineWidth: CGFloat = 1
        static let fontSize: CGFloat = 16
        
        static let validColor = Color.green
        static let invalidColor = Color.red
        static let defaultStrokeColor = Color.gray.opacity(0.6)
        static let backgroundColor = Color.white
    }
    
    enum ImageEditorConstants {
        static let textFieldFontSize: CGFloat =  17
        static let textFieldHeight: CGFloat = 30
        static var instrumentsSpacing: CGFloat = 30
        static var buttonHeight: CGFloat = 27
        static var buttonWidth: CGFloat = 35
        static var addButtonWidth: CGFloat = 40
        static var addButtonHeight: CGFloat = 30
    }
    
    enum AuthScenesConstants {
        static let titleSize: CGFloat = 32
        
        static let signUpTitle = "Sign up"
        static let createProfileTitle = "Create your profile"
        static let textMassage = "Please confirm your email via the link in your inbox!"
        
        static let passwordPlaceholder = "Enter your password"
        static let signInTitle = "Sign in"
        static let googleButton = "Sign in with Google"
        static let dontAccountTitle = "Don’t have an account?"
        static let registerButton = "Register account"
        static let signInSuccessMessage = "You have successfully signed in!"
        
        static let resetPasswordTitle = "Reset Password"
        static let emailPlaceholder = "Enter your email"
        static let resetButtonTitle = "Reset"
        static let successAlertTitle = "Password reseted"
        static let successAlertMessage = "Check your email to reset your password."
        static let errorAlertTitle = "Error"
        static let okButtonTitle = "OK"
    }
}
