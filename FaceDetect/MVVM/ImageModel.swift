//
//  ImageModel.swift
//  FaceDetect
//
//  Created by Tarun Khurana on 29/06/24.
//

import Foundation
import SwiftUI

struct ImageModel: Identifiable {
    var id = UUID()
    var image: UIImage
    var status: ImageStatus
    var abnormalities: [String]?
}

enum ImageStatus {
    case processing
    case processed
    case invalid(String)
}

extension ImageModel {
    var statusText: String {
        switch status {
        case .processing:
            return "Processing"
        case .processed:
            return "Processed"
        case .invalid(let message):
            return "Invalid: \(message)"
        }
    }
}

