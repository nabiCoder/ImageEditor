import SwiftUI
import PhotosUI
import AVFoundation
import PencilKit

struct ImageEditorScreen<EditorViewModel, AuthViewModel>: View
where EditorViewModel: ImageEditorViewModelType, AuthViewModel: AuthViewModelType {
    // MARK: - View Models
    @StateObject private var editorViewModel: EditorViewModel
    @StateObject private var authViewModel: AuthViewModel
    // MARK: - Media State
    @State private var imageToShare: UIImage?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isCameraPresented = false
    @State private var isSaveAlertPresented = false
    // MARK: - Drawing State
    @State private var canvasView = PKCanvasView()
    @State private var isDrawingEnabled = false
    @State private var canvasSize: CGSize = .zero
    // MARK: - Transform State
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Angle = .zero
    
    @GestureState private var gestureRotation: Angle = .zero
    @GestureState private var gestureScale: CGFloat = 1.0
    
    // MARK: - Text Overlay
    @State private var selectedColor: Color = .white
    @State private var selectedFont: Font = .title
    @State private var newTextInput: String = ""
    @State private var selectedFontSize: CGFloat = 24
    
    init(viewModel: EditorViewModel, authViewModel: AuthViewModel) {
        _editorViewModel = StateObject(wrappedValue: viewModel)
        _authViewModel = StateObject(wrappedValue: authViewModel)
    }
    
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                VStack(alignment: .center, spacing: 10) {
                    imageEditingArea
                    
                    Divider()
                    
                    controlsStack
                }
                .padding()
                .background(.ultraThinMaterial)
            }
            .navigationTitle("Editor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Sign Out") {
                        authViewModel.signOut()
                    }
                    .buttonStyle(.bordered)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    if isDrawingEnabled {
                        Button("Done", role: .cancel) {
                            isDrawingEnabled = false
                        }
                        .buttonStyle(.borderedProminent)
                        .padding()
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $isCameraPresented) {
            ImagePicker(sourceType: .camera) { image in
                editorViewModel.selectedImage = image
                editorViewModel.resetImageFilter()
            }
        }
        .sheet(item: $imageToShare) { image in
            ActivitySheet(items: [image])
        }
        .alert("Saved!", isPresented: $isSaveAlertPresented) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your image was saved to Photos.")
        }
    }
    
    // MARK: - Под-вью: область редактирования изображения
    private var imageEditingArea: some View {
        ZStack {
            imageOrPlaceholder
            
            if editorViewModel.selectedImage != nil {
                DrawingCanvasView(
                    isDrawingEnabled: $isDrawingEnabled,
                    canvasView: $canvasView,
                    selectedImage: editorViewModel.filteredImage ?? editorViewModel.selectedImage
                )
                .onPreferenceChange(CanvasSizeKey.self) { newSize in
                    canvasSize = newSize
                }
            }
            
            ForEach($editorViewModel.textOverlays) { $overlay in
                DraggableText(overlay: $overlay)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
    
    @ViewBuilder
    private var imageOrPlaceholder: some View {
        if let image = editorViewModel.filteredImage ?? editorViewModel.selectedImage {
            imageView(image)
        } else {
            Text("No image selected")
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor.systemBackground))
        }
    }
    
    // MARK: - Под-вью: панель управления
    private var controlsStack: some View {
        VStack(spacing: 20) {
            TextRenderer(
                inputText: newTextInput,
                selectedFont: selectedFont,
                selectedSize: selectedFontSize,
                selectedColor: selectedColor,
                viewModel: editorViewModel
            )
            .padding(.horizontal)
            .opacity(editorViewModel.selectedImage != nil ? 1 : 0)
            
            toolsBar
            
            HStack {
                Button("Reset Changes") {
                    editorViewModel.resetChangesOnScreen {
                        canvasView.drawing = PKDrawing()
                        editorViewModel.textOverlays.removeAll()
                    }
                }
                .buttonStyle(.bordered)
            }
            .padding(.bottom)
        }
    }
    
    private var toolsBar: some View {
        HStack(spacing: AppConstants.ImageEditorConstants.instrumentsSpacing) {
            // Draw
            Button {
                isDrawingEnabled.toggle()
            } label: {
                toolLabel("Draw", systemImage: "pencil.tip.crop.circle")
            }
            
            // Library
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                toolLabel("Library", systemImage: "photo.on.rectangle")
            }
            .onChange(of: selectedPhotoItem, { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        editorViewModel.selectedImage = image
                        editorViewModel.resetImageFilter()
                    }
                }
            })
            
            // Camera
            Button {
                checkCameraPermission { granted in
                    if granted {
                        isCameraPresented = true
                    }
                }
            } label: {
                toolLabel("Camera", systemImage: "camera")
            }
            
            // Filters
            Menu {
                Button("Sepia") { editorViewModel.applySepiaFilter(intensity: 1.0) }
                Button("Mono")  { editorViewModel.applyFilter(name: "CIPhotoEffectMono") }
                Button("Noir")  { editorViewModel.applyFilter(name: "CIPhotoEffectNoir") }
                Button("Chrome"){ editorViewModel.applyFilter(name: "CIPhotoEffectChrome") }
                Button("Fade")  { editorViewModel.applyFilter(name: "CIPhotoEffectFade") }
                Button("Reset") { editorViewModel.resetImageFilter() }
            } label: {
                toolLabel("Filters", systemImage: "camera.filters")
            }
            
            // Save
            Button {
                saveDrawing(canvasSize: canvasSize)
            } label: {
                toolLabel("Save", systemImage: "square.and.arrow.down")
            }
            
            // Share
            Button {
                imageToShare = editorViewModel.renderFinalImage(
                    canvasView: canvasView,
                    in: UIScreen.main.bounds.size
                )
            } label: {
                toolLabel("Share", systemImage: "square.and.arrow.up")
            }
        }
        .labelStyle(IconOnlyLabelStyle())
        .frame(height: 44)
        .padding(.horizontal)
    }
    
    private func toolLabel(_ text: String, systemImage: String) -> some View {
        Label(text, systemImage: systemImage)
            .font(.system(size: AppConstants.ImageEditorConstants.buttonHeight))
            .frame(
                width: AppConstants.ImageEditorConstants.buttonHeight,
                height: AppConstants.ImageEditorConstants.buttonHeight
            )
    }
    
    // MARK: - ViewBuilder
    
    @ViewBuilder
    private func imageView(_ uiImage: UIImage) -> some View {
        GeometryReader { geo in
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(width: geo.size.width, height: geo.size.height)
                .scaleEffect(scale * gestureScale)
                .rotationEffect(rotation + gestureRotation)
                .gesture(
                    SimultaneousGesture(
                        MagnificationGesture()
                            .updating($gestureScale) { value, state, _ in state = value }
                            .onEnded { scale *= $0 },
                        RotationGesture()
                            .updating($gestureRotation) { angle, state, _ in state = angle }
                            .onEnded { rotation += $0 }
                    )
                )
        }
    }
    
    func saveDrawing(canvasSize: CGSize) {
        let finalSize = (canvasSize == .zero)
        ? (editorViewModel.selectedImage?.size ?? CGSize(width: 300, height: 300))
        : canvasSize
        
        editorViewModel.saveToPhotoLibrary(canvasView: canvasView,
                                           targetSize: finalSize) { result in
            if case .success = result {
                isSaveAlertPresented = true
            }
        }
    }
}


#Preview {
    ImageEditorScreen(
        viewModel: ImageEditorViewModel(photoLibService: PhotoLibraryService()),
        authViewModel: AuthViewModel(
            authService: FirebaseAuthService(),
            googleAuthService: GoogleAuthService()
        )
    )
}
