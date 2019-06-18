//
//  ShowContentViewController.swift
//  GICMLearningApp
//
//  Created by Rafi on 29/05/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import QuickLook
import MobileCoreServices
import FirebaseStorage
import PDFGenerator
import WebKit

class ShowContentViewController: UIViewController,  UIDocumentInteractionControllerDelegate,UIDocumentPickerDelegate{
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var landscapeView: UIView!
    @IBOutlet weak var imgLandscape: UIImageView!
    
    public var subContent =  ""
    var downloadTask: URLSessionDownloadTask!
    var backgroundSession: URLSession!
    var strFileName = ""
    let webManager = WebserviceManager.shared
    let refStorage = Storage.storage().reference()
    var docController: UIDocumentInteractionController?
    var timer = Timer()
    //File upload
    var documentType: URL!
    var viewContPdf: UIView!
    var load : Int = 0
    var docCount : Int = 0
    var docIndex : Int = 0

    var y1 : CGFloat = 0.0
    var arrayDocs : [String] = ["uploads/MECE.txt","uploads/IMG_2161.jpg","uploads/doc1.doc","uploads/doc2.ppt","uploads/doc3.txt","uploads/doc4.pdf","uploads/doc5.jpg","uploads/doc6.mp4"]
    
    var actionButton: ActionButton!
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NSLog("***********************************************")
        NSLog("Show Content  View Controller View did load  ")
        
        let appdelegateRef = Constants.appDelegateRef
        appdelegateRef.timerLeader = Timer.scheduledTimer(timeInterval: 1, target: appdelegateRef, selector: #selector(appdelegateRef.calulateLeaderBoard), userInfo: nil, repeats: true)
        
         self.aniumationButtons()
        NotificationCenter.default.post(name: Notification.Name("NotifyHideMenu"), object: nil, userInfo: nil)
        Utility.sharedInstance.isShowMenu = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
       self.navigationController?.isNavigationBarHidden = true
        AppUtility.lockOrientation(.allButUpsideDown, andRotateTo: .unknown)
       
       // self.title = ""
        configUI()
        print(strFileName)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        Utility.sharedInstance.isShowMenu = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.actionButton.items?.removeAll()
         self.aniumationButtons()
    }

    
//    override func viewWillDisappear(_ animated: Bool) {
//        self.navigationController?.isNavigationBarHidden = false
//    }
    
    //MARK:- Orientaion Check
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        NotificationCenter.default.post(name: Notification.Name("NotifyHideMenu"), object: nil, userInfo: nil)
        Utility.sharedInstance.isShowMenu = false
        
        DispatchQueue.main.async {
            //        self.landscapeView.frame = self.view.frame
            //        self.imgLandscape.frame = self.landscapeView.frame

            self.actionButton.items?.removeAll()
            self.aniumationButtons()
            switch UIDevice.current.orientation{
            case .portrait:
                self.imgLandscape.isHidden = false
               // self.view.isUserInteractionEnabled = false
              //  self.aniumationButtons()
            case .landscapeLeft:
                self.imgLandscape.isHidden = true
              //  self.view.isUserInteractionEnabled = true
              //   self.aniumationButtons()
            case .landscapeRight:
                self.imgLandscape.isHidden = true
               // self.view.isUserInteractionEnabled = true
                // self.aniumationButtons()
            default:
                break
            }
        }
    }
    
    func CheckOrientation(){
        DispatchQueue.main.async {
            //        self.landscapeView.frame = self.view.frame
            //        self.imgLandscape.frame = self.landscapeView.frame
            
            switch UIDevice.current.orientation{
            case .portrait:
                self.imgLandscape.isHidden = false
                // self.view.isUserInteractionEnabled = false
            //  self.aniumationButtons()
            case .landscapeLeft:
                self.imgLandscape.isHidden = true
                //  self.view.isUserInteractionEnabled = true
            //   self.aniumationButtons()
            case .landscapeRight:
                self.imgLandscape.isHidden = true
                // self.view.isUserInteractionEnabled = true
            // self.aniumationButtons()
            default:
                break
            }
        }
    }
    
    //MARK:- Local Methods
    func configUI(){
        
        AppUtility.lockOrientation(.allButUpsideDown, andRotateTo: .unknown)
        // Do any additional setup after loading the view.
       determineMyDeviceOrientation()
        viewContPdf = UIView.init()

    // self.getPDFIndividual()
        self.downloadAndLoadDocs()
    }
   
    
    func downloadAndLoadDocs(){
        
       // arrayDocs[docIndex] Previous Model
        
        _ = refStorage.child(self.subContent).downloadURL { (durl, error) in
            if error == nil{
                print(durl!)
               self.webView.loadRequest(URLRequest(url: durl!))
            }else{
                print(error)
            }
            }
    }
    
    func getPDFIndividual(){
        _ = refStorage.child(arrayDocs[docCount]).downloadURL { (durl, error) in
            if error == nil{
                    let view = UIWebView.init()
                    view.delegate = self
                    view.loadRequest(URLRequest(url: durl!))
                view.frame = CGRect(x: 0.0, y: self.y1, width: self.view.frame.size.width, height: self.view.frame.size.height)
                self.y1 = self.y1 +  self.view.frame.size.height
                    self.viewContPdf.addSubview(view)
                self.viewContPdf.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height:self.y1)
                //self.webView.loadRequest(URLRequest(url: durl!))
                self.docCount = self.docCount + 1
                if(self.docCount < self.arrayDocs.count){
                self.getPDFIndividual()
                }
            }
        }
    }
    
    func aniumationButtons(){
        
        let upload = ActionButtonItem(title: "Submit changes", image: #imageLiteral(resourceName: "cloud-backup-up-arrow"))
        upload.action = { item in
            print("Upload...")
            
            let types = [(kUTTypeData as String), (kUTTypeContent as String), (kUTTypePDF as String), (kUTTypeText as String), (kUTTypePlainText as String), (kUTTypeXML as String), (kUTTypeJSON as String), (kUTTypeImage as String), (kUTTypeAudiovisualContent as String),(kUTTypeRTF as String),(kUTTypeJavaScript as String)]
            
            let documentPicker = UIDocumentPickerViewController(documentTypes: types as [String], in: .import)
            documentPicker.delegate = self
            self.present(documentPicker, animated: true, completion: nil)
            
        }
        
        let download = ActionButtonItem(title: "Edit", image:#imageLiteral(resourceName: "Download"))
        download.action = { item in
            print("Download...")
            
//            _ = self.refStorage.child(self.arrayDocs[self.docIndex]).getData(maxSize: 1 * 1024 * 1024, completion: { (dataFile, error) in
//                if error == nil{
//                    let file = "file.txt"
//                    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
//                        let fileURL = dir.appendingPathComponent(file)
//                        do {
//                            try dataFile?.write(to: fileURL)
//                           // self.showFileWithPath(urlShare: fileURL)
//                        }
//                        catch {/* error handling here */}
//                    }
//                }
//            })

        }
        
        let share = ActionButtonItem(title: "Share", image:#imageLiteral(resourceName: "share-outlined-sign"))
        share.action = { item in
            print("Share...")
            
            _ = self.refStorage.child(self.arrayDocs[self.docIndex]).getData(maxSize: 1 * 1024 * 1024, completion: { (dataFile, error) in
                if error == nil{
                    let file = "file.txt"
                    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                        let fileURL = dir.appendingPathComponent(file)
                        do {
                            try dataFile?.write(to: fileURL)
                            self.showFileWithPath(urlShare: fileURL)
                        }
                        catch {/* error handling here */}
                    }
                }
            })
        }
        
        
        let cancel = ActionButtonItem(title: "Learning Map", image: #imageLiteral(resourceName: "cancel"))
        cancel.action = { item in
            print("Cancel...")
            self.addLeaderBoardAPI()
            let appde = Constants.appDelegateRef

        }
        
        actionButton = ActionButton(attachedToView: self.view, items: [upload, share,download,cancel])
        actionButton.action = { button in button.toggleMenu() }
        actionButton.setTitle("+", forState: UIControlState())
        actionButton.backgroundColor = #colorLiteral(red: 0.2509803922, green: 0.6431372549, blue: 0.03921568627, alpha: 1)
        
    }
    func loadDocs(){
        do {
            let dst = URL(fileURLWithPath: NSTemporaryDirectory().appending("sample1.pdf"))
            
            let data = try PDFGenerator.generated(by: self.viewContPdf.subviews)
            try data.write(to: dst, options: .atomic)
            self.webView.loadRequest(URLRequest(url: dst))
            
        } catch (let error) {
            print(error)
        }
    }
    
    func navigateTolearninfgScreen(){
        for controller in self.navigationController!.viewControllers as Array
        {
            print(self.navigationController!.viewControllers as Array);
            
            if controller is LearningViewController
            {
                let _ =  self.navigationController?.popToViewController(controller as UIViewController, animated: true)
                break
            }
        }
    }
    
    func determineMyDeviceOrientation()
    {
        DispatchQueue.main.async {
            if UIDevice.current.orientation.isPortrait {
                print("Device is in landscape mode")
                self.landscape()
                
            } else {
                print("Device is in portrait mode")
                self.portaid()
            }
        }
    }
    
    func portaid(){
        DispatchQueue.main.async {
            self.imgLandscape.isHidden = false
           //self.view.isUserInteractionEnabled = false
        }
    }
    
    func landscape(){
        DispatchQueue.main.async {
            self.imgLandscape.isHidden = true
         //   self.view.isUserInteractionEnabled = true
        }
    }
    
    @objc func updateQuotes() {
        timer.invalidate()
        webManager.hideMBProgress(view: self.view)
    }
    
    //MARK: - UIButton Action Methods
    @IBAction func buttonBackPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func reUpload(_ sender: UIButton) {
        
        let types = [(kUTTypeData as String), (kUTTypeContent as String), (kUTTypePDF as String), (kUTTypeText as String), (kUTTypePlainText as String), (kUTTypeXML as String), (kUTTypeJSON as String), (kUTTypeImage as String), (kUTTypeAudiovisualContent as String),(kUTTypeRTF as String),(kUTTypeJavaScript as String)]
        
        let documentPicker = UIDocumentPickerViewController(documentTypes: types as [String], in: .import)
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    
    @IBAction func shareFile(_ sender: UIButton) {

                        _ = refStorage.child(arrayDocs[docIndex]).getData(maxSize: 1 * 1024 * 1024, completion: { (dataFile, error) in
                            if error == nil{
                                let file = "file.txt"
                                if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                                    let fileURL = dir.appendingPathComponent(file)
                                    do {
                                       try dataFile?.write(to: fileURL)
                                        self.showFileWithPath(urlShare: fileURL)
                                    }
                                    catch {/* error handling here */}
                                }
                            }
                        })
        
        
    }
    
    func showFileWithPath(urlShare: URL){
        docController = UIDocumentInteractionController(url: urlShare)
        docController?.delegate = self
        docController?.presentOptionsMenu(from: view.frame, in: UIApplication.shared.windows[0].rootViewController!.view, animated: true)
}
    
    
    func topMostController() -> UIViewController? {
        var topController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        while ((topController?.presentedViewController) != nil) {
            topController = topController?.presentedViewController
        }
        return topController
    }
    
    //MARK: UIDocumentPickerDelegate
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
         self.CheckOrientation()
    }
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController){
         self.CheckOrientation()
    }
}
//MARK: - UIWebViewDelegate Methods
extension ShowContentViewController : UIWebViewDelegate{
    func webViewDidStartLoad(_ webView: UIWebView) {
        WebserviceManager.shared.showMBProgress(view: self.view)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView){
        // the below commented need for merge pdf concepts
//        load = load + 1
//        if(load == self.viewContPdf.subviews.count) {
//            self.loadDocs()
//        }
        WebserviceManager.shared.hideMBProgress(view: self.view)

    }
}



// Add leader Board and Update Leader Board details
extension ShowContentViewController{
    //Create Wallet Bar Status
    func addLeaderBoardJSON() -> [String: Any]{
        let userId = UserDefaults.standard.getUserUUID()
         let userName = UserDefaults.standard.getUserName().count == 0 ? "Anonymous" : UserDefaults.standard.getUserName()
        let profile = UserDefaults.standard.getProfileImage()
        let currentCompany = UserDefaults.standard.string(forKey: "CurrentCompany") ?? "Others"
        
        let minitues = Float(Constants.appDelegateRef.totalLeaderBoardTimerCount)/60.0
        let score = minitues/30.0
        
        print("Score \(score)")
        let emptyDict = ["totalScore": 0.0]
        let dictEngagement = ["tracking": "0.0",
            "course": "\(score)",
            "capture": "0.0",
            "meeting": "0.0",
            "weeklyPlanner": "0.0",
            "totalScore": score] as [String: Any]
        let dict = ["user_id" : userId,
                    "username" : userName ,
                    "user_Picture" : profile ,
                    "companyName" : currentCompany ,
                    "Contribution" : emptyDict,
                    "engagement" : dictEngagement] as [String : Any]
        return dict
    }
    
    func addLeaderBoardAPI(){
        let ref = FirebaseManager.shared.firebaseDP!.collection("leaderBoard").whereField("user_id", isEqualTo: UserDefaults.standard.getUserUUID())
        ref.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                let leaderModel = LeaderModel()
                let leaderData = leaderModel.parseIntoLeaderModel(snap: snap)
                print(leaderData.companyName ?? "")
                // if exist update
                let documentID = snap[0].documentID
                let refExist = FirebaseManager.shared.firebaseDP!.collection("leaderBoard").document(documentID)
                refExist.updateData(self.updateLeaderBoardJSON(model : leaderData), completion: { (error) in
                    print("add career api error: \(String(describing: error?.localizedDescription))")
                     Constants.appDelegateRef.timerLeader.invalidate()
                })
                
                print("Already LeaderBord Amount Added")
                Constants.appDelegateRef.timerLeader.invalidate()
                 self.navigateTolearninfgScreen()
                
            }else{
                // add
                let refNew = FirebaseManager.shared.firebaseDP!.collection("leaderBoard")
                refNew.addDocument(data: self.addLeaderBoardJSON(), completion: { (error) in
                    if error != nil{
                         Constants.appDelegateRef.timerLeader.invalidate()
                        print(error.debugDescription)
                    }
                    else{
                        Constants.appDelegateRef.timerLeader.invalidate()
                        self.navigateTolearninfgScreen()
                    }
                })
            }
        }
    }
    
    // Update LeaderBoardDetails
    func updateLeaderBoardJSON(model : LeaderModel)-> [String: Any]{
        let userId = UserDefaults.standard.getUserUUID()
        let userName = UserDefaults.standard.getUserName().count == 0 ? "Anonymous" : UserDefaults.standard.getUserName()

        let profile: String? = UserDefaults.standard.getProfileImage() as? String ?? ""
        let currentCompany = UserDefaults.standard.string(forKey: "CurrentCompany") ?? "Others"
        
        var strBase64 = ""
        if let profileStr = profile, profileStr.count > 0{
            let dataDecoded : Data = Data(base64Encoded: profileStr)!
            let img = UIImage(data: dataDecoded)!
            let imageData: Data! = UIImageJPEGRepresentation(img, 0.1)
            strBase64 = imageData.base64EncodedString()
        }else{
            //  cell.imgApplying.image = UIImage(named: "noImage")
        }
        
        let minitues = Float(Constants.appDelegateRef.totalLeaderBoardTimerCount)/60.0
        let score = minitues/30.0
        
        let previousTotalScore = Float(model.engagementData?.totalScore ?? 0.0) ?? 0.0
        let total = previousTotalScore + score
        let changedTotalScore = Double(total).rounded(digits: 4)
        
        let module = Float(model.engagementData?.course ?? "0.0") ?? 0.0
        let moduleTotal = module + score
        let finalScore = Double(moduleTotal).rounded(digits: 5)
        
        print("Score \(score)")
        let dictContribution = ["totalScore": model.contributionData?.totalScore ?? 0.0]
        let dictEngagement = ["tracking": "\(model.engagementData?.tracking ?? "0.0")",
            "course": "\(finalScore)",
            "capture": "\(model.engagementData?.capture ?? "0.0")",
            "meeting": "\(model.engagementData?.meeting ?? "0.0")",
            "weeklyPlanner": "\(model.engagementData?.weeklyPlanner ?? "0.0")",
            "totalScore": changedTotalScore] as [String: Any]
        let dict = ["user_id" : userId,
                    "username" : userName ,
                    "user_Picture" : strBase64 ,
                    "companyName" : currentCompany ,
                    "Contribution" : dictContribution,
                    "engagement" : dictEngagement] as [String : Any]
        return dict
    }
}
