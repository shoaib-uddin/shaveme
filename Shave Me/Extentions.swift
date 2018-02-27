//
//  Extentions.swift
//  Shave Me
//
//  Created by NoorAli on 12/19/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import Foundation
import UIKit
import SWRevealViewController
import M13Checkbox

extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
}

extension UIViewController {
    var storyBoardID: String {
        return self.className + "SBID"
    }
    
    class var storyBoardID: String {
        return className + "SBID"
    }
    
    func configureNavigationBar() {
        // Changing navigation bar color
        if let navigationController = self.navigationController {
            navigationController.navigationBar.barTintColor = UIColor.COLcdcdcd()
            navigationController.navigationBar.tintColor = UIColor.COL47d9bf()
        }
        
        let backItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        
        if let revealVC = self.revealViewController() {
            if AppController.sharedInstance.language == "en" {
                let sideMenuButton = UIBarButtonItem(image: UIImage(named: "menubg"), style: .plain, target: revealVC, action: #selector
                    (SWRevealViewController.rightRevealToggle(_:)))
                self.navigationItem.rightBarButtonItem = sideMenuButton
            } else {
                let sideMenuButton = UIBarButtonItem(image: UIImage(named: "menubg"), style: .plain, target: revealVC, action: #selector
                    (SWRevealViewController.revealToggle(_:)))
                self.navigationItem.rightBarButtonItem = sideMenuButton
            }
            
            if let parentView = self.view {
                parentView.addGestureRecognizer(revealVC.panGestureRecognizer())
                parentView.addGestureRecognizer(revealVC.tapGestureRecognizer())
            }
        }
    }
    
    func hideKeyboardOnTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIView {
    @IBInspectable var borderColor : UIColor? {
        set (newValue) {
            applyBorder(color: (newValue ?? UIColor.clear).cgColor)
        }
        get {
            return UIColor(cgColor: self.layer.borderColor!)
        }
    }
    
    func applyBorder(color: CGColor = UIColor.COLcccccc().cgColor) {
        layer.cornerRadius = 5.0
        clipsToBounds = true
        layer.borderColor = color
        layer.borderWidth = 1
    }
}

extension Notification.Name {
    static let onPushMessageReceived = Notification.Name("onPushMessageReceived")
}

extension String {
    func date(fromFormat: String) -> Date? {
        let fromString = self == "24:00" ? "23:59" : self
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromFormat
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        return dateFormatter.date(from: fromString)
    }
    
    func base64EncodedImage() -> UIImage? {
        if let dataDecoded = Data(base64Encoded: self, options: .ignoreUnknownCharacters) {
            return UIImage(data: dataDecoded)
        }
        return nil
    }
    
    func to12HourString(fromFormat: String = "HH:mm") -> String? {
        if let date = self.date(fromFormat: fromFormat) {
            return date.string(fromFormat: "hh:mm aa")
        }
        
        return nil
    }
    
    func trunc(length: Int) -> String {
        if self.characters.count > length {
            return self.substring(to: self.characters.index(self.startIndex, offsetBy: length))
        } else {
            return self
        }
    }
    
    func trim() -> String{
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}

extension URL {
    func af_clearCache() {
        let urlRequest = Foundation.URLRequest(url: self)
        let imageDownloader = UIImageView.af_sharedImageDownloader
        
        // Clear from in-memory cache
        if let imageCache2 = imageDownloader.imageCache {
            _ = imageCache2.removeImage(for: urlRequest, withIdentifier: nil)
        }
        // Clear from on-disk cache
        imageDownloader.sessionManager.session.configuration.urlCache?.removeCachedResponse(for: urlRequest)
    }
}

extension UIImageView {
    func makeCircular(borderWidth: CGFloat = 0, borderColor: UIColor = UIColor.clear) {
        self.layer.cornerRadius = self.frame.size.height / 2
        self.layer.masksToBounds = true
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
    }
}

extension UIImage {
    func base64EncodedString() -> String {
        let imageData: Data = UIImagePNGRepresentation(self)!
        return imageData.base64EncodedString(options: .lineLength64Characters)
    }
    
    func resizeImage(newWidth: CGFloat) -> UIImage? {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func resizeToSquare() -> UIImage {
        // inspired by Hamptin Catlin
        // https://gist.github.com/licvido/55d12a8eb76a8103c753
        
        let newScale = self.scale // change this if you want the output image to have a different scale
        let originalSize = self.size
        
        var targetSize = CGSize(width: 1200, height: 1200);
        let w = self.size.width;
        let h = self.size.height;
        if(w > h){
            targetSize = CGSize(width: h, height: h);
        }else
            if(w < h){
                targetSize = CGSize(width: w, height: w);
            }else{
                targetSize = CGSize(width: w, height: h);
        }
        
        
        
        
        
        
        let widthRatio = targetSize.width / originalSize.width
        let heightRatio = targetSize.height / originalSize.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        let newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: floor(originalSize.width * heightRatio), height: floor(originalSize.height * heightRatio))
        } else {
            newSize = CGSize(width: floor(originalSize.width * widthRatio), height: floor(originalSize.height * widthRatio))
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(origin: .zero, size: targetSize)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        let format = UIGraphicsImageRendererFormat()
        format.scale = newScale
        format.opaque = true
        let newImage = UIGraphicsImageRenderer(bounds: rect, format: format).image() { _ in
            self.draw(in: rect)
        }
        
        return newImage
    }
    
    
    
    func scaleImage(toSize newSize: CGSize) -> UIImage? {
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            context.interpolationQuality = .high
            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
            context.concatenate(flipVertical)
            context.draw(self.cgImage!, in: newRect)
            let newImage = UIImage(cgImage: context.makeImage()!)
            UIGraphicsEndImageContext()
            return newImage
        }
        return nil
    }
}

extension NotificationCenter {
    func setObserver(_ observer: AnyObject, selector: Selector, name: NSNotification.Name, object: AnyObject?) {
        NotificationCenter.default.removeObserver(observer, name: name, object: object)
        NotificationCenter.default.addObserver(observer, selector: selector, name: name, object: object)
    }
}

extension Bool {
    func getCheckState() -> M13Checkbox.CheckState {
        return self ? M13Checkbox.CheckState.checked : M13Checkbox.CheckState.unchecked
    }
}

extension Dictionary where Value: Equatable {
    func containsValue(value : Value) -> Bool {
        return self.contains { $0.1 == value }
    }
}

extension Date {
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
    
    func getDifferenceInSecondsOfTimeOnly(to: Date) -> Int {
        let calendar = Calendar.current
        let components2 = calendar.dateComponents([.hour, .minute, .second], from: to)
        let date3 = calendar.date(bySettingHour: components2.hour!, minute: components2.minute!, second: components2.second!, of: self)!
        
        return calendar.dateComponents([.second], from: self, to: date3).second!
    }
    
    func getDifferenceInSeconds(to: Date) -> Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.second], from: self, to: to).second!
    }
    
    func getMinutes() -> Int {
        return Calendar.current.dateComponents([.minute], from: self).minute!
    }
    
    func getHours() -> Int {
        return Calendar.current.dateComponents([.hour], from: self).hour!
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var nextDay: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }
    
    var endOfDay: Date? {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)
    }
    
    mutating func addDays(numberOfDays: TimeInterval) {
        let secondsInOneDay: TimeInterval = 24 * 60 * 60;
        self.addTimeInterval(secondsInOneDay * numberOfDays)
    }
    
    mutating func addMonths(numberOfMonths: TimeInterval) {
        let secondsInOneMonth: TimeInterval = 30 * 24 * 60 * 60;
        self.addTimeInterval(secondsInOneMonth * numberOfMonths)
    }
    
    func compareTimeOnly(to: Date) -> ComparisonResult {
        let seconds = getDifferenceInSecondsOfTimeOnly(to: to)
        
        if seconds == 0 {
            return .orderedSame
        } else if seconds > 0 {
            return .orderedAscending
        } else {
            return .orderedDescending
        }
    }
    
    func isAfterTimeOnly(to: Date) -> Bool {
        let seconds = getDifferenceInSecondsOfTimeOnly(to: to)
        if seconds < 0 {
            return true
        }
        return false
    }
    
    func isAfter(to: Date?) -> Bool {
        guard let to = to else {
            return false
        }
        return self.compare(to) == .orderedDescending
    }
    
    func isBefore(to: Date?) -> Bool {
        guard let to = to else {
            return false
        }
        return self.compare(to) == .orderedAscending
    }
    
    func isBeforeTimeOnly(to: Date) -> Bool {
        let seconds = getDifferenceInSecondsOfTimeOnly(to: to)
        if seconds > 0 {
            return true
        }
        return false
    }
    
    static func getHourMinutesSeconds(fromSeconds: Int) -> (Int, Int, Int) {
        let hours = fromSeconds / (60 * 60)
        let minutes = (fromSeconds / 60) % 60
        let seconds = fromSeconds % 60
        return (hours, minutes, seconds)
    }
    
    func localString(fromFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromFormat
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.string(from: self)
    }
    
    func string(fromFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromFormat
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        return dateFormatter.string(from: self)
    }
    
    func isCurrentDate() -> Bool {
        return Calendar.current.compare(self, to: Date(), toGranularity: .day) == .orderedSame
    }
    
    func isEqualToDateOnly(dateTo: Date?) -> Bool {
        guard let dateTo = dateTo else {
            return false
        }
        
        return Calendar.current.compare(self, to: dateTo, toGranularity: .day) == .orderedSame
    }
    
    func isDateBetweenBothInclusive(dateFrom: Date?, dateTo: Date?) -> Bool {
        return self.isEqualToDateOnly(dateTo: dateFrom) || self.isEqualToDateOnly(dateTo: dateTo) || (self.isAfter(to: dateFrom) && self.isBefore(to: dateTo))
    }
}
