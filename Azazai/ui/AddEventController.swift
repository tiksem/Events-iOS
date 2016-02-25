//
// Created by Semyon Tikhonenko on 2/25/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import Eureka
import UIKit

class IconPickerController : UIViewController, TypedRowControllerType {
    public var row: RowOf<UIImage>!
    public var completionCallback : ((UIViewController) -> ())?

    override required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = .None;
    }
}

class IconPickerRow : SelectorRow<UIImage, IconPickerController, PushSelectorCell<UIImage>> {
    public required init(tag: String?) {
        super.init(tag: tag)
        presentationMode = .Show(controllerProvider: ControllerProvider.NibFile(name: "IconPicker", bundle: nil),
                completionCallback: {
            vc in vc.navigationController?.popViewControllerAnimated(true)
        })

        displayValueFor = {
            image in return ""
        }
    }

    public override func customUpdateCell() {
        super.customUpdateCell()
        cell.accessoryType = .None
        if let image = UIImage(named: "empty-avatar.jpg") {
            let imageView = UIImageView(frame: CGRectMake(0, 0, 44, 44))
            imageView.contentMode = .ScaleAspectFill
            imageView.image = image
            imageView.clipsToBounds = true
            cell.accessoryView = imageView
        }
        else{
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
            $0.title = "ImageRow"
            $0.value = UIImage(named: "empty-avatar.jpg")
        }
    }
}
