//
// Created by Semyon Tikhonenko on 2/27/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import UIKit

let DefaultEventIcon = "event_icon.png"
let IconBaseUrl = "http://azazai.com/icon/"

class EventUtils {
    public static func displayIcon(iconId:Int, imageView:UIImageView) {
        if iconId != 0 {
            imageView.sd_setImageWithURL(NSURL(string: IconBaseUrl + String(iconId))!)
        } else {
            imageView.image = UIImage(named: DefaultEventIcon)
        }
    }

    public static func displayPeopleNumberInLabel(label:UILabel, event:Event) {
        label.text = String(event.subscribersCount) + "/" + String(event.peopleNumber)
    }

    public static func eventDateToString(date:Int) -> String {
        let date = NSDate(timeIntervalSince1970: Double(date))
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        return formatter.stringFromDate(date)
    }

    public static func displayUserNameInLabel(label:UILabel, user:VkUser?) {
        if let user = user {
            label.text = user.first_name + " " + user.last_name
        }
    }

    public static func setupOpenProfile(target:UIViewController, avatar:UIImageView, name:UILabel) {
        let tapFactory = {UITapGestureRecognizer(target:target, action:"openVkProfile:")}
        avatar.userInteractionEnabled = true
        name.userInteractionEnabled = true
        avatar.addGestureRecognizer(tapFactory())
        name.addGestureRecognizer(tapFactory())
    }
}

extension UIImageView {
    func setImageFromURL(url:String?) {
        if let url = NSURL(string: url ?? "") {
            self.sd_setImageWithURL(url)
        }
    }
}
