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
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> Model {
        struct Singleton {
            static var sharedInstance = Model()
        }
        return Singleton.sharedInstance
    }
}

// MARK: - Shopping Item Category

enum itemCategory: Int {case Grocery = 0, Other}

// MARK: - Shopping List User Model

struct SLUser {
    var userID = ""
    var displayName = ""
    var email = ""
    var lists = [ShoppingList]()
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
        items = [ShoppingItem]()
    }
    
    init(dictionary: [String: AnyObject]) {
        listName = dictionary[FirebaseClient.NodeKeys.ListName]! as! String
        dueDate = dictionary[FirebaseClient.NodeKeys.DueDate]! as! String
        listKey = dictionary[FirebaseClient.NodeKeys.ListKey]! as! String
    }
}

// MARK: - Shopping Item Model

struct ShoppingItem {
    var itemName = ""
    var itemCategory : itemCategory = .Other
}
