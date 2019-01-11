//
//  LearningSectionVC.swift
//  GICM
//
//  Created by Rafi on 19/11/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit

class LearningSectionVC: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    //MARK-:- Initialixation
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet weak var collDashboard: UICollectionView!
    
    var arrSections = ["By Role Suggestion","Course list","Contributions"]
    var arrarModuleImage = [#imageLiteral(resourceName: "byRole"),#imageLiteral(resourceName: "CourseList"),#imageLiteral(resourceName: "Contribution")]
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK:- Local Methods
    func configUI(){
        
    }
    
    //MARK:- Button Action
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Collection View Delegate Methods
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionElementKindSectionHeader:
            
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerCell", for: indexPath as IndexPath) as! UICollectionViewCell
            
            headerView.backgroundColor = UIColor.blue;
            return headerView
            
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        DispatchQueue.main.async {
            self.collDashboard?.collectionViewLayout.invalidateLayout()
            self.collDashboard.layoutIfNeeded()
            self.collDashboard.reloadData()
        }
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return arrSections.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let dashBoardCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LearningSecCell", for: indexPath) as! LearningSecCell
        dashBoardCell.layer.borderWidth = 1.0
        dashBoardCell.layer.borderColor = UIColor.init(red: 214/255.0, green: 214/255.0, blue: 214/255.0, alpha: 1.0).cgColor
        dashBoardCell.lblModuleName.text = arrSections[indexPath.row]
        dashBoardCell.imgModule.image = arrarModuleImage[indexPath.row] as UIImage
        return dashBoardCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
            let dimension:CGFloat = self.view.frame.size.width / 2
            return CGSize(width: dimension, height: collectionView.frame.size.height/4)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0{
            print("By Role Suggestion")
            let story = UIStoryboard(name: "Main", bundle: nil)
            let nextVC = story.instantiateViewController(withIdentifier: "RoleVC") as! RoleVC
            self.navigationController?.pushViewController(nextVC, animated: true)
            
        }else if indexPath.row == 1{
            print("Course list")
            let story = UIStoryboard(name: "Main", bundle: nil)
            let nextVC = story.instantiateViewController(withIdentifier: "CourseListVC") as! CourseListVC
            self.navigationController?.pushViewController(nextVC, animated: true)
            
        }else if indexPath.row == 2{
            print("Contributions")
            let story = UIStoryboard(name: "Main", bundle: nil)
            let nextVC = story.instantiateViewController(withIdentifier: "ContributionVC") as! ContributionVC
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
}


