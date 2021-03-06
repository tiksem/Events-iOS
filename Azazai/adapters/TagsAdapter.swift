//
// Created by Semyon Tikhonenko on 2/20/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation

import Foundation
import SwiftUtils

class TagsAdapterDelegate : AzazaiAdapterDelegate<Tag, UITableViewCell> {
    init(controller:UIViewController) {
        super.init(hostController: controller, factory: {
            (tag) in
            return TagEventsController(tag: tag.tagName)
        })
    }

    override func displayItem(element tag: Tag, cell: CellType, position:Int) -> Void {
        cell.layoutMargins = UIEdgeInsetsZero
        cell.textLabel?.text = tag.tagName
    }
}

class TagsAdapter : AzazaiListAdapter<TagsAdapterDelegate> {
    init(controller viewController:UIViewController, tagsListView:UITableView, tags: LazyList<Tag, IOError>) {
        super.init(tableView: tagsListView,
                list: tags,
                cellIdentifier: "TagCell",
                delegate: TagsAdapterDelegate(controller: viewController))
    }
}
