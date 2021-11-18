//
//  TableCollectionCell.swift
//  facturation
//
//  Created by Lucas Araujo on 05/07/21.
//  Copyright © 2021 Guarana Technologies Inc. All rights reserved.
//

import UIKit

class STCollectionBuilder<Cell: UICollectionViewCell> {
    var counter: (() -> Int)?
    var builder: ((IndexPath, Cell) -> Void)?
    var didClick: ((IndexPath) -> Void)?
    var setupCollection: ((STGenericCollectionView<Cell>?) -> Void)?
}

class STTableCollectionCell<Cell: UICollectionViewCell>: UITableViewCell {
    
    var builder: STCollectionBuilder<Cell>?
    
    lazy var collection: STGenericCollectionView<Cell> = {
        let controller = STGenericCollectionView<Cell>()
        return controller
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        collection.clear()
    }
    
    func configureLayout() {
        
        self.contentView.addSubview(collection.view)
        collection.view.setAllConstraints(on: self.contentView)
        
        collection.counter = { [weak self] in
            self?.builder?.counter?() ?? 0
        }
        
        collection.builder = { [weak self] index, cell in
            self?.builder?.builder?(index, cell)
        }
        
        collection.didClick = { [weak self] index in
            debugPrint(" [DEBUG] didClick on \(index.row)")
            self?.builder?.didClick?(index)
        }
        
        // Custom setup
        self.builder?.setupCollection?(collection)
        
        // Default setup
        collection.setupCollection()
        
        // Update data
        collection.collectionView?.reloadData()
    }
}
