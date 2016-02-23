//
// Created by Semyon Tikhonenko on 2/20/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import SwiftUtils

class AzazaiAdapterDelegate<T, CellType>: PushControllerOnItemSelectedAdapterDelegate<T, CellType, LoadingView> {
    override func displayNullItem(cell cell: LoadingView) -> Void {
        super.displayNullItem(cell: cell)
        cell.loading.startAnimating()
    }

    override init(hostController:UIViewController, factory:(T) -> UIViewController) {
        super.init(hostController: hostController, factory: factory)
    }
}

class AzazaiListAdapter<Delegate : AdapterDelegate
                       where Delegate.CellType : UITableViewCell,
                       Delegate.CellType : UITableViewCell,
                       Delegate.NullCellType: LoadingView,
                       Delegate.T : Hashable> : LazyListAdapter<Delegate, IOError> {
    init(tableView:UITableView,
         list: LazyList<Delegate.T, IOError>,
         cellIdentifier:String,
         delegate: Delegate) {
        super.init(cellIdentifier: cellIdentifier,
                nullCellIdentifier: "Loading",
                list: list,
                tableView: tableView,
                delegate: delegate)
        list.onError = {
            Alerts.showOkAlert($0.description)
        }
    }
}
