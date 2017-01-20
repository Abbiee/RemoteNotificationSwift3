//
//  AppDelegate.swift
//  PushNotificationsApp


import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        // Override point for customization after application launch.
        
        application.applicationIconBadgeNumber = 0; // Clear badge when app is launched
        
        // Check if launched from notification
        if let notification = launchOptions?[.remoteNotification] as? NSDictionary {
            window?.rootViewController?.present(ViewController(), animated: true, completion: nil)
            notificationReceived(notification: notification as [NSObject : AnyObject])
        } else {
            registerPushNotifications()
        }
        return true
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != UIUserNotificationType() {
            application.registerForRemoteNotifications()
        }
    }
    
    func registerPushNotifications() {
        DispatchQueue.main.async { 
            let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("Device Token: \(tokenString)")//print device token in debugger console
        print("Registration succeeded!")
        print("Token: ", tokenString)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Registration failed!")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        notificationReceived(notification: userInfo as [NSObject : AnyObject])
    }
    
//    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
//        notificationReceived(notification: userInfo)
//    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0; // Clear badge when app is or resumed
    }
    
    func notificationReceived(notification: [NSObject:AnyObject]) {
        let viewController = window?.rootViewController
        let view = viewController as? ViewController
        view?.addNotification(
            title: getAlert(notification: notification).0,
            body: getAlert(notification: notification).1)
    }
    
    private func getAlert(notification: [NSObject:AnyObject]) -> (String, String) {
        let aps = notification["aps" as NSString] as? [String:Any]
        let alert = aps?["alert"] as? [String:AnyObject]
        let title = alert?["title"] as? String
        let body = alert?["body"] as? String
        return (title ?? "-", body ?? "-")
    }
}

