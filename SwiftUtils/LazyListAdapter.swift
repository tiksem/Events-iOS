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
                if this.reverse {
                    let count = data.count
                    if count > 0 {
                        this.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: data.count, inSection: 0),
                                atScrollPosition: .Top, animated: false)
                    }
                }
            } else {
                fatalError("LazyListAdapter reference is gone, after data loaded, please keep reference of it")
            }
        }
        reloadData()
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
    
    public func getCount() -> Int {
        if list.loadNextPageExecuted || list.allDataLoaded || list.itemsCount == 0 {
            return list.count
        } else {
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
        if isLoadMoreItem(position) {
            return tableView.dequeueReusableCellWithIdentifier(loadMoreCellNibFileName)!
        } else {
            return super.createItemForPosition(position)
        }
    }
    
    public override func onItemSelectedWithPosition(position:Int) {
        if isLoadMoreItem(position) {
            loadMore()
        } else {
            super.onItemSelectedWithPosition(position)
        }
    }

    public func loadMore() {
        list.loadNextPage()
        reloadData()
    }
}
