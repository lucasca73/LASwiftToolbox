//
//  GenericCollectionView.swift
//  facturation
//
//  Created by Lucas Araujo on 05/07/21.
//  Copyright © 2021 Guarana Technologies Inc. All rights reserved.
//

import UIKit

class STGenericCollectionView<Cell: UICollectionViewCell>: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    var builder: ((_ indexPath: IndexPath, _ cell: Cell) -> Void)?
    var counter: (() -> Int)?
    
    var spacing: CGFloat = 12
    var insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    var collectionView: UICollectionView?
    
    var didClick: ((IndexPath) -> Void)?
    
    func clear() {
        didClick = nil
        builder = nil
        counter = nil
        collectionView?.removeFromSuperview()
        collectionView = nil
    }
    
    func setupCollection() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = spacing
        flowLayout.minimumLineSpacing = spacing
        flowLayout.scrollDirection = .horizontal
        flowLayout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
        
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.showsVerticalScrollIndicator = false
        
        collectionView?.register(cellType: Cell.self)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        
        if let collection = collectionView {
            self.view.addSubview(collection)
            collectionView?.setAllConstraints(on: self.view)
        }
        
        collectionView?.backgroundColor = .white
        self.view.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.layoutIfNeeded()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return counter?() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: Cell.self, for: indexPath)
        builder?(indexPath, cell)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return insets
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didClick?(indexPath)
    }
}
