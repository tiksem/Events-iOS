//
// Created by Semyon Tikhonenko on 2/1/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import UIKit

public class UiUtils {
    public static func removeSeparator(cell:UITableViewCell) {
        cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0);
    }

    public static func instanceFromNib(fileName:String) -> UIView {
        return NSBundle.mainBundle().loadNibNamed(fileName,
                owner: nil, options: nil)[0] as! UIView
    }
}
