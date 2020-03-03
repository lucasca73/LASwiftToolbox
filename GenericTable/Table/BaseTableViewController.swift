//
//  BaseTableViewController.swift
//  GenericTable
//
//  Created by Lucas Araujo on 22/02/20.
//  Copyright © 2020 costa. All rights reserved.
//

import UIKit

typealias SectionViewBuilder = (Int) -> UIView?

class BaseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var tableView = UITableView()
    private var sections = [SectionBuilder]()
    
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
        
        reloadPlaceholder(animated: false)
    }
    
    // Runs when reloadView is called
    func setupView() {
        fatalError("Method setupView must be overridden")
    }
    
    // Empty placeholder
    func setupPlaceholder() {}
    
    // Remove all current builders
    func clearBuilders() {
        sections.removeAll()
    }
    
    // Update view with current builders
    func updateView() {
        tableView.reloadData()
    }
    
    func reloadView(animated: Bool = true) {
        clearBuilders()
        setupView()
        tableView.reloadData()
        
        if animated {
            UIView.animate(withDuration: 0.23) {
                self.tableView.layoutIfNeeded()
            }
        }
    }
    
    func reloadPlaceholder(animated: Bool = true) {
        clearBuilders()
        setupPlaceholder()
        tableView.reloadData()
        
        if animated {
            UIView.animate(withDuration: 0.23) {
                self.tableView.layoutIfNeeded()
            }
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].getNumberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = sections[indexPath.section]
        var builder: BuilderProtocol?
        
        builder = section.getTable()
        
        if builder == nil{
            builder = section.builders[indexPath.row]
        }
        
        // Generic dequeue
        let cell = tableView.dequeueReusableCell(with: builder!.getType(), for: indexPath)
        cell.selectionStyle = .none
        
        // Placeholder loading ending
        if let c = cell as? BaseCell {
            c.endLoading()
        }
        
        // Cell configure callback
        builder!.callBuilder(path: indexPath, cell: cell)
        
        return cell
    }
    
    func addSection( title: String? = nil, height: CGFloat = 0, _ builder: SectionViewBuilder? = nil ) {
        let sec = SectionBuilder()
        sec.viewBuilder = builder
        sec.height = height
        sec.title = title
        
        sections.append(sec)
    }
    
    func add<T:UITableViewCell>(cell: T.Type, builder: ((T) -> Void)? = nil ) {
        
        tableView.register(cellType: cell)
        let tb = CellBuilder(type: cell, builder: builder)
        tb.type = cell

        if sections.last?.isTable() ?? true {
            addSection()
        }
        
        if let lastSec = sections.last {
            lastSec.builders.append(tb)
        }
    }
    
    func addPlaceholder<T:BaseCell>(_ cell: T.Type) {
        
        tableView.register(cellType: cell)
        let tb = CellBuilder(type: cell) { cell in
            cell.setupPlaceholder()
        }
        tb.type = cell

        if sections.last?.isTable() ?? true {
            addSection()
        }
        
        if let lastSec = sections.last {
            lastSec.builders.append(tb)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let clicable = tableView.cellForRow(at: indexPath) as? ClicableCell {
            clicable.didClick?(indexPath)
        }
    }
    
    func addTable<T:UITableViewCell>(cell: T.Type, count: Int, builder: ((IndexPath, T) -> Void)? = nil ) {
        
        tableView.register(cellType: cell)
        let tb = TableBuilder(type: cell, builder: builder)
        tb.type = cell
        tb.rows = count
        
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
    
    func addTable<Cell: BaseCell, Data: DataModel<Cell>>(data: [Data]) {
        
        tableView.register(cellType: Cell.self)
        let tb = TableBuilder(type: Cell.self, builder: { index, cell in
            let builder = data[index.row]
            builder.setup(cell: cell)
        })
        tb.type = Cell.self
        tb.rows = data.count
        
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sections[section].viewBuilder?(section)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sections[section].height
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

protocol BuilderProtocol {
    func callBuilder(path:IndexPath, cell: UITableViewCell)
    func getType<U>() -> U.Type where U: UITableViewCell
    func getCount() -> Int
    func isTable() -> Bool
}

class CellBuilder<T>: BuilderProtocol where T: UITableViewCell {
    
    typealias BuildCell = ((T) -> Void)
    
    var buildCell: BuildCell?
    var type: T.Type
    
    init(type: T.Type, builder: BuildCell?) {
        self.buildCell = builder
        self.type = type
    }
    
    func callBuilder(path:IndexPath, cell: UITableViewCell) {
        buildCell?(cell as! T)
    }
    
    func getType<U>() -> U.Type where U : UITableViewCell {
        return type as! U.Type
    }
    
    func getCount() -> Int {
        return 1
    }
    
    func isTable() -> Bool {
        return false
    }
}

class TableBuilder<T>: BuilderProtocol where T: UITableViewCell {
    
    typealias buildTable = ((IndexPath, T) -> Void)
    
    var builder: buildTable?
    var rows: Int = 1
    var type: T.Type
    
    init(type: T.Type, builder: buildTable?) {
        self.builder = builder
        self.type = type
    }
    
    func callBuilder(path:IndexPath, cell: UITableViewCell) {
        builder?(path, cell as! T)
    }
    
    func getType<U>() -> U.Type where U : UITableViewCell {
        return type as! U.Type
    }
    
    func getCount() -> Int {
        return rows
    }
    
    func isTable() -> Bool {
        return true
    }
}

class SectionBuilder {
    
    var height: CGFloat = 0
    var title: String?
    var viewBuilder: SectionViewBuilder?
    var builders = [BuilderProtocol]()
    
    func isTable() -> Bool {
        
        if builders.isEmpty {
            return false
        }
        
        if let b = builders.first {
            if b.isTable() {
                return true
            }
        }
        
        return false
    }
    
    func getTable() -> BuilderProtocol? {
        if isTable() {
            return builders[0]
        }
        
        return nil
    }
    
    func getNumberOfRows() -> Int {
        
        var count = 0
        for i in builders {
            count += i.getCount()
        }
        
        return count
    }
    
    func hasBuilders() -> Bool {
        return builders.isEmpty == false
    }
}

protocol ClicableCell {
    var didClick: ( (IndexPath) -> Void )? { get set }
}

class BaseCell: UITableViewCell, ClicableCell {
    var didClick: ((IndexPath) -> Void)?
    var loadingPlaceholders = [TrackingObject]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        didClick = nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        didClick = nil
    }
    
    func endLoading() {
        for i in loadingPlaceholders {
            i.end?()
        }
        loadingPlaceholders.removeAll()
    }
    
    func addLoading(on view: UIView) {
        loadingPlaceholders.append(view.placeholderAnimation())
    }
    
    func setupPlaceholder() {
        addLoading(on: self)
    }
}

// Extension

class TrackingObject {
    var end: (() -> Void)?
}

extension UIView {
    
    func placeholderAnimation() -> TrackingObject {
        
        let key = "animation:\(self.className)"
        let originalBackgroundColor = self.backgroundColor
        self.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.white.withAlphaComponent(0).cgColor,
                                UIColor.white.withAlphaComponent(0.15).cgColor,
                                UIColor.white.withAlphaComponent(0.25).cgColor,
                                UIColor.white.withAlphaComponent(0.1).cgColor]
        
        gradientLayer.locations = [0, 0.75, 0.9, 1]
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = layer.cornerRadius
        gradientLayer.isHidden = false
        
        // Comment if vertical
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0);
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0);
        
        self.layer.addSublayer(gradientLayer)
        self.clipsToBounds = true
        
        let anim = CABasicAnimation(keyPath: "transform.translation.x")
        anim.duration = 2
        anim.fromValue = -frame.width
        anim.toValue = frame.width*2
        anim.repeatCount = Float.infinity

        gradientLayer.add(anim, forKey: key)
        
        var textColor: UIColor?
        
        if let label = self as? UILabel {
            textColor = label.textColor
            label.textColor = .clear
        }
        
        let tracking = TrackingObject()
        tracking.end = {
            gradientLayer.removeAnimation(forKey: key)
            gradientLayer.removeFromSuperlayer()
            self.backgroundColor = originalBackgroundColor
            if let label = self as? UILabel, textColor != nil {
                label.textColor = textColor
            }
        }
        
        return tracking
    }
    
    func setAllConstraints(on view: UIView, padding: CGFloat = 0) {
        
        self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding).isActive = true
        self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding).isActive = true
        self.topAnchor.constraint(equalTo: view.topAnchor, constant: padding).isActive = true
    }
}


public extension UITableView {
    func register<T: UITableViewCell>(cellType: T.Type, bundle: Bundle? = nil) {
        let className = cellType.className
        
        if Bundle.main.path(forResource: className, ofType: "nib") != nil {
            let nib = UINib(nibName: className, bundle: bundle)
            register(nib, forCellReuseIdentifier: className)
        } else {
            register(cellType, forCellReuseIdentifier: className)
        }
    }
    
    func register<T: UITableViewCell>(cellTypes: [T.Type], bundle: Bundle? = nil) {
        cellTypes.forEach { register(cellType: $0, bundle: bundle) }
    }
    
    func dequeueReusableCell<T: UITableViewCell>(with type: T.Type, for indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withIdentifier: type.className, for: indexPath) as! T
    }
}

public protocol ClassNameProtocol {
    static var className: String { get }
    var className: String { get }
}

public extension ClassNameProtocol {
    static var className: String {
        return String(describing: self)
    }
    
    var className: String {
        return type(of: self).className
    }
}

extension NSObject: ClassNameProtocol {}

