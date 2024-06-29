//
//  ContentView.swift
//  FaceDetect
//
//  Created by Tarun Khurana on 29/06/24.
//

import SwiftUI

// Implement navigation to the results screen once 10 images are selected or captured.

struct ContentView: View {
    @StateObject private var viewModel = ImageSelectionViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                ImageSelectionView(viewModel: viewModel)
                NavigationLink(destination: ResultsView(viewModel: viewModel), isActive: $viewModel.showResults) {
                    EmptyView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
