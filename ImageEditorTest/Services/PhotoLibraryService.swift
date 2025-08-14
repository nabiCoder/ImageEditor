import UIKit
import Photos
import PencilKit

typealias PhotoLibraryServiceType = ObservableObject & PhotoLibraryServiceProtocol

protocol PhotoLibraryServiceProtocol {
    func getPhotoLibraryAccess(image: UIImage,
                               completion: @escaping (Result<Void, Error>) -> Void)
    func renderFinalImage(canvasView: PKCanvasView,
                          filteredImage: UIImage?,
                          selectedImage: UIImage?,
                          textOverlays: [TextOverlay],
                          in size: CGSize) -> UIImage?
}

final class PhotoLibraryService: PhotoLibraryServiceType {
    /// Requests access to the user's photo library and saves the provided image if authorized.
    ///
    /// This method first checks the current authorization status. If authorized, it attempts to save the image.
    /// If not determined, it requests permission and retries the operation.
    ///
    /// - Parameters:
    ///   - image: The image to be saved to the photo library.
    ///   - completion: Completion handler that returns `.success` if the image was saved,
    ///                 or `.failure` if access was denied or an error occurred while saving.
    func getPhotoLibraryAccess(
        image: UIImage,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                } completionHandler: { _, error in
                    DispatchQueue.main.async {
                        if let err = error {
                            completion(.failure(err))
                        } else {
                            completion(.success(()))
                        }
                    }
                }
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { _ in
                    DispatchQueue.main.async {
                        self.getPhotoLibraryAccess(image: image, completion: completion)
                    }
                }
            case .restricted, .denied, .limited:
                DispatchQueue.main.async {
                    let error = NSError(domain: "PhotoLibraryAccess",
                                        code: 1,
                                        userInfo: [NSLocalizedDescriptionKey: "Access to Photo Library denied."])
                    completion(.failure(error))
                }
            @unknown default:
                DispatchQueue.main.async {
                    let error = NSError(domain: "PhotoLibraryAccess",
                                        code: 2,
                                        userInfo: [NSLocalizedDescriptionKey: "Unknown authorization status."])
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Combines the selected image, drawing, filters, and text overlays into a final rendered image.
    ///
    /// This method composites different visual layers: the base image (filtered or selected),
    /// any PencilKit drawings, and optional text overlays, all into a single image with the given size.
    ///
    /// - Parameters:
    ///   - canvasView: The `PKCanvasView` containing the user's drawing.
    ///   - filteredImage: An optional filtered version of the image.
    ///   - selectedImage: The original selected image, used if `filteredImage` is nil.
    ///   - textOverlays: An array of `TextOverlay` objects representing text to be rendered on the image.
    ///   - size: The target size of the final image.
    /// - Returns: A new `UIImage` representing the final composition, or `nil` if rendering fails.
    func renderFinalImage(canvasView: PKCanvasView,
                          filteredImage: UIImage?,
                          selectedImage: UIImage?,
                          textOverlays: [TextOverlay],
                          in size: CGSize) -> UIImage? {
        // 1. Set up the renderer's format so that
        //    its scale matches the canvasView's scale
        let format = UIGraphicsImageRendererFormat()
        format.scale = canvasView.contentScaleFactor
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        
        return renderer.image { _ in
            // Base photo (scaled to fit 'size')
            if let base = filteredImage ?? selectedImage {
                base.draw(in: CGRect(origin: .zero, size: size))
            }
            
            // 3. PencilKit drawing
            let drawing = canvasView.drawing
            if !drawing.strokes.isEmpty {
                // Рисуем всю площадь канваса
                let rect = CGRect(origin: .zero, size: size)
                let drawingImage = drawing.image(from: rect, scale: format.scale)
                drawingImage.draw(in: rect)
            }
            
            // 4. Text
            for overlay in textOverlays {
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: overlay.font.withSize(overlay.size),
                    .foregroundColor: UIColor(overlay.color)
                ]
                let attributed = NSAttributedString(string: overlay.text, attributes: attrs)
                let point = CGPoint(
                    x: overlay.offset.width + size.width / 2,
                    y: overlay.offset.height + size.height / 2
                )
                attributed.draw(at: point)
            }
        }
    }
}

