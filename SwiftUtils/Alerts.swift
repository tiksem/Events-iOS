//
// Created by Semyon Tikhonenko on 12/25/15.
// Copyright (c) 2015 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import UIKit

public struct Alerts {
    public static func showOkAlert(message:String? = nil, title:String? = nil, okButtonText:String = "OK") {
        let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: okButtonText)
        alert.show()
    }

    public static func showSlidingFromBottomOneActionAlert(controller:UIViewController, title:String? = nil,
                                                  message:String? = nil, actionName:String,
                                                           actionStyle:UIAlertActionStyle = .Destructive,
                                                           cancelActionName:String = "Cancel",
                                                           onAccept:()->Void) {
        let deleteAlert = UIAlertController(title: title,
        message: message,
        preferredStyle:.ActionSheet)

        let action = UIAlertAction(title: actionName, style: actionStyle,
        handler: {
            (action) in
            onAccept()
        });

        let cancelAction = UIAlertAction(title: cancelActionName, style:.Cancel,
                handler: {
                    (action) in
                    //Code to unfollow
                });

        deleteAlert.addAction(action)
        deleteAlert.addAction(cancelAction)
        controller.presentViewController(deleteAlert, animated:true, completion:nil)
    }
}
