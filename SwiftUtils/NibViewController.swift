//
// Created by Semyon Tikhonenko on 2/2/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import UIKit

public class NibViewController : UIViewController {
    private let nibFileName:String!

    public init?(coder: NSCoder, nibFileName:String) {
        self.nibFileName = nibFileName
        super.init(coder: coder)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = .None
        var nestedView = UiUtils.instanceFromNib(nibFileName)
        nestedView.clipsToBounds = true
        view.addSubview(nestedView)
        nestedView.center = view.center
        nestedView.bounds = view.bounds
    }

    public required init?(coder: NSCoder) {
        assertionFailure("Should not be called")
        nibFileName = nil
        super.init(coder: coder)
    }
}
