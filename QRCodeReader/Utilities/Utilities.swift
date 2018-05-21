//
//  Utilities.swift
//  QRCodeReader
//
//  Created by DaraPO on 5/10/18.
//  Copyright © 2018 DaraPO. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class Utilities: NSObject {
    // request post with alamofire
    class func requestPOSTURL(strURL urlIn : String, params : [String : String]?, success : @escaping (JSON) -> Void, failure : @escaping (NSError) -> Void){
        let headers = ["Content-Type" : "application/x-www-form-urlencoded"]
        isInternetAvailable(webSiteToPing: "https://www.google.com") { (isAvailable) in
            if isAvailable {
                Alamofire.request(urlIn, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { (responseObject) in
                    print(responseObject)
                    if responseObject.result.isSuccess {
                        let resJson = JSON(responseObject.result.value!)
                        success(resJson)
                    }
                    if responseObject.result.isFailure {
                        let error : NSError = responseObject.result.error! as NSError
                        failure(error)
                    }
                }
            }else{
                let error : NSError = NSError(domain: "pipay", code: 2003, userInfo: nil)
                failure(error)
            }
        }
        
    }
    class func isInternetAvailable(webSiteToPing: String?, completionHandler: @escaping (Bool) -> Void) {
        
        
        // 2. Check the Internet Connection
        var webAddress = "https://www.google.com" // Default Web Site
        if let _ = webSiteToPing {
            webAddress = webSiteToPing!
        }
        
        guard let url = URL(string: webAddress) else {
            completionHandler(false)
            print("could not create url from: \(webAddress)")
            return
        }
        
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            if error != nil || response == nil {
                completionHandler(false)
            } else {
                completionHandler(true)
            }
        })
        
        task.resume()
    }
}
extension UITextField {
    //Custom accessory bar
    func setDoneInputAccessory(_ target: Any? ,  action: Selector?){
        let numberToolbar = UIToolbar()
        numberToolbar.barStyle = UIBarStyle.default
        numberToolbar.isTranslucent = true
        numberToolbar.tintColor = UIColor.blue
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        numberToolbar.items = [spaceButton, spaceButton,
                               UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: target , action: action)
        ]
        numberToolbar.sizeToFit()
        self.inputAccessoryView = numberToolbar
    }
}
extension UIView {
    // Custom shadow view
    func dropShadow(offsetX : CGFloat,offsetY : CGFloat, color : UIColor, opacity : Float, radius : CGFloat, scale : Bool ) {
        layer.masksToBounds = false
        layer.shadowOffset = CGSize(width: offsetX, height: offsetY)
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}
extension UIButton {
    // Custom shadow button
    func dropShadowButton(offsetX : CGFloat,offsetY : CGFloat, color : UIColor, opacity : Float, radius : CGFloat, scale : Bool ) {
        layer.masksToBounds = false
        layer.shadowOffset = CGSize(width: offsetX, height: offsetY)
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}
extension String{
    // check is number
    var isNumeric : Bool {
        guard self.count > 0 else {
            return false
        }
        let nums : Set<Character> = ["0","1","2","3","4","5","6","7","8","9"]
        return Set(self).isSubset(of: nums)
    }
}
extension UIViewController {
    // alert view controller for pop up information
    func launchPopup(messageTitle : String, error : NSError?) {
        
        if presentedViewController != nil {
            return
        }
        
        let alertPrompt = UIAlertController(title: "Redeem Informtion", message:messageTitle, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            if let err = error , error?.domain == "pipay" {
                // error code 1008 is for invalid QR scan
                if  err.code == 1008 || err.code == 1009{
                    
                    //                        GO TO Scan QR
                    let mainStory = UIStoryboard(name: "Main", bundle: nil)
                    
                    let QRScreen = mainStory.instantiateViewController(withIdentifier: "QRScannerController") as! QRScannerController
                    
                     let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    
                    appDelegate.window!.rootViewController = nil
                    appDelegate.window!.rootViewController = QRScreen
                    
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        if let err = error , error?.domain == "pipay" {
            if  err.code != 1008 {
                alertPrompt.addAction(cancelAction)
            }
        }
        alertPrompt.addAction(confirmAction)
        
        present(alertPrompt, animated: true, completion: nil)
    }
}
