//
//  CareerListModel.swift
//  GICM
//
//  Created by Rafi on 06/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import Foundation


//ADD CAREER
struct AddCareerLevelModel : Codable {
    public var status :String?
    public var message :String?
    
    static func parse(data: Data) -> AddCareerLevelModel? {
        do {
            let jsonDecoder = JSONDecoder()
            return try jsonDecoder.decode(AddCareerLevelModel.self, from: data )
        } catch {
            return nil
        }
    }
}

class  CompanyListFB : NSObject {
    public var comp_id :String?
    public var company_name :String?
    public var posting = [PostingListFB]()
}

class PostingListFB :NSObject {
    public var post_id :String?
    public var post_name :String?
}

struct CareerLevelListModel  : Codable{
    public var status :String?
    public var message :String?
    var data:CareerList?
    struct CareerList :Codable {
      //  public var companies :String?
        
        public var company_name :String?
        public var post_id :String?
        public var post_name :String?
        public var companies = [CompanyList]()
    }
    
    struct  CompanyList : Codable {
        public var comp_id :String?
        public var company_name :String?
        public var posting = [postingList]()
    }
    
    struct postingList :Codable {
        public var post_id :String?
        public var post_name :String?
    }
    
    static func parse(data: Data) -> CareerLevelListModel? {
        do {
            let jsonDecoder = JSONDecoder()
            return try jsonDecoder.decode(CareerLevelListModel.self, from: data )
        } catch {
            return nil
        }
    }
    
    /*
     "data": {
     "company_name": "Accenture",
     "post_id": "2",
     "post_name": "Principal",
     "companies": [
     {
     "comp_id": "1",
     "company_name": "CapGemini",
     "posting": [
     {
     "post_id": "29",
     "post_name": "Job Seeker"
     },
 
 */
}

