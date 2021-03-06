//
// Created by Semyon Tikhonenko on 3/6/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import Eureka
import SwiftUtils

class TagsArray : Equatable {
    var array:[String] = []
}

func == (a: TagsArray, b: TagsArray) -> Bool {
    let lhs = a.array
    let rhs = b.array
    return lhs.count == rhs.count && (zip(lhs, rhs).contains { $0.0 != $0.1 }) == false
}

final class TagsRow: Row<TagsArray, TagsCell>, RowType {
    required init(tag: String?) {
        super.init(tag: tag)
        value = TagsArray()
        displayValueFor = nil

        cell.tagsView.onTagsChanged = {
            [unowned self]
            () in
            self.value!.array = self.cell.tagsView.tags as NSArray as! [String]
        }
    }
}

private class TagsListView : TLTagsControl {
    var onTagsChanged:(() -> Void)?

    override func reloadTagSubviews() {
        super.reloadTagSubviews()
        onTagsChanged?()
    }
}

final class TagsCell : Cell<TagsArray>, CellType {
    private var tagsView:TagsListView!

    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        tagsView = TagsListView(frame: CGRect(origin: CGPoint(x: frame.origin.x + 8, y: frame.origin.y),
                size: CGSize(width: frame.width - 16, height: 36)),
                andTags: [],
                withTagsControlMode: .Edit)
        addSubview(tagsView)
        UiUtils.centerVerticaly(tagsView)
    }
}
