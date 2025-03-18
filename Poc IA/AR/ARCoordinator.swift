//
//  ARCoordinator.swift
//  Poc IA
//
//  Created by Sérgio César Lira Júnior on 17/03/25.
//

import ARKit

class ARCoordinator: NSObject, ARSessionDelegate {
    var frameCount: Int = 0
    var frameThreshFold: Int = 1
    var queue = [MLMultiArray]()
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        frameCount += 1
        guard frameCount % 2 == 0 else {
            return
        }
        
        getHands(from: frame)
        
        
    }
    
    private func getHands(from frame: ARFrame) -> (MLMultiArray, VNChirality)? {
        let handPoseRequest = VNDetectHumanHandPoseRequest()
        handPoseRequest.maximumHandCount = 1
        let pixelBuffer = frame.capturedImage
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            try handler.perform([handPoseRequest])
        } catch {
            assertionFailure("Human Pose Request failed: \(error)")
        }
        guard let detectedHandPose = handPoseRequest.results?.first else { return nil }
        
        guard let arrayML = try? detectedHandPose.keypointsMultiArray() else { return nil }
        let chirality = detectedHandPose.chirality
    
        switch chirality {
        case .left:
            print("left")
        case .right:
            print("right")
        case .unknown:
            print("unknow")
        }
        return (arrayML, chirality)
    }
}

