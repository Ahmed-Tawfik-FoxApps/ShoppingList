//
//  Constants.swift
//  ShoppingList
//
//  Created by Ahmed Tawfik on 12/26/17.
//  Copyright © 2017 Fox Apps. All rights reserved.
//

import Foundation

extension FirebaseClient {
    struct NodeKeys {
        // User
        static let UserID = "userID"
        static let DisplayName = "displayName"
        static let Email = "email"
        static let Lists = "lists"
        
        // List
        static let ListName = "listName"
        static let DueDate = "dueDate"
        static let ListKey = "listKey"
        static let Items = "items"
        
        // Item
        static let ItemName = "itemName"
        static let ItemCategory = "itemCategory"
        static let ItemThumbnailURL = "itemThumbnailURL"

    }
    
    struct NodePath {
        // User
        static let UserNode = "/users/<userID>"
        static let UserDisplayName = "/users/<userID>/displayName"
        static let UserEmail = "/users/<userID>/email"
        static let UserLists = "/users/<userID>/lists"
        static let UserListKey = "/users/<userID>/lists/<listKey>"
        
        // List
        static let ListsNode = "/lists"
        static let UserListDetailsKey = "/lists/<listKey>"
        static let UserListDetailsKeyValue = "/lists/<listKey>/listKey"
        static let UserListDetailsListName = "/lists/<listKey>/listName"
        static let UserListDetailsDueDate = "/lists/<listKey>/dueDate"
        static let UserListDetailsItems = "/lists/<listKey>/items"

        // Items
        static let PredefinedItems = "/items-predefined"
        static let ListItems = "/lists/<listKey>/items"

    }
    
    struct NodePathKeys {
        static let UserID = "<userID>"
        static let ListKey = "<listKey>"
    }
}

// MARK: Global Constants

// MARK: Constants
struct Constants {
    static let SecondsForDay: Double = 86400
    static let SortListsByListName = "sortListsByListName"
}
// MARK: Alerts
struct Alerts {
    static let DismissAlert = "Dismiss"
    static let CancelAlert = "Cancel"
    static let OverwriteAlert = "Overwrite"
    static let EmptyListNameTitle = "List Name is not Set"
    static let EmptyListNameMessage = "List Name can't be Blank, please set the List Name"
}

// MARK: Notification Names
struct NotificationNames {
    static let UserListsUpdated = "UserListsUpdated"
    static let PredefinedItemsUpdated = "PredefinedItemsUpdated"
}

// MARK: Segue Identifiers
struct SegueIdentiers {
    static let ListsView = "listsViewSegue"
    static let AddOrEditList = "AddEditListSegue"
}


