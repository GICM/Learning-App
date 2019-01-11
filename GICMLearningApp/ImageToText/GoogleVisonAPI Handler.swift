 //
//  GoogleVisonAPI Handler.swift
//  Find Tyre
//
//  Created by CIPL108-MOBILITY on 20/12/17.
//  Copyright © 2017 Self. All rights reserved.
//

import UIKit

class GoogleVisonAPI_Handler: NSObject {

    static let sharedInstance = GoogleVisonAPI_Handler()
    let window = UIApplication.shared.windows.first!

    func getTyreSize(image : UIImage, completion : @escaping (String,Bool)->Void) {
        DispatchQueue.global(qos: .background).async {
            
            WebServiceHelper.sharedInstance.processImage(data: self.formPostImageData(image: image), onCompletion: {
                response, _  in
                
                DispatchQueue.main.async {
                    if response.allKeys.count > 0 {
                        print(response)
                        if let array = response["responses"] as? [[String : Any]] {
                            
                            if let dict = array.first?["fullTextAnnotation"] as? [String : Any] {
                                if let text = dict["text"] as? String {
                                    completion(text,true)
                                }
                                else {
                                    completion("",false)
                                }
                            }
                            else {
                                completion("",false)
                            }
                        }
                        else {
                            completion("",false)
                        }
                    }
                    else {
                        completion("",false)
                    }
                }
            })
        }
    }
    
    func formPostImageData(image : UIImage) -> [String : Any] {
        
        let type = ["type":"TEXT_DETECTION"
            ] as [String : Any]
        let arrImg = ["en-t-i0-handwrit"]
        let imageContext = ["languageHints":arrImg] as Dictionary
        
        let features = [type]
        let content = ["content" : UIImageJPEGRepresentation(image, 0.5)?.base64EncodedString() ?? ""]
        
        let request = ["image" : content,"features":features,"imageContext":imageContext] as [String : Any]
        return ["requests":request]
    }
}
