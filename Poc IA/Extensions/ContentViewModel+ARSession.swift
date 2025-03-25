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
        getJointsLocation(for: hands)
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
            guard let pose = hand.getMLMultiArray() else { return }

            if hand.chirality == .right {
                // Action Classify
                queue.append(pose)
                queue = Array(queue.suffix(queueSize))
                sampleCounter += 1
                if queueSize == queue.count && sampleCounter % sampleCount == 0  {
                    print("predizendo...")
                    ClassifierService.shared.classifyAction(poses: queue)
                }
            } else if hand.chirality == .left {
                //Pose Classify
                ClassifierService.shared.classifyPoses(pose: pose)
            }
        }
    }
    
    private func getJointsLocation(for hands: [HandModel]) {
        let viewPort = UIScreen.main.bounds.size
        for hand in hands {
            for joint in hand.joints {
                if joint.confidence > 0.3 {
                    let location = joint.location
                    points.append(.init(x: location.x * viewPort.width,
                                        y: location.y * viewPort.height))
                }
            }
        }
        addParticles()
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

