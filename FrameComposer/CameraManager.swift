import AVFoundation
import SwiftUI
import Combine

class CameraManager: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var isUsingFrontCamera = false
    @Published var permissionGranted = false
    @Published var capturedImage: UIImage?
    @Published var isCapturing = false
    
    private var videoOutput: AVCaptureVideoDataOutput?
    private var photoOutput = AVCapturePhotoOutput()
    private var currentInput: AVCaptureDeviceInput?
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    override init() {
        super.init()
        checkPermission()
    }
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            DispatchQueue.main.async { self.permissionGranted = true }
            setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.permissionGranted = granted
                    if granted { self?.setupSession() }
                }
            }
        default:
            DispatchQueue.main.async { self.permissionGranted = false }
        }
    }
    
    func setupSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.session.beginConfiguration()
            self.session.sessionPreset = .photo
            
            // Add input
            let position: AVCaptureDevice.Position = self.isUsingFrontCamera ? .front : .back
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
                  let input = try? AVCaptureDeviceInput(device: device) else {
                self.session.commitConfiguration()
                return
            }
            
            if self.session.canAddInput(input) {
                self.session.addInput(input)
                self.currentInput = input
            }
            
            // Add photo output
            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
                self.photoOutput.isHighResolutionCaptureEnabled = true
            }
            
            self.session.commitConfiguration()
            self.session.startRunning()
        }
    }
    
    func toggleCamera() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.session.beginConfiguration()
            
            // Remove current input
            if let currentInput = self.currentInput {
                self.session.removeInput(currentInput)
            }
            
            // Switch camera
            DispatchQueue.main.async { self.isUsingFrontCamera.toggle() }
            let newPosition: AVCaptureDevice.Position = self.isUsingFrontCamera ? .front : .back
            
            guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition),
                  let newInput = try? AVCaptureDeviceInput(device: newDevice) else {
                self.session.commitConfiguration()
                return
            }
            
            if self.session.canAddInput(newInput) {
                self.session.addInput(newInput)
                self.currentInput = newInput
            }
            
            self.session.commitConfiguration()
        }
    }
    
    func capturePhoto() {
        guard session.isRunning else { return }
        DispatchQueue.main.async { self.isCapturing = true }
        
        let settings = AVCapturePhotoSettings()
        settings.isHighResolutionPhotoEnabled = true
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func stopSession() {
        sessionQueue.async { [weak self] in
            self?.session.stopRunning()
        }
    }
    
    func startSession() {
        sessionQueue.async { [weak self] in
            if self?.session.isRunning == false {
                self?.session.startRunning()
            }
        }
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        DispatchQueue.main.async { self.isCapturing = false }
        
        guard error == nil,
              let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }
        
        DispatchQueue.main.async {
            self.capturedImage = image
        }
        
        // Save to camera roll
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}
