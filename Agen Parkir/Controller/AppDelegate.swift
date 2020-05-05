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
import FBSDKCoreKit
import FBSDKLoginKit
import OneSignal
import SendBirdSDK
import Firebase
import FirebaseMessaging
import FirebaseInstanceID

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    var mainNavigationController : UINavigationController?
//    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
//        if !stateChanges.from.subscribed && stateChanges.to.subscribed {
//            print("Subscribed for OneSignal push notifications!")
//        }
//
//        //The player id is inside stateChanges. But be careful, this value can be nil if the user has not granted you permission to send notifications.
//        if let playerId = stateChanges.to.userId {
//            print("Current playerId \(playerId)")
//            UserDefaults.standard.set(playerId, forKey: StaticVar.onesignal_player_id)
//        }
//    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //firebase
        configureFirebase(application: application)
        
        //sendbird init
        SBDMain.initWithApplicationId("4FB8C8E8-D452-497C-85DE-8EE0F4FA6251")
        
        //keyboard manager
        IQKeyboardManager.shared.enable = true
        
        //midtrans
        MidtransConfig.shared().setClientKey("Mid-client-Ecyno8FETxVdlm8N", environment: .production, merchantServerURL: "https://agenparkir.com")
        
        //one signal
        //configureOneSignal()
        
        return true
    }
    
//    private func configureOneSignal() {
//        let notificationReceivedBlock: OSHandleNotificationReceivedBlock = { notification in
//            print("Received Notification: \(String(describing: notification!.payload.notificationID))")
//        }
//
//        let notificationOpenedBlock: OSHandleNotificationActionBlock = { result in
//            // This block gets called when the user reacts to a notification received
//            let payload: OSNotificationPayload = result!.notification.payload
//
//            var fullMessage = payload.body
//            print("Message = \(String(describing: fullMessage))")
//
//            if payload.additionalData != nil {
//                if payload.title != nil {
//                    let messageTitle = payload.title
//                    print("Message Title = \(messageTitle!)")
//                }
//
//                let additionalData = payload.additionalData
//                if additionalData?["actionSelected"] != nil {
//                    fullMessage = fullMessage! + "\nPressed ButtonID: \(additionalData!["actionSelected"])"
//                }
//            }
//        }
//
//        OneSignal.add(self as OSSubscriptionObserver)
//
//        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false, kOSSettingsKeyInAppLaunchURL: true]
//
//        OneSignal.initWithLaunchOptions(launchOptions,
//                                        appId: "36504d26-6cdd-4271-b2de-666e692b398a",
//                                        handleNotificationReceived: notificationReceivedBlock,
//                                        handleNotificationAction: notificationOpenedBlock,
//                                        settings: onesignalInitSettings)
//
//        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
//
//        // Recommend moving the below line to prompt for push after informing the user about
//        OneSignal.promptForPushNotifications(userResponse: { accepted in
//            print("User accepted notifications: \(accepted)")
//        })
//    }
    
    private func notificationListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleEvent), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func handleEvent() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    private func configureFirebase(application: UIApplication) {
        FirebaseApp.configure()
        
        // For iOS 10 display notification (sent via APNS)
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            Messaging.messaging().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                if error == nil{
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        UIApplication.shared.registerForRemoteNotifications()
        
        //get application instance ID
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
                UserDefaults.standard.set(result.token, forKey: StaticVar.onesignal_player_id)
            }
        }
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("fcm token \(fcmToken)")
        UserDefaults.standard.set(fcmToken, forKey: StaticVar.onesignal_player_id)
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("refresh fcm token \(fcmToken)")
        UserDefaults.standard.set(fcmToken, forKey: StaticVar.onesignal_player_id)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("device token \(token)")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("notification data: \(userInfo)")
    }
    
    // function to handle when notification clicked
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        print("full message \(userInfo)")
        
        let type = userInfo[AnyHashable("type")]
        let news_id = userInfo[AnyHashable("news_id")]
        let buildingId = userInfo[AnyHashable("buildingId")]
        let buildingName = userInfo[AnyHashable("customerName")]
        
        if let rootViewController = self.window!.rootViewController as? UINavigationController {
            if "\(type ?? "")" == "news" {
                if rootViewController.viewControllers.count == 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        let vc = DetailNewsController()
                        vc.newsId = "\(news_id ?? "")"
                        rootViewController.pushViewController(vc, animated: true)
                    }
                } else {
                    let vc = DetailNewsController()
                    vc.newsId = "\(news_id ?? "")"
                    rootViewController.pushViewController(vc, animated: true)
                }
            } else if "\(type ?? "")" == "chat" {
                if rootViewController.viewControllers.count == 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        let vc = ChatController()
                        vc.buildingId = "\(buildingId ?? "")"
                        vc.buildingName = "\(buildingName ?? "")"
                        rootViewController.pushViewController(vc, animated: true)
                    }
                } else {
                    let vc = ChatController()
                    vc.buildingId = "\(buildingId ?? "")"
                    vc.buildingName = "\(buildingName ?? "")"
                    rootViewController.pushViewController(vc, animated: true)
                }
            } else {
                // go to main activity
            }
        }
        
        completionHandler()
    }
    
    func changeStoryboardRoot() {
        let rootViewController = self.window!.rootViewController as! UINavigationController
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let homeVC = mainStoryboard.instantiateViewController(withIdentifier: "HomeController") as! HomeController
        rootViewController.pushViewController(homeVC, animated: true)
    }
    
    func changeRootViewController(rootVC : UIViewController){
        mainNavigationController = UINavigationController(rootViewController: rootVC)
        mainNavigationController?.isNavigationBarHidden = true
        UIView.transition(with: self.window!, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.window?.rootViewController = self.mainNavigationController
        }, completion: { completed in
            // maybe do something here
        })
    }
    
    // handle notification in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let content = notification.request.content
        print("notification data foreground: \(content.userInfo)")
        completionHandler([.alert, .sound])
    }
    
    //facebook login
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if ApplicationDelegate.shared.application(app, open: url, options: options) {
            return true
        }
        return false
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
