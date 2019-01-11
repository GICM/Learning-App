//
//  EditProfileModel.swift
//  GICM
//
//  Created by Rafi on 04/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import Foundation

struct EditProfileRequest :Encodable {
  
  public var userId : String
  public var userName : String
  public var email : String
  public var dob : String
  public var profPic : String
  
  //MARK: - RequesrEdit
  func requesrEdit() -> [String:String]{
    return [
      "user_id"   : userId,
      "user_name" : userName,
      "e_mail"    : email,
      "dob"       : dob,
      "prof_pic"  : profPic]
  }
}

struct EditProfile : Codable{
  
  public var status: String
  public var message :String
  public var data: ProfileData
  
  struct ProfileData : Codable {
    public var dob: String
    public var email: String
    public var prof_pic: String
    public var username: String
    public var created_at: String
    
  }
  
  static func parse(data: Data) -> EditProfile? {
    do {
      let jsonDecoder = JSONDecoder()
      return try jsonDecoder.decode(EditProfile.self, from: data )
    } catch {
      return nil
    }
  }
}

struct GetProfile : Codable{
  
  public var status: String
  public var message :String
  public var data: GetProfileData
  
  struct GetProfileData : Codable {
    public var id: String
    public var username: String
    public var email: String
    public var dob: String
    public var prof_pic: String
    public var fb_id: String
    public var twitter_id: String
    public var company_id: String
    public var posting_id: String
    public var updated_at: String
    public var created_at: String
    public var role_flag: String
    public var access_token: String
    public var token: String
  }
  
  static func parse(data: Data) -> GetProfile? {
    do {
      let jsonDecoder = JSONDecoder()
      return try jsonDecoder.decode(GetProfile.self, from: data )
    } catch {
      return nil
    }
  }
}
