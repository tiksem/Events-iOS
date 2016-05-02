//
// Created by Semyon Tikhonenko on 2/25/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import UIKit
import Eureka
import SwiftUtils

private class IconPickerAdapterDelegate : AdapterDelegateDefaultImpl<IconInfo, IconCell, LoadingView> {
    let onItemSelected:(Int, IconInfo) -> Void

    init(onItemSelected:(Int, IconInfo) -> Void) {
        self.onItemSelected = onItemSelected
        super.init()
    }

    override func displayItem(element icon: IconInfo, cell: IconCell, position:Int) -> Void {
        EventUtils.displayIcon(icon.mediaId, imageView: cell.icon)
        cell.label.text = icon.tag
    }

    override func onItemSelected(element element: IconInfo, position: Int) -> Void {
        onItemSelected(position, element)
    }

}

private class IconPickerAdapter : AzazaiListAdapter<IconPickerAdapterDelegate> {
    init(icons: LazyList<IconInfo, IOError>,
                  tableView: UITableView, onItemSelected:(Int, IconInfo) -> Void) {
        super.init(tableView: tableView,
                list: icons,
                cellIdentifier: "IconPickerCell",
                delegate: IconPickerAdapterDelegate(onItemSelected: onItemSelected))
    }
}

private struct Icon : Equatable {
    init(image:UIImage?, id:Int) {
        self.image = image
        self.id = id
    }

    let image:UIImage?
    let id:Int
}

private func == (lhs: Icon, rhs: Icon) -> Bool {
    return lhs.id == rhs.id
}

private class IconPickerController : UIViewController, TypedRowControllerType {
    @IBOutlet weak var tableView: UITableView!

    var row: RowOf<Icon>!
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
            (position, iconInfo) in
            let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: position, inSection: 0)) as! IconCell
            self.row.value = Icon(image: cell.icon.image, id: iconInfo.mediaId)
            self.completionCallback?(self)
        })
    }
}

private class IconPickerRow : SelectorRow<Icon, PushSelectorCell<Icon>, IconPickerController>, RowType {
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
        if let image = self.value?.image {
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
    private var tags:TagsRow!
    private var requestManager:RequestManager!

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
        Alerts.showOkAlert(message)
    }

    func validateStringFieldOfRow(row:RowOf<String>, fieldTitle:String,
                                  minCount:Int, inout addTo:[String:CustomStringConvertible]) throws {
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
            try validateStringFieldOfRow(name, fieldTitle: "Event name", minCount: EventNameMinLength, addTo: &result)
            try validateStringFieldOfRow(address, fieldTitle: "Event address",
                    minCount: EventAddressMinLength, addTo: &result)

            result[eventType.tag!] = StringWrapper(eventType.value!.lowercaseString)
            result[date.tag!] = Int(date.value!.timeIntervalSince1970)
            result[peopleNumber.tag!] = peopleNumber.value ?? Int32.max
            result[icon.tag!] = icon.value?.id ?? 0

            let accessToken = VKSdk.accessToken().accessToken
            result["token"] = StringWrapper(accessToken)

            try validateStringFieldOfRow(eventDescription, fieldTitle: "Event description",
                    minCount: EventDescriptionMinLength, addTo: &result)

            if let tagsArray = tags.value?.array {
                result[tags.tag!] = StringWrapper(tagsArray.joinWithSeparator(","))
            } else {
                onValidateCellError("Enter tags", cell: tags.cell)
                throw Errors.Void
            }
        } catch {
            return nil
        }

        return result
    }

    func setupForm() {
        var section = Section("Create New Event")
        form +++ section

        name = TextFloatLabelRow("name") {
            $0.title = "Event Name"
            $0.cell.maxLength = EventNameMaxLength
        }
        section <<< name

        address = TextFloatLabelRow("address") {
            $0.title = "Event Address"
            $0.cell.maxLength = EventAddressMaxLength
        }
        section <<< address

        icon = IconPickerRow("icon") {
            $0.title = "Event Icon"
            $0.value = Icon(image: UIImage(named: DefaultEventIcon), id: 0)
        }
        section <<< icon

        date = DateTimeInlineRow("date") {
            $0.title = "Event Date"
        }.cellUpdate() {
            [unowned self]
            (cell) in
            self.date.minimumDate = NSDate()
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
            $0.title = "YO"
            $0.cell.height = {140}
        }
        section <<< eventDescription

        section = Section("Tags")
        form +++ section
        tags = TagsRow("tags")
        section <<< tags

        if let values = values {
            form.setValues(values)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupForm()
        requestManager = RequestManager()

        UiUtils.setupCancelDoneButtonsOfNavigationBar(self, doneAction: "createEvent", cancelAction: "cancel")
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

    func onEventCreated(id:Int) {
        let eventsController = UiUtils.getBackViewControllerFromTabBarIfTabBarExists(self) as! EventsController
        eventsController.resetData()
        cancel()
    }

    func createEvent() {
        if let args = validateReturnQueryArgsIfSuccess() {
            requestManager.createEvent(args) {
                [unowned self]
                (id, error) in
                if id != nil {
                    self.onEventCreated(id!)
                } else {
                    Alerts.showOkAlert(error!.description)
                }
            }
        }
    }

    func cancel() {
        navigationController!.popViewControllerAnimated(true)
    }
}
