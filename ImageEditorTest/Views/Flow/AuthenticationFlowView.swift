import SwiftUI

struct AuthenticationFlowView<ViewModel>: View where ViewModel: AuthViewModelType {

    @ObservedObject private var authViewModel: ViewModel

    init(authViewModel: ViewModel) {
        self.authViewModel = authViewModel
    }

    var body: some View {
        NavigationStack {
            SignInScreen(viewModel: authViewModel)
        }
    }
}
