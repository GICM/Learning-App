//
//  WebStoreLinkVC.swift
//  GICMLearningApp
//
//  Created by Rafi on 20/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import WebKit

class WebStoreLinkVC: UIViewController,WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    var strWebsiteLink = ""
    let webManager = WebserviceManager.shared
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        webView.navigationDelegate = self
        if let url = URL(string: strWebsiteLink) {
            webView.load(URLRequest(url: url))
            webView.allowsBackForwardNavigationGestures = true
        }
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Start to load")
        webManager.showMBProgress(view: self.view)
        
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Finish to load")
        webManager.hideMBProgress(view: self.view)
    }
    @IBAction func backAction(_ sender: Any) {
        //self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
