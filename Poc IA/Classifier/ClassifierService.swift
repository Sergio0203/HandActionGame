//
//  ClassifierService.swift
//  Poc IA
//
//  Created by Sérgio César Lira Júnior on 18/03/25.
//


import CoreML
final class ClassifierService {
    static let shared = ClassifierService()
    
    private let modelHandAction: HandActionClassifier?
    private var modelHandPose: HandPoseClassifier?
    private init() {
        modelHandAction = try? HandActionClassifier(configuration: MLModelConfiguration())
        modelHandPose = try? HandPoseClassifier(configuration: MLModelConfiguration())
    }
    
    func classifyAction(poses: [MLMultiArray]) -> (String, Double)? {
        let poses = MLMultiArray(concatenating: poses, axis: 0, dataType: .float32)
        let input = HandActionClassifierInput(poses: poses)
        let prediction = try? modelHandAction?.prediction(input: input)
        guard let label = prediction?.label, let confidence = prediction?.labelProbabilities[label] else { return nil }
        
        if confidence > 0.8 {
            return (label, confidence)
        }
        return nil
    }
    
    func classifyPoses(pose: MLMultiArray) -> (String, Double)? {
        let input = HandPoseClassifierInput(poses: pose)
        let prediction = try? modelHandPose?.prediction(input: input)
        guard let label = prediction?.label, let confidence = prediction?.labelProbabilities[label] else { return nil }
        
        if confidence > 0.8 {
            print("\(label): \(confidence)")
            return (label, confidence)
        }
        
        return nil
    }
}
