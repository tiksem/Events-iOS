//
// Created by Semyon Tikhonenko on 2/2/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import SwiftUtils
import UIKit

class EventController : UIViewController {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var peopleNumber: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var subscribeButton: UIButton!
    
    private var event:Event! = nil
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    init(event:Event) {
        super.init(nibName: "EventController", bundle: nil)
        self.event = event
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UiUtils.setupMultiLineForLabel(eventDescription, text: event.description)
        EventUtils.displayPeopleNumberInLabel(peopleNumber, event: event)
        name.text = event.name
        EventUtils.displayIcon(event.icon, imageView: icon)
        subscribeButton.setTitleColor(UIColor.whiteColor(), forState: .Selected)
        subscribeButton.setBackgroundImage(UIImage.fromColor(UIColor.brownColor()), forState: .Selected)
    }
    
    @IBAction func onSubscribeButtonClick(sender: AnyObject) {
        subscribeButton.selected = !subscribeButton.selected
    }
}
