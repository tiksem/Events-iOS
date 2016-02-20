//
// Created by Semyon Tikhonenko on 2/20/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import UIKit
import SwiftUtils

class TagsController : NibViewController {
    let requestManager:RequestManager

    required init?(coder:NSCoder) {
        requestManager = RequestManager()
        super.init(coder: coder, nibFileName: "TagsView")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let tagsView = nestedView as! TagsView
        TagsAdapter(controller: self, tagsListView: tagsView.tagsListView,
                tags: requestManager.getTags())
    }
}
