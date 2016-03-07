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
        displayValueFor = nil
    }
}

final class TagsCell : Cell<TagsArray>, CellType {
    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let tagsView = SwiftUtils.TagsView(frame: frame)
        addSubview(tagsView)
    }
}
