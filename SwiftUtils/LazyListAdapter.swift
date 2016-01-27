//
// Created by Semyon Tikhonenko on 1/10/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import UIKit

public class LazyListAdapter<T : Hashable, Error : ErrorType, CellType: UITableViewCell> : NSObject,
        UITableViewDelegate, UITableViewDataSource {
    private let cellIdentifier:String
    private let nullCellIdentifier:String
    private let list:LazyList<T, Error>
    private let displayItem:(T, CellType) -> Void
    private let displayNullItem:((UITableViewCell) -> Void)?
    private let onItemSelected:((T, Int) -> Void)?
    private unowned let tableView:UITableView

    public init(cellIdentifier:String,
                nullCellIdentifier:String,
                list:LazyList<T, Error>,
                displayItem:(T, CellType) -> Void,
                displayNullItem:((UITableViewCell) -> Void)? = nil,
                onItemSelected:((T, Int) -> Void)? = nil,
                tableView:UITableView) {
        self.cellIdentifier = cellIdentifier
        self.nullCellIdentifier = nullCellIdentifier
        self.list = list
        self.displayItem = displayItem
        self.displayNullItem = displayNullItem
        self.tableView = tableView
        self.onItemSelected = onItemSelected

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
        if let item = list[indexPath.row] {
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! CellType!
            displayItem(item, cell)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(nullCellIdentifier)!
            displayNullItem?(cell)
            return cell
        }
    }

    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        if let item = list[row] {
            onItemSelected?(item, row)
        }
    }
}
