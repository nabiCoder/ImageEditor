import SwiftUI
import UIKit

struct ActivitySheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func updateUIViewController(_ uiViewController: UIActivityViewController,
                                context: Context) { }
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
}
