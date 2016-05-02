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
    override func displayItem(element request: Request, cell: RequestCell) -> Void {
        if let user = request.user {
            cell.avatar.setImageFromURL(user.photo_200)
            let message = user.first_name + " " + user.last_name + " wants to participate in " + request.event.name
            UiUtils.setupMultiLineForLabel(cell.message, text: message)
        }
    }
    
    override func onItemSelected(element element: Request, position: Int) -> Void {
        
    }
}

private class RequestsAdapter : AzazaiListAdapter<RequestsAdapterDelegate> {
    init(list: LazyList<Request, IOError>,
         tableView: UITableView) {
        super.init(tableView: tableView,
                   list: list,
                   cellIdentifier: "RequestCell",
                   delegate: RequestsAdapterDelegate())
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