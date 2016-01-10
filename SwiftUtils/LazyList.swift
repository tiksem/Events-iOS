//
// Created by Semyon Tikhonenko on 1/1/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation

public class LazyList<T, Error : ErrorType> : RandomAccessable {
    public typealias ItemType = T
    private var items:[T] = []
    private var allDataLoaded = false
    private var loadNextPageExecuted = false
    private var pageNumber = 0

    public init(getNextPageData:(([T]) -> Void, (Error) -> Void, Int) -> Void) {
        self.getNextPageData = getNextPageData
    }

    public var onError:((Error) -> Void)?
    public var onNewPageLoaded:(([T]) -> Void)?
    public var getNextPageData:(([T]) -> Void, (Error) -> Void, Int) -> Void

    public subscript(index:Int) -> ItemType? {
        if allDataLoaded {
            return items[index]
        }

        assert(index <= items.count)
        if index == items.count {
            loadNextPage()
            return nil
        }

        return items[index]
    }

    public var count: Int {
        if allDataLoaded {
            return items.count
        }

        return items.count + 1
    }

    private func loadNextPage() {
        if loadNextPageExecuted {
            return
        }

        loadNextPageExecuted = true

        getNextPageData({
            self.loadNextPageExecuted = false
            self.items += $0
            self.pageNumber++
            self.onNewPageLoaded?($0)
        }, {
            self.onError?($0)
        }, pageNumber)
    }
}
