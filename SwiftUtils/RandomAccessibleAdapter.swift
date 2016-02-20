//
// Created by Semyon Tikhonenko on 1/10/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import UIKit

public protocol AdapterDelegate {
    typealias T
    typealias CellType
    func displayItem(element element:T, cell:CellType) -> Void
    func displayNullItem(cell cell:UITableViewCell) -> Void
    func onItemSelected(element element:T, position:Int) -> Void
}

public class AdapterDelegateDefaultImpl<T, CellType> : AdapterDelegate {
    public init() {

    }

    public func displayNullItem(cell cell:UITableViewCell) -> Void {
        UiUtils.removeSeparator(cell)
    }

    public func onItemSelected(element element:T, position:Int) -> Void {

    }

    public func displayItem(element element: T, cell: CellType) -> Void {

    }
}

public class PushControllerOnItemSelectedAdapterDelegate<T, CellType> : AdapterDelegateDefaultImpl<T, CellType> {
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
                                    Delegate.CellType:UITableViewCell> :
        NSObject, UITableViewDelegate, UITableViewDataSource {
    public typealias T = Delegate.T
    public typealias CellType = Delegate.CellType

    private let cellIdentifier:String
    private let cellNibFileName:String
    private let nullCellIdentifier:String
    private let nullCellNibFileName:String
    private let list:Container
    private unowned let tableView:UITableView
    public var delegate:Delegate

    public init(cellIdentifier:String,
                cellNibFileName:String? = nil,
                nullCellIdentifier:String,
                nullCellNibFileName:String? = nil,
                list:Container,
                tableView:UITableView,
                delegate:Delegate) {
        self.cellIdentifier = cellIdentifier
        self.cellNibFileName = cellNibFileName ?? cellIdentifier
        self.nullCellIdentifier = nullCellIdentifier
        self.nullCellNibFileName = nullCellNibFileName ?? nullCellIdentifier
        self.list = list
        self.tableView = tableView
        self.delegate = delegate

        UiUtils.registerNib(tableView: tableView, nibName: self.cellNibFileName, cellIdentifier: cellIdentifier)
        UiUtils.registerNib(tableView: tableView, nibName: self.nullCellNibFileName, cellIdentifier: nullCellIdentifier)

        super.init()

        reloadData()
    }

    public func reloadData() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }

    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let item = list[indexPath.row] {
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! CellType
            delegate.displayItem(element: item, cell: cell)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(nullCellIdentifier)!
            delegate.displayNullItem(cell: cell)
            return cell
        }
    }

    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        if let item = list[row] {
            delegate.onItemSelected(element: item, position: row)
        }
    }
}
