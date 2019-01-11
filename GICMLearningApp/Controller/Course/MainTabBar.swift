//
//  MainTabBarController.swift
//  TabBarSolution
//
//  Created by Dejan Skledar on 03/07/2017.
//  Copyright © 2017 FERI. All rights reserved.
//

import UIKit

class MainTabBar: UITabBar {

    private var middleButton = UIButton()
    private var middleButton2 = UIButton()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.tintColor = UIColor.gray
        setupMiddleButton()
    }
   
    func setupMiddleButton() {
        middleButton.frame.size = CGSize(width: UIScreen.main.bounds.width / 5, height: 49)
        middleButton.backgroundColor = .clear
        middleButton.layer.masksToBounds = true
        middleButton.setImage(UIImage(named: "Add"), for: .normal)
        middleButton.imageView?.contentMode = .scaleAspectFit
        middleButton.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: 25)
        middleButton.addTarget(self, action: #selector(plusButton), for: .touchUpInside)
        addSubview(middleButton)
        
//        middleButton2.frame.size = CGSize(width: UIScreen.main.bounds.width / 5, height: 50)
//        middleButton2.backgroundColor = .clear
//        middleButton2.layer.masksToBounds = true
//        middleButton2.setImage(UIImage(named: "friendsInvites"), for: .normal)
//        middleButton2.imageView?.contentMode = .scaleAspectFit
//        middleButton2.center = CGPoint(x: UIScreen.main.bounds.width / 2 + UIScreen.main.bounds.width / 5, y: 25)
//        middleButton2.addTarget(self, action: #selector(planeButton), for: .touchUpInside)
//        addSubview(middleButton2)
    }

    @objc func plusButton() {
       CustomMenu.sharedInstance.handleMenu(plus: true)
    }
    @objc func planeButton() {
      //  CustomMenu.sharedInstance.handleMenu(plus: false)
    }
   
}
