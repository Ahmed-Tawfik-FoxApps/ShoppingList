//
//  AddEditListViewController.swift
//  ShoppingList
//
//  Created by Ahmed Tawfik on 1/18/18.
//  Copyright © 2018 Fox Apps. All rights reserved.
//

import UIKit
import SDWebImage
import ReachabilitySwift

class AddEditListViewController: UIViewController {

    // MARK: Properties
    
    fileprivate var reachability = Reachability()!
    var currentList: ShoppingList!
    var currentListItems: [ShoppingItem]!
    var isNewList = true
    
    // MARK: IBOutlet
    
    @IBOutlet weak var listName: UITextField!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var listDetailsNavItem: UINavigationItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    // MARK: ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseClient.sharedInstance().observePredefinedItems()
        configureListForEdit()
        addTapGesture()
        // Configure Collection View Flow Layout
        configureFlowLayoutForWidth(view.frame.size.width - collectionViewFlowlayoutParameters.CollectionViewMargin)
        collectionView.allowsMultipleSelection = true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        configureFlowLayoutForWidth(size.width - collectionViewFlowlayoutParameters.CollectionViewMargin)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToNotifications()
        startObservingReachability(reachability)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        unSubscribeToNotifications()
        stopObservingReachability(reachability)
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
        currentList.items = currentListItems.sorted(by: {$0.itemName < $1.itemName})
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

    // MARK: Configure UI
    
    private func addTapGesture() {
        //Dismiss the keyboard in case the user click anywhere else in the screen
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: Helper Functions
    
    func configureListForEdit() {
        listName.becomeFirstResponder()
        switch isNewList {
        case true:
            listDetailsNavItem.title = ListDetailsNavTitles.AddList
            listName.text = ""
            dueDatePicker.date = Date().addingTimeInterval(Constants.SecondsForDay)
        case false:
            listDetailsNavItem.title = ListDetailsNavTitles.EditList
            listName.text = currentList.listName
            dueDatePicker.date = getDateFromString(currentList.dueDate)
        }
    }
    
    private func configureFlowLayoutForWidth (_ width: CGFloat) {
        if collectionViewFlowLayout != nil {
            let dimension = (width - (CGFloat(collectionViewFlowlayoutParameters.ItemsPerLine - 1) * collectionViewFlowlayoutParameters.Space)) / CGFloat(collectionViewFlowlayoutParameters.ItemsPerLine)

            collectionViewFlowLayout.minimumInteritemSpacing = collectionViewFlowlayoutParameters.Space
            collectionViewFlowLayout.minimumLineSpacing = collectionViewFlowlayoutParameters.Space
            collectionViewFlowLayout.itemSize = CGSize(width: dimension, height: dimension)
        }
    }
}

// MARK: Extension AddEditListViewController - CollectionView Delegate and DataSource

extension AddEditListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Model.sharedInstance().predefinedItems.count != 0 ? Model.sharedInstance().predefinedItems.count : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ResuableIDs.ItemCell, for: indexPath) as! ItemCell
        let itemImageURL = URL(string: Model.sharedInstance().predefinedItems[indexPath.row].itemThumbnailURL)
        
        cell.itemImageView.sd_setShowActivityIndicatorView(true)
        cell.itemImageView.sd_setIndicatorStyle(.whiteLarge)
        cell.itemImageView.sd_setImage(with: itemImageURL, placeholderImage: #imageLiteral(resourceName: "placeHolder"))
        
        if currentListItems.contains(where: {$0.itemName == Model.sharedInstance().predefinedItems[indexPath.row].itemName}) {
            cell.isSelected = true
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
        }
        cell.contentView.backgroundColor = cell.isSelected ? .lightGray : .clear

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath) as! ItemCell
        selectedCell.contentView.backgroundColor = .lightGray

        let selectedItem = Model.sharedInstance().predefinedItems[indexPath.row]
            currentListItems.append(selectedItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath) as! ItemCell
        selectedCell.contentView.backgroundColor = .clear

        let selectedItem = Model.sharedInstance().predefinedItems[indexPath.row]
        if let index = currentListItems.index(where: {$0.itemName == selectedItem.itemName}) {
            currentListItems.remove(at: index)
        }
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

extension AddEditListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        dismissKeyboard()
        return true
    }
}

