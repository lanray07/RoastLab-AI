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
                summary: "A selected creator image with social profile energy.",
                observations: ["Image placeholder detected.", "Ready for safe comedy observations."],
                dominantFormat: "unknown"
            )
        }

        let width = Int(image.size.width)
        let height = Int(image.size.height)
        let format = width > height ? "landscape" : width == height ? "square" : "portrait"

        return PhotoAnalysis(
            summary: "A \(format) image sized \(width)x\(height), ready for playful visual roasting.",
            observations: [
                "Strong profile-photo potential.",
                "The crop has creator-feed energy.",
                "Good candidate for meme-style captions."
            ],
            dominantFormat: format
        )
    }
}
