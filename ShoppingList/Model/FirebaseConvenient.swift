//
//  FirebaseConvenient.swift
//  ShoppingList
//
//  Created by Ahmed Tawfik on 1/10/18.
//  Copyright © 2018 Fox Apps. All rights reserved.
//

import Firebase

extension FirebaseClient {
    
    // MARK: User
    
    func getUserNode(for userID: String, completionHandler:@escaping (_ user: SLUser?) -> Void) {
        readDataOnce(at: substituteKeyInNodePath(NodePath.UserNode, key: NodePathKeys.UserID, value: userID)!) { (results, error) in
            guard error == nil else {
                completionHandler(nil)
                return
            }
            if let userData = results as? [String: AnyObject] {
                var currentUser = SLUser()
                currentUser.userID = userID
                if let displayName = userData[NodeKeys.DisplayName] as? String {
                    currentUser.displayName = displayName
                }
                if let email = userData[NodeKeys.Email] as? String {
                    currentUser.email = email
                }
                if let listKeys = userData[NodeKeys.Lists] as? [String: String] {
                    Model.sharedInstance().currentUser.lists = [ShoppingList]()
                    for (listKey, _) in listKeys {
                        self.readDataOnce(at: self.substituteKeyInNodePath(NodePath.UserListDetailsKey, key: NodePathKeys.ListKey, value: listKey)!, completionHandler: { (results, error) in
                            guard error == nil else {
                                return
                            }
                            if var userList = results as? [String: AnyObject] {
                                userList[NodeKeys.ListKey] = listKey as AnyObject
                                let shoppingList = ShoppingList(dictionary: userList)
                                currentUser.lists.append(shoppingList)
                            }
                        })
                    }
                }
                completionHandler(currentUser)
            } else {
                completionHandler(nil)
            }
        }
    }

    func addNewUser(for user: SLUser) {
        writeData(at: substituteKeyInNodePath(NodePath.UserDisplayName, key: NodePathKeys.UserID, value: user.userID)!, value: user.displayName as AnyObject)
        writeData(at: substituteKeyInNodePath(NodePath.UserEmail, key: NodePathKeys.UserID, value: user.userID)!, value: user.email as AnyObject)
        
        if user.lists.count == 1 {
            addNewListToUser(user.lists[0], user.userID)
        } else {
            for index in 0 ... user.lists.count - 1 {
                addNewListToUser(user.lists[index], user.userID)
            }
        }
    }
    
    // MARK: List
    
    func addNewListToUser(_ list: ShoppingList, _ userID: String) {
        let listMetaDataDictionary = getDictionaryFromList(list)
        let key = addChildByAutoID(at: NodePath.ListsNode, value: listMetaDataDictionary as AnyObject)
        writeData(at: substituteKeyInNodePath(substituteKeyInNodePath(NodePath.UserListKey, key: NodePathKeys.UserID, value: userID)!, key: NodePathKeys.ListKey, value: key)!, value: key as AnyObject)
        if list.listKey == "" {
            writeData(at: substituteKeyInNodePath(NodePath.UserListDetailsKeyValue, key: NodePathKeys.ListKey, value: key)!, value: key as AnyObject)
        }
        let listItemsDictionary = getDictionaryFromItems(list.items)
        writeData(at: substituteKeyInNodePath(NodePath.ListItems, key: NodePathKeys.ListKey, value: key)!, value: listItemsDictionary as AnyObject)
    }
    
    func updateListToUser(_ list: ShoppingList, _ userID: String) {
        writeData(at: substituteKeyInNodePath(NodePath.UserListDetailsListName, key: NodePathKeys.ListKey, value: list.listKey)!, value: list.listName as AnyObject)
        writeData(at: substituteKeyInNodePath(NodePath.UserListDetailsDueDate, key: NodePathKeys.ListKey, value: list.listKey)!, value: list.dueDate as AnyObject)
        let listItemsDictionary = getDictionaryFromItems(list.items)
        writeData(at: substituteKeyInNodePath(NodePath.UserListDetailsItems, key: NodePathKeys.ListKey, value: list.listKey)!, value: listItemsDictionary as AnyObject)
    }
    
    func observeUserLists(for userID: String) {
        addObserver(at: substituteKeyInNodePath(NodePath.UserLists, key: NodePathKeys.UserID, value: userID)!) { (results, error) in
            guard error == nil else {
                return
            }
            if let listKeys = results as? [String: String] {
                Model.sharedInstance().currentUser.lists = [ShoppingList]()
                for (listKey, _) in listKeys {
                    self.addObserver(at: self.substituteKeyInNodePath(NodePath.UserListDetailsKey, key: NodePathKeys.ListKey, value: listKey)!, completionHandler: { (results, error) in
                        guard error == nil else {
                            return
                        }
                        if var userList = results as? [String: AnyObject] {
                            let userListKey = userList[NodeKeys.ListKey] as! String
                            if let index = Model.sharedInstance().currentUser.lists.index(where: { $0.listKey == userListKey }) {
                                Model.sharedInstance().currentUser.lists.remove(at: index)
                                
                                userList[NodeKeys.ListKey] = userListKey as AnyObject
                                let shoppingList = ShoppingList(dictionary: userList)
                                Model.sharedInstance().currentUser.lists.append(shoppingList)

                            } else {
                                userList[NodeKeys.ListKey] = listKey as AnyObject
                                let shoppingList = ShoppingList(dictionary: userList)
                                Model.sharedInstance().currentUser.lists.append(shoppingList)
                            }
                        }
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.UserListsUpdated + userID), object: self)
                        }
                    })
                }
            } else {
                Model.sharedInstance().currentUser.lists = [ShoppingList]()
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.UserListsUpdated + userID), object: self)
                }
            }
        }
    }
    
    func deleteListWithKey(_ listKey: String, userID: String) {
//        removeObserver(at: substituteKeyInNodePath(NodePath.UserLists, key: NodePathKeys.UserID, value: userID)!)
        removeObserver(at: substituteKeyInNodePath(NodePath.UserListDetailsKey, key: NodePathKeys.ListKey, value: listKey)!)
        deleteData(at: substituteKeyInNodePath(NodePath.UserListDetailsKey, key: NodePathKeys.ListKey, value: listKey)!)
        deleteData(at: substituteKeyInNodePath(substituteKeyInNodePath(NodePath.UserListKey, key: NodePathKeys.UserID, value: userID)!, key: NodePathKeys.ListKey, value: listKey)!)
    }
    
    // MARK: Items

    func getPredefinedItems() {
        readDataOnce(at: NodePath.PredefinedItems) { (results, error) in
            guard error == nil else {
                return
            }
            
            if let predefinedItems = results as? [String: AnyObject] {
                Model.sharedInstance().predefinedItems = [ShoppingItem]()
                for (_, item) in predefinedItems {
                    if let item = item as? [String: AnyObject] {
                        let predefinedItem = ShoppingItem(dictionary: item)
                        Model.sharedInstance().predefinedItems.append(predefinedItem)
                    }
                }
                Model.sharedInstance().predefinedItems = Model.sharedInstance().predefinedItems.sorted(by: { $0.itemName.localizedCompare($1.itemName) == .orderedAscending })
            }
        }
    }
    
    func observePredefinedItems() {
        addObserver(at: NodePath.PredefinedItems) { (results, error) in
            guard error == nil else {
                return
            }
            
            if let predefinedItems = results as? [String: AnyObject] {
                Model.sharedInstance().predefinedItems = [ShoppingItem]()
                for (_, item) in predefinedItems {
                    if let item = item as? [String: AnyObject] {
                        let predefinedItem = ShoppingItem(dictionary: item)
                        Model.sharedInstance().predefinedItems.append(predefinedItem)
                    }
                }
                Model.sharedInstance().predefinedItems = Model.sharedInstance().predefinedItems.sorted(by: { $0.itemName.localizedCompare($1.itemName) == .orderedAscending })
            }
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.UserListsUpdated), object: self)
            }

        }
    }
    
    func updateItems(for listKey: String, items: [ShoppingItem]) {
        let itemsDictionary = getDictionaryFromItems(items)
        writeData(at: substituteKeyInNodePath(NodePath.ListItems, key: NodePathKeys.ListKey, value: listKey)!, value: itemsDictionary as AnyObject)
    }
    
    // MARK: Helper Functions
    
    private func substituteKeyInNodePath(_ nodePath: String, key: String, value: String) -> String? {
        if nodePath.range(of: "\(key)") != nil {
            return nodePath.replacingOccurrences(of: "\(key)", with: value)
        } else {
            return nil
        }
    }
    
    private func getDictionaryFromList(_ list: ShoppingList) -> [String: AnyObject] {
        return [NodeKeys.ListName: list.listName as AnyObject,
                NodeKeys.DueDate: list.dueDate as AnyObject,
                NodeKeys.ListKey: list.listKey as AnyObject]
    }

    private func getDictionaryFromItems(_ Items: [ShoppingItem]) -> [[String: AnyObject]] {
        var itemsDictionary = [[String: AnyObject]]()
        if Items.count != 0 {
            for i in 0 ... Items.count - 1 {
                let itemDictionary = [NodeKeys.ItemName: Items[i].itemName as AnyObject,
                                      NodeKeys.ItemCategory: Items[i].itemCategory as AnyObject,
                                      NodeKeys.ItemThumbnailURL: Items[i].itemThumbnailURL as AnyObject,
                                      NodeKeys.ItemIsDone: Items[i].itemIsDone as AnyObject]
                itemsDictionary.append(itemDictionary)
            }
        }
        return itemsDictionary
    }

    private func getStringFromDate(_ date: Date) -> String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MM-dd-yyyy"
        
        return dateFormater.string(from: date)
    }
    
    private func getDateFromString(_ string: String) -> Date {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MM-dd-yyyy"

        return dateFormater.date(from: string)!
    }
}
