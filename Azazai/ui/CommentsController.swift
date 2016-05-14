//
// Created by Semyon Tikhonenko on 3/19/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import SwiftUtils
import UIKit

class CommentsAdapterDelegate : AdapterDelegateDefaultImpl<Comment, CommentCell, LoadingView> {
    private let requestManager = RequestManager()
    private let list:LazyList<Comment, IOError>
    private let tableView:UITableView
    private let onEditComment:(Int, Comment) -> Void
    
    init(list:LazyList<Comment, IOError>, tableView:UITableView, onEditComment:(Int, Comment) -> Void) {
        self.list = list
        self.tableView = tableView
        self.onEditComment = onEditComment
    }
    
    override func displayItem(element comment: Comment, cell: CommentCell, position:Int) -> Void {
        UiUtils.setupMultiLineForLabel(cell.message, text: comment.text)
        cell.avatar.setImageFromURL(comment.user?.photo_200)
        EventUtils.displayUserNameInLabel(cell.name, user: comment.user)
        let date = NSDate(timeIntervalSince1970: Double(comment.date))
        cell.date.text = DateUtils.getOneHourAgoDisplayDateFormat(date)
    }
    
    override func onItemSelected(element comment: Comment, position: Int) {
        let alert = UIAlertController(title: nil,
                                      message: nil,
                                      preferredStyle:.ActionSheet)
        let user = comment.user!
        
        if (user.id != AppDelegate.get().user!.id) {
            SocialUtils.openVkProfile(String(user.id))
            return
        }
        
        let view = UiUtils.getCurrentView()!
        func addAction(title:String, style: UIAlertActionStyle = .Default, handler: (() -> Void)? = nil) {
            let action = UIAlertAction(title: title, style: style, handler: {
                (action) in
                handler?()
            });
            alert.addAction(action)
        }
        
        addAction("Delete comment", style: .Destructive) {
            MBProgressHUD.showHUDAddedTo(view, animated: true)
            self.requestManager.deleteComment(comment.id, token: VKSdk.accessToken().accessToken, complete: {
                (error) in
                if error != nil {
                    Alerts.showOkAlert(error!.description)
                } else {
                    self.list.removeItemAt(position)
                    self.tableView.reloadData()
                }
                MBProgressHUD.hideHUDForView(view, animated: true)
            })
        }
        
        addAction("Edit comment") {
            self.onEditComment(position, comment)
        }
        
        addAction(user.first_name + " " + user.last_name) {
            SocialUtils.openVkProfile(String(user.id))
        }
        
        addAction("Cancel", style: .Cancel)
        
        UiUtils.getCurrentViewController()!.presentViewController(alert, animated:true, completion:nil)
    }
}

class CommentsAdapter : LoadMoreLazyListAdapter<CommentsAdapterDelegate, IOError> {
    init(controller viewController:UIViewController, commentsListView:UITableView,
         comments: LazyList<Comment, IOError>, onEditComment:(Int, Comment)->Void) {
        super.init(cellIdentifier: "CommentCell",
                   nullCellIdentifier: "Loading",
                   list: comments,
                   tableView: commentsListView,
                   delegate: CommentsAdapterDelegate(list: comments, tableView: commentsListView, onEditComment: onEditComment),
                   loadMoreCellNibFileName: "LoadMoreCommentsCell",
                   reverse: true)
    }
}

class CommentsController : UIViewController, UITextViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addCommentViewHeight: NSLayoutConstraint!
    private var requestManager:RequestManager!
    private var adapter:CommentsAdapter!
    private var eventId:Int = 0
    private var topComments:[Comment] = []
    private var initialAddCommentViewHeight:CGFloat = 0
    private var editingComment:Comment? = nil
    private var editingCommentPosition = -1

    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var addCommentView: SAMTextView!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        assertionFailure("Should not be called")
    }

    init(eventId:Int, topComments:[Comment]) {
        super.init(nibName: "CommentsController", bundle: nil)
        self.eventId = eventId
        self.topComments = topComments
    }

    func textViewDidChange(textView: UITextView) {
        var contentHeight = textView.contentSize.height
        
        if contentHeight + 10 < initialAddCommentViewHeight {
            contentHeight = initialAddCommentViewHeight - 10
        }
        
        addCommentViewHeight.constant = contentHeight + 10
        addCommentView.updateConstraintsIfNeeded()
    }
    
    func onEditComment(position:Int, comment:Comment) {
        let indexPath = NSIndexPath(forRow: adapter.getCount() - position - 1, inSection: 0)
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
        addCommentView.text = comment.text
        postButton.setTitle("SAVE", forState: .Normal)
        editingComment = comment
        editingCommentPosition = position
        addCommentView.becomeFirstResponder()
    }
    
    private func scrollBottom() {
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: adapter.getCount() - 1, inSection: 0),
                                         atScrollPosition: .Top, animated: true)
    }
    
    @IBAction func onPostClick(sender: UIButton) {
        sender.enabled = false
        if var comment = editingComment {
            requestManager.updateComment(comment.id, token: VKSdk.accessToken().accessToken, text: addCommentView.text, complete: {
                (error) in
                if error != nil {
                    Alerts.showOkAlert(error!.description)
                } else {
                    comment.text = self.addCommentView.text
                    self.adapter.list[self.editingCommentPosition] = comment
                    self.adapter.reloadData()
                    self.addCommentView.text = ""
                    self.postButton.setTitle("POST", forState: .Normal)
                    self.editingComment = nil
                }
                sender.enabled = true
            })
        } else {
            let list = adapter.list
            list.prepend(nil)
            tableView.reloadData()
            scrollBottom()
            requestManager.addComment(eventId, token: VKSdk.accessToken().accessToken, text: addCommentView.text) {
                [unowned self]
                (var comment, error) in
                if error != nil {
                    Alerts.showOkAlert(error!.description)
                    list.removeFirst()
                    self.tableView.reloadData()
                } else {
                    comment!.user = AppDelegate.get().user
                    list[0] = comment
                    list.additionalOffset+=1
                    self.addCommentView.text = ""
                    self.tableView.reloadData()
                }
                sender.enabled = true
                self.scrollBottom()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = .None

        requestManager = RequestManager()
        let comments = requestManager.getCommentsList(eventId)
        comments.addAdditionalItemsToStart(topComments)
        adapter = CommentsAdapter(controller: self,
                                  commentsListView: tableView,
                                  comments: comments,
                                  onEditComment: onEditComment)
        navigationItem.title = "Comments"
        
        addCommentView.scrollEnabled = true
        addCommentView.delegate = self
        addCommentView.placeholder = "Add comment..."
        initialAddCommentViewHeight = addCommentViewHeight.constant
        textViewDidChange(addCommentView)
        addCommentView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0)
    }
}
