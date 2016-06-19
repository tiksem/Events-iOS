//
// Created by Semyon Tikhonenko on 2/1/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import UIKit

public class UiUtils {
    public static let STATUS_BAR_HEIGHT: CGFloat = 20.0
    public static let TABLE_SEPARATOR_COLOR = UIColor(red: 0.783922, green: 0.780392, blue: 0.8, alpha: 1.0)

    public static func removeSeparator(cell: UITableViewCell) {
        cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width + 999999, 0, 0);
    }

    public static func viewFromNib(fileName: String) -> UIView {
        return NSBundle.mainBundle().loadNibNamed(fileName,
                owner: nil, options: nil)[0] as! UIView
    }

    public static func registerNib(tableView tableView: UITableView, nibName: String, cellIdentifier: String) {
        let nib = UINib(nibName: nibName, bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: cellIdentifier)
    }

    public static func getTabBarHeightOfController(controller: UIViewController) -> CGFloat {
        return controller.tabBarController?.tabBar.frame.height ?? 0
    }

    public static func getNavigationBarHeightOfCotroller(controller: UIViewController) -> CGFloat {
        return controller.navigationController?.navigationBar.frame.height ?? 0.0
    }

    public static func addNavigationBarButtonOfTopController(viewController: UIViewController, left: Bool = false,
                                                             action: Selector,
                                                             barButtonSystemItem: UIBarButtonSystemItem)
                    -> UIViewController {
        let addButton = UIBarButtonItem(barButtonSystemItem: barButtonSystemItem, target: viewController,
                action: action)

        let topViewController = viewController.navigationController!.topViewController!
        if left {
            topViewController.navigationItem.setLeftBarButtonItem(addButton, animated: false)
        } else {
            topViewController.navigationItem.setRightBarButtonItem(addButton, animated: false)
        }
        return topViewController
    }

    public static func addAddButtonToTheRightOfNavigationBarOfTopController(viewController: UIViewController,
                                                                            action: Selector) -> UIViewController {
        return addNavigationBarButtonOfTopController(viewController,
                action: action, barButtonSystemItem: .Add)
    }

    public static func removeNavigationButtons(viewController:UIViewController, animated:Bool) {
        let navigationItem = viewController.navigationController!.topViewController!.navigationItem
        navigationItem.setLeftBarButtonItem(nil, animated: animated)
        navigationItem.setRightBarButtonItem(nil, animated: animated)
    }
    
    public static func removeLeftNavigationButton(viewController:UIViewController, animated:Bool) {
        let navigationItem = viewController.navigationController!.topViewController!.navigationItem
        navigationItem.setLeftBarButtonItem(nil, animated: animated)
    }
    
    public static func setupCancelDoneButtonsOfNavigationBar(target:UIViewController, doneAction:String,
                                                             cancelAction:String) {
        let topController = addNavigationBarButtonOfTopController(target,
                action: Selector(doneAction), barButtonSystemItem: .Done)
        topController.navigationItem.setHidesBackButton(true, animated: false)

        addNavigationBarButtonOfTopController(target, left: true,
                action: Selector(cancelAction), barButtonSystemItem: .Cancel)
    }

    public static func pushViewController(hostController: UIViewController, controller: UIViewController) {
        hostController.navigationController!.pushViewController(controller, animated: true)
    }

    public static func addLoadingToCenterOfViewController(viewController: UIViewController) -> UIActivityIndicatorView {
        let loading = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        let view = viewController.view
        view.addSubview(loading)
        loading.center = view.center
        return loading
    }

    public static func showIndicatorWhileLoadingViewDataReturnOnDataLoaded(view: UIView) -> ()->Void {
        let parent = view.superview!
        let loading = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
//        let viewFrame = view.frame
//        let viewSize = viewFrame.size
//        let viewOrigin = viewFrame.origin
//        let loadingSize = loading.frame.size
//        loading.frame = CGRect(x: viewOrigin.x + (viewSize.width - loadingSize.width) / 2,
//                y: viewOrigin.y + (viewSize.height - loadingSize.height) / 2,
//                width: loadingSize.width, height: loadingSize.height)
        loading.center = view.center
        parent.addSubview(loading)
        view.hidden = true
        loading.startAnimating()

        return {
            loading.removeFromSuperview()
            view.hidden = false
        }
    }

    public static func limitLengthHelper(textField textField: UITextField, maxLength: Int,
                                         shouldChangeCharactersInRange range: NSRange,
                                         replacementString string: String) -> Bool {
        return limitLengthHelper(text: textField.text, maxLength: maxLength,
                shouldChangeCharactersInRange: range, replacementString: string)
    }

    public static func limitLengthHelper(text text: String?, maxLength: Int,
                                         shouldChangeCharactersInRange range: NSRange,
                                         replacementString string: String) -> Bool {
        let currentCharacterCount = text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount) {
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= maxLength
    }

    public static func getBackViewController(controller:UIViewController) -> UIViewController? {
        let navigationController = controller.navigationController
        let numberOfViewControllers = navigationController?.viewControllers.count ?? 0
        if numberOfViewControllers < 2 {
            return nil
        } else {
            return navigationController!.viewControllers[numberOfViewControllers - 2]
        }
    }

    public static func getBackViewControllerFromTabBarIfTabBarExists(controller:UIViewController) -> UIViewController {
        let backController = getBackViewController(controller)!
        if let backController = (backController as? UITabBarController)?.selectedViewController {
            return backController
        }

       return backController
    }

    public static func setupMultiLineForLabel(label:UILabel, text:String) {
        label.lineBreakMode = .ByWordWrapping
        label.numberOfLines = 0
        label.text = text
        label.sizeToFit()
    }

    public static func setupMultiLineForLabel(label:UILabel, attributedText:NSAttributedString) {
        label.lineBreakMode = .ByWordWrapping
        label.numberOfLines = 0
        label.attributedText = attributedText
        label.sizeToFit()
    }
    
    public static func setBackgroundAndTitleColorOfButton(button: UIButton,
                                                         forState: UIControlState,
                                                         titleColor: UIColor,
                                                         backgroundColor:UIColor) {
        button.setTitleColor(titleColor, forState: forState)
        button.setBackgroundImage(UIImage.fromColor(backgroundColor), forState: forState)
    }

    public static func centerVerticaly(view:UIView) {
        let superFrame = view.superview!.frame
        view.frame.origin.y = (superFrame.height - view.frame.height) / 2
    }

    public static func calculateCellHeight(cell:UITableViewCell) -> CGFloat {
        cell.layoutIfNeeded()

        let size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        return size.height
    }

    public static func registerNotificationWithName(name:String, selector:Selector, target:NSObject) {
        let note = NSNotificationCenter.defaultCenter()
        note.addObserver(target, selector:selector, name:name, object:nil)
    }

    public static func postNotificationWithName(name:String, object:NSObject? = nil) {
        let note = NSNotificationCenter.defaultCenter()
        note.postNotificationName(name, object:object)
    }

    public static func getHeightConstraintOfView(view:UIView) -> NSLayoutConstraint? {
        var heightConstraint:NSLayoutConstraint?
        for constraint in view.constraints {
            if constraint.firstAttribute == NSLayoutAttribute.Height {
                heightConstraint = constraint
                break;
            }
        }
        return heightConstraint
    }

    public static func getAllSubViewsRecursive(view:UIView) -> [UIView] {
        var result:[UIView] = []
        func produce(root:UIView) {
            for subview in root.subviews {
                result.append(subview)
                produce(subview)
            }
        }
        produce(view)
        return result
    }
    
    public static func setTapListenerForViews(views:[UIView], target:NSObject, action:String) {
        let tapFactory = {UITapGestureRecognizer(target:target, action:Selector(action))}
        for view in views {
            view.userInteractionEnabled = true
            view.addGestureRecognizer(tapFactory())
        }
    }
    
    public static func showLoadingInCenterOfView(view:UIView) {
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityView.center = view.center
        activityView.startAnimating()
        view.addSubview(activityView)
    }
    
    public static func getCurrentView() -> UIView? {
        return getCurrentViewController()?.view
    }
    
    public static  func getCurrentViewController() -> UIViewController? {
        
        // If the root view is a navigation controller, we can just return the visible ViewController
        if let navigationController = getNavigationController() {
            
            return navigationController.visibleViewController
        }
        
        // Otherwise, we must get the root UIViewController and iterate through presented views
        if let rootController = UIApplication.sharedApplication().keyWindow?.rootViewController {
            
            var currentController: UIViewController! = rootController
            
            // Each ViewController keeps track of the view it has presented, so we
            // can move from the head to the tail, which will always be the current view
            while( currentController.presentedViewController != nil ) {
                
                currentController = currentController.presentedViewController
            }
            return currentController
        }
        
        return nil
    }
    
    public static func getNavigationController() -> UINavigationController? {
        if let navigationController = UIApplication.sharedApplication().keyWindow?.rootViewController  {
            return navigationController as? UINavigationController
        }
        return nil
    }
}

public extension UIView {
    func changeHeightConstraintToFitSubViews() {
        var h:CGFloat = 0

        for v in subviews {
            let fh = v.frame.origin.y + v.frame.size.height
            h = max(fh, h)
        }

        UiUtils.getHeightConstraintOfView(self)!.constant = h
    }
}

public extension UITableView {
    func scrollToBottom() {
        var yOffset:CGFloat = 0

        if self.contentSize.height > self.bounds.size.height {
            yOffset = self.contentSize.height - self.bounds.size.height
        }

        self.setContentOffset(CGPointMake(0, yOffset), animated:false)
    }
}

//public extension UITextView {
//    func getContentSize() -> CGSize {
//        let attributes = [NSFontAttributeName: font!]
//        (text as NSString).sizeWithAttributes(attributes)
//        CGSize textViewSize = [text sizeWithFont:[UIFont fontWithName:@"Marker Felt" size:20]
//            constrainedToSize:CGSizeMake(WIDHT_OF_VIEW, FLT_MAX)
//            lineBreakMode:UILineBreakModeTailTruncation];
//    }
//}
