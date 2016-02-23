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
    public override init(cellIdentifier:String,
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

        list.onNewPageLoaded = {
            (data) in
            self.reloadData()
        }

        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    public override var list : LazyList<Delegate.T, Error> {
        didSet {
            list.onNewPageLoaded = {
                (data) in
                self.reloadData()
            }
        }
    }
}
