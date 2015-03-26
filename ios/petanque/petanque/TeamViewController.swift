//
//  TeamViewController.swift
//  petanque
//
//  Created by Hans Ott on 28/11/14.
//  Copyright (c) 2014 Hans Ott. All rights reserved.
//

import UIKit

class TeamViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var lblErrorTeam1: UILabel!
    @IBOutlet weak var lblErrorTeam2: UILabel!
    
    @IBOutlet weak var inputNameTeam1: UITextField!
    @IBOutlet weak var inputNameTeam2: UITextField!
    
    var errorColor = UIColor(red: 243/255, green: 124/255, blue: 32/255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.inputNameTeam1.delegate = self
        self.inputNameTeam2.delegate = self
        
        navigationController?.navigationBarHidden = false
        lblErrorTeam1.textColor = errorColor
        lblErrorTeam1.hidden = true
        lblErrorTeam2.textColor = errorColor
        lblErrorTeam2.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // If user clicked on start game
    // --> Validate input!
    @IBAction func btnStartGameClicked(sender: AnyObject) {
            }
    
    // If user clicked on start game without names
    @IBAction func btnStartGameWithoutNamesClicked(sender: AnyObject) {
        // Give default names and start game
    }
    
    // If return on keyboard is pressed --> Hide keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    
    // check if the values are filled in
    override func shouldPerformSegueWithIdentifier(identifier: String!, sender: AnyObject!) -> Bool {
        if identifier == "segueNames" {
            var ok : Bool = true
            
            if (inputNameTeam1.text == "") {
                ok = false
                lblErrorTeam1.hidden = false
            }
            else {
                lblErrorTeam1.hidden = true
            }
            
            if (inputNameTeam2.text == "") {
                ok = false
                lblErrorTeam2.hidden = false
            }
            else {
                lblErrorTeam2.hidden = true
            }
            
            if (ok) {
               return true
            }
            else {
                return false
            }
        }
        
        // by default, transition
        return true
    }
    
    // When going to new viewcontroller add data from current viewcontroller
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var team1: String!
        var team2: String!
        if (segue.identifier == "segueNames") {
            team1 = self.inputNameTeam1.text
            team2 = self.inputNameTeam2.text
            
        } else if (segue.identifier == "segueNoNames") {
            team1 = "Team One"
            team2 = "Team Two"
        }
        
        // Pass data to next view using Segues
        if let destinationVC = segue.destinationViewController as? GameViewController {
            destinationVC.team1Name = team1
            destinationVC.team2Name = team2
        }
    }
    
    override func canPerformUnwindSegueAction(action: Selector, fromViewController: UIViewController, withSender sender: AnyObject) -> Bool {
        return false;
    }
}
