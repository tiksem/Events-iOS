//
// Created by Semyon Tikhonenko on 2/22/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import UIKit

public class TableViewNibViewController : NibViewController {
    public override func viewDidLayoutSubviews() {
        if let rect = self.navigationController?.navigationBar.frame {
            let y = rect.size.height + rect.origin.y
            getTableView()?.contentInset = UIEdgeInsetsMake(y, 0, 0, 0)
        }
    }

    public func getTableView() -> UITableView? {
        return nil
    }
}
