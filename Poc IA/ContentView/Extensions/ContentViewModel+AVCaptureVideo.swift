//
//  ContentView+UIViewControllerRepresentable.swift
//  Poc IA
//
//  Created by Sérgio César Lira Júnior on 26/03/25.
//
import AVFoundation
import UIKit
extension ContentViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        frameCount += 1
        guard frameCount % 2 == 0 else {
            return
        }
        self.resetLabels()
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        didGetFrames(frame: pixelBuffer)
       
    }
}
