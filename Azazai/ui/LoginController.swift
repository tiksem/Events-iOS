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
    var requestManager:RequestManager!

    @IBOutlet weak var loginButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        requestManager = RequestManager()
        VKSdk.instance().registerDelegate(self)
        VKSdk.instance().uiDelegate = self

        UiUtils.registerNotificationWithName("logout", selector: Selector("logout"), target: self)
    }
    
    @IBAction func onLoginClick(sender: UIButton) {
        VKSdk.authorize(PERMISSIONS)
    }

    func logout() {
//        requestManager.clearVkData()
        VkUtils.logout()
        loginButton.hidden = true
//        Network.getStringFromUrl("http://api.vkontakte.ru/oauth/logout", complete: {
//            (string, error) in
//            if let err = error {
//                Alerts.showOkAlert(err.description)
//            } else {
//                Alerts.showOkAlert(string!)
//                self.requestManager.clearVkData()
//                self.loginButton.hidden = false
//            }
//        })
//        requestManager.logoutFromVk {
//            [unowned self]
//            (error) in
//            if let err = error {
//                Alerts.showOkAlert(err.description)
//            } else {
//                self.loginButton.hidden = false
//            }
//        }
    }

    func onLoginSuccess() {
        print("onLoginSuccess")
        requestManager.getUserById(success: {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.user = $0
            self.showEvents()
        }, error: {
            Alerts.showOkAlert($0.description)
        })
    }

    func showEvents() {
        performSegueWithIdentifier("ShowEvents", sender: self)
    }

    func vkSdkAccessAuthorizationFinishedWithResult(_ result: VKAuthorizationResult!) {
        let callback = {
            if let error = result.error {
                Alerts.showOkAlert(error.description)
            } else {
                self.onLoginSuccess()
            }
        }

        if isViewLoaded() && view.window != nil {
            callback()
        } else {
            onViewDidAppear = callback
        }
    }

    func vkSdkUserAuthorizationFailed() {
        Alerts.showOkAlert("Failed")
    }

    func vkSdkShouldPresentViewController(controller: UIViewController!) {
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

    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.hidden = true
        VKSdk.wakeUpSession(PERMISSIONS) {
            [weak self]
            (state, error) in
            if let this = self {
                if state == .Authorized {
                    this.onLoginSuccess()
                } else {
                    this.loginButton.hidden = false
                }
            }
        }
    }

    deinit {
        VKSdk.instance().unregisterDelegate(self)
    }
}
