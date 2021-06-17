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

    //MARK:- Outlets
    @IBOutlet var snippetImageView: UIImageView!
    @IBOutlet var faceImageView: UIImageView!
    @IBOutlet var blankImageView: UIImageView!
    
    //MARK:- Variables
    var noseImageView : UIImageView!
    var leftEyeBall : UIView!
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        initializeFaceDetection()
    }
    
    //MARK:- Initialize Face Detection
    func initializeFaceDetection(){
        
        //Initializing face detector options
        let options = FaceDetectorOptions()
        
        //Adding properties
        options.performanceMode = .accurate
        options.landmarkMode = .all
        options.contourMode = .all
        options.classificationMode = .all
        
        //Adding image and resizing as per ML Kit guidelines
        let sampleImage = resizeImage(image: UIImage.init(named: "face-4")!, newWidth: 400)!
        faceImageView.image = sampleImage
        let image = UIImage.init()
        
        //Initializing vision Image object with our sample image
        let visionImage = VisionImage(image: sampleImage)
        visionImage.orientation = image.imageOrientation
        
        //Initializing face detector object with above defined properties
        let faceDetector = FaceDetector.faceDetector(options: options)
        
        //Starting face detection process
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

            //Faces found
            for face in faces {
                let faceFrame = face.frame
                var lipsX = 0.0, lipsY=0.0, lipsW=0.0, lipsH=0.0        //Lips dimensions
                var noseX = 0.0, noseY = 0.0, noseW = 0.0, noseH = 0.0  //Nose dimensions
                                
                //Calculating lips area with mouth position
                if let mouthLeft = face.landmark(ofType: .mouthLeft){
                    let mouthLeftPos = mouthLeft.position
                    print("Mouth Left = \(mouthLeftPos)")
                    lipsX = Double(mouthLeftPos.x)
                    lipsY = Double(mouthLeftPos.y)
                }
                
                if let mouthRight = face.landmark(ofType: .mouthRight){
                    let mouthRightPos = mouthRight.position
                    print("Mouth Right = \(mouthRightPos)")
                    lipsW = Double(mouthRightPos.x) - lipsX
                }
                
                //Calculating nose area with nose position
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
//                    var currentPoint:CGPoint = CGPoint(x: noseBottomPoints[0].x, y: noseBottomPoints[0].y)
                    for noses in noseBottomPoints{
//                        self.drawLineFromPoint(start: currentPoint, toPoint: CGPoint(x: noses.x, y: noses.y), ofColor: .green, inView: self.view)
//                        currentPoint = CGPoint(x: noses.x, y: noses.y)
                        avgNoseBottom = avgNoseBottom+Double(noses.y)
                    }
                    avgNoseBottom = avgNoseBottom/Double(noseBottomPoints.count)
                    noseH = avgNoseBottom - noseY
                }
                
                if let mouthBottom = face.landmark(ofType: .mouthBottom){
                    let mouthBottomPos = mouthBottom.position
                    print("Mouth Bottom = \(mouthBottomPos)")
                }
                
                lipsH = Double(faceFrame.origin.y+faceFrame.size.height) - lipsY
                
                var leftEyeX = 0.0
                var leftEyeY = 0.0
                if let leftEye = face.landmark(ofType: .leftEye) {
                    let leftEyePosition = leftEye.position
                    print("Left eye position \(leftEyePosition)")
                    leftEyeX = Double(leftEyePosition.x)
                    leftEyeY = Double(leftEyePosition.y)
                    let eyeView = UIView.init(frame: CGRect(x: leftEyePosition.x, y: leftEyePosition.y, width: 5, height: 5))
                    eyeView.backgroundColor = UIColor.black
                    self.view.addSubview(eyeView)
                }
                
                if let rightEye = face.landmark(ofType: .rightEye) {
                    let rightEyePosition = rightEye.position
                    print("Right eye position \(rightEyePosition)")
                  
                    let eyeView = UIView.init(frame: CGRect(x: rightEyePosition.x, y: rightEyePosition.y, width: 5, height: 5))
                    eyeView.backgroundColor = UIColor.black
                    self.view.addSubview(eyeView)
                }
                
                var leftEyeTop = 0.0
                var leftEyeBottom = 0.0
                var leftEyeShapeArray:[CGPoint] = []
                if let leftEyeContour = face.contour(ofType: .leftEye) {
                    let leftEyePoints = leftEyeContour.points
                    print("Left eye points \(leftEyePoints)")
                    leftEyeTop = Double(leftEyePoints[0].y)
                    leftEyeBottom = Double(leftEyePoints[0].y)
                    var currentPoint:CGPoint = CGPoint(x: leftEyePoints[0].x, y: leftEyePoints[0].y)
                    
                    for eyes in leftEyePoints{
                        leftEyeShapeArray.append(CGPoint(x: eyes.x, y: eyes.y))
//                        self.drawLineFromPoint(start: currentPoint, toPoint: CGPoint(x: eyes.x, y: eyes.y), ofColor: .green, inView: self.view)
                        if leftEyeTop<Double(eyes.y){
                            leftEyeTop = Double(eyes.y)
                        }
                        if leftEyeBottom>Double(eyes.y){
                            leftEyeBottom = Double(eyes.y)
                        }
                    currentPoint = CGPoint(x: eyes.x, y: eyes.y)
                    }
                }
                self.drawShape(points: leftEyeShapeArray)
                leftEyeY = leftEyeBottom
                let heightOfLeftEye = leftEyeTop-leftEyeBottom
                let widthOfLeftEye = heightOfLeftEye
                
                self.leftEyeBall = UIView.init(frame: CGRect(x: leftEyeX-5, y: leftEyeY, width: widthOfLeftEye, height: heightOfLeftEye))
                self.leftEyeBall.backgroundColor = .black
                self.leftEyeBall.layer.cornerRadius = self.leftEyeBall.frame.size.width/2
                self.leftEyeBall.clipsToBounds = true
                self.view.addSubview(self.leftEyeBall)
                
                

                
                var rightEyeShapeArray:[CGPoint] = []
                var rightEyeTop = 0.0
                var rightEyeBottom = 0.0
                if let rightEyeContour = face.contour(ofType: .rightEye) {
                    let rightEyePoints = rightEyeContour.points
                    print("Left eye points \(rightEyePoints)")
                    rightEyeTop = Double(rightEyePoints[0].y)
                    rightEyeBottom = Double(rightEyePoints[0].y)
                    var currentPoint:CGPoint = CGPoint(x: rightEyePoints[0].x, y: rightEyePoints[0].y)
                    for eyes in rightEyePoints{
//                        self.drawLineFromPoint(start: currentPoint, toPoint: CGPoint(x: eyes.x, y: eyes.y), ofColor: .red, inView: self.view)
                        rightEyeShapeArray.append(CGPoint(x: eyes.x, y: eyes.y))
                        
                        currentPoint = CGPoint(x: eyes.x, y: eyes.y)
                        if rightEyeTop<Double(eyes.y){
                            rightEyeTop = Double(eyes.y)
                        }
                        if rightEyeBottom>Double(eyes.y){
                            rightEyeBottom = Double(eyes.y)
                        }
                    }
                }
                
//                self.drawShape(points: rightEyeShapeArray)
                
                
                let heightOfRightEye = rightEyeTop-rightEyeBottom
                let widthOfRightEye = heightOfRightEye
                
                let frameOfLowerLip = CGRect.init(x: lipsX-5, y: lipsY-5, width: lipsW, height: lipsH)
                
                //Taking screenshot of lips and adding it to another image which will animate
                let snapshot = self.view.snapshot(of: frameOfLowerLip, afterScreenUpdates: true)
                self.snippetImageView.image = snapshot
                self.snippetImageView.frame = frameOfLowerLip
                
                self.blankImageView.frame = frameOfLowerLip
                self.blankImageView.isHidden = false
                self.view.bringSubviewToFront(self.snippetImageView)
                
                //Taking screenshot of nose and adding it to another image which will animate
                let noseFrame = CGRect(x: noseX, y: noseY, width: noseW, height: noseH)
                self.noseImageView = UIImageView.init(frame: noseFrame)
                let noseSnapshot = self.view.snapshot(of: noseFrame, afterScreenUpdates: true)
                self.noseImageView.image = noseSnapshot
                self.noseImageView.backgroundColor = UIColor.blue
                self.view.addSubview(self.noseImageView)
                
                

              // If classification was enabled:
//                if face.hasSmilingProbability {
//                    let smileProb = face.smilingProbability
//                    print("Is smiling \(smileProb)")
//                }
//                if face.hasRightEyeOpenProbability {
//                    let rightEyeOpenProb = face.rightEyeOpenProbability
//                    print("Right eye open \(rightEyeOpenProb)")
//                }

              // If face tracking was enabled:
//                if face.hasTrackingID {
//                    let trackingId = face.trackingID
//                    print("Tracking ID \(trackingId)")
//                }
            }
        }
    }

    
    //MARK:- Draw shape
    func drawShape(points: [CGPoint]) {
        let whiteView = UIImageView(frame: self.faceImageView.bounds)
        let maskLayer = CAShapeLayer()
        
        // create the path
        let path = UIBezierPath()
        path.move(to: points[0])
        for paths in points{
            path.addLine(to: paths)
        }
        path.addLine(to: points[0])
        path.close()
        
        // fill the path
        UIColor.red.set()
        path.fill()
        
        maskLayer.path = path.cgPath
        whiteView.layer.mask = maskLayer
        whiteView.clipsToBounds = true
        whiteView.backgroundColor = .white
//        whiteView.image = UIImage(named: "")
        self.view.addSubview(whiteView)
    }
    
    //MARK:- Resize Image
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {

        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }

    //MARK:- Animate Face
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

    //MARK:- Draw Life from Point A-B
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
    
    //MARK:- Animate Eyes
    @IBAction func animateEyes(_ sender: Any) {
        UIView.animate(withDuration: 0.5) {
            self.leftEyeBall.frame = CGRect(x: self.leftEyeBall.frame.origin.x-10, y: self.leftEyeBall.frame.origin.y, width: self.leftEyeBall.frame.size.width, height: self.leftEyeBall.frame.size.height)
        } completion: { (_) in
            UIView.animate(withDuration: 0.5) {
                self.leftEyeBall.frame = CGRect(x: self.leftEyeBall.frame.origin.x+20, y: self.leftEyeBall.frame.origin.y, width: self.leftEyeBall.frame.size.width, height: self.leftEyeBall.frame.size.height)
            } completion: { (_) in
                UIView.animate(withDuration: 0.5) {
                    self.leftEyeBall.frame = CGRect(x: self.leftEyeBall.frame.origin.x-10, y: self.leftEyeBall.frame.origin.y, width: self.leftEyeBall.frame.size.width, height: self.leftEyeBall.frame.size.height)
                }
            }
        }
    }
    
    //MARK:- Animate Nose
    @IBAction func animateNose(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            self.noseImageView.frame = CGRect(x: self.noseImageView.frame.origin.x-5, y: self.noseImageView.frame.origin.y, width: self.noseImageView.frame.size.width+10, height: self.noseImageView.frame.size.height)
        } completion: { (_) in
            UIView.animate(withDuration: 0.3) {
                self.noseImageView.frame = CGRect(x: self.noseImageView.frame.origin.x+5, y: self.noseImageView.frame.origin.y, width: self.noseImageView.frame.size.width-10, height: self.noseImageView.frame.size.height)
            }
        }
    }
    
    //MARK:- Animate Lips
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

//MARK:- UIView Extension
extension UIView {
    //MARK: Take Snapshot
    func snapshot(of rect: CGRect? = nil, afterScreenUpdates: Bool = true) -> UIImage {
        return UIGraphicsImageRenderer(bounds: rect ?? bounds).image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: afterScreenUpdates)
        }
    }
}


