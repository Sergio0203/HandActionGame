//
//  ClassifierService.swift
//  Poc IA
//
//  Created by Sérgio César Lira Júnior on 18/03/25.
//
import CoreML
final class ClassifierService {
    static let shared = ClassifierService()
    
    private let modelHandAction: HandActionClassifier = try! HandActionClassifier(configuration: MLModelConfiguration())
    private let modelHandPose: HandPoseClassifier = try! HandPoseClassifier(configuration: MLModelConfiguration())
    private init() {}
    
    func classifyAction(poses: [MLMultiArray]) {
        let poses = MLMultiArray(concatenating: poses, axis: 0, dataType: .float32)
        let input = HandActionClassifierInput(poses: poses)
        let prediction = try? modelHandAction.prediction(input: input)
        guard let label = prediction?.label, let confidence = prediction?.labelProbabilities[label] else { return }
        if confidence > 0.8 {
            print("\(label): \(confidence)")
        }
    }
    
    func classifyPoses(pose: MLMultiArray) {
        let input = HandPoseClassifierInput(poses: pose)
        let prediction = try? modelHandPose.prediction(input: input)
        guard let label = prediction?.label, let confidence = prediction?.labelProbabilities[label] else { return }
        
        if confidence > 0.8 {
            print("\(label): \(confidence)")
        }
    }
}
