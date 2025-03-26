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
    var arView = ARView()

    init(delegate: ARSessionDelegate) {
        self.delegate = delegate
    }
    
    func makeUIView(context: Context) -> ARView {
      
        let config = ARImageTrackingConfiguration()
        arView.session.delegate = delegate
        arView.session.run(config)
        
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
    }
}

