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

private class RequestsAdapterDelegate : AdapterDelegateDefaultImpl<Request, RequestCell, LoadingView> {
    private let list:LazyList<Request, IOError>
    private let requestManager = RequestManager()
    
    init(list:LazyList<Request, IOError>) {
        self.list = list
        super.init()
    }
    
    override func displayItem(element request: Request, cell: RequestCell, position:Int) -> Void {
        if let user = request.user {
            cell.avatar.setImageFromURL(user.photo_200)
            let message = user.first_name + " " + user.last_name + " wants to participate in " + request.event.name
            UiUtils.setupMultiLineForLabel(cell.message, text: message)
            cell.decline.tag = position
            cell.accept.tag = position
            cell.decline.addTarget(self, action: #selector(RequestsAdapterDelegate.onDecline(_:)),
                                   forControlEvents: .TouchUpInside)
            cell.accept.addTarget(self, action: #selector(RequestsAdapterDelegate.onAccept(_:)),
                                  forControlEvents: .TouchUpInside)
        }
    }
    
    override func onItemSelected(element element: Request, position: Int) -> Void {
        
    }
    
    func complete(error:IOError?) {
        if error != nil {
            Alerts.showOkAlert(error?.description)
        } else {
            
        }
    }
    
    @objc func onDecline(sender:UIButton) {
        let request = list[sender.tag]!
        requestManager.denieRequest(request.event.id, token: VKSdk.accessToken().accessToken, complete: complete)
    }
    
    @objc func onAccept(sender:UIButton) {
        
    }
}

private class RequestsAdapter : AzazaiListAdapter<RequestsAdapterDelegate> {
    init(list: LazyList<Request, IOError>,
         tableView: UITableView) {
        super.init(tableView: tableView,
                   list: list,
                   cellIdentifier: "RequestCell",
                   delegate: RequestsAdapterDelegate(list: list))
    }
}

class RequestsController : UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private var requestManager:RequestManager! = nil
    private var adapter:RequestsAdapter! = nil
    
    override func viewDidLoad() {
        requestManager = RequestManager()
        let requests = requestManager.getAllRequests(Int(VKSdk.accessToken().userId)!)
        adapter = RequestsAdapter(list: requests, tableView: tableView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.navigationItem.title = "Requests"
        UiUtils.removeNavigationButtons(self, animated: animated)
    }
}