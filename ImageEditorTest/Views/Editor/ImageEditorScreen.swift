import SwiftUI

struct ImageEditorScreen<EditorViewModel, AuthViewModel>: View
where EditorViewModel: ImageEditorViewModelType, AuthViewModel: AuthViewModelType {

    @StateObject private var editorViewModel: EditorViewModel
    @StateObject private var authViewModel: AuthViewModel

    init(viewModel: EditorViewModel, authViewModel: AuthViewModel) {
        _editorViewModel = StateObject(wrappedValue: viewModel)
        _authViewModel = StateObject(wrappedValue: authViewModel)
    }

    var body: some View {
        Text("ImageEditorScreen")
    }

    
}
