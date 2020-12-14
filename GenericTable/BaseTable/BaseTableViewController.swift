import UIKit

public protocol CustomDidSelectRowAt {
    func didSelectRowAt(indexPath: IndexPath)
}

typealias SectionViewBuilder = (Int) -> UIView?

class BaseTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView = UITableView()
    var sections = [SectionBuilder]()
    var willAppearEvent: (() -> Void)?
    var didAppearSetup: ( (BaseTableViewController) -> Void )?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func buildOnWillAppear() -> Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.hideBarButtonBackButtonTitle()
        
        if buildOnWillAppear() {
            buildTable()
            tableView.reloadData()
        }
        super.viewWillAppear(animated)
        willAppearEvent?()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didAppearSetup?(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        clearBuilders()
        tableView.reloadData()
    }
    
    deinit {
        debugPrint("[deinit] \(className)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        
        self.view.backgroundColor = .white
        
        self.view.addSubview(tableView)
        
        tableView.setAllConstraints(on: self.view)
        tableView.separatorStyle = .none
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func clearBuilders() {
        sections.removeAll()
    }
    
    func buildTable() {
        clearBuilders()
    }
    
    /// DEPRECIADO
    func reload(id: String, animation: UITableView.RowAnimation = .automatic) {
        reload(id)
    }
    
    func reload(_ ids: String...) {
        
        if tableView.dataSource == nil {
            return
        }
        
        let animation: UITableView.RowAnimation = .automatic
        
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
            
            // Inicia atualizacao da table
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
            
            // Finaliza atualizacao da table
            tableView.endUpdates()
            
        } else {
            tableView.reloadData()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].getNumberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section < sections.count {
            let section = sections[indexPath.section]
            var builder: BuilderProtocol?
            
            builder = section.getTable()
            
            // not table, get cell
            if builder == nil {
                builder = section.builders[indexPath.row]
            }
            
            if let b = builder {
                let cell = tableView.dequeueReusableCell(with: b.getType(), for: indexPath)
                cell.selectionStyle = .none
                b.callBuilder(path: indexPath, cell: cell)
                return cell
            } else {
                return UITableViewCell()
            }
            
        } else {
            buildTable()
        }
        
        return UITableViewCell()
    }
    
    func addSection( title: String? = nil, height: CGFloat = 0, reloadListener: String? = nil, _ builder: SectionViewBuilder? = nil ) {
        let sec = SectionBuilder()
        sec.viewBuilder = builder
        sec.height = height
        sec.title = title
        sec.sectionId = reloadListener
        
        sections.append(sec)
    }
    
    func add<T: UITableViewCell>(cell: T.Type, height: CGFloat = UITableView.automaticDimension, reloadListener: String? = nil, builder: ((T) -> Void)? = nil ) {
        
        tableView.register(cellType: cell)
        let tb = CellBuilder(type: cell, builder: builder, cellId: reloadListener)
        tb.type = cell
        tb.height = height

        if sections.last?.isTable() ?? true {
            // Caso não po@objc ssua section ou seja uma table, deve-se criar uma nova secção
            addSection()
        }
        
        if let lastSec = sections.last {
            lastSec.builders.append(tb)
        }
    }
    
    func addTable<T: UITableViewCell>(cell: T.Type, count: Int, rowHeight: CGFloat = UITableView.automaticDimension, reloadListener: String? = nil, builder: ((IndexPath, T) -> Void)? = nil ) {
        
        tableView.register(cellType: cell)
        let tb = TableBuilder(type: cell, builder: builder, cellId: reloadListener)
        tb.type = cell
        tb.rows = count
        tb.rowHeight = rowHeight
        
        // Caso não tenha section ou já possua builders
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
    }
    
    @discardableResult func addTable<T: UITableViewCell>(cell: T.Type, counter: @escaping (() -> Int), reloadListener: String? = nil, builder: ((IndexPath, T) -> Void)? = nil ) -> TableBuilder<T> {
        
        tableView.register(cellType: cell)
        let tb = TableBuilder(type: cell, builder: builder, cellId: reloadListener)
        tb.type = cell
        tb.rows = counter()
        tb.counter = counter
        
        // Caso não tenha section ou já possua builders
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
    
    func removeSection(id: String, animation: UITableView.RowAnimation = .automatic) {
        
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
    
    func insertNewSection(id: String, animation: UITableView.RowAnimation = .automatic) {
        
        let tableViewCount = tableView.numberOfSections
        let currentCount = sections.count
        
        if currentCount == tableViewCount {
            var reloadIndexes = IndexSet()
            
            for (index, section) in sections.enumerated() {
                if section.sectionId == id {
                    reloadIndexes.insert(index)
                }
            }
            
            // Reload section
            tableView.reloadSections(reloadIndexes, with: animation)
            
        } else if currentCount > tableViewCount {
            var appendingIndexes = IndexSet()
            
            for i in (tableViewCount..<currentCount) {
                appendingIndexes.insert(i)
            }
            
            // Insert section
            tableView.insertSections(appendingIndexes, with: animation)
        } else {
            
            // nothing
            return
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sections[section].viewBuilder?(section)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sections[section].height
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let section = sections[indexPath.section]
        if let builder = section.getTable() {
            return builder.getHeight()
        } else {
            return section.builders[indexPath.row].getHeight()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let section = sections[indexPath.section]
        if let builder = section.getTable() {
            return builder.getHeight()
        } else {
            return section.builders[indexPath.row].getHeight()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let clicableCell = tableView.cellForRow(at: indexPath) as? CustomDidSelectRowAt {
            clicableCell.didSelectRowAt(indexPath: indexPath)
        }
    }
}
