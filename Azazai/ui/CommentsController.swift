//
// Created by Semyon Tikhonenko on 3/19/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import SwiftUtils
import UIKit

class CommentsAdapterDelegate : AdapterDelegateDefaultImpl<Comment, CommentCell, LoadingView> {
    override func displayItem(element comment: Comment, cell: CommentCell, position:Int) -> Void {
        UiUtils.setupMultiLineForLabel(cell.message, text: comment.text)
        cell.avatar.setImageFromURL(comment.user?.photo_200)
        EventUtils.displayUserNameInLabel(cell.name, user: comment.user)
        let date = NSDate(timeIntervalSince1970: Double(comment.date))
        cell.date.text = DateUtils.getOneHourAgoDisplayDateFormat(date)
    }
    
    override func onItemSelected(element comment: Comment, position: Int) {
        if let user = comment.user {
            SocialUtils.openVkProfile(String(user.id))
        }
    }
}

class CommentsAdapter : AzazaiListAdapter<CommentsAdapterDelegate> {
    init(controller viewController:UIViewController, commentsListView:UITableView,
         comments: LazyList<Comment, IOError>) {
        super.init(tableView: commentsListView,
                list: comments,
                cellIdentifier: "CommentCell",
                delegate: CommentsAdapterDelegate())
    }
}

class CommentsController : UIViewController {
    @IBOutlet weak var tableView: UITableView!

    private var requestManager:RequestManager!
    private var adapter:CommentsAdapter!
    private var eventId:Int = 0
    private var topComments:[Comment] = []

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        assertionFailure("Should not be called")
    }

    init(eventId:Int, topComments:[Comment]) {
        super.init(nibName: "CommentsController", bundle: nil)
        self.eventId = eventId
        self.topComments = topComments
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = .None

        requestManager = RequestManager()
        let comments = requestManager.getCommentsList(eventId)
        comments.addAdditionalItemsToStart(topComments)
        adapter = CommentsAdapter(controller: self, commentsListView: tableView, comments: comments)
        navigationItem.title = "Comments"
    }
}
