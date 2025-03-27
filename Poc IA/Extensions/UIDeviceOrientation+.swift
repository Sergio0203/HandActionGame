//
//  UIDeviceOrientation+.swift
//  AIPoC
//
//  Created by Eduardo Cordeiro da Camara on 14/03/25.
//

#if !os(macOS)
import UIKit


extension UIDeviceOrientation {
    /// Returns the rotation angle in radians suitable for applying to video transforms.
    ///
    /// This mapping assumes:
    ///  - `.portrait`: 0
    ///  - `.landscapeLeft`: π/2 (90°)
    ///  - `.portraitUpsideDown`: π (180°)
    ///  - `.landscapeRight`: -π/2 (-90°)
    var videoRotationAngle: CGFloat {
        switch self {
        case .portrait:
            return 0
        case .landscapeLeft:
            return CGFloat.pi / 2
        case .portraitUpsideDown:
            return CGFloat.pi
        case .landscapeRight:
            return -CGFloat.pi / 2
        default:
            return 0
        }
    }
}
#endif
