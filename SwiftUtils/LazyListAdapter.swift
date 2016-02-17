//
// Created by Semyon Tikhonenko on 2/17/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import UIKit

public class LazyListAdapter<T:Hashable,
                            Error:ErrorType,
                            CellType:UITableViewCell> :
        RandomAccessableAdapter<LazyList<T, Error>, CellType> {
    public override init(cellIdentifier:String,
                cellNibFileName:String? = nil,
                nullCellIdentifier:String,
                nullCellNibFileName:String? = nil,
                list:LazyList<T, Error>,
                displayItem:(T, CellType) -> Void,
                displayNullItem:((UITableViewCell) -> Void)? = nil,
                onItemSelected:((T, Int) -> Void)? = nil,
                tableView:UITableView) {
        super.init(cellIdentifier: cellIdentifier,
                cellNibFileName: cellNibFileName,
                nullCellIdentifier: nullCellIdentifier,
                nullCellNibFileName: nullCellNibFileName,
                list: list,
                displayItem: displayItem,
                displayNullItem: displayNullItem,
                onItemSelected: onItemSelected,
                tableView: tableView)

        list.onNewPageLoaded = {
            (data) in
            self.reloadData()
        }
    }
}
