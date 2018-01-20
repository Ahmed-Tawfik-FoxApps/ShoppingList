//
//  ListDetailsViewController.swift
//  ShoppingList
//
//  Created by Ahmed Tawfik on 1/18/18.
//  Copyright © 2018 Fox Apps. All rights reserved.
//

import UIKit

class ListDetailsViewController: UIViewController {

    // MARK: Properties
    
    var currentList: ShoppingList!
    var isNewList = true
    
    // MARK: IBOutlet
    
    @IBOutlet weak var listName: UITextField!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var listDetailsNavItem: UINavigationItem!
    
    // MARK: App Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureListForEdit()
    }
    
    // MARK: IBAction
    
    @IBAction func doneEditingList(_ sender: UIBarButtonItem) {
        guard let listName = listName.text, !listName.isEmpty else {
            showAlert(Alerts.EmptyListNameTitle, message: Alerts.EmptyListNameMessage)
            return
        }
        let dueDate = getStringFromDate(dueDatePicker.date)
        currentList.listName = listName
        currentList.dueDate = dueDate
        if isNewList {
            FirebaseClient.sharedInstance().addNewListToUser(currentList, Model.sharedInstance().currentUser.userID)
        } else {
            FirebaseClient.sharedInstance().updateListToUser(currentList, Model.sharedInstance().currentUser.userID)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: Helper Functions
    
    func configureListForEdit() {
        switch isNewList {
        case true:
            listDetailsNavItem.title = "Add List"
            listName.text = ""
            dueDatePicker.date = Date().addingTimeInterval(Constants.SecondsForDay)
        case false:
            listDetailsNavItem.title = "Edit List"
            listName.text = currentList.listName
            dueDatePicker.date = getDateFromString(currentList.dueDate)
        }
    }
}
