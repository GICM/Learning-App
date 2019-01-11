//
//  CaptureVC.swift
//  GICM
//
//  Created by Rafi on 10/08/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import Instabug

class CaptureVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate{
    
    @IBOutlet weak var collCapture: UICollectionView!
    
    var arrChartType = ["Pie","Bar / Line","Hirarchy","List","Waterfall","2 × 2","Mindmap"]
    var arrChartImage = [#imageLiteral(resourceName: "Pie"),#imageLiteral(resourceName: "Bar"),#imageLiteral(resourceName: "Hierarchy"),#imageLiteral(resourceName: "List"),#imageLiteral(resourceName: "Waterfall"),#imageLiteral(resourceName: "two"),#imageLiteral(resourceName: "Mindmap")]
    
    var captureType = "Printed"
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collCapture.delegate = self
        self.collCapture.dataSource = self
        
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
        self.navigationController?.popViewController(animated: true)
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
