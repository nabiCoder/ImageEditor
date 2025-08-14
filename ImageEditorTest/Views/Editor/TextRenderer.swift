import SwiftUI

struct TextRenderer<ViewModel>: View where ViewModel: ImageEditorViewModelType {
    // MARK: - Properties
    @State var inputText: String
    @State var selectedFont: Font
    @State var selectedSize: CGFloat
    @State var selectedColor: Color
    
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        VStack(spacing: 18) {
            HStack(spacing: 10) {
                TextField("Enter text", text: $inputText)
                    .padding(.horizontal, 12)
                    .frame(height: AppConstants.ImageEditorConstants.textFieldHeight)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                    )
                    .font(.system(size: AppConstants.ImageEditorConstants.textFieldFontSize))
                    .frame(width: 180)
                
                Button("Add") {
                    addNewTextOverlay()
                }
                .font(.system(size: AppConstants.ImageEditorConstants.textFieldFontSize))
                .frame(width: AppConstants.ImageEditorConstants.addButtonWidth, height: AppConstants.ImageEditorConstants.buttonHeight)
                .disabled(inputText.isEmpty)
            }
            // Controls row
            HStack {
                Menu {
                    Button("Title") { selectedFont = .title }
                    Button("Body") { selectedFont = .body }
                } label: {
                    Label("Font", systemImage: "textformat")
                        .font(.system(size: AppConstants.ImageEditorConstants.buttonHeight))
                        .frame(width: AppConstants.ImageEditorConstants.buttonWidth, height: AppConstants.ImageEditorConstants.buttonHeight)
                }
                
                ColorPicker("", selection: $selectedColor)
                    .font(.system(size: AppConstants.ImageEditorConstants.buttonHeight))
                    .frame(width: AppConstants.ImageEditorConstants.buttonWidth, height: AppConstants.ImageEditorConstants.buttonHeight)
                
                Slider(value: $selectedSize, in: 12...72) {
                    Text("Size")
                }
                .frame(width: 120)
            }
        }
    }
    
    private func addNewTextOverlay() {
        let uiFont: UIFont
        switch selectedFont {
        case .title:
            uiFont = UIFont.systemFont(ofSize: selectedSize, weight: .bold)
        case .body:
            uiFont = UIFont.systemFont(ofSize: selectedSize, weight: .regular)
        default:
            uiFont = UIFont.systemFont(ofSize: selectedSize)
        }
        
        let overlay = TextOverlay(
            text: inputText,
            font: uiFont,
            color: selectedColor,
            size: selectedSize
        )
        
        viewModel.textOverlays.append(overlay)
        inputText = ""
    }
}

#Preview {
    TextRenderer(
        inputText: "",
        selectedFont: .body,
        selectedSize: 0,
        selectedColor: .red,
        viewModel: ImageEditorViewModel(photoLibService: PhotoLibraryService())
    )
}
