//
//  ProjectModel.swift
//  GICM
//
//  Created by Rafi on 28/06/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import Foundation

class Call4BackupModel :NSObject {
    public var date :String?
    public var details :String?
    public var doc_size :UInt64?
    public var doc_url :String?
    public var mode :String?
    public var title: String?
    public var urgency: String?
    public var user_id: String?
    public var user_name: String?
    public var doc_id: String?
    public var status: String?
}

class ProjectModelFB : NSObject{
    var project_id :String?
    var user_id :String?
    var project_name :String?
    var client_name :String?
    var project_image :String?
    var start_date :String!
    var end_date :String?
    var date :String?
    var meeting_point :String?
    var meeting_point_pos :Int?
    var meeting_point_neg :Int?
    var workStreamArray :[String]?
    var workStreamData : [[String:Any]]?
    var goal :String?
    var excercise :String?
    var meTime :String?
    var sleep :String?
    var data : [WeeklyPlannerData]?
}


struct WeeklyPlannerData {
    var id :String?
    var userName :String?
    var WorkStreamName :String?
    var Meetings :[String]?
    var Research :[String]?
    var Deliverable :[String]?
    var relation :String?
    var Travel :String?
    var isStatic : Bool?
    var packed :String?
}


struct ProjectModel : Codable {
    public var status :String?
    public var message :String?
    
    static func parse(data: Data) -> ProjectModel? {
        do {
            let jsonDecoder = JSONDecoder()
            return try jsonDecoder.decode(ProjectModel.self, from: data )
        } catch {
            return nil
        }
    }
}

struct ProjectListModel  : Codable{
    
    public var status :String?
    public var message :String?
    var data  = [ProjectList]()
    
    struct ProjectList :Codable {
        public var project_id :String?
        public var user_id :String?
        public var project_name :String?
        public var client_name :String?
        public var project_image :String?
        public var start_date :String?
        public var end_date :String?
        public var date :String?
        public var value_added :String?
        
        public var work :String?
        public var stress_level :String?
        public var relaxation :String?
        public var sleep :String?
        
        public var career_point  :String?
        public var meeting_point :String?
        
    }
    
    static func parse(data: Data) -> ProjectListModel? {
        do {
            let jsonDecoder = JSONDecoder()
            return try jsonDecoder.decode(ProjectListModel.self, from: data )
        } catch {
            return nil
        }
    }
}
