//
//  HandsDetector.swift
//  Poc IA
//
//  Created by Sérgio César Lira Júnior on 24/03/25.
//



import Vision
struct HandsService: HandsDetector {
    
    func detectHands(in image: CVPixelBuffer, numberOfHands: Int) -> [HandModel] {
        var handsResult = [HandModel]()
        let handPoseRequest = VNDetectHumanHandPoseRequest()
        handPoseRequest.maximumHandCount = numberOfHands
        
        let handler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .up, options: [:])
        
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

