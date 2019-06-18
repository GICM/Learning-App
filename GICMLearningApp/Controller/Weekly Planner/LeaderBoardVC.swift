//
//  LeaderBoardVC.swift
//  GICM
//
//  Created by CIPL0449 on 4/23/19.
//  Copyright © 2019 Praveenkumar R. All rights reserved.
//

import UIKit
import Instabug
import Firebase

class LeaderBoardVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    

    //MARK:- Initialization
    @IBOutlet weak var btnGlobal: UIButton!
    @IBOutlet weak var btnUserCompany: UIButton!
    @IBOutlet weak var btnOtherCompany: UIButton!
    
    @IBOutlet weak var btnEngage: UIButton!
    
    @IBOutlet weak var btnContribution: UIButton!
    @IBOutlet weak var collvwLeaderBoard: UICollectionView!
    
    
    var arrLeaderBoard = [LeaderModel]()
    var arrSearchLeaderBoard = [LeaderModel]()
    
    var strLeaderType = "Engagement"
    var strLeaderCategory = "global"
    let green = UIColor.init(red: 80.0/255.0, green: 190.0/255.0, blue: 80.0/255.0, alpha: 1.0)
    let blue = UIColor.init(red: 115.0/255.0, green: 115.0/255.0, blue: 190.0/255.0, alpha: 1.0)

    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("***********************************************")
        NSLog(" LeaderBoardVC View did load  ")
        self.leaderBoradListAPI()
        // Do any additional setup after loading the view.
    }
    
    //MARK:- Collection View delegates
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        DispatchQueue.main.async {
            self.collvwLeaderBoard?.collectionViewLayout.invalidateLayout()
            self.collvwLeaderBoard.layoutIfNeeded()
            self.collvwLeaderBoard.reloadData()
        }
    }
    
    //MARK:- Button Action
    @IBAction func engageAction(_ sender: Any) {
        
        self.strLeaderType = "Engagement"
         self.changeLeaderBoardData(strType: self.strLeaderType, strCategory: self.strLeaderCategory)
        btnEngage.setTitleColor(UIColor.white, for: .normal)
        btnEngage.backgroundColor = blue
        
        btnContribution.setTitleColor(blue, for: .normal)
        btnContribution.backgroundColor = UIColor.white
    }
    @IBAction func contributeAction(_ sender: Any) {
        
        self.strLeaderType = "contribution"
        self.changeLeaderBoardData(strType: self.strLeaderType, strCategory: self.strLeaderCategory)
        btnContribution.setTitleColor(UIColor.white, for: .normal)
        btnContribution.backgroundColor = blue
        
        btnEngage.setTitleColor(blue, for: .normal)
        btnEngage.backgroundColor = UIColor.white
    }
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func comment(_ sender: Any) {
        BugReporting.invoke()
    }
    
    @IBAction func globalAction(_ sender: Any) {
        self.chnageGlobalColor()
        self.strLeaderCategory = "global"
        self.changeLeaderBoardData(strType: self.strLeaderType, strCategory: self.strLeaderCategory)
    }
    
    @IBAction func userCompany(_ sender: Any) {
        self.chnageMyCompanyColor()
        self.strLeaderCategory = "user"
        self.changeLeaderBoardData(strType: self.strLeaderType, strCategory: self.strLeaderCategory)
    }
    
    @IBAction func otherCompany(_ sender: Any) {
        self.changeOtherColor()
        self.strLeaderCategory = "other"
        self.changeLeaderBoardData(strType: self.strLeaderType, strCategory: self.strLeaderCategory)
    }
    
    //MARK:- Local Methods
    //MARK:- Delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrSearchLeaderBoard.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LeaderBoardCell", for: indexPath) as! LeaderBoardCell
        self.UIConfigLeaderBoard(cell: cell, indexpath: indexPath)
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let dimension:CGFloat = self.view.frame.size.width / 2
        return CGSize(width: dimension, height: 145)
    }
    
    
    func UIConfigLeaderBoard(cell : LeaderBoardCell, indexpath: IndexPath){
        let modelObj = self.arrSearchLeaderBoard[indexpath.row]
        cell.lblName.text  = modelObj.username ?? ""
        if self.strLeaderType == "Engagement"{
            
            let value = self.roundUpValue(val: modelObj.engagementData?.totalScore ?? 0.0)
            cell.lblScore.text = String(value)
        }else{
            cell.lblScore.text = String(modelObj.contributionData?.totalScore ?? 0.0)
        }
        
        // Image
        if let profileStr = modelObj.user_picture, profileStr.count > 0{
            let dataDecoded : Data = Data(base64Encoded: profileStr)!
            cell.imgUser.image = UIImage(data: dataDecoded)
        }else{
            cell.imgUser.image = UIImage(named: "Profile")
        }
    }

    func roundUpValue(val: Double) -> Double{
        let roundedValue = val.rounded(digits: 4)
        return roundedValue
    }
    
}

// Leader Board API
extension LeaderBoardVC{
    func leaderBoradListAPI(){
        let ref = FirebaseManager.shared.firebaseDP!.collection("leaderBoard")
        ref.getDocuments(completion: { (snapshot, error) in
            if let snap = snapshot?.documents {
                if snap.count > 0{
                    let leaderModelObj =  LeaderModel()
                    self.arrLeaderBoard = leaderModelObj.parseIntoListOfLeaderModel(snap: snap)
                    print(self.arrLeaderBoard.count)
                    self.leaderBoardGlobalList(strType: self.strLeaderType)
                    self.collvwLeaderBoard.reloadData()
                }
            }
        })
    }
    
    //Leader Board List order Change
    func leaderBoardGlobalList(strType : String){
        
        if strType == "Engagement"{
            self.arrLeaderBoard = self.arrLeaderBoard.sorted(by: { $0.engagementData?.totalScore ?? 0.0 > $1.engagementData?.totalScore ?? 0.0})
            self.arrSearchLeaderBoard = self.arrLeaderBoard
            self.collvwLeaderBoard.reloadData()
        }else{
            self.arrLeaderBoard = self.arrLeaderBoard.sorted(by: { $0.contributionData?.totalScore ?? 0.0 > $1.contributionData?.totalScore ?? 0.0})
            self.arrSearchLeaderBoard = self.arrLeaderBoard
            self.collvwLeaderBoard.reloadData()
        }
       
    }
    
    // Get Our Company name
    func getUserCompanyLeaderBoardDetails(strType : String){
        
        if strType == "Engagement"{
            self.arrSearchLeaderBoard.removeAll()
            let currentCompany = UserDefaults.standard.string(forKey: "CurrentCompany") ?? "Others"
            // self.arrLeaderBoard = self.arrLeaderBoard.filter({ $0.companyName == currentCompany})
            self.arrSearchLeaderBoard = self.arrLeaderBoard.filter({$0.companyName?.range(of: currentCompany, options: [.diacriticInsensitive, .caseInsensitive]) != nil} )
            self.arrSearchLeaderBoard = self.arrSearchLeaderBoard.sorted(by: { $0.engagementData?.totalScore ?? 0.0 > $1.engagementData?.totalScore ?? 0.0})
            self.collvwLeaderBoard.reloadData()
        }else{
            self.arrSearchLeaderBoard.removeAll()
            let currentCompany = UserDefaults.standard.string(forKey: "CurrentCompany") ?? "Others"
            // self.arrLeaderBoard = self.arrLeaderBoard.filter({ $0.companyName == currentCompany})
            self.arrSearchLeaderBoard = self.arrLeaderBoard.filter({$0.companyName?.range(of: currentCompany, options: [.diacriticInsensitive, .caseInsensitive]) != nil} )
            self.arrSearchLeaderBoard = self.arrSearchLeaderBoard.sorted(by: { $0.contributionData?.totalScore ?? 0.0 > $1.contributionData?.totalScore ?? 0.0})
            self.collvwLeaderBoard.reloadData()
        }
       
    }
    
    func getOtherCompanyLeaderBoardDetails(strType : String){
        
        if strType == "Engagement"{
            
            let currentCompany = UserDefaults.standard.string(forKey: "CurrentCompany") ?? "Others"
            // self.arrLeaderBoard = self.arrLeaderBoard.filter({ $0.companyName == currentCompany})
            self.arrSearchLeaderBoard = self.arrLeaderBoard.filter({$0.companyName?.range(of: currentCompany, options: [.diacriticInsensitive, .caseInsensitive]) == nil} )
            self.arrSearchLeaderBoard = self.arrSearchLeaderBoard.sorted(by: { $0.engagementData?.totalScore ?? 0.0 > $1.engagementData?.totalScore ?? 0.0})
            self.collvwLeaderBoard.reloadData()
        }else{
            
            let currentCompany = UserDefaults.standard.string(forKey: "CurrentCompany") ?? "Others"
            // self.arrLeaderBoard = self.arrLeaderBoard.filter({ $0.companyName == currentCompany})
            self.arrSearchLeaderBoard = self.arrLeaderBoard.filter({$0.companyName?.range(of: currentCompany, options: [.diacriticInsensitive, .caseInsensitive]) == nil} )
            self.arrSearchLeaderBoard = self.arrSearchLeaderBoard.sorted(by: { $0.contributionData?.totalScore ?? 0.0 > $1.contributionData?.totalScore ?? 0.0})
            self.collvwLeaderBoard.reloadData()
        }
    }
    
    
    
    func changeLeaderBoardData(strType : String , strCategory : String){
        let type = leaderBorad(rawValue: strCategory)
        switch type {
        case .global?:
            print("Global")
            self.leaderBoardGlobalList(strType: strType)
        case .userCompany?:
            print("user")
            self.getUserCompanyLeaderBoardDetails(strType: strType)
            
        case .otherCompany?:
            print("other")
            self.getOtherCompanyLeaderBoardDetails(strType: strType)
            
        default:
            print("default")
        }
    }
    
    
    
    
    
    
    
    
}

// Change Button backGround Color
extension LeaderBoardVC{
    func chnageGlobalColor(){
        btnGlobal.setTitleColor(.white, for: .normal)
        btnGlobal.backgroundColor = green
        
        btnUserCompany.setTitleColor(blue, for: .normal)
        btnUserCompany.backgroundColor = UIColor.white
        
        btnOtherCompany.setTitleColor(blue, for: .normal)
        btnOtherCompany.backgroundColor = UIColor.white
    }
    
    func changeOtherColor(){
        btnOtherCompany.setTitleColor(.white, for: .normal)
        btnOtherCompany.backgroundColor = green
        
        btnGlobal.setTitleColor(blue, for: .normal)
        btnGlobal.backgroundColor = UIColor.white
        
        btnUserCompany.setTitleColor(blue, for: .normal)
        btnUserCompany.backgroundColor = UIColor.white
    }
    
    func chnageMyCompanyColor(){
        btnUserCompany.setTitleColor(.white, for: .normal)
        btnUserCompany.backgroundColor = green
        
        btnGlobal.setTitleColor(blue, for: .normal)
        btnGlobal.backgroundColor = UIColor.white
        
        btnOtherCompany.setTitleColor(blue, for: .normal)
        btnOtherCompany.backgroundColor = UIColor.white
    }
}

enum leaderBorad: String {
    case global = "global"
    case userCompany = "user"
    case otherCompany = "other"
}
