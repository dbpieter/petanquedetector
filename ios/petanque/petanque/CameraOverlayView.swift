//
//  OverlayView.swift
//  petanque
//
//  Created by Hans Ott on 27/11/14.
//  Copyright (c) 2014 Hans Ott. All rights reserved.
//

import UIKit
import CoreMotion

class CameraOverlayView : UIView {
    
    let motionManager: CMMotionManager = CMMotionManager()

    var isFlat : Bool = false;
    
    var arrowUp : UIImage = UIImage()
    var arrowDown : UIImage = UIImage()
    var arrowLeft : UIImage = UIImage()
    var arrowRight : UIImage = UIImage()
    
    var parent : GameViewController!
    
    init(frame : CGRect, parent: GameViewController) {
        super.init(frame: frame)
        
        self.parent = parent
        
        // create a button to take picture
        var cancel = UIButton(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 71))
        cancel.backgroundColor = Colors.blue
        cancel.tintColor = UIColor.whiteColor()
        cancel.setTitle("Cancel", forState: .Normal)
        cancel.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        cancel.addTarget(self, action: "cancel", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(cancel)
        
        // create a button to take picture
        var button = UIButton(frame: CGRect(x: 0, y: 497, width: self.frame.width, height: 71))
        button.backgroundColor = Colors.blue
        button.tintColor = UIColor.whiteColor()
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.addTarget(self, action: "takePicture", forControlEvents: UIControlEvents.TouchUpInside)
        var buttonIcon = UIImage(named: "camera")?.imageWithRenderingMode(.AlwaysTemplate)
        button.setImage(buttonIcon, forState: .Normal)
        self.addSubview(button)
        
        // draw crosshair on the camera view
        drawCrosshair()
        
        // Start listening to acceleration data
        self.startListening()
    }
    
    func cancel() {
        println("cancel")
        parent.imagePickerCancel()
    }
    
    func takePicture() {
        if(self.isFlat) {
            parent.imagePickerTakePicture()
        }
    }
    
    func drawCrosshair() {
        var crosshairWidth : CGFloat = 1;
        var vertical = UIView(frame: CGRect(x: self.frame.width / 2 - crosshairWidth / 2, y: 71, width: crosshairWidth, height: 426));
        vertical.backgroundColor = Colors.blue;
        
        var horizontal = UIView(frame: CGRect(x: 0, y: self.frame.height / 2 - crosshairWidth / 2, width: self.frame.width, height: crosshairWidth));
        horizontal.backgroundColor = Colors.blue;
        
        self.addSubview(vertical);
        self.addSubview(horizontal);
    }
    
    // Stop listening to acceleration data
    func stopListening() {
        self.motionManager.stopAccelerometerUpdates()
    }
    
    // Start listening to acceleration data
    func startListening() {
        if (self.motionManager.accelerometerAvailable) {
            self.motionManager.accelerometerUpdateInterval = 0.1
            self.motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue()) { (data, error) -> Void in
                //println("x = \(data.acceleration.x)")
                //println("y = \(data.acceleration.y)")
                //println("z = \(data.acceleration.z)")
                
                if(data.acceleration.x < 0.1 && data.acceleration.x > -0.1 && data.acceleration.y < 0.1 && data.acceleration.y > -0.1) {
                    self.backgroundColor = UIColor(red: 0, green: 255, blue: 0, alpha: 0.2)
                    self.isFlat = true;
                }
                else {
                    var value = (fabs(data.acceleration.x) + fabs(data.acceleration.y)) / 2
                    self.backgroundColor = UIColor(red: 255, green: 0, blue: 0, alpha: CGFloat(value))
                    self.isFlat = false;
                }
            }
        }
    }
    
    // Dunno what this is, but it's required.
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}