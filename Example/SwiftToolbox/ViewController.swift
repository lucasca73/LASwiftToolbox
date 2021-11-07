//
//  ViewController.swift
//  SwiftToolbox
//
//  Created by Lucas Costa Araujo on 11/06/2021.
//  Copyright (c) 2021 Lucas Costa Araujo. All rights reserved.
//

import UIKit
import SwiftToolbox

class ViewController: GenericTableViewController {

    override func buildTable() {
        super.buildTable()
        
        let builder = add(cell: UITableViewCell.self)
        
        builder.buildCell = { cell in
            cell.textLabel?.text = "Hello World"
        }
        
        builder.leadingEdit = {
            let action = UIContextualAction(style: .normal, title: "Print") { _, _, completion in
                debugPrint("Hello world")
                completion(true)
            }
            let actions = UISwipeActionsConfiguration(actions: [action])
            return actions
        }
        
        builder.trailingEdit = {
            let action = UIContextualAction(style: .normal, title: "Another Print") { _, _, completion in
                debugPrint("Hello world2")
                completion(true)
            }
            let actions = UISwipeActionsConfiguration(actions: [action])
            return actions
        }
        
        reload()
    }
}

