//
//  MembersListController.swift
//  Azazai
//
//  Created by Semyon Tikhonenko on 3/29/16.
//  Copyright © 2016 Semyon Tikhonenko. All rights reserved.
//

import Foundation
import SwiftUtils

private class MembersAdapterDelegate : AdapterDelegateDefaultImpl<VkUser, MemberCell, LoadingView> {
    
    override func displayItem(element user: VkUser, cell: MemberCell, position:Int) -> Void {
        EventUtils.displayUserNameInLabel(cell.name, user: user)
        cell.avatar.setImageFromURL(user.photo_200)
    }
    
    override func onItemSelected(element user: VkUser, position: Int) -> Void {
        SocialUtils.openVkProfile(String(user.id))
    }
    
}

private class MembersAdapter : AzazaiListAdapter<MembersAdapterDelegate> {
    init(users: LazyList<VkUser, IOError>,
         tableView: UITableView) {
        super.init(tableView: tableView,
                   list: users,
                   cellIdentifier: "MemberCell",
                   delegate: MembersAdapterDelegate())
    }
    
}

class MembersListController : UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private var adapter:MembersAdapter! = nil
    private let requestManager:RequestManager
    private let eventId:Int
    
    init(eventId:Int) {
        self.eventId = eventId
        requestManager = RequestManager()
        super.init(nibName: "MembersListController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        adapter = MembersAdapter(users: requestManager.getSubscribers(eventId: eventId), tableView: tableView)
    }
}


