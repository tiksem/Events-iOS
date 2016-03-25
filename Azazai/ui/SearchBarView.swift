//
// Created by Semyon Tikhonenko on 3/25/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import UIKit
import SwiftUtils

class SearchBarView : UIView {
    @IBOutlet weak var searchbar: AutoSearchBar!
    @IBOutlet weak var closeDateFilter: UILabel!
    @IBOutlet weak var dateFilterHeight: NSLayoutConstraint!
    @IBOutlet weak var dateFilter: UILabel!
}
