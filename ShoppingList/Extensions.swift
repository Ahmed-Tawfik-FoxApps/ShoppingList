//
//  Extensions.swift
//  ShoppingList
//
//  Created by Ahmed Tawfik on 1/18/18.
//  Copyright © 2018 Fox Apps. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alerts.DismissAlert, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func getStringFromDate(_ date: Date) -> String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MM-dd-yyyy"
        
        return dateFormater.string(from: date)
    }
    
    func getDateFromString(_ string: String) -> Date {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MM-dd-yyyy"
        
        return dateFormater.date(from: string)!
    }
}
