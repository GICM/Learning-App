    //
//  ConnectionManager.swift
//  BaoLee
//
//  Created by Rafi on 29/12/17.
//  Copyright © 2017 Rafi. All rights reserved.
//

import UIKit
import Foundation

class ConnectionManager {
  
  typealias SuccessCompletionHandler = (Data,Dictionary<String, Any>) -> Void
 // typealias SuccessCompletionHandler = (_ serverResponse : Any ,_ serverData : Data? ) -> Void
  typealias FailureCompletionHandler = (_ error : String) -> Void
  
  //Create singleton shareVariable.
  static let connectionSharedInstance = ConnectionManager()
  
  // MARK: - Connection Methods
  func requestGetServiceAPI(urlString : String, onSuccess :@escaping SuccessCompletionHandler, onFailure : @escaping FailureCompletionHandler){
    let theURL                  = URL(string: urlString)
    var urlRequest              = URLRequest(url: theURL!)
    urlRequest.timeoutInterval  = 60 //120
   urlRequest.cachePolicy       = .reloadIgnoringLocalCacheData
    urlRequest.httpMethod       = "GET"
    urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    
    let urlSessionConfig    = URLSessionConfiguration.default
    let urlSession          = URLSession(configuration: urlSessionConfig)
    
    if ReachabilityManager.isConnectedToNetwork() == true {
      
      let task    = urlSession.dataTask(with: urlRequest, completionHandler: {
        (data, response, error) in
        
        if error != nil{
          print("Error  ==",error!.localizedDescription);
          onFailure(error!.localizedDescription)
        }
        else{
          do {
            let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
           print("Server Response == ",jsonResponse)
            onSuccess(data!,jsonResponse as! Dictionary<String, Any>)
          }
          catch {
            print("Error in JSON Serialisation");
            onFailure("JSON Parse Error")
          }
        }
      })
      task.resume();
      
    } else {
      onFailure("Please check internet connection")
    }
  }
  
  func requestPostServiceAPI(urlString : String, postParamter : Any, onSuccess :@escaping SuccessCompletionHandler, onFailure : @escaping FailureCompletionHandler){
    
    let theURL                  = URL(string: urlString)
    var urlRequest              = URLRequest(url: theURL!)
    urlRequest.timeoutInterval  = 60 //120
    urlRequest.cachePolicy      = .reloadIgnoringLocalCacheData
    urlRequest.httpMethod       = "POST"
    urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    do {
      urlRequest.httpBody = try JSONSerialization.data(withJSONObject: postParamter, options: .prettyPrinted)
        
    }
    catch {
      print("Cannot Parse post json")
    }
    
    let urlSessionConfig    = URLSessionConfiguration.default
    let urlSession          = URLSession(configuration: urlSessionConfig)
    
    if ReachabilityManager.isConnectedToNetwork() == true {
      
      let task    = urlSession.dataTask(with: urlRequest, completionHandler: {
        (data, response, error) in
        
        if error != nil{
          print("Error  ==",error!.localizedDescription);
          onFailure(error!.localizedDescription)
        }
        else{
          do {
            let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
            print("Server Response == ",jsonResponse)
            onSuccess(data!,jsonResponse as! Dictionary<String, Any>)
          }
          catch{
            print("Error in JSON Serialisation");
            onFailure("JSON Parse Error")
          }
        }
      })
      task.resume();
    } else {
      onFailure("Please check internet connection")
    }
  }
    
    // MARK: - Image Upload POST Service Methods
    func fileUploadPOSTServiceCall (keyType:String,serviceURLString : NSString, uploadFileData : NSData, fileFormat : NSString, sourceName : NSString, params : NSDictionary,onCompletion : @escaping (_ serviceResponse : AnyObject) -> Void,Failure:@escaping ((_ serverError: String) -> Void))
    {
        
        let serviceURLString = NSString (string: serviceURLString)
        let serviceURL = NSURL (string: serviceURLString as String)
        let serviceURLRequest = NSMutableURLRequest (url: serviceURL! as URL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 25)
        serviceURLRequest .httpMethod = "POST"
        serviceURLRequest .addValue("application/json", forHTTPHeaderField: "Content-Type")
        serviceURLRequest .addValue("application/json", forHTTPHeaderField: "Accept")
//        serviceURLRequest .addValue("text/html", forHTTPHeaderField: "Accept")
//    serviceURLRequest .addValue("eyJ0deXAiOiJKdV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOisJhcGkud2luamEuY29tLmF1IiwibmFtZSI6ImhvdXNlcm9vIiwicGFzc3dvcmsQiOiJxRE80UDRLbW1PIn0.61AU-RzyLVgpLCqPgdWo5_xAM3QJlW6ahhkBuLrsDGdg", forHTTPHeaderField: "Authorization")
        
        print(params)
        let  boundary = "Boundary-\(NSUUID().uuidString)"
        serviceURLRequest .setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let body = NSMutableData();
        for (key, value) in params
        {
            body .append("--\(boundary)\r\n" .data(using: String.Encoding.utf8)!)
            body .append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n" .data(using: String.Encoding.utf8)!)
            body .append("\(value)\r\n" .data(using: String.Encoding.utf8)!)
            print(params)
        }
        
        //  let fileNameFormat = NSString (format: "%@.jpg", sourceName)
        let filename = fileFormat
        //  let mimetype = "image/jpg"
        let mimetype = "audio/x-m4a"
        body .append("--\(boundary)\r\n" .data(using: String.Encoding.utf8)!)
        body .append("Content-Disposition: form-data; name=\"\(keyType)\"; filename=\"\(filename)\"\r\n" .data(using: String.Encoding.utf8)!)
        body .append("Content-Type: \(mimetype)\r\n\r\n" .data(using: String.Encoding.utf8)!)
        body .append(uploadFileData as Data)
        body.append("\r\n" .data(using: String.Encoding.utf8)!)
        body.append("--\(boundary)--\r\n" .data(using: String.Encoding.utf8)!)
        
        serviceURLRequest .httpBody = body as Data
        print(serviceURLRequest.httpBody!)
        
        let rmiServiceURLSession = URLSession .shared
        let rmiServiceURLSessionDataTask = rmiServiceURLSession .dataTask(with: serviceURLRequest as URLRequest, completionHandler: {(serviceURLData, serviceURLResponse, serviceURLError) in
            
            if serviceURLError != nil
            {
                print(serviceURLError? .localizedDescription ?? "")
                Failure("error====\(serviceURLError)")
            } else {
                
                do {
                    let serviceResponse = try JSONSerialization .jsonObject(with: serviceURLData!, options: JSONSerialization.ReadingOptions .allowFragments)
                    onCompletion (serviceResponse as AnyObject)
                } catch {
                    print("Cannot convert json from service data")
                }
            }
        })
        rmiServiceURLSessionDataTask .resume()
    }
    
    
    func downloadHTML(downLoadURL: URL){
        
        let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationFileUrl = documentsUrl.appendingPathComponent("ResourceHTML.html")
        
        //Create URL to the source file you want to download
       // let fileURL = URL(string: downLoadURL)
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let request = URLRequest(url:downLoadURL)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Successfully downloaded. Status code: \(statusCode)")
                }
                
                do {
                    try FileManager.default.moveItem(at: tempLocalUrl, to: destinationFileUrl)
                    //copyItem(at: tempLocalUrl, to: destinationFileUrl)
                } catch (let writeError) {
                    print("Error creating a file \(destinationFileUrl) : \(writeError)")
                }
                
            } else {
                print("Error took place while downloading a file. Error description: %@", error?.localizedDescription);
            }
        }
        task.resume()
        
    }
    
    
    }

    
