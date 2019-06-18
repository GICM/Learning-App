//
//  AppDelegate.swift
//  GICMLearningApp
//
//  Created by Rafi on 22/05/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift
import FBSDKLoginKit
import GoogleMaps
import UserNotifications
import CoreLocation
import Firebase
import Instabug
import SwiftKeychainWrapper
import Fabric
import Crashlytics
import FirebaseFirestore
import FirebaseMessaging
import FirebaseDynamicLinks
import os.log
import Reachability

//@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {
    
    let googleApiKey = "AIzaSyDf2fdX0jo07EXk8BS6A-h_dXEJqCaOkQ4"
    let locationManager     = CLLocationManager()
    var imageFullScreenMeeting : [Data] = []
    var userUUID: String?
    public var navigationContollerObj : UINavigationController! = nil
    var window: UIWindow?
    var speed:CLLocationSpeed = 0.0
    var oldLoc:CLLocation?
    var strCurrentCompany = ""
    var speedClosure : (()->Void)?
    var reachability = Reachability()!
    
    
    var timerLeader = Timer()
    var totalLeaderBoardTimerCount = 0
    
 
    var timerIntrasit = Timer()
    var totalIntrasitTimerCount = 0
    
    //var contribution : Time
    
    // MARK: - Custom Font
    override init() {
        super.init()
        UIFont.overrideInitialize()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        self.redirectConsoleLogToDocumentFolder()

        NSLog("=======================================")
        NSLog("            App Launched               ")
        NSLog("Device Model : \(UIDevice.current.model)")
        NSLog("Device Name  : \(UIDevice.current.name)")
        NSLog("iOS Version  : \(UIDevice.current.systemVersion)")
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            NSLog("could not start reachability notifier")
        }
        
        if UserDefaults.standard.string(forKey: "Login") == nil {
            UserDefaults.standard.set("0", forKey: "Login")
            UserDefaults.standard.synchronize()
        }
        
        UserDefaults.standard.set("Closed", forKey: "isProfileCellExpand")
        UserDefaults.standard.synchronize()
        
        FirebaseManager.shared.firebaseConfigure()
        
        // let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
        //  edgePan.edges = .left
        //  window?.addGestureRecognizer(edgePan)
        
        Fabric.with([Crashlytics.self])
        Fabric.sharedSDK().debug = true
        
        if let retrievedUUID: String = KeychainWrapper.standard.string(forKey: "uniqueStr"){
            userUUID = retrievedUUID
        }
        else
        {
            userUUID = (UIDevice.current.identifierForVendor?.uuidString)!
            KeychainWrapper.standard.set(userUUID!, forKey: "uniqueStr")
        }
        
        UserDefaults.standard.setUserUUID(value: userUUID!)
        NSLog("UUID:\(userUUID!)")
        
        
        self.redirectConsoleLogToDocumentFolder()
        // Override point for customization after application launch.
        
        self.instaBug()
        setupLocationManager()
        IQKeyboardManager.shared.enable = true
        GMSServices.provideAPIKey(googleApiKey)
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                NSLog("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                NSLog("Remote instance ID token: \(result.token)")
            }
        }
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        NotificationCenter.default.post(name: Notification.Name("NofifyReloadApply"), object: nil, userInfo: nil)
        switch reachability.connection {
        case .wifi:
            NSLog("Reachable via WiFi")
            NotificationCenter.default.post(name: Notification.Name("NofifyOfflineCallback"), object: nil, userInfo: nil)
        case .cellular:
            NSLog("Reachable via Cellular")
            NotificationCenter.default.post(name: Notification.Name("NofifyOfflineCallback"), object: nil, userInfo: nil)
        case .none:
            NSLog("Network not reachable")
        }
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if handlePasswordlessSignIn(withURL: url) {
            return true
        }
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func instaBug(){
        Instabug.start(withToken: "0b309faf61e0ac5ee5e9cfe01adcd513", invocationEvents: .none)
        //   Instabug.start(withToken: "0b309faf61e0ac5ee5e9cfe01adcd513", invocationEvent: .none)
        BugReporting.floatingButtonEdge = .maxXEdge
        BugReporting.floatingButtonTopOffset = 20
    }
    
    func handleDynamicLink(_ dynamicLink: DynamicLink?) -> Bool {
        guard let dynamicLink = dynamicLink else { return false }
        guard let deepLink = dynamicLink.url else { return false }
        let queryItems = URLComponents(url: deepLink, resolvingAgainstBaseURL: true)?.queryItems
        if let invitedBy = queryItems?.filter({(item) in item.name == "invitedby"}).first?.value{
            NSLog(invitedBy)
            self.updateInvites(inviteID: invitedBy)
        }
        return true
    }
    
    func updateInvites(inviteID : String){
        let ref = FirebaseManager.shared.firebaseDP?.collection("invite").whereField("invite_id", isEqualTo: inviteID)
        ref?.getDocuments(completion: { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                let update_ref = FirebaseManager.shared.firebaseDP?.collection("invite").document((snap.first?.documentID)!)
                update_ref?.updateData(["status" :"earn"]
                    , completion: { (error) in
                })
            }
        })
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let message = url.absoluteString
        NSLog("message \(message)")
        if message == UserDefaults.standard.string(forKey: "SwitchLink"){
            UserDefaults.standard.set("1", forKey: "SwitchLinkVerify")
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: Notification.Name("NotifyLoginVerify"), object: nil, userInfo: nil)
            return true
        }
        else if DynamicLinks.dynamicLinks().shouldHandleDynamicLink(fromCustomSchemeURL: url)
        {
            let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url)
            return handleDynamicLink(dynamicLink)
        }
        else{
            return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        }
    }
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
            // ...
        }
        if handled{
            return handled
        }
        else{
            return userActivity.webpageURL.flatMap(handlePasswordlessSignIn)!
        }
    }
    
    func handlePasswordlessSignIn(withURL url: URL) -> Bool {
        let link = url.absoluteString
        // [START is_signin_link]
        if Auth.auth().isSignIn(withEmailLink: link) {
            // [END is_signin_link]
            UserDefaults.standard.set(link, forKey: "Link")
            NSLog("link\(link)")
            return true
        }
        return false
    }
    
    func redirectConsoleLogToDocumentFolder() {
        var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        
        let documentsDirectory = paths[0]
        let fileName = "/console_log.txt"
        let filePath = (documentsDirectory as NSString).appendingPathComponent(fileName)
        
        
        
        freopen(filePath.cString(using: String.Encoding.ascii)!, "a+", stderr)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        
        let currentDate = Date()//NSDate(timeIntervalSinceNow: -1*24*60*60)
        UserDefaults.standard.set(currentDate, forKey: "lastUsed")
        UserDefaults.standard.synchronize()
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
        let currentDate = NSDate(timeIntervalSinceNow: -5*24*60*60) //Date()//
        UserDefaults.standard.set(currentDate, forKey: "lastUsed")
        UserDefaults.standard.synchronize()
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    @objc func screenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .recognized {
            let transition:CATransition = CATransition()
            transition.duration = 0.35
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromLeft
            
            NSLog("Screen edge swiped!")
            
            let mainStoryboard = UIStoryboard(name: "ProfileStoryboard", bundle: nil)
            
            let vc = mainStoryboard.instantiateViewController(withIdentifier: "AdminVC") as! AdminVC
            let rootViewController = self.window!.rootViewController as! UINavigationController
            
            if (rootViewController.visibleViewController is ReleaseNotesVC) || (rootViewController.visibleViewController is ViewController) || (rootViewController.visibleViewController is LoginViewController) || (rootViewController.visibleViewController is CreateViewController) {
                return
            }
            
            if !(rootViewController.visibleViewController is AdminVC){
                rootViewController.view.layer.add(transition, forKey: kCATransition)
                rootViewController.pushViewController(vc, animated: true)
            }
        }
    }
    
    // MARK: - DEV METHODS
    class func getAppdelegateInstance() -> AppDelegate?{
        let appDelegateRef = UIApplication.shared.delegate as! AppDelegate
        return appDelegateRef
    }
    
    //MARK:- Logout
    func requesetAutoLogoutProcess(){
        DispatchQueue.main.async{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "NavigationController")
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
            self.navigationContollerObj = UIApplication.shared.windows[0].rootViewController as! UINavigationController
        }
    }
    
    func navigateToProjectList(){
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "TrackingStoryBoard", bundle: nil)
        if let vc = mainStoryboard.instantiateViewController(withIdentifier: "TrackingVC") as? TrackingVC , self.navigationContollerObj != nil {
            self.navigationContollerObj.pushViewController(vc, animated: true)}
    }
    
    func navigateToApplyVC(){

        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "WeeklyPlanner", bundle: nil)
        if let vc = mainStoryboard.instantiateViewController(withIdentifier: "WeeklyPlannerListVC") as? WeeklyPlannerListVC , self.navigationContollerObj != nil {
            self.navigationContollerObj.pushViewController(vc, animated: true)}
    }
    
    
    func navigateToBreathReset(){
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "ProfileStoryboard", bundle: nil)
        if let vc = mainStoryboard.instantiateViewController(withIdentifier: "BreathVC") as? BreathVC , self.navigationContollerObj != nil {
            self.navigationContollerObj.pushViewController(vc, animated: true)}
    }
    
    //MARK:- Orientation test
    var orientationLock = UIInterfaceOrientationMask.portrait
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }
    
    // MARK: - Core Data stack
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.geekylemon.CarSpotter" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "UserModel", withExtension: "momd")!
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
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
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
}

//Device Orientation Lock Update
struct AppUtility {
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    
    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
        
        self.lockOrientation(orientation)
        
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
    }
}

extension AppDelegate:CLLocationManagerDelegate,UNUserNotificationCenterDelegate {
    func setupLocationManager() {
        
        // trigger static reminder
        self.getTimeReminder()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation//kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10;
        //        locationManager.headingFilter = 5
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        //  locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.alert,.sound], completionHandler: {(granted, error) in
                if error != nil{
                    NSLog(error.debugDescription)
                }
            })
        } else {
            // Fallback on earlier versions
        }
        self.startGeoFencingFirebase()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        NSLog("locations = \(String(describing: locations.first?.coordinate.latitude)) \(String(describing: locations.first?.coordinate.longitude))")
        NSLog("***********************************************")
        NSLog("didUpdateLocations");
        NSLog("speed\(String(describing: locations.last?.speed))");
        
        speed = manager.location?.speed ?? 0
        speed =  Double(speed) * 3.6 // meter per second to km per hour
        
        
        let isBlackOut = UserDefaults.standard.bool(forKey: "BlackOutTime")
        
        print(isBlackOut)
         if speed < 15{
            self.resetTravelTime()
            if isBlackOut{
                self.checkBlack(limit: 10)
            }else{
                let intransitTime = FirebaseManager.shared.getCurrentDate()
                UserDefaults.standard.set(true, forKey: "BlackOutTime")
                UserDefaults.standard.setIntrasitLastTimeTrigger(value: intransitTime)
                UserDefaults.standard.synchronize()
            }
         }else{
             Utilities.sharedInstance.showToast(message: "speed:\(speed)")
        }
        
        
        NSLog("Speed :- \(speed) ")
        if speed > 20 {
            NSLog("*************************************************")
            NSLog("Speed :- \(speed) ")
            
            self.checkBlack(limit: 10)
            
            let isTrigger = UserDefaults.standard.getIntrasitTriggered()
            if !isTrigger{
                // Check Start time
                if self.totalIntrasitTimerCount > 60{
                     self.startTransitReminder()
                }else{
                    timerIntrasit = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.calulateIntransit), userInfo: nil, repeats: true)
                }
            }
            
            let userDef = UserDefaults.standard
            userDef.set(false, forKey: "BlackOutTime")
            userDef.synchronize()
        }
    
        guard let closeAction = speedClosure else {
            return
        }
        closeAction()
    }
    
    func checkBlack(limit: Int){
        
        let isTrigger = UserDefaults.standard.getIntrasitTriggered()
        if isTrigger{
            let time = UserDefaults.standard.getIntrasitLastTimeTrigger()
            let noOfMins = FirebaseManager.shared.noOfMinutes(startDate: time)
            print(noOfMins)
            if noOfMins >=  limit {
                NSLog("changed the blackout Time")
                let userDef = UserDefaults.standard
                userDef.setIntrasitTriggered(value: false)
                let intransitTime = FirebaseManager.shared.getCurrentDate()
                userDef.setIntrasitLastTimeTrigger(value: intransitTime)
                userDef.synchronize()
            }
        }
    }
    
    func resetTravelTime(){
        self.timerIntrasit.invalidate()
        self.totalIntrasitTimerCount = 0
    }
    
    // MARK: - Time reminder handler
    func getTimeReminder(){
        let ref = FirebaseManager.shared.firebaseDP?.collection("reminder").whereField("user_UUID", isEqualTo: userUUID!).whereField("isReminderOn", isEqualTo: true).whereField("type", isEqualTo: "0")
        ref?.getDocuments(completion: { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0{
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                for doc in snap{
                    self.triggerTimeNotification(dict: doc)
                }
            }
        })
    }
    
    func triggerTimeNotification(dict:QueryDocumentSnapshot) {
        
        NSLog("***********************************************")
        NSLog("triggerTimeNotification ")
        
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = dict.get("title") as! String
            content.subtitle = dict.get("subtitle") as! String
            content.body = dict.get("body") as! String
            if dict["title"] as! String == "Project Tracking:"{
                content.title = Utilities.sharedInstance.getRandomQuotes()
//                content.subtitle = Utilities.sharedInstance.getRandomQuotes()
                content.body = "Reminder to track your project"
            }
            else if dict["title"] as! String == "Week Preparation:"{
                content.title = Utilities.sharedInstance.getRandomQuotes()
//                content.subtitle = Utilities.sharedInstance.getRandomQuotes()
                content.body = "Reminder to prepare your week"
            }
            content.sound = UNNotificationSound(named: "GICM_Notification.wav")
            let arrayTimeDaysState = dict.get("repeatEveryState") as! [Bool]
            var dateComponents = DateComponents()
            let timeStr = dict.get("descr") as! String
            dateComponents.hour = Int(timeStr.split(separator:":")[0])
            dateComponents.minute = Int(timeStr.split(separator:":")[1])
            for i in 0..<arrayTimeDaysState.count {
                if arrayTimeDaysState[i] {
                    switch i {
                    case 0:
                        dateComponents.weekday = 2 //Monday
                    case 1:
                        dateComponents.weekday = 3 //Tuesday
                    case 2:
                        dateComponents.weekday = 4 //Wednesday
                    case 3:
                        dateComponents.weekday = 5 //Thursday
                    case 4:
                        dateComponents.weekday = 6 //Friday
                    case 5:
                        dateComponents.weekday = 7 //Saturday
                    case 6:
                        dateComponents.weekday = 1 //Sunday
                    default:
                        return
                    }
                    
                    let requestIdentifier =  "\((dict["title"] as! String).replacingOccurrences(of: " ", with: "_"))#\(Utility.sharedInstance.randomString(length: 5))"
                    let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents,repeats: true)
                    let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: notificationTrigger)
                    
                    UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
                    UNUserNotificationCenter.current().add(request){(error) in
                        if (error != nil){
                            print(error?.localizedDescription as Any )
                        }
                    }
                }
            }
            
        } else {
            // Fallback on earlier versions
        }
    }
    
    // MARK: - Transit reminder handler
    
    func startTransitReminder(){
        if speed > 20 {
            let ref = FirebaseManager.shared.firebaseDP?.collection("reminder").whereField("user_UUID", isEqualTo: userUUID!).whereField("isReminderOn", isEqualTo: true).whereField("type", isEqualTo: "2")
            ref?.getDocuments(completion: { (snapshot, error) in
                if let snap = snapshot?.documents, snap.count > 0 {
                    for doc in snap{
                        
                        NSLog("***********************************************")
                        NSLog("Check previously triggered In transit Reminder")
                        
                        if self.totalIntrasitTimerCount > 60{
                            self.triggerInTransit()
                        }else{
                            timerIntrasit = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.calulateIntransit), userInfo: nil, repeats: true)
                        }
                      
                    }
                }
            })
        }
    }
    
    
    func triggerInTransit(){
        FirebaseManager.shared.checkLastTrigger(docID: doc.documentID, limit: 1, onCompletion: { (isShow) in
            if isShow {
                NSLog("***********************************************")
                NSLog("updateLastTrigger")
                let userDef = UserDefaults.standard
                userDef.setIntrasitTriggered(value: true)
                
                let blackOutTime = FirebaseManager.shared.getCurrentDate()
                userDef.setIntrasitLastTimeTrigger(value: blackOutTime)
                userDef.set(false, forKey: "BlackOutTime")
                userDef.synchronize()
                self.resetTravelTime()
                
                FirebaseManager.shared.updateLastTrigger(docID:  doc.documentID)
                self.handleTransitEvent(doc: doc)
            }
        })
    }
    
    func handleTransitEvent(doc:QueryDocumentSnapshot) {
        NSLog("Transit Notification will be triggered.")
        
        NSLog("***********************************************")
        NSLog("Notification Triggered")
        
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            let title = doc.get("title") as? String ?? ""
            NSLog(title)
            content.title = "Transit: \(title)"
//            content.subtitle = doc.get("subtitle") as? String ?? ""
//            content.body = doc.get("descr") as? String ?? ""
            
            
            
            let requestIdentifier =  "In-Transit:"
            content.sound = UNNotificationSound(named: "GICM_Notification.wav")
            let trigger =  UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.add(request) { (error) in
                if error != nil {
                    NSLog("Error adding notification with identifier in-transit")
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    // MARK: - Location reminder (Geo Fencing) handler
    
    func startGeoFencingFirebase(){
        
        NSLog("***********************************************")
        NSLog("startGeoFencingFirebase")
        
        self.stopGeoFencingFirebase()
        let ref = FirebaseManager.shared.firebaseDP?.collection("reminder").whereField("user_UUID", isEqualTo: userUUID!).whereField("isReminderOn", isEqualTo: true).whereField("isTime", isEqualTo: false)
        ref?.getDocuments(completion: { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0{
                for doc in snap{
                    if let l = doc.get("latitute") as? String, l.count>0{
                        let lat = Double(doc.get("latitute") as! String)
                        let long = Double(doc.get("longtitute")as! String)
                        let isArrive = doc.get("isArriving")as? Bool ?? true
                        let title = "\(doc.documentID)#\(doc.get("title") as? String ?? "0")"
                        let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: lat!,
                                                                                     longitude: long!), radius: regionRadius, identifier:  title)
                        if isArrive {
                            region.notifyOnEntry = true
                            region.notifyOnExit = false
                        }
                        else{
                            region.notifyOnEntry = false
                            region.notifyOnExit = true
                        }
                        self.locationManager.startMonitoring(for: region)
                    }
                }
            }
        })
    }
    
    func stopGeoFencingFirebase(){
        for reg in self.locationManager.monitoredRegions{
            print(self.locationManager.monitoredRegions)
            self.locationManager.stopMonitoring(for: reg)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let ident = (region.identifier.split(separator: "#")[0])
        FirebaseManager.shared.checkLastTrigger(docID: String(ident),limit: 20) { (isShow) in
            if isShow {
                self.handleEvent(forRegion: region, str: "Arriving:")
                FirebaseManager.shared.updateLastTrigger(docID: String(ident))
            }
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let ident = region.identifier.split(separator: "#")[0]
        FirebaseManager.shared.checkLastTrigger(docID: String(ident),limit: 20) { (isShow) in
            if isShow {
                self.handleEvent(forRegion: region, str: "Leaving:")
                FirebaseManager.shared.updateLastTrigger(docID: String(ident))
            }
        }
    }
    
    func handleEvent(forRegion region: CLRegion!,str:String) {
        NSLog("Location Notification will be triggered")
        
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            let title = region.identifier.split(separator: "#")[1]
            print(title)
            content.title = "\(str) \(title)"
            //content.subtitle = str
            content.body = Utilities.sharedInstance.getRandomQuotes()
            content.sound = UNNotificationSound(named: "GICM_Notification.wav")
            let trigger =  UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            NSLog("identifier:\(region.identifier)")
            let request = UNNotificationRequest(identifier: region.identifier, content: content, trigger: trigger)
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.add(request) { (error) in
                if error != nil {
                    NSLog("Error adding notification with identifier: \(region.identifier)")
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    // MARK: - Notification Delegates
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        NSLog("Tapped in notification")
        var identifier = response.notification.request.identifier
        identifier = String(identifier.split(separator: "#")[0])
        if identifier == "Project_Tracking:"{
            self.navigateToProjectList()
        }
        else if identifier == "Week_Preparation:"{
            self.navigateToApplyVC()
        }
        else if identifier == "In-Transit:"{
            self.navigateToBreathReset()
        }
        
    }
    
    //This is key callback to present notification while the app is in foreground
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        NSLog("Notification being triggered")
        completionHandler( [.alert,.sound,.badge])
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        NSLog("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        Messaging.messaging().apnsToken = deviceToken as Data
    }
}


struct AppFontName {
    static let regular  = "Nunito-Regular"
    static let bold     = "Nunito-Bold"
    static let italic   = "Nunito-Light"
    static let thin     = "Nunito-Medium"
}

extension UIFontDescriptor.AttributeName {
    static let nsctFontUIUsage = UIFontDescriptor.AttributeName(rawValue: "NSCTFontUIUsageAttribute")
}

extension UIFont {
    
    @objc class func mySystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.regular, size: size)!
    }
    
    @objc class func myBoldSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.bold, size: size)!
    }
    
    @objc class func myItalicSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.italic, size: size)!
    }
    
    @objc convenience init?(myCoder aDecoder: NSCoder) {
        guard
            let fontDescriptor = aDecoder.decodeObject(forKey: "UIFontDescriptor") as? UIFontDescriptor,
            let fontAttribute = fontDescriptor.fontAttributes[.nsctFontUIUsage] as? String else {
                self.init(myCoder: aDecoder)
                return
        }
        var fontName = ""
        switch fontAttribute {
        case "CTFontRegularUsage":
            fontName = AppFontName.regular
        case "CTFontEmphasizedUsage", "CTFontBoldUsage":
            fontName = AppFontName.bold
        case "CTFontObliqueUsage":
            fontName = AppFontName.italic
        default:
            fontName = AppFontName.regular
        }
        self.init(name: fontName, size: fontDescriptor.pointSize)
    }
    
    class func overrideInitialize() {
        guard self == UIFont.self else { return }
        
        if let systemFontMethod = class_getClassMethod(self, #selector(systemFont(ofSize:))),
            let mySystemFontMethod = class_getClassMethod(self, #selector(mySystemFont(ofSize:))) {
            method_exchangeImplementations(systemFontMethod, mySystemFontMethod)
        }
        
        if let boldSystemFontMethod = class_getClassMethod(self, #selector(boldSystemFont(ofSize:))),
            let myBoldSystemFontMethod = class_getClassMethod(self, #selector(myBoldSystemFont(ofSize:))) {
            method_exchangeImplementations(boldSystemFontMethod, myBoldSystemFontMethod)
        }
        
        if let italicSystemFontMethod = class_getClassMethod(self, #selector(italicSystemFont(ofSize:))),
            let myItalicSystemFontMethod = class_getClassMethod(self, #selector(myItalicSystemFont(ofSize:))) {
            method_exchangeImplementations(italicSystemFontMethod, myItalicSystemFontMethod)
        }
        
        if let initCoderMethod = class_getInstanceMethod(self, #selector(UIFontDescriptor.init(coder:))), // Trick to get over the lack of UIFont.init(coder:))
            let myInitCoderMethod = class_getInstanceMethod(self, #selector(UIFont.init(myCoder:))) {
            method_exchangeImplementations(initCoderMethod, myInitCoderMethod)
        }
    }
}

extension AppDelegate{
    @objc func calulateLeaderBoard() {
        // Something cool
        self.totalLeaderBoardTimerCount += 1
        print(totalLeaderBoardTimerCount)
    }
    
    
    @objc func calulateIntransit() {
        // Something cool
        self.totalIntrasitTimerCount += 1
        print(totalIntrasitTimerCount)
    }
    
    
}



