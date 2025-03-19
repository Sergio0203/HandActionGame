//
//  ARCoordinator.swift
//  Poc IA
//
//  Created by Sérgio César Lira Júnior on 17/03/25.
//

import ARKit
import RealityKit

class ARCoordinator: NSObject, ARSessionDelegate {
    var frameCount: Int = 0
    var sampleCount: Int = 30
    var queueSize: Int = 30
    var sampleCounter: Int = 0
    var queue = [MLMultiArray]()
    var frame: ARFrame?
    var session: ARSession?
    var arView: ARView?
    var points: [CGPoint]
    init(arView: ARView){
        self.arView = arView
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        self.frame = frame
        self.session = session
        frameCount += 1
        guard frameCount % 2 == 0 else {
            return
        }
        self.arView?.scene.anchors.removeAll()

        
        guard let hands = getHands() else { return }
        
        for (pose, chirality) in hands where chirality == .right {
            queue.append(pose)
            queue = Array(queue.suffix(queueSize))
            sampleCounter += 1
            if queueSize == queue.count && sampleCounter % sampleCount == 0  {
                print("predizendo...")
                ClassifierService.shared.classify(poses: queue)
            }
        }
    }
    
    private func getHands() -> [(MLMultiArray, VNChirality)]? {
        let handPoseRequest = VNDetectHumanHandPoseRequest()
        var result: [(MLMultiArray, VNChirality)] = []
        handPoseRequest.maximumHandCount = 2
        guard let frame else { return nil }
        let pixelBuffer = frame.capturedImage
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        
        do {
            try handler.perform([handPoseRequest])
        } catch {
            assertionFailure("Human Pose Request failed: \(error)")
        }
        guard let detectedHandPoses = handPoseRequest.results else { return nil }
        detectedHandPoses.forEach { hand in
            drawJoints(for: hand)
            do {
                result.append((try hand.keypointsMultiArray(), hand.chirality))
            } catch {
                assertionFailure("Hand Pose Request failed: \(error)")
            }
        }
        
        return result
    }
    
    private func drawJoints(for hand: VNHumanHandPoseObservation) {
        let chirality = hand.chirality
        let viewPort = UIScreen.main.bounds.size
        do {
            let joints = try hand.recognizedPoints(.all)
            for (jointName, joint) in joints {
                if joint.confidence > 0.3 {
                    let location = joint.location
                    points.append(.init(x: location.x * viewPort.width, y: location.y * viewPort.height))
                }
            }
        } catch {
            assertionFailure("Error while processing joints: \(error)")
        }
    }
   
}

