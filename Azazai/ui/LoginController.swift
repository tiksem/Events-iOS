//
// Created by Semyon Tikhonenko on 1/28/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import UIKit
import SwiftUtils

class LoginController : UIViewController, VKSdkDelegate, VKSdkUIDelegate {
    let PERMISSIONS:[AnyObject] = [VK_PER_OFFLINE, VK_PER_WALL]
    var onViewDidAppear:(() -> Void)?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        VKSdk.instance().registerDelegate(self)
        VKSdk.instance().uiDelegate = self
    }
    
    @IBAction func onLoginClick(sender: UIButton) {
        VKSdk.authorize(PERMISSIONS)
    }

    func onLoginSuccess() {
        let request = VKApi.users().get([
            "fields": "photo_200"
        ])
        request.executeWithResultBlock({
            (response:VKResponse!) in
            let json = (response.json as! [[String:AnyObject]])[0]
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.user = VkUser(json)
            self.showEvents()
        }, errorBlock: {
            Alerts.showOkAlert($0.description)
        })
    }

    func showEvents() {
        performSegueWithIdentifier("ShowEvents", sender: self)
    }

    func vkSdkAccessAuthorizationFinishedWithResult(_ result: VKAuthorizationResult!) {
        onViewDidAppear = {
            if let error = result.error {
                Alerts.showOkAlert(error.description)
            } else {
                self.onLoginSuccess()
            }
        }
    }

    func vkSdkUserAuthorizationFailed() {
    }

    func vkSdkShouldPresentViewController(_ controller: UIViewController!) {
        presentViewController(controller, animated: true, completion: nil)
    }

    func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
        print("vkSdkNeedCaptchaEnter")
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        onViewDidAppear?()
        onViewDidAppear = nil
    }

    deinit {
        VKSdk.instance().unregisterDelegate(self)
    }
}
