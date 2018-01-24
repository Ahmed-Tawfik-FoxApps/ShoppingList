//
//  Model.swift
//  ShoppingList
//
//  Created by Ahmed Tawfik on 12/26/17.
//  Copyright © 2017 Fox Apps. All rights reserved.
//

import Foundation

class Model: NSObject {
    
    // MARK: - Current User/List/Item
    
    var currentUser = SLUser()
    var currentList = ShoppingList()
    var predefinedItems = [ShoppingItem]()
    var currentListItems = [ShoppingItem]()
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> Model {
        struct Singleton {
            static var sharedInstance = Model()
        }
        return Singleton.sharedInstance
    }
}

// MARK: - Shopping Item Category

//enum itemCategory: Int {case Grocery = 0, Other}

// MARK: - Shopping List User Model

struct SLUser {
    var userID = ""
    var displayName = ""
    var email = ""
    var lists = [ShoppingList]()
    
    mutating func sortListsByListName() {
        lists = lists.sorted(by: { $0.listName.localizedCompare($1.listName) == .orderedAscending })
    }
    
    mutating func sortListsByDueDate() {
        lists = lists.sorted(by: { $0.dueDate < $1.dueDate })
    }

}

// MARK: - Shopping List Model

struct ShoppingList {
    var listName = ""
    var dueDate = ""
    var listKey = ""
    var items = [ShoppingItem]()
    
    init() {
        listName = ""
        dueDate = ""
        listKey = ""
        items = [ShoppingItem]()
    }
    
    init(dictionary: [String: AnyObject]) {
        listName = dictionary[FirebaseClient.NodeKeys.ListName]! as! String
        dueDate = dictionary[FirebaseClient.NodeKeys.DueDate]! as! String
        listKey = dictionary[FirebaseClient.NodeKeys.ListKey]! as! String
        if let itemsDictionary = dictionary[FirebaseClient.NodeKeys.Items] as? [[String: AnyObject]] {
            if itemsDictionary.count != 0 {
                for item in itemsDictionary {
                        items.append(ShoppingItem(dictionary: item))
                }
            } else {
                items = [ShoppingItem]()
            }
        }
    }
    
    mutating func sortItemsByName() {
        items = items.sorted(by: { $0.itemName.localizedCompare($1.itemName) == .orderedAscending })
    }
    
    func getItemsPurchaseStatusInSections() -> [ItemsPurchaseStatus] {
        var toDoItems = [ShoppingItem]()
        var doneItems = [ShoppingItem]()
        for item in items {
            if !item.itemIsDone {
                toDoItems.append(item)
            } else if item.itemIsDone {
                doneItems.append(item)
            }
        }
        let toDoSetion = ItemsPurchaseStatus(purchaseStatus: ItemsSectionNames.ToDo, items: toDoItems)
        let doneSetion = ItemsPurchaseStatus(purchaseStatus: ItemsSectionNames.Done, items: doneItems)
        
        return [toDoSetion, doneSetion]
    }        
}

// MARK: - Shopping Item Model

struct ShoppingItem {
    var itemName = ""
    var itemCategory = ""
    var itemThumbnailURL = ""
    var itemIsDone = false
    
    init() {
        itemName = ""
        itemCategory = ""
        itemThumbnailURL = ""
        itemIsDone = false
    }
    
    init(dictionary: [String: AnyObject]) {
        itemName = dictionary[FirebaseClient.NodeKeys.ItemName]! as! String
        itemCategory = dictionary[FirebaseClient.NodeKeys.ItemCategory]! as! String
        itemThumbnailURL = dictionary[FirebaseClient.NodeKeys.ItemThumbnailURL]! as! String
        itemIsDone = dictionary[FirebaseClient.NodeKeys.ItemIsDone]! as? Bool ?? false
    }
}

// MARK: - Shopping Item Model

struct ItemsPurchaseStatus {
    var purchaseStatus: String
    var items: [ShoppingItem]
}

