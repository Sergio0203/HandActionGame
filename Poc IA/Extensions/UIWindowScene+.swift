//
//  UIWindowScene+.swift
//  AIPoC
//
//  Created by Eduardo Cordeiro da Camara on 14/03/25.
//

#if !os(macOS)
import UIKit


extension UIWindowScene {
    /// Returns the device orientation based on the window scene’s interface orientation.
    var deviceOrientation: UIDeviceOrientation {
        return switch self.interfaceOrientation {
        case .portrait: .portrait
        case .portraitUpsideDown: .portraitUpsideDown
        case .landscapeLeft: .landscapeLeft
        case .landscapeRight: .landscapeRight
        case .unknown: .unknown
        @unknown default: .unknown
        }
    }
}
#endif
