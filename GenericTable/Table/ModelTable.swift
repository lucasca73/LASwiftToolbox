//
//  ModelTable.swift
//  GenericTable
//
//  Created by Lucas Araujo on 25/02/20.
//  Copyright © 2020 costa. All rights reserved.
//

import UIKit

class ModelTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var tableView = UITableView()
    private var dataSource = [SectionModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.allowsSelection = true
        
        tableView.setAllConstraints(on: self.view)
        tableView.separatorStyle = .none
        
        tableView.delegate = self
        tableView.dataSource = self
        
        setup()
        reloadView()
    }
    
    func setup() {}
    
    func clear() {
        dataSource.removeAll()
    }
    
    func addSection(newSection: TableSectionProtocol, footer: TableFooterProtocol? = nil) {
        let section = SectionModel(section: newSection, rows: [], footer: footer)
        dataSource.append(section)
    }
    
    func add<Cell: BaseCell, Data: DataModel<Cell>>(_ data: Data...) {
        add(data)
    }
    
    func add<Cell: BaseCell, Data: DataModel<Cell>>(_ data: Data) {
        add([data])
    }
    
    func add<Cell: BaseCell, Data: DataModel<Cell>>(_ data: [Data]) {
        tableView.register(cellType: Cell.self)
        
        if dataSource.isEmpty {
            let section = SectionModel(section: TableSection(), rows: data)
            dataSource.append(section)
        } else {
            if var section = dataSource.last {
                section.rows.append(contentsOf: data)
                dataSource[dataSource.count - 1] = section
            }
        }
    }
    
    func reloadView(animated: Bool = true) {
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = dataSource[indexPath.section].rows[indexPath.row]
        
        // Generic dequeue
        let cell = tableView.dequeueReusableCell(with: data.getType(), for: indexPath)
        cell.selectionStyle = .none
        
        data.setupProtocol(cell: cell)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return dataSource[section].section.setup()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let clicable = tableView.cellForRow(at: indexPath) as? ClicableCell {
            clicable.didClick?(indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // Header
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource[section].section.title
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return dataSource[section].section.height ?? 0
    }
    
    // Footer
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return dataSource[section].footer?.setup()
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return dataSource[section].footer?.title
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return dataSource[section].footer?.height ?? 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return dataSource[section].footer?.height ?? 0
    }
}

protocol DataModelProtocol {
    func getType<T: BaseCell>() -> T.Type
    func setupProtocol<T: BaseCell>(cell: T) -> Void
}

class DataModel<Cell: BaseCell>: DataModelProtocol {
    
    func getType<T: BaseCell>() -> T.Type {
        return Cell.self as! T.Type
    }
    
    func setupProtocol<CellProtocol>(cell: CellProtocol) where CellProtocol: BaseCell {
        if let cell = cell as? Cell {
            self.setup(cell: cell)
        }
    }
    
    func setup(cell: Cell) {
        fatalError("Method must be implemented")
    }
}

protocol TableSectionProtocol {
    func setup() -> UIView?
    var title: String? { get }
    var height: CGFloat? { get }
}

class TableSection: TableSectionProtocol {
    var title: String?
    var height: CGFloat?
    
    func setup() -> UIView? {
        return nil
    }
}

struct SectionModel {
    var section: TableSectionProtocol
    var rows: [DataModelProtocol]
    var footer: TableFooterProtocol?
}

protocol TableFooterProtocol {
    func setup() -> UIView?
    var title: String? { get }
    var height: CGFloat? { get }
}
