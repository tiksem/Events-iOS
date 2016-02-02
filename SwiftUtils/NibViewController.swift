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
        view.addSubview(UiUtils.instanceFromNib(nibFileName))
    }

    public required init?(coder: NSCoder) {
        nibFileName = nil
        super.init(coder: coder)
    }
}
