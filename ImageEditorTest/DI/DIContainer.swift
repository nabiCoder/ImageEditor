import Swinject

final class DIContainer {
    static let shared = DIContainer()
    
    private init() { }
    
    // Сервисы
    private let authService = FirebaseAuthService()
    private let googleSignInService = GoogleAuthService()
    private let photoLibraryService = PhotoLibraryService()
    
    // ViewModels
    lazy var authViewModel = AuthViewModel(authService: authService,
                                           googleAuthService: googleSignInService)
    
    lazy var editorViewModel = ImageEditorViewModel(photoLibService: photoLibraryService)
}

