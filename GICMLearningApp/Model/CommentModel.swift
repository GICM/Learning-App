//
//  CommentModel.swift
//  GICMLearningApp
//
//  Created by Rafi A on 06/06/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import Foundation


class CommentDataFB :NSObject {
    public var user_id :String?
    public var course_id :String?
    public var comments :String?
    public var posted_date :String?
    public var type :String?
    public var username :String?
}

struct CommentListModel  : Codable{
    
    public var status :String?
    public var message :String?
    var data  = [CommentData]()
    
    struct CommentData :Codable {
        public var comment_id :String?
        public var user_id :String?
        public var course_id :String?
        public var comments :String?
        public var posted_date :String?
        public var type :String?
        public var username :String?
    }
    
    static func parse(data: Data) -> CommentListModel? {
        do {
            let jsonDecoder = JSONDecoder()
            return try jsonDecoder.decode(CommentListModel.self, from: data )
        } catch {
            return nil
        }
    }
}

struct AddCommentModel : Codable{
    
    public var status :String?
    public var message :String?
    var data:CommentData?
    
    struct CommentData :Codable {
        public var user_id :String?
        public var course_id :String?
        public var comments :String?
        public var posted_date :String?
    }
    
    static func parse(data: Data) -> AddCommentModel? {
        do {
            let jsonDecoder = JSONDecoder()
            return try jsonDecoder.decode(AddCommentModel.self, from: data )
        } catch {
            return nil
        }
    }
}


