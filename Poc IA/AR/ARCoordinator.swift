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
    var points: [CGPoint] = []
    let sphereEntity = ModelEntity(mesh:  MeshResource.generateSphere(radius: 0.01), materials: [SimpleMaterial(color: .red, isMetallic: false)])
    
    
    init(arView: ARView){
        self.arView = arView
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        self.frame = frame
        self.session = session
        frameCount += 1
        points.removeAll()
        
        guard frameCount % 2 == 0 else {
            return
        }
        guard let views = arView?.subviews else { return }
        for view in views where view.layer.name == "particle" {
            view.removeFromSuperview()
        }
        
        
        guard let hands = getHands() else { return }
        addParticles()
        
        
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
        
        let cameraSize = CGSize(width: CVPixelBufferGetWidth(frame.capturedImage),
                                height: CVPixelBufferGetHeight(frame.capturedImage))
        
        guard let detectedHandPoses = handPoseRequest.results else { return nil }
        detectedHandPoses.forEach { hand in
            drawJoints(for: hand, cameraSize: cameraSize)
            do {
                
                result.append((try hand.keypointsMultiArray(), hand.chirality))
                
            } catch {
                assertionFailure("Hand Pose Request failed: \(error)")
            }
        }
        return result
    }
    
    private func drawJoints(for hand: VNHumanHandPoseObservation, cameraSize: CGSize) {
        let chirality = hand.chirality
        let viewPort = UIScreen.main.bounds.size
        do {
            let joints = try hand.recognizedPoints(.all)
            for (_, joint) in joints {
                joint
                if joint.confidence > 0.3 {
                    let location = joint.location
                    points.append(.init(x: location.y * viewPort.width,
                                        y: location.x * viewPort.height))
                }
            }
        } catch {
            assertionFailure("Error while processing joints: \(error)")
        }
    }
    
    private func convertPoint(_ point: CGPoint, cameraSize: CGSize, screenSize: CGSize) -> CGPoint {
        let aspectRatioScreen = screenSize.width / screenSize.height
        let aspectRatioCamera = cameraSize.width / cameraSize.height
        
        print("Camera Ration \(aspectRatioCamera) || Screen Ratio \(aspectRatioScreen)")
        
        var adjustedX = point.x
        var adjustedY = point.y
        
        if aspectRatioScreen > aspectRatioCamera {
            // A tela é mais larga do que o vídeo da câmera
            let scaleFactor = screenSize.height / cameraSize.height
            let scaledWidth = cameraSize.width * scaleFactor
            let xOffset = (screenSize.width - scaledWidth) / 2
            adjustedX = xOffset + (point.x * scaledWidth)
            adjustedY = (1 - point.y) * screenSize.height
        } else {
            // A tela é mais alta do que o vídeo da câmera
            let scaleFactor = screenSize.width / cameraSize.width
            let scaledHeight = cameraSize.height * scaleFactor
            let yOffset = (screenSize.height - scaledHeight) / 2
            adjustedX = point.x * screenSize.width
            adjustedY = yOffset + ((1 - point.y) * scaledHeight)
        }
        
        return .init(x: adjustedX, y: adjustedY)
    }
    
    private func addParticles(){
        for point in points {
            
            let point = CGRect(x: point.x, y: point.y, width: 10 , height: 10)
            
            let view = UIView(frame: point)
           
            view.layer.cornerRadius = 5
            view.backgroundColor = .red
            view.layer.name = "particle"
            arView?.addSubview(view)
        
            
        }
    }
    
}

