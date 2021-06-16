//
//  ViewController.swift
//  FaceDetection_MLKit_Sample
//
//  Created by Abhimanyu Bhatnagar on 16/06/21.
//

import UIKit
import MLKitFaceDetection
import MLKitVision

class ViewController: UIViewController {

    @IBOutlet var snippetImageView: UIImageView!
    @IBOutlet var faceImageView: UIImageView!
    @IBOutlet var blankImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let options = FaceDetectorOptions()
        options.performanceMode = .accurate
        options.landmarkMode = .all
        options.contourMode = .all
        options.classificationMode = .none
        
//        let testImage = UIImage.init(named: "test.JPG")
//        let testImg = resizeImage(image: UIImage.init(named: "face-1")!, newWidth: 360)!
        faceImageView.image = UIImage.init(named: "face-1")
        let image = UIImage.init()
        let visionImage = VisionImage(image: UIImage.init(named: "face-1")!)
        visionImage.orientation = image.imageOrientation
        
        let faceDetector = FaceDetector.faceDetector(options: options)
        
        weak var weakSelf = self
        faceDetector.process(visionImage) { faces, error in
          guard let _ = weakSelf else {
            print("Self is nil!")
            return
          }
          guard error == nil, let faces = faces, !faces.isEmpty else {
            // ...
            return
          }

            for face in faces {
              let faceFrame = face.frame
//              if face.hasHeadEulerAngleX {
//                let rotX = face.headEulerAngleX  // Head is rotated to the uptoward rotX degrees
//                print(rotX)
//              }
//              if face.hasHeadEulerAngleY {
//                let rotY = face.headEulerAngleY  // Head is rotated to the right rotY degrees
//                print(rotY)
//              }
//              if face.hasHeadEulerAngleZ {
//                let rotZ = face.headEulerAngleZ  // Head is tilted sideways rotZ degrees
//                print(rotZ)
//              }
                var x = 0.0, y=0.0, w=0.0, h=0.0
                                
                if let mouthLeft = face.landmark(ofType: .mouthLeft){
                    let mouthLeftPos = mouthLeft.position
                    print("Mouth Left = \(mouthLeftPos)")
                    x = Double(mouthLeftPos.x)
                    y = Double(mouthLeftPos.y)
                }
                if let mouthRight = face.landmark(ofType: .mouthRight){
                    let mouthRightPos = mouthRight.position
                    print("Mouth Right = \(mouthRightPos)")
                    w = Double(mouthRightPos.x) - x
                }
              // If landmark detection was enabled (mouth, ears, eyes, cheeks, and
              // nose available):
                
                if let mouthBottom = face.landmark(ofType: .mouthBottom){
                    let mouthBottomPos = mouthBottom.position
                    print("Mouth Bottom = \(mouthBottomPos)")
//                    h = Double(mouthBottomPos.y) - y
                }
                
                h = Double(faceFrame.origin.y+faceFrame.size.height) - y
//              if let leftEye = face.landmark(ofType: .leftEye) {
//                let leftEyePosition = leftEye.position
//                print("Left eye position \(leftEyePosition)")
//              }
//
//              // If contour detection was enabled:
//              if let leftEyeContour = face.contour(ofType: .leftEye) {
//                let leftEyePoints = leftEyeContour.points
//                print("Left eye points \(leftEyePoints)")
//              }
                if let lowerLipTopContour = face.contour(ofType: .lowerLipTop) {
                let lowerLipTopPoints = lowerLipTopContour.points
                print("Lower lip Top points \(lowerLipTopPoints)")
              }
                
//                self.snippetImageView.frame = CGRect(x: faceFrame.origin.x, y: faceFrame.origin.y, width: faceFrame.size.width, height: faceFrame.size.height)
                
                
                let frameOfLowerLip = CGRect.init(x: x, y: y, width: w, height: h)
                
                let snapshot = self.view.snapshot(of: frameOfLowerLip, afterScreenUpdates: true)
                self.snippetImageView.image = snapshot
                self.snippetImageView.frame = frameOfLowerLip
                
                self.blankImageView.frame = frameOfLowerLip
                self.blankImageView.isHidden = false
                self.view.bringSubviewToFront(self.snippetImageView)
                self.animateFace(image: self.snippetImageView, direction: true)
              // If classification was enabled:
//              if face.hasSmilingProbability {
//                let smileProb = face.smilingProbability
//                print("Is smiling \(smileProb)")
//              }
//              if face.hasRightEyeOpenProbability {
//                let rightEyeOpenProb = face.rightEyeOpenProbability
//                print("Right eye open \(rightEyeOpenProb)")
//              }

              // If face tracking was enabled:
//              if face.hasTrackingID {
//                let trackingId = face.trackingID
//                print("Tracking ID \(trackingId)")
//              }
            }
          // Faces detected
          // ...
        }
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {

        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }

    func animateFace(image: UIImageView, direction: Bool){
        UIView.animate(withDuration: 0.3) {
            if direction{
                image.frame = CGRect(x: image.frame.origin.x, y: image.frame.origin.y+10, width: image.frame.size.width, height: image.frame.size.height)
            }
            else{
                image.frame = CGRect(x: image.frame.origin.x, y: image.frame.origin.y-10, width: image.frame.size.width, height: image.frame.size.height)
            }
        } completion: { (_) in
            let newDirection = !direction
            self.animateFace(image: image, direction: newDirection)
        }

    }

}

extension UIView {

    /// Create image snapshot of view.
    ///
    /// - Parameters:
    ///   - rect: The coordinates (in the view's own coordinate space) to be captured. If omitted, the entire `bounds` will be captured.
    ///   - afterScreenUpdates: A Boolean value that indicates whether the snapshot should be rendered after recent changes have been incorporated. Specify the value false if you want to render a snapshot in the view hierarchy’s current state, which might not include recent changes. Defaults to `true`.
    ///
    /// - Returns: The `UIImage` snapshot.

    func snapshot(of rect: CGRect? = nil, afterScreenUpdates: Bool = true) -> UIImage {
        return UIGraphicsImageRenderer(bounds: rect ?? bounds).image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: afterScreenUpdates)
        }
    }
}
