//
//  CreateVC.swift
//  GICM
//
//  Created by Rafi on 09/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import WebKit
import FirebaseStorage
import FirebaseFirestore

class CreateVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UIWebViewDelegate{
    
    
    var arrHeading: [String] = []
    var arrData: [String] = []
    @IBOutlet weak var webView:UIWebView!
    
    @IBOutlet weak var tblRelease: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configUI()
        webViewConfig()
        tblRelease.rowHeight = UITableViewAutomaticDimension
        tblRelease.delegate = self
        tblRelease.dataSource = self
        tblRelease.contentInset = UIEdgeInsets.zero
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func webViewConfig(){
        //webView.isHidden = true
        let refStorage = Storage.storage().reference().child("releasenotes").child("releaseNotes.html")
        refStorage.downloadURL(completion: {url,error in
            
            if error == nil{
                print("URL \(String(describing: url))")
                let requestObj = URLRequest(url: url!)
                self.webView.loadRequest(requestObj)
                
            }})
    }

    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        print(request.url)
        return true
    }
    
    func  configUI() {
//        let htmlFile = Bundle.main.path(forResource: "sample_temp", ofType: "html")
//        let htmlString = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
//        webView.loadHTMLString(htmlString!, baseURL: nil)
        
        arrHeading = ["Version 0.01 - 8th June 2018","Version 0.02 - 11th June 2018","Version 0.03 - 13th June 2018","Version 0.04 - 18th June 2018","Version 0.05 - 25th June 2018","Version 0.06 - 30th june 2018","Version 0.07 - 3rd July 2018","Version 0.08 - 4th July 2018","Version 0.09 - 10th July 2018","Version 0.10 - 13th July 2018","Version 0.11 - 13th July 2018","Version 0.12 - 21th July 2018","Version 0.13 - 24th July 2018","Version 0.14 - 26th July 2018","Version 0.15 - 30th July 2018","Version 0.16 - 3rd August 2018","Version 0.17 - 8th August 2018","Version 0.18 - 17th August 2018","Version 0.19 - 24th August 2018","Version 0.20 - 12th Sep 2018","Version 0.21 - 19th Sep 2018","Version 0.22 - 28th Sep 2018","Version 0.23 - 6th Oct 2018"]
        
        arrData = [
            """
            1) Basic iOS pattern setup
            2) Register UI & API implemented
            3) Login UI & API implemented
            4) Random Quote display in home screen which is added in the DB
            5) List of courses - Dashboard screen
            6) Lock feature
            7) Course categories list
            8) Content display
            9) Download and share the content - Native share screen.
            10) Re-Upload from iCloud.
            11) Bulb Feature - To add and view comments/Suggestions
            12) Force to turn the mobile in landscape mode.
            """ ,
            """
1) Popup missing in case user details are not in DB -> "E-Mail / Password combination not recognised. Please try again." .
2) Create can take over email / pwd from previous screen if something has been entered.
3) Forget password icon/feature missing (see page 10 in ppt) .
4) Remove the 'Next' button and have the entire text serve the function of "next"...so the user can click anywhere on the text in order to see the next random quote.
5) Remove the " from the text.
6) Stay in same font size as the rest of the text above...no change in font size per quote....just use more or less space.
7) Currently its cycling through the quotes....don't do that...show randomly only 1 and then only on user click present the next randomly selected one.
8) Buttons for Hours and Min are too small...increase for better accessibility.
9) Number format or hours is only "0" one digit .
10) Min increment is 15min.
11) Have standard min 45 at start
""" ,
            """
1) Remember the user choice for the time and next time keep it as last time.
2) App recognises when in background and after 15min this start screen comes up instead of the usual last screen the user left the app.
3) Once user is logged in already click on profile pic does not lead to login page but to profile page
4) Course table: target audience tags are missing e.g., #consultant, # jobseeker, #analyst (see page 11 of PPT)
5) Comments table: missing position of the bubble as it points towards a specified location on the screen
6) Comments table: missing flag for anonymous (in case the user doesn't want to expose himself)
""",
            """
1) Login with Facebook has been completed.
""",
            """
1) On App start check when app last have been used. If >1 day then always start here otherwise in module last used
2) Have timer run accordingly and notification popup a reminder after countdown “Planned time is up”
3) List of quotes - Offline feature done
4) Login - Offline feature done
""",
            """
1) Add Project
2) Edit Project
3) Delete Project
4) UI Implementation for project list
5) Applying Tool/Scale design for (Value Added, Project Status Details, Career, Work-life Balance)
6) Value Added - API integration
7) Bar-chart for value added
8) Line-chart for Work-life balance
9) Popup for adding positive/negatives of the project
""",
            """
1) API creation for adding project details/add meeting notes for Tracking tool
2) API creation for career in Tracking tool
3) API creation for work-life balance for Tracking tool
4) Timeline chart to view whole project status in single page with scroll option
5) Value Added API Integration
8) Chart glitches need to fixed
""",
            """
1) Tracking tool implemented
2) Value Added Bar chart integration
3) Project Status - Add Positive, Add Negative
4) Project Status - Timeline chart integration
5) Project Status - Line chart integration
6) Career - Add Positive, Add Negative
7) Career - Timeline chart integration
8) Career - Line chart integration
9) Work life Balance - Add Work, Add Stress, Add Relax and Add Sleep
10) Work life Balance - Multiline chart integration
""",
            """
1) Added sliding gesture to the quotes
2) Added clock timer in start page
3) Un-like quote features implemented
4) Version history added
5) Profile page completed
6) Career ladder added
7) Reminder design completed
""",
            """
1) Login with Facebook issues fixed
2) Added profile image in Bottom tab bar
3) Reminder section completed
4) Career Level Field is added in Profile screen
5) Value added loaded chart with real data
6) Added person position in the career level
""",
            """
1. Facebook Crash Issue
2. Profile pic default image need to set if no image coming from fb/profile
3. Like /dislike animation Comment popup changes - Anonymous/Me remove extra space in between
4. Crashlytics
5. Sub Menu Design Changed
""",
            """
1. Tab bar - text Removed
2. Replaced course list content
3. Add Project Text field alignment issue fixed
4. Remove success popup in profile screen
5. + animation need speedup
6. Remove Job Seeker from ladder and make Italic.
7. Each menu need to navigate to correct screen like Reminder -> reminder screen, Resources -> Resources screen - Done
8. Added original 10 images in call4backup screen.
9. Admin View added in Profile Screen.
10.  Add Project remove current date validation.
11. Call4Backup design completed
12. Send request screen design completed
13. Resource screen UI implementation Done
14. Invite Friend screen design completed
""",
            """
1) Quote Changes - Swipe right random quote / Swipe left viewed quotes in order
2) + blurred screen need to go back once clicked again
3) 2 Reminders should need to be there static
4) Increase the circle sizes
5) Remove the ugly white space in call4Backup screen
6) Call4Backup list text should be visible
7) Call4BackUp - Add attachment not working
8) Call4BackUp - remote/onsite alignment issue
9) Call4Back - Add confirmation popup
10) Invite Colleagues - Import own contacts
11) Admin view - Swipe function
12) Tracking scales need to be dynamic
""",
            """
1.  Resource  add Comment Api integrated
2.  Resource Comment List Api integrated
3. Remainder add Comment Api integrated
4.  Remainder Comment List Api integrated
5.  invite Friends  add Comment Api integrated
6.  Invite Friends  Comment List Api integrated
7. Profile   add Comment Api integrated
8.  Profile Comment List Api integrated
9. Tracking  add Comment Api integrated
10.  Tracking Comment List Api integrated
11. Admin screen Animation
""",
            """
1. In this video i only clicked on + to see the menu and + again to remove the menu...the previous screen and the highlighted previous menu icon was done automatic
1.1 Some more items...the “+” menu  when pressed again the menu collapses again and the blurred screen stops...the content to see is the last other menu item
2. The lightbulb icon for the comments has moved down into the text area
3. Like system cycles only through 2 states
4. Project overview: lightbulb has moved down into the text area
5. Admin menu: seems like a delay between the swiping from the side and the start of the animation....should be kind of like swiping and the menu opens with the finger....ALSO: when closing with the back arrow the animation should go to the right and not left (back to where it was)
6. Tracking: Timeline (no space) with name -> "Project timeline" name of screen and "Career timeline" name of screen. Same for chart: "Project diagram" and "Career diagram"
7. Call4Backup: Transparent bars below text only as long as the text itself
8. Add project: when starting to type project name or client the first letter should be capital - Fixed
9. Profile: Logout doesn't work - Fixed
""",
            """
1. Profile: move “Career level” text down as it labels the ladder. Instead call this line: “Consulting Company:”. for a new user the “Consulting Company:” says “Please choose your current/desired firm” (and only show the ladder once a firm is selected
2. Menu bar: increase icons to fill out space of previous text written below the icons
3. tracking: animation for the scale has only 3 states....please add more subtle steps 5 on negative and 5 on positive (with neutral being an additional state)
4. Profile pic on start screen not in sync with profile pic in profile screen
5. STILL NOT WORKING Profile: Logout doesn't work (see pic after logging out)
6. Profile: when editing the profile picture the selector is quadratic whereas the used part is circular
7. Tracking: replace “current project” with the actual project name
8. Tracking: career ladder is not in sync with the one chosen in profile
9. Instabug sdk integrated
""",
            """
1. Profile: move the "Edit" menu items under the profile pic in the profile screen....no needs for an extra edit menu....this means then also that tab open the profile pic itself gives choice to change as it is working already in the Edit sub screen.
2.  Add/edit projects: use different style of input fields
3. Invite colleagues: lets make it simpler...take out the list of contacts from the buttom and use the screen for the other items.....then have the button "invite colleagues" go to a normal contract list with search bar on top (guess this is standard) to select a contact...on selecting one contact ask for email or SMS and proceed accordingly.....
4. Profile pic: not working with Facebook login and when chosen manually not in sync with start screen or menu pic.
5. Tracking: Change "Career" under career tracker to company name chosen in Profile
6. Tracking: don't allow to change the career steps of the ladder....this should solely work in profile
7. Tracking: + icon of menu left over

8. Profile: when editing the profile picture the selector is quadratic whereas the used part is circular (see picture). iOS Default
9. Admin menu: when closing with the back arrow the animation should go be reverse to opening (now just disappears) 
""",
            """
1) Meeting manager speech API integrated
2) Small UI glitches in Meeting manager is in progress
3) Email template 80% data filled.
4) Capture Vision API integrated
5) Capture Data filling to pie chart facing some issues due to detected element is not coming only as integer.
6) Capture API Integration is in progress.
""",
            """
1.Capture Module Completed
2. Login with firebase
3.SignUp with firebase
4.Get user detail with firebase
5.Update user detail with firebase
6. Forgot password with firebase
7. Login with Facebook in firebase
8. List quotes with firebase
9. Like and dislike with firebase
""",
            """
1. All API has been migrated to Firebase
2. Now, the complete app is dependent on firebase. No backend PHP server is needed
""",
            """
 1) Two reminders should need to be there always as static.
 2) Meeting manager function will restrict guest to login to use this feature.
 3) Graphic error in reminder screen - Fixed
 4) Geo fencing
 5) Capture function will restrict guest to login to use this feature.
 6) Anonymous user sharing the same reminders - Fixed
""",
"""
 1)  And by default please for custom reminders enable Mo-Fri
 2)  And make the icons for the days larger please
 3)  Use all space left to right to size the circle days symbols
 4)  Tried custom location reminder...works!  But we should have better text of the notification itself...the headline is correctly the custom title chosen by user...the rest should be “leaving your location” or “arriving at your location”
 5)  For the location reminders please change the symbol according to “arriving” or “leaving”. And let your designers create the symbols the show way...thanks
""",
"""
1) Create call 4 back request by adding audio or video or docs
2) Send the request mail to login user now for testing purpose
3) If the file less than 15 mb then attached  directly as zip else download link added
4) List out the call 4 back up
Note : above feature only when user login
5) Invite func separate design for contact (design change from the last feedback)
"""
        ]
        arrHeading.reverse()
        arrData.reverse()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrHeading.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "release", for: indexPath) as! LearningTableViewCell
        cell.lblVersion.text = arrHeading[indexPath.row]
        cell.lblReleaseNotes.text = arrData[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
