//
//  GameViewController.swift
//  petanque
//
//  Created by Hans Ott on 28/11/14.
//  Copyright (c) 2014 Hans Ott. All rights reserved.
//

import UIKit
import QuartzCore
import CoreData
import MobileCoreServices

class GameViewController: UIViewController, UIImagePickerControllerDelegate, UIAlertViewDelegate, UINavigationControllerDelegate {
    
    // Dem properties
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnTeam1Score: UIButton!
    @IBOutlet weak var btnTeam2Score: UIButton!
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var lblTeam1: UILabel!
    @IBOutlet weak var lblTeam2: UILabel!
    @IBOutlet weak var btnRules: UIButton!
    
    // Teamnames
    var team1Name: String!
    var team2Name: String!
    
    // Scores
    var score1 : Int = 0
    var score2 : Int = 0
    
    // The image picker
    var cameraUI : UIImagePickerController!
    
    var api = ApiWrapper()
    var game : Game!
    
    var spinner : UIActivityIndicatorView!
    
    // if view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        createGameOnApi()
        var randomDice : Int = generateRandomIndex(lower: 1, upper: 2)
        initComponents()
        startingTeam(randomDice)
    }
    
    func createGameOnApi() {
        
        let teams : Array<Team> = [
            Team(name: self.team1Name, playersInTeam: 1),
            Team(name: self.team2Name, playersInTeam: 1)
        ]
        
        api.createGame(teams, finished: { (game) in

            self.game = game as Game
            
        })
    }
    
    // Get a random number between lower en upper value
    func generateRandomIndex(#lower: Int , upper: Int) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
    
    // Says what team has to start
    func startingTeam(nmbr: Int) {
        if nmbr == 1 {
            self.lblTitle.text = self.team1Name + " is up!"
        }
        else {
            self.lblTitle.text = self.team2Name + " is up!"
        }
    }
    
    // Init components
    func initComponents() {
        self.navigationItem.rightBarButtonItem = createShareButton()
        self.navigationItem.leftBarButtonItem = createBackButton()
        
        self.lblTeam1.text = self.team1Name
        self.lblTeam2.text = self.team2Name
        setBtnStyle(1, btn: btnCamera, color: Colors.blue)
        setBtnStyle(1, btn: btnRules, color: Colors.blue)
        setTextColors(lblTitle, color: UIColor.blackColor())
        setBtnScoresStyle(btnTeam1Score, color: Colors.blue)
        setBtnScoresStyle(btnTeam2Score, color: Colors.orange)
        
        self.spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        spinner.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2)
        spinner.tag = 12
        spinner.hidden = true
        self.view.addSubview(spinner)
    }
    
    func showSpinner() {
        spinner.startAnimating()
        spinner.hidden = false
    }
    
    func hideSpinner() {
        spinner.stopAnimating()
        spinner.hidden = true
    }
    
    func createShareButton() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "shareClicked")
    }
    
    func createBackButton() -> UIBarButtonItem {
        var backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
        backButton.setTitle("Stop", forState: UIControlState.Normal)
        backButton.setTitleColor(Colors.defaultBlue, forState: UIControlState.Normal)
        backButton.tintColor = Colors.defaultBlue
        backButton.addTarget(self, action: "stopGame", forControlEvents: UIControlEvents.TouchUpInside)
        var backButtonItem = UIBarButtonItem(customView: backButton)
        return backButtonItem
    }
    
    func stopGame() {
        var alert = UIAlertController(title: "Are you sure?", message: "This action will stop the current game.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        let stopGameAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Destructive, handler: {
            (alert : UIAlertAction!) in
            self.navigationController?.popViewControllerAnimated(true)
            return
            
        })
        alert.addAction(stopGameAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // Set the text color for a UILabel object
    func setTextColors(txt: UILabel, color: UIColor) {
        txt.textColor = color
    }
    
    // Set button style for a UIButton object
    func setBtnStyle(width: CGFloat, btn: UIButton, color: UIColor ) {
        btn.layer.borderWidth = 1
        btn.layer.borderColor = color.CGColor
        btn.setTitleColor(color, forState: UIControlState.Normal)
        btn.layer.cornerRadius = 2
    }
    
    // Set button style for the score UIButton object
    func setBtnScoresStyle(btn: UIButton, color: UIColor){
        btn.layer.cornerRadius = 46
        btn.backgroundColor = color
        btn.setTitleColor(color, forState: UIControlState.Normal)
        btn.setTitle("0", forState: UIControlState.Normal)
        btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
    }
    
    // Camera button clicked --> Show camera view
    @IBAction func btnCameraClicked(sender: AnyObject) {
        self.presentCamera()
    }
    
    @IBAction func btnShareClicked(sender: AnyObject) {
        shareClicked()
    }
    
    func shareClicked() {
        if self.game != nil {
            shareGame(NSURL(string: self.game.getShareUrl())!)
        }
    }
    
    // Share button clicked --> Let the user share game url with UIActivityViewController
    func shareGame(url : NSURL) {
        
        // let's add a String and an NSURL
        let activityViewController = UIActivityViewController(
            activityItems: ["I'm playing petanque", url],
            applicationActivities: nil)
        
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    // Show rules of the game
    @IBAction func btnShowRulesClicked(sender: AnyObject) {
        
    }
    
    // Team 1 button clicked
    @IBAction func btnTeam1Clicked(sender: AnyObject) {
        score1++
        self.btnTeam1Score.setTitle("\(score1)", forState: UIControlState.Normal)
        setlblTitle()
        
        if self.game != nil {
            api.updateScoreTeam(self.game.getTeams()[0].id, code: self.game.code, newScore: score1, finished: { (ok) in println(ok) })
        }
        
    }
    
    // Team 2 button clicked
    @IBAction func btnTeam2Clicked(sender: AnyObject) {
        score2++
        self.btnTeam2Score.setTitle("\(score2)", forState: UIControlState.Normal)
        setlblTitle()
        
        if self.game != nil {
            api.updateScoreTeam(self.game.getTeams()[1].id, code: self.game.code, newScore: score2, finished: { (ok) in println(ok) })
        }
    }
    
    // Set the title lable to the correct value
    func setlblTitle(){
        
        // if score is 13, say who the winner is and disable score buttons
        if score1 == 13 || score2 == 13 {
            self.btnTeam1Score.enabled = false
            self.btnTeam2Score.enabled = false
            if score1 == 13 {
                lblTitle.text = team1Name + " is the winner!"
            }else if score2 == 13 {
                lblTitle.text = team2Name + " is the winner!"
            }
            return
        }
        
        if score1 == score2 {
            lblTitle.text = "It is a tie!"
        }
        else if score1 > score2 {
            lblTitle.text = team1Name + " is winning!"
        }
        else {
            lblTitle.text = team2Name + " is winning!"
        }
        
    }
    
    // Show camera view --> If no camera is available (like on the simulator) show alert
    func presentCamera()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        {
            // Settings
            self.cameraUI = UIImagePickerController()
            cameraUI.delegate = self
            cameraUI.sourceType = .Camera;
            cameraUI.mediaTypes = [kUTTypeImage]
            cameraUI.allowsEditing = false
            cameraUI.showsCameraControls = false
            cameraUI.navigationBarHidden = true;
            cameraUI.toolbarHidden = true
            
            var transform = CGAffineTransformMakeTranslation(0, 71)
            cameraUI.cameraViewTransform = transform
            
            // Set the camera overlay view
            var overlay = CameraOverlayView(frame: self.view.bounds, parent: self)
            cameraUI.cameraOverlayView = overlay
            
            self.presentViewController(cameraUI, animated: true, completion: nil)
        }
        else {
            // Show alert
            var alert = UIAlertController(title: "Oh no!", message: "This feature is not available on your device.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerTakePicture() {
        self.cameraUI.takePicture()
    }
    
    func imagePickerCancel() {
        dismissImagePicker(self.cameraUI)
    }
    
    // if user canceled image picker
    func imagePickerControllerDidCancel(picker:UIImagePickerController)
    {
        dismissImagePicker(picker)
    }
    
    // if user took picture
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        showSpinner()
        
        // INTEGRATE API
        var apiWrapper = ApiWrapper()
        
        apiWrapper.detectBalls(image, whenSuccess: { (resultImage) in
            self.hideSpinner()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("DetectionResultVC") as DetectionResultVC
            vc.resultingImage = resultImage
            self.presentViewController(vc, animated: true, completion: nil)
        }, whenError: { (msg) in
            
            var alert = UIAlertController(title: "Oh no!", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)

            self.hideSpinner()
        })
        
        dismissImagePicker(picker)
    }
    
    // Dismiss the image picker
    func dismissImagePicker(picker : UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: {
            
            // Make sure there is an overlayview
            if let overlayView = picker.cameraOverlayView as? CameraOverlayView {
                overlayView.stopListening()
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}