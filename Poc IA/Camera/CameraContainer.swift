//
//  CameraContainer.swift
//  Poc IA
//
//  Created by Sérgio César Lira Júnior on 26/03/25.
//

import AVFoundation
import UIKit
import SwiftUI

struct CameraContainer: UIViewControllerRepresentable {
    let captureSession = AVCaptureSession()
    let delegate: AVCaptureVideoDataOutputSampleBufferDelegate
    let previewLayer: AVCaptureVideoPreviewLayer
    init(delegate: AVCaptureVideoDataOutputSampleBufferDelegate) {
        self.delegate = delegate
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession.canAddInput(videoInput) else {
            return viewController
        }
        do {
              try videoCaptureDevice.lockForConfiguration()
            videoCaptureDevice.activeVideoMinFrameDuration = .init(value: 1, timescale: 30)
            videoCaptureDevice.activeVideoMaxFrameDuration = .init(value: 1, timescale: 30)
            videoCaptureDevice.unlockForConfiguration()
          } catch {
              NSLog("An Error occurred: \(error.localizedDescription))")
          }
        captureSession.addInput(videoInput)
        
        let videoOutput = AVCaptureVideoDataOutput()
        
        if captureSession.canAddOutput(videoOutput) {
            videoOutput.setSampleBufferDelegate(delegate, queue: DispatchQueue(label: "videoQueue"))
            captureSession.addOutput(videoOutput)
        }
        
        //previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = viewController.view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)
        
        Task {
            captureSession.startRunning()
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
}
