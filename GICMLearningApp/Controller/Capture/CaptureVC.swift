//
//  CaptureVC.swift
//  GICM
//
//  Created by Rafi on 10/08/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import Instabug
import AVKit
import AVFoundation

class CaptureVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate{
    
    @IBOutlet weak var collCapture: UICollectionView!
    
    var arrChartType = ["Pie","Bar / Line","Hirarchy","List","Waterfall","2 × 2","Mindmap"]
    var arrChartImage = [#imageLiteral(resourceName: "Pie"),#imageLiteral(resourceName: "Bar"),#imageLiteral(resourceName: "Hierarchy"),#imageLiteral(resourceName: "List"),#imageLiteral(resourceName: "Waterfall"),#imageLiteral(resourceName: "two"),#imageLiteral(resourceName: "Mindmap")]
    
    var captureType = "Printed"
    
    
    // Video Player
    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
    
    var isPlaying = false
    var videoFullyPlayed = false
    
    @IBOutlet weak var btnPlayOption: UIButton!
    @IBOutlet weak var twWeek: UITextView!
    let publicbVideoURL = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
    var isCheckBokSelected = false
    var arrVideoList = [String]()
    @IBOutlet var vwVideoPopUp: UIView!
    @IBOutlet weak var vwPlayer: UIView!
    @IBOutlet weak var btnSelect: UIButton!
    
    var toolsContent = ""

    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NSLog("***********************************************")
        NSLog(" Capture View did load  ")
        
        let appdelegateRef = Constants.appDelegateRef
        appdelegateRef.timerLeader = Timer.scheduledTimer(timeInterval: 1, target: appdelegateRef, selector: #selector(appdelegateRef.calulateLeaderBoard), userInfo: nil, repeats: true)
        
        self.collCapture.delegate = self
        self.collCapture.dataSource = self
        
         NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem)
        
        // Do any additional setup after loading the view.
    NotificationCenter.default.post(name: Notification.Name("NotifyHideMenu"), object: nil, userInfo: nil)
    Utility.sharedInstance.isShowMenu = false
    
}

    override func viewDidDisappear(_ animated: Bool) {
    Utility.sharedInstance.isShowMenu = true
}
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        
        let showPopUp = UserDefaults.standard.bool(forKey: "isCaptureSelected")
        if !showPopUp{
            self.getCaptureVideoListFirebase()
            self.playerConfigUI(strContent: self.toolsContent)
        }
        
    }
    
    //MARK:- Local Methods
    //MARK:- Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrChartType.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CaptureCell", for: indexPath) as! CaptureCell
        cell.lblCapture.text = arrChartType[indexPath.row]
        cell.imgCapture.image = arrChartImage[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collCapture.frame.width/4, height: collectionView.frame.height/2)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            let story = UIStoryboard(name: "CaptureMeeting", bundle: nil)
            let nextVC =  story.instantiateViewController(withIdentifier: "CapturePiechartsVC") as! CapturePiechartsVC
            
            UserDefaults.standard.set(captureType, forKey: "type_of_capture")
            UserDefaults.standard.synchronize()
            
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    //MARK:- Button ACtion
    @IBAction func CaptureType(_ sender: UISegmentedControl) {
        let segIndex = sender.selectedSegmentIndex
        if segIndex == 0{
            captureType = "Printed"
        }else if segIndex == 1{
            captureType = "Notes"
        }else{
            captureType = "Whiteboard"
        }
        
        print(captureType)
        
    }
    
    @IBAction func backAction(_ sender: Any) {
        //  self.navigationController?.popViewController(animated: true)
         NotificationCenter.default.post(name: Notification.Name("NofifyReloadApply"), object: nil, userInfo: nil)
        self.addLeaderBoardAPI()

    }
    
    func resetLeaderBoardTimer(){
        let appde = Constants.appDelegateRef
        print("Total Timer Value  \(appde.totalLeaderBoardTimerCount)")
        appde.totalLeaderBoardTimerCount = 0
    }
    
    @IBAction func comment(_ sender: Any) {
        BugReporting.invoke()
    }
    
    @IBAction func Camera(_ sender: Any) {
        let story = UIStoryboard(name: "CaptureMeeting", bundle: nil)
        let vc = story.instantiateViewController(withIdentifier: "CameraOverlayVC") as! CameraOverlayVC
        vc.isMeeting = true
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: false,completion: nil)
 
    }
    
}




// Add leader Board and Update Leader Board details
extension CaptureVC{
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
                              "course": "0.0",
                              "capture": "\(score)",
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
                    self.resetLeaderBoardTimer()
                })
                
                self.resetLeaderBoardTimer()
                print("Already LeaderBord Amount Added")
                Constants.appDelegateRef.timerLeader.invalidate()
                self.resetLeaderBoardTimer()
                self.navigationController?.popViewController(animated: true)
                
            }else{
                // add
                let refNew = FirebaseManager.shared.firebaseDP!.collection("leaderBoard")
                refNew.addDocument(data: self.addLeaderBoardJSON(), completion: { (error) in
                    if error != nil{
                        print(error.debugDescription)
                        self.resetLeaderBoardTimer()
                        Constants.appDelegateRef.timerLeader.invalidate()
                        self.navigationController?.popViewController(animated: true)
                    }
                    else{
                        Constants.appDelegateRef.timerLeader.invalidate()
                        self.resetLeaderBoardTimer()
                        self.navigationController?.popViewController(animated: true)
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
        let changedTotalScore = Double(total).rounded(digits: 5)
        
        let module = Float(model.engagementData?.capture ?? "0.0") ?? 0.0
        let moduleTotal = module + score
        let finalScore = Double(moduleTotal).rounded(digits: 4)
        
        print("Score \(score)")
        let dictContribution = ["totalScore": model.contributionData?.totalScore ?? 0.0]
        let dictEngagement = ["tracking": "\(model.engagementData?.tracking ?? "0.0")",
            "course": "\(model.engagementData?.course ?? "0.0")",
            "capture": "\(finalScore)",
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




// Video Player
extension CaptureVC{
    //MARK:- API Integation
    
    func getCaptureVideoListFirebase(){
        let ref = FirebaseManager.shared.firebaseDP!.collection("ToolsSplash").whereField("toolsName", isEqualTo: "Capture")
        ref.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0
            {
                self.parseCaptureModel(snap: snap)
            }
        }
    }
    
    
    func parseCaptureModel(snap:[QueryDocumentSnapshot]){
        for obj in snap{
            let videoURL = obj["videoURL"] as? [String] ?? []
            let toolsContent = obj["toolsContent"] as? String ?? ""
            let toolsTitle = obj["toolsTitle"] as? String ?? ""
            self.toolsContent = toolsContent
            arrVideoList = videoURL
            print(arrVideoList)
        }
        self.playerConfigUI(strContent: self.toolsContent)
    }
    
    func playerConfigUI(strContent: String){
        self.vwVideoPopUp.frame = self.view.frame
        self.view.addSubview(self.vwVideoPopUp)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame =  vwPlayer.bounds
        avPlayerLayer.frame.size.width =  self.view.frame.width - 10
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        vwPlayer.layer.insertSublayer(avPlayerLayer, at: 0)
        self.vwPlayer.layoutIfNeeded()
        
        var videoURL = publicbVideoURL
        if arrVideoList.count > 0{
            let url = URL(string: arrVideoList[0])
            videoURL = url ?? self.publicbVideoURL
        }
        let playerItem = AVPlayerItem(url: videoURL!)
        avPlayer.replaceCurrentItem(with: playerItem)
        
        self.twWeek.text = "\(strContent)"
        //  avPlayer.play()
    }
    
    @IBAction func palyORPause(_ sender: Any) {
        videoPlayOrPauseAction()
    }
    
    @IBAction func playanPause(_ sender: Any) {
        videoPlayOrPauseAction()
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification){
        print("Video Finished")
        videoFullyPlayed = true
        btnPlayOption.isHidden = false
        btnPlayOption.setImage(#imageLiteral(resourceName: "videoPlay"), for: .normal)
    }
    
    //Play or Pause
    func videoPlayOrPauseAction(){
        
        let player = AVPlayer(url: publicbVideoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    @IBAction func okAction(_ sender: Any) {
        if self.btnSelect.currentImage == #imageLiteral(resourceName: "check"){
            UserDefaults.standard.set(true, forKey: "isCaptureSelected")
            UserDefaults.standard.synchronize()
            self.vwVideoPopUp.isHidden = true
        }else{
            self.vwVideoPopUp.isHidden = true
        }
    }
    
    @IBAction func donotShowAction(_ sender: Any) {
        isCheckBokSelected = !isCheckBokSelected
        if isCheckBokSelected{
            self.btnSelect.setImage(#imageLiteral(resourceName: "check"), for: .normal)
        }else{
            self.btnSelect.setImage(#imageLiteral(resourceName: "unCheck"), for: .normal)
        }
    }
}
