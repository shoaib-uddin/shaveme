//
//  MyPushNotifications.swift
//  Shave Me
//
//  Created by NoorAli on 1/15/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import UserNotifications

import Firebase
import FirebaseInstanceID
import FirebaseMessaging

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    // It will be called when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        var userInfo = notification.request.content.userInfo
        userInfo["isForeground"] = true
        
        // Print full message.
        print(userInfo)
        // It will call when app is in foreground
        print("AppDelegateExtension: userNotificationCenter willPresent")
        
        // post a notification
        NotificationCenter.default.post(name: NSNotification.Name.onPushMessageReceived, object: nil, userInfo: userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    // It will be called when app is in background
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        var userInfo = response.notification.request.content.userInfo
        userInfo["isForeground"] = false
        
        // post a notification
        NotificationCenter.default.post(name: NSNotification.Name.onPushMessageReceived, object: nil, userInfo: userInfo)
        
        // Print full message.
        print(userInfo)
        print("AppDelegateExtension: userNotificationCenter didReceive")
        
        completionHandler()
    }
}
// [END ios_10_message_handling]


// [START ios_10_data_message_handling]
extension AppDelegate : FIRMessagingDelegate {
    // Receive data message on iOS 10 devices while app is in the foreground.
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        print("applicationReceivedRemoteMessage foreground")
        print(remoteMessage.appData)
    }
}
// [END ios_10_data_message_handling]
