//
// Created by Semyon Tikhonenko on 1/10/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import UIKit

public class LazyListAdapter<T, Error : ErrorType, CellType: UITableViewCell> : NSObject,
        UITableViewDelegate, UITableViewDataSource {
    private let cellIdentifier:String
    private let list:LazyList<T, Error>
    private let displayItem:(T, CellType) -> Void
    private let displayNullItem:(CellType) -> Void
    private unowned let tableView:UITableView

    public init(cellIdentifier:String,
                list:LazyList<T, Error>,
                displayItem:(T, CellType) -> Void,
                displayNullItem:(CellType) -> Void, tableView:UITableView) {
        self.cellIdentifier = cellIdentifier
        self.list = list
        self.displayItem = displayItem
        self.displayNullItem = displayNullItem
        self.tableView = tableView

        super.init()
        reloadData()
        list.onNewPageLoaded = {
            (data) in
            self.reloadData()
        }
    }

    private func reloadData() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }

    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! CellType!
        if let item = list[indexPath.row] {
            displayItem(item, cell)
        } else {
            displayNullItem(cell)
        }

        return cell
    }

    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }
}
