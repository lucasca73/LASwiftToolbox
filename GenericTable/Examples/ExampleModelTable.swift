//
//  ExampleModelTable.swift
//  GenericTable
//
//  Created by Lucas Araujo on 25/02/20.
//  Copyright © 2020 costa. All rights reserved.
//

import UIKit

class ExampleModelTable: ModelTableViewController {
    
    let presenter = ExampleModelTablePresenter()
    
    override func setup() {
        let title = presenter.getTitle()
        add(title)
        
        let dataTable = presenter.getTable()
        
        if !dataTable.isEmpty {
            addSection(newSection: SectionExample())
            add( dataTable )
        }
        
        addSection(newSection: OtherSectionExample(), footer: FooterExample())
    }
}

class ExampleModelTablePresenter {
    
    func getTitle() -> TitleModel {
        let title = TitleModel(title: "Meu título")
        return title
    }
    
    func getTable() -> [TextModel] {
        
        var data = [TextModel]()
        
        for i in 0...3 {
            let model = TextModel(text: "Hello \(i)")
            data.append(model)
        }
        
        return data
    }
    
}


// Examples of Models and Sections

class TextModel: DataModel<BodyTextCell> {
    var text: String
    
    init(text: String) {
        self.text = text
    }
    
    override func setup(cell: BodyTextCell) {
        cell.bodyLabel.text = text
    }
}

class TitleModel: DataModel<BodyTextCell> {
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    override func setup(cell: BodyTextCell) {
        cell.bodyLabel.text = title
        cell.bodyLabel.font = UIFont(name: "Arial", size: 20)
        cell.bodyLabel.textAlignment = .center
    }
}

class SectionExample: TableSectionProtocol {
    var title: String? = "Example"
    var height: CGFloat? = 50
    
    func setup() -> UIView? {
        return nil
    }
}

class OtherSectionExample: TableSectionProtocol {
    var title: String?
    var height: CGFloat? = 50
    
    func setup() -> UIView? {
        let bounds = UIScreen.main.bounds
        let view = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 50) )
        view.backgroundColor = .gray
        
        return view
    }
}

class FooterExample: TableFooterProtocol {
    var title: String? = "Footer 3000"
    var height: CGFloat? = 50
    
    func setup() -> UIView? {
        return nil
    }
}
