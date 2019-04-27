//
//  AppDelegate.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 25/02/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import MidtransKit
import FacebookCore
import OneSignal
import SendBirdSDK
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, OSSubscriptionObserver {
    var window: UIWindow?

    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
        if !stateChanges.from.subscribed && stateChanges.to.subscribed {
            print("Subscribed for OneSignal push notifications!")
        }
        
        //The player id is inside stateChanges. But be careful, this value can be nil if the user has not granted you permission to send notifications.
        if let playerId = stateChanges.to.userId {
            print("Current playerId \(playerId)")
            UserDefaults.standard.set(playerId, forKey: StaticVar.onesignal_player_id)
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //firebase
        FirebaseApp.configure()
        
        //sendbird init
        SBDMain.initWithApplicationId("4FB8C8E8-D452-497C-85DE-8EE0F4FA6251")
        
        //keyboard manager
        IQKeyboardManager.shared.enable = true
        
        //midtrans
        let state = UserDefaults.standard.string(forKey: StaticVar.applicationState)
        
        if let appsState = state{
            switch appsState {
            case "Dev":
                print("Midtrans in development state")
                MidtransConfig.shared().setClientKey("SB-Mid-client-XAqp-KyYztrTJ6W8", environment: .sandbox, merchantServerURL: "https://merchant-url-sandbox.com")
            default:
                print("Midtrans in production state")
                MidtransConfig.shared().setClientKey("SB-Mid-client-fQDdQY9fNt8Eq17W", environment: .sandbox, merchantServerURL: "https://merchant-url-sandbox.com")
            }
        } else {
            print("Midtrans in production state")
            UserDefaults.standard.set("Prod", forKey: StaticVar.applicationState)
            MidtransConfig.shared().setClientKey("SB-Mid-client-fQDdQY9fNt8Eq17W", environment: .sandbox, merchantServerURL: "https://merchant-url-sandbox.com")
        }
        
        //facebook login
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        //one signal
        let notificationReceivedBlock: OSHandleNotificationReceivedBlock = { notification in
            print("Received Notification: \(String(describing: notification!.payload.notificationID))")
        }
        
        let notificationOpenedBlock: OSHandleNotificationActionBlock = { result in
            // This block gets called when the user reacts to a notification received
            let payload: OSNotificationPayload = result!.notification.payload
            
            var fullMessage = payload.body
            print("Message = \(String(describing: fullMessage))")
            
            if payload.additionalData != nil {
                if payload.title != nil {
                    let messageTitle = payload.title
                    print("Message Title = \(messageTitle!)")
                }
                
                let additionalData = payload.additionalData
                if additionalData?["actionSelected"] != nil {
                    fullMessage = fullMessage! + "\nPressed ButtonID: \(additionalData!["actionSelected"])"
                }
            }
        }
        
        OneSignal.add(self as OSSubscriptionObserver)
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false, kOSSettingsKeyInAppLaunchURL: true]
        
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "36504d26-6cdd-4271-b2de-666e692b398a",
                                        handleNotificationReceived: notificationReceivedBlock,
                                        handleNotificationAction: notificationOpenedBlock,
                                        settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        
        // Recommend moving the below line to prompt for push after informing the user about
        // how your app will use them.
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
        
//        // Check if launched from notification
//        let notificationOption = launchOptions?[.remoteNotification]
//
//        // 1
//        if let notification = notificationOption as? [String: AnyObject],
//            let aps = notification["aps"] as? [String: AnyObject] {
//
//            // 3
//            let homeController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeController") as! HomeController
//            homeController.channelUrl = aps["url"] as? String
//            self.window?.rootViewController = homeController
//        }
        
        return true
    }
    
    //facebook login
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return SDKApplicationDelegate.shared.application(app, open: url, options: options)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}
