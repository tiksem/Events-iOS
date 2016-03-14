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
        frame.size = tagLabel.frame.size
    }

    override required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

public class TagsView : UIView, UITextFieldDelegate {
    public var tagsSpace:CGFloat = 5
    private var tagEdit:UITextField!

    public override required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    public override init(frame withFrame:CGRect) {
        super.init(frame: withFrame)
        setup()
    }

    private func setup() {
        tagEdit = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
        tagEdit.placeholder = "Yo"
        //tagEdit.textAlignment = .
        tagEdit.delegate = self
        addSubview(tagEdit)
        UiUtils.centerVerticaly(tagEdit)
    }

    public func addTag(tag:String) {
        var tagViewOrigin = CGPoint(x: 0, y: 0)
        if let lastView = subviews.last {
            let lastViewFrame = lastView.frame
            tagViewOrigin.x = lastViewFrame.origin.x + lastViewFrame.width + tagsSpace
        }

        let tagViewFrame = CGRect(origin: tagViewOrigin, size: frame.size)
        let tagView = TagView(tagName: tag, withFrame: tagViewFrame)
        addSubview(tagView)
        UiUtils.centerVerticaly(tagView)
    }

    public func textField(textField: UITextField, var shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var resultingString:String!
        let text = textField.text


        if string.characters.count == 1 && string.rangeOfCharacterFromSet(
        NSCharacterSet.alphanumericCharacterSet()) == nil {
            return false;
        } else {
            if let text = text where !text.isEmpty {
                let textLength = text.characters.count
                if (range.location + range.length > textLength) {
                    range.length = textLength - range.location;
                }

                resultingString = ((textField.text ?? "") as NSString)
                .stringByReplacingCharactersInRange(range, withString:string)
            } else {
                resultingString = string
            }

            let components = resultingString.componentsSeparatedByCharactersInSet(
            NSCharacterSet.alphanumericCharacterSet().invertedSet)

            if (components.count > 2) {
                for  component in components {
                    if !component.isEmpty &&
                            component.rangeOfCharacterFromSet(
                        NSCharacterSet.alphanumericCharacterSet().invertedSet) != nil {
                        break
                    }
                }

                return false;
            }

            return true;
        }
    }

}
