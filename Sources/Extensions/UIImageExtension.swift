//
//  ImageExtension.swift
//  BlackBook
//
//  Created by Nikolas on 05.12.2022.
//

import Foundation
import UIKit

extension UIImage {
    func toPixelImage(_ scaleValue: Int) -> UIImage?{
        guard let currentCGImage = self.cgImage else { return nil}
        let currentCIImage = CIImage(cgImage: currentCGImage)

        let filter = CIFilter(name: "CIPixellate")
        filter?.setValue(currentCIImage, forKey: kCIInputImageKey)
        filter?.setValue(scaleValue, forKey: kCIInputScaleKey)
        guard let outputImage = filter?.outputImage else { return nil}

        let context = CIContext()
        
        guard let cgimg = context.createCGImage(outputImage, from: outputImage.extent) else{return nil}
        let processedImage = UIImage(cgImage: cgimg)
        return processedImage
    }
    
    func inverseImage(cgResult: Bool) -> UIImage? {
        let coreImage = UIKit.CIImage(image: self)
        guard let filter = CIFilter(name: "CIColorInvert") else { return nil }
        filter.setValue(coreImage, forKey: kCIInputImageKey)
        guard let result = filter.value(forKey: kCIOutputImageKey) as? UIKit.CIImage else { return nil }
        if cgResult {
            return UIImage(cgImage: CIContext(options: nil).createCGImage(result, from: result.extent)!)
        }
        return UIImage(ciImage: result)
      }
    
    func resizeImage(targetSize: CGSize) -> UIImage {
            let size = self.size

            let widthRatio  = targetSize.width  / size.width
            let heightRatio = targetSize.height / size.height

            var newSize: CGSize
            if(widthRatio > heightRatio) {
                newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            } else {
                newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
            }

            let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            self.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return newImage!
        }
}
