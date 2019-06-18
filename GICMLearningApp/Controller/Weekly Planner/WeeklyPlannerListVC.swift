//
//  WeeklyPlannerListVC.swift
//  GICM
//
//  Created by CIPL0449 on 04/02/19.
//  Copyright © 2019 Praveenkumar R. All rights reserved.
//

import UIKit
import ExpyTableView
import Firebase
import FirebaseFirestore
import FirebaseDatabase
import AVKit
import AVFoundation
import Instabug


class WeeklyPlannerListVC: UIViewController {

    //MARK:- Initialization
    @IBOutlet weak var tblWeeklyPlannerList: ExpyTableView!
    @IBOutlet var vwPopUp: UIView!
    @IBOutlet weak var vwPlayer: UIView!
    @IBOutlet weak var btnSelect: UIButton!
    
    let userId = UserDefaults.standard.getUserUUID()
    var arrProjectList : [ProjectModelFB] = []
    var arrWeeklyPlanner : [WeeklyPlannerData] = []
    var a = 0
    var isCheckBokSelected = false
    var strProjectID = ""
    var strWeeklyPlannerID = ""
    var currentSec = 0
    var currentWorkStramData = [[String:Any]()]
    var currentIndexpath = IndexPath()
    
    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
 
    var isPlaying = false
    var videoFullyPlayed = false
    
    //Custom Picker
    var customPickerObj : CustomPicker!
    var selectedPicker  = ""
    
    //show Time PopUp
    @IBOutlet var vwTimerPopUp: UIView!
    @IBOutlet weak var lblTimer: UILabel!
    var timer = Timer()
    var timerCount = 5
    var currentTimeCount = 0
    
    @IBOutlet weak var btnPlayOption: UIButton!
    @IBOutlet weak var twWeek: UITextView!
    let publicbVideoURL = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")

    var arrVideoList = [String]()
    
    //MARK:- View  Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        NSLog("***********************************************")
        NSLog(" WeeklyPlannerListVC View did load  ")
        let appdelegateRef = Constants.appDelegateRef
        appdelegateRef.timerLeader = Timer.scheduledTimer(timeInterval: 1, target: appdelegateRef, selector: #selector(appdelegateRef.calulateLeaderBoard), userInfo: nil, repeats: true)
        
        
        self.tableViewConfigUI()
        self.vwTimerPopUp.frame = self.view.frame
        self.vwTimerPopUp.isHidden = true
        self.view.addSubview(self.vwTimerPopUp)
        self.createCustomPickerInstance()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configUI()
    }
    
    
    
    //MARK:- API Integation
    var toolsContent = ""

    func getWeeklyPlannerVideoListFirebase(){
        let ref = FirebaseManager.shared.firebaseDP!.collection("ToolsSplash").whereField("toolsName", isEqualTo: "Weekly Planner")
        ref.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0
            {
                self.parseWeeklyModel(snap: snap)
            }
        }
    }
    
    
    func parseWeeklyModel(snap:[QueryDocumentSnapshot]){
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
        self.vwPopUp.frame = self.view.frame
        self.view.addSubview(self.vwPopUp)
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
    
    //MARK:- Local Methods
    func configUI(){
        let showPopUp = UserDefaults.standard.bool(forKey: "isCheckBokSelected")
        if showPopUp{
            self.projectListISLFirebase()
        }else{
            getWeeklyPlannerVideoListFirebase()
            playerConfigUI(strContent: self.toolsContent)
        }
    }

    func adjustUITextViewHeight(textView : UITextView)
    {
        textView.translatesAutoresizingMaskIntoConstraints = true
        textView.sizeToFit()
        textView.backgroundColor = UIColor.red
        textView.isScrollEnabled = false
    }
    
    func tableViewConfigUI(){
        
       //
        tblWeeklyPlannerList.register(UINib(nibName: "WeekPlannerListCell", bundle: nil), forCellReuseIdentifier: "WeekPlannerListCell")
        
        tblWeeklyPlannerList.register(UINib(nibName: "WeeklyXLSheetCeel", bundle: nil), forCellReuseIdentifier: "WeeklyXLSheetCeel")

        
        NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem)
        
        tblWeeklyPlannerList.delegate = self
        tblWeeklyPlannerList.dataSource = self
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
    
    
    //MARK:- Button Action
    @IBAction func backAction(_ sender: Any) {
        let appde = Constants.appDelegateRef
        print("Total Timer Value  \(appde.totalLeaderBoardTimerCount)")
        Constants.appDelegateRef.timerLeader.invalidate()
        self.addLeaderBoardAPI()

    }
    
    @IBAction func commentAction(_ sender: Any) {
        BugReporting.invoke()
    }
    
    @IBAction func okAction(_ sender: Any) {
        
        if self.btnSelect.currentImage == #imageLiteral(resourceName: "check"){
            UserDefaults.standard.set(true, forKey: "isCheckBokSelected")
            UserDefaults.standard.synchronize()
            self.vwPopUp.isHidden = true
        }else{
            self.vwPopUp.isHidden = true
        }
        self.projectListISLFirebase()
    }
    
    @IBAction func donotShowAction(_ sender: Any) {
        isCheckBokSelected = !isCheckBokSelected
        if isCheckBokSelected{
            self.btnSelect.setImage(#imageLiteral(resourceName: "check"), for: .normal)
        }else{
            self.btnSelect.setImage(#imageLiteral(resourceName: "unCheck"), for: .normal)
        }
    }
    
    @IBAction func tabAction(_ sender: Any) {
      self.timer.invalidate()
      self.vwTimerPopUp.isHidden = true
      self.profileViewController()
    }
    
}



// Add leader Board and Update Leader Board details
extension WeeklyPlannerListVC{
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
                              "capture": "0.0",
            "meeting": "0.0",
            "weeklyPlanner": "\(score)",
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
                self.navigationController?.popViewController(animated: true)
                
            }else{
                // add
                let refNew = FirebaseManager.shared.firebaseDP!.collection("leaderBoard")
                refNew.addDocument(data: self.addLeaderBoardJSON(), completion: { (error) in
                    if error != nil{
                        print(error.debugDescription)
                        Constants.appDelegateRef.timerLeader.invalidate()
                        self.navigationController?.popViewController(animated: true)
                    }
                    else{
                        Constants.appDelegateRef.timerLeader.invalidate()
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
        
        let module = Float(model.engagementData?.weeklyPlanner ?? "0.0") ?? 0.0
        let moduleTotal = module + score
        let finalScore = Double(moduleTotal).rounded(digits: 4)
        
        print("Score \(score)")
        let dictContribution = ["totalScore": model.contributionData?.totalScore ?? 0.0]
        let dictEngagement = ["tracking": "\(model.engagementData?.tracking ?? "0.0")",
            "course": "\(model.engagementData?.course ?? "0.0")",
            "capture": "\(model.engagementData?.capture ?? "0.0")",
            "meeting": "\(model.engagementData?.meeting ?? "0.0")",
            "weeklyPlanner": "\(finalScore)",
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
