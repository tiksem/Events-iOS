//
// Created by Semyon Tikhonenko on 1/10/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import UIKit

public class LazyListAdapter<T : Hashable, Error : ErrorType, CellType: UITableViewCell> : NSObject,
        UITableViewDelegate, UITableViewDataSource {
    private let cellIdentifier:String
    private let cellNibFileName:String
    private let nullCellIdentifier:String
    private let nullCellNibFileName:String
    private let list:LazyList<T, Error>
    private let displayItem:(T, CellType) -> Void
    private let displayNullItem:((UITableViewCell) -> Void)?
    private let onItemSelected:((T, Int) -> Void)?
    private unowned let tableView:UITableView

    public init(cellIdentifier:String,
                cellNibFileName:String? = nil,
                nullCellIdentifier:String,
                nullCellNibFileName:String? = nil,
                list:LazyList<T, Error>,
                displayItem:(T, CellType) -> Void,
                displayNullItem:((UITableViewCell) -> Void)? = nil,
                onItemSelected:((T, Int) -> Void)? = nil,
                tableView:UITableView) {
        self.cellIdentifier = cellIdentifier
        self.cellNibFileName = cellNibFileName ?? cellIdentifier
        self.nullCellIdentifier = nullCellIdentifier
        self.nullCellNibFileName = nullCellNibFileName ?? nullCellIdentifier
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

    private func getCell(cellIdentifier:String, nibFile:String) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) {
            return cell
        } else {
            tableView.registerNib(UINib(nibName: nibFile, bundle: nil), forCellReuseIdentifier: cellIdentifier)
            return tableView.dequeueReusableCellWithIdentifier(cellIdentifier)!
        }
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let item = list[indexPath.row] {
            let cell = getCell(cellIdentifier, nibFile: cellNibFileName) as! CellType
            displayItem(item, cell)
            return cell
        } else {
            let cell = getCell(nullCellIdentifier, nibFile: nullCellNibFileName)
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
