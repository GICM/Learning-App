//
//  WebServiceHandler.swift
//  Find Tyre
//
//  Created by CIPL108-MOBILITY on 21/02/18.
//  Copyright © 2018 Self. All rights reserved.
//

import UIKit

class WebServiceHandler: NSObject {

    static let sharedInstance = WebServiceHandler()

    let window = UIApplication.shared.windows.first!

    func imageFromURL(URLString:String,completionHandler:@escaping (_ Image:UIImage) ->Void) {
        DispatchQueue.main.async {
            let urlchange = URLString.replacingOccurrences(of: " ", with: "%20")
            guard let catPictureURL = URL(string:urlchange) else {
                return
            }
            let session = URLSession(configuration: .default)
            let downloadPicTask = session.dataTask(with: catPictureURL) { (data, response, error) in
                // The download has finished.
                if let e = error {
                    print("Error downloading picture: \(e)")
                } else {
                    // No errors found.
                    // It would be weird if we didn't have a response, so check for that too.
                    if (response as? HTTPURLResponse) != nil {
                        if let imageData = data {
                            // Finally convert that Data into an image and do what you wish with it.
                            completionHandler(UIImage(data: imageData) ?? UIImage())
                            // Do something with your image.
                        } else {
                            print("Couldn't get image: Image is nil")
                            completionHandler(#imageLiteral(resourceName: "noImage"))
                        }
                    } else {
                        print("Couldn't get response code for some reason")
                        completionHandler(#imageLiteral(resourceName: "noImage"))
                    }
                }
            }
            downloadPicTask.resume()
        }
    }
    
}
