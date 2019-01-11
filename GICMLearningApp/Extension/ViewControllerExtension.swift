//
//  ViewControllerExtension.swift
//  GICMLearningApp
//
//  Created by Rafi on 25/05/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import Foundation

extension UIViewController{
  
  func showLogoutConfirmAlert() {
    let alertController = UIAlertController(title: "Alert!", message: NSLocalizedString("Are you sure you want to logout?", comment:""), preferredStyle: .alert)
    
    let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
      UserDefaults.standard.setLoggedIn(value: false)
      Constants.appDelegateRef.requesetAutoLogoutProcess()
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
    }
    alertController.addAction(OKAction)
    alertController.addAction(cancelAction)
    self.navigationController?.present(alertController, animated: true, completion:nil)
  }
    
    //MARK: - Convert Time Stramp to Decimal Value
    func convert_decimal(dateString: String) -> Double
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let since1970 = formatter.date(from: dateString)?.timeIntervalSince1970
        return since1970 ?? 0.0
    }
}

extension Decodable {
  static func from(json: String, using encoding: String.Encoding = .utf8) -> Self? {
    guard let data = json.data(using: encoding) else { return nil }
    return Self.from(data: data)
  }
  
  static func from(data: Data) -> Self? {
    let decoder = JSONDecoder()
    do {
      return try decoder.decode(Self.self, from: data)
    } catch {
      print(error.localizedDescription)
      return nil
    }
  }
}

extension Date {
    func daysBetweenDate(toDate: Date) -> Int {
        let components = Calendar.current.dateComponents([.day], from: self, to: toDate)
        return components.day ?? 0
    }
}
