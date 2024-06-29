//
//  ResultView.swift
//  FaceDetect
//
//  Created by Tarun Khurana on 29/06/24.
//

import SwiftUI


struct ResultsView: View {
    @ObservedObject var viewModel: ImageSelectionViewModel
    
    var body: some View {
        List(viewModel.images) { image in
            VStack {
                Image(uiImage: image.image)
                    .resizable()
                    .scaledToFit()
                Text(image.statusText)
                if let abnormalities = image.abnormalities {
                    ForEach(abnormalities, id: \.self) { abnormality in
                        Text(abnormality)
                    }
                }
            }
        }.navigationTitle("Result Screen")
    }
}


