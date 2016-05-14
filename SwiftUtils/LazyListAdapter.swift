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
                tableView:UITableView,
                delegate:Delegate,
                reverse:Bool = false) {
        super.init(cellIdentifier: cellIdentifier,
                cellNibFileName: cellNibFileName,
                nullCellIdentifier: nullCellIdentifier,
                nullCellNibFileName: nullCellNibFileName,
                list: list,
                tableView: tableView,
                delegate: delegate,
                reverse: reverse)
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

    func updateTableContentInset() {
        let numRows = tableView.numberOfRowsInSection(0)
        var contentInsetTop = self.tableView.bounds.size.height;
        for i in 0 ..< numRows {
            contentInsetTop -= tableView.cellForRowAtIndexPath(NSIndexPath(forItem: i, inSection:0))?.frame.height ?? 0
            if contentInsetTop <= 0 {
                contentInsetTop = 0
                break
            }
        }
        self.tableView.contentInset = UIEdgeInsetsMake(contentInsetTop, 0, 0, 0);
    }
    
    public override func reloadData() {
        super.reloadData()
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

public class LoadMoreLazyListAdapter<Delegate:AdapterDelegate,
    Error:ErrorType where Delegate.T:Hashable,
    Delegate.CellType:UITableViewCell,
    Delegate.NullCellType:UITableViewCell> : LazyListAdapter<Delegate, Error> {
    
    private let loadMoreCellNibFileName:String
    
    public init(cellIdentifier:String,
                cellNibFileName:String? = nil,
                nullCellIdentifier:String,
                nullCellNibFileName:String? = nil,
                list:LazyList<T, Error>,
                tableView:UITableView,
                delegate:Delegate,
                loadMoreCellNibFileName: String,
                reverse:Bool = false) {
        self.loadMoreCellNibFileName = loadMoreCellNibFileName
        super.init(cellIdentifier: cellIdentifier,
                   cellNibFileName: cellNibFileName,
                   nullCellIdentifier: nullCellIdentifier,
                   nullCellNibFileName: nullCellNibFileName,
                   list: list,
                   tableView: tableView,
                   delegate: delegate,
                   reverse: reverse)
        
        UiUtils.registerNib(tableView: tableView, nibName: loadMoreCellNibFileName, cellIdentifier: loadMoreCellNibFileName)
    }
    
    public override func listDidSet() {
        super.listDidSet()
        list.manualLoadingEnabled = true
    }
    
    private func getCount() -> Int {
        if list.loadNextPageExecuted || list.allDataLoaded {
            print("tableView count = \(list.count)")
            return list.count
        } else {
            print("tableView count = \(list.count + 1)")
            return list.count + 1
        }
    }
    
    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getCount()
    }
    
    public override func getItemPositionForIndexPath(indexPath:NSIndexPath) -> Int {
        let index = indexPath.row
        if reverse {
            return getCount() - index - 1
        }
        
        return index
    }
    
    private func isLoadMoreItem(position:Int) -> Bool {
        return !list.allDataLoaded && !list.loadNextPageExecuted && position == list.count
    }
    
    public override func createItemForPosition(position:Int) -> UITableViewCell {
        print("createItemForPosition position = \(position)")
        if isLoadMoreItem(position) {
            return tableView.dequeueReusableCellWithIdentifier(loadMoreCellNibFileName)!
        } else {
            return super.createItemForPosition(position)
        }
    }
    
    public override func onItemSelectedWithPosition(position:Int) {
        if isLoadMoreItem(position) {
            list.loadNextPage()
            reloadData()
        } else {
            super.onItemSelectedWithPosition(position)
        }
    }
}
