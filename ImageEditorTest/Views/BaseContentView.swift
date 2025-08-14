import SwiftUI

struct BaseContentView<AuthViewModel, EditorViewModel>: View where AuthViewModel: AuthViewModelType,
                                                                    EditorViewModel: ImageEditorViewModelType {
    
    @StateObject private var authViewModel: AuthViewModel
    @StateObject private var editorViewModel: EditorViewModel
    
    init(authViewModel: AuthViewModel, editorViewModel: EditorViewModel) {
        _authViewModel = StateObject(wrappedValue: authViewModel)
        _editorViewModel = StateObject(wrappedValue: editorViewModel)
    }

    var body: some View {
        Group {
            switch authViewModel.appState {
            case .editor:
                ImageEditorScreen(viewModel: editorViewModel,
                                  authViewModel: authViewModel)
            case .auth:
                AuthenticationFlowView(authViewModel: authViewModel)
            }
        }
    }
}

#Preview {
    BaseContentView(
        authViewModel: AuthViewModel(authService: FirebaseAuthService(),
                                     googleAuthService: GoogleAuthService()),
        editorViewModel: ImageEditorViewModel(photoLibService: PhotoLibraryService())
    )
}
