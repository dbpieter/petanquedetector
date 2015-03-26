//
//  ApiWrapper.swift
//  petanque
//
//  Created by Hans Ott on 1/12/14.
//  Copyright (c) 2014 Hans Ott. All rights reserved.
//

import Alamofire
import UIKit

// API WRAPPER
class ApiWrapper {
    
    var baseUrl : String = "https://petanque.hansott.be"
    
    // Configure ApiWrapper with a default baseUrl : petanque.hansott.be
    init() { }
    
    // Configure ApiWrapper with a different baseUrl for local testing
    init(baseUrl : String) {
        self.baseUrl = baseUrl
    }
    
    func createImageUrl(imageName : String) -> String {
        return baseUrl + "/processeduploads/" + imageName
    }
    
    func detectBalls(image : UIImage, whenSuccess : (UIImage) -> (), whenError : (String) -> ()) {
        uploadImage(image, successHandler: { (fileName) in
            
            let url = NSURL(string: self.createImageUrl(fileName))
            
            if let data = NSData(contentsOfURL: url!) {
                var img : UIImage = UIImage(data: data)!
                whenSuccess(img)
            }
            else {
                whenError("Could not detect balls in picture.")
            }
            
        }, errorHandler: { (errorMsg) in whenError(errorMsg) })
    }
    
    func uploadImage(image : UIImage, successHandler : (String) -> (), errorHandler : (String) -> ()) {
        var tempImg = UIImage(CGImage: image.CGImage, scale: 1, orientation: UIImageOrientation.Left)
        var img = tempImg?.normalizedImage()
        var imageData = UIImagePNGRepresentation(RBResizeImage(img))
        
        var parameters = [
            "task": "task",
            "variable1": "var"
        ]
        
        let urlRequest = urlRequestWithComponents(baseUrl + "/api/detectballs/upload", parameters: parameters, imageData: imageData)
        
        Alamofire.upload(urlRequest.0, urlRequest.1)
            .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                println("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
            }
            .responseString { (request, response, data, error) in
                println(response)
                println(data)
                
                if (response?.statusCode == 200) {
                    
                    if let fileName = data {
                        successHandler(fileName)
                    }
                    else {
                        let msg : String = "Could not read image."
                        errorHandler(msg)
                    }
                }
                else {
                    errorHandler(("Could not detect balls in picture.") as String)
                }
            }
    }
    
    // this function creates the required URLRequestConvertible and NSData we need to use Alamofire.upload
    func urlRequestWithComponents(urlString:String, parameters:Dictionary<String, String>, imageData:NSData) -> (URLRequestConvertible, NSData) {
        
        // create url request to send
        var mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        let boundaryConstant = "myRandomBoundary12345";
        let contentType = "multipart/form-data;boundary="+boundaryConstant
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // create upload data to send
        let uploadData = NSMutableData()
        
        // add image
        uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Disposition: form-data; name=\"image\"; filename=\"image.png\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData(imageData)
        
        // add parameters
        for (key, value) in parameters {
            uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        uploadData.appendData("\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        // return URLRequestConvertible and NSData
        return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
    }
    
    func RBResizeImage(image: UIImage?) -> UIImage? {
        if let image = image {
            let size = image.size
            
            //let widthRatio  = targetSize.width  / image.size.width
            //let heightRatio = targetSize.height / image.size.height
            
            let widthRatio = 1000 / image.size.width
            let heightRatio = image.size.height * widthRatio
            
            // Figure out what our orientation is, and use that to form the rectangle
            var newSize: CGSize
            if(widthRatio > heightRatio) {
                newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
            } else {
                newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
            }
            
            // This is the rect that we've calculated out and this is what is actually used below
            let rect = CGRectMake(0, 0, newSize.width, newSize.height)
            
            // Actually do the resizing to the rect using the ImageContext stuff
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.drawInRect(rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage
        } else {
            return nil
        }
    }
    
    func updateScoreTeam(teamId : Int, code: String, newScore : Int, finished : (AnyObject) -> ()) {
        let url : String = baseUrl + "/api/teams/\(teamId)"
        let parameters : [String : AnyObject] = [
            "code" : code,
            "score" : newScore
        ]
        
        Alamofire.request(Method.PUT, url, parameters : parameters, encoding : ParameterEncoding.URL)
        .responseJSON { (request, response, data, error) in
            if (response?.statusCode == 200) {
                finished(true)
            }
            else {
                finished(false)
            }
        }
    }
    
    // Create Game object
    func createGame(teams : Array<Team>, finished : (AnyObject) -> ()) {
        
        // Only 2 teams are allowed
        if (teams.count != 2) {
            println("Only 2 teams are allowed")
            finished("")
        }
        
        let url : String = baseUrl + "/api/games/"
        
        // Build our parameters
        let parameters : [String : AnyObject] = [
            "players" : teams[0].playersInTeam,
            "team1" : teams[0].name,
            "team2" : teams[1].name
        ]
        
        // Fire request and when finished use callback function to return Game object
        Alamofire.request(Method.POST, url, parameters: parameters, encoding: ParameterEncoding.URL)
        .responseJSON { (request, response, data, error) in
            
            if let code = data as? NSString {
                var game : Game = Game(teams: teams, code : code)
                
                self.requestIds(game, finished: { data in
                    finished(game)
                })
            }
            else {
                finished("")
            }
        }
        
    }
    
    private func requestIds(game : Game, finished : (AnyObject) -> ()) {
        
        if let code = game.code {
            
            let url : String = baseUrl + "/api/games/" + game.code
            
            Alamofire.request(Method.GET, url).responseJSON { (request, response, data, error) in

                var json = data as NSDictionary
                
                var id: NSNumber = Int(json["id"]! as NSNumber)
                var teams = json["Teams"] as NSArray
                
                for team in teams {
                    for gteam in game.getTeams() {
                        if (gteam.name == team["name"] as String) {
                            gteam.id = Int(team["id"] as NSNumber)
                        }
                    }
                }
                
                game.id = Int(json["id"] as NSNumber)
                
                println(game.getTeams())
                
                finished("")
            }
            
        }
        
    }
    
    
}
