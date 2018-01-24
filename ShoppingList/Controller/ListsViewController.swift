//
//  ListsViewController.swift
//  ShoppingList
//
//  Created by Ahmed Tawfik on 12/25/17.
//  Copyright © 2017 Fox Apps. All rights reserved.
//

import UIKit
import Firebase
import ReachabilitySwift

class ListsViewController: UIViewController {

    // MARK: Properties
    
    fileprivate var reachability = Reachability()!
    
    // MARK: IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var listsSortButton: UIBarButtonItem!
    
    // MARK: App Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseClient.sharedInstance().observeUserLists(for: Model.sharedInstance().currentUser.userID)
        addLongPressGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToNotifications()
        loadData()
        startObservingReachability(reachability)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unSubscribeToNotifications()
        stopObservingReachability(reachability)
    }

    // MARK: IBAction
    
    @IBAction func signOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch {
            print("unable to sign out: \(error)")
        }
    }
    
    @IBAction func addNewList(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: SegueIdentiers.AddOrEditList, sender: sender)
    }
    
    @IBAction func listsSort(_ sender: UIBarButtonItem) {
        let sortListsByListName = UserDefaults.standard.bool(forKey: Constants.SortListsByListName)
        UserDefaults.standard.set(!sortListsByListName, forKey: Constants.SortListsByListName)
        UserDefaults.standard.synchronize()
        loadData()
    }
        
    // MARK: Configure the Edit Row and Load Data
    
    private func addLongPressGestureRecognizer () {
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(editList))
        longPressGestureRecognizer.minimumPressDuration = 0.5
        tableView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc func editList(press: UILongPressGestureRecognizer) {
        if press.state == .began {
            let touchPoint = press.location(in: tableView)
            if let listIndexPathRow = tableView.indexPathForRow(at: touchPoint)?.row {
                Model.sharedInstance().currentList = Model.sharedInstance().currentUser.lists[listIndexPathRow]
                performSegue(withIdentifier: SegueIdentiers.AddOrEditList, sender: press)
            }
        }
    }

    @objc func loadData() {
        tableView.reloadData()
    }

    // MARK: Prepare for Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentiers.AddOrEditList {
            if let AddEditListViewController = segue.destination as? AddEditListViewController {
                if let _ = sender as? UILongPressGestureRecognizer {
                    AddEditListViewController.currentList = Model.sharedInstance().currentList
                    AddEditListViewController.currentListItems = Model.sharedInstance().currentList.items
                    AddEditListViewController.isNewList = false
                } else if let _ = sender as? UIBarButtonItem {
                    AddEditListViewController.currentList = ShoppingList()
                    AddEditListViewController.currentListItems = [ShoppingItem]()
                    AddEditListViewController.isNewList = true
                }
            }
        } else if segue.identifier == SegueIdentiers.ListDetails {
            if let listDetailsViewController = segue.destination as? ListDetailsViewController {
                listDetailsViewController.currentList = Model.sharedInstance().currentList
                listDetailsViewController.currentListItemsInSections = Model.sharedInstance().currentList.getItemsPurchaseStatusInSections()
            }
        }
    }
}


// MARK: Extension ListsViewController - TableView Delegate and DataSource

extension ListsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Model.sharedInstance().currentUser.lists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ResuableIDs.ListCell)
        sortLists()
        cell?.textLabel?.text = Model.sharedInstance().currentUser.lists[indexPath.row].listName
        cell?.detailTextLabel?.text = "Due Date: \(Model.sharedInstance().currentUser.lists[indexPath.row].dueDate)"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deletedListKey = Model.sharedInstance().currentUser.lists[indexPath.row].listKey
            FirebaseClient.sharedInstance().deleteListWithKey(deletedListKey, userID: Model.sharedInstance().currentUser.userID)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Model.sharedInstance().currentList = Model.sharedInstance().currentUser.lists[indexPath.row]
        performSegue(withIdentifier: SegueIdentiers.ListDetails, sender: nil)
    }
    
    private func sortLists() {
        let sortListsByListName = UserDefaults.standard.bool(forKey: Constants.SortListsByListName)
        Model.sharedInstance().currentUser.sortListsByListName()
        if !sortListsByListName {
            Model.sharedInstance().currentUser.sortListsByDueDate()
        }
        listsSortButton.title = sortListsByListName ? ListSortTypes.ByDate : ListSortTypes.ByName
    }
}

// MARK: Extension ListsViewController - Notifications

extension ListsViewController {
    func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(loadData),
                                               name: NSNotification.Name(NotificationNames.UserListsUpdated + Model.sharedInstance().currentUser.userID),
                                               object: FirebaseClient.sharedInstance())
    }
    
    func unSubscribeToNotifications() {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name(NotificationNames.UserListsUpdated + Model.sharedInstance().currentUser.userID),
                                                  object: nil)
    }
}
