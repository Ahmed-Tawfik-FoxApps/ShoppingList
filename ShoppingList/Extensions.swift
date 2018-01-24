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
    
    func getDictionaryFromItems(_ Items: [ShoppingItem]) -> [[String: AnyObject]] {
        var itemsDictionary = [[String: AnyObject]]()
        if Items.count != 0 {
            for i in 0 ... Items.count - 1 {
                let itemDictionary = [FirebaseClient.NodeKeys.ItemName: Items[i].itemName as AnyObject,
                                      FirebaseClient.NodeKeys.ItemCategory: Items[i].itemCategory as AnyObject,
                                      FirebaseClient.NodeKeys.ItemThumbnailURL: Items[i].itemThumbnailURL as AnyObject,
                                      FirebaseClient.NodeKeys.ItemIsDone: Items[i].itemIsDone as AnyObject]
                itemsDictionary.append(itemDictionary)
            }
        }
        return itemsDictionary
    }
}
