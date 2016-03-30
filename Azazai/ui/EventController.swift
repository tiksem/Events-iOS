//
// Created by Semyon Tikhonenko on 2/2/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import SwiftUtils
import UIKit

private class TopCommentsAdapterDelegate : AdapterDelegateDefaultImpl<Comment, TopCommentCell, LoadingView> {
    override func displayItem(element comment: Comment, cell: TopCommentCell) -> Void {
        EventUtils.displayUserNameInLabel(cell.name, user: comment.user)
        cell.message.text = comment.text
        UiUtils.removeSeparator(cell)
    }
}

private class TopCommentsAdapter : ArrayAdapter<TopCommentsAdapterDelegate> {
    init(array:[Comment], tableView:UITableView) {
        super.init(cellIdentifier: "TopCommentCell", array: array, tableView: tableView,
                delegate: TopCommentsAdapterDelegate(), dynamicHeight: false)
    }
}

private let MaxTopComments = 3

class EventController : UIViewController {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var peopleNumber: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var subscribeButton: UIButton!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var organizerName: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var comments: UITableView!
    @IBOutlet weak var membersLabel: UILabel!
    
    private var event:Event! = nil
    private var requestManager:RequestManager! = nil
    private var topCommentsAdapter:TopCommentsAdapter!
    private var isMine = false
    private var subscribeStatus:SubscribeStatus = .none

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

        isMine = event.userId == Int(VKSdk.accessToken().userId)
        let normalTitle = isMine ? "Cancel" : "I Will Go"
        subscribeButton.setTitle(normalTitle, forState: .Normal)
        subscribeButton.setTitle("Loading...", forState: .Disabled)

        if !isMine {
            subscribeButton.enabled = false
            requestManager.isSubscribed(event.id, userId: AppDelegate.get().user.id) {
                [unowned self]
                (status, err) in
                if let err = err {
                    Alerts.showOkAlert(err.description)
                } else {
                    self.subscribeButton.enabled = true
                    self.subscribeButton.selected = status != .none
                    self.subscribeStatus = status!
                }
            }
        }
    }

    func setupOrganizer() {
        organizerName.text = "Loading..."
        requestManager.getUserById(event.userId, success: {
            (user) in
            EventUtils.displayUserNameInLabel(self.organizerName, user: user)
            if let url = NSURL(string: user.photo_200) {
                self.avatar.sd_setImageWithURL(url)
            }
        }, error: {
            (err) in
            self.organizerName.text = "No Internet Connection"
        })
    }

    func setupComments() {
        comments.scrollEnabled = false
        comments.allowsSelection = false
        comments.tableFooterView = UIView()
        requestManager.getTopComments(event.id, maxCount: MaxTopComments, complete: {
            [unowned self]
            (comments, error) in
            if let err = error {
                Alerts.showOkAlert(err.description)
            } else {
                self.requestManager.fillCommentsUsers(comments!, onFinish: {
                    [unowned self]
                    (comments, error) in
                    if let comments = comments {
                        self.topCommentsAdapter = TopCommentsAdapter(array: comments, tableView: self.comments)
                    } else {
                        Alerts.showOkAlert(error!.description)
                    }
                })
            }
        })

        let tap = UITapGestureRecognizer(target:self, action:#selector(EventController.onCommentsTap(_:)))
        comments.addGestureRecognizer(tap)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        UiUtils.setupMultiLineForLabel(eventDescription, text: event.description)
        EventUtils.displayPeopleNumberInLabel(peopleNumber, event: event)
        name.text = event.name
        EventUtils.displayIcon(event.icon, imageView: icon)
        address.text = " \(event.address)"
        let date = EventUtils.eventDateToString(event.date)
        eventDate.text = "\(date)"
        setupSubscribeButton()
        setupOrganizer()
        setupComments()
        let subView = view.subviews[0].subviews[0]
        subView.changeHeightConstraintToFitSubViews()
        (view.subviews[0] as! UIScrollView).contentSize = subView.frame.size

        EventUtils.setupOpenProfile(self, avatar: avatar, name: organizerName)
        
        UiUtils.setTapListenerForViews([membersLabel, peopleNumber], target:self, action:"showMembers:")
    }

    func showMembers(_:UIGestureRecognizer) {
        Alerts.showOkAlert()
    }
    
    private func onSubscribeCancelAccept() {
        let lastSelected = subscribeButton.selected
        subscribeButton.selected = false
        subscribeButton.enabled = false

        if isMine {
            requestManager.cancelEvent(event.id, token: VKSdk.accessToken().accessToken) {
                [unowned self]
                (err) in
                let eventsControler = UiUtils.getBackViewControllerFromTabBarIfTabBarExists(self) as! EventsController
                eventsControler.updateEvents()
                self.navigationController!.popViewControllerAnimated(true)
            }
        } else {
            requestManager.subscribe(event.id, token: VKSdk.accessToken().accessToken) {
                [unowned self]
                (err) in
                self.subscribeButton.enabled = true
                self.subscribeButton.selected = lastSelected
                if let err = err {
                    Alerts.showOkAlert(err.description)
                } else {
                    self.subscribeButton.selected = !self.subscribeButton.selected
                    if self.subscribeStatus == .none {
                        self.subscribeStatus = .subscribed
                    } else {
                        self.subscribeStatus = .none
                    }
                }
            }
        }
    }

    @IBAction func onSubscribeButtonClick(sender: AnyObject) {
        if !isMine && subscribeStatus == .none {
            onSubscribeCancelAccept()
            return
        }

        let cancelActionName = isMine ? "No" : "Cancel"
        let actionName = isMine ? "Yes, cancel it" : "Unsubscribe"
        let title = isMine ? "Cancel event \(event.name)?" : "Unsubscrive from \(event.name)?"
        Alerts.showSlidingFromBottomOneActionAlert(self, title: title,
                actionName: actionName, cancelActionName: cancelActionName, onAccept: onSubscribeCancelAccept)
    }

    func onCommentsTap(recognizer:UIGestureRecognizer) {
        navigationController!.pushViewController(CommentsController(eventId: event.id,
                topComments: topCommentsAdapter.list.array), animated: true)
    }

    func openVkProfile(recognizer:UIGestureRecognizer) {
        SocialUtils.openVkProfile(VKSdk.accessToken().userId)
    }
}
