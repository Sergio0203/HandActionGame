//
//  ARCoordinator.swift
//  Poc IA
//
//  Created by Sérgio César Lira Júnior on 17/03/25.
//

import ARKit
import RealityKit

extension ContentViewModel: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        frameCount += 1
        guard frameCount % 2 == 0 else {
            return
        }
        
        didGetFrames(frame: frame.capturedImage)
    }
    
}

