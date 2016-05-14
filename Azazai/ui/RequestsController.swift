//
//  RequestsController.swift
//  Azazai
//
//  Created by Semyon Tikhonenko on 4/18/16.
//  Copyright © 2016 Semyon Tikhonenko. All rights reserved.
//

import Foundation
import UIKit
import SwiftUtils

private let fontSize:CGFloat = 13

private class RequestsAdapterDelegate : AdapterDelegateDefaultImpl<Request, RequestCell, LoadingView> {
    private let itemProvider:(Int) -> Request
    private let removeItem:(Int)->Void
    private let requestManager = RequestManager()
    private let controller:UIViewController
    
    init(controller:UIViewController, itemProvider:(Int) -> Request, removeItem:(Int) -> Void) {
        self.itemProvider = itemProvider
        self.removeItem = removeItem
        self.controller = controller
        super.init()
    }
    
    override func displayItem(element request: Request, cell: RequestCell, position:Int) -> Void {
        if let user = request.user {
            cell.avatar.setImageFromURL(user.photo_200)
            
            let message:NSMutableAttributedString = NSMutableAttributedString()
            let nameAttrs = [
                NSFontAttributeName:UIFont.boldSystemFontOfSize(fontSize),
                NSForegroundColorAttributeName: cell.tintColor,
            ]
            message.appendAttributedString(NSAttributedString(string: user.first_name + " " + user.last_name, attributes: nameAttrs))
            let textAttrs = [NSForegroundColorAttributeName: UIColor.darkGrayColor()]
            message.appendAttributedString(NSAttributedString(string: " wants to participate in ", attributes: textAttrs))
            let eventAttrs = [
                NSFontAttributeName:UIFont.boldSystemFontOfSize(fontSize),
                NSForegroundColorAttributeName: UIColor.darkGrayColor(),
            ]
            message.appendAttributedString(NSAttributedString(string: request.event.name, attributes: eventAttrs))
            
            UiUtils.setupMultiLineForLabel(cell.message, attributedText: message)
            cell.decline.tag = position
            cell.accept.tag = position
            cell.decline.addTarget(self, action: #selector(RequestsAdapterDelegate.onDecline(_:)),
                                   forControlEvents: .TouchUpInside)
            cell.accept.addTarget(self, action: #selector(RequestsAdapterDelegate.onAccept(_:)),
                                  forControlEvents: .TouchUpInside)
        }
    }
    
    override func onItemSelected(element element: Request, position: Int) -> Void {
        if let user = element.user {
            SocialUtils.openVkProfile(String(user.id))
        }
    }
    
    func complete(error:IOError?, position:Int) {
        if error != nil {
            Alerts.showOkAlert(error!.description)
        } else {
            removeItem(position)
        }
    }
    
    func decline(request:Request, position:Int) {
        requestManager.denyRequest(request.event.id, userId: request.user!.id, token: VKSdk.accessToken().accessToken, complete: {
            self.complete($0, position: position)
        })
    }
    
    @objc func onDecline(sender:UIButton) {
        Alerts.showSlidingFromBottomOneActionAlert(controller, actionName: "Decline", cancelActionName: "Cancel", onAccept: {
            let position = sender.tag
            let request = self.itemProvider(position)
            self.decline(request, position: position)
        })
    }
    
    @objc func onAccept(sender:UIButton) {
        let position = sender.tag
        let request = itemProvider(position)
        requestManager.acceptRequest(request.event.id, userId: request.user!.id, token: VKSdk.accessToken().accessToken, complete: {
            self.complete($0, position: position)
        })
    }
}

private class EventRequestsAdapterDelegate : AdapterDelegateDefaultImpl<VkUser, RequestCell, LoadingView> {
    private let event:Event
    private var delegate:RequestsAdapterDelegate! = nil;
    private let list:LazyList<VkUser,IOError>
    
    func requestFromUser(user:VkUser) -> Request {
        var request = Request(userId: user.id, event: event)
        request.user = user
        return request
    }
    
    init(event:Event, list:LazyList<VkUser,IOError>, controller:UIViewController, tableView:UITableView) {
        self.event = event
        self.list = list
        
        super.init()
        
        delegate = RequestsAdapterDelegate(controller: controller, itemProvider: {
            [unowned self]
            (position) in
            let user = self.list[position]!
            return self.requestFromUser(user)
        }, removeItem: {
            [unowned tableView]
            (position) in
            list.removeItemAt(position)
            tableView.reloadData()
        })
    }
    
    private override func displayItem(element user: VkUser, cell: RequestCell, position: Int) {
        delegate.displayItem(element: requestFromUser(user), cell: cell, position: position)
    }
    
    override func onItemSelected(element user: VkUser, position: Int) {
        delegate.onItemSelected(element: requestFromUser(user), position: position)
    }
}

private class RequestsAdapter : AzazaiListAdapter<RequestsAdapterDelegate> {
    init(controller:UIViewController,
         list: LazyList<Request, IOError>,
         tableView: UITableView) {
        super.init(tableView: tableView,
                   list: list,
                   cellIdentifier: "RequestCell",
                   delegate: RequestsAdapterDelegate(controller: controller, itemProvider: {list[$0]!}, removeItem: {
                        [unowned tableView]
                        (position) in
                        list.removeItemAt(position)
                        tableView.reloadData()
                   }))
    }
}

private class EventRequestsAdapter : AzazaiListAdapter<EventRequestsAdapterDelegate> {
    init(controller:UIViewController,
         list: LazyList<VkUser, IOError>,
         event: Event,
         tableView: UITableView) {
        super.init(tableView: tableView,
                   list: list,
                   cellIdentifier: "RequestCell",
                   delegate: EventRequestsAdapterDelegate(event: event, list: list, controller: controller, tableView: tableView))
    }
}

class AbstractRequestsController : UIViewController {
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.navigationItem.title = "Requests"
        UiUtils.removeNavigationButtons(self, animated: animated)
    }
}


class RequestsController : AbstractRequestsController {
    @IBOutlet weak var tableView: UITableView!
    private var requestManager:RequestManager! = nil
    private var adapter:RequestsAdapter! = nil
    
    override func viewDidLoad() {
        requestManager = RequestManager()
        let requests = requestManager.getAllRequests(Int(VKSdk.accessToken().userId)!)
        adapter = RequestsAdapter(controller: self, list: requests, tableView: tableView)
    }
}

class EventRequestsController : AbstractRequestsController {
    private var requestManager:RequestManager! = nil
    private var adapter:EventRequestsAdapter! = nil
    private let event:Event
    @IBOutlet weak var tableView: UITableView!
    
    init(event:Event) {
        self.event = event
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        requestManager = RequestManager()
        let requests = requestManager.getRequests(eventId: event.id)
        adapter = EventRequestsAdapter(controller: self, list: requests, event: event, tableView: tableView)
    }
}

