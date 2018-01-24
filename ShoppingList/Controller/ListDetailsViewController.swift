//
//  ListDetailsViewController.swift
//  ShoppingList
//
//  Created by Ahmed Tawfik on 1/23/18.
//  Copyright © 2018 Fox Apps. All rights reserved.
//

import UIKit

class ListDetailsViewController: UIViewController {

    // MARK: Properties
    
    var currentList: ShoppingList!
    var currentListItemsInSections: [ItemsPurchaseStatus]!
    
    // MARK: IBOutlet
    @IBOutlet weak var listDetailsNavItem: UINavigationItem!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var completionPercentageLable: UILabel!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    
    // MARK: App Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        // Configure Collection View Flow Layout
        configureFlowLayoutForWidth(view.frame.size.width - collectionViewFlowlayoutParameters.CollectionViewMargin)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureListCompletionPercentage()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        configureFlowLayoutForWidth(size.width - collectionViewFlowlayoutParameters.CollectionViewMargin)
    }
    
    // MARK: Helper Functions
    
    private func configureUI() {
        listDetailsNavItem.title = currentList.listName
    }
    
    private func configureListCompletionPercentage() {
        if currentListItemsInSections[1].items.count == currentList.items.count {
            completionPercentageLable.text = "All items has been purchased"
            UIView.animate(withDuration: 0.5, animations: {
                self.checkmarkImageView.alpha = 1
            })
        } else {
            completionPercentageLable.text = "Done: \(currentListItemsInSections[1].items.count) / \(currentListItemsInSections[1].items.count)"
            UIView.animate(withDuration: 0.5, animations: {
                self.checkmarkImageView.alpha = 0
            })
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

    private func reloadData() {
        collectionView.reloadData()
    }
}

// MARK: Extension ListDetailsViewController - CollectionView Delegate and DataSource

extension ListDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return currentListItemsInSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentListItemsInSections[section].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ResuableIDs.ItemCell, for: indexPath) as! ItemCell
        
        let itemCategory = currentListItemsInSections[indexPath.section]
        let itemImageURL = URL(string: itemCategory.items[indexPath.item].itemThumbnailURL)
        cell.itemImageView.sd_setImage(with: itemImageURL, placeholderImage: #imageLiteral(resourceName: "placeHolder"))

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ResuableIDs.SectionHeader, for: indexPath) as! ItemsSectionHeader
        
        sectionHeaderView.itemsCategory = currentListItemsInSections[indexPath.section]
        
        return sectionHeaderView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = currentListItemsInSections[indexPath.section].items[indexPath.row]
        if let index = currentList.items.index(where: {$0.itemName == selectedItem.itemName})?.hashValue {
            currentList.items[index].itemIsDone = !currentList.items[index].itemIsDone
            FirebaseClient.sharedInstance().updateItems(for: currentList.listKey, items: currentList.items.sorted(by: {$0.itemName < $1.itemName}))
            currentListItemsInSections = currentList.getItemsPurchaseStatusInSections()
            configureListCompletionPercentage()
            collectionView.reloadData()
        }
    }
}
