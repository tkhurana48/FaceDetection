//
//  CameraView.swift
//  FaceDetect
//
//  Created by Tarun Khurana on 29/06/24.
//

import SwiftUI
import UIKit
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    @ObservedObject var viewModel: ImageSelectionViewModel
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let cameraVC = CameraViewController()
        cameraVC.viewModel = viewModel
        return cameraVC
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

class CameraViewController: UIViewController {
    var viewModel: ImageSelectionViewModel!
    var previewLayer: AVCaptureVideoPreviewLayer?
    var sessionRunning = false // Track if the capture session is running
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        setupUI()
    }
    
    private func setupCaptureSession() {
        guard let captureSession = viewModel.captureSession else {
            print("Capture session not available")
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer!)
        
        // Start the capture session on a background queue
        DispatchQueue.global().async {
            captureSession.startRunning()
            self.sessionRunning = true
        }
    }
    
    private func setupUI() {
        let takePhotoButton = UIButton(type: .system)
        takePhotoButton.setTitle("Take Photo", for: .normal)
        takePhotoButton.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        takePhotoButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(takePhotoButton)
        
        NSLayoutConstraint.activate([
            takePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            takePhotoButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
        ])
    }
    
    @objc func takePhoto() {
        guard viewModel.isFaceDetected else {
            showAlert(message: "No face detected, cannot take photo.")
            return
        }
        
        viewModel.takePhoto()
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Stop the capture session when the view is about to disappear
        if sessionRunning {
            viewModel.captureSession?.stopRunning()
            sessionRunning = false
        }
    }
}
