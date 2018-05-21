//
//  DetailQRViewController.swift
//  QRCodeReader
//
//  Created by DaraPO on 5/10/18.
//  Copyright © 2018 DaraPO. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import BulletinBoard

class DetailQRViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var redeemAmountTf: UITextField!
    @IBOutlet weak var redeemInputView: UIView!
    @IBOutlet weak var qrRedeemInfo: UILabel!
    @IBOutlet weak var redeemBtn: UIButton!
    @IBOutlet weak var nameCompanyLb: UILabel!
    @IBOutlet weak var availableLb: UILabel!
    @IBOutlet weak var amountLb: UILabel!
    @IBOutlet weak var qualityLb: UILabel!
    
    final let ticketURL = "http://tickets-test.pipay.com/api/redeeminfor"
    final let redeemURL = "http://tickets-test.pipay.com/api/redeem"
    var decodeURL = ""
    var availableTickets = 0
    
    lazy var alertQRSuccessManager: BulletinManager = {
        let page = PageBulletinItem(title: "QR Information")
        page.image = #imageLiteral(resourceName: "success")
        page.imageAccessibilityLabel = "Information"
        
        page.descriptionText = "Your ticket have been redeemed succesfully!\n Do you want to redeem more ticket?"
        page.actionButtonTitle = "Confirm"
        page.alternativeButtonTitle = "Cancel"
        
        page.isDismissable = true
        
        //        page.dismissalHandler = { item in
        //            NotificationCenter.default.post(name: .SetupDidComplete, object: item)
        //        }
        
        page.actionHandler = { item in
            item.manager?.dismissBulletin(animated: true)
            let mainStory = UIStoryboard(name: "Main", bundle: nil)
            
            let QRScreen = mainStory.instantiateViewController(withIdentifier: "QRScannerController") as! QRScannerController
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            appDelegate.window!.rootViewController = nil
            appDelegate.window!.rootViewController = QRScreen
        }
        page.alternativeHandler = { item in
            page.manager?.dismissBulletin(animated: true)
        }
        return BulletinManager(rootItem: page)
    }()
    lazy var alertNetworkStatusManager: BulletinManager = {
        let page = PageBulletinItem(title: "Network Information")
        page.image = #imageLiteral(resourceName: "wifi")
        page.imageAccessibilityLabel = "Information"
        
        page.descriptionText = "Network is currently unreachable!"
        page.actionButtonTitle = "Confirm"
        
        page.isDismissable = true
        
        page.actionHandler = { item in
            let mainStory = UIStoryboard(name: "Main", bundle: nil)
            
            let QRMainScreen = mainStory.instantiateViewController(withIdentifier: "QRCodeViewController") as! QRCodeViewController
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            appDelegate.window!.rootViewController = nil
            appDelegate.window!.rootViewController = QRMainScreen
        }
        return BulletinManager(rootItem: page)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(decodeURL)
        self.redeemAmountTf.delegate = self
        self.redeemAmountTf.setDoneInputAccessory(self, action: #selector(DetailQRViewController.doneEdited))
        
        let bodyParam = ["id" : decodeURL]
        
        Utilities.requestPOSTURL(strURL: ticketURL, params: bodyParam, success: { (response) in
            guard let dicRes = response.dictionaryObject as NSDictionary? else {
                return
            }
            if let data = dicRes.object(forKey: "data") as? NSDictionary {
                let amount = data.object(forKey: "amount") as? Int ?? 0
                let qty = data.object(forKey: "qty") as? Int ?? 0
                let available = data.object(forKey: "available_qty") as? Int ?? 0
                self.availableTickets = available
                
                if available == 0 {
                    self.redeemBtn.isHidden = true
                    self.redeemInputView.isHidden = true
                    self.qrRedeemInfo.text = "This QR code is redeem already."
                }else{
                    self.redeemBtn.isHidden = false
                    self.redeemInputView.isHidden = false
                    self.redeemAmountTf.becomeFirstResponder()
                    self.qrRedeemInfo.text = "Input your Redeem amount :"
                }
                
                self.nameCompanyLb.text = data.object(forKey: "product_name") as? String ?? ""
                self.amountLb.text = "\(amount) $"
                self.availableLb.text = "\(available) tickets"
                self.qualityLb.text = "\(qty) tickets"
            }

        }) { (errorRes) in
            if errorRes.code == 2003 {
                DispatchQueue.main.sync {
                    self.alertNetworkStatusManager.prepare()
                    self.alertNetworkStatusManager.presentBulletin(above: self)
                }
                
            }else {
                let errorin = NSError(domain: "pipay", code: 1008, userInfo: nil)
                self.launchPopup(messageTitle: "QR Information seem to be invalid! Please try again.", error: errorin)
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func redeemBtnClicked(_ sender: Any) {
        
        if !(redeemAmountTf.text?.isNumeric)! {
            let errorin = NSError(domain: "pipay", code: 1000, userInfo: nil)
            launchPopup(messageTitle: "You can only input number!!!",error: errorin)
            return
        }
        if Int(redeemAmountTf.text!)! <= 0 {
            let errorin = NSError(domain: "pipay", code: 1000, userInfo: nil)
            launchPopup(messageTitle: "You cannot redeem zero ticket!!!",error: errorin)
            return
        }
        if Int(redeemAmountTf.text!)! > availableTickets {
            let errorin = NSError(domain: "pipay", code: 1000, userInfo: nil)
            launchPopup(messageTitle: "You cannot redeem more than your available tickets!!!",error: errorin)
            return
        }
        
        let bodyParam = ["qty" : redeemAmountTf.text!,
                         "id" : decodeURL]
        Utilities.requestPOSTURL(strURL: redeemURL, params: bodyParam, success: { (response) in
            guard let dicRes = response.dictionaryObject as NSDictionary? else {
                return
            }
            if let data = dicRes.object(forKey: "data") as? NSDictionary {
                let type = dicRes.object(forKey: "success") as? Int ?? 0
                
                if type.description == "1" {
//                    let errorin = NSError(domain: "pipay", code: 1009, userInfo: nil)
//                    self.launchPopup(messageTitle: "Your ticket have been redeemed succesfully!/n Do you want to redeem more ticket?",error: errorin)
                    
                    self.alertQRSuccessManager.prepare()
                    self.alertQRSuccessManager.presentBulletin(above: self)
                    
                    let amount = data.object(forKey: "amount") as? Int ?? 0
                    let qty = data.object(forKey: "qty") as? Int ?? 0
                    let available = data.object(forKey: "available_qty") as? Int ?? 0
                    self.availableTickets = available
                    
                    if available == 0 {
                        self.redeemBtn.isHidden = true
                        self.redeemInputView.isHidden = true
                        self.qrRedeemInfo.text = "This QR code is redeem already."
                    }else{
                        self.redeemBtn.isHidden = false
                        self.redeemInputView.isHidden = false
                        self.qrRedeemInfo.text = "Input your Redeem amount :"
                    }
                    
                    self.nameCompanyLb.text = data.object(forKey: "product_name") as? String ?? ""
                    self.amountLb.text = "\(amount) $"
                    self.availableLb.text = "\(available) tickets"
                    self.qualityLb.text = "\(qty) tickets"
                }else{
                    let errorin = NSError(domain: "pipay", code: 1008, userInfo: nil)
                    self.launchPopup(messageTitle: "Error in processing!",error: errorin)
                }
                
            }
            
        }) { (error) in
            print(error)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ReachabilityManager.shared.addListener(listener: self)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ReachabilityManager.shared.removeListener(listener: self)
    }
    // MARK: -Helper Method
   
    @objc func doneEdited(){
        self.view.endEditing(true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension DetailQRViewController{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.endEditing(true)
    }
}
extension DetailQRViewController : NetworkStatusListener {
    func networkStatusDidChange(status: Reachability.Connection) {
        switch status {
        case .none:
            self.alertNetworkStatusManager.prepare()
            self.alertNetworkStatusManager.presentBulletin(above: self)
        default:
            print("Cellular or Wifi is Disconnect")
        }
    }
}

