//
//  ItemsSectionHeader.swift
//  ShoppingList
//
//  Created by Ahmed Tawfik on 1/23/18.
//  Copyright © 2018 Fox Apps. All rights reserved.
//

import UIKit

class ItemsSectionHeader: UICollectionReusableView {
    
    @IBOutlet weak var sectionHeaderTitle: UILabel!
    
    var itemsCategory: ItemsPurchaseStatus! {
        didSet {
            sectionHeaderTitle.text = itemsCategory.purchaseStatus
        }
    }
}
