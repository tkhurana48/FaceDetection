//
//  ImageSelectionViewModel.swift
//  FaceDetect
//
//  Created by Tarun Khurana on 29/06/24.
//

import SwiftUI
import PhotosUI
import Vision
import AVFoundation

class ImageSelectionViewModel: NSObject, ObservableObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
    @Published var images = [ImageModel]()
    @Published var showResults = false
    @Published var isFaceDetected = false
    
   
     var captureSession: AVCaptureSession?
     var videoOutput: AVCaptureVideoDataOutput?
     var photoOutput: AVCapturePhotoOutput?
    
    func captureImage() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera not available")
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            self.startCaptureSession()
        }
    }
    
    func selectFromGallery() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 0

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(picker, animated: true, completion: nil)
        }
    }
    
    func addImage(_ image: UIImage) {
        let imageModel = ImageModel(image: image, status: .processing)
        images.append(imageModel)
        processImage(imageModel)
    }
    
    private func processImage(_ imageModel: ImageModel) {
        DispatchQueue.global(qos: .background).async {
            let hasFace = self.detectFace(in: imageModel.image)
            DispatchQueue.main.async {
                if hasFace {
                    var updatedImageModel = imageModel
                    updatedImageModel.status = .processed
                    updatedImageModel.abnormalities = ["Mock Abnormality 1", "Mock Abnormality 2"]
                    self.updateImage(updatedImageModel)
                } else {
                    var updatedImageModel = imageModel
                    updatedImageModel.status = .invalid("No face detected")
                    self.updateImage(updatedImageModel)
                }
            }
        }
    }
    
    private func updateImage(_ updatedImage: ImageModel) {
        if let index = images.firstIndex(where: { $0.id == updatedImage.id }) {
            images[index] = updatedImage
            
                navigateToResults()
           
        }
    }
    
    func detectFace(in image: UIImage) -> Bool {
        guard let cgImage = image.cgImage else { return false }
        let request = VNDetectFaceRectanglesRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
            guard let results = request.results, !results.isEmpty else {
                return false
            }
            return true
        } catch {
            print("Face detection error: \(error)")
            return false
        }
    }
    
    func navigateToResults() {
        if images.count >= 10 {
            showResults = true
        }
    }
    
    private func startCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .photo
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("No front camera available")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            captureSession?.addInput(input)
            
            videoOutput = AVCaptureVideoDataOutput()
            videoOutput?.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            captureSession?.addOutput(videoOutput!)
            
            photoOutput = AVCapturePhotoOutput()
            captureSession?.addOutput(photoOutput!)
            
            captureSession?.startRunning()
        } catch {
            print("Error setting up camera: \(error)")
        }
    }
    
     func stopCaptureSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession?.stopRunning()
            self.captureSession = nil
            self.videoOutput = nil
            self.photoOutput = nil
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let request = VNDetectFaceRectanglesRequest { (request, error) in
            if let results = request.results as? [VNFaceObservation], !results.isEmpty {
                DispatchQueue.main.async {
                    self.isFaceDetected = true
                }
            } else {
                DispatchQueue.main.async {
                    self.isFaceDetected = false
                }
            }
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Error performing face detection: \(error)")
        }
    }
    
    func takePhoto() {
        guard isFaceDetected else {
            print("No face detected, cannot take photo")
            return
        }
        
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) else {
            print("Error converting photo data to UIImage")
            return
        }
        
        DispatchQueue.main.async {
            self.addImage(image)
            self.stopCaptureSession()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)

        if let image = info[.originalImage] as? UIImage {
            DispatchQueue.main.async {
                self.addImage(image)
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)

        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self.addImage(image)
                    }
                } else if let error = error {
                    print("Error loading image: \(error.localizedDescription)")
                }
            }
        }
    }
}

