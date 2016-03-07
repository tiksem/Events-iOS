//
// Created by Semyon Tikhonenko on 3/4/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import UIKit

class TagView : UIView {
    init(tagName:String, withFrame:CGRect) {
        super.init(frame: withFrame)

        layer.cornerRadius = 5
        //origin.y = tagInputField_.frame.origin.y
        backgroundColor = UIColor(red:0.9,
        green:0.91,
        blue:0.925,
        alpha:1)

        var tagLabel = UILabel()
        tagLabel.text = tagName
        var labelFrame = tagLabel.frame
        tagLabel.textAlignment = .Center
        addSubview(tagLabel)
        tagLabel.sizeToFit()
        tagLabel.textColor = UIColor.yellowColor()
        tagLabel.clipsToBounds = true
        tagLabel.layer.cornerRadius = 5
        tagLabel.frame.size.width += 10
        tagLabel.frame.size.height += 5
        frame = tagLabel.frame
    }

    override required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

public class TagsView : UIView {
    public override required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override init(frame withFrame:CGRect) {
        super.init(frame: withFrame)
    }

    public func addTag(tag:String) {
        let tagView = TagView(tagName: tag, withFrame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        addSubview(tagView)
        UiUtils.centerVerticaly(tagView)
    }
}
