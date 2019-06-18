//
//  call4BackupVC.swift
//  GICM
//
//  Created by Rafi on 19/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import Instabug
import GradientProgressBar

class call4BackupVC: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var tblCallBackUp: UITableView!
    
    @IBOutlet weak var grad: GradientProgressBar!
    @IBOutlet weak var btnWallet: UIButton!
    @IBOutlet weak var vwWallet: UIView!
    @IBOutlet weak var yContstraintButton: NSLayoutConstraint!
    @IBOutlet weak var heightConstaint: NSLayoutConstraint!
    var walletExpand = false

    @IBOutlet weak var lblWallet: UILabel!
    
    @IBOutlet weak var progressView: UIProgressView!
    var arrRemoteImage = [#imageLiteral(resourceName: "REMOTE Interview practice"),#imageLiteral(resourceName: "REMOTE RFP response"),#imageLiteral(resourceName: "REMOTE Ask the expert"),#imageLiteral(resourceName: "REMOTE Delivery Review"),#imageLiteral(resourceName: "REMOTE Team addition"),#imageLiteral(resourceName: "Personal coaching")]
    var arrClientImage = [#imageLiteral(resourceName: "Personal coaching"),#imageLiteral(resourceName: "ONSITE Team addition"),#imageLiteral(resourceName: "ONSITE Delivery Review"),#imageLiteral(resourceName: "REMOTE Team addition"),#imageLiteral(resourceName: "ONSITE Team addition"),#imageLiteral(resourceName: "ONSITE Delivery Review")]
    
    var type = ""
    var arrCall4BackUpText = ["Interview Practice","Proposal Support","Expert Support","Deliverable Review","Team Addition","Personal Coaching"]
    
    
    @IBOutlet var vwEmail: UIView!
    @IBOutlet weak var txtEmail: UITextField!
    @IBAction func emailCancel(_ sender: Any) {
        vwEmail.isHidden = true
        self.txtEmail.text = ""
        self.txtEmail.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    @IBAction func walletAction(_ sender: Any) {
        if walletExpand{
            self.vwWallet.isHidden = true
            UIView.animate(withDuration: 5.0, animations: {
                self.btnWallet.setImage(UIImage(named: "downWallet"), for: .normal)
                self.heightConstaint.constant = 0
                self.yContstraintButton.constant = 0
            }, completion: nil)
        }else{
            self.vwWallet.isHidden = false

            UIView.animate(withDuration: 5.0, animations: {
                self.btnWallet.setImage(UIImage(named: "upWallet"), for: .normal)
                self.heightConstaint.constant = 60
                self.yContstraintButton.constant = 30
            }, completion: { finish in
                self.progressBarAnimation()
            })
        }
        self.walletExpand.toggle()
    }
    
    @IBAction func saveEmail(_ sender: Any) {
        if (txtEmail.text?.count)! > 0 {
            let  strEmailSwitch = txtEmail.text ?? ""
            
            if !Utilities.sharedInstance.validateEmail(with:strEmailSwitch){
                let errorMessage = Constants.ErrorMessage.vaildemail
                Utilities.displayFailureAlertWithMessage(title: "Attention!", message: errorMessage, controller: self)
            }else{
                vwEmail.isHidden = true
                self.txtEmail.text = ""
                self.txtEmail.resignFirstResponder()
                self.view.endEditing(true)
                if UserDefaults.standard.getUserName().count == 0{
                    UserDefaults.standard.setUserName(value: "Anonymous")
                }else{
                    
                }
                UserDefaults.standard.setEmail(value: strEmailSwitch)
                UserDefaults.standard.synchronize()
                //                let story = UIStoryboard(name: "CaptureMeeting", bundle: nil)
                //                let nextVC = story.instantiateViewController(withIdentifier: "MeetingConfigVC") as! MeetingConfigVC
                //                self.navigationController?.pushViewController(nextVC, animated: true)
                
                let nextVC = storyboard?.instantiateViewController(withIdentifier: "SendCallBackVC") as! SendCallBackVC
                nextVC.strTitle = self.type//arrCall4BackUpText[indexPath.row]
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
            //self.switchUserFB();
        }else{
            Utilities.displayFailureAlertWithMessage(title: "Attention!", message: Constants.ErrorMessage.email, controller: self)
            //  Utilities.sharedInstance.showToast(message: (FirebaseManager.shared.toastMsgs.emailid)!)
        }
    }
    
    //Comment
    var customCommentObj     : CustomCommentVC!
    
    override func viewDidLoad() {
        
        
        NSLog("***********************************************")
        NSLog(" Call 4 backup VC View did load  ")
        
//        self.heightConstaint.constant = 60
//        self.yContstraintButton.constant = 30
        heightConstaint.constant = 0
        yContstraintButton.constant = 0
        vwWallet.isHidden = true
        
        super.viewDidLoad()
        
        self.vwEmail.frame = self.view.frame
        self.vwEmail.isHidden = true
        self.tabBarController?.view.addSubview(self.vwEmail)
        self.progressBarAnimation()

        
        
        createCustomCommentInstance()
        // Do any additional setup after loading the view.
        //        NotificationCenter.default.post(name: Notification.Name("NotifyHideMenu"), object: nil, userInfo: nil)
        //        Utility.sharedInstance.isShowMenu = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
      //  self.progressBarAnimation()
    }
    
    
    
    
    //    override func viewDidDisappear(_ animated: Bool) {
    //        Utility.sharedInstance.isShowMenu = true
    //    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func progressBarAnimation(){
       
        let gradientView = GradientView(frame: progressView.bounds)
        
        //convert gradient view to image , flip horizontally and assign as the track image
        progressView.trackImage = UIImage(view: gradientView).withHorizontallyFlippedOrientation()
        
        //invert the progress view
        progressView.transform = CGAffineTransform(scaleX: -1.0, y: -1.0)
        progressView.progressTintColor = UIColor.init(red: 161.0/255.0, green: 161.0/255.0, blue: 161.0/255.0, alpha: 1.0)
        
        
        let walletValue = UserDefaults.standard.string(forKey: "walletAmount") ?? "800"
        self.lblWallet.text = " Wallet Balance: \(walletValue)"
        let wallet = Float(walletValue) ?? 100.0
        
        
        let progressbarValue = wallet/100.0

        self.progressView.progress = progressbarValue
        
        
        
        let  greenColor = UIColor.init(red: 63.0/255.0, green: 157.0/255.0, blue: 75.0/255.0, alpha: 1.0)
        let  yellowColor = UIColor.init(red: 210.0/255.0, green: 231.0/255.0, blue: 50.0/255.0, alpha: 1.0)
        
        grad.progress = progressbarValue
        progressView.tintColor = UIColor.init(red: 161.0/255.0, green: 161.0/255.0, blue: 161.0/255.0, alpha: 1.0)
        grad.gradientColorList = [greenColor,.yellow]
        
      //  progressView.setProgress(progressbarValue, animated: true)
    }
    
    @IBAction func callBackType(_ sender: Any) {
        let index = (sender as AnyObject).selectedSegmentIndex
        switch index {
        case 0:
            print("Remote")
            let arr = [#imageLiteral(resourceName: "Personal coaching"),#imageLiteral(resourceName: "REMOTE Interview practice"),#imageLiteral(resourceName: "REMOTE RFP response"),#imageLiteral(resourceName: "REMOTE Ask the expert"),#imageLiteral(resourceName: "REMOTE Delivery Review"),#imageLiteral(resourceName: "REMOTE Team addition")]
            arrRemoteImage = arr
            tblCallBackUp.reloadData()
        case 1:
            print("Onsite")
            let arr = [#imageLiteral(resourceName: "Personal coaching"),#imageLiteral(resourceName: "ONSITE Team addition"),#imageLiteral(resourceName: "ONSITE Delivery Review"),#imageLiteral(resourceName: "REMOTE Team addition"),#imageLiteral(resourceName: "ONSITE Team addition"),#imageLiteral(resourceName: "ONSITE Delivery Review")]
            arrRemoteImage = arr
            tblCallBackUp.reloadData()
        default:
            break
        }
    }
    
    //MARK:- Comment
    @IBAction func comment(_ sender: Any) {
        BugReporting.invoke()
        //addCustomComment()
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    //MARK:- Delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrRemoteImage.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "callbackup", for: indexPath) as! CallBackUpCell
        cell.selectionStyle = .none
        cell.imgIcon.image = arrRemoteImage[indexPath.row]
        if indexPath.row % 2 == 0{
            cell.lblName2.isHidden = false
            cell.lblName.isHidden = true
            cell.lblName2.text = arrCall4BackUpText[indexPath.row]
        }else{
            cell.lblName.isHidden = false
            cell.lblName2.isHidden = true
            cell.lblName.text = arrCall4BackUpText[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let loginValue = UserDefaults.standard.string(forKey: "Login")
        
        if loginValue == "0"{
            
            
            let email = UserDefaults.standard.getEmail()
            if email.isEmpty{
                self.vwEmail.isHidden = false
                self.txtEmail.text = ""
                self.type = arrCall4BackUpText[indexPath.row]
            }else{
                let nextVC = storyboard?.instantiateViewController(withIdentifier: "SendCallBackVC") as! SendCallBackVC
                nextVC.strTitle = arrCall4BackUpText[indexPath.row]
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
            
        }else{
            let nextVC = storyboard?.instantiateViewController(withIdentifier: "SendCallBackVC") as! SendCallBackVC
            nextVC.strTitle = arrCall4BackUpText[indexPath.row]
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tblCallBackUp.frame.height/6
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return tblCallBackUp.frame.height/6
    }
}

extension call4BackupVC: CommentDelegates{
    func createCustomCommentInstance()
    {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        customCommentObj = storyBoard.instantiateViewController(withIdentifier: "CustomCommentVC") as! CustomCommentVC
        customCommentObj.delegate = self
    }
    
    //Add
    func addCustomComment() {
        self.view.addSubview(customCommentObj.view)
    }
    
    func removeCustomComment()
    {
        if customCommentObj != nil
        {
            customCommentObj.view.removeFromSuperview()
        }
    }
    
    func commentMe() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        nextVC.userID   = UserDefaults.standard.getUserID()
        nextVC.strFromVC = "Call4BackUp"
        nextVC.strUserType = "Me"
        self.navigationController?.pushViewController(nextVC, animated: true)
        removeCustomComment()
    }
    
    func commentAnonymous() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        nextVC.userID   = "0"
        nextVC.strFromVC = "Call4BackUp"
        nextVC.strUserType = "Ananymous"
        self.navigationController?.pushViewController(nextVC, animated: true)
        removeCustomComment()
    }
    
    func canceled() {
        removeCustomComment()
    }
}




// Gradient Progress View
extension UIImage{
    convenience init(view: UIView) {
        
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
        
    }
}

@IBDesignable
class GradientView: UIView {
    
    private var gradientLayer = CAGradientLayer()
    private var vertical: Bool = false
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        // Drawing code
        
        //fill view with gradient layer
        gradientLayer.frame = self.bounds
  
        //style and insert layer if not already inserted
        if gradientLayer.superlayer == nil {
            
            let  greenColor = UIColor.init(red: 63.0/255.0, green: 157.0/255.0, blue: 75.0/255.0, alpha: 1.0).cgColor
            let  yellowColor = UIColor.init(red: 210.0/255.0, green: 231.0/255.0, blue: 50.0/255.0, alpha: 1.0).cgColor
            
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = vertical ? CGPoint(x: 0, y: 1) : CGPoint(x: 1, y: 0)
            gradientLayer.colors = [greenColor, yellowColor]
            gradientLayer.locations = [0.0, 0.7]
            
            self.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
    
}

