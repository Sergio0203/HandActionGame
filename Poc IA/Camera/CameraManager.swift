import AVFoundation
import SwiftUI
import CoreImage
import os

final class CameraManager: NSObject {
    
    private let captureSession = AVCaptureSession()
    private var isCaptureSessionConfigured = false
    private var deviceInput: AVCaptureDeviceInput?
    private var photoOutput: AVCapturePhotoOutput?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var sessionQueue: DispatchQueue = .init(label: "video.preview.session")
    
    private var allCaptureDevices: [AVCaptureDevice] {
        #if os(iOS)
        AVCaptureDevice.DiscoverySession(
            deviceTypes: [
                .builtInTrueDepthCamera,
                    .builtInDualCamera,
                    .builtInDualWideCamera,
                    .builtInWideAngleCamera,
                    .builtInDualWideCamera
            ],
            mediaType: .video,
            position: .unspecified
        ).devices
        #elseif os(macOS)
        AVCaptureDevice.DiscoverySession(
            deviceTypes: [
                .builtInWideAngleCamera,
                .continuityCamera,
                .deskViewCamera
            ],
            mediaType: .video,
            position: .unspecified
        ).devices
        #endif
    }
    let delegate: AVCaptureVideoDataOutputSampleBufferDelegate
    #if os(iOS)
    private var frontCaptureDevices: [AVCaptureDevice] { allCaptureDevices.filter { $0.position == .front } }
    private var backCaptureDevices: [AVCaptureDevice] { allCaptureDevices.filter { $0.position == .back } }
    #endif
    
    private var captureDevices: [AVCaptureDevice] {
        var devices = [AVCaptureDevice]()
        #if os(macOS) || (os(iOS) && targetEnvironment(macCatalyst))
        devices += allCaptureDevices
        #else
        if let backDevice = backCaptureDevices.first(where: {$0.localizedName == "Back Camera"}) {
            devices.append(backDevice)
        }
        if let frontDevice = frontCaptureDevices.first {
            devices.append(frontDevice)
        }
        #endif
        return devices
    }
    
    private var availableCaptureDevices: [AVCaptureDevice] {
        captureDevices.filter { $0.isConnected && !$0.isSuspended }
    }
    
    private var captureDevice: AVCaptureDevice? {
        didSet {
            guard let captureDevice = captureDevice else { return }
            logger.debug("Using capture device: \(captureDevice.localizedName)")
            sessionQueue.async {
                self.updateSessionForCaptureDevice(captureDevice)
            }
        }
    }
    
    #if os(iOS)
    var isUsingFrontCaptureDevice: Bool {
        guard let captureDevice = captureDevice else { return false }
        return frontCaptureDevices.contains(captureDevice)
    }
    
    var isUsingBackCaptureDevice: Bool {
        guard let captureDevice = captureDevice else { return false }
        return backCaptureDevices.contains(captureDevice)
    }
    #endif
    
    var isRunning: Bool {
        captureSession.isRunning
    }
        
    private var addToPhotoStream: ((AVCapturePhoto) -> Void)?
    
    var addToPreviewStream: ((CIImage) -> Void)?
    
    var isPreviewPaused = false
    
    lazy var previewStream: AsyncStream<CIImage> = {
        AsyncStream { continuation in
            addToPreviewStream = { ciImage in
                if !self.isPreviewPaused {
                    continuation.yield(ciImage)
                    
                }
            }
        }
    }()
    
    lazy var photoStream: AsyncStream<AVCapturePhoto> = {
        AsyncStream { continuation in
            addToPhotoStream = { photo in
                continuation.yield(photo)
            }
        }
    }()
    
    init(delegate: AVCaptureVideoDataOutputSampleBufferDelegate) {
        self.delegate = delegate
        super.init()
        initialize()
    }
    
    private func initialize() {
        captureDevice = availableCaptureDevices.first ?? AVCaptureDevice.default(for: .video)
    }
    
    private func configureCaptureSession(completionHandler: (_ success: Bool) -> Void) {
        var success = false
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .hd4K3840x2160
        defer {
            captureSession.commitConfiguration()
            completionHandler(success)
        }
        
        guard let captureDevice = captureDevice,
              let deviceInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            logger.error("Failed to obtain video input.")
            return
        }
        
        let photoOutput = AVCapturePhotoOutput()
        captureSession.sessionPreset = .photo

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(delegate, queue: DispatchQueue(label: "VideoDataOutputQueue"))
    
        guard captureSession.canAddInput(deviceInput) else {
            logger.error("Unable to add device input to capture session.")
            return
        }
        guard captureSession.canAddOutput(photoOutput) else {
            logger.error("Unable to add photo output to capture session.")
            return
        }
        guard captureSession.canAddOutput(videoOutput) else {
            logger.error("Unable to add video output to capture session.")
            return
        }
        
        captureSession.addInput(deviceInput)
        captureSession.addOutput(photoOutput)
        captureSession.addOutput(videoOutput)
        
        self.deviceInput = deviceInput
        self.photoOutput = photoOutput
        self.videoOutput = videoOutput
        photoOutput.maxPhotoQualityPrioritization = .quality
        updateVideoOutputConnection()
        isCaptureSessionConfigured = true
        success = true
    }

    private func checkAuthorization() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            logger.debug("Camera access authorized.")
            return true
        case .notDetermined:
            logger.debug("Camera access not determined.")
            sessionQueue.suspend()
            let status = await AVCaptureDevice.requestAccess(for: .video)
            sessionQueue.resume()
            return status
        case .denied:
            logger.debug("Camera access denied.")
            return false
        case .restricted:
            logger.debug("Camera access restricted.")
            return false
        @unknown default:
            return false
        }
    }
    
    private func updateSessionForCaptureDevice(_ captureDevice: AVCaptureDevice) {
        guard isCaptureSessionConfigured else { return }
        
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }
        
        for input in captureSession.inputs {
            if let deviceInput = input as? AVCaptureDeviceInput {
                captureSession.removeInput(deviceInput)
            }
        }
        
        if let deviceInput = deviceInputFor(device: captureDevice),
           captureSession.canAddInput(deviceInput) {
            captureSession.addInput(deviceInput)
        }
        
        updateVideoOutputConnection()
    }
    
    private func updateVideoOutputConnection() {
        if let videoOutput = videoOutput,
           let connection = videoOutput.connection(with: .video) {
            
            
            #if os(iOS)
            if connection.isVideoMirroringSupported {
                connection.isVideoMirrored = isUsingFrontCaptureDevice
            }
            
            if connection.isVideoRotationAngleSupported(self.deviceRotationAngle) {
                connection.videoRotationAngle = self.deviceRotationAngle
            }
            #elseif os(macOS)
            connection.isVideoMirrored = true
            #endif
        }
    }

    private func deviceInputFor(device: AVCaptureDevice?) -> AVCaptureDeviceInput? {
        guard let device = device else { return nil }
        do {
            return try AVCaptureDeviceInput(device: device)
        } catch let error {
            logger.error("Error getting capture device input: \(error.localizedDescription)")
            return nil
        }
    }
    
    func start() async {
        let authorized = await checkAuthorization()
        guard authorized else {
            logger.error("Camera access was not authorized.")
            return
        }
        
        if isCaptureSessionConfigured {
            if !captureSession.isRunning {
                sessionQueue.sync {
                    self.captureSession.startRunning()
                }
            }
            return
        }
        
        sessionQueue.sync {
            self.configureCaptureSession { success in
                guard success else { return }
                self.captureSession.startRunning()
            }
        }
    }
    
    func stop() {
        guard isCaptureSessionConfigured else { return }
        if captureSession.isRunning {
            sessionQueue.async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func switchCaptureDevice() {
        if let captureDevice = captureDevice,
           let index = availableCaptureDevices.firstIndex(of: captureDevice) {
            let nextIndex = (index + 1) % availableCaptureDevices.count
            self.captureDevice = availableCaptureDevices[nextIndex]
        } else {
            self.captureDevice = AVCaptureDevice.default(for: .video)
        }
        updateVideoOutputConnection()
    }
        
    #if !os(macOS)
    private var deviceOrientation: UIDeviceOrientation {
        let orientation = UIDevice.current.orientation
        if orientation == .unknown {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                // Current orientation of the WindowScene
                return windowScene.deviceOrientation
            } else {
                // Fallback to default portrait
                return .portrait
            }
        }
        return orientation
    }
    #endif
    
    #if !os(macOS)
    private var deviceRotationAngle: CGFloat { deviceOrientation.videoRotationAngle }
    #endif
    
    func takePhoto() {
        guard let photoOutput = self.photoOutput else { return }
        sessionQueue.async {
            let photoSettings = AVCapturePhotoSettings()
            
            // Set flash mode if available.
            let isFlashAvailable = self.deviceInput?.device.isFlashAvailable ?? false
            photoSettings.flashMode = isFlashAvailable ? .auto : .off
            
            #if !os(macOS)
            if let previewPhotoPixelFormatType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
                photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
            }
            #endif
            
            photoSettings.photoQualityPrioritization = .balanced
            
            #if !os(macOS)
            // Update photo output connection with current video rotation angle.
            if let connection = photoOutput.connection(with: .video),
               connection.isVideoRotationAngleSupported(self.deviceRotationAngle) {
                connection.videoRotationAngle = self.deviceRotationAngle
            }
            #endif
            
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
}


extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error = error {
            logger.error("Error capturing photo: \(error.localizedDescription)")
            return
        }
        addToPhotoStream?(photo)
    }
}

// MARK: - Logger
fileprivate let logger = Logger(subsystem: "com.example.CameraManager", category: "Camera")
