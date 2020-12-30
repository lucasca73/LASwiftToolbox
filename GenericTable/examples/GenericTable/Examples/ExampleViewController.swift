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
        reloadView(animated: false)
    }
    
    override func setupView() {
        
        // Passing didClick as parameter
        let textBuilder = TextBuilder(text: self.headerTitle, didClick: didClickInCell)
        
        // Using different builders
        add(cell: BodyTextCell.self, builder: textBuilder.buildGreen)
        
        add(cell: BodyTextCell.self, builder: textBuilder.build)
    }
    
    func didClickInCell(_ indexPath: IndexPath) {
        navigationController?.pushViewController(ExampleModelTable(), animated: true)
    }
    
}

struct TextBuilder {
    var text: String
    var didClick: ((IndexPath) -> Void)?
    
    func build(cell: BodyTextCell) {
        cell.setupView(text: text)
        cell.didClick = didClick
    }
    
    func buildGreen(cell: BodyTextCell) {
        cell.setupView(text: text)
        cell.didClick = didClick
        cell.backgroundColor = UIColor.green
    }
}
