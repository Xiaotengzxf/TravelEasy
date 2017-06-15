//
//  AppDelegate.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/8/5.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import CoreData
import XCGLogger
import IQKeyboardManagerSwift
import UserNotifications

var log : XCGLogger!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate , JPUSHRegisterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.sharedManager().enable = true
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.hexStringToColor("#0071c4")], for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.hexStringToColor("#222222")], for: UIControlState())
        application.setStatusBarStyle(.lightContent, animated: false)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: 0 , vertical: -60), for: .default)
        changeRootController()
        log = XCGLogger.default
        log.setup(level: .debug, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil, fileLevel: .debug)
        
        
        
        setJPushService(launchOptions) // 极光推送
        
        if let userInfo = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] {
            handleUserInfo(userInfo)
        }
        
        #if DEBUG
            
        #else
            updateAppVersion() // 版本
        #endif
        
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        application.applicationIconBadgeNumber = 0
        JPUSHService.resetBadge()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        JPUSHService.resetBadge()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        refreshUserInfo() // 刷新用户信息
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    func changeRootController()  {
        if let info = UserDefaults.standard.object(forKey: "info") as? [String : AnyObject], info.count > 0 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
            window?.rootViewController = tabBarController
        }
    }
    
    func refreshUserInfo() {
        if let info = UserDefaults.standard.object(forKey: "info") as? [String : AnyObject], info.count > 0 {
            let manager = URLCollection()
            if let token = manager.validateToken() {
                manager.postRequest(manager.refreshLoginInfo, params: nil, headers: ["token" : token], callback: {[weak self] (json, error) in
                    if let jsonObject = json {
                        if jsonObject["Code"].int == 0 {
                            let approvalRequiredOld = info["ApprovalRequired"] as! Bool
                            let overrunOptionOld = info["OverrunOption"] as! String
                            let approvalRequired = jsonObject["ApprovalRequired"].boolValue
                            let overrunOption = jsonObject["OverrunOption"].stringValue
                            UserDefaults.standard.set(jsonObject.object, forKey: "info")
                            UserDefaults.standard.synchronize()
                            if approvalRequiredOld != approvalRequired || overrunOptionOld != overrunOption {
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ApprovalListViewController"), object: 5)
                            }
                            self?.loadApprovalAndAuthorizeCount() // 加载待审批、待授权数据
                        }
                    }
                })
            }
        }
        
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.zhangxiaofei.TravelEasy" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "TravelEasy", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    // MARK: - 极光推送
    func setJPushService(_ launchOptions: [AnyHashable: Any]?) {
        if #available(iOS 10.0, *) {
            let entity = JPUSHRegisterEntity()
            let type : UNAuthorizationOptions = [.alert , .badge , .sound]
            entity.types = Int(type.rawValue)
            JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self)
        } else {
            let type : UIUserNotificationType = [.alert , .badge , .sound]
            JPUSHService.register(forRemoteNotificationTypes: type.rawValue, categories: nil)
        }
        #if DEBUG
        JPUSHService.setup(withOption: launchOptions, appKey: "fa4a1f0c6022e5cd2a7331ea", channel: nil, apsForProduction: false) // 开发环境
        #else
        JPUSHService.setup(withOption: launchOptions, appKey: "fa4a1f0c6022e5cd2a7331ea", channel: nil, apsForProduction: true) // 发布环境
        #endif
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        JPUSHService.registerDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        JPUSHService.handleRemoteNotification(userInfo)
        handleUserInfo(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        let userInfo = response.notification.request.content.userInfo
        if response.notification.request.trigger is UNPushNotificationTrigger {
            JPUSHService.handleRemoteNotification(userInfo)
            handleUserInfo(userInfo)
        }
        completionHandler()
    }
    
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        let userinfo = notification.request.content.userInfo
        if notification.request.trigger is UNPushNotificationTrigger {
            JPUSHService.handleRemoteNotification(userinfo)
            handleUserInfo(userinfo)
        }
        completionHandler(Int(UNNotificationPresentationOptions.alert.rawValue))
    }
    
    // 如果推送消息中不含有“出差申请”这几个字，就一定是订单消息，定位到订单标签就行，订单标签不需要小红点
    func handleUserInfo(_ userInfo : [AnyHashable: Any] ) {
        if userInfo.count > 0 {
            if let aps = userInfo["aps"] as? [String : AnyObject] {
                NotificationManager.installShared.play()
                if let alert = aps["alert"] as? String {
                    if alert.contains("出差申请") {
                        loadApprovalAndAuthorizeCount()
                    }else{
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "MTabBarViewController"), object: 3)
                    }
                }
            }
            
        }
    }
    
    func loadApprovalAndAuthorizeCount() {
        if let info = UserDefaults.standard.object(forKey: "info") as? [String : AnyObject], info.count > 0 {
            let manager = URLCollection()
            if let token = manager.validateToken() {
                manager.getRequest(manager.getApprovalAndAuthorizeCount, params: nil, headers: ["token" : token], callback: {(json, error) in
                    if let jsonObject = json {
                        if jsonObject["Code"].int == 0 {
                            let approvalCount = jsonObject["ApprovalCount"].intValue
                            let authorizeCount = jsonObject["AuthorizeCount"].intValue
                            UserDefaults.standard.set(approvalCount, forKey: "approvalCount")
                            UserDefaults.standard.set(authorizeCount, forKey: "authorizeCount")
                            UserDefaults.standard.synchronize()
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "MTabBarViewController"), object: 12)
                            
                        }
                    }
                })
            }
        }
    }
    
    // 版本更新
    func updateAppVersion() {
        if let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            let url = "http://itunes.apple.com/lookup?id=1169409476"
            let manager = URLCollection()
            manager.postRequest(url, params: nil, headers: nil, callback: {[weak self] (json, error) in
                if let jsonObject = json {
                    if jsonObject["resultCount"].intValue == 1 {
                        if let remoteVersion = jsonObject["results" , 0 , "version"].string {
                            if Float(remoteVersion)! > Float(currentVersion)! {
                                if let version = UserDefaults.standard.object(forKey: "version") as? String {
                                    if Float(remoteVersion)! > Float(version)!{
                                        self?.showVersionAlert(remoteVersion)
                                    }
                                }else{
                                    self?.showVersionAlert(remoteVersion)
                                }
                            }
                        }
                    }
                }
            })
        }
    }
    
    func showVersionAlert(_ version : String) {
        let alert = UIAlertController(title: "版本更新", message: "出差易商旅有新版本V\(version)，您确定要更新吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
            UserDefaults.standard.set(version, forKey: "version")
            UserDefaults.standard.synchronize()
        }))
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
            UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/lookup?id=1169409476")!)
        }))
        window?.rootViewController?.present(alert, animated: true, completion: { 
            
        })
    }
}

