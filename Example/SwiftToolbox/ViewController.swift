//
//  ViewController.swift
//  SwiftToolbox
//
//  Created by Lucas Costa Araujo on 11/06/2021.
//  Copyright (c) 2021 Lucas Costa Araujo. All rights reserved.
//

import UIKit
import LASwiftToolbox

class ViewController: STGenericTableViewController {

    lazy var viewModel: ViewModel? = {
        let viewModel = ViewModel()
        viewModel.controller = self
        return viewModel
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.loadInfo()
    }
    
    override func buildTable() {
        super.buildTable()
        
        // Build methods, it helps to see the which comes first
        buildSideButtonsExample()
        buildOptionalCell()
        buildTableExample()
        
        reload()
    }
    
    func buildOptionalCell() {
        
        add(cell: STBaseGenericCell.self) { cell in
            let isOn = self.viewModel?.isTurnedOn ?? false
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = isOn ? "This is on 🌞 \n(click me!)" : "This is off 🌚 \n(click me!)"
            
            cell.didClick = { _ in
                // toggle logic
                self.viewModel?.isTurnedOn = !(self.viewModel?.isTurnedOn ?? false)
                
                // Rebuild the whole table
                self.buildTable()
            }
        }
        
        if viewModel?.isTurnedOn == true {
            add(cell: STBaseGenericCell.self) { cell in
                cell.textLabel?.text = "This cell is optional :), if the condition does not succeed, you can build again and this will not be on the table anymore."
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.textAlignment = .center
            }
        }
    }
    
    func buildTableExample() {
        
        if viewModel?.messages.isEmpty == true {
            add(cell: STBaseGenericCell.self) { cell in
                cell.textLabel?.text = "Loading fake messages... :)"
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.textAlignment = .center
            }
        } else {
        
            addSection(height: 50) { section in
                let customHeader = UIView()
                customHeader.backgroundColor = .systemBlue.withAlphaComponent(0.35)
                
                let label = UILabel(frame: CGRect(x: 24, y: 0, width: 200, height: 50))
                customHeader.addSubview(label)
                label.textColor = .white
                label.text = "Custom header view"
                
                return customHeader
            }
            
            addTable(cell: UITableViewCell.self, count: viewModel?.messages.count ?? 0) { index, cell in
                let msg = self.viewModel?.messages[index.row]
                cell.textLabel?.text = msg
                cell.textLabel?.numberOfLines = 0
            }
        }
    }
    
    func buildSideButtonsExample() {
        
        // System Section
        addSection(title: "As a System Section", height: 40)
        
        let builder = add(cell: UITableViewCell.self)
        
        // Separate config block
        builder.buildCell = { cell in
            cell.textLabel?.text = "Side buttons example (swipe both sides <- ->)"
            cell.textLabel?.numberOfLines = 0
            cell.contentView.backgroundColor = .systemGreen.withAlphaComponent(0.2)
        }
        
        // Separate config block
        builder.leadingEdit = {
            let action = UIContextualAction(style: .normal, title: "Print") { _, _, completion in
                debugPrint("Hello world")
                completion(true)
            }
            let actions = UISwipeActionsConfiguration(actions: [action])
            return actions
        }
        
        // Separate config block
        builder.trailingEdit = {
            let action = UIContextualAction(style: .normal, title: "Another Print") { _, _, completion in
                debugPrint("Hello world2")
                completion(true)
            }
            let actions = UISwipeActionsConfiguration(actions: [action])
            return actions
        }
    }
}

