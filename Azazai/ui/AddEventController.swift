//
// Created by Semyon Tikhonenko on 2/25/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import Eureka
import UIKit
import SwiftUtils

private let DefaultEventIcon = "event_icon.png"
private let IconBaseUrl = "http://azazai.com/icon/"

private class IconPickerAdapterDelegate : AdapterDelegateDefaultImpl<IconInfo, IconCell, LoadingView> {
    override func displayItem(element icon: IconInfo, cell: IconCell) -> Void {
        if let url = NSURL(string: IconBaseUrl + String(icon.mediaId)) {
            cell.icon.sd_setImageWithURL(url)
        }
        cell.label.text = icon.tag
    }
}

private class IconPickerAdapter : AzazaiListAdapter<IconPickerAdapterDelegate> {
    init(icons: LazyList<IconInfo, IOError>,
                  tableView: UITableView) {
        super.init(tableView: tableView,
                list: icons,
                cellIdentifier: "IconPickerCell",
                delegate: IconPickerAdapterDelegate())
    }

}

private class IconPickerController : UIViewController, TypedRowControllerType {
    @IBOutlet weak var tableView: UITableView!
    
    var row: RowOf<UIImage>!
    var completionCallback : ((UIViewController) -> ())?
    var requestManager:RequestManager!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = .None

        requestManager = RequestManager()
        IconPickerAdapter(icons: requestManager.getIcons(), tableView: tableView)
    }
}

private class IconPickerRow : SelectorRow<UIImage, IconPickerController, PushSelectorCell<UIImage>> {
    required init(tag: String?) {
        super.init(tag: tag)
        presentationMode = .Show(controllerProvider: ControllerProvider.NibFile(name: "IconPicker", bundle: nil),
                completionCallback: {
            vc in vc.navigationController?.popViewControllerAnimated(true)
        })

        displayValueFor = {
            image in return ""
        }
    }

    override func customUpdateCell() {
        super.customUpdateCell()
        cell.accessoryType = .None
        cell.height = { 55 }
        if let image = self.value {
            let imageView = UIImageView(frame: CGRectMake(0, 0, 44, 44))
            imageView.contentMode = .ScaleAspectFill
            imageView.image = image
            imageView.clipsToBounds = true
            cell.accessoryView = imageView
        } else {
            cell.accessoryView = nil
        }
    }
}

class AddEventController : FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("Create New Event")
                <<< TextFloatLabelRow() {
            $0.title = "Event Name"
        } <<< IconPickerRow("tag1") {
            $0.title = "Event Icon"
            $0.value = UIImage(named: DefaultEventIcon)
        }
    }
}
