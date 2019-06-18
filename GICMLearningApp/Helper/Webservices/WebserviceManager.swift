//
//  WebserviceManager.swift
//  BaoLee
//
//  Created by Rafi on 29/12/17.
//  Copyright © 2017 Rafi. All rights reserved.
//

import UIKit

class WebserviceManager: NSObject {
  
  /// A reference to the SessionsManager singleton.
  static let shared = WebserviceManager()
  
  let connectionObj =  ConnectionManager.connectionSharedInstance
  
  //MARK:- ShowMBProgress
  func showMBProgress (view : UIView){
    DispatchQueue.main.async {
    
      MBProgressHUD.showAdded(to:view, animated: true)
    }
  }
  //MARK:- HideMBProgress
  func hideMBProgress (view : UIView){
    DispatchQueue.main.async {
      MBProgressHUD.hide(for: view, animated: true)
    }
  }
    
  // MARK: - SignUp ISL
  func loginProcess(view : UIView,dictBody:[String:Any], Success:@escaping ((_ signINModelObj : LoginModel) ->Void),Failure:@escaping ((_ serverError : String) -> Void)) {
    
    let loginURL  = URLApi.login.description
    let dictLogin  = dictBody
    print("LoginURL ===== \(loginURL)")
    print("DictLogin ===== \(dictLogin)")
    //self.showMBProgress(view: view)
    
    connectionObj.requestPostServiceAPI(urlString:loginURL, postParamter: dictLogin, onSuccess: { (serverdata:Data, serverResponse:Dictionary<String,Any>) in
      
    //self.hideMBProgress(view: view)
      let status = serverResponse["status"] as? String ?? ""
      
      if status == "success"{
        let modelLoginData = LoginModel.parse(data: serverdata)
        Success(modelLoginData!)
      }else{
        let modelLoginData = LoginModel.parse(data: serverdata)
        Success(modelLoginData!)
        }
    },onFailure: { (error:String) in
      Failure(error)
    })
  }
    
    // MARK: - Logout ISL
    func logoutProcess(view : UIView, Success:@escaping ((_ signINModelObj : RegisiterModel) ->Void),Failure:@escaping ((_ serverError : String) -> Void)) {
        
        let loginURL  = URLApi.LOGOUT.description
        let userId = UserDefaults.standard.getUserID()
        let dictLogout  = ["id": userId]
        print("LoginURL =====: \(loginURL)")
        print("DictLogin ===== \(dictLogout)")
        //self.showMBProgress(view: view)
        
        connectionObj.requestPostServiceAPI(urlString:loginURL, postParamter: dictLogout, onSuccess: { (serverdata:Data, serverResponse:Dictionary<String,Any>) in
            
             //self.hideMBProgress(view: view)
            let status = serverResponse["status"] as? String ?? ""
            
            if status == "success"{
                let modelLogOut = RegisiterModel.parse(data: serverdata)
                Success(modelLogOut!)
            }else{
                let modelLogOut = RegisiterModel.parse(data: serverdata)
                Success(modelLogOut!)
            }
        },onFailure: { (error:String) in
            Failure(error)
        })
    }
  
    // MARK: - FaceBook And Twitter ISL
    func loginFBTW(view : UIView,dictBody:[String:Any], Success:@escaping ((_ signINModelObj : LoginModel) ->Void),Failure:@escaping ((_ serverError : String) -> Void)) {
        
        let loginURL  = URLApi.loginFBTW.description
        let dictLogin  = dictBody
        print("LoginURL ===== \(loginURL)")
        print("DictLogin ===== \(dictLogin)")
        //self.showMBProgress(view: view)
        
        connectionObj.requestPostServiceAPI(urlString:loginURL, postParamter: dictLogin, onSuccess: { (serverdata:Data, serverResponse:Dictionary<String,Any>) in
            
         //self.hideMBProgress(view: view)
            let status = serverResponse["status"] as? String ?? ""
            
            if status == "success"{
                let modelLoginData = LoginModel.parse(data: serverdata)
                Success(modelLoginData!)
            }else{
                let modelLoginData = LoginModel.parse(data: serverdata)
                Success(modelLoginData!)
            }
        },onFailure: { (error:String) in
            Failure(error)
        })
    }
    
  // MARK: - SignUp ISL
  func signUpProcess(view:UIView, dictBody:[String:Any], Success:@escaping ((_ userModelObj : RegisiterModel) ->Void),Failure:@escaping ((_ serverError : String) -> Void)) {
    
    let signUpURL        = URLApi.register.description
    let dictSignUp       = dictBody
    
    print("signUpURL ===== \(signUpURL)")
    print("DictSignUp ===== \(dictSignUp)")
    
   //self.showMBProgress(view: view)
    
    let connectionObj =  ConnectionManager.connectionSharedInstance
    
    connectionObj.requestPostServiceAPI(urlString: signUpURL, postParamter: dictSignUp, onSuccess: { (serverdata:Data, serverResponse:Dictionary<String,Any>) in
      
    //self.hideMBProgress(view: view)
      let status = serverResponse["status"] as? String ?? ""
      
      if status == "success"{
        let modelData = RegisiterModel.parse(data: serverdata)
        Success(modelData!)
      }else{
        Failure(serverResponse["message"] as? String ?? "")
      }
    }, onFailure: { (error:String) in
      self.hideMBProgress(view: view)
      Failure(error)
    })
  }
  
  //MARK: - Get ListofCourse
  func getListofCourse(view:UIView, Success:@escaping((_ serverData:ListofCourse)->Void),Failure:@escaping ((_ serverError : String) -> Void)){
    
    let courseListURL    = URLApi.listCourse.description
    let dictCourseList : [String : String] = [:]
    print("courseListURL ===== \(courseListURL)")
    print("dictCourseList ===== \(dictCourseList)")
   //self.showMBProgress(view: view)
    
    connectionObj.requestGetServiceAPI(urlString:courseListURL, onSuccess: { (serverdata:Data, serverResponse:Dictionary<String,Any>) in
        
       //self.hideMBProgress(view: view)
              let status = serverResponse["status"] as? String ?? ""
        
              if status == "success"{
                let jsonResponse = ListofCourse.parsedata(data: serverdata)
                Success(jsonResponse!)
              }
            },onFailure: { (error:String) in
              Failure(error)
            })
  }
    
    //MARK: - Get Listof  Quotes
    func getListofQuote(view:UIView, Success:@escaping((_ serverData:ListofQuotes)->Void),Failure:@escaping ((_ serverError : String) -> Void)){
        let userID = UserDefaults.standard.getUserID()
        let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let deviceID = appDel.userUUID
        let quoteURL    = URLApi.listQuotes.description + "\(userID)" + "/" + "\(deviceID ?? "NO Device ID")"
        let dictQuote : [String : String] = [:]
        print("quoteURL ===== \(quoteURL)")
        print("dictQuote ===== \(dictQuote)")
      //self.showMBProgress(view: view)
        
        connectionObj.requestGetServiceAPI(urlString:quoteURL, onSuccess: { (serverdata:Data, serverResponse:Dictionary<String,Any>) in
            
        //self.hideMBProgress(view: view)
            let status = serverResponse["status"] as? String ?? ""
            
            if status == "success"{
                let jsonResponse = ListofQuotes.parsedata(data: serverdata)
                Success(jsonResponse!)
            }
        },onFailure: { (error:String) in
            Failure(error)
        })
    }
    
    //MARK:- GetCommentList
    func commentList(view : UIView,listCommentURL: String,dictBody:[String:Any], Success:@escaping ((_ signINModelObj : CommentListModel) ->Void),Failure:@escaping ((_ serverError : String) -> Void)) {
        
        let commentURL  = listCommentURL //URLApi.listCommnet.description //
        let dictComment  = dictBody
        print("commentURL ===== \(commentURL)")
        print("dictComment ===== \(dictComment)")
      //self.showMBProgress(view: view)
        
        connectionObj.requestPostServiceAPI(urlString:commentURL, postParamter: dictComment, onSuccess: { (serverdata:Data, serverResponse:Dictionary<String,Any>) in
            
      //self.hideMBProgress(view: view)
            let status = serverResponse["status"] as? String ?? ""
            
            if status == "success"{
                let modelLoginData = CommentListModel.parse(data: serverdata)
                Success(modelLoginData!)
            }
        },onFailure: { (error:String) in
            Failure(error)
        })
    }
    
    //MARK:- GetCommentList
    func addComment(view : UIView,addCommentURL: String,dictBody:[String:Any], Success:@escaping ((_ signINModelObj : AddCommentModel) ->Void),Failure:@escaping ((_ serverError : String) -> Void)) {
        
        let commentURL  = addCommentURL //URLApi.addComment.description //
        let dictComment  = dictBody
        print("commentURL ===== \(commentURL)")
        print("dictComment ===== \(dictComment)")
      //self.showMBProgress(view: view)
        
        connectionObj.requestPostServiceAPI(urlString:commentURL, postParamter: dictComment, onSuccess: { (serverdata:Data, serverResponse:Dictionary<String,Any>) in
            
       //self.hideMBProgress(view: view)
            let status = serverResponse["status"] as? String ?? ""
            
            if status == "success"{
                let modelLoginData = AddCommentModel.parse(data: serverdata)
                Success(modelLoginData!)
            }
        },onFailure: { (error:String) in
            Failure(error)
        })
    }
    
    //MARK:- Get File Download
    func fileDownload(view : UIView,dictBody:[String:Any], Success:@escaping ((_ modelObj : FileDownloadModel) ->Void),Failure:@escaping ((_ serverError : String) -> Void)) {
        
        let downloadFileURL  = URLApi.fileDownload.description
        let dictDownloadFile  = dictBody
        print("URL ===== \(downloadFileURL)")
        print("dict ===== \(dictDownloadFile)")
   //self.showMBProgress(view: view)
        
        connectionObj.requestPostServiceAPI(urlString:downloadFileURL, postParamter: dictDownloadFile, onSuccess: { (serverdata:Data, serverResponse:Dictionary<String,Any>) in
            
      //self.hideMBProgress(view: view)
            let status = serverResponse["status"] as? String ?? ""
            if status == "success"{
                let modelFileDownloadData = FileDownloadModel.parsedata(data: serverdata)
                Success(modelFileDownloadData!)
            }
        },onFailure: { (error:String) in
            Failure(error)
        })
    }
    
    
    //MARK:- Get Like Quotes
    func likeQuotes(view : UIView,dictBody:[String:Any], Success:@escaping ((_ modelObj : LikeQuotes) ->Void),Failure:@escaping ((_ serverError : String) -> Void)) {
        
        let downloadFileURL  = URLApi.likeQuotes.description
        let dictDownloadFile  = dictBody
        print("URL ===== \(downloadFileURL)")
        print("dict ===== \(dictDownloadFile)")
   //self.showMBProgress(view: view)
        
        connectionObj.requestPostServiceAPI(urlString:downloadFileURL, postParamter: dictDownloadFile, onSuccess: { (serverdata:Data, serverResponse:Dictionary<String,Any>) in
            
 //self.hideMBProgress(view: view)
            let status = serverResponse["status"] as? String ?? ""
            if status == "Success"{
                let modelLikeQuotesData = LikeQuotes.parsedata(data: serverdata)
                Success(modelLikeQuotesData!)
            }
        },onFailure: { (error:String) in
            Failure(error)
        })
    }
    
    //MARK:- Add Project
    func addProject(view : UIView,dictBody:[String:Any], Success:@escaping ((_ modelObj : ProjectModel) ->Void),Failure:@escaping ((_ serverError : String) -> Void)) {
        
        let projectURL  = URLApi.addProject.description
        let dictProject  = dictBody
        print("URL ===== \(projectURL)")
        print("URL ===== \(dictBody)")
        //self.showMBProgress(view: view)
        
        connectionObj.requestPostServiceAPI(urlString:projectURL, postParamter: dictProject, onSuccess: { (serverdata:Data, serverResponse:Dictionary<String,Any>) in
            
        //self.hideMBProgress(view: view)
            let status = serverResponse["status"] as? String ?? ""
            if status == "success"{
                let modelData = ProjectModel.parse(data: serverdata)
                Success(modelData!)
            }
        },onFailure: { (error:String) in
            Failure(error)
        })
    }
    
    //MARK:- Edit Project
    func editProject(view : UIView,dictBody:[String:Any], Success:@escaping ((_ modelObj : ProjectModel) ->Void),Failure:@escaping ((_ serverError : String) -> Void)) {
        
        let projectURL  = URLApi.editProject.description
        let dictProject  = dictBody
        print("URL ===== \(projectURL)")
 //self.showMBProgress(view: view)
        
        connectionObj.requestPostServiceAPI(urlString:projectURL, postParamter: dictProject, onSuccess: { (serverdata:Data, serverResponse:Dictionary<String,Any>) in
            
   //self.hideMBProgress(view: view)
            let status = serverResponse["status"] as? String ?? ""
            if status == "success"{
                let modelData = ProjectModel.parse(data: serverdata)
                Success(modelData!)
            }
        },onFailure: { (error:String) in
            Failure(error)
        })
    }
    
    //MARK:- Delete Project
    func deleteProject(view : UIView,dictBody:[String:Any], Success:@escaping ((_ modelObj : ProjectModel) ->Void),Failure:@escaping ((_ serverError : String) -> Void)) {
        
        let projectURL  = URLApi.deleteProject.description
        let dictProject  = dictBody
        print("URL ===== \(projectURL)")
        print("DICT:::::::\(dictProject)")
   //self.showMBProgress(view: view)
        
        connectionObj.requestPostServiceAPI(urlString:projectURL, postParamter: dictProject, onSuccess: { (serverdata:Data, serverResponse:Dictionary<String,Any>) in
            
   //self.hideMBProgress(view: view)
            let status = serverResponse["status"] as? String ?? ""
            if status == "success"{
                let modelData = ProjectModel.parse(data: serverdata)
                Success(modelData!)
            }
        },onFailure: { (error:String) in
            Failure(error)
        })
    }
    
    //MARK: - Get Listof  Project
    func listOfProject(view:UIView, Success:@escaping((_ serverData:ProjectListModel)->Void),Failure:@escaping ((_ serverError : String) -> Void)){
        let userID = UserDefaults.standard.getUserID()
        let projectURL  = URLApi.listProject.description
        
        let dictProject = ["user_id":userID]
        print("quoteURL ===== \(projectURL)")
        print("quoteURL ===== \(dictProject)")
  //self.showMBProgress(view: view)
        connectionObj.requestPostServiceAPI(urlString:projectURL, postParamter: dictProject, onSuccess: { (serverdata:Data, serverResponse:Dictionary<String,Any>) in
            
        //self.hideMBProgress(view: view)
                let status = serverResponse["status"] as? String ?? ""
                if status == "success"{
                    let modelData = ProjectListModel.parse(data: serverdata)
                    Success(modelData!)
                }else{
                    let modelData = ProjectListModel.parse(data: serverdata)
                    Success(modelData!)
            }
            },onFailure: { (error:String) in
                Failure(error)
            })
    }
    
    //MARK: - Value Added API
    func addVAlueAdded(view:UIView,dictBody:[String:Any],Success:@escaping((_ serverData:ValueAddedModel)->Void),Failure:@escaping ((_ serverError : String) -> Void)){
        let apiURL  = URLApi.addValueAdded.description
        
        print("API  URL  ===== \(apiURL)")
        print("API  Dict ===== \(dictBody)")
    //self.showMBProgress(view: view)
        connectionObj.requestPostServiceAPI(urlString:apiURL, postParamter: dictBody, onSuccess: { (serverdata:Data, serverResponse:Dictionary<String,Any>) in
            
     //self.hideMBProgress(view: view)
            let status = serverResponse["status"] as? String ?? ""
            if status == "success"{
                let modelData = ValueAddedModel.parse(data: serverdata)
                Success(modelData!)
            }else{
                let modelData = ValueAddedModel.parse(data: serverdata)
                Success(modelData!)
            }
        },onFailure: { (error:String) in
            Failure(error)
        })
    }
    
    //MARK: - Value Chart Details API
    func listOfValueAdded(view:UIView,dictBody:[String:Any],Success:@escaping((_ serverData:ValueAddedListModel)->Void),Failure:@escaping ((_ serverError : String) -> Void)){
      
        let apiURL  = URLApi.chartOfValueAdded.description
        
        print("API  URL ===== \(apiURL)")
        print("API  Dict ===== \(dictBody)")
   //self.showMBProgress(view: view)
        connectionObj.requestPostServiceAPI(urlString:apiURL, postParamter: dictBody, onSuccess: { (serverdata:Data, serverResponse:Dictionary<String,Any>) in
            
   //self.hideMBProgress(view: view)
            let status = serverResponse["status"] as? String ?? ""
            if status == "success"{
                let modelData = ValueAddedListModel.parse(data: serverdata)
                Success(modelData!)
            }else{
                let modelData = ValueAddedListModel.parse(data: serverdata)
                Success(modelData!)
            }
        },onFailure: { (error:String) in
            Failure(error)
        })
    }
    
    
    //MARK: - Add WorkLife Balance API
    func addWorkLifeBalance(view:UIView,dictBody:[String:Any],Success:@escaping((_ serverData:WorkLifeBalanceModel)->Void),Failure:@escaping ((_ serverError : String) -> Void)){
        let apiURL  = URLApi.addWorkLifeBalance.description
        
        print("API  URL ===== \(apiURL)")
        print("API  Dict ===== \(dictBody)")
    //self.showMBProgress(view: view)
        connectionObj.requestPostServiceAPI(urlString:apiURL, postParamter: dictBody, onSuccess: { (serverdata:Data, serverResponse:Dictionary<String,Any>) in
            
     //self.hideMBProgress(view: view)
            let status = serverResponse["status"] as? String ?? ""
            if status == "success"{
                let modelData = WorkLifeBalanceModel.parse(data: serverdata)
                Success(modelData!)
            }else{
                let modelData = WorkLifeBalanceModel.parse(data: serverdata)
                Success(modelData!)
            }
        },onFailure: { (error:String) in
            Failure(error)
        })
    }
    
    //MARK: - List of  WorkLife Balance API
    func listOfWorkLifeBalance(view:UIView,dictBody:[String:Any],Success:@escaping((_ serverData:WorkLifeBalanceListModel)->Void),Failure:@escaping ((_ serverError : String) -> Void)){
        
        let apiURL  = URLApi.chartOfWorkLifeBalance.description
        
        print("API  URL ===== \(apiURL)")
        print("API  Dict ===== \(dictBody)")
   //self.showMBProgress(view: view)
        connectionObj.requestPostServiceAPI(urlString:apiURL, postParamter: dictBody, onSuccess: { (serverdata:Data, serverResponse:Dictionary<String,Any>) in
            
   //self.hideMBProgress(view: view)
            let status = serverResponse["status"] as? String ?? ""
            if status == "success"{
                let modelData = WorkLifeBalanceListModel.parse(data: serverdata)
                Success(modelData!)
            }else{
                let modelData = WorkLifeBalanceListModel.parse(data: serverdata)
                Success(modelData!)
            }
        },onFailure: { (error:String) in
            Failure(error)
        })
    }
    
    //MARK: - Add Meeting API
    func addMeeting(view:UIView,dictBody:[String:Any],Success:@escaping((_ serverData:AddMeetingModel)->Void),Failure:@escaping ((_ serverError : String) -> Void)){
        let apiURL  = URLApi.addMeeting.description
        
        print("API  URL ===== \(apiURL)")
        print("API  Dict ===== \(dictBody)")
     //self.showMBProgress(view: view)
        connectionObj.requestPostServiceAPI(urlString:apiURL, postParamter: dictBody, onSuccess: { (serverdata:Data, serverResponse:Dictionary<String,Any>) in
            
      //self.hideMBProgress(view: view)
            let status = serverResponse["status"] as? String ?? ""
            if status == "success"{
                let modelData = AddMeetingModel.parse(data: serverdata)
                Success(modelData!)
            }else{
                let modelData = AddMeetingModel.parse(data: serverdata)
                Success(modelData!)
            }
        },onFailure: { (error:String) in
            Failure(error)
        })
    }
    
    //MARK: - List of  Add Meeting API
    func listOfAddMeeting(view:UIView,dictBody:[String:Any],Success:@escaping((_ serverData:AddMeetingListModel)->Void),Failure:@escaping ((_ serverError : String) -> Void)){
        
        let apiURL  = URLApi.addMeetingList.description
        
        print("API  URL ===== \(apiURL)")
        print("API  Dict ===== \(dictBody)")
   //self.showMBProgress(view: view)
        connectionObj.requestPostServiceAPI(urlString:apiURL, postParamter: dictBody, onSuccess: { (serverdata:Data, serverResponse:Dictionary<String,Any>) in
            
    //self.hideMBProgress(view: view)
            let status = serverResponse["status"] as? String ?? ""
            if status == "success"{
                let modelData = AddMeetingListModel.parse(data: serverdata)
                Success(modelData!)
            }else{
                let modelData = AddMeetingListModel.parse(data: serverdata)
                Success(modelData!)
            }
        },onFailure: { (error:String) in
            Failure(error)
        })
    }
    
    
    //MARK: - Add Career API
    func addCareer(view:UIView,dictBody:[String:Any],Success:@escaping((_ serverData:AddCareerModel)->Void),Failure:@escaping ((_ serverError : String) -> Void)){
        let apiURL  = URLApi.addCareer.description
        
        print("API  URL ===== \(apiURL)")
        print("API  Dict ===== \(dictBody)")
   //self.showMBProgress(view: view)
        connectionObj.requestPostServiceAPI(urlString:apiURL, postParamter: dictBody, onSuccess: { (serverdata:Data, serverResponse:Dictionary<String,Any>) in
            
   //self.hideMBProgress(view: view)
            let status = serverResponse["status"] as? String ?? ""
            if status == "success"{
                let modelData = AddCareerModel.parse(data: serverdata)
                Success(modelData!)
            }else{
                let modelData = AddCareerModel.parse(data: serverdata)
                Success(modelData!)
            }
        },onFailure: { (error:String) in
            Failure(error)
        })
    }
    
    //MARK: - List of  Career API
    func listOfCareer(view:UIView,dictBody:[String:Any],Success:@escaping((_ serverData:CareerListModel)->Void),Failure:@escaping ((_ serverError : String) -> Void)){
        
        let apiURL  = URLApi.careerList.description
        
        print("API  URL ===== \(apiURL)")
        print("API  Dict ===== \(dictBody)")
  //self.showMBProgress(view: view)
        connectionObj.requestPostServiceAPI(urlString:apiURL, postParamter: dictBody, onSuccess: { (serverdata:Data, serverResponse:Dictionary<String,Any>) in
            
   //self.hideMBProgress(view: view)
            let status = serverResponse["status"] as? String ?? ""
            if status == "success"{
                let modelData = CareerListModel.parse(data: serverdata)
                Success(modelData!)
            }else{
                let modelData = CareerListModel.parse(data: serverdata)
                Success(modelData!)
            }
        },onFailure: { (error:String) in
            Failure(error)
        })
    }
  
  // MARK: - EditProfile ISL
  func editProfileProcess(view:UIView, dictBody:[String:String], Success:@escaping ((_ userModelObj : EditProfile) ->Void),Failure:@escaping ((_ serverError : String) -> Void)) {
    
    let editProrileURL        = URLApi.editProfile.description
    let dictEitProrile       = dictBody
    
    print("editProrileURL ===== \(editProrileURL)")
    print("DictSignUp ===== \(dictEitProrile)")
    
//self.showMBProgress(view: view)
    
    let connectionObj =  ConnectionManager.connectionSharedInstance
    
    connectionObj.requestPostServiceAPI(urlString: editProrileURL, postParamter: dictEitProrile, onSuccess: { (serverdata:Data, serverResponse:Dictionary<String,Any>) in
      
 //self.hideMBProgress(view: view)
      let status = serverResponse["status"] as? String ?? ""
      
      if status == "success"{
        let modelData = EditProfile.parse(data: serverdata)
        Success(modelData!)
      }else{
        Failure(serverResponse["message"] as? String ?? "")
      }
    }, onFailure: { (error:String) in
      self.hideMBProgress(view: view)
      Failure(error)
    })
  }
  
  // MARK: - GetProfile ISL
  func getProfileProcess(view:UIView, dictBody:[String:String], Success:@escaping ((_ userModelObj : GetProfile) ->Void),Failure:@escaping ((_ serverError : String) -> Void)) {
    
    let getProrileURL        = URLApi.getProfile.description
    let dictgetProrile       = dictBody
    
    print("getProrileURL ===== \(getProrileURL)")
    print("dictgetProrile ===== \(dictgetProrile)")
    
 //self.showMBProgress(view: view)
    
    let connectionObj =  ConnectionManager.connectionSharedInstance
    connectionObj.requestPostServiceAPI(urlString: getProrileURL, postParamter: dictgetProrile, onSuccess: { (serverdata:Data, serverResponse:Dictionary<String,Any>) in
      
  //self.hideMBProgress(view: view)
      let status = serverResponse["status"] as? String ?? ""
      
      if status == "success"{
        let modelData = GetProfile.parse(data: serverdata)
        Success(modelData!)
      }else{
        Failure(serverResponse["message"] as? String ?? "")
      }
    }, onFailure: { (error:String) in
      self.hideMBProgress(view: view)
      Failure(error)
    })
  }
    
    
    //MARK: - Get Company List
    func getListofCompany(view:UIView, Success:@escaping((_ serverData:CareerLevelListModel)->Void),Failure:@escaping ((_ serverError : String) -> Void)){
        
        let courseListURL    = URLApi.getCompanyList.description
        let userID = UserDefaults.standard.getUserID()
        let dictProject = ["user_id":userID]
        print("URL ===== \(courseListURL)")
        print("DICT ===== \(dictProject)")
        
   //self.showMBProgress(view: view)
        
        connectionObj.requestPostServiceAPI(urlString: courseListURL, postParamter: dictProject,onSuccess: { (serverdata:Data, serverResponse:Dictionary<String,Any>) in
        //requestGetServiceAPI(urlString:courseListURL, onSuccess: { (serverdata:Data, serverResponse:Dictionary<String,Any>) in
            
            //self.hideMBProgress(view: view)
            let status = serverResponse["status"] as? String ?? ""
            
            if status == "success"{
                let jsonResponse = CareerLevelListModel.parse(data: serverdata)
                Success(jsonResponse!)
            }
        },onFailure: { (error:String) in
            Failure(error)
        })
    }
    
    //MARK: - Post Career Level
    func postCareerLevel(view:UIView,dictBody:[String:Any],Success:@escaping((_ serverData:AddCareerModel)->Void),Failure:@escaping ((_ serverError : String) -> Void)){
        let apiURL  = URLApi.postCareerLevel.description
        print("API  URL ===== \(apiURL)")
        print("API  Dict ===== \(dictBody)")
   //self.showMBProgress(view: view)
        connectionObj.requestPostServiceAPI(urlString:apiURL, postParamter: dictBody, onSuccess: { (serverdata:Data, serverResponse:Dictionary<String,Any>) in
            
   //self.hideMBProgress(view: view)
            let status = serverResponse["status"] as? String ?? ""
            if status == "success"{
                let modelData = AddCareerModel.parse(data: serverdata)
                Success(modelData!)
            }else{
                let modelData = AddCareerModel.parse(data: serverdata)
                Success(modelData!)
            }
        },onFailure: { (error:String) in
            Failure(error)
        })
    }
    
    // MARK: - Upload ISL
    func fileUploadProcess(view:UIView, dictBody:[String:Any],fileData: NSData,Exten: String, Success:@escaping ((_ userModelObj : RegisiterModel) ->Void),Failure:@escaping ((_ serverError : String) -> Void)) {
        
        let fileUploadURL        = URLApi.fileUpload.description
        let dict       = dictBody
        let data = fileData
        
        
        print("URL ===== \(fileUploadURL)")
        print("Dict ===== \(dict)")
        
        //self.showMBProgress(view: view)
        
        
        
        connectionObj.fileUploadPOSTServiceCall(keyType:"subject_content",serviceURLString: fileUploadURL as NSString, uploadFileData: data, fileFormat: "application.\(Exten )" as NSString, sourceName:  ".elearn" as NSString, params: dict as NSDictionary,onCompletion:
            { (serviceResponse) in
                
                print(serviceResponse)
                //self.hideMBProgress(view: view)
                _ = serviceResponse["status"] as? String ?? ""
                
                // if status == "success"{
                //    let modelData = RegisiterModel.parse(data: serverdata)
                //   Success(modelData!)
                // }else{
                //   Failure(serverResponse["message"] as? String ?? "")
                // }
        }, Failure: { (error:String) in
            self.hideMBProgress(view: view)
            Failure(error)
        })
    }
    
    //MARK:- GetCommentList
    func sendMeetingReport(view : UIView,meetingURL: String,dictBody:[String:Any], Success:@escaping ((_ signINModelObj : String) ->Void),Failure:@escaping ((_ serverError : String) -> Void)) {
        
        let commentURL  = meetingURL //URLApi.addComment.description //
        let dictComment  = dictBody
        print("commentURL ===== \(commentURL)")
        print("dictComment ===== \(dictComment)")
        //self.showMBProgress(view: view)
        
        connectionObj.requestPostServiceAPI(urlString:commentURL, postParamter: dictComment, onSuccess: { (serverdata:Data, serverResponse:Dictionary<String,Any>) in
            
            //self.hideMBProgress(view: view)
            let status = serverResponse["status"] as? String ?? ""
            
            if status.lowercased() == "success"{
                Success("success")
            }
        },onFailure: { (error:String) in
            Failure(error)
        })
    }
}
