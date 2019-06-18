//
//  MeetingConfigVC.swift
//  GICM
//
//  Created by Rafi on 10/08/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import Instabug
import AVKit
import AVFoundation
import Firebase
import FirebaseFirestore

class MeetingConfigVC: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    //MARK:- Initialization
    
    @IBOutlet weak var txtMeetingName: UITextField!
    @IBOutlet weak var txtVwKeyWords: UITextView!
    @IBOutlet weak var lblNoOfSpeakers: UILabel!
    var speakerCount = 2
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var sliderBritness: UISlider!

    @IBOutlet weak var imgTranscribe: UIImageView!
    @IBOutlet weak var imgAirTime: UIImageView!
    @IBOutlet weak var imgPermission: UIImageView!
    
    @IBOutlet weak var vwPerMission: UIView!
    @IBOutlet weak var lblPerMission: UILabel!
    
    //PopUp
    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
    
    var isPlaying = false
    var videoFullyPlayed = false
    
    @IBOutlet var vwPopUp: UIView!
    @IBOutlet weak var vwPlayer: UIView!
    @IBOutlet weak var btnSelect: UIButton!
    @IBOutlet weak var twWeek: UITextView!
    
    let publicbVideoURL = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
     var arrVideoList = [String]()
    var isMeetingCheckBokSelected = false
    @IBOutlet weak var btnPlayOption: UIButton!

    @IBOutlet weak var heightConstaint: NSLayoutConstraint!
    private var selectionType = "Transcribe"
    

    var isPermissionSelected = false
    
     var toolsContent = ""
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NSLog("***********************************************")
        NSLog(" Meeting View Controller View did load  ")
        
        let appdelegateRef = Constants.appDelegateRef
        appdelegateRef.timerLeader = Timer.scheduledTimer(timeInterval: 1, target: appdelegateRef, selector: #selector(appdelegateRef.calulateLeaderBoard), userInfo: nil, repeats: true)
        
        self.imgPermission.image = UIImage(named: "unCheck")

        self.heightConstaint.constant = 90
        self.vwPerMission.isHidden = false
        self.imgTranscribe.image = UIImage(named: "radio-btn-check")
        self.configUI()
        NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem)
        
        self.navigationController?.isNavigationBarHidden = true
//        self.view.addSubview(viewFlip)
//        viewFlip.frame = .init(x: 0, y: 64, width: UIScreen.main.bounds.size.width, height:  UIScreen.main.bounds.size.height-110)
//        viewFlip.isHidden = true
        // Do any additional setup after loading the view.
    NotificationCenter.default.post(name: Notification.Name("NotifyHideMenu"), object: nil, userInfo: nil)
    Utility.sharedInstance.isShowMenu = false
    
}
    
override func viewDidDisappear(_ animated: Bool) {
    
    Utility.sharedInstance.isShowMenu = true
}

    func configUI(){
        let showPopUp = UserDefaults.standard.bool(forKey: "isMeetingCheckBokSelected")
        if showPopUp{
           // self.projectListISLFirebase()
        }else{
            getMeetingVideoListFirebase()
            playerConfigUI(strContent: self.toolsContent)
        }
    }

    func flipTransition () {
        UIView.animate(withDuration: 0.5) {
            self.viewMain.transform = self.viewMain.transform.rotated(by: .pi)
        }
    }
    
    @IBAction func rotateAction(_ sender: Any) {
        self.flipTransition()
    }
    
    @IBAction func comment(_ sender: Any) {
        BugReporting.invoke()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     //MARK:- Local Methods
            
    //MARK:- Button Action
    
    @IBAction func permissionAction(_ sender: Any) {
        
        if isPermissionSelected{
            self.imgPermission.image = UIImage(named: "unCheck")
        }else{
            self.imgPermission.image = UIImage(named: "check")
        }
        self.isPermissionSelected.toggle()
        
    }
    
    @IBAction func config(_ sender: Any) {
        
       
        
        if (sender as AnyObject).tag  == 10{
            self.selectionType = "AirTime"
            self.imgAirTime.image = UIImage(named: "radio-btn-check")
            self.heightConstaint.constant = 0
            self.vwPerMission.isHidden = true
            self.imgTranscribe.image = UIImage(named: "radio-btn-uncheck")
            self.imgPermission.image = UIImage(named: "unCheck")
            self.isPermissionSelected = false
        }else{
            self.selectionType = "Transcribe"
            self.imgTranscribe.image = UIImage(named: "radio-btn-check")
            self.heightConstaint.constant = 90
            self.vwPerMission.isHidden = false
            self.imgAirTime.image = UIImage(named: "radio-btn-uncheck")
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
      //  self.navigationController?.popViewController(animated: true)
        
        let appde = Constants.appDelegateRef
        print("Total Timer Value  \(appde.totalLeaderBoardTimerCount)")
        self.addLeaderBoardAPI()
        
    }
    
    @IBAction func speakers(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        if currentValue < 2{
        lblNoOfSpeakers.text =  "\(currentValue) speaker"
        }else{
        lblNoOfSpeakers.text =  "\(currentValue) speakers"
        }
        speakerCount = currentValue
    }
    
    @IBAction func brightness(_ sender: UISlider) {
        UIScreen.main.brightness = CGFloat(sender.value)
        
    }
    
    
    @IBAction func consulting(_ sender: Any) {
    }
    
    @IBAction func start(_ sender: Any) {
        
        let strMeetingName    = txtMeetingName.text?.trimmingCharacters(in:.whitespacesAndNewlines)
        
        if strMeetingName == "" {
            Utilities.displayFailureAlertWithMessage(title:"Attention!", message:Constants.ErrorMessage.meetingName, controller:self)
        }
        else
        {
            var type = ""
            if selectionType == ""{
                Utilities.displayFailureAlertWithMessage(title:"Attention!", message: "please select meeting Configuration type", controller:self)
            }else if selectionType == "AirTime"{
               type = "AirTime"
            }else if selectionType == "Transcribe"{
                type = "Transcribe"
                if imgPermission.image == UIImage(named: "unCheck"){
                    Utilities.displayFailureAlertWithMessage(title:"Attention!", message: "please select permission received", controller:self)
                }
            }
            
            let story = UIStoryboard(name: "CaptureMeeting", bundle: nil)
            let nextVC = story.instantiateViewController(withIdentifier: "MeetingVC") as! MeetingVC
            nextVC.strMeetingName = strMeetingName!
            nextVC.speakerCount = speakerCount
            nextVC.MeetingType = type
            if txtVwKeyWords.text.count > 0{
                nextVC.stringSpeechContext = txtVwKeyWords.text
            }
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    @IBAction func camera(_ sender: Any) {
        let story = UIStoryboard(name: "CaptureMeeting", bundle: nil)
        let vc = story.instantiateViewController(withIdentifier: "CameraOverlayVC") as! CameraOverlayVC
        vc.isMeeting = true
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: false,completion: nil)
            
        // vc.imgWhiteBoard.image =
//        if !(self.navigationController?.viewControllers.contains(vc))! {
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
    }
  
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    //MARK:- Delegate Methods
   
}


extension MeetingConfigVC{
    //MARK:- API Integation
    
    func getMeetingVideoListFirebase(){
   let ref = FirebaseManager.shared.firebaseDP!.collection("ToolsSplash").whereField("toolsName", isEqualTo: "Meeting Manager")
        ref.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0
            {
                self.parseMeetingModel(snap: snap)
            }
        }
    }
    
    
    func parseMeetingModel(snap:[QueryDocumentSnapshot]){
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
            UserDefaults.standard.set(true, forKey: "isMeetingCheckBokSelected")
            UserDefaults.standard.synchronize()
            self.vwPopUp.isHidden = true
        }else{
            self.vwPopUp.isHidden = true
        }
    }
    
    @IBAction func donotShowAction(_ sender: Any) {
        isMeetingCheckBokSelected = !isMeetingCheckBokSelected
        if isMeetingCheckBokSelected{
            self.btnSelect.setImage(#imageLiteral(resourceName: "check"), for: .normal)
        }else{
            self.btnSelect.setImage(#imageLiteral(resourceName: "unCheck"), for: .normal)
        }
    }
    

}


// Add leader Board and Update Leader Board details
extension MeetingConfigVC{
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
        "meeting": "\(score)",
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
    
    
    let module = Float(model.engagementData?.meeting ?? "0.0") ?? 0.0
    let moduleTotal = module + score
    let finalScore = Double(moduleTotal).rounded(digits: 4)
    
    print("Score \(score)")
    let dictContribution = ["totalScore": model.contributionData?.totalScore ?? 0.0]
    let dictEngagement = ["tracking": "\(model.engagementData?.tracking ?? "0.0")",
        "course": "\(model.engagementData?.course ?? "0.0")",
        "capture": "\(model.engagementData?.capture ?? "0.0")",
        "meeting": "\(finalScore)",
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
