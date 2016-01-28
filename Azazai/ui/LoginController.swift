//
// Created by Semyon Tikhonenko on 1/28/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import UIKit
import SwiftUtils

class LoginController : UIViewController {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    @IBAction func onLoginClick(sender: UIButton) {
        performSegueWithIdentifier("ShowEvents", sender: self)
    }
}
