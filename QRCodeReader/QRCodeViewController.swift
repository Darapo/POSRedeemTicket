//
//  QRCodeViewController.swift
//  QRCodeReader
//
//  Created by DaraPO on 5/9/18.
//  Copyright © 2018 DaraPO. All rights reserved.
//

import UIKit
import BulletinBoard

class QRCodeViewController: UIViewController {

    @IBOutlet weak var aboutUSBtn: ButtonCustom!
    @IBOutlet weak var redeemBtn: ButtonCustom!
    @IBOutlet weak var aboutUsView: ViewCustom!
    @IBOutlet weak var redeemView: ViewCustom!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let redeemTap = UITapGestureRecognizer(target: self, action: #selector(self.gotoRedeemClicked(sender:)))
        redeemView.addGestureRecognizer(redeemTap)
        let aboutTap = UITapGestureRecognizer(target: self, action: #selector(self.gotoAboutClicked(sender:)))
        aboutUsView.addGestureRecognizer(aboutTap)
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        redeemBtn.dropShadow(offsetX: 0, offsetY: 3, color: UIColor.gray, opacity: 1, radius: 5, scale: true)
        aboutUSBtn.dropShadowButton(offsetX: 0, offsetY: 3, color: UIColor.gray, opacity: 1, radius: 5, scale: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func gotoRedeemClicked(sender : UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "redeemSegue", sender: nil)
    }
    @objc func gotoAboutClicked(sender : UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "aboutSegue", sender: nil)
    }
    
    // MARK: - Navigation

    @IBAction func unwindToHomeScreen(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }

}
