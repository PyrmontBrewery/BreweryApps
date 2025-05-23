//
//  CameraView.swift
//  BeerColour2
//
//  Created by GitHub Copilot on 23/5/2025.
//

import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    class Coordinator: NSObject, AVCapturePhotoCaptureDelegate {
        var parent: CameraView
        var captureSession: AVCaptureSession?
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            if let imageData = photo.fileDataRepresentation(),
               let image = UIImage(data: imageData) {
                parent.image = image
                parent.presentationMode.wrappedValue.dismiss()
            }
        }
        
        @objc func capturePhoto() {
            guard let captureSession = captureSession,
                  let photoOutput = captureSession.outputs.first as? AVCapturePhotoOutput else {
                print("Failed to access photo output")
                return
            }
            
            let photoSettings = AVCapturePhotoSettings()
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        let captureSession = AVCaptureSession()
        context.coordinator.captureSession = captureSession
        
        guard let backCamera = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
        ) else {
            return controller
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            captureSession.addInput(input)
        } catch {
            print("Failed to access the camera: \(error.localizedDescription)")
            return controller
        }
        
        let photoOutput = AVCapturePhotoOutput()
        captureSession.addOutput(photoOutput)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        
        let previewView = UIView()
        previewView.layer.addSublayer(previewLayer)
        controller.view = previewView
        
        // Add capture button
        let captureButton = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        captureButton.backgroundColor = UIColor.white
        captureButton.layer.cornerRadius = 35
        captureButton.layer.borderWidth = 5
        captureButton.layer.borderColor = UIColor.darkGray.cgColor
        captureButton.addTarget(context.coordinator,
                              action: #selector(context.coordinator.capturePhoto),
                              for: .touchUpInside)
        
        let buttonView = UIView()
        controller.view.addSubview(buttonView)
        buttonView.addSubview(captureButton)
        
        // Setup constraints
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            buttonView.leftAnchor.constraint(equalTo: controller.view.leftAnchor),
            buttonView.rightAnchor.constraint(equalTo: controller.view.rightAnchor),
            buttonView.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor),
            buttonView.heightAnchor.constraint(equalToConstant: 100),
            
            captureButton.centerXAnchor.constraint(equalTo: buttonView.centerXAnchor),
            captureButton.centerYAnchor.constraint(equalTo: buttonView.centerYAnchor),
            captureButton.widthAnchor.constraint(equalToConstant: 70),
            captureButton.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        // Add target rect overlay (for beer targeting)
        let targetView = UIView()
        targetView.layer.borderColor = UIColor.yellow.cgColor
        targetView.layer.borderWidth = 2
        targetView.backgroundColor = UIColor.clear
        controller.view.addSubview(targetView)
        
        targetView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            targetView.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor),
            targetView.centerYAnchor.constraint(equalTo: controller.view.centerYAnchor),
            targetView.widthAnchor.constraint(equalTo: controller.view.widthAnchor, multiplier: 0.5),
            targetView.heightAnchor.constraint(equalTo: controller.view.widthAnchor, multiplier: 0.5)
        ])
        
        // Start the session
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
        }
        
        // Update frame when view appears
        DispatchQueue.main.async {
            previewLayer.frame = previewView.bounds
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let previewLayer = uiViewController.view.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiViewController.view.bounds
        }
    }
}
