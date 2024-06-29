# FaceDetection

Description About Project

Architecture used:- MVVM
Tools and technology used:- SwiftUI, Xcode
Language used:- Swift
Framework Used:- Vision, AVFoundation

By using this app we can select the images from the gallery a minimum of 10 images we have to select to go to the result screen. we can also take the picture from the front camera.When using the camera, the app should only allow a photo to be taken if a face is detected in the viewfinder.

On the ResultView :- Display the images along with their status: either "Processed" with assigned
abnormalities or "Processing." If no face is detected in an image from the gallery, mark it as "Invalid" with a "No face detected" message.
Assigning mock facial abnormalities as soon as the first image is selected or captured.
All bussiness logic is present in the ImageSelectionViewModel.

