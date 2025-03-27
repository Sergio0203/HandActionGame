//
//  ContentView+UIViewControllerRepresentable.swift
//  Poc IA
//
//  Created by Sérgio César Lira Júnior on 26/03/25.
//
import AVFoundation
import UIKit

extension ContentViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = sampleBuffer.imageBuffer else { return }
        #if os(iOS)
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer).oriented(connection.isVideoMirrored ? .left : .right)
        
        #elseif os(macOS)
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        #endif
        
        didGetFrames(frame: ciImage)
        self.cameraManager?.addToPreviewStream?(ciImage)
    }
}
