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
    var currentItem = ShoppingItem()
    var predefinedItems = [ShoppingItem]()
    
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
    }
    
    mutating func sortItemsByName() {
        items = items.sorted(by: { $0.itemName.localizedCompare($1.itemName) == .orderedAscending })
    }
}

// MARK: - Shopping Item Model

struct ShoppingItem {
    var itemName = ""
    var itemCategory = ""
    var itemThumbnailURL = ""
    
    init() {
        itemName = ""
        itemCategory = ""
        itemThumbnailURL = ""
    }
    
    init(dictionary: [String: AnyObject]) {
        itemName = dictionary[FirebaseClient.NodeKeys.ItemName]! as! String
        itemCategory = dictionary[FirebaseClient.NodeKeys.ItemCategory]! as! String
        itemThumbnailURL = dictionary[FirebaseClient.NodeKeys.ItemThumbnailURL]! as! String
    }
}
