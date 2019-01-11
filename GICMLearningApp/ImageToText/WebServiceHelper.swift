//
//  WebServiceHelper.swift
//  Find Tyre
//
//  Created by CIPL108-MOBILITY on 20/12/17.
//  Copyright © 2017 Self. All rights reserved.
//

import UIKit

typealias ServiceResponse = (NSDictionary, NSError?) -> Void

class WebServiceHelper: NSObject {

    static let sharedInstance = WebServiceHelper()
    
    let visionBaseUrl = Constants.API.google_vision_baseURL
    let baseUrl = Constants.API.baseUrl
    
    //MARK: GET METHOD
    func makeHTTPGetRequest(path: String, onCompletion: @escaping ServiceResponse) {
        
        guard let url = URL(string: path) else {
            return
        }
        
        Utility.sharedInstance.log(any: url)
        
        let request = NSMutableURLRequest(url: url)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            var json:NSDictionary = [:]
            if  data != nil {
                do{
                    json = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                } catch {
                }
            }
            else {
                print(error?.localizedDescription ?? "")
            }
            onCompletion(json, error as NSError?)
        })
        task.resume()
    }
    
    //MARK: POST METHOD
    func makeHTTPPostRequest(path: String, body: [String:Any] , onCompletion: @escaping ServiceResponse) {
        let _: NSError?
        let request = NSMutableURLRequest(url: NSURL(string: path)! as URL)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        Utility.sharedInstance.log(any: body)
        Utility.sharedInstance.log(any: request.url ?? "Invalid URL")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [.prettyPrinted])
        } catch {
            Utility.sharedInstance.log(any: error.localizedDescription)
            return
        }
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, err -> Void in
            
            var json:NSDictionary = [:]
            if data != nil {
                do{
                    json = try JSONSerialization.jsonObject(with: data!, options: [.mutableContainers]) as! NSDictionary
                } catch {
                    print(error)
                }
            }
            onCompletion(json, err as NSError?)
        })
        task.resume()
    }
    
    //MARK: OCR
    func processImage(data: [String:Any], onCompletion: @escaping (NSDictionary, NSError?) -> Void) {
        let route = "\(visionBaseUrl)\(Constants.API_KEY.OCRKey)"
        
        makeHTTPPostRequest(path: route, body: data, onCompletion: { json, err in
            onCompletion(json as NSDictionary, err)
        })
    }
    
    
   
   
    
    
}
