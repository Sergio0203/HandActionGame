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
        
        refreshPointsInView()
        
        let hands = handsService.detectHands(in: frame.capturedImage, numberOfHands: 2)
        addParticles()
        
        sendToIa(hands: hands)
        
        
    }
    
    private func refreshPointsInView(){
        points.removeAll()
        guard let views = arContainer?.arView.subviews else { return }
        for view in views where view.layer.name == "particle" {
            view.removeFromSuperview()
        }
    }
    
    private func sendToIa(hands: [HandModel]) {
        for hand in hands {
            if hand.chirality == .right {
                // Action Classify
                queue.append(hand.getMLMultiArray())
                queue = Array(queue.suffix(queueSize))
                sampleCounter += 1
                if queueSize == queue.count && sampleCounter % sampleCount == 0  {
                    print("predizendo...")
                    ClassifierService.shared.classify(poses: queue)
                }
            } else if hand.chirality == .left {
                //Pose Classify
            }
        }
    }
    
    private func drawJoints(for hand: HandModel) {
        let chirality = hand.chirality
        let viewPort = UIScreen.main.bounds.size
        
        let joints = hand.joints
        
        
        for joint in joints {
            if joint.confidence > 0.3 {
                let location = joint.location
                points.append(.init(x: location.y * viewPort.width,
                                    y: location.x * viewPort.height))
            }
        }
        
        
    }
    
    
    private func addParticles(){
        for point in points{
            
            let point = CGRect(x: point.x, y: point.y, width: 10 , height: 10)
            
            let view = UIView(frame: point)
            
            view.layer.cornerRadius = 5
            view.backgroundColor = .red
            view.layer.name = "particle"
            arContainer?.arView.addSubview(view)
        }
    }
    
}

