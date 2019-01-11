//
//  CommentViewModel.swift
//  GICM
//
//  Created by Rafi on 26/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import Foundation


enum ParticularComment: String {
    case Profile,
     InviteFriends,
     Resource,
     Tracking,
     Reminder,
     Project,
    Learn,
    Call4BackUp
    // in a single line like this, separated by commas
}

extension CommentVC {

    func currentCommentList(list: String){
        
        let comment : ParticularComment = ParticularComment(rawValue: list)!
        let userName = (strUserType == "Me") ? UserDefaults.standard.getUserName() : "Ananymous"
        
            switch comment {
            // Use Internationalization, as appropriate.\
                
            case .Profile, .InviteFriends, .Reminder,.Resource,.Tracking:
                 dictAddComment = ["user_id" : userID,
                                   "type" : strFromVC,
                                   "username":userName,
                                   "posted_date":postedDate,
                                   "comments" : txtComment.text ?? ""]
                 
                 refGetComments = FirebaseManager.shared.firebaseDP?.collection("comments").whereField("type", isEqualTo: strFromVC)
                
           
            case .Project,.Call4BackUp:
                                 dictAddComment = ["user_id" : userID,
                                   "course_id" : courseID,
                                   "type" : strFromVC,
                                   "username":userName,
                                   "posted_date":postedDate,
                                   "comments" : txtComment.text ?? ""]
                  refGetComments = FirebaseManager.shared.firebaseDP?.collection("comments").whereField("type", isEqualTo: strFromVC)

            case .Learn:
                print("Learn")
                dictAddComment = ["course_id" : courseID,
                                  "user_id" :  userID,
                                  "type" : strFromVC,
                                  "posted_date":postedDate,
                                  "username":userName,
                                  "comments" : txtComment.text ?? ""]
                refGetComments = FirebaseManager.shared.firebaseDP?.collection("comments").whereField("type", isEqualTo: strFromVC).whereField("course_id", isEqualTo: courseID)
                
                
        }

    }
}
