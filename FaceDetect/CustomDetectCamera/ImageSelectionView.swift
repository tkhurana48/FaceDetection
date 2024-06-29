//
//  ImageSelectionView.swift
//  FaceDetect
//
//  Created by Tarun Khurana on 29/06/24.
//

import SwiftUI

struct ImageSelectionView: View {
    @ObservedObject var viewModel: ImageSelectionViewModel
    
    var body: some View {
        VStack {
            Button(action: {
                viewModel.captureImage()
            }) {
                Text("Capture Image") 
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            Button(action: {
                viewModel.selectFromGallery()
            }) {
                Text("Select from Gallery")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            if viewModel.captureSession != nil {
                CameraView(viewModel: viewModel)
            }
           
            List(viewModel.images) { image in
                VStack {
                    Image(uiImage: image.image)
                        .resizable()
                        .scaledToFit()
                    //Text(image.statusText)
                }
            }
        }
    }
}

