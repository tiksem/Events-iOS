//
// Created by Semyon Tikhonenko on 2/1/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import UIKit

public class UiUtils {
    public static let STATUS_BAR_HEIGHT:CGFloat = 20.0

    public static func removeSeparator(cell:UITableViewCell) {
        cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0);
    }

    public static func viewFromNib(fileName:String) -> UIView {
        return NSBundle.mainBundle().loadNibNamed(fileName,
                owner: nil, options: nil)[0] as! UIView
    }

    public static func registerNib(tableView tableView:UITableView, nibName:String, cellIdentifier:String) {
        let nib = UINib(nibName: nibName, bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: cellIdentifier)
    }

    public static func getTabBarHeightOfController(controller:UIViewController) -> CGFloat {
        return controller.tabBarController?.tabBar.frame.height ?? 0
    }

    public static func getNavigationBarHeightOfCotroller(controller:UIViewController) -> CGFloat {
        return controller.navigationController?.navigationBar.frame.height ?? 0.0
    }

    public static func addNavigationBarButtonOfTopController(viewController:UIViewController, left:Bool = false,
                                                                         action:Selector,
                                                                         barButtonSystemItem: UIBarButtonSystemItem)
                    -> UIViewController {
        let addButton = UIBarButtonItem(barButtonSystemItem: barButtonSystemItem, target:viewController,
                action:action)

        let topViewController = viewController.navigationController!.topViewController!
        if left {
            topViewController.navigationItem.setLeftBarButtonItem(addButton, animated: false)
        } else {
            topViewController.navigationItem.setRightBarButtonItem(addButton, animated: false)
        }
        return topViewController
    }

    public static func addAddButtonToTheRightOfNavigationBarOfTopController(viewController:UIViewController,
                                                             action:Selector) -> UIViewController {
        return addNavigationBarButtonOfTopController(viewController,
                action:action, barButtonSystemItem: .Add)
    }

    public static func pushViewController(hostController:UIViewController, controller:UIViewController) {
        hostController.navigationController!.pushViewController(controller, animated: true)
    }

    public static func addLoadingToCenterOfViewController(viewController:UIViewController) -> UIActivityIndicatorView {
        let loading = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        let view = viewController.view
        view.addSubview(loading)
        loading.center = view.center
        return loading
    }

    public static func limitLengthHelper(textField textField: UITextField, maxLength:Int,
                                         shouldChangeCharactersInRange range: NSRange,
                                         replacementString string: String) -> Bool {
        return limitLengthHelper(text: textField.text, maxLength: maxLength,
                shouldChangeCharactersInRange: range, replacementString: string)
    }

    public static func limitLengthHelper(text text: String?, maxLength:Int,
                                         shouldChangeCharactersInRange range: NSRange,
                                         replacementString string: String) -> Bool {
        let currentCharacterCount = text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= maxLength
    }
}
