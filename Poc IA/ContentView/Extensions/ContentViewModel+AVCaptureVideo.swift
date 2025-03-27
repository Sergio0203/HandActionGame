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
        for layer in cameraContainer!.previewLayer.sublayers! where layer.name == "Points" {
            layer.removeFromSuperlayer()
        }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            for point in self.points {
                let newPoint = cameraContainer?.previewLayer.convert(point, to: cameraContainer?.previewLayer)
                let view = UIView(frame: .init(x: 0, y: 0, width: 5, height: 5))
                view.backgroundColor = .blue
                view.layer.name = "Points"
                view.layer.position = newPoint!
                self.cameraContainer?.previewLayer.addSublayer(view.layer)
            }
        }
       
    }
}
