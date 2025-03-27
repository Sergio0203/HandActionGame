//
//  CIIMage+Extension.swift
//  Poc IA
//
//  Created by Sérgio César Lira Júnior on 27/03/25.
//

import CoreImage

extension CIImage {
    var cgImage: CGImage? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else {
            return nil
        }
        return cgImage
    }
}
