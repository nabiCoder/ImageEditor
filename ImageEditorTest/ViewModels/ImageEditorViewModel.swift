import SwiftUI
import PencilKit
import CoreImage.CIFilterBuiltins
import Photos

typealias ImageEditorViewModelType = ObservableObject & ImageEditorViewModelProtocol

protocol ImageEditorViewModelProtocol: ObservableObject {
    var selectedImage: UIImage? { get set }
    var filteredImage: UIImage? { get set }
    var textOverlays: [TextOverlay] { get set }
    
    func resetImageFilter()
    func applyFilter(name: String)
    func applySepiaFilter(intensity: Double)
    func resetChangesOnScreen(_ completion: @escaping () -> Void)
    func saveToPhotoLibrary(canvasView: PKCanvasView,
                            targetSize: CGSize,
                            completion: @escaping (Result<Void, Error>) -> Void)
    func renderFinalImage(canvasView: PKCanvasView, in size: CGSize) -> UIImage?
}

final class ImageEditorViewModel<PhotoLibViewModel>: ImageEditorViewModelType
where PhotoLibViewModel: PhotoLibraryServiceType {
    
    @Published var selectedImage: UIImage? {
        didSet { filteredImage = selectedImage}
    }
    
    @Published var filteredImage: UIImage?
    @Published var textOverlays: [TextOverlay] = []
    
    @ObservedObject private var photoLibService: PhotoLibViewModel
    
    private let context = CIContext()
    private let sepiaFilter = CIFilter.sepiaTone()
    
    private let noir = CIFilter.photoEffectNoir()
    private let mono = CIFilter.photoEffectMono()
    private let fade = CIFilter.photoEffectFade()
    private let chrome = CIFilter.photoEffectChrome()
    
    init(photoLibService: PhotoLibViewModel) {
        self.photoLibService = photoLibService
    }
    
    func resetImageFilter() {
        filteredImage = selectedImage
    }
    
    func applyFilter(name: String) {
        guard let input = selectedImage,
              let ciInput = CIImage(image: input) else { return }
        
        let filter: CIFilter? = {
            switch name {
            case "CIPhotoEffectMono":    return mono
            case "CIPhotoEffectNoir":    return noir
            case "CIPhotoEffectChrome":  return chrome
            case "CIPhotoEffectFade":    return fade
            default:                     return nil
            }
        }()
        
        filter?.setValue(ciInput, forKey: kCIInputImageKey)
        
        guard let output = filter?.outputImage,
              let cgImage = context.createCGImage(output, from: output.extent) else {
            return
        }
        
        filteredImage = UIImage(cgImage: cgImage)
    }
    
    func applySepiaFilter(intensity: Double = 1.0) {
        guard let inputImage = selectedImage,
              let ciInput = CIImage(image: inputImage) else {
            return
        }
        
        sepiaFilter.inputImage = ciInput
        sepiaFilter.intensity = Float(intensity)
        
        guard let ciOutput = sepiaFilter.outputImage,
              let cgImage = context.createCGImage(ciOutput, from: ciOutput.extent) else {
            return
        }
        
        filteredImage = UIImage(cgImage: cgImage)
    }
    
    func resetChangesOnScreen(_ completion: @escaping () -> Void) {
        completion()
        resetImageFilter()
    }
}

extension ImageEditorViewModel {
    func saveToPhotoLibrary(canvasView: PKCanvasView,
                            targetSize: CGSize,
                            completion: @escaping (Result<Void, Error>) -> Void) {
        guard let image = renderFinalImage(canvasView: canvasView, in: targetSize) else {
            completion(.failure(NSError(domain: "RenderError", code: 0)))
            return
        }
        
        getPhotoLibraryAccess(image: image, completion: completion)
    }
    
    func getPhotoLibraryAccess(image: UIImage, completion: @escaping (Result<Void, Error>) -> Void) {
        photoLibService.getPhotoLibraryAccess(image: image, completion: completion)
    }
}

extension ImageEditorViewModel {
    func renderFinalImage(canvasView: PKCanvasView, in size: CGSize) -> UIImage? {
        photoLibService.renderFinalImage(canvasView: canvasView,
                                         filteredImage: filteredImage,
                                         selectedImage: selectedImage,
                                         textOverlays: textOverlays,
                                         in: size
        )
    }
}
