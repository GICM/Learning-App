//
//  LoginModel.swift
//  GICMLearningApp
//
//  Created by Rafi on 24/05/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import Foundation

struct LoginModel  : Decodable{
  
  public var status :String?
  public var message :String?
  var data : Logindata?
  
  struct Logindata :Codable {
    public var id :String?
    public var username :String?
    public var email :String?
    public var dob :String?
    public var prof_pic :String?
    public var rand_number :String?
    public var updated_at :String?
    public var created_at :String?
    
    public var fb_id :String?
    public var role_flag :String?
    public var twitter_id :String?
  }
  static func parse(data: Data) -> LoginModel? {
    do {
      let jsonDecoder = JSONDecoder()
      return try jsonDecoder.decode(LoginModel.self, from: data )
    } catch {
      return nil
    }
  }
}


// Register Model
struct RegisiterModel : Codable {
  public var status :String?
  public var message :String?
  
  static func parse(data: Data) -> RegisiterModel? {
    do {
      let jsonDecoder = JSONDecoder()
      return try jsonDecoder.decode(RegisiterModel.self, from: data )
    } catch {
      return nil
    }
  }
}



