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
    
    var noseImageView : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let options = FaceDetectorOptions()
        options.performanceMode = .accurate
        options.landmarkMode = .all
        options.contourMode = .all
        options.classificationMode = .none
        
        let testImg = resizeImage(image: UIImage.init(named: "ayush.png")!, newWidth: 400)!
        faceImageView.image = testImg
        let image = UIImage.init()
        let visionImage = VisionImage(image: testImg)
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
                var x = 0.0, y=0.0, w=0.0, h=0.0
                var noseX = 0.0, noseY = 0.0, noseW = 0.0, noseH = 0.0
                                
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
                var avgNoseHeight = 0.0
                if let noseBridge = face.contour(ofType: .noseBridge){
                    let nosePoints = noseBridge.points
//                    var currentPoint:CGPoint = CGPoint(x: nosePoints[0].x, y: nosePoints[0].y)
                    print(nosePoints)
                    
                    for noses in nosePoints{
//                        self.drawLineFromPoint(start: currentPoint, toPoint: CGPoint(x: noses.x, y: noses.y), ofColor: .red, inView: self.view)
//                        currentPoint = CGPoint(x: noses.x, y: noses.y)
                        avgNoseHeight = avgNoseHeight+Double(noses.y)
                    }
                    avgNoseHeight = avgNoseHeight/Double(nosePoints.count)
                    noseY = avgNoseHeight
                    
                }
                
                var avgNoseBottom = 0.0
                if let noseBottom = face.contour(ofType: .noseBottom){
                    let noseBottomPoints = noseBottom.points
                    noseX = Double((noseBottomPoints)[0].x)
                    let lastPoint = noseBottomPoints.count-1
                    noseW = Double(noseBottomPoints[lastPoint].x) - Double((noseBottomPoints)[0].x)
                    print(noseBottomPoints)
                    var currentPoint:CGPoint = CGPoint(x: noseBottomPoints[0].x, y: noseBottomPoints[0].y)
                    for noses in noseBottomPoints{
//                        self.drawLineFromPoint(start: currentPoint, toPoint: CGPoint(x: noses.x, y: noses.y), ofColor: .green, inView: self.view)
                        currentPoint = CGPoint(x: noses.x, y: noses.y)
                        avgNoseBottom = avgNoseBottom+Double(noses.y)
                    }
                    avgNoseBottom = avgNoseBottom/Double(noseBottomPoints.count)
                    noseH = avgNoseBottom - noseY
                }
                
                if let mouthBottom = face.landmark(ofType: .mouthBottom){
                    let mouthBottomPos = mouthBottom.position
                    print("Mouth Bottom = \(mouthBottomPos)")
                }
                
                h = Double(faceFrame.origin.y+faceFrame.size.height) - y
                
              if let leftEye = face.landmark(ofType: .leftEye) {
                let leftEyePosition = leftEye.position
                print("Left eye position \(leftEyePosition)")
              }
                
              if let leftEyeContour = face.contour(ofType: .leftEye) {
                let leftEyePoints = leftEyeContour.points
                print("Left eye points \(leftEyePoints)")
              }
                
                let frameOfLowerLip = CGRect.init(x: x, y: y, width: w, height: h)
                
                let snapshot = self.view.snapshot(of: frameOfLowerLip, afterScreenUpdates: true)
                self.snippetImageView.image = snapshot
                self.snippetImageView.frame = frameOfLowerLip
                
                self.blankImageView.frame = frameOfLowerLip
                self.blankImageView.isHidden = false
                self.view.bringSubviewToFront(self.snippetImageView)
//                self.animateFace(image: self.snippetImageView, direction: true)
                
                let noseFrame = CGRect(x: noseX, y: noseY, width: noseW, height: noseH)
                self.noseImageView = UIImageView.init(frame: noseFrame)
                let noseSnapshot = self.view.snapshot(of: noseFrame, afterScreenUpdates: true)
                self.noseImageView.image = noseSnapshot
                self.noseImageView.backgroundColor = UIColor.blue
                self.view.addSubview(self.noseImageView)
                
                

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

    func drawLineFromPoint(start : CGPoint, toPoint end:CGPoint, ofColor lineColor: UIColor, inView view:UIView) {
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.lineWidth = 1.0
        view.layer.addSublayer(shapeLayer)
    }
    
    @IBAction func animateNose(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            self.noseImageView.frame = CGRect(x: self.noseImageView.frame.origin.x-5, y: self.noseImageView.frame.origin.y, width: self.noseImageView.frame.size.width+10, height: self.noseImageView.frame.size.height)
        } completion: { (_) in
            UIView.animate(withDuration: 0.3) {
                self.noseImageView.frame = CGRect(x: self.noseImageView.frame.origin.x+5, y: self.noseImageView.frame.origin.y, width: self.noseImageView.frame.size.width-10, height: self.noseImageView.frame.size.height)
            }
        }
    }
    
    @IBAction func animateLips(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            self.snippetImageView.frame = CGRect(x: self.snippetImageView.frame.origin.x, y: self.snippetImageView.frame.origin.y+10, width: self.snippetImageView.frame.size.width, height: self.snippetImageView.frame.size.height)
        } completion: { (_) in
            UIView.animate(withDuration: 0.3) {
                self.snippetImageView.frame = CGRect(x: self.snippetImageView.frame.origin.x, y: self.snippetImageView.frame.origin.y-10, width: self.snippetImageView.frame.size.width, height: self.snippetImageView.frame.size.height)
            }
        }
    }
}

extension UIView {
    func snapshot(of rect: CGRect? = nil, afterScreenUpdates: Bool = true) -> UIImage {
        return UIGraphicsImageRenderer(bounds: rect ?? bounds).image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: afterScreenUpdates)
        }
    }
}


