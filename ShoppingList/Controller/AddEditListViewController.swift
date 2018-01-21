//
//  AddEditListViewController.swift
//  ShoppingList
//
//  Created by Ahmed Tawfik on 1/18/18.
//  Copyright © 2018 Fox Apps. All rights reserved.
//

import UIKit
import SDWebImage

class AddEditListViewController: UIViewController {

    // MARK: Properties
    
    var currentList: ShoppingList!
    var isNewList = true
    
    // MARK: IBOutlet
    
    @IBOutlet weak var listName: UITextField!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var listDetailsNavItem: UINavigationItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    // MARK: App Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseClient.sharedInstance().observePredefinedItems()
        configureListForEdit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        unSubscribeToNotifications()
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
    
    @objc func loadData() {
        collectionView.reloadData()
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

// MARK: Extension AddEditListViewController - CollectionView Delegate and DataSource

extension AddEditListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(Model.sharedInstance().predefinedItems)
        return Model.sharedInstance().predefinedItems.count != 0 ? Model.sharedInstance().predefinedItems.count : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reusedId = "itemCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reusedId, for: indexPath) as! ItemCell
        let itemImageURL = URL(string: Model.sharedInstance().predefinedItems[indexPath.row].itemThumbnailURL)
        
        cell.itemImageView.sd_setImage(with: itemImageURL, placeholderImage: #imageLiteral(resourceName: "placeHolder"))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let selectedItem = Model.sharedInstance().predefinedItems[indexPath.row]
        let selectedCell = collectionView.cellForItem(at: indexPath) as! ItemCell
//        let templateImage = selectedCell.itemImageView.image?.withRenderingMode(.alwaysTemplate)
//        selectedCell.itemImageView.image = templateImage
//        selectedCell.itemImageView.tintColor = UIColor.orange
    }
}

// MARK: Extension AddEditListViewController - Notifications

extension AddEditListViewController {
    func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(loadData),
                                               name: NSNotification.Name(NotificationNames.UserListsUpdated),
                                               object: FirebaseClient.sharedInstance())
    }
    
    func unSubscribeToNotifications() {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name(NotificationNames.PredefinedItemsUpdated),
                                                  object: nil)
    }
}

