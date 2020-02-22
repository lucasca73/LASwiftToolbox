//
//  ExampleViewController.swift
//  GenericTable
//
//  Created by Lucas Araujo on 22/02/20.
//  Copyright © 2020 costa. All rights reserved.
//

import UIKit

class ExampleViewController: BaseViewController {
    
    var headerTitle: String
    
    init(title: String) {
        headerTitle = title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        headerTitle = ""
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Detail"
    }
    
    override func setupView() {
        
        add(cell: BodyTextCell.self) { cell in
            cell.setupView(text: self.headerTitle)
        }
        
    }
    
}
