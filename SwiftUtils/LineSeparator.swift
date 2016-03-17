//
// Created by Semyon Tikhonenko on 3/17/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import UIKit

public class LineSeparator : UIView {
    private func setup() {
        frame.size.height = 1
        let horizontalLine = UIView(frame: CGRect(x: frame.origin.x, y: frame.origin.y,
                width: frame.size.width, height: 1))
        horizontalLine.backgroundColor = UiUtils.TABLE_SEPARATOR_COLOR
        addSubview(horizontalLine)
    }

    public required override init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
}