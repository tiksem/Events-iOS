//
// Created by Semyon Tikhonenko on 2/17/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import UIKit

public class LazyListAdapter<Delegate:AdapterDelegate,
                            Error:ErrorType where Delegate.T:Hashable,
                            Delegate.CellType:UITableViewCell,
                            Delegate.NullCellType:UITableViewCell> :
        RandomAccessibleAdapter<LazyList<Delegate.T, Error>, Delegate> {
    public init(cellIdentifier:String,
                cellNibFileName:String? = nil,
                nullCellIdentifier:String,
                nullCellNibFileName:String? = nil,
                list:LazyList<T, Error>,
                tableView:UITableView, delegate:Delegate) {
        super.init(cellIdentifier: cellIdentifier,
                cellNibFileName: cellNibFileName,
                nullCellIdentifier: nullCellIdentifier,
                nullCellNibFileName: nullCellNibFileName,
                list: list,
                tableView: tableView,
                delegate: delegate)
        listDidSet()
    }

    public func listDidSet() {
        list.onNewPageLoaded = {
            [weak self]
            (data) in
            if let this = self {
                this.reloadData()
            } else {
                fatalError("LazyListAdapter reference is gone, after data loaded, please keep reference of it")
            }
        }
        reloadData()
    }

    public func listWillSet() {
        list.reload()
    }

    public override var list : LazyList<Delegate.T, Error> {
        willSet {
            listWillSet()
        }

        didSet {
            listDidSet()
        }
    }

    deinit {
        list.onNewPageLoaded = nil
    }
}
