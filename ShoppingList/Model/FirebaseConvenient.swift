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
                    completionHandler(currentUser)
                } else {
                    completionHandler(nil)
                }
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
        let listDictionary = getDictionaryFromList(list)
        let key = addChildByAutoID(at: NodePath.ListsNode, value: listDictionary as AnyObject)
        writeData(at: substituteKeyInNodePath(substituteKeyInNodePath(NodePath.UserListKey, key: NodePathKeys.UserID, value: userID)!, key: NodePathKeys.ListKey, value: key)!, value: key as AnyObject)
        if list.listKey == "" {
            writeData(at: substituteKeyInNodePath(NodePath.UserListDetailsKeyValue, key: NodePathKeys.ListKey, value: key)!, value: key as AnyObject)
            // To be Added -- Update list items
        }
    }
    
    func updateListToUser(_ list: ShoppingList, _ userID: String) {
        writeData(at: substituteKeyInNodePath(NodePath.UserListDetailsListName, key: NodePathKeys.ListKey, value: list.listKey)!, value: list.listName as AnyObject)
        writeData(at: substituteKeyInNodePath(NodePath.UserListDetailsDueDate, key: NodePathKeys.ListKey, value: list.listKey)!, value: list.dueDate as AnyObject)
        // To be Added -- Update list items
    }
    
    func observeUserLists(for userID: String) {
        addObserver(at: substituteKeyInNodePath(NodePath.UserLists, key: NodePathKeys.UserID, value: userID)!) { (results, error) in
            guard error == nil else {
                return
            }
            if let listKeys = results as? [String: String] {
                Model.sharedInstance().currentUser.lists = [ShoppingList]()
                for (listKey, _) in listKeys {
                    self.readDataOnce(at: self.substituteKeyInNodePath(NodePath.UserListDetailsKey, key: NodePathKeys.ListKey, value: listKey)!, completionHandler: { (results, error) in
                        guard error == nil else {
                            return
                        }
                        if var userList = results as? [String: AnyObject] {
                            userList[NodeKeys.ListKey] = listKey as AnyObject
                            let shoppingList = ShoppingList(dictionary: userList)
                            Model.sharedInstance().currentUser.lists.append(shoppingList)
                        }
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.UserListsUpdated + userID), object: self)
                        }
                    })
                }
            }
        }
    }
    
    func deleteListWithKey(_ listKey: String, userID: String) {
        deleteData(at: substituteKeyInNodePath(NodePath.UserListDetailsKey, key: NodePathKeys.ListKey, value: listKey)!)
        deleteData(at: substituteKeyInNodePath(substituteKeyInNodePath(NodePath.UserListKey, key: NodePathKeys.UserID, value: userID)!, key: NodePathKeys.ListKey, value: listKey)!)
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
                NodeKeys.ListKey: list.listKey as AnyObject,
                NodeKeys.Items: list.items as AnyObject]
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
