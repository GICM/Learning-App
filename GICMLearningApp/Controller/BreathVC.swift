//
//  BreathVC.swift
//  GICM
//
//  Created by CIPL0449 on 5/7/19.
//  Copyright © 2019 Praveenkumar R. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Firebase
import FirebaseFirestore

class BreathVC: UIViewController {

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
    override func viewDidLoad() {
        super.viewDidLoad()

        NSLog("***********************************************")
        NSLog(" Breath reset controller View did load  ")
        let showPopUp = UserDefaults.standard.bool(forKey: "isBreathResetSelected")
        if !showPopUp{
            self.getBreathResetVideoListFirebase()
            self.playerConfigUI(strContent: self.toolsContent)
        }
        
        NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem)
        // Do any additional setup after loading the view.
    }

    @IBAction func backAction(_ sender: Any) {
         NotificationCenter.default.post(name: Notification.Name("NofifyReloadApply"), object: nil, userInfo: nil)
        self.navigationController?.popViewController(animated: true)
    }
}


// Video Player
extension BreathVC{
    //MARK:- API Integation
    func getBreathResetVideoListFirebase(){
        let ref = FirebaseManager.shared.firebaseDP!.collection("ToolsSplash").whereField("toolsName", isEqualTo: "Breath")
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
            UserDefaults.standard.set(true, forKey: "isBreathResetSelected")
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
