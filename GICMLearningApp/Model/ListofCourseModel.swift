//
//  ListofCourseModel.swift
//  GICMLearningApp
//
//  Created by Rafi on 28/05/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import Foundation

class ToastMessages :NSObject {
    var addCourse :String?
    var already_add :String?
    var already_invite :String?
    var buy_course :String?
    var connect :String?
    var course_add :String?
    var detail_empty :String?
    var emailid :String?
    var failed :String?
    var other_details :String?
    var pending_call :String?
    var register_failed :String?
    var snap_taken :String?
    var suc_mail :String?
    var switch_user :String?
    var thank_call4back :String?
    var thanks_survey :String?
    var update_invite :String?
    var update_mail :String?

}


class CoursedataFB :NSObject {
    var course_id :String?
    var course_title :String?
    var comments :String?
    var course_short_desc :String?
    var course_description :String?
    var thumbnail :String?
    var buy :String?
    var course_list = [CourseListDataFB]()
}

class CourseListDataFB :NSObject {
    var course_name :String?
    var courselist_id :String?
    var sub_content :String?
}

public struct ListofCourse : Codable {
  
  public var status :String?
  public var message :String?
  var data = [Coursedata]()
  
  
 public struct Coursedata :Codable {
    public var course_id :String?
    public var course_title :String?
    public var course_short_desc :String?
    public var course_description :String?
    public var thumbnail :String?
    var course_list = [CourseListData]()
    var comments_list: CommentListData?
  }
  
  struct CourseListData :Codable {
    public var course_name :String?
    public var courselist_id :String?
    var subject = [CourseContentData]()
  }
  
  struct CourseContentData :Codable {
    public var course_sub_id :String?
    public var sub_content :String?
    public var users_flag :String?
  }
  
    struct  CommentListData:Codable{
         var comment_id : String?
         var user_id : String?
         var course_id : String?
         var comments : String?
         var posted_date : String?
         var user_name : String?
    }
    
  static func parsedata(data:Data) -> ListofCourse? {
    do {
      let jsonDecoder = JSONDecoder()
      return try jsonDecoder.decode(ListofCourse.self, from: data )
      
    } catch {
      return nil
    }
  }
}

struct FileDownloadModel:Codable {
    public var status :String?
    public var file :String?
    
    static func parsedata(data:Data) -> FileDownloadModel? {
        do {
            let jsonDecoder = JSONDecoder()
            return try jsonDecoder.decode(FileDownloadModel.self, from: data )
            
        } catch {
            return nil
        }
    }
}


