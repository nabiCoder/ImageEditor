import SwiftUI
import CoreImage.CIFilterBuiltins
import PencilKit
import Photos

typealias ImageEditorViewModelType = ObservableObject & ImageEditorViewModelProtocol

protocol ImageEditorViewModelProtocol: ObservableObject {
    
}

final class ImageEditorViewModel<PhotoLibViewModel>: ImageEditorViewModelTyp where PhotoLibViewModel: PhotoLibraryServiceType {
    
    @ObservedObject private var photoLibService: PhotoLibViewModel

    init(photoLibService: PhotoLibViewModel) {
        self.photoLibService = photoLibService
    }

}
