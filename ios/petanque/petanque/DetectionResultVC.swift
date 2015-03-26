//
//  DetectionResultVC.swift
//  petanque
//
//  Created by Hans Ott on 8/01/15.
//  Copyright (c) 2015 Hans Ott. All rights reserved.
//

import Foundation
import UIKit

class DetectionResultVC : UIViewController {
    
    var resultingImage : UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (resultingImage != nil) {
            var scrollView = UIScrollView(frame: self.view.frame)
            var imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: resultingImage.size.width, height: resultingImage.size.height))
            scrollView.addSubview(imageView)
            scrollView.backgroundColor = UIColor.blackColor()
            imageView.image = resultingImage
            scrollView.maximumZoomScale = 4
            scrollView.minimumZoomScale = 0.4
            scrollView.contentSize = resultingImage.size
            self.view.addSubview(scrollView)
        }
        
        var closeBtn = createCloseButton()
        self.view.addSubview(closeBtn)
    }
    
    func createCloseButton() -> UIButton {
        var frame : CGRect = CGRect(x: 0, y: CGFloat(self.view.frame.height - 71), width: CGFloat(self.view.frame.width), height: 71)
        var btn = UIButton(frame: frame)
        btn.backgroundColor = Colors.blue
        btn.setTitle("Close", forState: .Normal)
        btn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        btn.addTarget(self, action: "dismiss", forControlEvents: .TouchUpInside)
        return btn
    }
    
    func dismiss() {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
}