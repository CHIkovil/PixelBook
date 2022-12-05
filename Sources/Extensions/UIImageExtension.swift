//
//  ImageExtension.swift
//  BlackBook
//
//  Created by Nikolas on 05.12.2022.
//

import Foundation
import UIKit

extension UIImage {
    func toPixelImage() -> UIImage?{
        guard let currentCGImage = self.cgImage else { return nil}
        let currentCIImage = CIImage(cgImage: currentCGImage)

        let filter = CIFilter(name: "CIPixellate")
        filter?.setValue(currentCIImage, forKey: kCIInputImageKey)
        filter?.setValue(12, forKey: kCIInputScaleKey)
        guard let outputImage = filter?.outputImage else { return nil}

        let context = CIContext()
        
        guard let cgimg = context.createCGImage(outputImage, from: outputImage.extent) else{return nil}
        let processedImage = UIImage(cgImage: cgimg)
        return processedImage
    }
}
