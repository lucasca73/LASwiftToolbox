import UIKit

public protocol STCustomDidSelectRowAt {
    func didSelectRowAt(indexPath: IndexPath)
}

public typealias STSectionViewBuilder = (_ section: Int) -> UIView?

open class STGenericTableViewController: UIViewController {
    
    public var reloadAnimation: UITableView.RowAnimation { .none }
    
    open var tableView = UITableView()
    open var sections = [STSectionBuilder]()
    open var willAppearEvent: (() -> Void)?
    open var didAppearSetup: ( (STGenericTableViewController) -> Void )?
    
    open func buildOnWillAppear() -> Bool {
        return true
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        
        if buildOnWillAppear() {
            buildTable()
            tableView.reloadData()
        }
        super.viewWillAppear(animated)
        willAppearEvent?()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didAppearSetup?(self)
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        clearBuilders()
        tableView.reloadData()
    }
    
    deinit {
        debugPrint("[deinit] \(className)")
    }
    
    override open func viewDidLoad() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        
        self.view.backgroundColor = .white
        
        self.view.addSubview(tableView)
        
        tableView.setAllConstraints(on: self.view)
        tableView.separatorStyle = .none
        
        tableView.delegate = self
        tableView.dataSource = self
        super.viewDidLoad()
    }
    
    open func clearBuilders() {
        sections.removeAll()
    }
    
    open func buildTable() {
        clearBuilders()
    }
    
    open func reload(_ ids: String...) {
        reload(ids)
    }
    
    open func reload(_ ids: [String]) {
        
        if tableView.dataSource == nil {
            return
        }
        
        let animation: UITableView.RowAnimation = reloadAnimation
        
        if ids.isEmpty == false {
            
            var indexes = [IndexPath]()
            var indexAppending = [IndexPath]()
            var indexRemoving = [IndexPath]()
            var sectionUpdate = IndexSet()
            
            for (sectionIndex, sectionBuilder) in sections.enumerated() {
                for (builderIndex, builder) in sectionBuilder.builders.enumerated() {
                    for id in ids {
                        if builder.shouldReload(id: id) {
                            
                            if builder.isTable() {
                                let lastCount = tableView.numberOfRows(inSection: sectionIndex)
                                let currentCount = builder.getCount()
                                
                                if currentCount > lastCount {
                                    // adding
                                    for newRow in ((lastCount)..<(currentCount)) {
                                        indexAppending.append(IndexPath(row: newRow, section: sectionIndex))
                                    }
                                    
                                } else if currentCount < lastCount {
                                    // Removing
                                    for removeRow in ((currentCount)..<(lastCount)) {
                                        indexRemoving.append(IndexPath(row: removeRow, section: sectionIndex))
                                    }
                                } else {
                                    // reload
                                    sectionUpdate.insert(sectionIndex)
                                }
                            } else {
                                if let sectionId = sectionBuilder.sectionId, sectionId == id {
                                    sectionUpdate.insert(sectionIndex)
                                } else {
                                    let index = IndexPath(row: builderIndex, section: sectionIndex)
                                    indexes.append(index)
                                }
                            }
                        }
                    }
                }
            }
            
            tableView.beginUpdates()
            
            if indexes.isEmpty == false {
                tableView.reloadRows(at: indexes, with: animation)
            }
            
            if indexAppending.isEmpty == false {
                tableView.insertRows(at: indexAppending, with: animation)
                var secReload = IndexSet()
                for index in indexAppending {
                    secReload.insert(index.section)
                }
                tableView.reloadSections(secReload, with: animation)
            }
            
            if indexRemoving.isEmpty == false {
                tableView.deleteRows(at: indexRemoving, with: animation)
                var secReload = IndexSet()
                for index in indexRemoving {
                    secReload.insert(index.section)
                }
                tableView.reloadSections(secReload, with: animation)
            }
            
            if sectionUpdate.isEmpty == false {
                tableView.reloadSections(sectionUpdate, with: animation)
            }
            
            tableView.endUpdates()
            
        } else {
            tableView.reloadData()
        }
    }
    
    open func addSection( title: String? = nil,
                     height: CGFloat = 0,
                     reloadListener: String? = nil,
                     _ builder: STSectionViewBuilder? = nil ) {
        let sec = STSectionBuilder()
        sec.viewBuilder = builder
        sec.height = height
        sec.title = title
        sec.sectionId = reloadListener
        
        sections.append(sec)
    }
    
    @discardableResult open func add<T: UITableViewCell>(cell: T.Type,
                                                           height: CGFloat = UITableView.automaticDimension,
                                                           reloadListener: String? = nil,
                                                           builder: ((T) -> Void)? = nil ) -> STCellBuilder<T> {
        
        tableView.register(cellType: cell)
        let cellBuilder = STCellBuilder(type: cell, builder: builder, cellId: reloadListener)
        cellBuilder.type = cell
        cellBuilder.height = height
        
        cellBuilder.leadingEdit = nil
        cellBuilder.trailingEdit = nil

        if sections.last?.isTable() ?? true {
            addSection()
        }
        
        if let lastSec = sections.last {
            lastSec.builders.append(cellBuilder)
        }
        
        return cellBuilder
    }
    
    @discardableResult open func addTable<T: UITableViewCell>(cell: T.Type,
                                                                count: Int,
                                                                rowHeight: CGFloat = UITableView.automaticDimension,
                                                                reloadListener: String? = nil,
                                                                builder: ((IndexPath, T) -> Void)? = nil ) -> STTableBuilder<T> {
        
        tableView.register(cellType: cell)
        let tb = STTableBuilder(type: cell, builder: builder, cellId: reloadListener)
        tb.type = cell
        tb.rows = count
        tb.rowHeight = rowHeight
        
        if let sec = sections.last {
            if sec.hasBuilders() {
                addSection(reloadListener: reloadListener)
            }
        } else {
            addSection(reloadListener: reloadListener)
        }
        
        if let lastSec = sections.last {
            lastSec.builders.append(tb)
        }
        
        return tb
    }
    
    @discardableResult open func addTable<T: UITableViewCell>(cell: T.Type,
                                                         counter: @escaping (() -> Int),
                                                         reloadListener: String? = nil,
                                                         builder: ((IndexPath, T) -> Void)? = nil ) -> STTableBuilder<T> {
        
        tableView.register(cellType: cell)
        let tb = STTableBuilder(type: cell, builder: builder, cellId: reloadListener)
        tb.type = cell
        tb.rows = counter()
        tb.counter = counter
        
        if let sec = sections.last {
            if sec.hasBuilders() {
                addSection()
            }
        } else {
            addSection()
        }
        
        if let lastSec = sections.last {
            lastSec.builders.append(tb)
        }
        
        return tb
    }
    
    open func removeSection(id: String, animation: UITableView.RowAnimation = .automatic) {
        
        var removingIndexes = IndexSet()
        
        for (index, section) in sections.enumerated() where section.sectionId == id {
            section.builders.removeAll()
            removingIndexes.insert(index)
        }
        
        // finish if empty
        if removingIndexes.isEmpty {
            return
        }
        
        // Updating sections
        sections = sections.filter({$0.sectionId != id})
        
        // Updating Tableview
        tableView.deleteSections(removingIndexes, with: animation)
    }
    
    open func insertNewSection(id: String, animation: UITableView.RowAnimation = .automatic) {
        
        let tableViewCount = tableView.numberOfSections
        let currentCount = sections.count
        
        if currentCount == tableViewCount {
            var reloadIndexes = IndexSet()
            
            for (index, section) in sections.enumerated() where section.sectionId == id {
                reloadIndexes.insert(index)
            }
            
            // Reload section
            tableView.reloadSections(reloadIndexes, with: animation)
            
        } else if currentCount > tableViewCount {
            var appendingIndexes = IndexSet()
            
            for index in (tableViewCount..<currentCount) {
                appendingIndexes.insert(index)
            }
            
            // Insert section
            tableView.insertSections(appendingIndexes, with: animation)
        } else {
            
            // nothing
            return
        }
    }
    
    open func builder(for indexPath: IndexPath) -> STBuilderProtocol? {
        let section = sections[indexPath.section]
        
        if let tableBuilder = section.getTable() {
            return tableBuilder
        } else {
            // row builder
            return section.builders[indexPath.row]
        }
    }
}

extension STGenericTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].getNumberOfRows()
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section < sections.count {
            let section = sections[indexPath.section]
            var builder: STBuilderProtocol?
            
            builder = section.getTable()
            
            // not a table, get cell
            if builder == nil {
                builder = section.builders[indexPath.row]
            }
            
            if let builder = builder {
                let cell = tableView.dequeueReusableCell(with: builder.getType(), for: indexPath)
                cell.selectionStyle = .none
                builder.callBuilder(path: indexPath, cell: cell)
                return cell
            } else {
                return UITableViewCell()
            }
            
        } else {
            buildTable()
        }
        
        return UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sections[section].viewBuilder?(section)
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sections[section].height
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let section = sections[indexPath.section]
        if let builder = section.getTable() {
            return builder.getHeight()
        } else {
            return section.builders[indexPath.row].getHeight()
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let section = sections[indexPath.section]
        if let builder = section.getTable() {
            return builder.getHeight()
        } else {
            return section.builders[indexPath.row].getHeight()
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let clicableCell = tableView.cellForRow(at: indexPath) as? STCustomDidSelectRowAt {
            clicableCell.didSelectRowAt(indexPath: indexPath)
        }
    }
    
    public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let config = builder(for: indexPath)?.setupLeadingEdit(index: indexPath)
        return config ?? UISwipeActionsConfiguration(actions: [])
    }
    
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let config = builder(for: indexPath)?.setupTrailingEdit(index: indexPath)
        return config ?? UISwipeActionsConfiguration(actions: [])
    }
}

extension UIView {
    func setAllConstraints(on view: UIView, padding: CGFloat = 0) {
        self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding).isActive = true
        self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding).isActive = true
        self.topAnchor.constraint(equalTo: view.topAnchor, constant: padding).isActive = true
    }
}
