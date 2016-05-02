//
//  RequestCell.swift
//  Azazai
//
//  Created by Semyon Tikhonenko on 5/1/16.
//  Copyright © 2016 Semyon Tikhonenko. All rights reserved.
//

import Foundation
import UIKit

class RequestCell : UITableViewCell {
    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var decline: UIButton!

    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var accept: UIButton!
}
