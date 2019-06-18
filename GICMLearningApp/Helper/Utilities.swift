//
//  Utilities.swift
//  MTopo
//
//  Created by CIPL137-MOBILITY on 13/02/17.
//  Copyright © 2017 Colan Infotech Pvt Ltd. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class Utilities: NSObject {
    
    static let sharedInstance = Utilities()
    
    func viewControllerWithName(identifier: String) ->UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }
    
    func viewControllerWithNameForCustomTableView(identifier: String) ->UIViewController {
        let storyboard = UIStoryboard(name: "ProfileStoryboard", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }
    
    func viewControllerWithStoryboardName(identifier: String) ->UIViewController {
        let storyboard = UIStoryboard(name: "Storage", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: 20, y: UIScreen.main.bounds.size.height-100, width: UIScreen.main.bounds.size.width-40, height: 44))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 15.0)
        toastLabel.text = message
        toastLabel.numberOfLines = 0
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        let app = UIApplication.shared.delegate as? AppDelegate
        app?.window?.rootViewController?.view.addSubview(toastLabel)
        UIView.animate(withDuration: 3.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        UIBezierPath(
            roundedRect: rect,
            cornerRadius: newSize.height
            ).addClip()
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    
    func getRandomQuotes() -> String{
        var quotes = UserDefaults.standard.array(forKey: "QuotesList") ?? []
        var shuffledQuotes = "Talent does what it can; genius does what it must."
        if quotes.count > 0{
            shuffledQuotes = quotes.shuffle()[0] as! String
        }
        return shuffledQuotes
    }
    
    //MARK:- Take Screen Shot
    class func takeScreenshot(view: UIView) -> UIImageView {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        
        return UIImageView(image: image)
    }
    
    // MARK: - Alerft Methods
    class func displayFailureAlertWithMessage(title : String, message: String, controller : UIViewController){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle:.alert)
        let alertOKButton = UIAlertAction(title: "OK", style:.cancel, handler: nil)
        alert.addAction(alertOKButton)
        controller.present(alert, animated: true, completion: {
        })
    }
    class func showSuccessFailureAlertWithDismissHandler(title : String, message: String, controller : UIViewController, alertDismissed:@escaping ((_ okPressed: Bool)->Void)){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let alertOKButton = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
            alertDismissed(true)
        })
        alert.addAction(alertOKButton)
        controller.present(alert, animated: true, completion: {
            
        })
    }
    
    class func showAlertOkandCancelWithDismiss(title : String,okTitile:String,cancelTitle:String, message: String, controller : UIViewController, alertDismissed:@escaping ((_ okPressed: Bool)->Void)){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let alertOKButton = UIAlertAction(title: okTitile, style: UIAlertActionStyle.default, handler: { action in
            alertDismissed(true)
        })
        let alertNOButton = UIAlertAction(title: cancelTitle, style: UIAlertActionStyle.default, handler: { action in
            alertDismissed(false)
        })
        
        alert.addAction(alertOKButton)
        alert.addAction(alertNOButton)
        controller.present(alert, animated: true, completion: {
            
        })
    }
    class alert {
        func msg(message: String, title: String = "")
        {
            let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            alertView.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
            
            UIApplication.shared.keyWindow?.rootViewController?.present(alertView, animated: true, completion: nil)
        }
    }
    //Buttom Border
    class func setBottomBorder(textField:UITextField)
    {
        let bottomLine = CALayer()
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        bottomLine.frame = CGRect(x: 0.0, y:  textField.frame.height - 5,   width:  screenWidth - 55 , height: 1.0)
        bottomLine.backgroundColor = UIColor.darkGray.cgColor
        textField.borderStyle = UITextBorderStyle.none
        textField.layer.addSublayer(bottomLine)
    }
    
    //MARK:- TextField LeftView
    class func leftGapView(_ fortextfield: UITextField)
    {
        let leftView = UIView.init(frame: CGRect(x: 0, y: 0, width: 15, height: fortextfield.frame.size.height+10))
        
        let bgview=UIView.init(frame: CGRect(x: 0, y: 0, width: 15, height: fortextfield.frame.size.height+10))
        bgview.backgroundColor = UIColor.clear//UIColor(red: 47/255, green: 77/255, blue: 103/255, alpha: 1)
        
        fortextfield.leftViewMode = UITextFieldViewMode.always
        fortextfield.leftView=leftView
        leftView.addSubview(bgview)
    }
    
    // MARK: - ValidateEmail
    func validateEmail(with email: String) -> Bool {
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    // MARK: - ValidatePassword
    class func isPasswordValid(with Password : String) -> Bool{
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{6,}")
        return passwordTest.evaluate(with: Password)
    }
    // MARK: - validateMobileNumber
    class func validateMobileNumber(with mobileNumber: String) -> Bool {
        let mobileNoRegex = "[789][0-9]{9}"
        let mobileNoTest = NSPredicate(format: "SELF MATCHES %@", mobileNoRegex)
        return mobileNoTest.evaluate(with: mobileNumber)
    }
    
    class func getCustomPickerInstance() -> CustomPicker{
        let customPickerObj =   Utilities.sharedInstance.viewControllerWithName(identifier:"CustomPickerStoryboard") as! CustomPicker
        return customPickerObj
    }
    
    class func getCustomTableViewInstance() -> customTableView{
        let customTableView =   Utilities.sharedInstance.viewControllerWithNameForCustomTableView(identifier:"customTableView") as! customTableView
        return customTableView
    }
    
    func setImageAtLeft(image:String,textField:UITextField){
        textField.leftViewMode = UITextFieldViewMode.always
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        let imageView = UIImageView(frame: CGRect(x:-10, y: 0, width: 30, height: 30))
        let image = UIImage(named: image)
        imageView.image = image
        imageView .contentMode = UIViewContentMode .scaleAspectFit
        view .addSubview(imageView)
        imageView.frame.origin.x = (view.bounds.size.width - imageView.frame.size.width) / 2.0 - 5
        textField.leftView = view;
        
    }
    
    func setImageAtRight(image:String,textField:UITextField){
        textField.rightViewMode = UITextFieldViewMode.always
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        let imageView = UIImageView(frame: CGRect(x:-5, y: 0, width: 30, height: 30))
        let image = UIImage(named: image)
        imageView.image = image
        imageView .contentMode = UIViewContentMode .scaleAspectFit
        view .addSubview(imageView)
        imageView.frame.origin.x = (view.bounds.size.width - imageView.frame.size.width) / 2.0 - 5
        textField.rightView = view;
    }
    
    
    class func simpleBlurFilterExample(myImage: UIImage) -> UIImage {
        // convert UIImage to CIImage
        let inputCIImage = CIImage(image: myImage)!
        
        // Create Blur CIFilter, and set the input image
        let blurFilter = CIFilter(name: "CISepiaTone")!
        blurFilter.setValue(inputCIImage, forKey: kCIInputImageKey)
        blurFilter.setValue(8, forKey: kCIInputRadiusKey)
        
        // Get the filtered output image and return it
        let myImage = blurFilter.outputImage!
        return UIImage(ciImage: myImage)
    }
    
    //MARK:- Crop Image
    class func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
        
        let cgimage = image.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width*1.5)
        var cgheight: CGFloat = CGFloat(height+30)
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = cgimage.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
    
    //MARK: - LOG
    func log(any : Any) {
        print(any)
    }
    
    static func zoomCamera(value:Float) {
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        do {
            try captureDevice.lockForConfiguration()
            defer { captureDevice.unlockForConfiguration()}
            captureDevice.videoZoomFactor = CGFloat(value)
        } catch {
            debugPrint(error)
        }
    }
}


extension UIButton {
    func setBottomBorder() {
         let greenClor = UIColor.init(red: 64.0/255.0, green: 164.0/255.0, blue: 10.0/255.0, alpha: 1.0)
        self.layer.backgroundColor = UIColor.white.cgColor
        self.setTitleColor(greenClor, for: .normal)
        self.layer.masksToBounds = false
        self.layer.shadowColor = greenClor.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
    
    func removeButtomBorder() {
        let defaultGTextColor = UIColor.init(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.75)
        self.layer.backgroundColor = UIColor.white.cgColor
        self.setTitleColor(defaultGTextColor, for: .normal)
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.white.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowOpacity = 0.0
        self.layer.shadowRadius = 0.0
    }
    
}
