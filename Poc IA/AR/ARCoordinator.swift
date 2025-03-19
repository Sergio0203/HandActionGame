//
//  ARCoordinator.swift
//  Poc IA
//
//  Created by Sérgio César Lira Júnior on 17/03/25.
//

import ARKit

class ARCoordinator: NSObject, ARSessionDelegate {
    var frameCount: Int = 0
    var frameThreshFold: Int = 60
    var sampleCount: Int = 0
    var queue = [MLMultiArray]()
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        frameCount += 1
        guard frameCount % 2 == 0 else {
            return
        }
        
        guard let hands = getHands(from: frame) else { return }
        
        for (pose, chirality) in hands {
            guard chirality == .right else { return }
            queue.append(pose)
            queue = Array(queue.suffix(frameThreshFold))
            sampleCount += 1
            if sampleCount % 30 == 0  {
                print("predizendo...")
                ClassifierService.shared.classify(poses: queue)
            }
        }
    }
    
    private func getHands(from frame: ARFrame) -> [(MLMultiArray, VNChirality)]? {
        let handPoseRequest = VNDetectHumanHandPoseRequest()
        var result: [(MLMultiArray, VNChirality)] = []
        handPoseRequest.maximumHandCount = 2
        let pixelBuffer = frame.capturedImage
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            try handler.perform([handPoseRequest])
        } catch {
            assertionFailure("Human Pose Request failed: \(error)")
        }
        guard let detectedHandPoses = handPoseRequest.results else { return nil }
        
        detectedHandPoses.forEach { hand in
            do {
                result.append((try hand.keypointsMultiArray(), hand.chirality))
            }catch {
                assertionFailure("Hand Pose Request failed: \(error)")
            }
        }
    
        return result
    }
}

