//
//  Constants.swift
//  ShoppingList
//
//  Created by Ahmed Tawfik on 12/26/17.
//  Copyright © 2017 Fox Apps. All rights reserved.
//

import UIKit

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
        static let ItemIsDone = "itemIsDone"

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
    static let DemoListName = "Demo List"
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
    static let NoInternetTitle = "Check Internet Connection"
    static let NoInternetMessage = "Stay connected to get the full online features of the App"
}

// MARK: Notification Names
struct NotificationNames {
    static let UserListsUpdated = "UserListsUpdated"
    static let PredefinedItemsUpdated = "PredefinedItemsUpdated"
    static let UserListItemsUpdated = "UserListItemsUpdated"
}

// MARK: Segue Identifiers
struct SegueIdentiers {
    static let ListsView = "listsViewSegue"
    static let AddOrEditList = "AddEditListSegue"
    static let ListDetails = "listDetailsSegue"
}

struct ItemsSectionNames {
    static let ToDo = "ToDo"
    static let Done = "Done"
}

struct ResuableIDs {
    static let ListCell = "listCell"
    static let ItemCell = "itemCell"
    static let SectionHeader = "sectionHeader"
}

struct ListDetailsNavTitles {
    static let AddList = "Add List"
    static let EditList = "Edit List"
}

struct ListSortTypes {
    static let ByName = "ABC"
    static let ByDate = "123"
}

struct collectionViewFlowlayoutParameters {
    static let CollectionViewMargin: CGFloat = 2
    static let Space : CGFloat = 4.0
    static let ItemsPerLine = 3
}

struct ItemsPurchaseStatusText {
    static let AllItemsPurchased = "All items have been purchased"
    static let NoItemsInList = "No items included in this List"
}
