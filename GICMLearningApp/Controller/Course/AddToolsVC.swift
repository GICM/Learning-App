//
//  AddToolsVC.swift
//  GICM
//
//  Created by Rafi on 17/12/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit

class AddToolsVC: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout  {

    @IBOutlet weak var collView: UICollectionView!
    @IBOutlet weak var collDashboard: UICollectionView!
    var arrSections = ["Tracking","Meeting Manager","Capture","Weekly planner","Breath reset"]//["Capture","Weekly planner"]
    
    var arrContributionSections = ["New Idea","Develop concept","Feedback","Own business"]
    var arrarContributionModuleImage = [#imageLiteral(resourceName: "NewIdea"),#imageLiteral(resourceName: "DevelopmentConcept"),#imageLiteral(resourceName: "Feedback"),#imageLiteral(resourceName: "OwnBussiness")]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSLog("***********************************************")
        NSLog(" Add ToolsView Controller View did load  ")
        
        changeApplyList()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func changeApplyList(){
        var arrApplyList = UserDefaults.standard.array(forKey: "ApplyList") as? [String] ?? []
        var list = arrSections

        for str in arrApplyList{
            list.remove(object: str)
            arrSections = list
        }
        
        print(arrSections)
        
    }
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        DispatchQueue.main.async {
            //Contribution
            self.collDashboard?.collectionViewLayout.invalidateLayout()
            self.collDashboard.layoutIfNeeded()
            self.collDashboard.reloadData()
            
            //Tools
            self.collView?.collectionViewLayout.invalidateLayout()
            self.collView.layoutIfNeeded()
            self.collView.reloadData()
        }
    }
    
    //MARK:- Delegates
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if collectionView == collView{
        return arrSections.count
        }else{
            return arrContributionSections.count
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        if collectionView == collView{
        let toolsCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ToolsCell", for: indexPath) as! LearningSecCell
        toolsCell.layer.borderWidth = 1.0
      //  toolsCell.contentView.alpha = 0.5
        toolsCell.layer.borderColor = UIColor.init(red: 214/255.0, green: 214/255.0, blue: 214/255.0, alpha: 1.0).cgColor
        toolsCell.lblModuleName.text = arrSections[indexPath.row]
        toolsCell.imgModule.image = UIImage(named: arrSections[indexPath.row])//arrarModuleImage[indexPath.row] as UIImage
        return toolsCell
        }else{
            let contributionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LearningSecCell", for: indexPath) as! LearningSecCell
            contributionCell.layer.borderWidth = 1.0
            contributionCell.layer.borderColor = UIColor.init(red: 214/255.0, green: 214/255.0, blue: 214/255.0, alpha: 1.0).cgColor
            contributionCell.lblModuleName.text = arrContributionSections[indexPath.row]
            contributionCell.imgModule.image = arrarContributionModuleImage[indexPath.row] as UIImage
            return contributionCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let dimension:CGFloat = self.view.frame.size.width / 2
        
        return CGSize(width: dimension, height: (collectionView.frame.size.height/2) - 15
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if collectionView == collView{
            //Tools
         //   Utilities.sharedInstance.showToast(message: "Development in progress")

                let addNewElement = self.arrSections[indexPath.row]
                self.addAllyList(strNewElement: addNewElement)

        }else{
            //Contribution
          //  Utilities.sharedInstance.showToast(message: "Development in progress")
            
            let email = UserDefaults.standard.getEmail()
            if email.isEmpty{
                Utilities.sharedInstance.showToast(message: "Please add email in profile")
            }else{
            
            let story = UIStoryboard(name: "CallBackupStoryboard", bundle: nil)
            let nextVC = story.instantiateViewController(withIdentifier: "SendCallBackVC") as! SendCallBackVC
            nextVC.fromVC = "Contribution"
            nextVC.strTitle = arrContributionSections[indexPath.row]
            nextVC.strContributionType = arrContributionSections[indexPath.row]
            self.navigationController?.pushViewController(nextVC, animated: true)
            }
        }
    }
    
    //MARK:- ADD New Apply List
    func addAllyList(strNewElement: String){
        var arrApplyList = UserDefaults.standard.array(forKey: "ApplyList") as? [String]
        if (arrApplyList?.contains(strNewElement))!{
            print("Already Added \(strNewElement)")
            //self.navigationController?.popViewController(animated: true)
            Utilities.sharedInstance.showToast(message: "Already Added")
        }else{
            arrApplyList?.append(strNewElement)
            let arrApplyList = arrApplyList
            UserDefaults.standard.set(true, forKey: "ApplyAdded")
            UserDefaults.standard.set(arrApplyList, forKey: "ApplyList")
            UserDefaults.standard.synchronize()
            self.navigationController?.popViewController(animated: true)
        }
    }
}


extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        guard let index = index(of: object) else {return}
        remove(at: index)
    }
    
}
