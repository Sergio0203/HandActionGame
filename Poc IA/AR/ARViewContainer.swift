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
struct ARViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.session.delegate = context.coordinator
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
    }
    
    func makeCoordinator() -> ARCoordinator {
        return ARCoordinator()
    }
}
