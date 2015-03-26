//
//  ViewController.swift
//  petanque
//
//  Created by Hans Ott on 27/11/14.
//  Copyright (c) 2014 Hans Ott. All rights reserved.
//

import UIKit
import Alamofire

class MainController: UIViewController {
    
    @IBOutlet weak var btn1vs1: UIButton!
    @IBOutlet weak var btn2vs2: UIButton!
    @IBOutlet weak var btn3vs3: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationController?.navigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btn1vs1Clicked(sender: AnyObject) {
        println("1vs1")
    }
    
    @IBAction func btn2vs2Clicked(sender: AnyObject) {
        println("2vs2")
    }
    
    @IBAction func btn3vs3Clicked(sender: AnyObject) {
        println("3vs3")
    }
    
    
}

