//
//  ContentModelView.swift
//  Poc IA
//
//  Created by Sérgio César Lira Júnior on 24/03/25.
//
import RealityKit
import SwiftUI
import ARKit
public enum Prediction: String {
    case left = "Left"
    case right = "Right"
    case up = "Up"
    case down = "Down"
    case none = "None"
}

final class ContentViewModel: NSObject, ObservableObject {
    
    @Published var prediction: Prediction
    @Published var predictionConfidence: Float
    

    var frameCount: Int = 0
    var sampleCount: Int = 30
    var queueSize: Int = 30
    var sampleCounter: Int = 0
    var queue = [MLMultiArray]()
    var points: [CGPoint] = []

    var arContainer: ARViewContainer?
    let handsService: HandsDetector

    
    init(handsService: HandsDetector = HandsService()) {
        self.prediction =  Prediction.none
        self.predictionConfidence = 0
        self.handsService = handsService
        super.init()
        arContainer = ARViewContainer(delegate: self)

    }
}
