//
// Created by Semyon Tikhonenko on 2/20/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import UIKit
import SwiftUtils

class TagsController : TableViewNibViewController {
    let requestManager:RequestManager
    var tagsView:TagsView! = nil
    var adapter:TagsAdapter! = nil

    required init?(coder:NSCoder) {
        requestManager = RequestManager()
        super.init(coder: coder, nibFileName: "TagsView")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tagsView = nestedView as! TagsView
        adapter = TagsAdapter(controller: self, tagsListView: tagsView.tagsListView,
                tags: requestManager.getTags())
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.navigationItem.title = "Tags"
    }

    override func getTableView() -> UITableView? {
        return tagsView?.tagsListView
    }

}
