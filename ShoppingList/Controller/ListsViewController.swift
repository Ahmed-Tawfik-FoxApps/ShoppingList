//
//  ListsViewController.swift
//  ShoppingList
//
//  Created by Ahmed Tawfik on 12/25/17.
//  Copyright © 2017 Fox Apps. All rights reserved.
//

import UIKit
import Firebase

class ListsViewController: UIViewController {

    // MARK: Properties
    
    // MARK: IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: App Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseClient.sharedInstance().observeUserLists(for: Model.sharedInstance().currentUser.userID)
        addLongPressGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unSubscribeToNotifications()
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
    
    // MARK: Configure the Edit Row and Load Data
    
    private func addLongPressGestureRecognizer () {
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(editList))
        longPressGestureRecognizer.minimumPressDuration = 1.0
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
            if let ListDetailsViewController = segue.destination as? ListDetailsViewController {
                if let _ = sender as? UILongPressGestureRecognizer {
                    ListDetailsViewController.currentList = Model.sharedInstance().currentList
                    ListDetailsViewController.isNewList = false
                } else if let _ = sender as? UIBarButtonItem {
                    ListDetailsViewController.currentList = ShoppingList()
                    ListDetailsViewController.isNewList = true
                }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell")
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

