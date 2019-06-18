//
//  ViewController.swift
//  GICMLearningApp
//
//  Created by Rafi on 22/05/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import SDWebImage
import HGCircularSlider
import Firebase
import FirebaseFirestore
import os.log
import UserNotifications
import AVFoundation

class ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate{
    
    //MARK:- Initialization
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var imgProfilePhoto: UIImageView!
    // @IBOutlet weak var lblQuotes: UILabel!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var lblMinutes: UILabel!
    @IBOutlet weak var lblHours: UILabel!
    @IBOutlet weak var lblAppUsedStatus: UILabel!
    @IBOutlet weak var circularView: CircularSlider!
    @IBOutlet weak var lblClock: UILabel!
    @IBOutlet weak var vwQuotes: UIView!
    @IBOutlet weak var btnRelease: UIButton!
    @IBOutlet weak var lblSpeedLimit: UILabel!
    
    //Timer
    var quote = ""
    var quoteID = ""
    var quoteStatus = ""
    var strMin   = 45
    var strHours = 00
    let userId = UserDefaults.standard.getUserID()
    
    //Array
    var arrLikeQuotesFirebase : [QueryDocumentSnapshot] = []
    var arrayListofComment : [ListofQuotes.CommentData] = []
    
    
    @IBOutlet weak var lblInitialization: UILabel!
    @IBOutlet weak var collVwQuotes: UICollectionView!
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    
    //Splash Screen
    @IBOutlet var vwSplash: UIView!
    @IBOutlet weak var imgComapny: UIImageView!
    @IBOutlet weak var imgLike: UIImageView!
    @IBOutlet weak var lblQuotes: UILabel!
    var timer = Timer()
    var strCurrentCompany = ""
    @IBOutlet var vwbackGround: UIView!
    
    var lastQuote = UserDefaults.standard.string(forKey: "quotes") ?? Utilities.sharedInstance.getRandomQuotes()
    
    //For vedio
    var avPlayer: AVPlayer!
    var avPlayerLayer: AVPlayerLayer!
    var paused: Bool = false
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //backGround View
        self.view.isUserInteractionEnabled = false

        self.vwSplash.frame = self.view.frame
        self.view.addSubview(self.vwSplash)

        self.addBackgroundVideo()
        self.vwbackGround.frame = self.view.frame
        self.view.addSubview(self.vwbackGround)
        self.checkUsersLikeQuotesFirebase()
        self.getQuotesFirebase()
        self.applyingList()
        self.updateLastQuote()
        //  currentCompany()
        Constants.appDelegateRef.navigationContollerObj = self.navigationController
        Constants.appDelegateRef.speedClosure = {
            self.speed()
        }
        
        if ((UserDefaults.standard.string(forKey: "isSynch")) == nil){
           
            FirebaseManager.shared.countTotal = 32
            FirebaseManager.shared.deleteUserData()
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
        else{
            FirebaseManager.shared.countTotal = 17
            FirebaseManager.shared.startSync()
        }
        
        FirebaseManager.shared.showProgressView()
        FirebaseManager.shared.onCompleteShync = {
            self.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.HideprogressBar), userInfo: nil, repeats: false)
        }
    }
    
    @objc func HideprogressBar(){
        FirebaseManager.shared.hideProgress()
        self.view.isUserInteractionEnabled = true
      //  self.lblInitialization.isHidden = true
        self.lblInitialization.text = "Tap to continue"
        self.timer.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configUI()
    }
    
    func applyingList(){
        let check = UserDefaults.standard.bool(forKey: "ApplyAdded") as? Bool ?? false
        if check == false{
            let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "1.4"
           self.applyListVesionBased(appVersion: appVersion)
        }else{
            print("ApplyListalready Added")
        }
    }
    
    func applyListVesionBased(appVersion: String){
        let version = appVersions.init(rawValue: appVersion)
        var arrApplyList = [String]()
        switch version {
        case .weeklyPlan?:
             arrApplyList = ["Weekly planner"]
        case .meetingManager?:
            arrApplyList = ["Meeting Manager"]
        case .tracking?:
            arrApplyList = ["Tracking"]
        case .capture?:
            arrApplyList = ["Capture"]
        default:
            print("Default")
        }
        
        UserDefaults.standard.set(arrApplyList, forKey: "ApplyList")
        UserDefaults.standard.synchronize()
    }
    
    
    func addBackgroundVideo(){
        
        let theURL = Bundle.main.url(forResource: "bg_video", withExtension: "mp4")
        avPlayer = AVPlayer(url: theURL!)
        avPlayerLayer = AVPlayerLayer(player: self.avPlayer)
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        avPlayer.volume = 0
        avPlayer.actionAtItemEnd = AVPlayerActionAtItemEnd.none
        
        avPlayerLayer.frame = self.view.frame
        vwSplash.layer.insertSublayer(self.avPlayerLayer, at: 0)
        avPlayer.play()
       
    }

    
    //MARK:- Local Methods
    func configUI(){
        
        // addCourse()
//        circularView.minimumValue = 0.5
//        circularView.maximumValue = 12.0
//        circularView.endPointValue = 1.0
//        circularView.thumbLineWidth = 0
        
        strHours = UserDefaults.standard.integer(forKey: "Hour")
        strMin = UserDefaults.standard.integer(forKey: "Minutes")
        
//        if strMin > 5{
//            strMin = UserDefaults.standard.integer(forKey: "Minutes")
//            circularView.endPointValue = CGFloat(strMin/5)
//        }else{
//            circularView.endPointValue = 1.0
//        }
        
        //Spalsh Screen View
        
        
        
       // self.updateTexts()
      //  circularView.addTarget(self, action: #selector(updateTexts), for: .valueChanged)
        
        checkUserLastUse()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.navigationBar.isHidden = true
        
        let userName =   UserDefaults.standard.getUserName()
        let userProile = UserDefaults.standard.getProfileImage()
        labelUsername.text = userName
        imgProfilePhoto.layer.cornerRadius = 60
        imgProfilePhoto.clipsToBounds      = true
        //        imgProfilePhoto.sd_setImage(with: URL(string: userProile), placeholderImage: UIImage(named: "No Name"))
        if let dataDecoded : Data = Data(base64Encoded: userProile){
            if let image = UIImage(data: dataDecoded)
            {
                self.imgProfilePhoto.image = image
            }
        }
        btnRelease.setTitle("Version 0.26", for: .normal)
    }
    
    //Speed
    func speed(){
        let mySpeedDouble = Constants.appDelegateRef.speed
        let doubleStr = String(format: "%.2f", mySpeedDouble) // "3.14"
        lblSpeedLimit.text  =  " Speed : \(doubleStr)  "
    }
    
    //Timer Calculation
    @objc func updateTexts() {
        let value = circularView.endPointValue > 1 ? circularView.endPointValue : 1.0
        let min = Int(value) * 5
        lblClock.text = "\(min) Min"
        strMin = min
        UserDefaults.standard.set(strMin, forKey: "Minutes")
        UserDefaults.standard.set(strHours, forKey: "Hour")
        UserDefaults.standard.synchronize()
    }
    
    //MARK:- Check User last Use
    func checkUserLastUse(){
        var appUsedDate = Date()
        if UserDefaults.standard.object(forKey: "lastUsed") != nil  {
            appUsedDate = UserDefaults.standard.object(forKey: "lastUsed") as! Date
        }
        
            let userLastUsed = appUsedDate.daysBetweenDate(toDate: Date())
        
        print(userLastUsed)
        //        if userLastUsed >= 1{
        // UserDefaults.standard.setLoggedIn(value: false)
        currnetQuotes()
        print("Logout ")
        //        }else{
        //            //            let LogedIn = UserDefaults.standard.isLoggedIn()
        //            //            if LogedIn{
        //            //                // gotoDashBoard()
        //            //                currnetQuotes()
        //            //                self.timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.dashBoard), userInfo: nil, repeats: false)
        //            //                //  return
        //            //            }else{
        //            //self.vwbackGround.isHidden = true
        //            Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.splashScreen), userInfo: nil, repeats: false)
        //            print("Logout Already")
        //            //            }
        //        }
    }
    
    func currnetQuotes(){
        if lastQuote != nil{
            self.lblQuotes.text = lastQuote
        }
        else{
            self.lblQuotes.text = Utilities.sharedInstance.getRandomQuotes()
        }
        self.strCurrentCompany = UserDefaults.standard.string(forKey: "CurrentCompany") ?? "AppLogo"
        print(" Company \(strCurrentCompany)")
        
        self.imgComapny.image = UIImage(named: "AppLogo")
        self.vwSplash.isHidden = false
        self.vwbackGround.isHidden = true
    }
    
    func statusOfQuotes(){
        let visibleIndexPaths = collVwQuotes.indexPathsForVisibleItems
        let modelObj = arrayListofComment[visibleIndexPaths[0].row]
        let status = modelObj.status ?? "0"
        
        if status == "0"{
            self.imgLike.image = #imageLiteral(resourceName: "Like")
        }else if status == "1"{
            self.imgLike.image = #imageLiteral(resourceName: "Liked")
        }else if status == "2"{
            self.imgLike.image = #imageLiteral(resourceName: "unLike")
        }else{
            self.imgLike.image = #imageLiteral(resourceName: "Like")
        }
    }
    
    @objc func dashBoard() {
        // Something cool
        self.timer.invalidate()
        FirebaseManager.shared.hideProgress()
        gotoDashBoard()
    }
    
    @objc func splashScreen() {
        // Something cool
        // gotoDashBoard()
        self.vwbackGround.isHidden = true
    }
    
    
    //MARK:- Navigateto DashBoasr
    func gotoDashBoard(){
        let vc = Utilities.sharedInstance.viewControllerWithName(identifier: Constants.StoryboardIdentifier.tabbar) as! TabBarViewController
        //  vc.tabBar.selectedItem = UITabBarItem(tabBarSystemItem: .more, tag: 1)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //Check Current Company
    //    func currentCompany(){
    //        let refCompanyUser = FirebaseManager.shared.firebaseDP!.collection("companies_user").whereField("user_id", isEqualTo: userId)
    //        refCompanyUser.getDocuments { (snapshot, error) in
    //            if let snap = snapshot?.documents, snap.count > 0{
    //
    //                self.strCurrentCompany = snap[0].get("company_name") as? String ?? "Select Company"
    //
    //                 print(" Company \(self.strCurrentCompany)")
    //                self.imgComapny.image = UIImage(named: self.strCurrentCompany)
    ////                UserDefaults.standard.set(currentCompany, forKey: "CurrentCompany")
    ////                UserDefaults.standard.synchronize()
    //            }
    //            else{
    //                self.strCurrentCompany = UserDefaults.standard.string(forKey: "CurrentCompany") ?? ""
    ////                UserDefaults.standard.set("", forKey: "CurrentCompany")
    ////                UserDefaults.standard.synchronize()
    //            }
    //
    //        }
    //    }
    
    func addCourse(){
        // create
        let refCompany = FirebaseManager.shared.firebaseDP!.collection("courseList")
        if let path = Bundle.main.path(forResource: "CourseList", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonCourse = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                
                refCompany.addDocument(data: jsonCourse as! [String: Any], completion: {(error) in
                    print("the create company error:\(error.debugDescription)")
                })
            } catch {
                // handle error
            }
        }
    }
    
    
    //    func add(){
    //        _ = FirebaseManager.shared.firebaseDP!.collection("projects").addDocument(data: self.getAddProjectJSON(), completion: { (err) in
    //            if err  != nil{
    //                print("add Project Error: \(String(describing: err?.localizedDescription))")
    //                Utilities.displayFailureAlertWithMessage(title: "Attention!", message: "Project creation has failed, try agian later", controller: self)
    //            }
    //            else
    //            {
    //                self.updateProjectID()
    //                Utilities.showSuccessFailureAlertWithDismissHandler(title: "success!", message: "Project has created successfully", controller: self, alertDismissed: { (_) in
    //                    self.navigationController?.popViewController(animated: true)
    //                })
    //            }
    //        })
    //    }
    //MARK: - UIButton Action Methods
    @IBAction func releaseNotes(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = mainStoryboard.instantiateViewController(withIdentifier: "ReleaseNotesVC") as! ReleaseNotesVC      //  let vc =
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func LikeAction(_ sender: Any) {
        if arrayListofComment.count > 0{
        let visibleIndexPaths = collVwQuotes.indexPathsForVisibleItems
        let modelObj = arrayListofComment[visibleIndexPaths[0].row]
        self.quoteID = modelObj.q_id ?? ""
        if imgLike.image == #imageLiteral(resourceName: "Like"){
            imgLike.image = #imageLiteral(resourceName: "Liked")
            self.quoteStatus = "1"
        }else  if imgLike.image == #imageLiteral(resourceName: "Liked"){
            imgLike.image = #imageLiteral(resourceName: "unLike")
            self.quoteStatus = "2"
        }else  if imgLike.image == #imageLiteral(resourceName: "unLike"){
            imgLike.image = #imageLiteral(resourceName: "Like")
            self.quoteStatus = "0"
        }
        self.arrayListofComment[visibleIndexPaths[0].row].status = self.quoteStatus
        self.collVwQuotes.reloadData()
        self.likeQuotesISLFirebase()
        }else{
            return
        }
    }
    
    @IBAction func StopSlashScreen(_ sender: Any) {
        self.timer.invalidate()
        self.dashBoard()
        //self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.dashBoard), userInfo: nil, repeats: false)
    }
    
    @IBAction func buttonLoginPressed(_ sender: UIButton) {
        let LogedIn = UserDefaults.standard.isLoggedIn()
        if LogedIn{
            let vc = Utilities.sharedInstance.viewControllerWithName(identifier: Constants.StoryboardIdentifier.tabbar) as! TabBarViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let vc = Utilities.sharedInstance.viewControllerWithName(identifier: Constants.StoryboardIdentifier.loginVC) as! LoginViewController
            UserDefaults.standard.set("", forKey: "email")
            UserDefaults.standard.set("", forKey: "password")
            UserDefaults.standard.synchronize()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    @IBAction func learning(_ sender: Any) {
        //        let vc = Utilities.sharedInstance.viewControllerWithName(identifier: Constants.StoryboardIdentifier.tabbar) as! TabBarViewController
        //        vc.selectedIndex = 0
        //        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func applying(_ sender: Any) {
        let vc = Utilities.sharedInstance.viewControllerWithName(identifier: Constants.StoryboardIdentifier.tabbar) as! TabBarViewController
        vc.selectedIndex = 1
        //Utility.sharedInstance.clearAllUserdata()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func creating(_ sender: Any) {
        let vc = Utilities.sharedInstance.viewControllerWithName(identifier: Constants.StoryboardIdentifier.tabbar) as! TabBarViewController
        vc.selectedIndex = 1
        //  Utility.sharedInstance.clearAllUserdata()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func MinutesMinus(_ sender: UIButton){
        if strMin > 0{
            strMin -= 15
            lblMinutes.text = "\(strMin)"
            if strMin == 0{
                lblMinutes.text = "\(strMin)"
                strMin = 60
            }
        }
        UserDefaults.standard.set(strMin, forKey: "Minutes")
        UserDefaults.standard.synchronize()
    }
    
    func getQuotesFirebase()
    {
        let ref = FirebaseManager.shared.firebaseDP!.collection("quotes_likes").whereField("user_id", isEqualTo: userId)
        ref.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                self.arrLikeQuotesFirebase = snap
            }
            let ref2 = FirebaseManager.shared.firebaseDP!.collection("quotes")
            ref2.getDocuments(completion: { (snapshot, error) in
                if let snap = snapshot?.documents,snap.count>0 {
                    for snapEach in snap{
                        var quote = ListofQuotes.CommentData()
                        quote.q_id = snapEach.get("q_id") as? String ?? ""
                        quote.quotes = snapEach.get("quotes") as? String ?? ""
                        quote.status = snapEach.get("status") as? String ?? ""
                        if let q_id = quote.q_id {
                            if let status = self.arrLikeQuotesFirebase.filter({$0.get("q_id") as? String ?? "" == q_id}).first?.get("status") as? String {
                                quote.status = status
                            }
                        }
                        self.arrayListofComment.append(quote)
                    }
                    let arrQuotes = self.arrayListofComment.map({$0.quotes})
                    UserDefaults.standard.set(arrQuotes, forKey: "QuotesList")
                    UserDefaults.standard.synchronize()
                    self.reloadCollectionQuotes()
                }
                else
                {
                    print("Get quotes details Error: \(String(describing: error?.localizedDescription))")
                }
                
            })
        }
    }
    
    func reArrangeQuotes(){
        if let index = self.arrayListofComment.index(where: {$0.quotes ==  lastQuote}) {
            let quoteObj =  self.arrayListofComment[index]
            self.arrayListofComment.remove(at: index)
            self.arrayListofComment.insert(quoteObj, at: 0)
        }
    }
    
    func updateLastQuote()
    {
        UNUserNotificationCenter.current().getDeliveredNotifications { (notify) in
            if notify.count > 0 {
                let lastNotify = notify.first
                let identifier = lastNotify?.request.identifier
                DispatchQueue.main.async {
                    if (identifier?.range(of:"Project_Tracking:") != nil) || (identifier?.range(of:"Week_Preparation:") != nil) {
                        print("exists notify")
                        UserDefaults.standard.set(lastNotify?.request.content.subtitle, forKey: "quotes")
                        UserDefaults.standard.synchronize()
                    }
                    self.getQuotesFirebase()
                }
            }else{
                self.getQuotesFirebase()
            }
        }
        
    }
    
    func reloadCollectionQuotes()
    {
        lastQuote = UserDefaults.standard.string(forKey: "quotes") ?? Utilities.sharedInstance.getRandomQuotes()
        self.lblQuotes.text = lastQuote
        print("last quotess:\(String(describing: lastQuote))")
        
        self.reArrangeQuotes()
        self.collVwQuotes.reloadData()
    }
    
    func checkUsersLikeQuotesFirebase()
    {
        let ref = FirebaseManager.shared.firebaseDP!.collection("quotes_likes").whereField("user_id", isEqualTo: userId)
        ref.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                self.arrLikeQuotesFirebase = snap
            }
        }
    }
    
    //MARK: - File Download API
    func getLikeQuotesJSON() -> [String:Any]{
        return ["user_id" : userId,
                "q_id" : quoteID,
                "status" : quoteStatus
        ]
    }
    
    func likeQuotesISLFirebase()
    {
        let ref = FirebaseManager.shared.firebaseDP!.collection("quotes_likes").whereField("user_id", isEqualTo: userId).whereField("q_id", isEqualTo: self.quoteID)
        ref.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                
                // update like
                let documentID = snap[0].documentID
                let refExist = FirebaseManager.shared.firebaseDP!.collection("quotes_likes").document(documentID)
                refExist.updateData(self.getLikeQuotesJSON(), completion: { (error) in
                    print("quotes like Error: \(String(describing: error?.localizedDescription))")
                })
            }
            else
            {
                //insert like if new
                _ = FirebaseManager.shared.firebaseDP!.collection("quotes_likes").addDocument(data: self.getLikeQuotesJSON(), completion: { (err) in
                    if err  != nil{
                        print("quotes like Error: \(String(describing: err?.localizedDescription))")
                    }
                })
            }
        }
    }
    
    @IBAction func likeUnlike(_ sender: Any) {
        let pointInTable: CGPoint = (sender as AnyObject).convert((sender as AnyObject).bounds.origin, to: self.collVwQuotes)
        let cellIndexPath = self.collVwQuotes.indexPathForItem(at: pointInTable)
        //indexPathForRow(at: pointInTable)
        
        let projectObj = self.arrayListofComment[(cellIndexPath?.row)!]
        self.quoteID = projectObj.q_id!
        
        let cell = collVwQuotes.cellForItem(at: cellIndexPath!) as? QuotesCell
        // cell?.lblWork.text = "\(value) hrs"
        if cell?.btnLike.currentImage == #imageLiteral(resourceName: "Like"){
            self.quoteStatus = "1"
        }else if cell?.btnLike.currentImage == #imageLiteral(resourceName: "Liked") {
            self.quoteStatus = "2"
        }else if cell?.btnLike.currentImage == #imageLiteral(resourceName: "unLike"){
            self.quoteStatus = "0"
        }
        self.arrayListofComment[(cellIndexPath?.row)!].status = self.quoteStatus
        collVwQuotes.reloadData()
        self.likeQuotesISLFirebase()
    }
    
    //MARK:- Collection View delegate methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayListofComment.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuotesCell", for: indexPath) as! QuotesCell
        
        let modelObj = arrayListofComment[indexPath.row]
        
        if (modelObj.quotes?.contains("Conficius")) ?? false {
    
            
            let string = (modelObj.quotes ?? "").components(separatedBy: "-")
            let normalText = string[0]
            
            let boldText  = " -\(string[1])"
            
            
            let attrs = [NSAttributedStringKey.font : UIFont(name:"Nunito-Regular", size: 16.0)]
            let attributedString = NSMutableAttributedString(string:boldText, attributes:attrs as [NSAttributedStringKey : Any])
            

            let normalString = NSMutableAttributedString(string:normalText)
            
            normalString.append(attributedString)
            cell.lblQuotes.attributedText = normalString
        
        }
        else {
            cell.lblQuotes.font = UIFont(name:"Nunito-SemiBold", size: 17.0)
            cell.lblQuotes.text = modelObj.quotes ?? ""
        }
        
        cell.checkImage(like: modelObj.status ?? "0")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collVwQuotes.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.statusOfQuotes()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "LearningView") {
            let vc = segue.destination as! TabBarViewController
            vc.selectedIndex = 0
            //   Utility.sharedInstance.clearAllUserdata()
        }
    }
}

extension Array {
    /// Returns an array containing this sequence shuffled
    var shuffled: Array {
        var elements = self
        return elements.shuffle()
    }
    /// Shuffles this sequence in place
    @discardableResult
    mutating func shuffle() -> Array {
        let count = self.count
        indices.lazy.dropLast().forEach {
            swapAt($0, Int(arc4random_uniform(UInt32(count - $0))) + $0)
        }
        return self
    }
    var chooseOne: Element { return self[Int(arc4random_uniform(UInt32(count)))] }
    func choose(_ n: Int) -> Array { return Array(shuffled.prefix(n)) }
}




