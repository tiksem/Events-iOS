//
// Created by Semyon Tikhonenko on 2/2/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import SwiftUtils
import UIKit

class EventController : UIViewController {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var peopleNumber: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var subscribeButton: UIButton!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var address: UILabel!
    
    private var event:Event! = nil
    private var requestManager:RequestManager! = nil

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    init(event:Event) {
        super.init(nibName: "EventController", bundle: nil)
        self.event = event
        requestManager = RequestManager()
    }

    func setupSubscribeButton() {
        UiUtils.setBackgroundAndTitleColorOfButton(subscribeButton, forState: .Selected,
                titleColor: UIColor.whiteColor(), backgroundColor: UIColor.brownColor())
        UiUtils.setBackgroundAndTitleColorOfButton(subscribeButton, forState: .Selected,
                titleColor: UIColor.whiteColor(), backgroundColor: self.view.tintColor)
        UiUtils.setBackgroundAndTitleColorOfButton(subscribeButton, forState: .Disabled,
                titleColor: UIColor.whiteColor(), backgroundColor: UIColor.lightGrayColor())

        subscribeButton.enabled = false
        subscribeButton.setTitle("Loading...", forState: .Disabled)
        requestManager.isSubscribed(event.id, userId: AppDelegate.get().user.id) {
            [unowned self]
            (status, err) in
            if let err = err {
                Alerts.showOkAlert(err.description)
            } else {
                self.subscribeButton.enabled = true
                self.subscribeButton.selected = status != .none
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        UiUtils.setupMultiLineForLabel(eventDescription, text: event.description)
        EventUtils.displayPeopleNumberInLabel(peopleNumber, event: event)
        name.text = event.name
        EventUtils.displayIcon(event.icon, imageView: icon)
        address.text! += " \(event.address)"
        let date = NSDate(timeIntervalSince1970: Double(event.date))
        eventDate.text! += " \(date)"
        setupSubscribeButton()
    }

    @IBAction func onSubscribeButtonClick(sender: AnyObject) {
        let lastSelected = subscribeButton.selected
        subscribeButton.selected = false
        subscribeButton.enabled = false
        requestManager.subscribe(event.id, token: VKSdk.accessToken().accessToken) {
            [unowned self]
            (err) in
            self.subscribeButton.enabled = true
            self.subscribeButton.selected = lastSelected
            if let err = err {
                Alerts.showOkAlert(err.description)
            } else {
                self.subscribeButton.selected = !self.subscribeButton.selected
            }
        }
    }
}
