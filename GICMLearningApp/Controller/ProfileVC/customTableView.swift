//
//  customTableView.swift
//  GICM
//
//  Created by CIPL0449 on 4/5/19.
//  Copyright © 2019 Praveenkumar R. All rights reserved.
//

import UIKit

protocol customGoalDelegate {
    func cancel()
    func saveGoalValues(goalArray : [String])
    func removeCustomGoal()
}

class customTableView: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var txtCustomGoal: UITextField!
    @IBOutlet weak var tblGoal: UITableView!
    var delegate :customGoalDelegate? = nil
    var isOtherSelect = false
    var arrPopUpData = ["drive to optimize","male people happy","earn money the tough way","learn fast deep and/or broad","dream of something better","to create a legacy","to lead"]
    var arrChoosedText = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblGoal.delegate = self
        self.tblGoal.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    //MARK:- TAbleView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrPopUpData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customTableViewCell", for: indexPath) as! customTableViewCell
        let strText = arrPopUpData[indexPath.row]
        cell.lblGoal.text = strText
        checkSelectedText(cell: cell, currentText: strText)
        cell.selectionStyle = .none
        return cell
    }
    
    //Check Image Selected
    func checkSelectedText(cell: customTableViewCell, currentText: String){
        if arrChoosedText.contains(currentText)
        {
            cell.imgSelect.image = UIImage(named:"check")
        }
        else
        {
            cell.imgSelect.image = UIImage(named: "unCheck")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.getSelectedText(selectedIndex: indexPath.row)
    }
    
    //MARK:-Multi Selection For Goal
    func getSelectedText(selectedIndex : Int)
    {
        let selectedIndex = arrPopUpData[selectedIndex]
        if arrChoosedText.count > 0{
            if arrChoosedText.contains(selectedIndex){
                arrChoosedText = arrChoosedText.filter{ $0 != selectedIndex }
                //remove particular Value and Text
            }else{
                if self.arrChoosedText.count >= 3{
                    Utilities.sharedInstance.showToast(message: "maximum of three goals reached")
                    return
                }
                arrChoosedText.append(selectedIndex)
                //Add particular Value and Text functionality
            }
        }
        else{
            if self.arrChoosedText.count >= 3{
                Utilities.sharedInstance.showToast(message: "maximum of three goals reached")
                return
            }
            arrChoosedText.append(selectedIndex)
        }
        
        self.tblGoal.reloadData()
        print("Selected Text  ------------> ",arrChoosedText)
    }
    
    
    //MARK:- Button Action
    @IBAction func cancelAction(_ sender: Any) {
        if self.delegate != nil
        {
            self.delegate?.cancel()
        }
    }
    
    @IBAction func saveAction(_ sender: Any) {
        if self.delegate != nil
        {
             self.delegate?.saveGoalValues(goalArray: self.arrChoosedText)
        }
    }
}


extension customTableView: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let selectedIndex = textField.text
        
        if arrChoosedText.count > 0{
           
                if self.arrChoosedText.count >= 3{
                    Utilities.sharedInstance.showToast(message: "maximum of three goals reached")
                    return
                }else{
                
                if selectedIndex?.count == 0{
                    arrChoosedText = arrChoosedText.filter{ $0 != selectedIndex }
                    return
                }
                arrChoosedText.append(selectedIndex ?? "")
                //Add particular Value and Text functionality
            }
            }
        else{
                if selectedIndex?.count == 0{
                    arrChoosedText = arrChoosedText.filter{ $0 != selectedIndex }
                    return
                }
            arrChoosedText.append(selectedIndex ?? "")
        }
         print("Selected Text  ------------> ",arrChoosedText)
    }
}
