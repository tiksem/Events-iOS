//
// Created by Semyon Tikhonenko on 3/21/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import UIKit

public class AutoSearchBar : UISearchBar, UISearchBarDelegate {
    public var onSearchButtonClicked:((String)->Void)? = nil
    public var onCancel:(()->Void)? = nil

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    public required override init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        delegate = self
    }

    public func searchBarShouldBeginEditing(_ searchBar: UISearchBar!) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }

    public func cancel() {
        text = nil
        resignFirstResponder()
        setShowsCancelButton(false, animated: true)
    }

    public func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        cancel()
        onCancel?()
    }

    public func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        resignFirstResponder()
        let text = searchBar.text ?? ""
        onSearchButtonClicked?(text)
        for subview in UiUtils.getAllSubViewsRecursive(self) {
            if let view = subview as? UIButton {
                view.enabled = true
            }
        }
    }
}
