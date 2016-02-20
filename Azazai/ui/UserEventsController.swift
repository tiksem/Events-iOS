//
// Created by Semyon Tikhonenko on 2/17/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import SwiftUtils

class UserEventsController: EventsController {
    var minusHeight:CGFloat = 0

    public override func getNestedViewFrame() -> CGRect {
        let statusBarHeight = UiUtils.STATUS_BAR_HEIGHT

        return CGRect(x: 0, y: 0,
                width: view.frame.width,
                height: view.frame.height - minusHeight - statusBarHeight)
    }
}

class CreatedEventsController: UserEventsController {
    override func getEventsList() -> LazyList<Event, IOError> {
        return requestManager.getUserEvents(.Created, token: VKSdk.accessToken().accessToken)
    }
}

class SubscribedEventsController: UserEventsController {
    override func getEventsList() -> LazyList<Event, IOError> {
        return requestManager.getUserEvents(.Subscribed, token: VKSdk.accessToken().accessToken)
    }
}

private let menuHeight: CGFloat = 34.0
private let selectionIndicatorHeight: CGFloat = 3.0

private let myEventsControllerTabsParameters: [CAPSPageMenuOption] = [
        .ScrollMenuBackgroundColor(UIColor(red: 30.0/255.0, green: 30.0/255.0, blue: 30.0/255.0, alpha: 1.0)),
        .ViewBackgroundColor(UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 1.0)),
        .SelectionIndicatorColor(UIColor.orangeColor()),
        .BottomMenuHairlineColor(UIColor(red: 70.0/255.0, green: 70.0/255.0, blue: 80.0/255.0, alpha: 1.0)),
        .MenuItemFont(UIFont(name: "HelveticaNeue", size: 13.0)!),
        .CenterMenuItems(true),
        .MenuItemSeparatorWidth(4.3),
        .MenuHeight(menuHeight),
        .SelectionIndicatorHeight(selectionIndicatorHeight),
        .UseMenuLikeSegmentedControl(true),
        .MenuItemSeparatorPercentageHeight(0.0)]


class MyEventsController: UIViewController {
    var coder:NSCoder

    required init?(coder: NSCoder) {
        self.coder = coder
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        var controllerArray : [UIViewController] = []

        // Create variables for all view controllers you want to put in the
        // page menu, initialize them, and add each to the controller array.
        // (Can be any UIViewController subclass)
        // Make sure the title property of all view controllers is set
        // Example:
        var controller : UserEventsController = SubscribedEventsController(coder: coder)!
        controller.title = "SUBSCRIBED"
        let minusHeight = UiUtils.getNavigationBarHeightOfCotroller(self) +
                UiUtils.getTabBarHeightOfController(self)
        controller.minusHeight = minusHeight
        controllerArray.append(controller)
        controller = CreatedEventsController(coder: coder)!
        controller.title = "CREATED"
        controller.minusHeight = minusHeight
        controllerArray.append(controller)

        // Initialize page menu with controller array, frame, and optional parameters
        var pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRectMake(0.0,
                (navigationController?.navigationBar.frame.height ?? 0.0) + UiUtils.STATUS_BAR_HEIGHT,
                self.view.frame.width,
                self.view.frame.height), pageMenuOptions: myEventsControllerTabsParameters)

        // Lastly add page menu as subview of base view controller view
        // or use pageMenu controller in you view hierachy as desired
        self.addChildViewController(pageMenu)
        self.view.addSubview(pageMenu.view)

        pageMenu.didMoveToParentViewController(self)
    }

}
