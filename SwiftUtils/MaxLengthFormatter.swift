//
// Created by Semyon Tikhonenko on 2/26/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation

public class MaxLengthFormatter : NSFormatter {
    public var maxlength:Int

    public init(_ maxlength:Int) {
        self.maxlength = maxlength
        super.init()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func isPartialStringValid(partialString: String,
                                       newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>,
                                       errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>) -> Bool {
        return partialString.characters.count <= maxlength
    }
}
