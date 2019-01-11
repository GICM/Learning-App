//
//  CustomCommentVC.swift
//  protocolTask
//
//  Created by Rafi on 21/07/18.
//  Copyright © 2018 Rafi A. All rights reserved.
//

import UIKit

//Step:- 1
protocol CommentDelegates: class {
    func commentMe()
    func commentAnonymous()
    func canceled()
}

class CustomCommentVC: UIViewController {

    @IBOutlet weak var vwCommentView: UIView!
    var isSelected: Bool = false
    //Step:- 2
    weak var delegate: CommentDelegates? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func removePickerViews()
    {
        let commentView = vwCommentView.subviews
        for view in commentView
        {
            view.removeFromSuperview()
        }
    }
    
    //Remove
    @IBAction func cancel(_ sender: Any) {
        print("Cancel")
        if self.delegate != nil
        {
            self.delegate?.canceled()
        }
    }
    
    
    @IBAction func Me(_ sender: Any) {
        print("Me")
        if self.delegate != nil
        {
            self.delegate?.commentMe()
        }
        
    }
    
    @IBAction func Anonymous(_ sender: Any) {
        print("Anonymous")
        if self.delegate != nil
        {
            self.delegate?.commentAnonymous()
        }
    }
    
}
