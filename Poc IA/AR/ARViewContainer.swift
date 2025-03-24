//
//  ARViewController.swift
//  Poc IA
//
//  Created by Sérgio César Lira Júnior on 17/03/25.
//
import SwiftUI
import ARKit
import RealityKit
import Vision
import Foundation

struct ARViewContainer: UIViewRepresentable {
    var delegate: ARSessionDelegate
    
    init(delegate: ARSessionDelegate) {
        self.delegate = delegate
    }
    
    func makeUIView(context: Context) -> ARView {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        
        let arView = ARView()
        arView.session.run(configuration)
        arView.session.delegate = delegate
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
    }
}
