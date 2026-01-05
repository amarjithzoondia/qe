//
//  UIImage+Extension.swift
//  ALNASR
//
//  Created by Amarjith B on 12/12/25.
//

import Foundation
import UIKit

extension UIImage {

    /// Compress image as much as possible while keeping reasonable quality
    func compressToMaximum(maxKB: Int = 300) -> UIImage {
        var compression: CGFloat = 1.0
        let maxBytes = maxKB * 1024
        var imageData = self.jpegData(compressionQuality: compression)!

        // Reduce quality by 10% gradually until the size fits
        while imageData.count > maxBytes && compression > 0.05 {
            compression -= 0.1
            if let data = self.jpegData(compressionQuality: compression) {
                imageData = data
            }
        }

        // If still large → resize image by scaling down
        if imageData.count > maxBytes {
            let ratio = CGFloat(maxBytes) / CGFloat(imageData.count)
            let scale = sqrt(ratio)
            let newWidth = size.width * scale
            let newHeight = size.height * scale
            let resized = self.resize(to: CGSize(width: newWidth, height: newHeight))

            return resized.compressToMaximum(maxKB: maxKB)
        }

        return UIImage(data: imageData) ?? self
    }

    /// Resize helper
    func resize(to targetSize: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1 // prevents 3x inflated size
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
