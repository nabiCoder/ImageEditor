import SwiftUI
import FirebaseCore

@main
struct ImageEditorTestApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            let authViewModel = DIContainer.shared.authViewModel
            let editorViewModel = DIContainer.shared.editorViewModel
            
            BaseContentView(
                authViewModel: authViewModel,
                editorViewModel: editorViewModel
            )
        }
    }
}
