//
// Created by Semyon Tikhonenko on 1/10/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import UIKit

public protocol AdapterDelegate {
    associatedtype T
    associatedtype CellType
    associatedtype NullCellType
    func displayItem(element element:T, cell:CellType, position:Int) -> Void
    func displayNullItem(cell cell:NullCellType) -> Void
    func onItemSelected(element element:T, position:Int) -> Void
}

public class AdapterDelegateDefaultImpl<T, CellType, NullCellType : UITableViewCell> : NSObject, AdapterDelegate {
    public override init() {
        super.init()
    }
    
    public func displayNullItem(cell cell:NullCellType) -> Void {
        UiUtils.removeSeparator(cell)
    }

    public func onItemSelected(element element:T, position:Int) -> Void {

    }

    public func displayItem(element element: T, cell: CellType, position:Int) -> Void {

    }
}

public class PushControllerOnItemSelectedAdapterDelegate<T, CellType, NullCellType: UITableViewCell> :
        AdapterDelegateDefaultImpl<T, CellType, NullCellType> {
    private unowned let hostController:UIViewController
    public var controllerFactory:(T) -> UIViewController

    public init(hostController:UIViewController, factory:(T) -> UIViewController) {
        self.hostController = hostController
        self.controllerFactory = factory
        super.init()
    }

    public override func onItemSelected(element element:T, position:Int) -> Void {
        let controller = controllerFactory(element)
        hostController.navigationController!.pushViewController(controller, animated: true)
    }
}

public class RandomAccessibleAdapter<Container:RandomAccessable,
                                    Delegate:AdapterDelegate
                                    where Container.ItemType == Delegate.T,
                                    Delegate.CellType:UITableViewCell,
                                    Delegate.NullCellType:UITableViewCell> :
        NSObject, UITableViewDelegate, UITableViewDataSource {
    public typealias T = Delegate.T
    public typealias CellType = Delegate.CellType

    private let cellIdentifier:String
    private let cellNibFileName:String
    private let nullCellIdentifier:String?
    private let nullCellNibFileName:String?
    public let reverse:Bool
    public var list:Container
    public unowned let tableView:UITableView
    public var delegate:Delegate

    public init(cellIdentifier:String,
                cellNibFileName:String? = nil,
                nullCellIdentifier:String? = nil,
                nullCellNibFileName:String? = nil,
                list:Container,
                tableView:UITableView,
                delegate:Delegate, dynamicHeight:Bool = true, reverse:Bool = false) {
        self.cellIdentifier = cellIdentifier
        self.cellNibFileName = cellNibFileName ?? cellIdentifier
        self.nullCellIdentifier = nullCellIdentifier
        self.nullCellNibFileName = nullCellNibFileName ?? nullCellIdentifier
        self.list = list
        self.tableView = tableView
        self.delegate = delegate
        self.reverse = reverse

        UiUtils.registerNib(tableView: tableView, nibName: self.cellNibFileName, cellIdentifier: cellIdentifier)

        if let nullNib = self.nullCellNibFileName {
            UiUtils.registerNib(tableView: tableView, nibName: nullNib,
                    cellIdentifier: nullCellIdentifier!)
        }

        super.init()

        reloadData()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        if dynamicHeight {
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 160.0
        }
    }

    public func reloadData() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }

    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }

    private func getItemFromIndexPath(indexPath:NSIndexPath) -> T? {
        return list[getItemPositionForIndexPath(indexPath)]
    }

    public func getItemPositionForIndexPath(indexPath:NSIndexPath) -> Int {
        var row = 0
        for section in 0..<indexPath.section {
            row += tableView(tableView, numberOfRowsInSection:section)
        }
        
        let index = row + indexPath.row
        if reverse {
            return list.count - index - 1
        }
        
        return index
    }
    
    public func createItemForPosition(position:Int) -> UITableViewCell {
        if let item = list[position] {
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! CellType
            delegate.displayItem(element: item, cell: cell, position: position)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(nullCellIdentifier!) as! Delegate.NullCellType
            delegate.displayNullItem(cell: cell)
            return cell
        }
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let position = getItemPositionForIndexPath(indexPath)
        return createItemForPosition(position)
    }

    public func onItemSelectedWithPosition(position:Int) {
        if let item = list[position] {
            delegate.onItemSelected(element: item, position: position)
        }
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let position = getItemPositionForIndexPath(indexPath)
        onItemSelectedWithPosition(position)
    }
}

public class ArrayRandomAccessible<ItemType> : RandomAccessable {
    public var array:[ItemType]

    public init(array:[ItemType]) {
        self.array = array
    }

    public subscript(index: Int) -> ItemType? {
        return array[index]
    }

    public var count: Int {
        return array.count
    }

}

public class ArrayAdapter<Delegate:AdapterDelegate where
        Delegate.CellType:UITableViewCell,
        Delegate.NullCellType:UITableViewCell> : RandomAccessibleAdapter<ArrayRandomAccessible<Delegate.T>, Delegate> {
    public init(cellIdentifier:String,
                         cellNibFileName:String? = nil,
                         array:[Delegate.T],
                         tableView:UITableView, delegate:Delegate, dynamicHeight:Bool = true) {
        super.init(cellIdentifier: cellIdentifier,
                cellNibFileName: cellNibFileName,
                list: ArrayRandomAccessible<Delegate.T>(array: array),
                tableView: tableView,
                delegate: delegate, dynamicHeight: dynamicHeight)
    }
}
