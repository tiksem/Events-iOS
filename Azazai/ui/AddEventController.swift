//
// Created by Semyon Tikhonenko on 2/25/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import UIKit
import Eureka
import SwiftUtils

private let DefaultEventIcon = "event_icon.png"
private let IconBaseUrl = "http://azazai.com/icon/"

private class IconPickerAdapterDelegate : AdapterDelegateDefaultImpl<IconInfo, IconCell, LoadingView> {
    let onItemSelected:(Int) -> Void

    init(onItemSelected:(Int) -> Void) {
        self.onItemSelected = onItemSelected
    }

    override func displayItem(element icon: IconInfo, cell: IconCell) -> Void {
        if let url = NSURL(string: IconBaseUrl + String(icon.mediaId)) {
            cell.icon.sd_setImageWithURL(url)
        }
        cell.label.text = icon.tag
    }

    override func onItemSelected(element element: IconInfo, position: Int) -> Void {
        onItemSelected(position)
    }

}

private class IconPickerAdapter : AzazaiListAdapter<IconPickerAdapterDelegate> {
    init(icons: LazyList<IconInfo, IOError>,
                  tableView: UITableView, onItemSelected:(Int) -> Void) {
        super.init(tableView: tableView,
                list: icons,
                cellIdentifier: "IconPickerCell",
                delegate: IconPickerAdapterDelegate(onItemSelected: onItemSelected))
    }

}

private class IconPickerController : UIViewController, TypedRowControllerType {
    @IBOutlet weak var tableView: UITableView!

    var row: RowOf<UIImage>!
    var completionCallback : ((UIViewController) -> ())?
    var requestManager:RequestManager!
    var adapter:IconPickerAdapter! = nil

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
        adapter = IconPickerAdapter(icons: requestManager.getIcons(), tableView: tableView, onItemSelected: {
            let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: $0, inSection: 0)) as! IconCell
            self.row.value = cell.icon.image
            self.completionCallback?(self)
        })
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

private var values:[String: Any?]?

private let EventNameMinLength = 5
private let EventDescriptionMinLength = 5
private let EventAddressMinLength = 5

private let EventNameMaxLength = 50
private let EventDescriptionMaxLength = 500
private let EventAddressMaxLength = 200

class AddEventController : FormViewController {
    private var name:TextFloatLabelRow!
    private var address:TextFloatLabelRow!
    private var icon:IconPickerRow!
    private var date:DateTimeInlineRow!
    private var peopleNumber:IntRow!
    private var eventType:AlertRow<String>!
    private var eventDescription:TextAreaRow!

    func animateErrorCell(cell: UITableViewCell) {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "position.x"
        animation.values =  [0, 20, -20, 10, 0]
        animation.keyTimes = [0, (1 / 6.0), (3 / 6.0), (5 / 6.0), 1]
        animation.duration = 0.3
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.additive = true
        cell.layer.addAnimation(animation, forKey: "shake")
    }

    func onValidateCellError(message:String, cell: UITableViewCell) {

    }

    func validateStringFieldOfRow(row:RowOf<String>, fieldTitle:String,
                                  minCount:Int, var addTo:[String:CustomStringConvertible]) throws {
        if row.value == nil {
            onValidateCellError("\(fieldTitle) can't be blank", cell: name.cell)
        } else {
            let value = row.value!
            let count = value.characters.count
            if count < minCount {
                onValidateCellError("\(fieldTitle) should contain at least \(count) characters", cell: name.cell)
            } else {
                addTo[row.tag!] = StringWrapper(value)
                return
            }
        }

        throw Errors.Void
    }

    func validateReturnQueryArgsIfSuccess() -> [String:CustomStringConvertible]? {
        var result:[String:CustomStringConvertible] = [:]
        do {
            try validateStringFieldOfRow(name, fieldTitle: "Event name", minCount: EventNameMinLength, addTo: result)
            try validateStringFieldOfRow(eventDescription, fieldTitle: "Event description",
                    minCount: EventDescriptionMinLength, addTo: result)
            try validateStringFieldOfRow(address, fieldTitle: "Event address",
                    minCount: EventAddressMinLength, addTo: result)

        } catch {
            return nil
        }

        return result
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        var section = Section("Create New Event")
        form +++ section

        name = TextFloatLabelRow("name") {
            $0.title = "Event Name"
            $0.cell.maxLength = EventNameMaxLength
        }
        section <<< name

        address = TextFloatLabelRow("addresss") {
            $0.title = "Event Address"
            $0.cell.maxLength = EventAddressMaxLength
        }
        section <<< address

        icon = IconPickerRow("icon") {
            $0.title = "Event Icon"
            $0.value = UIImage(named: DefaultEventIcon)
        }
        section <<< icon

        date = DateTimeInlineRow("date") {
            $0.title = "Event Date"
            $0.minimumDate = NSDate()
        }
        section <<< date

        peopleNumber = IntRow("peopleNumber") {
            $0.title = "People Number"
            $0.placeholder = "Unlimited"
        }
        section <<< peopleNumber

        eventType = AlertRow<String>("type") {
            $0.title = "Event Type"
            $0.options = ["Public", "Private"]
            $0.value = "Public"
        }
        section <<< eventType

        section = Section("Event Description")
        form +++ section
        eventDescription = TextAreaRow("description") {
            $0.cell.height = {140}
        }
        section <<< eventDescription

        if let values = values {
            form.setValues(values)
        }
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        values = form.values()
    }

    override func textInput<T>(textInput: UITextInput, shouldChangeCharactersInRange
            range: NSRange, replacementString string: String, cell: Eureka.Cell<T>) -> Bool {
        if cell === eventDescription.cell {
            return UiUtils.limitLengthHelper(text: eventDescription.cell.textView.text,
                    maxLength:EventDescriptionMaxLength,
                    shouldChangeCharactersInRange: range, replacementString: string)
        }

        return true
    }

}
