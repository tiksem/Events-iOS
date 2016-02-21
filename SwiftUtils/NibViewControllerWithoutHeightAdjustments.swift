//
// Created by Semyon Tikhonenko on 2/17/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import UIKit

public class NibViewControllerWithoutHeightAdjustments: NibViewController {
    public override init?(coder: NSCoder, nibFileName:String) {
        super.init(coder: coder, nibFileName: nibFileName)
    }

    public required init?(coder: NSCoder) {
        assertionFailure("Should not be called")
        super.init(coder: coder)
    }

    public override init(nibFileName:String) {
        super.init(nibFileName: nibFileName)
    }

    public override func getNestedViewFrame() -> CGRect {
        return view.frame
    }
}