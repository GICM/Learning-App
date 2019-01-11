//
//  AppDelegate.swift
//  GICMLearningApp
//
//  Created by Rafi on 22/05/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
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
    var arrVal = ["sdf"]
    public var navigationContollerObj : UINavigationController! = nil
    var window: UIWindow?
    var speed:CLLocationSpeed = 0.0
    var oldLoc:CLLocation?
    var strCurrentCompany = ""
    var speedClosure : (()->Void)?
    var reachability = Reachability()!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
        
        FirebaseManager.shared.firebaseConfigure()
        
        // let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
        //  edgePan.edges = .left
        //  window?.addGestureRecognizer(edgePan)
        
        Fabric.with([Crashlytics.self])
        Fabric.sharedSDK().debug = true
        self.redirectConsoleLogToDocumentFolder()
        
        if let retrievedUUID: String = KeychainWrapper.standard.string(forKey: "uniqueStr"){
            userUUID = retrievedUUID
        }
        else
        {
            userUUID = (UIDevice.current.identifierForVendor?.uuidString)!
            KeychainWrapper.standard.set(userUUID!, forKey: "uniqueStr")
            FirebaseManager.shared.addReminderLocationFireBase(userID: userUUID!)
            FirebaseManager.shared.addReminderTimeFireBase(userID: userUUID!)
        }
        
        UserDefaults.standard.setUserUUID(value: userUUID!)
        print("UUID:\(userUUID!)")
        
        // Override point for customization after application launch.
        
        self.instaBug()
        setupLocationManager()
        IQKeyboardManager.sharedManager().enable = true
        
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
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
            }
        }
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    @objc func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        NotificationCenter.default.post(name: Notification.Name("NofifyReloadApply"), object: nil, userInfo: nil)
        switch reachability.connection {
        case .wifi:
            print("Reachable via WiFi")
            NotificationCenter.default.post(name: Notification.Name("NofifyOfflineCallback"), object: nil, userInfo: nil)
        case .cellular:
            print("Reachable via Cellular")
            NotificationCenter.default.post(name: Notification.Name("NofifyOfflineCallback"), object: nil, userInfo: nil)
        case .none:
            print("Network not reachable")
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
            print(invitedBy)
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
        print("message \(message)")
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
            print("link\(link)")
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
        let currentDate = Date()//NSDate(timeIntervalSinceNow: -1*24*60*60)
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
            
            print("Screen edge swiped!")
            
            let mainStoryboard = UIStoryboard(name: "ProfileStoryboard", bundle: nil)
            
            let vc = mainStoryboard.instantiateViewController(withIdentifier: "AdminVC") as! AdminVC
            let rootViewController = self.window!.rootViewController as! UINavigationController
            
            if (rootViewController.visibleViewController is CreateVC) || (rootViewController.visibleViewController is ViewController) || (rootViewController.visibleViewController is LoginViewController) || (rootViewController.visibleViewController is CreateViewController) {
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
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "TrackingStoryBoard", bundle: nil)
        if let vc = mainStoryboard.instantiateViewController(withIdentifier: "ApplyingListVC") as? ApplyingListVC , self.navigationContollerObj != nil {
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
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
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
                    print(error.debugDescription)
                }
            })
        } else {
            // Fallback on earlier versions
            
        }
        self.startGeoFencingFirebase()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("locations = \(String(describing: locations.first?.coordinate.latitude)) \(String(describing: locations.first?.coordinate.longitude))")
        print("speed\(String(describing: locations.last?.speed))")
        if oldLoc != nil{
            let distance = oldLoc?.distance(from: locations.last!)
            let time = locations.last?.timestamp.timeIntervalSince((oldLoc?.timestamp)!)
            speed = distance! / time!
            
        }else {
            speed = 0.0
        }
        
        oldLoc = locations.last
        
        //        speed = locations.last?.speed ?? 0
        //        speed = Double(speed) * 3.6 // meter per second to km per hour
        //  Utilities.sharedInstance.showToast(message: "speed:\(speed!)")
        
        if speed > 15 {
            self.startTransitReminder()
        }
        guard let closeAction = speedClosure else {
            return
        }
        closeAction()
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
        print("Time Notification will be triggered")
        
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = dict.get("title") as! String
            content.subtitle = dict.get("subtitle") as! String
            content.body = dict.get("body") as! String
            if dict["title"] as! String == "Project Tracking:"{
                content.title = ""
                content.subtitle = Utilities.sharedInstance.getRandomQuotes()
                content.body = "Reminder to track your project"
            }
            else if dict["title"] as! String == "Week Preparation:"{
                content.title = ""
                content.subtitle = Utilities.sharedInstance.getRandomQuotes()
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
                    print(requestIdentifier)
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
        
        if speed > 15 {
            self.redirectConsoleLogToDocumentFolder()
            let ref = FirebaseManager.shared.firebaseDP?.collection("reminder").whereField("user_UUID", isEqualTo: userUUID!).whereField("isReminderOn", isEqualTo: true).whereField("type", isEqualTo: "2")
            ref?.getDocuments(completion: { (snapshot, error) in
                if let snap = snapshot?.documents, snap.count > 0 {
                    for doc in snap{
                        
                        FirebaseManager.shared.checkLastTrigger(docID: doc.documentID, limit: 60, onCompletion: { (isShow) in
                            if isShow {
                                FirebaseManager.shared.updateLastTrigger(docID:  doc.documentID)
                                self.handleTransitEvent(doc: doc)
                            }
                        })
                    }
                }
            })
        }
    }
    
    
    func handleTransitEvent(doc:QueryDocumentSnapshot) {
        print("Transit Notification will be triggered.")
        
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            let title = doc.get("title") as? String ?? ""
            print(title)
            content.title = "\(title)"
            content.subtitle = doc.get("subtitle") as? String ?? ""
            content.body = doc.get("descr") as? String ?? ""
            content.sound = UNNotificationSound(named: "GICM_Notification.wav")
            let trigger =  UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: doc.documentID, content: content, trigger: trigger)
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.add(request) { (error) in
                if error != nil {
                    print("Error adding notification with identifier in-transit")
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    // MARK: - Location reminder (Geo Fencing) handler
    
    func startGeoFencingFirebase(){
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
        FirebaseManager.shared.checkLastTrigger(docID: String(ident),limit: 15) { (isShow) in
            if isShow {
                self.handleEvent(forRegion: region, str: "Arriving at your location")
                FirebaseManager.shared.updateLastTrigger(docID: String(ident))
            }
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let ident = region.identifier.split(separator: "#")[0]
        FirebaseManager.shared.checkLastTrigger(docID: String(ident),limit: 15) { (isShow) in
            if isShow {
                self.handleEvent(forRegion: region, str: "Leaving your location")
                FirebaseManager.shared.updateLastTrigger(docID: String(ident))
            }
        }
    }
    
    func handleEvent(forRegion region: CLRegion!,str:String) {
        print("Location Notification will be triggered")
        
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            let title = region.identifier.split(separator: "#")[1]
            print(title)
            content.title = "\(title)"
            content.subtitle = str
            content.body = "Use the time mindfully"
            content.sound = UNNotificationSound(named: "GICM_Notification.wav")
            let trigger =  UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            print("identifier:\(region.identifier)")
            let request = UNNotificationRequest(identifier: region.identifier, content: content, trigger: trigger)
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.add(request) { (error) in
                if error != nil {
                    print("Error adding notification with identifier: \(region.identifier)")
                }
            }
            
            
        } else {
            // Fallback on earlier versions
        }
    }
    
    // MARK: - Notification Delegates
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Tapped in notification")
        var identifier = response.notification.request.identifier
        identifier = String(identifier.split(separator: "#")[0])
        if identifier == "Project_Tracking:"{
            self.navigateToProjectList()
        }
        else if identifier == "Week_Preparation:"{
            self.navigateToApplyVC()
        }
        
    }
    
    //This is key callback to present notification while the app is in foreground
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Notification being triggered")
        completionHandler( [.alert,.sound,.badge])
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
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






