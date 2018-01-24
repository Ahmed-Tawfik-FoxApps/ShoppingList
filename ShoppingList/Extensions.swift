//
//  Extensions.swift
//  ShoppingList
//
//  Created by Ahmed Tawfik on 1/18/18.
//  Copyright © 2018 Fox Apps. All rights reserved.
//

import UIKit
import ReachabilitySwift

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
    
    // MARK: Reachability Observing
    
    func startObservingReachability(_ reachability: Reachability) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification,object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    
    func stopObservingReachability(_ reachability: Reachability) {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self,
                                                  name: ReachabilityChangedNotification,
                                                  object: reachability)
    }
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        
        switch reachability.currentReachabilityStatus {
        case .reachableViaWiFi:
            print("Reachable via WiFi")
        case .reachableViaWWAN:
            print("Reachable via Cellular")
        case .notReachable:
            print("Network not reachable")
            showAlert(Alerts.NoInternetTitle, message: Alerts.NoInternetMessage)
        }
    }
}
