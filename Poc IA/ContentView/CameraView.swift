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
                        //.frame(width: geometryProxy.size.width, height: geometryProxy.size.height)
                } else {
                    ContentUnavailableView("No camera feed", systemImage: "xmark.circle.fill")
                        .frame(width: geometryProxy.size.width,
                               height: geometryProxy.size.height)
                }
            }
        }
    }
    
}
