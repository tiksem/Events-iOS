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

    public init(nibFileName:String) {
        self.nibFileName = nibFileName
        super.init(nibName: nil, bundle: nil)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = .None
        self.extendedLayoutIncludesOpaqueBars = false;
        self.automaticallyAdjustsScrollViewInsets = false;
        nestedView = UiUtils.viewFromNib(nibFileName)
        nestedView.clipsToBounds = true
        view.addSubview(nestedView)
        nestedView.frame = view.bounds
    }

    public required init?(coder: NSCoder) {
        assertionFailure("Should not be called")
        nibFileName = nil
        super.init(coder: coder)
    }
}
