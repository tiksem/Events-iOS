//
// Created by Semyon Tikhonenko on 1/1/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation

public class LazyList<T : Hashable, Error : ErrorType> : RandomAccessable {
    public typealias ItemType = T
    private var items:[T] = []
    private var itemsSet:Set<T> = []
    private(set) var allDataLoaded = false
    private var loadNextPageExecuted = false
    var pageNumber = 0
    public var canceler:Canceler? = nil
    private(set) var additionalOffset = 0
    public var isLastPage:([T])->Bool = {$0.isEmpty}

    public init(getNextPageData:(([T]) -> Void, (Error) -> Void, Int) -> Void) {
        self.getNextPageData = getNextPageData
    }

    public init() {

    }

    public var onError:((Error) -> Void)?
    public var onNewPageLoaded:(([T]) -> Void)?
    public var getNextPageData:((([T]) -> Void, (Error) -> Void, Int) -> Void)?

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

        getNextPageData!({
            [unowned self]
            (page) in
            self.loadNextPageExecuted = false
            self.pageNumber++
            self.allDataLoaded = self.isLastPage(page)
            for item in page {
                if !self.itemsSet.contains(item) {
                    self.items.append(item)
                    self.itemsSet.insert(item)
                }
            }
            self.onNewPageLoaded?(page)
        }, {
            self.onError?($0)
        }, pageNumber)
    }

    public func reload() {
        items = []
        itemsSet = []
        pageNumber = 0
        canceler?.cancel()
        allDataLoaded = false
        loadNextPageExecuted = false
    }

    public func addAdditionalItemsToStart(items:[T]) {
        self.items += items
        additionalOffset += items.count
    }

    deinit {
        canceler?.cancel()
    }
}
