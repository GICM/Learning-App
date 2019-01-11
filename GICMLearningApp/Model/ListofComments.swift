//
//  ListofComments.swift
//  GICMLearningApp
//
//  Created by Rafi A on 05/06/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import Foundation

public struct ListofQuotes : Codable {
    
    public var status :String?
    public var message :String?
    var data = [CommentData]()
    
    
    struct CommentData :Codable {
        public var q_id :String?
        public var quotes :String?
        public var status :String?
    }
    
    static func parsedata(data:Data) -> ListofQuotes? {
        do {
            let jsonDecoder = JSONDecoder()
            return try jsonDecoder.decode(ListofQuotes.self, from: data )
            
        } catch {
            return nil
        }
}
}


//Like Quotes
public struct LikeQuotes : Codable {
    public var status :String?
    public var message :String?
    
        
    static func parsedata(data:Data) -> LikeQuotes? {
        do {
            let jsonDecoder = JSONDecoder()
            return try jsonDecoder.decode(LikeQuotes.self, from: data )
            
        } catch {
            return nil
        }
    }
    
}

