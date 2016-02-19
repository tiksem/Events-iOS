//
// Created by Semyon Tikhonenko on 2/2/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import UIKit

public class NibViewController : UIViewController {
    private let nibFileName:String!
    private(set) public var nestedView:UIView!

    public init?(coder: NSCoder, nibFileName:String) {
        self.nibFileName = nibFileName
        super.init(coder: coder)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = .None
        nestedView = UiUtils.viewFromNib(nibFileName)
        nestedView.clipsToBounds = true
        view.addSubview(nestedView)
        let bounds = view.bounds
        let navHeight = getNavigationBarHeight()
        nestedView.bounds = CGRect(x: bounds.origin.x,
                y: bounds.origin.y,
                width: bounds.size.width,
                height: bounds.size.height - navHeight)
        nestedView.center = CGPoint(x: view.center.x, y: view.center.y + navHeight)
    }

    public required init?(coder: NSCoder) {
        assertionFailure("Should not be called")
        nibFileName = nil
        super.init(coder: coder)
    }

    public func getNavigationBarHeight() -> CGFloat {
        return navigationController?.navigationBar.bounds.height ?? 0.0
    }
}
