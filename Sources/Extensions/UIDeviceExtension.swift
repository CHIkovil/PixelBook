//
//  UIDeviceExtension.swift
//  BlackBook
//
//  Created by Nikolas on 11.12.2022.
//

import Foundation
import UIKit
import AVFoundation

extension UIDevice {
    static func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}
