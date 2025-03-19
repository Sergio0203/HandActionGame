//
//  ClassifierService.swift
//  Poc IA
//
//  Created by Sérgio César Lira Júnior on 18/03/25.
//
import CoreML
final class ClassifierService {
    static let shared = ClassifierService()
    private let model = HandActionTrack()
    private init() {}
    
    func classify(poses: [MLMultiArray]) {
        let poses = MLMultiArray(concatenating: poses, axis: 0, dataType: .float32)
        let input = HandActionTrackInput(poses: poses)
        let prediction = try? model.prediction(input: input)
        guard let label = prediction?.label, let confidence = prediction?.labelProbabilities[label] else { return }
        if confidence > 0.5 {
            print("\(label): \(confidence)")
        }
    }
}

