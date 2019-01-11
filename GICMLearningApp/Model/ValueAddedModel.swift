//
//  ValueAddedModel.swift
//  GICM
//
//  Created by Rafi on 29/06/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import Foundation

//VALUE ADDED
struct ValueAddedModel : Codable {
    public var status :String?
    public var message :String?
    
    static func parse(data: Data) -> ValueAddedModel? {
        do {
            let jsonDecoder = JSONDecoder()
            return try jsonDecoder.decode(ValueAddedModel.self, from: data )
        } catch {
            return nil
        }
    }
}
class ValueListFB :NSObject {
    var user_id :String?
    var value_added :String?
    var date_added :String?
}

class WorkLifeBalanceFB :NSObject {
    public var user_id :String?
    public var work :String?
    public var stress_level :String?
    public var relaxation :String?
    public var sleep :String?
    public var date :String?

}
    
struct ValueAddedListModel  : Codable{
    public var status :String?
    public var message :String?
    var data  = [ValueList]()
    
    struct ValueList :Codable {
        public var id :String?
        public var project_id :String?
        public var user_id :String?
        public var value_added :String?
        public var date_added :String?
    }
    
    static func parse(data: Data) -> ValueAddedListModel? {
        do {
            let jsonDecoder = JSONDecoder()
            return try jsonDecoder.decode(ValueAddedListModel.self, from: data )
        } catch {
            return nil
        }
    }
}

//WORK LIFE BALANCE
struct WorkLifeBalanceModel : Codable {
    public var status :String?
    public var message :String?
    
    static func parse(data: Data) -> WorkLifeBalanceModel? {
        do {
            let jsonDecoder = JSONDecoder()
            return try jsonDecoder.decode(WorkLifeBalanceModel.self, from: data )
        } catch {
            return nil
        }
    }
}

struct WorkLifeBalanceListModel  : Codable{
    public var status :String?
    public var message :String?
    var data  = [WorkLifeBalance]()
    
    struct WorkLifeBalance :Codable {
        public var id :String?
        public var project_id :String?
        public var user_id :String?
        public var work :String?
        public var stress_level :String?
        public var relaxation :String?
        public var sleep :String?
        public var date :String?
    }
    
    static func parse(data: Data) -> WorkLifeBalanceListModel? {
        do {
            let jsonDecoder = JSONDecoder()
            return try jsonDecoder.decode(WorkLifeBalanceListModel.self, from: data )
        } catch {
            return nil
        }
    }
}

class AddMeetingListFB :NSObject {
    public var id :String?
    public var project_id :String?
    public var user_id :String?
    public var point :Int?
    public var date :String?
    public var negative: [String] = []
    public var positive: [String] = []
}

//ADD MEETING
struct AddMeetingModel : Codable {
    public var status :String?
    public var message :String?
    
    static func parse(data: Data) -> AddMeetingModel? {
        do {
            let jsonDecoder = JSONDecoder()
            return try jsonDecoder.decode(AddMeetingModel.self, from: data )
        } catch {
            return nil
        }
    }
}

struct AddMeetingListModel  : Codable{
    public var status :String?
    public var message :String?
    var data  = [AddMeetingList]()
    
    
 
    
    struct AddMeetingList :Codable {
        public var id :String?
        public var project_id :String?
        public var user_id :String?
        public var point :String?
        public var date :String?
        public var negative: [String] = []
        public var positive: [String] = []
    }
    
    static func parse(data: Data) -> AddMeetingListModel? {
        do {
            let jsonDecoder = JSONDecoder()
            return try jsonDecoder.decode(AddMeetingListModel.self, from: data )
        } catch {
            return nil
        }
    }
}


//ADD CAREER
struct AddCareerModel : Codable {
    public var status :String?
    public var message :String?
    
    static func parse(data: Data) -> AddCareerModel? {
        do {
            let jsonDecoder = JSONDecoder()
            return try jsonDecoder.decode(AddCareerModel.self, from: data )
        } catch {
            return nil
        }
    }
}

struct CareerListModel  : Codable{
    public var status :String?
    public var message :String?
    var data  = [CareerList]()
    
    struct CareerList :Codable {
        public var id :String?
        public var project_id :String?
        public var user_id :String?
        public var point :String?
        public var date :String?
        public var negative: [String] = []
        public var positive: [String] = []
    }
    
    static func parse(data: Data) -> CareerListModel? {
        do {
            let jsonDecoder = JSONDecoder()
            return try jsonDecoder.decode(CareerListModel.self, from: data )
        } catch {
            return nil
        }
    }
}

