//
// Created by Semyon Tikhonenko on 3/25/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import UIKit

public class LinearLayout : UIView {
    public init(var origin: CGPoint, width:CGFloat, views:[UIView]) {
        super.init(frame: CGRect(origin: origin, size: CGSize.zero))
        var height:CGFloat = 0
        for view in views {
            let size = view.frame.size
            view.frame.origin = origin
            height += size.height
            origin.y += size.height
            view.frame.size.width = min(size.width, width)
            addSubview(view)
        }

        frame.size = CGSize(width: width, height: height)
    }

    public override required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        assertionFailure("Should not be called")
    }

}
