//
//  HandsDetector.swift
//  Poc IA
//
//  Created by Sérgio César Lira Júnior on 24/03/25.
//



import Vision
import CoreImage
struct HandsService: HandsDetector {
    
    func detectHands(in image: CIImage, numberOfHands: Int) -> [HandModel] {
        var handsResult = [HandModel]()
        let handPoseRequest = VNDetectHumanHandPoseRequest()
        handPoseRequest.maximumHandCount = numberOfHands
        
        let handler = VNImageRequestHandler(ciImage: image, orientation: .downMirrored, options: [:])
        
        do {
            try handler.perform([handPoseRequest])
        } catch {
            assertionFailure("Human Pose Request failed: \(error)")
        }
        
        guard let detectedHandPoses = handPoseRequest.results else { return [] }
        for hand in detectedHandPoses {
            handsResult.append(HandModel(hand: hand))
        }
        
        return handsResult
        
    }
}

