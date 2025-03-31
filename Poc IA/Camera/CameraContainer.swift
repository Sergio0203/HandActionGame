//
//  CameraContainer.swift
//  Poc IA
//
//  Created by Sérgio César Lira Júnior on 26/03/25.
//

import AVFoundation
import UIKit
import SwiftUI

enum CameraContainerError: LocalizedError {
    case withoutCapture
    
    var errorDescription: String? {
        switch self {
        case .withoutCapture:
            return "Sem câmera disponível"
        }
    }
}

struct CameraContainer: UIViewControllerRepresentable {
    let captureSession = AVCaptureSession()
    let delegate: AVCaptureVideoDataOutputSampleBufferDelegate
    init(delegate: AVCaptureVideoDataOutputSampleBufferDelegate) {
        self.delegate = delegate
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
              print(CameraContainerError.withoutCapture)
          }
        captureSession.addInput(videoInput)
        
        let videoOutput = AVCaptureVideoDataOutput()
        
        if captureSession.canAddOutput(videoOutput) {
            videoOutput.setSampleBufferDelegate(delegate, queue: DispatchQueue(label: "videoQueue"))
            captureSession.addOutput(videoOutput)
        }
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = viewController.view.bounds
        previewLayer.videoGravity = .resize
        viewController.view.layer.addSublayer(previewLayer)
        
        Task {
            captureSession.startRunning()
        }
        
        return viewController
    }
#if DEBUG
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
#endif
}
