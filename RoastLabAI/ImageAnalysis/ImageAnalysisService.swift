import Foundation
import UIKit

struct PhotoAnalysis: Identifiable {
    var id = UUID()
    var summary: String
    var observations: [String]
    var dominantFormat: String
}

final class PhotoAnalysisService {
    func analyze(imageData: Data?) async -> PhotoAnalysis {
        guard let imageData, let image = UIImage(data: imageData) else {
            return PhotoAnalysis(
                summary: "A selected image ready for a playful comedy prompt.",
                observations: ["No face recognition is performed.", "Only basic local image format details are used."],
                dominantFormat: "unknown"
            )
        }

        let width = Int(image.size.width)
        let height = Int(image.size.height)
        let format = width > height ? "landscape" : width == height ? "square" : "portrait"

        return PhotoAnalysis(
            summary: "A \(format) image sized \(width)x\(height), ready for playful visual roasting.",
            observations: [
                "Image stays on this device in the current build.",
                "Only dimensions and orientation are read locally.",
                "No face landmarks, faceprints, or biometric identifiers are created."
            ],
            dominantFormat: format
        )
    }
}
