//
//  CameraView.swift
//  Poc IA
//
//  Created by Sérgio César Lira Júnior on 27/03/25.
//

import SwiftUI

struct CameraView: View {
    
    @Binding var image: CGImage?
    @Binding var points: [CGPoint]
    var body: some View {
        GeometryReader { geometryProxy in
            ZStack {
                if let image = image {
                    Image(decorative: image, scale: 1)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometryProxy.size.width,
                               height: geometryProxy.size.height)
                        .border(.red, width: 2)
                joints
                } else {
                    ContentUnavailableView("No camera feed", systemImage: "xmark.circle.fill")
                        .frame(width: geometryProxy.size.width,
                               height: geometryProxy.size.height)
                }
            }
        }
    }
    
    @ViewBuilder
    private var joints: some View {
        ForEach(points, id: \.self) { point in
            Circle()
                .fill(Color.red)
                .frame(width: 5)
                .position(x: point.x, y: point.y)
        }
    }
    
}
