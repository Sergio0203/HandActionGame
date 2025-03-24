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
    
    var arView: ARViewContainer?
    let handsService: HandsDetector
    
    
    init(handsService: HandsDetector = HandsService()) {
        self.prediction =  Prediction.none
        self.predictionConfidence = 0
        arView = ARViewContainer(delegate: self)
        self.handsService = handsService
    }
}

extension ContentViewModel: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
    
        
    }
}
