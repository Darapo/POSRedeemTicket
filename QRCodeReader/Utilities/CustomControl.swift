//
//  CustomControl.swift
//  IBKBizcard
//
//  Created by Ralex on 6/8/16.
//  Copyright © 2016 webcash. All rights reserved.
//

import Foundation
import UIKit

/*
    TODO : Custom Designable of UIButton
 */
@IBDesignable class ButtonCustom:UIButton{
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    @IBInspectable var cornerRadius:CGFloat = 0{
        didSet{
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.white {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
}


/*
    TODO : Custom Designable of UIView
 */
@IBDesignable class ViewCustom:UIControl{
    @IBInspectable var borderColor:UIColor = UIColor.clear{
        didSet{
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth:CGFloat = 0{
        didSet{
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius:CGFloat = 0{
        didSet{
            layer.cornerRadius = cornerRadius
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
