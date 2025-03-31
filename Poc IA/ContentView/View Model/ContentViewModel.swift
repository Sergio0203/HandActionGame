//
//  ContentModelView.swift
//  Poc IA
//
//  Created by Sérgio César Lira Júnior on 24/03/25.
//
import RealityKit
import SwiftUI
import ARKit

public enum MovePrediction: String {
    case left = "Left"
    case right = "Right"
    case up = "Up"
    case down = "Down"
    case none = "None"
}

public enum HandPrediction: String {
    case open
    case closed
    case other
}

enum PreviewType {
    case camera, ar
}

final class ContentViewModel: NSObject, ObservableObject {
    
    @Published var rightPrediction: String = ""
    @Published var rightPredictionConfidence: Double = 0
    @Published var leftPrediction: String = ""
    @Published var leftPredictionConfidence: Double = 0

    var frameCount: Int = 0
    var sampleCount: Int = 30
    var queueSize: Int = 30
    var sampleCounter: Int = 0
    var queue = [MLMultiArray]()
    @Published var points: [CGPoint] = []
    
    var cameraContainer: CameraContainer?
    var arContainer: ARViewContainer?
    
    let handsService: HandsDetectorProtocol

    init(handsService: HandsDetectorProtocol = HandsService()) {
        self.handsService = handsService
        super.init()
        arContainer = ARViewContainer(delegate: self)
        cameraContainer = CameraContainer(delegate: self)
    }
    
    func sendToIa(hands: [HandModel]) {
        for hand in hands {
            guard let pose = hand.getMLMultiArray() else { return }
            if hand.chirality == .right {
                // Action Classify
                queue.append(pose)
                queue = Array(queue.suffix(queueSize))
                sampleCounter += 1
                if queueSize == queue.count && sampleCounter % sampleCount == 0  {
                    guard let result = ClassifierService.shared.classifyAction(poses: queue) else { return }
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        (self.rightPrediction, self.rightPredictionConfidence) = result
                    }
                }
            } else if hand.chirality == .left {
                //Pose Classify
                guard let result = ClassifierService.shared.classifyPoses(pose: pose) else { return }
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    (self.leftPrediction, self.leftPredictionConfidence) = result
                }
            }
        }
    }
    
    func getJointsLocation(for hands: [HandModel]) {
        let viewPort = UIScreen.main.bounds.size
        var points = [CGPoint]()
        for hand in hands {
            for joint in hand.joints {
                if joint.confidence > 0.5 {
                    let location = joint.location
                    points.append(CGPoint(x: location.x * viewPort.width, y: location.y * viewPort.height))
                }
            }
        }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.points = points
        }
    }

    func removePointsFromView(){
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.points.removeAll()
        }
    }
    
    func resetLabels(){
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.leftPrediction = ""
            self.leftPredictionConfidence = 0
            self.rightPrediction = ""
            self.rightPredictionConfidence = 0
        }
    }
    
    func didGetFrames(frame: CVPixelBuffer) {
        let hands = handsService.detectHands(in: frame, numberOfHands: 2)
        if hands.isEmpty {
            removePointsFromView()
            return
        }
        getJointsLocation(for: hands)
        sendToIa(hands: hands)
    }
}

